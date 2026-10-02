migrate((app) => {
  const users = app.findCollectionByNameOrId("users")
  const dummy = new Collection({
    fields: [{ name: "role", type: "select", required: true, maxSelect: 1, values: ["owner", "manager", "receptionist", "trainer", "member"] }]
  })
  users.fields.add(dummy.fields.getByName("role"))
  app.save(users)

  const staff = '@request.auth.role = "owner" || @request.auth.role = "manager" || @request.auth.role = "receptionist" || @request.auth.role = "trainer"'
  const manageStaff = '@request.auth.role = "owner" || @request.auth.role = "manager" || @request.auth.role = "receptionist"'

  const appConfig = new Collection({
    type: "base", name: "app_config",
    listRule: "", viewRule: "",
    createRule: null, deleteRule: null,
    updateRule: '@request.auth.role = "owner"',
    fields: [
      { name: "seed_color", type: "text", required: true },
      { name: "corner_radius", type: "number", required: true },
      { name: "input_style", type: "select", values: ["outlined", "filled", "underlined"], maxSelect: 1 },
      { name: "font_family", type: "text" },
      { name: "logo", type: "file", maxSelect: 1, mimeTypes: ["image/jpeg", "image/png", "image/svg+xml"] },
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
  })
  app.save(appConfig)

  const members = new Collection({
    type: "base", name: "members",
    listRule: staff + ' || user = @request.auth.id',
    viewRule: staff + ' || user = @request.auth.id',
    createRule: manageStaff, updateRule: manageStaff, deleteRule: '@request.auth.role = "owner"',
    fields: [
      { name: "user", type: "relation", collectionId: users.id, maxSelect: 1 },
      { name: "name", type: "text", required: true },
      { name: "phone", type: "text" },
      { name: "joined_on", type: "date", required: true },
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
  })
  app.save(members)

  const plans = new Collection({
    type: "base", name: "plans",
    listRule: "@request.auth.id != ''", viewRule: "@request.auth.id != ''",
    createRule: manageStaff, updateRule: manageStaff, deleteRule: '@request.auth.role = "owner"',
    fields: [
      { name: "name", type: "text", required: true },
      { name: "duration_days", type: "number", required: true },
      { name: "price", type: "number", required: true },
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
  })
  app.save(plans)

  const memberships = new Collection({
    type: "base", name: "memberships",
    listRule: staff + ' || member.user = @request.auth.id',
    viewRule: staff + ' || member.user = @request.auth.id',
    createRule: manageStaff, updateRule: manageStaff, deleteRule: '@request.auth.role = "owner"',
    fields: [
      { name: "member", type: "relation", collectionId: members.id, maxSelect: 1, required: true },
      { name: "plan", type: "relation", collectionId: plans.id, maxSelect: 1, required: true },
      { name: "start_date", type: "date", required: true },
      { name: "end_date", type: "date", required: true },
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
    indexes: ["CREATE INDEX idx_memberships_member_end ON memberships (member, end_date)"]
  })
  app.save(memberships)

  const payments = new Collection({
    type: "base", name: "payments",
    listRule: manageStaff + ' || member.user = @request.auth.id',
    viewRule: manageStaff + ' || member.user = @request.auth.id',
    createRule: manageStaff, updateRule: manageStaff, deleteRule: '@request.auth.role = "owner"',
    fields: [
      { name: "member", type: "relation", collectionId: members.id, maxSelect: 1, required: true },
      { name: "membership", type: "relation", collectionId: memberships.id, maxSelect: 1 },
      { name: "amount", type: "number", required: true },
      { name: "method", type: "select", values: ["cash", "upi", "card"], maxSelect: 1, required: true },
      { name: "notes", type: "text" },
      { name: "date", type: "date", required: true },
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
  })
  app.save(payments)

  const attendance = new Collection({
    type: "base", name: "attendance",
    listRule: staff + ' || member.user = @request.auth.id',
    viewRule: staff + ' || member.user = @request.auth.id',
    createRule: staff, updateRule: manageStaff, deleteRule: '@request.auth.role = "owner"',
    fields: [
      { name: "member", type: "relation", collectionId: members.id, maxSelect: 1, required: true },
      { name: "check_in_time", type: "date", required: true },
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
    indexes: ["CREATE INDEX idx_attendance_member_time ON attendance (member, check_in_time)"]
  })
  app.save(attendance)

}, (app) => {
  app.delete(app.findCollectionByNameOrId("attendance"))
  app.delete(app.findCollectionByNameOrId("payments"))
  app.delete(app.findCollectionByNameOrId("memberships"))
  app.delete(app.findCollectionByNameOrId("plans"))
  app.delete(app.findCollectionByNameOrId("members"))
  app.delete(app.findCollectionByNameOrId("app_config"))
  
  const users = app.findCollectionByNameOrId("users")
  users.fields.removeByName("role")
  app.save(users)
})
