****** ICE 2.41 trap 1 interception routine (ICE DISK)
****** Written by MAC SYS DATA of P.O.V.
******
****** 8/9/91
******
****** P.O. BOX 40
****** THORNTON-CLEVELEYS
****** BLACKPOOL
****** LANCS.
****** FY6 9AZ
******

	opt	o+,ow-,a+		; Optimizer for GENST2
start:	movea.l	#stackend,sp		;make a stack so we can exit
	move.l	sp,d0			;cleanly at end of prog (no bombs)
	subi.l	#start-$120,d0
	move.l	d0,-(sp)
	pea	start-$100(pc)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	adda.w	#$c,sp

	pea	mess			;print a message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	bsr	super
	move.l	$84.w,old_trap1+2	;store & change TRAP #1 vector
	move.l	#my_trap1,$84.w
	move.l	d7,-(sp)
	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	(sp)+,d7
	bsr	user
	pea	null(pc)
	pea	null(pc)
	pea	file_name(pc)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea.l	16(sp),sp
	bsr	super
	move.l	old_trap1+2(pc),$84.w
	bsr	user
	clr.w	-(sp)
	trap	#1

null:	dc.l 0,0

file_name:	dc.b 'main.bas',0	;  Program to run (pexec)
	EVEN 


****** the message, type in your text, this bit will sort it out
****** for LOW REZ only....

mess	dc.b	27,'E'
	dc.b	27,'b',1
 dc.b	27,'Y',32+8,32+((40-(line1end-line1))/2)

** MAX 40 characters per line
line1	dc.b	"SLAYTANIC CULT DEMO 5"
line1end
	dc.b	27,'b',2
 dc.b	27,'Y',32+10,32+((40-(line2end-line2))/2)


line2	dc.b	"Packed by"
line2end
	dc.b	27,'b',3
 dc.b	27,'Y',32+12,32+((40-(line3end-line3))/2)

line3	dc.b	"MAC SYS DATA"
line3end

 dc.b	27,'Y',32+14,32+((40-(line4end-line4))/2)
	dc.b	27,'b',4
line4	dc.b	"19 Oct '91"
line4end

 dc.b	27,'Y',32+17,32+((40-(line5end-line5))/2)
	dc.b	27,'b',4
line5	dc.b	"Simply brilliant!!!"
line5end

	dc.b	0
	even

super	clr.l	-(sp)		;supervisor state
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,d7
	rts	
user	move.l	d7,-(sp)		;user state
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts	

my_trap1
	movea.l	sp,a0
	btst	#$d,(sp)
	bne.s	supervisor
	move.l	usp,a0
	subq.l	#6,a0
supervisor
	addq.l	#6,a0
	cmpi.w	#$3f,(a0) 	; read
	beq.s	func_3f


******** HISOFT BASIC FRIG
	cmpi.w	#$42,(a0)
	bne.s	old_trap1
;frig for seek to end of file (for file length to load)
	cmp.w	#2,8(a0)	;seek to end of file
	bne.s	old_trap1
	move.l	8(a0),puffer
	move.l	2(sp),frig_jmp+2
	move.l	#seek_frig,2(sp)


old_trap1
	jmp	0.l

seek_frig
	move.l	a0,-(sp)
	move.l	length_table_pos,a0
	move.l	(a0)+,d0		;put new length in D0.L
	move.l	a0,length_table_pos
	move.l	(sp)+,a0
frig_jmp
	jmp	0.l

length_table_pos	dc.l	length_table
length_table
	dc.l	$aca	;JARRE.PIC
	dc.l	$bc3b7	;JARRE.EXE
	dc.l	$7d00	;JARRE_01.SPL
;;	dc.l	135480	;JARRE_02.SPL
;;	dc.l	109086	;JARRE_03.SPL


func_3f

************* MASTERSOUND xtra bit ************
;	cmp.l	#4,6(a0)	;is 4 bytes load for MASTERSOUND?
;	beq.s	old_trap1	;YES!

***********************************************


	move.l	8(a0),puffer
	move.l	2(sp),ret_addr5+2	; Returnadresse
	move.l	#read,2(sp)
	bra.s	old_trap1

read:	tst.w	2(sp)
	bmi.s	ret_addr5 	; device handle->do nothing
	movem.l	d1-d7/a0-a6,-(sp)
	movea.l	puffer(pc),a0	; Puffer
	move.w	$ffff8240.w,-(sp)
	bsr	decrunch
	move.w	(sp)+,$ffff8240.w
	movem.l	(sp)+,d1-d7/a0-a6
ret_addr5:	
	jmp	0.l

decrunch
;********************** Unpacking routine of PACK-ICE 2.41 **********
; a0 = Adress of packed data
; "bsr" or "jsr" to ice_decrunch_2 with register a0 to start of data.
ice_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr	.getinfo
	cmpi.l	#'ICE!',d0
	bne	.not_packed
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(sp)
	adda.l	d0,a6
	move.l	a6,a1

	moveq	#119,d0
.save:	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5


	bsr	.get_1_bit
	bcc.s	.no_picture




******* ICE 2.4 has a MASSIVE bug in it which prevents it from
******* saving the packed data when using PIC extension....
*******
******* However you can now use ICE 2.31 with the following code...
*******
	move.w	#$0f9f,d7

**************************************************************
*;;;;	bsr	.get_1_bit	;;removed for ICE 2.31 depack*
*;;;;	bcc.s	.ice_00		;;removed for ICE 2.31 depack*
*;;;;	moveq	#15,d0		;;removed for ICE 2.31 depack*
*;;;;	bsr	.get_d0_bits	;;removed for ICE 2.31 depack*
*;;;;	move.w	d1,d7		;;removed for ICE 2.31 depack*
**************************************************************


.ice_00	moveq	#3,d6
.ice_01	move.w	-(a3),d4
	moveq	#3,d5
.ice_02	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.l	(sp),d0-a3

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo moveq	#3,d1
.getbytes
	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	

.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	


.strings: lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_Åber
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1

.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	move.w	d3,-(sp)
	move.b	(a1),d3
	and.w	#$7,d3
	move.w	d3,$ffff8240.w
	move.w	(sp)+,d3
	dbf	d4,.dep_b
	bra	.normal_bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1

.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

ende_ice_decrunch_2:
;******************************* end of unpacking routine


pal	dc.w	$000,$770,$660,$550,$440,$330,$220,$110
	dc.w	$142,$231,$663,$741,$373,$270,$747,$777

	section	bss
puffer:		ds.l 1
		ds.b 500
stackend: 	ds.b 20

