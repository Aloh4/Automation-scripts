## Collect logs from Linux to Cisco like equipaments

* From a Linux terminal, just copy and paste the script as-wished name, ex: "script.sh"
* The script is able to automatically connect to Cisco/Huawei routers, and Huawei OLTs and collect its output

**What it does?**

* Verify your SSH version
* Ask the equipament ips to connect
* Validate wrong syntax of missing octets on the ip address
* Ask the equipament commands to be executed
* Remove the blank lines in the commands and ips file
* Ask your credentials for automatically login
* It does use `expect` to send the commands, in case of long outputs, its recommend to increase the sleep time in:
```
foreach comando \$comandos {
       expect "*#"
       send "\$comando\n"
       sleep 3
```
* Save the output in the current directory named as coleta.log.`+%Y%d%m-%H%M`
* When the scripts ran again, it will move the last `coleta.log` to the archive directory
* If the directory `archive` not exist, the script will automatically create on the current directory


**Instructions**

* Make sure to run the script with `root` privilegies
* Its not necessary to insert commands like `scroll, terminal length 0 , screen-length 0 temp`, the script is setup to do that
* Some of Cisco-like equipament use older SSH versions, for a correct usage, be sure to use OpenSSH_7.4p1
* Make sure to have `expect` and `tput` installed
```
# For Debian distros:

apt-get install expect && apt-get install tput
```
