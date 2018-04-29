;
;	CPU utilisation tester for SNDH files
;
;	gwEm 2005, 2006
;

		section	text
;................................................................
main:		move.l  4(sp),a5                ; address to basepage

		move.l	a5,d0			; basepage address
		add.l	#129,d0			; offset to commandline
		move.l	d0,filename

        	move.l  $0c(a5),d0              ; length of text segment
        	add.l   $14(a5),d0              ; length of data segment
		add.l   $1c(a5),d0              ; length of bss segment
        	add.l   #$1000,d0               ; length of stackpointer
		add.l   #$100,d0                ; length of basepage
		move.l  a5,d1                   ; address to basepage
		add.l   d0,d1                   ; end of program
		and.l   #-2,d1                  ; make address even
		move.l  d1,sp                   ; new stackspace

		move.l  d0,-(sp)                ; mshrink()
		move.l  a5,-(sp)                ;
		move.w  d0,-(sp)                ;
		move.w  #$4a,-(sp)              ;
		trap    #1                  	;
		lea 	12(sp),sp               ;  

		bsr	isit_snd
		bcc	fileerror

.file_is_snd:	move.w	#$2f,-(sp)		;fgetdta() save old dta address
		trap	#1			;
		addq.l	#2,sp			;
		move.l	d0,olddta		;

		move.l	#dta,-(sp)		;fsetdta() set new dta buffer
		move.w	#$1a,-(sp)		;
		trap	#1			;
		addq.l	#6,sp

		move.w	#0,-(sp)		;get file size
                move.l  filename(pc),-(sp)
		move.w	#$4E,-(sp)
		trap	#1			;FS_FIRST
		addq.l	#8,sp
		tst.l	d0			;Error?
		bmi	fileerror		;if negative then error
		move.l	dta+26(pc),filesize	;store filesize

		move.l	filesize(pc),-(sp)	;MAlloc the buffer needed to hold this file
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,filebuffer		;Start address of buffer
		beq	fileerror

                move.w  #0,-(SP)		;read only access
                move.l  filename(pc),-(sp)
                move.w  #$3d,-(SP)           	;OPEN file
                trap    #1
                addq.l  #8,SP
                move.w  D0,filehandle					
                bmi     fileerror		;if some kind of error exit

		move.l  filebuffer(pc),-(sp)	;READ file
		move.l	filesize(pc),-(sp)
		move.w	filehandle(pc),-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp
		tst.l	d0
		bmi     fileerror

		move.w  filehandle(pc),-(SP)
                move.w  #$3e,-(SP)		;CLOSE file
                trap    #1
                addq.l  #4,sp

;.................
		move.l	filebuffer(pc),a0
		cmpi.l	#'ICE!',(a0)
		bne.s	.unpacked

.packed		move.l	8(a0),d1		;d1 = unpacked length

		movem.l	d1-d2/a0-a2,-(sp)
		move.l	d1,-(sp)		;malloc the buffer needed to hold unpacked data
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d1-d2/a0-a2

		move.l	d0,sndhpoint		; assume its allocates ok								;a0 = packed
		move.l	d0,a1			; a0 = source, a1 = destination
		bsr	ice_decrunch
		bra.s	.common

.unpacked	move.l	a0,sndhpoint

;.................
.common		move.l	sndhpoint(pc),a0	; check for sndh tag
		cmpi.l	#"SNDH",12(a0)
		bne	fileerror

		bsr	getsndhfreq
		bsr	getsndhsubtunes

		move.l	#0,-(sp)		; supervisor mode
		move.w	#$20,-(sp)		;
		trap	#1			;
		addq.l	#6,sp			;
		move.l	d0,oldusp		; store old user stack pointer

		move.b	#$12,$fffffc02.w	; turn off mouse

		lea	initstring1(pc),a0
		bsr	printstring
		lea	tagfreq(pc),a0
		bsr	printstring
		lea	initstring2(pc),a0
		bsr	printstring
		lea	tagsubtunes(pc),a0
		bsr	printstring
		lea	initstring3(pc),a0
		bsr	printstring

		;move.l	$fffffa06.w,oldmfp	; store old MFP interrupt enables
		;clr.l	$fffffa06.w		; kill all MFP interrupts
		move.l	$70.w,oldvbl		; store old VBL vector
		move.l	$114.w,oldtimerc	: store old timerC vector

		move.l	#dummyvbl,$70.w		; steal VBL
		move.w	#$2500,sr		; vbl off

		move.l	#timerc_start,$114.w
		bset	#5,$fffffa09.w		; enable timer c

;.................
		move.w	#$fffffc02,a0
		move.b	(a0),d1			; wait for a key
.waitkey_start	addq.l	#1,currentcount
		cmp.b	(a0),d1
		beq.s	.waitkey_start
		
		move.l	previouscount(pc),noloadcount
		move.b	$fffffc02.w,d0
		andi.l	#$FF,d0
		beq.s	.subtunezero
		subq.b	#1,d0
		beq.s	.subtunezero
		
		cmp.w	sndhsubtunes(pc),d0
		bls.s	.waitup_start
		
		move.w	sndhsubtunes(pc),d0
		bra.s	.waitup_start

.subtunezero	moveq	#1,d0		

.waitup_start	tst.b	$fffffc02.w		; wait for key lift
		bge.s	.waitup_start

		lea	stopstring(pc),a0

		move.l	d0,d1
		divu	#10,d1
		add.l	#$00300030,d1
		move.b	d1,33(a0)
		swap	d1
		move.b	d1,34(a0)

		bsr	printstring

		lea	infotext(pc),a0
		bsr	printstring

		lea	mfpsave(pc),a1
		move.b	$FFFFFA19.w,(a1)+
		move.b	$FFFFFA1B.w,(a1)+
		move.b	$FFFFFA17.w,(a1)+
		move.b	$FFFFFA13.w,(a1)+
		move.b	$FFFFFA15.w,(a1)+
		move.b	$FFFFFA07.w,(a1)+
		move.b	$FFFFFA09.w,(a1)+
		move.b	$FFFFFA1F.w,(a1)+
		move.b	$FFFFFA25.w,(a1)+
		move.b	$FFFFFA21.w,(a1)+

		lea	vecsave(pc),a1
		move.l	$110.w,(a1)+				;d
		move.l	$134.w,(a1)+				;a
		move.l	$120.w,(a1)+				;b
		move.l	$8.w,(a1)+				; Bus error (for Falcon!)
		move.l	$C.w,(a1)+				; Address error - MM2
		move.l	$14.w,(a1)+				; Zero Divide
		move.l	$20.w,(a1)+				; Privilege Violation

		moveq	#7,d1
		lea.l	$60.w,a0				; Spurious IRQ + Autovecs (Timer)...
.sav_autov:	move.l	(a0)+,(a1)+
		dbra	d1,.sav_autov
				
		move.l	sndhpoint(pc),a0
		;moveq	#1,d0
		jsr	(a0)					; init music, d0 holds sub-tune
		move.l	noloadcount(pc),currentcount		; init routine should not affect results
		move.l	#timerc,$114.w

;.................
		move.w	#$fffffc02,a0
		;move.b	(a0),d1				; wait for space
		moveq	#$39,d1
.waitkey_end	addq.l	#1,currentcount
		cmp.b	(a0),d1
		bne.s	.waitkey_end

		move.l	sndhpoint(pc),a0
		jsr	4(a0)			; de-init music
		move.l	oldtimerc,$114.w	; restore timer C vector

.waitup_end	tst.b	$fffffc02.w		; wait for key lift
		bge.s	.waitup_end

		move.l	#$08000000,$ffff8800.w	; turn off YM
		move.l	#$09000000,$ffff8800.w	;
		move.l	#$0A000000,$ffff8800.w	;

		lea	mfpsave(pc),a1			
		move.b	(a1)+,$FFFFFA19.w
		move.b	(a1)+,$FFFFFA1B.w
		move.b	(a1)+,$FFFFFA17.w
		move.b	(a1)+,$FFFFFA13.w
		move.b	(a1)+,$FFFFFA15.w
		move.b	(a1)+,$FFFFFA07.w
		move.b	(a1)+,$FFFFFA09.w
		move.b	(a1)+,$FFFFFA1F.w
		move.b	(a1)+,$FFFFFA25.w
		move.b	(a1)+,$FFFFFA21.w

		lea	vecsave(pc),a1
		move.l	(a1)+,$110.w		;d
		move.l	(a1)+,$134.w		;a
		move.l	(a1)+,$120.w		;b
		move.l	(a1)+,$8.w		; Bus error (for Falcon!)
		move.l	(a1)+,$C.w		; Address error - MM2
		move.l	(a1)+,$14.w		; Zero Divide
		move.l	(a1)+,$20.w		; Privilege Violation

		moveq	#7,d0
		lea.l	$60.w,a0		; Spurious IRQ + Autovecs (Timer)...
.load_autov:	move.l	(a1)+,(a0)+
		dbra	d0,.load_autov

		;move.l	oldmfp(pc),$fffffa06.w	; restore MFP interrupts
		move.l	oldvbl(pc),$70.w	; restore VBL vector

		move.b	#$8,$fffffc02.w		; turn on mouse

		move.w	#$2300,sr		; vbl on

		move.l	oldusp(pc),-(sp)	; user mode
		move.w	#$20,-(sp)		;
		trap	#1			;
		addq.l	#6,sp			;

		move.l	sndhpoint(pc),-(sp)	; free the SNDH buffer
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp

		move.l	filebuffer(pc),-(sp)	; free the filebuffer
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp

		move.l	olddta(pc),-(sp)	; fsetdta()
		move.w	#$1a,-(sp)		; restore dta
		trap	#1			;
		addq.l	#6,sp			;

		move.w  #0,-(sp)                ; pterm()
		move.w	#$4c,-(sp)		;
		trap    #1      		;


fileerror:	lea	errorstring(pc),a0
		bsr	printstring

		move.l	filename(pc),a0
		bsr	printstring

		move.w	#7,-(sp)		; wait for a key
		trap	#1			;
		addq.l	#2,sp			;

		move.l	sndhpoint(pc),-(sp)	; free the SNDH buffer
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp

		move.l	filebuffer(pc),-(sp)	; free the filebuffer
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp

		move.l	olddta(pc),-(sp)	; fsetdta()
		move.w	#$1a,-(sp)		; restore dta
		trap	#1			;
		addq.l	#6,sp			;

		move.w  #0,-(sp)                ; pterm()
		move.w	#$4c,-(sp)		;
		trap    #1      		;


;................................................................
printstring:	movem.l	d0-d2/a0-a2,-(sp)	; print string in a0
		move.l	a0,-(sp)
		move.w	#$9,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d0-d2/a0-a2
		rts

;................................................................
dummyvbl:      	rte				; dont call system vbl


timerc_start:	move.l	d0,-(sp)
		subq.w	#1,.countcount
		bne.s	.end

		addq.w	#4,.countcount
		move.l	currentcount(pc),d0
		cmp.l	previouscount(pc),d0	; ensure count is highest possible with no load
		blo.s	.endcount
		move.l	d0,previouscount
.endcount	move.l	#0,currentcount

.end		move.l	(sp)+,d0
		bclr	#5,$fffffa11.w		; interrupt serviced
		rte
.countcount	dc.w	4


timerc:		movem.l	d0-d1/a0,-(sp)
		move.w	sr,-(sp)		; store status word - system friendly, but not needed in a demo i guess
		move.w	#$2500,sr		; enable timers
		
		move.w	sndhfreq(pc),d0
		sub.w	d0,.tccount		; you can use any replay rate here less than or equal to 200Hz
		bgt.s	.nomsx			; dont call zak this time
		add.w	#200,.tccount		; syntheses any freq from 200hz system tick

		move.l	sndhpoint(pc),a0
		not.b	$ffff8240.w
		jsr	8(a0)			; call music
		not.b	$ffff8240.w
	
.nomsx		subq.w	#2,.printcount
		bne.s	.count

.print		add.w	#200,.printcount
		move.l	noloadcount(pc),d1
		move.l	previouscount(pc),d0
		move.l	#$FFFFFFFF,previouscount
		move.l	d1,currentcount		; ensure print routine does not affect results
		sub.l	d1,d0
		neg.l	d0
		mulu	#100,d0
		divu	d1,d0
		add.w	d0,d0
		add.w	d0,d0
		lea	percent2str(pc,d0.w),a0
		bsr	printstring
		bra.s	.end

.count		subq.w	#1,.countcount
		bne.s	.end
		addq.w	#4,.countcount
		move.l	currentcount(pc),d0
		cmp.l	previouscount(pc),d0	; ensure count is worstcase
		bhi.s	.endcount
		move.l	d0,previouscount
.endcount	move.l	#0,currentcount

.end		move.w	(sp)+,sr		; restore status word
		movem.l	(sp)+,d0-d1/a0
		bclr	#5,$fffffa11.w		; interrupt serviced
		rte
.countcount	dc.w	4
.printcount	dc.w	200
.tccount:	dc.w	200


percent2str:	dc.b	" 0",$D,0
		dc.b	" 1",$D,0
		dc.b	" 2",$D,0
		dc.b	" 3",$D,0
		dc.b	" 4",$D,0
		dc.b	" 5",$D,0
		dc.b	" 6",$D,0
		dc.b	" 7",$D,0
		dc.b	" 8",$D,0
		dc.b	" 9",$D,0
		dc.b	"10",$D,0
		dc.b	"11",$D,0
		dc.b	"12",$D,0
		dc.b	"13",$D,0
		dc.b	"14",$D,0
		dc.b	"15",$D,0
		dc.b	"16",$D,0
		dc.b	"17",$D,0
		dc.b	"18",$D,0
		dc.b	"19",$D,0
		dc.b	"20",$D,0
		dc.b	"21",$D,0
		dc.b	"22",$D,0
		dc.b	"23",$D,0
		dc.b	"24",$D,0
		dc.b	"25",$D,0
		dc.b	"26",$D,0
		dc.b	"27",$D,0
		dc.b	"28",$D,0
		dc.b	"29",$D,0
		dc.b	"30",$D,0
		dc.b	"31",$D,0
		dc.b	"32",$D,0
		dc.b	"33",$D,0
		dc.b	"34",$D,0
		dc.b	"35",$D,0
		dc.b	"36",$D,0
		dc.b	"37",$D,0
		dc.b	"38",$D,0
		dc.b	"39",$D,0
		dc.b	"40",$D,0
		dc.b	"41",$D,0
		dc.b	"42",$D,0
		dc.b	"43",$D,0
		dc.b	"44",$D,0
		dc.b	"45",$D,0
		dc.b	"46",$D,0
		dc.b	"47",$D,0
		dc.b	"48",$D,0
		dc.b	"49",$D,0
		dc.b	"50",$D,0
		dc.b	"51",$D,0
		dc.b	"52",$D,0
		dc.b	"53",$D,0
		dc.b	"54",$D,0
		dc.b	"55",$D,0
		dc.b	"56",$D,0
		dc.b	"57",$D,0
		dc.b	"58",$D,0
		dc.b	"59",$D,0
		dc.b	"60",$D,0
		dc.b	"61",$D,0
		dc.b	"62",$D,0
		dc.b	"63",$D,0
		dc.b	"64",$D,0
		dc.b	"65",$D,0
		dc.b	"66",$D,0
		dc.b	"67",$D,0
		dc.b	"68",$D,0
		dc.b	"69",$D,0
		dc.b	"70",$D,0
		dc.b	"71",$D,0
		dc.b	"72",$D,0
		dc.b	"73",$D,0
		dc.b	"74",$D,0
		dc.b	"75",$D,0
		dc.b	"76",$D,0
		dc.b	"77",$D,0
		dc.b	"78",$D,0
		dc.b	"79",$D,0
		dc.b	"80",$D,0
		dc.b	"81",$D,0
		dc.b	"82",$D,0
		dc.b	"83",$D,0
		dc.b	"84",$D,0
		dc.b	"85",$D,0
		dc.b	"86",$D,0
		dc.b	"87",$D,0
		dc.b	"88",$D,0
		dc.b	"89",$D,0
		dc.b	"90",$D,0
		dc.b	"91",$D,0
		dc.b	"92",$D,0
		dc.b	"93",$D,0
		dc.b	"94",$D,0
		dc.b	"95",$D,0
		dc.b	"96",$D,0
		dc.b	"97",$D,0
		dc.b	"98",$D,0
		dc.b	"99",$D,0
		dc.b	"--",$D,0

;..................................................................................
getsndhfreq:	movem.l	d0-d2/a0,-(sp)

		move.l	sndhpoint(pc),a0	; sndhpoint

		move.l	#199,d0
.top		cmpi.b	#"T",(a0)+
		bne.s	.bot
		cmpi.b	#"C",(a0)+
		bne.s	.bot
		bra.s	.found
.bot		dbra	d0,.top

.notfound	move.w	#50,sndhfreq
		move.w	#"50",tagfreq
		bra.s	.end

.found		move.b	(a0),tagfreq
		move.b	1(a0),tagfreq+1
		move.b	2(a0),tagfreq+2

		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		cmpi.b	#"0",2(a0)
		blo.s	.found2digit
		cmpi.b	#"9",2(a0)
		bhi.s	.found2digit

.found3digit	move.b	(a0)+,d2
		sub.b	#$30,d2
		mulu	#100,d2

.found2digit	move.b	(a0)+,d1
		sub.b	#$30,d1
		mulu	#10,d1

		move.b	(a0)+,d0
		sub.b	#$30,d0

		add.b	d2,d0
		add.b	d1,d0

		move.w	d0,sndhfreq
.end		movem.l	(sp)+,d0-d2/a0
		rts

;..................................................................................
getsndhsubtunes:movem.l	d0-d2/a0,-(sp)

		move.l	sndhpoint(pc),a0	; sndhpoint

		move.l	#199,d0
.top		cmpi.b	#"#",(a0)+
		bne.s	.bot
		cmpi.b	#"#",(a0)+
		bne.s	.bot
		bra.s	.found
.bot		dbra	d0,.top

.notfound	move.w	#1,sndhsubtunes
		move.w	#"01",tagsubtunes
		bra.s	.end

.found		move.b	(a0),tagsubtunes
		move.b	1(a0),tagsubtunes+1

		move.b	(a0)+,d1
		sub.b	#$30,d1
		mulu	#10,d1

		move.b	(a0)+,d0
		sub.b	#$30,d0

		add.b	d2,d0
		add.b	d1,d0

		move.w	d0,sndhsubtunes
.end		movem.l	(sp)+,d0-d2/a0
		rts

;..................................................................................
isit_snd:	movem.l	a0/a4,-(sp)
		move.l	filename(pc),a0			; Address of full filename
.lop1:		cmpi.b	#$D,(a0)+			; Find end
		bhi.s	.lop1
		subq.l	#1,a0				; Now A0 points to the null byte
		movea.l	sp,a4				; Use A4
		move.b	-(a0),-(a4)			; Copy the 4 last chars from the fname
		move.b	-(a0),-(a4)			; to the stack. We know that this
		move.b	-(a0),-(a4)			; will be an even address, and
		move.b	-(a0),-(a4)			; then we can compare using
		cmp.l	#'.snd',(a4)			; these instructions
		beq.s	.file_is_snd
		cmp.l	#'.SND',(a4)
		beq.s	.file_is_snd
.file_not_snd:	and.b	#-2,ccr
		bra.s	.exit
.file_is_snd:	or.b	#1,ccr
.exit:		movem.l	(sp)+,a0/a4
		rts

;..................................................................................
;********************************************* unpacking routine of PACK-ICE
; a0 = Pointer to packed data
; a1 = Address to which the data is unpacked
; "bsr" of "jsr" to ice_decrunch with registers a0 and a1 prepared.
ice_decrunch:	movem.l	d0-a6,-(sp)
		bsr.s	getinfo
		cmpi.l	#'ICE!',d0
		bne	not_packed
		bsr.s	getinfo	
		lea.l	-8(a0,d0.l),a5
		bsr.s	getinfo
		move.l	d0,(sp)
		move.l	a1,a4
		move.l	a1,a6
		adda.l	d0,a6
		move.l	a6,a3
		move.b	-(a5),d7
		bsr	normal_bytes
	
		move.l	a3,a6
		bsr	get_1_bit
		bcc.s	not_packed
		move.w	#$0f9f,d7
		bsr	get_1_bit
		bcc.s	ice_00
		moveq	#15,d0	
		bsr	get_d0_bits
		move.w	d1,d7
ice_00:		moveq	#3,d6
ice_01:		move.w	-(a3),d4
		moveq	#3,d5
ice_02:		add.w	d4,d4
		addx.w	d0,d0
		add.w	d4,d4
		addx.w	d1,d1
		add.w	d4,d4
		addx.w	d2,d2
		add.w	d4,d4
		addx.w	d3,d3
		dbra	d5,ice_02
		dbra	d6,ice_01
		movem.w	d0-d3,(a3)
		dbra	d7,ice_00
	
not_packed:	movem.l	(sp)+,d0-a6
		rts

getinfo:	moveq	#3,d1
getbytes: 	lsl.l	#8,d0
		move.b	(a0)+,d0
		dbf	d1,getbytes
		rts

normal_bytes:	bsr.s	get_1_bit
		bcc.s	test_if_end
		moveq.l	#0,d1
		bsr.s	get_1_bit
		bcc.s	copy_direkt
		lea.l	direkt_tab+20(pc),a1
		moveq.l	#4,d3
nextgb:		move.l	-(a1),d0
		bsr.s	get_d0_bits
		swap.w	d0
		cmp.w	d0,d1
		dbne	d3,nextgb
no_more:	add.l	20(a1),d1
copy_direkt:	move.b	-(a5),-(a6)
		dbf	d1,copy_direkt
test_if_end:	cmpa.l	a4,a6
		bgt.s	strings
		rts	


get_1_bit:	add.b	d7,d7
		bne.s	bitfound
		move.b	-(a5),d7
		addx.b	d7,d7
bitfound:	rts	

get_d0_bits:	moveq.l	#0,d1
hole_bit_loop:	add.b	d7,d7
		bne.s	on_d0
		move.b	-(a5),d7
		addx.b	d7,d7
on_d0:		addx.w	d1,d1
		dbf	d0,hole_bit_loop
		rts	

strings:	lea.l	length_tab(pc),a1
		moveq.l	#3,d2
get_length_bit:	bsr.s	get_1_bit
		dbcc	d2,get_length_bit
no_length_bit:	moveq.l	#0,d4
		moveq.l	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	no_ber
get_ber: 	bsr.s	get_d0_bits
no_ber:	move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	get_offset_2

		lea.l	more_offset(pc),a1
		moveq.l	#1,d2
getoffs:	bsr.s	get_1_bit
		dbcc	d2,getoffs
		moveq.l	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	get_d0_bits
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bpl.s	depack_bytes
		sub.w	d4,d1
		bra.s	depack_bytes


get_offset_2:	moveq.l	#0,d1
		moveq.l	#5,d0
		moveq.l	#-1,d2
		bsr.s	get_1_bit
		bcc.s	less_40
		moveq.l	#8,d0
		moveq.l	#$3f,d2
less_40:	bsr.s	get_d0_bits
		add.w	d2,d1

depack_bytes:	lea.l	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
dep_b:		move.b	-(a1),-(a6)
		dbf	d4,dep_b
		bra	normal_bytes


direkt_tab:	dc.l 	$7fff000e,$00ff0007,$00070002,$00030001,$00030001
		dc.l	270-1,	15-1,	 8-1,	 5-1,	 2-1

length_tab:	dc.b	9,1,0,-1,-1
		dc.b	8,4,2,1,0

more_offset:	dc.b	11,   4,   7,  0
		dc.w	$11f,  -1, $1f


;************************************************* end of unpacking routine

;................................................................
oldvbl:		ds.l	1
oldtimerc:	ds.l	1
oldmfp:		ds.l	1
oldusp:		ds.l	1
olddta:		ds.l	1

dta:		ds.l	11

currentcount:	ds.l	1
previouscount:	ds.l	1
noloadcount:	ds.l	1
printactive	ds.w	1

filename:	ds.l	1
filesize:	ds.l	1
filehandle:	ds.w	1
filebuffer:	ds.l	1

sndhpoint:	ds.l	1
sndhfreq:	ds.w	1
sndhsubtunes:	ds.w	1

tagfreq:	ds.b	4
tagsubtunes:	ds.b	4

mfpsave		ds.b	10
vecsave		ds.l	15

initstring1:	dc.b	$1B,"E",$1B,"f" 			   ;curs off, clr home
		;        0123456789012345678901234567890123456789
		dc.b	"SNDH CPU Measuring Tool v0.2 - gwEm 2k6",$A,$D
		dc.b	"***************************************",$A,$D,$1B,"j"
		dc.b	"Replay rate:",0

initstring2:	dc.b	"Hz",$A,$D,"Sub-tunes  :",0
initstring3:	dc.b	$A,$D,$A
		dc.b	"   > Press key to start a sub-tune <   ",$1B,"k",0

errorstring:	dc.b	$1B,"E",$1B,"f"
		dc.b	"Error with file ",0

stopstring:	dc.b	"  > Press space to stop sub-tune ?? <  ",$A,$D
		dc.b	"                                       ",$A,$D
		dc.b	"--% CPU                                ",$A,$D
		dc.b	"                                       ",$A,$D,0

infotext:	dc.b 	"Alright  crew,   heres  my  attempt  at",$A,$D
		dc.b	"measuring CPU usage of SNDH chip music.",$A,$A,$D

		dc.b	"The figure shown  indicates the highest",$A,$D
		dc.b	"CPU usage the  music  has  had per 50Hz",$A,$D
		dc.b	"period in the last  0.5 secs.   Thats a",$A,$D
		dc.b	"useful measure for 1 VBL demos, average",$A,$D
		dc.b	"CPU usage would be better for multi VBL",$A,$D 
		dc.b	"prods.  The two may not be that similar",$A,$D
		dc.b	"for unusual replay rates, eg 51Hz.",$A,$A,$D

		dc.b	"The measurement  accuracy  is in no way",$A,$D
		dc.b	"guaranteed.  In  the case of SID fx the",$A,$D
		dc.b	"figure returned is  often lower than my",$A,$D
		dc.b	"gut feeling,  and also Grazey/PHF.  But",$A,$D
		dc.b	"as RA/Paradox points out - its a better",$A,$D
		dc.b	"indication than having no tool at all.",$A,$A,$D
 
		dc.b	"Greetings to these two guys and Cyclone"
		dc.b	$1B,"Y",$24,$20,0

;..................................................................................
