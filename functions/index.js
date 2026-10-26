const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
admin.initializeApp();

const BATCH_LIMIT = 400; // Safe threshold well below Firestore's 500 write limit

exports.notificationCronJob = onSchedule("0 8 * * *", async (event) => {
  const db = admin.firestore();
  const now = new Date();

  const snapshot = await db.collection("tyre_services")
    .where("status", "==", "completed")
    .get();

  if (snapshot.empty) {
    console.log("No completed tyre services found.");
    return;
  }

  const operations = []; // array of { type: 'set'|'update', ref, data }

  for (const doc of snapshot.docs) {
    const service = doc.data();
    if (!service.serviceDate) continue;

    const serviceDate = service.serviceDate.toDate ? service.serviceDate.toDate() : new Date(service.serviceDate);
    const daysSince = Math.floor((now - serviceDate) / (1000 * 60 * 60 * 24));
    const updates = {};

    // 1-Year Alert (monotonic threshold check)
    if (!service.notification1YrSent && daysSince >= 365) {
      const notifData = buildNotification(service, "1yr", "🔍 Tyre Check Reminder", "Your retreaded tyre (1 year) is due for inspection.");
      const notifRef = db.collection("notifications").doc();
      operations.push({ type: "set", ref: notifRef, data: notifData });
      updates.notification1YrSent = true;
    }

    // 2-Year Alert
    if (!service.notification2YrSent && daysSince >= 730) {
      const notifData = buildNotification(service, "2yr", "⚠️ Retreading Due Soon", "Your tyre has completed 2 years. Time to book a retreading service!");
      const notifRef = db.collection("notifications").doc();
      operations.push({ type: "set", ref: notifRef, data: notifData });
      updates.notification2YrSent = true;
    }

    // Expiry Alert
    const warrantyDays = (service.warrantyMonths || 24) * 30;
    if (!service.notificationExpirySent && daysSince >= warrantyDays) {
      const notifData = buildNotification(service, "expiry", "🚨 Warranty Expired", "Retreading warranty has expired. Book an inspection immediately.");
      const notifRef = db.collection("notifications").doc();
      operations.push({ type: "set", ref: notifRef, data: notifData });
      updates.notificationExpirySent = true;
    }

    if (Object.keys(updates).length > 0) {
      operations.push({ type: "update", ref: doc.ref, data: updates });
    }
  }

  // Commit operations in batches of BATCH_LIMIT
  if (operations.length > 0) {
    for (let i = 0; i < operations.length; i += BATCH_LIMIT) {
      const chunk = operations.slice(i, i + BATCH_LIMIT);
      const batch = db.batch();
      for (const op of chunk) {
        if (op.type === "set") {
          batch.set(op.ref, op.data);
        } else if (op.type === "update") {
          batch.update(op.ref, op.data);
        }
      }
      await batch.commit();
    }
    console.log(`Successfully committed ${operations.length} notification operations.`);
  } else {
    console.log("No pending lifecycle notifications for today.");
  }
});

function buildNotification(service, type, title, body) {
  return {
    userId: service.customerId || "",
    title: title,
    body: body,
    type: type,
    serviceId: service.serviceId || "",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    isRead: false,
  };
}
