
Pod::Spec.new do |spec|
  spec.name         = "VVRichText"
  spec.version      = "0.0.4"
  spec.summary      = "VVRichText 是一个支持异步文本渲染的富文本显示,编辑组件"
  spec.homepage     = "https://github.com/chinaxxren/VVRichText"
  spec.license      = "MIT"
  spec.author       = { "chinaxxren" => "182421693@qq.com" }
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/chinaxxren/VVRichText.git", :tag => "#{spec.version}" }
  spec.source_files  = "VVRichText/Source", "VVRichText/Source/**/*.{h,m}"
  spec.frameworks  = "UIKit"
  spec.dependency  "YYImage/WebP"
  spec.dependency  "SDWebImage"
end
