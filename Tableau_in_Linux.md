## Installing MySQL and Tableau Desktop in Linux

There are (probably) several solutions to the problem. This is the one I used and it's probably most useful if you already have or wanted a separate Windows install in a Virtual Machine anyway.

**1) Install Windows in a Virtual Machine**

Install and configure a Windows Virtual Machine with [Virtualbox](https://www.virtualbox.org/) . This is well documented and differs a bit based on your setup and distribution so I won't explain it here.

**Hint:** You can reuse the Windows Product Key that is (probably) stored in your Bios: "sudo strings /sys/firmware/acpi/tables/MSDM"

Most of Virtualbox's default settings should be fine, but grant the Windows guest OS at least 50-75GB of disk space and 8GB of RAM. Also make sure to install the [Guest Additions](https://www.virtualbox.org/manual/ch04.html/) to be able to Copy/Paste between your host OS (Linux) and the guest OS (Windows).

From there you install Tableau Desktop as you would with any other Windows program.

**2) Install MySQL server and workbench**

As a Manjaro (Arch) user, the default implementation of MySQL-server is [MariaDB](https://wiki.archlinux.org/title/) . You need to check for your distro, but on Manjaro [this](https://forum.manjaro.org/t/mysql-server-install/121098/) worked for the setup process of MariaDB and Mysql Workbench:

Hint: You may want to change the default data directory to avoid that your root partition is running full. In this case make sure you grant the necessary user rights to the folder (chown mysql:mysql) and lift the protections on the [Home directory](https://wiki.archlinux.org/title/MariaDB#Configure_access_to_home_directories) .

In Mysql-workbench set up a new MySQLconnection via TCP/IP and connect to 127.0.0.1 on Port 3306. Use the user credentials you entered as part of configuring MariaDB server or (user:root; pass: mysqlrootpassword).

Note on importing SQL dumps (e.g. Magist): Because MariaDB uses a differnt UTF8 (e.g. utf8mb4\_general\_ci), you may run into errors when importing a .sql dump files. Either you open the sql dump in a text editor and replace all instances of UTF8 (e.g. utf8mb4\_0900\_ai\_ci) with MariaDB's UTF8 or you run this command: sed -e 's/utf8mb4\_0900\_ai\_ci/utf8mb4\_unicode\_ci/g' -i myfilename.sql

**3) Connecting Tableau to your Mysql**

If you want to connect Tableau directly to your MySQL database, you may have to set the [gateway IP of your localhost](https://medium.com/@urubuz/accessing-localhost-in-mac-from-windows-vm-in-virtualbox-312a3de6fedb) (in my case 10.0.2.2). You can then make a connection in Tableau to 10.0.2.2: 3306 using the same login you used in MySQL-Workbench.
