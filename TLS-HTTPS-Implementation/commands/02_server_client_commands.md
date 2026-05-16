# TLS Server and Client Commands

## Prerequisites

### Install OpenSSL Development Libraries
```bash
sudo apt update
sudo apt install libssl-dev -y
```

---

## TLS Server

### Start TLS Server with Key Logging
```bash
cd ~/certs
openssl s_server -cert server.crt -key server.key \
  -accept 8443 -keylogfile keylog.txt
```

### Server Command Breakdown
- `openssl s_server` - Launch OpenSSL TLS server
- `-cert server.crt` - Use server certificate for authentication
- `-key server.key` - Use server private key
- `-accept 8443` - Listen on port 8443 (HTTPS)
- `-keylogfile keylog.txt` - Log session keys for Wireshark decryption

### Server Features
✅ Listens on port 8443 for incoming TLS connections  
✅ Uses server.crt and server.key for authentication  
✅ Logs session keys to keylog.txt for Wireshark decryption  
✅ Supports TLS 1.2 and TLS 1.3 protocols  
✅ Performs certificate-based client authentication  

### Expected Server Output
```
TLS Server listening on port 8443...
Client connected securely!
```

---

## TLS Client

### Connect to TLS Server
```bash
cd ~/certs
openssl s_client -connect 192.168.254.168:8443 \
  -cert client.crt -key client.key
```

### Client Command Breakdown
- `openssl s_client` - Launch OpenSSL TLS client
- `-connect 192.168.254.168:8443` - Connect to server IP and port
- `-cert client.crt` - Present client certificate for mutual authentication
- `-key client.key` - Use client private key

### Client Features
✅ Connects to server at 192.168.254.168 on port 8443  
✅ Presents client certificate for mutual authentication  
✅ Verifies server certificate during TLS handshake  
✅ Establishes encrypted session for data transmission  

### Expected Client Output
```
Connected to TLS server!
Received:
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 46

<html><body><h1>Hello from TLS Server!</h1></body></html>
```

---

## Testing the Connection

### Step-by-Step Test Procedure

1. **On Server VM (192.168.254.168):**
   ```bash
   cd ~/certs
   openssl s_server -cert server.crt -key server.key \
     -accept 8443 -keylogfile keylog.txt
   ```
   
   Wait for: `TLS Server listening on port 8443...`

2. **On Client VM (192.168.254.169):**
   ```bash
   cd ~/certs
   openssl s_client -connect 192.168.254.168:8443 \
     -cert client.crt -key client.key
   ```
   
   Wait for connection and certificate verification

3. **Verify Connection:**
   - Server should print: `Client connected securely!`
   - Client should receive HTTP response with HTML content

---

## Advanced Server Options

### Server with Verbose Output
```bash
openssl s_server -cert server.crt -key server.key \
  -accept 8443 -keylogfile keylog.txt -debug
```

### Server with Specific TLS Version
```bash
# Force TLS 1.2
openssl s_server -cert server.crt -key server.key \
  -accept 8443 -tls1_2

# Force TLS 1.3
openssl s_server -cert server.crt -key server.key \
  -accept 8443 -tls1_3
```

### Server with Client Certificate Verification
```bash
openssl s_server -cert server.crt -key server.key \
  -accept 8443 -verify 1 -CAfile rootCA.crt
```

---

## Advanced Client Options

### Client with Verbose Connection Info
```bash
openssl s_client -connect 192.168.254.168:8443 \
  -cert client.crt -key client.key -showcerts
```

### Client with Specific TLS Version
```bash
# Use TLS 1.2
openssl s_client -connect 192.168.254.168:8443 \
  -cert client.crt -key client.key -tls1_2

# Use TLS 1.3
openssl s_client -connect 192.168.254.168:8443 \
  -cert client.crt -key client.key -tls1_3
```

### Client with Cipher Suite Selection
```bash
openssl s_client -connect 192.168.254.168:8443 \
  -cert client.crt -key client.key \
  -cipher 'ECDHE-RSA-AES256-GCM-SHA384'
```

---

## Troubleshooting

### Common Issues

1. **Connection Refused:**
   - Verify server is running: `netstat -tuln | grep 8443`
   - Check firewall rules: `sudo ufw status`

2. **Certificate Verification Failed:**
   - Verify certificates: `openssl verify -CAfile rootCA.crt server.crt`
   - Check certificate CN matches server IP

3. **Keylog File Not Generated:**
   - Ensure proper permissions: `chmod 644 keylog.txt`
   - Verify file path is correct
   - Check if keylog.txt exists before starting server

### Check Session Keys
```bash
# Verify keylog.txt contains session keys
cat keylog.txt | head -5
```

Expected format:
```
CLIENT_RANDOM <hex> <hex>
CLIENT_RANDOM <hex> <hex>
...
```

---

## Network Configuration

### Firewall Rules (if needed)
```bash
# Allow port 8443 on server
sudo ufw allow 8443/tcp
sudo ufw reload
```

### Check Port Status
```bash
# Verify server is listening
sudo netstat -tuln | grep 8443

# Or using ss
sudo ss -tuln | grep 8443
```

---

## Session Key Logging for Wireshark

### Verify Keylog File
```bash
# Check if keylog.txt exists and has content
ls -lh ~/certs/keylog.txt
cat ~/certs/keylog.txt
```

### Expected Keylog Format
```
CLIENT_RANDOM 5a7b... 2c3d...
CLIENT_RANDOM 8f1e... a9b4...
```

Each line contains:
- `CLIENT_RANDOM` - Key type
- First hex string - Client random (64 hex chars)
- Second hex string - Master secret (96 hex chars)

---

## Performance Testing

### Test Multiple Connections
```bash
# Run 10 sequential connections
for i in {1..10}; do
  echo "Connection $i"
  echo "GET /" | openssl s_client -connect 192.168.254.168:8443 \
    -cert client.crt -key client.key -quiet
done
```

### Measure Connection Time
```bash
time openssl s_client -connect 192.168.254.168:8443 \
  -cert client.crt -key client.key
```
