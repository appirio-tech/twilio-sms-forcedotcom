public class TwilioSettingsController {
    
    public Twilio_Settings__c settings {get; set;}

    public TwilioSettingsController(){
        settings = Twilio_Settings__c.getInstance('main');
        if(settings == null){
            settings = new Twilio_Settings__c(Name = 'main');
        }
    
    }

    public void save() {
        upsert settings;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Settings saved.'));
    }

}