 ;*******************************************************
 ;***                                                 ***
 ;***         Allgemeines Programm zur Arbeit mit     ***
 ;***             VDI-Funktionen und Befehlen         ***
 ;***         -----------------------------------     ***
 ;***                                                 ***
 ;***             (c) 1987 by Klaus Lîffelmann        ***
 ;***            ==============================       ***
 ;***                                                 ***
 ;*******************************************************

        move.l sp,a5                              ;Stackpointer retten
        move.l 4(a5),a5                           ;BASE-PAGE nach a5
        move.l $c(a5),d0                          ;Text-Segment
        add.l $14(a5),d0                          ;initialisierte Daten
        add.l $1c(a5),d0                          ;uninitialisierte Daten
        add.l #$500,d0                            ;Stack
        move.l d0,d1                              ;Ergebnis nach d1
        add.l a5,d1                               ;BASE-PAGE addieren
        and.l #-2,d1                              ;nur gerade Adressen
        move.l d1,a7                              ;Ergebnis ist neuer Stack
        move.l d0,-(sp)                           ;zu reservierender Bereich
        move.l a5,-(sp)                           ;Adresse dieses Bereichs
        clr.w -(sp)                               ;Dummy
        move #$48,-(sp)                           ;Funktionsnummer
        trap #1                                   ;SET BLOCK aufrufen
        add.l #12,sp                              ;Stack korrigieren

        jsr init                                  ;Workstation îffnen
        jsr haupt                                 ;Hauptprogramm aufrufen
        jsr close                                 ;Workstation schlieûen

        clr.w -(sp)                               ;Programm beenden
        trap #1

 ;***************************************************
 ;*** Hier kann das eigentliche Programm beginnen ***
 ;***************************************************

haupt:  move #3,-(sp)                       ; Schreibmodus = Invers
        jsr vswr_mode
        move #5,d3
hlab1:  move #0,d0                          ; Linien-Demonstration:
        move #639,d1
hlab2:  move d0,-(sp)
        move #0,-(sp)
        move d1,-(sp)
        move #399,-(sp)
        jsr line
        add.l #8,sp
        addq #1,d0
        dbra d1,hlab2
        dbra d3,hlab1
        rts

 ;***************************************************
 ;*** Hier folgen die Routinen der VDI-Library ******
 ;***************************************************

 ;*** Workstation îffnen ***

init:   move.w #10,contrl
        clr.w intin
        clr.w addrin
        clr.l ap1
        clr.l ap2
        clr.l ap3
        clr.l ap4
        jsr aes                                   ; Applikation anmelden

        move #77,contrl                           ; GRAF_HANDLE
        clr intin
        clr addrin
        jsr aes
        move intout,handle                        ; HANDLE abspeichern

        move #100,contrl                          ; Control-Code fÅr
        clr ptsin                                 ; OPNVWK
        lea int_in,a0
        move #10,d0                               ; INT_IN-Array fÅllen
loop1:  move #1,(a0)+
        dbra d0,loop1

        move #2,int_in+20
        jmp vdi                                   ; Workstation îffnen

 ;*** Workstation schlieûen ***

close:  move #101,contrl                          ; Opcode 101
        clr.l ptsin                               ; keine Parameter
        clr.l intin
        jmp vdi                                   ; an VDI Åbergeben

 ;*** Workstation lîschen ***

v_clrwk:move #3,contrl                            ; Opcode 3
        clr.l ptsin                               ; keine Parameter
        clr.l intin
        jmp vdi                                   ; an VDI Åbergeben

 ;*************************************
 ;*** Set Clipping Rectangle **********
 ;*************************************

vs_clip:link a6,#0
        move #129,contrl                          ; Opcode 129
        move #2,ptsin                             ; Anzahl Punkte in PTS_IN
        move #1,intin                             ; Anzahl Parameter in INT_IN
        move 16(a6),int_in                        ; Flag
        move 14(a6),pts_in                        ; Koordinaten des Rechtecks
        move 12(a6),pts_in+2
        move 10(a6),pts_in+4
        move 8(a6),pts_in+6
        jsr vdi                                   ; VDI aufrufen
        unlk a6
        rts

 ;************************************
 ;*** Linie zeichnen *****************
 ;************************************

line:   link a6,#0
        move #6,contrl                            ; Opcode 6
        move #2,ptsin
        clr intin
        move 14(a6),pts_in                        ; Anfangs- und
        move 12(a6),pts_in+2
        move 10(a6),pts_in+4                      ; Endkoordinaten der
        move 8(a6),pts_in+6                       ; Linie
        jsr vdi                                   ; POLYLINE aufrufen
        unlk a6
        rts

 ;*******************************
 ;*** Polyline ******************
 ;*******************************

v_pline:move #6,contrl                            ; Opcode 6
        move 8(a6),ptsin                          ; Anzahl Punkte vom Stack
        clr intin
        jsr vdi                                   ; POLYLINE aufrufen

 ;*******************************
 ;*** Polymarker ****************
 ;*******************************

v_pmarker:link a6,#0
        move #7,contrl                          ; Opcode 7
        move 8(a6),ptsin                          ; Anzahl Markierungen
        clr intin
        jsr vdi
        unlk a6
        rts

 ;********************************
 ;*** Text ***********************
 ;********************************

v_gtext:link a6,#0
        move #8,contrl                            ; Opcode 8
        move 14(a6),pts_in                        ; X-Koordinate
        move 12(a6),pts_in+2                      ; Y-Koordinate
        move #1,ptsin                             ; Anzahl Koordinaten
        move.l 8(a6),a0                           ; Adresse des Textes
        lea int_in,a1
        clr d0
vgtlp:  addq #1,d0
        addq.l #1,a1
        move.b (a0)+,(a1)+                        ; Text umschaufeln
        beq vgtlpe
        jmp vgtlp
vgtlpe: subq #1,d0
        move d0,intin
        jsr vdi
        unlk a6
        rts

 ;*******************************
 ;*** Filled Area ***************
 ;*******************************

v_fillarea:link a6,#0
        move #9,contrl                            ; Opcode 9
        move 8(a6),ptsin                         ; LÑnge PTSIN
        clr intin                                 ; INTIN = 0
        jsr vdi
        unlk a6
        rts

 ;********************************
 ;*** Contour Fill ***************
 ;********************************

v_contourfill:link a6,#0
        move #103,contrl                          ; Opcode 103
        move #1,ptsin                             ; 1 Koordinate
        move #1,intin                             ; Farbenflag
        move 12(a6),int_in                        ; schreiben
        move 10(a6),pts_in                        ; X-Koordinate
        move 8(a6),pts_in+2                       ; Y-Koordinate
        jsr vdi
        unlk a6
        rts

 ;*********************************
 ;*** Fill Rectangle **************
 ;*********************************

vr_recfl:link a6,#0
        move #114,contrl
        move #2,ptsin
        clr intin
        move 14(a6),pts_in                        ; X- und
        move 12(a6),pts_in+2                      ; Y-Koordinate links, oben
        move 10(a6),pts_in+4                      ; X- und
        move 8(a6),pts_in+6                       ; Y-Koordinate rechts, unten
        jsr vdi
        unlk a6
        rts

 ;*********************************
 ;*** Bar *************************
 ;*********************************

v_bar:  link a6,#0
        move #11,contrl                           ; Opcode 11
        move #2,ptsin                             ; 2 Koordinaten
        clr intin
        move #1,scode                             ; Subcode 1
        move 14(a6),pts_in
        move 12(a6),pts_in+2
        move 10(a6),pts_in+4
        move 8(a6),pts_in+6
        jsr vdi
        unlk a6
        rts

 ;*********************************
 ;*** Arc *************************
 ;*********************************

v_arc:  link a6,#0
        move #11,contrl
        move #4,ptsin
        move #2,intin
        move #2,scode
        clr.l ptsin+4
        clr ptsin+10
        clr ptsin+14
        move 16(a6),ptsin                         ; X-Mittelpunkt
        move 14(a6),ptsin+2                       ; Y-Mittelpunkt
        move 12(a6),ptsin+12                      ; Radius
        move 10(a6),intin                         ; Anfangswinkel
        move 8(a6),intin+2                        ; Endwinkel
        jsr vdi
        unlk a6
        rts

 ;********************************
 ;*** Pie ************************
 ;********************************

v_pieslice:link a6,#0
        move #11,contrl
        move #4,ptsin
        move #2,intin
        move #3,scode
        move 16(a6),ptsin                         ; X-Mittelpunkt
        move 14(a6),ptsin+2                       ; Y-Mittelpunkt
        clr.l ptsin+4
        clr ptsin+10
        clr ptsin+14
        move 12(a6),ptsin+12                      ; Radius
        move 10(a6),intin                         ; Anfangswinkel
        move 8(a6),intin+2                        ; Endwinkel
        jsr vdi
        unlk a6
        rts

 ;*********************************
 ;*** Circle **********************
 ;*********************************

v_circle:link a6,#0
        move #11,contrl
        move #3,ptsin
        clr intin
        move #4,scode
        move 12(a6),pts_in                        ; Kreismittelpunkt
        move 10(a6),pts_in+2
        clr.l pts_in+4
        move 8(a6),pts_in+8                       ; Kreis-Radius
        clr pts_in+10
        jsr vdi                                   ; VDI aufrufen
        unlk a6
        rts

 ;**********************************
 ;*** Ellipse **********************
 ;**********************************

v_ellipse:link a6,#0
        move #11,contrl
        move #2,ptsin
        clr intin
        move #5,scode
        move 14(a6),pts_in                        ; Kreis-Mittelpunkt
        move 12(a6),pts_in+2
        move 10(a6),pts_in+4                      ; X-Radius
        move 8(a6),pts_in+6                       ; Y-Radius
        jsr vdi
        unlk a6
        rts

 ;**********************************
 ;*** Elliptical Arc ***************
 ;**********************************

v_ellarc:link a6,#0
        move #11,contrl
        move #2,ptsin
        move #2,intin
        move #6,scode
        move 18(a6),pts_in                        ; Mittelpunkt X
        move 16(a6),pts_in+2                      ; Mittelpunkt Y
        move 14(a6),pts_in+4                      ; Radius X
        move 12(a6),pts_in+6                      ; Radius Y
        move 10(a6),intin                         ; Anfangswinkel
        move 8(a6),intin+2                        ; Endwinkel
        jsr vdi
        unlk a6
        rts

 ;***********************************
 ;*** Elliptical Pie ****************
 ;***********************************

v_ellpie:link a6,#0
        move #11,contrl
        move #2,ptsin
        move #2,intin
        move #7,scode
        move 18(a6),pts_in                        ; Mittelpunkt X
        move 16(a6),pts_in+2                      ; Mittelpunkt Y
        move 14(a6),pts_in+4                      ; Radius X
        move 12(a6),pts_in+6                      ; Radius Y
        move 10(a6),intin                         ; Anfangswinkel
        move 8(a6),intin+2                        ; Endwinkel
        jsr vdi
        unlk a6
        rts

 ;********************************
 ;*** Rounded Rectangle **********
 ;********************************

v_rbox: link a6,#0
        move #11,contrl
        move #2,ptsin
        clr intin
        move #8,scode
        move 14(a6),pts_in                        ; Linke, obere Ecke
        move 12(a6),pts_in+2
        move 10(a6),pts_in+4                      ; Rechte, untere Ecke
        move 8(a6),pts_in+6                       ; des Rechtecks
        jsr vdi
        unlk a6
        rts

 ;********************************
 ;*** Filles Rounded Rectangle ***
 ;********************************

v_rfbox:link a6,#0
        move #11,contrl
        move #2,ptsin
        clr intin
        move #9,scode
        move 14(a6),pts_in                        ; Linke, obere Ecke
        move 12(a6),pts_in+2
        move 10(a6),pts_in+4                      ; Rechte, untere Ecke
        move 8(a6),pts_in+6                       ; des Rechtecks
        jsr vdi
        unlk a6
        rts

 ;*******************************
 ;*** Justified Graphics Text ***
 ;*******************************

v_justified:link a6,#0
        move #11,contrl
        move #2,ptsin
        move #2,intin
        move 20(a6),pts_in                        ; X-Koordinate
        move 18(a6),pts_in+2                      ; Y-Koordinate
        move 16(a6),pts_in+4                      ; LÑnge
        move 14(a6),int_in                        ; word_space
        move 12(a6),int_in+2                      ; char_space
        move.l 8(a6),a0
        lea int_in+4,a1
        clr d0
vjulp:  addq #1,d0
        addq.l #1,a1
        move.b (a0)+,(a1)+                        ; Text umschaufeln
        beq vjulpe
        jmp vjulp
vjulpe: subq #1,d0
        add d0,intin
        jsr vdi
        unlk a6
        rts

 ;*******************************
 ;*** Set Writing Mode **********
 ;*******************************

vswr_mode:link a6,#0
        move #32,contrl
        move #0,ptsin
        move #1,intin
        move 8(sp),int_in
        jsr vdi
        unlk a6
        rts

 ;********************************
 ;*** Set Color Representation ***
 ;********************************

vs_color:link a6,#0
        move #14,contrl
        clr ptsin
        move #4,intin
        move 14(a6),int_in                        ; Farbindex
        move 12(a6),int_in+2                      ; Rot-Anteil
        move 10(a6),int_in+4                      ; GrÅn-Anteil
        move 8(a6),int_in+6                       ; Blau-Anteil
        jsr vdi
        unlk a6
        rts

 ;********************************
 ;*** Set Polyline Color Index ***
 ;********************************

vsl_color:link a6,#0
        move #17,contrl
        clr ptsin
        move #1,intin
        move 8(a6),int_in                         ; Farbnummer
        jsr vdi
        unlk a6
        rts

 ;*********************************
 ;*** Set Polyline Line Type ******
 ;*********************************

vsl_type:link a6,#0
        move #15,contrl
        clr ptsin
        move #1,intin
        move 8(a6),int_in                         ; Linienstil
        jsr vdi
        unlk a6
        rts

 ;*******************************************
 ;*** Set User-Defined Line Style Pattern ***
 ;*******************************************

vsl_udsty:link a6,#0
        move #16,contrl
        clr intin
        move #1,ptsin
        move 8(sp),ptsin                          ; Selbst definierte Linienstil
        clr ptsin+2
        jsr vdi
        unlk a6
        rts

 ;****************************************
 ;*** Set Polyline End Styles ************
 ;****************************************

vsl_ends:link a6,#0
        move #108,contrl
        clr ptsin
        move #2,intin
        move 10(a6),int_in                        ; Anfangsstil
        move 8(a6),int_in+2                       ; Endstil
        jsr vdi
        unlk a6
        rts

 ;****************************************
 ;*** Set Polymarker Type ****************
 ;****************************************

vsm_type:link a6,#0
        move #18,contrl
        clr ptsin
        move #1,intin
        move 8(a6),int_in                         ; Polymarker Type
        jsr vdi
        unlk a6
        rts

 ;****************************************
 ;*** Set Polymarker Height **************
 ;****************************************

set_height:link a6,#0
        move #19,contrl
        move #1,ptsin
        clr intin
        clr pts_in
        move 8(sp),pts_in+2                       ; Polymarker Hîhe
        jsr vdi
        unlk a6
        rts

 ;***************************************
 ;*** Set Polymarker Color Index ********
 ;***************************************

vsm_color:link a6,#0
        move #20,contrl
        clr ptsin
        move #1,intin
        move 8(sp),int_in                         ; Farbnummer
        jsr vdi
        unlk a6
        rts

 ;****************************************
 ;*** Set Character Height ***************
 ;****************************************

vst_height:link a6,#0
        move #12,contrl
        clr intin
        move #1,ptsin
        clr pts_in
        move 8(a6),pts_in+2                       ; Zeichen-Hîhe
        jsr vdi
        unlk a6
        rts

 ;**************************************
 ;*** Set Character Baseline Vektor ****
 ;**************************************

vst_rotation:link a6,#0
        move #13,contrl
        clr ptsin
        move #1,intin
        move 8(sp),int_in                         ; Base-Line Winkel
        jsr vdi
        unlk a6
        rts

 ;**************************************
 ;*** Set Graphic Text Color Index *****
 ;**************************************

vst_color:link a6,#0
        move #22,contrl
        clr ptsin
        move #1,intin
        move 8(a6),int_in                         ; Farbindex
        jsr vdi
        unlk a6
        rts

 ;****************************************
 ;*** Set Graphic Text Special Effects ***
 ;****************************************

vst_effects:link a6,#0
        move #106,contrl
        clr ptsin
        move #1,intin
        move 8(a6),int_in                         ; Text-Effekt-Nummer
        jsr vdi
        unlk a6
        rts

 ;****************************************
 ;*** Set Graphic Text Alignment *********
 ;****************************************

vst_alignment:link a6,#0
        move #39,contrl
        clr ptsin
        move #2,intin
        move 10(a6),int_in                        ; horizontale Ausrichtung
        move 8(a6),int_in+2                       ; vertikale Ausrichtung
        jsr vdi
        unlk a6
        rts

 ;*****************************************
 ;*** Set Fill Interior Style *************
 ;*****************************************

vsf_interior:link a6,#0
        move #23,contrl
        clr ptsin
        move #1,intin
        move 8(a6),int_in                         ; FÅlltyp
        jsr vdi
        unlk a6
        rts

 ;******************************************
 ;*** Set Fill Style Index *****************
 ;******************************************

vsf_style:link a6,#0
        move #24,contrl
        clr ptsin
        move #1,intin
        move 8(a6),int_in                         ; FÅll-Stil
        jsr vdi
        unlk a6
        rts

 ;******************************************
 ;*** Set Fill Color Index *****************
 ;******************************************

vsf_color:link a6,#0
        move #25,contrl
        clr ptsin
        move #1,intin
        move 8(a6),int_in
        jsr vdi
        unlk a6
        rts

 ;******************************************
 ;*** Set Fill Perimeter Visibility ********
 ;******************************************

vsf_perimeter:link a6,#0
        move #104,contrl
        clr ptsin
        move #1,intin
        move 8(a6),int_in
        jsr vdi
        unlk a6
        rts

 ;*** Aufruf des AES ***

aes:    movem.l d0-d1,-(sp)
        move.l #aespar,d1
        move.w #$c8,d0
        trap #2
        movem.l (sp)+,d0-d1
        rts

 ;*** Aufruf des VDI ***

vdi:    movem.l d0-d1,-(sp)
        move.l #vdipar,d1
        move #$73,d0
        trap #2
        movem.l (sp)+,d0-d1
        rts

 ;*****************************************************************
 ;*** Variablen, die fÅr die VDI-Programmierung benîtigt werden ***
 ;*****************************************************************
        data
        align.w

txt:    dc.b "Dies ist ein Probetext"
        dc.b 0
        align.w

aespar: dc.l contrl
        dc.l global
        dc.l int_in
        dc.l int_out
        dc.l addr_in
        dc.l adr_out

vdipar: dc.l contrl                               ; VDI-Parameterblock
        dc.l int_in
        dc.l pts_in
        dc.l int_out
        dc.l pts_out

contrl: ds.w 1                                    ; Kontroll-Nummer

gintin:
ptsin:  ds.w 1                                    ; Anzahl Werte PTSIN

gintout:
ptsout: ds.w 1                                    ; Anzahl Werte PTSOUT

addrin:
intin:  ds.w 1

addrout:
intout: ds.w 1

scode:  ds.w 1                                    ; Subcode
handle: ds.w 1                                    ; VDI-Handle
        ds.w 4

int_in: ds.w 128                                  ; INTIN-Array   (VDI)
pts_in: ds.w 256                                  ; PTSIN-Array   (VDI)
int_out:ds.w 128                                  ; INTOUT-Array  (VDI)
pts_out:ds.w 12                                   ; PTSOUT-Array  (VDI)
addr_in:ds.w 128                                  ; ADDRIN-Array  (AES)
adr_out:ds.w 128                                  ; ADDROUT-Array (AES)


global:                                           ; AES-Global Array
apvers: ds.w 1
apcount:ds.w 1
apid:   ds.w 1
appriv: ds.w 1
apptree:ds.w 1
ap1:    ds.w 1
ap2:    ds.w 1
ap3:    ds.w 1
ap4:    ds.w 1

        end


Harald Schulz
Zum Billing 1
5920 Bad Berleburg 14



