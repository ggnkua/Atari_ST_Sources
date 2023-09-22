100  '  converts track names consisting of only pitch strings to
110  '  midi note numbers
120  '
130 cls
140    for i=130 to 176
150      ifthen lastevent(i)
160        get_seqname i;name$
170        let name$=left$(name$,3)
180       strp name$;note_no
190       let name$="Note#"+str$(note_no)
200       set_seqname name$,i
210     endif
220   next
230  end
240  '
250  '
260 SET_SEQNAME: procedure seq$,seq: locals index
270 '
280 ' ** This routine sets the name of a sequence **
290 '
300 if seq < 1 or seq > 192 then return
310 ifthen seq < 177 ' tracks and sequences
320    while len(seq$) < 8: seq$ = seq$+" ":wend
330    for index = 1 to 8
340        pokeb fileptr+1719+seq*8+index,asc(mid$(seq$,index,1))
350    next
360    return
370 endif
380 seq = seq-177
390 while len(seq$) < 60: seq$ = seq$+" ": wend
400 for index = 1 to 60
410    pokeb fileptr+7375+seq*60+index,asc(mid$(seq$,index,1))
420 next
430 return
440  '
450 STRP: procedure pit$;pit: locals note,oct
460 ' Convert a pitch string to a MIDI note number
470 '
480 note=instr("C D EF G A B",left$(pit$,1))
490 '
500 if note=0 then note=instr("c d ef g a b",left$(pit$,1))
510 if instr(pit$,"#") then note=note+1
520 oct=instr("0123456789",right$(pit$,1))-1
530 if instr(pit$,"-") then oct=-oct
540 pit=oct*12+note+11
550 return
560 '
570'
580'
590 GET_SEQNAME: procedure seq;seq$:locals index
600 '
610 ' ** This routine returns the name of a sequence **
620 '
630 seq$ = ""
640 if seq < 1 or seq > 192 then return
650 ifthen seq < 177
660    for index = 0 to 7
670       seq$ = seq$+chr$(peekb(fileptr+1720+seq*8+index))
680    next
690    return
700 endif
710 seq = seq-177
720 for index = 0 to 59
730    seq$ = seq$+chr$(peekb(fileptr+7376+seq*60))
740 next
750 return
