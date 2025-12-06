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


## Step 2: Initalize & Unseal the Vault Server

With the server running in the background/another terminal, execute the following to initialize and unseal.

1. Create an API request payload (`payload-init.json`) to initialize the server.
    - `secret_shares`: Specifies the number of shares to split the root key into.
    - `secret_threshold`: Specifies the number of shares required to reconstruct the root key. This must be less than or equal `secret_shares`.
> API: [ \[POST\] `/sys/init`](https://developer.hashicorp.com/vault/api-docs/system/init)
```
{
  "secret_shares": 1,
  "secret_threshold": 1
}
```

2. Send a POST request to the `/sys/init` endpoint to initalize a new Vault server.
Save the results into a json file to extract the necessary items later.
> API: [ \[POST\] `/sys/init`](https://developer.hashicorp.com/vault/api-docs/system/init)
```
curl --request POST \
  --data @payload-init.json \
  $VAULT_ADDR/v1/sys/init \
  | jq > result-init.json
```

3. Extract the root token and the server's unseal key. We will setup the server with root access initially.
Eventually we will enable a separate auth method and perform operations as a dedicated user.
```
jq -r ".root_token" result-init.json > .vault_token
jq -r ".keys[]" result-init.json > .vault_unseal_key
```

4. Create an API request payload (`payload-unseal.json`) to unseal the server.
> API: [ \[POST\] `/sys/unseal`](https://developer.hashicorp.com/vault/api-docs/system/unseal)
```
tee payload-unseal.json <<EOF
{
  "key": "$(cat .vault_unseal_key)"
}
EOF
```

5. Unseal the Vault server at the `/sys/unseal` endpoint.
> API: [ \[POST\] `/sys/unseal`](https://developer.hashicorp.com/vault/api-docs/system/unseal)
```
curl -s --request POST \
  --data @payload-unseal.json \
  $VAULT_ADDR/v1/sys/unseal | jq

# Example output
{
  "sealed": false,
  "t": 3,
  "n": 5,
  "progress": 0,
  "version": "0.6.2",
  "cluster_name": "vault-cluster-d6ec3c7f",
  "cluster_id": "3e8b3fec-3749-e056-ba41-b62a63b997e8"
}
```
