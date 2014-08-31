;Hallo Independent-Members:
;so, hier die fertige Version von unserem DSP-Player.
;Bitte nur innerhalb der Independent benutzen. Falls jemand aužerhalb
;der Independent die Rout benutzen m”chte, mich vorher fragen
;(an sich kein Problem, aber nur damit ich Bescheid weiž)!!
;
;signed: Chris of AURA of the Independent

;Versin V2.2: done at Risk-HQ 30.10-1.11.93
;             DSP-Paula f„uft nun auch mit anderen DSP-Programmen
;			  L-R-Kan„le werden nun nicht mehr vertauscht.



example:	equ	-1						;0=kein Beispiel

		mc68030

	IFNE	example=-1
		opt	d+

		pea		prg
		move.w  #38,-(sp)
		trap	#14
		clr.w	-(sp)
		trap 	#1
prg:
		bclr	#5,$fffffa09.w
		bsr		dsp_system				;DSP installieren

prescale:		equ	1  					;PCM-Prescale
ssi_or_host:	equ	-1 					;0=Host/-1=SSI
vbl_or_timer:	equ	-1 					;0=VBL/-1=Timer-A
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
		lea		module,a0				;Moduladresse
		bsr		ice_decrunch_2			;File gegf. vorher decrunchen

		move.w	#prescale,d0			;PCM-Prescale-Code
		moveq	#ssi_or_host,d1			;SSI oder Host-Ausgabe
		moveq	#vbl_or_timer,d2
	IFNE	vbl_or_timer=-1
		lea		timer_a_irq,a1			;Timer-A-IRQ-Adr. bei d2=-1
	ENDIF
		bsr		ap_grand_init			;Hauptinstallation

		move.w	#$8000,main_voice
		move.w	#$3919,d0
 		movec	d0,cacr
		
		pea	info(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp

	IFNE	vbl_or_timer=0		
		move.l	#play,$4d2.w
	ENDIF
		clr.l	$4d6.w
wait2:	cmp.b	#$39,$fffffc02.w
		bne.s	wait2

		moveq	#0,d7
		move.w	main_voice(pc),d7
fade_out:
		move.w	#37,-(sp)
		trap	#14
		addq.w	#2,sp
		move.w	d7,main_voice
		sub.l	#$200,d7
		bpl.s	fade_out

		bsr		ap_small_deinit				
		clr.l	$4d2.w		
		move.w	#$0fff,$ffff8240.w
		bset	#5,$fffffa09.w
		rts

info:   dc.b 27,"EDSP-Paula V2.2/Proplayer 3.0B",13,10
		dc.b    "coded by Chris of AURA/15.05.93",13,10
		dc.b	"now playing real 50 KHz/16 Bit/SSI-Output.",13,10,13,10
		dc.b	"blue       : required time to swap sampledata with DSP",13,10
		dc.b	"             +AMIGA-Proplayer",13,10
		dc.b	"blue+yellow: total DSP-time",13,10
		dc.b	"red        : free DSP time",13,10
		dc.b	"red+yellow : free CPU time",0        

play:
		movem.l	d0-a6,-(sp)
		move.w	#10000,d0
wait:	dbra	d0,wait
		move.w	#$007,$ffff8240.w
		move.l	#$ff,$ffff9800.w
		bsr		ap_dsp_paula_do
		move.w	#$770,$ffff8240.w
		move.l	#$ffff0000,$ffff9800.w
sss:	btst	#3,$ffffa202.w			;Bit zum Testen ob DSP mit
		bne.s	sss                     ;der Vorberechnung fertig ist
		move.w	#$700,$ffff8240.w		;und somit weiter benutzt werden
		move.l	#$ff000000,$ffff9800.w	;kann
		movem.l	(sp)+,d0-a6
		rts

timer_a_irq:
		movem.l	d0-a6,-(sp)
		move.w	#$007,$ffff8240.w
		bsr		ap_dsp_paula_do
		move.w	#$770,$ffff8240.w
ssss:	btst	#3,$ffffa202.w			;Bit zum Testen ob DSP mit
		bne.s	ssss                    ;der Vorberechnung fertig ist
		move.w	#$700,$ffff8240.w		;und somit weiter benutzt werden
										;kann
		movem.l	(sp)+,d0-a6
		rte

			path "d:\source\dsppaula\"
			include "ice_unp2.s"
;!!!!!ADS muž mit diesem Label eingebunden werden!!!!!
dsp_system:	path "d:\source\aura_dsp.sys\"
			inline	"dsp_sy11.inl"
	ENDIF
*****************************************************************************
**************************    D S P - P A U L A    **************************
****************  coded by Chris of AURA of the INDEPENDENT  ****************
****************************   DSP-Paula V2.2   *****************************
************************** Host- and SSI-Version ****************************
**********************  AMIGA-Proplayer V1.1B/V3.0B  ************************
************************  first code  :  14.04.93  **************************
************************  last changes:  15.05.93  **************************
*****************************************************************************
************************** about 85-95% CPU free ****************************
************************** about 75-90% DSP free ****************************
****************  thanx to bITmASTER and Questor of Inter  ******************
************************** for the SSI-Information **************************
*****************************************************************************
;Hinweise zum DSP-Coding mit der DSP-Paula:
;------------------------------------------
;>>Host-Betrieb<<
;- alle Register sind frei
;- Host-Command 1 ist belegt
;- P-Speicher $2C46 bis $4000 ist von der DSP-Paula belegt
;- nach Ausfhrung des Hostcommands steht die volle Rechenzeit zur Verfgung

;>>SSI-Betrieb<<
;- r7/m7 werden fr den SSI-IRQ ben”tigt, sonst sind alle Register frei
;- Host-Command 1 ist belegt
;- P-Speicher $2444 bis $4000 ist von der DSP-Paula belegt
;- w„hrend und nach der Ausfhrung des Hostcommands ist der SSI-IRQ aktiv
;  und muž laufende Programme unterbrechen k”nnen. Der SSI-IRQ ben”tigt
;  aber nur 4 Tz, somit ist er keine grože Bremse.

;Hinweise zum MC-Coding:
;------------------------------------------
;- der Code ist nur an den zeitkritischen Stellen optimiert, also nicht
;  schimpfen.
;- programmiert mit dem EasyAss 4.0L.
;
;1. Bra: Initialisierung.
;        d0.w: PCM-Prescalewert von 1-5 und 7
;		 d1.w: -1: SSI-Paula  (schneller, kann aber fr DSP-Coder
;							   ungeeignet sein, da SSI-IRQ)
;			    0: Host-Paula (langsamer, aber fr DSP-Coder geeignet, da
;				               kein SSI-IRQ dazwischenfunkt)
;		 d2.w: -1: Timer-A-IRQ (in a1 wird die IRQ-Adr. erwartet)
;				0: 50Hz-VBL
;        a0.l: Moduladresse
;        a1.l: Adr. des Timer-A-IRQs bei d2.w=-1
;2. Bra: Paula-Emulation+AMIGA-Proplayer, im IRQ benutzen
;        bei d2.w= 0: in den 50Hz-VBL h„ngen
;		 bei d2.w=-1: in den Timer-A-IRQ h„ngen dessen Startadr. in a1 
;					  erwartet wird
;3. Bra: Deinstallation
	TEXT
dsp_paula:
		bra.w	ap_grand_init			;Installation 
		bra.w	ap_dsp_paula_do			;VBL-IRQ
		bra.w	ap_small_deinit			;Deinstallation		
main_voice:		dc.w	$ffff			;Hauptlautst„rke 16 Bit (0-$ffff)
***************************************************************************
;Schnittstelle zwischen Player und DSP-Paula
;vor jedem Player-Aufruf anspringen
***************************************************************************
	TEXT
ap_dsp_paula_do:
 		move.b	#$93,$ffffa201.w		;DSP-Paula im DSP starten
		tst.w	ap_ssi_flag(pc)			;SSI-Version?
		bne.s	ap_no_dma_set
		movem.l	ap_pcm_buf_adr(pc),d0/a0	;PCM-Pufferadressen
		exg.l	d0,a0
		movem.l	d0/a0,ap_pcm_buf_adr	;vertauschen

		lea		$ffff8900.w,a1			;PCM-Basisadr.
		clr.w	(a1)
		movep.w	d0,5(a1)				;Lowbyte/Midbyte
		swap	d0
		move.b	d0,3(a1)				;Highbyte
		move.w	#$3,(a1)				;DMA-an
ap_no_dma_set:
		movec	cacr,d0					;CACR holen
		move.w	d0,cacr_rett			;retten
		move.w	#$3919,d0				;I- und D-Cache an + Burstmode
		movec	d0,cacr					;Cache setzen
		lea		$ffffa200.w,a1			;DSP-Basisadr.
		lea		6(a1),a3
ap_wait_to_command:
		btst	#3,2(a1)				;HF2-Bit zum Testen ob DSP-Paula 
		beq.s	ap_wait_to_command		;bereit ist

		tst.w	ap_ssi_flag(pc)			;SSI-Version angew„hlt?
		bne		ap_ssi_do_it			;>> SSI erledigt den Job
;vorberechnete PCM-Daten vom DSP abholen
ap_sam_clc_lp:
		move.w	#0,d0					;Schleifenanzahl holen
ap_dspcopy_to_pcmbuf:				
	REPEAT
 		move.w	(a3),(a0)+				;vorberechnete Daten in den Puffer
	UNTIL	#31
		subq.w	#1,d0
		bgt.s	ap_dspcopy_to_pcmbuf		
ap_dsp_copy_jmp:
		bra.s	*+0						;Aussprung
	REPEAT
		move.w	(a3),(a0)+
	UNTIL	#31
	REPEAT
		move.w	-2(a0),(a0)+			;Knacksen verhindern
	UNTIL	#7	
ap_ssi_do_it:
		lea		DFF0A0(pc),a0			;Stimme 1 Basisadr.
		moveq	#0,d1					;DMA-Bit 0
		bsr.s	ap_compute_voice
		lea		DFF0B0(pc),a0			;Stimme 2 Basisadr.
		moveq	#1,d1					;DMA-Bit 1
		bsr.s	ap_compute_voice
		lea		DFF0C0(pc),a0			;Stimme 3 Basisadr.
		moveq	#2,d1					;DMA-Bit 2
		bsr.s	ap_compute_voice
		lea		DFF0D0(pc),a0			;Stimme 4 Basisadr.
		moveq	#3,d1					;DMA-Bit 3
		bsr.s	ap_compute_voice

		bsr		ap_playmusic			;Proplayer
		move.w	cacr_rett(pc),d0
		movec	d0,cacr					;CACR zurcksetzen
		rts
	DATA
cacr_rett:	dc.w	0
	TEXT
ap_compute_voice:
		moveq	#0,d0
		move.w	(a3),d0					;Anzahl der tats„chlich bearb. Bytes holen

		btst	d1,dff096+1(pc)			;DMA-Bit an?
		beq.s	ap_compute_dum_sample	;an >> Sample abarbeiten
		tst.b	(a0)					;wurde neues Sample eingetragen?
		bmi.s	ap_no_new_sample
;neues Sample im Anmarsch
		moveq	#0,d0					;Anzahl l”schen da Samplebeginn erforderlich
		st		(a0)					;Sampleadr. markieren
;altes Sample wird weiterbearbeitet
ap_no_new_sample:
		move.l	(a0),a2					;akt. Sampleadr. holen
		add.w	d0,a2					;+Sample-Anzahl >> neue Sampleadr.
		asr.w	#1,d0					;/2
		moveq	#0,d7
		move.w	4(a0),d7				;akt. Samplel„nge holen
		sub.l	d0,d7					;Samplel„nge verringern>> neue Samplel„nge
		bgt.s	ap_compute_sample		;noch >0 >> Sampleende nicht erreicht

;Test auf Samplerepeat
		move.l	d7,d6
		move.w	14(a0),d7				;Repeatl„nge holen
		cmp.w	#1,d7					;L„nge<=1 >> Sample zuende
		bhi.s	ap_sample_repeat
ap_no_sample_repeat:  
		st		10(a0)					;markieren
		move.l	10(a0),a2				;Loopadr. holen
		bra.s	ap_compute_sample
ap_sample_repeat:
		st		10(a0)					;Sampleadr. markieren
		move.l	10(a0),a2				;Repeatsampleadr. holen
		neg.l	d6						;neg. Restsamplel„nge >> positiv
		divu.w	d7,d6					;Repeatl„nge/Restsamplel„nge
		swap	d6						;Rest holen 
		ext.l	d6
		sub.w	d6,d7					;Samplel„nge-bereits abgespielte Bytes
		lea		(a2,d6.l*2),a2			;zur Repeatadr.
ap_compute_sample:
		move.l	a2,(a0)+				;neue Sampleadr. speichern
		move.w	d7,(a0)+				;neue Samplel„nge speichern
		move.w	(a0)+,d1				;Periode holen
		move.w  (a0)+,d0				;Lautst„rke holen

		cmp.w	#1,d7					;Samplel„nge<=1?
		bhi.s	ap_no_dummy_sample
		cmp.w	#1,14-10(a0)			;Repeatl„nge auch =1?
   		bhi.s	ap_no_dummy_sample
ap_compute_dum_sample:
		lea		ap_dum_sample(pc),a2	;Leersampleadr.
		move.w	#107,d1					;Sonderperiode
		moveq	#0,d0					;Lautst„rke 0
ap_no_dummy_sample:	
		mulu.w	main_voice(pc),d0		;*frakt. Hauptlautst„rke
		swap	d0						;ganzzahliger Wert holen 
		move.l	(ap_vol_tab.w,PC,d0.w*4),4(a1) ;Lautst„rkewert in den DSP
		move.l	(ap_freq_tab-107*8.w,PC,d1.w*8),4(a1) ;ganzzahliger Offset an den DSP
		move.l	(ap_freq_tab+4-107*8.w,PC,d1.w*8),4(a1) ;fraktionaler Offset an den DSP
		move.w	(ap_samclc_tab-107*2.w,PC,d1.w*2),d0	;Samplebytesanzahl die zu senden sind holen
		clr.b	5(a1)					;oberstes Byte reinigen
  		move.w	d0,(a3)					;Transferanzahl senden
		move.w	(a2)+,(a3)				;1 Wort senden
		subq.w	#1,d0					;-1
		beq.s	ap_copy_sample_to_dsp_end	;falls nur 1 Samplewort >> Ende
		move.w	d0,d1
		asr.w	#5,d0					;/32
		and.w	#$1f,d1
		lea		(ap_rts_set.w,PC,d1.w*2),a0	;RTS-Adr. bestimmen
		move.w	#$4e75,(a0)				;RTS setzen
		move.w	#$3919,d2				;Instruktionscache
		movec	d2,cacr             	;l”schen
		bsr.s	ap_copy_sample_to_dsp
		move.w	#$369a,(a0)				;move.w (a2)+,(a3) setzen
ap_copy_sample_to_dsp_end:
		rts	
ap_copy_sample_to_dsp:
	REPEAT
		move.w	(a2)+,(a3)				;Samples in den DSP
	UNTIL	#31
		subq.w	#1,d0
		bgt	ap_copy_sample_to_dsp
ap_rts_set:
	REPEAT
		move.w	(a2)+,(a3)				;restliche Samples in den DSP
	UNTIL	#31
		rts

	DATA
ap_pcm_buf_adr:	dc.l ap_pcm_play,ap_pcm_calc
ap_dum_sample:	dc.l	$80808080		;Dummysample fr Kanalabschaltung

ap_pcm_play:	ds.w	983+8			;Puffer fr 
ap_pcm_calc:	ds.w	983+8			;die Stereodaten
ap_pcm_buf_end:

*****************************************************************************
;Hauptinstallation des Players
*****************************************************************************
;a0.l: Moduladr.
;a1.l: Timer-A-IRQ-Adr. bei d2=-1
;d0.w: Prescalewert (1-5/7)
;d1.w: =0 = Hostversion / -1 = SSI-Version anw„hlen
;d2.w: =0 = 50Hz-VBL / -1 = IRQ-7
	TEXT
ap_grand_init:
		move.l	a0,a6
		move.w	d1,ap_ssi_flag			;gleich speichern
		move.w	d2,ap_irq_flag
		moveq	#0,d1
		move.w	(ap_sampling_tab-2.w,PC,d0.w*2),d1	;Abspielfrequenz holen
		move.l	d1,ap_play_rate			;und speichern
		divu.w	#50,d1					;/ VBL-Frequenz
		ext.l	d1
		move.l	d1,ap_sam_clc			;Sampleworte pro VBL	
;Schleife fr die Stereodaten modifizieren
		tst.w	ap_ssi_flag(pc)			;SSI angew„hlt?
		bne.s	ap_ssi_no_code_mod
;im Hostbetrieb Code modifizieren
		move.w	d1,d6
		asr.w	#5,d6					;/32 
		move.w	d6,ap_sam_clc_lp+2		;Schleifenanzahl speichern
		and.w	#$1f,d1             	;MOD 32 holen
		eor.w	#$1f,d1             	;invertieren
		add.w	d1,d1					;*2
		addq.w	#2,d1             	  	;+2 da bra.s
		move.b	d1,ap_dsp_copy_jmp+1	;Branch modifizieren
ap_ssi_no_code_mod:
	DATA
ap_ssi_flag:	dc.w	0				;SSI-Flag
ap_irq_flag:	dc.w	0				;IRQ-Flag
ap_sam_clc:		dc.l	0				;Anzahl der Sampleworte pro VBL
ap_play_rate:	dc.l	0				;Abspielfrequenz des Players
ap_sampling_tab:
		dc.w	49150				;50 Khz
		dc.w	32750				;33 KHz
		dc.w	24600				;25 KHz
		dc.w	19650				;20 KHz
		dc.w	16400				;16 KHz
		dc.w	12300				;unzul„ssig
		dc.w	12300				;12 KHz
*****************************************************************************
	TEXT
ap_install_pcm:
		lea		$ffff8900.w,a2			;PCM-Basisadr.
		clr.w	(a2)					;IRQs aus/DMA stop
		clr.w	$20(a2)					;8 Bit/stereo
		move.w	$34(a2),d7				;Prescale holen
		and.w	#$ff00,d7
		and.w	#$7,d0
		or.w	d0,d7					;KHz-Rate setzen
		move.w	d7,$34(a2)
		bset	#2,$37(a2)				;Input vom Multiplexer
		clr.w	$3a(a2)					;volle Lautst„rke
		move.w	#-1,main_voice			;volle Lautst„rke
		tst.w	ap_ssi_flag(pc)			;SSI-Version?
		bne.s	ap_ssi_soundh_set

;Soundsystem fr Hostbetrieb vorbereiten
		move.w	$30(a2),d7				;Device-Prescale holen
		and.w	#$fff0,d7
 		or.w	#%1001,d7				;kein Handshake/25.175 MHz-Rate
		move.w	d7,$30(a2)
		move.w	$32(a2),d7				;Destination holen
		and.w	#$0fff,d7				;Source: DMA
		move.w	d7,$32(a2)
		move.l	#ap_pcm_buf_end,d7		;Endadresse
		movep.w	d7,$11(a2)				;Lowbyte/Midbyte
		swap	d7
		move.b	d7,$f(a2)				;Highbyte
		lea		ap_dsp_paula_host(pc),a0
		bsr		dsp_system+4			;DSP-Paula im Hostbetrieb
		bra		ap_calc_freq

;Soundsystem fr SSI-Betrieb vorbereiten
ap_ssi_soundh_set:
		move.w	$30(a2),d7				;Device-Prescale holen
		and.w	#$ff0f,d7
 		or.w	#$90,d7					;kein Handshake/25.175 MHz-Rate
 										;kein Tri-State
		move.w	d7,$30(a2)
		move.w	$32(a2),d7				;Destination holen
		and.w	#$0f7f,d7				;>> DSP-REC auf Tri-State
		or.w	#$2000,d7				;Source: DSP-XMIT
		move.w	d7,$32(a2)
		lea		ap_dsp_paula_ssi(pc),a0
		bsr		dsp_system+4			;DSP-Paula im Hostbetrieb
*****************************************************************************
;Berechnung	der	Frequenztabelle
	TEXT
ap_calc_freq:
		lea		ap_freq_tab(pc),a2		;Frequenztabelle
		lea		ap_samclc_tab(pc),a3
		clr.l	(a2)+					;Periode 107 >> Leersample
		clr.l	(a2)+                   ;Offset auf 0
		move.w	#1,(a3)+				;nur 1 Samplewort an den DSP

		moveq	#108,d7					;mit Periode 108 beginnen
ap_calc_freq_do:
		move.l	#3579546,d2				;Halbe Taktfrequenz	des	Amigas
		divu.l	d7,d2					;/Paula-Timerwert>>	Spielfrequenz
		move.l	d2,d3
		lsr		#8,d2					;oberes	Byte ins untere
		swap	d3						;mittleres Byte
		lsl.l	#8,d3					;ins oberste >>	d2:	Highbyte
										;				d3:	Lowbyte
		divu.l	ap_play_rate(pc),d2:d3	;64-Bit/32-Bit
		move.l	d3,d2
		rol.l	#8,d2					;Highbyte holen	>> Vorkommawert
		and.l	#$ff,d2
		move.l	d2,(a2)+				;Vorkommawert speichern
		mulu.w	ap_sam_clc+2(pc),d2		;*Samplebyteanzahl pro VBL
		and.l	#$00ffffff,d3			;Nachkommawert in 24-Bit holen
		move.l	d3,(a2)+				;und speichern
		rol.l	#8,d3
		mulu.l	ap_sam_clc(pc),d4:d3	;*Samplebyteanzahl pro VBL
		add.l	d4,d2					;+
		asr.w	#1,d2					;/2	>> da Wortbertragung
		addq.w	#2,d2					;2 Worte mehr >> Sicherheit
		move.w	d2,(a3)+				;und speichern
		addq.w	#1,d7					;Periode erh”hen
		cmp.w	#907+1,d7
		bne.s	ap_calc_freq_do
	DATA
ap_freq_tab:	ds.l	2*(907-107+1)
ap_samclc_tab:	ds.w	(907-107+1)
*****************************************************************************
;Volumeberechnung
	TEXT
ap_calc_vol:
		lea		ap_vol_tab(pc),a2		;Volumetabelle
		moveq	#65-1,d7				;noch 64 Volume-Abstufungen
		moveq	#64,d5					;mit Lautst„rkewert 1 beginnen
		move.l	#$800000/2,d6			;0.999999/2 
		tst.w	ap_ssi_flag(pc)			;SSI-Version?
		beq.s	ap_calc_vol_host
		move.l	#$8000/2,d6				;0.99999/2 auf 16 Bit
ap_calc_vol_host:
		divu.l	d5,d6                   ;/Lautst„rkeskala (64 Stufen)
		moveq	#0,d5
ap_calc_vol_do:
       	move.l  d5,(a2)+				;Lautst„rkewert als Kommawert
       	add.l	d6,d5
       	dbra	d7,ap_calc_vol_do
	DATA
ap_vol_tab:	ds.l	65					;65 Volume-Abstufungen
*****************************************************************************
	TEXT
ap_wait_to_host:
		btst	#1,$ffffa202.w			;auf DSP warten
		beq.s	ap_wait_to_host
		move.l	ap_sam_clc(pc),$ffffa204.w 	;Samplebyteanzahl an den DSP
*****************************************************************************
		pea		(a1)
		bsr		ap_mod_init				;Modul installieren
		move.l	(sp)+,a1
*****************************************************************************
ap_handle_irq:
		tst.w	ap_irq_flag(pc)			;50Hz-VBL oder IRQ-7?
		beq.s	ap_vbl_handle
		clr.b	$fffffa19.w
		move.l	a1,$134.w				;Timer-A-Vektor
		bset	#5,$fffffa07.w			;IER
		bset	#5,$fffffa13.w			;IMR
		bclr	#3,$fffffa17.w			;EOI
		move.b	#245,$fffffa1f.w		;Timer-Wert
		move.b	#$7,$fffffa19.w			;Vorteiler 1:200
										;>> Timer-A wird alle 1/50s aufgerufen
ap_vbl_handle:
		rts
*****************************************************************************
	TEXT
ap_small_deinit:
		clr.w	main_voice				;Hauptlautst„rke auf 0
		tst.w	ap_irq_flag(pc)
		beq.s	ap_no_irq
		bclr	#5,$fffffa07.w			;IER
		bclr	#5,$fffffa13.w			;IMR
		clr.b	$fffffa19.w				;Timer-Stop
ap_no_irq:
		tst.w	ap_ssi_flag(pc)			;SSI-Version?
		bne.s	ap_ssi_deinstall
		clr.w	$ffff8900.w				;DMA stoppen
		rts
ap_ssi_deinstall:
		bclr	#7,$ffff8931.w			;DSP-XMIT auf Tristate
		rts
*****************************************************************************
;Paula-Pseudoregister
	DATA 
DFF096:		dc.w $0000		;Amiga:DMA-Controlregister
DFF0A0:		dc.l $00000000	;Amiga:Adressregister ¯¯ Audio-Kanal 1 ®®
DFF0A4:		dc.w $0000		;Amiga:Sample-L„nge
DFF0A6:		dc.w $0000		;Amiga:Abtastfrequenz
DFF0A8:		dc.w $0000		;Amiga:Lautst„rke
DFF0AA:		dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0AE:		dc.w $0000		;XXXXX:Pseudo-Loop-L„nge

DFF0B0:		dc.l $00000000	;Amiga:Adressregister ¯¯ Audio-Kanal 2 ®®
DFF0B4:		dc.w $0000		;Amiga:Sample-L„nge
DFF0B6:		dc.w $0000		;Amiga:Abtastfrequenz
DFF0B8:		dc.w $0000		;Amiga:Lautst„rke
DFF0BA:		dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0BE:		dc.w $0000		;XXXXX:Pseudo-Loop-L„nge

DFF0C0:		dc.l $00000000	;Amiga:Adressregister ¯¯ Audio-Kanal 3 ®®
DFF0C4:		dc.w $0000		;Amiga:Sample-L„nge
DFF0C6:		dc.w $0000		;Amiga:Abtastfrequenz
DFF0C8:		dc.w $0000		;Amiga:Lautst„rke
DFF0CA:		dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0CE:		dc.w $0000		;XXXXX:Pseudo-Loop-L„nge

DFF0D0:		dc.l $00000000	;Amiga:Adressregister ¯¯ Audio-Kanal 4 ®®
DFF0D4:		dc.w $0000		;Amiga:Sample-L„nge
DFF0D6:		dc.w $0000		;Amiga:Abtastfrequenz
DFF0D8:		dc.w $0000		;Amiga:Lautst„rke
DFF0DA:		dc.l $00000000	;XXXXX:Pseudo-Loop-Adressregister
DFF0DE:		dc.w $0000		;XXXXX:Pseudo-Loop-L„nge
*****************************************************************************
	DATA
ap_dsp_paula_host:
			path "d:\source\dsppaula\"
			inline "dsppauv1.ads"		;DSP-Paula im Hostbetrieb
ap_dsp_paula_ssi:
			path "d:\source\dsppaula\"
			inline "dsppauv2.ads"		;DSP-Paula im SSI-Betrieb
*****************************************************************************
	TEXT
			path "D:\source\dsppaula\"
			include	"pro__30b.q"		;Proplayer
*****************************************************************************
	DATA
	IFNE	example=-1
module:		path "e:\mods\new_soun.d"
			inline "reach_te.mod"
	ENDIF
*****************************************************************************

		end