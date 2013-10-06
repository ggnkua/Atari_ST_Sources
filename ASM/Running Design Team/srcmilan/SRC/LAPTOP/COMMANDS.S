

; struktur laptopcommand
				rsreset
LAPTOPCOMMANDARG0PTR		rs.l	1
LAPTOPCOMMANDROUTINEPTR		rs.l	1
LAPTOPCOMMANDVISIBLEFORHELP	rs.w	1


LAPTOPCOMMANDTEMPSTRINGLENGTH	equ	2048



		text


; ---------------------------------------------------------
; 06.02.00/vk
; arg0: quit
lcCmd00		lea	laptop,a0
		move.w	#1,LAPTOPQUITFLAG(a0)
		rts


; ---------------------------------------------------------
; 06.02.00/vk
; arg0: help
lcCmd01		lea	lc01Txt00,a0			; anfangstext
		lea	lcTempString,a1			; temporaeren string erstellen
		bsr	stringCopy			; ersten teil (anfangstext) kopieren

		lea	laptopCommands,a6		; array der kommando-strukturen
lcc01Loop	move.l	(a6)+,d0			; naechstes kommando (struktur) holen
		beq.s	lcc01HelpOk			; ende des array erreicht
		movea.l	d0,a2

		tst.w	LAPTOPCOMMANDVISIBLEFORHELP(a2)	; soll kommando bei der hilfe ausgedruckt werden?
		beq.s	lcc01Loop			; nein -> dann gleich ab zum naechsten

		movea.l	a1,a3				; die anfangsposition im tempstring merken
		movea.l	LAPTOPCOMMANDARG0PTR(a2),a0	; string des befehls nach a0
		bsr	stringCopy			; und diesen nach a1 kopieren
		movea.l	a3,a0				; vorherige anfangsposition nach a0
		bsr	laptopDecryptString		; und den gerade kopierten string entschluesseln

		move.b	#" ",(a1)+			; ein leerzeichen nach jedem kommando
		clr.b	(a1)

		bra.s	lcc01Loop			; bis alle kommandos abgearbeitet sind
lcc01HelpOk
		lea	lcTempString,a0			; temporaeren string nochmals holen
		bsr	laptopAppendLines		; und jetzt ausgeben

		rts


; ---------------------------------------------------------
; 06.02.00/vk
; arg0:
lcCmd02
		rts


; ---------------------------------------------------------
; 06.02.00/vk
; arg0:
lcCmd03
		rts


; ---------------------------------------------------------
; 06.02.00/vk
; arg0:
lcCmd05		lea	lc05Txt00,a0
		bsr	laptopAppendLines
		rts


; ---------------------------------------------------------
; 06.02.00/vk
; arg0:
lcCmd06		lea	lc06Txt00,a0
		bsr	laptopAppendLines
		rts


; ---------------------------------------------------------
; 06.02.00/vk
; arg0:
lcCmd07		lea	lc07Txt00,a0
		bsr	laptopAppendLines
		rts


; ---------------------------------------------------------
; 06.02.00/vk
; arg0:
lcCmd08		lea	lc08Txt00,a0
		bsr	laptopAppendLines
		rts


; ---------------------------------------------------------
; 06.02.00/vk
; arg0:
lcCmd09		lea	lc09Txt00,a0
		bsr	laptopAppendLines
		rts


; ---------------------------------------------------------
; 06.02.00/vk
; arg0:
lcCmd10		;lea	lc07Txt00,a0
		;bsr	laptopAppendLines
		rts


; ---------------------------------------------------------
; 06.02.00/vk
; arg0:
lcCmd11		;lea	lc07Txt00,a0
		;bsr	laptopAppendLines
		rts







		data



; laptop kommandos
laptopCommands	dc.l	lc00
		dc.l	lc01
		dc.l	lc02
		dc.l	lc03
		dc.l	lc04
		dc.l	lc05
		dc.l	lc06
		dc.l	lc06a
		dc.l	lc07
		dc.l	lc08
		dc.l	lc08a
		dc.l	lc09
		dc.l	lc09a

		dc.l	lcc00
		dc.l	lcc01
		dc.l	lcc02
		dc.l	lcc03
		dc.l	lcc04
		dc.l	lcc05
		dc.l	lcc06
		dc.l	lcc07
		dc.l	lcc08
		dc.l	lcc09
		dc.l	lcc10
		dc.l	lcc11
		dc.l	lcc12
		dc.l	lcc13
		dc.l	lcc14
		dc.l	lcc15
		dc.l	lcc16
		dc.l	lcc17
		dc.l	lcc18
		dc.l	lcc19
		dc.l	lcc20
		dc.l	lcc21
		dc.l	lcc22
		dc.l	lcc23
		dc.l	lcc24
		dc.l	lcc25
		dc.l	lcc26
		dc.l	lcc27
		dc.l	lcc28
		dc.l	lcc29
		dc.l	lcc30
		dc.l	lcc31
		dc.l	lcc32
		dc.l	lcc33
		dc.l	lcc34
		dc.l	lcc35
		dc.l	lcc36
		dc.l	lcc37
		dc.l	lcc38
		dc.l	lcc39
		dc.l	lcc40
		dc.l	lcc41
		dc.l	lcc42
		dc.l	lcc43
		dc.l	lcc44
		dc.l	lcc45
		dc.l	lcc46
		dc.l	lcc47
		dc.l	lcc48
		dc.l	lcc49
		dc.l	lcc50
		dc.l	lcc51
		dc.l	lcc52
		dc.l	lcc53
		dc.l	lcc54
		dc.l	lcc55
		dc.l	lcc56
		dc.l	lcc57
		dc.l	lcc58
		dc.l	lcc59
		dc.l	lcc60
		dc.l	lcc61
		dc.l	lcc62
		dc.l	lcc63
		dc.l	lcc64

		dc.l	0

lc00		dc.l	lcCmdString00
		dc.l	lcCmd00
		dc.w	1
lcCmdString00	dc.b	xQ,xU,xI,xT,0
		even

lc01		dc.l	lcCmdString01
		dc.l	lcCmd01
		dc.w	1
lcCmdString01	dc.b	xH,xE,xL,xP,0
		even

lc02		dc.l	lcCmdString02
		dc.l	lcCmd02
		dc.w	1
lcCmdString02	dc.b	xL,xI,xN,xK,0
		even

lc03		dc.l	lcCmdString03
		dc.l	lcCmd03
		dc.w	1
lcCmdString03	dc.b	xC,xO,xN,xN,xE,xC,xT,0
		even

lc04		dc.l	lcCmdString04
		dc.l	lcCmd00				; mit quit gleichgesetzt
		dc.w	1
lcCmdString04	dc.b	xE,xX,xI,xT,0
		even

lc05		dc.l	lcCmdString05
		dc.l	lcCmd05
		dc.w	1
lcCmdString05	dc.b	xD,xI,xR,0
		even

lc06		dc.l	lcCmdString06
		dc.l	lcCmd06
		dc.w	0
lcCmdString06	dc.b	xA,xU,xT,xO,xE,xX,xE,xC,0
		even

lc06a		dc.l	lcCmdString06a
		dc.l	lcCmd06
		dc.w	0
lcCmdString06a	dc.b	xA,xU,xT,xO,xE,xX,xE,xC,LAPTOPCODENUMBER-".",xB,xA,xT,0
		even

lc07		dc.l	lcCmdString07
		dc.l	lcCmd07
		dc.w	0
lcCmdString07	dc.b	xC,xD,0

lc08		dc.l	lcCmdString08
		dc.l	lcCmd08
		dc.w	0
lcCmdString08	dc.b	xM,xK,xD,xI,xR,0

lc08a		dc.l	lcCmdString08a
		dc.l	lcCmd08
		dc.w	0
lcCmdString08a	dc.b	xM,xD,0

lc09		dc.l	lcCmdString09
		dc.l	lcCmd09
		dc.w	0
lcCmdString09	dc.b	xR,xM,xD,xI,xR,0

lc09a		dc.l	lcCmdString09a
		dc.l	lcCmd09
		dc.w	0
lcCmdString09a	dc.b	xR,xD,0



;lc		dc.l	lcCmdString
;		dc.l	lcCmd
;		dc.w	1
;lcCmdString	dc.b	,0


;mlc4		dc.b	H,E,L,P,0
;mlc5		dc.b	L,S,0
;mlc6		dc.b	A,U,T,O,E,X,E,C,0
;mlc7		dc.b	A,U,T,O,E,X,E,C,180-".",B,A,T,0
;mlc8		dc.b	C,D,SPC,S,Y,S,T,E,M,0
;mlc9		dc.b	V,E,R,S,i,O,N,0
;mlc10		dc.b	W,H,O,SPC,180-"-",A,0
;
;mlc12		dc.b	H,E,L,P,SPC,L,i,N,K,0
;mlc13		dc.b	H,E,L,P,SPC,C,O,N,N,E,C,T,0
;mlc15		dc.b	H,E,L,P,SPC,C,D,0
;mlc16		dc.b	H,E,L,P,SPC,D,i,R,0
;mlc17		dc.b	H,E,L,P,SPC,E,X,i,T,0
;mlc18		dc.b	S,A,V,E,0
;mlc19		dc.b	R,D,T,H,G,H,T,0
;mlc20		dc.b	D,O,U,B,L,E,SPC,V,B,L,0
;mlc21		dc.b	S,T,A,T,U,S,0
;mlc22		dc.b	S,E,T,A,N1,0
;mlc23		dc.b	S,E,T,A,N2,0
;		even


		IFEQ LANGUAGE
lc01Txt00	dc.b	"Available commands: ",0
lc05Txt00	dc.b	"Disk in drive C: is RUNNING",13
		dc.b	"Serialnumber: 0C90-BECC",13,13
		dc.b	"Contents of C:\",13,13
		dc.b	"21.01.2000  11:58  <DIR>          BIN",13
		dc.b	"18.01.2000  23:42  <DIR>          ETC",13
		dc.b	"21.01.2000  10:17  <DIR>          SBIN",13
		dc.b	"19.12.1999  08:23  <DIR>          USR",13
		dc.b	"10.10.1999  04:45  <DIR>          VAR",13
		dc.b	"04.06.1998  03:34           6.361 autoexec.bat",13
		dc.b	"15.01.1999  01:34           1.273 boot.ini",13
		dc.b	"14.08.1999  10:54          34.945 config.sys",13
		dc.b	"11.01.2000  04:23         754.510 vmlinuz",0
lc06Txt00	dc.b	"Disk cache is off.",13
		dc.b	"Smartdrive enabled.",13
		dc.b	"Mode con page: 49x90.",0
lc07Txt00	dc.b	"Directory change not permitted.",0
lc08Txt00	dc.b	"Directory could not be created.",0
lc09Txt00	dc.b	"Directory could not be deleted.",0
		ELSE
lc01Txt00	dc.b	"Verwendbare Befehle: ",0
lc05Txt00	dc.b	"Datentraeger in Laufwerk C: ist RUNNING",13
		dc.b	"Datentraegernummer: 0C90-BECC",13,13
		dc.b	"Verzeichnis von C:\",13,13
		dc.b	"21.01.2000  11:58  <DIR>          BIN",13
		dc.b	"18.01.2000  23:42  <DIR>          ETC",13
		dc.b	"21.01.2000  10:17  <DIR>          SBIN",13
		dc.b	"19.12.1999  08:23  <DIR>          USR",13
		dc.b	"10.10.1999  04:45  <DIR>          VAR",13
		dc.b	"04.06.1998  03:34           6.361 autoexec.bat",13
		dc.b	"15.01.1999  01:34           1.273 boot.ini",13
		dc.b	"14.08.1999  10:54          34.945 config.sys",13
		dc.b	"11.01.2000  04:23         754.510 vmlinuz",0
lc06Txt00	dc.b	"Disk cache is off.",13
		dc.b	"Smartdrive enabled.",13
		dc.b	"Mode con page: 49x90.",0
lc07Txt00	dc.b	"Verzeichniswechsel nicht erlaubt.",0
lc08Txt00	dc.b	"Verzeichnis konnte nicht erstellt werden.",0
lc09Txt00	dc.b	"Verzeichnis konnte nicht geloescht werden.",0
		ENDC
		even


; kommando nicht gefunden
				IFEQ LANGUAGE
laptopCommandNotFoundTxt	dc.b	"Command not found.",0
				ELSE
laptopCommandNotFoundTxt	dc.b	"Der Befehl ist entweder falsch geschrieben (z. B. Gross-/Kleinschreibung) oder konnte nicht gefunden werden.",0
				ENDC
				even


		bss

lcTempString	ds.b	LAPTOPCOMMANDTEMPSTRINGLENGTH
