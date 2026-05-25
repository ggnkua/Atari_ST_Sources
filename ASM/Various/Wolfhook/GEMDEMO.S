
* Ein GEM-Demo-Programm

* Sie kînnen Teile oder alles aus diesem Programm verwenden

* Es soll hauptsÑchlich der GEM-Aufruf in Assembler
* gezeigt werden. Das Programm selbst tut nicht allzuviel.        

* Letzte énderung: 27.1.86

	opt d+				Labels fÅr Debugger

* Der Include-File ist wichtig, soll aber nicht
	bra main			ausgefÅhrt werden

	include geminc.s

* the program proper
main	do_start			Init. RAM und Stack
	bsr initvdipars			und die VDI-Arrays
	bsr initgempars			und die AES-Arrays
	gem APPL_INIT
	move.w d0,ap_id(a6)		Applikations-ID sichern
* Hole Handle der aktuellen Workstation
	gem GRAF_HANDLE
	move.w d0,contrl+12(a6)         da ist Handle sicher
* und îffne damit virtuelle Workstation
	move.l #$00010001,d0
	move.l d0,intin(a6)		Die meisten Parameters = 1
	move.l d0,intin+4(a6)
	move.l d0,intin+8(a6)
	move.l d0,intin+12(a6)
	move.l d0,intin+16(a6)
	move.w #2,intin+20(a6)		RC-System muû sein
	clr.w contrl+2(a6)
	move.w #11,contrl+6(a6)
	vdi V_OPNVWK			Nun îffnen
	move.w contrl+12(a6),d0		Die Handle
	move.w d0,ws_handle(a6)		sichern

* Mauszeiger soll Pfeil werden
	clr.w int_in(a6)		0 heiût Pfeil
	clr.l addr_in(a6)
	gem GRAF_MOUSE

* Wir wollen ein Window îffnen, benîtigen dafÅr Grîûe der Workstation
	clr.w int_in(a6)		0 = Desktop-Handle
	move.w #4,int_in+2(a6)		Funktion "Bereich holen"
	gem WIND_GET			hole seine Grîûe

* Bits fÅr Window-Typ
wtype	equ %000000101111		title, close, full, move, size

* Grîûe ist in int_out(1..4), rechne Window-Grîûe
	move.w #1,int_in(a6)		Bereich festlegen
	move.w #wtype,int_in+2(a6)	Window mit allen Features
	movem.w int_out+2(a6),d0-d3     Grîûe von Workstation
	movem.w d0-d3,int_in+4(a6)	     Åbergeben
	gem WIND_CALC                   GEM rechnet fÅr uns

* Nun hole Offsets des Windows
	move.w int_out+2(a6),xstart(a6)
	move.w int_out+4(a6),ystart(a6)
	move.w int_out+6(a6),xwidth(a6)
	move.w int_out+8(a6),ywidth(a6)

* und kreiere da Window
	move.w #wtype,int_in(a6)	alle Features
	movem.w int_out+2(a6),d0-d3
	movem.w d0-d3,int_in+2(a6)	die Grîûe
	gem WIND_CREATE			Funktion aufrufen
	move.w d0,w_handle(a6)		Handle sichern

* Fenster-Titel setzen
	move.w d0,int_in(a6)            Handle
	move.w #2,int_in+2(a6)		Titel-String setzen
	lea windowname(pc),a0
	move.l a0,int_in+4(a6)		Die Addresse
	gem WIND_SET

* Nun zeige das Fenster, indem es geîffnet wird
	move.w w_handle(a6),int_in(a6)
	movem.w xstart(a6),d0-d3
	add.w #10,d0			X-Start
	add.w #10,d1			Y-Start
	sub.w #20,d2			Breite
	sub.w #20,d3			Hîhe
	movem.w d0-d3,int_in+2(a6)	Grîûe
	gem WIND_OPEN			ôffne es
	bsr recalcwindow
	bsr setupmode

* Die Hauptschleife
* Wir warten nur auf Events vom Typ Message
waitforevent
	lea messagebuf(a6),a0
	move.l a0,addr_in(a6)
	gem EVNT_MESAG			Hole die  Message
	lea messagebuf(a6),a0
	move.w (a0),d0			Message-Typ
	cmp.w #20,d0
	beq updateit			wenn Redraw
	cmp.w #22,d0
	beq quit			wenn Close-Box
	cmp.w #23,d0
	beq fullit			wenn volle-Grîûe-Box
	cmp.w #27,d0
	beq sizeit			wenn Grîûen-Box
	cmp.w #28,d0
	beq moveit			wenn Window verschoben

* nichts, was mich interessiert, also von vorn
	bra waitforevent

* Window verschieben
moveit	move.w 6(a0),d0
	cmp.w w_handle(a6),d0
	bne waitforevent		wenn nicht mein Window, nicht
changedwindow
	move.w d0,int_in(a6)
	move.w #5,int_in+2(a6)
	move.w 8(a0),int_in+4(a6)	neues x 
	move.w 10(a0),int_in+6(a6)	neues y 
	move.w 12(a0),d0
	cmp.w #40,d0
	bcc.s widok
	moveq #40,d0			nicht schmaler als 40
widok	move.w d0,int_in+8(a6)		Breite
	move.w 14(a0),d0
	cmp.w #50,d0
	bcc.s hiteok
	moveq #50,d0			nicht flacher als 50
hiteok	move.w d0,int_in+10(a6)		Hîhe
	gem WIND_SET			setze Window
	movem.w xwidth(a6),d4-d5	alte Grîûe
	bsr recalcwindow
	cmp.w xwidth(a6),d4
	bcs waitforevent
	cmp.w ywidth(a6),d5
	bcs waitforevent
	bne.s forceupdate
	cmp.w xwidth(a6),d4
	beq waitforevent		nicht, wenn das gleiche
* Wenn neue Grîûe kleiner in beiden Dimensionen als alte Grîûe,
* wird ein Update-Event nicht beachtet. Daher  muû "re-draw" 
* programmiert werden!
forceupdate
	bsr drawwindow			zeichne Window
	bra waitforevent		und zur Hauptschleife

* Neue Grîûe fÅr Window
sizeit	move.w 6(a0),d0
	cmp.w w_handle(a6),d0
	bne waitforevent		wenn nicht mein Window
	bra.s changedwindow

* Da ist ein  Update-Event
updateit
	move.w 6(a0),d0
	cmp.w w_handle(a6),d0
	bne waitforevent		wenn nicht mein Window
* Es gibt zwei Arten Updates zu behandeln:
* (a) fÅr Åberlappende  Windows,
* was viele Code braucht, langsam und tricky ist.
* (b) Die Mîglichkeit des öberlappens zu ignorieren,
* was wenig Code braucht und einfach ist.
* Wir nehmen Methode (b)! Methode (a) ist im Window-Kapitel
* des DR-GEM-Manuals beschrieben.

* Beginne mit Clipping des Rechtecks
	movem.w 8(a0),d0-d3		das Rechteck
	add.w d0,d2
	add.w d1,d3
	movem.w d0-d3,ptsin(a6)
	move.w #2,contrl+2(a6)
	move.w #1,contrl+6(a6)
	move.w ws_handle(a6),contrl+12(a6)
	st intin(a6)			Clipping an
	vdi VS_CLIP			und "Clippe"
	bsr drawwindow			Window zeichnen
	bra waitforevent

* Die Box "volle Grîûe" wurde angeklickt
* Unser Programm malt dann eine Alarm-Box
fullit
	move.w #1,int_in(a6)		1. Knopf = Return
	lea myalert(pc),a0
	move.l a0,addr_in(a6)		 alert definition
	gem FORM_ALERT
	bra waitforevent

* Nun die RÅckzugsgefechte
* Beginne mit Schlieûen des Fensters
quit	move.w w_handle(a6),int_in(a6)
	gem WIND_CLOSE			schlieûen
	gem WIND_DELETE			und lîschen
* Nun Schlieûen der  virtuellen Workstation
	clr.w contrl+2(a6)
	clr.w contrl+6(a6)
	move.w ws_handle(a6),contrl+12(a6)
	vdi V_CLSVWK			schlieûe
	gem APPL_EXIT			sage GEM, wir sind fertig
* Nun zurÅck zum Desk Top
	clr.w -(a7)			Status-Code
	move.w #$4c,-(a7)		P_TERM
	trap  #1		       und Ende

* Rechne Work érea des Windows
recalcwindow
	move.w w_handle(a6),int_in(a6)
	move.w #4,int_in+2(a6)		work area ermitteln
	gem WIND_GET
	movem.w int_out+2(a6),d0-d3
	movem.w d0-d3,xstart(a6)
	rts

* Male den Fenster-Inhalt
* Wird ein Oval in einem Rechteck

* Vor dem Zeichnen immer Mauszeiger abschalten
drawwindow
	clr.l contrl+2(a6)
	move.w ws_handle(a6),contrl+12(a6)
	vdi V_HIDE_C			Verstecke Maus
	clr.w contrl+2(a6)
	move.w #1,contrl+6(a6)
	move.w #2,intin(a6)		Pattern bitte
	vdi VSF_INTERIOR
	move.w #2,contrl+2(a6)
	clr.w contrl+6(a6)
	move.w ws_handle(a6),contrl+12(a6)
	movem.w xstart(a6),d0-d3
	add.w d0,d2
	subq.w #1,d2
	add.w d1,d3
	subq.w #1,d3
	movem.w d0-d3,ptsin(a6)		Das Rechteck
	vdi VR_RECFL			GefÅlltes Rechteck
* Das Oval, in das unser Pattern soll
	clr.w contrl+2(a6)
	move.w #1,contrl+6(a6)
	move.w #4,intin(a6)
	vdi VSF_INTERIOR		FÅll-Stil
	move.w #2,contrl+2(a6)
	clr.w contrl+6(a6)
	move.w #5,contrl+10(a6)
	move.w ws_handle(a6),contrl+12(a6)
	movem.w xstart(a6),d0-d3
	asr.w #1,d2			Halbe Breite
	asr.w #1,d3			Halbe Hîhe
	add.w d2,d0			X-Mitte
	add.w d3,d1			Y-Mitte
	movem.w d0-d3,ptsin(a6)
	vdi V_GDP			GDP-Ellipse
* Zeichnen fertig, also Maus wieder an
	clr.w contrl+2(a6)
	move.w #1,contrl+6(a6)
	clr.w intin(a6)
	vdi V_SHOW_C			Zeige Mauszeiger
	rts

* Hier wird der Zeichenmodus vorbereitet u.s.w.
setupmode
	clr.w contrl+2(a6)
	move.w #16,contrl+6(a6)
	move.w ws_handle(a6),contrl+12(a6)
	move.w #%0000100101000000,intin(a6)
	move.w #%0000100101000000,intin+2(a6)
	move.w #%0000111101000000,intin+4(a6)
	move.w #%0000100101000000,intin+6(a6)
	move.w #%0000100101000000,intin+8(a6)
	move.w #%0000000000000000,intin+10(a6)
	move.w #%0110010011011100,intin+12(a6)
	move.w #%1000101010001000,intin+14(a6)
	move.w #%1100101011001000,intin+16(a6)
	move.w #%0010101010001000,intin+18(a6)
	move.w #%1100010010001000,intin+20(a6)
	clr.l intin+22(a6)
	clr.l intin+26(a6)
	clr.w intin+30(a6)
	vdi VSF_UDPAT			setze unser FÅllmuster
	clr.w contrl+2(a6)
	move.w #1,contrl+6(a6)
	move.w #1,intin(a6)
	vdi VSF_COLOR			Nehme "Farbe" 1
	rts

* Alle C-Strings mÅssen 0-terminiert sein
windowname dc.b ' Ein GEM-Beispielprogramm von HiSoft ',0

myalert dc.b "[1][Dieses Programm ist in 68000-|Assembler mit HiSofts|"
	dc.b 'DevpacST Entwicklungssystem|geschrieben worden][ OK ]',0

* globale Variable, Zugriff Åber A6

* Diese mÅssen zusammenbleiben
xstart	rs.w 1
ystart	rs.w 1
xwidth	rs.w 1
ywidth	rs.w 1

w_handle	rs.w 1
ws_handle	rs.w 1
ap_id		rs.w 1
messagebuf	rs.b 16

datalength	rs.w 0			unbedingt erforderlich

* Hier Daten, Zugriff Åber A6
datastart	nop

	end




