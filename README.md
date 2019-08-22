# Strongswan IKEv2 Chef Cookbook (with LetsEncrypt) 

> * [Requirements](#requirements) 
> * [Installation](#installation)
> * [Tests](#tests)
> * [Attributes](#attributes)
> * [TODO](#sanity-checks)

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
## Tests

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



