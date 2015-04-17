Pod::Spec.new do |s|
  s.name = "Attendant"
  s.version = "0.1.0"
  s.summary = "Swift µFramework for associated objects and blocks."
  s.description  = <<-DESC
                   Simple Swift utilities for associated objects and blocks.

                   * Type-safe wrappers for associated object keys
                   * Bridge Swift closures back into Objective-C
                   * Modern equivalent for `-performSelector:withObject:afterDelay:`
                   DESC
  s.homepage     = "https://github.com/zwaldowski/Attendant"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Zachary Waldowski" => "zach@waldowski.me" }
  s.social_media_url = "http://twitter.com/zwaldowski"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.source = { :git => "https://github.com/zwaldowski/Attendant.git", :tag => "v#{s.version}" }
  s.source_files = "Attendant/*.swift", "Attendant/Debounce.{h,m}"
end
