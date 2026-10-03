migrate((app) => {
  const users = app.findCollectionByNameOrId("users");
  const members = app.findCollectionByNameOrId("members");

  // 1. Update Attendance Collection
  const attendance = app.findCollectionByNameOrId("attendance");
  attendance.fields.add(new Field({
    name: "check_out_time",
    type: "date",
    required: false,
  }));
  app.save(attendance);

  // Define Auth Rules
  const staff = '@request.auth.role = "owner" || @request.auth.role = "manager" || @request.auth.role = "receptionist" || @request.auth.role = "trainer"';
  const manageStaff = '@request.auth.role = "owner" || @request.auth.role = "manager" || @request.auth.role = "receptionist"';
  const trainerOrOwner = '@request.auth.role = "owner" || @request.auth.role = "trainer"';

  // 2. Exercises Collection
  const exercises = new Collection({
    type: "base", name: "exercises",
    listRule: "@request.auth.id != ''", 
    viewRule: "@request.auth.id != ''",
    createRule: trainerOrOwner, updateRule: trainerOrOwner, deleteRule: '@request.auth.role = "owner"',
    fields: [
      { name: "name", type: "text", required: true },
      { name: "body_part", type: "select", values: ["chest", "back", "legs", "arms", "shoulders", "core", "cardio", "full_body"], maxSelect: 1 },
      { name: "description", type: "text" },
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
  });
  app.save(exercises);

  // 3. Workout Templates Collection
  const workoutTemplates = new Collection({
    type: "base", name: "workout_templates",
    listRule: "@request.auth.id != ''", 
    viewRule: "@request.auth.id != ''",
    createRule: trainerOrOwner, updateRule: trainerOrOwner, deleteRule: '@request.auth.role = "owner"',
    fields: [
      { name: "name", type: "text", required: true },
      { name: "description", type: "text" },
      { name: "trainer", type: "relation", collectionId: users.id, maxSelect: 1 },
      { name: "routine_data", type: "json", required: true }, // Array of {exerciseId, sets, reps, rest}
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
  });
  app.save(workoutTemplates);

  // 4. Member Workouts Collection
  const memberWorkouts = new Collection({
    type: "base", name: "member_workouts",
    listRule: staff + ' || member.user = @request.auth.id', 
    viewRule: staff + ' || member.user = @request.auth.id',
    createRule: trainerOrOwner, updateRule: trainerOrOwner + ' || member.user = @request.auth.id', deleteRule: trainerOrOwner,
    fields: [
      { name: "member", type: "relation", collectionId: members.id, maxSelect: 1, required: true },
      { name: "template", type: "relation", collectionId: workoutTemplates.id, maxSelect: 1 },
      { name: "assigned_by", type: "relation", collectionId: users.id, maxSelect: 1 },
      { name: "date", type: "date", required: true },
      { name: "status", type: "select", values: ["pending", "completed"], maxSelect: 1, required: true },
      { name: "log_data", type: "json" }, // To store actual reps/weights lifted
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
  });
  app.save(memberWorkouts);

  // 5. Metrics Collection (Weight/Progress)
  const metrics = new Collection({
    type: "base", name: "metrics",
    listRule: staff + ' || member.user = @request.auth.id', 
    viewRule: staff + ' || member.user = @request.auth.id',
    createRule: staff + ' || member.user = @request.auth.id', updateRule: staff + ' || member.user = @request.auth.id', deleteRule: '@request.auth.role = "owner"',
    fields: [
      { name: "member", type: "relation", collectionId: members.id, maxSelect: 1, required: true },
      { name: "date", type: "date", required: true },
      { name: "weight_kg", type: "number" },
      { name: "body_fat_percent", type: "number" },
      { name: "notes", type: "text" },
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
  });
  app.save(metrics);

  // 6. Classes Collection
  const classes = new Collection({
    type: "base", name: "classes",
    listRule: "@request.auth.id != ''", 
    viewRule: "@request.auth.id != ''",
    createRule: manageStaff, updateRule: manageStaff, deleteRule: manageStaff,
    fields: [
      { name: "name", type: "text", required: true },
      { name: "instructor", type: "relation", collectionId: users.id, maxSelect: 1 },
      { name: "start_time", type: "date", required: true },
      { name: "end_time", type: "date", required: true },
      { name: "capacity", type: "number", required: true },
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
  });
  app.save(classes);

  // 7. Class Bookings Collection
  const classBookings = new Collection({
    type: "base", name: "class_bookings",
    listRule: staff + ' || member.user = @request.auth.id', 
    viewRule: staff + ' || member.user = @request.auth.id',
    createRule: staff + ' || member.user = @request.auth.id', updateRule: staff, deleteRule: staff + ' || member.user = @request.auth.id',
    fields: [
      { name: "class", type: "relation", collectionId: classes.id, maxSelect: 1, required: true },
      { name: "member", type: "relation", collectionId: members.id, maxSelect: 1, required: true },
      { name: "status", type: "select", values: ["booked", "cancelled", "attended"], maxSelect: 1, required: true },
      { name: "created", type: "autodate", onCreate: true },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true }
    ],
    indexes: ["CREATE UNIQUE INDEX idx_class_member_unique ON class_bookings (`class`, member)"]
  });
  app.save(classBookings);

}, (app) => {
  app.delete(app.findCollectionByNameOrId("class_bookings"));
  app.delete(app.findCollectionByNameOrId("classes"));
  app.delete(app.findCollectionByNameOrId("metrics"));
  app.delete(app.findCollectionByNameOrId("member_workouts"));
  app.delete(app.findCollectionByNameOrId("workout_templates"));
  app.delete(app.findCollectionByNameOrId("exercises"));

  const attendance = app.findCollectionByNameOrId("attendance");
  attendance.fields.removeByName("check_out_time");
  app.save(attendance);
});
