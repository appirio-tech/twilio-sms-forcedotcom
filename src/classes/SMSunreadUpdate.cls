public class SMSunreadUpdate {

    SMS_Message__c msg;
    
    public SMSunreadUpdate(ApexPages.StandardController controller) {
        msg = (SMS_Message__c)controller.getRecord();
    }
    
    public void checkStatus(){
        //If message is unread, change status to read
        if(msg.Status__c == 'Unread'){
            msg.Status__c = 'Read';
            update msg;
        }
    }
}