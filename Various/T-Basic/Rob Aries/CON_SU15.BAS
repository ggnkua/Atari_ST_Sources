  '  CONV_SUS.BAS  by Rob Aries  10/21/90  revised 11/6/90
  '
  clear:currseq=peekl(miscptr+36)+1
  if currseq>128 and currseq<177 then desig$="track" else desig$="sequence":if currseq>176 then alert!"You can't do this in song mode!":goto endit
  def fnsus(o,y)=type(currseq,y)>175 and type(currseq,y)<192 and pitch(currseq,y)=64 and vel(currseq,y)=o
  def fnotes(i)=type(currseq,i)>143 and type(currseq,i)<160 and vel(currseq,i)>0
  events.left=((peekl(miscptr+4)-peekl(miscptr))/6)+1
  on error goto error.handler
 cls: draw_menu: titlebar 2, "  CONVERT SUSTAINS  "
 main_loop: menu input m$
   if m$ = "  Do it!" then goto start
   if m$ = "  Fix overlaps " then gotoxy 24,8:fix.overlaps
   if m$ = "  To KCS" goto endit
   if m$ = "  Quit" then end
 goto main_loop
 '
 DRAW_MENU:
 menu "  Convert  |  Do it!|  Fix overlaps |  To KCS|  Quit"
 return
  start:option base 1:dim notes%(40,4):rangeflag=peek(peekl(miscptr+16))
  if rangeflag=1 then a=alert!("CONV_SUS.BAS operates    |on the entire "+desig$+".","Keep going|   Abort  ",2):if a=2 then endit
  suson.count=0:for i=1 to lastevent(currseq):if fnsus(127,i) then suson.count=suson.count+1
  next
  if suson.count=0 then alert!"  No sustain pedal events!  ":goto endit
  if desig$="track" then seqnum=130:max=176 else seqnum=1:max=128
  backup seqnum,max;seqnum:if seqnum=0 then a=alert.(" No free "+desig$+" for | backing up. ","Keep going|   Abort  ",2):if a=2 then endit
  if lastevent(currseq)>events.left-lastevent(currseq) and seqnum <> 0 then a=alert.("  Not enough free memory to |  make a backup "+desig$+".","Keep going|   Abort  ",2):if a=2 then endit
  if lastevent(currseq)<events.left-lastevent(currseq) and seqnum<>0 then gotoxy 24,7:print "Making backup...":gosub make.backup:events.left=events.left-lastevent(currseq)
  '
  gotoxy 24,8:print "Processing ";desig$;" ";mki$(peek(peekl(miscptr+28)));"..."
  '
  figure.it 1,time(currseq,1),127;sus.on.1,event.no
  toti=0:index=0:i=1
  do.again:figure.it event.no,sus.on.1,0;sus.off,event.no
  figure.it event.no,sus.off,127;sus.on.2,event.no
  suson.count=suson.count-1
  if index>0 then x=1:while index<>0:ifthen notes%(x,2)+notes%(x,3)<sus.on.2 and index<>0:stretch notes%(x,1),notes%(x,2),notes%(x,3),notes%(x,4):clearkew:endif:if x<>index then x=x+1:wend
  '
  while i<>lastevent(currseq):toti=toti+time(currseq,i)
  if fnotes(i) and toti<=sus.off gosub get.dur i,toti;_dur,eve:gosub stretch i,toti,_dur,eve
  if fnsus(0,i) and suson.count>0 then sus.on.1=sus.on.2:i=i+1:goto do.again
  i=i+1:wend
  fix.overlaps
  endit:command$="run":kcs
  '
  figure.it:procedure ii,tyme,on.off;tyme,ii:while not (fnsus(on.off,ii) or ii=lastevent(currseq)):ii=ii+1:tyme=tyme+time(currseq,ii):if ii=lastevent(currseq) then return else wend:return
  '
   stretch:procedure event,tyym,_dur,eve:ifthen tyym>sus.on.1 or tyym+_dur>sus.on.1
  if tyym+_dur>sus.on.2 then gosub markit:return
  if tyym+_dur>sus.off then return
  if dur(currseq,event)=0 then type(currseq,eve)=0
  if sus.off-tyym>999 then _dur=0:target=tyym+(sus.off-tyym):noteoff else _dur=sus.off-tyym
  dur(currseq,event)=_dur:endif:return
  '
  markit:index=index+1:if index=41 then alert! " Not enough room in | note array! ":end else notes%(index,1)=event:notes%(index,2)=tyym:notes%(index,3)=_dur:notes%(index,4)=eve:return
  '
  clearkew:ifthen x<index:for y=x to index-1:notes%(y,1)=notes%(y+1,1):notes%(y,2)=notes%(y+1,2):notes%(y,3)=notes%(y+1,3):notes%(y,4)=notes%(y+1,4):next:endif:index=index-1:x=x-1:return
  '
 NOTEOFF: locals ev
 makevent dummy;ev    'insert an event
 type(currseq,ev)=type(currseq,event)-16
 pitch(currseq,ev)=pitch(currseq,event)
 vel(currseq,ev)=0
 return
 '
 INSEVENT:locals e
 addevents currseq,1
 for e=lastevent(currseq)-1 to ev step -1
  type(currseq,e+1)=type(currseq,e)
  time(currseq,e+1)=time(currseq,e)
  pitch(currseq,e+1)=pitch(currseq,e)
  vel(currseq,e+1)=vel(currseq,e)
  dur(currseq,e+1)=dur(currseq,e)
 next
 event.no=event.no+1:events.left=events.left-1:return
 '
 MAKEVENT: procedure dummy;ev: locals totit,oldtoti
 totit=0
 for ev=1 to lastevent(currseq)
  oldtoti=totit
  totit=totit+time(currseq,ev)
  if totit>target then MAKEVENT.1
 next
 oldtoti=totit
 '
 MAKEVENT.1:
 '
 insevent
 time(currseq,ev)=target-oldtoti
 if lastevent(currseq)<>ev then time(currseq,ev+1)=time(currseq,ev+1)-time(currseq,ev)
 return
   '
 SET_SEQNAME: procedure seq$,seq: locals index
    while len(seq$) < 8: seq$ = seq$+" ":wend
    for index = 1 to 8
        pokeb fileptr+1719+seq*8+index,asc(mid$(seq$,index,1))
    next
    return
  '
  Backup: procedure seqnum,max;seqnum
 while lastevent(seqnum) and seqnum <=max
  seqnum = seqnum+1
 wend
 if seqnum > max then seqnum=0
 return
  '
  make.backup:
  addevents(seqnum),lastevent(currseq)
  for i=1 to lastevent(currseq)
    type(seqnum,i)=type(currseq,i)
    time(seqnum,i)=time(currseq,i)
    pitch(seqnum,i)=pitch(currseq,i)
    vel(seqnum,i)=vel(currseq,i)
    dur(seqnum,i)=dur(currseq,i)
  next
  if desig$="track" then gosub mute seqnum-129:seqnumber=currseq-128 else seqnumber=currseq
  seq$="BAK "+str$(seqnumber):set_seqname seq$,seqnum
  return
  '
  mute:procedure seq:pokeb fileptr+1664+seq,1:return
  '
  get.dur: procedure evnt,ti;_dur,off:locals event:if dur(currseq,evnt)>0 then _dur=dur(currseq,evnt):return
  first.t=ti:event=evnt
  looper:evnt=evnt+1:ti=ti+time(currseq,evnt):if type(currseq,evnt)+16=type(currseq,event) then goto _off
  ifthen type(currseq,evnt)=type(currseq,event)
    ifthen pitch(currseq,evnt)=pitch(currseq,event)
     if vel(currseq,evnt)=0 then goto fig_dur
    endif
  endif
  goto looper
  '
  _off:if pitch(currseq,evnt)<>pitch(currseq,event) or ti-first.t<1000 then looper
  '
  fig_dur: _dur=ti-first.t:off=evnt
  return
  '
  fix.overlaps:if m$="  Fix overlaps " then a=alert.("  This "+desig$+" was previously  |  converted, correct?  "," Yes | No ",2):if a=2 then return
  print tab(25);"Fixing overlaps..."
  toti=0:for event=1 to lastevent(currseq):toti=toti+time(currseq,event):ifthen fnotes(event)
  get.dur event,toti;_dur,note.off :
   targ=toti+_dur:search event,toti,targ:endif:next:goto cleanup
   search:procedure ev,tim,targ
  while tim<=targ:ev=ev+1:tim=tim+time(currseq,ev):if fnotes(ev) and pitch(currseq,ev)=pitch(currseq,event) then set.dur
  wend:return
  set.dur:_dur=tim-toti-1:if _dur<1000 then dur(currseq,event)=_dur else type(currseq,note.off)=0:target=toti+_dur:gosub noteoff
  return
  '
  cleanup:
  print tab(25);"Cleaning up..."
  i=1:totalcount=0:tim=0
  top:
  ifthen totalcount>0
   if i+totalcount<lastevent(currseq) then gosub find i+totalcount;dummy
    gosub move.up i,i+totalcount
    time(currseq,i)=time(currseq,i+totalcount)+tim
    ifthen i+totalcount=lastevent(currseq):addevents currseq,-totalcount
    print tab(25);"Done!":timer=0:while timer<1:wend:goto endit:endif
    tim=0
  endif
  gosub find i+totalcount;counter
  ifthen counter>0
    gosub move.up i,i+counter
    time(currseq,i)=time(currseq,i+counter)+tim
   tim=0
  endif
  i=i+1:goto top
  '
  find:procedure first;cnt
  gosub checkit first;flag
  while flag>0
    tim=tim+time(currseq,first+cnt)
    cnt=cnt+1:checkit first+cnt;flag
  wend
    totalcount=totalcount+cnt
  return
  '
  move.up:procedure event,count:type(currseq,event)=type(currseq,count):pitch(currseq,event)=pitch(currseq,count):vel(currseq,event)=vel(currseq,count):dur(currseq,event)=dur(currseq,count):return
 '
  checkit:procedure event;flag
  flag=0
  if type(currseq,event)=0 and event<>lastevent(currseq) then flag=2:return
  if type(currseq,event)>175 and type(currseq,event)<192 and pitch(currseq,event)=64 then flag=1:return
  return
  '
  error.handler:er$=str$(err):erl$=str$(erl):alert!" Error #"+er$+" at line "+erl$+" | Program ending...":end
  '
