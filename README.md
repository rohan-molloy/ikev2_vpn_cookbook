# ikev2_vpn_cookbook

IKEv2 VPN with Strongswan.
Uses LetsEncrypt (certbot) to issue a trusted server certificate
Clients authenticate with username/password (`EAP-MSCHAPv2`)

## Requirements

- This cookbook is tested on Ubuntu Bionic (Linux mint 19)
- The system have a hostname set, this hostname must point to its public IP over DNS

## Attributes

```
default['ikev2_vpn']['subnet']='10.13.37.0/24'
default['ikev2_vpn']['dns']='1.1.1.1'
default['ikev2_vpn']['le_email']='root@example.invalid'
default['ikev2_vpn']['disable_ipv6']=1
default['ikev2_vpn']['username']='vpn'
default['ikev2_vpn']['password']='P@ssW0rd'
```

## TODO

- Write inspec tests
- Store username/password in data bag 

