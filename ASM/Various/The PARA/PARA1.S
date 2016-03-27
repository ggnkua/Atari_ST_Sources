;*******************************************************
;**      The Great Universal Copy Program 1.0         **
;**               THE PARA 1989                       **
;*******************************************************


		opt o+
		opt w-
		
;***** EQUATES *****

pcon		equ $ffff8800
printer		equ $ffff8802
dmalow 		equ $ffff860d
dmamid		equ $ffff860b
dmahigh		equ $ffff8609
dmactrl		equ $ffff8606
fdcreg		equ $ffff8604
fdcstat		equ $fffffa01
side		equ 0
write 		equ 2
step 		equ 3
drive		equ 1
motor		equ 5
direction	equ 4
side_0		equ 253
side_1		equ 252
off		equ 255


;***** MACROS *****

;Equivalents of Z80 push and pop. Require both size and data.
push		macro
		move.\0 \1,-(a7)
		endm
pop		macro
		move.\0 (a7)+,\1
		endm
		
;Call gemdos. Requres function number and stack correction.
gdos		macro
		push.w #\1
		trap #1
		addq.l #\2,a7
		endm
		
;Call bios. Requires function number and stack correction.
bios		macro
		push.w #\1,-(a7)
		trap #13
		addq.l #\2,a7
		endm
		
;Call xbios.
xbios		macro
		push.w #\1
		trap #14
		addq.l #\2,a7
		endm
		
;Print a null terminated string. Requires string address.
print		macro
		move.l #\1,-(a7)
		gdos 9,6
		endm

;Print a number in decimal form (two digit only).
print_num	macro
		push.l d0
		clr.l d0
		move.w \1,d0
		divu #10,d0
		print_ascii d0
		swap d0
		print_ascii d0
		pop.l d0
		endm
		
;Print the ascii value character in the lower word of d0.
print_ascii	macro
		push.l d0
		add.w #48,d0
		push.w d0
		gdos 2,4
		pop.l d0
		endm
		
;Set a bit of the printer port. Requires bit number.
offbit		macro
		move.b #15,pcon
		move.b pcon,d0
		bset #\1,d0
		move.b d0,printer
		endm
		
;Reset printer bit.
onbit		macro
		move.b #15,pcon
		move.b pcon,d0
		bclr #\1,d0
		move.b d0,printer
		endm
		
;Pause for a multiple of 0.1ms
pause		macro
		move.w #0,done
		move.l #event,-(a7)
		move.w #\1,-(a7)
		move.w #6,-(a7)
		move.w #0,-(a7)
		move.w #31,-(a7)
		trap #14
		add.l #12,a7
loop1\@		cmp #1,done
		bne loop1\@
		move.w #13,-(a7)
		move.w #26,-(a7)
		trap #14
		addq.l #4,a7
		endm

;Delay for disk controller.
dsk_delay	macro
		push.w sr
		push.w d7
		move.w #$20,d7
dsk_loop1\@	dbra d7,dsk_loop1\@
		pop.w d7
		pop.w sr
		endm
		
;Send a command to the fdc. Requires command byte.
fdc_com		macro
		dsk_delay
		move.w \1,fdcreg
		dsk_delay
		endm
		
;Step drive b.
step_b		macro
		onbit step
		pause 20
		offbit step
		pause 60
		endm
		
;Restore drive b to track 0.
restore_b	macro
		offbit write
		onbit drive
		onbit motor
		offbit direction
resb_loo\@	step_b
		push.w #0
		bios 8,4
		cmp #0,d0
		beq resb_loo\@
		endm
		
;Test to see if fdc finished command, with timeout.
tst_done	macro
		move.l #$100000,d7
dloo\@		btst #5,fdcstat
		beq done_1772\@
		subq.l #1,d7
		bne dloo\@
done_1772\@	nop
		endm

;Set dma address.
set_dma		macro
		move.b d7,dmalow
		lsr.l #8,d7
		move.b d7,dmamid
		lsr.l #8,d7
		move.b d7,dmahigh
		endm

;Restore drive A to track00.
restore		macro
		move.w #$80,dmactrl
		fdc_com #0
		tst_done
		endm
		
;Step drive A.
step_a		macro
		move.w #$80,dmactrl
		fdc_com #$41
		tst_done
		endm
		
;Send a drive/side select byte to sound chip.
select		macro
		move.l #(14*65536*256+\1*256),pcon
		endm

;Read 6 ID fields from the disk. ID's stored at idbuf, status bytes at stbuf.
;Note that if no ID fields found, errflag is set.		
rd_address	macro
		clr.b errflag
		move.l #stbuf,a5
		clr.b 6(a5)
		move.l #dmactrl,a6
		move.l #idbuf,d7
		set_dma
		move.w #$90,(a6)
		move.w #$190,(a6)
		move.w #$90,(a6)
		fdc_com #$01
		move.w #$80,(a6)
		move.w #5,d4
idloop\@	fdc_com #$c0
idwait\@	btst #5,fdcstat
		bne idwait\@
		move.w fdcreg,d0
		dsk_delay
		move.b d0,(a5)+
		btst #4,d0
		beq hello\@
		move.w #0,d4
		st.b errflag
hello\@		dbra d4,idloop\@
noid\@
		endm
		
;Read sector with ID at idbuf. If ID field or sector corrupt, try another.
rd_sect		macro
		move.l #stbuf,a5
		move.l #idbuf,a3
try\@		tst.b 1(a5)
		beq oksect\@
		cmp.b #$80,(a5)
		bne again\@
		move.b 2(a3),d2
		cmp.b #$b,d2
		ble oksect\@
		cmp.b #$d,d2
		bge oksect\@
again\@		addq.l #6,a3
		addq.l #1,a5
		bra try\@ 
oksect\@	move.l #buffer,d7
		set_dma
		move.l #dmactrl,a6
		move.w #$90,(a6)
		move.w #$190,(a6)
		move.w #$90,(a6)
		fdc_com #$0c
		move.w #$84,(a6)
		fdc_com d2
		move.b (a3),d2
put\@		move.w #$82,(a6)
		fdc_com d2
		move.w #$80,(a6)
		fdc_com #$80
sect\@		btst #5,fdcstat
		bne sect\@
		move.w fdcreg,d0
		cmp.b #$80,d0
		beq read_s\@
		cmp.b #$a0,d0
		beq read_s\@
		tst.b 1(a5)
		bne again\@
		print err
read_s\@	
		endm

;Copy the current track/side.		
cpytrk		macro
		move.b #1,$43e
		clr.b errflag
		move.b #15,pcon
		move.b pcon,d5
		bset #2,d5
		rd_address
		tst.b errflag
		bne none\@
		rd_sect
none\@		clr.b $43e
		endm
	
;***** The Main Program *****

		push.l #mainprog
		xbios 38,6
		push.w #0
		trap #1	
mainprog	offbit write
		offbit drive
		offbit motor
		offbit step
		xbios 4,2
		cmp.w #0,d0
		bne notlow
		push.w #$1
		push.l #-1
		push.l #-1
		push.w #5
		trap #14
		add.l #12,a7
		push.w #-1
		push.w #0
		xbios 7,6
		move.w d0,stor0
		push.w #-1
		push.w #3
		xbios 7,6
		move.w d0,stor3
		push.w #$047
		push.w #0
		xbios 7,6
		push.w #$777
		push.w #3
		xbios 7,6
		st.b lowflag
notlow		move.w #0,single
		print title
		print menu
invalid		gdos 8,2
		swap d0
		cmp.b #1,d0
		beq exitprog
		cmp.b #32,d0
		beq double
		cmp.b #23,d0
		bne notins
		print instrs
		gdos 8,2
		bra notlow
notins		cmp.b #31,d0
		bne invalid
		move.w #1,single
double		print doing
		print linefeeds
		print escmes
		onbit drive
		onbit direction
		onbit motor
		restore_b
		select side_0
		restore
		move.l #81,d0
		move.w #0,track
		onbit direction
track_loop	print location
		print_num track
		onbit drive
		offbit side
		print mside0
		onbit write
		cpytrk
	 	move.b d5,printer
test		bsr esccheck
		beq mainprog
		cmp.w #1,single
		beq ntrack
		onbit side
		select side_1
		onbit drive
		print mside1
		onbit write
		cpytrk
		move.b d5,printer
		bsr esccheck
		beq mainprog
		select side_0
ntrack		onbit direction
		step_b
		step_a
		add.w #1,track
		cmp.w #83,track
		bne track_loop
		offbit drive
		offbit motor
		bra notlow
exitprog	tst.b lowflag
		beq retu
		push.w stor0
		push.w #0
		xbios 7,6
		push.w stor3
		push.w #3
		xbios 7,6
		push.w #0
		push.l #-1
		push.l #-1
		push.w #5
		trap #14
		add.l #12,a7
retu		rts
esccheck	push.w #2
		bios 1,4
		not d0
		tst.w d0
		bne doneesc
		push.w #2
		bios 2,4
		swap d0
		cmpi.w #1,d0
doneesc		rts 
pkey		dc.b "Press any key to stop drive.",13,10,0
title		dc.b 27,"E",27,"f"
		dc.b "*******************************************************************************",13,10
		dc.b "**                     The Great Universal Back-up Utility                   **",13,10
		dc.b "**                                Version 1.0                                **",13,10
		dc.b "**                          Written by THE PARA in 1989                      **",13,10
		dc.b "*******************************************************************************",13,10
		dc.b 10,10,0
linefeeds	dc.b 13,10,10,0
instrs		dc.b 27,"E",13,10
		dc.b "                    The Great Universal Back-up Utility V1.0",13,10
		dc.b "                                 FROM THE PARA 1989",13,10
		dc.b 13,10,13,10
		dc.b "  This program, together with its associated hardware, should back up ANY piece",13,10
		dc.b "of software, no matter how protected the disk may be. One possible exception to",13,10
		dc.b "this is the 'laser burnt' disks, which thankfully I have not come accross yet. ",13,10
		dc.b "Obviously however the program has not been tested with 100 percent of software!",13,10
		dc.b 13,10
		dc.b "  The program always copies 83 tracks (0-82), as the additional time taken to",13,10
		dc.b "copy the extra tracks did not warrant an option. However, if you are in a real",13,10
		dc.b "hurry, press ESC when the unformatted tracks are reached.",13,10,13,10
		dc.b "  If the message '***** Possible Copy Failure *****' appears, do not panic!",13,10
		dc.b "This usually indicates that the source disk is corrupt, if it works then the",13,10
		dc.b "copy should be O.K.",13,10,13,10
		dc.b "  Remember, only back up your own software, as piracy is ILLEGAL. Backing up",13,10
		dc.b "other people's for them does not count!!",13,10,13,10
		dc.b "  Program assembled with Hisoft's brilliant Devpac 2",13,10,13,10
		dc.b "Press any key.",0
menu		dc.b "Select:-",13,10
		dc.b "  S: start single sided copy",13,10
		dc.b "  D: start double sided copy",13,10
		dc.b "  I: program information",13,10
escmes		dc.b "  ESC to exit",13,10,0
doing		dc.b 27,"Y",39,32,27,"J"
		dc.b "Copying track",0	
location	dc.b 27,"Y",39,46,0
mside0		dc.b 27,"Y",39,49,"side 0",0
mside1		dc.b 27,"Y",39,49,"side 1",0	
finish		dc.b "Any key for desktop.",13,10,0
err		dc.b 13,10,13,10,13,10
		dc.b "***** Possible Copy Failure *****",0
		even
lowflag		dc.b 0
errflag		dc.b 0
stor0		dc.w 0
stor3		dc.w 2
		
;***** The timer A event handling routine. *****

event		move.w #1,done
		rte
track		dc.w 0
done		dc 0,0,0,0
single 		dc.w 0

;***** The track buffer. *****
		
idbuf		ds.l 1
stbuf		equ idbuf+50
buffer		equ idbuf+70
		end
