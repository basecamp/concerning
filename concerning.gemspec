Gem::Specification.new do |s|
  s.name      = 'concerning'
  s.version   = '1.0.0'
  s.author    = 'Jeremy Kemper'
  s.email     = 'jeremy@bitsweat.net'
  s.homepage  = 'https://github.com/jeremy/concerning'
  s.summary   = 'Bite-sized inline mixins'

  s.add_runtime_dependency 'activesupport', '>= 3.0.0'
  s.add_development_dependency 'minitest'

  s.files = [ "#{File.dirname(__FILE__)}/lib/concerning.rb" ]
end
