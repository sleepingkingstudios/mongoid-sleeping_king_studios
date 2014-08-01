# Roadmap

The following updates are planned to be implemented in the near future:

## HasTree

* Refactor concern name to BelongsToTree.
* Finish implementing support for using a custom field to determine the
  ancestry identifiers, such as a title or slug.

## Sluggable

* Refactor concern method from ::slugify to ::generates_slug.
* Add :as option to support custom slug field names, e.g.

    generates_slug, :full_name, :as => :short_name

* Rename helper methods using slug field name, e.g. #to_short_name.
* Support multiple slug fields per model.
