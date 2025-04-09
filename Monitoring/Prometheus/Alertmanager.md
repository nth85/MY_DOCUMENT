**Setup config Postfix local reicever Mail**

*Check status Postfix*
```
systemctl status postfix
systemctl restart postfix
```

*config postfix*
```
vi /etc/postfix/main.cf
inet_interfaces = all
mynetworks = 168.100.189.0/28, 127.0.0.0/8 10.0.0.0/8 192.168.0.0/16
myhostname = mail.cluster.local
relayhost =
mydestination = $myhostname, localhost.$mydomain, localhost, @cluster.local

systemctl restart postfix
```
*check port listen Postfix*
```
netstat -plntu
tcp        0      0 0.0.0.0:25              0.0.0.0:*               LISTEN      6383/master
```
*install sent mailx*
```
sudo yum install mailx -y
```

**Test sent mail local to Postfix mail***
```
echo "Hello from Postfix" | mail -s "Test Mail" root
cat /var/mail/root
`
From root@mail.cluster.local  Wed Apr  9 20:13:32 2025
Return-Path: <root@mail.cluster.local>
X-Original-To: root
Delivered-To: root@mail.cluster.local
Received: by mail.cluster.local (Postfix, from userid 0)
        id C3BCE22F88F1; Wed,  9 Apr 2025 20:13:32 +0700 (+07)
Date: Wed, 09 Apr 2025 20:13:32 +0700
To: root@mail.cluster.local
Subject: Test Mail
User-Agent: Heirloom mailx 12.5 7/5/10
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20250409131332.C3BCE22F88F1@mail.cluster.local>
From: root@mail.cluster.local (root)
Hello from Postfix
`
tail -f /var/log/maillog
echo -e "Subject: Test\n\nThis is a test" | sendmail root
```

**SETUP Alertmanager sent to mail**
```
vi alertmanager.yml
global
  smtp_smarthost: '192.168.56.120:25'
  smtp_from: 'alert@cluster.local'
route:
  receiver: 'mail-local'
receivers:
  - name: 'mail-local'
    email_configs:
      - to 'root'
        sent_resolved: true
cat /var/mail/root
tail -f /var/log/maillog
```
*check pod Alertmanager sent to outside*
```
kubectl exec -it alertmanager_pod_name -- sh telnet 192.168.56.120 25

Connected to 192.168.56.120
220 mail postfix ESMTP
```

