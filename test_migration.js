migrate((app) => {
  const users = app.findCollectionByNameOrId("users")
  console.log("users", typeof users, users)
})
