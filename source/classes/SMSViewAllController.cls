public class SMSViewAllController {

    public List<SMS_Message__c> messages {get; set;}

    public SMSViewAllController(ApexPages.StandardController controller) {
        Contact con = (Contact)controller.getRecord();
        
        //Query all messges related to a contact, limit to 500
        messages = [select Id, Message__c, Status__c, Direction__c, Date_Sent__c from SMS_Message__c where Contact__c = :con.Id order by Date_Sent__c desc limit 500];
    }

}