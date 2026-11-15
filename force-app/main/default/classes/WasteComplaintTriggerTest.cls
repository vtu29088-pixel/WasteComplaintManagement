@isTest
private class WasteComplaintTriggerTest {

    private static Waste_Complaint__c createComplaint(String status) {
        Waste_Complaint__c c = new Waste_Complaint__c(Status__c = status);
        insert c;
        return c;
    }

    private static Waste_Complaint__c reload(Id recordId) {
        return [
            SELECT Status__c, Resolution_Date__c
            FROM Waste_Complaint__c
            WHERE Id = :recordId
        ];
    }

    @isTest
    static void newComplaint_hasNoResolutionDate() {
        Waste_Complaint__c c = createComplaint('New');
        System.assertEquals(null, reload(c.Id).Resolution_Date__c);
    }

    @isTest
    static void updateToResolved_setsResolutionDate() {
        Waste_Complaint__c c = createComplaint('New');

        c.Status__c = 'Resolved';
        update c;

        System.assertNotEquals(null, reload(c.Id).Resolution_Date__c,
            'Resolution date should be set when status becomes Resolved');
    }

    @isTest
    static void updateToOtherStatus_doesNotSetResolutionDate() {
        Waste_Complaint__c c = createComplaint('New');

        c.Status__c = 'In Progress';
        update c;

        System.assertEquals(null, reload(c.Id).Resolution_Date__c);
    }

    @isTest
    static void updateWhileAlreadyResolved_keepsOriginalDate() {
        Waste_Complaint__c c = createComplaint('New');
        c.Status__c = 'Resolved';
        update c;
        Datetime firstDate = reload(c.Id).Resolution_Date__c;

        update c; // no status change

        System.assertEquals(firstDate, reload(c.Id).Resolution_Date__c);
    }

    @isTest
    static void bulkUpdate_setsDateOnAllRecords() {
        List<Waste_Complaint__c> complaints = new List<Waste_Complaint__c>();
        for (Integer i = 0; i < 200; i++) {
            complaints.add(new Waste_Complaint__c(Status__c = 'New'));
        }
        insert complaints;

        for (Waste_Complaint__c c : complaints) {
            c.Status__c = 'Resolved';
        }
        Test.startTest();
        update complaints;
        Test.stopTest();

        Integer withDate = [
            SELECT COUNT() FROM Waste_Complaint__c
            WHERE Resolution_Date__c != null
        ];
        System.assertEquals(200, withDate);
    }
}