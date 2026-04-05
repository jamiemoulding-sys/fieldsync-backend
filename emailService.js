const { sendEmail } = require('./sendgrid');

const sendInviteEmail = async ({ email, name, token }) => {
  const inviteLink = `${process.env.FRONTEND_URL}/accept-invite/${token}`;

  const html = `
    <h2>You're invited 🎉</h2>
    <p>Hello ${name},</p>
    <p>You’ve been invited to join a company.</p>
    <a href="${inviteLink}" style="
      display:inline-block;
      padding:10px 20px;
      background:#2563eb;
      color:white;
      text-decoration:none;
      border-radius:6px;
    ">
      Accept Invite
    </a>
  `;

  return sendEmail({
    to: email,
    subject: 'Company Invitation',
    html
  });
};

module.exports = { sendInviteEmail };