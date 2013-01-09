Pod::Spec.new do |s|
  s.name         = "V8HorizontalPickerView"
  s.version      = "0.0.1"
  s.summary      = "Horizontal UIPickerView Control for iOS."
  s.description  = <<-DESC
	A control for iOS apps which allows a user to select from multiple options by swiping 
        the control left and right.  The option which appears in the center is selected.  The
        control is not allowed to come to rest in between options.  One option will always be
        selected as movement comes to a stop. 
                    DESC
  s.homepage     = "https://github.com/veader/V8HorizontalPickerView"

  s.license      = { :type => 'zlib/libpng', :file => 'LICENSE' }

  s.author       = { "Shawn Veader" => "shawn@veader.org" }

  s.source       = { :git => "https://github.com/veader/V8HorizontalPickerView.git", :commit => '2d745e7737'}
  s.platform     = :ios

  s.source_files = 'Classes', '*.{h,m}'

  s.public_header_files = '*.h'

  s.requires_arc = false

end
