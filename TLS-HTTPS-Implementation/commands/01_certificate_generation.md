# Certificate Generation Commands

## Server-Side Certificate Generation

### 1. Create Certificate Directory
```bash
mkdir -p ~/certs && cd ~/certs
```

### 2. Generate Root CA Private Key (2048-bit RSA)
```bash
openssl genrsa -out rootCA.key 2048
```

### 3. Generate Self-Signed Root CA Certificate
```bash
openssl req -new -x509 -days 365 -key rootCA.key -out rootCA.crt
```

**Enter the following information:**
- Country Name (2 letter code): `EG`
- State or Province Name: `Alexandria`
- Locality Name: `Alexandria`
- Organization Name: `AAST`
- Organizational Unit Name: `MyRootCA`
- Common Name: `KareemServer`
- Email Address: `kareemtamer2512@gmail.com`

### 4. Generate Server Private Key
```bash
openssl genrsa -out server.key 2048
```

### 5. Create Server Certificate Signing Request (CSR)
```bash
openssl req -new -key server.key -out server.csr
```

**IMPORTANT:** Set Common Name (CN) to your server IP address: `192.168.254.168`

### 6. Sign Server Certificate with Root CA
```bash
openssl x509 -req -in server.csr -CA rootCA.crt -CAkey rootCA.key \
  -CAcreateserial -out server.crt -days 365 -sha256
```

---

## Client-Side Certificate Generation

### 1. Create Certificate Directory
```bash
mkdir -p ~/certs && cd ~/certs
```

### 2. Generate Client Private Key
```bash
openssl genrsa -out client.key 2048
```

### 3. Create Client Certificate Signing Request (CSR)
```bash
openssl req -new -key client.key -out client.csr
```

**Enter the following information:**
- Country Name: `EG`
- State: `Alexandria`
- Locality: `Alexandria`
- Organization: `AAST`
- Organizational Unit: `MYCLIENT`
- Common Name: `myclient`
- Email Address: `your_email@example.com`

### 4. Generate Local Root CA (Independent)
```bash
openssl genrsa -out rootCA.key 2048
openssl req -new -x509 -days 365 -key rootCA.key -out rootCA.crt
```

### 5. Sign Client Certificate
```bash
openssl x509 -req -in client.csr -CA rootCA.crt -CAkey rootCA.key \
  -CAcreateserial -out client.crt -days 365 -sha256
```

---

## Certificate Security

### Set Proper File Permissions
```bash
# Make private keys readable only by owner
chmod 600 rootCA.key server.key client.key

# Public certificates can remain readable
chmod 644 rootCA.crt server.crt client.crt
```

---

## Verify Certificates

### View Certificate Details
```bash
# View Root CA certificate
openssl x509 -in rootCA.crt -text -noout

# View Server certificate
openssl x509 -in server.crt -text -noout

# View Client certificate
openssl x509 -in client.crt -text -noout
```

### Verify Certificate Chain
```bash
# Verify server certificate was signed by Root CA
openssl verify -CAfile rootCA.crt server.crt

# Verify client certificate was signed by Root CA
openssl verify -CAfile rootCA.crt client.crt
```

---

## Certificate Information Summary

| Component | File | Key Size | Validity | Algorithm |
|-----------|------|----------|----------|-----------|
| Root CA Key | rootCA.key | 2048-bit RSA | - | RSA |
| Root CA Cert | rootCA.crt | - | 365 days | Self-signed |
| Server Key | server.key | 2048-bit RSA | - | RSA |
| Server Cert | server.crt | - | 365 days | SHA-256 |
| Client Key | client.key | 2048-bit RSA | - | RSA |
| Client Cert | client.crt | - | 365 days | SHA-256 |
