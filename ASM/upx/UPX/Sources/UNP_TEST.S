
          pea	buffer(pc)
          move   #$1a,-(sp)
          trap   #1
          addq.l #6,sp
          move   #%11001,-(sp)
          pea 	file1(pc)
          move   #$4e,-(sp)
          trap   #1
          addq.l #8,sp
          tst    d0
          bne    exit
more:     
	lea	file1+44-$10(pc),a4
          move.w #0,-(sp)          ;let's save the program
          pea (a4)
          move.w #$3d,-(sp)
          trap #1
          addq.l #8,sp
	  tst.l	d0
	  bmi	not_this
          pea where(pc)
          move.l #$ffffff,-(sp)       ;length of the program
          move.w d0,-(sp)
          move.w #$3f,-(sp)
          move.w d0,d7
          trap #1
          add.l #12,sp
          move.w d7,-(sp)
          move.w #$3e,-(sp)
          trap #1
          addq.l #4,sp
	
	lea	where(pc),a0
	bsr.s	unpack

not_this
          move #$4f,-(sp)
          trap #1
          addq.l #2,sp
          tst d0
          bne exit
          bra more
exit:     clr.l -(sp)              ;exit to Desktop
          trap #1
unpack
	include	upxunpok.s

          SECTION DATA

start2:   ds.l 1
store1:   ds.l 1
	  ds.b	1
bull:     dc.b 11
buffer:   dc.b 44
shit:     dc.b 22
file1:    dc.b '*.*',0 
	  ds.b	100
where


          END

