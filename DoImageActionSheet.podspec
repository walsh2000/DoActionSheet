Pod::Spec.new do |s|
  s.name     = 'DoImageActionSheet'
  s.version  = '1.2.1'
  s.author   = { 'Walsh' => 'fullscreen@gmail.com' }
  s.homepage = 'https://github.com/walsh2000/DoActionSheet'
  s.summary  = 'A replacement for UIActionSheet : images in the action sheet'
  s.license  = { :type => 'MIT', :file => 'License' }
  s.source   = { :git => 'https://github.com/walsh2000/DoActionSheet.git', :tag => '1.2.1' }
  s.source_files = 'TestActionSheet/3rdSource/UIImage-ResizeMagick/*.{h,m}','TestActionSheet/DoActionSheet/*.{h,m}'
  s.platform = :ios
  s.requires_arc = true
end
