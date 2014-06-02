platform :ios, '6.0'

pod 'OpenSSL-Universal', :git => 'https://github.com/krzak/OpenSSL.git', :branch => :master

xcodeproj 'UNNetPGP.xcodeproj'

target 'test client' do
  pod 'UNNetPGP', :path => 'UNNetPGP.podspec'
end

target 'UNNetPGP Tests' do
  pod 'UNNetPGP', :path => 'UNNetPGP.podspec'
end