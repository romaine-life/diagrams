import { SecretClient } from '@azure/keyvault-secrets';
import { DefaultAzureCredential } from '@azure/identity';

export async function fetchConfig() {
  const keyVaultUrl = process.env.KEY_VAULT_URL;
  if (!keyVaultUrl) {
    return { codexQueueJwtSecret: process.env.CODEX_QUEUE_JWT_SECRET ?? null };
  }

  const kv = new SecretClient(keyVaultUrl, new DefaultAzureCredential());
  const secret = await kv.getSecret('codex-queue-jwt-secret')
    .catch(() => ({ value: process.env.CODEX_QUEUE_JWT_SECRET ?? null }));
  return { codexQueueJwtSecret: secret.value };
}
