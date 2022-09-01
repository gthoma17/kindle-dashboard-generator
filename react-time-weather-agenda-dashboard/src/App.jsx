import React, { useState, useEffect } from "react";
import groupBy from "lodash/groupBy";
import "./App.css";

import agenda from './agenda';

function App() {  
  const numRows = 15;
  const stepSize = 30 * 60 * 1000; // thirty minutes
  const now = new Date();
  const minMinutes = (Math.floor(now.getMinutes() / 30)) * 30;

  // const min = new Date(new Date(now.setMinutes(minMinutes)).setSeconds(0));
  // const max = new Date(min.getTime() + (stepSize * numRows))


  const min = new Date((new Date(new Date(now.setMinutes(30)).setSeconds(0)).setHours(9))-(1000*60*60*24)+1000*60*60*6);
  const max = new Date(min.getTime() + (stepSize * numRows))

  const eventIsInRange = (event) => (!(max < new Date(event.start) || min > new Date(event.end))) 

  const EventColumn = (className, events, gridColumnStart, gridColumnEnd=null) => {
    gridColumnEnd = gridColumnEnd ? gridColumnEnd : gridColumnStart // if no end column is passed, assume it's one column wide
    return events
      .filter(eventIsInRange)
      .map(event => {
        const start = new Date(event.start);
        const end = new Date(event.end);

        const sizeInSteps = Math.floor((end - start) / stepSize)
        const startsInRange = start >= min
        const endsInRange = end <= max

        const stepsBetweenMinAndStart = (start - min) / stepSize

        const gridRowStart = startsInRange
          ? Math.floor((start - min) / stepSize) + 2
          : 1
        
        const gridRowEnd = endsInRange
          ? Math.floor((end - min) / stepSize) + 2
          : numRows

        return (
          <div className={className} key={`${event.name}-${start}`} style={{ gridRowStart, gridRowEnd, gridColumnStart, gridColumnEnd }}>
            <span className="event-name">{event.name}</span>
            <span className="event-time">{start.toLocaleString("en-US", {timeStyle: "short", timeZone: "America/Denver"})} - {end.toLocaleString("en-US", {timeStyle: "short", timeZone: "America/Denver"})}</span>
          </div>  
        )
    })

  }

  console.log({min, max})

  return (
    <div id="agenda">
      { TimeColumn(numRows, min, stepSize) }
      { EventColumn('reva-event', agenda['reva'], 2) }
      { EventColumn('greg-event', agenda['greg'], 3) }
      { EventColumn('shared-event', agenda['shared'], 2, 4) }
    </div>
  );
}


function TimeColumn(numRows, minTime, stepSize, timeZone){
  const allTimes = [minTime]
  for(let  i=1; i<numRows+1; i++){
    allTimes[i] = new Date(allTimes[i-1].getTime() + stepSize);
  }
  
  return allTimes.map((d) => {
    return (
      <div className="time-column" key={`time-${d.getTime()}`}>
        {d.toLocaleString("en-US", {timeZone, timeStyle: "short"})}
      </div>
    )
  })
}


export default App;