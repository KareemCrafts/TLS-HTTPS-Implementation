# Wireshark Traffic Capture and Analysis

## Prerequisites

### Install Wireshark
```bash
sudo apt update
sudo apt install wireshark -y

# Add user to wireshark group (for non-root capture)
sudo usermod -aG wireshark $USER

# Reboot or log out/in for changes to take effect
```

---

## Traffic Capture

### Start Wireshark
```bash
sudo wireshark
```

### Capture Filter Configuration

**Before starting capture, set this filter:**
```
ip.addr == 192.168.254.168 || ip.addr == 192.168.254.169
```

This captures only traffic between your server and client VMs.

### Capture Procedure

1. **Select Network Interface:**
   - Usually `eth0` or `ens33` for VMware
   - Look for the interface showing network activity

2. **Apply Capture Filter:**
   - Enter the IP filter in the capture filter box
   - Click the blue shark fin icon to start capture

3. **Execute TLS Connection:**
   - Start TLS server on server VM
   - Connect with TLS client from client VM
   - Perform data exchange

4. **Stop Capture:**
   - Click the red square icon to stop
   - Save as: `tls_client_server_231012043.pcap`

---

## Encrypted Traffic Analysis

### Display Filters for Encrypted Traffic

**Show only TLS packets:**
```
tls
```

**Show TLS between specific IPs:**
```
ip.addr == 192.168.254.168 && ip.addr == 192.168.254.169 && tls
```

**Show TLS handshake only:**
```
tls.handshake
```

**Show TLS Application Data (encrypted payload):**
```
tls.app_data
```

### What to Look For in Encrypted Capture

✅ **Client Hello** - Client initiating TLS handshake  
✅ **Server Hello** - Server responding with chosen cipher suite  
✅ **Certificate** - Server presenting X.509 certificate  
✅ **Server Key Exchange** - Diffie-Hellman parameters  
✅ **Certificate Request** - Server requesting client cert  
✅ **Client Certificate** - Client presenting X.509 certificate  
✅ **Client Key Exchange** - Encrypted pre-master secret  
✅ **Change Cipher Spec** - Switching to encrypted mode  
✅ **Encrypted Application Data** - All data encrypted (unreadable)  

### Following TCP Stream (Encrypted)

1. Right-click on any TLS packet
2. Select: **Follow → TCP Stream**
3. You'll see gibberish (encrypted data)

---

## TLS Decryption Setup

### Configure Wireshark to Decrypt TLS

1. **Navigate to Preferences:**
   - **Edit → Preferences → Protocols → TLS**

2. **Set Key Log File:**
   - **(Pre-)Master-Secret log filename:**
   - Enter: `/home/mint/certs/keylog.txt`
   - Click **OK**

3. **Wireshark automatically decrypts** all captured TLS traffic using these session keys

### Verify Keylog File

Before decryption, verify your keylog.txt has content:

```bash
cat ~/certs/keylog.txt
```

**Expected output:**
```
CLIENT_RANDOM 5a7b3c9d... 2c3d8f1e...
CLIENT_RANDOM 8f1e4a2b... a9b4c6d2...
```

If file is **empty**, regenerate keylog:
1. Stop server
2. Start server with: `openssl s_server ... -keylogfile keylog.txt`
3. Reconnect client
4. Check keylog.txt again

---

## Decrypted Traffic Analysis

### Display Filters for Decrypted Traffic

**Show HTTP (decrypted from TLS):**
```
http
```

**Show HTTP requests:**
```
http.request
```

**Show HTTP responses:**
```
http.response
```

**Show specific HTTP methods:**
```
http.request.method == "GET"
```

### What to Look For in Decrypted Capture

✅ **HTTP Protocol** visible instead of TLS  
✅ **Plain text HTTP headers** readable  
✅ **GET requests** clearly visible  
✅ **HTTP 200 OK responses** readable  
✅ **HTML content** exposed in plain text  

### Following HTTP Stream (Decrypted)

1. Right-click on any HTTP packet
2. Select: **Follow → HTTP Stream**
3. You'll see plain HTTP conversation:

```
GET / HTTP/1.1
Host: 192.168.254.168:8443

HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 46

<html><body><h1>Hello from TLS Server!</h1></body></html>
```

---

## Save Captures

### Save Encrypted Capture
```
File → Save As → tls_client_server_231012043.pcap
```

### Save Decrypted Capture
```
File → Save As → tls_decrypted_client_server_231012043.pcap
```

**Note:** The decrypted capture file still contains encrypted TLS packets, but Wireshark will decrypt them when opened with the keylog file loaded.

---

## Command-Line Packet Capture (Alternative)

### Using tcpdump

**Capture TLS traffic:**
```bash
sudo tcpdump -i eth0 -w tls_capture.pcap \
  'host 192.168.254.168 and host 192.168.254.169 and port 8443'
```

**Parameters:**
- `-i eth0` - Interface to capture on
- `-w tls_capture.pcap` - Output file
- `host ... and port 8443` - Filter for TLS traffic on port 8443

**Stop capture:** Press `Ctrl+C`

### Using tshark (Wireshark CLI)

**Capture with display filter:**
```bash
tshark -i eth0 -w tls_capture.pcap \
  -f "tcp port 8443" -Y "tls"
```

**Read and decrypt capture:**
```bash
tshark -r tls_capture.pcap \
  -o tls.keylog_file:/home/mint/certs/keylog.txt \
  -Y http
```

---

## Analysis Commands

### Extract TLS Handshake Information

**Show cipher suites:**
```bash
tshark -r tls_client_server_231012043.pcap \
  -Y "tls.handshake.type == 1" \
  -T fields -e tls.handshake.ciphersuite
```

**Show TLS version:**
```bash
tshark -r tls_client_server_231012043.pcap \
  -Y "tls.handshake.type == 2" \
  -T fields -e tls.handshake.version
```

**Show server certificate:**
```bash
tshark -r tls_client_server_231012043.pcap \
  -Y "tls.handshake.type == 11" \
  -T fields -e x509ce.dNSName
```

### Extract HTTP from Decrypted Traffic

**Show all HTTP requests:**
```bash
tshark -r tls_decrypted_client_server_231012043.pcap \
  -o tls.keylog_file:/home/mint/certs/keylog.txt \
  -Y "http.request" \
  -T fields -e http.request.method -e http.request.uri
```

**Show HTTP responses:**
```bash
tshark -r tls_decrypted_client_server_231012043.pcap \
  -o tls.keylog_file:/home/mint/certs/keylog.txt \
  -Y "http.response" \
  -T fields -e http.response.code -e http.response.phrase
```

---

## Statistics and Analysis

### Protocol Hierarchy
```
Statistics → Protocol Hierarchy
```

Shows breakdown of:
- Ethernet frames
- IP packets
- TCP segments
- TLS records
- HTTP messages

### Conversations
```
Statistics → Conversations
```

Shows:
- TCP conversations between client and server
- Bytes transferred
- Packets exchanged

### IO Graph
```
Statistics → IO Graphs
```

Visualizes:
- Traffic rate over time
- Packet size distribution

---

## Troubleshooting Wireshark Decryption

### Problem: No HTTP Shown After Loading Keylog

**Possible causes:**

1. **Keylog file is empty**
   ```bash
   cat ~/certs/keylog.txt
   # Should show CLIENT_RANDOM entries
   ```

2. **Wrong keylog path in Wireshark**
   - Verify: Edit → Preferences → Protocols → TLS
   - Path must be absolute: `/home/mint/certs/keylog.txt`

3. **Capture doesn't contain TLS traffic**
   ```bash
   tshark -r capture.pcap -Y "tls" | head
   # Should show TLS packets
   ```

4. **TLS 1.3 with 0-RTT** (advanced)
   - Some TLS 1.3 features may not decrypt
   - Try forcing TLS 1.2 on server/client

### Verify Decryption Works

**Test with tshark:**
```bash
tshark -r tls_client_server_231012043.pcap \
  -o tls.keylog_file:/home/mint/certs/keylog.txt \
  -Y "http" -V | grep "HTTP"
```

If this shows HTTP, decryption works!

---

## Export Decrypted Data

### Export HTTP Objects
```
File → Export Objects → HTTP
```

This extracts all HTTP files transferred over the decrypted TLS connection.

### Export Packet Dissections
```
File → Export Packet Dissections → As Plain Text
```

Saves packet details to text file for analysis.

---

## Best Practices

✅ **Always capture BEFORE starting TLS connection** to get full handshake  
✅ **Use display filters** to focus on relevant traffic  
✅ **Save both encrypted and decrypted** captures for comparison  
✅ **Verify keylog.txt has content** before expecting decryption  
✅ **Document your filter strings** for reproducibility  

---

## Security Note

🔒 **Keylog files contain session secrets!** 

- Never share keylog.txt files publicly
- Delete keylog.txt after analysis
- Only use for authorized security testing
- Session keys allow decryption of all captured traffic
