public without sharing class PersonAccountEmailPopulate {
    
    public static void process(List<Lead> triggerNew){
        Map<Id,Account> accleadMap = new Map<Id,Account>();
        Set<Id> leadAccId = new Set<Id>();
        Set<Id> leadOppId = new Set<Id>();
        List<Account> accList = new List<Account>();
        for(Lead l : triggerNew){
            if( l.isConverted && l.ConvertedAccountId!=Null){
               leadAccId.add(l.ConvertedAccountId);
            }
            if( l.isConverted && l.ConvertedOpportunityId!=Null){
                leadOppId.add(l.ConvertedOpportunityId);
            }  
        } 
        Map<Id,Account> accMap = getAcc(leadAccId) ;
        Map<Id,Opportunity> oppMap = getOpp(leadOppId);
        for(Lead l : triggerNew){
            Account a = accMap.containsKey(l.ConvertedAccountId) ? accMap.get(l.ConvertedAccountId) : new Account();
            Opportunity o = oppMap.containsKey(l.ConvertedOpportunityId)?  oppMap.get(l.ConvertedOpportunityId) : new Opportunity();
            if( l.isConverted && (string.isBlank(l.email__c)|| string.isBlank(l.Email)) && a!=Null ){    
                if(a.IsPersonAccount && string.isBlank(a.PersonEmail) ){
                    a.PersonEmail =  string.isNotBlank(o.Email__c) ? o.Email__c : '' ;
                }
                accleadMap.put(a.Id,a);
                //system.debug(' @@@@@ Acc Lead Map '+accleadMap.values());
            }
        }
        Database.update(accleadMap.values(),False);
    }
    
    @TestVisible
    public static Map<Id,Account> getAcc(Set<Id> Ids){
        return new Map<Id,Account>([Select Id,PersonEmail,Email__c,IsPersonAccount From Account Where IsPersonAccount=True And PersonEmail=Null And Id IN:Ids]);
    }
    @TestVisible
    public static Map<Id,Opportunity> getOpp(Set<Id> Ids){
        return new Map<Id,Opportunity>([Select Id,Email__c From Opportunity  Where Id IN:Ids]);
    }
}