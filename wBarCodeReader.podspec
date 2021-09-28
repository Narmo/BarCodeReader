Pod::Spec.new do |s|
	s.name         = "wBarCodeReader"
	s.version      = "1.0.2"
	s.summary      = "Lightweight library which allows reading various barcode types on iOS devices."
	s.swift_version = "5.3"
  
	s.description  = <<-DESC
					Lightweight library which allows reading various barcode types on iOS devices. Supported barcode types are included in AVMetadataObject.ObjectType: https://developer.apple.com/documentation/avfoundation/avmetadataobject/objecttype.
					 DESC
  
	s.homepage     = "https://github.com/Narmo/BarCodeReader"
	s.license      = { :type => "BSD", :file => "LICENSE" }
  
	s.author             = { "Nik Dyonin" => "nik@brite-apps.com" }
  
	s.platform     = :ios
	s.ios.deployment_target = "10.0"
	s.ios.framework = "UIKit"
  
	s.source       = { :git => "https://github.com/Narmo/BarCodeReader.git", :tag => "1.0.2" }
	s.source_files  = "BarCodeReader"
  
	s.requires_arc = true

end
  
