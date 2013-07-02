We often find ourselves with a medium-sized chunk of behavior that we'd
like to extract, but only mix in to a single class.

We typically choose to leave the implementation directly in the class,
perhaps with a comment, because the mental and visual overhead of defining
a module, making it a Concern, and including it is just too great.


Using comments as lightweight modularity:

  class Todo
    # Other todo implementation
    # ...

    ## Event tracking
    has_many :events

    before_create :track_creation
    after_destroy :track_deletion

    private
      def track_creation
        # ...
      end
  end


Trying on a noisy embedded module:

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

      private
        def track_creation
          # ...
        end
    end
    include EventTracking
  end


Once our chunk of behavior starts pushing the scroll-to-understand it
boundary, we give in and move it to a separate file. At this size, the
overhead feels in good proportion to the size of our extraction, despite
diluting our at-a-glance sense of how things really work.

Mix-in noise exiled to its own file:

  class Todo
    # Other todo implementation
    # ...

    include TodoEventTracking
  end


Introducing Module#concerning.

By quieting the mix-in noise, we arrive at a natural, low-ceremony way to
do bite-sized modularity:

  class Todo
    # Other todo implementation
    # ...

    concerning :EventTracking do
      included do
        has_many :events
        before_create :track_creation
        after_destroy :track_deletion
      end

      private
        def track_creation
          # ...
        end
    end
  end

  Todo.ancestors
  # => Todo, Todo::EventTracking, Object


This small step forward has some wonderful ripple effects. We can:
* grok the behaviors that compose our class in one glance
* clean up junk drawer classes by encapsulating their concerns
* stop leaning on protected/private for "internal stuff" modularity
