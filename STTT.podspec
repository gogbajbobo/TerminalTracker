Pod::Spec.new do |s|
  s.name         = "STTT"
  s.version      = "0.0.1"
  s.summary      = "STTT is Sys-Team TerminalTracker."
  s.homepage     = "https://github.com/sys-team/TerminalTracker"

  s.license      = 'MIT'
  s.author       = { "Grigoriev Maxim" => "grigoriev.maxim@gmail.com" }
  s.source       = { :git => "https://github.com/sys-team/TerminalTracker.git", :branch => 'master'}
  s.platform     = :ios, '5.0'

  s.source_files = 'TerminalTracker/*.lproj/STTT*.storyboard', 'TerminalTracker/*.lproj/Localizable.strings', 'TerminalTracker/Classes/STTT*.{h,m}', 'TerminalTracker/DataModel/STTT*.{h,m}'
  s.resources = 'TerminalTracker/DataModel/STTT*.{xcdatamodel,xcdatamodeld}'


  s.frameworks = 'SystemConfiguration', 'CoreData', 'MapKit', 'CoreLocation', 'UIKit', 'Foundation', 'CoreGraphics'

  s.requires_arc = true

end
