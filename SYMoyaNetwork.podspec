#
# Be sure to run `pod lib lint SYMoyaNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SYMoyaNetwork'
  s.version          = '1.1.0'
  s.summary          = "Network abstraction layer based on Moya extension"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Network abstraction layer based on Moya extension. You only need to care about what kind of data you want to get, and implement network data caching with different strategies. You don't need to spend a lot of time doing such work, and obtaining network data will become so simple.
                       DESC

  s.homepage         = 'https://github.com/Shannon-Yang/SYMoyaNetwork'
  s.screenshots     = 'https://raw.githubusercontent.com/Shannon-Yang/SYMoyaNetwork/master/images/logo.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ShannonYang' => 'shannonyang0805@gmail.com' }
  s.source           = { :git => 'https://github.com/Shannon-Yang/SYMoyaNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  # s.source_files = ["Sources/**/*.swift"]

  s.default_subspec = "Core"
  s.swift_version = '5.3'
  s.cocoapods_version = '>= 1.4.0'

  
  # s.resource_bundles = {
  #   'SYMoyaNetwork' => ['SYMoyaNetwork/Assets/*.png']
  # }

  s.requires_arc = true

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.subspec "Core" do |ss|
    ss.source_files  = "Sources/Core/Utility/", "Sources/Core/SYMoyaURLCache/", "Sources/Core/SYMoyaChainRequestProvider/", "Sources/Core/SYMoyaBatchRequestProvider/", "Sources/Core/SYMoya/", "Sources/Core/String/", "Sources/Core/Response/", "Sources/Core/Log/", "Sources/Core/JSON/", "Sources/Core/Image/", "Sources/Core/Error/", "Sources/Core/Config/", "Sources/Core/Cache/", "Sources/Core/SwiftyJSON/", "Sources/Core/Codable/"

    # https://github.com/Moya/Moya
    ss.dependency 'Moya', '~> 15.0'

    # https://github.com/SwiftyJSON/SwiftyJSON
    ss.dependency 'SwiftyJSON', '~> 5.0'

    ss.framework  = "Foundation"
  end
  
  s.subspec "SYObjectMapper" do |ss|
    ss.source_files  = "Sources/ObjectMapper/"
    ss.dependency "SYMoyaNetwork/Core"
    # https://github.com/tristanhimmelman/ObjectMapper
    ss.dependency 'ObjectMapper', '~> 4.0'
    ss.ios.deployment_target = '10.0'
    ss.osx.deployment_target = '10.12'
    ss.tvos.deployment_target = '10.0'
    ss.watchos.deployment_target = '3.0'
  end
  
  s.subspec "SYHandyJSON" do |ss|
    ss.source_files  = "Sources/HandyJSON/"
    ss.dependency "SYMoyaNetwork/Core"
    # https://github.com/alibaba/HandyJSON
    ss.dependency 'HandyJSON', '~> 5.0.2'
    ss.ios.deployment_target = '10.0'
    ss.osx.deployment_target = '10.12'
    ss.tvos.deployment_target = '10.0'
    ss.watchos.deployment_target = '3.0'
  end

  s.subspec "SYMJExtension" do |ss|
    ss.source_files  = "Sources/MJExtension/"
    ss.dependency "SYMoyaNetwork/Core"
    # https://github.com/CoderMJLee/MJExtension
    ss.dependency 'MJExtension'
    ss.ios.deployment_target = '10.0'
    ss.osx.deployment_target = '10.12'
    ss.tvos.deployment_target = '10.0'
    ss.watchos.deployment_target = '3.0'
  end

end
