module ActiveSupport::Concern
  # Provide a class_methods alternative to ClassMethods since defining
  # a constant within a block doesn't work as folks would expect.
  def class_methods(&class_methods_module_definition)
    mod = const_defined?(:ClassMethods) ?
      const_get(:ClassMethods) :
      const_set(:ClassMethods, Module.new)

    mod.module_eval(&class_methods_module_definition)
  end
end
