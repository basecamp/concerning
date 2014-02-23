module Kernel
  # A shortcut to define a toplevel concern, not within a module.
  def concern(topic, &module_definition)
    ::Object.concern topic, &module_definition
  end
end
