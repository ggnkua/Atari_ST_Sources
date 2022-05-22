;-----------------------------------------------------------------------;
;									;
;			   TTP .MOD Player				;
;	           7 Bit Ste/TT Pro-Tracker 2.1A Driver  		;
;          (C) October/November 1992 Griff of Electronic Images		;
;									;
; - 50 khz stereo sound, with microwire control.			;
; - The ONLY player in the whole wide world to emulate TEMPO properly.	;
; - SEE DOC file for furthur info.					;
;-----------------------------------------------------------------------;
; Quick notes about this source.					;
; - Assemble using DEVPAC 2 or 3.					;
; - This replay is NOT fast and nor should it be. 			;
; - It is designed for QUALITY and ACCURATE replay of ProTracker MODS.	;
; - It doe NOT pad samples and so doesn't waste any setup time/memory.	;
; - If you use it, then please credit me.				;
;-----------------------------------------------------------------------;
; V1.0  - '' Finished Version'' !!
; V1.1  - Fixed for high resolution.
; V1.2  - Fixed microwire setup(sometimes didnt seem to setup correctly)
; v1.2b - First released version.(tidyed up for release)
; v1.2p - Microwire routine rewritten,
;         Power Packer/Atomik 3.5 decrunch implemented.
;         Automation 5.01 decrunch implemted
;         Jampack 4.0 LZW! decrunch implemented.

		OUTPUT C:\BACKPLAY.PRG

test		EQU 0			; if test=1 then run from assember
					; (with a pre-included module)
bufsize 	EQU 5500		; maximum size of buffer
					; (when tempo =32)
dmamask 	EQU %00000011		; STE dmamask for 50khz

		OPT O+,OW-

letsgo		
		IFEQ test
		MOVEA.L 4(A7),A5
		LEA $80(A5),A5			; -> length,filename
		ELSEIF
		LEA testfile,A5			;  if in testmode
		ENDC				; then -> testfilename

		MOVE.B (A5)+,D0 		; get filename length.
		BEQ mustinstall			; no filename given?
		LEA filename(PC),A4
.lp		MOVE.B (A5)+,(A4)+		
		SUBQ.B #1,D0
		BNE.S .lp
		CLR.B (A4)			; terminate filename

		MOVE.L 4(SP),A5
		MOVE.L $C(A5),A4
		ADD.L $14(A5),A4
		ADD.L $1C(A5),A4
		LEA $100(A4),A4			; proggy size+basepage
		MOVEM.L A4/A5,saveem

		BSR load_mod			; load the module
		TST.B errorflag
		BNE load_error			; exit if load error
		
		PEA goformusic(PC)
		MOVE.W #$26,-(SP)
		TRAP #14
		ADDQ.L #6,SP

ALLOK		MOVEM.L saveem(PC),A4/A5
		ADD.L modlength(PC),A4
		MOVE.L A4,reservelength
		PEA (A4)
		PEA (A5)
		CLR -(SP)
		MOVE #$4A,-(SP)
		TRAP #1				; reserve some memory
		LEA 12(SP),SP
		CLR -(SP)
		MOVE.L reservelength(PC),-(SP)
		MOVE.W #$31,-(SP)
		TRAP #1

saveem		DC.L 0,0
reservelength	DC.L 0

goformusic	
		LEA mt_data,A0
		MOVE.L A0,mt_data_ptr		; -> mod
		BSR check_packed

		BSR SoundTest			; check for dma sound
;		TST.L D1			; if this is an old ST
;		BEQ wrongST_error		; then quit out!
		BSR TestMegaSTE
		MOVEQ #1,D0
		MOVEQ #0,D1
		BRA Init_ST			; install music

exit		
exitloaderr	
redir		PEA dummy(PC)
		MOVE.W #$4e,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		CLR.W -(SP)			; Get dir.
		PEA dir
		MOVE.W #$47,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		CLR -(SP)
		TRAP #1

;-------------------------------------------------------------------------
; A few error handlers.

; NO DMA Sound so can't use this player.

wrongST_error	PEA wrongST_err_txt(PC)
		MOVE.W #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		BRA exit

load_error	CMP.L #-33,error_no
		BNE.S .not_fnf
		PEA filenf_errortxt(PC)
		BRA.S .cont
.not_fnf	PEA load_errortxt(PC)
.cont		MOVE.W #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		BRA exitloaderr

; No FILENAME was passed error - so tell 'em how to install !!

mustinstall	DC.W $A00A
		PEA installtxt(PC)
		MOVE.W #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		DC.W $A009
		BRA.S redir

installtxt	DC.B 27,"E"
		DC.B "You must install this program as an",10,13
		DC.B "application on the Gem desktop,",10,13
		DC.B "OR Type the Module Name if you are",10,13
		DC.B "running this from a command line!",10,13
		DC.B "Press any key.",10,13,0

load_errortxt	DC.B 27,"E"
		DC.B "Load Error(disk error?)",10,13
		DC.B "Press any key.",10,13,0

filenf_errortxt	DC.B 27,"E"
		DC.B "File Not Found",10,13
		DC.B "Press any key.",10,13,0
	

wrongST_err_txt	DC.B 27,"E"
		DC.B "You must have an Ste,Mega Ste or TT",10,13
		DC.B "to run this module player..(sorry!)",10,13
		DC.B "Press any key.",10,13,0
		EVEN

;--------------------------------------------------------------------------
; CookieJar Check to see if we have DMA sound.(i.e STE/TT)
; Return D1=0 if DMA sound is not available on this machine. (else d1=-1)
;--------------------------------------------------------------------------

SoundTest	move.l $5A0.W,d0		; get cookie jar ptr
		beq.s no_dmasnd			;; nul ptr = no cookie jar
		move.l d0,a0			;; (no cookie jar= no dma snd)
.search_next	tst.l (a0)			
		beq.s no_dmasnd
		cmp.l #'_SND',(a0)		; cookie found?
		beq.s .search_found
		addq.l #8,a0
		bra.s .search_next
.search_found	move.l 4(a0),d0			; get _SND const.
		cmp.l #3,D0
		blt.s no_dmasnd
		moveq #-1,d1			; DMA SOUND FOUND!
		rts
no_dmasnd	moveq #0,d1			; NO DMA SOUND!
		rts

;--------------------------------------------------------------------------
; MegaSTE Test. Checks to whether we are running on a 16mhz switchable STE
; Return D1=0 if machine is not a MegaSTE, or -1 if the machine is.
;--------------------------------------------------------------------------

TestMegaSTE	move.l $8.w,a1
		move.l a7,a2
		move.l #.notmegaste,$8.w
		moveq #0,d1
		tst.b $ffff8e21.w
		moveq #-1,d1
.notmegaste	move.l a2,a7
		move.l a1,$8.w
		move.b d1,MegaSTE_Flag
		rts
MegaSTE_Flag	dc.b 0	
		even

; Wait for a vbl..

Wait_Vbl	MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		RTS

; Load that Module

load_mod	LEA filename(PC),A4
		LEA mt_data,A5
		MOVE.L #4000000,D7
		BSR Load_file			; load the file
		RTS

; Load a file of D7 bytes, Filename at A4 into address A5.

Load_file	SF.B errorflag			; assume no error!
		MOVE #2,-(SP)
		MOVE.L A4,-(SP)
		MOVE #$3D,-(SP)
		TRAP #1				; open da file
		ADDQ.L #8,SP
		TST.L D0
		BMI.S .error
		MOVE D0,D4
.read		MOVE.L A5,-(SP)
		MOVE.L D7,-(SP)
		MOVE D4,-(SP)
		MOVE #$3F,-(SP)
		TRAP #1				; read da file
		LEA 12(SP),SP
		TST.L D0
		BMI.S .error
		MOVE.L D0,modlength
.close		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1				; close da file!
		ADDQ.L #4,SP
		RTS
 
.error		MOVE.L D0,error_no
		ST.B errorflag			; shit a load error!
		RTS

; Check to see if a module is packed, depack it if it is!

check_packed	MOVE.L mt_data,D0
		CMP.L #'PP20',D0		; Power Packed?
		BNE.S .notpp
.is_pp		LEA mt_data,A0
		LEA 4(A0),A5
		LEA 256(A0),A3
		MOVE.L A3,mt_data_ptr
		ADD.L modlength(PC),A0
		BRA PP_Decrunch
.notpp		CMP.L #'ATM5',D0		; Atomik 3.5??
		BNE.S .notatom35
		LEA mt_data,A0
		BRA Atom35depack		
.notatom35	CMP.L #'LZW!',D0		; LZW ?
		BNE.S .notLZW
		LEA mt_data,A0
		LEA 1536(a0),A1
		MOVE.L A1,mt_data_ptr
		BRA LZW_UNPACK
.notLZW		CMP.L #'AU5!',D0		; Automation 501 ?
		BNE.S .not501
		LEA mt_data,A0
		BRA AU5_decrunch_2
.not501
		RTS

		include packers.s

; Various variables.

modlength	DC.L 0
mt_data_ptr	DC.L 0
error_no	DC.L 0
errorflag	DC.B 0
		EVEN
dummy:		DC.B '*.*',0
filename	DS.B 128
		EVEN

;-----------------------------------------------------------------------;

; Here we have the replay rout.

; Initialise Music Sequencer and ST Specific bits (e.g interrupts etc.)

; Initialise music - turn on/fade in.

Init_ST		BSR mt_init 
		BRA STspecific

global_vol	DC.W 0

; Paula emulation storage structure.

		RSRESET
sam_start	RS.L 1				; sample start
sam_length	RS.L 1				; sample length
sam_period	RS.W 1				; sample period(freq)
sam_vol		RS.W 1				; sample volume
sam_lpstart	RS.L 1				; sample loop start
sam_lplength	RS.L 1	 			; sample loop length
sam_vcsize	RS.B 1				; structure size.

ch1s		DS.B sam_vcsize
ch2s		DS.B sam_vcsize			; shadow channel regs
ch3s		DS.B sam_vcsize
ch4s		DS.B sam_vcsize
shadow_dmacon	DS.W 1
shadow_filter	DS.W 1

; Macro to move parameter '\1' into the shadow dma register...
; (Remember - bit 15 of 'dmacon' determines clearing or setting of bits!)

move_dmacon	MACRO
.setdma\@	MOVE.W D4,-(Sp)			; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dmacon		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dmacon		; not zero so set 'em
.dmacon_set\@	MOVE.W (sp)+,D4			; restore D4
		ENDM

; Player - This is THE  'Paula' Emulator.

do_music:	TAS.B mus_semaphore
		BNE.S skipit
		BSR Set_DMA
		MOVE.W #$2500,SR
		MOVEM.L D0-D7/A0-A6,-(SP)
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
		BSR calcnextdmaptrs
		BSR mt_music
skipit1		MOVEM.L (SP)+,D0-D7/A0-A6
		SF.B mus_semaphore
skipit		RTE
thisframe	DC.L 0,0
CurrTempo	DC.W 125
RealTempo	DC.W 125
mus_semaphore	DS.W 1

calcnextdmaptrs	MOVE.W RealTempo(PC),CurrTempo
		MOVE.L stebuf_ptrs+4(PC),A0
		LEA ciaem_tab(PC),A1
		MOVE.W CurrTempo(PC),D0
		ADD.W D0,D0
		MOVE.W (A1,D0),D0
		ADD.W D0,D0
		ADD.W D0,D0
		MOVE.L A0,a1
		ADD.W D0,A1
		MOVEM.L A0/A1,thisframe
		RTS

		RSRESET
Vaddr		RS.L 1
Voffy		RS.L 1
Vfrac		RS.L 1
Vfreqint	RS.W 1				; structure produced
Vfreqfrac	RS.L 1
Vvoltab		RS.W 1				; from 'paula' data
Vlpaddr		RS.L 1
Vlpoffy		RS.L 1
Vlpfreqint	RS.W 1
Vlpfreqfrac	RS.L 1

; Routine to add/move one voice to buffer. The real Paula emulation part!!

SetupVoice	MOVE.L sam_start(A5),A2		; current sample end address(shadow amiga!)
		MOVE.L sam_length(A5),D0
		MOVEM.W sam_period(A5),D1/D2	; offset/period/volume
		CMP.W #$40,D2
		BLS.S .ok
		MOVEQ #$40,D2
.ok		LSL.W #8,D2			; offset into volume tab
		LEA ftab(PC),A6
.OK2		MULU #6,D1
		ADD.L D1,A6
		MOVE.W (A6)+,D1			; int part
		MOVE.L (A6)+,D3
.zero		NEG.L D0			; negate sample offset
		MOVE.W shadow_dmacon(PC),D7
		BTST D4,D7
		BNE.S .vcon2
		MOVEQ #0,D1			; clear freq if off.
		MOVEQ #0,D3			; clear freq if off.
		MOVEQ #0,D2			; volume off for safety!!
.vcon2		TST.L D0
		BNE.S .isnotzero
		LEA nulsamp+2(PC),A2
.isnotzero	LEA nulsamp+2(PC),A6
		CMP.L A6,A2
		BNE.S .vcon
		MOVEQ #0,D1			; clear freq if off.
		MOVEQ #0,D3			; clear freq if off.
		MOVEQ #0,D2			; volume off for safety!!
.vcon		MOVE.L sam_lpstart(a5),A6	; loop addr
		MOVE.L sam_lplength(a5),D5	; loop length
		NEG.L D5			; negate it.
		MOVE.W D1,D6			; freq on loop
		MOVE.L D3,D7			;
		CMP.L #-2,D5
		BLT.S .isloop
.noloop		MOVEQ #0,D6
		MOVEQ #-2,D5
		MOVEQ #0,D7			; no loop-no frequency
		LEA nulsamp+2(PC),A6		; no loop-point to nul
.isloop		MOVE.L A2,(A0)+			; store address
		MOVE.L D0,(A0)+			; store offset int.L
		ADDQ.L #4,A0			; skip current frac.l
		MOVE.W D1,(A0)+			; store freq int.w
		MOVE.L D3,(A0)+			; store freq 32bit fraction
		MOVE.W D2,(A0)+			; address of volume tab.
		MOVE.L A6,(A0)+			; store loop addr
		MOVE.L D5,(A0)+			; store loop offset.L
		MOVE.W D6,(A0)+			; store loop freq int.w
		MOVE.L D7,(A0)+			; store loop freq frac.L
		RTS
ftab		DS.W 3
		INCBIN g:\PROTRACK.S\50PLAY.STE\FRQ32BIT.TAB

; Make that buffer! (channels are paired together!)

Goforit		LEA ch1s(PC),A2
		LEA ch3s(PC),A3
		LEA Voice1Set(PC),A5
		LEA Voice3Set(PC),A6
		BSR do2chans
		LEA ch2s(PC),A2
		LEA ch4s(PC),A3
		LEA Voice2Set(PC),A5
		LEA Voice4Set(PC),A6
		BSR do2chansb
		RTS

; Create 2 channels in the buffer.

do2chans	MOVEM.L A2-A3/A5-A6,-(SP)
		MOVE.L voltab_ptr(PC),D2
		MOVE.L D2,D3
		MOVEQ #0,D4
		MOVE.W Vvoltab(A5),D4
		ADD.L D4,D2			; volume tab chan 1
		MOVE.W Vvoltab(A6),D4
		ADD.L D4,D3			; volume tab chan 2

		MOVE.L Vaddr(A5),A0		; ptr to end of each sample!
		MOVE.L Voffy(A5),D0		; int.w offset
		MOVE.L Vfrac(A5),D4		; frac.w offset
		MOVE.W Vfreqint(A5),D6 
		MOVE.L Vfreqfrac(A5),A2		; frac.w/int.w freq

		MOVE.L Vaddr(A6),A1
		MOVE.L Voffy(A6),D1
		MOVE.L Vfrac(A6),D5
		MOVE.W Vfreqint(A6),D7
		MOVE.L Vfreqfrac(A6),A3	
		SWAP D6

		MOVE.L Vlpaddr(A5),lpvc1ste+2+2	; loop for voice 1
		MOVE.L Vlpoffy(A5),lpvc1ste+8+2
		MOVE.L Vlpfreqfrac(A5),lpvc1ste+14+2
		MOVE.W Vlpfreqint(A5),lpvc1ste+20+2

		MOVE.L Vlpaddr(A6),lpvc2ste+2+2 ; loop for voice 1
		MOVE.L Vlpoffy(A6),lpvc2ste+8+2
		MOVE.L Vlpfreqfrac(A6),lpvc2ste+14+2
		MOVE.W Vlpfreqint(A6),lpvc2ste+20+2

		LEA ciaem_tab(PC),A4
		MOVE.W CurrTempo(PC),D6
		ADD.W D6,D6
		MOVE.W (A4,D6),D6
		MOVE.L stebuf_ptrs(pc),a4
		BSR add2
		MOVEM.L (SP)+,A2-A3/A5-A6
		NEG.L D0			; +ve offset(as original!)
		NEG.L D1		
		MOVE.L A0,sam_start(A2)		; store voice address
		MOVE.L D0,sam_length(A2)	; store offset for next time
		MOVE.L D4,Vfrac(A5)		; store frac part
		MOVE.L A1,sam_start(A3)		; same for chan 2
		MOVE.L D1,sam_length(A3)		
		MOVE.L D5,Vfrac(A6)
		RTS
ciaem_tab	INCBIN g:\PROTRACK.S\50PLAY.STE\CIA_EMU.TAB

add2		SUBQ #1,D6
		LEA (A4),A6
make12_stelp	MOVE.B (A0,D0.L),D2
		MOVE.L D2,A4
		MOVE.B (A4),D2
		MOVE.B (A1,D1.L),D3
		MOVE.L D3,A4
		ADD.B (A4),D2
		MOVE.W D2,(A6)+
		MOVE.W D2,(A6)+			; oversample(!)
		SWAP D6
		ADD.L A2,D4			; 32 bit fraction
		ADDX.W D6,D0
		BCS.S lpvc1ste
contlp1ste	SWAP D6
		ADD.L A3,D5			; 32 bit fraction
		ADDX.W D7,D1
contlp2ste	DBCS D6,make12_stelp
		BCS.S lpvc2ste
		RTS

lpvc1ste	EXT.L D0
		LEA.L $12345678,A0	; 0+2
		ADD.L #0,D0		; 6+4
		LEA.L $12345678,A2	; 12+2
		MOVE.W #$1234,D6	; 18+2
		BRA.S contlp1ste

lpvc2ste	EXT.L D1
		LEA.L $12345678,A1	; 0+2
		ADD.L #0,D1		; 6+2
		LEA.L $12345678,A3	; 12+2
		MOVE.W #$1234,D7	; 18+2
		MOVE.W #0,CCR
		BRA.S contlp2ste	

; Create 2 channels in the buffer.

do2chansb	MOVEM.L A2-A3/A5-A6,-(SP)
		MOVE.L voltab_ptr(PC),D2
		MOVE.L D2,D3
		MOVEQ #0,D4
		MOVE.W Vvoltab(A5),D4
		ADD.L D4,D2			; volume tab chan 1
		MOVE.W Vvoltab(A6),D4
		ADD.L D4,D3			; volume tab chan 2

		MOVE.L Vaddr(A5),A0		; ptr to end of each sample!
		MOVE.L Voffy(A5),D0		; int.w offset
		MOVE.L Vfrac(A5),D4		; frac.w offset
		MOVE.W Vfreqint(A5),D6 
		MOVE.L Vfreqfrac(A5),A2		; frac.w/int.w freq

		MOVE.L Vaddr(A6),A1
		MOVE.L Voffy(A6),D1
		MOVE.L Vfrac(A6),D5
		MOVE.W Vfreqint(A6),D7
		MOVE.L Vfreqfrac(A6),A3	
		SWAP D6

		MOVE.L Vlpaddr(A5),lpvc1steb+2+2	; loop for voice 1
		MOVE.L Vlpoffy(A5),lpvc1steb+8+2
		MOVE.L Vlpfreqfrac(A5),lpvc1steb+14+2
		MOVE.W Vlpfreqint(A5),lpvc1steb+20+2

		MOVE.L Vlpaddr(A6),lpvc2steb+2+2 ; loop for voice 1
		MOVE.L Vlpoffy(A6),lpvc2steb+8+2
		MOVE.L Vlpfreqfrac(A6),lpvc2steb+14+2
		MOVE.W Vlpfreqint(A6),lpvc2steb+20+2

		LEA ciaem_tab(PC),A4
		MOVE.W CurrTempo(PC),D6
		ADD.W D6,D6
		MOVE.W (A4,D6),D6
		MOVE.L stebuf_ptrs(pc),a4
		BSR add2b
		MOVEM.L (SP)+,A2-A3/A5-A6
		NEG.L D0			; +ve offset(as original!)
		NEG.L D1		
		MOVE.L A0,sam_start(A2)		; store voice address
		MOVE.L D0,sam_length(A2)	; store offset for next time
		MOVE.L D4,Vfrac(A5)		; store frac part
		MOVE.L A1,sam_start(A3)		; same for chan 2
		MOVE.L D1,sam_length(A3)		
		MOVE.L D5,Vfrac(A6)
		RTS

Voice1Set	DS.L 10
Voice2Set	DS.L 10		 	; voice data (setup from 'paula' data)
Voice3Set	DS.L 10
Voice4Set	DS.L 10

nulsamp		DS.L 8		; nul sample
voltab_ptr	DC.L 0		; ptr to volume table

add2b		SUBQ #1,D6
		LEA (A4),A6
make12b_stelp	MOVE.B (A0,D0.L),D2
		MOVE.L D2,A4
		MOVE.B (A4),D2
		MOVE.B (A1,D1.L),D3
		MOVE.L D3,A4
		ADD.B (A4),D2
		MOVE.B D2,(A6)+
		ADDQ.L #1,A6
		MOVE.B D2,(A6)+			; oversample(!)
		ADDQ.L #1,A6
		SWAP D6
		ADD.L A2,D4			; 32 bit fraction
		ADDX.W D6,D0
		BCS.S lpvc1steb
contlp1steb	SWAP D6
		ADD.L A3,D5			; 32 bit fraction
		ADDX.W D7,D1
contlp2steb	DBCS D6,make12b_stelp
		BCS.S lpvc2steb
		RTS

lpvc1steb	EXT.L D0
		LEA.L $12345678,A0	; 0+2
		ADD.L #0,D0		; 6+4
		LEA.L $12345678,A2	; 12+2
		MOVE.W #$1234,D6	; 18+2
		BRA.S contlp1steb

lpvc2steb	EXT.L D1
		LEA.L $12345678,A1	; 0+2
		ADD.L #0,D1		; 6+2
		LEA.L $12345678,A3	; 12+2
		MOVE.W #$1234,D7	; 18+2
		MOVE.W #0,CCR
		BRA.S contlp2steb	

                   
; ST specific initialise - sets up shadow amiga registers etc

STspecific:	BSR makevoltab
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
		BSR start_music
		RTS

; A0-> voice data (paula voice) to initialise.

initvoice:	MOVE.L	A2,sam_start(A0)    ; point voice to nul sample
		MOVE.L	#2,sam_length(A0)		
		MOVE.W	D0,sam_period(A0)   ; period=0
		MOVE.W	D0,sam_vol(A0)	    ; volume=0
		MOVE.L	A2,sam_lpstart(A0)  ; and loop point to nul sample
		MOVE.L	#2,sam_lplength(A0)
		RTS

; Start up music.

start_music:	CLR.B $FFFF8901.W
		BSR calcnextdmaptrs
		BSR Set_DMA
		MOVE.W SR,-(sp)
		MOVE.W #$2700,SR
		MOVE.L #do_music,$134.W
		BCLR.B #3,$FFFFFA17.W
		BSET.B #5,$FFFFFA07.W		;iera
		BSET.B #5,$FFFFFA13.W		;imra
		CLR.B $FFFFFA19.W
		MOVE.B #1,$FFFFFA1F.W
		MOVE.B #8,$FFFFFA19.W		;timer a event mode.
		MOVE.W (SP)+,SR
		BSR Start_DMA
		RTS

; Set DMA to play buffer(buffer len based on TEMPO)

Set_DMA		MOVE.L D0,-(SP)
		MOVE.L thisframe+4(PC),-(SP)
		MOVE.L thisframe(PC),-(SP)
setptrs		BCLR.B #7,$FFFF8901.W
		CLR.W D0
		MOVE.B 3(a7),d0			;9
		MOVE.W d0,$FFFF8906.W
		MOVE.B 2(a7),d0			;8
		MOVE.W d0,$FFFF8904.W
		MOVE.B 1(a7),d0			;7
		MOVE.W d0,$FFFF8902.W	
		MOVE.B 7(a7),d0			;D
		MOVE.W d0,$FFFF8912.W
		MOVE.B 6(a7),d0			;C
		MOVE.W d0,$FFFF8910.W
		MOVE.B 5(a7),d0			;B
		MOVE.W d0,$FFFF890E.W
		ADDQ.L #8,SP
		MOVE.L stebuf_ptrs(PC),D0
		MOVE.L stebuf_ptrs+4(PC),stebuf_ptrs
		MOVE.L D0,stebuf_ptrs+4
		MOVE.L (SP)+,D0
		RTS

Start_DMA	MOVE.B #dmamask,$FFFF8921.W 	; set khz
		MOVE.B #3,$FFFF8901.W	  	; start STE dma.
		RTS
stebuf_ptrs	DC.L stebuf1,stebuf2
temp:		dc.l	0,0

stop_music:	CLR.B $FFFF8901.W	  	; stop STE dma.
		MOVE.W SR,D0
		MOVE.W #$2700,SR
		BCLR.B #5,$FFFFFA07.W		; iera
		BCLR.B #5,$FFFFFA13.W		; imra
		MOVE.W D0,SR
		RTS 

; Create the 65 volume lookup tables

makevoltab:	MOVE.L #vols+256,D0
		CLR.B D0
		MOVE.L D0,A0
		MOVE.L A0,voltab_ptr
		LEA 16640(A0),A0
		MOVEQ #$40,D0 
.lp1		MOVE.W #$FF,D1 
.lp2		MOVE.W D1,D2 
		EXT.W D2
		MULS D0,D2 
		ASR.L #7,D2
		MOVE.B D2,-(A0)
		DBF D1,.lp2
		DBF D0,.lp1
		LEA stebuf1,A0
		LEA stebuf2,A1
		MOVE.W #(bufsize/2)-1,d0
		MOVEQ #0,D1
.lp		
		REPT 4
		MOVE.B D2,(A0)+
		ENDR
		REPT 4
		MOVE.B D2,(A1)+
		ENDR
		DBF D0,.lp
		RTS

; ----- Protracker V2.1A Playroutine ----- 

; CIA Version 1:
; This playroutine is not very fast, optimized or well commented,
; but all the new commands in PT2.1 should work.
; If it's not good enough, you'll have to change it yourself.
; We'll try to write a faster routine soon...

; Changes from V1.0C playroutine:
; - Vibrato depth changed to be compatible with Noisetracker 2.0.
;   You'll have to double all vib. depths on old PT modules.
; - Funk Repeat changed to Invert Loop.
; - Period set back earlier when stopping an effect.

n_note		EQU	0  ; W
n_cmd		EQU	2  ; W
n_cmdlo		EQU	3  ; B
n_start		EQU	4  ; L
n_length	EQU	8  ; W
n_loopstart	EQU	10 ; L
n_replen	EQU	14 ; W
n_period	EQU	16 ; W
n_finetune	EQU	18 ; B
n_volume	EQU	19 ; B
n_dmabit	EQU	20 ; W
n_toneportdirec	EQU	22 ; B
n_toneportspeed	EQU	23 ; B
n_wantedperiod	EQU	24 ; W
n_vibratocmd	EQU	26 ; B
n_vibratopos	EQU	27 ; B
n_tremolocmd	EQU	28 ; B
n_tremolopos	EQU	29 ; B
n_wavecontrol	EQU	30 ; B
n_glissfunk	EQU	31 ; B
n_sampleoffset	EQU	32 ; B
n_pattpos	EQU	33 ; B
n_loopcount	EQU	34 ; B
n_funkoffset	EQU	35 ; B
n_wavestart	EQU	36 ; L
n_reallength	EQU	40 ; W

mt_init	MOVE.L	mt_data_ptr(PC),A0
	MOVE.L	A0,mt_SongDataPtr
	MOVE.L	A0,A1
	LEA	952(A1),A1
	MOVEQ	#127,D0
	MOVEQ	#0,D1
mtloop	MOVE.L	D1,D2
	SUBQ.W	#1,D0
mtloop2	MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BGT.S	mtloop
	DBRA	D0,mtloop2
	ADDQ.B	#1,D2
			
	LEA	mt_SampleStarts(PC),A1
	ASL.L	#8,D2
	ASL.L	#2,D2
	ADD.L	#1084,D2
	ADD.L	A0,D2
	MOVE.L	D2,A2
	MOVEQ	#30,D0
mtloop3	CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	42(A0),D1
	ASL.L	#1,D1
	ADD.L	D1,A2
	ADD.L	#30,A0
	DBRA	D0,mtloop3

	MOVE.B	#6,mt_speed
	CLR.B	mt_counter
	CLR.B	mt_SongPos
	CLR.W	mt_PatternPos
	ST	mt_Enable
	move_dmacon #$F
	RTS

mt_end	SF	mt_Enable
	move_dmacon #$F
	RTS

mt_music
	TST.B	mt_Enable
	BEQ	mt_exit
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_dskip

mt_NoNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	ch1s(PC),A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch2s(PC),A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch3s(PC),A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch4s(PC),A5
	LEA	mt_chan4temp(PC),A6
	BRA	mt_CheckEfx

mt_GetNewNote
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	12(A0),A3
	LEA	952(A0),A2	;pattpo
	LEA	1084(A0),A0	;patterndata
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	mt_PatternPos(PC),D1
	CLR.W	mt_DMACONtemp

	LEA	ch1s(PC),A5
	LEA	mt_chan1temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch2s(PC),A5
	LEA	mt_chan2temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch3s(PC),A5
	LEA	mt_chan3temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch4s(PC),A5
	LEA	mt_chan4temp(PC),A6
	BSR.S	mt_PlayVoice
	BRA	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE.S	mt_plvskip
	BSR	mt_PerNop
mt_plvskip
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	LEA	mt_SampleStarts(PC),A1
	MOVE	D2,D4
	SUBQ.L	#1,D2
	ASL.L	#2,D2
	MULU	#30,D4
	MOVE.L	(A1,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)
	MOVE.W	(A3,D4.L),n_reallength(A6)
	MOVE.B	2(A3,D4.L),n_finetune(A6)
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3 ; Get repeat
	TST.W	D3
	BEQ.S	mt_NoLoop
	MOVE.L	n_start(A6),D2	; Get start
	ASL.W	#1,D3
	ADD.L	D3,D2		; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0	; Get repeat
	ADD.W	6(A3,D4.L),D0	; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)	; Set volume
	BRA.S	mt_SetRegs

mt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)	; Set volume
mt_SetRegs
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ	mt_CheckMoreEfx	; If no note
	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.S	mt_SetPeriod
	BSR	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_DoSetFineTune
	BSR	mt_SetFineTune
	BRA.S	mt_SetPeriod

mt_ChkTonePorta
	BSR	mt_SetTonePorta
	BRA	mt_CheckMoreEfx

mt_SetPeriod
	MOVEM.L	D0-D1/A0-A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#36,D2
mt_ftuloop
	CMP.W	(A1,D0.W),D1
	BHS.S	mt_ftufound
	ADDQ.L	#2,D0
	DBRA	D2,mt_ftuloop
mt_ftufound
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	ADD.L	D1,A1
	MOVE.W	(A1,D0.W),n_period(A6)
	MOVEM.L	(SP)+,D0-D1/A0-A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ	mt_CheckMoreEfx

	move_dmacon n_dmabit(A6)
	BTST	#2,n_wavecontrol(A6)
	BNE.S	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.S	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.L	n_start(A6),sam_start(A5)	; Set start
	MOVEQ #0,D0
	MOVE.W	n_length(A6),D0
	ADD.L D0,D0
	ADD.L D0,sam_start(A5)
	MOVE.L D0,sam_length(A5)		; Set length

	MOVE.W	n_period(A6),D0
	MOVE.W	D0,sam_period(A5)		; Set period
	MOVE.W	n_dmabit(A6),D0
	OR.W	D0,mt_DMACONtemp
	BRA	mt_CheckMoreEfx
 
mt_SetDMA
	MOVE.W	mt_DMACONtemp(PC),D0
	OR.W	#$8000,D0
	move_dmacon d0

	LEA ch4s(PC),A5
	LEA mt_chan4temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVEQ #0,D0
	MOVE.W	n_replen(A6),D0
	ADD.L D0,D0
	MOVE.L D0,sam_lplength(A5)
	ADD.L D0,sam_lpstart(A5)

	LEA ch3s(PC),A5
	LEA mt_chan3temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVEQ #0,D0
	MOVE.W	n_replen(A6),D0
	ADD.L D0,D0
	MOVE.L D0,sam_lplength(A5)
	ADD.L D0,sam_lpstart(A5)

	LEA ch2s(PC),A5
	LEA mt_chan2temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVEQ #0,D0
	MOVE.W	n_replen(A6),D0
	ADD.L D0,D0
	MOVE.L D0,sam_lplength(A5)
	ADD.L D0,sam_lpstart(A5)

	LEA ch1s(PC),A5
	LEA mt_chan1temp(PC),A6
	MOVE.L n_loopstart(A6),sam_lpstart(A5)
	MOVEQ #0,D0
	MOVE.W	n_replen(A6),D0
	ADD.L D0,D0
	MOVE.L D0,sam_lplength(A5)
	ADD.L D0,sam_lpstart(A5)

mt_dskip
	ADD.W	#16,mt_PatternPos
	MOVE.B	mt_PattDelTime,D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2
	CLR.B	mt_PattDelTime
mt_dskc	TST.B	mt_PattDelTime2
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2
	BEQ.S	mt_dska
	SUB.W	#16,mt_PatternPos
mt_dska	TST.B	mt_PBreakFlag
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
mt_nnpysk
	CMP.W	#1024,mt_PatternPos
	BLO.S	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
	CLR.B	mt_PBreakPos
	CLR.B	mt_PosJumpFlag
	ADDQ.B	#1,mt_SongPos
	AND.B	#$7F,mt_SongPos
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	950(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos
mt_NoNewPosYet	
	TST.B	mt_PosJumpFlag
	BNE.S	mt_NextPosition
mt_exit	
	RTS

mt_CheckEfx
	BSR	mt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_Arpeggio
	CMP.B	#1,D0
	BEQ	mt_PortaUp
	CMP.B	#2,D0
	BEQ	mt_PortaDown
	CMP.B	#3,D0
	BEQ	mt_TonePortamento
	CMP.B	#4,D0
	BEQ	mt_Vibrato
	CMP.B	#5,D0
	BEQ	mt_TonePlusVolSlide
	CMP.B	#6,D0
	BEQ	mt_VibratoPlusVolSlide
	CMP.B	#$E,D0
	BEQ	mt_E_Commands
SetBack	MOVE.W	n_period(A6),sam_period(A5)
	CMP.B	#7,D0
	BEQ	mt_Tremolo
	CMP.B	#$A,D0
	BEQ	mt_VolumeSlide
mt_Return
	RTS

mt_PerNop
	MOVE.W	n_period(A6),sam_period(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	CMP.W	#0,D0
	BEQ.S	mt_Arpeggio2
	CMP.W	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2
	MOVE.W	n_period(A6),D2
	BRA.S	mt_Arpeggio4

mt_Arpeggio3
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVEQ	#36,D3
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BHS.S	mt_Arpeggio4
	ADDQ.L	#2,A0
	DBRA	D3,mt_arploop
	RTS

mt_Arpeggio4
	MOVE.W	D2,sam_period(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE.S	mt_Return
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#113,n_period(A6)
mt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,sam_period(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#856,n_period(A6)
mt_PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,sam_period(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#37*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ.W	#2,D0
mt_StpGoss
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE	mt_Return
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

mt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

mt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
mt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

mt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,sam_period(A5) ; Set period
	RTS

mt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
mt_Vibrato2
	MOVE.B	n_vibratopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine
	MOVE.B	(A4,D0.W),D2
mt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,sam_period(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	RTS

mt_TonePlusVolSlide
	BSR	mt_TonePortNoChange
	BRA	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR.S	mt_Vibrato2
	BRA	mt_VolumeSlide

mt_Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
mt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine
	MOVE.B	(A4,D0.W),D2
mt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk
	MOVE.W	D0,sam_vol(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
mt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,n_length(A6)
	LSL.W	#1,D0
	ADD.L	D0,n_start(A6)
	RTS
mt_sofskip
	MOVE.W	#$0001,n_length(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,n_volume(A6)
mt_vsuskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)
	RTS

mt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.S	mt_vsdskip
	CLR.B	n_volume(A6)
mt_vsdskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,sam_vol(A5)
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	MOVE.W	D0,sam_vol(A5)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ	mt_end
;	TST.B tempo_cont_flg		; tempo control on?
;	BEQ.S .notempo
	CMP.B	#32,D0			; yes then d0>=32
	BHS	SetTempo		; then Set Tempo
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS
.notempo				; tempo control is OFF
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed		; so set speed  regardless
	CMP.W   #32,D0
	BLO.S 	.okdefspeed
	MOVE.W D0,OldTempo		; but store in old tempo
.okdefspeed				; for tempo turn back on.
	RTS
OldTempo	DC.W 125

SetTempo
	CMP.W	#32,D0
	BHS.S	setemsk
	MOVEQ	#32,D0
setemsk	MOVE.W	D0,RealTempo		; set tempo speed
	RTS

mt_CheckMoreEfx
	BSR	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#$9,D0
	BEQ	mt_SampleOffset
	CMP.B	#$B,D0
	BEQ	mt_PositionJump
	CMP.B	#$D,D0
	BEQ	mt_PatternBreak
	CMP.B	#$E,D0
	BEQ.S	mt_E_Commands
	CMP.B	#$F,D0
	BEQ	mt_SetSpeed
	CMP.B	#$C,D0
	BEQ	mt_VolumeChange
	BRA	mt_PerNop

mt_E_Commands
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	CMP.B	#1,D0
	BEQ	mt_FinePortaUp
	CMP.B	#2,D0
	BEQ	mt_FinePortaDown
	CMP.B	#3,D0
	BEQ.S	mt_SetGlissControl
	CMP.B	#4,D0
	BEQ	mt_SetVibratoControl
	CMP.B	#5,D0
	BEQ	mt_SetFineTune
	CMP.B	#6,D0
	BEQ	mt_JumpLoop
	CMP.B	#7,D0
	BEQ	mt_SetTremoloControl
	CMP.B	#9,D0
	BEQ	mt_RetrigNote
	CMP.B	#$A,D0
	BEQ	mt_VolumeFineUp
	CMP.B	#$B,D0
	BEQ	mt_VolumeFineDown
	CMP.B	#$C,D0
	BEQ	mt_NoteCut
	CMP.B	#$D,D0
	BEQ	mt_NoteDelay
	CMP.B	#$E,D0
	BEQ	mt_PatternDelay
	CMP.B	#$F,D0
	BEQ	mt_FunkIt
	RTS

mt_FilterOnOff
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#1,D0
	ASL.B	#1,D0
;	AND.B	#$FD,$BFE001		; filter!
;	OR.B	D0,$BFE001		; hehe
	RTS	

mt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_SetFineTune
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	RTS

mt_JumpLoop
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ	mt_Return
mt_jmploop	MOVE.B	n_pattpos(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PatternPos(PC),D0
	LSR.W	#4,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig
	move_dmacon n_dmabit(A6)	; Channel DMA off
	MOVE.L	n_start(A6),sam_start(A5) ; Set sampledata pointer
	MOVEQ #0,D0
	MOVE.W	n_length(A6),D0		; Set length
	ADD.L D0,D0
	ADD.L D0,sam_start(A5)
	MOVE.L D0,sam_length(A5)		; Set length

	MOVE.W	n_dmabit(A6),D0
	BSET	#15,D0
	move_dmacon d0
	MOVE.L	n_loopstart(A6),sam_lpstart(A5)
	MOVEQ #0,D0
	MOVE.W	n_replen(A6),D0
	ADD.L D0,D0
	ADD.L D0,sam_lpstart(A5)
	MOVE.L D0,sam_lplength(A5)
	MOVE.W	n_replen+2(A6),sam_period(A5)
mt_rtnend
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE	mt_Return
	CLR.B	n_volume(A6)
	MOVE.W	#0,sam_vol(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_Counter,D0
	BNE	mt_Return
	MOVE.W	(A6),D0
	BEQ	mt_Return
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE	mt_Return
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ	mt_Return
mt_UpdateFunk
	MOVEM.L	A0/D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.S	mt_funkend
	CLR.B	n_funkoffset(A6)

	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	n_wavestart(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	n_loopstart(A6),A0
mt_funkok
	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
mt_funkend
	MOVEM.L	(SP)+,A0/D1
	RTS


mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp	dc.l	0,0,0,0,0,$00010000,0,  0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,0,$00020000,0,  0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,0,$00040000,0,  0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,0,$00080000,0,  0,0,0,0

mt_SampleStarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr	dc.l 0
mt_speed	dc.b 6
mt_counter	dc.b 0
mt_SongPos	dc.b 0
mt_PBreakPos	dc.b 0
mt_PosJumpFlag	dc.b 0
mt_PBreakFlag	dc.b 0
mt_LowMask	dc.b 0
mt_PattDelTime	dc.b 0
mt_PattDelTime2	dc.b 0
mt_Enable	dc.b 0
mt_PatternPos	dc.w 0
mt_DMACONtemp	dc.w 0

;/* End of File */

		IFNE test
testfile	DC.B (endtestfilename-testfilename)
testfilename	DC.B "h:\mods\MADNESS.MOD"
endtestfilename
		ENDC

		SECTION BSS
vols		DS.L 64
		DS.L 16640/4
stebuf1:	DS.W bufsize	 	; buffers must be this big to handle
stebuf2:	DS.W bufsize		; downto tempo 32
dir		DS.W 1
mt_data					; module is loaded here.
