# This library was merged to Rails 4.1.
#
# Prefer Active Support's implementation if it's available.
#
# This allows libraries which support multiple Rails versions to depend on
# `concerning` without worrying about implementation collision. This lib
# will step aside if it sees its work is done.
begin
  require 'active_support/core_ext/module/concerning'
rescue LoadError
  require 'concerning/extension'
end
