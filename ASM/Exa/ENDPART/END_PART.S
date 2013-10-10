;	aff_text

	jmp	start(pc)
	include		macro&co.s
	include		fal_rez2.s
start

	pea	$200000
	trap	#1

	bsr	init_trap

	asave_video
	asave_screen
	asave_palette
	trap	#3
	

	lea	buffer_ecran(pc),a0
	move.l	a0,d0
	addq.l	#4,d0
	and.b	#$fc,d0
	move.l	d0,ecran	
	move	#384*280/4-1,d0
loop_cls
	clr.l	(a0)+
	dbf	d0,loop_cls
	

 	clr.w	sc
	clr.l	pt_aff

start_scrol
	addq	#1,sc
	cmp.w	#20,sc
	blt.s	.no
	clr.w	sc
	bsr	search_char
.no	cmp	#15,sc
	bgt.s	.no_aft
	bsr	aff_bout
.no_aft
	move.l	pt_aff,d0
	add.l	#384/2,d0
	cmp.l	#(384/2)*280,d0
	bne.S	.no_end_scroll
	clr.l	d0
.no_end_scroll
	move.l	d0,pt_aff
	move.l	ecran,d1
	add.l	#384/2,d1
	add.l	d0,d1
	vsync
	vsync
	aset_nbcoul	#table_col,#$ffff9800,#4
	trap	#3
	clr.l	$fffff9800.w
	aset_screen	d1	
	aset_video	#0
	trap	#3	
	cmp.b	#$39,$fffffc02.w
	bne	start_scrol

	arestore_video
	arestore_screen
	arestore_palette
	trap	#3

	clr.L	-(sp)
	trap	#1

aff_bout
	lea	pbuffer(pc),a0
	move.l	ecran,a1
	add.l	pt_aff,a1
	move.l	a1,a3
	add.l	#(384/2)*280,a3
.rest
	move.l	(a0)+,d0
	ble.s	.no_t	
	cmp.l	#1,d0
	bne.s	.No_sp
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a3)+
	clr.l	(a3)+
	bra.s	.rest
.No_sp
	move.l	d0,a2
	move.l	(a2),(a1)+
	clr.l	(a1)+
	move.l	(a2),(a3)+
	clr.l	(a3)+
	add.l	#20*4,-4(a0)
	bra.s	.rest
.no_t	
	rts


sc	dc.w	0
pt_aff	dc.l	0




	
search_char
	lea	pbuffer(pc),a1
	move.l	p_text(pc),a0
.loop2
	move.b	(a0)+,d0	
	bmi.s	.no_text
	beq.s	.end_line
	moveq	#-1,d2
	lea	list_char(pc),a2
.loop
	move.b	(a2)+,d1
	bmi.s	.no_think
.cont
	addq	#1,d2
	cmp.b	d1,d0
	bne.s	.loop

	lea	fonte+34(pc),a2
	move	d2,d3
	sub	#20,d2
	bmi.s	.no_add_line
	add.l	#20*4*16,a2
	bra.s	.aj
.no_add_line
	move	d3,d2
.aj
	lsl	#2,d2
	add	d2,a2
	move.l	a2,(a1)+
	bra.s	.loop2		
.no_think
	move.l	#1,(a1)+
	bra	.loop2
.end_line
	move.l	a0,p_text
	clr.l	(a1)
	rts
.no_text	
	move.l	o_text(pc),p_text
	move.l	#-1,(a1)
	rts

pbuffer	ds.l	40
o_text	dc.l	text
p_text	dc.l	text
text	
	dc.b	'                      ',0
	DC.B	'WELL,IT IS THE END NOW',0
	DC.B	'EXA TEAM  HOPE YOU DID',0
	DC.B	'ENJOY OUR...EVOLUTION!',0
	DC.B	'                      ',0
	DC.B	'  IT WAS REALISED FOR ',0
	DC.B	'    THE GIGAFUN 95.   ',0
	DC.B	'                      ',0
	DC.B	'SPECIAL HELLOS TO...  ',0
	DC.B	'.EKO                  ',0
	DC.B	'.ADRENALINE AND NLC   ',0
	DC.B	'.SPECULOOS BISCUITS   ',0
	DC.B	'.STEPHANE,SACHA,DAVID ',0
	DC.B	'.ZAPPY AND ELRIC      ',0
	DC.B	'.FRONTIER SOFTWARE    ',0
	DC.B	'.LAST BUT NOT LEAST...',0
	DC.B	' FRIENDS AND PARENTS! ',0
	DC.B	'                      ',0
	DC.B	'  SPECIAL MESSAGE FOR ',0
	DC.B	'       ELENDIL        ',0
	DC.B	'DO YOU LIKE YOUR BRAND',0
	DC.B	'NEW BLUE SUIT IN NAVY?',0
	DC.B	'                      ',0
	DC.B	'WELL,IF               ',0
	DC.B	'       YOU            ',0
	DC.B	'         WANT         ',0
	DC.B	'           TO         ',0
	DC.B	'             CONTACT  ',0
	DC.B	'               US     ',0
	DC.B	'YOU WILL FIND ADRESSES',0
	DC.B	'IN THE TEXTFILE SPREAD',0
	DC.B	'WITH OTHER DEMO FILES.',0
	DC.B	'ALSO READ IT FOR MORE ',0
	DC.B	'INFORMATIONS ABOUT THE',0
	DC.B	'DEMO...               ',0
	DC.B	'                      ',0
	DC.B	'      GOOD BYE !      ',0
	DC.B	'           EXA A.D. 95',0
	DC.B    '                      ',0
	DC.B    '                      ',0
	DC.B    '                      ',0        
        DC.B    '                      ',0
	DC.B    '                      ',0
	DC.B    '                      ',0
	DC.B    '                      ',0
	DC.B    '                      ',0
	DC.B    '                      ',0
	DC.B    '                      ',0
	DC.B    '                      ',0
	dc.b	-1
	even
list_char
	dc.b	'ABCDEFGHIJKLMNOPQRST'
	dc.b	'UVWXYZ!?,.1234567890',-1
	even
table_ste
	dc.b	0<<4,8<<4,1<<4,9<<4,2<<4,10<<4,3<<4,11<<4,4<<4,12<<4,5<<4,13<<4,6<<4,14<<4,7<<4,15<<4
fonte	
	incbin	exafnt.pl2
	even
table_col	dc.l	0,$aaaaaaaa,$55555555,$FfffffFF 
	section	bss
ecran		ds.l	1
buffer_ecran	ds.b	384*240*4
	