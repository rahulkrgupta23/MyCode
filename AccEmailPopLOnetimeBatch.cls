global class AccEmailPopLOnetimeBatch implements Database.Batchable<sObject> {
    /*public Set<Id> recIds = new Set<Id>();
	global AccEmailPopLOnetimeBatch(Set<Id> ids){
    recIds = ids ;
	}*/
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='Select Id,PersonEmail,RecordtypeId,Email__c,IsPersonAccount From Account Where IsPersonAccount=True '/*+ (recIds.isEmpty() ? '' : 'AND Id IN : recIds')*/;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Account> scope){
        Map<Id,List<Opportunity>> oppMap = getOpp(scope);
        //System.debug('@@@1  '+oppMap);
        for(Account a : scope){
            for(Opportunity o : (!oppMap.isEmpty() && oppMap.containskey(a.id)) ? oppMap.get(a.Id) : new List<Opportunity>()){
                //System.debug('@@@2  '+o);
                if( string.isBlank(a.PersonEmail) || string.isEmpty(a.PersonEmail) ){
                    a.PersonEmail = string.isNotBlank(o.Email__c) ? o.Email__c : '';
                }//System.debug('@@@3  '+a.PersonEmail);
            }
        }
        Database.update(scope,false);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    @TestVisible
    public static Map<Id,List<Opportunity>> getOpp(List<Account> accounts){
        Map<Id,List<Opportunity>> oppMap = new Map<Id,List<opportunity>>();
        for(Opportunity o: [Select Id, Email__c,AccountId From Opportunity Where Email__c!=Null And AccountId IN : accounts]){
            if(!oppMap.containskey(o.AccountId)){
                oppMap.put(o.AccountId, new List<Opportunity>());
            }
            List<Opportunity> oppList = oppMap.get(o.AccountId);
            oppList.add(o);
            oppMap.put(o.AccountId,oppList);
        }
        return oppMap;
    }
    
}