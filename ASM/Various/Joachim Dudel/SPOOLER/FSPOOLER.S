* fspooler.prg
* Druckerspooler Åber File
* (c)'91 by MAXON Computer GmbH
* written by Joachim Dudel

* text-segment
resanf  pea     initsp(pc)      Routine initsp..
        move    #$20,-(sp)      auf Trap0 legen
        move    #5,-(sp)        setexc
        trap    #13             bios
        addq.l  #8,sp

        move.l  d0,oldtrap      Trap0 retten

        pea     text(pc)        (c) ausgeben
        move    #9,-(sp)        cconws
        trap    #1              gemdos
        addq.l  #6,sp

        clr     -(sp)           Fehlercode = 0
        move.l  #(resend-resanf+$100),-(sp)
        move    #49,-(sp)       ptermres
        trap    #1              gemdos
* Das Programm ist beendet, bleibt aber im
* Speicher und wartet auf Trap0...

        dc.b    "XBRADSpF"      XBRA-Kennung
oldtrap ds.l    1               alter Trap0
* Hier springt Trap0 hin
initsp  tst     flag            schon in Betrieb?
        beq.s   cont
        rte                     ja -> zurÅck!

cont    st      flag            jetzt in Betrieb
        move.l  $100.w,oldbusy  busy-int. retten
        bclr.b  #0,$fa03.w      aktive-edge
        move.l  #busy,$100.w    busy-int. inst.
        bset.b  #0,$fa15.w      entmaskieren
        clr.l   count           File-Zeiger = 0

* Schleife zum 4kByte Blîcke einlesen & ausgeben
loop    bclr.b  #0,$fa09.w      busy deaktivieren
* Register austauschen
* (d0-d2 und a0-a2 werden von Traps zerstîrt)
        movem.l d0-d2/a0-a2,savesp
        movem.l save(pc),d0-d2/a0-a2
        move.l  $114.w,old200   200Hz-Int. retten
        move.l  #load,$114.w    eigene Routine
        rte                     warten auf Userm.

* jetzt kommt das Hauptprogramm wieder dran...

        dc.b    "XBRADSpF"      XBRA-Kennung
old200  ds.l    1               alter 200Hz-Int.
* Hier landet der umgeleitete 200Hz-Int.
load    btst.b  #5,(a7)         Supervisormodus?
        beq.s   lcont           nein -> lcont
        move.l  old200(pc),-(sp)        sonst..
        rts                     ..alter 200Hz-I.

lcont   movem.l d0-d2/a0-a2,save        Register-
        movem.l savesp(pc),d0-d2/a0-a2   Wechsel
* 200Hz wiederherstellen
        move.l  old200(pc),$114.w
* in Service(200Hz) lîschen
        move.b  #%11011111,$fa11.w

        move    sr,d0           Status-Register
* Interrupt-PrioritÑt auf 5 setzen
        and     #%1111100011111111,d0
        or      #%0000010100000000,d0
        move    d0,sr           Status-Register
* so kînnen wieder 200Hz-Int. auftreten -
* die braucht GEMDOS beim laden

        clr     -(sp)           nur lesen
        pea     fname(pc)       'C:\spool.tsk'
        move    #61,-(sp)       fopen
        trap    #1              gemdos
        addq.l  #8,sp
        move    d0,handle       file-handle
        bmi     ende            Fehler -> ende

        clr     -(sp)           ab Datei-Anfang
        move    handle(pc),-(sp)
        move.l  count(pc),-(sp) Position
        move    #66,-(sp)       fseek
        trap    #1              gemdos
        lea     $a(sp),sp
        tst.l   d0              alles o.k.?
        bmi     ende            nein -> ende

        pea     puffer(pc)      4kB-Puffer
        move.l  #$1000,-(sp)    nÑchste 4kByte
        move    handle(pc),-(sp)
        move    #63,-(sp)       fread
        trap    #1              gemdos
        lea     $c(sp),sp
        move.l  d0,length       eingelesene Bytes

        move    handle(pc),-(sp)
        move    #62,-(sp)       fclose
        trap    #1              gemdos
        addq.l  #4,sp

        move.l  length(pc),d0
        subq.l  #1,d0           d0: Puffer-ZÑhler
        bmi     ende            Datei schon leer
        add.l   #$1000,count    4kB weiter merken
        lea     puffer(pc),a0   a0: Puffer-Zeiger
        lea     $8800.w,a1      a1: PSG-Adressen
        lea     $8802.w,a2      a2: PSG-Daten
        bset.b  #0,$fa09.w      busy-int. aktiv

* Schleife fÅr einzelne Zeichen Ausgeben
cent    move.b  #15,(a1)        portB wÑhlen
        move.b  (a0)+,(a2)      Byte auf Centr.
        move.b  #14,(a1)        portA wÑhlen
        move.b  (a1),d1         d1: portA
        bclr.b  #5,d1           strobe low
        move.b  d1,(a2)         senden
        bset.b  #5,d1           strobe high
        move.b  d1,(a2)         senden
        movem.l d0-d2/a0-a2,savesp      Register-
        movem.l save(pc),d0-d2/a0-a2     Wechsel
* in-service(busy) lîschen & auf busy-int. warten
        move.b  #%11111110,$fa11.w
        rte

* solange kann das 'Hauptprogramm' weiterlaufen..

        dc.b    "XBRADSpF"      XBRA-Kennung
oldbusy ds.l    1               alter busy-Vektor
* Einsprung fÅr busy-Int.
busy    movem.l d0-d2/a0-a2,save        Register-
        movem.l savesp(pc),d0-d2/a0-a2   Wechsel
        dbra    d0,cent         nÑchstes Byte
* Puffer ist leer, also wieder nachladen
        bra     loop

* Routine sauber beenden
ende    bclr.b  #0,$fa09.w      busy-int. deakt.
        move.l  oldbusy(pc),$100.w
        clr     flag            nicht in Betrieb
        movem.l save(pc),d0-d2/a0-a2    Register
        rte                     warten auf Trap0

* data-segment
text    dc.b    13,10,"Drucker-Spooler "
        dc.b    "installiert",13,10
        dc.b    "(c)'91 by MAXON Computer GmbH"
        dc.b    13,10
        dc.b    "written by Joachim Dudel"
        dc.b    13,10,0
        even
fname   dc.b    "C:\SPOOL.TSK",0        Dateiname
        even

* bss-segment
handle  dsbss   1               File-Handle
count   dsbss.l 1               Datei-Position
length  dsbss.l 1               Datei-LÑnge
flag    dsbss   1               'in Betrieb'
* Register-Puffer (a0-a2/d0-d2) fÅr
save    dsbss.l 6               Hauptprogramm
savesp  dsbss.l 6               Interrupt
puffer  dsbss.b $1000           Spool-Puffer
resend  dsbss   0               Programmende
