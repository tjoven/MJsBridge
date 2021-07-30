#
# Be sure to run `pod lib lint LDJsBridge.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LDJsBridge'
  s.version          = '1.0.1'
  s.summary          = 'iOS平台的JsToNative交互'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
iOS平台的JsToNative交互组件，参考“https://github.com/Lision/WKWebViewJavascriptBridge”
                       DESC

  s.homepage         = 'https://code.lenovows.com/lenovocloud/css/cc/ios-components/ldjsbridge'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'changmin_wow@163.com' => 'changmin@lenovocloud.com' }
  s.source           = { :git => 'https://code.lenovows.com/lenovocloud/css/cc/ios-components/ldjsbridge.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  # 支持版本设定
  s.ios.deployment_target = '8.0'
  #  s.osx.deployment_target = '10.10'
  # 源文件
  s.source_files = 'iOS/LDJsBridge/Classes/*.{h,m}'
  # s.ios.source_files = 'LDJsBridge/ios/Classes/**/*'
  # s.osx.source_files = 'LDJsBridge/osx/Classes/**/*'

  # s.resource_bundles = {
  #   'LDJsBridge' => ['LDJsBridge/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # 系统库设定
  # s.frameworks = 'UIKit', 'MapKit'
  s.ios.frameworks = 'Foundation', 'UIKit', 'WebKit'
  # s.osx.frameworks = 'Foundation', 'AppKit'
  # 第三方依赖设定
  # s.dependency 'AFNetworking', '~> 2.3'
  # s.ios.dependency 'AFNetworking/Reachability'
  # s.osx.dependency 'AFNetworking/Reachability'
  # 动态framework
  # s.vendored_frameworks = 'LDCADPreview/Assets/CADPreview.framework'
  s.requires_arc = true
end
