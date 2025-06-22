const { Octokit } = require("@octokit/rest");
const sodium = require("tweetsodium");

(async () => {
  const octokit = new Octokit({ auth: process.env.GH_PAT_FOR_SECRETS });
  const owner = process.env.GITHUB_REPOSITORY.split('/')[0];
  const repo = process.env.GITHUB_REPOSITORY.split('/')[1];

  async function encryptSecret(publicKey, secretValue) {
    const messageBytes = Buffer.from(secretValue);
    const keyBytes = Buffer.from(publicKey, "base64");
    const encryptedBytes = sodium.seal(messageBytes, keyBytes);
    return Buffer.from(encryptedBytes).toString("base64");
  }

  async function setSecret(secretName, secretValue) {
    const { data: publicKeyData } = await octokit.actions.getRepoPublicKey({
      owner,
      repo,
    });

    const encrypted_value = await encryptSecret(publicKeyData.key, secretValue);

    await octokit.actions.createOrUpdateRepoSecret({
      owner,
      repo,
      secret_name: secretName,
      encrypted_value,
      key_id: publicKeyData.key_id,
    });

    console.log(`✅ Secret ${secretName} updated`);
  }

  try {
    await setSecret("AWS_ACCESS_KEY_ID", process.env.AWS_ACCESS_KEY_ID);
    await setSecret("AWS_SECRET_ACCESS_KEY", process.env.AWS_SECRET_ACCESS_KEY);
    if (process.env.AWS_SESSION_TOKEN) {
      await setSecret("AWS_SESSION_TOKEN", process.env.AWS_SESSION_TOKEN);
    }
  } catch (error) {
    console.error("Error updating secrets:", error);
    process.exit(1);
  }
})();
