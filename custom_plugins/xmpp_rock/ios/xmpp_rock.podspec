#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint xmpp_rock.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'xmpp_rock'
  s.version          = '0.0.1'
  s.summary          = 'XMPP agent for flutter apps.'
  s.description      = <<-DESC
XMPP agent for flutter apps.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.dependency 'Flutter'
  s.dependency 'XMPPFramework'
  s.dependency 'CocoaAsyncSocket'
  s.dependency 'CocoaLumberjack'
  s.dependency 'KissXML'
  s.dependency 'libidn'
  s.dependency 'RxSwift', '~> 5'
  s.dependency 'RxCocoa', '~> 5'

  s.swift_version = '5.0'
end
