	jmp	main(pc)
save_ints
	move.l	$70.w,oldvbl
	rts
init_ints
	move.l	#vbi,$70.w
	rts
ret_ints
	move.l	oldvbl,$70.w
	rts
main	pea	0			*supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,physbase
	move.l	usp,a0
	move.l	a0,save_usp
	move.l	$44e,scrbase

	move.w	#7,d0
	lea	$ff8240,a0
fixpal	clr.l	(a0)+
	dbra.w	d0,fixpal
	
	jsr	save_ints

	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	move.l	#flashdat,flashcnt
	
	lea	dotdata,a0
	lea	copyspace,a1
	move.w	#3099,d0
copylp1	move.l	(a0)+,(a1)+
	dbra.w	d0,copylp1
	
	jsr	init_ints			*init. interrupts
	clr.w	wfnc
demo_loop	cmp.w	#1,wfnc			*wait for video
	bne	demo_loop
	clr.w	wfnc

	addq.l	#2,flashcnt
	move.l	flashcnt,a0
	cmp.w	#$ffff,(a0)
	bne	nowrap3
	move.l	#flashdat,flashcnt
nochg	move.l	flashcnt,a0
nowrap3	move.w	(a0),$ff8250
	move.w	#$222,$ff8248
	move.w	#$222,$ff8258
	move.w	#$444,$ff8244
	move.w	#$444,$ff8254
	move.w	#$666,$ff8242
	move.w	#$666,$ff8252
	
	jsr	putdotz
	
	jmp	demo_loop
	
*****************************************************

putdotz	move.l	scrbase,d4	;Backup
	lea	dotdata,a0
	add.l	fldcnt,a0
	
	rept	100
	move.l	d4,a1		;Scrbase to a1
	add.w	(a0)+,a1		;Add offset from scrbase
	lea	122(a0),a0
	clr.w	(a1)		;Sudda da pixl
	endr
	

	addq.l	#4,fldcnt
	cmp.l	#23324,fldcnt
	bne	nowrap
	clr.l	fldcnt
nowrap	lea	dotdata,a0
	add.l	fldcnt,a0
	
	rept	100

	move.l	d4,a1		;Scrbase to a1
	add.w	(a0)+,a1		;Add offset from scrbase
	move.w	(a0)+,d0		;Put nibble in d0
	lea	120(a0),a0
	or.w	d0,(a1)		;Put da pixel
	
	endr
	rts
******************************************************************
vbi	movem.l	d0-d5/a0-a1,-(sp)		*save registers
	move.w	#1,wfnc			*set video flag
	movem.l	(sp)+,d0-d5/a0-a1		*pop registers
	rte
******************************************************************
flashcnt
	ds.l	1
flashdat
	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
	dc.w	$600,$500,$400,$300,$200,$100,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$001,$002,$003
	dc.w	$004,$005,$006,$007,$006,$005,$004,$003
	dc.w	$002,$001,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$101,$212,$323,$434,$545,$656,$767
	dc.w	$656,$545,$434,$323,$212,$101,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$010,$121,$232,$343,$454,$565
	dc.w	$676,$777,$676,$565,$454,$343,$232,$121
	dc.w	$010,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$ffff
fldcnt
	ds.l	1
dotdata
	incbin	a:\fildat3.bin
copyspace
	ds.l	3100		;23324 bytes=field-data-copy!
scrbase
	ds.l	1 
save_usp
	dc.l	0
physbase
	ds.l	1
wfnc
	dc.w	0
save_stk
	dc.l	0
oldvbl:
		dc.l	0
