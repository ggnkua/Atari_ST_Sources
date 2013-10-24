;****************************************************************************
;*******************    D S P - P A U L A - SSI-Version   *******************
;****************  coded by Chris of AURA of the INEPENDENT  ****************
;****************  thanx to Bitmaster and Questor of Inter   ****************
;************************ for the great information *************************
;****************************************************************************
;***************   first code  : 14.04.93					  ***************
;***************   last changes: 12.05.93					  ***************
;****************************************************************************

;wichtige Hinweise:
;die DSP-Paula darf nur komplett im Y-Ram betrieben werden.
;Hostcommand $13 wird durch die DSP-Paula belegt-
;es werden insgesamt 2 StackeintrÑge benîtigt-

dsp_paula_start:	equ $4000-7100  ;Startadr. des DSP-Paulacodes

v_hz:		equ	50					;VBL-Frequenz
sam_bufcnt:	equ	33300/v_hz			;max. BytedurchsatzpufferlÑnge pro VBL
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
		move	a1,P:voice1_par			;Stimme 1-Parameter setzen
		move	a1,P:voice1_par+4		;Restoffset
		move	a1,P:voice1_par+5		;auf 0,0
		move	a1,P:voice2_par			;Stimme 2-Parameter setzen
		move	a1,P:voice2_par+4		;Restoffset
		move	a1,P:voice2_par+5		;auf 0,0
		move	a1,P:voice3_par			;Stimme 3-Parameter setzen
		move	a1,P:voice3_par+4		;Restoffset
		move	a1,P:voice3_par+5		;auf 0,0
		move	a1,P:voice4_par			;Stimme 4-Parameter setzen
		move	a1,P:voice4_par+4		;Restoffset
		move	a1,P:voice4_par+5		;auf 0,0

		move	#sam_clc,r1
		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,Y:(r1)		;Samplebyteanzahl holen

		move	#stereo1_trk,r0			;Stereopuffer
		rep		#1000*2*2
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

		move	P:sam_clc,x0			;Sampleanzahl holen
		move	r4,a
		add		x0,a
		add		x0,a
		move	a,r4					;r4: Samplepufferende
		move	#>1,n4
		do		#16,knacken_kill
		move	Y:(r4)+,x0              ;8 Worte kopieren
		move	x0,Y:(r4+n4)			;dadurch Knacken verhindern
knacken_kill:		

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
		lua		(r0)+,r2				;1 Eintrag Åberspringen
		nop								;Pipeline-NOP
		move	Y:(r2)+,y1				;LautstÑrke holen
		move	Y:(r2)+,x1				;Sample-Vorkommaoffset holen
		move	Y:(r2)+,x0				;Sample-Nachkommaoffset holen
		move	r2,r3
		move	Y:(r2)+,b				;Restvorkomma holen
		move	Y:(r2)+,b0				;Restnachkomma holen
		move	r2,y0					;Sampleadr. 
		add		y0,b	r2,n2			;+,Sampleadr. retten
		move	b1,r2					;Startadr. im Samplepuffer
        move	P:sam_clc,y0			;Anzahl holen
        
		do		y0,calc_one_voice_do
		add		x,b		Y:(r2),y0		;Sampleoffset addieren
										;Samplebyte holen
		mpy		y1,y0,a		b1,r2		;*LautstÑrke,neue Sampleadr. holen	
		move	a0,Y:(r1)+n1			;und speichern
calc_one_voice_do:

		move	n2,x0					;Samplestart holen
		sub		x0,b					;- akt. Sampleposition
		move	b1,x0
		bclr	#0,x0					;auf Wort abrunden
		move	x0,Y:(r0)				;und speichern
		sub		x0,b					;- >> Restoffset errechnen
		move	b1,Y:(r3)+				;und fÅr nÑchsten VBL speichern		
		move	b0,Y:(r3)
		rts
;***************************************
;Berechnet 1 Spur mit mischen
;r0: Pufferadr. des Samples
;r1: Stereopufferadr.
mix_one_voice:
		lua		(r0)+,r2				;1 Eintrag Åberspringen
		nop								;Pipeline-NOP
		move	Y:(r2)+,y1				;LautstÑrke holen
		move	Y:(r2)+,x1				;Sample-Vorkommaoffset holen
		move	Y:(r2)+,x0				;Sample-Nachkommaoffset holen
		move	r2,r3
		move	Y:(r2)+,b				;Restvorkomma holen
		move	Y:(r2)+,b0				;Restnachkomma holen
		move	r2,y0					;Sampleadr. 
		add		y0,b	r2,n2			;+,Sampleadr. retten
		move	b1,r2					;Startadr. im Samplepuffer
 		move	P:sam_clc,y0			;Anzahl
		clr		a						;a lîschen

		do		y0,mix_one_voice_do
		add		x,b		Y:(r2),y0		;Sampleoffset addieren
										;Samplebyte holen
		move	Y:(r1),a0				;zuvor berechn. Samplewert holen
		mac		y1,y0,a		b1,r2		;*LautstÑrke,neue Sampleadr. holen	
		clr		a	a0,Y:(r1)+n1		;und speichern
mix_one_voice_do:

		move	n2,x0					;Samplestart holen
		sub		x0,b					;- akt. Sampleposition
		move	b1,x0
		bclr	#0,x0					;auf Wort abrunden
		move	x0,Y:(r0)				;und speichern
		sub		x0,b					;- >> Restoffset errechnen
		move	b1,Y:(r3)+				;und fÅr nÑchsten VBL speichern		
		move	b0,Y:(r3)
		rts
;***************************************
;LÑd LautstÑrke und Sample in den Y-Speicher
;Sampledaten von 0 bis 255
;r0: Parameteradr. des Sampels
get_sample_data:
		jclr	#1,X:<<$ffe9,*
		movep	Y:(r0)+,X:<<$ffeb			;TatsÑchlich bearb. Bytes senden
		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,Y:(r0)+			;LautstÑrke holen
		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,Y:(r0)+			;Schrittweite Vorkomma holen
		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,Y:(r0)+			;Schrittweite Nachkomma holen

		move	#<2,n0
		nop									;Pipeline-NOP
		lua		(r0)+n0,r0					;Restwert Åberspringen

		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,y0				;Anzahl der zu Åbertr. Worte holen

		move	#>$10000/2,x0				;Verschiebungswert durch mpy
		move	#>128,x1					;Subr.Wert
		move	#>$0000FF,y1				;Ausmaskierungswert
		do		y0,load_sample
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
sam_clc:	ds	1							;Anzahl der Samplebytes
stereo_puf_adr:
			dc	stereo1_trk,stereo2_trk
;Parameter und Puffer fÅr die Samples
voice1_par: ds	1							;tatsÑchlich abgearb. Bytes
											;auf Wortgrenze abgerundet
											;muû dem Host vor neuer SampleÅbergabe
											;Åbermittelt werden
;LautstÑrke als Fraktionalwert (zw. 0 und 1)
			ds	1							;LautstÑrke als Kommawert
											;vom Host pro VBL Åbermittelt
;Schrittweite innerhalb des Samples
			ds	2							;Sampleoffset (48 Bit)
;Da der Samplepuffer nie vollstÑndig abgearbeitet wird, bleibt ein Rest
;Åbrig der das nÑchste Mal zur voice_buf-Adr. dazuaddiert werden muû.
			ds	2							;Restoffset von der letzten Berechnung
voice1_buf:	ds	sam_bufcnt					;Puffer der Sampledaten

voice2_par: ds	6
voice2_buf:	ds	sam_bufcnt					;Puffer der Sampledaten
voice3_par: ds	6
voice3_buf:	ds	sam_bufcnt					;Puffer der Sampledaten
voice4_par: ds	6
voice4_buf:	ds	sam_bufcnt					;Puffer der Sampledaten


;****************************************
;Stereopuffer, 2 Spuren gemischt
stereo1_trk:	ds	1000*2					;Stereopuffer 1
stereo2_trk:	ds	1000*2					;Stereopuffer 2
;****************************************
end:
		end		dsp_paula_start			;Installierung starten