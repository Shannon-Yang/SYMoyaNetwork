<p align="center">
  <img height="160" src="https://raw.githubusercontent.com/Shannon-Yang/SYMoyaNetwork/master/Images/logo.png" />
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
provider = SYMoyaProvider<GitHub>()
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

pod 'SYMoyaNetwork/MJExtension'
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

> NOTE: At this time, Carthage does not provide a way to build only specific repository submodules. All submodules and their dependencies will be built with the above command. However, you don't need to copy frameworks you aren't using into your project. For instance, if you aren't using `ObjectMapper`, feel free to delete that framework along with `ObjectMapper` from the Carthage Build directory after `carthage update` completes. Or if you are using `HandyJSON` but not `MJExtension` or `ObjectMapper`, then `ObjectMapper`, `MJExtension` etc. can safely be deleted.

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

### 数据请求

像和使用`Moya`一样，`SYMoyaNetwork`的用法和`Moya`完全一样，你不用担心它的使用方式会很复杂，像



`SYMoyaNetwork`提供了JSON、String、Image、HandyJSON、ObjectMapper、Codable、SwiftyJSON等多种数据类型的支持，你可以使用SYMoyaProvider调用对应的Response方法。

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

### 网络缓存

#### URL缓存
如果你想要实现URL缓存，那么你可以在SYTarget中设置`networkCacheType`为`urlRequestCache`类型，如：

```swift
var networkCacheType: NetworkCacheType {
      return .URLCacheInfo(maxAge: 10)
   }
```

在设置`urlRequestCache`需要传入URL缓存相关的基本信息，例如`ignoreServer`、`maxAge`、`autoClearCache`等关于URL缓存的相关信息，这些信息将在缓存时做重要的决策，设置了 maxAge > 0 将在请求时根据缓存信息进行数据缓存，这些工作都已经自动帮你完成了🍯

如果需要忽略服务器端缓存配置，默认情况下，如果服务器配置了缓存头，则使用服务器端配置，但您可以使用自定义缓存年龄并通过设置ignoreServer参数忽略此配置，只需要设置如下即可：

```swift
var networkCacheType: NetworkCacheType {
      return .URLCacheInfo(ignoreServer: true, maxAge: 10, isPrivate: false)
   }
```

有时您需要手动清理缓存而不是刷新缓存数据，但是对于网络请求错误、序列化错误等我们推荐使用autoClearCache参数自动忽略错误的缓存数据，可以如下设置：

```swift
var networkCacheType: NetworkCacheType {
        return .URLCacheInfo(maxAge: 10, autoClearCache: true)
    }
```

#### 数据缓存
URL缓存仅仅只能对Get请求的数据进行缓存，若需要对Post或者其他类型的请求进行缓存，那么我们需要对Response进行数据存储，`SYMoyaNetwork`已经做好了这一切🍯，仅仅只需要在SYTarget中设置`networkCacheType`为`syMoyaNetworkCache`类型，`syMoyaNetworkCache`做了两种存储，一种为内存存储（MemoryStorage），一种为磁盘存储（DiskStorage），和URL缓存类似，也需要传入存储相关的信息，例如：`diskStorageConfig`、`memoryStorageConfig`等，具体参考`NetworkCacheType.NetworkCacheOptionsInfo`相关，具体实例代码如下：

```swift
var networkCacheType: NetworkCacheType {
        return .syMoyaNetworkCache(networkCacheOptionsInfo: .init())
    }
```
默认使用的`networkCacheOptionsInfo`为`NetworkConfig`中的默认配置，也可自定义配置，仅只需初始化自定义的`networkCacheOptionsInfo`对象，`networkCacheType`返回类型为`syMoyaNetworkCache`时，在请求完成时，不管是Get还是Post或者其他方式的请求，都将自动根据缓存信息进行数据缓存

`SYMoyaProvider`提供了`responseCodableObject`、`responseObject<T: HandyJSON>`、`responseObject<T: BaseMappable>`、`responseSwiftyJSON`等方法，在每一个方法中都有`responseDataSourceType`这样的一个参数，这个参数主要是数据返回的响应类型，目前`responseDataSourceType`分为`server`、`cache`、`cacheIfPossible`、`cacheAndServer`、`custom`一共5种数据返回类型。

* `server`：直接从服务器获取数据，不会回调缓存数据
* `cache`：如果有缓存，直接从缓存中获取数据并进行回调，将回调`success`结果，若不存在缓存则回调失败`failure`结果，并会返回对应的`error`信息
* `cacheIfPossible`：如果有缓存，将直接从缓存中获取数据，如果缓存获取成功，那么将进行`success`回调，若缓存获取失败，将发起网络请求，网络请求成功后将进行`success`回调，请求失败后将进行`failure`回调
* `cacheAndServer`：如果当前接口有缓存，那么将先获取缓存数据后进行一次回调，然后发起网络请求，然后再次回调。
* `custom`：自定义模式的回调，需要实现`ResponseDataSourceCustomizable`协议，这将先从缓存获取缓存数据，得到缓存数据后，将会通过`shouldSendRequest`方法将当前的缓存数进行回调，可以通过回调的缓存数据进行判断，需要通过`shouldUpdateCache`方法回调是否需要更新缓存，这种数据回调模式比较常用的是用作获取数据量比较大的请求。

> `custom`的场景适用如下，例如：我们有一本书，这本书的书籍详情数据是很多的，当我们第一次获取了这本书的书籍详情时，一个比较机智的做法是把当前这本书的书籍详情缓存到本地，下一次打开app的时候先展示这本书的缓存数据，然后在去请求书籍的详情最新的数据，更新本地的缓存，这样确实能达到想要的效果，可是并非是最优方案，一般情况下，如果将书籍详情完全请求覆盖本地缓存，由于书籍详情的数据可能比较大，因此在网络请求相应时间上会很长，而且用户的数据流量也会浪费，所以比较好的方案是仅仅只请求当前书籍的一些基本信息，通过基本信息的一些关键字段判断当前本地缓存的书籍数据是否是最新，然后在判断当前是否需要更新本地缓存，如果书籍的详情数据为最新的，那将不需要再去请求数据，比如基本信息中的`version`等字段，可以通过传`version`等字段给服务端来验证当前的缓存是否为最新，如果当前的缓存不是最新的再发起网络请求，将最新的书籍详情数据请求下来，这样既能先展示数据给用户，又能节省用户流量，在不必要更新数据的时候减少这种庞大数据的请求。

### 批量请求

在一些情况下，我们可能需要发送一批网络请求，`SYMoyaNetwork`提供了批量发起网络请求操作，`SYMoyaBatchRequestProvider`主要用于批量发起网络请求操作，在发起网络请求前，需要初始化`BatchMoyaProvider`的数组传入，在批量请求时，`SYMoyaBatchRequestProvider`维护了一个`BatchMoyaProvider`的请求数组，在所有请求全部请求完成后，将会返回`BatchResult`对象。

> 注意：在批量请求过程中，只要其中有一个请求失败了，那么整个Provider都会回调`failure`方法，只有全部请求都成功后才会回调`success`

如下：

```swift
let batchProvider = BatchMoyaProvider(targetType:.zen, provider: SYMoyaProvider<GitHub>())
let batchProvider2 = BatchMoyaProvider(targetType:.zen, provider: SYMoyaProvider<GitHub>())
    
let batchRequestProvider = SYMoyaBatchRequestProvider(providers: [batchProvider, batchProvider2])
batchRequestProvider.request { batchResponse in
   switch batchResponse.result {
     case .success(let batchData):
        // do something with the response batch data. You can use the batchData directly without conversion
     case .failure(let error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
        }
    }
```

### 链式请求

用于管理有相互依赖的网络请求，它实际上最终可以用来管理多个拓扑排序后的网络请求。

例如，我们有一个需求，需要用户在注册时，先发送注册的 Api，然后 :

* 如果注册成功，再发送读取用户信息的 Api。并且，读取用户信息的 Api 需要使用注册成功返回的用户 id 号。
* 如果注册失败，则不发送读取用户信息的 Api 了。

如下：
```swift
    let chainRequestProvider = SYMoyaChainRequestProvider()
    // Initial chain request
    let chainProvider = ChainProvider(targetType:.zen, provider: SYMoyaProvider<GitHub>(), chainCompletion: { dataResponses in
        switch dataResponses.result {
          case .success(let chainData):
            // After the request is completed, proceed to the next request based on the requested data
            let chainProvider2 = ChainProvider(targetType:.zen, provider: SYMoyaProvider<GitHub>(), chainCompletion: nil)
             chainRequestProvider.addChainProvider(provider: chainProvider2)
                
          case .failure(let error):
            // this means there was a network failure - either the request
            // wasn't sent (connectivity), or no response was received (server
            // timed out).  If the server responds with a 4xx or 5xx error, that
            // will be sent as a ".success"-ful response.
           }
        })
    chainRequestProvider.delegate =  self
    chainRequestProvider.addChainProvider(provider: chainProvider)
    chainRequestProvider.request()
```
## License

SYMoyaNetwork is released under an MIT license. See License.md for more information.
























