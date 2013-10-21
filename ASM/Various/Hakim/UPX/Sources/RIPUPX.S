;
;This routine makes an UPX datafile out of
;UPX executable file by stripping of the unpacking
;and relocation routine.
;
;Files are saved in a folder named FILES.UPX
;
;Make sure that you have created this FILES.UPX-folder BEFORE
;running this program.
;
;Also make sure, that you have enough memory to load the files,
;as no memory checking is made.
;
;After completing the work, the program will
;inform about the unpacking routines required to
;unpack UPX datafile(s).
;
;Works ONLY with UPX v.1.24 PC, ST, LINUX, etc. 
;
;DO NOTE: ATM Only NRV2B files are supported with the unpacking
;routine.
;

upx_dir
	pea	file2(pc)
	move.w	#$19,-(sp)
*	trap	#1
	addq.l	#6,a7

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
	lea	where(pc),a6          
	move.w #0,-(sp)          ;let's load a file
	pea (a4)
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
	tst.l	d0
	bmi	not_this
	pea (a6)
	move.l #$ffffff,-(sp)
	move.w d0,-(sp)
	move.w #$3f,-(sp)
	move.w d0,d7
	trap #1
	add.l #12,sp
	move.l	d0,d6
	move.w d7,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp

	lea	file1+44-$10(pc),a4
	lea	extension(pc),a0
	moveq	#12,d0
loopex2
	move.b	(a4)+,(a0)+
	dbf	d0,loopex2
	lea	$b0(a6),a5
	lea	$1F4(a6),a6
	cmp.l	#"UPX!",(a6)
	bne	not_this
	moveq	#0,d0
	move.b	#"!",d0
	move.l	#$7eff7c98,d1	;nrv2B	(!)
	move.l	#$7eff7cb0,d2	;nrv2D	(")
	move.l	#$7e007cb0,d3	;nrv2E	(#)

	st	nrv2B
	cmp.l	(a5),d1		;nrv2B
	beq.s	found_nrv
	st	nrv2D
	addq.l	#1,d0
	cmp.l	(a5),d2		;nrv2D
	beq.s	found_nrv
	st	nrv2E
	addq.l	#1,d0
	cmp.l	(a5),d3		;nrv2E
	bne	not_detected
found_nrv
	move.b	d0,3(a6)	;different routine
no_change
	move.l	$c(a6),a5
	lea	$20(a5),a5

	lea	file2(pc),a4
again		
	move.w #0,-(sp)          ;let's save the program
	pea (a4)
	move.w #$3c,-(sp)
	trap #1
	addq.l #8,sp
	pea	(a6)
	pea	(a5)       ;length of the program again
	move.w d0,-(sp)
	move.w #$40,-(sp)
	move.w d0,d7
	trap #1
	add.l #12,sp
	move.l	a5,d1
	cmp.l	d0,d1
	bne	error
	move.w d7,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	clr.l	(a6)
not_this
	move #$4f,-(sp)
	trap #1
	addq.l #2,sp
	tst d0
	bne exit
	bra more
exit:   
	lea	nrv2B(pc),a6
	lea	nrv_text-17(pc),a5
	moveq	#2,d7
print_loop
	lea	17(a5),a5
	bsr.s	print_text
	dbf	d7,print_loop
	bsr.s	wait

	clr.l -(sp)              ;exit to Desktop
	trap #1
print_text
	tst.b	(a6)+
	beq.s	no_print
	pea	(a5)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
no_print
	rts
wait
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts
nrv_text
	dc.b	"NRV2B detected",$a,$d,0
	dc.b	"NRV2D detected",$a,$d,0
	dc.b	"NRV2E detected",$a,$d,0
	even
not_detected
	illegal
	bra	no_change
error
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,a7
	bra	again

	SECTION DATA

nrv2B	dc.b	0
nrv2D	dc.b	0
nrv2E	dc.b	0
	dc.b	0
file2:
	dc.b	'files.upx\'
extension
	dc.b	0,'2345678.123',0
	even
start2:	ds.l 1
store1:	ds.l 1
	ds.b	1
bull:	dc.b 11
buffer:	dc.b 44
shit:	dc.b 22
file1:	dc.b '*.*',0 
	ds.b	100
where
	dc.w	$601a
	ds.b	$1a
*	incbin	header.dat
here


	END

