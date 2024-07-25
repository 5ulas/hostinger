I assume I'm working with a machine directly (not a container).

First of all I'd try to identify which exact service is failing since the end-functionality might be interconnected between several services. 
I should have prior knowledge of what services should be up and running. `systemctl list-units --type=service` to see all of the services. 
Then, i'd try to identify exact service and see it's logs `systemctl status <service_name>`, `journalctl -u  <service_name> -n 50 -f` `dmesg -w`. 
Depending on the logs output or lack there of I'd try to narrow down the problem based on it. Firstly, look for fast, obvious, most common issues first. 
Since the identified service is stopped i'd try to start it `systemctl start --type=service`.

If it starts, there might've been a reboot and the service wasn't enabled. Then I'd proceed looking at node's **past metrics** to identify any anomalies high CPU , RAM, I/O load, high network traffic.
Depending on the service maybe worker count froze the system, less likely hardware failure.

Otherwise if it is failing to start or fails soon after starting I'd take into consideration recent production changes (or not so recent if there is a possibility if slow memory leak), most likely it is a software problem.
Later on check for permission errors, endpoint errors which are environment variables or other configuration files, network connectivity errors in case something is not reachable or bad DNS resolution (`curl/ping/dig`),
busy port `netstat -tulpn`, disk space issues (`df/du`), process limits `ulimit` `sysctl -a`, file descriptor limits `/etc/security/limits. conf `.

Lastly if the service starts, but does not serve traffic I'd in part do steps mentioned before as in checking logs, but also check live system cpu usage `top` `mpstat -P ALL -1`, short lasting process `atop`, memory usage including swap usage `free -m`
`vmstat 1`, disk space `df -h`, disk utilization `iostat -x 1`, high I/O wait time `top` `iostat` network utilization `sar -n DEV 1`, firewall (`iptables, nftables`) issues, network errors in general from a `tcpdump` network dump and visualized in `wireshark`. 
`strace`the process if it is readable. If the underlying service is in machine which is hosted on cloud, check for cloud console errors. 