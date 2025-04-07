Pod::Spec.new do |s|
  s.name             = 'Flutter'
  s.version          = '1.0.0'
  s.summary          = 'Flutter Engine Framework'
  s.homepage         = 'https://flutter.dev'
  s.license          = { :type => 'BSD' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :git => 'https://github.com/flutter/engine.git' }
  s.ios.deployment_target = '11.0'
  s.vendored_frameworks = 'Flutter.xcframework'
end
