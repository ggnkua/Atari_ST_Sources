
COOKIEJAR	equ	$000005a0

	SECTION	TEXT

****************************************
* init routine to get pointers etc		*
* should be run in SUPER					*
* return: d0=0  no stik found				*
*         d0=-1 stik found but inactive*
*	  d0=-2 stik found but maybe 			*
*		corrupted								*
*	  d0=-3 transport layer not found	*
*        d0=1 ok stik (transport layer)*
*			  found.								*
****************************************
stik_init
	move.l	COOKIEJAR.w,a0
	tst.l		(a0)
	beq.s		.no_jar_found
	move.l	#"STiK",d0
.zoek_koekie2	
	tst.l		(a0)
	beq.s		.no_stik_cookie
	lea		8(a0),a0
	cmp.l		-8(a0),d0
	bne.s		.zoek_koekie2
	move.l	-4(a0),stikpointer	;stikpointer ophalen
	bra.s		.stik_found              
.no_jar_found
.no_stik_cookie
	clr.l		d0							;Stik not found
.leave_stik_init	
	move.l	d0,stik_status
	rts

.acterror
	move.l	#-2,d0
	bra.s		.leave_stik_init

.stik_found
	tst.l		stikpointer
	bne.s		.stik_active
	move.l	#-1,d0
	bra.s		.leave_stik_init

.stik_active
	move.l	stikpointer,a0			;check the magic
	cmp.l		#"STiK",(a0)
	bne.s		.acterror
	cmp.l		#"magi",4(a0)
	bne.s		.acterror
	cmp.w		#"c"*256,8(a0)
	bne.s		.acterror

	move.l	10(a0),drvheader	;pointer to drvheader routine
	move.l	14(a0),etmexec		;pointer to exec stik module routine
	move.l	18(a0),stikconfig	;pointer to stikconfig
	move.l	22(a0),stikbasepage	;pointer to stik basepage

	move.l	10(a0),a0			;find transport layer module
	pea		TRANSPORT_DRIVER
	jsr	(a0)
	lea		4(sp),sp
	move.l	d0,tplpointer		;pointer to transport structure

	tst.l		tplpointer
	beq.s		.tplnotfound

	moveq		#1,d0	
	bra.s		.leave_stik_init

.tplnotfound
	move.l	#-3,d0
	bra.s		.leave_stik_init

	SECTION	BSS

stik_status	ds.l	1

stikpointer		ds.l	1	;pointer from stikcookie
drvheader		ds.l	1	;pointer to drvheader routine
etmexec			ds.l	1	;pointer to etm_exec routine
stikconfig		ds.l	1	;pointer to stik config struct
tplpointer		ds.l	1	;pointer to transport structure
stikbasepage	ds.l	1	;pointer to stik basepage

	SECTION	TEXT
