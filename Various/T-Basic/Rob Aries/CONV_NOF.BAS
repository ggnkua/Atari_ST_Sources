  '    This program converts note-off's to note-on's with a velocity of 0.
  '    A backup of the original sequence is made.
  '
  clear:cls:gotoxy 24,8:? "Working..."
  currseq=peekl(miscptr+36)+1:events.left=1+(peekl(miscptr+4)-peekl(miscptr))/6
  backup
  for i=1 to lastevent(currseq)
   ifthen type(currseq,i)>127 and type(currseq,i)<144
    type(currseq,i)=type(currseq,i)+16
    vel(currseq,i)=0
   endif
  next
  kcs
  '
  backup:
  if events.left<lastevent(currseq) then a=alert!("No room for backup!|Convert anyway?"," Yes | No ",2):if a=2 then kcs else return
  addevents 35,-lastevent(35)
  addevents 35,lastevent(currseq)
  for i=1 to lastevent(currseq)
   type(35,i)=type(currseq,i)
   time(35,i)=time(currseq,i)
   pitch(35,i)=pitch(currseq,i)
   vel(35,i)=vel(currseq,i)
   dur(35,i)=dur(currseq,i)
  next
  return
