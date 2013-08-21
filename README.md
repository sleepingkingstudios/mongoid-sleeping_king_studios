# Mongoid::SleepingKingStudios

A collection of concerns and extensions to add functionality to Mongoid
documents and collections.

## The Mixins

### Sluggable

    require 'mongoid/sleeping_king_studios/sluggable'

Adds a slug field that automatically tracks a base attribute and stores a
short, url-friendly version.

**How To Use:**

    class SluggableDocument
      include Mongoid::Document
      include Mongoid::SleepingKingStudios::Sluggable

      field :title, :type => String

      slugify :title
    end # class

#### Options

##### Lockable

    slugify :title, :lockable => true

Allows the slug to be specified manually. Adds an additional slug_lock field
that is automatically set to true when #slug= is called. To resume tracking the
base attribute, set :slug_lock to false.

### Tree

    require 'mongoid/sleeping_king_studios/tree'

Sets up a basic tree structure by adding belongs_to :parent and has_many
:children relations, as well as some helper methods.

**How To Use:**

    class TreeDocument
      include Mongoid::Document
      include Mongoid::SleepingKingStudios::Tree
    end # class

#### Options

To customize the created #parent and #children relations, you can define
::options_for_parent and ::options_for_children class methods before including
the Tree concern. These methods must return a hash if defined.

    class EvilEmployee
      include Mongoid::Document

      def self.options_for_parent
        { :relation_name => :overlord }
      end # class method options_for_parent

      def self.options_for_children
        { :relation_name => :minions, :dependent => :destroy }
      end # class method options_for_children

      include Mongoid::SleepingKingStudios::Tree
    end # class

Available options include the default Mongoid options for a :belongs_to and a
:has_many relationship, respectively. In addition, you can set a :relation_name
option to change the name of the created relation (see example above). The
concern will automatically update the respective :inverse_of options to match
the updated relation names.

## License

RSpec::SleepingKingStudios is released under the
[MIT License](http://www.opensource.org/licenses/MIT).
