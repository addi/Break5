![Alt text](Icons/Break5-256.png?raw=true "Icon")
# Break5

Break 5 is a simple tool that comments out lines in your /etc/hosts file for 5 minutes.

Sometimes is hard to get stuff done when procrastination is only a single click away. The more tech-savvy of us have started adding productivity draining websites to the /etc/hosts file in order to block them.

However every now and then you need to unblock them: someone sends you a link, you need to authenticate with facebook or just just need a break.

Simply run Break 5 from spotlight and do whatever you have to do. After 5 minutes the sites will be blocked again and that’s how you know it’s time to get back to work.

# How it works

Simply add *#break* and *#/break* above and below the sites you want to be able to unblock with Break 5 in your /etc/hosts file.

```
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1	localhost
255.255.255.255	broadcasthost
::1             localhost 
fe80::1%lo0	localhost

#break
127.0.0.1	reddit.com
127.0.0.1	www.reddit.com
127.0.0.1	twitter.com 
127.0.0.1	www.twitter.com
127.0.0.1	facebook.com
127.0.0.1	www.facebook.com
#/break
```
