// Generated by CoffeeScript 1.4.0
(function() {

  define(['underscore', 'backbone', 'bifocal/models/regiontype'], function(_, Backbone, RegionType) {
    var RegionTypes;
    RegionTypes = Backbone.Collection.extend({
      model: RegionType
    });
    return RegionTypes;
  });

}).call(this);
