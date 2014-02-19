require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
$VERBOSE = true

require 'concerning'

class ConcerningTest < MiniTest::Unit::TestCase
  def test_concern_shortcut_creates_a_module_but_doesnt_include_it
    mod = Module.new { concern(:Foo) { } }
    assert_kind_of Module, mod::Foo
    assert mod::Foo.respond_to?(:included)
    assert !mod.ancestors.include?(mod::Foo), mod.ancestors.inspect
  end

  def test_concern_creates_a_module_extended_with_active_support_concern
    klass = Class.new do
      concern :Foo do
        included { @foo = 1 }
        def should_be_public; end
      end
    end

    # Declares a concern but doesn't include it
    assert_kind_of Module, klass::Foo
    assert !klass.ancestors.include?(klass::Foo), klass.ancestors.inspect

    # Public method visibility by default
    assert klass::Foo.public_instance_methods.map(&:to_s).include?('should_be_public')

    # Calls included hook
    assert_equal 1, Class.new { include klass::Foo }.instance_variable_get('@foo')
  end

  def test_concerning_declares_a_concern_and_includes_it_immediately
    klass = Class.new { concerning(:Foo) { } }
    assert klass.ancestors.include?(klass::Foo), klass.ancestors.inspect
  end

  class Foo
    concerning :Bar do
      module ClassMethods
        def should_not_be_public; end
      end
      class_methods do
        def should_be_public; end
      end
    end
  end

  def test_concerning_does_not_add_a_class_method_if_module_defined_directly
    assert !Foo.methods.include?(:should_not_be_public)
  end

  def test_concerning_adds_class_methods
    assert Foo.methods.include?(:should_be_public)
  end
end

# Put a fake Active Support implementation in the load path to verify that
# we defer to it when we can.
class ForwardCompatibilityWithRails41Test < MiniTest::Unit::TestCase
  def setup;    expunge_loaded_features end
  def teardown; expunge_loaded_features end

  def test_check_for_active_support_implementation_before_providing_our_own
    with_stubbed_active_support_in_load_path do
      require 'concerning'
    end
    assert defined?(::CONCERNING_DEFERRED_TO_ACTIVE_SUPPORT)
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
