# IMPORTANT
# TO satisfy dependency add this line to you Podfile, just before netpgp:
# pod 'OpenSSL', :podspec => 'https://raw.github.com/krzak/OpenSSL/master/OpenSSL.podspec'  

Pod::Spec.new do |s|
  s.name     = 'UNNetPGP'
  s.version  = '0.5'
  s.platform = :ios, '6.0'
  s.license  = { :type => 'Apache License, Version 2.0', :file => 'Licence.txt' }
  s.summary  = 'Objective-c wrapper of NetPGP for iOS'
  s.description = "NetPGP is a standards-compliant library and suite of utilities providing digital signature and verification functionality, as well as data encryption and decryption, using RSA and DSA/Elgamal keys."
  s.homepage = 'http://www.netpgp.com'
  s.authors  = { 'Marcin Krzyżanowski' => 'marcin.krzyzanowski@hakore.com', 'Nominet UK' => 'http://www.nic.uk' }
  s.source   = { :git => 'https://github.com/upnext/unnetpgp.git', :tag => "v#{s.version}" }
  s.requires_arc = false

  s.dependency 'OpenSSL'
  s.frameworks = 'Security'
  s.libraries = 'bz2'

  s.source_files = 'netpgp/lib/*.{h,c}', 'netpgp/*.{h,m}', 'netpgp/fmemopen/*.{h,c}'
  s.public_header_files = 'netpgp/lib/netpgp.h', 'netpgp/UNNetPGP.h'
end