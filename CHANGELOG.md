# Changelog

## 0.7.6

### New Features

* Moved Orderable finders into included/extended modules, so classes including
  the concern can override the finders and use super() to call the originals. 
  Also adds optional scope parameter to finders, which filters the results and
  defaults to base class ::all.

### Resolved Issues

* Add unique relation names for each ordering, fixing some undefined behavior 
  when multiple orderings were defined on the same model.

## 0.7.5

### New Features

* Add #first and #last helpers to Orderable concern.

## 0.7.4

* Remove bson_ext dependency.

## 0.7.3

* Update bson_ext dependency to accept bson_ext 2.0.0 release candidates as 
  required by Mongoid 4.0.0.alpha2.

## 0.7.2

* Update Mongoid dependency to prevent compatibility issues when using Mongoid
  4.0.0.alpha versions with Mongoid::SleepingKingStudios.

## 0.7.1

### New Features

* Add #next and #prev helpers to Orderable concern.

## 0.7.0

### New Features

* Add Orderable concern.

## 0.6.2

* Update dependencies (no user-facing changes).

## 0.6.1

### New Features

* Added #siblings scope to HasTree concern.
