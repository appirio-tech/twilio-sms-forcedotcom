Twilio SMS Challange

Demo videos:
Long, has much more detail: http://www.youtube.com/watch?v=TCiLXCOAkQ8
Short, brief overview: http://www.youtube.com/watch?v=Rzb3ASjO7ac

Features:
Twilio Settings tab that updates custom settings object with all necessay Twilio information.
SMS Messages tab for custom object.
Custom SMS_Message__c object hold all inbound and outbound messages, related to Contact.
Character counter when sending a SMS message displaying remaining number characters available.
Option to update Contact with new Mobile Phone # on send of a SMS message.
Optional workflow email on success/failure of a SMS delivery.
Opt out functionality that accepts multiple keywords (STOP,QUIT,ect). Controlled on Twilio settings page.
Resend button for outbound messages that failed.
Reply button for inbound messages.
Automatic read/unread status. Status will be automatically set to Read after it is viewed for inbound messages.
View All Visualforce page that displays 500 most resent messages in easy to consume format.

Other Notes:
Apologies for not being able to supply an installable packaged but I decided to put focus towards additional features. I think the long demo video above should clearly demostrate most of the added features. 

All code should be documented with comments to make review easier. 