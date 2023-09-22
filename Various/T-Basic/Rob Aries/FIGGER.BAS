 '************************************
 '  This prog figures out phrase length between two SMPTE frames
 '  it assumes 1) 1st SMPTE # is start of sequence/track (1:1:1)
 '             2) steps/beat=96  3) steps/meas=384  4) tempo=96
 '  space bar for next, any other key goes back to KCS
 '***********************************
    top:
   cls
  ' dialog "Enter 1st SMPTE time:"," ","Hour:  ##","Min:   ##","Sec:   ##","Frame: ##",nul$,nul$,hour$,min$,sec$,frame$
  ' hour.1=val(hour$):min.1=val(min$):sec.1=val(sec$):frame.1=val(frame$)
   hour.1=1:min.1=0:sec.1=0:frame.1=4
   dialog "Enter 2nd SMPTE time:"," ","Hour:  ##","Min:   ##","Sec:   ##","Frame: ##",nul$,nul$,hour$,min$,sec$,frame$
   hour.2=val(hour$):min.2=val(min$):sec.2=val(sec$):frame.2=val(frame$)
   _frame:frame=frame.2-frame.1:if frame<0 then frame.2=frame.2+30:sec.2=sec.2-1:goto _frame
   _second:second=sec.2-sec.1:if second<0 then sec.2=sec.2+60:min.2=min.2-1:goto _second
   _minute:minute=min.2-min.1:if minute<0 then min.2=min.2+60:hour.2=hour.2-1:goto _minute
   hour=hour.2-hour.1
  frames=frame+(second*30)+(minute*1800)+(hour*108000)
   steps=frames*5.12   '  tempo=96
  meas=fix(steps/384):steps=((steps/384)-meas)*384
  if steps<96 then steps=cint(steps):beats=0:goto display
  beats=fix(steps/96):steps=cint(((steps/96)-beats)*96)
  display:print:print "2nd SMPTE time is at MEASURE:";meas+1;"  BEAT:";beats+1;"  STEP:";steps+1
  while not inp(-2):wend:x=inp(2):if x=32 then goto top else command$="run":kcs
