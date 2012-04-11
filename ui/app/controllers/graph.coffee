Spine = require('spine')

class Graph extends Spine.Controller
    className: "graph"
    
    @year_labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    @week_labels = ['Sun','Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    @hour_labels = ['1am', '4am', '7am','10am','1pm','4pm','7pm','10pm']
    
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
        'click #yearInput' : 'click_quantum_year'
        'click #monthInput' : 'click_quantum_month'
        'click #weekInput' : 'click_quantum_week'
        'click #dayInput' : 'click_quantum_day'
        'click #leftButton' : 'click_left'
        'click #rightButton': 'click_right'
        'swiperight #bar1'  : 'swipe_right'
        'swipeleft #bar1'   : 'swipe_left'     
          
    constructor: ->
        super
        console.log "In Graph constructor"
        console.log @year_labels
        start = Date.parse("1/1/2012")
        @state = 
            date : start
            quantum: 'W'
            
    makeDateString: =>
        switch @state.quantum
            when 'Y'
                @state.date.getFullYear()
            when 'M'
                @state.date.format("mmm,yyyy")
            when 'W'
                tmpDate = @state.date.clone()
                tmpDate.addWeeks(1)
                @state.date.format("mmm dd")+"--"+tmpDate.format("mmmdd,yyyy")
            when 'D'
                @state.date.format("mmm dd,yyyy")
                        
    makeUrl: =>
        console.log @state
        switch @state.quantum
            when 'Y'
                ["/api/1.0/year/", @state.date.getFullYear()].join("")
            when 'M'
                ["/api/1.0/year/", @state.date.getFullYear(), "/month/", @state.date.getMonth()+1].join("")
            when 'W'
                ["/api/1.0/year/", @state.date.getFullYear(), "/week/", @state.date.getWeekOfYear()].join("")
            when 'D'
                ["/api/1.0/year/", @state.date.getFullYear(), "/day/", @state.date.getDayOfYear()+1].join("")             
    
    updateView: =>
        console.log @state.quantum
        #switch @state.quantum
        #    when 'Y'
        #        @yearBox.attr("checked", "checked")
        #    when 'M'
        #        @monthBox.attr("checked", "checked")
        #    when 'W'
        #        @weekBox.attr("checked", "checked")
        #    when 'D'
        #        @dayBox.attr("checked", "checked")
                
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
        state = @state
        dateString = @makeDateString()
        $.ajax( url: url,
            type: "GET",
            contentType: "application/json" 
        ).done((result, status, xhr) ->
            console.log "In done"
            console.log result
            data = (v for k,v of result)
            console.log data.length
            @bar = new RGraph.Bar('bar1', data)
            @bar.Set('chart.gutter.left', 65)
            @bar.Set('chart.title', dateString+' Energy Usage')
            @bar.Set('chart.title.yaxis', 'Watt hours')
            @bar.Set('chart.title.yaxis.pos', .08)
            @bar.Set('chart.gutter.bottom', 40)
            @bar.Set('chart.colors', ('0099ff' for i in [1..data.length]))
            if state.quantum is 'Y' 
                @bar.Set('chart.labels', Graph.year_labels)
            if state.quantum is 'W'
                @bar.Set('chart.labels', Graph.week_labels)
                @bar.Set('chart.colors', ['0033cc','0099ff' , '0099ff','0099ff', '0099ff', '0099ff','0033cc'])
                @bar.Set('chart.colors.sequential', true)
            if state.quantum is 'M'
                f = ( month, year ) ->
                    d = new Date(month+",1 "+year)
                    numDays = d.getDaysInMonth()
                    f2 = (s) ->
                        d = new Date(s)
                        #wd = d.isWeekday()
                        color = if d.isWeekday() then '0099ff' else '0033cc'
                        color
                    dates = (f2(month+","+day+" "+year) for day in [1..numDays])
                days = f(state.date.getMonthName(), state.date.getFullYear())
                @bar.Set('chart.colors', days )
                @bar.Set('chart.colors.sequential', true) 
                @bar.Set('chart.labels', [1..data.length])
                @bar.Set('chart.text.angle', 90)
            if state.quantum is 'D'
                @bar.Set('chart.labels', Graph.hour_labels)
                @bar.Set('chart.text.angle', 90)
                @bar.Set('chart.labels.specific.align', 'left')
                     
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
            
    click_quantum_year: (event) =>
        console.log "clicked year button"
        quantum = 'Y'
        dayInYear = @state.date.getDayOfYear()
        @state.date.addDays(-dayInYear)
        @state.quantum = 'Y'
        @render()

    click_quantum_month: (event) =>
    	console.log "clicked month button"
    	console.log "test"
    	dayInMonth = @state.date.getDate()
    	@state.date.addDays(-(dayInMonth-1))
    	@state.quantum = 'M'
    	@render()
          
    click_quantum_week: (event) =>
    	console.log "clicked week button"
    	@state.quantum = 'W'
    	@render()
    
    click_quantum_day: (event) =>
        console.log "clicked day button"
        @state.quantum = 'D'
        @render()
        	
    shift_dates: (amount) => 
        switch @state.quantum
            when "Y" 
                @state.date.addYears(amount)
            when "M"
                @state.date.addMonths(amount)
            when "W" 
                @state.date.addWeeks(amount)
            when "D" 
                @state.date.addDays(amount)
                    
    click_left: (event) =>
        @shift_dates(-1)
        @render()
         
    click_right: (event) =>
        @shift_dates(1)
        @render()        
                
    click_event: (event, bar) =>
        console.log "In click event"
        console.log bar[5]
        index = bar[5] 
        switch @state.quantum
            when "Y" 
                @state.quantum = 'M'
                @state.date.addMonths(index)
            when "M"
                @state.quantum = 'D'
                @state.date.addDays(index)
            when "W" 
                @state.quantum = 'D'
                @state.date.addDays(index)
            when "D" 
                console.log "Can't drill down" 
            else
                console.log "Unhandled"
        @render()    
     
    swipe_right: (event) =>
        console.log event
        console.log "in swipe_right"
        @shift_dates(-1)
        @render()
        
    swipe_left: (event) =>
        console.log event
        console.log "in swipe_left"
        @shift_dates(1)
        @render()
                                             
module.exports = Graph           
