<p align="center">
  <img height="160" src="https://raw.githubusercontent.com/Shannon-Yang/SYMoyaNetwork/master/Images/logo.png" />
</p>

# SYMoyaNetwork
基于[Moya](https://github.com/Moya/Moya)二次封装的网络抽象，保持[Moya](https://github.com/Moya/Moya)一样的使用方法，扩展[Moya](https://github.com/Moya/Moya)的`TargetType`，实现常用的数据解析，支持：[HandyJSON](https://github.com/alibaba/HandyJSON)、[ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper)、[Codable](https://developer.apple.com/documentation/swift/codable)、[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)，开发者无需再写数据解析的样板代码，仅仅只需要关心想要什么样的数据，选择数据类型，***SYMoyaNetwork***已做好了这一切，***SYMoyaNetwork***同时实现了网络缓存，并配置常用的缓存策略，仅仅实现想要的缓存策略，`Response`将根据策略进行缓存同步，开发者无需再花大量时间再去做这样的工作，***SYMoyaNetwork***让数据请求变得简单，减少开发者编写样板代码，更多时间去关注业务。

## What
也许你会像大多数iOS开发者一样，使用[Moya](https://github.com/Moya/Moya)来作为网络请求的抽象，[Moya](https://github.com/Moya/Moya)是一个很棒的框架，它规范了你的数据请求，它可以让你足够简单的完成数据请求，***SYMoyaNetwork***是基于[Moya](https://github.com/Moya/Moya)二次封装，它并没有改变Moya的使用方式，仅仅是对Moya的进一步扩展与更友好的封装。

也许你会用Moya这样写请求：

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
当数据请求完成后，我们需要手动的将`moyaResponse`转换成我们想要的数据对象，例如使用[ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper)做为数据模型时，需要每次在返回响应时都需要将`moyaResponse`转换为`BaseMappable`对象，也许你会封装一个统一的方法去做这件事情，但还是需要手动调用这样的一些转换方法，这将让使用者做这些繁琐而又无味的工作，因此***SYMoyaNetwork***已做好了这样的工作，你只需要关心你想要得到的数据，***SYMoyaNetwork***将会给你想要返回的数据，例如使用[ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper)做为数据模型时，我们可以这样来获取数据对象

```swift
provider = SYMoyaProvider<GitHub>()
/// Note: `BaseMappable `here is the data type in which you implement `BaseMappable`, such as a `Class` or `Struct` or `Other` 
provider.responseObject(.zen) { (response: SYMoyaNetworkDataResponse<BaseMappable>) in
    switch response.result {
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
现在使用***SYMoyaNetwork***，你不用再关心如何将response转换成你想要的数据，你只需要关心你想要的数据，***SYMoyaNetwork***已经做好了这一切。

***SYMoyaNetwork***提供多种数据类常用的数据类型解析，例如：`JSON`、`String`、`Image`、`HandyJSON`、`ObjectMapper`、`Codable`、`SwiftyJSON`，使用时仅仅只需要关心你想要得到的数据，其他的你都不用关心，***SYMoyaNetwork***已经对[Moya](https://github.com/Moya/Moya)的`Response`做好了解析，你只管关心你的业务实现。

***SYMoyaNetwork***不仅仅只是做了[Moya](https://github.com/Moya/Moya)的`Response`的转换，更重要的一点是，在[Moya](https://github.com/Moya/Moya)的基础上***SYMoyaNetwork***已经帮你做好网络缓存，在大多数应用使用情况下，网络缓存是非常重要，它可以让你的App更快的展示数据，更能为用户节省数据流量，可以说在网络这一层是一个很重要的决策，因此***SYMoyaNetwork***提供常用的网络缓存策略的实现，参考[数据缓存](###数据缓存)。

***SYMoyaNetwork***支持[Combine](https://developer.apple.com/documentation/combine)，同时也支持[RxSwift](https://github.com/ReactiveX/RxSwift)、[ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift)等常用的响应式框架。

***SYMoyaNetwork***也支持链式请求以及批量请求，在大多数的业务情况下，我们可能会有一批请求发送，或者有关联的链式请求，***SYMoyaNetwork***也提供这些功能，可以轻松快捷的实现，参考：[链式请求](###链式请求)和[批量请求](###批量请求)。

## 功能
* 支持：[HandyJSON](https://github.com/alibaba/HandyJSON)、[ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper)、[Codable](https://developer.apple.com/documentation/swift/codable)、[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)数据解析，开发者只需要关心你想要得到的数据。
* 扩展[Moya](https://github.com/Moya/Moya)的`TargetType`，新增`timeoutInterval`、`cdnURL`、`allowsCellularAccess`、`cachePolicy`等属性.
* 支持数据缓存（磁盘和内存），并实现数据缓存策略
* 支持链式请求
* 支持批量请求
* 支持[Combine](https://developer.apple.com/documentation/combine)，同时也支持[RxSwift](https://github.com/ReactiveX/RxSwift)、[ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift)等常用的响应式框架。
* 支持`Concurrency`异步调用
* 支持请求日志输出，请求数据信息一目了然

## Tip
***SYMoyaNetwork***为了支持不同类型的数据解析，将不同类型的数据解析拆分为不同的Framework包，所有的解析数据包都依赖于核心`Core`包，开发者可以选择使用的解析类型进行安装，例如：使用[RxSwift](https://github.com/ReactiveX/RxSwift)可以直接安装`SYMoyaObjectMapper`包，如果还需要使用[ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper)作为数据解析，那么可以安装`SYMoyaRxObjectMapper`。

![SYMoyaNetwork](/Images/SYMoyaNetwork.png)

## 安装

### Swift Package Manager

要使用苹果的 Swift Package Manager 集成，将以下内容作为依赖添加到你的 `Package.swift`：

```swift
.package(url: "https://github.com/Shannon-Yang/SYMoyaNetwork", .upToNextMajor(from: "2.0.0"))
```

然后为你的Taeget指定***SYMoyaNetwork***依赖。这里是一个 `PackageDescription` 实例：

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
        .package(url: "https://github.com/Shannon-Yang/SYMoyaNetwork", .upToNextMajor(from: "2.0.0"))
    ]
)
```

### CocoaPods

在你的 Podfile 文件中添加 SYMoyaNetwork：

```rb

pod 'SYMoyaNetwork', '~> 2.0'

# or 
pod 'SYMoyaNetwork/SYMoyaReactiveHandyJSON', '~> 2.0'
# or
pod 'SYMoyaNetwork/SYMoyaReactiveObjectMapper', '~> 2.0'
#or
pod 'SYMoyaNetwork/SYMoyaHandyJSON', '~> 2.0'
#or
pod 'SYMoyaNetwork/SYMoyaRxHandyJSON', '~> 2.0'
#or
pod 'SYMoyaNetwork/SYMoyaRxObjectMapper', '~> 2.0'
#or
pod 'SYMoyaNetwork/SYMoyaObjectMapper', '~> 2.0'
#or
pod 'SYMoyaNetwork/ReactiveSYMoyaNetwork', '~> 2.0'
#or
pod 'SYMoyaNetwork/RxSYMoyaNetwork', '~> 2.0'
```

然后运行 `pod install`。

在任何你想使用 ***SYMoyaNetwork*** 的文件中，使用 `import SYMoyaNetwork` 导入框架。

### Carthage

Carthage 用户可以指向这个仓库并使用他们喜欢的生成框架，`SYMoyaNetwork`

在你的 Cartfile 中添加下面的代码：

```
github "SYMoyaNetwork/SYMoyaNetwork"
```

然后运行 `carthage update --use-xcframeworks`。

如果这是你首次在项目中使用 Carthage，你将需要进行一些额外的步骤，它们在 [Carthage](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) 中有解释。

> NOTE: At this time, Carthage does not provide a way to build only specific repository submodules. All submodules and their dependencies will be built with the above command. However, you don't need to copy frameworks you aren't using into your project. For instance, if you aren't using `ObjectMapper`, feel free to delete that framework along with `ObjectMapper` from the Carthage Build directory after `carthage update` completes. Or if you are using `HandyJSON` but not `MJExtension` or `ObjectMapper`, then `ObjectMapper`, `MJExtension` etc. can safely be deleted.

### 手动

- 打开终端，`cd` 到你项目的顶层目录，如果你的项目没有初始化为 git 仓库，运行下面的命令：

```bash
$ git init
```

- 通过运行以下命令来添加 Alamofire & Moya & SYMoyaNetwork & The data model library you want to use, such as [HandyJSON](https://github.com/alibaba/HandyJSON) 或者 [ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper)作为 git [submodule](http://git-scm.com/docs/git-submodule)：

```bash
$ git submodule add https://github.com/Alamofire/Alamofire.git
$ git submodule add https://github.com/Moya/Moya.git
$ git submodule add https://github.com/Shannon-Yang/SYMoyaNetwork
$ git submodule add 'The data model library you want to use, such as HandyJSON, ObjectMapper, SwiftyJSON'
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

### 数据请求

像和使用`Moya`一样，`SYMoyaNetwork`的用法和`Moya`完全一样，你不用担心它的使用方式会很复杂

***SYMoyaNetwork***提供了JSON、String、Image、HandyJSON、ObjectMapper、Codable、SwiftyJSON等多种数据类型的支持，你可以使用``SYMoyaProvider``调用对应的`Response`方法。

#### JSON

```swift
provider = SYMoyaProvider<GitHub>()
provider.responseJSON(.zen) { (response: SYMoyaNetworkDataResponse<Any>) in
    switch response.result {
    case let .success(json):
        // do something with the response json data. You can use the json object directly without conversion
    case let .failure(error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```

#### String

```swift
provider = SYMoyaProvider<GitHub>()
provider.responseString(.zen) { (response: SYMoyaNetworkDataResponse<String>) in
    switch response.result {
    case let .success(string):
        // do something with the response string data. You can use the string object directly without conversion
    case let .failure(error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```

#### Image

```swift
provider = SYMoyaProvider<GitHub>()
provider.responseImage(.zen) { (response: SYMoyaNetworkDataResponse<Image>) in
    switch response.result {
    case let .success(image):
        // do something with the response image data. You can use the image object directly without conversion
    case let .failure(error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```

#### HandyJSON

```swift
provider = SYMoyaProvider<GitHub>()
provider.responseObject(.zen) { (response: SYMoyaNetworkDataResponse<T: HandyJSON>) in
    switch response.result {
    case let .success(handyJSONObject):
        // do something with the response handyJSONObject data. You can use the handyJSONObject object directly without conversion
    case let .failure(error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```

#### ObjectMapper

```swift
provider = SYMoyaProvider<GitHub>()
provider.responseObject(.zen) { (response: SYMoyaNetworkDataResponse<T: BaseMappable>) in
    switch response.result {
    case let .success(mappableObject):
        // do something with the response mappableObject data. You can use the mappableObject object directly without conversion
    case let .failure(error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```

#### Codable

```swift
provider = SYMoyaProvider<GitHub>()
provider.responseObject(.zen) { (response: SYMoyaNetworkDataResponse<T: Decodable>) in
    switch response.result {
    case let .success(codableObject):
        // do something with the response codableObject data. You can use the codableObject object directly without conversion
    case let .failure(error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```

#### SwiftyJSON

```swift
provider = SYMoyaProvider<GitHub>()
provider.responseSwiftyJSON(.zen) { (response: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) in
    switch response.result {
    case let .success(swiftyjson):
        // do something with the response swiftyjson data. You can use the swiftyjson object directly without conversion
    case let .failure(error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```

### 数据缓存

在多数业务情况下，我们需要将服务器返回的`Response`缓存到本地，例如：那些长时间不更新的资源或者需要在用户没有网络的时候展示出来内容，***SYMoyaNetwork***已经做好了这一切🍯，仅仅只需要在`SYTarget`中设置`networkCacheType`的属性并配置`NetworkCacheOptionsInfo`，***SYMoyaNetwork***做了两种存储，一种为内存存储（MemoryStorage），一种为磁盘存储（DiskStorage），需要传入存储相关的信息，例如：`diskStorageConfig`、`memoryStorageConfig`等，具体参考`NetworkCacheType.NetworkCacheOptionsInfo`相关，具体实例代码如下：

```swift
var networkCacheType: NetworkCacheType {
        return .cache(networkCacheOptionsInfo: .init())
    }
```
默认使用的`networkCacheOptionsInfo`为`NetworkConfig`中的默认配置，也可自定义配置，仅只需初始化自定义的`networkCacheOptionsInfo`对象，`networkCacheType`返回类型为`cache`时，在请求完成时，将会根据这个参数进行校验是否满足缓存条件，如果满足缓存条件，不管是Get还是Post或者其他方式的请求，都将自动根据缓存信息进行数据缓存

`SYMoyaProvider`提供了`responseCodableObject`、`responseObject<T: HandyJSON>`、`responseObject<T: BaseMappable>`、`responseSwiftyJSON`等方法，在每一个方法中都有`responseDataSourceType`这样的一个参数，这个参数主要是数据返回的响应类型，目前`responseDataSourceType`分为`server`、`cache`、`cacheIfPossible`、`cacheAndServer`、`custom`一共5种数据返回类型。

* `server`：直接从服务器获取数据，不会检索缓存数据
* `cache`：如果有缓存，直接从缓存中获取数据并进行回调，将回调`success`结果，若不存在缓存则回调失败`failure`结果，并会返回对应的`error`信息，不会发起网络请求，只会从缓存中检索
* `cacheIfPossible`：如果有缓存，将直接从缓存中获取数据，如果缓存获取成功，那么将进行`success`回调，若缓存获取失败，将发起网络请求，网络请求成功后将进行`success`回调，请求失败后将进行`failure`回调
* `cacheAndServer`：如果当前接口有缓存，那么将先获取缓存数据后进行一次回调，然后发起网络请求，然后再次回调。
* `custom`：自定义模式的回调，需要实现`ResponseDataSourceCustomizable`协议，这将先从缓存获取缓存数据，得到缓存数据后，将会通过`shouldSendRequest`方法将当前的缓存数进行回调，可以通过回调的缓存数据进行判断，需要通过`shouldUpdateCache`方法回调是否需要更新缓存，这种数据回调模式比较常用的是用作获取数据量比较大的请求。

> `custom`的场景适用如下，例如：我们有一本书，这本书的书籍详情数据是很多的，当我们第一次获取了这本书的书籍详情时，一个比较机智的做法是把当前这本书的书籍详情缓存到本地，下一次打开app的时候先展示这本书的缓存数据，然后在去请求书籍的详情最新的数据，更新本地的缓存，这样确实能达到想要的效果，可是并非是最优方案，一般情况下，如果将书籍详情完全请求覆盖本地缓存，由于书籍详情的数据可能比较大，因此在网络请求相应时间上会很长，而且用户的数据流量也会浪费，所以比较好的方案是仅仅只请求当前书籍的一些基本信息，通过基本信息的一些关键字段判断当前本地缓存的书籍数据是否是最新，然后在判断当前是否需要更新本地缓存，如果书籍的详情数据为最新的，那将不需要再去请求数据，比如基本信息中的`version`等字段，可以通过传`version`等字段给服务端来验证当前的缓存是否为最新，如果当前的缓存不是最新的再发起网络请求，将最新的书籍详情数据请求下来，这样既能先展示数据给用户，又能节省用户流量，在不必要更新数据的时候减少这种庞大数据的请求。

### 批量请求

在一些情况下，我们可能需要发送一批网络请求，`SYMoyaNetwork`提供了批量发起网络请求操作，`SYMoyaBatchProviderSession`主要用于批量发起网络请求操作，在发起网络请求前，需要初始化实现了`SYBatchMoyaProviderType`的数组对象，默认`SYMoyaBatchProvider`已经实现`SYBatchMoyaProviderType`，在批量请求时，`SYMoyaBatchProviderSession`维护了一个`SYMoyaBatchProvider`的请求数组，在所有请求全部请求完成后，将会返回`SYMoyaProviderSessionResponse`的数组。

> 注意：在批量请求过程中，只要其中有一个请求失败了，那么整个Provider都会回调`failure`方法，只有全部请求都成功后才会回调`success`

如下：

```swift
var session: SYMoyaBatchProviderSession?

let provider = SYMoyaBatchProvider<HTTPBinDynamicData>(targetTypes: [.getDelay(delay: 1), .stream(n: 1)])
let provider2 = SYMoyaBatchProvider<HTTPBinResponseFormats>(targetTypes: [.brotli, .json, .gzipped])
session = SYMoyaBatchProviderSession(providers: [provider, provider2])
session?.request { [weak self] progress in
        // do something with the response batch data. You can use the batchData directly without conversion
} completion: { [weak self] result in
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
}
```

### 链式请求

用于管理有相互依赖的网络请求，它实际上最终可以用来管理多个拓扑排序后的网络请求。

例如，我们有一个需求，需要用户在注册时，先发送注册的 Api :
* 如果注册成功，再发送读取用户信息的 Api。并且，读取用户信息的 Api 需要使用注册成功返回的用户 id 号。
* 如果注册失败，则不发送读取用户信息的 Api 了。

如下：
```swift
 let chainProvider = SYMoyaChainProvider(targetType: HTTPBinAuth.bearer) { progress in
    debugPrint("🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️----> \(progress) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️")
 }
 SYMoyaChainProviderSession.request(chainMoyaProviderType: chainProvider) { response in
    let targetType = response.targetType
    let result = response.result
    switch targetType {
      case HTTPBinAuth.bearer:
        let json = result.serializerSwiftyJSON().value
        let authenticated = json?["authenticated"].boolValue ?? false
        if authenticated {
            return SYMoyaChainProvider(targetType: HTTPBinDynamicData.getDelay(delay: 1))
        }
      case HTTPBinDynamicData.getDelay:
        let responseString = result.serializerStringDataResponse(atKeyPath: nil)
        self.contentLabel.text = responseString.value
        self.contentLabel.isHidden = false
        self.indicator.stopAnimating()
      default:
            break
     }
    return nil
  } completion: {
     self.indicator.stopAnimating()
     debugPrint("🔥🔥🔥🔥🔥---->  <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🔥🔥🔥🔥🔥")
  }
```
## License

SYMoyaNetwork is released under an MIT license. See License.md for more information.

























