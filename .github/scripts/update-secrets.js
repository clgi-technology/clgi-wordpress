const { Octokit } = require("@octokit/rest");
const sodium = require("tweetsodium");

(async () => {
  const token = process.env.GH_PAT_FOR_SECRETS;

  if (!token) {
    console.error("❌ GH_PAT_FOR_SECRETS is not defined.");
    process.exit(1);
  }

  const repoFull = process.env.GITHUB_REPOSITORY;
  if (!repoFull || !repoFull.includes("/")) {
    console.error("❌ GITHUB_REPOSITORY is not set correctly.");
    process.exit(1);
  }

  const [owner, repo] = repoFull.split("/");
  const octokit = new Octokit({ auth: token });

  async function encryptSecret(publicKey, secretValue) {
    const messageBytes = Buffer.from(secretValue);
    const keyBytes = Buffer.from(publicKey, "base64");
    const encryptedBytes = sodium.seal(messageBytes, keyBytes);
    return Buffer.from(encryptedBytes).toString("base64");
  }

  async function setSecret(secretName, secretValue) {
    try {
      if (!secretValue) {
        console.warn(`⚠️ Skipping ${secretName}: value not provided.`);
        return;
      }

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
    } catch (error) {
      console.error(`❌ Error updating secret ${secretName}:`, error.message || error);
      throw error;
    }
  }

  try {
    await setSecret("AWS_ACCESS_KEY_ID", process.env.AWS_ACCESS_KEY_ID);
    await setSecret("AWS_SECRET_ACCESS_KEY", process.env.AWS_SECRET_ACCESS_KEY);
    if (process.env.AWS_SESSION_TOKEN) {
      await setSecret("AWS_SESSION_TOKEN", process.env.AWS_SESSION_TOKEN);
    }
  } catch (err) {
    console.error("🚫 Failed to update one or more secrets.");
    process.exit(1);
  }
})();
