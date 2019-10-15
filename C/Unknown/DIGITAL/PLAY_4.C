/*******************************************************************
*
* PLAY_4.C
* 
* MULTI-PLAYER-DEMO, Copyright (C) 1991, TOS MAGAZIN
*
* Musik auf 4 Kanaelen, Compiler: LASER C (MEGAMAX)
*
* Zusammenlinken mit PLAYFOR.O !!!
*
* PLAY_4.C spielt einen 4-Stimmigen Song im Interrupt
* Die Songdaten sind dabei 'zeilenweise', codiert, daher der
* oefters auftauchende Begriff Zeile. Eine Zeile besteht immer
* aus 4*4 Bytes, jeweils 4 Bytes bilden einen Event, also ein
* Informationspacken fuer einen der 4 Kanaele (also Zeile = 4 Events) 
* Aufbau Event: 
* - Byte 0: Notennummer in MIDI-Tonhoehen 36..96, 0: Keine Note
* - Byte 1: Instrument: Es gibt nur 4 Stimmen, aber 16 MIDI-Kanaele
*           Jeweils 4 MIDI-Kanaele werden auf eine Stimme gelegt,
*           aber fuer jeden MIDI-Kanal kann mit 'prg_chg()' eines
*           der 32 moeglichen Instrumente eingestellt werden
*           Sinn der Sache: max. 4 Instrumente koennen sich eine
*           Stimme teilen
* - Byte 2,3: Zusaetzliche Informationen: Sequenz-Nr, Instrument,
*           Vibrato... (erklaert in den Kommentaren zu 'play_zeile()')
*
* Leider belegen die Samples im Original eine ordentliche Menge
* Speicherplatz (etwa 95kB) daher musste ich sie komprimieren.
* Die Samples werden also nicht ueber 'load_sam()' geladen, sondern
* ueber einen speziellen Entpacker, siehe Artikel
*
* POWER:
* Die Displayroutine bringt es (trotz 'Bremse') auf immerhin noch
* etwa 40 Bilder pro Sekunde!
*
*******************************************************************/

#include <osbind.h>
#include <stdio.h>

/**** Deklaration der externen Funktionen in PLAYFOUR.O ****/
extern  	init_sam();			/* (Re-)Initialisiert Daten */
extern long	load_sam();			/* laedt Sample */
extern long *play_on();			/* Schaltet Player an (Interrupts) */
extern	    play_off();			/* 			"      aus */

extern	   	volume();			/* Waehlt Lautstaerke */
extern	   	note_on();			/* Note an-schalten */
extern	   	note_off();			/*    .dto aus     */
extern		sustain();			/* Sustain AN/AUS */
extern		pitch_b();			/* Tonhoehenraedchen */
extern		vibrato();			/* Vibratotiefe */
extern		arpeggio();			/* 3-Ton Arpeggio */
extern		prg_chg();			/* Programmwechsel */

extern unsigned clock;			/* Die Uhr */
extern long psamples[];			/* Die Adressen der Samples */

/* Interne Variablen, Funktionen ... */

#define TIMER	49				/* Freq.=614400Hz/TIMER, hier: 12.54kHz */
#define DATENRAM	95000L		/* Soviel Platz fuer Samples/Song */

long adresse0;					/* Adresse 1. Sample (Long einfacher) */ 
long song0;						/* Adresse des Songs ( char* ) */

#define VISBYTES	144			/* Soviele Bytes auf einen Schlag */
long screen;					/* Bildschirmadresse (char *) */
long oldadrs[4][VISBYTES];		/* Speicher zum Spielen... */
int lines[128];
long ziele[4];					/* Zieladressen im Bildschirm */

long merke_pos;					/* Einige Flags der Abspielroutine */
long workpos;
unsigned spec,cnt,sret;
extern my_vbl();				/* Assembler-Label deklarieren */

/***************************************************************** 
* Da die ungepackten Samples zuviel Speicherplatz auf Disk
* kosten wuerden (95kB), wurden sie mit LSD gepackt. LSD arbeitet
* nach einem aehnlichen Verfahren wie in TOS 4/91 von Frank Mathy
* beschrieben und bringt es hier auf eine Quote von 38%! 
* Der Aufruf des Entpackers geschieht, indem ihm ein Fildeskriptor
* und die Zieladresse uebergeben wird.
* Fuer Ihre eigenen Arbeiten mit PLAYFOUR ist LSD nicht wesentlich, 
* da PLAYFOUR Samples, die mit SMSSEDIT von der letzten Disk gemacht
* worden, sind direkt laden kann (via 'load_sam()').
*****************************************************************/

int _cread[]={
	0x6050,0x0,0x0,0x0,0x0,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
	0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
	0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
	0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0x0,0x0,0x0,
	0x0,0x0,0x0,0x0,0x0,0x41FA,0xFFB6,0x48D0,0x7EFE,
	0x41FA,0xFFAC,0x30AF,0x4,0x242F,0x6,0x41FA,0xFF9C,0x4290,
	0x41FA,0xFF94,0x4250,0x487A,0xFFCE,0x2F3C,0x0,0xE,0x3F3A,
	0xFF8A,0x3F3C,0x3F,0x4E41,0x4FEF,0xC,0x41FA,0xFF76,0x30BC,
	0xFFF5,0x4A80,0x6F00,0x230,0x30BC,0xFFDC,0x303A,0xFFA4,0xC40,
	0xABCD,0x6600,0x220,0x303A,0xFF9A,0x6626,0x2F02,0x2F3A,0xFF94,
	0x3F3A,0xFF52,0x3F3C,0x3F,0x4E41,0x4FEF,0xC,0x41FA,0xFF3E,
	0x30BC,0xFFF5,0x4A80,0x6F00,0x1F8,0x6000,0x1E8,0x2F3C,0xFFFF,
	0xFFFF,0x3F3C,0x48,0x4E41,0x5C8F,0x41FA,0xFF1E,0x30BC,0xFFD9,
	0xC80,0x0,0x44A,0x6F00,0x1D4,0x2C00,0x2F06,0x3F3C,0x48,
	0x4E41,0x5C8F,0x41FA,0xFF00,0x30BC,0xFFD9,0x4A80,0x6F00,0x1BA,
	0x3E3A,0xFF34,0xC47,0x1,0x6700,0x1CE,0xC47,0x3,0x6700,
	0x1C6,0x486,0x0,0x40A,0x41FA,0xFEDA,0x2080,0x2C40,0x4BEE,
	0x40A,0x2642,0x4287,0x244D,0x2F0E,0x2F3C,0x0,0x40A,0x3F3A,
	0xFEC4,0x3F3C,0x3F,0x4E41,0x4FEF,0xC,0x41FA,0xFEB0,0x30BC,
	0xFFF5,0x4A80,0x6F00,0x16A,0x30BC,0xFFDC,0x342E,0x400,0x242,
	0xFFFE,0x6600,0x15A,0x242E,0x402,0x222E,0x406,0x284E,0x4283,
	0x303A,0xFED2,0x4245,0x51CF,0x3E,0x5383,0x6A34,0x3800,0x2F0D,
	0xB286,0x6D04,0x2F06,0x6002,0x2F01,0x3F3A,0xFE70,0x3F3C,0x3F,
	0x4E41,0x4FEF,0xC,0x41FA,0xFE5C,0x30BC,0xFFF5,0x4A80,0x6F00,
	0x116,0x3004,0x244D,0x2606,0x5383,0x9286,0x181A,0x7E07,0xF04,
	0x6702,0x5445,0x3A34,0x5000,0x6EB4,0xBA00,0x670A,0x16C5,0x5382,
	0x66A8,0x6000,0xB2,0x4245,0x51CF,0x3E,0x5383,0x6A34,0x3800,
	0x2F0D,0xB286,0x6D04,0x2F06,0x6002,0x2F01,0x3F3A,0xFE14,0x3F3C,
	0x3F,0x4E41,0x4FEF,0xC,0x41FA,0xFE00,0x30BC,0xFFF5,0x4A80,
	0x6F00,0xBA,0x3004,0x244D,0x2606,0x5383,0x9286,0x181A,0x7E07,
	0xF04,0x6702,0x5445,0x3A34,0x5000,0x6EB4,0x3005,0x4245,0x51CF,
	0x3C,0x5383,0x6A32,0x3800,0x2F0D,0xB286,0x6D04,0x2F06,0x6002,
	0x2F01,0x3F3A,0xFDC4,0x3F3C,0x3F,0x4E41,0x4FEF,0xC,0x41FA,
	0xFDB0,0x30BC,0xFFF5,0x4A80,0x6F6A,0x3004,0x244D,0x2606,0x5383,
	0x9286,0x181A,0x7E07,0xF04,0x6702,0x5445,0x3A34,0x5000,0x6EB6,
	0x245,0xFF,0x16C0,0x51CD,0xFFFC,0x303A,0xFDCC,0x5782,0x6E00,
	0xFEF6,0x4A6E,0x400,0x6712,0x223A,0xFDB4,0x5381,0x206F,0x6,
	0x1018,0xD110,0x5381,0x6EF8,0x2F3A,0xFD60,0x3F3C,0x49,0x4E41,
	0x5C8F,0x41FA,0xFD52,0x30BC,0xFFBD,0x4A40,0x660C,0x203A,0xFD8A,
	0x4CFA,0x7EFE,0xFD48,0x4E75,0x203A,0xFD3C,0x670C,0x2F3A,0xFD36,
	0x3F3C,0x49,0x4E41,0x5C8F,0x4CFA,0x7EFE,0xFD2E,0x303A,0xFD22,
	0x48C0,0x4E75,0x41FA,0xFD1C,0x2080,0x2C40,0x2642,0x223A,0xFD58,
	0x2A01,0x303A,0xFD56,0x4283,0x5383,0x6A32,0x3800,0x2F0E,0xB286,
	0x6D04,0x2F06,0x6002,0x2F01,0x3F3A,0xFCF8,0x3F3C,0x3F,0x4E41,
	0x4FEF,0xC,0x41FA,0xFCE4,0x30BC,0xFFF5,0x4A80,0x6F9E,0x3004,
	0x244E,0x2606,0x5383,0x9286,0x181A,0xB800,0x670A,0x16C4,0x5385,
	0x66BE,0x6000,0x84,0x5383,0x6A34,0x3800,0x2F0E,0xB286,0x6D04,
	0x2F06,0x6002,0x2F01,0x3F3A,0xFCB2,0x3F3C,0x3F,0x4E41,0x4FEF,
	0xC,0x41FA,0xFC9E,0x30BC,0xFFF5,0x4A80,0x6F00,0xFF58,0x3004,
	0x244E,0x2606,0x5383,0x9286,0x1E1A,0x5383,0x6A34,0x3800,0x2F0E,
	0xB286,0x6D04,0x2F06,0x6002,0x2F01,0x3F3A,0xFC78,0x3F3C,0x3F,
	0x4E41,0x4FEF,0xC,0x41FA,0xFC64,0x30BC,0xFFF5,0x4A80,0x6F00,
	0xFF1E,0x3004,0x244E,0x2606,0x5383,0x9286,0x4244,0x181A,0x16C7,
	0x51CC,0xFFFC,0x5785,0x6E00,0xFF3A,0x303A,0xFC7E,0xC40,0x3,
	0x6700,0xFEC2,0x6000,0xFED0
};
long (*cread)() = (long (*)())_cread;		/* Funktion, kein Array! */

/**** play_zeile: Spielt 4 Events des Songs (hier 'Zeile') ****/
unsigned char *play_zeile(sdata)
register unsigned char *sdata;{
	register int kan=0,Aku,Mkn;		/* 4 Kanaele */

	asm{
		clr.w sret					; Return-Flag loeschen!
	dolo:
		clr.w Mkn					; Mkn wird MIDI-Kanal
		move.b 1(sdata),Mkn			; 0..3: Kanalzaehler
		lsl.w #2,Mkn				; auf den entsprechenden
		add.w kan,Mkn				; MIDI-Kanal umrechnen

		move.b 2(sdata),Aku			; Command holen
		beq doon					; Ist da was?
		lsr.b #4,Aku				; und isolieren
		cmpi.b #1,Aku
		beq pitch					; 1: Pitch 			1xpp
		cmpi.b #2,Aku
		beq sust					; 2: Sustain 		2xss
		cmpi.b #3,Aku
		beq mainvol					; 3: Main_Volume 	3xvv
		cmpi.b #4,Aku
		beq vibra					; 4: Vibrato	 	4xvv
		cmpi.b #9,Aku
		beq speed					; 9: Speed	 		9xvv
		cmpi.b #0xC,Aku
		beq prg						; C: Prg_Change 	Cxpp
		cmpi.b #0xD,Aku
		beq call					; D: Unterprogramm! Dppp
		cmpi.b #0xE,Aku
		beq ende					; E: Return			Exxx
		cmpi.b #0xF,Aku
		beq off						; F: Note_off 		Fxxx
		cmpi.b #0xA,Aku
		beq arp						; A: Arpeggio 		Aabc
	doon:					
		clr.w Aku					; *** NOTE ON ??? ***
		move.b (sdata),Aku			; Note holen
		beq donix					; Tonhoehe 0: Ignorieren
		move.w Aku,-(A7)			; Note auf Stack,
		move.w Mkn,-(A7) 			; Dann noch den (MIDI) Kanal
		jsr note_on
		addq.w #4,A7				; Stack OK
	donix:
		addq.w #4,sdata				; 4*4 Bytes pro Zeile!
		addq.w #1,kan
		cmp.w #4,kan				; 0..3 erlaubt
		blt dolo					; Wenn weniger...
		bra pl_end					; Das war's
	speed:							; *** Speed! ***
		move.b 3(sdata),spec+1		; uebernehmen...
		bra doon
	off:							; *** NOTE OFF ***
		move.w Mkn,-(A7) 			; Kanal
		jsr note_off
		addq.w #2,A7				; Stack OK
		bra doon
	prg:							; *** PRG_CHG ***
		clr.w Aku					; Als Wort formatieren
		move.b 3(sdata),Aku			; Prg holen
		move.w Aku,-(A7)			; und auf Stack
		move.w Mkn,-(A7) 			; Kanal
		jsr prg_chg
		addq.w #4,A7				; Stack OK
		bra doon
	arp:							; *** ARPEGGIO ***
		tst.b (sdata)				; Arp. ohne Noten
		beq donix					; ist verboten!
		move.b 3(sdata),Aku
		andi.w #0xF,Aku
		add.b (sdata),Aku			; Note 3
		move.w Aku,-(A7)			; auf Stack
		move.b 3(sdata),Aku
		lsr.b #4,Aku
		andi.w #0xF,Aku
		add.b (sdata),Aku			; Note 2
		move.w Aku,-(A7)			; auf Stack
		move.b 2(sdata),Aku
		andi.w #0xF,Aku
		add.b (sdata),Aku			; Note 1
		move.w Aku,-(A7)			; auf Stack
		move.w Mkn,-(A7)			; Kanal dazu...
		jsr arpeggio
		addq.w #8,A7
		bra donix					; NIX MEHR!
	vibra:							; *** VIBRATO ***
		clr.w Aku
		move.b 3(sdata),Aku			; Vibrato holen
		move.w Aku,-(A7)			; und auf Stack
		move.w Mkn,-(A7) 			; (MIDI) Kanal dazu
		jsr vibrato
		addq.w #4,A7				; Stack OK
		bra doon
	 mainvol:						; *** MAIN VOLUME ***
	 	clr.w Aku
	 	move.b 3(sdata),Aku
	 	lsl.w #4,Aku				; Volume 0..1024..2048
	 	move.w Aku,-(A7)			; fuer alle Kanaele!
		jsr volume
		addq.w #2,A7				; Stack OK
		bra doon
	sust:							; *** SUSTAIN ON/OFF ***
		clr.w Aku
		move.b 3(sdata),Aku			; Sustain 0 oder <>0 holen
		move.w Aku,-(A7)			; und auf Stack
		move.w Mkn,-(A7) 			; Kanal dazu
		jsr sustain
		addq.w #4,A7				; Stack OK
		bra doon
	pitch:							; *** PITCH BENDER ***
		clr.w Aku
		move.b 3(sdata),Aku			; Pitchbender holen
		move.w Aku,-(A7)			; und auf Stack
		move.w Mkn,-(A7) 			; (MIDI) Kanal
		jsr pitch_b
		addq.w #4,A7				; Stack OK
		bra doon
	call:							; *** UNTERPROGRAMM ***
		move.l sdata,D0 			; alte Songpos merken!
	ca_1:
		addq.l #4,D0				; Auf naechste Zeilenanfang stellen
		addq.w #1,kan
		cmpi.w #4,kan
		blt ca_1					; Muss auf naechsten Zeilenanfang zeigen	
		move.l D0,merke_pos			; und abspeichern
		move.l song0,A0				; Basisadresse holen
		move.w 2(sdata),D0			; Zeile relativ		
		andi.w #31,D0				; Sonst zuweit!
		beq donix					; Sprung nach 0 verboten!
		mulu #512,D0				; Zeigt auf's Pattern
		lea 0(A0,D0.w),sdata
		clr.w kan					; von vorne!
		bra dolo					; Dort weitermachen!
	ende:							; *** UP ENDE ***
		st sret						; Return-Flag setzen
		bra doon					; Noch'ne Note da?
	pl_end:
		tst.w sret
		beq pl_fert
		tst.w merke_pos
		bpl gotox					; Total fertig?
		move.l song0,sdata			; Von Vorne!	
		bra pl_fert			
	gotox:
		move.l merke_pos,sdata 		; Alte Adresse holen
		move.w #-1,merke_pos 		; loeschen!
	pl_fert:
	}
	return(sdata);					/* Neue Position zurueckgeben! */
}
/*******************************************************************
* Periodischer Interrupt-Handler, wird als VBL eingehaengt 
* Vorsicht: Funktion endet mit RTE und nicht mit RTS
*******************************************************************/
dummy(){
	asm{
	my_vbl:
		subq.b #4,cnt+1			; Nur alle paar Aufrufe spielen...
		bpl cl_e				; Noch nicht?
		move.b spec+1,cnt+1		; Zaehler neu starten
		movem.l D0/A0,-(A7) 	; Register sichern
		move.l workpos,-(A7)    
		jsr play_zeile			; Zeile spielen im Interrupt!
		addq.w #4,A7			; Stack ok
		move.l D0,workpos		; neue Zeile merken
		movem.l (A7)+,D0/A0 	; Register wiederherstellen
	cl_e:						
		rte						; VBL Interrupt fertig!
	}
}

/*** Einige Bytes eines Samples zeichnen ***/
do_one_disp(imbild,olds,data,step)
register char *imbild, *olds, *data;
register int step;{
	register mask=254, high=0x0F, low=0xF0;
	register char *lip;
	
	lip=(char*)lines;
	asm{
		move.w #VISBYTES/2-1,D2		; Immer 2 Pro Schleife...
		move.l A6,-(A7);			; Auto-Register sichern
		lea (olds),A6;				; Spart etwas Zeit...
	ollo:
		move.l (olds)+,A0			; Alte Bildschirmadr. holen
		move.l (olds)+,A1
		st (A0)						; Schwarz!
		st (A1)					

		move.b (data),D0 			; Datenbyte 1 holen
		adda.w step,data			; Schrittchen
		and.w mask,D0				; Bit 0 loeschen
		move.w 0(lip,D0.w),D0		; Multiplikation mit 80
		move.b (data),D1			; Datenbyte 2 holen
		adda.w step,data			; Schrittchen
		and.w mask,D1
		move.w 0(lip,D1.w),D1		; Auf Zeilen bringen

		lea 0(imbild,D0.w),A0		; A0: Bildbyte 1
		lea 0(imbild,D1.w),A1		; A1: Bildbyte 1

		move.l A0,(A6)+				; Adressen merken
		move.l A1,(A6)+
		
		cmp.w D1,D0
		beq.s gleich
		move.b high,(A0)			; Oberes Nibble setzen
		move.b low,(A1)				; Unteres Nibble setzen
		bra.s next
	gleich:
		clr.b (A0)					; Vollbyte setzen
	next:
		addq.w #1,imbild			; Naechstes Screenbyte
		dbf D2,ollo
		move.l (A7)+,A6				; Auto-Register holen
	}
}

/* Abspielen des Songs im Interrupt */
spielen(){
	long o_vbl;
	long *adr4;
	register cnt,i;

	merke_pos=-1;								/* Songpointer */
	workpos=song0;								/* Vom Anfang an! */
	init_graf();								/* Initialisieren der Grafik */

	adr4 = play_on(TIMER);    					/* Vorne! */
	o_vbl=Setexc(28,my_vbl); 	 				/* Eigenen VBL verwenden */

	while(Cconis) Cnecin();						/* Tasten abfangen */
	while(!Bconstat(2)){ 						/* Bios schneller? */
		for(i=0;i<100;i++)						/* Abfrage langsam! */ 
		asm{
			move.w #3,cnt						; *** DARSTELLUNG ***
		disp:
			move.w cnt,D0
			lsl.w #2,D0							; * 4, als Index
			movea.l adr4(A6),A0					; A0 zeigt auf Feld
			movea.l 0(A0,D0.w),A0				; A0 zeigt auf Variablen
			movem.l 0(A0),D1-D3					; Auf einmal!

; 			* D1: Adr, D2: Step, D3: Index

			add.l #32767,D2						; so ungefaehr...
			add.l 12(A0),D2						; Mit Pitch!
			swap D2								; D2 runden...
			cmp.w #3,cnt						; Drums?
			bne.s nodrums
			moveq #2,D2							; Drums: Mehr darstellen
		nodrums:
			move.l D1,A1						; A1: Adresse des Samples
			cmpi.w #2,-2(A1)					; Zerosample?
			bne noze
			clr.w D3							; Immer Schrittweite 0
			clr.w D2							; Stillhalten!
		noze:
			move.w D2,-(A7)						; STEP->
			pea 0(A1,D3.w)						; Aktuelle Adresse->	
			lea ziele,A0
			move.l 0(A0,D0.w),A1				; A1: Screenadr.
			mulu #VISBYTES,D0					; Bufferadr?
			lea oldadrs,A0
			pea 0(A0,D0.w)						; Bufferadresse->
			pea (A1)							; Screen->
			jsr do_one_disp						; Darstellen...
			lea 14(A7),A7						; Stack OK
			dbf cnt,disp						; Das: 4 Mal!
		}
	} 
	Cnecin();

	Setexc(28,o_vbl); 
	play_off(); 

}



/*** Diagnoseroutine ****/
error(s,fatal)
char *s;
int fatal;{
	Cconws("\r\007*** TOS MULTI PLAYER => Fehler: ***\r\n");
	Cconws(s);
	Cconws("\r\n*** (<TASTE>) ***");
	Cnecin();
	if(fatal) exit(-1);		/* Fatale Fehler fuehren zum Abbruch */
}

/*** Initialisierung der Grafik-Variablen ****/
init_graf(){
	int i,j,r;
	screen=Physbase();
	ziele[0]=screen+1284;		/* Adresse 1. Kanal */
	ziele[1]=screen+8484;		/* 1. Kanal */
	ziele[2]=screen+15764;
	ziele[3]=screen+22964;
	Cconws("\033E    /// THE TOS-CILLOSCOPE /// 4 Kanal, 12.54 kHz, ca 40% CPU-Zeit frei! ///\033v\033p");
	for(j=1;j<24;j++){
		Cconws("\033Y");
		Cconout(j+32);
		Cconout(36);
		for(i=0;i<72;i++) Bconout(2,' '); 
	}
Cconws("\033q\n\r    /// TOS MAGAZIN 1991, Ende: [TASTE] ///  Geschrieben in LASER C (JP) ///");

	for(i=0;i<128;i++){
		r=(((i-64)*16)/16)+48;		/* Skalieren */
		if(r<0)r=0;					/* Oversize!  */
		if(r>95)r=95;
		lines[i]=r*80;
	}
	for(i=0;i<4;i++) 			/* Gueltige Adressen eintragen */
		for(j=0;j<VISBYTES;j++) oldadrs[i][j]=screen+32000;
}

/*** HIER GEHT'S ENDLICH LOS! ***/
main(){
	int fd;
	long len;

	init_sam();
	if(Getrez()!=2) 			/* Farbe: Trotzdem weitermachen... */
	   error("Programm arbeitet nur in Monochrom richtig!",0);

	if(!(adresse0=Malloc(DATENRAM))) error("Speicher voll!",1);
	if((fd=Fopen("SOUNDS.LSD",0))<0) error("Wo ist 'SOUNDS.LSD'?",1);
	if((len=(*cread)(fd,adresse0))<0) error("'SOUNDS.LSD' defekt!",1);
	song0=adresse0+len;	/* Hinter den Samples liegt der Song */
	if((len=(*cread)(fd,song0))<0) error("'SOUNDS.LSD' defekt!",1);

	/* Eintragen der Adressen der Samples von Hand! Beim Laden eines
	* Samples mit 'load_sam()' passiert das automatisch */
	psamples[0]=adresse0;				/* E-Piano     */
	psamples[1]=adresse0+19754;			/* E-Bass      */
	psamples[4]=adresse0+31636;			/* Synthesizer */
	psamples[5]=adresse0+62710;			/* Trompete    */
	psamples[16]=adresse0+75614;		/* Bassdrum    */
	psamples[17]=adresse0+77182;		/* Snaredrum   */
	psamples[18]=adresse0+79230;		/* Highhats    */
	psamples[20]=adresse0+82882;		/* Cowbell     */

	spielen();							/* Auge und Ohr! */
}
