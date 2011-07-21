public class SMSStatusListenController {
    
    /*This class is linked to page exposed as force.com site and listens for SMS delivery status callback */
    
    SMS_Message__c msg;

    public void updateStatus() {
        //Twilio passes all information as URL parameters so we can simply add these to a map and use as needed
        Map<String,String> parameters = ApexPages.currentPage().getParameters();
        
        //Find the message__c record that needs to be updated
        List<SMS_Message__c> messsages = [select Status__c from SMS_Message__c where Sid__c = :parameters.get('SmsSid')];
        if(messsages.size() > 0){
            msg = messsages[0];
            msg.Status__c = parameters.get('SmsStatus');
            
            //Updated date sent if messages was sent succcessfully
            if(parameters.get('SmsStatus') != null && parameters.get('SmsStatus').toLowerCase() == 'sent'){
            	msg.Date_Sent__c = system.now();
            }
        }
        
       	//Updated message if one was found
        if(msg != null){
            update msg;
        }
    }
}