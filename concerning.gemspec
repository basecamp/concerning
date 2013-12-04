Gem::Specification.new do |s|
  s.name      = 'concerning'
  s.version   = '1.0.0'
  s.author    = 'Jeremy Kemper'
  s.email     = 'jeremy@37signals.com'
  s.homepage  = 'https://github.com/37signals/concerning'
  s.summary   = 'Separating small concerns'

  s.add_runtime_dependency 'activesupport', '>= 3.0.0'
  s.add_development_dependency 'minitest'

  s.files = [ "#{File.dirname(__FILE__)}/lib/concerning.rb" ]
end
