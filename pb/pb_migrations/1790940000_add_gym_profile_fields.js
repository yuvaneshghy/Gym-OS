migrate((app) => {
  const collection = app.findCollectionByNameOrId("app_config");
  const dummy = new Collection({
    fields: [
      { name: "gym_name", type: "text" },
      { name: "gym_phone", type: "text" },
      { name: "gym_email", type: "text" },
      { name: "gym_address", type: "text" }
    ]
  });
  
  collection.fields.add(dummy.fields.getByName("gym_name"));
  collection.fields.add(dummy.fields.getByName("gym_phone"));
  collection.fields.add(dummy.fields.getByName("gym_email"));
  collection.fields.add(dummy.fields.getByName("gym_address"));
  
  app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("app_config");
  collection.fields.removeByName("gym_name");
  collection.fields.removeByName("gym_phone");
  collection.fields.removeByName("gym_email");
  collection.fields.removeByName("gym_address");
  app.save(collection);
});
