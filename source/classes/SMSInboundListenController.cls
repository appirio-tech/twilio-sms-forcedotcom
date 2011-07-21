public class SMSInboundListenController {
    
    public String response {get; set;}
    SMS_Message__c msg;
    Contact con;
 
    public void processMessage(){
        //Instantiate new message object
        msg = new SMS_Message__c();        
        
        //Setup default reponse
        response = '<Response><Sms>Thanks, you rock.</Sms></Response>'; 
            
        //Twilio passes all the data to this page in url parameters, get those and store in map  
        Map<String,String> parameters = ApexPages.currentPage().getParameters();    
        
        /*Attempt to locate contact in system with mobile number of inbound SMS, also query at least one
        SMS related to the contact. Will use this for dupe logic.*/
        List<Contact> consWithSMS = new List<Contact>();
        List<Contact> contacts = new List<Contact>(); 
        
        for(Contact con : [select Id, OwnerId, (Select Id from SMS_Message__r limit 1) from Contact where MobilePhone = :parameters.get('From')]){
            //Add contact to correct list based on if they have existing SMS messages attached to them
            if(con.SMS_Message__r.size() > 0){
                consWithSMS.add(con);
            }else{
                contacts.add(con);
            }
        } 
        
        //If there are contacts with existing sms messages use the first contact return
        if(consWithSMS.size() > 0){
            con = consWithSMS[0];
            msg.OwnerId = consWithSMS[0].OwnerId;
            msg.Contact__c = consWithSMS[0].Id;
        }else if(contacts.size() > 0){
            //Else attempt to use first contact with match phone but no existing messages
            con = contacts[0];
            msg.OwnerId = contacts[0].OwnerId;
            msg.Contact__c = contacts[0].Id;
        }      
        
        //Identify record type for inbound sms messages
        Id inboundRecordTypeId = [select Id from RecordType where DeveloperName = 'Inbound' AND sObjectType = 'SMS_Message__c' limit 1].Id;
        
        //Apply infromation from Twilio to SMS Message object before insertion
        msg.RecordTypeId = inboundRecordTypeId;
        msg.Sid__c = parameters.get('SmsSid');
        msg.AccountSid__c = parameters.get('AccountSid');
        msg.From__c = parameters.get('From');
        msg.To__c = parameters.get('To');
        msg.Message__c = parameters.get('Body');
        msg.Date_Sent__c = system.now();
        msg.Direction__c = 'Inbound';
        msg.Status__c = 'Unread';
        msg.Price__c = 0.02;
        
        //If user replied with STOP, make SMS_Enabled__c false on contact
        Set<String> unsubscribeWords = new Set<String>();        
        
        //Get and process unsubscribe keywords from custom settings, convert to lowercase
        Twilio_Settings__c settings = Twilio_Settings__c.getInstance('main');
        if(settings.Unsubscribe_Keywords__c != null){
            for(String s : settings.Unsubscribe_Keywords__c.split(',')){
                unsubscribeWords.add(s.toLowerCase());
            }   
        }
        
        //If messages is the same as one of the unsubscribe keyworks uncheck SMS_Enabled field
        if(unsubscribeWords.contains(msg.Message__c.toLowerCase()) && con != null){
            response = '<Response><Sms>Okay, we won\'t annoying you any more.</Sms></Response>'; 
            con.SMS_Enabled__c = false;
            update con;
        }
        
        //Only insert the new SMS message if there was a smsID present in URL, if not this request isn't coming from Twilio, ie: someone viewing the page
        if(msg.Sid__c != null){
        	insert msg;
        }
    }
}