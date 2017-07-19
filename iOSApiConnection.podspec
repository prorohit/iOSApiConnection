#
# Be sure to run `pod lib lint iOSApiConnection.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iOSApiConnection'
  s.version          = '1.1.0'
  s.summary          = 'iOSApiConnection is a wrapper or helper to call the API.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This helper class will make it very easy to call the json based APIs. This helper can also be used for uploading the images and videos to server with progress.
                       DESC

  s.homepage         = 'https://github.com/prorohit/iOSApiConnection'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'prorohit' => 'prorohit13@gmail.com' }
  s.source           = { :git => 'https://github.com/prorohit/iOSApiConnection.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'iOSApiConnection/Classes/**/*'
  
  # s.resource_bundles = {
  #   'iOSApiConnection' => ['iOSApiConnection/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'AFNetworking'
    s.dependency 'Reachability'
end
