import agenda from './agenda/agenda';

const numRows = 15;
const stepSize = 30 * 60 * 1000; // thirty minutes
const timeFormat = {timeStyle: "short", timeZone: "America/Denver"}

function App() {  
  
  const now = new Date();
  const minMinutes = (Math.floor(now.getMinutes() / 30)) * 30;

  const min = new Date(new Date(now.setMinutes(minMinutes)).setSeconds(0));
  const max = new Date(min.getTime() + (stepSize * numRows))

  const eventIsInRange = (event) => (!(max < new Date(event.start)  || min > new Date(event.end)))

  const filteredAgenda = {
    greg: agenda['greg'].filter(eventIsInRange),
    reva: agenda['reva'].filter(eventIsInRange),
    shared: agenda['shared'].filter(eventIsInRange)
  }


  console.log("~~~ rendering agenda with these inputs ~~~", {min, max, agenda})
  console.log("min: "+min.toLocaleString('en-US', {timeStyle: "short", dateStyle: "short", timeZone: "America/Denver"}))
  console.log("max: "+max.toLocaleString('en-US', {timeStyle: "short", dateStyle: "short", timeZone: "America/Denver"}))
  console.log("Reva Events: "+JSON.stringify(filteredAgenda['reva']))
  console.log("Greg Events: "+JSON.stringify(filteredAgenda['greg']))
  console.log("Sared Events: "+JSON.stringify(filteredAgenda['shared']))

  const EventColumn = (className, events) => {
    const getStartRow = (event) => new Date(event.start) >= min
      ? Math.floor((new Date(event.start) - min) / stepSize) + 2
      : 2

    const getEndRow = (event) => new Date(event.end) <= max
      ? Math.floor((new Date(event.end) - min) / stepSize) + 2
      : numRows
    return events
      .map(event => {
        const style = {
          gridRowStart: getStartRow(event),
          gridRowEnd: getEndRow(event)
        }
        const start = new Date(event.start).toLocaleString("en-US", timeFormat)
        const end = new Date(event.end).toLocaleString("en-US", timeFormat)
        return (
          <div className={className} key={`${event.name}-${event.start}`} style={style}>
            <span className="event-name">{event.name}</span>
            <span className="event-time">{start} - {end}</span>
          </div>  
        )
    })

  }

  return (
    <div id="agenda">
      <div className="agenda-header style={{gridColumn: 1, gridRow: 1}}"><span>Time</span></div>
      <div className="agenda-header" style={{gridColumn: 2, gridRow: 1}}><span>Reva</span></div>
      <div className="agenda-header" style={{gridColumn: 3, gridRow: 1}}><span>Greg</span></div>
      { TimeColumn(numRows, min, stepSize) }
      { EventColumn('reva-event', filteredAgenda['reva'], 2) }
      { EventColumn('greg-event', filteredAgenda['greg'], 3) }
      { EventColumn('shared-event', filteredAgenda['shared'], 2, 4) }
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
        {d.toLocaleString("en-US", timeFormat)}
      </div>
    )
  })
}


export default App;