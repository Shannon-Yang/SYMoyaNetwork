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
  Network abstraction layer based on Moya extension. You only need to care about what kind of data you want to get, and implement network data caching with different strategies. You don't need to spend a lot of time doing such work, and obtaining network data will become so simple.
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
  s.watchos.deployment_target = '3.0'

  s.source_files = ["Sources/**/*.swift"]

  s.swift_version = '5.3'
  s.cocoapods_version = '>= 1.4.0'

  s.default_subspec = "Core"
  
  # s.resource_bundles = {
  #   'SYMoyaNetwork' => ['SYMoyaNetwork/Assets/*.png']
  # }

  s.requires_arc = true

  s.subspec "Core" do |s|
    s.source_files  = "Sources/Core/Utility/", "Sources/Core/SYMoyaURLCache/", "Sources/Core/SYMoyaChainRequestProvider/", "Sources/Core/SYMoyaBatchRequestProvider/", "Sources/Core/SYMoya/", "Sources/Core/String/", "Sources/Core/Response/", "Sources/Core/Log/", "Sources/Core/JSON/", "Sources/Core/Image/", "Sources/Core/Error/", "Sources/Core/Config/", "Sources/Core/Cache/", "Sources/Core/SwiftyJSON/"
    # https://github.com/Moya/Moya
    s.dependency 'Moya', '~> 15.0'
    # https://github.com/SwiftyJSON/SwiftyJSON
    s.dependency 'SwiftyJSON', '~> 5.0'
    s.framework  = "Foundation"
  end
  
  s.subspec "Codable" do |s|
    s.source_files  = "Sources/Codable/"
    s.dependency "SYMoyaNetwork/Core"
    s.ios.deployment_target = '10.0'
    s.osx.deployment_target = '10.12'
    s.tvos.deployment_target = '10.0'
    s.watchos.deployment_target = '3.0'
  end

  s.subspec "ObjectMapper" do |s|
    s.source_files  = "Sources/ObjectMapper/"
    s.dependency "SYMoyaNetwork/Core"
    # https://github.com/tristanhimmelman/ObjectMapper
    s.dependency 'ObjectMapper', '~> 4.0'
    s.ios.deployment_target = '10.0'
    s.osx.deployment_target = '10.12'
    s.tvos.deployment_target = '10.0'
    s.watchos.deployment_target = '3.0'
  end
  
  s.subspec "HandyJSON" do |s|
    s.source_files  = "Sources/HandyJSON/"
    s.dependency "SYMoyaNetwork/Core"
    # https://github.com/alibaba/HandyJSON
    s.dependency 'HandyJSON', '~> 5.0.2'
    s.ios.deployment_target = '10.0'
    s.osx.deployment_target = '10.12'
    s.tvos.deployment_target = '10.0'
    s.watchos.deployment_target = '3.0'
  end

  s.subspec "MJExtension" do |s|
    s.source_files  = "Sources/MJExtension/"
    s.dependency "SYMoyaNetwork/Core"
    # https://github.com/CoderMJLee/MJExtension
    s.dependency 'MJExtension'
    s.ios.deployment_target = '10.0'
    s.osx.deployment_target = '10.12'
    s.tvos.deployment_target = '10.0'
    s.watchos.deployment_target = '3.0'
  end

end
