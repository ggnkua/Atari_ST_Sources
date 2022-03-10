;---------------------------------------------------------------------
;Programm-/Routinen-Name:	Line-F Emulation Driver / LFED
;						 Version 2.00
;Datum: 27.07.92
;
;Aufgabe/Kurzdoku: Line-F-Emulator fÅr die Benutzung eines MC68881
;in einem Atari ST/STE mit MC68000 (also auch der SFP004-Karte).
;Mit LFED ist die Nutzung der FPU in vollem Umfang gewÑhrleistet und
;kann von jedem Programm angesprochen werden, welches FPU-UnterstÅtzung
;verlangt. MC68030 (TT) optimierte Programme sind hiervon natÅrlich
;ausgenommen, da der MC68000 dessen InstructionSet nicht versteht!
;
;Wird ein MC68882 als FPU genutzt, mÅssen einige kleinere Anpassungen
;vorgenommen werden, da dieser an verschiedenen Stellen öbertragungen
;des PC's erwartet.

;Autor:  Roger Butenuth (c't 04/90 Seite 430 ff.)
;		 Michael Hauschild (XBRA-Erweiterungen und alle folgenden
;		 Versionen)  

;	(c)	Smart Systems '92
;		Windhornstraûe 2 / 3016 Seelze 1
;		Telefon (05137) 9 20 09
;---------------------------------------------------------------------
;Dokumentation: 
;---------------------------------------------------------------------
;Der Treiber installiert sich unter Beachtung des XBRA-Protokolls, 
;d.h. er erkennt sein Vorhandensein und gibt eine Meldung aus, falls
;versucht wird, ihn erneut zu installieren.

;Nicht unterstÅtzte FPU-Befehle:

;	FTRAP, FSAVE, FRESTORE

;Erkannte BUGS in Version 1.00:

;	FMOVEM (An),FP0-FPn  ... dieser ist eigentlich kein BUG !

;	Es tritt ein BUS-Error beim Terminieren von Programmen auf, die
;	die FPU nutzen und fÅr das Terminieren die C-Funktion return() 
;	verwenden. Der Grund hierfÅr ist ein Restore der FPU-Register
;	mit FMOVEM (diese werden am Programmbegin gesichert). Man kann
;	dieses SAUBER umgehen, indem man aus FPU-nutzenden Funktionen
;	mit exit() zurÅckkehrt (sofern man kein Funktionsergebnis
;	erwartet!) - dann sollte auch kein Bus-Error mehr auftreten 
;	(siehe FPU_TST2.C oder auch BGIDEMO.C)

;Letzte énderung:
;	19.05.92	Freigabe der Version 1.00, da der BUG mit FMOVEM und
;				return(0) "gefixt" ist!
;	27.07.92	Version 2.00 fÅr neuere TOS-Versionen (ab TOS-Version
;				1.06), in denen die	LineF nicht mehr "miûbraucht" wird.
;				In dieser Version wird keine PrÅfung mehr gemacht, ob 
;				der Trap-Aufruf aus	dem ROM oder RAM kam. Es wird 
;				grundsÑtzlich davon ausgegangen, daû dieser von einer
;				Applikation gemacht wurde!
;   09.02.94	Diverse kleinere énderungen die den Code optimieren
;				und kleiner machen. Zudem wird jetzt auch auf den
;				_FPU-Cookie getestet und bei diesem das untere Wort
;				auf 1 gesetzt. Wenn der _FPU-Cookie oder kein 68881
;				Prozessor vorhanden ist, dann installiert sich diese
;				Version auch _nicht_!
;				Es gibt unter PureC keine Probleme wenn man die
;				Compileroption '-S' setzt, anscheinend optimiert sich 
;				PureC selber raus! :-((
;									Jan Kriesten, Maus F
;												  2:244/4344@Fidonet
;												  90:400/1002@NeST

;---------------------------------------------------------------------
;ACHTUNG: bei den Assembler-Options muû -S Flag gesetzt werden 
;(wegen ReTurn from Exception / RTE) ! 

;-------------- macro - definitions ----------------------------------

.MACRO Supexec
	move.w		#38,-(sp)		;Supexec()
	trap		#14				;XBIOS
	addq.l		#6,sp			;Stack aufrÑumen
.ENDM			
		
;-------------- set FPU-register-addresses ---------------------------
	
_p_cookies	equ		$05a0.w

response 	equ 	$fffa40	;in a6 (Coprozessor-Basisregister)
control		equ		$02		;Alle weiteren Register relativ zu
save		equ		$04		;response
restore		equ		$06		
command		equ		$0a		;in a5
condition	equ		$0e
operand		equ		$10		;in a4
reg_selec	equ		$14
ins_add		equ		$18
lineF		equ		$2c		;Line-F / TRAP #11

;-------------- start of code ----------------------------------------

			.TEXT
			pea.l		Install(pc)		;Installations-Routine
			Supexec						;SVC
			cmp.l		#"LFED",d1		;ist "LFED" ?
			beq			Terminate_1		;ja -> dann terminieren
			
			bsr			getcookie		;ist _FPU-Cookie vorhanden?
			tst.b		d0				;
			beq			Terminate_2		; nicht -> dann terminieren

			move.w		4(a0), d0		;Copro Åberhaupt vorhanden?
			andi.w		#%111, d0		;
			beq			Terminate_3		;
			
			move.w		#1, 6(a0)		; LineF-UnterstÅtzung eintragen
			
start:		pea.l		titel(pc)		;Titel-Daten holen
			move.w		#9,-(sp)		;Cconws 
			trap		#1				;GEMDOS-Call
			addq.l		#6,sp			;Stack-Korrektur

			pea			mytrap(pc)		;Diesen Vektor setzen
			move.l		#$0005000B,-(sp);Setexc (BIOS 5),LineF (Exception 11) setzen
			trap		#13
			addq.l		#8, sp
			move.l		d0, oldtrap		;Alten Wert retten
						
			movea.l		4(sp),a0		;Basepageadresse holen
			move.l		#$100,d1		;BasepagelÑnge
			add.l		$0c(a0),d1		;+TextlÑnge
			add.l		$14(a0),d1		;+DatenlÑnge
			add.l		$1c(a0),d1		;+BSS-LÑnge
			move.l		d1,-(sp)		;LÑnge des belegten Speichers
			move.w		#$31,-(sp)		;an GEMDOS melden
			trap		#1
			
getcookie:
		move.l		d3, -(sp)			; Register retten
		move.l		#"_FPU", d3			;

		; Cookie Jar Adresse holen:		
		pea			.cookies(pc)		; Adresse der Funktion auf den Stack
		Supexec

		tst.l		d0					; ist Åberhaupt ein Cookie Jar vorhanden?
		beq.b		.end_search			; wenn nicht, dann zurÅck

		movea.l		d0, a0				; Adresse speichern
		moveq		#0, d0				; erstmal auf FALSE setzen

.loop:
		tst.l		(a0)				; Ende des Cookie Jars erreicht?
		beq.b		.end_search			; wenn, dann zurÅck
		
		cmp.l		(a0), d3			; Cookie gefunden?
		bne.b		.not_found			; wenn nicht, dann weitersuchen

		moveq		#1, d0				; Cookie gefunden;
		bra			.end_search			; und zurÅck
		
.not_found:
		addq.l		#8, a0				; nÑchster Cookie
		bra.b		.loop				; Schleife
		
.end_search:
		move.l		(sp)+, d3			;	Register restaurieren
		rts
		
.cookies:
		move.l		(_p_cookies), d0	; Zeiger auf den Cookie Jar
		rts								;

;-------------- XBRA-structure ---------------------------------------
			
xb_magic:	.dc.b		"XBRA"			;XBRA-Struktur vor neuem Trap
xb_id:		.dc.b		"LFED"			;XBRA-Kennung

oldtrap:	.dc.l		0				;Platz fÅr alten Line-F-Vektor

;-------------- lineF-handler -----------------------------------------

mytrap:		movem.l		d0-a6,dregs		;Register retten
			move.l		usp,a0			;USP retten
			move.l		a0,rusp			;Åber Umweg
			lea			response,a6		;#response nach A6
			lea			command(a6),a5	;#command  nach A5
			lea			operand(a6),a4	;#operand  nach A4
			lea			dregs(pc),a3	;#dregs    nach A3
			movea.l		2(sp),a0		;PC nach A0
			move.w		(a0),d1			;Kommando nach D1
again:				;-------- Einsprung fÅr weitere FPU-Befehle
			andi.w		#%111000000,d1	;Spezialteil ausmaskieren
			bne			spezial			;Ein Bit gesetzt->Spezialbefehl
			move.w		2(a0),d1		;zweiten Befehlsteil in D1 merken
			move.w		d1,(a5)			;Befehl in FPU schreiben (A3==#command)
do_ca:				;-------- Einsprung fÅr weiter Nachfragen an FPU
			move.w		(a6),d0			;Response lesen
			btst		#12,d0			;erstes Modusbit testen
			bne			rw_1x			;==1 -> springen
			btst		#11,d0			;zweites Modusbit testen
			beq.s		rw_00			;==0 -> springen
			;-------- %xxx01, Null-Primitive/Transfer Single CPU-Register
			btst		#10,d0			;Register Åbertragen?
			bne.s		rw_sngl			;JA -> Transfer Single CPU-Register
			btst		#15,d0			;CA (Come Again) gesetzt?
			bne.s		do_ca			;JA -> weiter fragen, sonst fertig
			addq.l		#4,a0			;A0 um reine BefehlslÑnge weiter
					;(Alles andere wurde in calc_add erledigt)
			move.w		(a0),d1			;erstes Befehlswort holen
			move.w		d1,d0			;und nach D0
			andi.w		#$f000,d0		;wieder COP-Befehl?
			eori.w		#$f000,d0		;
			beq.s		again			;JA -> direkt weiter machen
			move.l		a0,2(sp)		;neuen PC eintragen
			movea.l		rusp(pc),a0		;USP wieder restaurieren
			move.l		a0,usp			;wieder Åber Umweg
			movem.l		(a3),d0-a6		;Register restaurieren
			rte							;Trap beenden

rw_sngl:	andi.w		#%1110000,d1	;Registernummer ausmaskieren (nur Dn)
			lsr.w		#2,d1			;D1=Nummer*4
			move.l		(a3,d1.w),(a4)	;Register Åbertragen (a4==#operand,a3==#dregs)
			bra.s		do_ca			;danach kommt immer noch etwas
			
rw_00:		;-------- %xxx00, Transfer multiple coprocessor registers
			bsr 		calc_add		;Operandenadresse nach A1 holen
			move.w		reg_selec(a6),d4	;Registerliste nach D4 holen
			btst		#13,d0			;Dr-Bit testen
			beq.s		w_00			;==0 -> Daten in FPU schreiben
						
			btst		#12,d0			;Predekrementmodus?
			beq.s		r_pred			;==0 -> ja, springen
			
			moveq		#7,d0			;SchleifenzÑhler fÅr 8 Bits
			
.l_1:		add.w		d4,d4			;ein Bit ins Carry
			bcc.s		.l_2 			;nur bei Bit==1 etwas machen
			move.l		(a4),(a1)+		;1 (A4==#operand)
			move.l		(a4),(a1)+		;2
			move.l		(a4),(a1)+		;3 Langworte fÅr jedes Register
.l_2:		dbra		d0,.l_1			;fÅr alle 8 Bits

			bra			do_ca			;nochmal FPU befragen
			
r_pred:		moveq		#7,d0			;SchleifenzÑhler fÅr 8 Bits

.l_1:		add.w		d4,d4			;ein Bit ins Carry
			bcc.s		.l_2			;nur bei Bit==1 etwas machen
			move.l		(a4),(a1)+		;1 (A4==#operand)
			move.l		(a4),(a1)+		;2
			move.l		(a4),(a1)+		;3 Langworte fÅr jedes Register
			suba.w		#24,a1			;Dekrement durchfÅhren
.l_2:		dbra		d0,.l_1			;fÅr alle 8 Bits

			adda.w		#12,a1			;A1 wieder auf letztes Register
			move.l		a1,(a2)			;A1 als Registerinhalt abspeichern

			bra			do_ca			;Nochmal FPU fragen
			
w_00:		move.w		(a0),d0			;erstes Befehlswort holen
			andi.b		#%111000,d0		;Adressierungsart maskieren
			cmpi.b		#%011000,d0		;Gleich (An)+ ?
			beq.s		w_post			;JA -> Postinkrementmodus

			moveq		#7,d0			;SchleifenzÑhler fÅr 8 Bits

.l_1:		add.w		d4,d4			;ein Bit ins Carry
			bcc.s		.l_2			;nur bei Bit==1 etwas machen
			move.l		(a1)+,(a4)		;1 (A4==#operand)
			move.l		(a1)+,(a4)		;2
			move.l		(a1)+,(a4)		;3 Langworte fÅr jedes Register
.l_2:		dbra		d0,.l_1			;fÅr alle 8 Bits

			bra			do_ca			;Nochmal FPU fragen
			
w_post:		suba.w		#12,a1			;Inkrement von calc_add aufheben

			moveq		#7,d0			;SchleifenzÑhler fÅr 8 Bits

.l_1:		add.w		d4,d4			;ein Bit ins Carry
			bcc.s		.l_2			;nur bei Bit==1 etwas machen
			move.l		(a1)+,(a4)		;1 (A4==#operand)
			move.l		(a1)+,(a4)		;2
			move.l		(a1)+,(a4)		;3 Langworte fÅr jedes Register
.l_2:		dbra		d0,.l_1			;fÅr alle 8 Bits
			move.l		a1,(a2)			;A1 als Registerinhalt abspeichern
			
			bra			do_ca			;Nochmal FPU fragen
			
rw_1x:		btst		#11,d0			;zweites Modusbit testen
			bne.s		rw_11			;==1 -> springen (Trap, Error)
			btst		#13,d0			;DR-Bit testen
			beq.s		w_10			;==0 -> Daten an FPU schreiben
			;--------  %xx110, evaluate effective address and transfer data
			bsr			calc_add		;Operandenadresse berechnen
										;A1=Operandenadresse, d1.l=OperandenlÑnge
			cmpi.w		#2,d1			;LÑnge-2
			ble.s		r_bw			;<=2 -> Wort- oder Byteoperand
			
r_11:		move.l		(a4),(a1)+		;ein Langwort lesen (a4==#operand)
			subq.l		#4,d1			;und runterzÑhlen
			bgt.s		r_11			;>0 -> weiter Åbertragen
			bra			do_ca			;Nochmal FPU befragen
			
r_bw:		subq.b		#1,d1			;Byte?
			beq.s		r_byte			;JA!
			move.w		(a4),(a1)		;Word-Operand lesen (A4==#operand)
			bra			do_ca			;Nochmal FPU befragen
			
r_byte:		move.b		(a4),(a1)		;Byteoperand lesen (A4==#operand)
			bra			do_ca			;Nochmal FPU befragen
			
w_10:		;--------  %xx010, evaluate effective address and transfer data
			bsr			calc_add		;Operandenadresse berechnen
										;A1=Operandenadresse, d1.l=OperandenlÑnge
			cmpi.w		#2,d1			;LÑnge-2
			ble.s		w_bw			;<=2 -> Wort- oder Byteoperan
			
w_11:		move.l		(a1)+,(a4)		;Langwort schreiben (a4==#operand)
			subq.l		#4,d1			;und runterzÑhlen
			bgt.s		w_11			;>0 -> weiter Åbertragen
			bra			do_ca			;Nochmal FPU befragen
			
w_bw:		subq.b		#1,d1			;Byte?
			beq.s		w_byte			;JA!
			move.w		(a1),(a4)		;Word schreiben (A4==#operand)
			bra			do_ca			;Nochmal FPU befragen

w_byte:		move.b		(a1),(a4)		;Byte schreiben (A4==#operand)
			bra			do_ca			;Nochmal FPU befragen
			
rw_11:		;-------- %xxx11, take pre-instruction exception
			bra 		cop_error		;Error-Handler anspringen
			;(hier sollte man eine genauere Fehleranalyse machen)!
			
spezial:				;Sprungbefehle etc.
			cmpi.w		#%001000000,d1	;FScc, FDBcc oder FTRAPcc
			beq.s		s_trap
			cmpi.w		#%010000000,d1	;Branch mit 16Bit-Offset
			beq			s_br16
			eori.w		#%011000000,d1	;Branch mit 32Bit-Offset
			beq			s_br32
			bra			cop_error		;FSAVE/FRESTORE nicht unterstÅtzt
			
s_trap:		move.w		(a0),d0			;erstes Befehlswort nach D0
			move.w		d0,d1			;und nach D1 retten
			andi.w		#%111000,d0		;wichtige Bits ausmaskieren
			cmpi.w		#%001000,d0		;FDBcc?
			beq.s		s_fdbcc			;JA -> springen
			cmpi.w		#%111000,d0		;FTRAP?
			beq			cop_error		;JA -> Fehler (s.o.)
										;sonst FScc
			move.w		2(a0),condition(a6)	;Bedingung an FPU schicken
			moveq		#1,d0			;OperandenlÑnge=1 (fÅr calc_add)
			bsr			calc_add		;OperandenlÑnge berechnen
			
.l_1:		move.w		(a6),d0			;Response lesen
			btst		#8,d0			;IA-Bit testen
			beq.s		.l_2			;==0 -> fertig
			andi.w		#%1100000000000,d0	;Bit 11 und 12 ausmaskieren
			eori.w		#%1100000000000,d0	;Beide gesetzt?
			bne.s		.l_1			;nicht Beide ==1 -> warten
			bra			cop_error		;sonst Exception aufgetreten
			
.l_2:		btst		#0,d0			;Antwortbit testen
			sne			(a1)			;je nach Bit setzen/lîschen
			bra			do_ca			;nochmal FPU befragen
			
s_fdbcc:	move.w		2(a0),condition(a6)	;Bedingung an FPU schicken
			andi.w		#%111,d1		;Registernummer maskieren (D1=(A0))
			add.w		d1,d1			;D1=Nummer*4
			add.w		d1,d1			;
			lea			(a3,d1.w),a1	;A1 enthÑlt Adresse des Datenregisters
			move.l		(a1),d1			;Dn holen
			subq.w		#1,d1			;Dn=Dn-1
			move.l		d1,(a1)			;Dn zurÅckschreiben
			movea.l		a0,a2			;alten PC nach A2 holen
			addq.l		#2,a0			;PC 2 weiter (fÅr "nicht springen")
						
.l_1:		move.w		(a6),d0			;Response lesen
			btst		#8,d0			;IA-Bit testen
			beq.s		.l_2			;==0 -> fertig
			andi.w		#%1100000000000,d0	;Bit 11 und 12 ausmaskieren
			eori.w		#%1100000000000,d0	;Beide gesetzt?
			bne.s		.l_1			;nicht Beide ==1 -> warten
			bra			cop_error		;sonst Exception aufgetreten
			
.l_2:		btst		#0,d0			;Antwortbit testen
			bne			do_ca			;TRUE -> das war's schon
			adda.w		4(a2),a2		;16Bit Sprungdist. add. (A2=PC)
			addq.w		#1,d1			;Dn==1 ?
			beq			do_ca			;JA -> kein Sprung (Schleifenende)
			movea.l		a2,a0			;sonst "Sprung" (neuen PC laden)
			bra			do_ca			;nochmal FPU befragen
			
s_br16:		move.w		(a0),condition(a6)	;Bedingung an FPU schicken

.l_1:		move.w		(a6),d0			;Response lesen
			btst		#8,d0			;IA-Bit testen
			beq.s		.l_2			;==0 -> fertig
			andi.w		#%1100000000000,d0	;Bit 11 und 12 ausmaskieren
			eori.w		#%1100000000000,d0	;Beide gesetzt?
			bne.s		.l_1			;nicht Beide ==1 -> warten
			bra			cop_error		;sonst Exception aufgetreten
			
.l_2:		btst		#0,d0			;Antwortbit testen
			beq			do_ca			;FALSE -> das war's schon
			adda.w		2(a0),a0		;16Bit Sprungdistanz addieren
			subq.l		#2,a0			;ein Wort zurÅck (weil spÑter
			;noch addiert wird und nur 2 addiert werden mÅûte)
			bra			do_ca			;nochmal FPU befragen
			
s_br32:		move.w		(a0),condition(a6)	;Bedingung an FPU schicken

.l_1:		move.w		(a6),d0			;Response lesen
			btst		#8,d0			;IA-Bit testen
			beq.s		.l_2			;==0 -> fertig
			andi.w		#%1100000000000,d0	;Bit 11 und 12 ausmaskieren
			eori.w		#%1100000000000,d0	;Beide gesetzt?
			bne.s		.l_1			;nicht Beide ==1 -> warten
			bra			cop_error		;sonst Exception aufgetreten
			addq.l		#2,a0			;Befehl ist 3 Worte lang
										;(nun: (A0)=Distanz)			
.l_2:		btst		#0,d0			;Antwortbit testen
			beq			do_ca			;TRUE -> das war's schon
			adda.l		(a0),a0			;32Bit Sprungdistanz addieren
			subq.l		#4,a0			;ein Wort zurÅck (weil spÑter
			;noch addiert wird und nur 2 addiert werden mÅûte)
			bra			do_ca			;nochmal FPU befragen
			
cop_error:		;Error_Handler fÅr einen TRAP der FPU (sehr einfach gehalten).
				;Es wird ein Reset der FPU durchgefÅhrt und das aktuelle
				;Programm terminiert. Return-Code = 881.
			move.w		#0,control(a6)	;FPU-Reset (kein clr.w verwenden!)
			move.w		#881,-(sp)		;Return-Code
			move.w		#$4c,-(sp)		;Funktion Pterm(881)
			trap		#1				;des GEMDOS aufrufen
			
calc_add:
	;Operandenadresse berechnen. A0 muû die Adresse des Line-F-Befehls 
	;enthalten, D0 im unteren Byte die OperandenlÑnge. Die zu berechnende
	;Adresse wird in A1 abgelegt. A0 wird um die LÑnge der zusÑtzlichen
	;Daten erhîht. ZusÑtzlichen wird in D1 die LÑnge des Operanden zurÅck-
	;gegeben (in Bytes, als Langwort). D2, D3, A2 werden zerstîrt. Bei den
	;Adressierungsarten -(An), (An)+ steht in A2 ein Zeiger auf die Stelle,
	;in der der Inhalt des Adressregisters An steht (wird fÅr FMOVEM 
	;gebraucht).
	
			clr.l		d1				;LÑnge als Langwort lîschen
			move.b		d0,d1			;und Byte einkopieren
			move.w		(a0),d2			;Erstes Befehlswort nach D2
			move.w		d2,d3			;und nach D3 retten
			andi.w		#%111000,d3		;Adressierungsart ausmaskieren
			lsr.w		#1,d3			;D3=Adressierungsart*4 (Langworte!)
			lea			cs_tab(pc),a1	;Sprungtabellenadresse nach A1
			move.l		(a1,d3.w),a1	;Adresse der Routine nach A1
			jmp			(a1)			;und Routine anspringen
			
c_drd:		;%000	Data Register Direct:		Dn
c_ard:		;%001	Address Register Direct:	An
			lea			(a3),a1			;A1 auf Registerfeld
			andi.w		#%1111,d2		;Registernummer ausmaskieren
			;(und ein Bit vom Modus, 0 fÅr Daten-, 1 fÅr Adressregister)
			add.w		d2,d2			;D2="Registernummer"*4 (+Modusbit!)
			add.w		d2,d2			;
			addq.w		#4,d2			;+4 (fÅr OperandenlÑnge)
			sub.w		d1,d2			;wahre LÑnge abziehen
			adda.w		d2,a1			;Offset auf Registerfeldanfang add.
			rts
			
c_ari:		;%010	Address Register Indirect:	(An)
			andi.w		#%111,d2		;Registernummer ausmaskieren
			add.w		d2,d2			;D2="Registernummer"*4 
			add.w		d2,d2			;
			move.l		32(a3,d2.w),a1	;Adresse nach A1
			rts
			
c_arpo:		;%011	ARI with Postincrement:		(An)+
			andi.w		#%111,d2		;Registernummer ausmaskieren
			add.w		d2,d2			;D2="Registernummer"*4 
			add.w		d2,d2			;
			lea 		32(a3,d2.w),a2	;Adresse Adressregister nach A2
			movea.l		(a2),a1			;Adresse (Inhalt A.-Reg.) nach A1
			btst		#0,d1			;D1 ungerade? (Byteoperand)
			bne.s		.l_2			;JA -> Spezialbehandlung
			
.l_1:		add.l		d1,(a2)			;Inkrement durchfÅhren
			rts
			
.l_2:		cmpi.w		#4*7,d2			;ist A7 gemeint?
			bne.s		.l_1			;NEIN -> normal vorgehen
			addq.l		#2,(a2)			;sonst (bei Byte) 2 addieren,
			rts							;damit Stack gerade bleibt!
			
c_arpr:		;%100	ARI with Predecrement:		-(An)
			andi.w		#%111,d2		;Registernummer ausmaskieren
			add.w		d2,d2			;D2="Registernummer"*4 
			add.w		d2,d2			;
			lea 		32(a3,d2.w),a2	;Adresse Adressregister nach A2
			btst		#0,d1			;D1 ungerade? (Byteoperand)
			bne.s		.l_2			;JA -> Spezialbehandlung
			
.l_1:		sub.l		d1,(a2)			;Inkrement durchfÅhren
			movea.l		(a2),a1			;Adresse (Inhalt des A.-Reg.) nach A1
			rts
			
.l_2:		cmpi.w		#4*7,d2			;ist A7 gemeint?
			bne.s		.l_1			;NEIN -> normal vorgehen
			subq.l		#2,(a2)			;sonst (bei Byte) 2 subtrahieren,
			   							;damit Stack gerade bleibt!
			movea.l		(a2),a1			;Adresse (Inhalt A.-Reg.) nach A1
			rts
			
c_ar16:		;%101	ARI with Displacement:		d16(An)
			andi.w		#%111,d2		;Registernummer ausmaskieren
			add.w		d2,d2			;D2="Registernummer"*4 
			add.w		d2,d2
			movea.l		32(a3,d2.w),a1	;Adresse nach A1
			move.w		4(a0),d2		;3. Befehlswort nach D2 (Offset)
			adda.w		d2,a1			;Offset auf Adresse addieren
			addq.l		#2,a0			;A0 ein Wort (d16) weiter
			rts
			
c_ar08:		;%110	ARI with Index:				d8(An,Xn)
			andi.w		#%111,d2		;Registernummer ausmaskieren
			add.w		d2,d2			;D2="Registernummer"*4 
			add.w		d2,d2			;
			movea.l		32(a3,d2.w),a1	;Adresse nach A1
			move.w		4(a0),d2		;3. Befehlswort nach D2 (Offset)
			move.w		d2,d3			;und nach D3
			andi.w		#$ff,d3			;Byte ausmaskieren (Byte-Offset)
			adda.w		d3,a1			;Offset auf Adresse addieren
			btst		#11,d2			;1=long, 0=word
			bne.s		c_ar81

			rol.w		#6, d2			;Nummer von Dn und Modusbit maskieren
			andi.w		#%111100,d2		;d2=Registernummer*4 (+Modusbit)
			adda.w		2(a3,d2.w),a1	;16Bit-Index auf A1 addieren
			addq.l		#2,a0			;A0 ein Wort (Kram & d8) weiter
			rts
			
c_ar81:
			rol.w		#6, d2			;Nummer von Dn und Modusbit maskieren
			andi.w		#%111100,d2		;d2=Registernummer*4 (+Modusbit)
			adda.l		(a3,d2.w),a1	;32Bit-Index auf A1 addieren
			addq.l		#2,a0			;A0 ein Wort (Kram & d8) weiter
			rts
			
c_pc:		;%111	absolut short/long, PC-Relativ (ohne/mit Index)
			;oder direkt
			btst		#2,d2			;Immidiate?
			bne.s		immi			;!=0 -> JA
			btst		#1,d2			;PC-Relativ?
			bne.s		pc_rel			;!=0 -> JA
			btst		#0,d2			;Long?
			bne.s		c_long			;!=0 -> JA
										;sonst Short
			move.w		4(a0),d2		;Wortadresse holen,
			ext.l		d2				;Auf Langwort erweitern
			movea.l		d2,a1			;und als Operandenadresse merken
			addq.l		#2,a0			;A0 ein Wort (Short-Addr.) weiter
			rts

c_long:		movea.l		4(a0),a1		;Langwortadresse holen
			addq.l		#4,a0			;A0 zwei Worte (Long-Addr.) weiter
			rts
			
immi:		movea.l		a0,a1   		;Langwortadresse holen
			addq.l		#4,a1			;Beide Befehlsworte Åberspringen
			adda.l		d1,a0			;A0 Åber Operand hinwegsetzen
			rts
			
pc_rel:		btst		#0,d2			;mit Index?
			bne.s		pc_idx			;!=0 -> JA
			movea.l		a0,a1			;PC nach A1
			adda.w		4(a0),a1		;Offset addieren
			addq.l		#4,a1			;+4 fÅr LÑnge des FPU-Befehls
			addq.l		#2,a0			;A0 zwei (16Bit-Offset) weiter
			rts
			
pc_idx:		move.l		a0,a1			;PC nach A1
			clr.w		d2				;oberes Byte lîschen
			move.b		5(a0),d2		;Offset nach D2
			adda.w		d2,a1			;und addieren
			addq.l		#4,a1			;+4 fÅr LÑnge des FPU-Befehls
			move.b		4(a0),d2			;D2=Registernummer*16 und Modusbit
										;(high-byte ist noch 0)
			btst		#3,d2			;Long-Bit testen
			bne.s		pc_i_l			;!=0 -> Long-Index
			andi.w		#%111110000,d2	;Restinformation ausblenden
			lsr.w		#2,d2			;D2=Registernummer*4 und Modusbit
			adda.w		2(a3,d2.w),a1	;Word-Index addieren
			addq.l		#2,a0			;A0 zwei (16Bit-Offset) weiter
			rts
			
pc_i_l:		andi.w		#%111110000,d2	;Restinformation ausblenden
			lsr.w		#2,d2			;D2=Registernummer*4 und Modusbit
			adda.l		(a3,d2.w),a1	;Long-Index addieren
			addq.l		#2,a0			;A0 zwei (16Bit-Offset) weiter
			rts			;ENDE von calc_add ***

;-------------- installation-handler ---------------------------------

Install:	movea.l		lineF.w,a0 		;Vektor nach A0
        	move.l		(-12.b,a0),d0	;falls "XBRA" -> jetzt in D0
			move.l		(-8.b,a0),d1	;falls "LFED" -> jetzt in D1
			rts 
			
Terminate_1:
			pea			failure_1(pc)	;Fehlermeldung
			bra			Ende

Terminate_2:
			pea			failure_2(pc)	;Fehlermeldung
			bra			Ende

Terminate_3:
			pea			failure_3(pc)	;Fehlermeldung

Ende:
			move.w		#9,-(sp)		;Cconws
			trap		#1				;GEMDOS
			move.w		#0,-(sp)		;richtig terminieren
			trap		#1				;mit Pterm(0)/GEMDOS
						
;-------------- data-segment -----------------------------------------
			
			.DATA
			.EVEN
			
cs_tab:		.dc.l	c_drd,c_ard,c_ari,c_arpo	;Sprungtabelle fÅr
			.dc.l	c_arpr,c_ar16,c_ar08,c_pc	;Adressierungsarten

titel:      .dc.b 	10, 13, 27, 112	;CR/invers on
			.ASCII	"  Line-F-Emulation-Driver LFED  ", 10, 13 
            .ASCII	"         Version 2.00           ", 10, 13
			.dc.b	27, 113         ;invers off
			.ASCII  "    (c) by Smart Systems '92   ", 10, 13
			.ASCII  "   Michael Hauschild / Seelze  ", 10, 13
			.ASCII  "     Phone: 05137 / 9 20 09    ", 10, 13, 0

failure_1:	.dc.b	10, 13	;CR
			.ASCIIZ	" LFED already installed! "
			.dc.b	10, 13	;CR

failure_2:	.dc.b	10, 13	;CR
			.ASCIIZ	" No _FPU cookie installed! "
			.dc.b	10, 13	;CR

failure_3:	.dc.b	10, 13	;CR
			.ASCIIZ	" No coprocessor available! "
			.dc.b	10, 13	;CR

;-------------- blockstorage-segment ---------------------------------
			
			.BSS
			.EVEN

dregs:		.ds.l	(8+7)	;Platz fÅr Register (D0-D7/A0-A6)
rusp:		.ds.l	1		;Platz fÅr USP (A7)

;-------------- end of code ------------------------------------------
			.END
