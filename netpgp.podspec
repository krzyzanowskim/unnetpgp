Pod::Spec.new do |s|
  s.name     = 'netpgp'
  s.version  = '0.1'
  s.license  = 'MIT'
  s.summary  = 'NetPGP'
  s.homepage = 'http://www.netpgp.com'
  s.authors  = { 'Unknown' => 'unknown@unknown.com' }
  #s.source   = { :git => '/Users/marcinkrzyzanowski/Devel/netpgp-xcode/netpgp', :commit => '05e5f3d943e18e88b5fcc69ae701985f97b9e557', :submodules => false }
  s.requires_arc = false

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'

  # add this to you Podfile, just before netpgp
  # pod 'OpenSSL', :podspec => 'https://raw.github.com/yaakov-h/SKSteamKit/master/podspecs/OpenSSL.podspec'  

  s.dependency 'OpenSSL'
  s.frameworks = 'Security'

  s.source_files = 'netpgp'
  s.public_header_files = 'netpgp/lib/netpgp.h'
end