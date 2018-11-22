; rockyone			for Mi-3 and MI-9	        16/03/2017							
; 								01.08.2018
;
; Disassembly of DISPC306.bin
;
;
; time  0  Stop by keyboard only
;       >0 Display time
;
;			call spc_play( L buffer_palette,time )
;-------------------------------------------------------------------------

	movem.l	d1-d7/a0-a6,-(sp)

	lea.l	L0006(PC),a5
	move.l	60(sp),(a5)		; Addresse buffer palette

	move.l	$4ce,vbl_list
	move.b	$ffff820a,syncro

	move.b	#2,$ffff820a		; 60 Hz
	lea.l	spectrum(PC),a0		; Display routine 
	move.l	a0,$4CE.w 		; in VBL
;.........................................................................
	move.b	#$12,$fffc02	; disable the mouse

	moveq.l	#0,d0
	move.w	64(sp),d5	; time for slideshow

time:	tst.w	d5	
	beq.s	key

	moveq.l	#48,d7	
wait_v:	move.w	#$25,-(sp)	; Vsync
	trap	#14		; Xbios
	addq.l	#2,sp
	dbra.w	d7,wait_v
		
	subq.w	#1,d5
	beq.s	end_prg
		
key:	move.w	#2,-(sp)	; Device
	move.w	#1,-(sp)	; Bbonstat
	trap	#13		; Bios
	addq.l	#4,sp
	tst.w	d0
	beq.s	time

	move.w	#2,-(sp)	; Device
	move.w	#2,-(sp)	; Bconin
	trap	#13		; Bios
	addq.l	#4,sp

	cmpi.b	#14,d0		; encore la souris!
	bmi.s	time

	btst.b	#6,d0	  	; space barre =%100000 #32
	beq.s	end_t	
	bclr.b	#5,d0	  	; All characters allen uppercase

;.........................................................................
end_t:	move.l	d0,d5
end_prg:	
	move.b	syncro,$ffff820a
	move.l	vbl_list,$4ce
	move.b	#$8,$fffc02		; enable the mouse
	move.l	d5,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts 
;.........................................................................

spectrum:
	move	sr,-(sp)		; Save status register
	ori.w	#$700,sr		; Stop interruptions IPL 7
	lea.l	$FF8240.l,a4		; Palette address
	lea.l	$FF8209.l,a5		; Video pointeur address low
	movea.l	a4,a0 
	movea.l	a4,a1 
	movea.l	a4,a2 
	lea.l	blc(PC),a6		; Nop address
	movea.l	L0006(PC),a3		; Palett address
	move.w	#196,d7 		; 197 lines
	moveq.l	#0,d0 

wait:	tst.b	(a5)			; Waiting screen start
	beq.s	wait 

	move.b	(a5),d0 
	adda.l	d0,a6 
	adda.l	L0005(PC),a6		
	jmp	(a6)

blc:	nop 		;77 nop
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 		;10
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop		;20
 	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop		;30
 	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop		;40
 	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 		
	nop 		;50
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 		;60
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 		;70
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
;				; 48 coulors per line
color_line:	
	nop 		;77
	movea.l	a4,a0 			
	movea.l	a4,a1 
	move.l	a4,a2 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+
 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	nop 
	dbra.w	d7,color_line
;....................................... Before last line
	movea.l	a4,a0 			
	movea.l	a4,a1 
	move.l	a4,a2 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+
 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 

;....................................... Last line	
	movea.l	a4,a0 
	movea.l	a4,a1 
	movea.l	a4,a2 
	lea.l	-19040(a3),a4 
	nop 
	nop 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move	(sp)+,SR	; restors the status register 

spc_fin:	rts

;---------------------------------------------------- 

L0005:		dc.l	0 
L0006:		dc.l	0
vbl_list:	dc.l	0
syncro:		dc.b	0
;-------------------------------------------------------------------------

	end

;-------------------------------------------------------------------------
