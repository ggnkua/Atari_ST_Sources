;*--------------------------*
;*   System                 *
;*   by Ralf Stachs         *
;* (c) 1992 MAXON Computer  *
;*--------------------------*

;###################################
;# Grîûe des Environment Speichers #
;###################################
ENV_BUFFER equ 200

;TRAPS
;*****
GEMDOS  equ 1
BIOS     equ 13
XBIOS equ 14


   TEXT
;Anfang des resident gehaltenen Speicher
RESI_ANFANG:

;zuerst System installieren
      jmp INSTALL

;######################
;# Neue Gemdosroutine #
;######################
;XBRA Protokoll der neuen Gemdosroutine
         dc.b "XBRA"       ;XBRA Protokoll
         dc.b "RS23"       ;eigene Erkennung 
OLD_GEMDOS: dc.l 0            ;alter Vektor

NEW_GEMDOS:
;nach zweitem Fsfirst aufruf NEW_GEMDOS ausgehÑngt
      tst.b COUNTER        ;Counter gleich 0
      beq ENDE          ;ja, dann ende

;Stack bestimmen
      move.l usp,a0        ;Zeiger auf Userstack (USP) holen
       
;Gemdos Aufruf aus Supervisor Modus ?     
      move.w (sp),d0       ;Statusreg. von Stack holen
      btst #13,d0          ;Supervisormodus ?
      beq USER          ;nein User Modus
      
;Zeiger auf Gemdosaufruf (SSP) 
      move.l a7,a0         ;Stackpointer (SSP) holen 
      move.w OFFSET,d0     ;Offset ab 68010
      lea 6(a0,d0.w),a0    ;Zeiger auf Gemdosaufruf
      
;Gemdosnummer holen
USER: move.w (a0)+,d0         ;Gemdosnummer holen
      cmp.w #78,d0         ;Fsfirst Aufruf
      bne ENDE          ;Nein

;Suchname = '\*.ACC' 
      move.l (a0),a0       ;Zeiger auf Suchnamen
      cmp.b #'\',(a0)+     ;Suchname '\'
      bne ENDE          ;nein dann ende
      cmp.b #'*',(a0)+     ;Suchname '*'
      bne ENDE          ;nein dann ende
      cmp.b #'.',(a0)+     ;Suchname '.'
      bne ENDE          ;nein dann ende
      cmp.b #'A',(a0)+     ;Suchname 'A'
      bne ENDE          ;nein dann ende
      cmp.b #'C',(a0)+     ;Suchname 'C'
      bne ENDE          ;nein dann ende
      cmp.b #'C',(a0)+     ;Suchname 'C'
      bne ENDE          ;nein dann ende

;Gemdosaufruf Fsfirst mit richtigem Suchname liegt vor
;*****************************************************
;Desktop aktuelles PRG ?
      move.l A_RUN,a0         ;Adresse auf Zeiger der aktuellen Basepage
      move.l (a0),a0       ;Zeiger auf Basepage
      tst.l $C(a0)         ;LÑnge des Programmcode = 0
      bne ENDE          ;nein, nicht Desktop 

;RÅcksprungadresse merken
      move.l 2(a7),a0         ;RÅcksprungadresse vom SSP holen
      move.l a0,RETURN     ;und sichern

;und neue RÅcksprungadresse setzen
      move.l #MY_PATH,2(a7)   ;RÅcksprung zu eigenen Routine

;Aufrufe ZÑhlen
      sub.b #1,COUNTER     ;Counter herunterzÑhlen
            
;alten Gemdosvektor anspringen
ENDE: move.l OLD_GEMDOS,a0 ;alten Gemdosvektor laden
      jmp (a0)             ;und anspringen


;Eigene Routine nach Fsfirst von GEM
;***********************************
MY_PATH:movem.l d1-d7/a0-a6,-(sp) ;Register retten

;neuen Pfad setzen "\SYSTEM.ACC"
      move.l #PATH,-(sp)      ;Pfad "\SYSTEM.ACC"
      move.w #59,-(sp)     ;Dsetpath aufrufen
      trap #GEMDOS         
      addq.l #6,sp

;Directory nach ACC absuchen
;ersetzt den Original Fsfirst (GEM) aufruf
      move.w #0,-(sp)         ;normaler Dateityp
      pea PATH_2           ;Pfad "\SYSTEM.ACC\*.ACC"
      move.w #78,-(sp)     ;Fsfirst aufrufen
      trap #GEMDOS         
      addq.l #8,sp

      movem.l (sp)+,d1-d7/a0-a6 ;Register zurÅckschreiben

;zur alten Fsfirst Routine (GEM) springen
      move.l RETURN,a0     ;alte RÅcksprungadresse
      jmp (a0)          ;anspringen

;##################################
;# setzen der Environment Strings #
;##################################
;XBRA Protokoll fÅr 
         dc.b "XBRA"       ;XBRA Protokoll
         dc.b "RS23"       ;eigene Erkennung 
OLD_EXEC_OS:dc.l 0            ;alter Vektor

NEW_EXEC_OS:
      move.l 4(sp),a0         ;Adresse BASEPAGE
      move.l #NEW_ENV,$2c(a0) ;neues Environment setzen
      move.l OLD_EXEC_OS,a0   ;alten Vektor
      jmp (a0)          ;anspringen
      
;Variablen und Flags
;*******************
   ;OFFSET   -> ab 68010 ein offset von 2 fÅr Formate-Code
   ;RETURN   -> RÅcksprungadresse der Fsfirst Routine (GEM)
   ;A_RUN    -> Adresse von Zeiger auf aktueller Basepage
   ;COUNTER -> Anzahl der Aufrufe bis NEW_GEMDOS ausgehÑngt wird
OFFSET:     dc.w 0
RETURN:     dc.l 0
A_RUN:      dc.l 0
COUNTER: dc.b 2
         dc.b 0

   EVEN
   ;Pfad zum laden der ACC
PATH:    dc.b "\SYSTEM.ACC",0 

   EVEN
   ;Pfad fÅr Fsfirst
PATH_2:     dc.b "\SYSTEM.ACC\*.ACC",0 

   EVEN
   ;neue Environment Strings
NEW_ENV: dc.b "PATH=;?:;?:\SYSTEM.ACC",0,0   ;Voreinstellung ohne SYSTEM.INF
         ds.b ENV_BUFFER         ;200 Bytes fÅr Environment
         dc.b -1,0            ;Ende des Buffers (-1)
         
;Ende des resident gehaltenen Speicher
RESI_ENDE:


;#############################
;# Installierung von System  #
;#############################
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
      beq SP_20            ;ja, keine ap_version

;vom desktop aus gestartet
;SYSTEM nur aus Auto Ordner starten
      pea  STRING_4           
      jmp ERROR

;###########################################
;# internes Setzen der Environment Strings #
;###########################################
;aktuelles Laufwerk fÅr SYSTEM.INF lesen        
SP_20:   move.w #$19,-(sp)    ;Dgetdrv aufrufen
      trap #GEMDOS
      addq.l #2,sp
         
      add.b #"A",d0        ;Laufwerksbuchstabe berechnen
      move.b d0,FNAME         ;Laufwerksbuchstabe in Pfad setzen
      move.b d0,NEW_ENV+6     ;voreinstellung fÅr Environment Variable Path
      move.b d0,NEW_ENV+10 ;voreinstellung fÅr Environment Variable Path
      
;SYSTEM.INF îffnen (?:\AUTO\SYSTEM.INF)
      move.w #0,-(sp)         ;nur lesen
      pea FNAME            ;Pfad mit Dateinamen
      move.w #$3d,-(sp)    ;Fopen aufrufen
      trap #GEMDOS
      addq.l #8,sp
      
      tst.w d0          ;SYSTEM.INF nicht vorhanden
      bmi SP_21            ;ja, RÅckgabewert negativ
      move.w d0,FILE_HANDLE   ;Handle merken    

;SYSTEM.INF lesen
      lea NEW_ENV,a6       ;Adresse der Environment Strings 

SP_23:   tst.b (a6)           ;ende des Buffer (negativ)
      bpl SP_28            ;nein     

;Fehlermeldung ausgeben wenn ende des Puffer erreicht
      pea STRING_5
      move.w   #9,-(sp)
      trap #GEMDOS
      addq.l #6,sp

;auf Taste warten
      move.w #2,-(sp)         ;von Tastatur
      move.w #2,-(sp)         ;Bconin
      trap   #BIOS
      addq.l #4,sp
      bra SP_22            ;SYSTEM.INF schlieûen
      
SP_28:   move.l a6,-(sp)         ;Adresse des Buffers
      move.l #1,-(sp)         ;Anzahl der Bytes
      move.w FILE_HANDLE,-(sp)
      move.w #$3f,-(sp)    ;Fread
      trap   #GEMDOS
      lea    $c(sp),sp

      tst.l d0          ;Ende von SYSTEM.INF
      beq SP_22            ;ja, kein Zeichen gelesen

;Daten von SYSTEM.INF in Environment schreiben
      move.b (a6),d0       ;Zeichen holen

      cmp.b #'?',d0        ;Bootlaufwerk ?
      bne SP_26            ;nein, dann weiter
      move.b FNAME,(a6)    ;ja, Bootlaufwerk eintragen
   
SP_26:   cmp.b #13,d0         ;Return
      beq SP_23            ;ja, Zeichen Åberschreiben
      
      cmp.b #10,d0         ;Line Feed
      bne SP_24            ;nein, Buffer plus 1
      move.b #0,(a6)       ;ja, dann ende des Strings

SP_24:   add.l #1,a6          ;Adresse des Buffers plus 1      
      bra SP_23            ;nÑchstes Zeichen lesen

;Ende von SYSTEM.INF
SP_22:   move.b #0,(a6)       ;Doppel null als ende

;SYSTEM.INF schlieûen
      move.w FILE_HANDLE,-(sp)      
      move.w #$3E,-(sp)    ;Fclose aufrufen
      trap   #GEMDOS
      addq.l #4,sp

;zur Installierung in Supervisor-Modus
;*************************************
SP_21:   lea INIT_GEMDOS,a0      ;Adresse von INIT_GEMDOS nach a0
      pea   (a0)
      move.w #$26,-(sp)    ;Supexec aufrufen
      trap #XBIOS
      addq.l #6,sp

;Installierung abgeschlossen und String ausgeben
      pea STRING_2      
      move.w   #9,-(sp)
      trap #GEMDOS
      addq.l #6,sp

;neue Gemdos-Routine resident im Speicher halten
;von RESI_ENDE bis RESI_ANFANG
      clr.w -(sp)
      pea RESI_ENDE-RESI_ANFANG+256
      move.w #49,-(sp)     ;Ptermres aufrufen   
      trap #GEMDOS


;########################################################
;# neue GEMDOS-Routine im Supervisor-Modus installieren #
;########################################################
;Adresse von Kbshift ermitteln         
;und bei gedrÅckter Control Taste abbrechen
INIT_GEMDOS: 
      move.l #$e1b,a1         ;vorgabe fÅr TOS 1.0 (Kbshift)
      move.l #$602c,A_RUN     ;vorgabe fÅr TOS 1.0 (Basepage)
      move.l $4f2,a0       ;_sysbase a0=Anfangsadresse des Betriebssystem
   
      cmp.w #$0100,2(a0)      ;TOS 1.0
      beq SP_9          ;ja
   
      move.l 36(a0),a1     ;(a1) Adresse von Kbshift
      move.l 40(a0),A_RUN     ;Adresse auf Zeiger der aktuellen Basepage

SP_9: btst.b #2,(a1)       ;Control Taste gedrÅckt
      beq SP_12            ;nein, dann weiter
      
;Installieren durch drÅcken der Control Taste abgebrochen
      pea STRING_3      
      jmp ERROR

;System  schon installiert ?
;***************************
SP_12:   move.l $84,a0        ;Adresse des Gemdosvektor nach a0

SP_1: cmp.l #"RS23",-8(a0) ;System schon vorhanden
      beq SP_2          ;ja, System dann ende

      cmp.l #"XBRA",-12(a0)   ;XBRA Kennung
      bne SP_4          ;nein, dann System installieren

      move.l -4(a0),a1     ;Adresse der nÑchsten Gemdosvektors
      move.l a1,a0         ;von a1 nach a0
      bra SP_1          ;weiter                       

;System war schon installiert
;****************************
;Meldung System schon installiert
SP_2: pea STRING_1      
      jmp ERROR

;System  installieren
;********************
SP_4: move.l $84,OLD_GEMDOS   ;alten Gemdos-Vektor sichern
      move.l #NEW_GEMDOS,$84  ;und neuen Gemdos-Vektor setzen

      cmp.b #'-',NEW_ENV      ;Environment setzen
      beq SP_8          ;nein, erstes Zeichen '-' dann nicht setzen
         
      move.l $4fe,OLD_EXEC_OS ;alten exec_os Vektor sichern
      move.l #NEW_EXEC_OS,$4fe;und neuen exec_os Vektor setzen

;Prozessor feststellen
SP_8: move.l $5a0,d0       ;_p_cookies laden Zeiger vorhanden
      beq _68000           ;nein, dann 68000
      move.l d0,a0         ;Zeiger auf Cookies in a0
      
SP_31:   move.l (a0)+,d1         ;Cookie ID-Code in d1
      beq _68000           ;das war der letzte dann 68000
      cmp.l #"_CPU",d1     ;CPU Cookie suchen
      beq SP_30            ;gefunden
      add.l #4,a0          ;Cookie Wert Åberspringen
      bra SP_31            ;weiter suchen

;CPU Cookie gefunden
SP_30:   tst.l (a0)           ;Cookie Wert testen
      beq _68000           ;Cookie Wert = 0 dann 68000
      
      move.w #2,OFFSET     ;ab 68010 offset von 2
      
_68000:  rts

;###############################################
;# Fehlermeldung ausgeben und auf Taste warten #
;###############################################
ERROR:   move.w   #9,-(sp)
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

;################
;# Datensegment #
;################
   DATA
   ;FILE_HANDLE   -> Handle von SYSTEM.INF
FILE_HANDLE: dc.w 0
          
   EVEN
   ;Pfad von SYSTEM.INF
FNAME:      dc.b "A:\AUTO\SYSTEM.INF",0   

   EVEN
STRING_1:   dc.b 13,10,"**********"
         dc.b 13,10,"*** System ist schon installiert "
         dc.b 13,10,"*** Taste drÅcken"
         dc.b 13,10,"**********",13,10,0
   EVEN
STRING_2:   dc.b 27,"p"
         dc.b 13,10,"+*********************************+"
         dc.b 13,10,"+           System 1.0            +" 
         dc.b 13,10,"+                                 +"
         dc.b 13,10,"+     (c)12/91  Ralf Stachs       +"
         dc.b 13,10,"+          ST Computer            +"
         dc.b 13,10,"+*********************************+"
         dc.b 13,10,27,"q",0
   EVEN
STRING_3:   dc.b 27,"p"
         dc.b 13,10,"**********"
         dc.b 13,10,"*** System wird nicht installiert "
         dc.b 13,10,"*** Taste drÅcken                 "
         dc.b 13,10,"**********",13,10
         dc.b 27,"q",0
   EVEN
STRING_4:   dc.b 27,"E"
         dc.b 13,10,"*** SYSTEM.PRG nur aus dem Auto Ordner starten"
         dc.b 13,10,"*** Taste drÅcken",13,10,0
   EVEN
STRING_5:   dc.b 27,"p"
         dc.b 13,10,"**********"
         dc.b 13,10,"*** Environment Speicher voll max. 224 Zeichen"
         dc.b 13,10,"*** Taste drÅcken                             "
         dc.b 13,10,"**********",13,10
         dc.b 27,"q",0

   EVEN
aes_data:   dc.l contrl
         dc.l aes_global
         dc.l init_in
         dc.l init_out
         dc.l addr_in
         dc.l addr_out

;###############
;# BSS-Segment #
;###############
   EVEN
   BSS
aes_global: ds.w 15
contrl:     ds.w 10
init_in: ds.w 128
init_out:   ds.w 128
addr_in: ds.l 128
addr_out:   ds.l 128

      ds.b 256
sUSTACK:  ds.w 0
