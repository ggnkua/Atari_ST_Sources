*
* copy.s
*
* written nov 85 by Jens-Uwe Mager
*

* offsets in die base-page

prglen    =         $c
datalen   =         $14
bsslen    =         $1c
cmdlin    =         $80

* traps

bios      =         13
xbios     =         14
tos       =         1

* functions

prstrf    =         9
creatf    =         $3c
openf     =         $3d
closef    =         $3e
readf     =         $3f
writef    =         $40
lseekf    =         $42
termf     =         $4c

          .text
main:
          lea       inits,a0
          bsr       prstr
          lea       fname,a0
          bsr       open
          bmi       errxit
          move.w    d0,d7               ;file handle
          bsr       filelen
          bmi       errxit
          lea       buffer,a0
          move.l    a0,-(sp)            ;buffer ad
          add.l     d0,a0
          move.b    #0,(a0)+
          move.l    a0,d1
          btst      #0,d1
          beq       iseven
          addq.l    #1,d1
iseven    move.l    d1,listend
          lea       -256(sp),a1
          sub.l     d1,a1
          move.l    a1,max
          move.l    d0,-(sp)            ;length
          move.w    d7,-(sp)            ;handle
          move.w    #readf,-(sp)
          trap      #tos
          add.l     #12,sp
          tst.l     d0
          bmi       errxit
          move.w    d7,d0
          bsr       close
          bmi       errxit
          lea       buffer,a6
          move.w    (a6),d7             ; contains C:
          bsr       skip
          bcs       exit
          move.l    a5,a6
mainlp:   bsr       skip
          bcs       exit
          bsr       progress
          lea       destname,a0
          bsr       creat
          bmi       errxit
          move.w    d0,d6               ;handle for new file
          move.l    a6,a0
          bsr       open
          bmi       errxit
          move.w    d0,d5               ;handle for old file
copylp:   move.l    listend,-(sp)
          move.l    max,-(sp)
          move.w    d5,-(sp)
          move.w    #readf,-(sp)
          trap      #tos
          add.l     #12,sp
          tst.l     d0
          bmi       errxit
          beq       iseof
          move.l    listend,-(sp)
          move.l    d0,-(sp)
          move.w    d6,-(sp)
          move.w    #writef,-(sp)
          trap      #tos
          add.l     #12,sp
          tst.l     d0
          bmi       errxit
          bra       copylp
iseof:    move.w    d6,d0
          bsr       close
          bmi       errxit
          move.w    d5,d0
          bsr       close
          bmi       errxit
          move.l    a5,a6
          bra       mainlp

exit:
          move.w    #0,-(sp)
          bra.s     xit
errxit:
          move.w    #1,-(sp)
xit:
          move.w    #termf,-(sp)
          trap      #tos

progress:
          lea       mess1,a0
          bsr       prstr
          move.l    a6,a0
          bsr       prstr
          lea       mess2,a0
          bsr       prstr
          lea       destname,a0
          bsr       prstr
          lea       mess3,a0

prstr:
          move.l    a0,-(sp)
          move.w    #prstrf,-(sp)
          trap      #tos
          addq.l    #6,sp
          rts

open:
          clr.w     -(sp)               ;readonly
          move.l    a0,-(sp)
          move.w    #openf,-(sp)
          trap      #tos
          addq.l    #8,sp
          tst.w     d0
          rts

creat:
          clr.w     -(sp)               ;std file r/w
          move.l    a0,-(sp)
          move.w    #creatf,-(sp)
          trap      #tos
          addq.l    #8,sp
          tst.w     d0
          rts

close:
          move.w    d0,-(sp)
          move.w    #closef,-(sp)
          trap      #tos
          addq.l    #4,sp
          tst.w     d0
          rts

filelen:
          move.w    d0,-(sp)
          move.w    #2,-(sp)
          move.w    d0,-(sp)
          clr.l     -(sp)
          move.w    #lseekf,-(sp)
          trap      #tos
          add.l     #10,sp
          move.w    (sp)+,d1
          move.l    d0,-(sp)
          move.w    #0,-(sp)
          move.w    d1,-(sp)
          clr.l     -(sp)
          move.w    #lseekf,-(sp)
          trap      #tos
          add.l     #10,sp
          move.l    (sp)+,d0
          rts
skip0:
          move.l    a5,a6
skip:
          move.l    a6,a5
          lea       destname,a0
          move.w    d7,(a0)+            ;drive
skiplp:   move.b    (a5)+,d0
          beq.s     skipeof
          cmp.b     #13,d0
          beq.s     cr
          move.b    d0,(a0)+
          bra.s     skiplp
cr:       move.b    #0,(a0)+
          move.b    #0,-(a5)
          addq.l    #2,a5
          move.b    destname,d0
          beq       skip0
          rts
skipeof:  or        #1,ccr
          rts

          .data
listend:  dc.l      0
max:      dc.l      0
fname:    dc.b      'file.lst',0
mess1:    dc.b      'Copying ',0
mess2:    dc.b      ' -> ',0
mess3:    dc.b      13,10,0
inits:    dc.b      $1b,'E',0

          .bss
destname: ds.b      128
buffer:   ds        1

          .end
