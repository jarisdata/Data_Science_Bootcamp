Installing MySQL and Tableau Desktop in Linux
========================
There are (probably) several solutions to the problem. This is the one I used and it's probably most useful if you already have or wanted a separate Windows install in a Virtual Machine anyway. 

**1) Install Windows in a Virtual Machine**

Install and configure a Windows Virtual Machine with <a href="https://www.virtualbox.org/">Virtualbox</a> . This is well documented and differs a bit based on your setup and distribution so I won't explain it here. 

**Hint:** You can reuse the Windows Product Key that is (probably) stored in your Bios: "sudo strings /sys/firmware/acpi/tables/MSDM"

Most of Virtualbox's default settings should be fine, but grant the Windoes guest OS at least 50-75GB of disk space and 8GB of RAM. Also make sure to install the <a href="https://www.virtualbox.org/manual/ch04.html/">Guest Additions </a> to be able to Copy/Paste between your host OS (Linux) and the guest OS (Windows).

From there you install Tableau Desktop as you would with any other Windows program.

**2) Install MySQL server and workbench**

As a Manjaro (Arch) user, the default implementation of MySQL-server is  <a href="https://wiki.archlinux.org/title/"> MariaDB </a>. You need to check for your distro, but on Manjaro<a href="https://forum.manjaro.org/t/mysql-server-install/121098/"> this </a>  worked for the setup process of MariaDB and Mysql Workbench: 

Hint: You may want to change the default data directory to avoid that your root partition is running full. In this case make sure you grant the necessary user rights to the folder (chown mysql:mysql) and lift the protections on the <a href="https://wiki.archlinux.org/title/MariaDB#Configure_access_to_home_directories"> Home directory </a>.

In Mysql-workbench set up a new MySQLconnection via TCP/IP and connect to 127.0.0.1 on Port 3306. Use the user credentials you entered as part of configuring MariaDB server or (user:root; pass: mysqlrootpassword).

Note on importing SQL dumps (e.g. Magist): Because MariaDB uses a differnt UTF8 (e.g. utf8mb4_general_ci), you may run into error 1273. Open the sql dump in a text editor and replace all instances of UTF8 (e.g. utf8mb4_0900_ai_ci) with MariaDB's UTF8.

**3) Connecting Tableau to your Mysql**

If you want to connect Tableau directly to your MySQL database, you may have to set the <a href="https://medium.com/@urubuz/accessing-localhost-in-mac-from-windows-vm-in-virtualbox-312a3de6fedb"> gateway IP of your localhost </a> (in my case 10.0.2.2).  You can then make a connection in Tableau to 10.0.2.2: 3306 using the same login you used in MySQL-Workbench.

