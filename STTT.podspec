Pod::Spec.new do |s|
  s.name         = "STTT"
  s.version      = "1.7.7"
  s.summary      = "STTT is Sys-Team TerminalTracker."
  s.homepage     = "https://github.com/sys-team/TerminalTracker"

  s.license      = 'MIT'
  s.author       = { "Grigoriev Maxim" => "grigoriev.maxim@gmail.com" }
  s.source       = { :git => "https://github.com/sys-team/TerminalTracker.git", :branch => 'master'}
  s.platform     = :ios, '5.0'

  s.source_files = 'TerminalTracker/*.lproj/Localizable.strings', 'TerminalTracker/Classes/ST*.{h,m}', 'TerminalTracker/Data Model/ST*.{h,m}'
  s.resources = 'TerminalTracker/*.lproj/ST*.storyboard', 'TerminalTracker/Data Model/*.{xcdatamodel,xcdatamodeld}', 'TerminalTracker/Resources/Images/*.png'

  s.frameworks = 'SystemConfiguration', 'CoreData', 'MapKit', 'CoreLocation', 'UIKit', 'Foundation', 'CoreGraphics'

  s.requires_arc = true

end
