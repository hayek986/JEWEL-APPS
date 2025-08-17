/**
 * هذا الملف يحتوي على Firebase Cloud Function معدلة لإرسال إشعارات
 * تحتوي على اسم العميل والسعر الإجمالي عند إضافة طلب جديد.
 * تم إصلاح خطأ TypeError: newOrder.totalPrice.toStringAsFixed
 */

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNewOrderNotification = onDocumentCreated(
  "orders/{orderId}",
  async (event) => {
    // احصل على بيانات الطلب الجديد من الحدث
    const newOrder = event.data.data();

    // استخرج اسم العميل
    const customerName = newOrder.customerName || 'عميل مجهول';

    // ✅ إصلاح المشكلة: تأكد من أن totalPrice هو رقم قبل استخدامه
    let totalPrice = 0;
    const totalPriceData = newOrder.totalPrice;

    // تحقق من نوع البيانات وقم بتحويلها إلى رقم
    if (typeof totalPriceData === 'string') {
      totalPrice = parseFloat(totalPriceData) || 0;
    } else if (typeof totalPriceData === 'number') {
      totalPrice = totalPriceData;
    }

    const payload = {
      notification: {
        title: `طلب جديد من ${customerName}`,
        // ✅ الآن يمكننا استخدام toStringAsFixed() بأمان
        body: `السعر الإجمالي: ${totalPrice.toFixed(2)} د.أ`,
      },
      topic: "admin",
    };

    try {
      await admin.messaging().send(payload);
      console.log("تم إرسال الإشعار بنجاح");
    } catch (error) {
      console.error("فشل إرسال الإشعار:", error);
    }
  }
);
