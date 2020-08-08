public class PaymentAfterTriggerHandler {
    public static Set<Id> processIds = new Set<Id>();
    
    public static void process(List<Payments__C>triggerNew,Map<Id,Payments__C>triggerOldMap) {
        Set<Id> credId = new Set<Id>();
        Map<Id,Creditor__c> payCredMap = new Map<Id,Creditor__c>();
        for(Payments__c p : Trigger.isDelete ? triggerOldMap.values() : triggerNew){
            if( Trigger.isInsert || (Trigger.isUpdate && hasfieldChange(p,triggerOldMap.get(p.Id))) ) {    
                credId.add(p.Creditor__c);
            }
        } 
        Map<Id,List<Payments__c>> PaymentMap = processIds.isEmpty() ? getCreditorPayment(credId) : new Map<Id,List<Payments__c>>();
        for(Id key : PaymentMap.keyset()){
           Decimal totalamount = 0.00;
            for(Payments__c p : processIds.isEmpty() ? PaymentMap.get(key) : new List<Payments__c>() ){
                 totalamount = totalamount + p.Payment_Sent_Amount__c;
                 //system.debug('@@@@ total '+totalamount);
                if(Trigger.isUpdate && triggerOldMap.containsKey(p.Id)){
                    processIds.add(p.Id);
                }
            }
            //System.debug('@@@@ Key '+key);
            Creditor__c cred = new Creditor__c(Id=Key,Total_Payments_Made_to_Creditor__c = totalamount);
            payCredMap.put(key,cred); //System.debug('@@@@ CredPay '+cred.Total_Payments_Made_to_Creditor__c);
            //System.debug('@@@@ payCredMap  '+payCredMap);
        }
        if(!payCredMap.isEmpty()){
           Database.update(payCredMap.values(),False);
        }
    }
    
    @TestVisible
    private static Map<Id,List<Payments__c>> getCreditorPayment(Set<Id> scope){
        Map<Id,List<Payments__c>> PaymentMap = new Map<Id,List<Payments__c>>();
        for(Payments__c pay : [Select Id,Payment_Sent__c,Payment_Sent_Amount__c,Creditor__c From Payments__c Where 
                               Payment_Sent__c = TRUE AND Payment_Sent_Amount__c!=Null  AND RECORDTYPE.NAME ='Creditor Payment' AND Creditor__c In:scope]){
            if(!PaymentMap.containsKey(pay.Creditor__c)){
                PaymentMap.put(pay.Creditor__c, new List<Payments__c>());
            }
            List<Payments__c> PaymentCredList = PaymentMap.get(pay.Creditor__c);
            PaymentCredList.add(pay);
            PaymentMap.put(pay.Creditor__c,PaymentCredList);
        }
        return PaymentMap;
    }
    @TestVisible
    private static Boolean hasfieldChange(Payments__c pNew,Payments__c pOld){
        return( (pNew.Payment_Sent__c!=pOld.Payment_Sent__c || pNew.Payment_Sent_Amount__c!=pOld.Payment_Sent_Amount__c) );
    }

}