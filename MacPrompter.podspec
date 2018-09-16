Pod::Spec.new do |s|

s.name              = 'MacPrompter'
s.version           = '0.0.11'
s.summary           = 'Prompts the user to rate the app or view your other apps.'
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
:tag => "0.0.11"
}
s.platform     = :osx, '10.10'
s.swift_version = '4.2'
s.source_files = 'MacPrompter/Classes/**/*.{swift, strings}'
s.resource_bundles = {
    'MacPrompter' => ['MacPrompter/Resources/*.lproj']
}
s.requires_arc = true
s.social_media_url = "https://twitter.com/markbridgesapps"

end
