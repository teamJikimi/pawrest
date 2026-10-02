const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

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
