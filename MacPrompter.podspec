Pod::Spec.new do |s|

s.name              = 'MacPrompter'
s.version           = '0.0.1'
s.summary           = 'An NSButton subclass that looks just like the Yosemite+ native window close button'
s.homepage          = 'https://github.com/Megatron1000/MacPrompter'
s.license           = {
:type => 'MIT',
:file => 'LICENSE'
}
s.author            = {
'Mark Bridges' => 'support@bridgetech.io'
}
s.source            = {
:git => 'https://github.com/Megatron1000/MacPrompter.git',
:tag => "0.0.1"
}
s.platform     = :osx, '10.10'
s.source_files = 'MacPrompter/**/*'
s.requires_arc = true
s.social_media_url = "https://twitter.com/markbridgesapps"

end
