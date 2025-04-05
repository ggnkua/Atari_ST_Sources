********************************************************
**                                                    **
** Screen-Tools              by Rolf Peukert  12/1989 **
** (C) Computec Verlag                                **
**                                                    **
**      dynamischer Mausbeschleuniger                 **
**      Bildschirmadreûverschieber                    **
**      24-Nadel Hardcopy (NEC und kompatible)        **
**      Zeitanzeige auf Bildschirm                    **
**      Bildschirmschoner                             **
**      Screendump auf Disk                           **
**      Anzeige des freien Speichers                  **
**                                                    **
** assemblierbar mit: AS68, MadMac, TurboC-MAS        **
********************************************************


        Schwelle         = 2            ;* Schwellwert fÅr Beschleunigung
        Superexec        = $26          ;* XBIOS-Routinen
        Gemdos           = 1
        Bios             = 13
        Xbios            = 14
        Kdvbase          = 34
        Acc_open         = 40           ;* AES-Routinen
        Appl_init        = $0A000100
        Evnt_mesag       = $17000101
        Menu_register    = $23010101
        Form_alert       = $34010101
        NVBL             = $454         ;* Anzahl VBL-Routinen
        VBLqueue         = $456
        Kbdvec           = $118         ;* Tastaturinterrupt
        HBLvec           = $68
        RTC              = $FFFC21      ;* RP 5C15: Basisadresse
        Mode             = $FFFC3B      ;*          Modusregister
        CReset           = $FFFC3F      ;*          Resetregister
        Bank0            = %1000        ;*          Bank 0 selektieren
        Bank1            = %1001        ;*          Bank 1 selektieren
        scrhigh          = $FF8201      ;* SHIFTER: Screenadresse High
        scrmid           = $FF8203      ;*          Screenadresse Mid
        cntmid           = $FF8207      ;*          ZÑhler Mid
        Vsync            = $FF820A      ;*          ext. Synchronisation
        Palette          = $FF8240      ;*          Farbpalette 
        vbasadr          = $44E         ;* System-Screenadresse
        sshiftmd         = $44C         ;* Grafik-Auflîsung (2 = Mono)
        sysbase          = $4F2         ;* Startadresse des OS
        etv_crit         = $404         ;* Fehlerbehandlung
        savptr           = $42A         ;* Puffer fÅr Prozessor-Register
        kbsoffs          = $24          ;* Offset der KbShift-Adresse
        apdoffs          = $28          ;* Offset der act_pd -Adresse
**     (in act_pd steht ein Zeiger auf den aktuellen Prozess-Deskriptor)
        S_chip           = $FF8800
        MFP              = $FFFA00
        prntout          = 5            ;* Gemdos Printer-Output
        prtline          = 9            ;* Gemdos Print Line
        dgetdrv          = $19          ;* Gemdos Diskfunktionen:
        Fcreate          = $3C
        Fwrite           = $40
        Fclose           = $3E
        Malloc           = $48
        physbase         = 2            ;* Xbios Physbase
        bconout          = 3            ;* Bios-Ausgabe
        do_vect          = $502         ;* Vektor fÅr Alt/Help
        alt_flag         = $4EE         ;* Alt/Help - ZÑhler
        A_INIT           = $A000        ;* benutzte Line-A Befehle
        A_HIDEM          = $A00A
        A_SHOWM          = $A009

        .text

********************************************************
**      Anmeldung beim GEM                            **
********************************************************

        move.l  #stack1,A7              ;* eigenen Stack installieren

        bsr     install                 ;* Vektoren verbiegen

        lea     contrl,A0
        move.l  #Appl_init,D0
        movep.l D0,1(A0)                ;* Appl_Init-Aufruf
        bsr     aes
        move.w  intout,ap_id            ;* eigene ID merken

**      Eintragen in die MenÅleiste

        lea     contrl,A0
        move.l  #Menu_register,D0
        movep.l D0,1(A0)                ;* Menu_Register-Aufruf
        move.w  ap_id,intin             ;* eigene ID
        move.l  #menu,addrin            ;* MenÅeintrag "Screen-Tools"
        bsr     aes
        move.w  intout,desk_id          ;* ID des MenÅeintrags
        
********************************************************
**  warten, bis Accessory angeklickt wird:

event:  lea     contrl,A0               ;* Evnt_Message aufrufen:
        move.l  #Evnt_mesag,D0
        movep.l D0,1(A0)
        move.l  #msgbuff,addrin
        bsr     aes

        lea     msgbuff,A2              ;* Message-Puffer auswerten:
        cmpi.w  #Acc_open,(A2)          ;* wurde ein Acc angeklickt?
        bne     event                   ;* Nein, weiter warten
        move.w  desk_id,D0
        cmp.w   8(A2),D0                ;* eigener Eintrag angeklickt?
        bne     event                   ;* Nein, weiter warten

mem:    moveq.l #-1,D0                  ;* Restspeicher erfragen
        move.l  D0,-(A7)                ;* -1.L auf Stack
        move.w  #Malloc,-(A7)           ;* Malloc(-1) liefert freien Speicher
        trap    #Gemdos
        addq.l  #6,A7                   ;* in D0 Restspeicher
        lea     freetx,A4               ;* Stringadresse in der Alertbox
        bsr     longnum                 ;* Zahl in D0 in Dezimal wandeln

        lea     alert,A1                ;* Text der Startbox
        moveq.l #3,D1                   ;* Defaultbutton
        bsr     Alertbox                ;* Alertbox ausgeben

        cmp.b   #3,D1                   ;* Abbruchbutton ?
        beq     evnt3                   ;* ja, nichts tun
        cmp.b   #1,D1                   ;* Setup ?
        bne     evnt2                   ;* nein, Default
        bsr     setup                   ;* sonst setup aufrufen
        bra     evnt3                   ;* und fertig
evnt2:  move.b  def_conf,act_conf       ;* Defaultwert setzen
evnt3:
        move.l  #reset_screen,-(A7)
        move.w  #Superexec,-(A7)        ;* Screen rÅcksetzen (zur Sicherheit)
        trap    #Xbios                  ;* im Supervisormodus
        addq.l  #6,A7
                                        
        bra     event                   ;* Endlosschleife

aes:    clr.w   8(A0)
        move.l  #aespb,D1
        move.w  #$C8,D0                 ;* AES aufrufen
        trap    #2                      ;* ... Åber GEM-Trap
        rts

**  Ende der Hauptschleife
*************************************************************


*************************************************************
**  Alertbox ausgeben, Textzeiger in A1, Defaultbutton in D1
**  (Unterprogramm fÅr Setup)

Alertbox:
        lea     contrl,A0
        move.l  #Form_alert,D0      ;* Parameter setzen
        movep.l D0,1(A0)
        move.w  D1,intin            ;* Defaultbutton setzen
        move.l  A1,addrin           ;* Zeiger auf den Text
        bsr     aes                 ;* AES aufrufen
        move.w  intout,D1           ;* RÅckgabe in D1 merken
        rts

*************************************************************
**  2-Button-Alertbox auswerten
**  Eing.: Text in A1, Button in D1, Bitnummer im Statuswort in D2
**  (Unterprogramm fÅr Setup)

alert2: bsr     Alertbox            ;* Alertbox ausgeben
        cmp.b   #2,D1               ;* 'Aus' gewÑhlt ?
        bne     al_2
        bclr    D2,act_conf         ;* ja, Bit im Statusbyte lîschen
        bra     al_3
al_2:   bset    D2,act_conf         ;* nein, Bit setzen
al_3:   rts


********************************************************
**                  Setup-MenÅ:                       **
********************************************************

setup:  lea     ms_frage,A1         ;* Mausbeschleuniger ?
        moveq.l #1,D1               ;* Defaultbutton 'An'
        moveq.l #0,D2               ;* Bitnummer 0
        bsr     alert2              ;* Box auswerten
        lea     sm_frage,A1         ;* Screen-Mover ?
        moveq.l #2,D1               ;* Defaultbutton 'Aus'
        moveq.l #2,D2               ;* Bit 2
        bsr     alert2            
        lea     nt_frage,A1         ;* Bildschirmschoner ?
        moveq.l #1,D1               ;* Defaultbutton 'An'
        moveq.l #6,D2               ;* Bit 6
        bsr     alert2             
        lea     cl_frage,A1         ;* Uhrzeit ?
        moveq.l #1,D1               ;* Defaultbutton 'Desk'
        bsr     Alertbox            ;* Box ausgeben
        cmp     #3,D1               ;* keine Uhr ?
        bne     s_cl1
        bclr    #5,act_conf         ;* Uhrzeit ganz aus
        bra     s_hc
s_cl1:  bset    #5,act_conf
        cmp     #2,D1               ;* Uhrzeit immer anzeigen ?
        bne     s_cl2
        bset    #7,act_conf         ;* Anzeige erzwingen
        bra     s_hc
s_cl2:  bclr    #7,act_conf         ;* Anzeige nur im Desktop
s_hc:   lea     hc_frage,A1
        moveq.l #1,D1               ;* Defaultbutton 'Original'
        bsr     Alertbox            ;* Hardcopy ?
        cmp     #1,D1               ;* Original ?
        bne     s_hc1
        bclr    #3,act_conf         ;* ja, User-Bit lîschen
        bra     set_2               ;* und fertig
s_hc1:  bset    #3,act_conf         ;* nein, User-Bit setzen
        cmp.b   #2,D1               ;* 24-Nadel HC ?
        bne     s_hc2
        bclr    #4,act_conf         ;* ja, Dump-Bit lîschen
        bra     set_2
s_hc2:  bset    #4,act_conf         ;* nein, Dump-Bit setzen
set_2:
        rts
        

********************************************************
**               Install-Routinen:                    **
********************************************************

install:    move.w  #Kdvbase,-(A7)      ;* Adr. der Keyboard-Vektoren holen
            trap    #Xbios
            addq.l  #2,A7
            move.l  D0,kbdv_adr         ;* Adresse in kbdv_adr merken
            dc.w    A_INIT              ;* Line-A Adressen holen
            move.l  8(a0),a_intin       ;* Adresse des Intin-Arrays retten
            move.l  4(a0),a_contrl      ;* Contrl-Adresse retten
            move.l  #vec_inst,-(A7)     ;* Vektoren im Supervisor-Mode setzen:
            move.w  #Superexec,-(A7)
            trap    #Xbios
            addq.l  #6,A7
            rts

********************************************************
**          Vektoren umbiegen (Supervisor-Modus)      **
********************************************************

vec_inst:   movea.l kbdv_adr,A0             ;* Keyboardroutinen-Tabelle
            move.l  16(A0),mouse_vec        ;* alten Mausvektor merken
            move.l  #newmouse,16(A0)        ;* neuer Mausvektor

            move.l  Kbdvec,oldkbd           ;* alten Vektor merken
            move.l  #newkbd,Kbdvec          ;* neuen installieren

**          Versionsnummer holen u.a.

getver:     move.l  sysbase,A0              ;* System-Startadresse holen
            move.w  2(A0),D0                ;* Versionsnummer
            move.w  D0,tosver
            cmp     #$0100,D0               ;* altes TOS 1.0 ?
            bne     gv_1
            move.l  #$0E1B,kbsadr           ;* ja, undok. Adressen nehmen
            move.l  #$4E0E,gemtime  
            lea     $602C,A1                ;* act_pd-Adresse
            move.l  A1,apdadr               ;* merken
            move.l  (A1),desk_pd            ;* PD des Desktop merken
            bra     gv_x
gv_1:       move.l  kbsoffs(A0),kbsadr      ;* nein, KbShift-Adr. aus Header
            move.l  apdoffs(A0),A1          ;* act_pd holen
            move.l  A1,apdadr               ;* merken
            move.l  (A1),desk_pd            ;* PD des Desktop merken
gv_2:       cmp     #$0102,D0               ;* Blitter-TOS ?
            bne     gv_3                    ;* nein, dann (Rainbow-) TOS 1.4
            move.l  #$75B0,gemtime          ;* undok. Sysvar.
            bra     gv_x
gv_3:       move.l  #$378A,gemtime          ;* Var. fÅr Rainbow-TOS
gv_x:
            add.b   #'0',D0                 ;* Ziffer der TOS-Version
            move.b  D0,tosnum               ;* in Alertbox
            move.l  vbasadr,D0              ;* Bildschirmadresse
            lsr.l   #8,D0                   ;* (Lowbyte ist eh' Null)
            move.w  D0,actscr               ;* als Wort speichern
**          Test auf Echtzeituhr :
            lea     RTC+4,A1
            move.b  #Bank1,Mode             ;* Uhr auf Bank 1
            movep.w 0(A1),D2                ;* alte Alarmzeit merken
            move.w  #$0907,D1
            movep.w D1,0(A1)                ;* Alarmminuten setzen
            movep.w 0(A1),D0                ;* wieder lesen
            movep.w D2,0(A1)                ;* alte Zeit zurÅck
            move.b  #Bank0,Mode             ;* wieder Bank 0
            and     #$0F0F,D0
            cmp     D1,D0                   ;* stand's noch drin ?
            bne     noclock                 ;* nein, da ist kein Uhrenchip
            move.b  #'j',clflag1            ;* in Alertbox
            st.b    clflag2                 ;* Flag setzen
            move.b  #%00001100,CReset       ;* Uhr-Alarm aus
            bra     gv_5
noclock:    move.b  #'n',clflag1
            clr.b   clflag2

**          Alternate/Help-Routine installieren

gv_5:       lea     hcstart(pc),a0          ;* Adresse der neuen HC
            move.l  do_vect,hc_vect         ;* alten Vektor merken
            move.l  a0,do_vect              ;* neuen installieren

**          VBL - Routinen installieren:

            move.w   NVBL,D0                ;* freien VBL-Slot suchen
            lsl      #2,D0
            move.l   VBLqueue,A0
            clr      D1
vbltest:    tst.l    (A0,D1)                ;* Slot testen
            beq      vblfound               ;* Spring, wenn Slot frei war
            addq     #4,D1                  ;* nÑchster Slot
            cmp      D0,D1                  ;* letzter Slot ?
            bne      vbltest                ;* nein, weiter suchen
noinst:     rts

vblfound:   lea       (A0,D1),A2            ;* Slotadresse nach A2
            move.l    #newvbl,(A2)          ;* unsere Routine eintragen
            rts
           
reset_screen:
            move.l    vbasadr,D0            ;* Bildschirm zurÅcksetzen
            lea       scrhigh,A0            ;* Bildschirmregister im Shifter
            lsr.l     #8,D0
            movep.w   D0,0(A0)              ;* setzen
            rts

get_screen:
            moveq.l   #0,D0                 ;* Bildschirmadresse holen
            lea       scrhigh,A0            ;* direkt aus Videochip
            movep.w   0(A0),D0
            asl.l     #8,D0
            rts
            

****************************************************************
**      Zahl in D0 nach ASCII-Dezimalzahl wandeln             **
**      Adresse des Textpuffers in A4                         **
**      diese Routine stammt von JÅrgen Stessun (ST 10/89)    **
****************************************************************

longnum:    moveq.l #7,D4                   ;* maximal 7 Stellen
            move.l  #1000,D1                ;* erstmal 4 Stellen berechnen
            moveq.l #-16,D2                 ;* Space erlaubt
            divu    D1,D0                   ;* durch 1000
            bsr     d4todez                 ;* umwandeln
            swap    D0                      ;* Rest in D0.W
            moveq.l #100,D1                 ;* jetzt 3-stellig

d4todez:    move    D0,D3                   ;* Zahl retten
lw1:        ext.l   D3                      ;* auf Lang erweitern
            subq    #1,D4                   ;* schon letzte Ziffer ?
            bne     lw2                     ;* nein
            clr     D2                      ;* sonst kein Space erlaubt
lw2:        divu    D1,D3                   ;* Rest durch Teiler
            beq     dez_1                   ;* ergab schon 0
            clr     D2                      ;* kein Space erlaubt
dez_1:      add.b   D2,D3                   ;* Space-Offset zuaddieren
            addi.b  #'0',D3                 ;* Offset fÅr Ascii
            move.b  D3,(A4)+                ;* ablegen in String
            swap    D3                      ;* Rest der Division nach vorn
            divu    #10,D1                  ;* nÑchster Teiler
            bne     lw1                     ;* wenn ungleich 0
            rts                             ;* sonst fertig


****************************************************************
**      Hier beginnt die neue Mausroutine                     **
****************************************************************


            .dc.b   'XBRA'              ;* XBRA-Protokoll
            .dc.b   'SCRT'              ;* eigene ID
mouse_vec:  .dc.l   0                   ;* alter Vektor
        
newmouse:   movem.l D0-D1/A0-A1,-(A7)   ;* Register retten
            btst    #2,act_conf         ;* Mover aktiv ?
            beq     no_mover            ;* Sprung, wenn nicht
            btst    #0,(A0)             ;* rechte Maustaste gedrÅckt ?
            bne     pull                ;* Sprung, wenn ja
no_mover:   clr.b   mkeyflag
            btst    #0,act_conf         ;* Speeder aktiv ?
            beq     mv_exit
            addq.l  #1,A0
            move.b  (A0),D0             ;* X-Bewegung
            bsr     fast
            move.b  (A0),D0             ;* Y-Bewegung
            bsr     fast
mv_exit:    movem.l (A7)+,D0-D1/A0-A1
            move.l  mouse_vec,-(A7)
            rts

fast:       move.b  D0,D1
            bpl     pos                 ;* Bewegung positiv ?
            neg.b   D1                  ;* sonst D1 positiv machen
pos:        cmpi.b  #Schwelle,D1        ;* mit Schwellwert vergleichen
            ble     nofast              ;* kleiner, nicht beschleunigen
            muls    D1,D0               ;* sonst quadrieren
            asr.b   #1,D0               ;* und halbieren
nofast:     move.b  D0,(A0)+            ;* zurÅckschreiben
            rts

            
****************************************************************
**          Screen verschieben

pull:       move.l  kbsadr,A1
            tst.b   (A1)          ;* Shift gedrÅckt ?
            bne     no_mover      ;* ja: nichts mehr tun
            andi.b  #$FE,(A0)+    ;* Maustaste lîschen
            move.b  (A0),D0       ;* X - Bewegung
            clr.b   (A0)+
            move.b  (A0),D1       ;* Y - Bewegung
            clr.b   (A0)          ;* lîschen
            st      mkeyflag      ;* Maustastenflag setzen
            addq.b  #1,D0
            asr.b   #2,D0         ;* X-Bewegung durch vier teilen
            ext.w   D1
            ext.w   D0
            muls.w  #5,D1         ;* Y-Bewegung mal 5
            add     D0,D1         ;* addieren
            sub.w   D1,actscr     ;* von aktueller Adresse abziehen
pl_exit:    bra     mv_exit       ;* RÅckkehr


****************************************************************
**          Neuer Keyboardinterrupt (benutzt keine Register!) **
**          Bildschirm prÅfen und einschalten                 **
****************************************************************

            .dc.b   'XBRA'              ;* XBRA-Kennung
            .dc.b   'SCRT'              ;* eigene ID
oldkbd:     .dc.l   0

newkbd:     tst.b     n_active          ;* Bildschirm dunkel ?
            beq       kb_exit           ;* nein
            clr.b     n_active          ;* Flag lîschen !
            bclr      #0,Vsync          ;* Screen an
kb_exit:    clr.w     n_count           ;* VerdunkelungszÑhler lîschen
            move.l    oldkbd,-(A7)      ;* Sprung per rts in Originalroutine
            rts


****************************************************************
**          Alternate-Help-Routine                            **
****************************************************************

            .dc.b   'XBRA'                  ;* XBRA-Protokoll
            .dc.b   'SCRT'                  ;* eigene ID
hc_vect:    .dc.l   0                       ;* alter Vektor

hcstart:    btst    #3,act_conf             ;* neue Routine aktiv ?
            beq     hc_old                  ;* nein, alte Routine
            move.l  A7,oldstack             ;* Stackpointer sichern
            lea     stack2,A7               ;* eigenen Stack benutzen
            movem.l D0-D7/A0-A6,-(A7)       ;* Register sichern
            clr.w   alt_flag                ;* Flag erstmal lîschen
            lea     my_save,A1              ;* Zeiger auf Savearea
            move.l  savptr,4(A1)            ;* alten Pointer merken
            move.l  A1,savptr               ;* eigene SaveArea benutzen
            move.l  a_intin,A0              ;* Maus verschwinden lassen:
            move.w  #1,(A0)                 ;* Aufrufe mitzÑhlen
            dc.w    A_HIDEM                 ;* LineA-Aufruf
            lea     sshiftmd,A2             ;* aktuelle Auflîsung
            btst    #4,act_conf             ;* Hardcopy oder Dump ?
            bne     sdump                   ;* 1: Sprung zum Screendump
            bsr     do_hc24
            bra     hcont
sdump:      bsr     scrdump
hcont:      move.l  a_contrl,a0             ;* Maus wieder sichtbar machen:
            move.w  #0,2(a0)                ;* Parameter setzen
            move.w  #3,6(a0)
            move.l  a_intin,a0
            move.w  #1,(a0)                 ;* Anzahl Aufrufe berÅcksichtigen
            dc.w    A_SHOWM                 ;* LineA-Aufruf
            move.l  old_save,savptr         ;* wieder alte SaveArea
            move.w  #$FFFF,alt_flag
            movem.l (A7)+,D0-D7/A0-A6       ;* Register zurÅck
            move.l  oldstack,A7             ;* alten Stackpointer aktivieren
            rts

hc_old:     move.l  hc_vect,-(A7)           ;* RÅcksprung per rts
            rts
        
****************************************************************
**          24-Nadel-Hardcopy                                 **
****************************************************************

do_hc24:    cmp.b   #2,(A2)                 ;* Auflîsung testen
            beq     do_2                    ;* nur weiter wenn Hires
            rts                             ;* sonst zurÅck
do_2:       bsr     get_screen              ;* Bildadresse holen
            move.l  D0,A5                   ;* Bildschirmstartadresse

            lea     pr_init,A4              ;* Drucker initialisieren
            bsr     stringout
            move.w  #33,D7                  ;* ZeilenzÑhler
nline:      move.l  A5,A3
            bsr     getlength               ;* LÑnge feststellen
            tst.w   D6                      ;* Zeile leer ?
            beq     endline                 ;* dann fertig
            subq    #1,D6                   ;* fÅr dbxx-Schleife
            lea     vorzeile,A4
            bsr     stringout
            tst.w   D7
            beq     lastline
nword:      moveq.l #15,D5                  ;* SpaltenzÑhler
nrow:       move.l  A3,A2                   ;* eine Druckspalte berechnen:
            moveq.l #11,D4                  ;* PunktzÑhler
            moveq.l #0,D1                   ;* Ergebnis erstmal lîschen
ndot:       move.w  (A2),D0                 ;* Wort aus Grafik holen
            lsr.w   D5,D0                   ;* gesuchten Punkt nach rechts
            and     #1,D0                   ;* Punkt ausmaskieren
            lsl.l   #1,D1                   
            or.b    D0,D1                   ;* in D1 einblenden
            lsl.l   #1,D1
            or.b    D0,D1                   ;* (zweimal einblenden)
            add.l   #80,A2                  ;* eine Zeile tiefer
            dbf     D4,ndot                 ;* nÑchster Punkt
            bsr     rowout                  ;* Spalte ausgeben
            bsr     rowout                  ;* (wenn doppelte Dichte)
            dbf     D5,nrow                 ;* nÑchste Spalte
            addq.l  #2,A3                   ;* ein Wort weiter
            dbf     D6,nword                ;* nÑchstes Wort
        
endline:
            lea     endzeile,A4
            bsr     stringout
            add.l   #12*80,A5               ;* 12 Zeilen = 1 Druckzeile
            tst     alt_flag                ;* Abbruch durch User ?
            dbne    D7,nline                ;* sonst nÑchste Zeile
        
            lea     endhc,A4
            bsr     stringout
            rts
        
**          Letzte Zeile (nur 4 Punkte hoch) drucken

lastline:
lword:      moveq.l #15,D5                  ;* SpaltenzÑhler
lrow:       move.l  A3,A2
            moveq.l #3,D4                   ;* PunktzÑhler
            moveq.l #0,D1
ldot:       move.w  (A2),D0                 ;* Bits verwursten (wie oben)
            lsr.w   D5,D0
            and     #1,D0
            lsl.l   #1,D1
            or.b    D0,D1
            lsl.l   #1,D1
            or.b    D0,D1
            add.l   #80,A2                  ;* eine Zeile tiefer
            dbf     D4,ldot                 ;* nÑchster Punkt
            swap    D1                      ;* unteres Wort bleibt leer
            bsr     rowout                  ;* Spalte ausgeben
            bsr     rowout                  ;* (wenn doppelte Dichte)
            dbf     D5,lrow                 ;* nÑchste Spalte
            addq.l  #2,A3                   ;* ein Wort weiter
            dbf     D6,lword

            bra     endline


**  LÑnge einer Bildschirmzeile holen (letztes benutztes Wort feststellen)
**  (zerstîrt D0,D1,D2,D3)
**  gibt Wortanzahl in D6 zurÅck, setzt 'Vorzeile' entsprechend

getlength:
            move.l  #80,D1                  ;* von rechts anfangen
            moveq.l #0,D0
gl_l1:      moveq.l #11,D3                  ;* 16*12 Feld testen
            move    D1,D2
gl_l2:      or      -2(A3,D2.w),D0          ;* Wort nach D0 odern
            add     #80,D2
            dbf     D3,gl_l2                ;* nÑchstes Wort
            tst     D0                      ;* Punkte gesetzt ?
            bne     gl_x1                   ;* wenn ja
            subq    #2,D1                   ;* ein Wort nach links
            bne     gl_l1                   ;* weiter prÅfen
gl_x1:      move    D1,D6                   ;* WortzÑhler setzen
            lsr     #1,D6
            asl     #4,D1                   ;* Anzahl Grafikspalten ber.
            move.b  D1,ll_low               ;* setzen
            lsr     #8,D1
            move.b  D1,ll_high
            rts
            

**      Grafikspalte (24 Punkte, rechtsbÅndig in D1) drucken:
**      (zerstîrt D0)

rowout:     move.l  D1,D0
            swap    D0
            bsr     cenout
            move.w  D1,D0
            lsr.w   #8,D0
            bsr     cenout
            move.b  D1,D0
            bsr     cenout
            rts
        
**      Textstring auf Drucker ausgeben:
**      (Adresse in A4, erstes Byte enthÑlt LÑnge-1, zerstîrt D0,D1)

stringout:  clr.l   D1
            move.b  (A4)+,D1
nchar:      move.b  (A4)+,D0
            bsr     cenout
            dbf     D1,nchar
            rts
        
**      Zeichen in D0 an Centronics-Port ausgeben.

cenout:     movem.l D0-D1,-(A7)     ;* D0 und D1 retten
            move.w  D0,-(A7)
            move.w  #0,-(A7)        ;* Ausgabe an Drucker
            move.w  #bconout,-(A7)
            trap    #Bios
            addq.l  #6,A7
            movem.l (A7)+,D0-D1
            rts
        

**********************************************************************
** Screendump-Routine                                               **
** macht GEMDOS-Aufrufe aus Interrupt, daher Register aus PD retten **
** (es kann trotzdem noch érger geben, da Gemdos im Gegensatz zu    **
**  BIOS und XBIOS kein biûchen reentrant ist. Wer weiû, wie man    **
**  sichere Gemdos-Aufrufe aus Interrupts macht, bitte melden)      **
**********************************************************************

scrdump:  move.l  apdadr,A0             ;* act_pd holen
          lea     (A0),A0               ;* dereferenzieren
          movem.l $68(A0),D0-D5         ;* 6 Longwords holen
          movem.l D0-D5,my_preg         ;* und sichern
          move.l  etv_crit,sv_critic    ;* Fehlerbehandlung installieren
          move.l  #sd_exit,etv_crit
          lea     deg_buf,A3
          moveq.l #0,D0
          move.b  (A2),D0               ;* Auflîsung holen
          move.w  D0,(A3)               ;* Kennung setzen
          add.b   #'1',D0               ;* in Ziffer wandeln
          move.b  D0,f_res              ;* in Filenamen schreiben
          lea     Palette,A0            ;* Adresse der Farbpalette 
          lea     2(A3),A1              ;* Puffer fÅr File
          moveq.l #15,D1
palcopy:  move    (A0)+,D0              ;* Palette  kopieren
          and     #%0000011101110111,D0 ;* Farbwerte ausmaskieren
          move    D0,(A1)+
          dbf     D1,palcopy
          
**        aktuelles Laufwerk erfragen:
          move.w  #dgetdrv,-(a7)
          trap    #Gemdos               ;* Dgetdrv(), akt. Laufwerk
          addq.l  #2,A7 

**        Dateinamen erzeugen:
          add.w   #$41,D0               ;* Buchstaben berechnen
          move.b  D0,filename 
          move.b  counter,fnummer       ;* ZÑhler in Namen
          addq.b  #1,counter
          cmpi.b  #$39,counter
          ble     sd_2                  ;* max. 9 Bilder
          move.b  #$30,counter

**        Datei îffnen:
sd_2:     clr.w   -(A7)                 ;* R/W
          move.l  #filename,-(A7)
          move.w  #Fcreate,-(A7)
          trap    #Gemdos               ;* Fcreate(R/W,Filename)
          addq.l  #8,A7 
          tst.w   D0                    ;* Fehler aufgetreten ?
          bmi     sd_exit               ;* direkt 'raus
          move.w  d0,fhandle            ;* Handle merken

**        Bildvorspann abspeichern:
          move.l  A3,-(A7)              ;* Adresse Vorspann
          move.l  #34,-(A7)             ;* LÑnge
          move.w  fhandle,-(A7) 
          move.w  #Fwrite,-(A7)
          trap    #Gemdos               ;* Fwrite(Adr,LÑnge,Handle)
          adda.l  #$C,A7
          tst.l   D0
          bmi     sd_exit

**        Bildschirm abspeichern:
          bsr     get_screen            ;* Bildadresse holen
          move.l  D0,-(A7)              ;* Bildschirm speichern
          move.l  #32000,-(A7)          ;* LÑnge
          move.w  fhandle,-(A7) 
          move.w  #Fwrite,-(A7)
          trap    #Gemdos               ;* Fwrite(Adr,LÑnge,Handle)
          adda.l  #$C,A7
          tst.l   D0
          bmi     sd_exit

**        Datei schlieûen :
          move.w  fhandle,-(A7)
          move.w  #Fclose,-(A7)
          trap    #Gemdos
          addq.l  #4,A7 

**        Ausstieg: Fehlervektor zurÅck
sd_exit:  move.l  sv_critic,etv_crit
          move.l  apdadr,A0             ;* Adresse der Prozeûadresse
          lea     (A0),A0               ;* Prozeûadresse
          movem.l my_preg,D0-D5         ;* gesicherte Register
          movem.l D0-D5,$68(A0)         ;* zurÅckschreiben
          rts 



****************************************************************
**          Neue VBL-Routine (Bildschirmzeiger, Uhr) :        **
****************************************************************

            .dc.b   'XBRA'              ;* XBRA-Protokoll
            .dc.b   'SCRT'              ;* eigene ID
            .dc.l   0                   ;* alter Vektor nicht erforderlich

newvbl:
            tst.b     clflag2           ;* Uhrenchip installiert ?
            beq       no_rtc            ;* nein
            bsr       m_vbl             ;* Routine fÅr RPC-Chip
            bra       msmv
no_rtc:     bsr       n_vbl             ;* keine Echtzeituhr
msmv:       btst      #2,act_conf       ;* Mover aktiv ?
            beq       vbl_s1            ;* nein
            lea       scrhigh,A2        ;* Shifter-Bildschirmadr.
            tst.b     mkeyflag          ;* Maustaste gedrÅckt ?
            beq       no_pull           ;* nein
do_pull:    move.w    actscr,D0         ;* bei gedrÅckter Taste
            movep.w   D0,0(A2)
            bra       vbl_s1
no_pull:    move.l    vbasadr,D0
            lsr.l     #8,D0
            move.w    D0,actscr
*           movep.w   D0,0(A2)          ;* wahlweise Screen halten

vbl_s1:     
vbl_exit:   rts


****************************************************************
**  VBL-Routine fÅr RPC 5C15 (Mega-Uhrenchip)                 **
****************************************************************

m_vbl:
            lea     RTC,A1              ;* RTC-Basisadresse
            lea     Mode,A0             ;* Adr. Modusregister
            move.b  (A0),-(A7)          ;* Mode-Register merken
            move.b  #Bank0,(A0)         ;* auf Bank 0 schalten
            move.b  (A1),D0             ;* 1er Sekunden holen
            and.b   #$0F,D0
            cmp.b   oldtime,D0          ;* mit altem Wert vergleichen
            beq     mvb_exit            ;* noch gleich: fertig
            move.b  D0,oldtime          ;* neuen Wert merken
            btst    #6,act_conf         ;* Bildschirmschoner aktiv ?
            beq     m_nonight           ;* Sprung wenn nicht
            lea     n_active,A2         ;* Adresse Bildschirmflag
            tst.b   (A2)                ;* dunkel ?
            bne     m_nonight           ;* Sprung wenn ja
            lea     n_count,A3          ;* Adr. ZÑhler
            move    (A3),D0
            addq    #1,D0               ;* weiterzÑhlen
            move    D0,(A3)
            cmp     night_time,D0
            blt     m_nonight           ;* noch nicht verdunkeln

            bsr     nightfall           ;* verdunkeln

m_nonight:  btst    #5,act_conf         ;* Zeitanzeige aktiv ?
            beq     mvb_exit            ;* nein

            bsr     cltest              ;* Uhrzeit schreiben ?
            bne     mvb_exit

m_ntst:     addq.l  #3,A3               ;* letztes Byte
            move.b  (A1),D0             ;* 1er Sekunden
            bsr     wr_ziff
            move.b  2(A1),D0            ;* 10er
            bsr     wr_ziff
            bsr     wr_dot              ;* Doppelpunkt
            move.b  4(A1),D0            ;* 1er Minuten
            bsr     wr_ziff
            move.b  6(A1),D0            ;* 10er
            bsr     wr_ziff
            bsr     wr_dot              ;* Doppelpunkt
            move.b  8(A1),D0            ;* 1er Stunden
            bsr     wr_ziff
            move.b  10(A1),D0           ;* 10er
            and.b   #$0F,D0             ;* frÅher als 10 Uhr ?
            bne     m_wr1               ;* fÅhrende Ziffer nicht Null ?
            moveq.l #10,D0              ;* sonst lîschen
m_wr1:      bsr     wr_ziff
                                    
mvb_exit:   move.b  (A7)+,(A0)          ;* RTC-Register restaurieren
            rts

****************************************************************
**          Screen aus: (Flagadresse in A2)

nightfall:  st      (A2)                ;* Flag setzen
            lea     cntmid,A3           ;* auf VBlank warten:
            move.b  scrmid,D0
n_wt1:      cmp.b   (A3),D0
            bne     n_wt1
            bset    #0,Vsync            ;* es wird Nacht
            rts
            
****************************************************************
**          Test, ob Uhr angezeigt werden soll

cltest:     lea     sshiftmd,A5         ;* Kennung der Auflîsung
            move.l  vbasadr,A3          ;* Bildschirmadr.
            lea     76(A3),A3           ;* letztes Longword in erster Zeile
            btst    #7,act_conf         ;* Uhrzeit immer anzeigen ?
            bne     test2               ;* ja, nur Kollisionstest
            move.l  desk_pd,D0          ;* PD des Desktop holen
            move.l  apdadr,A4           ;* Adresse von act_pd holen
            cmp.l   (A4),D0             ;* ist Desktop aktiv ?
            bne     cl_exit             ;* nein, direkt 'raus

test2:      cmp.b   #2,(A5)             ;* Hires ?
            bne     n_tst               ;* nein, nicht testen
            move.l  640(A3),D0          ;* ist es Null ?
            or.l    636(A3),D0
            rts                         ;* Auswertung beim Aufrufer
n_tst:      moveq.l #0,D0               ;* Uhr zeichnen
cl_exit:    rts
            

****************************************************************
**  VBL-Routine fÅr Rechner ohne RP5C15                       **
****************************************************************

n_vbl:
            lea     oldtime,A1
            move.l  gemtime,A2
            move    (A2),D7             ;* Gemdos-Zeit holen
            cmp     (A1),D7             ;* Zeit vergleichen
            beq     nvb_exit            ;* noch gleich
            move    D7,(A1)             ;* sonst neue Zeit merken
            btst    #6,act_conf         ;* Bildschirmschoner aktiv ?
            beq     n_nonight           ;* Sprung wenn nicht
            lea     n_active,A2         ;* Adresse Bildschirmflag
            tst.b   (A2)                ;* dunkel ?
            bne     n_nonight           ;* Sprung wenn ja
            lea     n_count,A3          ;* Adr. ZÑhler
            move    (A3),D0
            addq    #2,D0               ;* weiterzÑhlen (2 sek.!)
            move    D0,(A3)
            cmp     night_time,D0
            blt     n_nonight           ;* noch nicht verdunkeln

            bsr     nightfall           ;* verdunkeln

n_nonight:  btst    #5,act_conf         ;* Zeitanzeige aktiv ?
            beq     nvb_exit            ;* nein

            bsr     cltest              ;* Uhrzeit schreiben ?
            bne     nvb_exit

n_ntst:     addq.l  #3,A3               ;* letztes Byte
            move    #10,D6              ;* Divisor
            move    D7,D5               ;* Zeit holen
            and.l   #31,D5              ;* Sekunden
            asl     D5                  ;* mal 2
            divu    D6,D5               ;* durch 10
            swap    D5
            move.b  D5,D0               ;* 1er Sekunden
            bsr     wr_ziff
            swap    D5
            move.b  D5,D0               ;* 10er Sek
            bsr     wr_ziff
            bsr     wr_dot
            move    D7,D5               ;* Zeit in D5 restaurieren
            lsr     #5,D5
            and.l   #63,D5              ;* Minuten
            divu    D6,D5
            swap    D5
            move.b  D5,D0               ;* 1er Minuten
            bsr     wr_ziff
            swap    D5
            move.b  D5,D0               ;* 10er Minuten
            bsr     wr_ziff
            bsr     wr_dot
            move    D7,D5               ;* Zeit wieder neu nach D5
            lsr     #7,D5
            lsr     #4,D5
            and.l   #31,D5              ;* Stunden
            divu    D6,D5
            swap    D5
            move.b  D5,D0               ;* 1er Stunden
            bsr     wr_ziff
            swap    D5
            move.b  D5,D0
            and.b   #$0F,D0             ;* vor 10 Uhr ?
            bne     n_wr1               ;* fÅhrende Ziffer ausgeben
            moveq.l #10,D0              ;* sonst lîschen
n_wr1:      bsr     wr_ziff
nvb_exit:
            rts


****************************************************************
**  Ziffer auf Bildschirm schreiben:
**  Adresse oberstes Byte in A3
**  Ziffer in D0
**  benutzt A6,D0

wr_ziff:    and.l   #$0F,D0
            asl.l   #3,D0               ;* Adr. der Ziffer berechnen
            lea     ziffern,A6
            adda.l  D0,A6
            cmp.b   #2,(A5)             ;* Hires-Modus ?
            bne     col2                ;* nein, andere Ausgabe
            move.b  (A6)+,(A3)          ;* Ziffer direkt in Bildschirm
            move.b  (A6)+,80(A3)
            move.b  (A6)+,160(A3)
            move.b  (A6)+,240(A3)
            move.b  (A6)+,320(A3)
            move.b  (A6)+,400(A3)
            move.b  (A6)+,480(A3)
            move.b  (A6)+,560(A3)
            subq.l  #1,A3
            rts

col2:
            addq.l  #1,A6               ;* keine Leerzeile oben
            move.b  (A6)+,78(A3)        ;* Ziffer direkt in Bildschirm
            move.b  (A6)+,238(A3)
            move.b  (A6)+,398(A3)
            move.b  (A6)+,558(A3)
            move.b  (A6)+,718(A3)
            move.b  (A6)+,878(A3)
            move.b  (A6)+,1038(A3)
c_inc:      move.l  A3,D0
            and.b   #1,D0               ;* gerade Adresse ?
            bne     cx2                 ;* nein, fertig
            subq.l  #2,A3
            tst.b   (A5)                ;* Low-Res ?
            bne     cx2
            subq.l  #4,A3               ;* ja, noch was abziehen
cx2:        subq.l  #1,A3
            rts


****************************************************************
**  Doppelpunkt auf Bildschirm (Adr in A0, benutzt D0)

wr_dot:     moveq.l #%00011000,D0
            cmp.b   #2,(A5)
            bne     wrd2
            move.b  D0,240(A3)
            move.b  D0,400(A3)
            subq.l  #1,A3
            rts

wrd2:       move.b  D0,398(A3)
            move.b  D0,718(A3)
            bra     c_inc               ;* Adresse richtig erhîhen

                       
****************************************************************
**  Datensegment                                              **
****************************************************************

        .data

**          Text der ersten Dialogbox:
alert:      .dc.b   '[1]['
            .dc.b   ' **  Screen-Tools  V 1.0  **  |' 
            .dc.b   ' **  by Rolf Peukert ',$27,'89  **  |'
            .dc.b   ' Speicher :   '
freetx:     .dc.b   '         Bytes  |'
            .dc.b   ' TOS V 1.'
tosnum:     .dc.b   '0,   Echtzeituhr: '
clflag1:    .dc.b   'n  ]'
            .dc.b   '[ Setup |Default|Abbruch]',0

.even
****************************************************************
**  Definition der Ziffern :

ziffern:    
null:       .dc.b   %00000000
            .dc.b   %00111100
            .dc.b   %01000010
            .dc.b   %01000010
            .dc.b   %01000010
            .dc.b   %01000010
            .dc.b   %01000010
            .dc.b   %00111100

eins:       .dc.b   %00000000
            .dc.b   %00001000
            .dc.b   %00011000
            .dc.b   %00001000
            .dc.b   %00001000
            .dc.b   %00001000
            .dc.b   %00001000
            .dc.b   %00011100

zwei:       .dc.b   %00000000
            .dc.b   %00111100
            .dc.b   %01000010
            .dc.b   %00000100
            .dc.b   %00001000
            .dc.b   %00010000
            .dc.b   %00100000
            .dc.b   %01111110

drei:       .dc.b   %00000000
            .dc.b   %00111100
            .dc.b   %01000010
            .dc.b   %00000010
            .dc.b   %00011100
            .dc.b   %00000010
            .dc.b   %01000010
            .dc.b   %00111100

vier:       .dc.b   %00000000
            .dc.b   %01000010
            .dc.b   %01000010
            .dc.b   %01000010
            .dc.b   %00111110
            .dc.b   %00000010
            .dc.b   %00000010
            .dc.b   %00000010

fuenf:      .dc.b   %00000000
            .dc.b   %01111110
            .dc.b   %01000000
            .dc.b   %01000000
            .dc.b   %01111100
            .dc.b   %00000010
            .dc.b   %00000010
            .dc.b   %01111100

sechs:      .dc.b   %00000000
            .dc.b   %00111100
            .dc.b   %01000010
            .dc.b   %01000000
            .dc.b   %01111100
            .dc.b   %01000010
            .dc.b   %01000010
            .dc.b   %00111100

sieben:     .dc.b   %00000000
            .dc.b   %01111110
            .dc.b   %00000010
            .dc.b   %00000100
            .dc.b   %00001000
            .dc.b   %00010000
            .dc.b   %00100000
            .dc.b   %01000000

acht:       .dc.b   %00000000
            .dc.b   %00111100
            .dc.b   %01000010
            .dc.b   %01000010
            .dc.b   %00111100
            .dc.b   %01000010
            .dc.b   %01000010
            .dc.b   %00111100

neun:       .dc.b   %00000000
            .dc.b   %00111100
            .dc.b   %01000010
            .dc.b   %01000010
            .dc.b   %00111110
            .dc.b   %00000010
            .dc.b   %00000010
            .dc.b   %00111100

space:      .dc.l   0,0         ;* Leerzeichen

****************************************************************
**      Texte der Dialogboxen:

ms_frage:   .dc.b   '[2][Dynamischer|Mausbeschleuniger][ An |Aus]',0

sm_frage:   .dc.b   '[2][Bildschirmverschieber][ An |Aus]',0

cl_frage:   .dc.b   '[2][Uhrzeitanzeige][Desk|Immer|Aus]',0

nt_frage:   .dc.b   '[2][Bildschirmschoner|3 Min.][ An |Aus]',0

hc_frage:   .dc.b   '[2][Hardcopy-Routine][Orig.|24-Pin|Disk]',0

       
menu:       .dc.b   '  Screen-Tools',0        ;* Text f. MenÅzeile

****************************************************************
**          Drucker-Steuerzeichen:

pr_init:    .dc.b   2,$1B,'l',4             ;* linken Rand auf 4

vorzeile:   .dc.b   4,$1B,'*',39            ;* Graphik init.
ll_low:     .dc.b   $00
ll_high:    .dc.b   $05
** ^^^  fÅr doppelte Dichte: .dc.b 4,$1B,'*',39,$00,$05
** ^^^  fÅr einfache Dichte: .dc.b 4,$1B,'*',38,$80,$02 (wird etwas schneller)
**      (auûerdem muû die Routine 'getlength' geÑndert werden)

endzeile:   .dc.b   3,$1B,$4A,24,$0D        ;* Vorschub 24/180, CR
endhc:      .dc.b   2,$1B,'l',0             ;* linker Rand wieder bei 0


        .even
aespb:         .dc.l   contrl, global       ;* AES Parameter Block
               .dc.l   intin, intout
               .dc.l   addrin, addrout

**      Konfigurationen:
**
**      Bedeutung der Bits:   0  = $01  Mausbeschleuniger
**                            1  = $02  keine (hat hist. GrÅnde)
**                            2  = $04  Screen-Mover
**                            3  = $08  0= orig. Hardcopy  1= unsere Routine
**                            4  = $10  0= 24-Pin-HC       1= Screendump
**                            5  = $20  Uhrzeitanzeige
**                            6  = $40  Bildschirmschoner
**                            7  = $80  0= Uhr nur im Desk 1= Uhrzeit immer


            .dc.w   $DADA               ;* Kennung fÅr Diskmon
def_conf:   .dc.b   $61                 ;* mit 'Default' anwÑhlbar
act_conf:   .dc.b   $61                 ;* direkt nach Start aktiv

night_time: .dc.w   180                 ;* Zeit (s) fÅr Bildschirmschoner
counter:    .dc.b   $30                 ;* ZÑhler f. Screendump
filename:   .dc.b   'A:\SCREEN'         ;* f. MadMac '\' durch '\\' ersetzen
fnummer:    .dc.b   '0.PI'
f_res:      .dc.b   '0',0
n_active:   .dc.w   0                   ;* Flag: -1 wenn Screen dunkel
mkeyflag:   .dc.w   0                   ;* -1: rechte Taste gedrÅckt

        .bss
        .even
** diverse Zwischenspeicher:

kbdv_adr:       .ds.l   1       ;* Kbd-Routinen-Tabelle
kbsadr:         .ds.l   1       ;* Adresse von KBSHIFT
apdadr:         .ds.l   1       ;* Adresse von act_pd
desk_pd:        .ds.l   1       ;* PD des Desktop
tosver:         .ds.w   1       ;* TOS-Versionsnummer
n_count:        .ds.w   1       ;* ZÑhler fÅr Bildschirmschoner
oldtime:        .ds.w   1       ;* Merker fÅr letzte Uhrzeit
clflag2:        .ds.w   1       ;* -1 wenn Uhrenchip erkannt
actscr:         .ds.w   1       ;* neuer Screen f. Mover
fhandle:        .ds.w   1       ;* Filehandle fÅr Dump
a_intin:        .ds.l   1       ;* Adressen der Parameterarrays fÅr LineA
a_contrl:       .ds.l   1
sv_critic:      .ds.l   1       ;* Critical-Error-Handler
gemtime:        .ds.l   1       ;* Gemdos-Uhrzeit
oldstack:       .ds.l   1       ;* alter Stack bei Alt/Help-Routine
ap_id:          .ds.w   1       ;* eigener Application Identifier
desk_id:        .ds.w   1       ;* MenÅeintragsnummer
msgbuff:        .ds.w   16      ;* Puffer fÅr evnt_mesag

contrl:         .ds.w   12      ;* Parameterarrays fÅr GEM
global:         .ds.w   16
intin:          .ds.w   128
intout:         .ds.w   128
addrin:         .ds.l   9
addrout:        .ds.l   9

**              Puffer fÅr DEGAS-Bildvorspann:
deg_buf:        .ds.w   1       ;* Kennung $000x
dg_pal:         .ds.w   16      ;* Platz fÅr Palette 

**              Puffer fÅr BIOS-Save-Area
                .ds.l   255
my_save:        .ds.l   1 
old_save:       .ds.l   1       ;* Platz fÅr alten Vektor (nicht Ñndern)

**              Puffer fÅr GEMDOS-Register
my_preg:        .ds.l   6       ;* D0,A3-A6,*p_reg  =  6 Longwords

**              Platz fÅr eigenen Stack
                .ds.l   256
stack1:         .ds.l   1

**              Platz fÅr eigenen Stack (Alt-Help-Routine)
                .ds.l   256
stack2:         .ds.l   1
        .end

