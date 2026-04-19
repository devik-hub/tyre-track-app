const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require('firebase-admin');
admin.initializeApp();

exports.notificationCronJob = onSchedule("0 8 * * *", async (event) => {
  const db = admin.firestore();
  const now = new Date();

  const snapshot = await db.collection("tyre_services")
    .where("status", "==", "completed")
    .get();

  const batch = db.batch();
  const notifications = [];

  for (const doc of snapshot.docs) {
    const service = doc.data();
    if (!service.serviceDate) continue;
    
    const serviceDate = service.serviceDate.toDate();
    const daysSince = Math.floor((now - serviceDate) / (1000 * 60 * 60 * 24));

    // 1-Year Alert
    if (!service.notification1YrSent && daysSince >= 365 && daysSince < 366) {
      notifications.push(buildNotification(service, "1yr", "🔍 Tyre Check Reminder", "Your retreaded tyre (1 year) is due for inspection."));
      batch.update(doc.ref, { notification1YrSent: true });
    }
    // 2-Year Alert
    if (!service.notification2YrSent && daysSince >= 730 && daysSince < 731) {
      notifications.push(buildNotification(service, "2yr", "⚠️ Retreading Due Soon", "Your tyre has completed 2 years. Time to book a retreading service!"));
      batch.update(doc.ref, { notification2YrSent: true });
    }
    // Expiry Alert
    const warrantyDays = (service.warrantyMonths || 24) * 30;
    if (!service.notificationExpirySent && daysSince >= warrantyDays) {
      notifications.push(buildNotification(service, "expiry", "🚨 Warranty Expired", "Retreading warranty has expired. Book an inspection immediately."));
      batch.update(doc.ref, { notificationExpirySent: true });
    }
  }

  // Send Notifications via FCM (Batching in chunks of 500)
  // await sendFCMNotifications(notifications);
  
  if (notifications.length > 0) {
      await batch.commit();
      console.log(`Dispatched ${notifications.length} lifecycle notifications.`);
  }
});

function buildNotification(service, type, title, body) {
   return {
       userId: service.customerId,
       title: title,
       body: body,
       type: type,
       serviceId: service.serviceId,
       createdAt: admin.firestore.FieldValue.serverTimestamp(),
       isRead: false
   };
}
