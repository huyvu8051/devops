Below is a minimal, self-contained Bash script that watches Docker once every **10 seconds**.
If it sees **zero running containers for a full two-minute window** (120 s) it hibernates the host with `systemctl hibernate`.

```bash
#!/usr/bin/env bash
# File: /usr/local/sbin/docker-idle-hibernate.sh
# Purpose: Hibernate the machine after 2 min with no running Docker containers.

GRACE=120      # seconds of continuous idleness before we hibernate (2 minutes)
INTERVAL=10    # check every 10 seconds
idle=0         # how long we've been idle so far

while true; do
    # Are there *any* running containers?
    if docker ps -q --filter "status=running" | grep -q .; then
        idle=0                      # reset the idle counter
    else
        idle=$(( idle + INTERVAL )) # accumulate idle time
    fi

    if (( idle >= GRACE )); then
        echo "No running containers for ${GRACE}s — hibernating…" | systemd-cat -t docker-idle
        systemctl hibernate
        exit 0                      # should never return, but be tidy
    fi

    sleep "$INTERVAL"
done
```

### Make it executable

```bash
sudo install -m 755 docker-idle-hibernate.sh /usr/local/sbin/
```

---

## Run it automatically at boot with systemd

Create **`/etc/systemd/system/docker-idle-hibernate.service`**:

```ini
[Unit]
Description=Hibernate host when Docker has been idle 2 minutes
After=network-online.target docker.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/docker-idle-hibernate.sh
Restart=always
Nice=10                # lower priority
IOSchedulingClass=idle # be gentle to disk

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now docker-idle-hibernate.service
```

The script now runs in the background from the moment the system boots, whether or not anyone is logged in.

---

### What to check if it doesn’t hibernate

1. **Hibernate support**
   Ensure `/sys/power/disk` lists `platform shutdown hibernate`.
   If not, configure swap large enough and, on Ubuntu, set `AllowHibernation=yes` in `/etc/systemd/sleep.conf` (then `systemctl daemon-reload`).

2. **Docker daemon active**
   The `docker ps` call only works when Dockerd is running. If you sometimes stop Dockerd, add `Requires=docker.service` to the unit.

3. **Permissions**
   The service runs as **root**, so `systemctl hibernate` will succeed.
   If you ever run the script manually as a regular user, you’ll need sudo or `polkit` rules.

---
