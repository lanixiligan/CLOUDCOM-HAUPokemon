# HAUPokemon 
This document outlines the cloud infrastructure and secure networking configuration for the HAUPokemon mobile ecosystem.

## ☁️ AWS EC2 Instances

The backend is architected using a decoupled approach, separating the API logic from the data persistence layer.

### 1. Database Tier (`hau-database-server`)
* **Role:** MySQL Host / Monster Data Storage
* **Instance ID:** `i-05eed06c8a863333f`
* **Public IP:** `3.91.206.113`
* **Private IP:** `10.0.1.169`
* **Security:** Access restricted via `haudbkp.pem`

### 2. Web Tier (`hau-web-server`)
* **Role:** Node.js API Gateway / Application Logic
* **Instance ID:** `i-05ce381fccaf8c19e`
* **Public IP:** `15.237.195.254`
* **Private IP:** `10.1.1.153`
* **Security:** Access restricted via `hauwebkp.pem`

---

## 🔒 Secure Networking (Tailscale)

| Parameter | Configuration |
| :--- | :--- |
| **Gateway IP** | `100.73.206.81` |
| **Protocol** | WireGuard® Mesh VPN |
| **Auth Key** | `tskey-auth-k2FEJ4YHGJ11CNTRL-ZpmeP9zxfu1HcEA4UgvCv1vt6z18GaAw` |

---

## 🔑 SSH Key Management & Setup

To manage the server infrastructure, the required RSA private keys must be placed in the project directory.

### Directory Placement
Place your downloaded `.pem` files in the following location:
`project_root/lib/EC2KEYS/`

### Download & Permission Instructions
1. **Download:** Securely transfer `haudbkp.pem` and `hauwebkp.pem` from your secure storage to `lib/EC2KEYS/`.
2. **Set Permissions:** On Linux/Mac, you must restrict file permissions, or the SSH connection will be rejected:
   ```bash
   cd lib/EC2KEYS
   chmod 400 haudbkp.pem
   chmod 400 hauwebkp.pem

### Testing & QA Credentials
To verify the system functionality on the website or mobile app, use the following authorized testing account:

**Username:** testuser
**Password:** test123
Access Level: Standard Hunter (Registry Access Enabled)
