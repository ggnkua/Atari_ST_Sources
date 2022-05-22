;-----------------------------------------------------------------------;
;	  		   Hallucinations				;
;									;
; The Loader(i.e the part that loads each section, decrunchs it etc)	;
;  - Draws and Fades in/out text telling you about the next part.	;
;  - Dma Loads and decrunchs the next part. 				;
;									;
;-----------------------------------------------------------------------;
; LOADER CHANGED - INT EXIT IN DMALOAD - CHECK IT WORKS IF CRASHES!
	
		OUTPUT d:\LOADER.PRG
		
		ORG $500

		BRA.W start			; $500
		BRA.W do_play			; $504 - call music
		BRA.W doFadeOutText		; $508 - fade out text
		DC.L 0				; $50C
		DC.L 0				; $510 
		DC.L 0				; $514
		DC.W 0				; $518
		DC.L $5555AAAA			; $51a - tos 2 memory valid???!

start		MOVE #$2700,SR
		LEA stack,SP
		BSR blank_pal
		BSR set_ints
		BSR init_music
		MOVE #$2300,SR
		BSR wait_vbl
		BSR wait_vbl

		BSR blank_pal
		BSR Initscreens
		BSR Init_Hbl

lp		MOVE.L #res1,myJUMPthru
		LEA intload(PC),A5
		MOVE.W #0,drive
		BSR normload

res1		MOVE.L #res2,myJUMPthru
		LEA cubeDload(PC),A5
		LEA cubeTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeload

res2		MOVE.L #res3,myJUMPthru
		LEA dotsphDload(PC),A5
		LEA dotsphTEXT(PC),A6
		BSR fadeload

res3		MOVE.L #res4,myJUMPthru
		LEA linesphDload(PC),A5
		LEA linesphTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeload

res4		MOVE.L #res4a1,myJUMPthru
		LEA solsphDload(PC),A5
		LEA solsphTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeload

res4a1		MOVE.L #res4a2,myJUMPthru
		LEA gouraudDload(PC),A5
		LEA gouraudTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeload

res4a2		MOVE.L #res4a,myJUMPthru
		LEA fractalDload(PC),A5
		LEA fractalTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeload

res4a		MOVE.L #res5,myJUMPthru
		LEA threedload(PC),A5
		LEA threedTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeload

res5		MOVE.L #res6,myJUMPthru
		LEA fracload(PC),A5
		LEA fracTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeload

res6		MOVE.L #res6a,myJUMPthru
		LEA rayload(PC),A5
		LEA rayTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeload

res6a		MOVE.L #res7,myJUMPthru
		LEA steload(PC),A5
		LEA steTEXT(PC),A6
		MOVE.W #1,drive
.FADELOAD	PEA (A5)		
		BSR blank_pal
		BSR flush
		BSR wait_vbl
		BSR wait_vbl
		SF hbl_on
		BSR wait_vbl
		BSR Initscreens
		BSR Init_Hbl
		BSR Print_text
		BSR FadeInText
		BSR wait_vbl
		MOVE.L (SP)+,A5
FOREVER		BRA.S FOREVER

res7		MOVE.L #res1,myJUMPthru
		LEA endload(PC),A5
		LEA endTEXT(PC),A6
		ST turnoff_music
		BSR fadeload
		BRA lp
	
intload		DC.W 230,150,0
cubeDload	DC.W 29,380,0
dotsphDload	DC.W 14,409,0 
linesphDload	DC.W 17,422,0
solsphDload	DC.W 16,439,0
gouraudDload	DC.W 18,645,1
fractalDload	DC.W 6,663,1
threedload	DC.W 32,669,1
rayload		DC.W 641,0,1
fracload	DC.W 355,455,0

endload		DC.W 297,0,1
steload		DC.W 400,0,0
myJUMPthru	DC.L res1

; Faded Text loader!

fadeload	PEA (A5)		
		BSR blank_pal
		BSR flush
		BSR wait_vbl
		BSR wait_vbl
		SF hbl_on
		BSR wait_vbl
		BSR Initscreens
		BSR Init_Hbl
		BSR Print_text
		BSR FadeInText
		BSR wait_vbl
		MOVE.L (SP)+,A5
		LEA $FD00-28,A0
		MOVEM.W (A5)+,D0-D2
		BSR Do_load
		MOVEQ #15,D7
.qulp		BSR wait_vbl
		DBF D7,.qulp
		BSR wait_vbl
.nofade1	LEA $FD00-28,A0
		LEA $10000-28,A1
		BSR depack
		LEA $10000-28,A0
		BSR ClearBSS	
.nofade2	BSR wait_vbl
		JSR $10000
		BSR blank_pal
		RTS

; Normal loader - with no text.

normload	PEA (A5)		
		BSR blank_pal
		BSR wait_vbl
		BSR wait_vbl
		SF hbl_on
		BSR flush
		BSR wait_vbl
		BSR Initscreens
		BSR wait_vbl
		BSR wait_vbl
		MOVE.L (SP)+,A5
		LEA $FD00-28,A0
		MOVEM.W (A5)+,D0-D2
		BSR Do_load
		MOVEQ #15,D7
.qulp		BSR wait_vbl
		DBF D7,.qulp
		BSR wait_vbl
.nofade1	LEA $FD00-28,A0
		LEA $10000-28,A1
		BSR depack
		LEA $10000-28,A0
		BSR ClearBSS	
.nofade2	BSR wait_vbl
		JSR $10000
		BSR blank_pal
		RTS

doFadeOutText	BSR FadeOutText	
		BSR blank_pal
		BSR Initscreens
		BRA wait_vbl

WaitKey		
.WAIT		BTST.B #0,$FFFFFC00.W
		BEQ.S .WAIT
		MOVE.B $FFFFFC02.W,D0
		CMP.B #$39,D0
		BNE.S .WAIT
		RTS

; Swap screens and set h/ware reg.

Swap_Screens	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		NOT.W (A0)			; switch screens
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W		; set hardware...
		RTS

; Wait for one vbl..

wait_vbl	MOVE vbl_timer(PC),D0
.wait_vbl	CMP vbl_timer(PC),D0		
		BEQ.S .wait_vbl
		RTS

; Wait for D1 vbls.

Wait_D1_vbls	SUBQ #1,D1
.lp		BSR wait_vbl
		DBF D1,.lp
		RTS

blank_pal	LEA $FFFF8240.W,A0
		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A0)+
		ENDR
		RTS

; My little vbl interrupt.

my_vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		AND.B #$FE,$FFFFFA07.W
		AND.B #$FE,$FFFFFA13.W
		TST.B hbl_on
		BEQ.S .hblisoff
		CLR.B $FFFFFA1B.W
		OR.B #1,$FFFFFA07.W
		OR.B #1,$FFFFFA13.W
		MOVE.L #hbl_collist,$120.W
		MOVE.B #1,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
.hblisoff	BCLR.B #3,$FFFFFA17.W
clearme		BSR.W do_play
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer	
		RTE

; Turn on Hbl (for text display) - initialise to black.

Init_Hbl	BSR wait_vbl
		BSR wait_vbl
		BSR wait_vbl
		ST hbl_on
		LEA hbl_collist+2(PC),A0
		MOVE #200-1,D0
.initcol	CLR.W (A0)
		LEA 16(A0),A0
		DBF D0,.initcol
		RTS

; Fade in Text display (black to blue)

FadeInText	MOVEQ #0,D1
.fadeinlp	BSR wait_vbl
		BSR wait_vbl
		BSR wait_vbl
		LEA hbl_collist+2(PC),A0
		MOVE #200-1,D0
.initcol	MOVE.W D1,(A0)
		LEA 16(A0),A0
		DBF D0,.initcol
		ADD #$001,D1
		CMP.W #$008,D1
		BNE.S .fadeinlp
		RTS

; Flash Fade Out Text display 

FadeOutText	LEA rastfadeptrs(PC),A1
		MOVEQ #$17-1,D7 
.lp		CLR.W (A1)+ 
		DBF D7,.lp
		MOVEQ #1,D6 
		LEA rastfadepal(PC),A3
.cyclefadelp	BSR wait_vbl
		LEA hbl_collist+2+(191*16)(pc),A1
		LEA rastfadeptrs(PC),A2
		MOVEQ #0,D4 
		MOVE.W D6,D7 
		SUBQ.W #1,D7 
.doitlp		ADDQ.W #2,(A2) 
		MOVE.W (A2)+,D0
		MOVE.L A3,A4
		ADDA.W D0,A4
		CMP.L #rastfadepal+($26E-$210),A4 
		BGT.S .skip
		LEA (A1),A5 
		MOVEQ #8,D5 
		MOVE #$777,D1
.copyone	MOVE.W (A4)+,D0
		LSR #1,D0
		AND.W D1,D0
		MOVE.W D0,(A5)
		LEA 16(A5),A5 
		DBF D5,.copyone
		MOVEQ #-1,D4
.skip		LEA -16*9(A1),A1
		DBF D7,.doitlp
		CMP.W  #$16,D6 		;$17
		BGE.S .noinc
		ADDQ.W #1,D6 
.noinc		TST.W D4
		BNE.S .cyclefadelp
		BSR wait_vbl
		BSR wait_vbl
		SF hbl_on
		BSR wait_vbl
		BRA wait_vbl

rastfadeptrs	DS.W $17
rastfadepal	DC.B  $00,$0F,$00,$0F,$00,$0F,$00,$0F
		DC.B  $00,$0F,$00,$0F,$00,$0F,$00,$0F
		DC.B  $00,$0F,$01,$1F,$02,$2F,$03,$3F
		DC.B  $04,$4F,$05,$5F,$06,$6F,$07,$7F
		DC.B  $08,$8F,$09,$9F,$0A,$AF,$0B,$BF
	  	DC.B  $0C,$CF,$0D,$DF,$0E,$EF,$0F,$FF
		DC.B  $0F,$EE,$0F,$DD,$0F,$CC,$0F,$BB
		DC.B  $0F,$AA,$0F,$99,$0F,$88,$0F,$77
		DC.B  $0F,$66,$0E,$55,$0D,$44,$0C,$33
		DC.B  $0B,$22,$0A,$11,$09,$00,$08,$00
		DC.B  $07,$00,$06,$00,$05,$00,$04,$00
		DC.B  $03,$00,$02,$00,$01,$00,$00,$00
		DS.W   8
		DS.W   8*5

i		SET 0 
hbl_collist	
		REPT 199
i		SET i+16
		MOVE.W #$007,$FFFF8242.W
		MOVE.L #hbl_collist+i,$120.W
		RTE
		ENDR
		MOVE.W #$001,$FFFF8242.W
		MOVE.L #hbl_collist,$120.w
		RTE
hbl_on		DC.W 0

myreset		MOVE.W #$2700,SR
		LEA stack,SP
		BSR blank_pal
		BSR Initscreens
		BSR set_ints
		MOVE.W #$2300,SR
		BSR wait_vbl
		BSR wait_vbl
		;MOVE.B #2,$FFFF820A.W
		BSR Init_Hbl
		MOVE.L myJUMPthru(PC),A0
		JMP (A0)

; Initialisation and restore interrupt routs.

set_ints	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		LEA my_vbl(pc),a1
		MOVE.L a1,$70.w
		MOVE.B #0,$FFFFFA07.W
		MOVE.B #0,$FFFFFA09.W
		MOVE.B #0,$FFFFFA13.W
		MOVE.B #0,$FFFFFA15.W
		MOVE.B #0,$FFFFFA19.W
		MOVE.B #0,$FFFFFA1F.W
		MOVE.B #%01000000,$fffffa17.W
		BCLR.B #3,$FFFFFA17.W
		BSR flush
		MOVE.L #$31415926,$426.W
		MOVE.L #myreset,$42A.W
		SF hbl_on
		MOVE.W (SP)+,SR
		RTS

; Flush keyboard Buffer

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

; Allocate space for screens and clear them + make standard *160 table.

Initscreens	lea log_base(pc),a1
		move.l #$f6000,(a1)+
		move.l log_base(pc),a0
		bsr clear_screen
		move.l log_base(pc),d0
		lsr #8,d0
		move.l d0,$ffff8200.w
		rts

; Clear screen ->A0

clear_screen	moveq #0,d0
		move #1999,d1
.cls		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		dbf d1,.cls
		rts

log_base 	DC.L 0
switch		DS.W 1
vbl_timer	DS.W 1
turnoff_music	DS.W 1

pal1		dc.w	$000,$777,$000,$310,$420,$531,$642,$764
		dc.w	$700,$700,$700,$700,$700,$700,$700,$700

Print_text	MOVE.L log_base(PC),A2
		LEA font_tab-(32*4)(PC),A3
		MOVE.W (A6)+,D1
		MULU #160,D1
		ADDA D1,A2
.row_lp		MOVE.L A6,A1
		MOVEQ #0,D0
.fnd_length	MOVE.B (A1)+,D1
		BEQ.S .found_rowend
		CMP.B #1,D1
		BEQ.S .found_rowend
		EXT.W D1
		ADD.W D1,D1
		ADD.W D1,D1
		ADD.W 2(A3,D1),D0
		BRA.S .fnd_length
.found_rowend	LSR #1,D0
		NEG D0
		ADD.W #160,D0
.do1line	MOVE.B (A6)+,D1
		BEQ.S .row_done
		CMP.B #1,D1
		BEQ.S .text_done 
		MOVE D0,D2
		AND #15,D2
		LEA font_buf(PC),A0
		EXT.W D1
		ADD.W D1,D1
		ADD.W D1,D1
		ADD.W (A3,D1),A0
		MOVE.W 2(A3,D1),D6
		MOVE D0,D3
		LSR #1,D3
		AND #$FFF8,D3
		LEA (A2,D3),A1
		MOVEQ #19,D3
.linep_lp	MOVEQ #0,D1
		MOVE (A0)+,D1
		ROR.L D2,D1
		OR.W D1,(A1)
		SWAP D1
		OR.W D1,8(A1)
		MOVEQ #0,D1
		MOVE (A0)+,D1
		ROR.L D2,D1
		OR.W D1,8(A1)
		SWAP D1
		OR.W D1,16(A1)
		LEA $28-4(A0),A0
		LEA 160(A1),A1
		DBRA D3,.linep_lp
		ADD D6,D0
		BRA .do1line
.row_done	LEA 27*160(A2),A2
		BRA .row_lp
.text_done	RTS

font_tab	INCBIN ENIG1PL.TAB
font_buf	INCBIN ENIG1PL.FNT

;--------------------------------------------------------------------------
; LZW Depack routine for the JAM packer V4.0
; It is kept simple to minimise depack time.

; A0 -> packed data A1 -> depack address

depack	MOVE.L	A0,A4
	MOVE.L	A1,A6
	ADDA.L	8(A0),A4		; -> end of packed data
	ADDA.L	4(A0),A6		; -> end of unpacked data
	MOVE.L	A6,A5			;KEEP COPY TO CHECK AGAINST
	MOVE.L	4(A0),D4
	MOVE.B	#$20,D3

	MOVE.W	#$0FED,D5
	MOVEA.L A6,A3			;KEEP ADDR OF END OF SPACES

	MOVEQ	#$00,D7			;START UNPACK ROUTINE
TOPDEP:	DBF	D7,NOTUSED
	MOVE.B	-(A4),D6		;GET COMMAND BYTE
	MOVEQ	#$07,D7
NOTUSED:
	LSR.B	#1,D6
	BCC.S	COPY			;BIT NOT SET, COPY FROM UNPACKED AREA 
	MOVE.B	-(A4),-(A6)		;COPY BYTES FROM PACKED AREA
	ADDQ.W	#1,D5
	SUBQ.L	#1,D4
	BGT.S	TOPDEP
	BRA.S	EXITUP
COPY:	MOVE.B	-2(A4),D0
	LSL.W	#4,D0
	MOVE.B	-(A4),D0
	SUB.W	D5,D0
	NEG.W	D0
	AND.W	#$0FFF,D0
	LEA	1(A6,D0.W),A0
	MOVEQ	#$0F,D1
	AND.B	-(A4),D1
	ADDQ.W	#2,D1
	MOVEQ	#$01,D0
	ADD.W	D1,D0
	CMPA.L	A5,A0
	BGT.S	SPACES
	
WRITE:	MOVE.B	-(A0),-(A6)
	DBF	D1,WRITE
BACK:	ADD.L	D0,D5
	SUB.L	D0,D4
	BGT.S	TOPDEP
EXITUP:	RTS

SPACES: CMPA.L	A5,A0
	BLE.S	WRITE
	MOVE.B	D3,-(A6)		;COPY OUT SPACES
	SUBQ.L	#1,A0
	DBF	D1,SPACES
	BRA.S	BACK

;--------------------------------------------------------------------------
	 
;-----------------------------------------------------------------------;
;                           The dma load code                      	;
;			    -----------------				;	
; A0 -> points to address to read into. D2 - side to read.		;
; D0 - no of sectors to load, D1 - logical sector offset to load from.	;				
;-----------------------------------------------------------------------;

Sectptr		EQU 10

Do_load		SF fin_load				;haven't finished yet
		MOVE D0,no_sects			;sectors to go
		AND.L #$FFFF,D1
		DIVU #Sectptr,D1			;calc track offset
		MOVE D1,seektrack			;seek this track
		MOVE D1,currtrack				
		MOVE D2,sideL
		SWAP D1					;remainder+1 =
		ADDQ #1,D1				;start sector within
		MOVE D1,sector				;sector.
		MOVE.L A0,pointer				
		BSR seldrive				;select drive & side
		BSR setdiskint				;setup interrupts
		BSR do_seek				;do the seek
wait_disk	TST.B fin_load
		BEQ.S wait_disk
		MOVE SR,-(SP)
		MOVE #$2700,SR
		BCLR #7,$FFFFFA09.W			;clear int enable for fdc int
		BCLR #7,$FFFFFA15.W			;clear int mask for fdc int
		BSET #5,$FFFFFA03.W			;unactive!
		MOVE.W (SP)+,SR
		RTS

* Setup mfp for disk interrupts.

setdiskint	MOVE.W SR,-(SP)
		MOVE #$2700,SR
		BCLR #5,$FFFFFA03.W			;active edge
		BSET #7,$FFFFFA09.W			;set int enable for fdc int
		BSET #7,$FFFFFA15.W			;set int mask for fdc int
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
		SUB.L #512,pointer			;retry loading!
		MOVE.W (SP)+,D0
		BRA.S errorcont

read		MOVE.W D0,-(SP)
		MOVE.W #$80,$FFFF8606.W			;select status
		MOVE.W $FFFF8604.W,D0			;read status from last load
		BTST #3,D0				
		BNE.S loaderror
		BTST #4,D0
		BNE.S loaderror
		BTST #5,D0
		BNE.S loaderror
noerror		MOVE.W (SP)+,D0
		ADDQ #1,sector				;next sector
errorcont	TST.W no_sects
		BEQ INT_DONE		
		CMP #Sectptr,sector			;new track?
		BGT.S stepin				;yes/no -
read_rout	MOVE.B pointer+3(PC),$FFFF860D.W	;load sector
		MOVE.B pointer+2(PC),$FFFF860B.W	;dma address count
		MOVE.B pointer+1(PC),$FFFF8609.W
		MOVE.W #$90,$FFFF8606.W
		MOVE.W #$190,$FFFF8606.W		;fifo enable read
		MOVE.W #$90,$FFFF8606.W
		MOVE.W #1,$FFFF8604.W 			;read 1 sector
		MOVE.W #$84,$FFFF8606.W
		MOVE.W sector(PC),$FFFF8604.W		;say which sector
		MOVE.W #$80,$FFFF8606.W			;read it
		MOVE.W #$80,$FFFF8604.W			
		ADD.L #512,pointer			;add to pointer
		SUBQ #1,no_sects			;decrement total sects
		MOVE.L #read,$11C.W			
		RTE

* Step in a track and then continue reading

stepin		MOVE #1,sector				;reset sector count
		ADDQ #1,currtrack			;next track
		MOVE.L #read_rout,$11C.W		;continue reading
step		MOVE #$80,$FFFF8606.W			;send seek
		MOVE #64+16+8+3,$FFFF8604.W		;command to controller(+4 for verify)
		RTE

INT_DONE	MOVE.L #INT_EXIT,$11C.W			;sectors loaded
		ST fin_load				;set flag to say so
INT_EXIT	RTE

* Select current drive/side

seldrive	MOVE.W drive(PC),D0			;get bootdevice
		AND #1,D0				;isolate first bit
		ADDQ #1,D0
		ADD D0,D0				;calc right bit
		OR sideL(PC),D0
		EOR.B #7,D0
select		MOVE.B #$E,$FFFF8800.W			;select psg
		MOVE.B $FFFF8800.W,D1				
		AND.B #$F8,D1				
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W			;select drive/side
		RTS

drive		DS.W 1
seektrack	DS.W 1
currtrack	DS.W 1
pointer		DS.L 1
no_sects	DS.W 1
sideL		DS.W 1
sector		DS.W 1
fin_load	DS.W 1

; Deselect current drive e.g turn motor off!

Deselect	
		MOVE #$80,$FFFF8606.W
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

; BSS clearer 

ClearBSS	MOVE.L 2(A0),D0			; text length
		ADD.L 6(A0),D0			; + data length
		MOVE.L 10(A0),D2		; bss length
		LEA 28(A0,D0.L),A0
		MOVEQ #0,D1
.rel1_lp2	MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		SUBQ.L #8,D2
		BGE.S .rel1_lp2
		RTS

cubeTEXT	DC.W 27
		DC.B "YES !!!!",0
		DC.B " ",0
		DC.B "LET THE DEMO BEGIN",0
		DC.B "WITH A WEIRD CUBE",1
		EVEN

dotsphTEXT	DC.W 27
		DC.B "AND AS ALWAYS...",0
		DC.B " ",0
		DC.B "SOME RECORDS WILL",0
		DC.B "BE BROKEN",1
		EVEN

linesphTEXT	DC.W 27
		DC.B "WOW!!! THAT SPHERE",0
		DC.B "CONSISTED OF",0
		DC.B " ",0
		DC.B "1000 POINTS",0
		DC.B "rotated around all three axiz",1
		EVEN

solsphTEXT	DC.W 13
		DC.B "COMING UP NEXT IS",0
		DC.B " ",0
		DC.B "OLLESBOLL",0
		DC.B " ",0
		DC.B "it consists of 42 polygons",0
		DC.B "in four bitplanes",1
		EVEN

gouraudTEXT	DC.W 13
		DC.B "NEXT UP...",0
		DC.B " ",0
		DC.B "REALTIME GOURAUD",0
		DC.B "SHADED 3D ROUTINES",0
		DC.B " ",0
		DC.B "THE FASTEST",0
		DC.B "(OF COURSE)",1
		EVEN

fractalTEXT	DC.W 17
		DC.B "NOW... A CHANGE",0
		DC.B " ",0
		DC.B "WITH SOME",0
		DC.B "ORIGINAL FRACTALS",0
		DC.B " ",1
		EVEN

fracTEXT	DC.W 13
		DC.B "MORE NEW THINGS.....",0
		DC.B " ",0
		DC.B "lets hear it for",0
		DC.B "a",0
		DC.B "RAY-TRACED",0
		DC.B "FRACTAL !",1
		EVEN

rayTEXT		DC.W 17
		DC.B "THAT WAS QUITE NICE",0
		DC.B "BUT BE PATIENT!!! ",0
		DC.B " ",0
		DC.B "YOU WILL SOON SEE",0
		DC.B "SOMETHING BETTER!!!",1
		EVEN

steTEXT		DC.W 17
		DC.B " ",0
		DC.B "AND THATS",0
		DC.B "ALL THAT IS",0
		DC.B "FINISHED!",0
		DC.B " ",1
		EVEN

threedTEXT	DC.W 7
		DC.B "AND NOW ANOTHER",0
		DC.B "FIRST ON THE ST",0
		DC.B "3D WORLD DEMO",0
		DC.B "THANKS TO",0
		DC.B "SYNERGY FOR THIS",0
		DC.B "GREAT MUSIC!",1
		EVEN

endTEXT		DC.W 7
		DC.B "FINALLY LET'S DEAL",0
		DC.B "WITH THE USUAL...",0
		DC.B " ",0
		DC.B "CREDITS AND GREETS",0
		DC.B " ",0
		DC.B "AND DO ENJOY THE",0
		DC.B "ENIGMA AMIGA MUSIC.",1
		EVEN

		INCLUDE MUSIC.S

		SECTION BSS
		DS.L 399
stack		DS.L 3
