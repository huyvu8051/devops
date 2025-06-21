
To **test the Wake-on-LAN Docker image locally**, follow these steps after building it:

---

## ✅ 1. Build the image

In the folder with your `Dockerfile` and `wol.sh`:

```bash
docker build -t jenkins-wol-agent:latest .
```

---

## ✅ 2. Run the container interactively

We use `--network host` so the container shares the host network, which is **required to send WOL broadcast packets**:

```bash
docker run -it --rm \
  --network host \
  --cap-add NET_BROADCAST \
  --cap-add NET_RAW \
  jenkins-wol-agent:latest \
  bash
```

You’ll be dropped into a shell inside the container.

---

## ✅ 3. Send the Wake-on-LAN packet

Run the helper script you added:

```bash
wol 00:e3:4f:98:35:15
 
```

Replace:

* `00:11:22:33:44:55` with the **MAC address** of the target device.

You should see output like:

```bash
Sending magic packet to 192.168.1.255:9 with 00:11:22:33:44:55
```

---

## 🧪 4. Confirm the target device powers on

If not, check:

* The target machine supports WOL (BIOS/UEFI setting is enabled)
* It's connected via Ethernet (most Wi-Fi NICs don’t support WOL)
* Your router/switch allows UDP broadcasts
* The MAC address is correct and formatted with colons `:` (not dashes)

---

## 🧼 Optional: Run from host without entering container

You can also run WOL in a single command like this:

```bash
docker run --rm \
  --network host \
  --cap-add NET_BROADCAST \
  --cap-add NET_RAW \
  jenkins-wol-agent:1.0 \
  wol 00:e3:4f:98:35:15

```

---

Let me know if you want to **add logging**, test multiple devices, or run it as a background service (e.g., on reboot).
