# Commands Reference

This folder contains comprehensive command references for the TLS/HTTPS Implementation project.

## Files

### 01_certificate_generation.md
Complete guide to generating certificates using OpenSSL:
- Root CA creation (server and client)
- Server certificate generation and signing
- Client certificate generation and signing
- Certificate verification commands
- Security best practices

**Use this when:** Setting up PKI infrastructure from scratch

### 02_server_client_commands.md
TLS server and client implementation commands:
- OpenSSL s_server configuration
- OpenSSL s_client usage
- Connection testing procedures
- Advanced options (TLS versions, cipher suites)
- Troubleshooting guide
- Performance testing

**Use this when:** Running TLS applications and testing connections

### 03_wireshark_analysis.md
Wireshark traffic capture and analysis:
- Installation and setup
- Capture filters for TLS traffic
- Display filters for analysis
- TLS decryption configuration
- Session key logging setup
- Command-line alternatives (tcpdump, tshark)
- Troubleshooting decryption issues

**Use this when:** Capturing and analyzing network traffic

## Quick Start

### 1. Generate Certificates
```bash
# Server VM
cd ~/certs
openssl genrsa -out rootCA.key 2048
openssl req -new -x509 -days 365 -key rootCA.key -out rootCA.crt
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr
openssl x509 -req -in server.csr -CA rootCA.crt -CAkey rootCA.key \
  -CAcreateserial -out server.crt -days 365 -sha256

# Client VM  
cd ~/certs
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr
openssl genrsa -out rootCA.key 2048
openssl req -new -x509 -days 365 -key rootCA.key -out rootCA.crt
openssl x509 -req -in client.csr -CA rootCA.crt -CAkey rootCA.key \
  -CAcreateserial -out client.crt -days 365 -sha256
```

### 2. Start TLS Server (Server VM)
```bash
cd ~/certs
openssl s_server -cert server.crt -key server.key \
  -accept 8443 -keylogfile keylog.txt
```

### 3. Start Wireshark (Server VM)
```bash
sudo wireshark
# Apply filter: ip.addr == 192.168.254.168 || ip.addr == 192.168.254.169
# Start capture
```

### 4. Connect Client (Client VM)
```bash
cd ~/certs
openssl s_client -connect 192.168.254.168:8443 \
  -cert client.crt -key client.key
```

### 5. Configure Wireshark Decryption
```
Edit → Preferences → Protocols → TLS
(Pre-)Master-Secret log filename: /home/mint/certs/keylog.txt
OK
```

### 6. Analyze Traffic
- Encrypted: Follow → TCP Stream (see gibberish)
- Decrypted: Filter `http` → Follow → HTTP Stream (see plaintext)

## Command Cheat Sheet

### Certificates
```bash
# Generate key
openssl genrsa -out file.key 2048

# Create CSR
openssl req -new -key file.key -out file.csr

# Self-sign certificate
openssl req -new -x509 -days 365 -key file.key -out file.crt

# Sign with CA
openssl x509 -req -in file.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out file.crt -days 365 -sha256

# View certificate
openssl x509 -in file.crt -text -noout

# Verify certificate
openssl verify -CAfile ca.crt file.crt
```

### TLS Server/Client
```bash
# Server
openssl s_server -cert server.crt -key server.key \
  -accept PORT -keylogfile keylog.txt

# Client
openssl s_client -connect IP:PORT \
  -cert client.crt -key client.key

# With specific TLS version
-tls1_2  # Force TLS 1.2
-tls1_3  # Force TLS 1.3
```

### Wireshark/Network
```bash
# Capture with tcpdump
sudo tcpdump -i eth0 -w capture.pcap 'port 8443'

# Analyze with tshark
tshark -r capture.pcap -Y "tls" -V

# Decrypt with tshark
tshark -r capture.pcap \
  -o tls.keylog_file:keylog.txt \
  -Y "http"
```

## File Permissions
```bash
# Private keys (restrictive)
chmod 600 *.key

# Certificates (readable)
chmod 644 *.crt

# Keylog (readable)
chmod 644 keylog.txt
```

## Network Testing
```bash
# Test connectivity
ping IP_ADDRESS

# Check port
netstat -tuln | grep PORT
sudo ss -tuln | grep PORT

# Test TLS connection
openssl s_client -connect IP:PORT -showcerts
```

## Troubleshooting

### Certificate Issues
```bash
# Verify certificate chain
openssl verify -CAfile rootCA.crt server.crt

# Check certificate details
openssl x509 -in server.crt -noout -subject -issuer -dates

# Test certificate with server
openssl s_server -cert server.crt -key server.key -www
```

### Connection Issues
```bash
# Check if server is listening
sudo netstat -tuln | grep 8443

# Test connection without certificates
openssl s_client -connect 192.168.254.168:8443

# Enable firewall port
sudo ufw allow 8443/tcp
```

### Decryption Issues
```bash
# Verify keylog has content
cat keylog.txt | head

# Expected format
CLIENT_RANDOM <hex1> <hex2>

# Check Wireshark configuration
Edit → Preferences → Protocols → TLS
(Pre-)Master-Secret log filename: /path/to/keylog.txt
```

## Additional Resources

- **OpenSSL Documentation:** https://www.openssl.org/docs/
- **Wireshark User Guide:** https://www.wireshark.org/docs/
- **TLS 1.2 RFC:** https://tools.ietf.org/html/rfc5246
- **TLS 1.3 RFC:** https://tools.ietf.org/html/rfc8446

## Notes

- All commands assume Linux Mint environment
- Adjust paths and IP addresses for your setup
- Private keys should NEVER be committed to version control
- Session keys (keylog.txt) should be deleted after analysis
- Use strong passphrases in production environments
