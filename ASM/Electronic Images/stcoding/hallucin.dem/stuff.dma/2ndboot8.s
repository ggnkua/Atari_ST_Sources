;-----------------------------------------------------------------------;
; Enigma 2nd load Source Code : -					;
; This is the Second loader. (loaded by the bootsector)			;
; It is loaded by the bootcode to a high location. (&7B000)		;
;-----------------------------------------------------------------------;

; Encode the 2nd loader

write		MOVE #09,-(SP)		; write 9 sectors
		MOVE #00,-(SP)		; side 0
		CLR -(SP)		; track 0
		MOVE #02,-(SP)		; sector 2
		MOVE #00,-(SP)		; boot device
		CLR.L -(SP)		; filler
		PEA decoder(PC)		; address to write
		MOVE #$09,-(SP)		; _flopwr
		TRAP #14		; xbios
		LEA 20(SP),SP		; correct stack
		CLR -(SP)
		TRAP #1

**************************************************************************
**************************************************************************

; Second loader code starts here On entry is at address $7b000

decoder
		ORG $70000

		MOVE #$2700,SR			; kill ints
start		LEA $80000,SP			; our stack
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+			; palette off.
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,$426.W
		MOVE.L D0,$42A.W
		BSR flush
		BSR re_init			; go with ints
		BSR flush		
		MOVEQ #$12,D0
		BSR Write_ikbd
		MOVEQ #$1A,D0			
		BSR Write_ikbd

; The Sync test bits

		BSR Initscreens
		LEA synctext(PC),A0
		MOVE.B #0,txpos
		MOVE.B #3,typos
		BSR print
		LEA my_vbl(pc),a1
		MOVE.L A1,$70.w
		BSR wait_vbl
		BSR wait_vbl
		;MOVE.B #2,$FFFF820A.W
		BSR fadein_sync
.sync_frame	CMP.B #$39+$80,$FFFFFC02.W	; space to exit...
		BNE .sync_frame
.exit		BSR wait_vbl
		BSR fadeout_sync
		BSR wait_vbl
		LEA nul_vbl(pc),a1
		MOVE.L A1,$70.w

; Main Code load and run

		BSR clearmem			; clear all memory.

		MOVE.L #120,D0			; 120 sects to load
		MOVE.L #10,D1			; log sector 10
		MOVEQ #0,D2			; side 0
		LEA $500-28,A0
		BSR Do_load			; LOAD MAIN LOADER
		BSR Deselect
		JMP $500

; Turn off all shit... and Initialise all vectors etc.

re_init		MOVE.W #$2700,SR
		BSR ourvects
		MOVEQ #0,D0
		MOVE.B D0,$FFFFFA07.W
		MOVE.B D0,$FFFFFA09.W
		MOVE.B D0,$FFFFFA13.W
		MOVE.B D0,$FFFFFA15.W
		MOVE.B D0,$FFFFFA0F.W
		MOVE.B D0,$FFFFFA11.W
		MOVE.B D0,$FFFFFA0B.W
		MOVE.B D0,$FFFFFA0D.W
		BCLR.B #3,$FFFFFA17.W
		MOVE.W #$2300,SR
		RTS

; Write D0 to the ikbd 

Write_ikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Write_ikbd
		MOVE.B D0,$FFFFFC02.W
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

; Clear Memory...

clearmem	LEA $70000,A0
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVE.L D6,A1
		MOVE.W #($6f000/128)-1,D7
cl_lp		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		DBF D7,cl_lp
		RTS

; Install nul vectors and bombout vectors...

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

bombout		MOVE #$2700,SR
		MOVE.B #$7,$FFFF8800.W
		MOVE.B #-1,$FFFF8802.W
		MOVE #$700,$FFFF8240.W	
forever		BRA.S forever

;-----------------------------------------------------------------------;
;                           The dma load code                      	;
;			    -----------------				;	
; A0 -> points to address to read into. D2 - side to read.		;
; D0 - no of sectors to load, D1 - logical sector offset to load from.	;				;
;-----------------------------------------------------------------------;

Sectptr		EQU 10

Do_load		SF fin_load				haven't finished yet
		MOVE D0,no_sects			sectors to go
		AND.L #$FFFF,D1
		DIVU #Sectptr,D1			calc track offset
		MOVE D1,seektrack			seek this track
		MOVE D1,currtrack				
		MOVE D2,side
		SWAP D1					remainder+1 =
		ADDQ #1,D1				start sector within
		MOVE D1,sector				sector.
		MOVE.L A0,pointer				
		BSR seldrive				select drive & side
		BSR setdiskint				setup interrupts
		BSR do_seek				do the seek
wait_disk	TST.B fin_load
		BEQ.S wait_disk
		MOVE SR,-(SP)
		MOVE #$2700,SR
		BCLR #7,$FFFFFA09.W			clear int enable for fdc int
		BCLR #7,$FFFFFA15.W			clear int mask for fdc int
		BSET #5,$FFFFFA03.W			unactive!
		MOVE.W (SP)+,SR
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

do_seek		MOVE #$86,$FFFF8606.W
		MOVE seektrack(PC),$FFFF8604.W
		MOVE #$80,$FFFF8606.W
		MOVE #16+4+3,$FFFF8604.W
		RTS

loaderror	ADDQ #1,no_sects
		SUB.L #512,pointer			retry loading!
		MOVE.W (SP)+,D0
		BRA.S errorcont

read		MOVE.W D0,-(SP)
		MOVE.W #$80,$FFFF8606.W			select status
		MOVE.W $FFFF8604.W,D0			read status from last load
		BTST #3,D0				
		BNE.S loaderror
		BTST #4,D0
		BNE.S loaderror
		BTST #5,D0
		BNE.S loaderror
noerror		MOVE.W (SP)+,D0
		ADDQ #1,sector				next sector
errorcont	CMP #Sectptr,sector			new track?
		BGT.S stepin				yes/no -
read_rout	MOVE.B pointer+3(PC),$FFFF860D.W	load sector
		MOVE.B pointer+2(PC),$FFFF860B.W	dma address count
		MOVE.B pointer+1(PC),$FFFF8609.W
		MOVE.W #$90,$FFFF8606.W
		MOVE.W #$190,$FFFF8606.W		fifo enable read
		MOVE.W #$90,$FFFF8606.W
		MOVE.W #1,$FFFF8604.W 			read 1 sector
		MOVE.W #$84,$FFFF8606.W
		MOVE.W sector(PC),$FFFF8604.W		say which sector
		MOVE.W #$80,$FFFF8606.W			read it
		MOVE.W #$80,$FFFF8604.W			
		ADD.L #512,pointer			add to pointer
		SUBQ #1,no_sects			decrement total sects
		BEQ.S INT_DONE				to load.if done exit
		MOVE.L #read,$11C.W			
		RTE

* Step in a track and then continue reading

stepin		MOVE #1,sector				reset sector count
		ADDQ #1,currtrack			next track
		MOVE.L #read_rout,$11C.W		continue reading
step		MOVE #$80,$FFFF8606.W			send seek
		MOVE #64+16+8+3,$FFFF8604.W		command to controller(+4 for verify)
		RTE

INT_DONE	MOVE.L #INT_EXIT,$11C.W			sectors loaded
		RTE

INT_EXIT	ST fin_load				set flag to say so
		RTE

* Select current drive/side

seldrive	MOVE.W $446.W,D0			get bootdevice
		AND #1,D0				isolate first bit
		ADDQ #1,D0
		ADD D0,D0				calc right bit
		OR side(PC),D0
		EOR.B #7,D0
select		MOVE.B #$E,$FFFF8800.W			select psg
		MOVE.B $FFFF8800.W,D1				
		AND.B #$F8,D1				
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W			select drive/side
		RTS

seektrack	DS.W 1
currtrack	DS.W 1
pointer		DS.L 1
no_sects	DS.W 1
side		DS.W 1
sector		DS.W 1
fin_load	DS.W 1

; Deselect current drive e.g turn motor off!

Deselect	MOVE #$80,$FFFF8606.W
.wait		MOVE $FFFF8604.W,D0
		BTST #7,D0
		BNE.S .wait
		MOVEQ #7,D0
.select		MOVE.B #$E,$FFFF8800.W
		MOVE.B $FFFF8800.W,D1
		AND.B #$F8,D1
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W
		RTS
		
; Relocator : relocates from a1->a0 and clears bss.		

Relocateit	MOVE.L 2(A1),D0			; text length
		ADD.L 6(A1),D0			; + data length
		MOVE.L 10(A1),D2		; bss length
		LEA 28(A1),A1
.rel1_lp	MOVE.B (A1)+,(A0)+		; relocate
		SUBQ.L #1,D0			; text and data.
		BNE.S .rel1_lp
		MOVEQ #0,D1
.rel1_lp2	MOVE.B D1,(A0)+
		SUBQ.L #1,D2
		BNE.S .rel1_lp2
		RTS

; My little vbl interrupt.

my_vbl		MOVEM.L D0-A6,-(SP)
		MOVEM.W col1(PC),D3/D4
		MOVE.W D3,$FFFF8242.W
		LEA $FFFF8209.W,A0
		LEA $FFFF825E.W,A1
		MOVE.W D3,(A1)
.ok		MOVE.B (A0),D0
		BEQ.S .ok
		MOVEQ #$20,D1
		SUB.B D0,D1
		LSL.B D1,D0
		MOVEQ #80-1,D5
.lp		DCB.W 125,$4e71
		DBF D5,.lp

		MOVEQ #12-1,D5
.lp1		DCB.W 15,$4E71
		MOVE.W D4,(A1)
		MOVE.W D3,(A1)
		DCB.W 125-4-15,$4e71
		DBF D5,.lp1 
		MOVEM.L (SP)+,D0-A6
nul_vbl		ADDQ #1,vbl_timer
		RTE
phy_base	DC.L 0
vbl_timer	DC.W 0

wait_vbl	MOVE.W vbl_timer(PC),D0
.wait		CMP.W vbl_timer(PC),D0
		BEQ.S .wait
		RTS

col1		DC.W 0
col2		DC.W 0

; Fade in sync shit.

fadein_sync	BSR wait_vbl
		MOVEQ #0,D1
		MOVEQ #0,D2
.lp		MOVE.W D1,col1
		MOVE.W D2,col2
		BSR wait_vbl
		BSR wait_vbl
		BSR wait_vbl
		ADD.W #$111,D1
		ADD.W #$010,D2
		CMP.W #$080,D2
		BNE.S .lp
		RTS

; Fade out sync shit.

fadeout_sync	BSR wait_vbl
		MOVE #$777,D1
		MOVE #$070,D2
.lp		MOVE.W D1,col1
		MOVE.W D2,col2
		BSR wait_vbl
		BSR wait_vbl
		BSR wait_vbl
		SUB.W #$111,D1
		SUB.W #$010,D2
		BGE.S .lp
		RTS

; Allocate space for screens and clear them + make standard *160 table.

Initscreens	lea phy_base(pc),a1
		move.l #screens+256,d0
		clr.b d0
		move.l d0,(a1)
		lsr #8,d0
		move.l d0,$ffff8200.w
		move.l phy_base(pc),a0
		BSR clear_screen
		MOVE.L phy_base(pc),a0
		LEA 80*160(A0),A0
		MOVE.W #(12*160)/2-1,D0
		MOVE.W #%00000000000001000,D1
.lp1		MOVE.W D1,(A0)+
		DBF D0,.lp1
		RTS

; Clear screen ->A0

clear_screen	moveq #0,d0
		move #3999,d1
.cls		move.l d0,(a0)+
		move.l d0,(a0)+
		dbf d1,.cls
		rts

; Print Rout -> Text address in A0...  Uses TXPOS and TYPOS (.B)
; 1 (in text) = Inverse text, else normal.
; 2 (in text) = Normal text.
; Returns with LASTPTR holding last address after 0 termination.

print:		movem.l	d0-d4/a0/a2-a3,-(sp)
		moveq	#0,d2
printline:
		move.b	(a0)+,d0
		bne.s	notend
		move.l	a0,lastptr
		movem.l	(sp)+,d0-d4/a0/a2-a3
		rts
notend:		cmpi.b	#1,d0
		bne.s	notinv
		moveq	#1,d2
		move.b	(a0)+,d0
notinv:		cmpi.b	#2,d0
		bne.s	notnorm
		moveq	#0,d2
		move.b	(a0)+,d0
notnorm:	cmpi.b	#$a,d0
		bne.s	notcr
		addq.b	#8,typos
		bra.s	printline
notcr:		cmpi.b	#$d,d0
		bne.s	notlf
		move.b	#0,txpos
		bra.s	printline
notlf:		;tst.b	d2
		;bne.s	inverse
		moveq   #0,D3
	        moveq   #0,D4
        	move.b  txpos(PC),D3
	        move.b  typos(PC),D4
		mulu #160,d4
	        movea.l phy_base(pc),A2		; Screen
        	adda.l d4,A2
	        lea     xtab(PC),a3
		add.w d3,d3        
        	add.w 0(a3,D3.w),a2
        	lea     font(PC),a3
	        moveq   #0,D3
	        move.b  D0,D3
        	sub.b   #32,D3
	        lsl.w   #3,D3
        	adda.w  D3,a3
        	move.b  (a3)+,(A2)
	        move.b  (a3)+,160(A2)
        	move.b  (a3)+,320(A2)
	        move.b  (a3)+,480(A2)
        	move.b  (a3)+,640(A2)
	        move.b  (a3)+,800(A2)
        	move.b  (a3)+,960(A2)
	        move.b  (a3),1120(A2)
		addq.b	#1,txpos
		bra	printline

font:   	dc.l	$00000000,$00000000,$00181818,$18001800,$00666666 
		dc.l	$00000000,$0066FF66,$66FF6600,$183E603C,$067C1800 
		dc.l	$00666C18,$30664600,$1C361C38,$6F663B00,$00181818 
		dc.l	$00000000,$000E1C18,$181C0E00,$00703818,$18387000 
		dc.l	$00663CFF,$3C660000,$0018187E,$18180000,$00000000 
		dc.l	$00181830,$0000007E,$00000000,$00000000,$00181800 
		dc.l	$00060C18,$30604000,$003C666E,$76663C00,$00183818 
		dc.l	$18187E00,$003C660C,$18307E00,$007E0C18,$0C663C00 
		dc.l	$000C1C3C,$6C7E0C00,$007E607C,$06663C00,$003C607C 
		dc.l	$66663C00,$007E060C,$18303000,$003C663C,$66663C00 
		dc.l	$003C663E,$060C3800,$00001818,$00181800,$00001818 
		dc.l	$00181830,$060C1830,$180C0600,$00007E00,$007E0000 
		dc.l	$6030180C,$18306000,$003C660C,$18001800,$003C666E 
		dc.l	$6E603E00,$00183C66,$667E6600,$007C667C,$66667C00 
		dc.l	$003C6660,$60663C00,$00786C66,$666C7800,$007E607C 
		dc.l	$60607E00,$007E607C,$60606000,$003E6060,$6E663E00 
		dc.l	$0066667E,$66666600,$007E1818,$18187E00,$00060606 
		dc.l	$06663C00,$00666C78,$786C6600,$00606060,$60607E00 
		dc.l	$0063777F,$6B636300,$0066767E,$7E6E6600,$003C6666 
		dc.l	$66663C00,$007C6666,$7C606000,$003C6666,$666C3600 
		dc.l	$007C6666,$7C6C6600,$003C603C,$06063C00,$007E1818 
		dc.l	$18181800,$00666666,$66667E00,$00666666,$663C1800 
		dc.l	$0063636B,$7F776300,$0066663C,$3C666600,$0066663C 
		dc.l	$18181800,$007E0C18,$30607E00,$001E1818,$18181E00 
		dc.l	$00406030,$180C0600,$00781818,$18187800,$00081C36 
		dc.l	$63000000,$00000000,$0000FF00,$00183C7E,$7E3C1800 
		dc.l	$00003C06,$3E663E00,$0060607C,$66667C00,$00003C60 
		dc.l	$60603C00,$0006063E,$66663E00,$00003C66,$7E603C00 
		dc.l	$000E183E,$18181800,$00003E66,$663E067C,$0060607C 
		dc.l	$66666600,$00180038,$18183C00,$00060006,$0606063C 
		dc.l	$0060606C,$786C6600,$00381818,$18183C00,$0000667F 
		dc.l	$7F6B6300,$00007C66,$66666600,$00003C66,$66663C00 
		dc.l	$00007C66,$667C6060,$00003E66,$663E0606,$00007C66 
		dc.l	$60606000,$00003E60,$3C067C00,$00187E18,$18180E00 
		dc.l	$00006666,$66663E00,$00006666,$663C1800,$0000636B 
		dc.l	$7F3E3600,$0000663C,$183C6600,$00006666,$663E0C78 
		dc.l	$00007E0C,$18307E00,$00183C7E,$7E183C00,$18181818 
		dc.l	$18181818,$007E787C,$6E660600,$08183878,$38180800 

xoff		set	0
xtab:   	
		rept	40
		dc.w	xoff,xoff+1
xoff		set	xoff+8
		endr

txpos:		ds.b 1
typos:		ds.b 1
lastptr:	ds.l 1

synctext	DC.B $a,$d,$a,$d,$a,$d
		DC.B "            Electronic Images",$a,$d,$a,$d
		DC.B "                Sync Test    ",$a,$d,$a,$d
		DC.B "----------------------------------------",$a,$d,$a,$d
		DC.B $a,$d,$a,$d,$a,$d,$a,$d
		DC.B "----------------------------------------",$a,$d,$a,$d
		DC.B "If the above middle vertical line is not",$a,$d
		DC.B "green, switch off your ST for 10 seconds",$a,$d
		DC.B "to kick your shifter chip into sync!!   ",$a,$d,$a,$d,$a,$d
		DC.B "       Press <SPACE> to continue.       ",$a,$d
		DC.B 0
		EVEN

end
screens		DS.B 256
		DS.B 32000
