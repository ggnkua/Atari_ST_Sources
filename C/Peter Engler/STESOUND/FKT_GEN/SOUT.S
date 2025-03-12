* ------------------------------------------------------------------ *
* --- SOUT.S : Routinen zur Programmierung der DMA-Soundchips    --- *
* ---                                                            --- *
* --- Zum Einbinden in Turbo-C 2.0 , von Peter Engler			 --- *
* ------------------------------------------------------------------ *



* --- Deklaration der Routinen

GLOBL	snd_stop
GLOBL   snd_play
GLOBL   snd_laut
GLOBL   snd_links
GLOBL   snd_rechts
GLOBL   snd_hoehen
GLOBL   snd_tiefen
GLOBL   snd_mix
GLOBL	snd_init


* --- Adressen der DMA-Soundchipregister

S_CNTRL	EQU		$FF8900
F_BASE	EQU		$FF8903
F_COUNT EQU    	$FF8908
F_END	EQU		$FF890F
 
S_MODE	EQU		$FF8920


* --- Adressen der Microwireregister

MW_DATA	EQU		$FF8922
MW_MASK	EQU		$FF8924


* --- Konstanten fÅr die Microwirekommandos

C_LAUT	EQU		$04C0
C_LINKS EQU		$0540
C_RECHTS EQU	$0500
C_HOEHEN EQU	$0480
C_TIEFEN EQU	$0440
C_MIX	EQU		$0400


* --- Daten

		DATA
		EVEN
		
		
* --- Heap

		BSS
		EVEN
		
		
* --- Speicher fÅr Parameter reservieren
		
SND_ADR:
       	ds.l	1
       	
LAUTST: ds.w	1
LINKS:	ds.w	1
RECHTS:	ds.w	1
HOEHEN:	ds.w	1
TIEFEN:	ds.w	1
MIX:	ds.w	1
		
		
* --- Code

		TEXT
		EVEN

     
* --- Aufruf von s_stop im Supervisormodus 

snd_stop:
		pea		s_stop			* Adresse von s_stop auf Stack
		move.w	#$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
		trap	#14
		addq.l	#6,sp
		rts


* --- Aufruf von s_play im Supervisormodus

snd_play:
		move.l	a0,SND_ADR		* Adresse der Struktur retten
		pea		s_play			* Adresse von s_stop auf Stack
		move.w	#$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
		trap	#14				* Xbios Aufruf
		addq.l	#6,sp			* Stackpointer korrigieren
		rts


* --- Aufruf von s_laut im Supervisormodus

snd_laut:
		move.w	d0,LAUTST		* Parameter (LautstÑrke) retten
		pea		s_laut			* Adresse von s_laut auf Stack
		move.w	#$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
		trap	#14				* Xbios Aufruf
		addq.l	#6,sp			* Stackpointer korrigieren
		rts     


* --- Aufruf von s_links im Supervisormodus

snd_links:
		move.w	d0,LINKS		* Parameter (LautstÑrke links) retten
		pea		s_links			* Adresse von s_links auf Stack
		move.w	#$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
		trap	#14				* Xbios Aufruf
		addq.l	#6,sp			* Stackpointer korrigieren
		rts 
		
		
* --- Aufruf von s_rechts im Supervisormodus

snd_rechts:
		move.w	d0,RECHTS		* Parameter (LautstÑrke rechts) retten
		pea		s_rechts		* Adresse von s_rechts auf Stack
		move.w	#$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
		trap	#14				* Xbios Aufruf
		addq.l	#6,sp			* Stackpointer korrigieren
		rts 		


* --- Aufruf von s_hoehen im Supervisormodus

snd_hoehen:
		move.w	d0,HOEHEN		* Parameter (Hoehen) retten
		pea		s_hoehen		* Adresse von s_hoehen auf Stack
		move.w	#$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
		trap	#14				* Xbios Aufruf
		addq.l	#6,sp			* Stackpointer korrigieren
		rts 
		

* --- Aufruf von s_tiefen im Supervisormodus

snd_tiefen:
		move.w	d0,TIEFEN		* Parameter (Tiefen) retten
		pea		s_tiefen		* Adresse von s_tiefen auf Stack
		move.w	#$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
		trap	#14				* Xbios Aufruf
		addq.l	#6,sp			* Stackpointer korrigieren
		rts 
		
		
* --- Aufruf von s_mix im Supervisormodus

snd_mix:
		move.w	d0,LAUTST		* Parameter (Mix) retten
		pea		s_mix			* Adresse von s_mix auf Stack
		move.w	#$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
		trap	#14				* Xbios Aufruf
		addq.l	#6,sp			* Stackpointer korrigieren
		rts 
		
		
* --- Aufruf von s_init im Supervisormodus

snd_init:
		pea		s_init			* Adresse von s_init auf Stack
		move.w	#$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
		trap	#14				* Xbios Aufruf
		addq.l	#6,sp			* Stackpointer korrigieren
		rts
		
		
* --- Stoppen der Tonausgabe 
		
s_stop:
		move.w	#0, S_CNTRL		* Sound-Control-Register lîschen
		rts
		
		
* --- Ton ausgeben. Der Ton wird durch die SOUND-Struktur 
*				    beschrieben.

s_play:
		movem.l	d3/d4,-(sp)		* d3 und d4 retten
		movea.l	SND_ADR,a0		* Adresse der Sound-Struktur in a0
		move.l	(a0)+,d0		* Anzahl Bytes in d0 
		lea.l	4(a0),a0		* Auf 'control_reg' positionieren
		move.w	(a0)+,d3		* 'control_reg' in d3
		move.w	(a0),d4			* 'mode_reg' in d4
		lea.l	4(a0),a0		* Auf 's_ptr' positionieren
		move.l  (a0),d1			* Adresse der Bytes in d1
		move.l	d1,d2			* Adresse merken
		move.b	d1,F_BASE+4    	* Low-Byte eintragen
		asr.l	#8,d1			* Mid-Byte holen
		move.b	d1,F_BASE+2		* Mid-Byte eintragen
		asr.l	#8,d1			* High-Byte holen
		move.b	d1,F_BASE		* High-Byte eintragen
		add.l	d0,d2			* Frame-End berechnen
		move.b	d2,F_END+4  	* Low-Byte eintragen
		asr.l	#8,d2			* Mid-Byte holen
		move.b	d2,F_END+2		* Mid-Byte eintragen
		asr.l	#8,d2			* High-Byte holen
		move.b	d2,F_END		* High-Byte eintragen
		move.w	d4,S_MODE	 	* Mode-Register setzen
		move.w	d3,S_CNTRL  	* Sound ausgeben (Control-Register)
 		movem.l	(sp)+,d3/d4		* d3 und d4 restaurieren
		rts
		
		
* --- Einstellen der GesamtlautstÑrke
		
s_laut:
		move.w 	LAUTST,d0		* Parameter in d0
		add.w	#80,d0			* Wert fÅr Eintragung in Microwire -
		asr.w	#1,d0			* Datenregister aufbereiten
		add.w	#C_LAUT,d0		* GesamtlautstÑrke setzen
lt_wait:	
		cmp.w	#$07FF,MW_MASK	* Warten bis voriger Zyklus
		bne 	lt_wait			*  abgeschlossen
		move.w	d0,MW_DATA  	* Datenregister eintragen
		rts


* --- Einstellen der LautstÑrke des linken Kanals
		
s_links:
		move.w 	LINKS,d0		* Parameter in d0
		add.w	#40,d0			* Wert fÅr Eintragung in Microwire -
		asr.w	#1,d0			* Datenregister aufbereiten
		add.w	#C_LINKS,d0		* LautstÑrke links setzen
lk_wait:	
		cmp.w	#$07FF,MW_MASK	* Warten bis voriger Zyklus
		bne 	lk_wait			*  abgeschlossen
		move.w	d0,MW_DATA  	* Datenregister eintragen
		rts

		
* --- Einstellen der LautstÑrke des rechten Kanals
		
s_rechts:
		move.w 	RECHTS,d0		* Parameter in d0
		add.w	#40,d0			* Wert fÅr Eintragung in Microwire -
		asr.w	#1,d0			* Datenregister aufbereiten
		add.w	#C_RECHTS,d0	* LautstÑrke rechts setzen
rt_wait:	
		cmp.w	#$07FF,MW_MASK	* Warten bis voriger Zyklus
		bne 	rt_wait			*  abgeschlossen
		move.w	d0,MW_DATA  	* Datenregister eintragen
		rts

		
* --- Einstellen der Hoehen
		
s_hoehen:
		move.w 	HOEHEN,d0		* Parameter in d0
		add.w	#12,d0			* Wert fÅr Eintragung in Microwire -
		asr.w	#1,d0			* Datenregister aufbereiten
		add.w	#C_HOEHEN,d0	* Hoehen setzen
ho_wait:	
		cmp.w	#$07FF,MW_MASK	* Warten bis voriger Zyklus
		bne 	ho_wait			*  abgeschlossen
		move.w	d0,MW_DATA  	* Datenregister eintragen
		rts

		
* --- Einstellen der Tiefen
		
s_tiefen:
		move.w 	TIEFEN,d0		* Parameter in d0
		add.w	#12,d0			* Wert fÅr Eintragung in Microwire -
		asr.w	#1,d0			* Datenregister aufbereiten
		add.w	#C_TIEFEN,d0	* Tiefen setzen
tf_wait:	
		cmp.w	#$07FF,MW_MASK	* Warten bis voriger Zyklus
		bne 	tf_wait			*  abgeschlossen
		move.w	d0,MW_DATA  	* Datenregister eintragen
		rts

		
* --- Mischung mit GI-Soundcvhip festlegen
		
s_mix:
		move.w 	MIX,d0			* Parameter in d0
		add.w	#C_MIX,d0		* Mischung festlegen
mx_wait:	
		cmp.w	#$07FF,MW_MASK	* Warten bis voriger Zyklus
		bne 	mx_wait			*  abgeschlossen
		move.w	d0,MW_DATA  	* Datenregister eintragen
		rts
		
	
* --- Initialisieren der Microwireregister	
		
s_init:
		move.w	#0,MW_DATA		* Microwire - Datenregister init.
		move.w	#$07FF,MW_MASK  * Microwire - Maskenregsiter setzen
		bsr		s_stop			* Ton ausschalten
		move.w	#0,LAUTST		* GesamtlautstÑrke auf 0 dB
		bsr		s_laut			*  setzen
		move.w	#0,LINKS		* LautstÑrke links auf 0 dB
		bsr		s_links			*  setzen
		move.w	#0,RECHTS		* LautstÑrke rechts auf 0 dB
		bsr		s_rechts		*  setzen
		move.w	#0,HOEHEN		* Hîhen auf 0 dB
		bsr		s_hoehen		*  setzen
		move.w	#0,TIEFEN		* Tiefen auf 0 dB
		bsr		s_tiefen		*  setzen
		move.w	#1,MIX			* Keine Mischung mit GI-Chip
		bsr		s_mix			* 
		rts
			
		END

