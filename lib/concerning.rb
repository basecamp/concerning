# This library was merged to Rails 4.1.
#
# Prefer Active Support's implementation if it's available.
#
# This allows libraries which support multiple Rails versions to depend on
# `concerning` without worrying about implementation collision. This lib
# will step aside if it sees its work is done.

require 'active_support/concern'

# Check for Concern#class_methods
if !ActiveSupport::Concern.method_defined?(:class_methods)
  require 'concerning/concern_class_methods'
end

# Check for Module#concerning
begin
  require 'active_support/core_ext/module/concerning'
rescue LoadError
  require 'concerning/module_concerning'
end

# Check for Kernel#concern
begin
  require 'active_support/core_ext/kernel/concern'
rescue LoadError
  require 'concerning/kernel_concern'
end
