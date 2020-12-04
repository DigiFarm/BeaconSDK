#
# Be sure to run `pod lib lint BeaconSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BeaconSDK'
  s.version          = '0.3.0'
  s.summary          = 'iOS SDK for receiving NMEA data from the DigiFarm NTRIP Client app.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The DigiFarm NTRIP Client app is used to deliver RTK corrections data to the GRTech Beacon V3.0 family of devices. This SDK allows your iOS app to receive NMEA data from the Beacon through the DigiFarm Client app.
                       DESC

  s.homepage         = 'https://github.com/DigiFarm/BeaconSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Paul Himes' => 'digifarm@tinwhistlellc.com' }
  s.source           = { :git => 'https://github.com/DigiFarm/BeaconSDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'BeaconSDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BeaconSDK' => ['BeaconSDK/Assets/*.png']
  # }

  s.public_header_files = 'BeaconSDK/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
