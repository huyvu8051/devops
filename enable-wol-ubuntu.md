To make the `Wake-on-LAN (WOL)` setting (`g` for **MagicPacket**) persistent across reboots on Ubuntu, you can follow one of these common methods:

---

### ✅ **Method 1: Use systemd service (Recommended)**

1. **Create a custom systemd service:**

```bash
sudo nano /etc/systemd/system/wol.service
```

2. **Paste the following content:**

```ini
[Unit]
Description=Enable Wake-on-LAN on enp7s0
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ethtool -s enp7s0 wol g

[Install]
WantedBy=multi-user.target
```

> Make sure `/sbin/ethtool` is the correct path on your system (verify with `which ethtool` if needed).

3. **Enable and start the service:**

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable wol.service
sudo systemctl start wol.service
```

4. **Verify after reboot:**

```bash
ethtool enp7s0 | grep Wake-on
```

---

### ✅ **Alternative: Add to rc.local (if available)**

If you're using an older Ubuntu system with `/etc/rc.local`, you can add:

```bash
/sbin/ethtool -s enp7s0 wol g
```

Just make sure the file is executable:

```bash
sudo chmod +x /etc/rc.local
```

---
