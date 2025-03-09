*-------------------------*
*  Control-Shift-Maus     *
*  by Ralf Stachs         *
*-------------------------*
* (c) 1991 MAXON Computer *
*-------------------------*

;TRAPS
GEMDOS  equ 1
BIOS     equ 13
XBIOS    equ 14


****************************************************
;Programmteil der resident im Speicher gehalten wird
;von RESI_ANFANG bis RESI_ENDE
****************************************************
   TEXT
RESI_ANFANG:
      bra INSTALL       ;zur Installationrutine springen

;Flags
******
   ;FIRST      ->Rechte Maustaste zum ersten mal gedrckt
   ;           0->Rechte Maustaste noch nicht gedrckt
   ;           1->Rechte Maustaste war schon gedrckt
   ;MAUS_OFF   ->schaltet CS_Maus an oder aus
   ;           $00 CS_Maus an
   ;           $FF CS_MAUS aus

FIRST:      dc.b 0
MAUS_OFF:   dc.b 0   

         dc.b "XBRA"       ;XBRA Protokoll
         dc.b "RS11"       ;eigene Erkennung
OLD_VEC:    dc.l 0            ;alter Mousevektor

;neue Mausroutine
*****************
NEW_MOUSE:  
      movem.l d0/a0-a2,-(sp)  ;Register retten

;Maus Header ?
      move.b (a0),d0       ;Header Kopf in d0

      cmp.b #$f8,d0        ;kleiner $f8
      blt ENDE          ;ja

      cmp.b #$fb,d0        ;gr”žer $fb
      bgt ENDE          ;ja

;Maus ausgeschaltet TOS ?           
      move.l A_MOUSE_FLAG,a1  ;Flag fr Maus aus (MOUSE_FLAG)

      tst.b (a1)           ;Maus ausgeschaltet
      bne ENDE          ;ja

;CS_Maus ausgeschaltet ?
      tst.b MAUS_OFF       ;CS_MAUS ausgeschaltet
      bne ENDE          ;ja

;aktuelles PRG Desktop ?
      move.l A_RUN,a1         ;a1=Adresse auf Zeiger der aktuellen Basepage
      move.l (a1),a2       ;a2=Zeiger auf Basepage
      tst.l $C(a2)         ;L„nge des Programmcode = 0
      bne SP_11            ;nein, nicht Desktop 

;Rechte Maustaste gedrckt        
      btst.b #0,(a0)       ;rechte Maustaste gedrckt
      beq SP_11            ;nein, Flags und Tasten l”schen
                        ;wenn FIRST noch gesetzt
                        
;Rechte Maustaste zum ersten mal gedrckt
      tst.b FIRST          ;zum ersten mal
      bne ENDE          ;nein
      
;Control und Shift Taste setzen
      move.l A_KBSHIFT,a1     ;Adresse von Kbshift in a1
      or.b #%00000101,(a1) ;Control Taste (Bit 2) setzen
                        ;und Shift Taste (Bit 0) setzen
      move.b #1,FIRST         ;Flag setzen
      bra ENDE
      
;Control und Shift Taste l”schen
SP_11:   tst.b FIRST          ;First Flag noch gesetzt
      beq ENDE          ;Nein, dann Ende

      move.l A_KBSHIFT,a1     ;Adresse von Kbshift in a1
      and.b #%11111010,(a1)   ;Control Taste (Bit 2) l”schen
                        ;und Shift Taste (Bit 0) l”schen
      move.b #0,FIRST         ;Flag l”schen
               
;alte Mausroutine anspringen
ENDE: movem.l (sp)+,d0/a0-a2  ;Register zurckschreiben
      move.l OLD_VEC,-(sp) ;alte Mausroutine
      rts               ;anspringen


;VBL-Routine bei Start aus AUTO-Ordner
**************************************

      dc.b "XBRA"          ;XBRA Protokoll
      dc.b "RS12"          ;eigene Erkennung
      dc.l 0               ;alter vektor nicht benutzt

NEU_VBL:
      move.l A_KBDV,a0     ;kdbv Adresse nach a0
      lea 16(a0),a1        ;Adresse Mausvektor a1
      lea OLD_VEC,a0       ;alter Mausvektor vom Betriebssystem
      cmp.l (a0)+,(a1)+    ;alter Mausvektor noch da
      beq SP_3          ;ja   

      move.l -(a1),OLD_VEC ;alten Mausvektor sichern 
      move.l #NEW_MOUSE,(a1)  ;neue Mausroutine initialisieren

      move.l A_VBL_SLOT,a0 ;vbl-Slot l”schen
      move.l #0,(a0)    

SP_3: rts

;Adressen 
;********
   ;A_KBDV        -> Adresse der kbdv Tabelle
   ;A_VBL_SLOT    -> Adresse des VBL-Slot
   ;A_MOUSE_FLAG  -> Adresse von MOUSE_FLAG                          
   ;     MOUSE_FLAG = 0 ->Maus-Interuptbehandlung ein
   ;     MOUSE_FLAG <>0 ->Maus-Interuptbehandlung aus
   ;A_KBSHIFT     -> Adresse von Kbshift 
   ;A_RUN         -> Adresse von Zeiger auf aktueller Basepage
A_KBDV:     dc.l 0
A_VBL_SLOT:    dc.l 0
A_MOUSE_FLAG:  dc.l 0   
A_KBSHIFT:     dc.l 0
A_RUN:         dc.l 0

RESI_ENDE:


*************************
;Instalierung von CS_Maus
*************************
;gesammten Programmspeicher belegen
   EVEN
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

;Adresse KBDVECS holen
      move #34,-(a7)          ;Kbdvbase aufrufen
      trap #XBIOS
      addq.l #2,a7
      move.l d0,A_KBDV     ;Adresse der Vektortabelle sichern
         
;CS_Maus schon installiert ?        
      move.l A_KBDV,a1     ;Adresse der Vektortabelle nach a1
      move.l 16(a1),a2     ;Adresse von mausrutine in a2
      move.l a2,a0         ;a0 zum suchen

SP_1: cmp.l #"RS11",-8(a0) ;CS_Maus schon vorhanden
      beq SP_2          ;ja, CS_MAUS initialisieren

      cmp.l #"XBRA",-12(a0)   ;XBRA Kennung
      bne SP_4          ;CS_Maus instalieren
                        ;Orginal Mausvektor oder kein XBRA Protokoll

      move.l -4(a0),a1     ;Adresse der n„chsten Mausrutine
      move.l a1,a0         ;von a1 nach a0
      bra SP_1          ;weiter                       

;CS_Maus war schon instaliert
*****************************
SP_2: not.b -13(a0)        ;MAUS_OFF invertieren      
      bne SP_7

;Meldung CS_Maus einschalten
      pea STRING_3      
      move.w   #9,-(sp)
      trap #GEMDOS
      addq.l #6,sp
      bra SP_8          ;ende

;Meldung CS_Maus auschalten
SP_7: pea STRING_4         
      move.w   #9,-(sp)
      trap #GEMDOS
      addq.l #6,sp
   
;PRG beenden
SP_8: clr.w  -(sp)
      trap #GEMDOS

;CS_MAUS instalieren
********************
;alten Vektor sichern
SP_4: lea OLD_VEC,a0 
      move.l a2,(a0)       

;AES-anmelden
      move.w #10,d0        ;Applikation anmelden
      bsr AES_INIT         ;AES aufrufen
      tst.w AES_GLOBAL     ;starten aus AUTO-Ordner
      beq SP_6          ;ja, keine ap_version
         
;Vom Desktop starten
********************
;maus installieren         
         lea DESKTOP,a0       ;Adresse von Desktop nach a0
      pea   (a0)
      move.w #38,-(sp)     ;Supexec aufrufen
      trap #XBIOS
      addq.l #6,sp
      bra SP_5
         
;Aus AUTO-Ordner starten
************************
;Unterprogramm im Supervisor-Modus ausfhren
SP_6: lea AUTO,a0          ;Adresse von auto nach a0
      pea   (a0)
      move.w #$26,-(sp)    ;Supexec aufrufen
      trap #XBIOS
      addq.l #6,sp

;Adresse von MOUSE_FLAG holen
SP_5: dc.w $a000           ;Adresse negative Line-A Variabelen
      sub.l #$153,a0       ;Adresse MOUSE-FLAG berechnen
      move.l a0,A_MOUSE_FLAG  ;MOUSE FLAG merken

;installierung i.o.
      pea STRING_1
      move.w   #9,-(sp)
      trap #GEMDOS
      addq.l #6,sp
         
;Speicherplatz fr Mausroutine            
;resident im Speicher halten
      clr.w -(sp)
      pea RESI_ENDE-RESI_ANFANG+256
      move.w #49,-(a7)     ;Ptermres aufrufen   
      trap #GEMDOS


***************************
;Unterprogramme von CS_MAUS
***************************

;PRG im Supervisor-Modus Mausroutine installieren
*************************************************
;starten aus AUTO Ordner
;VBL installieren
AUTO: move.w $454,d0       ;Anzahl der VBL Routinen (nvbls)
      lsl #2,d0            ;Anzahl*4
      move.l $456,a0       ;Zeiger auf VBL (_vblqueue)            
      clr d1               ;Z„hler

WEITER:  tst.l 4(a0,d1)       ;VBL Slot frei
      beq FREI          ;ja
      add #4,d1            ;n„chster Slotpointer
      cmp.w d0,d1          ;alle slots abgefragt
      bne WEITER           

;CS_Maus nicht initialisieren
      pea STRING_2         ;Alle Slots besetzt
      move.w   #9,-(sp)
      trap #GEMDOS
      addq.l #6,sp

      clr.w  -(sp)         ;PRG beenden
      trap #GEMDOS

FREI: lea 4(a0,d1),a2         ;Adresse  Slot in a2
      lea NEU_VBL,a1       ;Adresse neue Routine
      move.l a1,(a2)       ;neue Routine einh„ngen
      lea A_VBL_SLOT,a1    ;Slot Adresse
      move.l a2,(a1)       ;sichern

;Adresse von Kbshift ermitteln und
;Adresse von Zeiger auf aktueller Basepage                  
SP_10:   move.l #$e1b,A_KBSHIFT  ;vorgabe fr TOS 1.0 (Kbshift)
      move.l #$602c,A_RUN     ;vorgabe fr TOS 1.0 (Basepage)

      move.l $4f2,a0       ;(a0) _sysbase
   
      cmp.w #$0100,2(a0)      ;TOS 1.0
      beq SP_9          ;ja
   
      move.l 36(a0),a1     ;(a1) Adresse von Kbshift
      move.l a1,A_KBSHIFT     ;Adresse merken

      move.l 40(a0),a1     ;(a1) Adresse auf Zeiger der aktuellen Basepage
      move.l a1,A_RUN         ;Adresse merken

SP_9: rts


;PRG im Supervisor-Modus Mausroutine installieren
*************************************************
;Starten vom Desktop
DESKTOP: 
      move.l A_KBDV,a0     ;Keyboardadresse nach a0   
      lea NEW_MOUSE,a1     ;Adresse neue Mausroutine
      move.l a1,16(a0)     ;neuen Vektor setzen

                        ;Kbshift und Zeiger auf 
      bra SP_10            ;aktueller Basepage ermitteln
      
;AES aufrufen
*************
AES_INIT:
      lea CONTRL,a0        ;Adresse CONTRL nach a0
      move.w d0,(a0)+         ;Opcode
      clr.w (a0)+          ;eintr„ge INIT_IN
      move.w #1,(a0)       ;eintr„ge INIT_OUT
      clr.w (a0)+          ;eintr„ge ADDR_IN
      clr.w (a0)           ;eintr„ge ADDR_OUT
            
      move.l #AES_DATA,d1     ;Adresse AES-Array
      move.w #$c8,d0       ;AES_Aufruf
      trap #2
      rts


   DATA
   EVEN
STRING_1:
   dc.b 27,"E",27,"p"
   dc.b 13,10,"+***************************+"
   dc.b 13,10,"+                           +"
   dc.b 13,10,"+  Control-Shift-Maus  1.0  +"
   dc.b 13,10,"+    >>>>  CS_MAUS  <<<<    +"
   dc.b 13,10,"+                           +"
   dc.b 13,10,"+    (c)7/91  Ralf Stachs   +"
   dc.b 13,10,"+        ST Computer        +"
   dc.b 13,10,"+                           +"
   dc.b 13,10,"+***************************+"
   dc.b 13,10
   dc.b 27,"q",0

   EVEN
STRING_2: 
   dc.b 13,10,"Alle VBL-Slots besetzt",13,10,0

   EVEN
STRING_3: 
   dc.b 27,"E"
   dc.b 13,10,"*****************"
   dc.b 13,10,"*  CS_MAUS EIN  *"
   dc.b 13,10,"*****************",0

   EVEN
STRING_4: 
   dc.b 27,"E",27,"p"
   dc.b 13,10,"*****************"
   dc.b 13,10,"*  CS_MAUS AUS  *"
   dc.b 13,10,"*****************"
   dc.b 27,"q",0

   EVEN
AES_DATA:
      dc.l CONTRL
      dc.l AES_GLOBAL
      dc.l INIT_IN
      dc.l INIT_OUT
      dc.l ADDR_IN
      dc.l ADDR_OUT

   BSS
AES_GLOBAL: ds.w 15
CONTRL:     ds.w 10
INIT_IN: ds.w 128
INIT_OUT:   ds.w 128
ADDR_IN: ds.l 128
ADDR_OUT:   ds.l 128

      ds.b 100
USTACK:  ds.w 0
