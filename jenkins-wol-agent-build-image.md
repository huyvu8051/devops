
Below is a **minimal, production-ready “wake-on-LAN Jenkins agent” image** and everything you need to wire it into **Manage Jenkins → “Docker Cloud” → Template**.

---

### 1  Dockerfile  (`jenkins-wol-agent/Dockerfile`)

```Dockerfile
FROM jenkins/inbound-agent:latest-jdk17

USER root

RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
    wakeonlan etherwake iputils-ping \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY wol.sh /usr/local/bin/wol
RUN chmod +x /usr/local/bin/wol

USER jenkins
```

### 2  Helper wrapper  (`wol.sh`)

```bash
#!/usr/bin/env bash
# Usage: wol 00:11:22:33:44:55 192.168.1.255 9
MAC="$1"
# perl-based, no root needed
wakeonlan "${MAC}"
```

### 3  Build & push once

```bash
docker build -t <your-registry>/jenkins-wol-agent:1.0 .
docker push <your-registry>/jenkins-wol-agent:1.0
```

*(If you only use a local Docker host for agents you can skip the push.)*

---

### 4  Template settings in **Docker Cloud**

| Field                   | Value / Notes                                                                                                                                                                                                                                                                          |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Image**               | `your-registry/jenkins-wol-agent:1.0`                                                                                                                                                                                                                                                  |
| **Labels**              | `wol-sender` (use in `agent { label 'wol-sender' }`)                                                                                                                                                                                                                                   |
| **Remote FS Root**      | `/home/jenkins`                                                                                                                                                                                                                                                                        |
| **Instance Cap**        | `1` (it’s just a utility agent)                                                                                                                                                                                                                                                        |
| **Connect method**      | JNLP (secret, name, URL like any inbound agent)                                                                                                                                                                                                                                        |
| **Additional Run Args** | `--network host --cap-add NET_RAW --cap-add NET_BROADCAST --restart unless-stopped`<br>Host networking keeps the container on the same L2 segment so broadcast packets actually reach your LAN devices – the simplest reliable approach for WOL inside Docker ([docs.olivetin.app][1]) |

---

### 5  Smoke-test pipeline

```groovy
pipeline {
    agent { label 'wol-sender' }          // spins up the new image
    parameters {
        string(name:'MAC',     defaultValue:'00:11:22:33:44:55', description:'Target MAC')
    }
    stages {
        stage('Wake host') {
            steps {
                sh "wol ${params.MAC}"
            }
        }
    }
}
```

When the stage runs you should see:

```
Sending magic packet to 255.255.255.255:9 with 00:11:22:33:44:55
```

If the target machine’s BIOS/NIC is WOL-ready it will power on a few seconds later.

---

### 6  Practical tips & troubleshooting

| Checklist                       | Why it matters                                                   |
| ------------------------------- | ---------------------------------------------------------------- |
| **BIOS / UEFI WOL = ON**        | otherwise the NIC ignores the magic packet                       |
| **LAN switch allows broadcast** | some managed switches filter it                                  |
| **Firewall**                    | UDP 9 (or the port you chose) must be allowed on the Docker host |
| **MAC address correct**         | double-check no “-“ instead of “:”                               |
| **Multiple VLANs?**             | keep agent on the same VLAN/L2 as the target, or use a relay     |

---

That’s it!
Build once, register the template, and Jenkins can now spin up a lightweight agent that **wakes any box on your local network on demand** without having to keep a big host online 24 × 7.

[1]: https://docs.olivetin.app/solutions/wol/index.html?utm_source=chatgpt.com "Wake On LAN from a container - OliveTin docs"
