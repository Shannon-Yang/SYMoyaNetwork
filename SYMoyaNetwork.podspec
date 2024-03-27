#
# Be sure to run `pod lib lint SYMoyaNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SYMoyaNetwork'
  s.version          = '2.0.0'
  s.summary          = "Based on the network abstraction of Moya's secondary encapsulation, it maintains the same usage method of Moya, extends Moya's TargetType, and implements commonly used data parsing. It supports: HandyJSON, ObjectMapper, Codable, SwiftyJSON. Developers no longer need to write boilerplate code for data parsing, just You need to care about what kind of data you want and choose the data type. SYMoya Network has done all this. SYMoya Network also implements network caching and configures common caching strategies. It only implements the desired caching strategy and Response will perform cache synchronization according to the strategy. , developers no longer need to spend a lot of time doing such work. SYMoya Network makes data requests simple, reducing developers from writing boilerplate code and giving them more time to focus on business."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    Based on the network abstraction of Moya's secondary encapsulation, it maintains the same usage method of Moya, extends Moya's TargetType, and implements commonly used data parsing. It supports: HandyJSON, ObjectMapper, Codable, SwiftyJSON. Developers no longer need to write boilerplate code for data parsing, just You need to care about what kind of data you want and choose the data type. SYMoya Network has done all this. SYMoya Network also implements network caching and configures common caching strategies. It only implements the desired caching strategy and Response will perform cache synchronization according to the strategy. , developers no longer need to spend a lot of time doing such work. SYMoya Network makes data requests simple, reducing developers from writing boilerplate code and giving them more time to focus on business.
                       DESC

  s.homepage         = 'https://github.com/Shannon-Yang/SYMoyaNetwork'
  s.screenshots     = 'https://raw.githubusercontent.com/Shannon-Yang/SYMoyaNetwork/master/images/logo.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ShannonYang' => 'shannonyang0805@gmail.com' }
  s.source           = { :git => 'https://github.com/Shannon-Yang/SYMoyaNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '6.0'

  # s.source_files = ["Sources/**/*.swift"]

  s.default_subspec = "SYMoyaNetwork"
  s.swift_version = ['5']
  s.cocoapods_version = '>= 1.4.0'

  
  # s.resource_bundles = {
  #   'SYMoyaNetwork' => ['SYMoyaNetwork/Assets/*.png']
  # }

  s.requires_arc = true

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.subspec "SYMoyaNetwork" do |ss|
    ss.source_files  = 'Source/SYMoyaNetwork/**/*.swift'

    # https://github.com/Moya/Moya
    ss.dependency 'Moya', '~> 15.0'

    # https://github.com/SwiftyJSON/SwiftyJSON
    ss.dependency 'SwiftyJSON', '~> 5.0'

    ss.framework  = "Foundation"
  end
  
  s.subspec "SYMoyaReactiveHandyJSON" do |ss|
    ss.source_files  = 'Source/SYMoyaReactiveHandyJSON/**/*.swift'
    ss.dependency "Source/SYMoyaHandyJSON"
    
    # https://github.com/ReactiveCocoa/ReactiveSwift
    ss.dependency 'ReactiveSwift', '~> 7.1.1'
    
    ss.ios.deployment_target = '13.0'
    ss.osx.deployment_target = '10.15'
    ss.tvos.deployment_target = '13.0'
    ss.watchos.deployment_target = '6.0'
  end
  
  s.subspec "SYMoyaReactiveObjectMapper" do |ss|
    ss.source_files  = 'Source/SYMoyaReactiveObjectMapper/**/*.swift'
    ss.dependency "Source/SYMoyaObjectMapper"

    # https://github.com/ReactiveCocoa/ReactiveSwift
    ss.dependency 'ReactiveSwift', '~> 7.1.1'
    
    ss.ios.deployment_target = '13.0'
    ss.osx.deployment_target = '10.15'
    ss.tvos.deployment_target = '13.0'
    ss.watchos.deployment_target = '6.0'
  end

  s.subspec "SYMoyaHandyJSON" do |ss|
    ss.source_files  = 'Source/SYMoyaHandyJSON/**/*.swift'
    ss.dependency "Source/SYMoyaNetwork"
    
    # https://github.com/alibaba/HandyJSON
    ss.dependency 'HandyJSON', '~> 5.0.2'
    
    ss.ios.deployment_target = '13.0'
    ss.osx.deployment_target = '10.15'
    ss.tvos.deployment_target = '13.0'
    ss.watchos.deployment_target = '6.0'
  end

  s.subspec "SYMoyaRxHandyJSON" do |ss|
    ss.source_files  = 'Source/SYMoyaRxHandyJSON/**/*.swift'
    ss.dependency "Source/SYMoyaHandyJSON"
    
    # https://github.com/ReactiveX/RxSwift
    ss.dependency 'RxSwift', '6.6.0'
    
    ss.ios.deployment_target = '13.0'
    ss.osx.deployment_target = '10.15'
    ss.tvos.deployment_target = '13.0'
    ss.watchos.deployment_target = '6.0'
  end
  
  s.subspec "SYMoyaRxObjectMapper" do |ss|
    ss.source_files  = 'Source/SYMoyaRxObjectMapper/**/*.swift'
    ss.dependency "Source/SYMoyaObjectMapper"
    
    # https://github.com/ReactiveX/RxSwift
    ss.dependency 'RxSwift', '6.6.0'
    
    ss.ios.deployment_target = '13.0'
    ss.osx.deployment_target = '10.15'
    ss.tvos.deployment_target = '13.0'
    ss.watchos.deployment_target = '6.0'
  end
  
  s.subspec "SYMoyaObjectMapper" do |ss|
    ss.source_files  = 'Source/SYMoyaObjectMapper/**/*.swift'
    ss.dependency "Source/SYMoyaNetwork"
    
    # https://github.com/tristanhimmelman/ObjectMapper
    ss.dependency 'ObjectMapper', '~> 4.3'
    
    ss.ios.deployment_target = '13.0'
    ss.osx.deployment_target = '10.15'
    ss.tvos.deployment_target = '13.0'
    ss.watchos.deployment_target = '6.0'
  end
  
  s.subspec "ReactiveSYMoyaNetwork" do |ss|
    ss.source_files  = 'Source/ReactiveSYMoyaNetwork/**/*.swift'
    ss.dependency "Source/SYMoyaNetwork"
    
    # https://github.com/ReactiveCocoa/ReactiveSwift
    ss.dependency 'ReactiveSwift', '~> 7.1.1'
    
    ss.ios.deployment_target = '13.0'
    ss.osx.deployment_target = '10.15'
    ss.tvos.deployment_target = '13.0'
    ss.watchos.deployment_target = '6.0'
  end
  
  s.subspec "RxSYMoyaNetwork" do |ss|
    ss.source_files  = 'Source/RxSYMoyaNetwork/**/*.swift'
    ss.dependency "Source/SYMoyaNetwork"
    
    # https://github.com/ReactiveX/RxSwift
    ss.dependency 'RxSwift', '6.6.0'
    
    ss.ios.deployment_target = '13.0'
    ss.osx.deployment_target = '10.15'
    ss.tvos.deployment_target = '13.0'
    ss.watchos.deployment_target = '6.0'
  end
end
