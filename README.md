# Strongswan IKEv2 Chef Cookbook (with LetsEncrypt) 

> * [Requirements](#requirements) 
> * [Installation](#installation)
> * [Attributes](#attributes)
> * [TODO](#sanity-checks)
> * [Chef Output](#chef-output)
> * [Inspec Output](#inspec-output)

IKEv2 VPN with Strongswan. Uses LetsEncrypt (certbot) to issue a trusted server certificate; authentication is based on username/password (`EAP-MSCHAPv2`). To use the VPN on mobile, download the Strongswan Mobile App. 

## Requirements

- This cookbook is tested on Ubuntu Bionic (Linux mint 19)
- The system hostname is set and points to public IP over DNS (for Letsencrypt)

## Installation

```
# Install Chef-Workstation
wget https://packages.chef.io/files/stable/chef-workstation/0.8.7/ubuntu/18.04/chef-workstation_0.8.7-1_amd64.deb
echo '7086dbfcff02666d54af8dd4e9ad5a803027c1326a6fcc1442674ba4780edb5a  chef-workstation_0.8.7-1_amd64.deb' > chef-workstation_0.8.7-1_amd64.deb.sha256sum
sha256sum --status -c chef-workstation_0.8.7-1_amd64.deb.sha256sum && dpkg -i chef-workstation_0.8.7-1_amd64.deb

# Clone the repo
mkdir /var/chef && cd /var/chef && mkdir -p cache cookbooks cookbooks/ikev2_vpn && cd cookbooks/ikev2_vpn
git clone https://github.com/rohan-molloy/ikev2_vpn_cookbook .

# Run Chef Solo
chef-solo --chef-license accept-silent -c $PWD/solo.rb -j $PWD/solo.json
```

## Attributes

```
default['ikev2_vpn']['subnet']='10.13.37.0/24'
default['ikev2_vpn']['dns']='1.1.1.1'
default['ikev2_vpn']['le_email']=''
default['ikev2_vpn']['disable_ipv6']=1
default['ikev2_vpn']['username']='vpn'
default['ikev2_vpn']['password']='P@ssW0rd'
default['ikev2_vpn']['iptables']['allow_all_from_vpn']=true
default['ikev2_vpn']['iptables']['allow_external_ssh']=true
```

## TODO

- Store username/password in data bag
- Client PKI Authentication 

## Chef Output

```
Starting Chef Infra Client, version 15.2.20
resolving cookbooks for run list: ["ikev2_vpn"]
Synchronizing Cookbooks:
  - ikev2_vpn (0.1.0)
Installing Cookbook Gems:
Compiling Cookbooks...
Converging 24 resources
Recipe: ikev2_vpn::default
  * apt_update[update] action periodic (up to date)
Recipe: ikev2_vpn::install_ipsec
  * apt_package[Install-strongswan] action install
    - install version 5.7.1-1ubuntu2 of package strongswan
    - install version 5.7.1-1ubuntu2 of package libstrongswan-standard-plugins
    - install version 5.7.1-1ubuntu2 of package strongswan-libcharon
    - install version 5.7.1-1ubuntu2 of package libcharon-standard-plugins
    - install version 5.7.1-1ubuntu2 of package libcharon-extra-plugins
Recipe: ikev2_vpn::letsencrypt
  * apt_package[Install-certbot] action install
    - install version 0.31.0-1 of package certbot
  * directory[Create-letsencrypt-directory] action create (up to date)
  * template[Generate-letsencrypt-config] action create
    - update content in file /etc/letsencrypt/cli.ini from d7c034 to 6306bb
    --- /etc/letsencrypt/cli.ini	2018-05-26 17:55:06.000000000 +0000
    +++ /etc/letsencrypt/.chef-cli20190822-963-185mpbj.ini	2019-08-22 14:55:57.515693464 +0000
    @@ -1,4 +1,6 @@
    -# Because we are using logrotate for greater flexibility, disable the
    -# internal certbot logrotation.
    -max-log-backups = 0
    +preferred-challenges = http
    +rsa-key-size = 4096
    +pre-hook = /sbin/iptables --insert INPUT -p tcp --dport 80 -j ACCEPT
    +post-hook = /sbin/iptables --delete INPUT -p tcp --dport 80 -j ACCEPT
    +renew-hook = /usr/sbin/ipsec reload && /usr/sbin/ipsec secrets
  * execute[Execute-letsencrypt-without-email] action run
    - execute /usr/bin/certbot certonly --register-unsafely-without-email --no-eff-email --non-interactive --agree-tos --standalone -d [redacted]
  * execute[Execute-letsencrypt-with-email] action run (skipped due to not_if)
  * execute[Copy-cert] action run
    - execute cp /etc/letsencrypt/live/[redacted]/cert.pem /etc/ipsec.d/certs/cert.pem
  * execute[Copy-chain] action run
    - execute cp /etc/letsencrypt/live/[redacted]/chain.pem /etc/ipsec.d/cacerts/chain.pem
  * execute[Copy-key] action run
    - execute cp /etc/letsencrypt/live/[redacted]/privkey.pem /etc/ipsec.d/private/privkey.pem
Recipe: ikev2_vpn::config_ipsec
  * template[Generate-ipsec-config] action create
    - update content in file /etc/ipsec.conf from e1a6e7 to a134cc
    --- /etc/ipsec.conf	2018-12-10 07:30:01.000000000 +0000
    +++ /etc/.chef-ipsec20190822-963-1xnsxmb.conf	2019-08-22 14:56:09.900138505 +0000
    @@ -1,29 +1,28 @@
    -# ipsec.conf - strongSwan IPsec configuration file
    -
    -# basic configuration
    -
     config setup
    -	# strictcrlpolicy=yes
    -	# uniqueids = no
    -
    -# Add connections here.
    -
    -# Sample VPN connections
    -
    -#conn sample-self-signed
    -#      leftsubnet=10.1.0.0/16
    -#      leftcert=selfCert.der
    -#      leftsendcert=never
    -#      right=192.168.0.2
    -#      rightsubnet=10.2.0.0/16
    -#      rightcert=peerCert.der
    -#      auto=start
    -
    -#conn sample-with-ca-cert
    -#      leftsubnet=10.1.0.0/16
    -#      leftcert=myCert.pem
    -#      right=192.168.0.2
    -#      rightsubnet=10.2.0.0/16
    -#      rightid="C=CH, O=Linux strongSwan CN=peer name"
    -#      auto=start
    +  strictcrlpolicy=no
    +  uniqueids=never
    +conn roadwarrior 
    +  auto=add
    +  compress=no
    +  type=tunnel
    +  keyexchange=ikev2
    +  fragmentation=yes
    +  forceencaps=yes
    +  ike=aes256gcm16-prfsha384-ecp521,aes256gcm16-prfsha384-ecp384!
    +  esp=aes256gcm16-ecp521,aes256gcm16-ecp384!
    +  dpdaction=clear
    +  dpddelay=900s
    +  rekey=no
    +  left=%any
    +  leftid=@[redacted]
    +  leftcert=cert.pem
    +  leftsendcert=always
    +  leftsubnet=0.0.0.0/0
    +  right=%any
    +  rightid=%any
    +  rightauth=eap-mschapv2
    +  eap_identity=%identity
    +  rightdns=1.1.1.1
    +  rightsourceip=10.13.37.0/24
    +  rightsendcert=never
    - change mode from '0644' to '0600'
  * template[Generate-ipsec-secrets] action create
    - update content in file /etc/ipsec.secrets from ad4e48 to caeeb5
    --- /etc/ipsec.secrets	2018-12-10 07:30:01.000000000 +0000
    +++ /etc/.chef-ipsec20190822-963-ydyybs.secrets	2019-08-22 14:56:09.916139090 +0000
    @@ -1,6 +1,3 @@
    -# This file holds shared secrets or RSA private keys for authentication.
    -
    -# RSA private key for this host, authenticating it to any other host
    -# which knows the public part.
    -
    +[redacted] : RSA "privkey.pem"
    +vpn : EAP "P@ssW0rd"
Recipe: ikev2_vpn::iptables
  * apt_package[Install-netfilter-persistent] action install
    - install version 1.0.11 of package netfilter-persistent
    - install version 1.0.11 of package iptables-persistent
  * directory[Create-iptables-directory] action create (up to date)
  * template[Generate-iptables-rules] action create
    - update content in file /etc/iptables/rules.v4 from c79b56 to 82395f
    --- /etc/iptables/rules.v4	2019-08-22 14:56:14.020290302 +0000
    +++ /etc/iptables/.chef-rules20190822-963-92gjct.v4	2019-08-22 14:56:17.464418566 +0000
    @@ -1,8 +1,47 @@
    -# Generated by iptables-save v1.6.1 on Thu Aug 22 14:56:14 2019
    +#####################
    +# Generated by Chef #
    +#####################
    +*nat
    +:PREROUTING ACCEPT [0:0]
    +:INPUT ACCEPT [0:0]
    +:OUTPUT ACCEPT [0:0]
    +:POSTROUTING ACCEPT [0:0]
    +:IPSEC - [0:0]
    +-A IPSEC -s 10.13.37.0/24 -m policy --dir out --pol ipsec -j ACCEPT
    +-A IPSEC -s 10.13.37.0/24 -j MASQUERADE
    +-A POSTROUTING -o ens3 -j IPSEC 
    +COMMIT
    +*mangle
    +:PREROUTING ACCEPT [0:0]
    +:INPUT ACCEPT [0:0]
    +:FORWARD ACCEPT [0:0]
    +:OUTPUT ACCEPT [0:0]
    +:POSTROUTING ACCEPT [0:0]
    +:IPSEC - [0:0]
    +-A IPSEC -s 10.13.37.0/24 -p tcp -m policy --dir in --pol ipsec -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360
    +-A FORWARD -o ens3 -j IPSEC 
    +COMMIT
     *filter
    -:INPUT ACCEPT [259:28401]
    +:INPUT ACCEPT [0:0]
     :FORWARD ACCEPT [0:0]
    -:OUTPUT ACCEPT [289:30291]
    +:OUTPUT ACCEPT [0:0]
    +:VPN_LOCAL - [0:0]
    +:WAN_LOCAL - [0:0]
    +:VPN_IN - [0:0]
    +:VPN_OUT - [0:0]
    +-A WAN_LOCAL -p udp -m multiport --destination-ports 4500,500 -j ACCEPT
    +-A WAN_LOCAL -p ah -j ACCEPT
    +-A WAN_LOCAL -p esp -j ACCEPT
    +-A WAN_LOCAL -p tcp --dport 22 -j ACCEPT
    +-A WAN_LOCAL -m conntrack --ctstate NEW,UNTRACKED -j DROP
    +-A VPN_LOCAL -p icmp -j ACCEPT
    +-A VPN_LOCAL -p tcp --dport ssh -j ACCEPT
    +-A VPN_LOCAL -j RETURN
    +-A VPN_IN -j RETURN 
    +-A VPN_OUT -j RETURN 
    +-A INPUT -m policy --dir in --pol ipsec -j VPN_LOCAL 
    +-A INPUT -i ens3 -j WAN_LOCAL
    +-A FORWARD -s 10.13.37.0/24 -p esp -m policy --dir in --pol ipsec -j VPN_IN
    +-A FORWARD -d 10.13.37.0/24 -p esp -m policy --dir out --pol ipsec -j VPN_OUT
     COMMIT
    -# Completed on Thu Aug 22 14:56:14 2019
    - change mode from '0644' to '0600'
  * execute[Apply-iptables-rules] action run
    - execute /sbin/iptables-restore < /etc/iptables/rules.v4
  * service[Reload-iptables-service] action enable (up to date)
  * service[Reload-iptables-service] action restart
    - restart service service[Reload-iptables-service]
Recipe: ikev2_vpn::sysctl
  * sysctl[ipv4-enable-forwarding] action apply
    - create ipv4-enable-forwarding
    -   set key      to "net.ipv4.ip_forward"
    -   set value    to "1"
    -   set conf_dir to "/etc/sysctl.d" (default value)
    * directory[/etc/sysctl.d] action create (up to date)
    * file[/etc/sysctl.d/99-chef-net.ipv4.ip_forward.conf] action create
      - create new file /etc/sysctl.d/99-chef-net.ipv4.ip_forward.conf
      - update content in file /etc/sysctl.d/99-chef-net.ipv4.ip_forward.conf from none to 58a5d0
      --- /etc/sysctl.d/99-chef-net.ipv4.ip_forward.conf	2019-08-22 14:56:17.780430390 +0000
      +++ /etc/sysctl.d/.chef-99-chef-net20190822-963-1gqpfxj.ipv4.ip_forward.conf	2019-08-22 14:56:17.780430390 +0000
      @@ -1 +1,2 @@
      +net.ipv4.ip_forward = 1
    * execute[Load sysctl values] action run
      - execute sysctl -p
  
  * sysctl[ipv4-turn-off-path-mtu-discovery] action apply
    - create ipv4-turn-off-path-mtu-discovery
    -   set key      to "net.ipv4.ip_no_pmtu_disc"
    -   set value    to "1"
    -   set conf_dir to "/etc/sysctl.d" (default value)
    * directory[/etc/sysctl.d] action create (up to date)
    * file[/etc/sysctl.d/99-chef-net.ipv4.ip_no_pmtu_disc.conf] action create
      - create new file /etc/sysctl.d/99-chef-net.ipv4.ip_no_pmtu_disc.conf
      - update content in file /etc/sysctl.d/99-chef-net.ipv4.ip_no_pmtu_disc.conf from none to 0e4fe8
      --- /etc/sysctl.d/99-chef-net.ipv4.ip_no_pmtu_disc.conf	2019-08-22 14:56:17.844432785 +0000
      +++ /etc/sysctl.d/.chef-99-chef-net20190822-963-ei7007.ipv4.ip_no_pmtu_disc.conf	2019-08-22 14:56:17.840432636 +0000
      @@ -1 +1,2 @@
      +net.ipv4.ip_no_pmtu_disc = 1
    * execute[Load sysctl values] action run
      - execute sysctl -p
  
  * sysctl[ipv4-enable-reverse-path-filtering] action apply
    - create ipv4-enable-reverse-path-filtering
    -   set key      to "net.ipv4.conf.all.rp_filter"
    -   set value    to "1"
    -   set conf_dir to "/etc/sysctl.d" (default value)
    * directory[/etc/sysctl.d] action create (up to date)
    * file[/etc/sysctl.d/99-chef-net.ipv4.conf.all.rp_filter.conf] action create
      - create new file /etc/sysctl.d/99-chef-net.ipv4.conf.all.rp_filter.conf
      - update content in file /etc/sysctl.d/99-chef-net.ipv4.conf.all.rp_filter.conf from none to dee23b
      --- /etc/sysctl.d/99-chef-net.ipv4.conf.all.rp_filter.conf	2019-08-22 14:56:17.904435030 +0000
      +++ /etc/sysctl.d/.chef-99-chef-net20190822-963-13zqlgn.ipv4.conf.all.rp_filter.conf	2019-08-22 14:56:17.904435030 +0000
      @@ -1 +1,2 @@
      +net.ipv4.conf.all.rp_filter = 1
    * execute[Load sysctl values] action run
      - execute sysctl -p
  
  * sysctl[ipv4-never-accept-redirects] action apply
    - create ipv4-never-accept-redirects
    -   set key      to "net.ipv4.conf.all.accept_redirects"
    -   set value    to "0"
    -   set conf_dir to "/etc/sysctl.d" (default value)
    * directory[/etc/sysctl.d] action create (up to date)
    * file[/etc/sysctl.d/99-chef-net.ipv4.conf.all.accept_redirects.conf] action create
      - create new file /etc/sysctl.d/99-chef-net.ipv4.conf.all.accept_redirects.conf
      - update content in file /etc/sysctl.d/99-chef-net.ipv4.conf.all.accept_redirects.conf from none to 1e1854
      --- /etc/sysctl.d/99-chef-net.ipv4.conf.all.accept_redirects.conf	2019-08-22 14:56:17.964437276 +0000
      +++ /etc/sysctl.d/.chef-99-chef-net20190822-963-10cnj7z.ipv4.conf.all.accept_redirects.conf	2019-08-22 14:56:17.964437276 +0000
      @@ -1 +1,2 @@
      +net.ipv4.conf.all.accept_redirects = 0
    * execute[Load sysctl values] action run
      - execute sysctl -p
  
  * sysctl[ipv4-never-send-redirects] action apply
    - create ipv4-never-send-redirects
    -   set key      to "net.ipv4.conf.all.send_redirects"
    -   set value    to "0"
    -   set conf_dir to "/etc/sysctl.d" (default value)
    * directory[/etc/sysctl.d] action create (up to date)
    * file[/etc/sysctl.d/99-chef-net.ipv4.conf.all.send_redirects.conf] action create
      - create new file /etc/sysctl.d/99-chef-net.ipv4.conf.all.send_redirects.conf
      - update content in file /etc/sysctl.d/99-chef-net.ipv4.conf.all.send_redirects.conf from none to d8b817
      --- /etc/sysctl.d/99-chef-net.ipv4.conf.all.send_redirects.conf	2019-08-22 14:56:18.020439373 +0000
      +++ /etc/sysctl.d/.chef-99-chef-net20190822-963-ffgybr.ipv4.conf.all.send_redirects.conf	2019-08-22 14:56:18.020439373 +0000
      @@ -1 +1,2 @@
      +net.ipv4.conf.all.send_redirects = 0
    * execute[Load sysctl values] action run
      - execute sysctl -p
  
  * sysctl[disable-all-ipv6] action apply
    - create disable-all-ipv6
    -   set key      to "net.ipv6.conf.all.disable_ipv6"
    -   set value    to "1"
    -   set conf_dir to "/etc/sysctl.d" (default value)
    * directory[/etc/sysctl.d] action create (up to date)
    * file[/etc/sysctl.d/99-chef-net.ipv6.conf.all.disable_ipv6.conf] action create
      - create new file /etc/sysctl.d/99-chef-net.ipv6.conf.all.disable_ipv6.conf
      - update content in file /etc/sysctl.d/99-chef-net.ipv6.conf.all.disable_ipv6.conf from none to 236ab1
      --- /etc/sysctl.d/99-chef-net.ipv6.conf.all.disable_ipv6.conf	2019-08-22 14:56:18.080441625 +0000
      +++ /etc/sysctl.d/.chef-99-chef-net20190822-963-1l2mok3.ipv6.conf.all.disable_ipv6.conf	2019-08-22 14:56:18.080441625 +0000
      @@ -1 +1,2 @@
      +net.ipv6.conf.all.disable_ipv6 = 1
    * execute[Load sysctl values] action run
      - execute sysctl -p
  
Recipe: ikev2_vpn::restart_ipsec
  * service[Restart-ipsec-service] action restart
    - restart service service[Restart-ipsec-service]

Running handlers:
Running handlers complete
Chef Infra Client finished, 32/43 resources updated in 55 seconds

```

## Inspec Output
```
  Directory /etc/ipsec.d/private
     ✔  should exist
     ✔  should be owned by "root"
     ✔  mode should cmp == "0700"
  File /etc/ipsec.conf
     ✔  should exist
     ✔  should be owned by "root"
     ✔  mode should cmp == "0600"
  File /etc/ipsec.secrets
     ✔  should exist
     ✔  should be owned by "root"
     ✔  mode should cmp == "0600"
  Service ipsec
     ✔  should be enabled
     ✔  should be running
  System Package certbot
     ✔  should be installed
  Directory /etc/letsencrypt/live
     ✔  should exist
     ✔  should be owned by "root"
     ✔  mode should cmp == "0700"
  x509_certificate /etc/ipsec.d/certs/cert.pem
     ✔  subject.CN should match "[redacted]"
     ✔  issuer_dn should match "/C=US/O=Let's Encrypt/CN=Let's Encrypt Authority X3"
     ✔  key_length should equal 4096
     ✔  signature_algorithm should cmp == "sha256WithRSAEncryption"
     ✔  validity_in_days should be >= 89
  x509_certificate /etc/ipsec.d/cacerts/chain.pem
     ✔  subject_dn should match "C=US/O=Let's Encrypt/CN=Let's Encrypt Authority X3"
     ✔  issuer_dn should match "/O=Digital Signature Trust Co./CN=DST Root CA X3"
  System Package netfilter-persistent
     ✔  should be installed
  System Package iptables-persistent
     ✔  should be installed
  Service netfilter-persistent
     ✔  should be enabled
  Directory /etc/iptables
     ✔  should exist
     ✔  should be owned by "root"
  File /etc/iptables/rules.v4
     ✔  should exist
     ✔  should be owned by "root"
     ✔  mode should cmp == "0600"
  Iptables table: filter
     ✔  should have rule "-P FORWARD ACCEPT"
     ✔  should have rule "-N VPN_LOCAL"
     ✔  should have rule "-N WAN_LOCAL"
     ✔  should have rule "-A INPUT -m policy --dir in --pol ipsec -j VPN_LOCAL"
     ✔  should have rule "-A VPN_LOCAL -p icmp -j ACCEPT"
     ✔  should have rule "-A VPN_LOCAL -p tcp -m tcp --dport 22 -j ACCEPT"
     ✔  should have rule "-A VPN_LOCAL -j RETURN"
     ✔  should have rule "-A WAN_LOCAL -p udp -m multiport --dports 4500,500 -j ACCEPT"
     ✔  should have rule "-A WAN_LOCAL -p ah -j ACCEPT"
     ✔  should have rule "-A WAN_LOCAL -p esp -j ACCEPT"
     ✔  should have rule "-A WAN_LOCAL -m conntrack --ctstate NEW,UNTRACKED -j DROP"
     ✔  should have rule "-A INPUT -i ens3 -j WAN_LOCAL"
  System Package strongswan
     ✔  should be installed
  System Package libstrongswan-standard-plugins
     ✔  should be installed
  System Package strongswan-libcharon
     ✔  should be installed
  System Package strongswan
     ✔  should be installed
  System Package libcharon-standard-plugins
     ✔  should be installed
  File /proc/sys/net/ipv4/ip_forward
     ✔  content should match "1"
  File /proc/sys/net/ipv4/ip_no_pmtu_disc
     ✔  content should match "1"
  File /proc/sys/net/ipv4/conf/all/rp_filter
     ✔  content should match "1"
  File /proc/sys/net/ipv4/conf/all/accept_redirects
     ✔  content should match "0"
  File /proc/sys/net/ipv4/conf/all/send_redirects
     ✔  content should match "0"

Test Summary: 52 successful, 0 failures, 0 skipped

```



