trigger WasteComplaintTrigger on Waste_Complaint__c (before update) {
    for (Waste_Complaint__c complaint : Trigger.new) {
        Waste_Complaint__c oldComplaint =
            Trigger.oldMap.get(complaint.Id);

        if (complaint.Status__c == 'Resolved' &&
            oldComplaint.Status__c != 'Resolved') {
            complaint.Resolution_Date__c = System.now();
        }
    }
}