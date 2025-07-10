	listing off

;****************************************************************************
;*                                                                          *
;*   AS 1.33 - Datei STDDEF51.INC      (Alfred Arnold)                      *
;*   								            *
;*   Sinn : enthÑlt SFR- und Bitdefinitionen fÅr die MCS-51-Prozessoren     *
;* 									    *
;*   letzte énderungen :  7. 1.1993                                         *
;*                       14. 1.1993 USING-Makro hinzugefÅgt   		    *
;*                       26. 1.1993 REGUSAGE-Variable ergÑnzt               *
;*			 21. 1.1993 Erzeugerhinweis			    *
;*			 25. 3.1993 Anpassung an MASS51 (SJ)		    *
;*                                                                          *
;****************************************************************************

                ifndef  stddef51inc     ; verhindert Mehrfacheinbindung

		segment data

stddef51inc     equ     1

		message	"MCS-51-SFR-Definitionen (C) 1993 Alfred Arnold"
		message "binde \{CPU}-SFRs ein"

;----------------------------------------------------------------------------
; erstmal die Sachen, die es Åberall gibt :

P0		SFRB	80H		; I/O-Ports
P1		SFRB	90H
P2		SFRB	0A0H
P3		SFRB	0B0H
RD		BIT	P3.7		; Port 3: Schreibleitung
WR		BIT	P3.6		;         Leseleitung
T1		BIT	P3.5		;	  Testleitung 1
T0		BIT	P3.4		;	  Testleitung 0
INT1		BIT	P3.3		;         ext. Interrupt 1
INT0		BIT	P3.2		;	  ext. Interrupt 0
TXD		BIT	P3.1		;	  ser. Ausgang
RXD		BIT	P3.0		;	  ser. Eingang

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SP		SFR	81H		; Stapelzeiger
DPL		SFR	82H		; Datenzeiger Bit 0..7
DPH		SFR	83H		;      "      Bit 8..15
PSW		SFRB	0D0H		; Statuswort
CY		BIT	PSW.7
AC		BIT	PSW.6
F0		BIT	PSW.5
RS1		BIT	PSW.4
RS0		BIT	PSW.3
OV		BIT	PSW.2
P		BIT	PSW.0
ACC		SFRB	0E0H		; Akkumulator
B		SFRB	0F0H		; Hilfsakku fÅr MUL/DIV

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SCON		SFRB	98H		; ser. Schnittstelle: Steuerregister
SM0		BIT     SCON.7          ; Betriebsarten
SM1		BIT     SCON.6
SM2		BIT     SCON.5
REN		BIT	SCON.4		; Empfangssperre
TB8		BIT	SCON.3		; 9. zu sendendes Bit
RB8		BIT	SCON.2		; 9. empfangenes Bit
TI		BIT	SCON.1		; Senderinterruptflag
RI		BIT	SCON.0		; EmpfÑngerinterruptflag
SBUF		SFR	99H		;  "         "        Datenregister

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PCON		SFR	87H		; "Power-Management"

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

TCON		SFRB	88H		; Timer 0/1 Steuerregister
TF1		BIT	TCON.7		; öberlauf Timer 1
TR1		BIT	TCON.6		; Timer 1 laufenlassen
TF0		BIT	TCON.5		; öberlauf Timer 0
TR0		BIT	TCON.4		; Timer 0 laufenlassen
IE1		BIT	TCON.3		; Externer Interrupt 1 aufgetreten
IT1		BIT	TCON.2		; Einstellung Triggerflanke externer Interrupt 1
IE0		BIT	TCON.1		; Externer Interrupt 0 aufgetreten
IT0		BIT	TCON.0		; Einstellung Triggerflanke externer Interrupt 0
TMOD		SFR 	89H		; Timer 0/1 Betriebsartenregister
TL0		SFR	8AH		; Daten Timer 0
TL1		SFR	8BH
TH0		SFR	8CH		; Daten Timer 1
TH1		SFR	8DH

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; kein Timer 2 beim 8051

		if	CPU<>8051
T2CON	 	 SFRB	0C8H		; Steuerregister Timer 2
TL2	 	 SFR	0CCH		; Daten Timer 2
TH2	 	 SFR	0CDH
		 if	CPU=8052
RCAP2L	 	  SFR	0CAH		; Capture-Register
RCAP2H	 	  SFR	0CBH
TF2		  BIT	T2CON.7		; Overflow Timer 2
EXF2		  BIT	T2CON.6		; Reload aufgetreten
RCLK		  BIT	T2CON.5		; Timer 2 liefert RxD-Takt
TCLK		  BIT	T2CON.4		; Timer 2 liefert TxD-Takt
EXEN2		  BIT	T2CON.3		; externer Enable Timer 2
TR2		  BIT	T2CON.2		; Timer 2 starten
CT2		  BIT	T2CON.1		; Timer 2 als ZÑhler
CPRL2		  BIT	T2CON.0		; Capture erlauben
		 elseif
CRCL		  SFR   0CAH		; andere Namen beim 80515 !!
CRCH		  SFR	0CBH
T2PS		  BIT	T2CON.7
I3FR		  BIT	T2CON.6
I2FR		  BIT	T2CON.5
T2R1		  BIT	T2CON.4
T2R0		  BIT	T2CON.3
T2CM		  BIT	T2CON.2
T2I1		  BIT	T2CON.1
T2I0		  BIT	T2CON.0
T2		  BIT	P1.7
CLKOUT		  BIT	P1.6
T2EX		  BIT	P1.5
INT2		  BIT	P1.4
INT6		  BIT	P1.3
INT5		  BIT	P1.2
INT4		  BIT	P1.1
INT3		  BIT	P1.0
CC0		  BIT	P1.0
CC1		  BIT	P1.1
CC2		  BIT	P1.2
CC3		  BIT	P1.3
                 endif
		endif

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; zusÑtzliche 80515-Register

		if	CPU=80515
P4		 SFRB	0E8H
P5		 SFRB   0F8H

CCEN		 SFR	0C1H
CCH3		 SFR	0C7H
CCL3		 SFR	0C6H
CCH2		 SFR	0C5H
CCL2		 SFR	0C4H
CCH1		 SFR	0C3H
CCL1		 SFR	0C2H

ADCON   	 SFRB	0D8H
BD		 BIT	ADCON.7
CLK		 BIT    ADCON.6
BSY		 BIT	ADCON.4
ADM		 BIT	ADCON.3
MX2		 BIT	ADCON.2
MX1		 BIT	ADCON.1
MX0		 BIT	ADCON.0
ADDAT		 SFR	0D9H
DAPR		 SFR	0DAH
		endif

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Interruptsteuerregister: nicht kompatibel zwischen 8051/52 und 80515 !!!

		if	CPU=80515
IEN0		 SFRB	0A8H
EA		 BIT	IEN0.7
WDT		 BIT	IEN0.6
ET2		 BIT	IEN0.5
ES		 BIT	IEN0.4
ET1		 BIT	IEN0.3
EX1		 BIT	IEN0.2
ET0		 BIT	IEN0.1
EX0		 BIT	IEN0.0
IEN1		 SFRB	0B8H
EXEN2		 BIT    IEN1.7
SWDT		 BIT	IEN1.6
EX6		 BIT	IEN1.5
EX5		 BIT	IEN1.4
EX4		 BIT	IEN1.3
EX3		 BIT	IEN1.2
EX2		 BIT	IEN1.1
EADC		 BIT	IEN1.0
IP0		 SFR	0A9H
IP1		 SFR	0B9H
IRCON		 SFRB	0C0H
EXF		 BIT	IRCON.7
TF2              BIT    IRCON.6
IEX6             BIT    IRCON.5
IEX5             BIT    IRCON.4
IEX4             BIT    IRCON.3
IEX3             BIT    IRCON.2
IEX2             BIT    IRCON.1
IADC             BIT    IRCON.0
                elseif
IE		 SFRB	0A8H		; Interruptfreigaben
EA		 BIT	IE.7		; generelle Interruptsperre
ES		 BIT    IE.4		; Interrupts ser. Schnittstelle freigeben
ET1		 BIT	IE.3		; Interrupt Timer 1 freigeben
EX1		 BIT	IE.2		; externen Interrupt 1 freigeben
ET0		 BIT	IE.1		; Interrupt Timer 0 freigeben
EX0		 BIT	IE.0		; externen Interrupt 0 freigeben
IP		 SFRB	0B8H		; InterruptprioritÑten
PS		 BIT	IP.4		; PrioritÑt serieller Interrupt
PT1		 BIT	IP.3		; PrioritÑt Interrupt Timer 1
PX1		 BIT	IP.2		; PrioritÑt externer Interrupt 1
PT0		 BIT	IP.1		; PrioritÑt Interrupt Timer 0
PX0		 BIT	IP.0		; PrioritÑt externer Interrupt 0
		 if 	CPU=8052
ET2		  BIT	IE.5		; Interrupt Timer 2 freigeben
PT2		  BIT	IP.5		; PrioritÑt Interrupt Timer 2
                 endif
		endif
(*
;---------------------------------------------------------------------------
; Da man die Register beim 8051 nicht direkt pushen und poppen kann, mu· man
; dies Åber direkte Adressen tun. Da dazu die Kenntnis der gewÑhlten Regis-
; terbank erforderlich ist, steht hier das Makro USING zur VerfÅgung, wel-
; ches in den Symbolen AR0..AR7 die momentanen Registeradressen ablegt.
; USING erwartet als Parameter die gewÑhlte Banknummer.

Bank0		equ	0		; nur der Schînheit halber...
Bank1		equ	1
Bank2		equ	2
Bank3		equ	3

		segment code

using		macro	bank
		if	(bank<0)||(bank>3)          ; nur 0..3 erlaubt
		 error  "Falsche Banknummer"
                endif

                ifdef	RegUsage	; BuchfÅhrung Åber benutzte BÑnke
RegUsage*	 set	RegUsage|(2^bank)
		elseif
RegUsage*	 set	2^bank
		endif

ar0*		set	bank*8		; Symbole besetzen
ar1*		set	ar0+1
ar2*		set	ar0+2
ar3*		set	ar0+3
ar4*		set	ar0+4
ar5*		set	ar0+5
ar6*		set	ar0+6
ar7*		set	ar0+7
		endm
*)
                endif

	listing =