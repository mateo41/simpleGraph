require('lib/setup')

Spine = require('spine')
Graph = require('controllers/graph')

class App extends Spine.Controller


  constructor: ->
      super
      console.log "making graph"
      @graph = new Graph { el: $("<div class=\"graph\"></div>")}
      @manager = new Spine.Manager(@graph)
      @graph.active()
      @el.show
      @append @graph
 
module.exports = App
    
