migrate((app) => {
  const users = app.findCollectionByNameOrId("users")
  
  // Create owner
  const owner = new Record(users)
  owner.set("email", "owner@gym.local")
  owner.set("password", "password123")
  owner.set("passwordConfirm", "password123")
  owner.set("role", "owner")
  owner.set("name", "Gym Owner")
  app.save(owner)

  // Create member user
  const memberUser = new Record(users)
  memberUser.set("email", "member@gym.local")
  memberUser.set("password", "password123")
  memberUser.set("passwordConfirm", "password123")
  memberUser.set("role", "member")
  memberUser.set("name", "Test Member")
  app.save(memberUser)

  // Link member record
  const members = app.findCollectionByNameOrId("members")
  const member = new Record(members)
  member.set("user", memberUser.id)
  member.set("name", "Test Member")
  member.set("phone", "1234567890")
  member.set("joined_on", new Date().toISOString())
  app.save(member)

  // Create plan
  const plans = app.findCollectionByNameOrId("plans")
  const plan = new Record(plans)
  plan.set("name", "Monthly Standard")
  plan.set("duration_days", 30)
  plan.set("price", 1000)
  app.save(plan)

  // Create App Config
  const appConfig = app.findCollectionByNameOrId("app_config")
  const config = new Record(appConfig)
  config.set("seed_color", "#0055FF")
  config.set("corner_radius", 12)
  config.set("input_style", "outlined")
  app.save(config)

}, (app) => {
  // Not strictly needed since pb_data can be wiped, but good practice
  try {
    const owner = app.findAuthRecordByEmail("users", "owner@gym.local")
    app.delete(owner)
  } catch {}
  try {
    const member = app.findAuthRecordByEmail("users", "member@gym.local")
    app.delete(member)
  } catch {}
})
