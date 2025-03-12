*-------------------------*
*         Auto Maus       *
*        Ralf Stachs      *
*-------------------------*
* (c) 1991 MAXON Computer *
*-------------------------*

************
* Auto Maus 2.0 und Maus REC 2.0 fÅr ST Computer   
*
* 2.1 Pause zwischen PRESS und RELASE
* 2.2 Pause zwischen MOVE und PRESS
*
*************


;A_KLICK ->Anzahl der Klicks
;WAIT_RELASE->Anzahl der VBL Aufrufe zwischen PRESS und RELASE
;WAIT_PRESS ->Anzahl der VBL Aufrufe zwischen MOVE und PRESS 
;          WAT_RELASE+WAIT_PRESS nicht grîûer 10

A_KLICK equ 25 
WAIT_RELASE equ 5
WAIT_PRESS equ 2

;TRAPS
GEMDOS  equ 1
BIOS     equ 13
XBIOS    equ 14

                           
RESI_ANFANG:
jmp INSTALL                ;Auto Maus Installieren
                        
;Klick Steuerung
;Verzîgerung/X-Position/Y-Position bei Mausklick
START_DAT:
      dc.b "MAUS_1"        ;Kennung
KLICK_1:dc.l 0             ;Pausenzeit
      dc.w 0,0          ;X-Position/Y-Position

      ds.l A_KLICK*2       ;Platzhalter fÅr 25 Klick Steuerungen

ENDE_DAT:dc.l -1           ;Ende der Klick Steuerung

;S_DAT   = Belegter Speicher des DAT File 
S_DAT equ ENDE_DAT-START_DAT

;VBL-Routine Maus positionieren und Doppelklick ausfÅhren
      dc.b "XBRA"          ;XBRA Protokoll
      dc.b "RS_5"          ;eigene Erkennung 
      dc.l 0               ;alter Vektor

;Mausvektor sperren oder verbiegen auf MAUS_REC 
;**********************************************
NEU_VBL:
      tst.b VEK_SET        ;GEM Mausvektor schon gesetzt
      bne SP_15            ;ja

      move.l MAUS_VEKTOR,a1   ;Adresse Mausvektor a1
      lea OLD_M_VEK,a0     ;alter Mausvektor (RTS)
      cmp.l (a0)+,(a1)+    ;alter Mausvektor noch da
      beq SP_11            ;ja   
   
      move.l -(a1),OLD_M_VEK  ;alten Mausvektor merken
      move.l #MAUS_REC,(a1)   ;Vektor auf eigene Mausrutine

;aufnehmen oder abspielen ?
      tst.b REC_PLAY       ;Maus aufnehmen
      beq SP_10            ;nein
                        
;Klicksteuerung aufnehmen (verbiegen auf MAUS_REC)
;*************************************************
;Startzeit merken
      move.l $466,TIME     ;_frclock

;vbl-Slot lîschen
      move.l VBL_SLOT,a0
      move.l #0,(a0)    
SP_11:   rts


;Klicksteuerung abspielen (Mausvektor sperren)
;*********************************************
SP_10:   move.b #1,MAUS_AUS      ;Mausbewegung von A_MAUS   
      move.b #1,VEK_SET    ;GEM Mausvektor gesetzt
      move.l $466,TIME     ;_frclock merken
      move.l KLICK_ADR,a0  ;Adresse der aktuellen Klick Steuerung
                        ;.l Pausenzeit /.w X-Position /.w Y-Position 
      tst.l (a0)           ;erste Pausenzeit gleich 0
      beq SP_23            ;dann abspielen abbrechen
      rts

;Maus abpielen       
;*************
SP_15:
;Maus aus (MOUSE_FLAG) ?
      move.l M_FLAG_ADR,a1    ;Adresse Mouse Flag
      tst.b (a1)           ;Maus ausgeschaltet
      bne ENDE

      tst.b LAST           ;zum letztem mal RELASE       
      bne SP_23            ;ja
      
      btst.b #1,$FF8800    ;Floppy A selectiert
      beq ENDE          ;ja

      btst.b #2,$FF8800    ;Floppy B selectiert
      beq ENDE          ;ja

;Pausenzeit berechnen
      move.l KLICK_ADR,a0  ;Adresse der aktuellen Klick Steuerung
                        ;.l Pausenzeit /.w X-Position /.w Y-Position 
      move.l $466,d0       ;_frclock in d0
      sub.l TIME,d0        ;Pausenzeit berechnen

;nach x VBL Aufrufen linke Maustaste loslassen
      cmp.l #WAIT_RELASE,d0   ;x VBL Aufrufe Pause
      blt ENDE          ;kleiner x
       bgt SP_90           ;grîûer x
       
      move.w sr,-(sp)         ;Status retten
      ori #$700,sr         ;Interupts sperren
      move.l OLD_M_VEK,a2     ;Mausvektor in a2
      lea RELASE,a0        ;Adresse Mauspaket in a0
      jsr (a2)          ;in Mausrutine springen
      move.w (sp)+,sr         ;alten Status herstellen
      bra ENDE 

;Klickzeit erreicht
SP_90:   cmp.l (a0)+,d0       ;Pausenzeit <= ZÑhler
      bls ENDE          ;ja

;Maus Positonieren
      move.b #0,MOVE+1     ;X Wert in Mauspaket auf 0
      move.b #0,MOVE+2     ;Y Wert in Mauspaket auf 0

;X-Verschiebung berechnen        
      move.l X_POS,a2         ;Adresse der X-Position
      move.w (a2),d0       ;ist  X-Position in d0
      move.w (a0)+,d1         ;soll X-Position in d1

      sub.w d0,d1          ;soll X-Pos. Minus  ist X-Pos.   
      beq   Y_WERT            ;soll X-Pos. gleich ist X-Pos.  
      bmi SP_2          ;negativer X-Wert
         
;positiver X-Wert
      cmp.w #127,d1        ;grîûer gleich 127
      bge SP_3          ;ja
      move.b d1,MOVE+1     ;X-Bewegung
      bra Y_WERT              
SP_3: move.b #127,MOVE+1      ;max. Mausbewegung
      bra Y_WERT
         
;negativer X-Wert
SP_2: cmp.w #-127,d1       ;kleiner gleich -127
      bls SP_4          ;ja
      move.b d1,MOVE+1     ;X-Bewegung
      bra Y_WERT              
SP_4: move.b #-127,MOVE+1     ;max. Mausbewegung

;Y-Verschiebung berechnen
Y_WERT:  move.l Y_POS,a2         ;Adresse der Y-Position
      move.w (a2),d0       ;ist  Y-Position in d0
      move.w (a0),d1       ;soll Y-Position in d1

      sub.w d0,d1          ;soll Y-Pos. minus  ist Y-Pos.   
      beq   POS_OK            ;soll Y-Pos. gleich ist Y-Pos.  
      bmi SP_5          ;negativer Y-Wert
         
;positiver Y-Wert
      cmp.w #127,d1        ;grîûer gleich 127
      bge SP_6          ;ja
      move.b d1,MOVE+2     ;Y-Bewegung
      bra POS_OK              
SP_6: move.b #127,MOVE+2      ;max. Mausbewegung
      bra POS_OK
         
;negativer Y-Wert
SP_5: cmp.w #-127,d1       ;kleiner gleich -127
      bls SP_7          ;ja
      move.b d1,MOVE+2     ;Y-Bewegung
      bra POS_OK              
SP_7: move.b #-127,MOVE+2     ;max. Mausbewegung

;X-Position O.K.
POS_OK:  move.l KLICK_ADR,a0  ;Adresse von aktueller Klick Steuerung
      add.l #4,a0          ;Adresse von soll X-Position
      move.l X_POS,a1         ;Adresse ist  X-Position
      cmp.w (a0)+,(a1)+    ;soll X-Position gleich ist X-Position
      bne MOVE_MAUS

;Y-Position O.K.
      move.l Y_POS,a1         ;Adresse ist Y-Position
      cmp.w (a0)+,(a1)+    ;soll Y-Position gleich ist Y-Position
      beq KLICK            ;ja   

;Maus auf Zielpunkt bewegen
MOVE_MAUS:
      move.w sr,-(sp)         ;Status retten
      ori #$700,sr         ;Interupts sperren      
      move.l OLD_M_VEK,a2     ;Mausvektor in a2
      lea MOVE,a0          ;Adresse Mauspaket
      jsr (a2)          ;in Mausrutine springen
      move.w (sp)+,sr         ;alten Status herstellen
      rts
         
;X und Y Position ereicht        
;Pause abgelaufen ?
KLICK:   sub.b #1,SAVE_PRESS     ;Pause minus 1
      tst.b SAVE_PRESS     ;noch Pause
      bne ENDE          ;ja

;neue Pause setzen x VBL Aufrufe Pause fÅr PRESS
      move.b #WAIT_PRESS,SAVE_PRESS 

;Klick ausfÅhren     
      move.w sr,-(sp)         ;Status retten

      ori #$700,sr         ;Interupts sperren
      move.l OLD_M_VEK,a2     ;Mausvektor in a2
      lea PRESS,a0         ;Adresse Mauspaket in a0
      jsr (a2)          ;in Mausrutine springen

      move.w (sp)+,sr         ;alten Status herstellen

;letzte Klick Steuerung
      move.l KLICK_ADR,a0  ;Adresse von aktueller Klick Steuerung
      add.l  #8,a0         ;Adresse der nÑchsten Klick Steuerung
      move.l (a0),d0       ;Pausenzeit oder ende
      cmp.l  #-1,d0        ;ende
      bne NEXT_KLICK       ;nein

;ende der Klick Steuerung     
      move.b #WAIT_RELASE+2,LAST ;x VBL Aufrufe Pause

;linke Maustaste loslassen
SP_23:   sub.b #1,LAST        ;minus 1
      cmp.b #1,LAST        ;Zeit fÅr RELASE ?
      bne ENDE          ;nein

;RELASE     
      move.w sr,-(sp)         ;Status retten
      ori #$700,sr         ;Interupts sperren
      move.l OLD_M_VEK,a2     ;Mausvektor in a2
      lea RELASE,a0        ;Adresse Mauspaket in a0
      jsr (a2)          ;in Mausrutine springen
      move.w (sp)+,sr         ;alten Status herstellen

;Mausvektor wieder herstellen    
SP_91:   move.b #0,MAUS_AUS      ;Mausbewegung von Maus
      move.l MAUS_VEKTOR,a0   ;Adresse des Mausvektors
      move.l (a0),d0       ;Vektor in d0
      cmp.l #MAUS_REC,d0      ;ist Vektor verÑndert worden
      bne SP_33            ;ja 
      move.l OLD_M_VEK,(a0)   ;alten Mausvektor herstellen
            
;vbl-Slot lîschen
SP_33:   move.l VBL_SLOT,a0      ;Adresse VBL-SLOT
      move.l #0,(a0)       ;lîschen
      rts

NEXT_KLICK:
      move.l a0,KLICK_ADR     ;Adresse neue Klick Steuerung       
      move.l $466,TIME     ;_frclock merken
ENDE: rts


;Neue Mausrutine 
;***************
;Mausrutine fÅr Aufname
      dc.b "XBRA"          ;XBRA Protokoll
      dc.b "RS_6"          ;eigene Erkennung
OLD_M_VEK: 
      dc.l 0               ;alter Vektor

MAUS_REC:      
;Aufnahme abspielen
      tst.b REC_PLAY       ;Aufnahme abspielen
      beq SP_16            ;ja dann alte Rutine anspringen

;Aufnahme beendet
      tst.b END_REC        ;Rec ende
      bne SP_32            ;nein
      rts

SP_32:   movem.l d0/a0-a2,-(sp)  ;Register retten

;Maus aus
      move.l M_FLAG_ADR,a1 ;Adresse von MOUSE_FLAG
      tst.b (a1)           ;Maus ausgeschaltet 
      bne SP_14            ;ja dann zu alter Mausrutine

;Maus Header ?
      move.b (a0)+,d0         ;Header Kopf in d0
         
;linke Maustaste dann Zeit und Koordinaten merken
      cmp.b #$fa,d0        ;linke Maustaste gedrÅckt
      beq SP_25            ;ja

      move.b d0,HEADER     ;Maustaste merken
      bra SP_14            ;zur GEM Mausrutine

;testen ob Maustaste losgelassen
SP_25:   cmp.b #$fa,HEADER    ;letzte Maustaste links
      bne SP_26            ;nein dann merken

;Klick weder merken noch weitergeben
      movem.l (sp)+,d0/a0-a2  ;Register zurÅckschreiben
      rts                            

SP_26:   move.b d0,HEADER     ;Maustaste merken

;Zeit und Koordinaten merken
      move.l KLICK_ADR,a2     ;Adresse Aktuelle Klick Steuerung

      move.l $466,d0       ;_frclock in d0
      sub.l  TIME,d0       ;Pausenzeit berechnen

      move.l d0,(a2)+         ;Pausenzeit speichern in Klick Steuerung        

;bei Doppelklick gleiche Position
      cmp.l #$f,d0         ;grîûer als $f
      bgt SP_35            ;ja 

;letzte x/y Position gleich neue x/y Position
      move.l a2,a1         ;Adresse Aktuelle Klick Steuerung
      sub.l  #8,a1         ;Adresse letzte x/y Position
      move.l (a1),(a2)+    ;letzte x/y Position gleich neue x/y Position
      bra SP_34
         
SP_35:   move.l X_POS,a1         ;Adresse X-Pos.
      move.b (a0)+,d0         ;X-Mausbewegung in d0
      ext.w  d0            ;d0 Vorzeichenrichtig auf .w
      add.w  (a1),d0       ;plus X-Pos.
      move.w d0,(a2)+         ;X-Pos. merken       

      move.l Y_POS,a1         ;Adresse Y-Pos.
      move.b (a0)+,d0         ;Y-Mausbewegung in d0
      ext.w  d0            ;d0 Vorzeichenrichtig auf .w
      add.w  (a1),d0       ;plus Y-Pos.
      move.w d0,(a2)+         ;Y-Pos. merken       

;letzte Klick Steuerung ?
SP_34:   move.l (a2),d0       ;Pausenzeit oder -1 
      cmp.l  #-1,d0        ;letzte Klick Steuerung
      beq SP_30            ;ja
         
;nÑchste Klick Steuerung
      move.l #-1,(a2)         ;vorlÑufiges Ende kenzeichnen
      move.l $466,TIME     ;neue Startzeit setzen
      move.l a2,KLICK_ADR     ;Adresse der nÑchsten Klick Steuerung        
      bra SP_14

;letze Klick Steuerung
SP_30:   move.b #0,END_REC    ;Aufnahme beendet
         
;alte Mausroutine anspringen
SP_14:   movem.l (sp)+,d0/a0-a2  ;Register zurÅckschreiben
SP_16:   tst.b MAUS_AUS       ;Mausbewegung von A_MAUS
      bne SP_21            ;ja

      move.l OLD_M_VEK,-(sp)  ;alte Mausroutine
SP_36:   rts               ;anspringen


;beide Maustasten gedrÅckt dann abbrechen nur beim abspielen
;***********************************************************
SP_21:   movem.l d0/a0-a1,-(sp)  ;Register retten
      move.b (a0),d0       ;Header Kopf in d0
      cmp.b #$fb,d0        ;beide Maustasten gedrÅckt
      bne SP_24            ;nein

;Maus abspielen abbrechen 
      bsr SP_91            ;VBL-Slot lîschen
                        ;Mausvektor wieder herstellen
                  
SP_24:   movem.l (sp)+,d0/a0-a1  ;Register zurÅckschreiben
      rts



;Speichert die Daten der Klick Steuerung
;***************************************
;Speichern der Klick Steuerung in A_MAUS.DAT
            dc.b "XBRA"    ;XBRA Protokoll
            dc.b "RS_7"    ;eigene Erkennung
OLD_SCR_VEK:   dc.l 0         ;alter Vektor

SAVE_KLICK: 
;A_MAUS.DAT File îffnen
      move.w #0,-(sp)         ;Diskettenname
      pea FNAME            ;Pfad mit Dateinamen
      move.w #$3c,-(sp)    ;Fcreate aufrufen
      trap #GEMDOS
      addq.l #8,sp
      move.w d0,FILE_HANDLE   ;Handle merken    

;Daten Schreiben
      pea    START_DAT     ;Adresse des Buffers
      move.l #S_DAT,-(sp)  ;Anzahl der Bytes
      move.w FILE_HANDLE,-(sp)
      move.w #$40,-(sp)       ;Fwrite
      trap   #GEMDOS
      lea    $c(sp),sp        

;File schliesen
      move.w FILE_HANDLE,-(sp)      
      move.w #$3E,-(sp)    ;Fclose aufrufen
      trap   #GEMDOS
      addq.l #4,sp

;Reset ausfÅhren
      move.l $fc0004,a0    ;Reset Adresse laden
      jmp (a0)          ;Reset ausfÅhren


;Variabelen und Flags
;********************
;MAUS_VEKTOR   -> Adresse des Vektors der Mausrutine
;OLD_M_VEK     -> alter Mausvektor
;X_POS         -> Adresse X-Position des Mauszeigers
;Y_POS         -> Adresse Y-Position des Mauszeigers
;M_FLAG_ADR    -> Adresse von MOUSE_FLAG                          
;                 0 Maus wird angezeigt                           
;                 1 Maus wird nicht angezeigt                     
;VBL_SLOT      -> Adresse des VBL-Slot
;TIME       -> ZÑhler fÅr Verzîgerung
;KLICK_ADR     -> Adresse der Aktuellen Klick Steuerung
;FILE_HANDLE   -> Kennung von A_MAUS.DAT
;REC_PLAY      -> Flag  0 Maus abspielen
;                  1 Maus aufnehmen
;OLD_SCR_VEK   -> alte Hardcopyvektor  
;VEK_SET    -> Flag  0 Bios Mausvektor gesetzt
;                     1 GEM  Mausvektor gesetzt
;MAUS_AUS      -> Flag  0 Mausbewgung von A_MAUS
;                  1 Mausbewegung von Maus      
;END_REC    -> Flag  0 Aufnahme beendet
;                  1 Aufnahme aktiv
;LAST       -> Speicher fÅr WAIT_RELASE beim letzten RELASE 
;                  0 =  Klicksteuerung abspielen 
;                 0 <> Pausenzeit
;                 1 =  Auto Maus beenden letztes RELASE     
;SAVE_PRESS    -> Speicher fÅr Pausenzeit vor Press
;                 0 = Pause zuende
MAUS_VEKTOR:   dc.l 0
X_POS:         dc.l 0
Y_POS:         dc.l 0
M_FLAG_ADR:    dc.l 0
VBL_SLOT:      dc.l 0
TIME:       dc.l 0
KLICK_ADR:     dc.l KLICK_1
FILE_HANDLE:   dc.w 0
REC_PLAY:      dc.b 0
VEK_SET:    dc.b 0
MAUS_AUS:      dc.b 0
HEADER:        dc.b 0
END_REC:    dc.b 1
LAST:       dc.b 0
SAVE_PRESS:    dc.b WAIT_PRESS

   EVEN

;Maus Pakete
;***********
;PRESS         ->Linke Maustaste gedrÅckt
;RELASE        ->Keine Maustaste gedrÅckt
;MOVE       ->Mauszeiger bewegen

PRESS:         dc.b $fa,0,0
   EVEN
RELASE:        dc.b $f8,0,0
   EVEN
MOVE:       dc.b $f8,0,0
   EVEN

;Pfad von A_MAUS.DAT
;*******************
FNAME:         dc.b "A:\AUTO\A_MAUS.DAT",0   

RESI_ENDE:

;Installierung von Auto Maus
;***************************

      TEXT
      EVEN
;gesamt-PRG Speicher belegen
INSTALL:
      move.l   sp,a6       ;Adresse BASEPAGE
      lea      USTACK,sp      ;neuer Stack
      
      move.l   4(a6),a6    ;Speicher belegen
      move.l   $c(a6),a4
      adda.l   $14(a6),a4
      adda.l   $1c(a6),a4
            
      pea      256(a4)
      pea      (a6)
      clr.w -(sp)
      move.w   #74,-(sp)      ;Mshrink aufrufen
            
      trap #GEMDOS
      lea 12(sp),sp

;Start aus Autoordner ? (AES anmelden)
      lea contrl,a0        ;Adresse contrl nach a0
      move.w #10,(a0)+     ;Opcode
      clr.w (a0)+          ;eintrÑge int_in
      move.w #1,(a0)       ;eintrÑge int_out
      clr.w (a0)+          ;eintrÑge addr_in
      clr.w (a0)           ;eintrÑge addr_out
            
      move.l #aes_data,d1     ;Adresse AES-Array
      move.w #$c8,d0       ;AES_Aufruf
      trap #2

      tst.w aes_global     ;starten aus AUTO-Ordner
      beq SP_31            ;nein keine ap_version

;vom desktop gestartet
      pea STRING_5            
      move.w   #9,-(sp)
      trap #GEMDOS
      addq.l #6,sp

;auf Taste warten
      move.w #2,-(sp)         ;von Tastatur
      move.w #2,-(sp)         ;Bconin
      trap   #BIOS
      addq.l #4,sp

;PRG beenden
      clr.w  -(sp)
      trap #GEMDOS

;aus Auto-Ordner gestartet
;Laufwerk A und B desaktivieren
SP_31:   move.w #6,-(sp)         ;Laufwerk A und B
      move #30,-(sp)          ;Ongibit aufrufen
      trap #XBIOS
      addq.l #4,sp
            
;Adresse KBDVECS holen
      move.w #34,-(sp)     ;Kbdvbase aufrufen
      trap #XBIOS
      addq.l #2,sp

;Adresse des Vektors der Mausrutine berechnen
      add.l  #16,d0           
      move.l d0,MAUS_VEKTOR

;Anfangsadresse der Line-A Variabelen
      dc.w $a000           ;Adresse der Line-A Variabelen

;Adresse MOUSE-FLAG berechnen
      sub.l  #$153,a0         ;Adresse MOUSE-FLAG berechnen
      move.l a0,M_FLAG_ADR ;Adresse merken

;Adresse GCURY berechnen
      move.l d0,a0         ;Adresse der Line-A Variabelen
      sub.l  #$258,a0         ;Adresse GCURY berechnen
      move.l a0,Y_POS         ;Adresse GCURY merken

;Adresse GCURX berechnen
      move.l d0,a0         ;Adresse der Line-A Variabelen
      sub.l  #$25a,a0         ;Adresse GCURX berechnen
      move.l a0,X_POS         ;Adresse GCURX merken

;alten Vektor sichern
      lea OLD_M_VEK,a0     ;Adresse zum speichern des alten Mausvektor  
      move.l MAUS_VEKTOR,a2   ;Adresse des Vektors der Mausrutine in a0
      move.l (a2),(a0)     ;alten Mausvektor speichern BIOS (rts)

;aktuelles Laufwerk fÅr A_MAUS.DAT lesen        
      move.w #$19,-(sp)    ;Dgetdrv aufrufen
      trap #GEMDOS
      addq.l #2,sp
         
      add.b #"A",d0        ;Laufwerksbuchstabe berechnen
      move.b d0,FNAME         ;Laufwerksbuchstabe in Pfad setzen

;A_MAUS.DAT suchen
      pea BUF              ;Anfangsadresse der DTA setzen
      move.w #$1a,-(sp)    ;Fsetdta aufrufen
      trap #GEMDOS
      addq.l #6,sp

      move.w #0,-(sp)         ;normale Datei
      pea   FNAME          ;Suchname (A_MAUS.DAT)
      move.w #$4e,-(sp)    ;Fsfirst aufrufen
      trap #GEMDOS
      addq.l #8,sp
         
      cmp.b #"A",BUF       ;A_MAUS.DAT gefunden
      beq PLAY          ;ja dann PLAY

;Maus aufnehmen
;**************
;Flag fÅr MAUS-REC
      move.b #1,REC_PLAY      ;Flag abspielen oder aufnehmen

;Kopf ausgeben
      pea STRING_3
      move.w   #9,-(sp)
      trap #GEMDOS
      addq.l #6,sp

;VBL und Mausrutine resitend halten
      bra SP_13      


;Maus abspielen
;**************

PLAY:
;Klick Steuerung laden
;File îffnen
      move.w #0,-(sp)         ;nur lesen
      pea FNAME            ;Pfad mit Dateinamen
      move.w #$3d,-(sp)    ;Fopen aufrufen
      trap #GEMDOS
      addq.l #8,sp
      move.w d0,FILE_HANDLE   ;Handle merken    

;Kennung des DAT File         
      pea    START_DAT     ;Adresse des Buffers
      move.l #S_DAT,-(sp)     ;Anzahl der Bytes
      move.w FILE_HANDLE,-(sp)
      move.w #$3f,-(sp)    ;Fread
      trap   #GEMDOS
      lea    $c(sp),sp

      cmp.l #S_DAT,d0   ;Grîûe der geladenen Daten O.K.
      bne SP_99            ;nein
         
      lea KENNUNG_DAT,a0      ;Vorgabe Kennung
      lea START_DAT,a1     ;Kennung der geladenen Datei
      cmp.l (a1)+,(a0)+    ;Kennung richtig
      beq SP_100           ;ja


;Falsche Kennung oder Grîûe der von A_MAUS.DAT falsch
SP_99:   pea STRING_4            
      move.w   #9,-(sp)
      trap #GEMDOS
      addq.l #6,sp

;auf Taste warten
      move.w #2,-(sp)         ;von Tastatur
      move.w #2,-(sp)         ;Bconin
      trap   #BIOS
      addq.l #4,sp

;PRG beenden
      clr.w  -(sp)
      trap #GEMDOS

;File schliesen
SP_100:  move.w FILE_HANDLE,-(sp)      
      move.w #$3E,-(sp)    ;Fclose aufrufen
      trap #GEMDOS
      addq.l #4,sp

;Kopf ausgeben
      pea STRING_1
      move.w   #9,-(sp)
      trap #GEMDOS
      addq.l #6,sp

;Unterprogramm im Supervisor-Modus ausfÅhren
SP_13:   lea VBL_INST,a0         ;Adresse von VBL_INST nach a0
      pea   (a0)
      move.w #$26,-(sp)    ;Supexec aufrufen
      trap #XBIOS
      addq.l #6,sp

;Speicherplatz fÅr VBL- und Mausrutine             
      clr.w -(sp)
      pea RESI_ENDE-RESI_ANFANG+256
      move.w #49,-(sp)     ;Ptermres aufrufen   
      trap #GEMDOS         ;Initialisierung ende


;Unterprogramm im Supervisor-Modus 
;*********************************

;VBL installieren
VBL_INST:move.w $454,d0       ;Anzahl der VBL Routinen (nvbls)
      lsl #2,d0            ;Anzahl*4
      move.l $456,a0       ;Zeiger auf VBL (_vblqueue)            
      clr d1               ;ZÑhler
WEITER:  tst.l 4(a0,d1)       ;VBL Slot frei
      beq FREI          ;ja
      add #4,d1            ;nÑchster Slotpointer
      cmp.w d0,d1          ;alle slots abgefragt
      bne WEITER           

;VBL nicht initialisieren
      pea STRING_2         ;Alle Slots besetzt
      move.w   #9,-(sp)
      trap #GEMDOS
      addq.l #6,sp

;PRG beenden
      clr.w  -(sp)
      trap #GEMDOS

FREI: lea 4(a0,d1),a2         ;Adresse  Slot in a2
      lea NEU_VBL,a1       ;Adresse neue Routine
      move.l a1,(a2)          ;neue Routine einhÑngen
      lea VBL_SLOT,a1         ;Slot Adresse
      move.l a2,(a1)       ;sichern

      tst.b REC_PLAY       ;Maus aufnehmen
      beq SP_12            ;nein

;Hardcopyroutine auf eigen Routine verbiegen
      move.l $502,OLD_SCR_VEK ;alter Hardcopy Vektor speichern
      move.l #SAVE_KLICK,$502 ;zeiger auf neue Rutine    
SP_12:   rts


   DATA
STRING_1:dc.b 13,10,"+-----------------------+"
       dc.b 13,10,"+      Auto Maus 2.2    +"
       dc.b 13,10,"+ (c) 11/89 Ralf Stachs +"
       dc.b 13,10,"+       ST-Computer     +"
       dc.b 13,10,"+-----------------------+"
       dc.b 13,10,0
   EVEN

STRING_3:dc.b 13,10,">***********************<"
       dc.b 13,10,">       Maus REC 2.0    <"
       dc.b 13,10,"> (c) 11/89 Ralf Stachs <"
       dc.b 13,10,">       ST-Computer     <"
       dc.b 13,10,">***********************<"
       dc.b 13,10,0
   EVEN
STRING_2:      dc.b 13,10,"Alle VBL-Slots besetzt",13,10,0

   EVEN
STRING_4:      dc.b 13,10,13,10,"*** Fehler bei Laden von A_MAUS.DAT"
            dc.b 13,10,"*** Taste drÅcken",13,10,0
   EVEN
STRING_5:      dc.b 13,10,13,10,27,"E*** A_MAUS.PRG nur"
            dc.b " aus dem Auto-Ordner starten"
            dc.b 13,10,"*** Taste drÅcken",13,10,0

   EVEN
KENNUNG_DAT:   dc.b "MAUS_1"
   EVEN
aes_data:   dc.l contrl
         dc.l aes_global
         dc.l init_in
         dc.l init_out
         dc.l addr_in
         dc.l addr_out
   
   BSS
aes_global: ds.w 15
contrl:     ds.w 10
init_in: ds.w 128
init_out:   ds.w 128
addr_in: ds.l 128
addr_out:   ds.l 128

BUF:  ds.b 100
      ds.b 256
USTACK:  ds.w 0

