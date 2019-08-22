describe package('netfilter-persistent') do
  it { should be_installed }
end

describe package('iptables-persistent') do
  it { should be_installed }
end

describe service('netfilter-persistent') do
  it { should be_enabled }
end 

describe directory('/etc/iptables') do
  it { should exist }
  it { should be_owned_by 'root' }
end

describe file('/etc/iptables/rules.v4') do
  it { should exist }
  it { should be_owned_by 'root'}
  its('mode') { should cmp '0600'}
end

describe iptables(table:'filter') do
  it { should have_rule('-P FORWARD ACCEPT') }
  it { should have_rule('-N VPN_LOCAL') }
  it { should have_rule('-N WAN_LOCAL') }
  it { should have_rule('-A INPUT -m policy --dir in --pol ipsec -j VPN_LOCAL') }
  it { should have_rule('-A VPN_LOCAL -p icmp -j ACCEPT') }
  it { should have_rule('-A VPN_LOCAL -p tcp -m tcp --dport 22 -j ACCEPT') }
  it { should have_rule('-A VPN_LOCAL -j RETURN') }
  it { should have_rule('-A WAN_LOCAL -p udp -m multiport --dports 4500,500 -j ACCEPT') }
  it { should have_rule('-A WAN_LOCAL -p ah -j ACCEPT') }
  it { should have_rule('-A WAN_LOCAL -p esp -j ACCEPT') }
  it { should have_rule('-A WAN_LOCAL -m conntrack --ctstate NEW,UNTRACKED -j DROP') }
  it { should have_rule('-A INPUT -i '+Mixlib::ShellOut.new("ip r l default|head -n1|awk '{print $5}'").run_command.stdout.strip+' -j WAN_LOCAL') }
end