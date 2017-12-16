 ;-----------------------------------------------------------.
 ; AUTO-FONTLOADER (SEKA-Sourcecode)                         |
 ; von Marcus Bode, 3200 Hildesheim                          |
 ;-----------------------------------------------------------|
 begin:               ; ** Programm initialisieren **        |
   move.l     a7,a5   ; Stackpointer in A5 puffern           |
   move.l   4(a5),a5  ; Basepage-Anfang holen                |
   move.l   $c(a5),d0 ; Programm-LÑnge holen                 |
   add.l    $14(a5),d0 ;DATA-Bereich addieren                |
   add.l    $1c(a5),d0 ;BSS-Bereich addieren                 |
   add.l    #$100,d0  ; $100 Bytes fÅr Basepage addieren     |
   move.l   d0,laenge ; GesamtlÑnge puffern                  |
 ;-----------------------------------------------------------|
 super:               ; ** Supervisor Mode einschalten **    |
   clr.l    -(sp)     ; User Stack wird Supervisor Stack     |
   move.w   #$20,-(sp) ;SUPER-Opcode Åbergeben               |
   trap     #1        ; GEMDOS aufrufen                      |
   add.l    #6,sp     ; Stack aufrÑumen                      |
   move.l   d0,oldssp ; alten Supervisor-Stack puffern       |
   move.l   $42e,a0   ; RAM-Endadresse holen, ...            |
   sub.l    #4,a0     ; ...Minus-Offset (4 Byte) und...      |
   move.l   #buf,(a0) ; ...Puffer-Adresse dorthin schreiben  |
 ;-----------------------------------------------------------|
 open:                ; ** Font-Datei îffnen **              |
   move.w   #2,-(sp)  ; Dateiattribut Åbergeben              |
   pea      filename  ; Filenamen-Adresse Åbergeben          |
   move.w   #$3d,-(sp) ;OPEN-Opcode Åbergeben                |
   trap     #1        ; GEMDOS aufrufen                      |
   addq.l   #8,sp     ; Stack aufrÑumen                      |
   tst.l    d0        ; Fehler aufgetreten ?                 |
   bmi      break     ; Ja, dann alles abbrechen !           |
 ;-----------------------------------------------------------|
 read:                ; ** Font-Datei einlesen **            |
   move.w   d0,handle ; File-Handle zwischenspeichern        |
   pea      buf       ; Fontpuffer-Adresse Åbergeben         |
   move.l   #4698,-(sp) ; Systemfont-LÑnge Åbergeben         |
   move.w   handle,-(sp) ;File-Handle Åbergeben              |
   move.w   #$3f,-(sp) ; READ-Opcode Åbergeben               |
   trap     #1        ; GEMDOS aufrufen                      |
   add.l    #12,sp    ; Stack aufrÑumen                      |
   tst.l    d0        ; Fehler aufgetreten ?                 |
   bmi      break     ; Ja, dann alles abbrechen !           |
 ;-----------------------------------------------------------|
 close:               ; ** Font-Datei wieder schlieûen **    |
   move.w   handle,-(sp) ; File-Handle Åbergeben             |
   move.w   #$3e,-(sp) ; CLOSE-Opcode Åbergeben              |
   trap     #1        ; GEMDOS aufrufen                      |
   addq.l   #4,sp     ; Stack aufrÑumen                      |
   tst.l    d0        ; Fehler aufgetreten ?                 |
   bmi      break     ; Ja, dann alles abbrechen !           |
 ;-----------------------------------------------------------|
 change:              ; ** Vektoren Ñndern **                |
   move.l   #buf+$25a,$607e ; neue Font-Adresse in Header    |
   move.w   #32,d0    ; 8 mîgliche VBL-Routinen mal 4 Bytes  |
   move.l   #$4ce,a0  ; Startadresse der VBL-Routinen holen  |
   move.w   #4,d1     ; erste VBL-Routine Åberspringen       |
 ;-----------------------------------------------------------|
 loop:                ; ** freien VBL-Vektor suchen **       |
   tst.l    (a0,d1)   ; testen, ob Routine benutzt wird      |
   beq      free      ; Nein, dann Suche abbrechen           |
   addq     #4,d1     ; sonst nÑchste VBL-Routine            |
   cmp      d0,d1     ; schon alle Routinen getestet ?       |
   bne      loop      ; Nein, dann weitersuchen              |
 ;-----------------------------------------------------------|
 error:               ; ** Error-Exit der Suchroutine **     |
   move.l   #0,laenge ; GesamtlÑnge auf Null setzen          |
   bra      fertig    ; Alle Routinen getestet!              |
 ;-----------------------------------------------------------|
 break:               ; ** Error-Exit der Diskroutinen **    |
   move.l   #0,d0     ; GesamtlÑnge auf Null setzen          |
   bra      fertig    ; Programm beenden                     |
 ;-----------------------------------------------------------|
 free:                ; ** freie Routine gefunden **         |
   lea      (a0,d1),a2 ;Adresse der freien VBL-Routine holen |
   move.l   a2,vbl    ; Adresse zwischenspeichern            |
   move.l   #instal,(a2) ; VBL-Vektor auf User-Routine setzen|
 ;-----------------------------------------------------------|
 fertig:              ; ** zurÅck in User Mode **            |
   move.l   oldssp,-(sp) ; alten Supervisor Stack holen      |
   move.w   #$20,-(sp)   ; SUPER-Opcode Åbergeben            |
   trap     #1        ; GEMDOS aufrufen                      |
   add.l    #6,sp     ; Stack aufrÑumen                      |
   move.l   laenge,d0 ; GesamtlÑnge zurÅckholen              |
 ;-----------------------------------------------------------|
 ende:                ; ** Programm beenden **               |
   move.w   #0,-(sp)  ; Fehlercode 0 Åbergeben               |
   move.l   d0,-(sp)  ; GesamtlÑnge Åbergeben                |
   move.w   #$31,-(sp) ;KEEP PROCESS-Opcode Åbergeben        |
   trap     #1        ; GEMDOS aufrufen (zurÅck zum Desktop) |
 ;-----------------------------------------------------------|
 instal:              ; ** VBL-Interrupt-Routine **          |
   cmpi.l   #buf+$25a,$607e ; Fontdaten-Zeiger verÑndert ?   |
   beq      weiter    ; Nein, dann weiter prÅfen             |
   move.l   #buf+$25a,$607e;sonst neue Fontdaten-Adresse in..|
   move.l   #buf+$25a,$2924;..TOS-/GEM-Fontvektoren eintragen|
   move.l   vbl,a0    ; Adresse der User-VBL-Routine holen   |
   clr.l    (a0)      ; User-VBL-Routine lîschen             |
 ;-----------------------------------------------------------|
 weiter:              ; ** VBL-Routine beenden **            |
   rts                ; RÅcksprung                           |
 ;-----------------------------------------------------------|
 filename:  dc.b 'system*.fnt',0 ; Filename des neuen Fonts  |
 handle:    blk.w 1   ; Speicher fÅr File-Handle             |
 laenge:    blk.l 1   ; Speicher fÅr GesamtlÑnge             |
 vbl:       blk.l 1   ; Speicher fÅr VBL-Adresse             |
 oldssp:    blk.l 1   ; Speicher fÅr Supervisor Stack        |
 buf:       blk.b 5000 ;Speicher fÅr neuen Systemfont        |
 ;-----------------------------------------------------------'
