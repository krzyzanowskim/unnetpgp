# IMPORTANT
# TO satisfy dependency add this line to you Podfile, just before netpgp:
# pod 'OpenSSL', :podspec => 'https://raw.github.com/yaakov-h/SKSteamKit/master/podspecs/OpenSSL.podspec'  

Pod::Spec.new do |s|
  s.name     = 'netpgp'
  s.version  = '0.4'
  s.license  = { :type => 'Apache License, Version 2.0', :file => 'Licence.txt' }
  s.summary  = 'NetPGP'
  s.homepage = 'http://www.netpgp.com'
  s.authors  = { 'Nominet UK' => 'http://www.nic.uk' }
  s.source   = { :git => 'ssh://git@stash.up-next.com:7999/spc/netpgp.git', :tag => "v#{s.version}" }
  s.requires_arc = false

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'

  s.dependency 'OpenSSL'
  s.frameworks = 'Security'
  s.libraries = 'bz2'

  s.source_files = 'netpgp/lib/*.{h,c}', 'netpgp/*.{h,m}', 'netpgp/fmemopen/*.{h,c}'
  s.public_header_files = 'netpgp/lib/netpgp.h', 'netpgp/UNNetPGP.h'
end