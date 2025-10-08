---
name: 'Bug report'
about: 'Create a report to help us improve this project!'
title: 'Explain Your Issue'
labels: 'needs triage'
---

## 🚨 Do not submit AI-generated reports

AI reports usually cite invalid sources and omit critical information that this template specifies.

---

### Describe the Bug

A clear and concise description of what the bug is.

### Your Runtime Command or Docker Compose File

Please censor anything sensitive. Your runtime command might look like this:

```shell
docker run --name="nightingale" -p 7777 -v ./nightingale:/config fireblade004/nightingale-server:latest
```

### Debug Output

Run the container with `DEBUG=true` as an environment variable, and it'll print out the system specs requested below, as
well as a bunch of information about your container (version, environment variables, etc.)

```shell
OUTPUT HERE
```

### System Specs (please complete the following information):

If you're on Linux, paste the following block as a single command, and paste the output here.

```shell
echo "===== START ISSUE REPORT =====
OS:  $(uname -a)
CPU: $(lscpu | grep 'Model name:' | sed 's/Model name:[[:space:]]*//g')
RAM: $(awk '/MemAvailable/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)GB/$(awk '/MemTotal/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)GB
HDD: $(df -h | awk '$NF=="/"{printf "%dGB/%dGB (%s used)\n", $3,$2,$5}')
===== END ISSUE REPORT ====="
```

Alternatively, you can find the information manually. Here's what we're looking for:

- OS: [e.g. Ubuntu 18.04 x86_64] (Linux: `uname -a`)
- CPU: [e.g. AMD Ryzen 5 3600 6-Core Processor] (Linux: `lscpu`)
- RAM: [e.g. 4GB/16GB] (Linux: `cat /proc/meminfo | grep Mem`)
- HDD; [e.g. 22GB/251GB (9% used)] (Linux: `df -h`)

### Logs

<details>
<summary>Click to expand full container logs</summary>

Please provide your container logs. Do not link to an external site for them, just paste them here.

```
PASTE YOUR LOGS HERE
```

</details>

### Additional Context

Add any other context about the problem here.