public class MaintenanceRequestHelper {

  private static List<Work_Part__c> relatedWorkParts;

  public static void updateWorkOrders(Map<Id, Case> oldCaseMap, Map<Id, Case> newCaseMap) {

    relatedWorkParts = new List<Work_Part__c>();
    Map<Id, Case> oldCaseIdNewCase = new Map<Id, Case>();
    List<Case> caseList  = new List<Case>();

    List<Work_Part__c> partsList = [SELECT Maintenance_Request__c, Equipment__r.Maintenance_Cycle__c FROM Work_Part__c WHERE Maintenance_Request__c =: oldCaseMap.keySet()];

    for (Id oldCaseId : oldCaseMap.keySet()) {

      Case oldCase = oldCaseMap.get(oldCaseId);
      Case newCase = newCaseMap.get(oldCaseId);

      if ((oldCase.Status != 'Closed') && (newCase.Status == 'Closed') && ((oldCase.Type == 'Repair') || (newCase.Type == 'Routine Maintenance'))) {
        Case newCheckupCase = createNewCheckupCase(oldCase, calculateDateDue(oldCaseId, partsList));
        oldCaseIdNewCase.put(oldCaseId, newCheckupCase);
        caseList.add(newCheckupCase);
      }
    }

    insert caseList;

    for (Work_Part__c part : relatedWorkParts) {
      part.Maintenance_Request__c = oldCaseIdNewCase.get(part.Maintenance_Request__c).Id;
    }

    update partsList;
  }

  private static Date calculateDateDue(Id oldCaseId, List<Work_Part__c> partsList) {

    for(Work_Part__c part : partsList) {
      if (part.Maintenance_Request__c == oldCaseId) {
        relatedWorkParts.add(part);
      }
    }

    List<Decimal> maintenanceCycleList = new List<Decimal>();

    Integer shortestMaintenanceCycle = 0;

    if (relatedWorkParts.size() > 0) {
      for (Work_Part__c part : relatedWorkParts) {
        maintenanceCycleList.add(part.Equipment__r.Maintenance_Cycle__c);
      }
      maintenanceCycleList.sort();
      shortestMaintenanceCycle = maintenanceCycleList[0].intValue();
    }

    return Date.today().addDays(shortestMaintenanceCycle);
  }

  private static Case createNewCheckupCase(Case oldCase, Date dateDue) {
    return new Case(Type = 'Routine Maintenance',
                    Subject = String.isBlank(oldCase.Subject) ? 'Routine CheckUp' : oldCase.Subject,
                    Origin = oldCase.Origin,
                    Status = 'New',
                    Equipment__c = oldCase.Equipment__c,
                    Date_Reported__c = Date.today(),
                    Vehicle__c = oldCase.Vehicle__c,
                    Date_Due__c = dateDue);
  }

}