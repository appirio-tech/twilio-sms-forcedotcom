global class SMSSendController {

    public SMS_Message__c msg {get; set;}
    public Boolean updateMobile {get; set;}
    Contact con;
    public String response {get; set;}
    
    //Get Twilio setting from custom settings object
    Twilio_Settings__c settings = Twilio_Settings__c.getInstance('main');
    String ACCOUNT_SID = settings.Account_Sid__c; 
    String AUTH_TOKEN = settings.Auth_Token__c;   
    String TWILIO_SMS_ENDPOINT = 'https://api.twilio.com/2010-04-01/Accounts/'+ACCOUNT_SID+'/SMS/Messages';
    String TWILIO_SMS_FROM_NUMBER = settings.Primary_Phone__c;    
    String STATUS_CALLBACK_URL = settings.Twilio_Status_Listen_Page__c; 

    //Contructor
    public SMSSendController(ApexPages.StandardController controller) {
        msg = (SMS_Message__c)controller.getRecord();
    }
    
    public Contact getCon(){
        if(con == null){
            //if message is related to existing contact query that contact
            if(msg.Contact__c != null){
                con = [select Id, Name, Title, MobilePhone, SMS_Enabled__c from Contact where Id = :msg.Contact__c];
        
                //Default phone number to mobile on contact
                msg.To__c = con.MobilePhone;
            }else{
                //Instantiate a new empty contact
                con = new Contact();
            }
        }
        return con;
    }
    
    public PageReference SendSMS(){
        //Do validation of message length first
        if(msg.Message__c.length() > 160){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Message length must be less than 160 characters.'));
            return null;
        }
        
        //First update the mobile number if user checks box on vf page update mobile box checked
        if(updateMobile == true){
            con.MobilePhone = msg.To__c;
            update con;
        }
        
        String result = smsCallout(msg,false);
        
        if(result == 'success'){
            //Return user to previous page
            PageReference retPage = new PageReference('/'+ ApexPages.currentPage().getParameters().get('retURL'));
            retPage.setRedirect(true);
            return retPage;
        }else{
            //Else return error message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There was an error sending the message. Error code: ' + result ));
            return null; 
        }
    }
    
    //Webservice method that can be called from Resend button on outbound layout
    webservice static String resendSMS(Id msgId){
        String response;
        
        //Query info from message required for resend
        SMS_Message__c resendMsg = [select Id, To__c, Message__c from SMS_Message__c where Id = :msgId];
        
        //Since this is a static method, we need to instanstiate a new instances of the SMSSendController class and then call methods.
        ApexPages.StandardController sc = new ApexPages.StandardController(resendMsg );
        SMSSendController controller = new SMSSendController(sc);
        
        //Make smsCallout, tru param indicates this is a resend
        String result = controller.smsCallout(resendMsg,true);
        
        if(result == 'success'){
            response = 'Message has been resent.';
        }else{
            response = 'Uh oh. There was a problem resending the message. Error code: ' + result;
        }
    
        return response;
    }
    
    public string smsCallout(SMS_Message__c message, Boolean resend){
        //Create new HTTP request object
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TWILIO_SMS_ENDPOINT);
        req.setMethod('POST');
        
        //Setup basic authorization header
        Blob headerValue = Blob.valueOf(ACCOUNT_SID+ ':' + AUTH_TOKEN);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        
        //Create body of the the request
        String body = 'From=+'+TWILIO_SMS_FROM_NUMBER+'&To='+message.To__c+'&Body='+message.Message__c+'&StatusCallback='+ STATUS_CALLBACK_URL;
        req.setBody(body);
        
        //Make the callout to Twilio
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        //If response was a success insert the message and return 'success' response
        if(res.getStatusCode() == 201){
            //Updated messsage with information returned from twilio
            DOM.Document doc = new DOM.Document();
            doc.load(res.getBody());
            Dom.XMLNode twilioResponse= doc.getRootElement();
            Dom.XMLNode smsMessage = twilioResponse.getChildElement('SMSMessage',null);

            message.Sid__c = smsMessage.getChildElement('Sid',null).getText(); 
            message.AccountSid__c = smsMessage.getChildElement('AccountSid',null).getText(); 
            message.To__c = smsMessage.getChildElement('To',null).getText();  
            message.From__c = smsMessage.getChildElement('From',null).getText(); 
            message.Status__c = smsMessage.getChildElement('Status',null).getText(); 
            if(smsMessage.getChildElement('Price',null).getText() != ''){
                message.Price__c = Decimal.valueOf(smsMessage.getChildElement('Price',null).getText()); 
            }
            message.Direction__c = 'Outbound';
            message.Debug__c = res.getBody();
            
            //Insert if new message, update if resend
            upsert message;
            
            /*Based on response, if the formatting of twilio number does not equal contact number, update the contact phone number. This needs to be
            done so future sms messages from twilio can be associated with this contact number*/
            if(resend == false && con.MobilePhone != message.To__c){
                con.MobilePhone = message.To__c;
                update con;             
            }
                        
            return 'success';
        }else{
            //return failure code
            return res.getBody().substring(res.getBody().indexOf('<Code>') + 6,res.getBody().indexOf('</Code>'));  
        }
    }
}