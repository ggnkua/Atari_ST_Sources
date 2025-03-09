* ------------------------------------------------------------------ *
* --- FRM.S : Routinen zum Abspielen unterschiedlicher Frames    --- *
* ---		  mittels Interrupt.	                  			 --- *
* ---                                                            --- *
* --- Zum Einbinden in Turbo-C 2.0 , von Peter Engler			 --- *
* ------------------------------------------------------------------ *



* --- Deklaration der Routinen

GLOBL	frm_stop
GLOBL   frm_start

* --- Adressen der DMA-Soundchipregister

S_CNTRL	EQU		$FF8900
F_BASE	EQU		$FF8903
F_COUNT EQU    	$FF8908
F_END	EQU		$FF890F
 
S_MODE	EQU		$FF8920


* --- Daten

		DATA
		EVEN
		
		
* --- Heap

		BSS
		EVEN
		
* --- Speicher fr Parameter reservieren
		
FRM_ADR:
       	ds.l	1
AKT_FRM:
		ds.w	1
       	
		
* --- Code

		TEXT
		EVEN

     
* --- Aufruf von f_stop im Supervisormodus 

frm_stop:
		pea		f_stop			* Adresse von f_stop auf Stack
		move.w	#$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
		trap	#14				* Xbios Aufruf
		addq.l	#6,sp			* Stack korrigieren
		rts


* --- Aufruf von f_start im Supervisormodus 

frm_start:
		move.l	a0,FRM_ADR		* Adresse der FRAME-Struktur speichern
		pea		f_start			* Adresse von f_start auf Stack
		move.w	#$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
		trap	#14				* Xbios Aufruf
		addq.l	#6,sp			* Stack korrigieren
		rts


* --- Stoppen der Tonausgabe und sperren des Interrupts
		
f_stop:
		move.w	#13,-(sp)		* Interrupt 13
		move.w	#$1A,-(sp)		*  sperren (Timer A)
		trap	#14				* Xbios Aufruf
		addq.l	#4,sp			* Stack korrigieren
		move.w	#0, S_CNTRL		* Sound-Control-Register l”schen
		rts


* --- Setzen der Interruptroutine f_next,  aktivieren des 1. Frames
	  
f_start:
		movem.l	d0-d5/a0,-(sp)	* d3, d4 und d5 retten
		move.l	FRM_ADR,a0		* Adresse der Frame-Struktur speichern
		move.w	(a0)+,d0		* 'anz_frames' in d0
		tst.w	d0				* Keine Frames ?
		beq		f_ende			*  dann Routine beenden
		
		move.l	(a0),a0			* Adresse der ersten
		move.l	(a0),a0			*  FSOUND - Struktur holen
		lea.l	14(a0),a0		* Auf 'wiederholungen' positionieren
		move.w	(a0),d5			* 'wiederholungen' in d5
		tst.w	d5				*  d5 = 0 ?
		bne		k_wieder		* nein, dann weiter bei 'k_wieder'
		moveq.l	#1,d5			* Wenn d5 = 0, dann auf 1 setzen
								* (Bei 0 werden keine Interrupts 
								*  ausgel”st )
k_wieder:
		move.w	#13,-(sp)		* Interrupt 13
		move.w	#$1A,-(sp)		*  sperren (Timer A)
		trap	#14				* Xbios Aufruf
		addq.l	#4,sp			* Stack korrigieren
		
		pea		f_next			* Interruptroutine f_next
		move.w	d5,-(sp)		* Anzahl Wiederholungen
		move.w	#$08,-(sp)		* Timer auf Ereignisz„hlung setzen
		move.w	#0,-(sp)		* Timer A
		move.w	#$1F,-(sp)		* Xbios Nr. $1F ( -> Xbtimer )
		trap	#14				* Xbios Aufruf
		lea.l	12(sp),sp		* Stack korrigieren
		
		move.b	$FFFA03,d0		* Aktive-Edge-Register auslesen
		andi.b	#$EF,d0			* Timer A soll auf 1/0-Flanke reagieren
		move.b	d0,$FFFA03		* Aktive-Edge-Register setzen

		move.w	#13,-(sp)		* Interrupt 13
		move.w	#$1B,-(sp)		*  freigeben (Timer A)
		trap	#14				* Xbios Aufruf
		addq.l	#4,sp			* Stack korrigieren
		
		movea.l	FRM_ADR,a0		* Adresse der Frame-Struktur in a0
		lea.l	2(a0),a0		* Auf 'frame_tab' positionieren
		
		move.w	#1,AKT_FRM		* 1. Frame wird gerade gespielt
		move.l	(a0),a0			* Adresse der ersten
		move.l	(a0),a0			*  FSOUND - Struktur holen
		move.l	(a0)+,d0		* Anzahl Bytes in d0 
		lea.l	4(a0),a0		* Auf 'control_reg' positionieren
		move.w	(a0)+,d3		* 'control_reg' in d3
		move.w	(a0),d4			* 'mode_reg' in d4
		lea.l	6(a0),a0		* Auf 's_ptr' positionieren
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
		
f_ende:	movem.l	(sp)+,d0-d5/a0		* d3, d4 und d5 restaurieren
		rts				
	  		
* --- Auf n„chsten Frame umschalten (Interruptroutine)
*     verwendet werden dabei folgende globale Variablen:
*			- FRM_ADR:	Adresse der FRAME-Struktur
*			- AKT_FRM:	Nummer des aktuellen Frames

f_next:
		movem.l	d0-d5/a0,-(sp)	* Register retten
		movea.l	FRM_ADR,a0		* Adresse der FRAME-Struktur in a0
		move.w	AKT_FRM,d0		* Akt. Frame in d0
		cmp.w	(a0)+,d0		* Akt. Frame mit 'anz_frames' vergleichen
		blt		inc_frm			* wenn 'anz_frames' gr”žer -> Akt. Frame +1
		moveq.l	#0,d0			* Akt.Frame = 0
		
inc_frm:
		addq.w	#1,d0			* n„chsten Frame 
		move.w	d0,AKT_FRM		* in globale Variable eintragen
		movea.l	(a0),a0			* Adresse der FSOUND-Struktur
		subq.w	#1,d0			*  berechnen
		asl.w	#2,d0			* (d0 * 4, da Zeiger 4 Bytes belegen)
		adda.w	d0,a0			*  
		movea.l	(a0),a0			*  Adresse in a0 
		move.l	(a0)+,d0		* Anzahl Bytes in d0 
		lea.l	4(a0),a0		* Auf 'control_reg' positionieren
		move.w	(a0)+,d3		* 'control_reg' in d3
		move.w	(a0),d4			* 'mode_reg' in d4
		lea.l	4(a0),a0		* Auf 'wiederholungen' positionieren
		move.w	(a0)+,d5		* 'wiederholungen' in d5
		tst.w	d5				*  d5 = 0 ?
		bne		k_wieder2   	* nein, dann weiter bei 'k_wieder'
		moveq.l	#1,d5			* Wenn d5 = 0, dann auf 1 setzen
								* (Bei 0 werden keine Interrupts 
								*  ausgel”st )
k_wieder2:
		move.b	d5,$FFFA1F		* Anzahl-Wiederh. in Timer-Register
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
		
		movem.l	(sp)+,d0-d5/a0	* Register restaurieren
		move.b	#$DF,$FFFA0F	* Interrup-in-Service-Bit l”schen
		rte
		
			
		END