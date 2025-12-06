# Automate Vault Setup Locally


## Step 1: TLS & Server Configs

Vault server expects TLS enabled by default. For this tutorial we will use a self-signed certificate.
In production, it is recommended to use certificates published by a public CA (LetsEncrypt, UPKI, etc.).
This tutorial is loosely based on the official documentation by Hashicorp.
Here is the official documentation; give them a read as Vault has excellent documentation as is.
> [Set up a Vault Dev Server | Vault | Hashicorp Developer](https://developer.hashicorp.com/vault/tutorials/get-started/setup)  
> [Learn to use the Vault HTTP API | Vault | Hashicorp Developer](https://developer.hashicorp.com/vault/tutorials/get-started/learn-http-api)

1. Set the environment variables needed.
```
export VAULT_CONFIG=/etc/vault.d
export VAULT_DATA=/opt/vault/data
```

2. Use openssl to generate a self-signed TLS certificate and key for the server to use.
Write them to the files `<VAULT_CONFIG>/vault-cert.pem` and `<VAULT_CONFIG>/vault-key.pem.`
```
sudo openssl req -x509 -newkey rsa:4096 -sha256 -days 365 \
  -nodes -keyout ${VAULT_CONFIG}/vault-key.pem -out ${VAULT_CONFIG}/vault-cert.pem \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
```

3. Create a server configuration file at within the config dir `<VAULT_CONFIG>/vault-server.hcl`.
> API: [Vault configuration parameters](https://developer.hashicorp.com/vault/docs/configuration)
```
api_addr                = "https://127.0.0.1:8200"
cluster_addr            = "https://127.0.0.1:8201"
cluster_name            = "upinem-vault-server"
disable_mlock           = true
ui                      = false

listener "tcp" {
address       = "127.0.0.1:8200"
tls_cert_file = "/etc/vault.d/vault-cert.pem"
tls_key_file  = "/etc/vault.d/vault-key.pem"
}

backend "raft" {
path    = "/opt/vault/data"
node_id = "upinem-vault-server"
}

```

4. Set user permissions for the files created.
We will run the Vault server as the dedicated service user `vault`.
```
sudo chown vault:vault ${VAULT_CONFIG}/vault*
```

5. Run the server as the service user `vault`.
```
sudo -u vault vault server -config=${VAULT_CONFIG}/vault-server.hcl
```

6. **In another terminal**, set the necessary environment variables needed to use the HTTP API.
```
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_CACERT=${VAULT_CONFIG}/vault-cert.pem
export CURL_CA_BUNDLE=${VAULT_CACERT}
```

7. Use the HTTP API to check the server status.
```
curl -s $VAULT_ADDR/v1/sys/seal-status | jq

# Example output
{
  "type": "shamir",
  "initialized": true,
  "sealed": false,
  "t": 1,
  "n": 1,
  "progress": 0,
  "nonce": "",
  "version": "1.15.5",
  "build_date": "2024-01-26T14:53:40Z",
  "migration": false,
  "cluster_name": "vault-cluster-cfe1cb9c",
  "cluster_id": "f507fd9f-89c4-e1f4-69ec-6919b0f9307b",
  "recovery_seal": false,
  "storage_type": "inmem"
}
```
