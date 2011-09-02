<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SMS_Failed_Delivery</fullName>
        <description>SMS Failed Delivery</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SMS_Templates/SMS_Failed_Delivery</template>
    </alerts>
    <alerts>
        <fullName>SMS_Successfully_Sent</fullName>
        <description>SMS Successfully Sent</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SMS_Templates/SMS_Successfully_Sent</template>
    </alerts>
    <rules>
        <fullName>SMS Failed Delivery</fullName>
        <actions>
            <name>SMS_Failed_Delivery</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SMS_Message__c.Status__c</field>
            <operation>equals</operation>
            <value>Failed</value>
        </criteriaItems>
        <criteriaItems>
            <field>SMS_Message__c.Notification__c</field>
            <operation>equals</operation>
            <value>Failure,Both</value>
        </criteriaItems>
        <description>Sent to owner of SMS message when delivery fails.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SMS Successfully Sent</fullName>
        <actions>
            <name>SMS_Successfully_Sent</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SMS_Message__c.Status__c</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <criteriaItems>
            <field>SMS_Message__c.Notification__c</field>
            <operation>equals</operation>
            <value>Success,Both</value>
        </criteriaItems>
        <description>Sent to owner of SMS message when delivery is successful.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
