# Mongoid::SleepingKingStudios

A collection of concerns and extensions to add functionality to Mongoid
documents and collections.

## The Mixins

### HasTree

    require 'mongoid/sleeping_king_studios/has_tree'

Sets up a basic tree structure by adding belongs_to :parent and has_many
:children relations, as well as some helper methods.

From 0.2.0 to 0.3.1, was Mongoid::SleepingKingStudios::Tree

**How To Use:**

    class TreeDocument
      include Mongoid::Document
      include Mongoid::SleepingKingStudios::HasTree

      has_tree
    end # class

#### Options

You can pass customisation options for the generated relations into the
::has\_tree method.

    class EvilEmployee
      include Mongoid::Document
      include Mongoid::SleepingKingStudios::HasTree

      has_tree :parent => { :relation_name => :overlord },
        :children => { :relation_name => :minions, :dependent => :destroy }
    end # class

Available options include the standard Mongoid options for a :belongs_to and a
:has_many relationship, respectively. In addition, you can set a :relation_name
option to change the name of the created relation (see example above). The
concern will automatically update the respective :inverse_of options to match
the updated relation names.

#### Cache Ancestry

Stores the chain of ancestors in an :ancestor_ids array field, and adds the
\#ancestors and #descendents scopes.

    class AncestryTree
      include Mongoid::Document
      include Mongoid::SleepingKingStudios::HasTree

      has_tree :cache_ancestry => true
    end # class

**Options**

You can customize the ancestry cache by passing in a hash of options as the
:cache\_ancestry value in the ::has_tree method.

  class PartGroup
    include Mongoid::Document
    include Mongoid::SleepingKingStudios::HasTree

    has_tree :cache_ancestry => { :relation_name => :assemblies }
  end # class

- _relation\_name_: The name of the generated relation for the array of
  parent objects. Defaults to 'ancestors'.

**Warning:** Using this option will make many write operations much, much
slower and more resource-intensive. Do not use this option outside of
read-heavy applications with very specific requirements, e.g. a directory
structure where you must access all parent directories on each page view.

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

## License

RSpec::SleepingKingStudios is released under the
[MIT License](http://www.opensource.org/licenses/MIT).
