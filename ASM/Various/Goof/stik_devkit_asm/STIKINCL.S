*** STIK ASM routs by Goof 1995 (arcovang@caiw.nl)
*** I tried to use as much names from the original C source
*** Thanx to Steve Adam

COOKIEJAR	equ	$000005a0

	section text


*****************************************
* init routine to get pointers etc	*
* should be run in SUPER		*
* return: d0=0  no stik found		*
*         d0=-1 stik found but inactive	*
*	  d0=-2 stik found but maybe 	*
*		corrupted		*
*         d0=any other ok stik active	*
*****************************************
stik_init
	movem.l	d0-d1/a0,-(sp)
	move.l	COOKIEJAR.w,a0		;haal koekdoospijl op
	tst.l	(a0)
	beq	.no_jar_found		;we hebben geen koekjes!
	move.l	#"STiK",d0		;ik wil zo'n koekje, mam?
.zoek_koekie2	
	tst.l	(a0)			;de bodem?
	beq	.no_stik_cookie		;yess
	lea	8(a0),a0
	cmp.l	-8(a0),d0		;stik-koekie?
	bne.s	.zoek_koekie2		;
	move.l	-4(a0),stikpointer	;stikpointer ophalen
	bra	.stik_found              
.no_jar_found
.no_stik_cookie
	clr.l	d0			;Stik not found
.leave_stik_init	
	movem.l	(sp)+,d0-d1/a0
	rts
.acterror
	move.l	#-2,d0
	bra	.leave_stik_init
.stik_found
	tst.l	stikpointer
	bne	.stik_active
	move.l	#-1,d0
	bra	.leave_stik_init
.stik_active
	move.l	stikpointer,a0		;check the magic
	cmp.l	#"STiK",(a0)
	bne	.acterror
	cmp.l	#"magi",4(a0)
	bne	.acterror
	cmp.w	#"c"*256,8(a0)
	bne	.acterror
	move.l	10(a0),drvheader	;pointer to drvheader routine
	move.l	14(a0),etmexec		;pointer to rout?
	move.l	18(a0),stikconfig	;pointer to stikconfig
	move.l	22(a0),tplpointer	;pointer to transport structure
	bra	.leave_stik_init







	section bss
stikpointer	ds.l	1	;pointer from stikcookie
drvheader	ds.l	1	;pointer to drvheader routine
etmexec		ds.l	1	;pointer to routine
stikconfig	ds.l	1	;pointer to stik config struct
tplpointer	ds.l	1	;pointer to transport structure
