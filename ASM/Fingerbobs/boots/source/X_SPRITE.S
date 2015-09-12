;-----------------------------------------------------------------------
; Sprites Bootsector
;
; (c)1990 Oberje'
;
; Displays 16 sine-y sprites until a key is pressed. And it all fits
; into the bootsector! Amazing or what!
; Well not bad anyway!
;
;-----------------------------------------------------------------------


nospr	equ	16-1	; No of sprites - 1

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

now	dc.b	27,"E",27,"p Fingerbobs Sprites Bootsector Installer ",27,"q",13,10
	dc.b	13,10
	dc.b	"Please insert disk to Groovify into drive A",13,10
	dc.b	"then Press a key!",13,10,0
	
	even
	
out	dc.b	13,10,13,10,"Writing Bootblock Disk Now!",0

	even
	
done	dc.b	13,10,13,10,"Finished.......Press a key to exit. ",13,10,0

	even
		
bufty	ds.b	512

	even
	
	
;-----------------------------------------------------------------------
	
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
	; This code = 463 bytes
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
bootls	lea	use_coords,a0	; Set up sprite coords
	moveq	#0,d1		;
	move.w	#32,d2		;
	moveq	#nospr,d0	;
.loop	move.w	d1,(a0)+	;
	move.w	d2,(a0)+	;
	addq.w	#8,d1		;
	addq.w	#8,d2		;
	dbf	d0,.loop	;

	move.w	#2,-(a7)	; Set up screen address
	trap	#14		;
	addq.l	#2,a7		;
	lea	screen+2(pc),a0	;
	move.l	d0,(a0)		;

	pea	message(pc)	; Print text
	move.w	#9,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;

main	move.w	#37,-(a7)	; Wait for VBL
	trap	#14		;
	addq.l	#2,a7		;
	moveq	#0,d5		; RUBOUT
	bsr	draw		;
	bsr	update		; Update sprites
	moveq	#-1,d5		; DRAW
	bsr	draw		;
	pea	$000600ff	; Test for key...
	trap	#1		; If no key then repeat
	addq.l	#4,a7		; 
	tst.w	d0		;
	beq.s	main
	
	rts			; Finshed->

;
; Update sprite coords
;
Xinc	equ	1
Yinc	equ	2

update	lea	use_coords,a0	; Co_ords
	move.w	#nospr,d7	; 10 Sprites
.loop	move.w	(a0),d0		; X offset
	move.w	2(a0),d1	; Y offset
	addi.w	#Xinc,d0	;
	addi.w	#Yinc,d1	;
	andi.w	#$7f,d0		;
	andi.w	#$7f,d1		;
	move.w	d0,(a0)+	;
	move.w	d1,(a0)+	;
	dbf	d7,.loop	;
	rts			;

;
;
; Sprite Rubout/Draw routine
;
; d5 =  0 : Rubout sprites
;    = -1 : Draw sprites
;
draw	lea	use_coords,a0	; Co_ords
	lea	sin(pc),a4	; Sine table
	move.w	#nospr,d7	; 10 Sprites
dloop	move.w	(a0)+,d0	; X offset
	move.w	(a0)+,d1	; Y offset
	move.b	(a4,d0.w),d0	; X coord
	move.b	(a4,d1.w),d1	; Y coord
	addi.w	#72,d0		; Centre X
	addi.w	#30,d1		; Centre Y
	andi.w	#$ff,d1		; Trim off garbage from Y 
screen	lea	$78000,a1	; Screen Base
	mulu	#$a0,d1		; Line Offset
	adda.l	d1,a1		; Screen Line Address
	move.w	d0,d2		;
	andi.l	#$f0,d2		;
	asr.l	#1,d2		; Word Offset 
	adda.l	d2,a1		; Screen Line & Word Address
	andi.w	#$f,d0		; Pixel offset
				;
	lea	blob(pc),a2	; Sprite Data
	moveq	#15,d6		; 16 Lines
	tst.w	d5		;
	beq	dinner2		; d5=0 = rubout, 1=draw
				;	
dinner	move.l	(a2),d1		; Get Data
	move.w	#0,d1		; Get Blank area
	lsr.l	d0,d1		; Shift by Pixel offset
	or.w	d1,8(a1)	;
	swap	d1		;
	or.w	d1,(a1)		; Place on screen
	adda.l	#2,a2		;
	lea	$a0(a1),a1	; Next line
	dbf	d6,dinner
	dbf	d7,dloop
	rts
	
dinner2	move.w	#0,(a1)		; Rubout
	move.w	#0,8(a1)	;
	lea	$a0(a1),a1	;
	dbf	d6,dinner2	;
	
	dbf	d7,dloop	;
	rts
	

********************************************
* The Altogether Famous Sine Table Of Doom *
********************************************

sin	dc.b	$4A,$47,$44,$41
	dc.b	$3E,$3B,$38,$35
	dc.b	$32,$2F,$2C,$29
	dc.b	$26,$24,$21,$1F
	dc.b	$1C,$1A,$18,$16
	dc.b	$14,$13,$11,$10
	dc.b	$E,$D,$C,$B
	dc.b	$B,$A,$A,$A
	dc.b	$A,$A,$A,$A
	dc.b	$B,$C,$C,$D
	dc.b	$F,$10,$11,$13
	dc.b	$15,$17,$19,$1B
	dc.b	$1D,$1F,$22,$24
	dc.b	$27,$2A,$2C,$2F
	dc.b	$32,$35,$38,$3B
	dc.b	$3F,$42,$45,$48
	dc.b	$4B,$4F,$52,$55
	dc.b	$58,$5B,$5E,$61
	dc.b	$64,$67,$6A,$6D
	dc.b	$6F,$72,$74,$77
	dc.b	$79,$7B,$7D,$7F
	dc.b	$81,$83,$84,$86
	dc.b	$87,$88,$89,$8A
	dc.b	$8A,$8B,$8B,$8B
	dc.b	$8B,$8B,$8B,$8B
	dc.b	$8A,$89,$88,$87
	dc.b	$86,$85,$83,$82
	dc.b	$80,$7E,$7C,$7A
	dc.b	$77,$75,$73,$70
	dc.b	$6D,$6B,$68,$65
	dc.b	$62,$5F,$5C,$59
	dc.b	$56,$52,$4F,$4C

blob	dc.w	%0000011111100000
	dc.w	%0001111111111000
	dc.w	%0011100111111100
	dc.w	%0111001111111110
	dc.w	%0111001111111110
	dc.w	%0111001111111110
	dc.w	%1110011111111111
	dc.w	%1110011111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%0111111111111110
	dc.w	%0011111111111100
	dc.w	%0001111111111000
	dc.w	%0000011111100000

message	dc.b	27,"Y",31+2,31+15
	dc.b	"FINGERBOBS"
	dc.b	27,"Y",31+3,31+14
	dc.b	"BOOT SPRITES"
	dc.b	0

	;
endof	ds.b	512		;Ensure enough data for full sector
	;
	even
	
;-----------------------------------------------------------------------
	
use_coords equ	$50000
	
*
* END
*

