platform :ios, '15.0'
use_frameworks!
use_local_pods = (ENV['CI'] != 'true') # 本地开发 true，CI 构建 false

target 'MobileProject' do
  # UI 布局
  pod 'SnapKit', '~> 5.7.1'
    
  # 本地化
  pod 'Localize-Swift', '~> 3.2'
  
  # 开发环境专用
  pod 'SwiftGen', '~> 6.6.3', :configurations => ['Debug']
    
  # 键盘处理
  pod 'IQKeyboardManagerSwift', '8.0.0'

  # 数据存储
  pod 'SQLite.swift', '~> 0.13.0'
  
  pod "TrackReport", :git => "https://github.com/OYForever/TrackReport.git", :tag => "1.1.5"

  if use_local_pods
    puts "👉 本地环境：使用开发路径版本 KiwiPublicPod"
    pod 'KiwiPublicPod', :path => '../KiwiPublicPod'
  else
    puts "🚀 CI 构建：使用远程 tag 版本 KiwiPublicPod"
    pod 'KiwiPublicPod', :git => "https://github.com/kiwiszhang/KiwiPublicPod.git"
  end
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
    end
  end
end
