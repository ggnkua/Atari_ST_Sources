
 lea text,a0
 move.l a0,a5
 lea endtext,a1
 move.l a1,d0
 sub.l a0,d0
 move.l d0,d5
 clr.w -(sp)
 pea filename
 move.W #$3c,-(sp)
 trap #1
 add.l #8,sp
 move.w d0,d3
 move.l a5,-(sp)
 move.l d5,-(sp)
 move.w d3,-(sp)
 move.w #$40,-(sp)
 trap #1
 add.l #12,sp
 move.w d3,-(sp)
 move.w #$3e,-(sp)
 trap #1
 addq.l #4,sp
 clr.w -(sp)
 trap #1 
filename:
 dc.B 'd:\delirous.3\ball1.z',0
	even
text:
	include c:\dessin\copyb1

endtext

