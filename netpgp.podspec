Pod::Spec.new do |s|
  s.name     = 'netphp'
  s.version  = '0.1'
  s.license  = 'MIT'
  s.summary  = 'NetPGP'
  s.homepage = 'http://www.netpgp.com'
  s.authors  = { 'Unknown' => 'unknown@unknown.com' }
  s.source   = { :git => '/Users/marcinkrzyzanowski/Devel/netpgp-xcode/netpgp', :commit => '05e5f3d943e18e88b5fcc69ae701985f97b9e557', :submodules => false }
  s.requires_arc = false

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'

  s.dependency 'OpenSSL', :podspec => 'https://raw.github.com/yaakov-h/SKSteamKit/master/podspecs/OpenSSL.podspec''
  s.frameworks = 'Security'

  s.source_files = 'netpgp'
end