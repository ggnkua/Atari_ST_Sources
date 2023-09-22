 '  All Tracks to All Sequences, by Rob Aries
  '
   cls:clear
   titlebar 2,"  All Tracks to sequences  "
   events.left=((peekl(miscptr+4)-peekl(miscptr))/6)+1
   x=alert("  Include muted tracks?  |"," Yes | No | Quit ",2):if x=3 then end
   for i=129 to 176
     ifthen lastevent(i)>0
       ifthen x=1 or (peekb(fileptr+i+1535)<>1 and x=2)
         freeseq dummy;seq_num
         if seq_num=0 then alert!"No more free sequences!":goto endit
         events.left=events.left-lastevent(i):if events.left<100 then alert!"No more room!":goto endit
         get_seqname i;seq$:set_seqname seq$,seq_num,i-128
         addevents seq_num,lastevent(i)
         gotoxy 10,10:? "Bouncing track";i-128
        for e=1 to lastevent(i)
          type(seq_num,e)=type(i,e)
          time(seq_num,e)=time(i,e)
          pitch(seq_num,e)=pitch(i,e)
          vel(seq_num,e)=vel(i,e)
          dur(seq_num,e)=dur(i,e)
        next
      endif
    endif
  next
  endit:command$="run":kcs
  '
 GET_SEQNAME: procedure seq;seq$:locals index
 seq$ = ""
 for index = 0 to 7
  seq$ = seq$+chr$(peekb(fileptr+1720+seq*8+index))
 next
 return
 '
 SET_SEQNAME: procedure seq$,seq,trk: locals index
 trk$=str$(trk):com$="from Track"+trk$
 if trk=1 then com$=com$+" (conductor)"
 for index = 1 to len(seq$)
  pokeb fileptr+1719+seq*8+index,asc(mid$(seq$,index,1))
 next
 for index=1 to len(com$)
  pokeb fileptr+3073+seq*30+index,asc(mid$(com$,index,1))
 next
 return
 '
 FREESEQ: procedure dummy; seq_num
 seq_num = 1
 top:while lastevent(seq_num) and seq_num <=128
  seq_num = seq_num+1
 wend
 if seq_num=34 then seq_num=36:goto top
 if seq_num > 128 then seq_num = 0
 return
