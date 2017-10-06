* Dieses Programm ermittelt Primzahlen.
* Die Anzahl der Primzahlen ist SpeicherplatzabhÑngig. Bei 1 MByte RAM
* und TOS im ROM sind Primzahlen bis etwa 1.2 Mrd. mîglich.
* Geben Sie als Feldgrîûe z.B. 10000 ein, dann werden alle Primzahlen
* bis 20000 ermittelt (die geraden Zahlen werden automatisch nicht
* mitgezÑhlt !!!).
*
* Falls Sie bei der Abfrage "Filename:" Ctrl+A drÅcken, dann werden
* die Primzahlen nicht auf Diskette abgelegt.
*
* Das Programm wurde als Demo-Programm geschrieben, um zu zeigen, wie
* man BASIC-Programme in Assembler umsetzen kann. Die momentane
* Programmversion ist noch nicht ausgereift. Wer Lust und Zeit hat
* kann jede mîgliche Modifikation durchfÅhren (nur der Name des
* ursprÅnglichen Autors sollte noch erhalten bleiben).
*
* Die entsprechende BASIC-Version finden Sie am Programmende.
*
* Geschrieben von Stephan Slabihoud, Gustav-Ohm-Str.72, 4250 Bottrop
*
* Assembler: GenST Assembler von HiSoft
*



prog_init:
        move.l  a7,a5           * Programm anmelden
        move.l  4(a5),a5        * Basepage Anfang
        move.l  $c(a5),d0       * LÑnge Text-Bereich
        add.l   $14(a5),d0      * +LÑnge Data-Bereich
        add.l   $1c(a5),d0      * +LÑnge Bss-Bereich
        add.l   #8192,d0        * +8Kbyte Userstack
        move.l  a5,d1           * Anfang Basepage
        add.l   d0,d1           * +LÑnge Programm = Userstack
        and.l   #-2,d1          * Gerade Adresse
        move.l  d1,a7           * Userstack setzen
        move.l  d0,-(sp)        * LÑnge Programm
        move.l  a5,-(sp)        * Start Programm
        move.w  d0,-(sp)        * Dummy Wert
        move.w  #$4a,-(sp)      * Set-Block
        trap    #1
        add.l   #12,sp

        bsr     hauptprogramm   * Hauptprogramm aufrufen

		clr.w	-(a7)
        move.w  #$4c,-(a7)      * ZurÅck zum Desktop
        trap    #1

inkey:
        move.w  #2,-(sp)        * Fragt die Tastatur ab
        move.w  #1,-(sp)        * ASCII+SCAN - Code in D0
        trap    #13             * Wartet nicht auf einen
        addq.l  #4,sp           * Tastendruck
        tst.w   d0
        bpl     leereend
        move.w  #7,-(sp)
        trap    #1
        addq.l  #2,sp
        rts
leere_inkey:
        move.w  #$b,-(sp)       * Entfernt alle Zeichen aus
        trap    #1              * dem Tastaturpuffer
        addq.l  #2,sp
        tst.w   d0
        beq     leereend
        move.w  #7,-(sp)
        trap    #1
        addq.l  #2,sp
        bra     leere_inkey
leereend:
        rts
printf:
        move.l  a0,-(sp)        * Gibt eine Zeichenkette aus
        move.w  #9,-(sp)        * Adresse des Strings in a0
        trap    #1
        addq.l  #6,sp
        rts

**********************************************************************
**********************************************************************
**********************************************************************

hauptprogramm:

		lea		text1(pc),a0
		bsr  	printf

		bsr  	gebe_zahl_ein   * Zahl eingeben
		bsr  	gebe_file_ein   * Filename eingeben

		lea		text3(pc),a0    * Text 3 ausgeben
		bsr  	printf          

		bsr  	leere_inkey     * Tastaturspeicher leeren
		cmp.b	#-1,saveflag	* File anlegen ?
		beq		nosave1			* Nein !
		bsr  	create_file     * File anlegen
nosave1:
		lea		feld(pc),a0     * Adresse des Feldes
		move.l	maximal,d1      * LÑnge des Feldes              
		lsr.l	#5,d1			* Division durch 32
		addq.l	#1,d1                                           

weiter1:
		move.l	#-1,(a0)+  	    * Feld auf 1 setzen             
		subq.l	#1,d1
		tst.l	d1
		bne		weiter1

		clr.l	d0              * ZÑhler auf 0
		lea		feld(pc),a0     * Adresse des Feldes

fornext1:
		move.l	d0,d1                                           
		move.l	d0,d2
		lsr.l	#3,d1			* DIV durch 8
		and.l	#7,d2			* MOD durch 8

		btst.b	d2,0(a0,d1.l)   * Feld(x)=1 ?                   
		bne		if1             * Ja                            
endif1:
		movem.l	d0/a0,-(sp)
		move.w	#$b,-(sp)       * Wurde eine Taste gedrÅckt
		trap	#1
		addq.l	#2,sp
		move.w	d0,d1
		movem.l	(sp)+,d0/a0
        tst.w	d1
		bne		abbruch         * Ja, Abbruch !!!

		addq.l	#1,d0           * ZÑhler um eins erhîhen
		cmp.l	maximal,d0      * ZÑhler > LÑnge des Feldes ?
		bls		fornext1        * Nein

abbruch:
		cmp.b	#-1,saveflag	* File schlieûen ?
		beq		nosave2			* Nein !
		bsr  	file_close      * File schlieûen
nosave2:
		bsr  	leere_inkey     * Tastaturspeicher leeren
		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		rts                     * Ende des Programmes

if1:
		move.l	d0,primzahl     * Primzahl <= 2*ZÑhler +3
		add.l	d0,primzahl
		addq.l	#3,primzahl

		bsr  	gebeprimzahlaus * Primzahl ausgeben

		move.l	d0,d6		    * Hilfsvariable <= ZÑhler + Primzahl
		add.l	primzahl,d6 

		cmp.l	maximal,d6      * Hilfsvariable > FeldlÑnge
		bls		if2             * Nein

endif2:
		bra		endif1          

if2:
fornext2:
		move.l	d6,d1                                           
		move.l	d6,d2
		lsr.l	#3,d1			* DIV durch 8
		and.l	#7,d2			* MOD durch 8

		bclr.b	d2,0(a0,d1.l)   * Feld(x) <= 0                  

		add.l	primzahl,d6     * ZÑhler <= ZÑhler + Primzahl

		cmp.l	maximal,d6      * ZÑhler > FeldlÑnge
		bls		fornext2        * Nein
		bra		endif2


create_file:
		move.w	#0,-(sp)        * File erzeugen
		move.l	#filename,-(sp)
		move.w	#$3c,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.w	d0
		bmi		error
		move.w	d0,filehandle   * Filehandle merken
		rts
file_close:
		move.w	filehandle,-(sp)
		move.w	#$3e,-(sp)      * File schlieûen
		trap	#1
		addq.l	#4,sp
		rts
file_write:
		movem.l	d0/a0,-(sp)
		move.l	#freezahl,-(sp) * Anfang der Zahl (ASCII)
		move.l	#$8,-(sp)       * 8 Zeichen LÑnge
		move.w	filehandle,-(sp)
		move.w	#$40,-(sp)      * Zahl speichern
		trap	#1
		add.l	#12,sp
		tst.w	d0
		bmi		error
		movem.l	(sp)+,d0/a0
		rts

gebeprimzahlaus:
		move.l	primzahl,d1     * Primzahl nach D1
		lea		freezahl(pc),a2 * Anfang der ASCII-Zahl
		bsr  	binasc          * D1 --> ASCII
		cmp.b	#-1,saveflag	* Zahl speichern ?
		beq		nosave3			* Nein !
		bsr  	file_write      * Zahl speichern
nosave3:
		movem.l	d0/a0,-(sp)
		lea		primpos(pc),a0  * Cursor setzen und Primzahl
		bsr  	printf          * ausgeben
		movem.l	(sp)+,d0/a0
		rts

binasc:
		moveq.l	#10,d3          * 10ner Basis
		move.l	a2,a4           * ASCII-Feld Anfang
		moveq.l	#7,d4           * 7 Stellen
sch1:
		move.b	#32,(a4)+       * ASCII-Zahl zurÅcksetzen
		dbra	d4,sch1
binweiter:
		bsr  	division        * D2 <= D1 / D3
		or.b	#$30,d2         * In eine ASCII-Zahl wandeln
		move.b	d2,-(a4)        * Zahl ins ASCII-Feld eintragen
		cmpi.l	#0,d1
		bne		binweiter
		rts
division:
		movem.l	d0/d3/d4,-(sp)  * Dividiert D1 durch D3
		move.l	d3,d4           * Ergebnis in D1, Rest in D2
		moveq.l	#31,d0          * 32-Bit Division
		clr.l	d2              * D2 <= D1 MOD D3
		clr.l	d3              * D1 <= D1 DIV D3  ;  D1=D1-(D1 MOD D3)
nextbit:
		roxl.l	#1,d1           
		roxl.l	#1,d2           
		asl.l	#1,d3
		sub.l	d4,d2
		bmi		unter
		addq.l	#1,d3
endediv:
		dbra	d0,nextbit     * NÑchstes Bit
		move.l	d3,d1          * Rest nach D1
		movem.l	(sp)+,d0/d3/d4
		rts
unter:
		add.l	d4,d2
		bra		endediv
error:
		movem.l	(sp)+,d0/a0
		move.w	#0,-(sp)
		trap	#1

gebe_zahl_ein:
		movea.l	#zeile,a5
ein1:	move.w	#1,-(sp)        * Zahl eingeben
		trap	#1
		addq.l	#2,sp
		move.b	d0,(a5)+
		cmpi.b	#8,d0
		beq		loesche1
		cmpi.b	#13,d0
		bne		ein1
		move.b	#0,-(a5)
		movea.l	#zeile,a5
		clr.l	d7              * D7 = 0
		clr.l	d6
		clr.l	d5
wandel:
		move.b	(a5)+,d6
		subi.b	#$30,d6         * ASCII-Code -> BIN-Zahl
		cmpi.b	#9,d6
		bhi		binfertig
		add.l	d7,d7
		move.l	d7,d5
		add.l	d7,d7
		add.l	d7,d7
		add.l	d5,d7
		add.l	d6,d7
		bra		wandel
binfertig:
		move.l	d7,maximal
		rts

gebe_file_ein:
		lea		text2(pc),a0    * Text2 ausgeben
		bsr  	printf
		movea.l	#input,a5       * Eingabe des File-Namens
		clr.b	saveflag
ein2:	move.w	#1,-(sp)
		trap	#1
		addq.l	#2,sp
		move.b	d0,(a5)+
		cmpi.b	#8,d0
		beq		loesche2
		cmpi.b	#1,d0
		beq		nosave
		cmpi.b	#13,d0
		bne		ein2
		move.b	#0,-(a5)
        rts
nosave:
		move.b	#-1,saveflag
		rts

loesche2:
		clr.b	-(a5)
		clr.b	-(a5)
		bsr  	leerraum
		bra		ein2
loesche1:
		clr.b	-(a5)
		clr.b	-(a5)
		bsr  	leerraum
		bra		ein1

leerraum:
		move.w	#$0020,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.l	#4,sp
		move.w	#$0008,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.l	#4,sp
		rts

primzahl:	dc.l	0
maximal:	dc.l	0
filehandle:	dc.l	0
saveflag:	dc.w	0

primpos:	dc.b	27,'Y',46,58
freezahl:	dc.b	'        ',0,0
			even

text1:		dc.b	27,'E',27,'f'
			dc.b	'   Boolean Primzahlenprogramm',13,10,13,10
			dc.b	' Copyright by Stephan Slabihoud  1987',13,10
			dc.b	27,'Y',42,39
			dc.b	'FeldlÑnge         :',0,0
			even
text2:		dc.b	27,'Y',44,39
			dc.b	'Filename (Ctrl+A) :',0,0
			even
text3:		dc.b	27,'Y',46,39
			dc.b	'Primzahl          :',0,0
			even

zeile:
		ds.b	80
filename:
input:
		ds.b	80

feld:
		ds.w	1
		even

        end



**********************************************************************
*
*  INPUT max
*  DIM feld(max)
*  FOR i=0 to max: feld(i)=1: next i
*
*  FOR i=0 to max
*
*   IF feld(i)=1 THEN
*        prime=2*i+3
*		 PRINT USING("########");prime;
*        k=i+prime
*        IF k<=max THEN
*             FOR k=k to max
*              flag(k)=0
*			  NEXT k
*		 ENDIF
*   ENDIF
*
*  NEXT i
*
*
*  Es werden die ungeraden Zahlen von 0-n durchnummeriert !
*    [ (Zahl-3)/2 ]
*
*  Das Array feld() zeigt alle bereits berechneten Primezahlen an.
*
*  Jedes Feld des Arrays wird min. einmal durch die Ñuûere ZÑhl-
*  schleife I angesprochen. Ist das Feld[x]=0, dann wird zum nÑchsten
*  Feld Åbergegangen.
*  Wenn das Feld[x]=1 ist, dann wird die Primzahl berechnet (2*I+3=P)
*  und ausgegeben; danach wird jeder P-te Eintrag ab der aktuellen
*  Position gestrichen (auf Null gesetzt), sofern die Feldgrenze
*  noch nicht erreicht wurde.
*
**********************************************************************
