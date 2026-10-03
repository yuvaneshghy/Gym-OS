migrate((app) => {
  const members = app.findCollectionByNameOrId("members");
  const plans = app.findCollectionByNameOrId("plans");
  const memberships = app.findCollectionByNameOrId("memberships");
  const payments = app.findCollectionByNameOrId("payments");
  const attendance = app.findCollectionByNameOrId("attendance");
  const exercises = app.findCollectionByNameOrId("exercises");
  const classes = app.findCollectionByNameOrId("classes");
  const classBookings = app.findCollectionByNameOrId("class_bookings");
  const metrics = app.findCollectionByNameOrId("metrics");

  // Fetch existing member and plan
  const memberRecords = app.findAllRecords(members);
  const planRecords = app.findAllRecords(plans);
  
  if (memberRecords.length === 0 || planRecords.length === 0) return;
  
  const member = memberRecords[0];
  const plan = planRecords[0];

  // 1. Create Membership
  const membership = new Record(memberships);
  membership.set("member", member.id);
  membership.set("plan", plan.id);
  
  const now = new Date();
  const startDate = new Date(now);
  startDate.setDate(now.getDate() - 5); // Started 5 days ago
  
  const endDate = new Date(startDate);
  endDate.setDate(startDate.getDate() + 30); // 30 day plan
  
  membership.set("start_date", startDate.toISOString());
  membership.set("end_date", endDate.toISOString());
  app.save(membership);

  // 2. Create Payment
  const payment = new Record(payments);
  payment.set("member", member.id);
  payment.set("membership", membership.id);
  payment.set("amount", 1000);
  payment.set("method", "upi");
  payment.set("date", startDate.toISOString());
  payment.set("notes", "Initial seed payment");
  app.save(payment);

  // 3. Create Attendance Records
  for (let i = 1; i <= 3; i++) {
    const attend = new Record(attendance);
    attend.set("member", member.id);
    const checkIn = new Date(now);
    checkIn.setDate(now.getDate() - i);
    checkIn.setHours(10, 0, 0, 0);
    attend.set("check_in_time", checkIn.toISOString());
    
    const checkOut = new Date(checkIn);
    checkOut.setHours(11, 30, 0, 0);
    attend.set("check_out_time", checkOut.toISOString());
    
    app.save(attend);
  }

  // 4. Create Exercises
  const squat = new Record(exercises);
  squat.set("name", "Barbell Squat");
  squat.set("body_part", "legs");
  app.save(squat);

  const bench = new Record(exercises);
  bench.set("name", "Bench Press");
  bench.set("body_part", "chest");
  app.save(bench);

  // 5. Create Class
  const yogaClass = new Record(classes);
  yogaClass.set("name", "Morning Yoga");
  const classStart = new Date(now);
  classStart.setHours(8, 0, 0, 0);
  const classEnd = new Date(now);
  classEnd.setHours(9, 0, 0, 0);
  yogaClass.set("start_time", classStart.toISOString());
  yogaClass.set("end_time", classEnd.toISOString());
  yogaClass.set("capacity", 20);
  app.save(yogaClass);

  // 6. Create Class Booking
  const booking = new Record(classBookings);
  booking.set("class", yogaClass.id);
  booking.set("member", member.id);
  booking.set("status", "booked");
  app.save(booking);

  // 7. Create Metrics
  const metric = new Record(metrics);
  metric.set("member", member.id);
  metric.set("date", startDate.toISOString());
  metric.set("weight_kg", 75.5);
  metric.set("body_fat_percent", 18);
  app.save(metric);

}, (app) => {
  // Revert logic (not strictly necessary for pb_data wipe, but good practice)
});
