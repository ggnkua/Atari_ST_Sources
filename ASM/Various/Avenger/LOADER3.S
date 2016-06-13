
* MURDER -FRENCH- CRACKED/FILED/PACKED
		
		clr.l   -(a7) 
      		move.w  #$20,-(a7) 	;super
      		trap    #1
      		addq.l  #6,a7 

		dc.w	$a00a		;hide mouse

		move.w	#0,-(a7)	;low resolution
      		move.l  #$78000,-(a7) 
      		move.l  #$78000,-(a7) 
      		move.w  #5,-(a7) 	;setscreen
      		trap    #$e 
      		adda.l  #12,a7

		move.w	#$666,d6	;Fade background to black
lop1:		move.w	d6,$ffff8240.w
		bsr.w	delay2
		sub.w	#$111,d6
		bpl.s	lop1

print		pea     message(pc)     ; Print Message
		move.w  #9,-(a7)
		trap    #1
		addq.l  #6,a7
			
		move.w	#$111,d6	;Fade text to white
.loop2		move.w	d6,$ffff825e.w
		bsr	delay2
		add.w	#$111,d6
		cmp.w	#$888,d6
		bne.s	.loop2

		move.w  #7,-(a7)        ; Wait for key
		trap    #1
		addq.l  #2,sp           

start_game:
      		clr.w   -(a7) 
      		move.l  #filename,-(a7)
      		move.w  #$3d,-(a7) 	;fopen
      		trap    #1
      		addq.l  #8,a7 

		move.w  d0,d7 
      		
		move.l  #$50000,-(a7)	;destination address	
      		move.l  #$20000,-(a7)	;size
      		move.w  d7,-(a7)
      		move.w  #$3f,-(a7) 	;fread
      		trap    #1
      		adda.l  #12,a7
	    
		move.w  d7,-(a7)
	      	move.w  #$3e,-(a7) 	;fclose 
	      	trap    #1
	      	addq.l  #4,a7 

		lea	$50000,a0
		bsr.w	depack

********************************************************
*copy whole shit to $70000
		lea	mover(pc),a0
		lea	$70000,a1
		lea	endmover(pc),a2
copymover:	move.b	(a0)+,(a1)+
		cmp.l	a0,a2
		bne.s	copymover
		jmp	$70000

mover:		lea	MY_DISKHANDLER(pc),a0
		lea	($50000+$ac4a),a1
		lea	END_HANDLER(pc),a2
copyhandler:	move.b	(a0)+,(a1)+
		cmp.l	a0,a2
		bne.s	copyhandler

		lea	DEPACK_FILE(pc),a0
		lea	depacker,a1	
		lea	END_DEPACKER(pc),a2
copydepacker:	move.b	(a0)+,(a1)+
		cmp.l	a0,a2
		bne.s	copydepacker

		lea	$50000,a0
		lea	$13880,a1
		lea	($13880+$16800),a2
copymain:	move.b	(a0)+,(a1)+
		cmp.l	a1,a2
		bne.s	copymain
		
		move.l	#$4e714e71,$14076	;patch the manual check
		move.w	#$4e71,$1407a
		
		jmp	$13880			;starts the game
**[ copy this to $1e4ca ]*******************************************************
* d0 = track
* d1 = starting sector in track
* d7 = amount of bytes needed
* a0 = destination address

* USES d7,d2,d0,d1,a0,a1

MY_DISKHANDLER:
		move.w	sr,-(a7)

		move.w	#$2300,sr

		mulu	#10,d0
		add.w	d0,d1
		and.l	#$ffff,d1

		movea.l	a0,a1			;destination

		lea	logical_sector(pc),a0
		move.w	d1,(a0)			;logical sector
;		move.w	d2,2(a0)		;amount of sectors needed
		move.l	a1,4(a0)		;destination

		bsr.w	READ_BOOTSECTOR
		bsr.w	READ_DIRECTORY	
		bsr.w	SEARCH_FILE	
	
		move.w	#$2300,sr
		move.l	destaddr(pc),a0
		jsr	$84000			;depacking routine is copied here

		rte
		even
********************************************************************************
filenames		dc.b	"MURDERVF000",0,0 (FILENAMEext)
start_of_dir		dc.w	0
dirsize_in_sectors	dc.w	0
sides			dc.w	0
cluster			dc.w	0
logical_sector		dc.w	0
amount_of_sectors	dc.w	0
destaddr		dc.l	0
depacker		equ	$84000
********************************************************************************
SEARCH_FILE:
		move.w	#$2300,sr

		move.w	logical_sector(pc),d0
		move.l	d0,d1
		move.l	d0,d2
		and.l	#$f,d0
		and.l	#$f0,d1
		and.l	#$f00,d2
		
		lsl.l	#8,d2
		lsl.l   #4,d1
		add.l	d2,d1
		cmp.l	#$9,d0
		bgt.s	letter
		add.b	#$30,d0
		bra.s	checkd1
letter:		add.b	#$37,d0		
checkd1:	cmp.w	#$900,d1
		bgt.s	letter2
		add.l	#$303000,d1
		bra.s	donethis
letter2:	add.l	#$303700,d1
donethis:	add.l	d1,d0
		lsl.l	#8,d0
		move.l	d0,d6
		lea	filenames(pc),a0
		move.l	d0,8(a0)

		move.l	destaddr(pc),a0
scan_it:	lea	filenames(pc),a1
		movea.l a1,a3 
      		movea.l a0,a4 
      		move.w  #10,d0		;11 chars (no ".")
l000b:		cmpm.b  (a3)+,(a4)+ 
      		bne.w   next_file 
      		dbf     d0,l000b
		bra.s	foundfile

next_file:	lea	$20(a0),a0
		cmp.l	#0,(a0)
		bne.s	scan_it

moredir:	lea	start_of_dir(pc),a0
		add.w	#1,(a0)
		bsr.w	READ_DIRECTORY
		bra.s	scan_it
********************************************************************************
foundfile:	moveq	#0,d0
		moveq	#0,d1
		move.b	27(a0),d0	;d0 contains the log.sect of the filestart
		lsl.l	#8,d0
		move.b	26(a0),d0

* use the original size from disk 
		move.b	30(a0),d1
		lsl.l	#8,d1
		move.b	29(a0),d1
		lsl.l	#8,d1
		move.b	28(a0),d1

;		divu	#$200,d1

		move.l	d1,d6
;		swap	d1
;		cmp.w	#0,d1
;		beq.s	evensize
;		add.b	#1,d6
;evensize:	ext.l	d6	
************************************
		lea	cluster(pc),a0
		move.w	d0,(a0)			;cluster of the file

		move.l	destaddr(pc),a0		;address where to load the file
		 
 		move.l	#$e,d0			;always this sector	
 		move.w	cluster(pc),d1
 		mulu	#2,d1
		add.l	d1,d0

		bsr.w	calc_position	
		move.l	d6,d1
		bsr.w	READ_DISK
		rts
********************************************************************************
READ_DIRECTORY:
		move.w	#$2300,sr
		move.w	start_of_dir(pc),d0
		bsr.w	calc_position
;		moveq	#1,d1
		move.l	#$200,d1
		move.l	destaddr(pc),a0
		bsr.w	READ_DISK
		rts
********************************************************************************
READ_BOOTSECTOR:
		move.w	#$2300,sr
		moveq	#0,d0		;logical sector 0
		bsr.w	calc_position	
;		moveq	#1,d1		;read 1 sector
		move.l	#$200,d1
		move.l	destaddr(pc),a0
		bsr.s	READ_DISK
		eor.l	d0,d0
		eor.l	d1,d1
		move.l	destaddr(pc),a0
		move.b	$1a(a0),d2	;ss/dd ??
		move.b	$10(a0),d0	;how many sectors/track
		move.b	$16(a0),d1
		mulu	d1,d0
		add.b	#1,d0
		lea	start_of_dir(pc),a1
		move.w	d0,(a1)		
		move.b	$11(a0),d1
		lsr.l	#4,d1
		move.w	d1,2(a1)	;dirsize
		move.w	d2,4(a1)	;sides
		rts
********************************************************************************
* D0 contains logical sector number like 30
* and in return it uses d2/d0 as TRACK/SECTOR and swaps
* floppy side if needed
calc_position:
		move.w	#$2300,sr
		lea	disk(pc),a4
		ext.l	d0
		divu	#10,d0
		move.w	sides(pc),d3
		cmp.w	#1,d3
		beq.s	side0
		btst	#0,d0
		bne.s	side1
side0:		move.b	#5,(a4)
		bra.s	norm
side1:		move.b	#4,(a4)
norm:		move.l	d0,d1
		cmp.w	#1,d3
		beq.s	ss
		lsr.w	#1,d0
ss:		swap	d1
		addq.w	#1,d1
		move.l	d0,d2
		move.l	d1,d0
		ext.l	d0
		ext.l	d2
		move.w	d2,2(a4)	;track 
		move.b	d0,1(a4)	;sector where to start
		rts
********************************************************************************
* a0=destination address

dmamode		equ	$ffff8606
dmadat		equ	$ffff8604
dmahigh		equ	$ffff8609
dmamid		equ	$ffff860b
dmalow		equ	$ffff860d
mfp		equ	$fffffa01
flselec		equ	$ffff8800
flwrite		equ	$ffff8802
flock		equ	$43e

disk:		
side:		dc.b	0		;5 or 4 (side 0 or side 1)
sector:		dc.b	0		
track:		dc.w	0		

READ_DISK:
		lea	disk(pc),a4
;		mulu	#$200,d1	;512bytes per sector
		move.l	d1,d3		;d3 contains the needed size

fastload	st	flock		;Disable floppy interrupt
		move.b	#$e,flselec	;Select port A	
		move.b	#5,flwrite	;Activate drive
		move.w	#$80,dmamode	;Access FDC register
		move.w	#$d0,dmadat	;Reset command
		move.w	#80,d7		;Set up a delay
delay		dbf	d7,delay	;Wait for reset

loaddata	lea	lbuffer(pc),a1
		move.l	a1,d7		;Copy into d7
		move.b	d7,dmalow	;Set low byte
		lsr.l	#8,d7
		move.b	d7,dmamid	;Set mid byte
		lsr.l	#8,d7
		move.b	d7,dmahigh	;Set high byte
	
		move.b	#$e,flselec	;Select port A
		move.b	(a4),flwrite	;Select side

		move.w	#$86,dmamode	;Access track register
		move.w	2(a4),d6	;New track
		move.w	d6,dmadat	;Send command
		move.w	#$80,dmamode	;Select FDC register
		move.w	#27,dmadat	;Seek track command
		bsr	waitready	;Wait for ready signal

		move.w  #$90,dmamode
		move.w  #$190,dmamode
		move.w  #$90,dmamode 
;		move.w	#$90,dmamode	;Sector count register
		move.w	#1,dmadat	;Read 1 sector
		move.w	#$84,dmamode	;Select sector register
		move.b	1(a4),d6	;New sector
		move.w	d6,dmadat	;Send command
		move.w	#$80,dmamode	;Select FDC register
		move.w	#$80,dmadat	;Read sector command
		bsr	waitready	;Wait for ready signal

		add.b	#1,1(a4)	;Move to next sector
		cmp.b	#11,1(a4)	;Next track yet?
		bne	posfound	;No, skip next bit
		eori.b	#1,(a4)		;swap another side
		move.b	#1,1(a4)	;Back to sector 1
		cmp.b	#5,(a4)
		bne.s	posfound	
		add.w	#1,2(a4)	;Move up track counter

posfound:	lea	lbuffer(pc),a1	;Address of buffer
		cmp.l	#512,d3		;Less than 513 bytes remaining?
		bls.s	endload		;Yes, end load sequence
		move.w	#31,d0		;Set up a counter
buffcopy:	move.l	(a1)+,(a0)+	;Copy data out of buffer
		move.l	(a1)+,(a0)+	;Copy data out of buffer
		move.l	(a1)+,(a0)+	;Copy data out of buffer
		move.l	(a1)+,(a0)+	;Copy data out of buffer
		dbf	d0,buffcopy	;Copy some more data
		sub.l	#512,d3		;Decrease amount to load
		bra	loaddata	;Load in some more

endload:	sub.w	#1,d3		;Number of bytes remaining
buffcopy2:	move.b	(a1)+,(a0)+	;Copy data out of buffer
		dbf	d3,buffcopy2	;Copy some more
		sf	flock		;Enable floppy interrupt
		rts			;Return

waitready:	btst	#5,mfp		;Command processed?
		bne	waitready	;No, keep waiting
		rts			;Return

lbuffer:	ds.b	512

END_HANDLER:
*********************************************************
DEPACK_FILE:
		include depack35.s
END_DEPACKER:
*********************************************************
endmover:
filename	dc.b	"MURDERVF.AL",0

delay2:		moveq	#5,d7		
.11		move.w	#$25,-(a7)	
		trap	#14
		addq.l	#2,a7
		dbf	d7,.11
		rts

message		dc.b 27,"E"
		dc.b " ",13,10
		dc.b " Murder *FRENCH*",13,10
		dc.b " ---------------",13,10
		dc.b " ",13,10
		dc.b " Cracked/Filed/Packed by Avenger",13,10
		dc.b " ",13,10
		dc.b " Press any key to continue ",0
		even

