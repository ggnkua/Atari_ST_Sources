 	lea 	text+128,a0
 	lea	ici,a1
 	move.l	#255,d0
 	
la	moveq	#0,d1
	move.w	(a0)+,d1
	divu	#4,d1
	addq.b	#4,d1
	move.b	d1,(a1)+ 
	
	moveq	#0,d1
	move.w	(a0)+,d1
	divu	#4,d1
	addq.b	#4,d1
	move.b	d1,(a1)+
	
	move.b	#0,(a1)+
	
	moveq	#0,d1
	move.w	(a0)+,d1
	divu	#4,d1
	addq.b	#4,d1
	move.b	d1,(a1)+
	dbf	d0,la
	move.l	#0,ici
 	
 	
 lea 	text+$680,a0
 move.l a0,a5
 move.l a0,a1
 add.l	#640*840,a1
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
 
 lea ici,a0
 move.l a0,a5
 lea ici+1024,a1
 move.l a1,d0
 sub.l a0,d0
 move.l d0,d5
 clr.w -(sp)
 pea filename2
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
 dc.B 'mgt.img',0
	even
filename2:
 dc.B 'mgt.pal',0	
text:
	incbin mgt.tpi

endtext:
ici:
