describe package('certbot') do
  it { should be_installed }
end

describe directory('/etc/letsencrypt/live') do
  it { should exist }
  it { should be_owned_by 'root' }
  its('mode') { should cmp '0700' }
end

describe x509_certificate('/etc/ipsec.d/certs/cert.pem') do
  its('subject.CN') { should match Mixlib::ShellOut.new('hostname').run_command.stdout.strip }
  its('issuer_dn') { should match "/C=US/O=Let's Encrypt/CN=Let's Encrypt Authority X3" }
  its('key_length') { should be 4096 }
  its('signature_algorithm') { should cmp "sha256WithRSAEncryption" }
  its('validity_in_days') { should be >= 89 }
end

describe x509_certificate('/etc/ipsec.d/cacerts/chain.pem') do
  its('subject_dn') { should match "C=US/O=Let's Encrypt/CN=Let's Encrypt Authority X3" }
  its('issuer_dn') { should match "/O=Digital Signature Trust Co./CN=DST Root CA X3" }
end
