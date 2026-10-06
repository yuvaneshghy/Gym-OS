migrate((app) => {
  // 1. Lock down app_config to Superadmin only
  const appConfig = app.findCollectionByNameOrId("app_config");
  appConfig.updateRule = null;
  
  // Add GST fields to app_config
  appConfig.fields.add(new Field({
    name: "gst_number",
    type: "text",
    required: false,
  }));
  appConfig.fields.add(new Field({
    name: "gym_address",
    type: "text",
    required: false,
  }));
  app.save(appConfig);

  // 2. Add GST fields to payments
  const payments = app.findCollectionByNameOrId("payments");
  payments.fields.add(new Field({
    name: "gst_amount",
    type: "number",
    required: false,
  }));
  payments.fields.add(new Field({
    name: "tax_rate",
    type: "number",
    required: false,
  }));
  app.save(payments);

}, (app) => {
  const payments = app.findCollectionByNameOrId("payments");
  payments.fields.removeByName("gst_amount");
  payments.fields.removeByName("tax_rate");
  app.save(payments);

  const appConfig = app.findCollectionByNameOrId("app_config");
  appConfig.fields.removeByName("gst_number");
  appConfig.fields.removeByName("gym_address");
  appConfig.updateRule = '@request.auth.role = "owner"';
  app.save(appConfig);
});
