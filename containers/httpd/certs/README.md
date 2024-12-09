# SSL-Certificates for HTTPS and HTTP/2 support 

## Generation of certificates

### ATTENTION:
The following steps are not necessary anymore, as the needed CA-files and the SSL-certificates 
for the server are already existing in the current directory (`containers/httpd/certs`) of the SDK.

### Create a Certificate Authority (CA)
Configurations, done in `openssl-ca.conf`, are used to create the *CA-Certificate* (`oxid_esales_localhost_ca.crt`)
and the *CA-Key* (`ca.key`).

```shell
openssl req -x509 -config openssl-ca.conf -days 365 -newkey rsa:4096 -sha256 -nodes -out oxid_esales_localhost_ca.crt
```

### Generate the Server Key and Certificate Signing Request (CSR)
Configurations, done in `openssl-server.conf`, are used to create the *Certificate Signing Request (CSR)* for the server
(`server.csr`) and the SSL-key (`server.key`).

```shell
openssl req -config openssl-server.conf -newkey rsa:2048 -sha256 -nodes -out server.csr
```

The *Certificate Signing Request (CSR)* is used to generate the final SSL-Certificate.

### Sign the Server Certificate
The *CA-Certificate* will be used to sign the previously created *Certificate Signing Request (CSR)* and finally creates
the SSL-Certificate (`server.crt`) for the server.

Therefore we have two possibilities:

**The first one** creates the SSL-Certificate and the database and serial-files. This is interesting if you might want to
create multiple SSL-Certificates from the CSR. This solution creates and stores and updates the serial-number
automatically in a database (`index.txt`) and a serial-file (`serial.txt`).
To store the serials we need to create database file:
```shell
touch index.txt
```
and the file with the current serial number:
```shell
echo '01' > serial.txt
```

Afterwards we can generate the *Server SSL-Certificate* by passing the used config file for this process.

```shell
openssl ca -config openssl-ca.conf -policy signing_policy -extensions signing_req -out server.crt -infiles server.csr
```


**The second one** creates the *Server SSL-Certificate* without any database or serial file. Without a database or
serial file, you will need to manage certificate tracking and revocation manually.

```shell
openssl x509 -req -in server.csr -CA oxid_esales_localhost_ca.crt -CAkey ca.key -out server.crt -days 365 -sha256 -set_serial 01
```

**The second method without a database file was used for our SSL-Certificate which is already existing in our SDK, because
only a single certificate is necessary for development purpose.**

## Adding Self-signed CA Certificates

### Adding Certificates to the Local Key Store

#### macOS
1. **Keychain:**
    - Open the Terminal and execute the following command:
      ```bash
      sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain <certificate.pem>
      ```
    - Replace `<certificate.pem>` with the path to your certificate.

2. **Manual Addition:**
    - Open the **Keychain Access** application.
    - Drag and drop the `.pem` file into the **"System"** or **"Login"** keychain.
    - Right-click the certificate → **Get Info** → **Trust** → Set "When using this certificate" to **Always Trust**.

---

#### Linux
1. **System-wide CA Store (Debian/Ubuntu):**
    - Copy the certificate to the CA directory:
      ```bash
      sudo cp <certificate.pem> /usr/local/share/ca-certificates/
      ```
    - Update the CA store:
      ```bash
      sudo update-ca-certificates
      ```

2. **Red Hat/CentOS:**
    - Copy the certificate:
      ```bash
      sudo cp <certificate.pem> /etc/pki/ca-trust/source/anchors/
      ```
    - Update the CA store:
      ```bash
      sudo update-ca-trust
      ```

---

#### Windows
1. **Management Console (MMC):**
    - Press `Win + R`, type `mmc`, and press Enter.
    - File → Add/Remove Snap-in → **Certificates** → **Computer Account** → Local Computer

2. **Import Certificate:**
    - Navigate to **Trusted Root Certification Authorities** → Right-click → **All Tasks** → **Import**.
    - Follow the wizard and select the `.pem` or `.crt` file.

---

### Manually Adding Certificates in Browsers

#### Firefox
1. Open Firefox settings:
    - **Settings → Privacy & Security → Certificates → View Certificates**.
2. Import the certificate:
    - Go to the **Authorities** tab → Click **Import**.
    - Select the certificate and enable **Trust this CA to identify websites**.

---

### Chrome
1. Open Chrome settings:
    - **Settings → Privacy and Security → Security → Manage certificates** (under **Advanced** settings).
2. Import the certificate:
    - Switch to the **Authorities** tab → Click **Import**.
    - Select the `.pem` or `.crt` file and confirm.
    - Enable the appropriate trust options (e.g., **Trust this certificate for identifying websites**) and click **OK**.

---

### Safari
1. Open Safari settings:
    - Go to **Preferences → Privacy → Manage Website Data** (or **Certificates**, depending on the version).
2. Import the certificate:
    - Drag and drop the certificate into the window or use the import option.
    - Confirm the trust settings if prompted.

---

## Summary
- **System Key Store:** Most browsers (Chrome, Safari) rely on the system-wide certificate store.
- **Browser-specific:** Firefox requires manual configuration, while Chrome and Safari use the system key store by default.

