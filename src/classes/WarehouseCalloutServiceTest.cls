@isTest
private class WarehouseCalloutServiceTest {

  @isTest static void testWarehouse() {
    Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
    Test.startTest();
    WarehouseCalloutService.runWarehouseEquipmentSync();
    Test.stopTest();
    Product2 equipment = [SELECT Id, Current_Inventory__c, Replacement_Part__c, Name, Maintenance_Cycle__c, Lifespan_Months__c, Cost__c, Warehouse_SKU__c FROM Product2];
    System.assertEquals(equipment.Current_Inventory__c, 5);
    System.assertEquals(equipment.Replacement_Part__c, true);
    System.assertEquals(equipment.Name, 'Generator 1000 kW');
    System.assertEquals(equipment.Maintenance_Cycle__c, 365);
    System.assertEquals(equipment.Lifespan_Months__c, 120);
    System.assertEquals(equipment.Cost__c, 5000);
    System.assertEquals(equipment.Warehouse_SKU__c, '100003');
  }
}