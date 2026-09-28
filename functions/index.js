const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

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

    const fcmToken = userDoc.data()?.fcmToken;
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
