       <div style="text-align: center">
            <canvas id="bar1" width="480" height="300">[No canvas support]</canvas>
      
            <div id="timeSelect" class="ui-grid-d">
				<div class="ui-block-a"> <input id="yearInput" type="radio" name="time" value="Year" checked > Year </div>
				<div class="ui-block-b"> <input id="monthInput" type="radio" name="time" value="Month"> Month </div>
				<div class="ui-block-c" ><input id="weekInput" type="radio" name="time" value="Week"> Week </div>
				<div class="ui-block-d"> <input id="dayInput" type="radio" name="time" value ="Day"> Day </div>
				<div class="ui-block-d">
				<img src="/images/2arrow_left.png" id="leftButton"/>
				{{dateString}}
				<img src="/images/2arrow_right.png" id="rightButton"/>
				</div>
            </div>
       </div>
