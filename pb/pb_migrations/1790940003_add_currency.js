/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("app_config");

  try {
    if (!collection.fields.getByName("currency")) {
      const dummy = new Collection({
        fields: [
          { name: "currency", type: "text" }
        ]
      });
      collection.fields.add(dummy.fields.getByName("currency"));
      app.save(collection);
    }
  } catch (e) {
    // ignore
  }
}, (app) => {
  const collection = app.findCollectionByNameOrId("app_config");

  try {
    if (collection.fields.getByName("currency")) {
      collection.fields.removeByName("currency");
      app.save(collection);
    }
  } catch (e) {
    // ignore
  }
});
