async function sendEmail() {
  console.log("Email skipped (no SendGrid)");
  return true;
}

module.exports = { sendEmail };