## Bite-sized separation of concerns

(*Note!* Module#concerning is included in Rails 4.1!)

We often find ourselves with a medium-sized chunk of behavior that we'd
like to extract, but only mix in to a single class.

Extracting a plain old Ruby object to encapsulate it and collaborate or
delegate to the original object is often a good choice, but when there's
no additional state to encapsulate or we're making DSL-style declarations
about the parent class, introducing new collaborators can obfuscate rather
than simplify.

The typical route is to just dump everything in a monolithic class, perhaps
with a comment, as a least-bad alternative. Using modules in separate files
means tedious sifting to get a big-picture view.

## Dissatisfying ways to separate small concerns

#### Using comments:

```ruby
class Todo
  # Other todo implementation
  # ...

  ## Event tracking
  has_many :events

  before_create :track_creation
  after_destroy :track_deletion

  def self.next_by_event
    # ...
  end


  private
    def track_creation
      # ...
    end
end
```

#### With an inline module:

Noisy syntax.

```ruby
class Todo
  # Other todo implementation
  # ...

  module EventTracking
    extend ActiveSupport::Concern

    included do
      has_many :events
      before_create :track_creation
      after_destroy :track_deletion
    end

    module ClassMethods
      def next_by_event
        # ...
      end
    end

    private
      def track_creation
        # ...
      end
  end
  include EventTracking
end
```

#### Mix-in noise exiled to its own file:

Once our chunk of behavior starts pushing the scroll-to-understand it
boundary, we give in and move it to a separate file. At this size, the
overhead feels in good proportion to the size of our extraction, despite
diluting our at-a-glance sense of how things really work.

```ruby
class Todo
  # Other todo implementation
  # ...

  include TodoEventTracking
end
```

## Introducing Module#concerning

By quieting the mix-in noise, we arrive at a natural, low-ceremony way to
separate bite-sized concerns.

```ruby
  class Todo
    # Other todo implementation
    # ...

    concerning :EventTracking do
      included do
        has_many :events
        before_create :track_creation
        after_destroy :track_deletion
      end

      class_methods do
        def next_by_event
          # ...
        end
      end

      private
        def track_creation
          # ...
        end
    end
  end

  Todo.ancestors
  # => Todo, Todo::EventTracking, Object
```

This small step has some wonderful ripple effects. We can
* grok the behavior of our class in one glance,
* clean up monolithic junk-drawer classes by separating their concerns, and
* stop leaning on protected/private for crude "this is internal stuff" modularity.
