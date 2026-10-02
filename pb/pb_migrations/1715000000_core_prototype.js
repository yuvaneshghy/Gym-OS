migrate((db) => {
  const dao = $app.dao()

  // 1. app_config
  const config = new Collection({
    id: "app_config_00000",
    name: "app_config",
    type: "base",
    schema: [
      { name: "brand_name", type: "text", required: true },
      { name: "seed_color", type: "text", required: true },
      { name: "corner_radius", type: "number", required: true },
      { name: "logo", type: "file", maxSelect: 1 },
      { name: "font", type: "text" },
      { name: "input_style", type: "select", options: { values: ["outlined", "filled"], maxSelect: 1 } },
      { name: "dark_default", type: "bool" },
      { name: "currency", type: "text" },
      { name: "locale", type: "text" },
      { name: "contact_info", type: "text" },
      { name: "features", type: "json", required: true }
    ],
  });
  $app.save(config);

  // 2. Modify system `users` to add roles
  const users = $app.findCollectionByNameOrId("users");
  users.fields.add({
    name: "role",
    type: "select",
    options: { values: ["ADMIN", "STAFF", "MEMBER"], maxSelect: 1 },
    required: true,
  });
  $app.save(users);

  // 3. members (Separate from users for leads/walk-ins without app access)
  const members = new Collection({
    id: "members_0000000",
    name: "members",
    type: "base",
    schema: [
      { name: "user", type: "relation", required: false, options: { collectionId: users.id, maxSelect: 1 } },
      { name: "name", type: "text", required: true },
      { name: "phone", type: "text" },
      { name: "email", type: "email" },
      { name: "joined_on", type: "date", required: true },
      { name: "notes", type: "text" },
    ],
  });
  $app.save(members);

  // 4. plans
  const plans = new Collection({
    id: "plans_00000000000",
    name: "plans",
    type: "base",
    schema: [
      { name: "name", type: "text", required: true },
      { name: "price", type: "number", required: true },
      { name: "duration_days", type: "number", required: true },
    ],
  });
  $app.save(plans);

  // 5. memberships
  const memberships = new Collection({
    id: "memberships_00000",
    name: "memberships",
    type: "base",
    schema: [
      { name: "member", type: "relation", required: true, options: { collectionId: members.id, maxSelect: 1 } },
      { name: "plan", type: "relation", required: true, options: { collectionId: plans.id, maxSelect: 1 } },
      { name: "start_date", type: "date", required: true },
      { name: "end_date", type: "date", required: true },
    ],
  });
  $app.save(memberships);

  // 6. payments (Stub for v1)
  const payments = new Collection({
    id: "payments_00000000",
    name: "payments",
    type: "base",
    schema: [
      { name: "member", type: "relation", required: true, options: { collectionId: members.id, maxSelect: 1 } },
      { name: "amount", type: "number", required: true },
      { name: "date", type: "date", required: true },
    ],
  });
  $app.save(payments);

  // 7. attendance (Stub for v1)
  const attendance = new Collection({
    id: "attendance_000000",
    name: "attendance",
    type: "base",
    schema: [
      { name: "member", type: "relation", required: true, options: { collectionId: members.id, maxSelect: 1 } },
      { name: "check_in_time", type: "date", required: true },
    ],
  });
  $app.save(attendance);

}, (db) => {
  $app.delete($app.findCollectionByNameOrId("attendance"));
  $app.delete($app.findCollectionByNameOrId("payments"));
  $app.delete($app.findCollectionByNameOrId("memberships"));
  $app.delete($app.findCollectionByNameOrId("plans"));
  $app.delete($app.findCollectionByNameOrId("members"));
  $app.delete($app.findCollectionByNameOrId("app_config"));
});
