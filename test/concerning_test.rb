require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
$VERBOSE = true

require 'concerning'

class ConcerningTest < Minitest::Test
  def test_concerning_declares_a_concern_and_includes_it_immediately
    klass = Class.new { concerning(:Foo) { } }
    assert klass.ancestors.include?(klass::Foo), klass.ancestors.inspect
  end
end

class ConcernTest < Minitest::Test
  def test_concern_creates_a_module_extended_with_active_support_concern
    klass = Class.new do
      concern :Baz do
        included { @foo = 1 }
        def should_be_public; end
      end
    end

    # Declares a concern but doesn't include it
    assert klass.const_defined?(:Baz, false)
    assert !ConcernTest.const_defined?(:Baz)
    assert_kind_of ActiveSupport::Concern, klass::Baz
    assert !klass.ancestors.include?(klass::Baz), klass.ancestors.inspect

    # Public method visibility by default
    assert klass::Baz.public_instance_methods.map(&:to_s).include?('should_be_public')

    # Calls included hook
    assert_equal 1, Class.new { include klass::Baz }.instance_variable_get('@foo')
  end

  def test_may_be_defined_at_toplevel
    mod = ::TOPLEVEL_BINDING.eval 'concern(:ToplevelConcern) { }'
    assert_equal mod, ::ToplevelConcern
    assert_kind_of ActiveSupport::Concern, ::ToplevelConcern
    assert !Object.ancestors.include?(::ToplevelConcern), mod.ancestors.inspect
  end

  class Foo
    concerning :Bar do
      module ClassMethods
        def will_be_orphaned; end
      end

      const_set :ClassMethods, Module.new {
        def hacked_on; end
      }

      # Doesn't overwrite existing ClassMethods module.
      class_methods do
        def nicer_dsl; end
      end

      # Doesn't overwrite previous class_methods definitions.
      class_methods do
        def doesnt_clobber; end
      end
    end
  end

  def test_using_class_methods_blocks_instead_of_ClassMethods_module
    assert !Foo.respond_to?(:will_be_orphaned)
    assert Foo.respond_to?(:hacked_on)
    assert Foo.respond_to?(:nicer_dsl)
    assert Foo.respond_to?(:doesnt_clobber)

    # Orphan in Foo::ClassMethods, not Bar::ClassMethods.
    assert Foo.const_defined?(:ClassMethods)
    assert Foo::ClassMethods.method_defined?(:will_be_orphaned)
  end
end

# Put a fake Active Support implementation in the load path to verify that
# we defer to it when we can.
class ForwardCompatibilityWithRails41Test < Minitest::Test
  def setup;    expunge_loaded_features end
  def teardown; expunge_loaded_features end

  def test_check_for_active_support_implementation_before_providing_our_own
    with_stubbed_active_support_in_load_path do
      require 'concerning'
    end
    assert defined?(::MODULE_CONCERNING_DEFERRED_TO_ACTIVE_SUPPORT)
    assert defined?(::KERNEL_CONCERN_DEFERRED_TO_ACTIVE_SUPPORT)
  end

  private
  def expunge_loaded_features
    $LOADED_FEATURES.delete_if { |feature| feature =~ /concerning/ }
  end

  def with_stubbed_active_support_in_load_path
    $LOAD_PATH.unshift File.expand_path('../active_support_stub', __FILE__)
    yield
  ensure
    $LOAD_PATH.shift
  end
end
