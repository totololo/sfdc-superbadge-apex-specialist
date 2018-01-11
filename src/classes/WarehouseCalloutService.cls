public with sharing class WarehouseCalloutService {

  private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
  private static final String GET = 'GET';

  @future (callout=true)
  public static void runWarehouseEquipmentSync(){

    List<Product2> upsertList = new List<Product2>();

    HttpRequest req = new HttpRequest();
    req.setEndpoint(WAREHOUSE_URL);
    req.setMethod(GET);
    Http http = new Http();
    HTTPResponse res = http.send(req);

    String response = res.getBody().replaceAll('_id', 'equipmentId');
    JSONParser parser = JSON.createParser(response);

    while (parser.nextValue() == JSONToken.START_ARRAY) {
      if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
        while (parser.nextToken() != null) {
          if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
            Equipment ep = (Equipment)parser.readValueAs(Equipment.class);
            upsertList.add(new Product2(Lifespan_Months__c = ep.lifespan,
                                        Cost__c = ep.cost,
                                        Replacement_Part__c = true,
                                        Maintenance_Cycle__c = ep.maintenancePeriod,
                                        Warehouse_SKU__c = ep.sku,
                                        Current_Inventory__c = ep.quantity,
                                        Name = ep.name));
            parser.skipChildren();
          }
        }
      }
    }
    upsert upsertList Warehouse_SKU__c;
  }

  public class Equipment {
    public String equipmentId;
    public Boolean replacement;
    public Integer quantity;
    public String name;
    public Integer maintenancePeriod;
    public Integer lifespan;
    public Integer cost;
    public String sku;
  }
}