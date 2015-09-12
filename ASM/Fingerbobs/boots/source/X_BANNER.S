;--------------------------------------------------------------------------
;
; Raster Banner Bootsector
; (c)1991 Oberje'
;
;--------------------------------------------------------------------------

; 2009/1/16 Noticed under STeem that rasters are incorrectly
;           sync'd on a cold boot, but okay on a warm boot

;
; Bootsector write code
;
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

now	dc.b	27,"E",27,"p Fingerbobs ""Raster-Banner"" Bootsector Installer ",27,"q",13,10
	dc.b	13,10
	dc.b	"Please insert disk to Groovify in drive A",13,10
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
	; This code = 472 bytes
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
bootls	
;===================================================================
;
; Actuall routs.
;
;===================================================================

;code_address	equ	$90000
;data_address	equ	$a0000

code_address	equ	$20000	; Sensible values for 1/2 meg machines!
data_address	equ	$30000


begin	pea	message(pc)		; Message
	move.w	#9,-(a7)		;
	trap	#1			;
	addq.l	#6,a7			;
	bsr	depack_data		; Unexpand data
	bsr	create_code		; Unexpand code
	move.w	#$2700,sr		; IPL 7
	move.b	$fffffa07.w,-(a7)	; iea
	move.b	$fffffa09.w,-(a7)	; ieb
	move.l	$70.w,-(a7)		; vbl
	lea	myvbl(pc),a0	
	move.l	a0,$70.w		; new vbl
	lea	myhbl(pc),a0		;
	move.l	a0,$120.w		; new hbl
	clr.b	$fffffa09.w		; ieb off!
	move.b	#1,$fffffa07.w		; iea on!
	move.b	#1,$fffffa13.w		; ima on!
	move.w	#$2300,sr		; IPL 3

wait	stop	#$2300			; Sync VBL
	cmp.b	#$39,$fffffc02.w	; Space?
	bne.s	wait			; Nope!
	
	move.w	#$2700,sr		; Restore
	move.l	(a7)+,$70.w
	move.b	(a7)+,$fffffa09.w
	move.b	(a7)+,$fffffa07.w
	move.w	#$2300,sr
	rts
	

myvbl	move.b	#0,$fffffa1b.w		; Timer B off
	move.b	#$14,$fffffa21.w	; 
	lea	myhbl(pc),a0
	move.l	a0,$120.w
	move.b	#8,$fffffa1b.w		; Timer B on
	rte
	
nullhbl	bclr.b	#0,$fffffa0f.w
	rte
	
myhbl	movem.l	d0-d7/a0-a6,-(a7)
	lea	$ffff8209,a3
	lea	data_address,a0
	lea	$ffff8240,a1
	lea	$fffffa21,a2
	lea	code_address,a4
oor	tst.b	(a3)
	beq.s	oor
	move.b	(a3),d4
	adda.l	d4,a4
	jmp	(a4)

finish_up
	move.b	#0,$fffffa1b.w
	lea	nullhbl(pc),a0
	move.l	a0,$120.w
	movem.l	(A7)+,D0-d7/a0-a6
	bclr	#0,$fffffa0f.w
	rte
	
create_code
	lea	code_address,a0
	move.w	#178,d0		; 179 nops!
.loop	move.w	#$4e71,(a0)+
	dbf	d0,.loop
	move.w	#7,d7
big_loop
	move.w	#15,d6		; Line constant!!!! <------
small_loop
	move.w	#32,d0		; 33 copies
.loop2	move.w	#$3298,(a0)+
	dbf	d0,.loop2
	move.l	#$31fc0777,(a0)+
	move.w	#$8240,(a0)+
	move.w	#22,d0		; 22 nops!
.loop3	move.w	#$4e71,(a0)+
 	dbf	d0,.loop3
	move.l	#$41e8ffbe,(a0)+
	dbf	d6,small_loop
new_line
	move.w	#32,d0		; 33 copies
.loop2	move.w	#$3298,(a0)+
	dbf	d0,.loop2
	move.l	#$31fc0777,(a0)+
	move.w	#$8240,(a0)+
	move.w	#24,d0		; 22 nops!
.loop3	move.w	#$4e71,(a0)+
	dbf	d0,.loop3
	
	dbf	d7,big_loop
	lea	finish_up(pc),a1
	move.w	#$4ef9,(a0)+
	move.l	a1,(a0)+
	rts		
	
bgnd	equ	$278	; These values control the colour scheme!
f_gd	equ	$633

depack_data
	move.w	#bgnd,d2	;*******************
	lea	data1(pc),a1	; Packed(?) data
	lea	data_address,a0	; Destination
	move.w	#7,d7		; 8-lines
depack_line_loop
	move.w	(a1)+,d0	; Word1

	move.w	#1,d5
loop2
	move.w	#15,d6
loop1
	lsl.w	#1,d0		; Get bit	
	bcs.s	.over
	move.w	d2,(a0)+	; Background
	add.w	#$100,d2
	bra.s	.cont
.over	move.w	#f_gd,(a0)+	; Foreground
.cont	dbf	d6,loop1	;
	move.w	(a1)+,d0	; Word2 ( Word3 )
	dbf	d5,loop2	;
outloop
	lsl.w	#1,d0
	bcs.s	.over
	move.w	d2,(a0)+
	bra.s	.cont
.over	move.w	#f_gd,(a0)+
.cont	dbf	d7,depack_line_loop
	rts

; Y 32+Row 32+Col
message	dc.b	27,"Y",32+22,32+12,"Bitchin' Dude!",0
	even
;		 |-------|-------  |-------|------- |
data1	dc.w	%0111101110011110,%1110011110111100,-1
	dc.w	%0100101001010000,%1001000010100000,-1
	dc.w	%0100101001010000,%1001000010100001,0
	dc.w	%0100101110011110,%1110000010111100,0
	dc.w	%0100101001010000,%1001000010100000,0
	dc.w	%0100101001010000,%1001000010100000,0
	dc.w	%0100101001010000,%1001010010100000,0
	dc.w	%0111101111011110,%1001001100111100,0

	;
endof	ds.b	512		;Ensure enough data for full sector
	;
	even
	
*
* END
*


