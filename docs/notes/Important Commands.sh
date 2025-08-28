ssh -i ~/.ssh/devopsproj -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/devopsproj devops@13.61.153.223" devops@10.0.2.168

# Once logged into the app server, check Docker containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

sudo netstat -tulpn | grep -E ':(80|8080|9000|3000|9090|8000)'

sudo ss -tulpn | grep -E ':(80|8080|9000|3000|9090|8000)'

devops@ip-10-0-2-168:~$ sudo ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere                  
8000/tcp                   ALLOW IN    Anywhere                  
22/tcp (v6)                ALLOW IN    Anywhere (v6)             
8000/tcp (v6)              ALLOW IN    Anywhere (v6)             

