;-----------------------------------------------------------------------;
;  		              - Loader Screen -                            	;
; All Code (C) 1990 Martin Griffiths - Griff of The Inner Circle		;
; This is the loader screen the screen inbetween menu and demo...		;
; Is programmed to be compact and fast - about 30k when resident.		;
; LZH depack code is by Griff. Thanks go to Russel Payne for help.	;
; Please credit me if you use any of the code contained in this screen	;
; e.g the interrupt dma loader, lzh depack code etc...			;
;-----------------------------------------------------------------------;

		OPT O+,OW-

; demo 0 - The Main menu!
; demo 1 - The Parallax scroll
; demo 2 - The flexiscroll
; demo 3 - Quartet screen
; demo 4 - Where's my willy
; demo 5 - Insignificant demo
; demo 6 - Gigadist
; demo 7 - Wow!Scroll 2
;demo 8 - Red Herrings
; demo 9 - The 3d dots screen
; demo 10 - The Raster scroll
; demo 11 - The Pipeworx demo
; demo 12 -	Hotline guest screen
; demo 13 - The vector screen
; demo 14 - The mixuload
		
demo		EQU 1				run from gem/demo - 0/1

screen1	EQU $78100			screen pointer
tlength	EQU 19			spaces on screen for name etc

* On entry to the loader,D0 contains 'demo' to load.
* using d0 setup various stuff ready for loading.

* This crap is needed if we run from gem...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

		IFEQ demo			
		move.l d0,-(sp)
		CLR -(SP)					switch to low res
		PEA -1.W					no change scr bases
		PEA -1.W
		MOVE #5,-(SP)				xbios(5)
		TRAP #14
		LEA 12(SP),SP
		MOVE #37,-(SP)
		TRAP #14					xbios(37) - waitvbl
		ADDQ.L #2,SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1					super
		ADDQ.L #6,SP 
		move.l (sp)+,d0
		LEA old_mfp(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+		save some vectors
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.L $70.W,old_vbl			old vbl interrupt
		ENDC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

; On entry :-  (parameter passed from main menu)
; D0 - demo no to load and run...

runit		MOVE #$2700,SR				bye bye interrupts
		LEA $80000,SP
		MOVE.L D0,-(SP)
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA0B.W
		CLR.B $FFFFFA0D.W
		CLR.B $FFFFFA0F.W
		CLR.B $FFFFFA11.W
		BCLR.B #3,$FFFFFA17.W
		BSR ourvects
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVEQ #0,D7
		MOVE.W D0,hblfade
		MOVE.W D0,loading
		MOVE.W D0,depacking
		MOVEM.L D0-D7,$FFFF8240.W
		LEA pal+96(PC),A0
		MOVEM.L D0-D7,-(A0)
		MOVEM.L D0-D7,-(A0)
		MOVEM.L D0-D7,-(A0)
		BSR Flush					flush key buffer
		MOVE.B #$12,$FFFFFC02.W			kill the mouse
		BSR clearmemory
		MOVE.L (SP)+,D0
		TST D0
		BEQ mainmenu
		LEA demotab(PC),A0			point to demo vectors
		ADD D0,D0					get
		ADD D0,D0					longword offset
		MOVE.L (A0,D0),A0				get address
		LEA diskstuff(PC),A1
		MOVE (A0)+,(A1)+				side the screen is on
		MOVE (A0)+,(A1)+				sector offset
		MOVE (A0)+,(A1)+				no. of sectors to load
		LEA pointerstuff(PC),A1
		MOVE.L A0,(A1)+				demo name pointer
		LEA tlength(A0),A0
		MOVE.L A0,(A1)+				demo group name pointer
		LEA tlength(A0),A0
		MOVE.L A0,(A1)+				little scroll text pointer
		MOVE.L A0,(A1)+				store again for wrap....
		MOVEQ #1,D0
		BSR music+28
		MOVE.L #screen1,D0
		LSR #8,D0					set screen base
		MOVE.L D0,$FFFF8200.W
		MOVE.L #first_vbl,$70.W			our vbl
Set_ints	MOVE.B #1,$FFFFFA07.W
		CLR.B $FFFFFA09.W				set interrupt
		MOVE.B #1,$FFFFFA13.W
		CLR.B $FFFFFA15.W
		BCLR.B #3,$FFFFFA17.W			software end of interrupt
		CLR.B $FFFFFA1B.W
		CLR.B $FFFFFA21.W
Decomppic	LEA depack_pic(PC),A0
		LEA screen1-34,A1
		BSR Depack
		MOVEM.L screen1-32,D0-D7
		LEA pal(pc),a1
		MOVEM.L D0-D7,(a1)
		MOVE.W #$045,8(a1)			lawrence cocked up palette!
		BSR setupload				print screen name etc	
		MOVE #$2300,SR				enable interrupts
		BSR Fade_in					fade in piccy
		MOVE.L #vbl,$70.w
		BSR Do_load					go for the load
		BSR Flush					flush key buffer
		BSR lzhdepack
		BSR Relocateit
		MOVE.L A0,-(SP)
		MOVE #6,hblfade
waitspace	BTST.B #0,$FFFFFC00.W
		BEQ waitspace
		MOVE.B $FFFFFC02.W,D0
		CMP.B #$39+$80,D0
		BNE waitspace
		MOVE #$2700,SR
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA0B.W
		CLR.B $FFFFFA0D.W
		CLR.B $FFFFFA0F.W
		CLR.B $FFFFFA11.W
		MOVE #$8240,A0
		REPT 8
		CLR.L (A0)+
		ENDR
		MOVEQ #0,D0
		BSR music+28
		LEA $7ff00,A0
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVE.L D6,A1
		MOVE #($7ff00-$75000)/128-1,D7
clearpackthng	
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		DBF D7,clearpackthng
		BSR Flush
		BSR ourvects
		BSR Flush
		MOVE.L (SP)+,A0
		JSR (A0)
		MOVE #$2700,sr
		MOVEQ #0,D0
		BRA runit

reset_ints	IFEQ demo
		MOVE #$2700,SR
		BSR Flush
		MOVE.B #$8,$FFFFFC02.W			
		MOVE.L old_vbl(PC),$70.W
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		MOVE.L #$07770000,$FFFF8240.W
		MOVE.L #$00000000,$FFFF8244.W
		CLR -(SP)
		TRAP #1
		ENDC	

; Install vectors

ourvects	LEA $8.W,A0
		LEA bombout(PC),A1
inst1_lp	MOVE.L A1,(A0)+
		CMP.L #$40,A0
		BNE.S inst1_lp
		LEA $60.W,A0
		LEA plainrte(PC),A1
inst2_lp	MOVE.L A1,(A0)+
		CMP.L #$200,A0
		BNE.S inst2_lp 
		RTS

plainrte	RTE

bombout	MOVE #$2700,SR
		MOVE.B #$7,$FFFF8800.W
		MOVE.B #-1,$FFFF8802.W
		MOVE #$700,$FFFF8240.W	
forever	BRA.S forever

; Load,decode,depack the main menu

mainmenu	MOVE #$2500,SR
		BSR Flush
		TST onemegflag
		BNE itsin1meg 
		CLR.W side
		MOVE #488,sectoffset
		MOVE #109,sectstoload
		BSR Do_load
		MOVE #$2700,SR
		LEA file,A0
		LEA file+$200,a1
		BSR Depack
		LEA file+$200,a0
		BSR dorel
		LEA file+$200,A0
		LEA $a0000,a1
copy		move.l #180000/64,d7
copytoloop	rept 16
		move.l (a0)+,(a1)+
		endr
		dbf d7,copytoloop
		CMP #$601A,$A0000
		BNE notonemeg
		MOVE #-1,onemegflag
notonemeg	CLR.B $FFFFFA0B.W
		CLR.B $FFFFFA0D.W
		CLR.B $FFFFFA0F.W
		CLR.B $FFFFFA11.W
		BSR Flush
		JSR file+$200			; run menu
		MOVE #$2700,SR
		BRA runit
onemegflag	DC.W 0

; Copy from one meg into ram

itsin1meg	move #$2700,sr
		LEA file+$200,A1
		LEA $a0000,a0
		bra copy

***************************************************************************
***************************************************************************
;                           The dma load code                             ;
***************************************************************************
***************************************************************************

Seekrate	EQU 3
Sectptr	EQU 10

Do_load	ST loading					say were loading
		SF fin_load					haven't finished yet
		MOVEQ #0,D1
		MOVE sectstoload(PC),D0			no. sects to load
		MOVE sectoffset(PC),D1			sector offset
		LEA file,A0					address
		DIVU #Sectptr,D1				calc track offset
		MOVE D1,seektrack				seek this track
		MOVE D1,currtrack				
		SWAP D1					remainder+1 =
		ADDQ #1,D1					start sector within
		MOVE D1,sector				sector.
		MOVE.L A0,pointer				
		MOVE D0,no_sects				sectors to go
		BSR setdiskint				setup interrupts
		BSR seldrive				select drive & side
		BSR do_seek					do the seek
wait_disk	TST.B fin_load
		BEQ.S wait_disk
		MOVE SR,-(SP)
		MOVE #$2700,SR
		BCLR #7,$FFFFFA09.W			clear int enable for fdc int
		BCLR #7,$FFFFFA15.W			clear int mask for fdc int
		BSET #5,$FFFFFA03.W			unactive!
		MOVE.W (SP)+,SR
		SF loading
		RTS

* Setup mfp for disk interrupts.

setdiskint	MOVE.W SR,-(SP)
		MOVE #$2700,SR
		BCLR #5,$FFFFFA03.W			active edge
		BSET #7,$FFFFFA09.W			set int enable for fdc int
		BSET #7,$FFFFFA15.W			set int mask for fdc int
		MOVE.L #read_rout,$11C.W
		MOVE.W (SP)+,SR
		RTS

* Send a seek command and track to seek to the floppy controller.

do_seek	MOVE #$86,$FFFF8606.W
		MOVE seektrack(PC),D5
		BSR writefdc
		MOVE #$80,$FFFF8606.W
		MOVEQ #16+4+3,D5
		BSR writefdc
		RTS

read		MOVE.W D0,-(SP)
		MOVE.W #$80,$FFFF8606.W			select status
		MOVE.W $FFFF8604.W,D0			read status from last load
		BTST #3,D0				
		BEQ.S okay1
		BRA.S loaderror
okay1		BTST #4,D0
		BEQ.S okay2
loaderror	ADDQ #1,no_sects
		SUB.L #512,pointer			retry loading!
		SUBQ #1,sector
okay2		MOVE.W (SP)+,D0
		ADDQ #1,sector				next sector
		CMP #Sectptr,sector			new track?
		BGT.S stepin				yes/no -
read_rout	MOVE.B pointer+3(PC),$FFFF860D.W	load sector
		MOVE.B pointer+2(PC),$FFFF860B.W	dma address count
		MOVE.B pointer+1(PC),$FFFF8609.W
		MOVE.W #$90,$FFFF8606.W
		MOVE.W #$190,$FFFF8606.W		fifo enable read
		MOVE.W #$90,$FFFF8606.W
		BSR fwait
		MOVE.W #1,$FFFF8604.W 			read 1 sector
		MOVE.W #$84,$FFFF8606.W
		BSR fwait
		MOVE.W sector(PC),$FFFF8604.W		say which sector
		MOVE.W #$80,$FFFF8606.W			read it
		BSR fwait
		MOVE.W #$80,$FFFF8604.W			
		ADD.L #512,pointer			add to pointer
		SUBQ #1,no_sects				decrement total sects
		BEQ.S INT_DONE				to load.if done exit
		MOVE.L #read,$11C.W			
		RTE

* Step in a track and then continue reading

stepin	MOVE #1,sector				reset sector count
		ADDQ #1,currtrack				next track
		MOVE.L #read_rout,$11C.W		continue reading
step		MOVE #$80,$FFFF8606.W			send seek
		BSR fwait
		MOVE #64+16+8+4+3,$FFFF8604.W		command to controller
		RTE

INT_DONE	MOVE.L #INT_EXIT,$11C.W			sectors loaded
		ST fin_load					set flag to say so
INT_EXIT	RTE

fwait		MOVE.L D0,-(SP)
		MOVEQ #19,D0
aw		DBF D0,aw
		MOVE.L (SP)+,D0
		RTS

* Write d5 to fdc

writefdc	MOVE.L D6,-(SP)
		MOVE.W SR,-(SP)
		BSR waitf
		MOVE D5,$FFFF8604.W
		BSR waitf
		MOVE.W (SP)+,SR
		MOVE.L (SP)+,D6
		RTS

waitf		MOVEQ #32,D6
waitflp	DBF D6,waitflp
		RTS

* Select current drive/side

seldrive	MOVE.W $446.W,D0				get bootdevice
		AND #1,D0					isolate first bit
		ADDQ #1,D0
		ADD D0,D0					calc right bit
		OR side(PC),D0
		EOR.B #7,D0
select	MOVE.B #$E,$FFFF8800.W			select psg
		MOVE.B $FFFF8800.W,D1				
		AND.B #$F8,D1				
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W			select drive/side
		RTS

seektrack	DS.W 1
currtrack	DS.W 1
pointer	DS.L 1
no_sects	DS.W 1
sector	DS.W 1
fin_load	DS.W 1

; Program relocator

Relocateit	LEA file(PC),A0
		MOVEQ #0,D2
dorel		MOVE.L 2(A0),D0
		ADD.L $6(A0),D0
		ADD.L $E(A0),D0
		LEA $1C(A0),A0
		MOVE.L A0,A1
		MOVE.L A0,A2
		MOVE.L A0,D1
		ADD.L D0,A1
		MOVE.L (A1)+,D0
		ADD.L D0,A2
		ADD.L D1,(A2)
		MOVEQ #0,D0
rel_lp	MOVE.B (A1),D0
		MOVE.B D2,(A1)+
		TST.B D0
		BEQ.S rel_done
		CMP.B #1,D0
		BEQ.S rel_1
		ADD.L D0,A2
		ADD.L D1,(A2)
		BRA.S rel_lp
rel_1		LEA $FE(A2),A2
		BRA.S rel_lp
rel_done	RTS

; Unpacking source for Pack-Ice Version 2.1
; a0: Pointer on packed Data
; a1: Pointer on destination of unpacked data

igetbit	macro
		add.l	d7,d7
		bne.s	nofetch\@
ice_0d\@	move.w	a5,d7
		btst	#0,d7
		bne.s	ice_0e\@
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s nofetch\@
ice_0e\@	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
nofetch\@
		endm

Depack	movem.l d0-a6,-(sp)
		addq.l #4,a0
		move.l (a0)+,d0		; read packed data
		lea -8(a0,d0.l),a5
		move.l (a0)+,(sp)
		movea.l a1,a4
		movea.l a1,a6
		adda.l (sp),a6
		lea ice_0f(PC),a3
		bsr ice_08
		bsr ice_04
ice_03:	movem.l (sp)+,d0-a6
		rts
ice_04:	igetbit
		bcc.s	ice_07
		moveq	#0,d1
		igetbit
		bcc.s	ice_06
		lea	ice_1a(pc),a1
		moveq	#4,d3
ice_05:	move.l	-(a1),d0
		jsr (a3)
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice_05
		add.l	20(a1),d1
ice_06:	move.b	-(a5),-(a6)
		dbra	d1,ice_06
ice_07:	cmpa.l	a4,a6
		bgt.s	ice_12
		rts
		even
ice_08:	rept 4
		move.b -(a5),d7
		ror.l	#8,d7
		endr
		rts
ice_0a:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice_0b
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice_11
ice_0b:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
ice_11a:	addx.w	d1,d1
		dbra	d0,ice_10
		rts

ice_0f:	moveq	#0,d1
ice_10:	add.l	d7,d7
		beq.s	ice_0a
ice_11:	addx.w	d1,d1
		dbra	d0,ice_10
		rts
ice_12:	moveq	#3,d2
ice_13:	igetbit
		dbcc	d2,ice_13
		moveq	#0,d4
		moveq	#0,d1
		move.b	ice_1b+1(pc,d2.w),d0
		ext.w	d0
		bmi.s	ice_14
		jsr (a3)
ice_14:	move.b	ice_1b+6(pc,d2.w),d4
		add.w	d1,d4
		beq.s	ice_16
		moveq	#1,d2
ice_15:	igetbit
		dbcc	d2,ice_15
		moveq	#0,d1
		move.b	ice_1c+1(pc,d2.w),d0
		ext.w	d0
		jsr (a3)
		add.w	d2,d2
		add.w	ice_1c+6(pc,d2.w),d1
ice_18a:	lea 2(a6,d4.w),a1
		adda.w d1,a1
		move.b -(a1),-(a6)
ice_19a:	move.b -(a1),-(a6)
		dbra d4,ice_19a
		bra ice_04
ice_1b:	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
		DC.B $01,$00
ice_1c:	DC.B $0b,$04,$07,$00,$01,$20,$00,$00
		DC.B $00,$20

ice_16:	moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		igetbit
		bcc.s	ice_17
		moveq	#8,d0
		moveq	#$40,d2
ice_17:	jsr (a3)
		add.w	d2,d1
ice_18:	lea 2(a6,d4.w),a1
		adda.w d1,a1
		move.b -(a1),-(a6)
ice_19:	move.b -(a1),-(a6)
		dbra d4,ice_19
		bra ice_04

		DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
		DC.B $00,$07,$00,$02,$00,$03,$00,$01
		DC.B $00,$03,$00,$01
ice_1a:	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
		DC.B $00,$00,$00,$07,$00,$00,$00,$04
		DC.B $00,$00,$00,$01

***************************************************************************

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
;                        Depack .LZH file 					;
; The file is depacked above the depacked file unlike most depackers	;
; but I have now added a routine to relocate it back to the packed file ;
; address at the end....								;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

N		equ	4096
F		equ	60
THRESHOLD	equ	2
NIL		equ	N
N_CHAR	equ	(256-THRESHOLD+F)
T		equ	(N_CHAR*2-1)
R		equ	(T-1)
MAX_FREQ	equ	32768

d_code	equ $75000
d_len		equ d_code+512
freq		equ d_len+512
son		equ freq+((T+1)*2)
prnt		equ son+(T*2)
text_buf	equ prnt+(T+N_CHAR)*2

; read a single bit from the packed data

getbitl	macro
		add.b d7,d7
		bne.s notzero\@
		move.b (a0)+,d7
		addx.b d7,d7
notzero\@	
		endm

; First generate bit tables

lzhdepack	lea file(pc),a0
		lea 11+4(a0),a2
		lea xoutput,a1
		move.b -(a2),d7
		rol.w	#8,d7
		move.b -(a2),d7
		swap d7
		move.b -(a2),d7
		rol.w	#8,d7
		move.b -(a2),d7
		moveq	#0,d0
		move.b (a0)+,d0
		lea 1(a0,d0.w),a0
		move.l a1,a6
		add.l d7,a6

; a0 = pointer to LZH data
; a1 = pointer to output
; a6 = pointer to end of output(unpacked)
; d7 = number of bytes to unpack

		bsr starthuff
		lea.l	d_code,a2
		bsr gendcode
		lea.l d_len,a2
		bsr gendlen
		moveq	#$20,d0
		move.w #N-F-1,d1
		lea.l text_buf,a2
.clrbuf	move.b d0,(a2)+
		dbra	d1,.clrbuf
		move.w #N-F,d6
		lea.l son,a2
		move.l a2,usp
		move.l d7,-(sp)
		move.b #$80,d7				;clear bitbuf
		move #-1,depacking
		lea text_buf,a5

;-----------------------------------------------------------------------;
; Main unpacking loop									;
; d7 = count										;
; d6 = R											;
;-----------------------------------------------------------------------;
;------------------;
; decode character ;
;------------------;

unpackloop	move.l usp,a2				;decode character
		move.w R*2(a2),d0				;son[r]
		move #T,d2
wloop1 	getbitl
		bcc.s noadd1
		add.w d0,d0
		move.w 2(a2,d0.w),d0
		cmp.w d2,d0
		bcs.s wloop1
		bra.s wover
noadd1	add.w d0,d0
		move.w 0(a2,d0.w),d0			;c=son[c]
		cmp.w d2,d0
		bcs.s wloop1
wover		move.w d0,d5

; update d0=character

update	lea.l freq,a2
		cmp.w	#MAX_FREQ,R*2(a2)
		beq reconst
noregen	lea.l prnt,a2
		add.w	d0,d0
		move.w 0(a2,d0.w),d0
.doloop	lea.l freq,a2
		add.w	d0,d0				;c*2
		move.l a2,a3
		adda.w d0,a3
		addq.w #1,(a3)
		move.w (a3)+,d1
		cmp.w	(a3)+,d1
		bls .endif
.wloop	cmp.w	(a3)+,d1
		bhi.s	.wloop
		subq.l #4,a3
		move.w (a3),0(a2,d0.w)		;freq[c]=freq[l]
		move.w d1,(a3)
		sub.l	a2,a3
		move.w a3,d2
		move.l usp,a2
		lea.l	prnt,a3
		move.w 0(a2,d0.w),d3		;i=son[c]
		add.w	d3,d3
		lsr.w	#1,d2
		move.w d2,0(a3,d3.w)		;prnt[i]=l
		cmp.w	#T*2,d3
		bcc.s	.nosi
		move.w d2,2(a3,d3.w)		;prnt[i+1]=l
.nosi		add.w	d2,d2
		move.w 0(a2,d2.w),d4		;j=son[l]
		lsr.w	#1,d3
		move.w d3,0(a2,d2.w)		;son[l]=i
		lsr.w	#1,d0
		add.w	d4,d4
		move.w d0,0(a3,d4.w)		;prnt[j]=c
		cmp.w	#T*2,d4
		bcc.s	.nosj
		move.w d0,2(a3,d4.w)		;prnt[j+1]=c
.nosj		add.w	d0,d0
		lsr.w	#1,d4
		move.w d4,0(a2,d0.w)		;son[c]=j
		move.w d2,d0			;c=l
.endif	lea.l prnt,a2
		move.w 0(a2,d0.w),d0		;c=prnt[c]
		bne .doloop
		
		cmp.w #256+T,d5
		bge.s doposition
		sub.w #T,d5
		move.b d5,(a1)+			;output(c)
		move.b d5,(a5,d6.w)		;textbuf[r] = c;
		addq.w #1,d6
		and.w #N-1,d6
		cmp.l a1,a6
		bgt unpackloop			;repeat for rest
		bra unpackdone

doposition	
; decode position
		moveq #0,d4
		rept 8
		getbitl
		addx.b d4,d4
		endr
		move.w d4,d1
		add d1,d1
		lea.l d_len,a2
		move.w 0(a2,d1.w),d2
wloop		getbitl
		addx.w d4,d4
		dbf d2,wloop
zero		and.w #$3f,d4
		lea.l d_code,a2
		or.w 0(a2,d1.w),d4
		move.w d6,d1
		sub.w d4,d1				;r - decodepos() -1
		subq.w #1,d1
		sub.w #255-THRESHOLD+1+T,d5	;c - 255 + threshold  +1(dbf)
		move #N-1,d4
.floop	and.w	d4,d1
		move.b 0(a5,d1.w),d0		;c = textbuf[]
		move.b d0,(a1)+
		move.b d0,0(a5,d6.w)
		addq.w #1,d6			;r++
		and.w	d4,d6
		addq.w #1,d1
		dbf d5,.floop
		cmp.l a1,a6
		bgt unpackloop

; Depack is done...
unpackdone	move.l (sp)+,d7
		move.w vbl_timer(pc),d0
waitquim	cmp vbl_timer(pc),d0
		beq waitquim
		clr depacking
		lea xoutput,a0
		lea file(pc),a1
		moveq #0,d0
		moveq #16,d1
reloc_lp	move.l (a0),(a1)+
		move.l d0,(a0)+
		move.l (a0),(a1)+
		move.l d0,(a0)+
		move.l (a0),(a1)+
		move.l d0,(a0)+
		move.l (a0),(a1)+
		move.l d0,(a0)+
		sub.l d1,d7
		bgt.s reloc_lp
		rts

;
; reconstruct
;

reconst	movem.l d5/a5,-(sp)
		moveq	#0,d1
		moveq	#0,d2
		move.l usp,a2
		lea.l freq,a3
.floop1	move.w 0(a2,d1.w),d3		;son[i]
		cmp.w	#T,d3
		bcs.s	.if1
		move.w 0(a3,d1.w),d4		;freq[i]
		addq.w #1,d4
		asr.w	#1,d4
		move.w d4,0(a3,d2.w)		;freq[j]=(freq[i]+1)/2
		move.w d3,0(a2,d2.w)		;son[j]=son[i]
		addq.w #2,d2
.if1		addq.w #2,d1
		cmp.w	#T*2,d1
		blt.s	.floop1
		moveq	#0,d1				;i=0
		move.w #N_CHAR*2,d2		;j=n_char
.floop2	move.w 0(a3,d1.w),d3
		add.w	2(a3,d1.w),d3
		move.w d3,0(a3,d2.w)		;freq[j] = freq[i]+freq[i+1]
		move.w d2,d4
.floop3	subq.w #2,d4			;k--
		cmp.w	0(a3,d4.w),d3
		bcs.s	.floop3			;while f<freq[k]
		addq.w #2,d4
		lea 0(a3,d4.w),a4			;from
		lea 2(a4),a5			;to
		move.w d2,d5
		sub.w	d4,d5				;(j-k)*2
		beq.s	.nomov1
		move.w d5,d0
		add.w	d0,a4
		add.w	d0,a5
		subq.w #1,d0
.movmem1	move.b -(a4),-(a5)
		dbra	d0,.movmem1
		lea 0(a2,d4.w),a4
		lea 2(a4),a5
		move.w d5,d0
		add.w	d0,a4				;from
		add.w	d0,a5				;to
		subq.w #1,d0
.movmem2	move.b -(a4),-(a5)
		dbra	d0,.movmem2
.nomov1	move.w d3,0(a3,d4.w)		;freq[k]=f
		move.w d1,d0
		lsr.w	#1,d0
		move.w d0,0(a2,d4.w)		;son[k]=i
		addq.w #4,d1			;i+=2
		addq.w #2,d2			;j++
		cmp.w	#T*2,d2
		blt.s	.floop2
		moveq	#0,d1				;i=0
		moveq	#0,d2
		lea.l prnt,a3
.floop4	move.w 0(a2,d2.w),d3
		add.w	d3,d3
		cmp.w	#T*2,d3
		bcc.s	.if3
		move.w d1,2(a3,d3.w)
.if3		move.w d1,0(a3,d3.w)
		addq.w #2,d2
		addq.w #1,d1
		cmp.w	#T,d1
		blt.s	.floop4
		movem.l (sp)+,d5/a5
		move.w d5,d0
		bra noregen

;
; generate d_code lookup table
; a2 = destination
;

gendcode	lea .gtab(pc),a3
		moveq	#0,d0
		moveq	#32,d1
		move.w (a3)+,d2
.outer	move.w d1,d3
		subq.w #1,d3
.inner	move.w d0,(a2)+
		dbra d3,.inner
		add.w #64,d0
		dbra d2,.outer
		asr.w	#1,d1
		move.w (a3)+,d2
		bpl.s	.outer
		rts

.gtab		dc.w	1-1,3-1,8-1,12-1,24-1,16-1,-1

;
; generate d_len lookup table
; a2 = destination
;

gendlen	lea .gtab(pc),a3
		moveq	#0,d0
		move.w (a3)+,d1
.loop		move.w d0,(a2)+
		dbra d1,.loop
		addq.w #1,d0
		move.w (a3)+,d1
		bpl.s	.loop
		rts
.gtab		dc.w	32-1,48-1,64-1,48-1,48-1,16-1,-1

;
; start huffman code
;
starthuff	moveq	#0,d0
		lea.l freq,a2
		lea.l	son,a3
		lea.l	prnt,a4
.loop		move.w #1,(a2)+			;freq[i]=1
		move.w d0,d1
		add.w	#T,d1
		move.w d1,(a3)+			;son[i]=T+i
		add.w	d1,d1	
		move.w d0,0(a4,d1.w)		;prnt[i+T]=i
		addq.w #1,d0
		cmp.w	#N_CHAR,d0
		blt.s .loop
		moveq	#0,d0				;i=0
		move.w #N_CHAR,d1			;j=n_char
		lea.l freq,a2
		lea.l son,a3
.wloop	move.w d0,d2
		add.w	d2,d2				;(i*2) coz words
		move.w 0(a2,d2.w),d3
		add.w	2(a2,d2.w),d3		;freq[i]+freq[i+1]
		move.w d1,d2
		add.w	d2,d2
		move.w d3,0(a2,d2.w)
		move.w d0,0(a3,d2.w)		;son[j]=i
		move.w d0,d2
		add.w	d2,d2
		move.w d1,0(a4,d2.w)		;prnt[i]=j
		move.w d1,2(a4,d2.w)		;prnt[i+1]=j
		addq.w #2,d0
		addq.w #1,d1			;j++
		cmp.w	#R,d1
		ble .wloop
.wover	lea.l freq,a2
		move.w #-1,T*2(a2)
		lea.l prnt,a2
		clr.w R*2(a2)
		rts


		EVEN

first_vbl	CLR.B $FFFFFA1B.W
		MOVE.L #hbl,$120.W
		MOVE.B #145,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVE.B #45,$FFFFFA21.W
		ADDQ #1,vbl_timer
		RTE

* Vbl for screen update etc...

vbl		MOVE #$2500,SR
		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA1B.W
		MOVE.L #hbl,$120.W
		MOVE.B #145,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVE.B #45,$FFFFFA21.W
		MOVEM.L pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		TST.B fin_load
		BEQ.S notloaded
motor_off	MOVE.W #$80,$FFFF8606.W
		MOVE.W $FFFF8604.W,D0
		BTST #7,D0					wait until motor is off
		BNE.S notloaded
		MOVEQ #7,D0					motor now off
		BSR select					so deselect
notloaded	TST depacking
		BEQ Do_scroller
		MOVE #229,x
		MOVE #102,y
		MOVE.L A6,D0
		SUB.L A1,D0
		MOVEQ #9,D1
		LSR.L D1,D0
		BSR num_print
Do_scroller	BSR music+28+2
		LEA screen1,A0
		LEA (192*160)+152(A0),A0
		LEA 1(A0),A2
		MOVEQ #7,D1
shift2	REPT 2
		LSL.W (A0)
		ROXL.W -8(A0)
		ROXL.W -16(A0)
		ROXL.W -24(A0)
		ROXL.W -32(A0)
		ROXL.W -40(A0)
		ROXL.W -48(A0)
		ROXL.W -56(A0)
		ROXL.W -64(A0)
		ROXL.W -72(A0)
		ROXL.W -80(A0)
		ROXL.W -88(A0)
		ROXL.W -96(A0)
		ROXL.W -104(A0)
		ROXL.W -112(A0)
		ROXL.W -120(A0)
		ROXL.W -128(A0)
		ROXL.W -136(A0)
		ROXL.W -144(A0)
		ROXL.W -152(A0)
		ENDR
		LEA 160(A0),A0
		DBF D1,shift2
		MOVE.L scr_point(PC),A0
		MOVE scrx(PC),D5
		BNE.S pos_ok
		ADDQ.L #1,A0
		MOVE.B (A0),D0
		BNE.S notwrap
		MOVE.L startoftext(PC),A0
notwrap	MOVEQ #8,D5
pos_ok	SUBQ #2,D5
		MOVE D5,scrx
		MOVE.L A0,scr_point
		CLR D0
		MOVE.B (A0),D0
		SUB.B #32,D0
		LSL #3,D0
		LEA font8_8(PC),A1
		ADDA.W D0,A1
		MOVEQ #7,D2
loopety	MOVE.B (A1)+,D1
		LSR.B D5,D1
		OR.B D1,(A2)
		LEA 160(A2),A2
		DBF D2,loopety
		MOVEQ #0,D0
		MOVE no_sects(PC),D0
		MOVE #229,x
		MOVE #84,y
		BSR num_print
		MOVEM.L (SP)+,D0-D7/A0-A6
end_vbl	ADDQ #1,vbl_timer
		RTE

; The hbl

hbl		MOVEM.L D0-D7/A0-A2,-(SP)
		MOVE.L #hbl1,$120.W
		NOT hblswitch
		BEQ ENDHBL
		TST hblfade
		BEQ.S ENDHBL
		LEA pal(PC),A1
		LEA pal2(PC),A0
		MOVEQ #15,D4
hcol_lp	MOVE (A0),D0
		MOVE (A1)+,D1
		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3		
		BLE.S R_done
		ADD #$100,D0
R_done	MOVE D0,D2
		MOVE D1,D3
		AND #$070,D2
		AND #$070,D3
		CMP D2,D3
		BLE.S G_done
		ADD #$010,D0
G_done 	MOVE D0,D2
		MOVE D1,D3
		AND #$007,D2
		AND #$007,D3
		CMP D2,D3
		BLE.S B_done
		ADDQ #$001,D0
B_done	MOVE D0,(A0)+
		DBF D4,hcol_lp
		SUBQ #1,hblfade

ENDHBL	MOVEM.L pal2(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVEM.L (SP)+,D0-D7/A0-A2
		RTE

hblswitch	DC.W 0
hblfade	DC.W 0

hbl1		CLR.B $FFFFFA1B.W
		MOVE.W #$777,$FFFF8242.W
		CLR.L $FFFF8240+4.W
		CLR.L $FFFF8240+8.W
		CLR.L $FFFF8240+12.W
		CLR.L $FFFF8240+16.W
		CLR.L $FFFF8240+20.W
		CLR.L $FFFF8240+24.W
		CLR.L $FFFF8240+28.W
		RTE		

* Colour Fade-In the screen.

Fade_in	LEA pal(pc),A1
		LEA pal3(pc),a2
		MOVEQ #6,D5		
fade_lp	MOVEQ #1,D0
spd_lp	MOVE vbl_timer(PC),D1
wait_vbl	CMP vbl_timer(PC),D1
		BEQ.S wait_vbl
		LEA pal3(PC),A3
		LEA $FFFF8240.W,A4
		REPT 8
		MOVE.L (A3)+,(A4)+
		ENDR
		DBF D0,spd_lp
		MOVEQ #15,D4
col_lp	MOVE (A2),D0
		MOVE (A1)+,D1
		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3		
		BLE.S R_doneh
		ADD #$100,D0
R_doneh	MOVE D0,D2
		MOVE D1,D3
		AND #$070,D2
		AND #$070,D3
		CMP D2,D3
		BLE.S G_doneh
		ADD #$010,D0
G_doneh	MOVE D0,D2
		MOVE D1,D3
		AND #$007,D2
		AND #$007,D3
		CMP D2,D3
		BLE.S B_doneh
		ADDQ #$001,D0
B_doneh	MOVE D0,(A2)+
		DBF D4,col_lp
		LEA -32(A1),A1
		LEA -32(A2),A2
		DBF D5,fade_lp
		RTS

pal		ds.w 16
pal2		ds.w 16
pal3		ds.w 16

; Clear all the memory above this loader...

clearmemory	LEA screen1+32000,a0
		moveq #0,d0
		moveq #0,d1
		moveq #0,d2
		moveq #0,d3
		moveq #0,d4
		moveq #0,d5
		moveq #0,d6
		move.l d6,a1
		lea file+256(pc),a2
clearmem	movem.l d0-d6/a1,-(a0)
		movem.l d0-d6/a1,-(a0)
		movem.l d0-d6/a1,-(a0)
		movem.l d0-d6/a1,-(a0)
		movem.l d0-d6/a1,-(a0)
		movem.l d0-d6/a1,-(a0)
		movem.l d0-d6/a1,-(a0)
		movem.l d0-d6/a1,-(a0)
		cmp.l a2,a0
		bgt.s clearmem
		rts

clearscreen	LEA screen1,A0
		MOVE #1999,D0
		MOVEQ #0,D1
clsscreen	MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,clsscreen
		RTS

* Routine to print a number held
* in D0.W slow version with divu's.

num_print	MOVE.L A2,-(SP)
		LEA num_buf(PC),A2
		DIVU #100,D0
		ADD #48,D0
		MOVE.B D0,(A2)
		CLR D0
		SWAP D0
		DIVU #10,D0
		ADD #48,D0
		MOVE.B D0,1(A2)
		CLR D0
		SWAP D0
		ADD #48,D0
		MOVE.B D0,2(A2)
		BSR smll_text
		MOVE.L (SP)+,A2
		RTS

* Routine to print text at position
* in 'x' and 'y' with text at A2

smll_text	MOVEM.L D0-D7/A0-A3,-(SP)
		LEA screen1,A3
		MOVE x(PC),D7
		MOVE y(PC),D1
		MULU #160,D1
		ADDA.W D1,A3
txtlp		CLR D0
		MOVE.B (A2)+,D0
		BEQ txtdone
		ADD D0,D0
		LEA smlfnttab(PC),A0
		LEA smallfnt(PC),A1
		ADD.W (A0,D0),A1
		MOVE D7,D0
		MOVE D0,D5
		LSR #1,D0
		AND #$FFF8,D0
		LEA (A3,D0),A0
		AND #15,D5
		MOVE.L #%11111111111111110000000011111111,A4
		MOVEQ #7,D6
chli_lp	MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVE.L A4,D4
		MOVE (A1)+,D0
		MOVE (A1)+,D1
		MOVE (A1)+,D2
		MOVE (A1)+,D3
		ROR.L D5,D0
		ROR.L D5,D1
		ROR.L D5,D2
		ROR.L D5,D3
		ROR.L D5,D4
		AND D4,(A0)
		OR D0,(A0)+
		AND D4,(A0)
		OR D1,(A0)+
		AND D4,(A0)
		OR D2,(A0)+
		AND D4,(A0)
		OR D3,(A0)+
		SWAP D1
		MOVE D1,D0
		SWAP D3
		MOVE D3,D2
		MOVE.L D4,D3
		SWAP D4
		MOVE D4,D3
		AND.L D3,(A0)
		OR.L D0,(A0)+
		AND.L D3,(A0)
		OR.L D2,(A0)
		LEA 148(A0),A0
		DBF D6,chli_lp
		ADD #10,D7
		BRA txtlp
txtdone	MOVEM.L (SP)+,D0-D7/A0-A3
		RTS

* Print info for demo that is about
* to load in allocated spaces. 

setupload	MOVE.L name_ptr(PC),A2
		MOVE #79,x
		MOVE #40,y
		BSR smll_text
print_group	MOVE.L group_ptr(PC),A2
		MOVE #79,x
		MOVE #66,y
		BSR smll_text
print_blip	MOVE #229,x
		MOVE #102,y
		MOVEQ #0,D0
		BSR num_print
print_sects	MOVEQ #0,D0
		MOVE sectstoload(PC),D0
		MOVE D0,no_sects
		MOVE #229,x
		MOVE #84,y
		BSR num_print
		CLR depacking
		RTS

* Flush keyboard buffer

Flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S Flush
flok		RTS

***************************************************************************
***************************************************************************
;                     Demo names,groups and text                          ;
***************************************************************************
***************************************************************************

pointerstuff
name_ptr	DC.L 0
group_ptr	DC.L 0
scr_point	DC.L 0
startoftext	DC.L 0
scrx		DC.W 0

demotab	DC.L 0
		DC.L demo1info
		DC.L demo2info
		DC.L demo3info
		DC.L demo4info
		DC.L demo5info
		DC.L demo6info
		DC.L demo7info
		DC.L demo8info
		DC.L demo9info
		DC.L demo10info
		DC.L demo11info
		DC.L demo12info
		DC.L demo13info
		DC.L demo14info

* Demo information data structure.
* Side 		.w
* Sector offset 	.w
* No. of sectors  .w
* Demo name       17 bytes,0 terminates
* Coded by?       17 bytes,0 terminates
* Mini text as long as need be, 0 terminates
 
***************************************************************************
demo1info	DC.W 1
		DC.W 101
		DC.W 56
		DC.B "PARALLAX SCROLL   ",0
		DC.B "THE RESISTANCE    ",0		
		DC.B "   WE NEARLY HAD HYSTERICS WHEN TLB SAID THEIR PARALLAX SCROLL COULDN'T BE BEATEN, ANYWAY HERE'S A FULLSCREEN VERSION WITH EVEN MORE STUFF....      ",0
		EVEN
***************************************************************************
demo2info	DC.W 0
		DC.W 234
		DC.W 46
		DC.B "THE FLEXISCROLL   ",0
		DC.B "THE RESISTANCE    ",0
		DC.B "     THE FLEXISCROLLER.... THE SCROLLER WHICH CAN TAKE ANY FORM.... WHO SAYS YOU NEED A BLITTER TO DO REAL TIME PIXEL DISTORTING.... 3000 INDIVIDUAL PIXELS PLOTTED PER FRAME GIVING AN EFFECT UNSEEN BEFORE ON THE ST...    ",0
		EVEN
***************************************************************************
demo3info	DC.W 1
		DC.W 574
		DC.W 241
		DC.B "QUARTET SCREEN    ",0
		DC.B "ELECTRONIC IMAGES ",0
		DC.B "      YOU WILL SOON SEE THE BIGGEST AND BEST DIGI-SOUND DEMO YET ON THE ST, CONTAINING OVER 90 MINUTES OF DIGITAL MUSIC TO BLOW YOUR BRAIN AWAY.... THIS SCREEN TAKES AN AGE TO DEPACK... "
		DC.B " THE PRICE YOU HAVE TO PAY FOR HAVING THE BEST PACKER... THE PACKER WE USE BEATS ALL OTHER PACKERS BY MILES, BUT IT HAS THE DISADVANTAGE OF BEING SLOWER DEPACKING DUE TO THE MORE COMPLEX PACKING ALGORITHMS...      ",0
		EVEN
***************************************************************************
demo4info	DC.W 0
		DC.W 109
		DC.W 126
		DC.B "WHERES MY WILLY!? ",0
		DC.B "ELECTRONIC IMAGES ",0
		DC.B "   YOU ARE ABOUT TO SEE THE WHERE'S MY WILLY SCREEN BY ELECTRONIC IMAGES.... FAK OFF TO ALL PEOPLE WHO SAY 'THEY COULD HAVE PLOTTED AT LEAST 13.53 SPRITES IN THE PROCESSOR TIME THEY HAD LEFT'.... FAK YOU!!!   ",0
		EVEN
***************************************************************************
demo5info	DC.W 1
		DC.W 49
		DC.W 53
		DC.B "INSIGNIFICANT DEMO",0
		DC.B "THE FINGERBOBS    ",0
		DC.B "  THOSE SCOTTISH LADS 'CUM UP' WITH THE GOODS AGAIN(OOOEERRR...), THE FINGERBOBS PRESENT THE BRILLIANT BUT INSIGNIFICANT DEMO....      ",0
		EVEN
***************************************************************************
demo6info	DC.W 1
		DC.W 10
		DC.W 40
		DC.B "THE GIGADIST      ",0
		DC.B "THE ST SQUAD      ",0
		DC.B "  MATRIXX OF THE ST SQUAD TAKES THE ST TO ITS LIMITS ONCE AGAIN, IT'S SURPRISING WHAT YOU CAN DO WITHOUT THE CHIMP SLOWING YOU DOWN.... (E.G ARCHIE IS A CHIMP!)       ",0
		EVEN
***************************************************************************
demo7info	DC.W 1
		DC.W 156
		DC.W 142
		DC.B "WOW!SCROLL 2      ",0
		DC.B "THE RESISTANCE    ",0
		DC.B "    ONCE UPON A TIME THERE WAS A SCREEN IN THE CLASSIC UNION DEMO CALLED - THE WOW SCROLL BY TCB. BOY HAVEN'T THINGS CHANGED SINCE THEN, ANYWAY HERE'S THE SEQUEL FEATURING FULL OVERSCAN AND 15.8 KHZ SOUND...   ",0
		EVEN
***************************************************************************

demo8info	DC.W 1
		DC.W 369
		DC.W 206
		DC.B "SOLID 3D SCREEN   ",0
		DC.B "THE RED HERRINGS  ",0
		DC.B "   AMAZING SOLID 3D DEMO BY THE RED HERRINGS... THE RED HERRINGS APOLOGISE FOR THE SLOWNESS OF ONE OR TWO OF THE LARGE OBJECTS AS THESE WERE DESIGNED IN CAD3D WHICH PRODUCES TWICE AS MANY FACES AS THE OBJECT SHOULD CONTAIN..."
		DC.B " PROGRAMMERS SHOULD UNDERSTAND THIS ANYWAY...        ",0
		EVEN
***************************************************************************

demo9info	DC.W 0
		DC.W 33
		DC.W 36 
		DC.B "3D MANIA          ",0
		DC.B "ELECTRONIC IMAGES ",0
		DC.B "      DEPTH CUED 3D DOTS BY ELECTRONIC IMAGES, COO THIS DON'T HALF LOOK SMOOTH.... SMOOTH AS MY..... *END OF TEXT*    ",0
		EVEN
***************************************************************************

demo10info	DC.W 0
		DC.W 68
		DC.W 42 
		DC.B "THE RASTERSCROLL  ",0
		DC.B "ELECTRONIC IMAGES ",0
		DC.B "  512 COLOUR SCROLLER CODED BY COUNT ZERO OF ELECTRONIC IMAGES. HEY REPLICANTS WE REALLY LIKED YOUR RASTER DIST IN 'LIFES A BITCH' - VERY NICE!!    ",0
		EVEN
***************************************************************************

demo11info	DC.W 1
		DC.W 297
		DC.W 73 
		DC.B "THE PIPEWORX DEMO ",0
		DC.B "THE ST SQUAD      ",0
		DC.B "  ARCHIE PRESENTS.... OOOPS... SORRY! MATRIXX OF THE ST SQUAD PRESENTS THE BARREL SCROLLER, HEY SENSE WE REALLY LIKE YOUR GLASS FONT - BLOODY GOOD!!!     ",0
		EVEN
***************************************************************************

demo12info	DC.W 0
		DC.W 279
		DC.W 159 
		DC.B "THE HOTLINE SCREEN",0
		DC.B "ERR.... HOTLINE?! ",0
		DC.B "    A GUEST SCREEN?  ANYWAY THE GUYS FROM HOLLAND DELIVER THE GOODS EVEN IF IT DID TAKE 700K RUNNING AT FIRST!!! ANYWAY EVERYTHING NOW WORKS IN HALF MEG FINE THANKS TO GRIFF(OF COURSE)...       ",0
		EVEN

***************************************************************************

demo13info	DC.W 0
		DC.W 663
		DC.W 61 
		DC.B "THE VECTORSCREEN  ",0
		DC.B "THE RESISTANCE    ",0
		DC.B "     THIS DEMO WAS REALLY RUSHED, SO TAKE OR LEAVE IT, WE WROTE THE BULK OF THIS SCREEN IN A DAY AND WE DIDN'T HAVE TIME LEFT TO INCLUDE TWEENING OR MORE SHAPES... STILL IT IS THE JOINT FASTEST VECTOR DEMO ON THE ST, "
		DC.B "ALONG WITH MCODER'S VECTOR DEMO.      ",0
		EVEN
***************************************************************************
demo14info	DC.W 0
		DC.W 596
		DC.W 68 
		DC.B "THE MIXULOAD      ",0
		DC.B "ELECTRONIC IMAGES ",0
		DC.B "    THE REAL MAN WITH THE MUSIC COUNT ZERO BRINGS YOU SOMETHING ELSE TO PLAY WITH, APART FROM..........GAMES!...         ",0
		EVEN
***************************************************************************

* Various crap used in the text routine/dma load etc...

x		DC.W 0
y		DC.W 0
num_buf	DC.L 0

smlfnttab	DS.W 32
		DC.W 43*64
		DC.W 38*64
		DC.W 0
		DC.W 0
		DC.W 0
		DC.W 0
		DC.W 0
		DC.W 0
		DC.W 40*64
		DC.W 41*64
		DC.W 0
		DC.W 0
		DC.W 37*64
		DC.W 42*64
		DC.W 36*64
		DC.W 0
		DC.W 26*64
		DC.W 27*64
		DC.W 28*64
		DC.W 29*64
		DC.W 30*64
		DC.W 31*64
		DC.W 32*64
		DC.W 33*64
		DC.W 34*64
		DC.W 35*64
		DC.W 0
		DC.W 0
		DC.W 0
		DC.W 0
		DC.W 0
		DC.W 39*64
		DC.W 0
		DC.W 00*64
		DC.W 01*64
		DC.W 02*64
		DC.W 03*64
		DC.W 04*64
		DC.W 05*64
		DC.W 06*64
		DC.W 07*64
		DC.W 08*64
		DC.W 09*64
		DC.W 10*64
		DC.W 11*64
		DC.W 12*64
		DC.W 13*64
		DC.W 14*64
		DC.W 15*64
		DC.W 16*64
		DC.W 17*64
		DC.W 18*64
		DC.W 19*64
		DC.W 20*64
		DC.W 21*64
		DC.W 22*64
		DC.W 23*64
		DC.W 24*64
		DC.W 25*64


vbl_timer	DC.W 0
loading	DC.W 0
depacking	DC.W 0
diskstuff	
side		DC.W 0		side
sectoffset	DC.W 0		sector offset on disk
sectstoload	DC.W 0		number of sectors to load	

		IFEQ demo
old_vbl	DC.L 0
old_mfp	DS.L 4
		ENDC
font8_8	dc.l $00000000,$00000000,$1C1C1C1C,$1C001C1C,$00666666 
		dc.l $00000000,$0066FF66,$66FF6600,$183E603C,$067C1800 
		dc.l $3033060C,$18306606,$1C361C38,$6F663B00,$38381830 
		dc.l $00000000,$0C183030,$3030180C,$30180C0C,$0C0C1830 
		dc.l $00663CFF,$3C660000,$0018187E,$18180000,$00000000 
		dc.l $1C1C1C30,$0000007E,$00000000,$00000000,$1C1C1C00 
		dc.l $03060C18,$3060C080,$003C7E66,$667E3C00,$18387818 
		dc.l $18187C00,$78CC660C,$30627E00,$7C664C18,$06C37F00 
		dc.l $0C1C3C6C,$CCFE0C00,$3E303C06,$06E67C00,$0E38E0DC 
		dc.l $C6C67C00,$FC8C1830,$60606000,$7CC6F65C,$C6C67C00 
		dc.l $78CCC67E,$060C7800,$38383800,$38383800,$38383800 
		dc.l $38383870,$060C1830,$180C0600,$00007E00,$007E0000 
		dc.l $6030180C,$18306000,$003C660C,$18001800,$003C666E 
		dc.l $6E603E00,$E070786C,$667E67E0,$00FC667C,$666343FE 
		dc.l $1C366660,$60666C78,$00F84C66,$66664EFC,$00FC4470 
		dc.l $6062FE00,$00FE6278,$6060F000,$1C3662C0,$C0DFCC78 
		dc.l $E067667E,$6666E607,$7E5A1818,$185A7E00,$7E180C0C 
		dc.l $C6663E00,$E0666C78,$786CE603,$F0606060,$6663FE00 
		dc.l $E0667E7E,$6666E607,$E066767E,$6E66E607,$007E4666 
		dc.l $66667E00,$00FC4666,$7C6060E0,$007E4666,$66647E07 
		dc.l $00FC4666,$7C6CE603,$003E3238,$1C8E86FE,$FEB2B030 
		dc.l $30303860,$00E06766,$66667E00,$E0616366,$6C787060 
		dc.l $E0666666,$7E7E6600,$E067361C,$386CE607,$C3E7663C 
		dc.l $1818D870,$00FE8C18,$3062FE00,$003E3838,$38383E00 
		dc.l $80C06030,$180C0603,$007C1C1C,$1C1C7C00,$00183C7E 
		dc.l $18181818,$00000000,$0000FF00,$0C181C1C,$00000000 
		dc.l $0000007C,$CCCC7F00,$00E0607C,$6666FC00,$0000003C 
		dc.l $60603C00,$000E0C7C,$CCCC7600,$00003C66,$7E603E00 
		dc.l $0E1A1818,$3E181878,$00063C66,$663E607E,$E060607C 
		dc.l $6666E700,$00180038,$18183C00,$0006000E,$0606663C 
		dc.l $00E0606C,$786CE603,$38181818,$18181C00,$0000C07E 
		dc.l $6A6A6B00,$0000C07C,$6666F700,$0000003C,$66663C00 
		dc.l $0000FC66,$667C60E0,$00007ECC,$CC7C0C0E,$0000DC66 
		dc.l $6060F000,$00007E62,$18067E00,$0000187E,$18180E00 
		dc.l $0000EE66,$66663B00,$0000E762,$74381000,$0000C6D6 
		dc.l $FE7C6C00,$0000663C,$183C6600,$00006666,$663E067C 
		dc.l $00007E4C,$18327E00,$00183C7E,$7E183C00,$18181818 
		dc.l $18181818,$00000018,$18000000,$08183878,$38180800 

smallfnt	incbin LOADER.SCN\smallfnt.dat

music		INCBIN LOADER.SCN\LOADMUS.CZI
depack_pic	INCBIN LOADER.SCN\LOADER1.PI1
end_pic	even
		section bss
file		ds.l 31000
xoutput