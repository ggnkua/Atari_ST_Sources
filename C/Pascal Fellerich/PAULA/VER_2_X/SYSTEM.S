*************************************************************************
*
*  SYSTEM.S
*  --------
*
*  MODPlayer low level routines: Hardware accesses etc.
*
*
*
*  last modified: 13-Jan-1993
*				  14-sep-1994 (tas -> bset)
*************************************************************************

				include "pdefs.inc"

SOFTDMA_COOKIE	equ 'SSND'
SOFTDMA_MAGIC	equ 'CLPF'


; -----------------------------------------------------------------------
; Globals:
; -----------------------------------------------------------------------
;
; exported subroutines:
;
				xdef p_global_init
				xdef acc_malloc 		; special malloc for ACC's
				xdef alloc_fast_ram
				xdef free_memory
				xdef init_DMA_sound, exit_DMA_sound
				xdef check_sound_running
				xdef supexec
				xdef read_cookie
;
; exported variables:
;
				xdef has_DMA_sound		;charflag
				xdef has_XBIOS_sound		;charflag
				xdef has_68020			;charflag
				xdef softdma_interface	;Pointer!
				xdef sdmabufadr1,sdmabufadr2
;
; imported subroutines:
;
				xref mt_music			;vbl seq.
				xref Paula				;chip emulator
				xref SoftPaula			;softdma interface
				xref calc_voltab
;
; imported variables:
;
				xref AudioFrameSize 	;from synth.s
				xref voltabP
				xdef LeftBuffer, RightBuffer
				
				xref p_interpolate		;from player.s
				xref p_overload
				xref p_cpuload
				xref p_state
				xref p_boost
				xref p_samplefreq
				xref paula_frequencies
				

; -----------------------------------------------------------------------
; internally used defines:
; -----------------------------------------------------------------------

INTBIT			equ 7					;Port 7 interrupt
PCM_VECTOR		equ $013C				;associated MFP vector

ISRA			equ $FFFFFA0F			;MFP Registers
IERA			equ $FFFFFA07
IPRA			equ $FFFFFA0B
IMRA			equ $FFFFFA13

* STE/TT DMA SOUNDCHIP:
SDMACNTR		equ $FFFF8900
FRMBASEHI		equ $FFFF8902
FRMBASEMID		equ $FFFF8904
FRMBASELO		equ $FFFF8906
FRMCNTHI		equ $FFFF8908
FRMCNTMID		equ $FFFF890A
FRMCNTLO		equ $FFFF890C
FRMENDHI		equ $FFFF890E
FRMENDMID		equ $FFFF8910
FRMENDLO		equ $FFFF8912
SMODCNTR		equ $FFFF8920

MWDATA			equ $FFFF8922
MWMASK			equ $FFFF8924



; -----------------------------------------------------------------------
; Code
; -----------------------------------------------------------------------
				text
				super					;MUST use SuperMode!

;STE mit 8.0106 MHz:
;		dc.w 6258,12517,25033,50066; (ste)
;TT mit 32.215905 MHz:
tt_paula_frequencies:
		dc.w 6292,12584,25167,50337 ;(tt)
;Falcon030 mit neuem Soundsubsystem 25.175 MHz:
falcon_paula_frequencies:
		dc.w 6146,12292,24585,49170 ;(falcon030)

*
* p_global_init: initialisiert den Player, alloziert Speicher.
* Param:  keine
* Return: Fehlercode
*
p_global_init:
		movem.l d3-d7/a2-a6,-(sp)
		move.l	a0,basepage 			;Bpage Pointer merken

;NEW: check for XBIOS sound....
	move.w #128,-(sp)
	trap #14
	addq #2,sp
	cmpi #1,d0					; free!
	beq .xbiosfree	
	cmpi #-129,d0				; already reserved...
	beq .xbiosout
.xbiosfree:
	move.w #129,-(sp)			; unlock sound system for now!
	trap #14
	addq #2,sp
.xbiosout:
	st	has_XBIOS_sound			; we have it....
.noxbiossnd:

		lea 	getsys(pc),a0
		bsr 	supexec					;Systemdaten lesen
		tst.b	has_DMA_sound			;STE DMA vorhanden?
		beq		.no_dmasound			;nein -> kein ST ram alloc
		clr.l	softdma_interface		;du nicht!

		move.w	machine_type(pc),d0		;Welche Maschine?
		lea		tt_paula_frequencies(pc),a0
		cmpi.w	#2,d0					;TT: h”her!
		beq.s	.setfreq
		lea		falcon_paula_frequencies(pc),a0
		cmpi.w	#3,d0					;Falcon: niedriger		
		bne.s	.skip
.setfreq:
		lea		paula_frequencies(pc),a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
.skip:	
		move.l	#BUFFERSIZE,d0
		clr.w	-(sp)					;Modus 0: ST-Ram only
		move.l	d0,-(sp)				;Amount
		move.w	mxalloc(pc),-(sp)		;Mxalloc
		trap	#1
		addq.w	#8,sp
		tst.l	d0
		spl 	can_work
		bmi.s	.noplayer				;ohne ST Ram kein Player !
		addq.l	#3,d0
		andi.w	#$FFFC,d0				;LongWord aligned for TT!
		movea.l d0,a0
		lea 	buffer1(a0),a1			;Erster Puffer
		move.l	a1,sdmabufadr1
		lea 	buffer2(a0),a1
		move.l	a1,sdmabufadr2
.softentry:
		tst.b	has_68020				;Volume Table n”tig??
		bne.s	.novoltab
		move.l	#TOGGLEVOLUME*256,d0
		bsr 	fm_alloc				;returns addr in a0 & d0
		move.l	d0,voltabP
		bsr 	calc_voltab
.novoltab:
		moveq	#E_OK,d0
.globlin1:
		clr.w	p_state 				;Idle State
		movem.l (sp)+,d3-d7/a2-a6
		rts

.noplayer:
		moveq	#E_FRAMEBUFFER,d0
		bra.s	.globlin1
.no_dmasound:
		move.l	softdma_interface(pc),d0	;Christians DMA Emulator?
		sne		can_work					;dann drfen wir!
		beq.s	.no_dmasound2
		movea.l	d0,a1
;		move.l	#PaulaHook,SDMA_HOOK(a1)	;Anmelden!
		lea		paula_frequencies(pc),a0	;our samplefreqs
		move.l	SDMA_SF0(a1),(a0)+
		move.l	SDMA_SF2(a1),(a0)+
		bra.s	.softentry					;weiter
		
.no_dmasound2:
		moveq	#E_DMASOUND,d0			;ansonsten fehler!
		bra.s	.globlin1

supexec:
		pea 	(a0)
		move.w	#38,-(sp)
		trap	#14
		addq.l	#6,sp
		rts

getsys: lea 	fstacktop(pc),a0
		move.l	a0,d0
		andi.w	#$FFFC,d0				;Stack auf longwords
		move.l	d0,faststack
		sf		has_DMA_sound			;Annahme: kein DMA sound
		sf		has_68020				;Annahme: 68000
		movea.l _sysbase.w,a0
		move.l	$28(a0),os_act_pd		;systemvektor fr sp„ter
		cmpi.w	#$0205,2(a0)			;OS-Version
		bge.s	.istos3
		move.w	#Malloc,mxalloc			;Extended Alloc Call OK?!
.istos3:
		movea.l _p_cookies.w,a0			;Cookie
		move.l	a0,d0
		beq.s	.get_end 				;kein Cookiejar -> Abbruch
.readjar:
		move.l	(a0)+,d0				;Cookie holen
		beq.s	.get_end 				;fertig.
		move.l	(a0)+,d1				;Value holen
		cmpi.l	#'_CPU',d0				;Prozessortyp?
		beq.s	.getproc
		cmpi.l	#'_SND',d0				;Soundhardware?
		beq.s	.getsnd
		cmpi.l	#'_MCH',d0				;Maschinentyp?
		beq.s	.getmachine
		cmpi.l	#'MiNT',d0				;MTOS / MiNT?
		beq.s	.isMiNT
		bra.s	.readjar
.get_end:
		rts

.getproc:
		cmpi.w	#20,d1					;op d'manst ‚n 68020!
		sge 	has_68020				;020/030 Flag
		bra.s	.readjar

.getsnd:	
		btst	#1,d1
		sne 	has_DMA_sound			;OK!
		bra.s	.readjar 				;DMA Soundchip vorhanden

.getmachine:
		swap	d1						;get highword
		move.w	d1,machine_type
		bra.s	.readjar

.isMiNT:
		clr.l	basepage				;Kein Basepage gefummels
		bra.s	.readjar
	

*
* Mxalloc, FASTRAM preferred (fr Programm und Daten)
* Param.: d0.l Anzahl Bytes die verlangt werden
* Return: d0.l & a0   Startadresse
acc_malloc:								;PureC Interface
		move.l	a2,-(sp)
		bsr		alloc_fast_ram
		movea.l	(sp)+,a2
		rts
alloc_fast_ram:
		move.l	basepage(pc),d1 		;Verbiegerei NICHT unter MiNT oder
		beq.s	is_applic				;als Programm!
		move.l	a3,-(sp)
		movea.l os_act_pd(pc),a3		;Zeiger auf Processpointer
		move.l	(a3),-(sp)				;retten
		move.l	d1,(a3) 				;meine Basepage, ich bin der Owner!
		bsr.s	fm_alloc
		move.l	(sp)+,(a3)				;os_act_pd zurcksetzen
		movea.l (sp)+,a3
		rts

is_applic:
fm_alloc:
		move.w	#3,-(sp)				;Modus 3
		move.l	d0,-(sp)				;Amount
		move.w	mxalloc(pc),-(sp)		;Mxalloc
		trap	#1
		addq.w	#8,sp
		movea.l d0,a0
		rts


*
* Speicherblock freigeben:
*
* Param.: d0: Blockadresse
free_memory:
		move.l	a2,-(sp)
		tst.l	d0
		beq.s	freem1
		move.l	d0,-(sp)
		move.w	#Mfree,-(sp)
		trap	#1
		addq.w	#6,sp
freem1: movea.l	(sp)+,a2
		rts


;--------------------------------- cookie jar ------------------
; Deklaration in C:
;	int read_cookie(long ID, long *ret);
;
; ID: Cookie Jar Identifier.
; *ret: return value
; Funktion gibt 1 (TRUE) oder 0 (FALSE) zurck.
;
read_cookie:					;fr'n Linker!
		movem.l d3/a2-a3,-(sp)
		move.l	d0,d3			;ID retten
		movea.l a0,a3			;Returnpointer
		lea 	getpointer(pc),a0
		bsr		supexec
		tst.l	d0				;Pointer?
		beq.s	no_cookiejar
		btst	#0,d0			;odd?
		bne.s	no_cookiejar
		movea.l d0,a0			;Pointer seems OK
check_next:
		move.l	(a0)+,d1		;Cookie ID
		beq.s	cookie_not_found
		move.l	(a0)+,d2		;entry
		cmp.l	d1,d3			;gesuchtes Objekt?
		bne.s	check_next
		move.l	d2,(a3) 		;dem User das Objekt bergeben
		moveq	#TRUE,d0
		bra.s	cookie_exit

cookie_not_found:
no_cookiejar:
		moveq	#FALSE,d0

cookie_exit:
		movem.l (sp)+,d3/a2-a3
		rts

getpointer:
		move.l	_p_cookies.w,d0
		rts


;---------------------------------------------------------------

*
* XBIOS-routinen:
*

*
* Hauptroutine:
*
PaulaHook:
		movem.l d3-d7/a2-a6,-(sp)
		move.l	sp,savestack
		movea.l faststack(pc),sp		;use own stack (32 bit fastram)
		lea		p_overload(pc),a0
		subq.w	#1,(a0)
		bpl.s	.domusic
		clr.w	(a0)
.domusic:		
		bsr 	mt_music				;
		not.w	frameflag				;Pufferumschaltung
		bne.s	.setbuf2 				;N„chster puffer ist Nummer 2
.setbuf1:
		lea		LeftBuffer(pc),a0			;Frame 1 berechnen
		bsr 	SoftPaula				;Chip Emulator
		lea		LeftBuffer(pc),a0			;und Frame 1 setzen!
		bra.s	.setbuf
.setbuf2:
		lea		RightBuffer(pc),a0			;Frame 2 berechnen
		bsr 	SoftPaula
		lea		RightBuffer(pc),a0			;Adresse des 2ten Puffers
.setbuf:
		move.w	AudioFrameSize(pc),d1	;L„nge des Puffers
		exg		d0,d1					;bitsize kommt korrekt zurck.
		move.l	softdma_interface(pc),a1
		move.w	p_boost(pc),SDMA_BOOST(a1)
		move.l	SDMA_SETFRAME(a1),a1
		jsr		(a1)
		movea.l savestack(pc),sp
		movem.l (sp)+,d3-d7/a2-a6		;ab hier wieder reentrant
		rts

*
* new init:
*
softdma_init:
	move.w #128,-(sp)			; reserve sound susbystem
	trap #14
	addq #2,sp
	cmpi #1,d0					; free!
	bne .nosound
	move.w #1,-(sp)	; protcol
	move.w prescale,-(sp)
	move.w srcclk,-(sp)
	move.w dst,-(sp)
	move.w src,-(sp)
	move.w #139,-(sp)			; devconnect
	trap #14
	lea 12(sp),sp

 Setbuffer(0, sambufstart, sambufend);
 Devconnect(DMAPLAY, DAC, 0, CLK12K, 1);   /* 12KHz einstellen */
 Setmode(MONO8);
 Soundcmd(LTATTEN, 0x070); Soundcmd(RTATTEN, 0x070);

	
.nosound:
	rts
	
;		movea.l	d0,a0
;		movea.l	SDMA_INIT(a0),a1
;		move.l	#PaulaHook,SDMA_HOOK(a0)
;		lea		LeftBuffer(pc),a0		;erster (Mono-)Puffer
;		clr.w	frameflag				;current running buffer!
;		move.w	AudioFrameSize,d0		;L„nge der Daten
;		moveq	#0,d1					;Range = 0 bit :-)
;		move.w	p_samplefreq(pc),d2		;Diese Frequenz...
		jmp		(a1)					;jsr/rts

*
* new exit:
*
softdma_exit:
;		movea.l	d0,a0
;		movea.l	SDMA_EXIT(a0),a1
;		jmp		(a1)					;stop it.

*
* Testroutine zum evtl. Anschmeissen des Sounds nach Fremd-Abbruch
* 
*
check_sound_running:
		move.l	softdma_interface(pc),d0
		bne.s	.nocheck				;Nicht fr's SoftDMA!
		btst	#0,SDMACNTR+1.w			;DMA running?
		beq.s	relaunch_dma
.nocheck:
		rts

*
* Routinen zum Starten/Stoppen des Chips
* - supervisor mode erforderlich
*
init_DMA_sound:
		move.l	softdma_interface(pc),d0
		bne.s	softdma_init
		andi.w	#!%11,SDMACNTR.w		;Stop DMA & Repeat
relaunch_dma:
		btst	#INTBIT,gpip.w			;Monitor Type ?
		bne.s	m_high
		bclr	#INTBIT,aer.w
		bra.s	m_cont
m_high: bset	#INTBIT,aer.w
m_cont: lea 	Sound_interrupt(pc),a0
		move.l	a0,PCM_VECTOR.w 		;Set the Exception Vector
		bclr	#INTBIT,IPRA.w			;MFP_PendA.w
		bset	#INTBIT,IMRA.w			;Mask 'Sound Active' interupt.
		bset	#INTBIT,IERA.w			;Enable 'Sound Active' interupt

		move.b	p_samplefreq+1(pc),SMODCNTR+1.w ;Chip Mode Control

		movea.l sdmabufadr1(pc),a0		;Adresse des 1ten Puffers
		bsr 	SetFrame
		clr.w	frameflag				;current running buffer!
		ori.w	#%11,SDMACNTR.w			;chipstart!
		rts


exit_DMA_sound:
		move.l	softdma_interface(pc),d0
		bne.s	softdma_exit
		move	sr,d0					;Except. #24: spurious interrupt
		ori		#$700,sr				;hope it helps...
		andi.w	#!%10,SDMACNTR.w		;DMA Repeat aus
		bclr	#INTBIT,IERA.w			;weitere Irq's unterdrcken
		clr.l	PCM_VECTOR.w			;Vektor zurcksetzen
		clr.w	p_cpuload				;Indikator l”schen
		clr.w	p_overload
		move	d0,sr
		rts


*
* interrupt overlapping...
*
overlap:
		bclr	#INTBIT,ISRA.w			;End Of Interrupt -> wg. IKBD irq

		move.w	#OVERTICKS,p_overload	;25 irq's = 0.5 sec
		move.w	AudioFrameSize(pc),p_cpuload

;--- call song data interpreter (although overload...)
		movem.l d0-a6,-(sp)
		bsr 	mt_music
		movem.l (sp)+,d0-a6

		rte

**********************************************************************
*
* INTERRUPT-ROUTINE, ALLE 20 MSEC AUFZURUFEN!
*
*
				dc.l 'XBRA','PAUL',0
Sound_interrupt:
		bset.b	#7,interrupt_pending
		bne.s	overlap 				;HORROR: berlappende IRQ's!!!!
		bclr	#INTBIT,ISRA.w			;End Of Interrupt -> wg. IKBD irq
		move	#$2300,sr				;SuperVisor & normal IRQ level.

		movem.l d0-a6,-(sp)
;**** !!!!! NON REENTRANT CODE !!!!! ****
		move.l	sp,savestack
		movea.l faststack(pc),sp		;use own stack (32 bit fastram)

		tst.w	p_overload
		ble.s	.peak_load
		subq.w	#1,p_overload			;decrement overload
.peak_load:
		not.w	frameflag				;Pufferumschaltung
		bne.s	.setbuf2 				;N„chster puffer ist Nummer 2

.setbuf1:
		movea.l sdmabufadr1(pc),a0		;Frame 1 berechnen
		bsr 	Paula					;Chip Emulator
		move.l	sdmabufadr2(pc),d2
		movea.l sdmabufadr1(pc),a0		;und Frame 1 setzen!
		bra.s	.setbuf

.setbuf2:
		movea.l sdmabufadr2(pc),a0		;Frame 2 berechnen
		bsr 	Paula
		move.l	sdmabufadr1(pc),d2
		movea.l sdmabufadr2(pc),a0		;Adresse des 2ten Puffers

.setbuf:
		move.l	d2,-(sp)				;save sdmabufadr...
		bsr 	SetFrame

;--- call song data interpreter --------;
		bsr 	mt_music				;
;---------------------------------------;

; Rechenzeitverbrauch messen!
		lea 	FRMCNTHI.w,a0			;Chipregister
		movep.l -1(a0),d1				;akt. Adresse auslesen
		sub.l	(sp)+,d1				;im Lowword Differenz!
		lea 	p_cpuload(pc),a6
		add.w	d1,(a6)
		lsr.w	(a6)					;/2

;-- ok! --
		movea.l savestack(pc),sp
		movem.l (sp)+,d0-a6 			;ab hier wieder reentrant
		sf		interrupt_pending
		rte

*
*****************************************************************************

*
* Setze n„chsten Abspielbereich: von a0 bis a1;
* Param:	a0: FrameStart
* Return:	void
* Global:	FrameSize is read from AudioFrameSize!
*
SetFrame:
		move	sr,d0
		ori 	#$0700,sr
		pea 	(a0)
		move.b	3(sp),FRMBASELO+1.w
		move.b	2(sp),FRMBASEMID+1.w
		move.b	1(sp),FRMBASEHI+1.w 	;Start des Frames
		move.w	AudioFrameSize(pc),d1
		adda.w	d1,a0					;Stereo: L & R !
		adda.w	d1,a0
		move.l	a0,(sp)
		move.b	3(sp),FRMENDLO+1.w
		move.b	2(sp),FRMENDMID+1.w
		move.b	1(sp),FRMENDHI+1.w		;Ende des Frames
		addq.l	#4,sp
		move	d0,sr
		rts



; -----------------------------------------------------------------------
; initialized variables
; -----------------------------------------------------------------------
				data

mxalloc:		dc.w Mxalloc



; -----------------------------------------------------------------------
; variables
; -----------------------------------------------------------------------
				bss

faststack:		ds.l 1					;Eigener Stackbereich!
savestack:		ds.l 1
sdmabufadr1:	ds.l 1					;Adresse der Framebuffer fr den D/A-Wandler
sdmabufadr2:	ds.l 1					;es sind 2 wegen Double buffering technik

os_act_pd:		ds.l 1					;Zeiger auf den act_pd vektor
basepage:		ds.l 1					;Zeiger auf eigene BasePage


last_freqtabcheck:
				ds.l 1					;Letzte berechnete Samplingfrequenz
softdma_interface:
				ds.l 1					;DMA Emulator?
				
frameflag:		ds.w 1					;Welcher Puffer gerade gespielt wird

machine_type:	ds.w 1					;Maschinentyp aus Cookie Jar (_MCH)
has_DMA_sound:	ds.b 1
has_XBIOS_sound:ds.b 1
has_68020:		ds.b 1					;>'020!!

can_work:		ds.b 1					;gesetzt wenn Arbeit m”glich...
interrupt_pending:
				ds.b 1					;seeeehhhr wichtig

				even

				ds.l FSTACK 			;interner Stack
fstacktop:		ds.l 1



; -----------------------------------------------------------------------
; end of file
; -----------------------------------------------------------------------

