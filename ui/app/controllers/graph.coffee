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
        '#dayInput'   : 'dayBox'
        '#leftButton' : 'leftButton'
        '#rightButton': 'rightButton'
         

    events:
        'click #timeSelect' : 'click_quantum'
        'click #leftButton' : 'click_left'
        'click #rightButton': 'click_right'     
          
    constructor: ->
        super
        console.log "In Graph constructor"
        console.log @year_labels
        @state = 
            year:2012
            week:1
            quantum: 'W'
            
    makeDateString: =>
        switch @state.quantum
            when 'Y'
                @state.year
            when 'M'
                [@state.month,@state.year].join()
            when 'W'
                tmpDate = Date.parse("1/1/"+@state.year)
                tmpDate.addWeeks(@state.week-1)
                tmpDate.format("mmm,dd")
            when 'D'
                tmpDate = Date.parse("1/1/"+@state.year)
                tmpDate.addDays(@state.day-1)
                tmpDate.format("mmm,dd,yyyy")
                        
    makeUrl: =>
        console.log @state
        switch @state.quantum
            when 'Y'
                ["/api/1.0/year/", @state.year].join("")
            when 'M'
                ["/api/1.0/year/", @state.year, "/month/", @state.month].join("")
            when 'W'
                ["/api/1.0/year/", @state.year, "/week/", @state.week].join("")
            when 'D'
                ["/api/1.0/year/", @state.year, "/day/", @state.day].join("")             
    
    updateView: =>
        console.log @state.quantum
        switch @state.quantum
            when 'Y'
                @yearBox.attr("checked", "checked")
            when 'M'
                @monthBox.attr("checked", "checked")
            when 'W'
                @weekBox.attr("checked", "checked")
            when 'D'
                @dayBox.attr("checked", "checked")
                
    render: =>
        console.log "In render" 
        $.mustache.load("graph", "/graph.mu").done (template) =>
            @dateString = @makeDateString()
            console.log @dateString
            @html $.mustache(template, @)
            
            @updateView()
            url = @makeUrl()
            @doRest(url)
        
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
    
    stateTransition: (old, new) =>
        
        switch new
            when "Y"
                @state.quantum = "Y"
            
            when "M"
                switch old
                when "Y"
                    @state.month = 1
                when "M"
                     console.log "do nothing"
                when "W"
                     tmpDate = Date.parse("1/1/"+@state.year)
                     tmpDate.addWeeks(@state.week-1)
                     @state.month = tmpDate.getMonth()+1
                when "D"
                     tmpDate = Date.parse("1/1/"+@state.year)
                     tmpDate.addDays(@state.day-1)
                     @state.month = tmpDate.getMonth()+1
            when "W"
            
            when "D"
            
    click_quantum: (event) =>
        console.log "Clicked Radio button"
        box = $('input:checked')
        time = box.attr("value")
        quantum = time[0]
        stateTransition(@state.quantum, quantum)
        
    click_left: (event) =>
        switch @state.quantum
            when "Y" 
                @state.year = @state.year-1
            when "M"
                @state.month = @state.month-1
            when "W" 
                @state.week = @state.week-1
            when "D" 
                @state.day = @state.day-1
        @render()
         
    click_right: (event) =>
        console.log "in click right"
        switch @state.quantum
            when "Y" 
                @state.year = @state.year+1
            when "M"
                @state.month = @state.month+1
            when "W" 
                @state.week = @state.week+1
            when "D" 
                @state.day = @state.day+1
        @render()        
                
    click_event: (event, bar) =>
        console.log "In click event"
        console.log bar[5]
        index = bar[5] + 1 
        switch @state.quantum
            when "Y" 
                @state.quantum = 'M'
                @state.month = index
            when "M"
                console.log "Can't drill down" 
            when "W" 
                @state.quantum = 'D'
                tmpDate = Date.parse("1/1/"+@state.year)
                tmpDate.addWeeks(@state.week-1)
                tmpDate.addDays(index)
                @state.day = tmpDate.getDayOfYear()
            when "D" 
                console.log "Can't drill down" 
            else
                console.log "Unhandled"
        @render()    
                                         
module.exports = Graph           
