 start:
 smpt=0:mbs=0  '  may not be needed eventually
 menu " Quit | To KCS | To Basic "," Calculate | Smpte | Meas-Bt-St | Set start"
 titlebar 2,"** KCS Smptecalc v1.0 by Rob Aries **"
 cls
  '
 gotoxy 2,2:print "SMPTE start time:"
 print.start :
  '
 main_loop:menu input m$
  if m$="  Desktop Info... " then alert "KCS Smptecalc v1.0   |   by Rob Aries"
  if m$=" To KCS " then command$="goto start":kcs
  if m$=" To Basic " then end
  if m$=" Smpte " then smpt=-1:clear.display:smpte:smpt=0
  if m$=" Meas-Bt-St " then mbs=-1:meas.bt.st:mbs=0
  if m$=" Set start" gosub ask.start:print.start
 goto main_loop
  '
 meas.bt.st:
  if lastevent(129)=0 then alert!"No events in track 1.":return
  dialog "   Calculate meas/beat/step for SMPTE time:   "," ","               Hour:  ##","               Min:   ##","               Sec:   ##","               Frame: ##","               Bit:   ##",nul$,nul$,hr$,min$,sec$,fr$,bt$
  hur=val(hr$):meen=val(min$):sek=val(sec$):frem=val(fr$):beet=val(bt$)
  ifthen (hur>23 or meen>59 or sek>59 or frem>29 or beet>79)
   kosher :if but=1 goto meas.bt.st else return
  endif
  init.parms
  get.steps 0,0,0;toti
 return
  '
 ask.start:
  old.hr=hr:old.min=min:old.sec=sec:old.fr=fr:old.bt=bt
  again:
  gotoxy 53,8:print "Enter an illegal number"
  print tab(55);"to abort!"
  dialog "  Enter start time:  "," ","  Hour: ##","  Min:  ##","  Sec:  ##","  Frame:##","  Bit:  ##",nul$,nul$,hr$,min$,sec$,fr$,bit$
  hr=val(hr$):min=val(min$):sec=val(sec$):fr=val(fr$):bt=val(bit$)
  ' print hr,min,sec,fr,bit
  ifthen (hr>23 or min>59 or sec>59 or fr>29 or bt>79)
    clearit :kosher:ifthen but=1:goto again
     else
    hr=old.hr:min=old.min:sec=old.sec:fr=old.fr:bt=old.bt
    endif
  endif
  clearit
 return
  '
 clearit:gotoxy 53,8:print space$(23):print tab(55);space$(9):return
  '
 IEEE.FLOAT: procedure ieee!;float!:locals ex,man!
  ex=peek(varptr(ieee!))\128
  man!=(peek(varptr(ieee!)) and 127)*2^16+peek(varptr(ieee!)+2)
  man!=man!+2^23
  float!=man!*2^(ex-150)
  float!=fix(float!*10)/10
 return
  '
 kosher:but=alert?("Something ain't kosher...","Again|Abort",0):return
  '
 smpte:
  if lastevent(129)=0 then alert!"No events in track 1.":return
  dialog " Calculate SMPTE time for: "," "," Measure: ____"," Beat:     ___"," Step:    ____",nul$,nul$,meas$,beat$,step$
  meas=val(meas$):beat=val(beat$):step=val(step$)
  init.parms
  if step>=steps.beat gosub kosher:if but=1 goto smpte else return
  '  ifthen beat=0:beat=1:endif:if step=0 then step=1
  '  if meas=0 then meas=1
  ifthen meas<0 or beat<0 or step<0
    neg.steps
  else
    ifthen beat=0:beat=1:endif:if step=0 then step=1
    if meas=0 then meas=1
  endif
 '   if meas=0 and not (beat<0 or step<0) then meas=1
 '   if meas=1 and (beat<=1 and step<=1) then meas=0
 ' if beat<0 then beat=beat+1    '   ????
 ' if step<0 then step=step+1    '   ????
  gotoxy 2,20:? space$(30)
  '  gotoxy 2,20:print "FINAL FIGURES:";meas,beat,step
  steps=get.steps[meas,beat,step]
  ifthen seconds>59 or seconds<-59
   min$=str$(fix(seconds/60)):secs$=str$((seconds/60-fix(seconds/60))*60)
   _time$=str$(fix(seconds/60))+" minute(s),"+str$(((seconds/60)-fix(seconds/60))*60)+" second(s)"
  else
   _time$=str$(seconds)+" second(s)"
  endif
  gotoxy 2,4:print "Steps from beginning of track=";steps:gotoxy 2:print "Time from beginning of track= "+_time$
  time.conv :add.smpte hr,min,sec,fr,bt
  gotoxy 2
  ifthen meas<0 or beat<=0 or step<=0
    print "New SMPTE start time to add";abs(meas);" measures,";abs(beat);" beats,";abs(step);" steps is:"
  else 
    print "SMPTE time for measure";meas;", beat";beat;", step";step;" is:"
  endif
  print:gotoxy 1:print hour;":";minute;":";_seconds;":";frame;".";bit
 return
  '
 get.steps:procedure meas,beat,step;toti
  _time=0:tot.meas=0:toti=0:seconds=0:carry=0:_beat=0:_step=0
  for i=1 to lastevent(129)
    old.meas=tot.meas:old.beat=_beat:old.step=_step
    old.secs=seconds:old.toti=toti
    _time=_time+time(129,i):toti=toti+time(129,i)
    abs.time
    _meas=int(_time/steps.meas):_step=_time-(_meas*steps.meas)
    ifthen _step>=steps.beat
       _beat=int(_step/steps.beat):_step=_step-(_beat*steps.beat)
    else
       _beat=0
    endif
    _beat=_beat+1:_step=_step+1:_meas=_meas+1
    tot.meas=_meas+carry
   '  print "Tot.meas:";tot.meas,"Meas:";_meas
   '
    ifthen smpt
     if tot.meas>meas or (tot.meas=meas and ((_beat*steps.beat)+_step)>=((beat*steps.beat)+step)) gosub hit:return
    endif
  '
    ifthen mbs
     time.conv :add.smpte hr,min,sec,fr,bt
     ifthen hour>=hur
      ifthen minute>=meen
       ifthen _seconds>=sek
        ifthen frame>=frem
         ifthen bit>=beet
          gosub hit.2:return
         endif
        endif
       endif
      endif
     endif
    endif
  '
    if type(129,i)=5 gosub stepsmeas:_time=0:carry=tot.meas-1
    if type(129,i)=4 gosub tempo
  '  print "Event #";i;" is at";tot.meas,_beat,_step
  '  print "Time to event #";i;" is";seconds;" seconds"
  '  print "toti=";toti
  next
  i=i-1
  old.meas=tot.meas:old.beat=beat:old.step=step
  toti=toti+time(129,i)
  hit
 return
  '
 hit.2:
   print hour,minute,_seconds,frame,bit
   add.smpte -hur,-meen,-sek,-frem,-beet
   print hour,minute,_seconds,frame,bit
   toti=toti-(hour*_tempo*steps.beat*60)-(minute*_tempo*steps.beat)
   toti=toti-(_seconds*(_tempo*steps.beat/60))
   steps.frame=(_tempo*steps.beat/60)/30:steps.bit=steps.frame/80
   toti=toti-(frame*steps.frame)-(bit*steps.bit)
   print toti
 return
  '
 stepsmeas:steps.meas=(vel(129,i)*256)+dur(129,i):return
  '
 tempo:_tempo=((vel(129,i)*256)+dur(129,i))/10:return
  '
 hit:
   ifthen old.meas=0:old.meas=1:endif:ifthen old.beat=0:old.beat=1:endif
   if old.step=0 then old.step=1
  '  gotoxy 2,12:print space$(90)
  '  gotoxy 1,12:print old.meas,old.toti,old.secs,toti,meas,beat,step,seconds,time(129,i),old.beat,old.step
   ifthen meas>=0 and beat>=0 and step>=0
    toti=(toti-time(129,i))+((meas-old.meas)*steps.meas)+((beat-old.beat)*steps.beat)+step-old.step
   else
    toti=(meas*steps.meas)+((beat)*steps.beat)+step
  endif
  '  gotoxy 2,14:print space$(20):gotoxy 2,14:print "toti now";toti
   seconds=old.secs+((toti-old.toti)/(_tempo/60*steps.beat))
 return
  '
 neg.steps:
  i=1
  while time(129,i)=0
   ifthen type(129,i)=5
     but=alert.("Use SM setting from track 1| or KCS environment page?","Trk. 1|Env.",1)
     if but=1 gosub stepsmeas
   endif
   if type(129,i)=4 gosub tempo
   i=i+1
  wend
 return
  '
 abs.time:
   seconds=seconds+(time(129,i)/(_tempo/60*steps.beat))
 return
  '
 init.parms:
   poke varptr(_tempo!),peek(envptr+24)
   poke varptr(_tempo!)+2,peek(envptr+26)
   _tempo!=ieee.float[_tempo!]
   steps.meas=peek(envptr+16):steps.beat=peek(envptr+28)
 return
  '
 time.conv:
   hour=int(seconds/3600)
   if hour=0 then minit
   seconds=seconds-(hour*3600)
   minit:
   minute=int(seconds/60)
   if minute=0 then secinds
   seconds=seconds-(minute*60)
   secinds:
   _seconds=int(seconds)
   remain=seconds-_seconds
   frame=int(remain*30)
   remain=(remain*30)-frame
   _bit=remain*80:bit=int(remain*80):if _bit-bit>.5 then bit=bit+1
  '  print "Hour:";hour,"Minute:";minute,"Second:";_seconds,"Frame:";frame,"Bit:";bit
 return
  '
 add.smpte:procedure _hr,_min,_sec,_fr,_bt
   ' print _hr,_min,_sec,_fr,_bt
   '  print hour,minute,_seconds,frame,bit
   bit=bit+_bt
   if bit>79 then bit=bit-80:_fr=_fr+1
   if bit<0 then bit=bit+80:_fr=_fr-1
   frame=frame+_fr
   if frame>29 then frame=frame-30:_sec=_sec+1
   if frame<0 then frame=frame+30:_sec=_sec-1
   _seconds=_seconds+_sec
   if _seconds>59 then _seconds=_seconds-60:_min=_min+1
   if _seconds<0 then _seconds=_seconds+60:_min=_min-1
   minute=minute+_min
   if minute>59 then minute=minute-60:_hr=_hr+1
   if minute<0 then minute=minute+60:_hr=_hr-1
   hour=hour+_hr
   if hour>23 then hour=hour-24
   if hour<0 then hour=hour+24
 return
  '
 print.start:
   gotoxy 20,2:print space$(19)
   gotoxy 20,2: print hr;":";min;":";sec;":";fr;".";bt
 return
  '
 clear.display:locals i
   for i=4 to 8
    gotoxy 2,i:print space$(64)
   next i
 return
  '
