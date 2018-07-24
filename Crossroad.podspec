Pod::Spec.new do |s|
  s.name         = "Crossroad"
  s.version      = "1.0.1"
  s.summary      = "Route URL schemes easily"
  s.description  = <<-DESC
  Crossroad is URL router focused on handling Custom URL Scheme.
  Using this, you can route multiple URL schemes and fetch arguments and parameters easily.
                   DESC

  s.homepage     = "https://github.com/giginet/Crossroad"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "giginet" => "giginet.net@gmail.com" }
  s.social_media_url   = "http://twitter.com/giginet"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/giginet/Crossroad.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/Crossroad/**/*.{h,swift}"
  s.requires_arc = true
  s.swift_version = "4.1"
end
