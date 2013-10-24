;****************************************************************************
;*******************    D S P - P A U L A - SSI-Version   *******************
;****************  coded by Chris of AURA of the INEPENDENT  ****************
;****************  thanx to Bitmaster and Questor of Inter   ****************
;************************ for the great information *************************
;****************************************************************************
;***************   first code  : 14.04.93					  ***************
;***************   last changes: 20.02.94					  ***************
;****************************************************************************

;wichtige Hinweise:
;die DSP-Paula darf nur komplett im Y-Ram betrieben werden.
;Hostcommand $13 wird durch die DSP-Paula belegt-
;es werden insgesamt 2 StackeintrÑge benîtigt-
;
;History:
;V21: Neue Berechnungs- und Protokolverfahren zur UnterstÅtzung
;     der Echtzeitpaula
;
dsp_paula_start:	equ $4000-8300  ;Startadr. des DSP-Paulacodes

v_hz:		equ	48					;VBL-Frequenz
sam_bufcnt:	equ	45000/v_hz			;max. BytedurchsatzpufferlÑnge pro VBL
									;Erfahrungswert
		opt cc
;*********************************************************************
;r7: Stereopufferadresse
		org		P:$10				;SSI-Transmit
		movep	Y:(r7)+,X:<<$ffef	;1 Monosamplewort rÅber
		org		P:$12				;SSI-Transmit with Exception
		movep	Y:(r7)+,X:<<$ffef	;1 Monosamplewort rÅber
;*********************************************************************
;Vektor fÅr Hostcommand 1 setzen
		org		P:$26				;Hostcommandvektor 1
		jsr		dsp_paula
;*********************************************************************		
		org		P:dsp_paula_start

install_paula:
		clr		a
		move	a1,P:voice1_par+3		;Restoffset
		move	a1,P:voice1_par+4		;auf 0,0
		move	a1,P:voice1_par+5		;1. 2 Bytes
		move	a1,P:voice1_par+6		;lîschen
		move	a1,P:voice2_par+3		;Restoffset
		move	a1,P:voice2_par+4		;auf 0,0
		move	a1,P:voice2_par+5		;1. 2 Bytes
		move	a1,P:voice2_par+6		;lîschen
		move	a1,P:voice3_par+3		;Restoffset
		move	a1,P:voice3_par+4		;auf 0,0
		move	a1,P:voice3_par+5		;1. 2 Bytes
		move	a1,P:voice3_par+6		;lîschen
		move	a1,P:voice4_par+3		;Restoffset
		move	a1,P:voice4_par+4		;auf 0,0
		move	a1,P:voice4_par+5		;1. 2 Bytes
		move	a1,P:voice4_par+6		;lîschen

		move	#stereo1_trk,r0			;Stereopuffer
		move	#>1050*2*2,x0
		rep		x0
		move	a,Y:(r0)+				;lîschen

		bset	#13,X:<<$ffff
		bset	#12,X:<<$ffff			;SSI auf Prio 3
		movep	#$01f8,X:<<$ffe1		;PCC: alle SSI-Ports auf seriell
		movep	#$0000,X:<<$ffe3		;PCDDR setzen: alles 'in'
		movep	#$4100,X:<<$ffec		;CRA setzen: 16 Bit/ 2 Worte 
										;pro Frame
		movep	#$4a00,X:<<$ffed		;CRB setzen: Transmitter-IRQ an
										;Network/syncron....
		move	#$ffff,m7
infinity:
		jmp		infinity

;*********************************************************************
dsp_paula:
;vorberechnete Stereodaten an den Host
		andi	#$fc,mr
		ori		#$2,mr					;auf Prio 2 gehen
		bclr	#3,X:<<$ffe8			;HF2 lîschen

		move	r0,P:save_reg
		move	#save_reg+1,r0
		move	m0,P:save_reg+23
		movec	#$ffff,m0
		nop
		move	r1,Y:(r0)+				;Adressregister
		move	r2,Y:(r0)+
		move	r3,Y:(r0)+
		move	r4,Y:(r0)+
		move	n0,Y:(r0)+
		move	n1,Y:(r0)+				;Offsetregister
		move	n2,Y:(r0)+
		move	n4,Y:(r0)+
		move	m1,Y:(r0)+				;Modifierreg.
		move	m2,Y:(r0)+
		move	m3,Y:(r0)+
		move	m4,Y:(r0)+
		move	x0,Y:(r0)+				;Arithmetikregister
		move	x1,Y:(r0)+
		move	y0,Y:(r0)+
		move	y1,Y:(r0)+
		move	a2,Y:(r0)+
		move	a1,Y:(r0)+
		move	a0,Y:(r0)+
		move	b2,Y:(r0)+
		move	b1,Y:(r0)+
		move	b0,Y:(r0)+	
		movec	m0,m1
		movec	m0,m2					;setzen
		movec	m0,m3
		movec	m0,m4


		bset	#12,X:<<$ffed			;SSI-IRQ starten

										;auf Frame-Sync warten

		jset	#2,X:<<$ffee,*			;auf aufst. Flanke warten
		jclr	#2,X:<<$ffee,*			;auf abst. Flanke warten
		jset	#2,X:<<$ffee,*			;auf aufst. Flanke warten

		nop								;keine Ahnung-NOPs
		nop
		nop
		nop
				
		move	P:stereo_puf_adr,r7		;1. Pufferadr. holen
		move	P:stereo_puf_adr+1,r4	;2. Pufferadr. holen
		move	r7,P:stereo_puf_adr+1	;vertauschen
		move	r4,P:stereo_puf_adr		;r7 >> akt. Abspieladresse

		bset	#3,X:<<$ffe8			;HF2 setzen >> DSP-Paula am Werk

		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,Y:sam_clc		;Samplebyteanzahl holen
				
;Samples der 4 Stimmen holen
		move	#voice1_par,r0
		jsr		get_sample_data			;Sampledaten holen

		move	#voice2_par,r0			;2. Stimme
		jsr		get_sample_data			;Sampledaten holen

		move	#voice3_par,r0			;3. Stimme
		jsr		get_sample_data			;Sampledaten holen

		move	#voice4_par,r0			;4. Stimme
		jsr		get_sample_data			;Sampledaten holen

;Stimmen mischen
;r4: akt. Berechnungspufferadr.
		move	#<$2,n1					;Monooffset
		move	#voice2_par,r0			;Puffer der 2. Stimme
		move	r4,r1
		jsr		calc_one_voice			;berechnen

		move	#voice3_par,r0			;Puffer der 3. Stimme
		move	r4,r1
		jsr		mix_one_voice			;berechnen und dazumischen

		move	#voice1_par,r0			;Puffer der 1. Stimme
		lua		(r4)+,r1				
		jsr		calc_one_voice			;berechnen

		move	#voice4_par,r0			;Puffer der 4. Stimme
		lua		(r4)+,r1				
		jsr		mix_one_voice			;berechnen und dazumischen


		move	#save_reg+1,r0
		nop
		move	Y:(r0)+,r1				;Adressregister
		move	Y:(r0)+,r2
		move	Y:(r0)+,r3
		move	Y:(r0)+,r4
		move	Y:(r0)+,n0
		move	Y:(r0)+,n1				;Offsetregister
		move	Y:(r0)+,n2
		move	Y:(r0)+,n4
		move	Y:(r0)+,m1				;Modifierreg.
		move	Y:(r0)+,m2
		move	Y:(r0)+,m3
		move	Y:(r0)+,m4
		move	Y:(r0)+,x0				;Arithmetikregister
		move	Y:(r0)+,x1
		move	Y:(r0)+,y0
		move	Y:(r0)+,y1
		move	Y:(r0)+,a2
		move	Y:(r0)+,a1
		move	Y:(r0)+,a0
		move	Y:(r0)+,b2
		move	Y:(r0)+,b1
		move	Y:(r0)+,b0	
		move	Y:(r0)+,m0				;Modifierreg.
		move	P:save_reg,r0

		bclr	#3,X:<<$ffe8			;HF2 lîschen >> DSP nun frei
		rti
;***************************************
;Berechnet 1 Spur ohne mischen
;r0: Parameteradr. des Samples
;r1: Stereopufferadr.
calc_one_voice:
		move	Y:(r0)+,y1				;LautstÑrke holen
		move	Y:(r0)+,x1				;Sample-Vorkommaoffset holen
		move	Y:(r0)+,x0				;Sample-Nachkommaoffset holen
		move	r0,r3
		move	Y:(r0)+,b				;Restvorkomma holen
		move	Y:(r0)+,b0				;Restnachkomma holen
		move	r0,y0					;Sampleadr. 
		add		y0,b	r0,n0			;+,Sampleadr. retten
		move	b1,r0					;Startadr. im Samplepuffer
        move	P:sam_clc,y0			;Anzahl holen
        
		do		y0,calc_one_voice_do
		add		x,b		Y:(r0),y0		;Sampleoffset addieren
										;Samplebyte holen
		mpy		y1,y0,a		b1,r0		;*LautstÑrke,neue Sampleadr. holen	
		move	a0,Y:(r1)+n1			;und speichern
calc_one_voice_do:

		move	n0,x0					;Samplestart holen
		sub		x0,b					;- akt. Sampleposition
		move	b1,x0
		bclr	#0,x0					;auf Wort abrunden
		sub		x0,b					;- >> Restoffset errechnen
		move	b1,Y:(r3)+				;und fÅr nÑchsten VBL speichern		
		move	b0,Y:(r3)

;letzte 2 Bytes an den Anfang kopieren
		move	n0,a
		add		x0,a					;+auf Wort abger. Offset
		move	a,r0
		move	n0,r3					;Samplestartadr. holen
		move	Y:(r0)+,a
		move	a,Y:(r3)+				;1. Byte
		move	Y:(r0)+,a
		move	a,Y:(r3)+				;2. Byte umkopieren
		rts
;***************************************
;Berechnet 1 Spur mit mischen
;r0: Pufferadr. des Samples
;r1: Stereopufferadr.
mix_one_voice:
		move	Y:(r0)+,y1				;LautstÑrke holen
		move	Y:(r0)+,x1				;Sample-Vorkommaoffset holen
		move	Y:(r0)+,x0				;Sample-Nachkommaoffset holen
		move	r0,r3
		move	Y:(r0)+,b				;Restvorkomma holen
		move	Y:(r0)+,b0				;Restnachkomma holen
		move	r0,y0					;Sampleadr. 
		add		y0,b	r0,n0			;+,Sampleadr. retten
		clr		a		b1,r0			;Startadr. im Samplepuffer
 		move	P:sam_clc,y0			;Anzahl

		do		y0,mix_one_voice_do
		add		x,b		Y:(r0),y0		;Sampleoffset addieren
										;Samplebyte holen
		move	Y:(r1),a0				;zuvor berechn. Samplewert holen
		mac		y1,y0,a		b1,r0		;*LautstÑrke,neue Sampleadr. holen	
		clr		a	a0,Y:(r1)+n1		;und speichern
mix_one_voice_do:
		move	n0,x0					;Samplestart holen
		sub		x0,b					;- akt. Sampleposition
		move	b1,x0
		bclr	#0,x0					;auf Wort abrunden
		sub		x0,b					;- >> Restoffset errechnen
		move	b1,Y:(r3)+				;und fÅr nÑchsten VBL speichern		
		move	b0,Y:(r3)

;letzte 2 Bytes an den Anfang kopieren
		move	n0,a
		add		x0,a					;+auf Wort abger. Offset
		move	a,r0
		move	n0,r3					;Samplestartadr. holen
		move	Y:(r0)+,a
		move	a,Y:(r3)+				;1. Byte
		move	Y:(r0)+,a
		move	a,Y:(r3)+				;2. Byte umkopieren
		rts
;***************************************
;LÑd LautstÑrke und Sample in den Y-Speicher
;Sampledaten von 0 bis 255
;r0: Parameteradr. des Sampels
get_sample_data:
		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,Y:(r0)+			;LautstÑrke holen
		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,x1				;Schrittweite Vorkomma holen
		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,a1				;Schrittweite Nachkomma holen
		move	x1,Y:(r0)+					;Vorkomma speichern
		move	a1,Y:(r0)+					;Nachkomma speichern

		move	Y:sam_clc,y1				;Anzahl der zu berechn. Samplebytes pro VBL
		lsr		a							;logisch /2	>> da MSB Vorzeichenbit weg muû
		move	a1,x0						;Nachkommawert nach x0
		
		move	Y:(r0)+,a					;Restvorkomma holen
		move	Y:(r0)+,a0					;Restnachkomma holen

		mac		y1,x0,a						;Anzahl Samplebytes * Nachkomma
		mpy		y1,x1,b						;Anzahl Samplebytes * Vorkomma
		asr		b							;noch /2 da Kommaverschiebung
		move	b0,y0
		add		y0,a						;dazuaddieren
		asr		a							;/2 da WortÅbertragung		
		move	a1,a						;nach b mit Erweiterung auf 56 Bit
		
		jclr	#1,X:<<$ffe9,*
		movep	a1,X:<<$ffeb				;zu Åbertragende Worte senden 

		tst		a		#<2,n0				;a1= 0 Worte?
		jeq		load_sample					;dann nichts laden

		lua		(r0)+n0,r0					;2 Bytes vorspringen
		move	#>$10000/2,x0				;Verschiebungswert durch mpy
		move	#>128,x1					;Subr.Wert
		move	#>$0000FF,y1				;Ausmaskierungswert
		do		a1,load_sample
		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,y0				;2 8-bit-Samplewerte holen
;wichtig: oberstes Byte muû null sein
		mpy		x0,y0,a						;oberes Byte nach a1 schieben
		sub		x1,a						;-128
		move	y0,a	a,Y:(r0)+			;und speichern
		and		y1,a						;unteres Byte holen
		sub		x1,a						;-128
		move	a,Y:(r0)+					;unteres Byte speichern		
load_sample:
		rts
;***************************************
save_reg:	ds	25							;Platz fÅr die Register
sam_clc:	ds	1							;Anzahl der zu ber. Samplebytes in 2er-Schritten
stereo_puf_adr:
			dc	stereo1_trk,stereo2_trk
;Parameter und Puffer fÅr die Samples
voice1_par:	
;LautstÑrke als Fraktionalwert (zw. 0 und 1)
			ds	1							;LautstÑrke als Kommawert
											;vom Host pro VBL Åbermittelt
;Schrittweite innerhalb des Samples
			ds	2							;Sampleoffset (48 Bit)
;Da der Samplepuffer nie vollstÑndig abgearbeitet wird, bleibt ein Rest
;Åbrig der das nÑchste Mal zur voice_buf-Adr. dazuaddiert werden muû.
			ds	2							;Restoffset von der letzten Berechnung
voice1_buf:	ds	sam_bufcnt					;Puffer der Sampledaten

voice2_par: ds	5
voice2_buf:	ds	sam_bufcnt					;Puffer der Sampledaten
voice3_par: ds	5
voice3_buf:	ds	sam_bufcnt					;Puffer der Sampledaten
voice4_par: ds	5
voice4_buf:	ds	sam_bufcnt					;Puffer der Sampledaten


;****************************************
;Stereopuffer, 2 Spuren gemischt
stereo1_trk:	ds	1050*2					;Stereopuffer 1
stereo2_trk:	ds	1050*2					;Stereopuffer 2
;****************************************
end:

		end		dsp_paula_start			;Installierung starten