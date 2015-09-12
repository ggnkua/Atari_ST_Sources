;
; Paralax Stars Improved Bootsector
;
; (c)1990 Oberje'
;

no_of_stars	equ	40	; No of stars each plane.
				; TOTAL = 40*3 = 120 Stars!
				; ( Max 64 stars per plane
				; since above screen memory used! )
				
time		equ	8	;No of seconds to run stars for


*********
* Begin *
*********
	pea	now		;Warn user of impending doom
	move.w	#9,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;
	move.w	#8,-(a7)	;wait-key
	trap	#1		;
	addq.l	#2,a7		;
	
*************************
* First Get old Sector! *
*************************
go	move.w	#1,-(a7)	;1 Sector
	move.w	#0,-(a7)	;Side 1
	move.w	#0,-(a7)	;Track 0
	move.w	#1,-(a7)	;Sector 1
	move.w	#0,-(a7)	;Drive A
	move.l	#0,-(a7)	;DUMMY
	move.l	#bufty,-(a7)	;Buffer
	move.w	#$8,-(a7)	;_floprd
	trap	#14		;
	add.l	#20,a7		;

	lea	bufty+2,a0	;Copy important values to our bootsector
	lea	bootbl+2,a1	;Thus ensuring we don't fuck-up
	move.w	#13,d0		;the disk, if it already contains stuff
patsy_kensit			;
	move.w	(a0)+,(a1)+	;
	dbf	d0,patsy_kensit	;

	move.w	#1,-(a7)	;Make Our Sector EXECUTABLE
	move.w	#-1,-(a7)	;Use OLD values
	move.l	#-1,-(a7)	;Use OLD values
	move.l	#bootbl,-(a7)	;512 Byte buffer
	move	#18,-(a7)	;
	trap	#14		; _protobt
	add.l	#14,a7 		;
	pea	out		;Tell 'em about it!
	move.w	#9,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;
	move	#0,d1		;Track is 0
	move	#1,d0		;Sector is 1
	bsr	write		;Write the boot sector
	pea	done		;We're done!
	move.w	#9,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;
	move.w	#8,-(a7)	;Wait-key
	trap	#1		;
	addq.l	#2,a7		;
	move	#0,-(a7)	;PTerm0
	trap	#1		;
		
write	movem.l	d0-d2/a0-a2,-(a7)
	move	#1,-(a7)	;Number of sectors
	move	#0,-(a7)	;Side number
	move	d1,-(a7)	;Track number
	move	d0,-(a7)	;Start Sector
	move	#0,-(a7)	;Device number
	clr.l	-(a7)		;Not used
	move.l	#bootbl,-(a7)	;Buffer
	move	#9,-(a7)	;
	trap	#14		; _flopwr
	add.l	#20,a7		;
	movem.l	(a7)+,d0-d2/a0-a2
	rts
		
	even

now	dc.b	27,"E",27,"p Fingerbobs Parallax Stars Bootsector Installer ",27,"q",13,10
	dc.b	13,10
	dc.b	"Please insert disk to Groovify in Drive A",13,10
	dc.b	"and Press a key!",13,10,0
	
	even
	
out	dc.b	13,10,13,10,"Writing Auto-Boot Disk Now!",0

	even
	
done	dc.b	13,10,13,10,"Finished.......Press a key to exit. ",13,10,0

	even
		
bufty	ds.b	512

	even
	
	
	*********************
	*		    *
	*  The Boot Sector  *
	*		    *
	*********************
	
	;
	; Size of Bootsector is endof-bootbl
	; ( This must be 510 bytes or less )
	;
	; Max code size = 480 bytes
	;
	; This code = 470 bytes
	;
		
bootbl	bra.s	bootls		;Branch to Boot code
	ds.b	6		;OEM area
	dc.b	$00,$00,$00	;Serial number
	dc.b	$00,$02		;Bytes/Sector
	dc.b	$02		;Sectors/Cluster
	dc.b	$01,$00		;No. of Reserved Sectors
	dc.b	$02		;No. of FATs
	dc.b	$70,$00		;No. of Directory Entries
	dc.b	$d0,$02		;No. of Sectors
	dc.b	$f8		;Media descriptor
	dc.b	$05,$00		;Sectors/FAT
	dc.b	$09,$00		;Sectors/Track
	dc.b	$01,$00		;Sides on media
	dc.b	$00,$00		;Hidden Sectors
	;
	;
	;
bootls	move.w	#$2300,sr	; Allow Interrupts
	
	pea	$80000000	; Low Res $78000
	pea	$80000007	;
	pea	$00050007	;
	trap	#14		;
	lea	12(a7),a7	;
	
	bsr	wait_vbl	; Wait for frame
				;
	pea	message(pc)	; Print the text
	move.w	#9,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;
				;
	bsr	init_stars	; Create the Star Data
				;
	pea	new_palette(pc)	;
	move.w	#6,-(a7)	;Install the correct palette
	trap	#14		;
	addq.l	#6,a7		;
				;
	lea	store3,a2	;
	bsr	do_pix		;Display pixels
	lea	store2,a2	;
	bsr	do_pix		;Display pixels
	lea	store1,a2	;
	bsr	do_pix		;Display pixels
				;
	move.w	#50*time,d6	;No of Frames Stars to run for
	bsr.s	stars		;Call the actuall program!!
				;
	lea	new_palette(pc),a0
	move.w	#$777,(a0)	;Border White
	move.w	#$000,30(a0)	;Pen Black
	move.l	a0,-(a7)	;Install this palette
	move.w	#6,-(a7)	;
	trap	#14		;
	addq.l	#6,a7		;
	rts			;Finito!
	;
	;
	;
stars	bsr	wait_vbl
	moveq	#0,d4
	bsr.s	layer_1		;Call each layer of stars
	bsr.s	layer_2		;
	bsr.s	layer_3		;

	pea	$000600ff	; Test for key...
	trap	#1		; If no key then repeat
	addq.l	#4,a7		; until timeout

	tst.w	d0		;
	bne.s	goon		;Keypress->arrrgh!

	dbf	d6,stars	;Round we go...
goon	rts			;Finshed->
	;
	;
	;
update	movea.l	a2,a0		;Pointer to star data
	move.w	#no_of_stars-1,d7
another_point			;
	move.w	(a0),d0		;
	sub.w	d4,d0	 <--    ;This value determines the speed
	cmpi.w	#0,d0		;and direction of the stars				
	ble.s	zero		;
loop	move.w	d0,(a0)		;
	addq.l	#4,a0		;
	dbra	d7,another_point
	rts			;
zero	move.w	#319,d0		;
	bra.s	loop		;
	;
	;
	;
layer_3	lea	store3,a2	; a2 = points data
	moveq	#3,d4		; d4 = Speed of layer
	bra	standard	;
layer_2	lea	store2,a2	;
	moveq	#2,d4		;
	bra	standard	;
layer_1	lea	store1,a2	;
	moveq	#1,d4		;
standard
	bsr.s	do_pix		;Blank out pixels
	bsr.s	update		;Update this layer
	bsr.s	do_pix		;Show new pixels
	rts			;
	;
	;
	;
	dc.b	"-* Fingerbobs Parallax Intro v2.0 *-"
	;
	;
	;
	even
	;
do_pix	move.w	#no_of_stars-1,d7
	movea.l	a2,a0		;Pointer to Star data
nextpoint
	moveq	#0,d0		;Remove
	moveq	#0,d1		;Garbage
	move.w	(a0)+,d0	;Get X value
	move.w	(a0)+,d1	;Get Y value
	move.w	d0,d2		;
	lea	$78000,a1	;
	add.l	d1,a1		;Address of screen line
	asr.w	#4,d0		;
	asl.w	#3,d0		;
	add.l	d0,a1		;Address of word
	move.w	d2,d0		;
	andi.w	#$f,d0		;
	eori.w	#$f,d0		;Bit of word
	move.w	(a1),d2		;\
	bchg	d0,d2		;| Change it!
	move.w	d2,(a1)		;/
	dbf	d7,nextpoint	;
	rts			;
	;
	;
	*
	* Pseudo-Random No Generator
	* (c)1989 The Creeper
	*
init_stars
	move.l	#(no_of_stars*3)-1,d0
	lea	store1,a0	;area to hold X.w and Y.w
star_loop	
	lea	rand(pc),a6	;
	move.w	(a6),d1		;Random seed/number
	move.l	d1,d2		;copy it so I can use it for y also
	asl.l	#8,d1		;X.w uses bottom bits
	and.l	#$ffff,d1	;and out top word
	and.l	#$ffff,d2	;and again
	divu	#$ffff/320,d1	;get value from 0-320 for X.w
	divu	#$ffff/200,d2	;get value from 0-200 for Y.w
	move.w	d1,(a0)+	;put X.w into table
	move.l	d2,d3		;put Y.w into work register
	mulu	#$a0,d3		;multiply Y.w by bytes per line for offset
	move.w	d3,(a0)+	;put Y.w into table
	add.w	d1,(a6)		;add X.w to current seed
	asr.l	#4,d2		;effectivelty muddle Y.w bits
	eor.w	d2,(a6)		;and then EOR it with current seed
	dbra	d0,star_loop	;and repeat for all stars
	rts			;

wait_vbl
	move.l	$466.w,d0
.wait	cmp.l	$466.w,d0
	beq.s	.wait
	rts

	;
	even
	;
	***********
	* Message *
	***********
message	dc.b 27,"E",27,"Y",32+12,32+2
change  dc.b "         F.I.N.G.E.R.B.O.B.S          ",0,0
	;
	even
	;
new_palette	dc.w	$0,$777,$70,$0,$111,$222,$333,$444
		dc.w	$555,$0,$1,$10,$100,$200,$20,$456
	;
rand		dc.w	$1fff		;Random seed (this one works well)
	;
store1	equ	$7fd00	
store2	equ	store1+(no_of_stars*4)
store3	equ	store2+(no_of_stars*4)
	;
endof	ds.b	512		;Ensure enough data for full sector
	;
	even
	
*
* END
*

