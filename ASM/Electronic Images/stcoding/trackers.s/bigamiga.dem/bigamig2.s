;--------------------------------------------------------------------------
;
;       	     B i g Amiga Sound Emulator Demo
;                   by Martin Griffiths (C) July 1992
;
;--------------------------------------------------------------------------

; SetVideo() equates.

VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000

; Falcon video register equates

vhz	        EQU $FFFF820A
voff_nl     EQU $FFFF820E
vwrap       EQU $FFFF8210
_stshift	EQU $FFFF8260
_sshift    EQU $FFFF8266
hht         EQU $FFFF8282
hbb         EQU $FFFF8284
hbe         EQU $FFFF8286
hdb         EQU $FFFF8288
hde         EQU $FFFF828A
hss         EQU $FFFF828C
hfs         EQU $FFFF828E
hee         EQU $FFFF8290
vft         EQU $FFFF82A2
vbb         EQU $FFFF82A4
vbe         EQU $FFFF82A6
vdb         EQU $FFFF82A8
vde         EQU $FFFF82AA
vss         EQU $FFFF82AC
vco_hi      EQU $FFFF82C0
vco         EQU $FFFF82C2

gemrun		EQU 0				; 0 = run from gem
						; 1 = no gem calls	
letsgo		
		IFEQ gemrun
		MOVE.W #4,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.W D0,oldres
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase

		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		bsr Save_Rez
		ENDC
		LEA my_stack,SP
		MOVE.W #$8240,A0
		MOVE.W #$9800,A1
		REPT 8
		CLR.L (A0)+
		CLR.L (A1)+
		CLR.L (A1)+
		ENDR
		BSR init_2screens
		LEA text(PC),A6
		BSR Print_Text
		JSR Ste_Test
		BSR init_ints
		BSR wait_vbl
		BSR wait_vbl
		MOVEQ #0,D0
		BSR .init_themusic	

.waitspace	BSR wait_vbl
		MOVE.B key,D0
		CMP.B #2,D0
		BNE.S .n1
		MOVEQ #0,D0
		BRA.W .init_themusic
.n1		CMP.B #3,D0
		BNE.S .n2
		MOVEQ #1,D0
		BRA.W .init_themusic
.n2		CMP.B #4,D0
		BNE.S .n3
		MOVEQ #2,D0
		BRA.W .init_themusic
.n3		CMP.B #5,D0
		BNE.S .n4
		MOVEQ #3,D0
		BRA.W .init_themusic
.n4		CMP.B #6,D0
		BNE.S .n5
		MOVEQ #4,D0
		BRA.W .init_themusic
.n5		CMP.B #7,D0
		BNE.S .n6
		MOVEQ #5,D0
		BRA.W .init_themusic
.n6		CMP.B #8,D0
		BNE.S .n7
		MOVEQ #6,D0
		BRA.W .init_themusic
.n7		CMP.B #9,D0
		BNE.S .n8
		MOVEQ #7,D0
		BRA.W .init_themusic
.n8		CMP.B #10,D0
		BNE.S .n9
		MOVEQ #8,D0
		BRA.W .init_themusic
.n9		CMP.B #16,D0
		BNE.S .n10
		MOVEQ #9,D0
		BRA.W .init_themusic
.n10		CMP.B #17,D0
		BNE.S .n11
		MOVEQ #10,D0
		BRA.W .init_themusic
.n11		CMP.B #18,D0
		BNE.S .n12
		MOVEQ #11,D0
		BRA.W .init_themusic
.n12		CMP.B #19,D0
		BNE.S .n13
		MOVEQ #12,D0
		BRA.W .init_themusic
.n13		CMP.B #20,D0
		BNE.S .n14
		MOVEQ #13,D0
		BRA.W .init_themusic
.n14		CMP.B #21,D0
		BNE.S .n15
		MOVEQ #14,D0
		BRA.W .init_themusic
.n15		CMP.B #22,D0
		BNE.S .n16
		MOVEQ #15,D0
		BRA.W .init_themusic
.n16		CMP.B #23,D0
		BNE.S .n17
		MOVEQ #16,D0
		BRA.W .init_themusic
.n17		CMP.B #24,D0
		BNE.S .n18
		MOVEQ #17,D0
		BRA.W .init_themusic
.n18		CMP.B #25,D0
		BNE.S .n19
		MOVEQ #18,D0
		BRA.W .init_themusic
.n19
		CMP.B #$39,D0
		BNE .waitspace

		BSR rotfile+12			; stop those timer ints!
		BSR restore_ints

		IFEQ gemrun
		bsr Restore_Rez
		move.w	#-1,-(sp)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		CLR -(SP)
		TRAP #1
		ENDC


.init_themusic	CMP.W currtune,D0
		BEQ .waitspace
		MOVE.L D0,-(SP)
		BSR wait_vbl
		BSR rotfile+12			; stop those timer ints!
		MOVE.L (SP)+,D0

		MOVE.W D0,currtune
		ADD.W D0,D0
		ADD.W D0,D0
		LEA tune_inits(PC),A0
		MOVE.L (A0,D0.W),rotfile+20
		MOVEQ #1,D0
		MOVEQ #0,D1
		BSR rotfile+8			; 
		BRA.W .waitspace

currtune	DC.W -1

tune_inits	
		DC.L sndmon_init1 
		DC.L sndmon_init2 
		DC.L sndmon_init3 
		DC.L jmcrk_init1
		DC.L jmcrk_init2
		DC.L sonic_init1
		DC.L sonic_init2
		DC.L fut_init1
		DC.L fut_init2
		DC.L fut_init3
		DC.L fut_init4
		DC.L init_tfmx1
		DC.L init_tfmx2
		DC.L init_tfmx3
		DC.L pro_init1 
		DC.L pro_init2 
		DC.L pro_init3
		DC.L ruby_init1
		DC.L ruby_init2

Save_Rez:	move.w	#37,-(sp)
			trap	#14
			addq.l	#2,sp
			lea		saved_res,a0
		    move.w  (voff_nl.w),(a0)+
			MOVE.W  (vwrap.w),(a0)+
			move.l  (_sshift-2.w),(a0)+		
			LEA 	(hht).w,A1
			MOVE.L	(a1)+,(A0)+
			MOVE.L	(a1)+,(A0)+
			MOVE.L	(a1)+,(A0)+
			MOVE.L	(a1)+,(A0)+
			move.W	(vft.w),(a0)+
			move.w	(vbe.w),(a0)+ 
			move.w 	(vbb.w),(a0)+	
			move.w	(vdb.w),(a0)+
			move.w	(vde.w),(a0)+
			move.w	(vss.w),(a0)+
	        move.l  (vco_hi.w),(a0)+
			move.w  (vhz.w),(a0)+
			RTS

Restore_Rez:LEA		saved_res,a0
		    move.w  (a0)+,(voff_nl.w)
			MOVE.W  (a0)+,(vwrap.w)
			move.l  (a0)+,(_sshift-2.w)
			LEA 	(hht).w,A1
			MOVE.L	(a0)+,(a1)+
			MOVE.L	(a0)+,(a1)+
			MOVE.L	(a0)+,(a1)+
			MOVE.L	(a0)+,(a1)+
			move.W	(a0)+,(vft.w)
			move.w	(a0)+,(vbe.w)
			move.w 	(a0)+,(vbb.w)
			move.w	(a0)+,(vdb.w)
			move.w	(a0)+,(vde.w)
			move.w	(a0)+,(vss.w)
	        move.l  (a0)+,(vco_hi.w)
			move.w  (a0)+,(vhz.w)
			RTS
		
 
;-------------------------------------------------------------------------
; Interrupt setup routines

; Save mfp vectors and ints and install our own.(very 'clean' setup rout)

init_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff(PC),A0
		MOVE.L USP,A1
		MOVE.L A1,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $B0.W,(A0)+
		MOVE.L $110.W,(A0)+
		MOVE.L $118.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA0B.W,(A0)+
		MOVE.B $FFFFFA0D.W,(A0)+
		MOVE.B $FFFFFA0F.W,(A0)+
		MOVE.B $FFFFFA11.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+	; restore mfp
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.B $FFFFFA25.W,(A0)+
		MOVE.B #$20,$FFFFFA07.W
		MOVE.B #$40,$fffffa09.W
		MOVE.B #$20,$FFFFFA13.W
		MOVE.B #$40,$fffffa15.W
		MOVE.L #togglesuper,$B0.W
		BCLR.B #3,$fffffa17.W		; software end of int.
		LEA vbl(PC),A0
		MOVE.L A0,$70.W			; set our vbl
		LEA key_rout(PC),A0
		MOVE.L A0,$118.W		; and our keyrout.
		CLR key			
		MOVE.B #$00,$FFFFFA0F.W
		MOVE.B #$00,$FFFFFA11.W		; dummy service.
		MOVE.B #$00,$FFFFFA0B.W
		MOVE.B #$00,$FFFFFA0D.W		; clear any pendings
		CLR.B	$FFFFFA19.W
		MOVE.L	#MUSIC_INT,$134.W
		MOVE.B	#245,$FFFFFA1F.W
		MOVE.B	#7,$FFFFFA19.W
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume sending
		BSR Writeikbd
		MOVEQ #$12,D0			; kill mouse
		BSR Writeikbd
		BSR flush
		RTS

togglesuper	BCHG #13-8,(SP)
		RTE

; Restore mfp vectors and ints.

restore_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff(PC),A0
		MOVE.L (A0)+,A1
		MOVE.L A1,USP
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$B0.W
		MOVE.L (A0)+,$110.W
		MOVE.L (A0)+,$118.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA0B.W
		MOVE.B (A0)+,$FFFFFA0D.W
		MOVE.B (A0)+,$FFFFFA0F.W
		MOVE.B (A0)+,$FFFFFA11.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W	; restore mfp
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.B (A0)+,$FFFFFA25.W
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume
		BSR Writeikbd		
		MOVEQ #$8,D0			; restore mouse.
		BSR Writeikbd
		BSR flush
		RTS

old_stuff:	DS.L 32
oldvideo	DS.W 1
oldres		DS.W 1
oldbase		DS.L 1
oldsp		DS.L 1

; Allocate and Initialise(clear) screen memory.

init_2screens	
		MOVE.L #screen,d0
		add.l	#256,d0
		clr.b	d0
		move.l	d0,phy_base
		move.l	d0,a0
		BSR cls
		LSR.W	#8,D0
		MOVE.L	D0,$FFFF8200.W
		move.w	#BPS4+VGA+COL80,-(SP)	
		move.w	#$58,-(SP)	
		TRAP #14
		ADDQ.L #4,SP
		

		RTS

; Clear a 48k screen. a0 -> screen.

cls		MOVE.L A0,A2
		MOVEQ #0,D2
		MOVE.W #((320*480)/16)-1,D1
.cls_lp		MOVE.L D2,(A2)+
		MOVE.L D2,(A2)+
		MOVE.L D2,(A2)+
		MOVE.L D2,(A2)+
		DBF D1,.cls_lp
		RTS

;-------------------------------------------------------------------------

vbl		
		MOVEM.L D0-D7/A0-A6,-(SP)
		MOVEM.L pal1(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		move.l	#$0,$ffff9800.w
		move.l	#$ffff00ff,$ffff9804.w
		MOVEM.L (SP)+,D0-D7/A0-A6
	
		ADDQ #1,vbl_timer
		RTE
pal1		DC.W $000,$577,$000,$000,$000,$000,$000,$000
		DC.W $000,$000,$000,$000,$000,$000,$000,$000

; Wait for a vbl..

wait_vbl	LEA vbl_timer(PC),A0
		MOVE.W (A0),D0
.wait_vbl	CMP.W (A0),D0
		BEQ.S .wait_vbl
		RTS

WaitD7Vbls	
.wait_lp	BSR wait_vbl
		DBF D7,.wait_lp
		RTS

; Flush IKBD

flush		BTST.B #0,$FFFFFC00.W		; any waiting?
		BEQ.S .flok			; exit if none waiting.
		MOVE.B $FFFFFC02.W,D0		; get next in queue
		BRA.S flush			; and continue
.flok		RTS

; Write d0 to IKBD

Writeikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Writeikbd			; wait for ready
		MOVE.B D0,$FFFFFC02.W		; and send...
		RTS

; Keyboard handler interrupt routine...

key_rout	MOVE #$2500,SR			; ipl 5 for 'cleanness' 
		MOVE D0,-(SP)
		MOVE.B $FFFFFC00.W,D0
		BTST #7,D0			; int req?
		BEQ.S .end			
		BTST #0,D0			; 
		BEQ.S .end
		MOVE.B $FFFFFC02.W,key		; store keypress
.end		MOVE (SP)+,D0
		RTE
key		DC.W 0
vbl_timer	DC.W 0
log_base	DC.L 0
phy_base	DC.L 0

; Print (and centre) text. a6-> text
	
Print_text	MOVE.L phy_base(PC),A2
		LEA 48*320(A2),A2
		MOVE.W (A6)+,D1
		MULU #320,D1
		ADDA D1,A2 
.row_lp		MOVE.L A6,A1
		MOVEQ #0,D0
.fnd_length	MOVE.B (A1)+,D1
		BEQ.S .found_rowend
		CMP.B #1,D1
		BEQ.S .found_rowend
		EXT.W D1
		ADD.W D1,D1
		ADDQ.W #8,D0
		BRA.S .fnd_length
.found_rowend	LSR #1,D0
		NEG D0
		ADD.W #320,D0
.do1line	MOVE.B (A6)+,D1
		BEQ.S .row_done
		CMP.B #1,D1
		BEQ.S .text_done 
		MOVE D0,D2
		AND #15,D2
		LEA font_buf(PC),A0
		EXT.W D1
		SUB.B #32,D1
		LSL.W #3,D1
		ADD.W D1,A0
		MOVE D0,D3
		LSR #1,D3
		AND #$FFF8,D3
		LEA (A2,D3),A1
		MOVEQ #7,D3
.linep_lp	MOVEQ #0,D1
		MOVE.B (A0)+,D1
		ROR.L D2,D1
		OR.W D1,(A1)
		SWAP D1
		OR.W D1,8(A1)
		LEA 320(A1),A1
		DBRA D3,.linep_lp
		ADDQ #8,D0
		BRA .do1line
.row_done	LEA 8*320(A2),A2
		BRA .row_lp
.text_done	RTS

font_buf	INCBIN MET_09.FN8

text		DC.W 0
		DC.B "The Amiga Sound Emulator",0
		DC.B "Programmed by Martin Griffiths",0
		DC.B " ",0

		DC.B "   ------- Sound Monitor V2.0 -------",0
		DC.B "1: Commando                        51k",0
		DC.B "2: Green Beret                     53k",0
		DC.B "3: StormLord(?)                    47k",0
		DC.B "   --------- Jam Crack V2.0 ---------",0
		DC.B "4: Mental Relapse                  28k",0
		DC.B "5: Comic Bakery                    18k",0 
		DC.B "   ----- Sonic Projects Tracker -----",0
		DC.B "6: Sanxion Remix                   88k",0
		DC.B "7: Jan Hammer Remix                56k",0
		DC.B "   ------ Future Composer V1.4 ------",0
		DC.B "8: Chambers of Shaolin 1           35k",0
		DC.B "9: Chambers of Shaolin 2           34k",0
		DC.B "Q: The Seven Gates of Jambala      90k",0
		DC.B "W: Astorath 2                      70k",0
		DC.B "   -------------- TFMX --------------",0  
		DC.B "E: Turrican 2 World 1 Main Theme   71k",0
		DC.B "R: Turrican 2 World 2 Main Theme   78k",0
		DC.B "T: Turrican 2 World 3 Main Theme   78k",0
		DC.B "   -------- ProTracker V1.1B --------",0
		DC.B "Y: Yans Highscore theme            61k",0
		DC.B "U: Termination Day                 15k",0
		DC.B "I: StarWorx                        16k",0
		DC.B "   -- Charles Deenans Amiga Driver --",0
		DC.B "O: Rubicon Main Title Theme        99k",0
		DC.B "P: Rubicon Highscore Theme         62k",0
		DC.B "   ---- SoundImages Amiga Driver ----",0
		DC.B "A: Moonfall                        52k",0
		DC.B "--------------------------------------",0
		DC.B " ",1
		EVEN

;-------------------------------------------------------------------------

sndmon_init1	LEA commando,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #BS_Music,rotfile+24
		MOVE.L #mus_data,BS_DATA_PTR
		JMP BS_INIT

sndmon_init2	LEA greenberet,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #BS_Music,rotfile+24
		MOVE.L #mus_data,BS_DATA_PTR
		JMP BS_INIT

sndmon_init3	LEA stormlord,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #BS_Music,rotfile+24
		MOVE.L #mus_data,BS_DATA_PTR
		JMP BS_INIT

jmcrk_init1	LEA mentalre,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #pp_play,rotfile+24
		MOVE.L #mus_data,jcdata_ptr
		JMP _pp_init

jmcrk_init2	LEA comicbak,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #pp_play,rotfile+24
		MOVE.L #mus_data,jcdata_ptr
		JMP _pp_init

sonic_init1	LEA thalamusic,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #ct_music,rotfile+24
		MOVE.L #mus_data,ct_data_ptr
		JMP ct_init

sonic_init2	LEA jan_hamm,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #ct_music,rotfile+24
		MOVE.L #mus_data,ct_data_ptr
		JMP ct_init

fut_init1	LEA shaolin1,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #PLAY,rotfile+24
		MOVE.L #mus_data,fc_mus_ptr
		JMP INIT_MUSIC

fut_init2	LEA shaolin2,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #PLAY,rotfile+24
		MOVE.L #mus_data,fc_mus_ptr
		JMP INIT_MUSIC

fut_init3	LEA jambala,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #PLAY,rotfile+24
		MOVE.L #mus_data,fc_mus_ptr
		JMP INIT_MUSIC

fut_init4	LEA astorath2,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #PLAY,rotfile+24
		MOVE.L #mus_data,fc_mus_ptr
	     	JMP INIT_MUSIC


init_tfmx1	MOVE.L #Play_T2,rotfile+24	
		Lea T2_Song1,a0
		Move.l	a0,d0
		Lea T2_Smpl1,a0
		Move.l	a0,d1
		Jsr T2_Replay+$14
		Jsr T2_Replay+$8
		Moveq	#0,d0			; Tune Number
		JMP T2_Replay+$c
init_tfmx2	MOVE.L #Play_T2,rotfile+24	
		Lea T2_Song2,a0
		Move.l	a0,d0
		Lea T2_Smpl2,a0
		Move.l	a0,d1
		Jsr T2_Replay+$14
		Jsr T2_Replay+$8
		Moveq	#0,d0			; Tune Number
		JMP T2_Replay+$c
init_tfmx3	MOVE.L #Play_T2,rotfile+24	
		Lea T2_Song3,a0
		Move.l	a0,d0
		Lea T2_Smpl3,a0
		Move.l	a0,d1
		Jsr T2_Replay+$14
		Jsr T2_Replay+$8
		Moveq	#0,d0			; Tune Number
		JMP T2_Replay+$c

pro_init1	LEA fullyan,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #mt_music,rotfile+24	
		MOVE.L #mus_data,mt_data_ptr
		JMP mt_init

pro_init2	LEA term_day,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #mt_music,rotfile+24	
		MOVE.L #mus_data,mt_data_ptr
		JMP mt_init

pro_init3	LEA starworx,a0
		LEA mus_data,A1
		BSR UNPACK
		MOVE.L #mt_music,rotfile+24	
		MOVE.L #mus_data,mt_data_ptr
		JMP mt_init

ruby_init1	MOVE.L #RUBYMUSIC+4,rotfile+24
		MOVEQ #0,D0
		JSR RUBYMUSIC
		MOVEQ #1,D0
		JSR RUBYMUSIC+8
		RTS

ruby_init2	MOVE.L #RUBYMUSIC+4,rotfile+24
		MOVEQ #0,D0
		JSR RUBYMUSIC
		MOVEQ #2,D0
		JSR RUBYMUSIC+8
		RTS

;ATOMIK DECRUNCH SOURCE CODE v3.5 (non optimise, pas le temps. sorry...)

;ce depacker est indissociable du programme ATOMIK V3.5 tous les mecs
;qui garderons se source dans l'espoir de prendre de l'importance
;en se disant moi je l'ai et pas l'autre sont des lamers.

;MODE=1 depack data from a0 to a0 
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)

;PIC_ALGO = 0 decrunch file not encoded with special picture algorythm.
;PIC_ALGO = 1 decrunch all files with or without picture algorythm.

;DEC_SPACE = (lesser decrunch space is gived after packing by atomik v3.5)
             
;RESTORE_SPACE = 1 the allocated decrunch space will be restored .
;RESTORE_SPACE = 0 the allocated decrunch space will not be restored.

;call it by BSR DEPACK or JSR DEPACK but call it!

 
UNPACK:
	MOVE.W	$FFFF8240.W,-(A7)
	BSR depack
	MOVE.W	(A7)+,$FFFF8240.W
	RTS


MODE:	EQU	0
PIC_ALGO:	EQU	0
DEC_SPACE:	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	0

depack:	movem.l	d0-a6,-(a7)
	cmp.l	#"ATM5",(a0)+
	bne	not_packed
	link	a2,#-28
	move.l	(a0)+,d0
	ifne	MODE
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	elseif
	move.l	a1,a5
	add.l	d0,a5
	endc
	move.l	a5,a4
	ifne	MODE
	ifne	DEC_SPACE
	lea	DEC_SPACE(a4),a5
	endc
	endc
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	ifne	PIC_ALGO
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	ifne	RESTORE_SPACE
	lsl	#2,d0
	sub	d0,a4
	endc
	elseif
	ifne	RESTORE_SPACE
	clr	-2(a2)
	endc
	subq	#1,a6
	endc
	ifne	RESTORE_SPACE
	lea	buff_marg(pc),a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.save
.save_m:	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	take_type
decrunch:	move	d3,d5
take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	decrun_table(pc),a4
	move	d5,d2
	bne.s	bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	word
.ho_kesako:	moveq	#3,d6
	bsr.s	get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	tst_end
.ho_kesako1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	tst_end
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
bigger:	moveq	#2,d6
word:	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	get_bit2
.spe_ofcod2:	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk:	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	string
	move.b	-(a6),-(a5)
tst_end:
	move.w d7,$ffff8240.w
	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l	(a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m:	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:	bne.s	.restore_m
	endc
	unlk	a2
not_packed:	movem.l	(a7)+,d0-a6
 	rts
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
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
	ifne	MODE
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc
	ifne	RESTORE_SPACE
buff_marg:	dcb.b	$90+DEC_SPACE+$C
	endc

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------

MUSIC_INT:	MOVEM.L D0-D7/A0-A6,-(SP)
		BSR rotfile+4			; call sequencer
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE

; The Paula Emu v2.0

rotfile		BRA.W Init_PAL_or_NTSC
		BRA.W Vbl_play
		BRA.W Init_ST
		BRA.W stop_ints
		DC.L vol_bitflag-rotfile
init_ptr	DC.L 0
play_ptr	DC.L 0

		DC.B "ST/STE/TT Digi-Driver "
		DC.B "By Martin Griffiths(aka Griff of Inner Circle),"
		EVEN

speed		EQU 38    			; timer d (17KHZ)

; Select PAL/NTSC

Init_PAL_or_NTSC
		RTS

; Initialise Music Sequencer and ST Specific bits (e.g interrupts etc.)
; D0=0 then turn music OFF. D1=0 straight off else d1=fadeOUT speed.
; D0=1 then turn music ON.  D1=0 straight on else d1=fadeIN speed.

Init_ST		LEA vol_bitflag(PC),A0	
		BSET #0,(A0)		; still fading.
		LEA fadeINflag(PC),A0
		SF (A0)			; reset fade IN flag 
		LEA fadeOUTflag(PC),A0
		SF (A0)			; reset fade OUT flag
		TST.B D0		
		BNE.S .init_music

; Deinitialise music - turn off/fade out.

.deinit_music	TST.B D1		; any fade down?
		BNE.S .trigfadedown
		LEA global_vol(PC),A0
		MOVE.W #$0,(A0) 	; turn off music
		RTS
.trigfadedown	LEA fadeOUTflag(PC),A0
		ST.B (A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		RTS

; Initialise music - turn on/fade in.

.init_music	TST.B D1
		BNE.S .trigfadein
		LEA global_vol(PC),A0
		MOVE.W #$40,(A0) 	; assume no fade in.
		MOVE.L init_ptr(PC),A0
		JSR (A0)

		BRA STspecific
.trigfadein	LEA global_vol(PC),A0
		MOVE.W #$0,(A0) 	; ensure zero to start with!
		LEA fadeINflag(PC),A0
		ST.B (A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		MOVE.L init_ptr(PC),A0
		JSR (A0)
		BRA STspecific

vol_bitflag	DC.W 0
global_vol	DC.W 0
fadeOUTflag	DC.B 0
fadeOUTcurr	DC.B 0
fadeOUTspeed	DC.B 0
fadeINflag	DC.B 0
fadeINcurr	DC.B 0
fadeINspeed	DC.B 0

		EVEN

; Paula emulation storage structure.

		RSRESET
sam_start	RS.L 1				; sample start
sam_length	RS.W 1				; sample length
sam_period	RS.W 1				; sample period(freq)
sam_vol		RS.W 1				; sample volume
sam_lpstart	RS.L 1				; sample loop start
sam_lplength	RS.W 1	 			; sample loop length
sam_vcsize	RS.B 1				; structure size.

basespeed	DC.W 0

ch1s		DS.B sam_vcsize
ch2s		DS.B sam_vcsize			; shadow channel regs
ch3s		DS.B sam_vcsize
ch4s		DS.B sam_vcsize
shadow_dmacon	DS.W 1
shadow_dff09a	DS.W 1
shadow_dff09c	DS.W 1
shadow_filter	DS.W 1
saved4		DS.L 1
freqconst	DS.L 1

; Macro to move parameter '\1' into the shadow dma register...
; (Remember - bit 15 of 'dmacon' determines clearing or setting of bits!)

move_dmacon	MACRO
.setdma\@	MOVE.W D4,saved4		; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dmacon		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dmacon		; not zero so set 'em
.dmacon_set\@	MOVE.W saved4,D4		; restore D4
		ENDM

move_dff09a	MACRO
.setdma\@	MOVE.W D4,saved4			; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dff09a		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dff09a		; not zero so set 'em
.dmacon_set\@	MOVE.W saved4,D4			; restore D4
		ENDM

move_dff09c	MACRO
.setdma\@	MOVE.W D4,saved4		; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dff09c		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dff09c		; not zero so set 'em
.dmacon_set\@	MOVE.W saved4,D4			; restore D4
		ENDM

; Vbl player - This is THE  'Paula' Emulator.

Vbl_play:	LEA music_on(PC),A0
		TST.B (A0)			; music on?
		BEQ skipit			; if not skip all!

.do_fadein	LEA fadeINflag(PC),A0
		TST.B (A0)			; are we fadeing down?
		BEQ.S .nofadein
		SUBQ.B #1,1(A0)			; curr count-1
		BNE.S .nofadein
		MOVE.B 2(A0),1(A0)		; reset count
		LEA global_vol(PC),A1
		CMP #$40,(A1)			; reached max?
		BLT.S .notinyet
		SF (A0)				; global vol=$40!
		LEA vol_bitflag(PC),A1
		BCLR #0,(A1)			; signal fade done
		BRA.S .nofadein
.notinyet	ADDQ #1,(A1)			; global vol+1
.nofadein
.do_fadedown	LEA fadeOUTflag(PC),A0
		TST.B (A0)			; are we fadeing down?
		BEQ.S .nofadedown
		SUBQ.B #1,1(A0)			; curr count-1
		BNE.S .nofadedown
		MOVE.B 2(A0),1(A0)		; reset count
		LEA global_vol(PC),A1
		TST.W (A1)
		BNE.S .notdownyet
		SF (A0)				; global vol=0!
		LEA vol_bitflag(PC),A1
		BCLR #0,(A1)			; signal fade done
		BRA.S .nofadedown
.notdownyet	SUBQ #1,(A1)			; global vol-1
.nofadedown	
.STE_read	BSR Set_DMA
		LEA $FFFF8909.W,A0
.read		MOVEP.L 0(A0),D0		; major design flaw in ste
		DCB.W 15,$4E71			; h/ware we must read the
		MOVEP.L 0(A0),D1		; frame address twice
		LSR.L #8,D0			; since it can change
		LSR.L #8,D1			; midway thru a read!
		CMP.L D0,D1			; so we read twice and
		BNE.S .read			; check the reads are
						; the same!!!!
.notwrap	MOVE.L buff_ptr(PC),A4
		MOVE.L A4,lastwrt_ptr
		MOVE.L D0,buff_ptr
		CMP.L D0,A4
		BEQ skipit

		LEA.L Voice1Set(PC),A0		; Setup Chan 1
		LEA.L ch1s(PC),A5
		MOVEQ #0,D4
		BSR SetupVoice		
		LEA.L Voice2Set(PC),A0		;      "     2
		LEA.L ch2s(PC),A5
		MOVEQ #1,D4
		BSR SetupVoice		
		LEA.L Voice3Set(PC),A0  	;      "     3
		LEA.L ch3s(PC),A5
		MOVEQ #2,D4
		BSR SetupVoice
		LEA.L Voice4Set(PC),A0  	;      "     4
		LEA.L ch4s(PC),A5
		MOVEQ #3,D4
		BSR SetupVoice
		BSR Goforit
		MOVE.L play_ptr(PC),A0
		JMP (A0)
skipit		RTS

		RSRESET
Vaddr		RS.L 1
Vfrac		RS.W 1
Voffy		RS.W 1
Vfreq		RS.L 1				; structure produced
Vvoltab		RS.W 1				; from 'paula' data
Vlpaddr		RS.L 1
Vlpoffy		RS.W 1
Vlpfreq		RS.L 1

; Routine to add/move one voice to buffer. The real Paula emulation part!!

SetupVoice	MOVE.L sam_start(A5),A2		; current sample end address(shadow amiga!)
		MOVEM.W sam_length(A5),D0/D1/D2	; offset/period/volume
		CMP.W #$40,D2
		BLS.S .ok
		MOVEQ #$40,D2
.ok		MULU global_vol(PC),D2
		LSR #6,D2			; /64
		LSL.W #8,D2			; offset into volume tab
		EXT.L D1
		BEQ.S .zero
		MOVE.L freqconst(PC),D5 
		SWAP D5
		MOVEQ #0,D3 
		MOVE.W D5,D3 
		DIVU D1,D3 
		MOVE.W D3,D6 
		SWAP D6
		SWAP D5
		MOVE.W D5,D3 
		DIVU D1,D3 
		MOVE.W D3,D6 
		MOVE.L D6,D1

.zero		NEG.W D0			; negate sample offset
		MOVE.W shadow_dmacon(PC),D7
		BTST D4,D7
		BNE.S .vcon2
		MOVEQ #0,D1			; clear freq if off.
		MOVEQ #0,D2			; volume off for safety!!
.vcon2		LEA nulsamp+2(PC),A6
		CMP.L A6,A2
		BNE.S .vcon
		MOVEQ #0,D1			; clear freq if off.
		MOVEQ #0,D2			; volume off for safety!!
.vcon		MOVE.L sam_lpstart(a5),A6	; loop addr
		MOVE.W sam_lplength(a5),D5	; loop length
		NEG.W D5			; negate it.
		MOVE.L D1,D7			; freq on loop
		CMP.W #-2,D5
		BNE.S isloop
.noloop		MOVEQ #0,D7			; no loop-no frequency
		LEA nulsamp+2(PC),A6		; no loop-point to nul
isloop		SWAP D1
		SWAP D7
		MOVE.L A2,(A0)+			; store address
		ADDQ.W #2,A0
		MOVE.W D0,(A0)+			; store offset
		MOVE.L D1,(A0)+			; store int.w/frac.w
		MOVE.W D2,(A0)+			; address of volume tab.
		MOVE.L A6,(A0)+			; store loop addr
		MOVE.W D5,(A0)+			; store loop offset.
		MOVE.L D7,(A0)+			; store loop freq int.w/frac.w
		RTS

; Make that buffer! (channels are paired together!)

Goforit		LEA ch1s(PC),A2
		LEA ch2s(PC),A3
		LEA Voice1Set(PC),A5
		LEA Voice2Set(PC),A6
		MOVE.W #0,bufoff+2
		BSR do2chans
		LEA ch3s(PC),A2
		LEA ch4s(PC),A3
		LEA Voice3Set(PC),A5
		LEA Voice4Set(PC),A6
		MOVE.W #1,bufoff+2
		BSR do2chans
		RTS

; Create 2 channels in the ring buffer.

do2chans	MOVEM.L A2-A3/A5-A6,-(SP)
channels12	MOVE.L Vaddr(A5),A0		; ptr to end of each sample!
		MOVE.L Vaddr(A6),A1
		MOVE.L Vfrac(A5),D0		; frac.w/int.w offset
		MOVE.L Vfrac(A6),D1
		MOVE.L Vfreq(A5),A2		; frac.w/int.w freq
		MOVE.L Vfreq(A6),A3	
		MOVE.L Vlpfreq(A5),lpvc1ste+2
		MOVE.L Vlpaddr(A5),lpvc1ste+8	; loop for voice 1
		MOVE.W Vlpoffy(A5),lpvc1ste+14		
		MOVE.L Vlpfreq(A6),lpvc2ste+2
		MOVE.L Vlpaddr(A6),lpvc2ste+8	; loop for voice 1
		MOVE.W Vlpoffy(A6),lpvc2ste+14		

		MOVE.L voltab_ptr(PC),D2
		MOVE.L D2,D3
		MOVEQ #0,D4
		MOVE.W Vvoltab(A5),D4
		ADD.L D4,D2			; volume tab chan 1
		MOVE.W Vvoltab(A6),D4
		ADD.L D4,D3			; volume tab chan 2

		MOVE.L lastwrt_ptr(PC),A4
		MOVE.L buff_ptr(PC),D6
		SUB.L A4,D6
		BGT.S .cse1
.cse2		MOVE.L #endbuffer,D6		
		SUB.L A4,D6
		BSR.S add2
		MOVE.L buff_ptr(PC),D6
		LEA buffer(PC),A4
		SUB.L A4,D6
.cse1		BSR.S add2
		MOVEM.L (SP)+,A2-A3/A5-A6
		NEG.W D0			; +ve offset(as original!)
		MOVE.L A0,sam_start(A2)		; store voice address
		MOVE.W D0,sam_length(A2)	; store offset for next time
		SWAP D0
		MOVE.W D0,Vfrac(A5)		; store frac part
		NEG.W D1		
		MOVE.L A1,sam_start(A3)		; same for chan 2
		MOVE.W D1,sam_length(A3)		
		SWAP D1
		MOVE.W D1,Vfrac(A6)
		RTS

; Move d6/2 words of 2 channels to the buffer.

add2		LSR.W #1,D6
		SUBQ #1,D6			; -1 (dbf)
		BMI exitadd12			; none to do!?
make12_ste	TRAP #12
bufoff		LEA 1(A4),SP
		MOVEQ #0,D7
make12_stelp	MOVE.B (A0,D0.W),D2
		MOVE.L D2,A4
		MOVE.B (A4),D2
		MOVE.B (A1,D1.W),D3
		MOVE.L D3,A4
		ADD.B (A4),D2
		MOVE.B D2,(SP)+
		ADD.L A2,D0
		ADDX D7,D0
		BGE.S lpvc1ste
contlp1ste	ADD.L A3,D1
		ADDX D7,D1
contlp2ste	DBGE D6,make12_stelp
		BGE lpvc2ste
		TRAP #12
exitadd12	RTS

lpvc1ste	LEA.L $12345678,A2
		LEA.L $12345678,A0
		ADD #0,D0
		BRA.S contlp1ste

lpvc2ste	LEA.L $12345678,A3
		LEA.L $12345678,A1
		ADD #0,D1
		BRA.S contlp2ste

; YM 2149 interrupt - fucking bastard shite ST chip(designer cunts)

player		
		RTE

Voice1Set	DS.L 8
Voice2Set	DS.L 8		; voice data (setup from 'paula' data)
Voice3Set	DS.L 8
Voice4Set	DS.L 8

buffer		DS.B $1000	; circular(ring) buffer
endbuffer	DC.L -1
		DS.L 4		; (in case!!)
nulsamp		DS.L 4		; nul sample
lastwrt_ptr	DC.L 0
buff_ptr 	DC.L 0		; last pos within ring buffer
music_on	DC.B 0		; music on flag
ste_flag	DC.B 0		; STE flag!
voltab_ptr	DC.L 0		; ptr to volume table
initialval	DC.L 0
                   
; ST specific initialise - sets up shadow amiga registers etc

STspecific:	

.setfreq	MOVE.L #$8EFE3B/2,freqconst
		LEA nulsamp+2(PC),A2
		MOVEQ #0,D0
		LEA ch1s(pc),A0
		BSR initvoice
		LEA ch2s(pc),A0
		BSR initvoice
		LEA ch3s(pc),A0
		BSR initvoice
		LEA ch4s(pc),A0
		BSR initvoice
		BSR Init_Voltab
		BSR Init_Buffer
		BSR start_ints
		LEA music_on(PC),A0
		ST (A0)
.nostartdma	RTS

; A0-> voice data (paula voice) to initialise.

initvoice:	MOVE.L	A2,sam_start(A0)    ; point voice to nul sample
		MOVE.W	#2,sam_length(A0)		
		MOVE.W	D0,sam_period(A0)   ; period=0
		MOVE.W	D0,sam_vol(A0)	    ; volume=0
		MOVE.L	A2,sam_lpstart(A0)  ; and loop point to nul sample
		MOVE.W	#2,sam_lplength(A0)
		RTS

; Save mfp vects that are used and install our interrupts.

start_ints	MOVE SR,-(SP)
		MOVE #$2700,SR
		LEA buffer(PC),A1
		LEA buff_ptr(PC),A0
		MOVE.L A1,(A0)
		LEA ste_flag(PC),A0
		CLR.B $FFFF8901.W
		BSR Set_DMA
		MOVE.B #%00000011,$FFFF8921.W 	; 12.5khz
		MOVE.B #3,$FFFF8901.W	  	; start STE dma.

.exitste	MOVE.W (SP)+,SR
		RTS

Set_DMA		LEA temp(PC),A6			
		LEA buffer(PC),A0		
		MOVE.L A0,(A6)			
		MOVE.B 1(A6),$ffff8903.W
		MOVE.B 2(A6),$ffff8905.W	; set start of buffer
		MOVE.B 3(A6),$ffff8907.W
		LEA endbuffer(PC),A0
		MOVE.L A0,(A6)
		MOVE.B 1(A6),$ffff890f.W
		MOVE.B 2(A6),$ffff8911.W	; set end of buffer
		MOVE.B 3(A6),$ffff8913.W
		RTS
temp		dc.l	0		
; Turn off the music i.e restore old interrupts and clear soundchip.

stop_ints	LEA music_on(PC),A0		
		SF (A0)				; signal music off.

		MOVE.B #0,$FFFF8901.W		; nop kill STE dma.
		RTS

save_stuff	DS.L 4

; The STE test rout...

Ste_Test	
		LEA ste_flag(PC),A4
		ST (A4)				; assume STE
		RTS

; Make sure Volume lookup table is on a 256 byte boundary.

Init_Voltab	MOVE.L #vols+256,D0
		CLR.B D0
		MOVE.L D0,A0
		MOVE.L A0,voltab_ptr
		LEA 16640(A0),A0
		MOVE.B ste_flag(PC),D0
		BNE stevoltab
YMvoltab	MOVEQ #$40,D0 
.lp1		MOVE.W #$FF,D1 
.lp2		MOVE.W D1,D2 
		EXT.W D2
		MULS D0,D2
		ASR.L #6,D2
		EOR.B #$80,D2
		MOVE.B D2,-(A0)
		DBF D1,.lp2
		DBF D0,.lp1
		RTS 
stevoltab	MOVEQ #$40,D0 
.lp1		MOVE.W #$FF,D1 
.lp2		MOVE.W D1,D2 
		EXT.W D2
		MULS D0,D2 
		ASR.L #7,D2		;/$80 giving a 7 bit sample
		MOVE.B D2,-(A0)
		DBF D1,.lp2
		DBF D0,.lp1
		RTS 


Init_Buffer	LEA buffer+$1000(PC),A0
		MOVEQ.L #0,D0
		MOVE.L D0,D1
		MOVE.L D0,D2
		MOVE.L D0,D3
		MOVE.L D0,D4
		MOVE.L D0,D5
		MOVE.L D0,D6
		MOVE.L D0,A1
		MOVEQ #($1000/128)-1,D7
.lp		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		DBF D7,.lp
		RTS

vols		DS.L 64
		DS.L 16640/4

		INCLUDE SOUNDMON.S
		INCLUDE SONICPRJ.S
		INCLUDE JAMCRACX.S
		INCLUDE TFMX.S
		INCLUDE FUTCOMP.S
		INCLUDE PROTRACK.S
		INCLUDE RUBICON.S
		
		SECTION DATA

musdata		INCBIN MODS\rubimus.dat
		EVEN
commando	INCBIN MODS\PACKED\COMMANDO.MOD
		EVEN
greenberet	INCBIN MODS\PACKED\GREENBER.MOD
		EVEN
stormlord	INCBIN MODS\PACKED\STORMLRD.MOD
		EVEN
mentalre	INCBIN MODS\PACKED\MENTALRE.MOD
		EVEN
comicbak	INCBIN MODS\PACKED\COMICBAK.MOD
		EVEN
thalamusic	INCBIN MODS\PACKED\THALAMUS.MOD
		EVEN
jan_hamm	INCBIN MODS\PACKED\JAN_HAMM.MOD
		EVEN
fullyan		INCBIN MODS\PACKED\FULLYAN.MOD
		EVEN
starworx	INCBIN MODS\PACKED\STARWORX.MOD
		EVEN
term_day	INCBIN MODS\PACKED\TERM_DAY.MOD
		EVEN
shaolin1	INCBIN MODS\PACKED\SHAOLIN1.FUT
		EVEN
shaolin2	INCBIN MODS\PACKED\SHAOLIN2.FUT
		EVEN
astorath2	INCBIN MODS\PACKED\AST____2.FUT
		EVEN
jambala		INCBIN MODS\PACKED\JAMBALA.FUT
		EVEN
T2_Song1	incbin ..\tfmx.mod\t2music1.Sng
		EVEN
T2_Smpl1	ds.w 22272/2
		incbin ..\tfmx.mod\t2music1.Smp
		EVEN
T2_Song2	incbin ..\tfmx.mod\t2music2.Sng
		EVEN
T2_Smpl2	ds.w 22272/2
		incbin ..\tfmx.mod\t2music2.Smp
		EVEN
T2_Song3	incbin ..\tfmx.mod\t2music3.Sng
		EVEN
T2_Smpl3	ds.w 22272/2
		incbin ..\tfmx.mod\t2music3.Smp
		EVEN

		SECTION BSS
saved_res:	ds.l	32

mus_data	DS.B 90000
		DS.L 399
my_stack	DS.L 3
		cnop	0,4

screen		ds.b 150000
