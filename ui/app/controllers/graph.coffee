Spine = require('spine')

class Graph extends Spine.Controller
    className: "graph"
    
    @year_labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    
    elements:
        '#button' : 'button'
        '#bar1' : 'bar'
        '#timeSelect' : 'timeSelect'
        '#yearInput'  : 'yearBox' 
        '#monthInput' : 'monthBox' 
        '#weekInput'  : 'weekBox' 
        '#yearInput'  : 'dayBox' 

    events:
        "click #timeSelect" : 'click_time'     
          
    constructor: ->
        super
        console.log "In Graph constructor"
        console.log @year_labels
        @graphType = "year"
        @year = 2011
        
    render: =>
        console.log "In render" 
        $.mustache.load("graph", "/graph.mu").done (template) =>
            console.log $.mustache template
            @html $.mustache(template, @)

        @doRest("/api/1.0/year/2011/")
        
    doRest: (url) =>
        click_event = @click_event
        
        $.ajax( url: url,
            type: "GET",
            contentType: "application/json" 
        ).done((result, status, xhr) ->
            console.log "In done"
            console.log result
            data = (v for k,v of result)
            console.log data.length
            @bar = new RGraph.Bar('bar1', data)
            @bar.Set('chart.gutter.left', 55)
            #@bar.Set('chart.labels', Graph.year_labels)
            @bar.Set('chart.events.click', click_event ) 
            RGraph.Effects.Bar.Grow(@bar)
            
        ).fail((xhr, status, error) ->
            console.log "In fail"
            console.log status
            console.log error
            console.log xhr
        )          
         
    activate: =>
        console.log "In graph.activate"
        @render()
        @el.addClass('active')
        @
    
    click_box: (event) =>
        console.log "Clicked Radio button"
        box = $('input:checked')
        console.log(box.attr("value"))
        time = box.attr("value")
    
    click_event: (event, bar) =>
        console.log "In click event"
        console.log bar[5]
        index = bar[5] + 1
        console.log @graphType 
        switch @graphType
            when "year" 
                @graphType ="month"
                @monthBox.attr("checked", "checked")
                @doRest(["/api/1.0/year/", @year, "/month/", index].join(""))
            when "month"
                console.log "Can't drill down" 
            when "week" 
                @graphType = "day"
                @dayBox.attr("checked", "checked")
                @doRest(["/api/1.0/year/", @year, "/day/", 200].join(""))  
            when "day" 
                console.log "Can't drill down" 
            else
                console.log "Unhandled"
                                         
module.exports = Graph           
