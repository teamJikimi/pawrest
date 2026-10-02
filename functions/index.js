const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const nodemailer = require("nodemailer");

initializeApp();

const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: "dlathdms1206@gmail.com",
        pass: "nmwh ggcx emxf hlfu"
    }
});

exports.sendReportEmail = onDocumentCreated("reports/{reportId}", async (event) => {
    const data = event.data.data();
    await transporter.sendMail({
        from: "dlathdms1206@gmail.com",
        to: "dlathdms1206@gmail.com",
        subject: `[Pawrest] 신고 접수 - ${data.targetType}`,
        text: `신고 접수되었습니다.\n\n신고 유형: ${data.targetType}\n신고 사유: ${data.reason}\n신고자 ID: ${data.reporterID}\n대상자 ID: ${data.targetAuthorID}\n대상 ID: ${data.targetID}`
    });
});

exports.sendCommunityNotification = onDocumentCreated(
  "users/{userId}/notifications/{notifId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const data = snapshot.data();
    const userId = event.params.userId;

    const userDoc = await getFirestore()
      .collection("users")
      .doc(userId)
      .get();

    const userData = userDoc.data();

    if (userData?.communityNotificationEnabled === false) {
      await snapshot.ref.delete();
      return;
    }

    const fcmToken = userData?.fcmToken;
    if (!fcmToken) return;

    const message = {
      token: fcmToken,
      notification: {
        title: data.type === "comment" ? "댓글" : "좋아요",
        body: data.body,
      },
      data: {
        type: data.type,
        postID: data.postID,
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    };

    try {
      await getMessaging().send(message);
    } catch (error) {
      console.error("FCM 발송 실패:", error);
    }
  }
);