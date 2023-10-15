;----------------------------------------------------;
;                                                    ;
;      OVERSCAN.S       Version 1.6                  ;
;      Bernd Gebauer   ,Berlin 31.05.89              ;
;      Karsten Isakovic,Berlin 07.07.89              ;
;                                                    ;
;  RAMTOS 1.4 / BETATOS / ROMTOS 1.4 / BLITTER TOS   ;
; -------------------------------------------------  ;
;                                                    ;
;      GFA-Assembler 1.2                             ;
;                                                    ;
;----------------------------------------------------;


; ------------ NEGATIVE LINE-A VARIABLEN -------------

M_POS_HX       = -$358
WKXRez         = -$2b4
WKYRez         = -$2b2
CUR_X          = -$158
CUR_Y          = -$156
CUR_FLAG       = -$154
MOUSE_FLAG     = -$153
SAVE_LEN       = -$14a
v_cel_ht       = -$2e
v_cel_mx       = -$2c
v_cel_my       = -$2a
v_cel_wr       = -$28
v_cur_add      = -$22
v_cur_of       = -$1e
v_cur_x        = -$1c
v_cur_y        = -$1a
v_rez_hz       = -$c
v_rez_vt       = -4
bytes_lin      = -2
; ---------- LINE-A VARIABLEN ------------------------

v_planes       = 0
width          = 2
col_bit0       = $18
col_bit1       = $1a
col_bit2       = $1c
col_bit3       = $1e
lstlin         = $20
lnmask         = $22
wmode          = $24
x1             = $26
y1             = $28
x2             = $2a
y2             = $2c
patptr         = $2e
patmsk         = $32
mfill          = $34
clip           = $36

; ----------------- HARDWARE + TOS -------------------

gemdos         = 1
bios           = 13
xbios          = 14
Pterm0         = 0       ; Gemdos
Cconin         = 1       ; Gemdos
Cnecin         = 8       ; Gemdos
Cconws         = 9       ; Gemdos
Dgetdrv        = 25      ; Gemdos
Ptermres       = 49      ; Gemdos
Fopen          = 61      ; Gemdos
Fclose         = 62      ; Gemdos
Fwrite         = 64      ; Gemdos
Fseek          = 66      ; Gemdos
Pterm          = 76      ; Gemdos
Kbshift        = 11      ; bios
Physbase       = 2       ; xbios
Setscreen      = 5       ; xbios
Supexec        = 38      ; xbios
Dosound        = 32      ; xbios
dostrap        = $84
gemtrap        = $88
xbiostrap      = $b8
memtop         = $436
defshiftmd     = $44b
sshiftmd       = $44c
v_bas_add      = $44e
_nvbls         = $454
_vblqueue      = $456
dumpflag       = $4ee
sysbase        = $4f2
hardcopy       = $502
vid_bashigh    = $ff8201
vid_basmid     = $ff8203
vid_ismid      = $ff8207
vid_pal3       = $ff8246
vid_palF       = $ff825e
add_len        = $9000

               .TEXT 
main:          bra.s     Start_of_Code       ; Zum Anfang springen

;#############################################################
;#
;# Die Tabelle der BildschirmWerte
;#
;#############################################################
ScreenTab:     .DC.w 400,832,672             ;   X-Auflîsung Low,Mid,High
               .DC.w 280,280,480             ;   Y-Auflîsung
               .DC.w 236,236,100             ;   Bytes pro Zeile
               .DC.l -$1600,-$1600,$2000     ;   VideoAdd  <> Memtop Offset
               .DC.l 252,248,9800            ;   v_bas_add <> Memtop Offset
               .DC.w 320,640,640             ;   Alte X-Auflîsung
               .DC.w 200,200,400             ;   Alte Y-Auflîsung
TruePhys:      .DC.w 0   ;                       Physbase Emulation aus
ActivateKey:   .DC.b 9,0 ;                       Hardcopy Taste
;#############################################################
;#
;# Das Hauptprogramm
;#
;#############################################################

Start_of_Code: movea.l   4(sp),a5            ; Basepointer einrichten
               lea.l     $100(a5),sp         ; Stack einrichten

               pea       do_setup(pc)        ; Test und Installation im
               move.w    #Supexec,-(sp)      ; Supervisormodus durchfÅhren
               trap      #xbios              ; Ergebnis in inst_ok
               addq.l    #6,sp

               move.w    inst_ok,d0
               tst.w     d0                  ; war Installation erfolgreich ?
               bne       not_ok              ; leider nein, raus

               move.w    #Dgetdrv,-(sp)      ; Bootlaufwerk holen
               trap      #gemdos             ;
               addq.l    #2,sp               ;
               lea.l     save_name(pc),a0    ;
               add.b     d0,(a0)             ; und einstellen

               move.w    #-1,-(sp)           ;   Irgendeine Sondertaste gedrÅckt
               move.w    #Kbshift,-(sp)      ;
               trap      #bios               ;
               addq.l    #4,sp               ;
               tst.w     d0
               beq       DoIntro
               bsr       UserInstall
               bra       DoTitle
DoIntro:       bsr       Intro               ; GrowBox und Sound ausgeben
DoTitle:       pea       msg_title(pc)       ; Titelzeile ausgeben
               move.w    #Cconws,-(sp)
               trap      #gemdos
               addq.l    #6,sp
               pea       msg_installed(pc)   ; 'Installiert' Meldung ausgeben
               move.w    #Cconws,-(sp)
               trap      #gemdos
               addq.l    #6,sp

               clr.w     -(sp)               ; Resident beenden
               lea.l     _ende(pc),a0        ;   Programmende
               suba.l    a5,a0               ; - Programmanfang
               move.l    a0,-(sp)            ; = Programmlaenge
               move.w    #Ptermres,-(sp)
               trap      #gemdos
;-----------------------------------------------------
not_ok:        pea       msg_title(pc)       ; Titelzeile ausgeben
               move.w    #Cconws,-(sp)
               trap      #gemdos
               addq.l    #6,sp
               move.w    inst_ok,d0
               cmpi.w    #1,d0               ; war's das falsche TOS ?
               bne       main_2              ; nein -> Kein Overscan-Modus

               pea       msg_notactive(pc)   ; 'Nicht aktiviert' Meldung ausgeben
               move.w    #Cconws,-(sp)
               trap      #gemdos
               addq.l    #6,sp
               bra       Goodbye             ; einfach beenden
;-----------------------------
main_2:        cmpi.w    #2,d0
               bne       main_3
               pea       msg_noTos(pc)       ; 'Falsches TOS' Meldung ausgeben
               move.w    #Cconws,-(sp)
               trap      #gemdos
               addq.l    #6,sp
               bra       wait_key            ; einfach beenden
;-----------------------------
main_3:        pea       msg_already(pc)     ; 'Schon installiert' Meldung
               move.w    #Cconws,-(sp)       ; ausgeben
               trap      #gemdos
               addq.l    #6,sp               ;  und
;-----------------------------
wait_key:      move.w    #Cnecin,-(sp)       ; Auf Tastendruck warten
               trap      #gemdos
               addq.l    #2,sp
;-----------------------------
Goodbye:       clr.w     -(sp)               ; Programm beenden (Returncode 0)
               trap      #gemdos

;############################################################
;#
;# Die Installations-Routine
;#
;#############################################################

do_setup:      movem.l   d0-d7/a0-a6,-(sp)
               move.w    #3,inst_ok          ; Status : schon installiert

               movea.l   dostrap,a0          ; GemDos-Trap nach OVERSCAN absuchen

tstXBRA:       cmpi.l    #'XBRA',-12(a0)     ; XBRA ?
               bne       noXBRA              ; nein -> Ende der Vektorkette
               cmpi.l    #'OVER',-8(a0)      ; OVER ?
               beq       EndSetup            ; ja   -> Schon Installiert !
               movea.l   -4(a0),a0           ;
               bra       tstXBRA             ; weiter suchen

noXBRA:        move.w    #2,inst_ok          ; Status : falsches TOS
;----------------------------  auf richtige TOS-Version testen

               sf        BadTos              ; TOS als ok annehmen

testBETATOS:   movea.l   #$170ee,a0          ;-------- Ist es BETA-RAMTOS ?
               cmpi.l    #$cec0e84f,(a0)     ; schon gepatched ?
               beq       isBETA              ; ja
               cmpi.l    #$e848cec0,(a0)     ;     LSR #4,D0 / MULU D0,D7 ?
               bne       testRAMTOS1_4       ; nein -> RAMTOS1.4
               move.l    #$cec0e84f,$170ee   ;     MULU D0,D7 / LSR #4,D7
isBETA:        movea.l   $5232,a0            ;     A0 = Zeiger auf MemAllocList
               bra       TOSok               ;

testRAMTOS1_4: movea.l   #$17192,a0          ;-------- Ist es RAMTOS 1.4 ?
               cmpi.l    #$cec0e84f,(a0)     ; schon gepatched ?
               beq       isRAMTOS1_4
               cmpi.l    #$e848cec0,(a0)     ;
               bne       testROMTOS1_4       ; nein -> ROMTOS1.4
               move.l    #$cec0e84f,$17192   ;     1. mal Scrollfehler
isRAMTOS1_4:   move.l    #$cec0e84f,$171d6   ;     2. mal Scrollfehler beheben
               movea.l   $5232,a0            ;     A0 = Zeiger auf MemAllocList
               bra       TOSok               ;

testROMTOS1_4: movea.l   sysbase,a1          ;-------- Ist es ROMTOS 1.4 ?
               cmpi.w    #$0104,2(a1)        ;     os_version testen
               bne       testTOS1_2          ; nein -> TOS 1.2 (BlitterTOS)
               movea.l   $532c,a0            ;     A0 = Zeiger auf MemAllocList
               bra       TOSok               ;

testTOS1_2:    cmpi.w    #$0102,2(a1)        ;-------- Ist es TOS 1.2 ?
               bne       EndSetup            ; nein -> falsches TOS -> ENDE
               st        BadTos              ;     BlitterTOS -> Flag setzen
               movea.l   $7e92,a0            ;     A0 = Zeiger auf MemAllocList

TOSok:         move.w    #1,inst_ok          ; Status : Nicht im OVERSCAN-Modus
;---------------------------------------------
; Ist der Schalter umgelegt (OVERSCAN aktiv) ?
; Es wird gewartet, bis der VideoadresszÑhler bis zum Ende
; der normalen Bildschirmseite hochgezÑhlt hat.
; Dann wird getestet, ob er auf den Anfang zurÅckspringt.
; Tut er das nicht, ist OVERSCAN aktiv.
               clr.w     d0
               move.b    vid_basmid,d0       ;
               move.w    d0,d1               ;
               addi.w    #$7d,d1             ;
Wait1:         cmp.b     vid_ismid,d1        ;
               bne       Wait1               ;
Wait2:         cmp.b     vid_ismid,d1        ;
               beq       Wait2               ;
               cmp.b     vid_ismid,d0        ;
               beq       EndSetup            ; Nicht aktiv -> Beenden

               clr.w     inst_ok             ; Status : OVERSCAN aktiv

               move.l    v_bas_add,StartBasAdd    ; Startaddr des Bildschirms

               move.l    memtop,d0           ;     Letzte beschreibbare Addresse
               addi.l    #$8000,d0           ;     bestimmen und merken
               move.l    d0,MemEnd           ;

               subi.l    #add_len,8(a0)      ;     Belegten Speicherblock
               subi.l    #add_len,memtop     ;     ... verkÅrzen

               tst.b     BadTos              ; BlitterTOS ?
               beq       no_extra_buff       ; nein, weiter
               subi.l    #32768,8(a0)        ;     32K Sicherheitpuffer ...
               subi.l    #32768,memtop       ;     ... vor Bildspeicher anlegen
no_extra_buff: 
               clr.w     d0
               move.b    sshiftmd,d0
               move.w    d0,Reso             ;     Auflîsung merken
               .DC.w $a000                   ; LineA init
               move.l    d0,LineA            ;     Zeiger auf LineA Variablen
               move.l    memtop,MyMemtop     ;     AltenWert sichern
               bsr       SetOverscan         ;     Overscan Werte einstellen
;
; Diese einmalige Initialisieren der Werte reicht nicht aus,
; da sie beim Starten vom AES wieder zurÅckgesetzt werden.
; Wir mÅssen also die Werte kurz nach v_opnwk nochmal setzen
;
;----------------------> ALSO  GEM-Routine (AES/VDI) umleiten
               lea.l     OldVec(pc),a0       ; Alten GemTrapVektor retten
               move.l    gemtrap,(a0)        ;
               lea.l     MyGem(pc),a0        ;
               move.l    a0,gemtrap          ; und neuen Vektor eintragen
               tst.b     BadTos              ; BlitterTOS ?
               beq       NoSlot              ; nein -> Nicht in VBL einhÑngen

               move.w    _nvbls,d0           ; Anzahl Routinen in _vblqueue
               lsl.w     #2,d0               ; mal sizeof(long)
               movea.l   _vblqueue,a0        ; Zeiger auf _vblqueue
               moveq.l   #4,d1               ; ersten Slot auslassen
TestSlot:      tst.l     0(a0,d1.w)          ; ist Eintrag frei ?
               beq.s     SlotFound           ; ja, gefunden
               addq.w    #4,d1               ; offset fÅr nÑchsten Slot
               cmp.w     d0,d1               ; Ende der Liste ?
               bne.s     TestSlot            ; nein, nÑchsten Slot testen
               bra       NoSlot              ; keinen freien Slot gefunden, raus
SlotFound:     
               lea.l     MyVB(pc),a1         ; eigene VBL-Routine ...
               move.l    a1,0(a0,d1.w)       ; ... in Slot eintragen
NoSlot:        
;---------------------------- Gemdos umleiten
               lea.l     OldDos(pc),a0       ;     Alten GemdosVektor retten
               move.l    dostrap,(a0)        ;
               lea.l     MyDos(pc),a0        ;
               move.l    a0,dostrap          ;     und neuen Vektor eintragen
;---------------------------- Xbios umleiten
               lea.l     OldXbios(pc),a0     ;     Alten XbiosVektor retten
               move.l    xbiostrap,(a0)      ;
               lea.l     MyXbios(pc),a0      ;
               move.l    a0,xbiostrap        ;     und neune Vektor eintragen
;---------------------------- Hardcopy-Routine umleiten
               lea.l     OldHard(pc),a0      ;     Alten HardcopyVektor retten
               move.l    hardcopy,(a0)       ;
               lea.l     MyHard(pc),a0       ;
               move.l    a0,hardcopy         ;     und neuen Vektor eintragen

               sf        GemStarted
EndSetup:      movem.l   (sp)+,d0-d7/a0-a6
               rts       

;#############################################################
;#
;# Die umgebogenen Traps und Vektoren
;# ----------------------------------
;#        MyGem      AES/VDI Trap
;#        MyDos      GEMDOS  Trap
;#        MyXbios    XBIOS   TRAP
;#        MyHard     Hardcopy-Vektor
;#        MyVB       VerticalBlank-Vektor (nur bei BlitterTOS )
;#        MyMouse    Mouse-Vektor         (nur bei BlitterTOS)
;#
;################################################ GEM- TRAP

; XBRA-Protokoll
               .DC.b "XBRAOVER"              ; !! Ja, das ist alles !!
OldVec:        .DC.l 0
MyGem:         cmpi.w    #$73,d0             ; Ist es ein VDI-Aufruf ?
               bne       NotMyGem            ;   nein -> weiter
               movea.l   d1,a0               ; Addresse der VDI-Parameterfelder
               move.l    12(a0),WorkOut      ; WorkOut-Zeiger speichern
               movea.l   (a0),a0             ; VDI-Control[0] = VDI-Befehlscode
               cmpi.w    #1,(a0)             ; ist es Open-WorkStation ?
               bne       NotMyGem            ;    nein-> weiter
               movea.l   d1,a0
               movea.l   4(a0),a0            ; WorkIn-Zeiger
               cmpi.w    #5,(a0)             ;    WorkIn[0] gleich Screen ?
               bge       NotMyGem            ;    nein -> weiter
;-------------> NACH !!! 'v_opnwk()' in Patchroutine springen
               move.l    2(sp),Back          ; Orginal RÅcksprungadresse merken
               lea.l     PatchIt(pc),a0      ; RÅcksprung auf 'PatchIt' ...
               move.l    a0,2(sp)            ; ... umleiten
NotMyGem:      movea.l   OldVec(pc),a0       ; Orginal GEM-Routine ...
               jmp       (a0)                ; ... ausfÅhren
;----------------------------------------------------------
PatchIt:       bsr       SetOverscan         ; LineA Werte nochmal eintragen

               move.w    #-1,-(sp)           ;   Auf rechte Schifttaste testen
               move.w    #Kbshift,-(sp)      ;
               trap      #bios               ;
               addq.l    #4,sp               ;
               tst.w     d0
               beq       PatchCont

               bsr       UserInstall

PatchCont:     bsr       ClearScreen         ; Rand lîschen
               pea       msg_erase(pc)       ; und Mitte auf Weiss
               move.w    #Cconws,-(sp)       ;
               trap      #gemdos             ;
               addq.l    #6,sp               ;
               st        GemStarted          ; Okay GEM lÑuft
               movea.l   WorkOut,a0          ; Adresse des Workout-Feldes
               move.w    RezX,0(a0)          ; Work_out[0] = Breite
               move.w    RezY,2(a0)          ; Work_out[1] = Hîhe

               move.w    VPlanes,d0          ; Farben Vorgeben
               cmpi.w    #4,d0
               bne       PatchMid
               move.w    #200,78(a0)
               move.w    #16,26(a0)
               bra       PatchEnd
PatchMid:      cmpi.w    #2,d0
               bne       PatchHigh
               move.w    #200,78(a0)
               move.w    #4,26(a0)
               bra       PatchEnd
PatchHigh:     
               move.w    #2,78(a0)
               move.w    #2,26(a0)

PatchEnd:      move.l    Back,-(sp)          ; Zum 'v_opnwk()' - Aufrufer
               rts                           ;   zurÅckspringen
;################################################ GEMDOS-Trap
               .DC.b "XBRAOVER"
OldDos:        .DC.l 0
MyDos:         move.w    (sp),d0             ; Je nachdem ob GEMDOS vom
               btst      #13,d0              ; Supervisor- oder User-modus
               bne       no_super            ; aufgerufen wurde sind die
               move.l    usp,a0              ; Parameter auf dem entsprechendem
               bra       tst_term            ; Stack
no_super:      lea.l     6(sp),a0
tst_term:      cmpi.w    #Pterm0,(a0)        ; Der Overscan-Modus wird
               beq       TermFound           ; NACH jedem Programm nocheinmal
               cmpi.w    #Pterm,(a0)         ; neu installiert, da viele
               bne       NoTerm              ; Programme den Bildschirm umsetzen
TermFound:     movem.l   d0-d7/a0-a6,-(sp)   ; oder direkt beschreiben.
               bsr       SetOverscan         ;
               bsr       ClearScreen         ;
NoClear:       movem.l   (sp)+,d0-d7/a0-a6
NoTerm:        movea.l   OldDos(pc),a0
               jmp       (a0)
;################################################ XBIOS-Trap
               .DC.b "XBRAOVER"
OldXbios:      .DC.l 0
MyXbios:       move.w    TruePhys,d0
               beq       No_Xbios
               move.w    (sp),d0             ; Je nachdem ob XBIOS vom
               btst      #13,d0              ; Supervisor- oder User-modus
               bne       no_x_super          ; aufgerufen wurde sind die
               move.l    usp,a0              ; Parameter auf dem entsprechendem
               bra       tst_phys            ; Stack
no_x_super:    lea.l     6(sp),a0
tst_phys:      cmpi.w    #Physbase,(a0)      ; Beim Physbase-Aufruf wird
               beq       PhysFound           ;
No_Xbios:      movea.l   OldXbios(pc),a0
               jmp       (a0)
PhysFound:     move.l    v_bas_add,d0        ; v_bas_add zurÅckgegeben
               rte       
;################################################ HARDCOPY-Vec
               .DC.b "XBRAOVER"              ;  HARDCOPY
OldHard:       .DC.l 0   ;
MyHard:        move.w    #-1,-(sp)           ;   Auf Shift ALT/HELP testen
               move.w    #Kbshift,-(sp)      ;
               trap      #bios               ;
               addq.l    #4,sp               ;
               cmp.b     ActivateKey,d0      ;   ja -> eigene Routine
               beq       NewHard             ;
               movea.l   OldHard(pc),a0      ;   nein -> alte Routine anspringen
               jmp       (a0)                ;
;------------------------------------------
NewHard:       movem.l   d0-d7/a0-a6,-(sp)
               bsr       SetOverscan         ;     Overscan Werte nochmal setzen
               bsr       ClearScreen         ;     BilschirmrÑnder lîschen
DoNotClear:    move.w    #-1,dumpflag        ;  Hardcopy-DumpFlag lîschen
EndHard:       movem.l   (sp)+,d0-d7/a0-a6
               rts                           ; zurÅck
;################################################ VBL-Vektor
               .DC.b "XBRAOVER"              ; VerticalBlank nur bei BLITTER-TOS
               .DC.l 0
MyVB:          tst.b     GemStarted          ; LÑuft GEM schon
               beq.s     MyVB_1              ; nein, raus

               movea.l   _vblqueue,a0        ; in VBL-Slot 0 schon ...
               tst.l     (a0)                ; ... GEM-Mausroutine installiert ?
               beq.s     MyVB_1              ; nein, raus

               pea       MyMouse(pc)         ; durch eigene Mausroutine ...
               move.l    (sp)+,(a0)          ; ... ersetzen

; ???????????????????????????
               movea.l   MouseVec,a0
               cmpi.l    #$fcfe82,(a0)
               bne.s     MyVB_1
               move.w    sr,-(sp)
               ori.w     #$700,sr
               move.l    #$fcfe8c,(a0)
               move.w    (sp)+,sr
MyVB_1:        rts       
;################################################ MOUSE-Vektor
               .DC.b "XBRAOVER"              ; MouseVec nur bei BLITTER-TOS
               .DC.l 0
MyMouse:       move.w    sr,-(sp)            ; Alte Interruptmaske merken
               ori.w     #$0700,sr           ; alle Interrupts sperren

               movea.l   LineA,a0            ; Zeiger auf LineA Variablen
               bclr      #0,CUR_FLAG(a0)     ; !0 -> Maus neu zeichnen ?
               beq.s     MyMouse_2           ; nein, raus

               clr.l     d0
               clr.l     d1
               move.w    CUR_X(a0),d0        ; Maus X-Position holen
               move.w    CUR_Y(a0),d1        ; Maus Y-Position holen
               move.w    (sp)+,sr            ; wieder Interrupts zulassen
               tst.b     MOUSE_FLAG(a0)      ; !0 -> Mausinterrupt ein ?
               bne.s     MyMouse_1           ; ja, raus

               movem.w   d0/d1,-(sp)         ; Register retten

               lea.l     SAVE_LEN(a0),a2     ; Zeiger auf LineA SpriteSaveBuffer
               bsr       UndrawSprite        ; Mauszeiger lîschen

               movem.w   (sp)+,d0/d1         ; Register restaurieren

               movea.l   LineA,a0
               lea.l     SAVE_LEN(a0),a2     ; Zeiger auf LineA SpriteSaveBuffer
               lea.l     M_POS_HX(a0),a0     ; SDB-Zeiger fÅr LineA-MausSprite
               bsr       DrawSprite          ; Mauszeiger neu zeichnen
MyMouse_1:     
               rts                           ; raus
MyMouse_2:     
               move.w    (sp)+,sr            ; wieder Interrupts zulassen
               rts                           ; raus


;#############################################################
;#
;# Die wichtigsten Unterprogramme
;# ------------------------------
;#     SetOverscan       LineA und Auflîsung initialisieren
;#     ClearScreen       Nur BildschirmRÑnder auf Schwarz
;#     ClearFullScreen   Ganzen Bildschirmspeicher lîschen
;#
;#############################################################

SetOverscan:   clr.l     d2
               move.b    sshiftmd,d2         ; Aktuelle Aufîsung
               move.w    d2,Reso             ;    merken
               add.w     d2,d2               ; mal 2 als Word-Offset in Tabelle
               lea.l     ScreenTab(pc),a0    ; TabellenZeiger holen
               move.w    0(a0,d2.w),RezX     ; X-Auflîsung
               move.w    6(a0,d2.w),RezY     ; Y-Auflîsung
               move.w    12(a0,d2.w),BpL     ; Bytes pro Zeile
               add.w     d2,d2               ; mal 2 als Long-Offset
               move.l    18(a0,d2.w),d0      ; Offset  MEMTOP <> VIDEO_ADD
               move.l    30(a0,d2.w),d1      ; Offset  MEMTOP <> V_BAS_ADD
               move.w    d1,Offset           ; merken
;----------------------------  Videoaddresse auf 'memtop + D0'
               move.l    MyMemtop,v_bas_add
               tst.b     BadTos              ; Bei BlitterTOS
               beq       no_buff_1           ;     hinter Sicherheits-
               addi.l    #32768,v_bas_add    ;     Puffer beginnen
no_buff_1:     
               add.l     d0,v_bas_add
               move.b    v_bas_add+1,vid_bashigh  ; Addresse setzen
               move.b    v_bas_add+2,vid_basmid
               move.l    v_bas_add,VidAdd    ;       und merken
;----------------------------  v_bas_ad auf 'memtop + D1' setzen
               move.l    MyMemtop,v_bas_add
               tst.b     BadTos              ; Bei BlitterTOS
               beq       no_buff_2           ;     hinter Sicherheitspuffer
               addi.l    #32768,v_bas_add    ;
no_buff_2:     
               add.l     d1,v_bas_add        ;         v_bas_add setzen
               move.l    v_bas_add,BasAdd    ;         und merken
;--------------- Werte in den negativen LineA Variablen anpassen
               movea.l   LineA,a0            ; LineA Zeiger holen
               move.w    RezX,v_rez_hz(a0)   ; Breite setzen
               move.w    RezX,WKXRez(a0)     ;
               subi.w    #1,WKXRez(a0)       ; Breite-1
               move.w    RezY,v_rez_vt(a0)   ; Hîhe   setzen
               move.w    RezY,WKYRez(a0)     ;
               subi.w    #1,WKYRez(a0)       ; Hîhe-1
               move.w    BpL,bytes_lin(a0)   ; Bytes pro Zeile setzen
               move.w    BpL,width(a0)       ;
               move.w    RezX,d0             ;
               asr.w     #3,d0               ;
               subq.w    #1,d0               ; Breite/8 -1
               move.w    d0,v_cel_mx(a0)     ; -> Anzahl Buchstaben pro Zeile
               clr.l     d0                  ;
               move.w    RezY,d0             ;
               divu.w    v_cel_ht(a0),d0     ;
               subq.w    #1,d0               ; Hîhe/Buchstabenhîhe -1
               move.w    d0,v_cel_my(a0)     ; -> Anzahl Buchstabenzeilen
               move.w    v_cel_ht(a0),d0     ;
               mulu.w    BpL,d0              ; AnzBuchstaben*BytesProZeile
               move.w    d0,v_cel_wr(a0)     ; -> BlocklÑnge fÅr Scrolling
               move.w    v_planes(a0),VPlanes     ; Anzahl der Farbebenen
               tst.b     BadTos              ; BLITTER-TOS ?
               beq       setLineA_1          ; nein -> fertig
;-----------------------------
               move.w    #3,MonPLine
               move.b    sshiftmd,d0
               cmpi.b    #1,d0
               bgt       setLineA_1
               move.w    #2,MonPLine
               tst.b     d0
               bne       setLineA_1
               move.w    #1,MonPLine
setLineA_1:    bsr       ResetCursor         ; Neue CursorAddresse bestimmen
               rts       
;-----------------------------
CallSetOverscan:         
               move.w    sr,d0
               btst      #13,d0
               beq       DoCallOver
               bra       SetOverscan
DoCallOver:    pea       SetOverscan(pc)     ; im
               move.w    #Supexec,-(sp)      ; Supervisormodus durchfÅhren
               trap      #xbios              ;
               addq.l    #6,sp
               rts       
;#############################################################
ClearScreen:   bsr       BlackColor          ; Lîschfarbe holen in D0
               move.l    d0,d4               ;
;-----------------------------
               movea.l   VidAdd,a1           ; Oberen Rand lîschen
               movea.l   BasAdd,a0           ;
               subq.l    #2,a0               ; Falls HIGH_OFF nicht /4 teilbar
Hflp:          move.l    d4,(a1)+            ; Vor dem Bildschirm RÅcklauf
               cmpa.l    a0,a1               ; Pixel auf Schwarz setzen
               blt       Hflp                ;
;-----------------------------
               move.w    Reso,d5             ;
               movea.l   BasAdd,a0           ; Links & Rechts im RÅcklauf lîschen
               clr.l     d0                  ; Den ungenutzten Bereich im
               clr.l     d1                  ; RÅcklauf auf Schwarz setzen
               move.w    BpL,d0              ; Bytes pro Zeile - Pixel/xxx
               move.w    RezX,d1             ;
               addq.w    #1,d5
               asr.w     d5,d1               ;   >>3:High  >>2:Mid  >>1:Low
               sub.w     d1,d0               ;
               move.w    RezY,d2             ; Hîhe des Bereichs
               subq.w    #1,d2               ;
               subq.w    #1,d0               ;
Hlp1:          adda.l    d1,a0               ; Normalen Bildbereich Åberspringen
               move.w    d0,d3               ;
Hlp2:          move.b    d4,(a0)+            ; Bereich lîschen
               dbf       d3,Hlp2             ;
               dbf       d2,Hlp1             ;
;-----------------------------
               move.l    a0,d0               ; Unteren Bildrand lîschen
               bclr      #0,d0               ; Zeiger auf gerade Addresse
               movea.l   d0,a0               ; bringen
               move.l    MemEnd,d1           ; Anzahl der zulîschenden Blîcke
               sub.l     d0,d1               ; Speicherende minus ZeigerAddr
               asr.l     #4,d1               ; durch 16 (BlocklÑnge)
               subq.l    #1,d1               ; minus 1 (wegen dbf)
;-----------------------------
Hlp3:          move.l    d4,(a0)+            ; auf Schwarz lîschen
               move.l    d4,(a0)+            ;
               move.l    d4,(a0)+            ;
               move.l    d4,(a0)+            ;
               dbf       d1,Hlp3             ;
               rts                           ; fertig
;-----------------------------
CallClearScreen:         
               move.w    sr,d0
               btst      #13,d0
               beq       DoCallClearSc
               bra       ClearScreen
DoCallClearSc: pea       ClearScreen(pc)     ; im
               move.w    #Supexec,-(sp)      ; Supervisormodus durchfÅhren
               trap      #xbios              ;
               addq.l    #6,sp
               rts       
;#############################################################
; Gesamten Bildspeicher lîschen (auf schwarz)
; Lîschfarbe bestimmen
ClearFullScreen:         
               bsr       BlackColor          ; Lîschwert holen in D0
               move.l    #$8000,d1           ; LÑnge des alten Bildschirmspeichers
               addi.l    #add_len,d1         ; plus Erweiterung
               lsr.l     #4,d1               ; geteilt durch 16L
               subq.l    #1,d1               ; minus 1 wegen dbf
;-----------------------------
               movea.l   MyMemtop,a0         ; ab MEMTOP lîschen
               tst.b     BadTos              ; BlitterTOS ?
               beq       sc_clp              ; Sicherheitspuffer beachten
               adda.l    #32768,a0           ; alte LÑnge
;-----------------------------
sc_clp:        move.l    d0,(a0)+            ;
               move.l    d0,(a0)+            ;
               move.l    d0,(a0)+            ;
               move.l    d0,(a0)+            ;
               dbf       d1,sc_clp           ; die nÑchsten 16 Bytes
               bsr       ResetCursor
               rts                           ; fertig
;-----------------------------
CallClearFull: 
               move.w    sr,d0
               btst      #13,d0
               beq       DoCallClearFu
               bra       ClearFullScreen
DoCallClearFu: pea       ClearFullScreen(pc) ; im
               move.w    #Supexec,-(sp)      ; Supervisormodus durchfÅhren
               trap      #xbios              ;
               addq.l    #6,sp
               rts       
;-----------------------------
BlackColor:    move.l    #-1,d0              ; erstmal FÅllwert $FFFFFFFF
               move.w    Reso,d1             ; Bildschirmmodus ...
               cmpi.w    #2,d1               ; ... Monochrom ?
               bne       NotWhite            ; nein, weiter
               btst      #0,$ff8241          ; Inverse Monochrome ?
               bne       NotWhite            ; nein, Farbe richtig
               not.l     d0                  ; sonst FÅllwert $0
NotWhite:      rts       
;-----------------------------
CallBlackColor:          
               move.w    sr,d0
               btst      #13,d0
               beq       DoCallBlackCo
               bra       BlackColor
DoCallBlackCo: pea       BlackColor(pc)      ; im
               move.w    #Supexec,-(sp)      ; Supervisormodus durchfÅhren
               trap      #xbios              ;
               addq.l    #6,sp
               rts       
;#############################################################
; Retten des alten SchirmInhaltes in den neuen OVERSCAN Bildschirm
;
ScreenSave:    movem.l   d0-d7/a0-a6,-(sp)   ;
               movea.l   StartBasAdd,a0      ; Bildschirmspeicher kurz
               movea.l   MyMemtop,a1         ; vor MemTop kopieren !
               suba.l    #$8000,a1           ;
               move.l    #1000,d0
ScSaveLoop:    movem.l   (a0)+,d1-d7/a2
               movem.l   d1-d7/a2,(a1)
               lea.l     32(a1),a1           ; 32 Bytes transportieren
               dbf       d0,ScSaveLoop
               movem.l   (sp)+,d0-d7/a0-a6
               rts       
;---------------------------------------------------------
ScreenCopy:    movem.l   d0-d7,-(sp)         ;
               movea.l   BasAdd,a0           ; Bildschirmspeicher wieder
               movea.l   MyMemtop,a1         ; zurÅckkopieren
               suba.l    #$8000,a1           ;
               move.w    #160,d0             ; Alte Breite in BYTE D0
               move.w    #200,d1             ; Alte Hîhe            D1
               cmpi.w    #2,Reso             ;
               bne       CopyNoHigh          ;
               move.w    #80,d0              ; High-Reso
               move.w    #400,d1             ;
CopyNoHigh:    clr.l     d2                  ;
               move.w    BpL,d2              ; Neue Bytes Pro Line  D3
               sub.w     d0,d2               ; Differenz Neue-Alte
               asr.w     #2,d0               ; /4 -> Longs
               subq.w    #1,d0               ; wegen dbf -> LONGs to copy
               subq.w    #1,d1               ; Lines to Copy
               subq.w    #1,d2               ; Rest zu lîschen

CopyLoop:      move.w    d0,d3               ;
Copy_1:        move.l    (a1)+,(a0)+         ; Alten Schirm kopieren
               dbf       d3,Copy_1           ;
               move.w    d2,d3               ;
Copy_2:        clr.b     (a0)+               ;
               dbf       d3,Copy_2           ; Zeile bis Ende lîschen
               dbf       d1,CopyLoop         ;

               bsr       CallClearScreen
               bsr       ResetCursor         ; CursorAddr bestimmen
               movem.l   (sp)+,d0-d7
               rts       
;#####################################################################
; Neue CursorAddresse bestimmen
;
ResetCursor:   movea.l   LineA,a0            ;
               move.l    BasAdd,v_cur_add(a0)     ;  Neue Addresse
               move.w    v_cur_y(a0),d0      ;    = V_bas_add
               mulu.w    v_cel_wr(a0),d0     ;
               add.l     d0,v_cur_add(a0)    ;      + y * cel_wr
               move.w    v_cur_x(a0),d0      ;
               bclr.l    #0,d0               ;      + x^1 * v_planes
               mulu.w    v_planes(a0),d0     ;
               add.l     d0,v_cur_add(a0)    ;      + x^1 * planes
               move.w    v_cur_x(a0),d0      ;
               andi.l    #$fffe,d0           ;
               add.w     d0,v_cur_add(a0)    ;      + x&1
               clr.l     d0                  ;
               move.w    v_cur_of(a0),d0     ;
               add.l     d0,v_cur_add(a0)    ;      + cursor_offset
               rts       
;#############################################################
;#
;# INTRO GrowBox Effekt und Sound
;#
;#############################################################

Intro:         bsr       ScreenSave
               pea       SoundTab(pc)        ; Sound abspielen
               move.w    #Dosound,-(sp)
               trap      #xbios
               addq.l    #6,sp
;-----------------------------
               clr.w     d0
               bsr       set_color
               move.w    Reso,d5             ; Aktuelle Aufîsung
               add.w     d5,d5               ; mal 2 als Word-Offset in Tabelle
               lea.l     ScreenTab(pc),a0
               move.w    RezX,d6             ; D6 = (Breite - AlteBreite)/2
               cmp.w     42(a0,d5.w),d6      ; Neue Breite kleiner als Alte ?
               blt       EndIntro            ;     ja -> Nur Schirm kopieren
               sub.w     42(a0,d5.w),d6
               asr.w     #1,d6
               move.w    d6,d0               ; als X1
               move.w    d0,d2
               add.w     42(a0,d5.w),d2      ; X2 = X1 + AlteAuflîsung
               move.w    RezY,d7             ; D7 = (Hîhe   - AlteHîhe  )/2
               cmp.w     48(a0,d5.w),d7      ; Neue Hîhe kleiner als Alte ?
               blt       EndIntro            ;     ja -> Nur Schirm kopieren
               sub.w     48(a0,d5.w),d7
               asr.w     #1,d7
               move.w    d7,d1               ; als Y1
               move.w    d1,d3
               add.w     48(a0,d5.w),d3      ; Y2 = Y1 + AlteAuflîsung
               move.w    d6,Dx               ; Alle Werte abspeichern
               move.w    d7,Dy               ;
               move.w    d0,Xa               ;
               move.w    d1,Ya               ;
               move.w    d2,Xe               ;
               move.w    d3,Ye               ;

               movem.l   d0-d7/a0-a6,-(sp)
               bsr       CallClearFull
               movem.l   (sp)+,d0-d7/a0-a6

               bsr       draw_rect           ; Das gefÅllte Rechteck zeichnen
;-------------------------------------------------------------
               move.w    d6,Max              ; In welche Richtung ist der
               cmp.w     d6,d7               ; Zugewinn am grîûten ?
               blt       grow_box            ;
               move.w    d7,Max              ;
grow_box:      move.w    #1,d6               ; Zaehler
grow_loop:     
               clr.w     d7                  ; Schleife fÅr die grîûer werdenden
               move.w    Dx,d4               ; Rechtecke. Die Bewegung soll
               mulu.w    d6,d4               ; proportional verlaufen...
               divu.w    Max,d4              ; ...deswegen der ganze Hermann
               move.w    Dy,d5               ;
               mulu.w    d6,d5
               divu.w    Max,d5

               cmpi.w    #0,d0               ; X links oben
               beq       no_d0
               move.w    Xa,d0
               sub.w     d4,d0
               addq.w    #1,d7
no_d0:         cmpi.w    #0,d1               ; Y links oben
               beq       no_d1
               move.w    Ya,d1
               sub.w     d5,d1
               addq.w    #1,d7
no_d1:         cmp.w     RezX,d2             ; X rechts unten
               beq       no_d2
               move.w    Xe,d2
               add.w     d4,d2
               addq.w    #1,d7
no_d2:         cmp.w     RezY,d3             ; Y rechts unten
               beq       no_d3
               move.w    Ye,d3
               add.w     d5,d3
               addq.w    #1,d7
no_d3:         bsr       draw_box            ; das Rechteck zeichnen
;-----------------------------
               addq.w    #1,d6               ;
               tst.w     d7                  ; Solange sich noch was Ñndert
               bne       grow_loop           ; die Rechteckschleife wiederholen

EndIntro:      bsr       ResetCursor
               bra       ScreenCopy

;-----------------------------
set_color:     movea.l   LineA,a0            ; Farbe setzen
               move.w    d0,col_bit0(a0)     ;
               move.w    d0,col_bit1(a0)     ;
               move.w    d0,col_bit2(a0)     ;
               move.w    d0,col_bit3(a0)     ;
               rts       
;---------------------------------
draw_box:      movea.l   LineA,a0            ; Ein Rechteck aus Linien zeichnen
               clr.w     wmode(a0)           ; d0/d1 linke  obere  Ecke
               move.w    #$ffff,lnmask(a0)   ; d2/d3 rechte untere Ecke
               move.w    #1,lstlin(a0)
               move.w    d0,x1(a0)
               move.w    d1,y1(a0)
               move.w    d2,x2(a0)
               move.w    d1,y2(a0)
               bsr       draw_line           ; Oben
               movea.l   LineA,a0
               move.w    d2,x1(a0)
               move.w    d1,y1(a0)
               move.w    d2,x2(a0)
               move.w    d3,y2(a0)
               bsr       draw_line           ; Rechts
               movea.l   LineA,a0
               move.w    d2,x1(a0)
               move.w    d3,y1(a0)
               move.w    d0,x2(a0)
               move.w    d3,y2(a0)
               bsr       draw_line           ; Unten
               movea.l   LineA,a0
               move.w    d0,x1(a0)
               move.w    d1,y1(a0)
               move.w    d0,x2(a0)
               move.w    d3,y2(a0)
               bsr       draw_line           ; Links
               rts       
;-----------------------------
draw_diag:     movea.l   LineA,a0            ; Diagonalen zeichnen
               move.w    d0,x1(a0)           ;
               move.w    d1,y1(a0)           ; Parameter wie oben
               move.w    d2,x2(a0)           ;
               move.w    d3,y2(a0)
               bsr       draw_line           ; Diagonale links
               movea.l   LineA,a0
               move.w    d2,x1(a0)
               move.w    d1,y1(a0)
               move.w    d0,x2(a0)
               move.w    d3,y2(a0)
               bsr       draw_line           ; Diagonale rechts
EndBox:        rts       
;-----------------------------
draw_line:     movem.l   d0-d7,-(sp)         ; Einzelne Linie Ziehen
               .DC.w $a003
               movem.l   (sp)+,d0-d7
               rts       
;-----------------------------
pattern:       .DC.w $ffff                   ; Fuellmuster
;-----------------------------
draw_rect:     movem.l   d0-d7,-(sp)         ; Ein Rechteck zeichnen
               movea.l   LineA,a0            ;
               move.w    #1,mfill(a0)        ; d0/d1 linke  obere  Ecke
               clr.w     wmode(a0)           ; d2/d3 rechte untere Ecke
               move.w    d0,x1(a0)
               move.w    d1,y1(a0)
               move.w    d2,x2(a0)
               move.w    d3,y2(a0)
               lea.l     pattern(pc),a1
               move.l    a1,patptr(a0)
               move.w    #1,patmsk(a0)
               clr.w     clip(a0)
               .DC.w $a005
               movem.l   (sp)+,d0-d7
               rts       

;#############################################################
;#
;# OVERSCAN - Einstellung
;#
;#############################################################

UserInstall:   bsr       UserInit            ; Initialisieren
UserLoop:      move.w    #0,d0               ; Wiederhole
               bsr       DrawSetup           ;
               bsr       WriteSetup          ;     Zeichne Kreuz und Werte
               bsr       GetKey              ;     Hole Taste
               move.w    #1,d0               ;
               bsr       DrawSetup           ;     Lîsche Kreuz
               bsr       ChangeSetup         ;     Bearbeite Taste
               tst.w     UserSave            ;
               beq       UserLoop            ; Bis EndeFlag gesetzt
               bra       UserExit            ; Meldung ausgeben
;------------------------------------------------------------
UserInit:      bsr       CallClearFull       ; Schirm lîschen
               bsr       CallClearPal        ; Farbregister 3 lîschen
               move.w    Reso,ResoSave       ; Startauflîsung merken
               bsr       InitReso
               clr.w     UserSave
               bsr       Do_Help             ; HilfsText
               bra       CallClearFull       ; und wieder schwarz
;--------------------------------------------
UserExit:      pea       msg_erase(pc)       ; Bildschirm lîschen & CursorHome
               move.w    #Cconws,-(sp)       ;
               trap      #gemdos             ;
               addq.l    #6,sp               ;
               move.w    UserSave,d0
               cmpi.w    #1,d0               ; 1 -> Nicht gespeichert
               bne       tstNotFound
               pea       msg_nosave(pc)      ;
               move.w    #Cconws,-(sp)
               trap      #gemdos
               addq.l    #6,sp
               bra       UserContinue
;----------------------
tstNotFound:   cmpi.w    #2,d0               ; 2 -> Datei nicht gefunden
               bne       Saved               ;
               pea       save_name(pc)       ; Datei-Name ausgeben
               move.w    #Cconws,-(sp)       ;
               trap      #gemdos             ;
               addq.l    #6,sp               ;
               pea       msg_notfound(pc)    ;
               move.w    #Cconws,-(sp)
               trap      #gemdos
               addq.l    #6,sp
               move.w    #Cnecin,-(sp)       ; Tastendruck abwarten
               trap      #gemdos
               addq.l    #2,sp
               bra       UserContinue
;--------------------------
Saved:         pea       msg_save(pc)        ; 3 -> Alles gespeichert
               move.w    #Cconws,-(sp)
               trap      #gemdos
               addq.l    #6,sp
UserContinue:  move.w    Reso,d0
               cmp.w     ResoSave,d0
               bne       NoRestorePal
               bsr       CallRestorePal      ; Farbregister 3 zurÅck
NoRestorePal:  rts       
;-----------------------------
GetKey:        move.w    #Cnecin,-(sp)
               trap      #gemdos
               addq.l    #2,sp
               swap.w    d0                  ; ScanCode
               move.w    d0,UserKey
               rts       
;-----------------------------
ChangeSetup:   move.w    UserKey,d0          ; Auf Tastendruck reagieren
               cmpi.w    #16,d0              ; Q
               bne       NoQ
               move.w    #1,UserSave
               bra       ChangeClear
NoQ:           cmpi.w    #31,d0              ; S
               bne       NoS
               bra       Do_Save
NoS:           cmpi.w    #98,d0              ; Help
               bne       NoHelp
               bsr       Do_Help
               bra       ChangeClear
NoHelp:        cmpi.w    #75,d0              ; LinksPfeil
               bne       NoLeft
               bra       Do_Left
NoLeft:        cmpi.w    #77,d0              ; RechtsPfeil
               bne       NoRight
               bra       Do_Right
NoRight:       cmpi.w    #72,d0              ; RaufPfeil
               bne       NoUp
               bra       Do_Up
NoUp:          cmpi.w    #80,d0              ; RunterPfeil
               bne       NoDown
               bra       Do_Down
NoDown:        cmpi.w    #101,d0             ; /
               bne       NoDiv
               bsr       Do_Div
               bra       ChangeClear
NoDiv:         cmpi.w    #102,d0             ; *
               bne       NoMul
               bsr       Do_Mul
               bra       ChangeClear
NoMul:         cmpi.w    #74,d0              ; -
               bne       NoSub
               bsr       Do_Sub
               bra       ChangeClear
NoSub:         cmpi.w    #78,d0              ; +
               bne       NoAdd
               bsr       Do_Add
               bra       ChangeClear
NoAdd:         cmpi.w    #25,d0              ; P
               bne       NoP
               bsr       Do_Phys
               bra       ChangeClear
NoP:           cmpi.w    #46,d0              ; C
               bne       NoC
               bsr       Do_Activ
               bra       ChangeClear
NoC:           cmpi.w    #35,d0              ; H
               bne       NoH
               bsr       ResoChangeTest
               bne       ChangeClear
               move.w    #2,d0
               bra       SetScreenReso
NoH:           cmpi.w    #50,d0              ; M
               bne       NoM
               bsr       ResoChangeTest
               bne       ChangeClear
               move.w    #1,d0
               bra       SetScreenReso
NoM:           cmpi.w    #38,d0              ; L
               bne       EndChange
               bsr       ResoChangeTest
               bne       ChangeClear
               move.w    #0,d0
               bra       SetScreenReso

EndChange:     rts       
ChangeClear:   bra       CallClearFull
;----------------------------------------------
ClearPal:      move.w    vid_pal3,Pal3Save   ; Farbregister 3 retten
               move.w    vid_palF,PalFSave
               clr.w     vid_pal3            ; auf schwarz setzen
               clr.w     vid_palF
               rts       
CallClearPal:  move.w    sr,d0
               btst      #13,d0
               beq       DoCallClearPa
               bra       ClearPal
DoCallClearPa: pea       ClearPal(pc)        ; Farbregister 3 lîschen
               move.w    #Supexec,-(sp)      ; Supervisormodus durchfÅhren
               trap      #xbios              ;
               addq.l    #6,sp
               rts       
;----------------------------------------------
RestorePal:    move.w    Pal3Save,vid_pal3   ; Farbregister 3 zurÅck
               move.w    PalFSave,vid_palF
               rts       
CallRestorePal:          
               move.w    sr,d0
               btst      #13,d0
               beq       DoCallRestore
               bra       RestorePal
DoCallRestore: pea       RestorePal(pc)      ; Farbregister 3 lîschen
               move.w    #Supexec,-(sp)      ; Supervisormodus durchfÅhren
               trap      #xbios              ;
               addq.l    #6,sp
               rts       
;----------------------------------------------
InitReso:      move.w    #8,Y_Inc
               move.w    Reso,d0             ; Aktuelle Auflîsung
               cmpi.w    #2,d0               ;
               bne       NoHighReso          ;
               move.w    #16,Y_Inc           ;     Y-Inkrement feststellen
;-----------------------------
NoHighReso:    move.l    #8,d1               ;
               tst.w     d0
               beq       InitOffset
               asr.l     d0,d1               ;
InitOffset:    move.l    d1,Off_Inc          ;     Offset-Inkrement festlegen
;-----------------------------
               clr.l     d1                  ;     Max X/Y feststellen
               move.w    d0,d1               ;
               addq.w    #1,d1               ;
               move.w    #1,d2               ;
               asl.w     d1,d2               ; 1 << (Reso+)
               mulu.w    BpL,d2              ;
               move.w    d2,X_Max            ; MaxX = Bpl * 1<<(Reso+1)
               move.l    MemEnd,d1           ;
               sub.l     MyMemtop,d1         ;
               divu.w    BpL,d1              ; MaxY = SpeicherlÑnge/BytePerLine
               move.w    d1,Y_Max            ;
               move.w    #320,X_Min          ;
               move.w    #160,Y_Min          ;
               cmpi.w    #2,d0               ;
               bne       InitPointer         ;
               move.w    #320,Y_Min          ;
;-----------------------------
InitPointer:   add.w     d0,d0               ; Words
               lea.l     ScreenTab(pc),a0    ;     Breite/Hîhe/Offset Pointer
               lea.l     0(a0,d0.w),a1       ;     ermitteln
               move.l    a1,X_Add
               lea.l     6(a0,d0.w),a1
               move.l    a1,Y_Add
               add.w     d0,d0               ; Longs
               lea.l     30(a0,d0.w),a1
               move.l    a1,Off_Add
               rts       
;-----------------------------
Do_Save:       bsr       CallClearFull       ; Schirm lîschen
               move.w    #2,UserSave         ; Nicht gefunden Flag setzen


               move.w    #1,-(sp)            ; Fopen('\AUTO\OVERSCAN.PRG',1)
               pea       save_name(pc)       ;
               move.w    #Fopen,-(sp)
               trap      #gemdos             ;
               addq.l    #8,sp               ;
               tst.w     d0                  ; Gefunden ?
               bmi       EndSave             ; nein -> ende
               move.w    #3,UserSave         ; Flag setzen...
               move.w    d0,Handle           ; Dateihandle merken
               clr.w     -(sp)               ;
               move.w    Handle,-(sp)        ;     Header Åberlesen
               move.l    #30,-(sp)           ;
               move.w    #Fseek,-(sp)        ; Fseek(30,Handle,0)
               trap      #gemdos             ;
               lea.l     $a(sp),sp           ;
               pea       ScreenTab(pc)       ;     ScreenTab speichern
               move.l    #60,-(sp)           ;
               move.w    Handle,-(sp)        ;
               move.w    #Fwrite,-(sp)       ; Fwrite(Handle,60L,ScreenTab)
               trap      #gemdos             ;
               lea.l     $c(sp),sp           ;
               move.w    Handle,-(sp)        ;
               move.w    #Fclose,-(sp)       ; Fclose(Handle)
               trap      #gemdos             ;
               addq.l    #4,sp               ;
EndSave:       rts       
;----------------------------------------------------
Do_Help:       pea       msg_help(pc)        ; Hilfstext ausgeben
               move.w    #Cconws,-(sp)
               trap      #gemdos
               addq.l    #6,sp
               move.w    #Cnecin,-(sp)
               trap      #gemdos
               addq.l    #2,sp               ; Tastendruck abwarten
               rts       
;-----------------------------
Do_Left:       move.w    X_Min,d0            ; Breite vermindern
               cmp.w     RezX,d0
               bge       End_Left
               movea.l   X_Add,a0
               subi.w    #16,(a0)
               bsr       CallSetOversc