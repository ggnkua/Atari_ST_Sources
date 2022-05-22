;-----------------------------------------------------------------------;
;	  		   Hallucinations				;
;									;
; The Loader(i.e the part that loads each section, decrunchs it etc)	;
;  - Draws and Fades in/out text telling you about the next part.	;
;  - Dma Loads and decrunchs the next part. 
;									;
;-----------------------------------------------------------------------;

demo		EQU 1

		IFNE demo

		ORG $500

		ELSEIF

		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; low res
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; super visor
		ADDQ.L #6,SP
		ENDC

		BRA.W start
		BRA.W do_play			; $504 - call music
		BRA.W doFadeOutText		; $508 - fade out text

start		MOVE #$2700,SR
		LEA stack,SP
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_cols
		BSR blank_pal
		BSR set_ints
		MOVE.L #$31415926,$426.W
		MOVE.L #myreset,$42A.W
		BSR init_music
		MOVE #$2300,SR

		BSR wait_vbl

		BSR wait_vbl
		BSR blank_pal
		BSR Initscreens
		BSR Init_Hbl

lp		LEA intload(PC),A5
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

res4		MOVE.L #res4a,myJUMPthru
		LEA solsphDload(PC),A5
		LEA solsphTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeload

res4a		MOVE.L #res5,myJUMPthru
		LEA threedload(PC),A5
		LEA threedTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeloadN

res5		MOVE.L #res6,myJUMPthru
		LEA fracload(PC),A5
		LEA fracTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeload

res6		MOVE.L #res6a,myJUMPthru
		LEA rayload(PC),A5
		LEA rayTEXT(PC),A6
		MOVE.W #0,drive
		BSR fadeloadI

res6a		MOVE.L #res7,myJUMPthru
		MOVE.L #$4E714E71,clearme
		MOVE.B #8,$FFFF8800.W
		MOVE.B #0,$FFFF8802.W
		MOVE.B #9,$FFFF8800.W
		MOVE.B #0,$FFFF8802.W
		MOVE.B #10,$FFFF8800.W
		MOVE.B #0,$FFFF8802.W
		MOVE.B #7,$FFFF8800.W
		MOVE.B #-1,$FFFF8802.W
		LEA steload(PC),A5
		LEA steTEXT(PC),A6
		MOVE.W #1,drive
		BSR fadeloadN

res7		MOVE.L #res1,myJUMPthru
		LEA endload(PC),A5
		LEA endTEXT(PC),A6
		ST turnoff_music
		BSR fadeload
		BRA lp
	
cubeDload	DC.W 21,95,0
dotsphDload	DC.W 11,60,0 
linesphDload	DC.W 11,71,0
solsphDload	DC.W 13,82,0
fracload	DC.W 297,0,1
rayload		DC.W 571,120,0
endload		DC.W 297,0,1
threedload	DC.W 57,500,1
steload		DC.W 400,0,0
intload		DC.W 200,560,1
myJUMPthru	DC.L res1

Exit		MOVE #$2700,SR
		BSR rest_ints
		BSR flush
		MOVE.B #$8,$FFFFFC02.W
		MOVEQ #0,D0
		MOVEM.L old_cols(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE #$2300,SR
		CLR -(SP)			; bye for now...
		TRAP #1			

; Altair depack

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
		LEA $10000-28,A0
		MOVEM.W (A5)+,D0-D2
		BSR Do_load
		MOVEQ #15,D7
.qulp		BSR wait_vbl
		DBF D7,.qulp
		BSR wait_vbl
.nofade1	LEA $10000-28,A0
		BSR depack
		LEA $10000-28,A0
		BSR ClearBSS	
.nofade2	JSR $10000
		BSR blank_pal
		RTS

; ice depack one.

fadeloadI	PEA (A5)		
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
		LEA $10000-28,A0
		MOVEM.W (A5)+,D0-D2
		BSR Do_load
		MOVEQ #15,D7
.qulp		BSR wait_vbl
		DBF D7,.qulp
.nofade1	BSR wait_vbl
		LEA $10000-28,A0
		BSR ice_decrunch_3
		LEA $10000-28,A0
		BSR ClearBSS	
.nofade2	JSR $10000
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
		LEA $10000-28,A0
		MOVEM.W (A5)+,D0-D2
		BSR Do_load
		MOVEQ #15,D7
.qulp		BSR wait_vbl
		DBF D7,.qulp
.nofade1	BSR wait_vbl
		LEA $10000-28,A0
		BSR ice_decrunch_3
		LEA $10000-28,A0
		BSR ClearBSS	
.nofade2	BSR wait_vbl
		JSR $10000
		BSR blank_pal
		RTS

; no depack

fadeloadN	PEA (A5)		
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
		LEA $10000-28,A0
		MOVEM.W (A5)+,D0-D2
		BSR Do_load
		MOVEQ #15,D7
.qulp		BSR wait_vbl
		DBF D7,.qulp
.nofade1	BSR wait_vbl
		LEA $10000-28,A0
		BSR ClearBSS	
		BSR doFadeOutText
.nofade2	JSR $10000
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
hbl_collist	REPT 199
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
		MOVE.B #2,$FFFF820A.W
		BSR Init_Hbl
		MOVE.L myJUMPthru(PC),A0
		JMP (A0)

; Initialisation and restore interrupt routs.

set_ints	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		IFNE demo
		LEA old_stuff(pc),A0
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $500.W,(A0)+
		MOVE.L $504.W,(A0)+
		MOVE.L $508.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		ENDC
		LEA my_vbl(pc),a1
		MOVE.L a1,$70.w
		MOVE.B #0,$FFFFFA07.W
		MOVE.B #0,$FFFFFA09.W
		MOVE.B #0,$FFFFFA13.W
		MOVE.B #0,$FFFFFA15.W
		MOVE.B #0,$FFFFFA19.W
		MOVE.B #0,$FFFFFA1F.W
		move.b	#%1000000,$fffffa17.w
		BCLR.B #3,$FFFFFA17.W
		BSR flush
		MOVE.L #$31415926,$426.W
		MOVE.L #myreset,$42A.W
		SF hbl_on
		MOVE.W (SP)+,SR
		RTS

rest_ints	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		IFNE demo
		LEA old_stuff(pc),A0
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$500.W
		MOVE.L (A0)+,$504.W
		MOVE.L (A0)+,$508.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		ENDC
		MOVE.W (SP)+,SR
		RTS

; Flush keyboard Buffer

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

old_stuff	DS.L 16
old_cols	DS.W 16

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

font_tab	INCBIN D:\HALLUCIN.DEM\LOADER\ENIG1PL.TAB
font_buf	INCBIN D:\HALLUCIN.DEM\LOADER\ENIG1PL.FNT
 
;-----------------------------------------------------------------------;
;                           The dma load code                      	;
;			    -----------------				;	
; A0 -> points to address to read into. D2 - side to read.		;
; D0 - no of sectors to load, D1 - logical sector offset to load from.	;				
;-----------------------------------------------------------------------;

Sectptr		EQU 10

Do_load		SF fin_load				haven't finished yet
		MOVE D0,no_sects			sectors to go
		AND.L #$FFFF,D1
		DIVU #Sectptr,D1			calc track offset
		MOVE D1,seektrack			seek this track
		MOVE D1,currtrack				
		MOVE D2,sideL
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
		ST fin_load				set flag to say so
INT_EXIT	RTE

* Select current drive/side

seldrive	MOVE.W drive(PC),D0			get bootdevice
		AND #1,D0				isolate first bit
		ADDQ #1,D0
		ADD D0,D0				calc right bit
		OR sideL(PC),D0
		EOR.B #7,D0
select		MOVE.B #$E,$FFFF8800.W			select psg
		MOVE.B $FFFF8800.W,D1				
		AND.B #$F8,D1				
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W			select drive/side
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
.select	MOVE.B #$E,$FFFF8800.W
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
		SUBQ.L #1,D2
		BNE.S .rel1_lp2
		RTS


;decrunch source code of ATOMIK by ALTAIR	;je tiens a preciser
;A0=packed code		;que j'ai entierement
;call it by bsr		;ecris ce compacteur
			;environnement compris.
DEC_MARGE:	equ	126	;min=0 , max=126 (pair!)
RESTORE_M:	equ	1	;argh j'ai plantÇ pendant
			;10 jours sur TOTAL RECALL
			;a cause de ca!!!!!
PIC_ALGO:	equ	1	;PIC_ALGO=1,RESTORE_M=0 ; lenght=$18e
depack:	movem.l	d0-a6,-(a7)	;PIC_ALGO=0,RESTORE_M=0 ; lenght=$146
	cmp.l	#"ATOM",(a0)+	;RESTORE_M=1 ; lenght=lenght+
	bne	no_crunched	;DEC_MARGE+$32
	move.l	(a0)+,d0
	move.l	d0,-(a7)
	lea	DEC_MARGE(a0,d0.l),a5
	ifne	RESTORE_M
	move.l	a5,a4
	lea	buff_marg(pc),a3
	move	#DEC_MARGE+9,d0
.save_m:	move.b	-(a4),(a3)+
	dbf	d0,.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.l	(a0)+,d0	
	lea	0(a0,d0.l),a6
	move.b	-(a6),d7
	bra	make_jnk
tablus:	lea	tablus_table(pc),a4
	moveq	#1,d6
	bsr.s	get_bit2
	bra.s	tablus2
decrunch:	moveq	#6,d6
take_lenght:	add.b	d7,d7
	beq.s	.empty1
.cont_copy:	dbcc	d6,take_lenght
	bcs.s	.next_cod
	moveq	#6,d5
	sub	d6,d5
	bra.s	.do_copy
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#6,d5
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15+6,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_copy
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15+6,d5
.do_copy:	move	d5,-(a7)
	bne.s	bigger
	lea	decrun_table2(pc),a4
	moveq	#2,d6
	bsr.s	get_bit2
	cmp	#5,d5
	blt.s	contus
	addq	#2,a7
	subq	#6,d5
	bgt.s	tablus
	move.l	a5,a4
	blt.s	.first4
	addq	#4,a4
.first4:	moveq	#1,d6
	bsr.s	get_bit2
tablus2:	move.b	0(a4,d5.w),-(a5)	
	bra.s	make_jnk
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	lea	decrun_table(pc),a4
cont:	moveq	#2,d6
	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	bsr.s	get_bit2
	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move	(a7)+,d5
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d5,.copy_same
make_jnk:	moveq	#11,d6
	moveq	#11,d5
take_jnk:	add.b	d7,d7
	beq.s	empty
cont_jnk:	dbcc	d6,take_jnk
	bcs.s	next_cod
	sub	d6,d5
	bra.s	copy_jnk1
next_cod:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#8,d5
	addq	#3,d5
	bra.s	copy_jnk1
.next_cod1:	moveq	#2,d6
	bsr.s	get_bit2
	swap	d5
	moveq	#15,d6
	bsr.s	get_bit2
	addq.l	#8,d5
	addq.l	#3,d5	
copy_jnk1:	subq	#1,d5
	bmi.s	.end_word
	moveq	#1,d6
	swap	d6
.copy_jnk:	move.b	-(a6),-(a5)
	dbf	d5,.copy_jnk
	sub.l	d6,d5
	bpl.s	.copy_jnk
.end_word:	cmp.l	a6,a0
.decrunch:	bne	decrunch
	cmp.b	#$80,d7
	bne.s	.decrunch
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	bsr	decod_picture
	endc
	ifne	RESTORE_M
	movem.l	(a7)+,a3-a4
	endc
	move.l	(a7)+,d0
	bsr	copy_decrun
	ifne	RESTORE_M
	move	#DEC_MARGE+9,d0
.restore_m:	move.b	-(a3),(a4)+
	dbf	d0,.restore_m
	endc
no_crunched:	movem.l	(a7)+,d0-a6
 	rts
empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	cont_jnk
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	4,5,7,8,9,10,11,12
decrun_table2:	dc.w	32,32+64,32+64+128,32+64+128+256
	dc.w	32+64+128+256+512,32+64+128+256+512*2
	dc.w	32+64+128+256+512*3
	dc.b	4,5,6,7,8,8
tablus_table:	dc.b	$60,$20,$10,$8
	ifne	PIC_ALGO
decod_picture:	move	-(a0),d7
	clr	(a0)
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	clr.l	(a0)
	lea	0(a5,d0.l),a1
	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	ifne	RESTORE_M
buff_marg:	dcb.b	DEC_MARGE+10,0
	endc

;********************************************* Unpackroutine von ICE-PACK
; Eingabe: a0 = Adresse gepackter Daten
ice_decrunch_3:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	move.l	a0,a1
	move.l	a0,a4		; a4 = Anfang entpackte Daten
	move.l	a0,a6		; a6 = Ende entpackte Daten
	bsr.s	.getinfo
	cmpi.l	#'ICE!',d0	; Kennung gefunden?
	bne	.not_packed
	bsr.s	.getinfo		; gepackte LÑnge holen
	moveq	#119,d1		; 120 Bytes vor gepackten Daten
.save:	move.b	-(a1),-(a3)	; in sicheren Bereich sichern
	dbf	d1,.save
	move.l	a1,a2		; Anfang der gepackten Daten
	lea.l	-8(a1,d0.l),a5	; a5 = Ende der gepackten Daten
.move	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.move
	move.l	a2,a0
	bsr.s	.getinfo		; ungepackte LÑnge holen (original)
	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a3		; merken fÅr Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr.s	.normal_bytes

.no_picture

	movem.l	(sp),d0-a3	; hole nîtige Register
	moveq	#119,d0		; um Åberschriebenen Bereich
.rest	move.b	-(a3),-(a4)	; wieder herzustellen
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1		; ein Langwort vom Anfang
.getbytes: lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,.nextgb	; ja: dann weiter Bits lesen
.no_more: add.l	20(a1),d1 	; Anzahl der zu Åbertragenen Bytes
.copy_direkt:	
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,.copy_direkt	; noch ein Byte
.test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	.strings		; Weiter wenn Ende nicht erreicht
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schluû

.get_1_bit:add.b	d7,d7		; hole ein bit
	bne.s	.bitfound 	; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.bitfound:	rts	

.get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	.on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,.hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


.strings: lea.l	.length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit	; nÑchstes Bit holen
.no_length_bit:	
	moveq.l	#0,d4		; d4 = öberschuû-LÑnge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	.no_Åber		; kein öberschuû nîtig
.get_Åber: bsr.s	.get_d0_bits
.no_Åber: move.b	6(a1,d2.w),d4	; Standard-LÑnge zu öberschuû add.
	add.w	d1,d4		; d4 = String-LÑnge-2
	beq.s	.get_offset_2	; LÑnge = 2: Spezielle Offset-Routine


	lea.l	.more_offset(pc),a1 ; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1		; Offset-öberschuû
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	.get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu öberschuû add.
	bpl.s	.depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1		; öberschuû-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	.get_1_bit
	bcc.s	.less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1		; Standard-Offset + öber-Offset

.depack_bytes:			; d1 = Offset, d4 = Anzahl Bytes
	lea.l	2(a6,d4.w),a1	; Hier stehen die Originaldaten
	adda.w	d1,a1		; Dazu der Offset
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d4,.dep_b 	; und noch ein Mal
	bra	.normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1	; Anz. Bytes

.length_tab:
	dc.b 9,1,0,-1,-1		; Bits lesen
	dc.b 8,4,2,1,0		; Standard-LÑnge - 2 (!!!)

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

ende_ice_decrunch_3:

;*************************************************** Ende der Unpackroutine

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
		DC.B "800 POINTS",0
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

fracTEXT	DC.W 13
		DC.B "MORE NEW THINGS.....",0
		DC.B " ",0
		DC.B "lets hear it for",0
		DC.B "a",0
		DC.B "RAY-TRACED",0
		DC.B "FRACTAL !",1

rayTEXT		DC.W 17
		DC.B "THAT WAS QUITE NICE",0
		DC.B "BUT BE PATIENT!!! ",0
		DC.B " ",0
		DC.B "YOU WILL SOON SEE",0
		DC.B "SOMETHING BETTER!!!",1

steTEXT		DC.W 17
		DC.B "NEXT WE HAVE A",0
		DC.B "DEMONSTRATION OF",0
		DC.B "STE POWER",0
		DC.B "THIS PART CANNOT",0
		DC.B "BE MADE ON STFM...",1

threedTEXT	DC.W 7
		DC.B "AND NOW ANOTHER",0
		DC.B "FIRST ON THE ST",0
		DC.B "3D WORLD DEMO",0
		DC.B "THANKS TO",0
		DC.B "SYNERGY FOR THIS",0
		DC.B "GREAT MUSIC!",1

endTEXT		DC.W 7
		DC.B "FINALLY LET'S DEAL",0
		DC.B "WITH THE USUAL...",0
		DC.B " ",0
		DC.B "CREDITS AND GREETS",0
		DC.B " ",0
		DC.B "AND DO ENJOY THE",0
		DC.B "ENIGMA AMIGA MUSIC.",1
		EVEN

		INCLUDE D:\HALLUCIN.DEM\LOADER\MUSIC.S

		SECTION BSS
		DS.L 349
stack		DS.L 3
