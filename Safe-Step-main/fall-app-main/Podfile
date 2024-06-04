platform :ios, '14.0'
use_frameworks!
target 'fall-app' do
    # LOCAL
    pod "MetaWear", :subspecs => ['UI', 'AsyncUtils', 'DFU']
    # COCOA POD
    pod "MetaWear"
    # COCOA POD RELEASE SPECIFIC
    # pod "MetaWear", '~> '4.0.2'

    pod 'SkeletonUI'
    pod 'Polyline', '~> 5.0'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
               end
          end
   end
end
