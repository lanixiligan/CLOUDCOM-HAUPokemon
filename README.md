# HAUPokemon Infrastructure Registry

This document outlines the cloud infrastructure and secure networking configuration for the HAUPokemon mobile ecosystem.

## ☁️ AWS EC2 Instances

The backend is architected using a decoupled approach, separating the API logic from the data persistence layer.

### 1. Database Tier (`hau-database-server`)
* **Role:** MySQL Host / Monster Data Storage
* **Instance ID:** `i-05eed06c8a863333f`
* **Networking:**
    * **Public IP:** `3.91.206.113`
    * **Private IP:** `10.0.1.169`
* **Security:** Access restricted via `haudbkp.pem`

### 2. Web Tier (`hau-web-server`)
* **Role:** Node.js API Gateway / Application Logic
* **Instance ID:** `i-05ce381fccaf8c19e`
* **Networking:**
    * **Public IP:** `15.237.195.254`
    * **Private IP:** `10.1.1.153`
* **Security:** Access restricted via `hauwebkp.pem`

---

## 🔒 Secure Networking (Tailscale)

To ensure encrypted communication between the Flutter client and the AWS VPC, **Tailscale** is implemented as a Zero-Trust networking overlay.

| Parameter | Configuration |
| :--- | :--- |
| **Gateway IP** | `100.73.206.81` |
| **Protocol** | WireGuard® Mesh VPN |
| **Auth Key** | `tskey-auth-k2FEJ...GaAw` (Masked for Security) |

### Connection Flow
1. **Client Authentication:** Mobile device authenticates via the Tailscale Auth Key.
2. **Encrypted Tunnel:** A point-to-point tunnel is established to the Web Server.
3. **Internal Routing:** The Web Server communicates with the Database Server over the AWS Private Network (`10.x.x.x`).

---

## 🔑 Key Management

| Key Name | Type | Target |
| :--- | :--- | :--- |
| `haudbkp.pem` | RSA Private Key | Database Server SSH |
| `hauwebkp.pem` | RSA Private Key | Web Server SSH |
| `JWT_SECRET` | Auth Token | API Authorization |

---

## 🚀 Deployment Notes
- Ensure the `.pem` files have permissions set to `400` before attempting SSH:
  ```bash
  chmod 400 hauwebkp.pem
  ssh -i "hauwebkp.pem" ubuntu@15.237.195.254
