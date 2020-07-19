 ; #####################################################################
 ; ##    VT 100 Emulation              Markus Hoffmann        4'91    ##
 ; ##    V. 1.02a     Letzte Bearbeitung    12.03.1995                ##
 ; #####################################################################

VERSION=$30C
XB_ID='VT10'      ; XBRA-Kennung

END_BASE:                       ; Ende der Basepage, Beginn des Programms
; ###########################
          bra.s DIREKTSTART     ;  0 Fuer Direktstarts
          nop                   ;  2
; ###########################
          dc.l INSTALL          ;  4 Installation
          dc.l STRING           ;  8 Copyrightmeldung
          dc.l VT100            ; 12 Hauptroutine
          dc.l 0,0,0,0          ; 16 4L (reserviert
          dc.l 0,0,0,0          ; 32 4L (reserviert)
          dc.l BLK_FELD         ; 48 Screenbuffer
          dc.l ESC_VARS         ; 52 Tabelle ESC-Vars

 ; Hier geht's weiter, wenn das Programm direkt aus dem Desktop
 ; installiert wurde...

DIREKTSTART:
          lea    string(pc),a0   ; Standartmeldung ausgeben
          bsr.s  print
       
          MOVE    #-1,IN_ARBEIT  ;ERST MAL INTERRUPT SPERREN
          pea     patch(pc)      ;Adr. Patch-Routine
          MOVE    #38,-(SP)      ;SUPEREXEC
          trap    #14
          addq.l  #6,sp

          BSR    INSTALL
          move.l d0,-(sp)
          CLR    IN_ARBEIT     ; JETZT FREIGEBEN

          move   #-1,-(sp)  ; Wenn Control nicht gedrÅckt,
          move   #11,-(sp)
          trap   #13
          addq.l #4,sp
          btst   #2,d0
          beq.s  keepterm   ; gleich ende

          lea    string100(pc),a0  ; Info-Meldung
          bsr.s  print
          bsr.s  wait              ; auf Taste warten
          LEA    ESC_CLRHOME(pc),a0  ; screen lîschen (wegen blink)
          bsr.s  print

KEEPTERM: move.l (sp)+,d0
          clr    -(sp)   ; Keepterm
          move.l d0,-(sp)
          move   #49,-(sp)
          trap   #1
          illegal             ; Programmende

PRINT:  ibytes  "\assemble\library\print_sr.b"
WAIT:   ibytes  "\assemble\library\key_wait.b"

;* Vektoren patchen
;* -----------------
PATCH:  lea     new_bios(pc),a0
        lea     new_vbl(pc),a1
        move.l  $b4,(old_bios-new_bios)(a0)
        move.l  a0,$b4
        move.l  $70,(old_vbl-new_vbl)(a1)
        move.l  a1,$70
        lea     new_gem(pc),a1
        move.l  $88,(old_gem-new_gem)(a1)
        move.l  a1,$88
     ;   lea     new_acia(pc),a1
     ;   move.l  $118,(old_acia-new_acia)(a1)
     ;   move.l  a1,$118
     ; wieder rausgenommen ! 9.2.1995
     ;   move.l  #$7777eeee,$51A             ; memval3 ungÅltig
        rts

        include "100acia.q"  ; Tastatur-/Messageverwaltung
        include "100bios.q"  ; BIOS-Ein-/Ausgabebereich
        include "100vdi.q"   ; VDI-ESC-Befehlssatz


; #########################################################
; Installationsroutine: gibt nichtbenîtigten Speicher frei
; RÅckgabe in D0: LÑnge des belegten Speichers ab Basepage
; #########################################################
INSTALL: lea (END_BASE-256)(pc),a5  ; Adresse Basepage in a5
         move.l #$100,d0
         add.l  $C(a5),d0
         add.l  $14(a5),d0
         add.l  $1c(a5),d0   ; LÑnge des Programms+BasepagelÑnge in d0
         MOVE.L D0,-(Sp)     ; sichern
         move.l d0,-(sp)
         move.l a5,-(sp)
         clr    -(sp)
         move   #$4a,-(sp)    ;SETBLOCK
         trap   #1
         add.l  #12,sp

         dc.w $a000           ; Fonttabelle anfertigen:
         move.l 8(a1),a1
         lea    FONTTABLE(pc),a2
         move.l 76(a1),(a2)   ; ATARI-8*16-Systemfont
         move.l #ibmfont,4(a2)  ; IBM-Font
         move.l #ext_font,8(a2) ; Grafikfont

         move   #1,-(sp)        ; Tastaturpuffer holen
         move   #14,-(sp)
         trap   #14
         addq.l #4,sp
         move.l d0,keybufp

         lea    esc_vars(pc),a6  ; Variablen initialisieren
         BSR    VT_INIT
         move.l (sp)+,d0
         rts

; ################################################################
; VBL-Interruptroutine, Åbernimmt das Cursorblinken
; und die Style-Option "Blink"
; ################################################################
         include "100VBL.Q"

; ################# Hier die eigentliche Routine zur Ausgabe ###########
; ASCII-Code des auszugebenden Zeichens Åber 4(SP)
; ######################################################################
       dc.l   'XBRA',XB_ID,0

VT100: move   4(sp),d7         ; D7 tabu fÅr alles
conout and.l  #$FF,d7
       lea    esc_vars(pc),a6  ; A6 ebenfalls tabu
       dc.w   $6000            ; BRA
aktu:  dc.w   standart-aktu

setesc: move   #(ESCAPES-aktu),(aktu-esc_vars)(a6)
        rts

;### Hier werden die 1-Byte-Kommandos verzweigt ####

; erst die, die die Cursorposition nicht verÑndern

standart:  cmp   #27,d7       ; ==> ESC
       BEQ.s SETESC
       TST   AUTOPRINTF(A6)  ; AUTOPRINT
       beq.s  \no
       bsr   autoprint
\no:   cmp   #127,d7      ; DEL
       bne.s   \we
       bsr   hide_cursor
       bsr   delete_char
       bra   show_cursor
\we    cmp   #16,d7       ; hier Control-Codes abfangen
       bgt.s m_zout       ; ASCII 7 bis 16
       cmp   #7,d7
       blt.s m_zout
       bsr   hide_cursor
       lea   ctrltab(pc),a0
       subq  #7,d7
       lsl   #1,d7
       move  (a0,d7.w),(cbas-esc_vars)(a6)
       dc.w  $6100        ; BSR
cbas:  dc.w  'XX'
       bra   show_cursor
 data
 ; Adressen der Routinen fÅr ASCII 7-16
 ; Parameter nur a6 (d7 kaputt!)
 ; Cursor ist ausgeschaltet
ctrltab: dc.w bell-cbas,bsp-cbas,h_tab-cbas,lfnewline-cbas       ; 7,8,9,10
         dc.w lfnewline-cbas,lfnewline-cbas,retnewline-cbas     ; 11,12,13
         dc.w g1_char_set-cbas,g0_char_set-cbas,g2_char_set-cbas ; 14,15,16
 text
m_zout BSR   HIDE_CURSOR
       bsr.s  out5         ; bei allen anderen da weiter...
       BRA   SHOW_CURSOR

 ; Ausgabe ohne Sonderzeicheninterpretation

OUT5:    BSR   ZEICHENAUSGABE
         addq #1,cursor_x(A6)
         cmp  #80,cursor_x(A6) ; am Zeilenende angekommen ?
         blt.s \ret            ; nein -->
         move max_curx(A6),cursor_x(A6)
         move.l status(a6),d0
         btst  #7,d0           ; overflowflag
         beq.s \ret
         clr  cursor_x(A6)     ; sonst nÑchste Zeile
         addq #1,cursor_y(A6)
         cmp  #25,cursor_y(A6) ; Bildschirmende ?
         blt.s \ret
         move max_cury(A6),cursor_y(A6) ; Ja, dann Scrollen
         BRA  SCROLL_UP
\ret:    rts

MASTER_RESET:sf     (cursor_o_o_flg-esc_vars)(a6)    ; CURSOR ON
VT_INIT:     move.l #$80324,status(a6)    ; Alle Variablen initialisieren
             move.l #$1000, setup(a6)
             clr    style(a6)             ; bei Init und RESET
             clr    led(a6)
             move   #79,max_curx(a6)
             move   #24,max_cury(a6)
             clr    cursor_x(a6)
             clr    cursor_y(a6)
             move.b #20,cur_br(a6)
             move.b #20,cur_bc(a6)
             clr    autoprintf(a6)
             clr    reg_top(a6)
             move   #22,reg_bot(a6)
             bsr    inittabs
             bsr    CLRBUF                ; Messagebuffer lîschen
             BRA.s  G1_CHAR_SET

G0_char_set: lea    FONTTABLE(pc),a1
             move.l (a1),fontadr(A6)
             clr    font_nr(a6)
zret         rts
G1_char_set: lea    FONTTABLE(pc),a1
             move.l 4(a1),fontadr(A6)  ; 8*16 IBM-Like-Font
             MOVE   #1,FONT_NR(a6)
             rts
G2_char_set: lea    FONTTABLE(pc),a1
             move.l 8(a1),fontadr(A6)  ; 8*16 EXTENDED-Font
             MOVE   #2,FONT_NR(a6)
             rts

BELL:        IBYTES "..\vt100emu\bell.b"

; Routinen setzen Adresse fÅr nÑchste Verzweigung Mehrfachschalter

SETSP0:      clr    (GEW_FONT-esc_vars)(a6)
             bra.s  seteee
setsp1:      move   #1,(gew_font-esc_vars)(a6)
             bra.s  seteee
setsp2:      move   #2,(gew_font-esc_vars)(a6)
SETEEE:      MOVE   #(NF1-aktu),(AKTU-esc_vars)(a6)
             move   font_nr(a6),(alt_font-esc_vars)(a6)
             rts
paset:       move   #(pa1-aktu),(aktu-esc_vars)(a6)
             rts
pa1:         sub    #32,d7
             move   d7,cursor_y(a6)
             move   #(pa2-aktu),(aktu-esc_vars)(a6)
             rts
pa2:         sub   #32,d7
             move  d7,cursor_x(a6)
             bra  sst
seteklammerauf: move   #(eklau-aktu),(aktu-esc_vars)(a6)
                clr    (fragezeichenf-esc_vars)(a6)
                clr    (varpoint-esc_vars)(a6)
                clr.l  (varwert1-esc_vars)(a6)  ; erste zwei Worte lîschen
                rts

;#################################################################
; Routine verteilt die ESC nn - Kommandos (Mehrbyte-Kommandos mÅssen
; immer mit bra sst beendet werden auûer die Verteiler )
ESCAPES: bsr hide_cursor
         cmp #'#',d7        ; ESC-#    Zuerst alle Verteiler
         cmp #'(',d7        ; ESC-(    abfangen !
         cmp #')',d7        ; ESC-)
         cmp #'N',d7        ; ESC-N
         beq.s setsp1
         cmp #'O',d7        ; ESC-O
         beq.s setsp0
         cmp #'P',d7        ; ESC-P
         beq.s setsp2
         cmp #'Y',d7        ; ESC-Y bei VT52
         beq paset
         cmp #'[',d7        ; ESC-[
         beq.s seteklammerauf
         cmp #'Z',d7        ; > Z
         bgt.s klein
         SUB  #'0',D7       ; < 0
         bmi  sst
         lea  esccodes(pc),a0
         lsl  #1,d7
         move (a0,d7.w),(ebas-esc_vars)(a6)
         dc.w $6100         ; BSR    alle Groûbuchst
ebas:    dc.w ret-ebas
         bra  sst           ; diese Funkt werden mit sst beendet
ret:     rts
       data
 ; Liste der Funktionsadressen der Funktionen fÅr
 ; ESC-Groûbuchstabe
 ; Diese Routinen mÅssen mit RTS abgeschlossen werden

esccodes: dc.w ret-ebas,ret-ebas,ret-ebas,ret-ebas            ; 0,1,2,3
          dc.w ret-ebas,ret-ebas,ret-ebas,savecursp-ebas      ; 4,5,6,7
          dc.w restorecursp-ebas,ret-ebas,ret-ebas,ret-ebas   ; 8,9,:,;
          dc.w enter_vt100-ebas,kkiap-ebas,kkinp-ebas,ret-ebas; <,=,>,?
          dc.w ret-ebas                                       ; @
          dc.w cursor_up-ebas,cursor_down-ebas,cursor_right-ebas,esc_d-ebas  ; A-D
          dc.w esc_e-ebas,ret-ebas,ret-ebas,esc_h-ebas        ; E-H
          dc.w cursor_up_scroll-ebas,esc_J-ebas,erasezac-ebas,INSert_LINe-ebas ; I-L
          DC.W ESC_M-EBAS,ret-EBAS,ret-EBAS,ret-EBAS ; M-P
          dc.w ret-ebas,ret-ebas,ret-ebas,ret-ebas            ; Q-T
          dc.w ret-ebas,ret-ebas,ret-ebas,ret-ebas            ; U-X
          dc.w ret-ebas,rep_terminal-ebas                     ; Y Z
       text
klein:   cmp #'z',d7
         bgt sst
         sub #'a',d7
         bmi sst
         lea esckcodes(pc),a0
         lsl #1,d7
         move (a0,d7.w),(kbas-esc_vars)(a6)
         dc.w $6100         ; BSR
kbas:    dc.w ret-kbas
         bra  sst
         data
esckcodes: dc.w ret-kbas,ret-kbas,ESC_C-kbas,erasesbc-kbas      ; a-d
        dc.w cursor_on-kbas,cursor_off-kbas,ret-kbas,ret-kbas   ; e-h
        dc.w ret-kbas,savecursp-kbas,restorecursp-kbas,erase_line-kbas ; i-l
        dc.w ret-kbas,ret-kbas,erasezbc-kbas,inverse_on-kbas        ; m-p
        dc.w inverse_off-kbas,ret-kbas,ret-kbas,ret-kbas        ; q-t
        dc.w ret-kbas,wrap_on-kbas,wrap_off-kbas,ret-kbas       ; u-x
        dc.w ret-kbas,ret-kbas                                 ; y z
       text
ESC_C:       move.l status(a6),d0
             btst   #2,d0
             beq    ret
             BRA    master_reset
ESC_D:       move.l status(a6),d0
             btst   #2,d0
             beq    Cursor_LEFT
             BRA    Cursor_down_scroll
ESC_E:       move.l status(a6),d0
             btst   #2,d0
             beq    CLR_HOME      ; Vt52
             BRA    newline       ; Vt100
ESC_H:       move.l status(a6),d0
             btst   #2,d0
             beq    Cursor_HOME
             BRA    set_htab
ESC_J:       move.l status(a6),d0
             btst   #2,d0
             beq    erasesac
             BRA    set_vtab
ESC_M:       move.l status(a6),d0
             btst   #2,d0
             beq    DELete_LINe
             BRA    cursor_up_scroll
LFNEWLINE:   move.l setup(a6),d0
             btst   #20,d0        ; Linefeed/newline-mode
             beq    linefeed
             bra    newline
RETNEWLINE:  move.l setup(a6),d0
             btst   #20,d0
             beq    return
             bra    newline

ENTER_VT100: move.l status(a6),d0
             bset   #2,d0
             move.l d0,status(a6)
             rts

NF1:         move gew_font(pc),d0     ; Setzt fÅr ein Zeichen einen
             move d0,font_nr(a6)      ; anderen Font
             lsl  #2,d0               ; Hier lassen sich auch sonderzeichen
             lea  fonttable(pc),a0    ; ausgeben wie 8 10 13 ...
             move.l (a0,d0.w),fontadr(a6)
             bsr out5
             lea  fonttable(pc),a0
             move alt_font(pc),d0
             move d0,font_nr(a6)
             lsl  #2,d0
             move.l (a0,d0.w),fontadr(a6)
             bra sst

; #### Verteiler fÅr ESC-[ Kommandos ####

eklau:     cmp    #'?',d7   ; Fragezeichen abfangen
           beq.s  sfrag
           cmp    #';',d7   ; Semikolon trennt Werte
           beq.s  mv2
           cmp    #'0',d7   ; < 0 , dann Kommando abbrechen
           blt    sst
           cmp    #'9',d7
           bgt.s  endfunc      ; sonst Kommando
           lea  varwert1(pc),a0  ; Zahl verarbeiten
           move varpoint(pc),d0
           move (a0,d0.w),d1
           mulu #10,d1
           SUB  #'0',D7
           add  d7,d1
           move d1,(a0,d0.w)
           rts
endfunc    cmp #'Z',d7        ; > Z
           bgt.s iklein
           SUB  #'A',D7       ; < A
           bmi  sst

           lea  escicodes(pc),a0
           lsl  #1,d7
           move (a0,d7.w),(ibas-esc_vars)(a6)
           dc.w $6100         ; BSR    alle Groûbuchst
ibas:      dc.w ret-ibas
           bra  sst

   data
 ; ESC-[-Groûbuchstabe

ESCicodes: dc.w curnup-ibas,curndown-ibas,curnright-ibas,curnleft-ibas ; A,B,C,D
           dc.w ret-ibas,ret-ibas,ret-ibas,print_at-ibas ; E,F,G,H
           dc.w n_h_tab-ibas,erasess-ibas,erasels-ibas,insertxl-ibas ; I,J,K,L
           dc.w deletexl-ibas,ret-ibas,ret-ibas,deletexc-ibas ; M,N,O,P
           dc.w ret-ibas,ret-ibas,ret-ibas,ret-ibas  ; Q,R,S,T
           dc.w ret-ibas,ret-ibas,ret-ibas,ret-ibas  ; U,V,W,X
           DC.W N_V_TAb-IBAS,N_B_TAB-IBAS            ; Y,Z
           text

iklein:    cmp #'z',d7
           bgt sst
           sub #'a',d7
           bmi sst
           lea escjcodes(pc),a0
           lsl #1,d7
           move (a0,d7.w),(jbas-esc_vars)(a6)
           dc.w $6100         ; BSR
jbas:      dc.w ret-jbas
           bra  sst
   data
 ; ESC-[-Kleinbuchstabe

ESCjcodes: dc.w ret-jbas,ret-jbas,identify-jbas,ret-jbas ; a,b,c,d
           dc.w ret-jbas,print_at-jbas,tab_m-jbas,diverse_h-jbas ; e,f,g,h
           dc.w print_m-jbas,ret-jbas,ret-jbas,diverse_l-jbas ; i,j,k,l
           dc.w att_m-jbas,requests-jbas,ret-jbas,ret-jbas ; m,n,o,p
           dc.w led_set-jbas,set_region-jbas,savecursp-jbas,ret-jbas ; q,r,s,t
           dc.w restorecursp-jbas,ret-jbas,ret-jbas,ret-jbas ; u,v,w,x
           dc.w ret-jbas,new_z-jbas                   ; y,z
           text

SFRAG: MOVE  #-1,(FRAGEZEICHENF-esc_vars)(a6)
       rts
mv2:    ; Semikolon trennt die einzelnen Zahlen voneinander
        addq   #2,(varpoint-esc_vars)(a6)   ; ZÑhler erhîhen
        lea    varwert1(pc),a0   ; Buffer
        move   varpoint(pc),d0
        cmp    #40*2,d0        ; Buffer voll ?
        blt.s  \cmv2
        move   #39*2,(varpoint-esc_vars)(a6)
\cmv2   clr    (a0,d0.w)     ; nein, dann nÑchten Eintrag lîschen
        rts

; Diese Routine nach Beenden der Mehrbyte-Kommandos aufrufen !

SST:    move  #(standart-aktu),(aktu-esc_vars)(a6)
sst2    tst   cursor_x(A6)
        BMI.s MAKE_X_0
        tst   cursor_y(A6)
        bmi.s make_y_0
        move  cursor_x(a6),a0
        cmp   max_curx(A6),a0
        bgt.s make_x_80
        move  cursor_y(a6),a0
        cmp   max_cury(A6),a0
        bgt.s make_y_25
        BRA   SHOW_CURSOR

MAKE_X_0: clr CURSOR_X(A6)
          bra.s  sst2
MAKE_Y_0: clr CURSOR_Y(A6)
          bra.s  sst2
make_x_80:move max_curx(A6),cursor_x(A6)
          bra.s  sst2
make_y_25:move max_cury(A6),cursor_y(A6)
          bra.s  sst2

; ######### Endfunktionen der Mehrbytekommandos ###############
kkiap:       bset  #0,flags(a6)
             rts
kkinp:       bclr  #0,flags(a6)
             rts

deletexc:   move varwert1(pc),d5
            tst  d5
            beq.s \hook
            subq  #1,d5
\hook       move d5,-(sp)
            bsr  delete_char
            move (sp)+,d5
            dbra d5,\hook
            rts

deletexl:   move varwert1(pc),d5
            tst  d5
            beq.s \hook
            subq  #1,d5
\hook       move d5,-(sp)
            bsr  delete_line
            move (sp)+,d5
            dbra d5,\hook
            rts

insertxl:   move varwert1(pc),d5
            tst  d5
            beq.s \hook
            subq  #1,d5
\hook       move d5,-(sp)
            bsr  insert_line
            move (sp)+,d5
            dbra d5,\hook
            rts

DIVERSE_H:  move   varwert1(pc),d6
            cmp    #31,d6
            bgt.s  \ret
            TST    (FRAGEZEICHENF-esc_vars)(a6)
            beq.s  msetup
            move.l status(a6),d0
            bset   d6,d0
            move.l d0,status(a6)
            cmp    #5,d6
            BEQ    COLOR_H
\ret        rts

msetup:     move.l setup(a6),d0
            bset   d6,d0
            move.l d0,setup(a6)
            rts

DIVERSE_L:  move   varwert1(pc),d6
            cmp    #31,d6
            bgt.s  \ret
            TST    (FRAGEZEICHENF-esc_vars)(a6)
            beq.s  lsetup
            move.l status(a6),d0
            bclr   d6,d0
            move.l d0,status(a6)
            cmp    #5,d6
            BEQ    COLOR_L
\ret        rts

lsetup:     move.l setup(a6),d0
            bclr   d6,d0
            move.l d0,setup(a6)
            rts

LED_SET:    lea   varwert1(pc),a0 ; hier kînnen 8 (standart 4)
            tst   (a0)            ; Bits fÅr den individuellen
            beq.s LED_OFF         ; Gebrauch gesetzt werden
            move  varpoint(pc),d5
            lsr   #1,d5
;            subq  #1,d5
            bmi.s \ret
            moveq  #0,d4
            move  led(a6),d0
\hook       move  (a0,d4.w),d6
            and   #$F,d6          ; max 15
            bset  d6,d0
            addq  #2,d4
            dbra  d5,\hook
            move  d0,led(a6)
\ret        rts

LED_OFF:    clr   LED(a6)
            rts

 ; ## Schriftattribute einstellen/Abschalten ESC-[-bp-m ##

ATT_M:       lea  varwert1(pc),a0
             tst   (a0)          ; 0 = Attribute aus
             beq.s \att_off
             move  varpoint(pc),d5 ; Mehrere auf einmal !
             LSR   #1,D5  ;/2
 ;            subq  #1,d5
             bmi.s \ret
             moveq #0,d4
             move  style(a6),d0
\hook        move  (a0,d4.w),d6
             cmp   #15,d6
             Ble.S \set
\X_OFF:      SUB  #20,D6
             BMI.s \next
             cmp  #15,d6
             BGT.s \next
             bclr d6,d0      ; Attribut lîschen
             bra.s \next
\set         bset d6,d0      ; Attribut setzen
\next        addq  #2,d4
             dbra d5,\hook
             bra.s m_d0_s

\ATT_OFF:    clr style(a6)
\ret         rts

INVERSE_ON:  move style(a6),d0
             bset #7,d0
             bra.s m_d0_s
INVERSE_OFF: move style(a6),d0
             bclr #7,d0
m_d0_s       move d0,style(a6)
             rts

NEW_z:    lea   varwert1(pc),a1
          lea    ext_font(pc),a0
          move   (a1),d0
          and.l  #$ff,d0
          add.l  d0,a0
          moveq  #15,d5
          move   #15*256,d3
\schleife lsl    #1,d5
          move.b 3(a1,d5.w),(a0,d3.w)
          lsr    #1,d5
          sub    #256,d3
          dbra   d5,\schleife
          rts

erasels:    move varwert1(pc),d6
            tst d6
            beq erasezac
            cmp #1,d6
            beq erasezbc
            cmp #2,d6
            beq erase_line
            rts

erasess:    move varwert1(pc),d6
            tst d6
            beq erasesac
            cmp #1,d6
            beq erasesbc
            cmp #2,d6
            beq clear_screen
            rts

SET_REGION:  lea   varwert1(pc),a0   ; Achtung: auf ungÅltige Werte aufpassen !
             move  max_cury(a6),d0
             subq  #1,(a0)
             subq  #1,2(a0)
             tst   (a0)
             bmi.s regw     ; negativer wert
             cmp   (a0),d0
             blt.s regw     ; zu groû
             move  (a0),d1
             move  d1,reg_top(a6)
regw:        tst   2(a0)    ; dasselbe fÅr bottomwert
             bmi.s regw2
             cmp   2(a0),d0
             blt.s regw2
             move  2(a0),reg_bot(a6)
regw2        cmp   reg_bot(a6),d1     ; top < bot
             ble.s \ret               ; Ja -> OK
             move  reg_bot(a6),reg_top(a6)
             move  d1,reg_bot(a6)     ; sonst vertausche
\ret         rts

WRAP_ON:     move.l status(a6),d0
             bset #7,d0
             bra.s sast
WRAP_OFF:    move.l status(a6),d0
             bclr #7,d0
sast:        move.l d0,status(a6)
             rts

COLOR_h:     move #1,$ffff8240
             rts
COLOR_l:     clr  $ffff8240
             rts

DELETE_CHAR: move.l $44e,a0
             lea    blk_feld(pc),a1
             move   cursor_y(a6),d1
             move   d1,d2
             mulu   #80*16,d1
             mulu   #80*4,d2
             lea    (a0,d1.w),a0
             lea    (a1,d2.w),a1
             move   cursor_x(a6),d1
             lea    (a0,d1.w),a0
             lsl     #2,d1
             lea     (a1,d1.w),a1
             subq    #1,(in_arbeit-esc_vars)(a6)
             moveq   #15,d5
\nline       move   max_curx(A6),d4
             sub    cursor_x(a6),d4
             move.l a0,a2
             subq   #1,d4
             bmi.s  \onlyc
\HOOK        move.B 1(a2),(a2)+
             dbra   d4,\hook
\onlyc       clr.b  (a2)
             lea    80(a0),a0
             dbra   d5,\nline
             move   max_curx(A6),d4   ; Im Feld
             sub    cursor_x(a6),d4
             subq   #1,d4
             bmi.s  \onlyf
\hook2       move.l 4(a1),(A1)+
             dbra   d4,\hook2
\onlyf       clr.l  (a1)
             addq   #1,(in_arbeit-esc_vars)(a6)
             rts
DELETE_LINE: move cursor_y(a6),d1
             move.l $44e,a0
             lea    blk_feld(pc),a2
             move   d1,d2
             mulu   #80*16,d1
             mulu   #80*4,d2
             lea    (a0,d1.w),a0   ; Ziel
             lea    (a2,d2.w),a2
             lea    80*16(a0),a1   ; Quelle
             lea    80*4(a2),a3
             move   max_cury(a6),d5
             sub    cursor_y(a6),d5
             BEQ    ERASE_LINE     ; DANN NUR LôSCHEN
             move   d5,d6
             mulu   #16*80/4,d5
             mulu   #80*4/4,d6
             subq   #1,d5
             sUBQ   #1,D6
             subq   #1,(in_arbeit-esc_vars)(a6)
\hook        move.l (a1)+,(a0)+
             dbra   d5,\hook
\HOOK2       move.l (a3)+,(a2)+      ; Feld
             dbra   d6,\hook2
             move   cursor_y(a6),(xl-esc_vars)(a6)
             move   max_cury(a6),cursor_y(a6)
             bsr    ERASE_LINE
             move   xl(pc),cursor_y(a6)
             addq   #1,(in_arbeit-esc_vars)(a6)
             rts
 bss
xl: dc.w 0
 text
INSERT_LINE: move.l $44e,a0
             lea    (blk_feld+80*25*4)(pc),a2
             lea    32000(a0),a0   ; Ziel
             lea    -80*16(a0),a1  ; Quelle
             lea    -80*4(a2),a3
             move   max_cury(a6),d5
             sub    cursor_y(a6),d5
             BEQ    ERASE_LINE     ; DANN NUR LôSCHEN
             move   d5,d6
             mulu   #16*80/4,d5
             mulu   #80*4/4,d6
             subq   #1,d5
             sUBQ   #1,D6
             subq   #1,(in_arbeit-esc_vars)(a6)
\hook        move.l -(a1),-(a0)
             dbra   d5,\hook
\HOOK2       move.l -(a3),-(a2)      ; Feld
             dbra   d6,\hook2
             bsr    ERASE_LINE
             addq   #1,(in_arbeit-esc_vars)(a6)
             rts

    INCLUDE "..\vt100emu\100erase.q"   ; Erase-Funktionen
    INCLUDE "..\vt100emu\100scrol.q"   ; Scrollfunktionen
    INCLUDE "..\vt100emu\drucken.q"    ; DRUCKROUTINEN
    INCLUDE "..\vt100emu\100resp.q"    ; Respond-Funktionen
    INCLUDE "..\vt100emu\100curs.q"    ; Cursorfunktionen
    INCLUDE "..\VT100emu\100zausg.q"   ; Zeichenausgabe

    data
IBMFONT:      IBYTES "..\vt100emu\ibm_like.fnt",4096
EXT_FONT:     IBYTES "..\vt100emu\SPAT-A.fnt",4096

; Definitionen fÅr Offsets in den Esc_vars:
max_curx=2      ; w
max_cury=4      ; w
txtz_l=6        ; w
offset=16       ; w
cursor_x=18     ; w
cursor_y=20     ; w
cur_br=22       ; b    Blinkrate   (20 = 20*Vbl)
cur_bc=23       ; b    Blinkcounter
fontadr=24      ; l
STATUS=46       ; l    1: Cursort.modus 2: VT100/52   4: Scrolltyp 5: Color
                ;      6: Region on     7: Zeilenwrap 8: Tastaturrepeat
                ;     18: Formfeed     19: Printregion
SETUP=50        ; l    2: Tastatur eanable 4: Insert Mode 12: Echo 20: newline mode
LED=54          ; w    1-15
style=56        ; w
font_nr=58      ; w
autoprintf=60   ; w
reg_top=62      ; w
reg_bot=64      ; w
flags=66        ; l

blink_flg:      dc.w 0
cursor_v_l_flg: dc.w 0

STring:   dc.b 27,'p s/w VT100/VT102/ANSI Terminal-Emulator  (c) by Markus Hoffmann V.1.02a Feb. 1992 ',27,'q',13,10
          dc.b ' CTRL bei Programmstart = SETTINGS und INFO ',13,10,0
STRING100:   IBYTES "..\VT100EMU\INTRO.ANS"
             dc.b 0
esc_clrhome: dc.b 27,'[m',27,'[H',27,'[2J',0
 align
    bss
keybufp:       ds.l 1
FONTTABLE:     ds.l 3
in_arbeit:     ds.w 1
ESC_VARS:      ds.w 36         ; offs bis 71 mîglich
cursor_s_h_flg:ds.w 1
cursor_o_o_flg:ds.w 1
fragezeichenf: ds.w 1
gew_font:      ds.w 1
alt_font:      ds.w 1
varpoint:      ds.w 1
varwert1:      ds.w 1
               ds.w 40
blk_feld:      ds.l 80*25
 end
 