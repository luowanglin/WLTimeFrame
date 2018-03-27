Pod::Spec.new do |s|

  s.name         = "WLTimeFrameView"
  s.version      = "0.0.5"
  s.summary      = "Scroll time frame for 24hours."
  s.description  = "This library provides an smart time frame. For convenience, we added UI elements like WLTimePointer, WLTimeFrameView"
  s.homepage     = "https://github.com/luowanglin/WLTimeFrame"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "luowanglin" => "luowanglin@icloud.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/luowanglin/WLTimeFrame.git", :tag => "#{s.version}" }
  s.source_files  = 'WLTimeFrameView/*.swift' 

end
