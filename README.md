<p align="center">
  <img height="160" src="https://raw.githubusercontent.com/Shannon-Yang/SYMoyaNetwork/main/Images/logo.png" />
</p>

# SYMoyaNetwork
基于[Moya](https://github.com/Moya/Moya)再次封装的网络抽象层，保持[Moya](https://github.com/Moya/Moya)一样的使用方法，扩展[Moya](https://github.com/Moya/Moya)的TargetType，新增对HandyJSON、ObjectMapper、Codable、SwiftyJSON等数据支持，对[Moya](https://github.com/Moya/Moya)的Response做默认的数据转换，仅仅只需要关心你想要得到什么样的数据，实现不同策略的网络数据缓存，无需再花大量时间再去做这样的工作，获取网络数据将变得如此简单。


## What
也许你会像大多数iOS开发者一样，使用Moya来作为网络请求的抽象层，Moya是一个很棒的框架，它可以让足够简单的完成网络请求，SYMoyaNetwork是基于Moya再次封装的抽象，它并没有改变Moya的使用方式，仅仅是对Moya的进一步扩展与更友好的封装
也许你会用Moya这样写网络请求

```swift
provider = MoyaProvider<GitHub>()
provider.request(.zen) { result in
    switch result {
    case let .success(moyaResponse):
        let data = moyaResponse.data
        let statusCode = moyaResponse.statusCode
        // do something with the response data or statusCode
    case let .failure(error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```
当网络数据请求完成后，我们需要手动的将moyaResponse转换成我们想要的对象，例如使用[ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper)做为数据模型时，我们需要每次在返回网络请求时都需要将moyaResponse转换为BaseMappable对象，也许你会封装一个统一的方法去做这件事情，但还是需要手动调用这样的一些转换方法，这将让使用者做这些繁琐而又无味的工作，因此SYMoyaNetwork已经做好了这样的工作，你只需要关心你想要得到的数据，SYMoyaNetwork将会给你想要返回的数据，例如使用[ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper)做为数据模型时，我们可以这样来获取数据对象

```swift
provider = MoyaProvider<GitHub>()
provider.responseObject(.zen) { (result: SYMoyaNetworkDataResponse<BaseMappable>) in
    switch result {
    case let .success(mappable):
        // The mappable will be the data you want to get, you can use it directly, you don’t need to do any conversion
    case let .failure(error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```
现在使用SYMoyaNetwork，你不用再关心如何将response转换成你想要的数据，你只需要关心你想要的数据，SYMoyaNetwork已经做好了这一切。

SYMoyaNetwork提供多种数据类常用的数据类型转换，例如：JSON、String、Image、HandyJSON、ObjectMapper、Codable、SwiftyJSON等，使用时仅仅只需要关心你想要得到的数据，其他的你都不用关心，SYMoyaNetwork已经对Moya的response做好了转换，你只管关心你的业务实现。

SYMoyaNetwork不仅仅只是做了Moya的Response的转换，更重要的一点是，在Moya的基础上SYMoyaNetwork已经帮你做好网络缓存，在大多数应用使用情况下，网络缓存是非常重要的一个策略，它可以让你的App更快的展示数据，更能为用户节省流量，可以说在网络这一层是一个很重要的决策，因此SYMoyaNetwork提供了两种网络缓存方式，第一种是根据HTTP协议做的网络缓存，第二种是根据请求的数据进行缓存。

第一种方式是参考[AlamofireURLCache
Public](https://github.com/kenshincui/AlamofireURLCache)用[Moya](https://github.com/Moya/Moya)的方式对网络缓存进行了实现
第二种方式是参考[YTKNetwork](https://github.com/yuantiku/YTKNetwork)的方式为[Moya](https://github.com/Moya/Moya)的Response做了缓存。

SYMoyaNetwork也支持链式请求以及批量请求，具体参考SYMoyaChainRequestProvider、SYMoyaBatchRequestProvider


## 功能

* Response支持扩展[HandyJSON](https://github.com/alibaba/HandyJSON)、[ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper)、Codable、[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)等数据对象
* 内部进行数据解析，使用者只需要关心你想要得到的数据
* 网络缓存，并支持HTTP协议缓存
* 扩展Moya的TargetType，新增timeoutInterval、cdnURL、allowsCellularAccess、cachePolicy等属性
* 支持链式请求(SYMoyaChainRequestProvider)
* 支持批量请求(SYMoyaBatchRequestProvider)


## 安装

### Swift Package Manager

要使用苹果的 Swift Package Manager 集成，将以下内容作为依赖添加到你的 `Package.swift`：

```swift
.package(url: "https://github.com/Shannon-Yang/SYMoyaNetwork", .upToNextMajor(from: "15.0.0"))
```

然后指定 `"SYMoyaNetwork"` 为你想要使用 SYMoyaNetwork 的 Target 的依赖。这里是一个 `PackageDescription` 实例：

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Shannon-Yang/SYMoyaNetwork", .upToNextMajor(from: "15.0.0"))
    ]
)
```

### CocoaPods

在你的 Podfile 文件中添加 SYMoyaNetwork：

```rb
pod 'SYMoyaNetwork'

# or 

pod 'SYMoyaNetwork/ObjectMapper'

# or

pod 'SYMoyaNetwork/HandyJSON'

#or

pod 'SYMoyaNetwork/SwiftyJSON'
```

然后运行 `pod install`。

在任何你想使用 SYMoyaNetwork 的文件中，使用 `import SYMoyaNetwork` 导入框架。

### Carthage

Carthage 用户可以指向这个仓库并使用他们喜欢的生成框架，`SYMoyaNetwork`

在你的 Cartfile 中添加下面的代码：

```
github "SYMoyaNetwork/SYMoyaNetwork"
```

然后运行 `carthage update --use-xcframeworks`。

如果这是你首次在项目中使用 Carthage，你将需要进行一些额外的步骤，它们在 [Carthage](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) 中有解释。

### 手动

- 打开终端，`cd` 到你项目的顶层目录，如果你的项目没有初始化为 git 仓库，运行下面的命令：

```bash
$ git init
```

- 通过运行以下命令来添加 Alamofire & Moya & SYMoyaNetwork & The data model library you want to use, such as HandyJSON, ObjectMapper, Codable, SwiftyJSON 作为 git [submodule](http://git-scm.com/docs/git-submodule)：

```bash
$ git submodule add https://github.com/Alamofire/Alamofire.git
$ git submodule add https://github.com/Moya/Moya.git
$ git submodule add https://github.com/Shannon-Yang/SYMoyaNetwork
$ git submodule add 'The data model library you want to use, such as HandyJSON, ObjectMapper, Codable, SwiftyJSON'
```

- 打开新建的 `Alamofire` 文件夹，把 `Alamofire.xcodeproj` 拖拽到你 Xcode 的项目导航中。对 Moya 文件夹下的 `Moya.xcodeproj` 做同样的操作，对SYMoyaNetwork文件夹下面的`SYMoyaNetwork.xcodeproj`也做同样的操作，以及其他的数据模型库也做以上相同的操作。

> 它们应该嵌套在应用程序的蓝色项目图标下面，在其它 Xcode group 的上面或者下面都没关系。

- 验证 `xcodeproj` 的部署 target 与你项目导航中的应用程序 target 一致。
- 接下来，在项目导航（蓝色的项目图标）中选择你的应用项目然后导航到 target 配置窗口，并且在侧栏中的 Targets 标题下选择应用程序 target。
- 在窗口顶部的标签栏中，打开 "General" 面板。
- 点击 "Embedded Binaries" 区域下面的 `+` 按钮。
- 你将会看到两个不同的 `Alamofire.xcodeproj` 文件夹。每个文件夹都有两个不同版本的 `Alamofire.framework` 嵌套在 `Products` 文件夹里。

> 选择哪个 `Products` 文件夹并不重要，重要的是你选择的是上边的还是下边的 `Alamofire.framework`。

- 为 iOS 选择上边的 `Alamofire.framework`，下边的用于 macOS。

> 你可以通过检查项目的构建日志来验证你选择的是哪一个。`Alamofire` 的 build target 将被列为 `Alamofire iOS`, `Alamofire macOS`, `Alamofire tvOS` 或 `Alamofire watchOS`。

- 再次点击 `+` 按钮为 `Moya` 添加正确的 build target，对`SYMoyaNetwork`也做以上相同的事

- 这就完事了！

> 这些框架会作为 target dependency，linked framework 和 embedded framework 被自动添加到一个 copy files build phase，这就是在模拟器和设备进行构建所需要的全部内容了。

## 用法

像和使用`Moya`一样，`SYMoyaNetwork`的用法和`Moya`完全一样，你不用担心它的使用方式会很复杂，这将减少




























