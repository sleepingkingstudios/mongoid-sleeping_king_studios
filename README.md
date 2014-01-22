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

      # This creates the #assemblies method and #assembly_ids field.
      has_tree :cache_ancestry => { :relation_name => :assemblies }
    end # class

- *foreign\_key*: The name of the field used to store the ancestor references.
  Defaults to 'ancestor_ids'.
- *relation\_name*: The name of the generated relation for the array of
  parent objects. Defaults to 'ancestors'.

**Warning:** Using this option will make many write operations much, much
slower and more resource-intensive. Do not use this option outside of
read-heavy applications with very specific requirements, e.g. a directory
structure where you must access all parent directories on each page view.

### Orderable

    require 'mongoid/sleeping_king_studios/orderable'

Adds a field that tracks the index of each record with respect to the provided
sort order parameters.

**How To Use:**

    class OrderedDocument
      include Mongoid::Document
      include Mongoid::SleepingKingStudios::Orderable

      cache_ordering :created_at.desc, :as => :most_recent_order
    end # class

The ::cache_ordering method accepts a subset of the params for an Origin
\#order_by query operation, e.g.:

- :first_field.desc, :second_field
- { :first_field => -1, :second_field => :asc }
- [[:first_field, :desc], [:second_field, 1]]

#### Helpers

Creating an ordering cache also creates the following helpers. The name of the
generated helpers will depend on the sort params provided, or the name given 
via the :as option (see below). For example, providing :as => 
:alphabetical_order will generate helpers \#next_alphabetical, 
\#prev_alphabetical, and ::reorder_alphabetical!.

##### \#first_ordering_name

Finds the first document, based on the stored ordering values.

##### \#last_ordering_name

Finds the last document, based on the stored ordering values.

##### \#next_ordering_name

Finds the next document, based on the stored ordering values.

##### \#prev_ordering_name

Finds the previous document, based on the stored ordering values.

##### ::reorder_ordering_name!

(Class Method) Loops through the collection and sets each item's field to the 
appropriate ordered index. Normally, this is handled on item save, but this 
helper allows a bulk update of the collection when adding the concern to an 
existing model, or if data corruption or other issues have broken the existing 
values.

#### Options

##### As

    cache_ordering sort_params, :as => :named_order

Sets the name of the generated order field and helpers. If no name is 
specified, one will be automatically generated of the form 
first_field_desc_second_field_asc_order.

##### Filter

    cache_ordering sort_params, :filter => { :published => true }

Restricts which records from the collection will be sorted to generate the
ordering values. If a record is filtered out, its ordering field will be set 
to nil.

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

Allows the slug to be specified manually. Adds an additional #slug_lock field
that is automatically set to true when #slug= is called. To resume tracking the
base attribute, set :slug_lock to false.

## License

Mongoid::SleepingKingStudios is released under the
[MIT License](http://www.opensource.org/licenses/MIT).
