;********************************************************************
;*           OVER_LOW.S             K.Isakovic/OverScan GbR 30.07.90
;*
;*  Low-Level Routinen zum Feststellen, ob OverScan/Hyperscreen
;*  vorhanden ist.
;*
;********************************************************************
;*
;* Dieses Beipiel ist fÅr Programmierer gedacht, die nicht auf die
;* Betriebssystem-Funktionen zurÅckgreifen  kînnen.  Entweder weil
;* sie unter einem anderen  Betriebssystem programmieren oder aber
;* ein Auto-Boot Programm schreiben (z.B. ein Spiel/Demo), bei dem
;* der OverScan-Treiber nicht gebootet werden kann.
;*
;********************************************************************
;*
;*  Folgende Tabelle gibt eine öbersicht Åber die einzelnen Modi:
;*
;*
;*         Modus            | BpL  |     PhyOff   |   LogOff  | AddMem |
;*  ------------------------+------+--------------+-----------+--------+
;*   Normal   High  70 Hz   |   80 |      0       |   0/    0 |     0  |
;*            Mid  50/60 Hz |  160 |      0/    0 |   0/    0 |     0  |
;*            Low  50/60 Hz |  160 |      0/    0 |   0/    0 |     0  |
;*  ------------------------+------+--------------+-----------+--------+
;*   Hyper    High  70 Hz   |  100 |      0       | $774      | $4400  |
;*            Mid   50 Hz   |  236 | -$1600/  -   | $104/ -   | $8800  |
;*            Low   50 Hz   |  236 | -$1600/  -   | $104/ -   | $8800  |
;*  ------------------------+------+--------------+-----------+--------+
;*   OverScan High  70 Hz   |   80 |      0       | $6c6      | $3c00  |
;*            Mid  50/60 Hz |  160 | -$1400/-$c00 | $118/$138 | $7a00  |
;*            Low  50/60 Hz |  160 | -$1400/-$c00 | $118/$138 | $7a00  |
;*  ------------------------+------+--------------+-----------+--------+
;*
;* BpL:      BytesPerLine
;* PhyOff:   VideoCounter/MemoryStart - Offset
;* LogOff:   Logbase     /MemoryStart - Offset
;* AddMem:   ZusÑtzlich notwendiger Bildschirmspeicher
;*
;* Die Werte zwischen MemoryStart und LogOff mÅssen auf schwarz gesetz werden,
;* da sie im BildschirmrÅcklauf liegen und sonst als Streifen sichtbar sind.
;*
;* Anmerkung zur Hyperscreen-Hardware:
;*   Die BpL sind nicht durch 32 teilbar, auûerdem funktioniert der 60 Hz
;*   Modus nicht!
;*
;* Die LogOff-Werte sind die Default-Werte, sie sind aber vom Monitor
;* abhÑngig und sollten etweder interaktiv oder Åber Patchvariablen
;* verÑnderbar sein.
;* Auch die Bildschirmhîhe und Breite ist nicht auf allen Monitoren
;* gleich!  Die Pixel rechts neben der maximalen Breite bsi zum Anfang
;* der nÑchsten Zeile mÅssen alle auf schwarz gesetzt werden, ansonsten
;* gibt es  stîrende RÅcklaufstrahlen in Monochrom und 'Dreckeffekte' in
;* Color.
;*
;*
;*
; ----------------- HARDWARE + TOS ----------------------
GEMDOS         = 1
XBIOS          = 14
;------------------------------------- Funktions Nummern
Cnecin         = 8       ; GEMDOS
Cconws         = 9       ; GEMDOS
Malloc         = 72      ; GEMDOS
Mfree          = 73      ; GEMDOS
Supexec        = 38      ; XBIOS
;----------------------------------------------HardwareAddressen
VID_BASHIGH    = $ff8201
VID_BASMID     = $ff8203
VID_ISHIGH     = $ff8205
VID_ISMID      = $ff8207
VID_PAL0       = $ff8240
VID_REZ        = $ff8260
KBD_ACIA       = $fffc00
;
;********************************************************************
;
main:          
               lea.l     main-256(pc),a5
               movea.l   a5,sp             ; START
               move.l    $c(a5),d0         ; + text
               add.l     $14(a5),d0        ; + data
               add.l     $1c(a5),d0        ; + bss
               addi.l    #512,d0           ; + BaseBage(256) + Stack(256) !
               adda.l    d0,sp

               move.l    d0,-(sp)          ; Nicht benîtigten Speicher
               move.l    a5,-(sp)          ; freigeben
               move.w    #0,-(sp)
               move.w    #74,-(sp)
               trap      #1
               lea.l     12(sp),sp

               pea       Do_Test(pc)       ; Do_Test im Supervisormodus
               move.w    #Supexec,-(sp)    ;   ausfÅhren
               trap      #XBIOS            ; Ergebnis in IsVideo
               addq.l    #6,sp             ;

               pea       Msg_Title(pc)
               move.w    #Cconws,-(sp)
               trap      #GEMDOS
               addq.l    #6,sp

               move.w    IsVideo(pc),d7
               bne       Mode_Hyper
               pea       Msg_Normal        ; Normal-Modus
               bra       Output_Mode
;
Mode_Hyper:    subq.w    #1,d7
               bne       Mode_OverScan
               pea       Msg_Hyper         ; HyperScreen-Modus
               bra       Output_Mode
;
Mode_OverScan: subq.w    #1,d7
               pea       Msg_OverScan      ; OverScan-Modus
Output_Mode:   move.w    #Cconws,-(sp)
               trap      #GEMDOS
               addq.l    #6,sp

               subq.w    #1,d7
               bne       End_Msg
               pea       Msg_NotActive     ; OverScan / Nicht aktiviert
               move.w    #Cconws,-(sp)
               trap      #GEMDOS
               addq.l    #6,sp

End_Msg:       pea       Msg_End(pc)
               move.w    #Cconws,-(sp)
               trap      #GEMDOS
               addq.l    #6,sp

               move.w    #Cnecin,-(sp)     ; Auf Tastendruck warten
               trap      #GEMDOS
               addq.l    #2,sp
               clr.w     -(sp)             ; Programm beenden (Returncode 0)
               trap      #GEMDOS

;********************************************************************
Do_Test:       clr.w     IsVideo           ; Normal-Modus setzen

               clr.w     ActMode           ; OverScan-Status vermerken
               bsr       VSync_Test
               beq       Do_Toggle         ; Da der OverScan-Modus aktiviert
               move.w    #1,ActMode        ; ist
               move.w    #1,IsVideo        ;     -> Zumindest HyperScreen

Do_Toggle:     
;
; Die folgenden Sachen  geschehen  _nur_  aus optischen  GrÅnden.  Der
; VideoPointer wird auf einen 'schwarzen' Speicherbereich umgelegt, so
; das das Umschalten unsichtbar bleibt.  Ansonsten  wÅrde man entweder
; die RÅcklaufstrahlen  oder  wirre  Adressbus-Signale am unteren Ende
; des Monitor sehen.
;
; In Color reicht es  Åbrigens aus,  alle Farben auf denselben Wert zu
; setzen.  Wenn  alle  Farben  gleich  sind,  _kann_  nichts  blitzen.
;
               move.l    #$11000,-(sp)     ; Speicher anfordern
               move.w    #Malloc,-(sp)     ;     $8000 + maximaler AddMem_Wert
               trap      #GEMDOS
               addq.l    #6,sp
               move.l    d0,d7             ; Block-Anfang merken
               tst.l     d0
               beq       NoBlackMem        ; Kein Speicher -> Also ohne...

               movea.l   d0,a0
               move.w    VID_PAL0,d6       ; Farbe merken
               clr.l     d1                ; In Color ist der Wert $000=schwarz
               clr.w     d2
               move.b    VID_REZ,d0
               andi.b    #3,d0
               cmpi.b    #2,d0
               bne       Do_Clr
               move.l    #$ffffffff,d1     ; In Monochrom aber $ffff
               move.w    #$ffff,d2
Do_Clr:        move.w    d2,VID_PAL0       ;   Auf Schwarz setzen
               move.w    #$10ff,d0         ; Speicher auf Schwarz setzen
Clr_Lp:        move.l    d1,(a0)+
               move.l    d1,(a0)+
               move.l    d1,(a0)+
               move.l    d1,(a0)+
               dbf       d0,Clr_Lp

               move.b    VID_BASHIGH,d5    ; Video-Pointer merken
               asl.w     #8,d5
               move.b    VID_BASMID,d5

               bsr       VSync_Test        ; Warten und VideoPointer umsetzen
               move.l    d7,d0             ;   Speicher Anfangsadresse
               addi.l    #$800,d0          ;   + Maximaler LogOff-Wert
               asr.l     #8,d0
               move.b    d0,VID_BASMID
               asr.l     #8,d0
               move.b    d0,VID_BASHIGH
;
; Nun wird einmal umgeschaltet...
;
NoBlackMem:    
               bsr       Toggle_Mode
               bsr       VSync_Test
               bsr       VSync_Test
               bsr       VSync_Test        ; kurz warten
               beq       Now_Normal
;
Now_Over:      tst.w     ActMode           ; Umgeschaltet von
               beq       Toggle_Back       ;   Over   nach Over   -> HyperScreen
               move.w    #3,IsVideo        ;   Normal nach Over   -> OverScan!
               bra       Toggle_Back
;
Now_Normal:    tst.w     ActMode
               bne       Toggle_Back       ;   Normal nach Normal -> Normal
               move.w    #4,IsVideo        ;   Normal nach Over   -> OverScan!

Toggle_Back:   bsr       Toggle_Mode       ; zurÅckschalten

               tst.l     d7                ; Wurde Speicher angelegt ?
               beq       DT_End

               bsr       VSync_Test        ; VideoPointer zurÅcksetzen
               move.b    d5,VID_BASMID
               asr.w     #8,d5
               move.b    d5,VID_BASHIGH

               move.w    d6,VID_PAL0       ; Farbe zurÅck

               move.l    d7,-(sp)
               move.w    #Mfree,-(sp)
               trap      #GEMDOS
               addq.l    #6,sp

DT_End:        rts       
;
;********************************************************************
;
; Overscan Testroutine und VSync-Routine
;
VSync_Test:    move.b    VID_BASMID,d0     ; Anfang des Video-Bildes
               move.b    d0,d1             ;  merken und das Ende des normalen
               addi.b    #$7d,d1           ;  Bildschirms berechnen.
VS_Wait1:      cmp.b     VID_ISMID,d1      ; Warten bis Video-Counter am Ende
               bne       VS_Wait1          ;  angekommen ist
VS_Wait2:      cmp.b     VID_ISMID,d1      ; Warten bis sich der Counter wieder
               beq       VS_Wait2          ;  Ñndert
               cmp.b     VID_ISMID,d0
               rts       
;
; Im 'normalen' Video-Modus steht der Video-Counter eine Zeitlang (LÑnge des
;; BildschirmrÅcklaufs...)  auf der Anfangsadresse. Unter OverScan/Hyperscreen
; lÑuft er hingegen weiter.
;
; Ein einfacher,Vergleich des Video-Counters mit der Anfangsaddresse (steht
; noch in D0 ) liefert den aktuellen Zustand.
;
;********************************************************************
;
; Umschalt-Routine fÅr AutoSwitch-OverScan
;
Toggle_Mode:   bsr       VSync_Test
               tst.w     ActMode
               beq       TM_IsNormal
;
TM_IsOver:     move.b    #$96,KBD_ACIA
               clr.w     ActMode
               rts       
;
TM_IsNormal:   move.b    #$d6,KBD_ACIA
               move.w    #1,ActMode
               rts       
;
;********************************************************************
;
IsVideo:       .DC.w 0
ActMode:       .DC.w 0

Msg_Title:     .DC.b "     OverScan - LowLevel Test    ",13,10
               .DC.b "  ------------------------------ ",13,10
               .DC.b "  Active video mode:             ",13,10
               .DC.b "                                 ",13,10,0
Msg_Normal:    .DC.b "    Normal Video                 ",13,10,0
Msg_Hyper:     .DC.b "    Hyperscreen                  ",13,10,0
Msg_OverScan:  .DC.b "    AutoSwitch-OverScan          ",13,10,0
Msg_NotActive: .DC.b "      (in normal mode)           ",13,10,0

Msg_End:       .DC.b "                                 ",13,10
               .DC.b "  press <return>                 ",13,10,0


