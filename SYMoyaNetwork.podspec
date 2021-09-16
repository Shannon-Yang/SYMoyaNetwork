#
# Be sure to run `pod lib lint SYMoyaNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SYMoyaNetwork'
  s.version          = '1.0.0'
  s.summary          = "Network abstraction layer based on Moya extension"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Shannon-Yang/SYMoyaNetwork'
  s.screenshots     = 'https://raw.githubusercontent.com/Shannon-Yang/SYMoyaNetwork/master/images/logo.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ShannonYang' => 'shannonyang0805@gmail.com' }
  s.source           = { :git => 'https://github.com/ShannonYang/SYMoyaNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '6.0'

  s.source_files = ["Sources/**/*.swift"]

  s.swift_version = '5.3'
  
  # s.resource_bundles = {
  #   'SYMoyaNetwork' => ['SYMoyaNetwork/Assets/*.png']
  # }

  s.requires_arc = true

  s.framework  = "Foundation"

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  # https://github.com/tristanhimmelman/ObjectMapper
  s.dependency 'ObjectMapper', '~> 4.0'

  # https://github.com/Moya/Moya
  s.dependency 'Moya', '~> 14.0'
  
  # https://github.com/SwiftyJSON/SwiftyJSON
  s.dependency 'SwiftyJSON', '~> 5.0'

end
