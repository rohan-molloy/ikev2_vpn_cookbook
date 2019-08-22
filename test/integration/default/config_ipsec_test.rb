describe directory('/etc/ipsec.d/private') do
  it { should exist}
  it { should be_owned_by 'root' }
  its('mode') { should cmp '0700'}
end 

describe file('/etc/ipsec.conf') do
  it { should exist }
  it { should be_owned_by 'root' }
  its('mode') { should cmp '0600' }
end

describe file('/etc/ipsec.secrets') do
  it { should exist }
  it { should be_owned_by 'root' }
  its('mode') { should cmp '0600' }
end

describe service('ipsec') do
  it { should be_enabled }
  it { should be_running }
end