	text
 lea the_bin,a0
 move.l a0,a5
 lea endthe_bin,a1
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
 dc.B 'D:\DEVPAC\SOURCE\COLUMS\COLUMS.HS',0
	even
the_bin:
	REPT 3
	dc.b	'RODOLPHE  ',0,0
	dc.l	40000
	dc.b	'LINDSAY   ',0,0
	dc.l	30000
	dc.b	'PIERRE    ',0,0
	dc.l	20000
	dc.b	'BENOIT    ',0,0
	dc.l	10000
	dc.b	'EMERSON   ',0,0
	dc.l	9000
	dc.b	'LAURENCE  ',0,0
	dc.l	8000
	dc.b	'CHRISTOPHE',0,0
	dc.l	7000
	dc.b	'STEPHANE  ',0,0
	dc.l	6000
	dc.b	'NIRINA    ',0,0
	dc.l	5000
	dc.b	'FABRICE   ',0,0
	dc.l	4000
	ENDR
	
endthe_bin
