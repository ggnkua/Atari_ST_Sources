
;Hallo Independent-Members:
;so, hier die fertige Version von unserem DSP-Player.
;Bitte nur innerhalb der Independent benutzen. Falls jemand auûerhalb
;der Independent die Rout benutzen mîchte, mich vorher fragen
;(an sich kein Problem, aber nur damit ich Bescheid weiû)!!
;
;signed: Chris of AURA of the Independent

;Version V2.2: done at Risk-HQ 30.10-1.11.93
;              DSP-Paula fÑuft nun auch mit anderen DSP-Programmen
;		 	   L-R-KanÑle werden nun nicht mehr vertauscht.
;
;Version V2.3: 31.1-3.2.94
;			   - Der CIA-Proplayer wird nun unterstÅtzt, d.h. alle F-
;              Kommandos werden bearbeitet. Ich lasse die Paula jedoch
;              im VBL laufen, sodaû ich nicht weiû ob sich die Musis
;              mit diesem Verfahren korrekt anhîren (da ich nur 2 Musis
;              mit dem F-Kommando habe, die laufen jedoch perfekt).
;
;              - Die Knackser beim SSI-Betrieb sind nun ENDgÅltig weg!!!
;
;              - Nach vielfachem Wunsch wird nun ein PC-relatives Infile
;              erzeugt.
;
;              - Nun ist der Proplayer re-enterbar, d.h. man kann mehrere
;              Module hintereinander abspielen ohne jedesmal den kompletten
;              Player neu laden zu mÅssen (Installationsfehler im ProPlayer).
;
;Version V2.4: 10.2-20.2.94
;              - Host-Version wurde entfernt, da sie zu viel Zeit verbraucht und die
;              SSI-Version die DSP-Programmierung nicht stîrt.
;              - Echtzeit-PAULA eingebunden 
;              - Die Paula lÑuft jetzt im selben Timer wie der CIA-ProPlayer, d.h. Hopser
;              beim Abspielen der Musik die bei V2.3 auftreten konnten sind nun ausgeschlossen,
;              dafÅr muû jedoch mit dem Blitter aufgepasst werden.
;              - Es laufen nur Module mit mehr als 115bpm (kein Nachteil, da mir DOMM
;              versichert hat, daû es kein Modul mit weniger als 125bpm gibt)  
;              - die ModullÑnge wird dank Realtime-Paula nicht mehr vergrîûert.

make_bin	equ 0						;-1=Inline-File erzeugen
bin_tst		equ	-1						;-1= Infile testen
		mc68030

	IFNE	make_bin=-1
		org $0
	ENDIF

	IFNE	make_bin=0


		pea		prg
		move.w  #38,-(sp)
		trap	#14
		clr.w	-(sp)
		trap 	#1
prg:
		bclr	#5,$fffffa09.w

;       move.w #$4EB,$ffff82a2.w



prescale:		equ	1  					;PCM-Prescale
vga_flag:		equ	0					;0=ext. Lautspr./-1=int. Lautspr.

	IFNE	vga_flag=0
 		move.b	#14,$ffff8800.w
		move.b	$ffff8800.w,d0
		bset	#6,d0
		move.b	d0,$ffff8802.w
	ELSE
		move.b	#14,$ffff8800.w
		move.b	$ffff8800.w,d0
		bclr	#6,d0
		move.b	d0,$ffff8802.w
	ENDIF
		lea		name1,a5
		lea		module1,a6
		bsr		load_mod

		lea		name2,a5
		lea		module2,a6
		bsr		load_mod
		
		lea		module1,a0				;1. Moduladresse
		lea		module2,a2				;2. Moduladresse
		move.w	#prescale,d0			;PCM-Prescale-Code
		move.w	#-1,d1					;ADS installieren
		lea		timer_a_irq,a1			;Timer-A-IRQ-Adr. (Player-IRQ)
		bsr		dsp_paula+0				;Hauptinstallation

		move.w	#$8000,dsp_paula+12		;LautstÑrke
		move.w	#$3919,d0
 		movec	d0,cacr
		
		pea	info(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp

wait2:	cmp.b	#$39,$fffffc02.w
		bne.s	wait2

		moveq	#0,d7
		move.w	dsp_paula+12(pc),d7
fade_out:
		move.w	#37,-(sp)
		trap	#14
		addq.w	#2,sp
		move.w	d7,dsp_paula+12
		sub.l	#$200,d7
		bpl.s	fade_out

		bsr		dsp_paula+8
		move.w	#$0fff,$ffff8240.w
		bset	#5,$fffffa09.w
		rts

info:   dc.b 27,"EDSP-Realtime-Paula V2.4/Proplayer 3.0B-CIA",13,10
		dc.b    "coded by Chris of AURA/20.02.94",13,10
		dc.b	"now playing real 50 KHz/16 Bit/SSI-Output.",13,10,13,10
		dc.b	"blue       : required time to swap sampledata with DSP",13,10
		dc.b	"blue+yellow: total DSP-time",13,10
		dc.b	"white      : Proplayer-time",13,10
		dc.b	"red        : free DSP time",13,10
		dc.b	"red+yellow : free CPU time",0        
		

timer_a_irq:
		move.w	#$007,$ffff8240.w
		move.l	#$ff,$ffff9800.w
		bsr		dsp_paula+4
		move.w	#$770,$ffff8240.w
		move.l	#$ffff0000,$ffff9800.w
		move.w	#$2300,sr
sss:	btst	#3,$ffffa202.w			;Bit zum Testen ob DSP mit
		bne.s	sss                     ;der Vorberechnung fertig ist
		move.w	#$700,$ffff8240.w		;und somit weiter benutzt werden
		move.l	#$ff000000,$ffff9800.w	;kann
		rte

		IFNE bin_tst=-1
dsp_paula:
;Test der Inline-Version
		path "d:\source\dsppaula\8st_vers\"
		inline "pau_8st1.inl"
load_mod:
		clr.w	-(sp)
		pea		(a5)
		move.w	#$3d,-(sp)
		trap	#1
		addq.w	#8,sp		
		move.w	d0,d7
		
		pea		(a6)
		move.l	#500000,-(sp)
		move.w	d7,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea		$c(sp),sp
		
		move.w	d7,-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.w	#4,sp
		rts

name1:	dc.b "double1a.mod",0
name2:	dc.b "double2a.mod",0
	even
	BSS
module1:  		path "e:\mods\nospread\"
;			inline "double1a.mod"
			ds.b	500000
module2:	
;           inline "double2a.mod"
			ds.b	500000
	TEXT
	ENDIF

*****************************************************************************
**************************    D S P - P A U L A    **************************
****************  coded by Chris of AURA of the INDEPENDENT  ****************
***********************   DSP-Realtime Paula V2.4   *************************
******************************** SSI-Version ********************************
***********************  AMIGA-Proplayer V3.0B-CIA  *************************
************************  first code  :  14.04.93  **************************
************************  last changes:  20.02.94  **************************
*****************************************************************************
************************** about 90-95% CPU free ****************************
************************** about 80-90% DSP free ****************************
****************  thanx to bITmASTER and Questor of Inter  ******************
************************** for the SSI-Information **************************
*****************************************************************************
;Hinweise zum DSP-Coding mit der DSP-Paula:
;------------------------------------------

;- r7/m7 werden fÅr den SSI-IRQ benîtigt, sonst sind alle Register frei
;- Host-Command 1 ist belegt
;- P-Speicher $1F94 bis $4000 ist von der DSP-Paula belegt
;- wÑhrend und nach der AusfÅhrung des Hostcommands ist der SSI-IRQ aktiv
;  und muû laufende Programme unterbrechen kînnen. Der SSI-IRQ benîtigt
;  aber nur 6 Tz, somit ist er keine groûe Bremse.

;Hinweise zum MC-Coding:
;------------------------------------------
;- der Code ist nur an den zeitkritischen Stellen optimiert, also nicht
;  schimpfen.
;- programmiert mit dem EasyAss 4.0L.
;
;1. Bra.w: Initialisierung (von CODEC, Timer-A, ProPlayer und DSP-PAULA)
;          d0.w: PCM-Prescalewert von 1-5 und 7
;		   d1.w:  0: ADS nicht installieren (schon installiert)
;                -1: ADS installieren, d.h. DSP fÅr Paula vorbereiten
;          a0.l: Moduladr. des 1. Moduls
;          a1.l: Adr. des Timer-A-IRQs
;          a2.L: Moduladr. des 2. Moduls
;2. Bra.w: Paula-Emulation + ProPlayer 3.0B-CIA-Einsprungadr.
;          (immer in den Timer A setzen)
;3. Bra.w: Deinstallation (von CODEC und Timer-A)
;+12.w   : Main-Voice: zw. $0000(leise) und $ffff(laut)
;+14.w   : Offset in Bytes zu den Paula-Registern
;Aufbau der Paularegister:
;	DFF0A0:				dc.l $00000000	;Amiga:Adressregister ØØ Audio-Kanal 1 ÆÆ
;	DFF0A4:				dc.w $0000		;Amiga:Sample-LÑnge
;	DFF0A6:				dc.w $0000		;Amiga:Abtastfrequenz
;	DFF0A8:				dc.w $0000		;Amiga:LautstÑrke
;	DFF0AA:				ds.w 3			;Interne Informationen
; dasselbe in dieser Reihenfolge fÅr DFF0B0,DFF0C0,DFF0D0. 


;
;Hinweise zur Installation:
;Die Paula lÑuft nun im Timer und kann somit mit dem Blitter ins Gehege
;kommen. Der Blitter belegt je nach dem zu viel Buszyklen, sodaû er den 
;Timer-A zu spÑt ausgelîst werden kann. Die Folge wÑhre ein Knacksen, das
;nicht zu verhindern ist, da der DSP die neuen Sampledaten benîtigt, aber 
;nicht rechtzeitig erhÑlt.

;weitere Hinweise:
;die Proplayer und DSP-Paula-Routine rettet alle notwendigen Register!!


	    ELSE

	TEXT
BASE5:

;Test der ausf. Version 
paula_start:
 		bra.w	ap_grand_init			;Installation 
		bra.w	ap_dsp_paula_do			;Paula samt ProPlayer ausfÅhren
		bra.w	ap_small_deinit			;Deinstallation		
main_voice:		dc.w	$ffff			;HauptlautstÑrke 16 Bit (0-$ffff)
paula_regs:		dc.w	DFF0A0-paula_start
txt:	dc.b "DSP-REALTIME-PAULA V2.4 coded by Chris of Aura/"
		dc.b "Independent / >20.2.94< "

	even
***************************************************************************
;Schnittstelle zwischen Player und DSP-Paula
;vor jedem Player-Aufruf anspringen
***************************************************************************
	TEXT
ap_dsp_paula_do:
		move.w	sr,-(sp)
		ori		#$0700,sr				;ALLE IRQS MöSSEN AUS SEIN
 		move.b	#$93,$ffffa201.w		;DSP-Paula im DSP starten
		move.w	(sp)+,sr
		movem.l	d0-a6,-(sp)
		lea		BASE5(pc),a5			;Basisadr. in a5 setzen

		move.w	main_voice(pc),go_2nd_player+12(a5)	;LautstÑrke kopieren

		movec	cacr,d0					;CACR holen
		move.w	d0,cacr_rett(a5)		;retten
		lea		$ffffa200.w,a1			;DSP-Basisadr.
		lea		6(a1),a3

		moveq	#0,d0
		move.w	ap_mfp_timerwert(a5),d0	;neuer MFP-Timerwert holen
		move.b	d0,$fffffa1f.w			;und gleich setzen
										;ist ab nÑchten IRQ aktiv (WICHTIG!!)
		move.w	(ap_mfp_bytes.w,pc,d0*2),d0	;Anzahl Bytes zur Berechnung holen

ap_wait_to_command:
		btst	#3,2(a1)				;HF2-Bit zum Testen ob DSP-Paula 
		beq.s	ap_wait_to_command		;bereit ist
		move.l	d0,4(a1) 				;zu berechnende Bytes Åbergeben

		lea		DFF0A0(a5),a0			;Stimme 1 Basisadr.
		moveq	#0,d1					;DMA-Bit 0
		bsr.s	ap_compute_voice
		lea		DFF0B0(a5),a0			;Stimme 2 Basisadr.
		moveq	#1,d1					;DMA-Bit 1
		bsr.s	ap_compute_voice
		lea		DFF0C0(a5),a0			;Stimme 3 Basisadr.
		moveq	#2,d1					;DMA-Bit 2
		bsr.s	ap_compute_voice
		lea		DFF0D0(a5),a0			;Stimme 4 Basisadr.
		moveq	#3,d1					;DMA-Bit 3
		bsr.s	ap_compute_voice

		bsr		go_2nd_player+4			;2. Player abspielen
**************
	IFNE	make_bin=0
		move.l	#-1,$ffff9800.w			;Kontrollfarbe weiû
	ENDIF
**************
		bsr		ap_playmusic			;Proplayer anspringen
;!! a5 zerstîrt !!
		move.w	cacr_rett(pc),d0
		movec	d0,cacr					;CACR zurÅcksetzen
		movem.l	(sp)+,d0-a6
		rts



		
ap_compute_voice:
		btst	d1,DFF096+1(a5)			;DMA-Bit an?
		beq.s	ap_compute_dum_sample	;an >> Sample abarbeiten
ap_no_new_sample:
		move.l	(a0),a2					;akt. Sampleadr. holen
		moveq	#0,d0
		move.w	4(a0),d0				;akt. SamplelÑnge holen
		move.w	6(a0),d1				;Periode holen
		move.w	8(a0),d2				;LautstÑrke holen
		cmp.w	#1,d0					;SamplelÑnge<=1
		bhi.s	ap_go_samplecopy
		move.l	10(a0),a2				;Loopadresse holen holen
		move.w	14(a0),d0				;LooplÑnge holen
		cmp.w	#1,d0					;LoopsamplelÑnge <=1
		bhi.s	ap_go_samplecopy
ap_compute_dum_sample:
;Leersample einrichten um öbertragungszeit zu sparen
		lea		ap_dum_sample(a5),a2	;Leersampleadr.
		moveq	#1,d0					;SamplelÑnge = 1 Wort
		move.w	#79,d1					;Sonderperiode
		moveq	#0,d2					;LautstÑrke 0
		move.w	d1,6(a0)				;Periode speichern
		move.w	d2,8(a0)				;LautstÑrke speichern
		move.l	a2,10(a0)				;Loopsampleadr. setzen
		move.w	d0,14(a0)				;LoopsamplelÑnge auch = 1
ap_go_samplecopy:
		mulu.w	main_voice(a5),d2		;*frakt. HauptlautstÑrke
		swap	d2						;ganzzahliger Wert holen 

		move.l	(ap_vol_tab.w,PC,d2.w*4),4(a1) ;LautstÑrkewert in den DSP
		move.l	(ap_freq_tab-79*8.w,PC,d1.w*8),4(a1) ;ganzzahliger Offset an den DSP
		move.l	(ap_freq_tab+4-79*8.w,PC,d1.w*8),4(a1) ;fraktionaler Offset an den DSP
		moveq	#0,d7
ap_wait_for_dspwords:
		btst	#0,2(a1)				;Auf Antwort warten
		beq.s	ap_wait_for_dspwords
		move.w	(a3),d7					;Anzahl zu Åbertr. Worte holen
		clr.b	5(a1)					;oberstes Byte reinigen
;ECHTZEIT-PAULA-Emulation
;d7.l: Anzahl der zu kopierenden Worte
;a2.l: akt. Sampleadresse
;d0.l: akt. SamplelÑnge
ap_ploop_realtimepaula:
		tst.w	d7						;Anzahl = 0?
		beq		ap_pcopied_all_sample
		cmp.w	#1,d0					;SamplelÑnge<=1?
		bhi.s	ap_pcopy_no_leersample

;** SamplelÑnge <=1 >> Loopregister ÅberprÅfen **
		move.l	10(a0),a2				;neue Sampleadr. holen
		move.w	14(a0),d0				;neue SamplelÑnge holen
		cmp.w	#1,d0					;auch SamplelÑnge<=1?
		bhi.s	ap_pcopy_no_leersample
;** kein Loop >> restliche Leersampleworte Åbertragen **
		moveq	#1,d0					;1 Samplewort Åbertragen
		move.w	(a2),d1					;Samplewort holen
ap_pcopy_rest_leersample:
		nop								;Wartezyklen
		nop
		move.w	d1,(a3)					;Leersample kopieren
		subq.w	#1,d7
		bne.s	ap_pcopy_rest_leersample
		bra		ap_pcopied_all_sample	;Raussprung

;** Sampleworte Åbertragen **
ap_pcopy_no_leersample:
		move.l	d7,d6
		cmp.l	d0,d6					;zu Åbertr. Worte > Sampleworte?
		blt.s	ap_pcopy_all_sample
		move.l	d0,d6					;nur Sampleanzahl kopieren
ap_pcopy_all_sample:
		sub.l	d6,d0					;neue SamplelÑnge
		sub.l	d6,d7					;neue Kopieranzahl

		move.w	d6,d1
		and.w	#$1f,d1
		asr.w	#5,d6					;/32
		lea		(ap_pcopy_samplerest.w,PC,d1.w*2),a4	;RTS-Adr. bestimmen
		move.w	#$4e75,(a4)				;RTS setzen
		move.w	#$3919,d2				;Instruktionscache
		movec	d2,cacr             	;lîschen
		bsr.s	ap_pcopy_sample
		move.w	#$369a,(a4)				;move.w (a2)+,(a3) setzen
		
		bra		ap_ploop_realtimepaula
ap_pcopied_all_sample:
;ECHTZEIT-Paula-Emulation *ENDE*
		move.l	a2,(a0)					;neue Sampleadr. speichern
		move.w	d0,4(a0)				;neue SamplelÑnge speichern		
		rts

;Sample wird kopiert
ap_pcopy_sample:
		tst.w	d6
		beq		ap_pcopy_samplerest		;=0 >> keine 32er-Blîcke kopieren
		REPEAT
		move.w	(a2)+,(a3)
		UNTIL #31
		subq.w	#1,d6					;32 Worte auf einmal kopieren
		bne		ap_pcopy_sample
ap_pcopy_samplerest
		REPEAT 
		move.w	(a2)+,(a3)				;Restsample kopieren
		UNTIL #31
		rts

*****************************************************************************
;Hauptinstallation des Players
*****************************************************************************
;a0.l: Moduladr.
;a1.l: Timer-A-IRQ-Adr. bei d2=-1
;d0.w: Prescalewert (1-5/7)
;d1.w: =0 keine DSP-Installierung

ap_grand_init:
		pea		(a0)
		move.l	a2,a0					;2. Moduladr. holen
		bsr		go_2nd_player+0			;init
		move.l	(sp)+,a0

		lea		BASE5(pc),a5			;Basisadr. in a5
		move.l	a0,a6
 		tst.w	d1						;ADS schon installiert?
		beq.s	no_ads_inst
		bsr		dsp_system				;DSP installieren
no_ads_inst:
		moveq	#0,d1
		move.w	(ap_sampling_tab-2.w,PC,d0.w*2),d1	;Abspielfrequenz holen
		move.l	d1,ap_play_rate(a5)		;und speichern
*****************************************************************************
ap_install_pcm:
		lea		$ffff8900.w,a2			;PCM-Basisadr.
		clr.w	(a2)					;IRQs aus/DMA stop
		clr.w	$20(a2)					;8 Bit/stereo
		move.w	$34(a2),d7				;Prescale holen
		and.w	#$ff00,d7
		and.w	#$7,d0
		or.w	d0,d7					;KHz-Rate setzen
		move.w	d7,$34(a2)
		bset	#1,$37(a2)				;Input vom Multiplexer
		clr.w	$3a(a2)					;volle LautstÑrke
		move.w	#-1,main_voice(a5)		;volle LautstÑrke

		move.w	$30(a2),d7				;Device-Prescale holen
		and.w	#$ff0f,d7
 		or.w	#$90,d7					;kein Handshake/25.175 MHz-Rate
 										;kein Tri-State
		move.w	d7,$30(a2)
		move.w	$32(a2),d7				;Destination holen
		and.w	#$0f7f,d7				;>> DSP-REC auf Tri-State
		or.w	#$2000,d7				;Source: DSP-XMIT
		move.w	d7,$32(a2)
		lea		ap_dsp_paula_ssi(a5),a0
		bsr		dsp_system+4			;DSP-Paula im Hostbetrieb
*****************************************************************************
;Berechnung	der	Frequenztabelle
ap_calc_freq:
		lea		ap_freq_tab(a5),a2		;Frequenztabelle
		clr.l	(a2)+					;Periode 79 >> Leersample
		clr.l	(a2)+                   ;Offset auf 0

		moveq	#80,d7					;mit Periode 80 beginnen
ap_calc_freq_do:
		move.l	#3579546,d2				;Halbe Taktfrequenz	des	Amigas
		divu.l	d7,d2					;/Paula-Timerwert>>	Spielfrequenz
		move.l	d2,d3
		lsr		#8,d2					;oberes	Byte ins untere
		swap	d3						;mittleres Byte
		lsl.l	#8,d3					;ins oberste >>	d2:	Highbyte
										;				d3:	Lowbyte
		divu.l	ap_play_rate(a5),d2:d3	;64-Bit/32-Bit
		move.l	d3,d2
		rol.l	#8,d2					;Highbyte holen	>> Vorkommawert
		and.l	#$ff,d2
		move.l	d2,(a2)+				;Vorkommawert speichern
		and.l	#$00ffffff,d3			;Nachkommawert in 24-Bit holen
		move.l	d3,(a2)+				;und speichern
		rol.l	#8,d3
		addq.w	#1,d7					;Periode erhîhen
		cmp.w	#907+1,d7
		bne.s	ap_calc_freq_do
*****************************************************************************
;Volumeberechnung
ap_calc_vol:
		lea		ap_vol_tab(a5),a2		;Volumetabelle
		moveq	#65-1,d7				;noch 64 Volume-Abstufungen
		moveq	#64,d5					;mit LautstÑrkewert 1 beginnen
		move.l	#$8000/2,d6				;0.99999/2 auf 16 Bit
ap_calc_vol_host:
		divu.l	d5,d6                   ;/LautstÑrkeskala (64 Stufen)
		moveq	#0,d5
ap_calc_vol_do:
       	move.l  d5,(a2)+				;LautstÑrkewert als Kommawert
       	add.l	d6,d5
       	dbra	d7,ap_calc_vol_do
*****************************************************************************
		lea		ap_mfp_bytes(a5),a2		;Pufferadresse
		move.w	#1,d0					;mit MFP-ZÑhler=1 beginnen

ap_calc_mfp_bytes:		
		move.l	#12288*100,d1			;2457600/200 Tz des MFP
		divu	d0,d1					;/MFP-ZÑhlerwert
		move.l	ap_play_rate(a5),d2		;Abspielrate holen
		mulu	#100,d2					;*100		
		divu	d1,d2					;Abspielrate/Timerzeit
;		addq.w	#3,d2					;+4 bytes
		move.w	d2,(a2)+				;Byteanzahl zw. Timeraufruf speichern
		addq.w	#1,d0
		cmp.w	#256+1,d0				;256 erreicht?
		bne		ap_calc_mfp_bytes

*****************************************************************************
		pea		(a1)
		bsr		ap_mod_init				;Modul installieren
		move.l	(sp)+,a1
*****************************************************************************
ap_handle_irq:
		move.w	#245,ap_mfp_timerwert(a5)
		clr.b	$fffffa19.w
		move.l	a1,$134.w				;Timer-A-Vektor
		bset	#5,$fffffa07.w			;IER
		bset	#5,$fffffa13.w			;IMR
		bclr	#3,$fffffa17.w			;EOI
		move.b	#245,$fffffa1f.w		;Timer-Wert	 246 >> 50.15Hz
		move.b	#$7,$fffffa19.w			;Vorteiler 1:200
										;>> Timer-A wird alle 1/50s aufgerufen
ap_vbl_handle:
		rts

*****************************************************************************
	TEXT
ap_small_deinit:
		bsr		go_2nd_player+8			;2. Player ausschalten
		lea		BASE5(pc),a5
		clr.w	main_voice(a5)			;HauptlautstÑrke auf 0
		bclr	#5,$fffffa07.w			;IER
		bclr	#5,$fffffa13.w			;IMR
		clr.b	$fffffa19.w				;Timer-Stop
		bclr	#7,$ffff8931.w			;DSP-XMIT auf Tristate
		clr.w	DFF096(a5)				;DSP-Paula ausschalten
		rts
*****************************************************************************
;Paula-Pseudoregister
DFF096:				dc.w $0000		;Amiga:DMA-Controlregister
DFF0A0:				dc.l $00000000	;Amiga:Adressregister ØØ Audio-Kanal 1 ÆÆ
DFF0A4:				dc.w $0000		;Amiga:Sample-LÑnge
DFF0A6:				dc.w $0000		;Amiga:Abtastfrequenz
DFF0A8:				dc.w $0000		;Amiga:LautstÑrke
DFF0AA:				dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0AE:				dc.w $0000		;XXXXX:Pseudo-Loop-LÑnge

DFF0B0:				dc.l $00000000	;Amiga:Adressregister ØØ Audio-Kanal 2 ÆÆ
DFF0B4:				dc.w $0000		;Amiga:Sample-LÑnge
DFF0B6:				dc.w $0000		;Amiga:Abtastfrequenz
DFF0B8:				dc.w $0000		;Amiga:LautstÑrke
DFF0BA:				dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0BE:				dc.w $0000		;XXXXX:Pseudo-Loop-LÑnge

DFF0C0:				dc.l $00000000	;Amiga:Adressregister ØØ Audio-Kanal 3 ÆÆ
DFF0C4:				dc.w $0000		;Amiga:Sample-LÑnge
DFF0C6:				dc.w $0000		;Amiga:Abtastfrequenz
DFF0C8:				dc.w $0000		;Amiga:LautstÑrke
DFF0CA:				dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0CE:				dc.w $0000		;XXXXX:Pseudo-Loop-LÑnge

DFF0D0:				dc.l $00000000	;Amiga:Adressregister ØØ Audio-Kanal 4 ÆÆ
DFF0D4:				dc.w $0000		;Amiga:Sample-LÑnge
DFF0D6:				dc.w $0000		;Amiga:Abtastfrequenz
DFF0D8:				dc.w $0000		;Amiga:LautstÑrke
DFF0DA:				dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0DE:				dc.w $0000		;XXXXX:Pseudo-Loop-LÑnge


*****************************************************************************
dsp_system:	path "d:\source\dsppaula\8st_vers\"
			inline	"dsp_sy11.inl"
ap_dsp_paula_ssi:
			inline "pau_8st.ads"		;DSP-Paula im SSI-Betrieb
go_2nd_player:	
			inline "pau_8st2.inl"
*****************************************************************************
			include	"pro__30d.q"		;Proplayer
*****************************************************************************
ap_play_rate:	dc.l	0				;Abspielfrequenz des Players
ap_mfp_timerwert:	dc.w	245			;aktueller Timer-Wert

ap_sampling_tab:
		dc.w	49150				;50 Khz
		dc.w	32750				;33 KHz
		dc.w	24600				;25 KHz
		dc.w	19650				;20 KHz
		dc.w	16400				;16 KHz
		dc.w	12300				;unzulÑssig
		dc.w	12300				;12 KHz
ap_freq_tab:	ds.l	2*(907-79+1)
ap_mfp_bytes:	ds.w	256				;zu berechn. Bytes pro MFP-ZÑhlerwert
ap_vol_tab:	ds.l	65					;65 Volume-Abstufungen


cacr_rett:	dc.w	0
ap_dum_sample:	dc.l	$80808080		;Dummysample fÅr Kanalabschaltung
*****************************************************************************
	IFNE	make_bin=0
			path "e:\mods\nospread\"
module1:		inline "double1a.mod"
module2:		inline "double2a.mod"
	ENDIF
	ENDIF
*****************************************************************************
	
		end
