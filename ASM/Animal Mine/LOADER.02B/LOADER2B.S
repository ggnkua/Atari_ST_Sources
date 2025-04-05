          TEXT
          PART 'infotext'
;    ************ ANIMAL MINE USE ONLY ***************
;Alle Loader-Versionen sind vîllig aufwÑrtskompatibel zueinander!
;D.h. die neuesten Versionen ersetzen alle alten komplett!  Alle GSC Compils ab
;Nummer 35 laufen mit diesem Loading System!
;Dieser Loader lÑuft auf 512 KB und mehr.
;Bei 512 KB ist er NICHT resetfest, sondern nur ab 1 MB.
;Er akzeptiert jedes Programm, das absolut KEINE absolute Adresse benutzt!!!!!!!
;Also auf keinen Fall den Screen nach $78000 oder so legen, sondern nur ins BSS! (Weiû doch jeder...)
;Jedes MenÅprogramm (MENU.DAT) wird im Supervisormodus gestartet, und sollte
;mit RTS beendet werden.  Also den Stack NICHT umlegen!
;(Bzw. wieder vor dem Verlassen restaurieren...)
;Wenn Du viel Stackplatz brauchst, muû er hier im Loader vergrîûert werden (superstackbereich und userstackbereich (alles doppelt benutzt))!
;MENU.DAT bekommt einen Zeiger Åbergeben:
;         d0.l: relativer Scrolltextzeiger (relativ zum Scrolltextanfang: DC.L aktuelle_position-scrolltext)
;MENU.DAT sollte folgende Zeiger zurÅckÅbergeben:
;         d0.l: relativer Scrolltextzeiger (damit der Scrolltext auch da anfÑngt, wo er aufhîrt)
;         a0.l: Zeiger auf Filename
;BEDENKE: Alles in diesem Loader MUSS PC-relativ und Adreûregister-indirekt programmiert sein!!!
;ACHTUNG: Es sollte UNBEDINGT der TITAN-AM-Bootsector auf der Intro-Compil sein, damit
;der Bootsektor nicht jedesmal stîrt!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;(Oder der neue Bootsektor vom August 1993, der auch den FALCON unterstÅtzt.)
;(FÅr eigene Bootsektoren:  Bei $60A.W steht "AM", wenn der Loader installiert ist)
;
;07.07.1992  (first final version 0.1)
;10.09.1992  (changes for version 0.1b) (StandardausfÅhrung)
;27.06.1993  (changes for version 0.2a)
;30.08.1993  (changes for version 0.2b)
;
;Neue Features der Version 0.2a:
;    - LÑuft jetzt auf dem Falcon
;    - alle Register werden nun gerettet, statt vorher nur d0
;    - Betriebssystemfehler bezÅglich $45e wurde bereinigt.
;
;Fehlerbereinigung/neue Features in Version 0.2b:
;    - Destallieren des Loaders bei v0.2a funktionierte nicht mehr (peinlich!),
;      aufgrund eines Fehlers, der durch Unwissenheit entstand (unbenutztertrap=$80...)
;    - Der Loader destalliert den BIOS-Patch des neuen Bootsektors, falls er noch
;      nicht vom Patch selber destalliert wurde.
;
;(Die Sache mit der Harddisk klappt aber immer noch nicht so ganz...)
;(Nicht mehr getestet!)
;
;
;All coding by SETHOS of ANIMAL MINE (ex-RAMSES XIII of XENEX -- DEMOZONE 68000 -- DIVISON ATARI ST ==> R.I.P May, 1992)
;Dieser Source wurde freigegeben, zum anschauen und anstaunen (haha)...
;Trotzdem: Wer Benutzungsrechte kaufen will soll uns mal kontaktieren!
;
          ENDPART
trap13    EQU $b4
unbenutztertrap EQU $0600          ;geÑndert von $800 auf $600= weil bei $800 MMU-Tabellen stehen (FALCON)!
;ACHTUNG!  Mit $80 anstelle von $800 geht's wohl nicht!
start:
          move.l    4(sp),own_basepage
          lea       own_stack(pc),sp

;evtl. muû der BIOS-Patch destalliert werden, der den ALTERNATE-Tastendruck
;simuliert hat (Kînnte nur auf dem ST passieren, da auf dem FALCON sich der
;Patch auf jeden Fall selbst destalliert, da Kbshift im TOS aufgerufen wird):
;(Der BIOS-patch liegt normalerweise bei $600.  Dorthin wird aber auch der Loader
;resetfest hingelegt.  Also muû der Patch UNBEDINGT aus dem BIOS-Vektor entfernt werden!)
;Ich weiss, daû das nicht das gelbe vom Ei ist, da es nicht immer 100%ig funkt-
;ioniert.  Vielleicht sollte man auch einfach alle Harddisks (IDE/SCSI) abmelden,
;dann gibt's keine Probleme mehr beim Booten.  Aber dann ist die Mîglichkeit weg,
;auch Laufwerke ab C: zu benutzen!

          lea       destallbiospatch(pc),a0
          bsr       super
          lea       varsave(pc),a0
          bsr       super
          lea       installtest(pc),a0
          bsr       super
          tst.b     sofortendeflag
          bne.s     sofortende

;          sf        menuinstalliertflag ;NUR ZUM TESTEN fÅr 512KB-Version!!!

          tst.b     menuinstalliertflag ;0=nicht installieren,<>0=installieren
          beq.s     menunichtinstallieren
          clr.l     -(sp)
          move.w    #32,-(sp)      ;in den Supervisormodus gehen
          trap      #1
          addq.l    #6,sp
          bsr.s     installmenu
          move.l    own_basepage(pc),-(sp)
          move.w    #$49,-(sp)     ;Release Memory
          trap      #1
;Fehlertest ist hier vîllig unwichtig(bringt nur Verwirrung), genau wie die Stackkorrektur
;          addq.l    #6,sp
;          tst.w     d0
;          bpl.s     nacherror2
;          pea       fehlerrouty(pc)
;          move.w    #$26,-(sp)
;          trap      #14
;          addq.l    #6,sp
;nacherror2:
          movea.l   4.w,a0
          jmp       (a0)           ;und anspringen
sofortende:
          clr.l     -(sp)
          move.w    #$20,-(sp)
          trap      #1             ;Supervisormode
          addq.l    #6,sp
          bsr       varload
          clr.l     unbenutztertrap.w ;fÅr den nÑchsten Loader wieder alles ins Lot bringen
;          move.l    old47a.w,$047a.w
          clr.w     -(sp)
          trap      #1
menunichtinstallieren:
;jetzt liegt ein 512 KB Rechner vor
;          move.l    own_basepage(pc),-(sp)
;          move.w    #$49,-(sp)     ;Release Memory
;          trap      #1
;          addq.l    #6,sp
          pea       ende-start+$0100.w ;Newsize
          move.l    own_basepage(pc),-(sp) ;Block
          clr.w     -(sp)
          move.w    #$4a,-(sp)     ;Mshrink
          trap      #1
          lea       $0c(sp),sp
          tst.w     d0
          bpl.s     nacherror3
          pea       fehlerrouty(pc)
          move.w    #$26,-(sp)
          trap      #14
          addq.l    #6,sp
nacherror3:
          clr.l     -(sp)
          move.w    #$20,-(sp)
          trap      #1             ;in den Supervisormode gehen
;bei Reset: Kaltstart
          clr.l     $0420.w        ;memvalid
          clr.l     $043a.w        ;memval2
          bra       pexecroutystart
;*********
          PART 'installmenu'
installmenu:
;wir sind im Supervisormode!
          lea       menuname(pc),a0
          lea       buffer(pc),a6
          bsr       load
          tst.b     d7
          beq.s     notraus2
          bsr       fehlerrouty
          bsr       selectagainnewdrive ;damit man auch 'ne Harddisk dranhaben kann.
          bra.s     installmenu
;          clr.w     -(sp)
;          trap      #1
notraus2:
          add.l     #$0200,d6
          and.l     #-$0200,d6     ;auf 512 Bytegrenze bringen, wegen _memtop/phystop!
          move.l    d6,dateicopylÑnge
;          add.l     #$0200+$2000,d6 ;"Magicseite"+$2000 fÅr Pexecrouty
          add.l     #$2000,d6      ;fÅr Pexecrouty
          movea.l   $042e.w,a0     ;_phystop
          suba.l    d6,a0
          move.l    a0,$042e.w
          cmpa.l    $0436.w,a0
          bgt.s     _memtopistkleiner
          movea.l   $0436.w,a1     ;_memtop
          suba.l    d6,a1
          move.l    a1,$0436.w
_memtopistkleiner:
          move.l    a0,jumpadr+2   ;'nen Jump eintragen

          move.w    #3,-(sp)       ;Logbase
          trap      #14
          addq.l    #2,sp
          move.l    d0,d7
          move.w    #2,-(sp)       ;Physbase
          trap      #14
          addq.l    #2,sp

          sub.l     d6,d7          ;logbase korrigieren
          sub.l     d6,d0          ;physbase korrigieren
          move.w    #-1,-(sp)
          move.l    d0,-(sp)       ;physbase
          move.l    d7,-(sp)       ;logbase
          move.w    #5,-(sp)
          trap      #14
          lea       12(sp),sp

;          sub.l     d6,$044e.w     ;Bildschirmadresse korrigieren
;          lea       $ffff8201.w,a1
;          movep.w   0(a1),d0
;          lsl.l     #8,d0
;          sub.l     d6,d0
;          move.l    d0,old82002+2
;          lsr.l     #8,d0
;          movep.w   d0,0(a1)       ;Bildschirmadresse korrigieren
          move.l    $ffff8200.w,old82002+2

          ori       #$0700,sr
          clr.l     $fffffa06.w
;          move.l    #bootsektorrts,$047a.w ;Bootsektorroutine abkappen
          movea.l   jumpadr+2(pc),a3
          lea       pexecroutystart(pc),a0
          lea       pexecroutyend(pc),a2
;nach a3 kopieren
copypexecroutyagain:
          move.w    (a0)+,(a3)+
          cmpa.l    a2,a0
          blt.s     copypexecroutyagain
;und das Programm auch noch hochkopieren:
          movea.l   a3,a4
          lea       buffer(pc),a0
          lea       (a0),a1
          adda.l    dateicopylÑnge(pc),a1
copybufferagain:move.w (a0)+,(a3)+
          cmpa.l    a1,a0
          blt.s     copybufferagain

          move.l    a4,checksumstart+2
          movea.l   a4,a0          ;menuprogrammstart
          movea.l   old42e+2(pc),a1
          moveq     #0,d0
checksummenteststart:
          add.w     (a0)+,d0
          cmpa.l    a1,a0
          blt.s     checksummenteststart
          move.w    d0,checksumme+2

;Berechnen der PrÅfsumme von $700 bis $800:
          lea       $0700.w,a3
          move.w    #$5678,d1      ;das soll das Ergebnis der Speicherseite sein
          move.w    #256/2-1,d0
addmagicstart1:
          sub.w     (a3)+,d1
          dbra      d0,addmagicstart1
;Runterkopieren des resetfesten Programms nach $600 bis maximal $700:
;Achtung!  d1.w nicht zerstîren!

          lea       $0600.w,a0     ;die Kopierroutine wird nach $600 gehÑngt!
          movea.l   a0,a3
          move.l    #$12123456,(a0)+ ;"MAGIC"
          move.l    a3,(a0)+       ;Zeiger auf die Speicherseite
          lea       cmptext(pc),a1
          lea       cmptextende2(pc),a2
copymagictextagain:
          move.w    (a1)+,(a0)+    ;es werden eh' nur words gemovet!
          cmpa.l    a2,a1
          blt.s     copymagictextagain

;Berechnen der PrÅfsumme von $600 bis $700-2:
          move.w    #256/2-1-1,d0
addmagicstart2:
          sub.w     (a3)+,d1
          dbra      d0,addmagicstart2
;Bei $700-2 wird dann die berechnete PrÅfsumme eingetragen:
          move.w    d1,(a3)+       ;MAGIC muû stimmen...

          rts
;*********
;Hier beginnt die Routine, die nach $600 kopiert wird!
;Diese Routine darf nicht lÑnger als 246 Bytes+2 Bytes PrÅfsumme+1 Long MAGIC+1 Long Zeiger auf die Speicherseite
;sein, da auf dem FALCON 030 by $700 die MMU-Tabellen beginnen!!!
cmptext:  bra.s     cmptextende    ;MUSS ein BRA.S sein!!!
;ACHTUNG!  Das "AM" wird gebraucht, damit Bootsektoren prÅfen kînnen, ob das Menu installiert ist.
          DC.B "AMls Menu loading system v0.2b by SETHOS and TITAN of ANIMAL MINE (ex-XENEX)"
          EVEN
cmptextende:
checksumstart:movea.l #"AM92",a0   ;start des Menuprogramms
          movea.l   old42e+2(pc),a1
          moveq     #0,d0
checksummenteststart0:
          add.w     (a0)+,d0
          cmpa.l    a1,a0
          blt.s     checksummenteststart0
checksumme:cmp.w    #$babe,d0
          beq.s     jumpadr
bombenreset:
;          move.l    old47a.w,$047a.w ;_hdvboot
old436:   move.l    #"XNX!",$0436.w ;_memtop
old42e:   move.l    #"XNX!",$042e.w ;_phystop
          not.l     $060a.w        ;das "AMls" rauslîschen, damit der Loader nochmal geladen wird
;          not.l     $060c.w        ;das "ls" rauslîschen!!!!!!!!!!!
;          not.l     $0600+$0100-4.w ;Resetfestes Prg rauslîschen
;          not.l     unbenutztertrap.w
bombenreset2:
          movea.l   4.w,a0
          jmp       (a0)           ;und Reset
jumpadr:  jmp       $44444444      ;wird hier noch eingetragen!
;          DS.B 512-(jumpadr-cmptext)-8-2-4 ;-2 Magiclongs-PrÅfsummenkorrekturwort-jump.l
cmptextende2:
          IF cmptextende2-cmptext>256-2-4-4
          FAIL
          ENDC
;Ende der Routine, die nach $600 kopiert wird!
;*********
pexecroutystart:
;jetzt ist der Prozessor im SUPERVISORMODUS!
          lea       superstackbereich(pc),sp
          clr.l     -(sp)
          move.w    #$20,-(sp)
          trap      #1             ;aus dem Supervisormodus rausgehen
;          addq.l    #6,sp
again1:
          lea       userstackbereich(pc),sp
          lea       laufwerksmotoroff(pc),a0 ;Laufwerksmotor abschalten
          bsr       super

          lea       varload(pc),a0 ;Variablenurzustand wieder herstellen
          bsr       super

          lea       bombenabfangrouty512(pc),a0
          lea       menuinstalliertflag(pc),a1
          tst.b     (a1)           ;0=nicht installieren,<>0=installieren
          beq.s     bombenabfangrouty512lea
          lea       bombenabfangrouty(pc),a0 ;die Bombenabfangroutine fÅr 1MB und mehr
bombenabfangrouty512lea:
          bsr       super

          move.l    #-1,-(sp)      ;LÑnge des grîûten freien Speicherblocks holen
          move.w    #$48,-(sp)
          trap      #1
          addq.l    #6,sp
          subi.l    #8*1024,d0     ;die empfohlenen 8KB abziehen

          move.l    d0,-(sp)       ;allen Speicher-8 Kb reservieren
          move.w    #$48,-(sp)
          trap      #1
          addq.l    #6,sp
          tst.l     d0
          beq       fehler
          lea       blockadresse(pc),a0
          move.l    d0,(a0)        ;blockadresse
          movea.l   d0,a3

          lea       menuinstalliertflag(pc),a0
          tst.b     (a0)
          beq.s     menunachladen
          lea       pexecroutyend(pc),a2
          lea       (a2),a1
          adda.l    dateicopylÑnge(pc),a1
copyprgrunter:
          move.w    (a2)+,(a3)+
          cmpa.l    a1,a2
          blt.s     copyprgrunter
          bra.s     nachmenunachladen
menunachladen:
          lea       menuname(pc),a0
          movea.l   blockadresse(pc),a6
          bsr       load           ;Parameter: a0.l/a6.l
          tst.b     d7
          beq.s     notraus1
          lea       fehlerrouty(pc),a0
          bsr       super
          bsr       selectagainnewdrive
          bra.s     menunachladen
notraus1:
nachmenunachladen:
          lea       pleasewait(pc),a0
          bsr       print
          movea.l   blockadresse(pc),a0
          bsr       ice_decrunch_2
          movea.l   blockadresse(pc),a3
          bsr       relo           ;Parameter: a3.l

          clr.l     -(sp)
          move.w    #$20,-(sp)     ;wieder in den Supervisormode
          trap      #1
          lea       superstackbereich(pc),sp
;          addq.l    #6,sp
;          lea       oldstackpointer(pc),a0
;          move.l    d0,(a0)        ;oldstackpointer ;alter Stackpointer

          movem.l   scrolltextstartadr(pc),d0-a6 ;Restaurieren aller Register
;          move.l    scrolltextstartadr2(pc),d1
;in:
;d0.l: relativer Scrolltextzeiger

;Umgehen eines Betriebssystemfehlers, der dazu fÅhrt, daû die Bildschirmadresse
;durch das XBIOS ab und zu nicht korrekt gesetzt wurde:
          clr.l     $045e.w

          movea.l   blockadresse(pc),a0
          jsr       (a0)

;out:
;d0.l: relativer Scrolltextzeiger
;d0.l= $DEADFACE, dann wird das Loadingsystem destalliert!
;a0.l: Zeiger auf Filename
;und alle anderen Register kînnen auch "out" geben!

          lea       scrolltextstartadr(pc),a1
;Wir retten nun alle Register, damit auch noch mehr Scrolltextzeiger oder
;sonstwas Åbergeben werden kînnen:
          movem.l   d0-a6,(a1)     ;scrolltextstartadr
;          lea       scrolltextstartadr2(pc),a1
;          move.l    d2,(a1)        ;scrolltextstartadr
          cmp.l     #$deadface,d0  ;abtesten, ob das gesamte Intro beendet werden soll
          beq       beendeloader
          lea       filename(pc),a1
          move.b    drive(pc),(a1)+ ;Defaultdrive, oder eingestelltes
          move.b    #":",(a1)+
          move.b    #"\",(a1)+
holefilenameagain1:move.b (a0)+,(a1)+
          bne.s     holefilenameagain1
          lea       cls(pc),a0
          bsr       print
;          move.l    oldstackpointer(pc),-(sp)
          clr.l     -(sp)
          move.w    #$20,-(sp)     ;und wieder raus aus dem Supervisormode
          trap      #1
;          addq.l    #6,sp
          lea       userstackbereich(pc),sp

menuloaderror:
          move.l    blockadresse(pc),-(sp)
          move.w    #$49,-(sp)     ;Release Memory
          trap      #1             ;benutzten Speicher wieder freigeben
          addq.l    #6,sp

          pea       0.w            ;envptr
          pea       0.w            ;cmdline
          pea       filename(pc)
          move.w    #3,-(sp)       ;nur laden und relozieren
          move.w    #$4b,-(sp)     ;Pexec
          trap      #1
          lea       $10(sp),sp
          tst.l     d0
          bpl.s     nofehler
          pea       fehlerrouty(pc)
          move.w    #$26,-(sp)
          trap      #14
          addq.l    #6,sp
;neues Laufwerk selektieren:
          bsr       selectagainnewdrive
          bra.s     nacherror1
nofehler:
          lea       basepage(pc),a0
          move.l    d0,(a0)        ;basepage

          pea       0.w            ;envptr
          move.l    d0,-(sp)
          pea       filename(pc)
          move.w    #4,-(sp)       ;nur anspringen
          move.w    #$4b,-(sp)     ;Pexec
          trap      #1
          lea       $10(sp),sp
          move.l    basepage(pc),-(sp)
          move.w    #$49,-(sp)     ;Release Memory
          trap      #1
          addq.l    #6,sp
          tst.w     d0
          bpl.s     nacherror1
fehler:
          pea       fehlerrouty(pc)
          move.w    #$26,-(sp)
          trap      #14
          addq.l    #6,sp
nacherror1:
          bra       again1
beendeloader:
          ori       #$0700,sr
old8200:  move.l    #"XNX!",$ffff8200.w
          lea       _600rettbereich(pc),a0
          lea       $0600.w,a1
          moveq     #512/4-1,d0
rettzurÅck600:move.l (a0)+,(a1)+
          dbra      d0,rettzurÅck600

          lea       _8rettbereich(pc),a0
          lea       $08.w,a1
          moveq     #(512-8)/4-1,d0
rettzurÅck8:move.l  (a0)+,(a1)+
          dbra      d0,rettzurÅck8
          move.l    #$deadface,unbenutztertrap.w
;nur Warmstart:
          move.l    #$752019f3,$0420.w ;memvalid1
          move.l    #$237698aa,$043a.w ;memval2
          movea.l   4.w,a0
          jmp       (a0)           ;und noch 'nen Reset
;          move      #$2300,sr      ;Muû im Supervisormodus bleiben!
;          rts
filename: DS.B 258
menuname: DC.B "A:\MENU.DAT",0
pleasewait:DC.B "E    ANIMAL MINE loading system v0.2b",13,10,0
menuinstalliertflag:DS.B 1
          EVEN
scrolltextstartadr:DS.L 15         ;Platz fÅr 15 Register
dateicopylÑnge:DS.L 1
basepage: DS.L 1
oldcols:  DS.L 8
blockadresse:DS.L 1
;rausstackrett:DS.L 40
soundchipregbereich:DS.B 16
_600rettbereich:
          DS.L 500
superstackbereich:
_8rettbereich:
          DS.L 500
userstackbereich:
          ENDPART
          >PART 'selectagainnewdrive'
selectagainnewdrive:
          lea       selecttext(pc),a0
          bsr       print
          lea       drive(pc),a0
          bsr       print
          move.w    #7,-(sp)       ;Zeichen einlesen mit Echo
          trap      #1
          addq.l    #2,sp
          lea       drive(pc),a0
          cmp.b     #"+",d0
          bne.s     drivekleiner
          cmpi.b    #"P",(a0)
          bge.s     selectagainnewdrive
          addq.b    #1,(a0)
          bra.s     selectagainnewdrive
drivekleiner:cmp.b  #"-",d0
          bne.s     return
          cmpi.b    #"A",(a0)
          bls.s     selectagainnewdrive
          subq.b    #1,(a0)
          bra.s     selectagainnewdrive
return:   cmp.b     #13,d0
          bne.s     selectagainnewdrive
and31:
;          move.b    d0,(a0)
          move.b    drive(pc),d0
          lea       menuname(pc),a0
          move.b    d0,(a0)        ;damit das Menu auch vom richtigen Laufwerk geladen wird
          and.w     #%11111,d0
          add.w     d0,d0
          move.w    drivetab(pc,d0.w),-(sp) ;neues Defaultdrive
          move.w    #$0e,-(sp)
          trap      #1
          addq.l    #4,sp
          lea       cls(pc),a0
          bsr.s     print
          rts                      ;bra       nacherror1
drivetab: DC.W %1,%10,%100,%1000,%10000,%100000 ;Bit 0="A",Bit 1="B" etc.
          DC.W %1000000,%10000000,%100000000,%1000000000,%10000000000,%100000000000
          DC.W %1000000000000,%10000000000000,%100000000000000,%1000000000000000
drive:    DC.B "A",0               ;Defaultdrive
selecttext:DC.B "ESelect default drive(+/-/return): ",0
cls:      DC.B "E",0
          EVEN
          ENDPART
          >PART 'print'
print:    pea       (a0)
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp
          rts
          ENDPART
          >PART 'ice_decrunch'
;********************************************* Unpacking routine of PACK-ICE
; a0 = Adress of packed data
; "bsr" or "jsr" to ice_decrunch_2 with register a0 prepared.
ice_decrunch_2:
          link      a3,#-120
          movem.l   d0-a6,-(sp)
          lea       120(a0),a4
          movea.l   a4,a6
          bsr.s     .getinfo
          cmpi.l    #'ICE!',d0
          bne.s     .not_packed
          bsr.s     .getinfo
          lea       -8(a0,d0.l),a5
          bsr.s     .getinfo
          move.l    d0,(sp)
          adda.l    d0,a6
          movea.l   a6,a1

          moveq     #119,d0
.save:    move.b    -(a1),-(a3)
          dbra      d0,.save
          movea.l   a6,a3
          move.b    -(a5),d7
          bsr.s     .normal_bytes
          movea.l   a3,a5


          bsr       .get_1_bit
          bcc.s     .no_picture
          move.w    #$0f9f,d7
          bsr       .get_1_bit
          bcc.s     .ice_00
          moveq     #15,d0
          bsr       .get_d0_bits
          move.w    d1,d7
.ice_00:  moveq     #3,d6
.ice_01:  move.w    -(a3),d4
          moveq     #3,d5
.ice_02:  add.w     d4,d4
          addx.w    d0,d0
          add.w     d4,d4
          addx.w    d1,d1
          add.w     d4,d4
          addx.w    d2,d2
          add.w     d4,d4
          addx.w    d3,d3
          dbra      d5,.ice_02
          dbra      d6,.ice_01
          movem.w   d0-d3,(a3)
          dbra      d7,.ice_00
.no_picture:
          movem.l   (sp),d0-a3

.move:    move.b    (a4)+,(a0)+
          subq.l    #1,d0
          bne.s     .move
          moveq     #119,d0
.rest:    move.b    -(a3),-(a5)
          dbra      d0,.rest
.not_packed:
          movem.l   (sp)+,d0-a6
          unlk      a3
          rts

.getinfo: moveq     #3,d1
.getbytes:lsl.l     #8,d0
          move.b    (a0)+,d0
          dbra      d1,.getbytes
          rts

.normal_bytes:
          bsr.s     .get_1_bit
          bcc.s     .test_if_end
          moveq     #0,d1
          bsr.s     .get_1_bit
          bcc.s     .copy_direkt
          lea       .direkt_tab+20(pc),a1
          moveq     #4,d3
.nextgb:  move.l    -(a1),d0
          bsr.s     .get_d0_bits
          swap      d0
          cmp.w     d0,d1
          dbne      d3,.nextgb
.no_more: add.l     20(a1),d1
.copy_direkt:
          move.b    -(a5),-(a6)
          dbra      d1,.copy_direkt
.test_if_end:
          cmpa.l    a4,a6
          bgt.s     .strings
          rts

.get_1_bit:
          add.b     d7,d7
          bne.s     .bitfound
          move.b    -(a5),d7
          addx.b    d7,d7
.bitfound:
          rts

.get_d0_bits:
          moveq     #0,d1
.hole_bit_loop:
          add.b     d7,d7
          bne.s     .on_d0
          move.b    -(a5),d7
          addx.b    d7,d7
.on_d0:   addx.w    d1,d1
          dbra      d0,.hole_bit_loop
          rts


.strings: lea       .length_tab(pc),a1
          moveq     #3,d2
.get_length_bit:
          bsr.s     .get_1_bit
          dbcc      d2,.get_length_bit
.no_length_bit:
          moveq     #0,d4
          moveq     #0,d1
          move.b    1(a1,d2.w),d0
          ext.w     d0
          bmi.s     .no_Åber
.get_Åber:
          bsr.s     .get_d0_bits
.no_Åber: move.b    6(a1,d2.w),d4
          add.w     d1,d4
          beq.s     .get_offset_2


          lea       .more_offset(pc),a1
          moveq     #1,d2
.getoffs: bsr.s     .get_1_bit
          dbcc      d2,.getoffs
          moveq     #0,d1
          move.b    1(a1,d2.w),d0
          ext.w     d0
          bsr.s     .get_d0_bits
          add.w     d2,d2
          add.w     6(a1,d2.w),d1
          bpl.s     .depack_bytes
          sub.w     d4,d1
          bra.s     .depack_bytes


.get_offset_2:
          moveq     #0,d1
          moveq     #5,d0
          moveq     #-1,d2
          bsr.s     .get_1_bit
          bcc.s     .less_40
          moveq     #8,d0
          moveq     #$3f,d2
.less_40: bsr.s     .get_d0_bits
          add.w     d2,d1

.depack_bytes:
          lea       2(a6,d4.w),a1
          adda.w    d1,a1
          move.b    -(a1),-(a6)
.dep_b:   move.b    -(a1),-(a6)
          dbra      d4,.dep_b
          bra       .normal_bytes


.direkt_tab:
          DC.L $7fff000e,$ff0007,$070002,$030001,$030001
          DC.L 270-1,15-1,8-1,5-1,2-1

.length_tab:
          DC.B 9,1,0,-1,-1
          DC.B 8,4,2,1,0

.more_offset:
          DC.B 11,4,7,0            ; Bits lesen
          DC.W $011f,-1,$1f        ; Standard Offset

ende_ice_decrunch_2:
;************************************************** end of unpacking routine

          ENDPART
          >PART 'super'
super:    pea       (a0)
          move.w    #$26,-(sp)
          trap      #14
          addq.l    #6,sp
          rts
          ENDPART
          >PART 'fehlerrouty'
fehlerrouty:
          move.w    $ffff8240.w,-(sp)
          move.w    #$0700,$ffff8240.w
          moveq     #-1,d0
nop0:     moveq     #10-1,d1
dbrad1:   dbra      d1,dbrad1
          dbra      d0,nop0
          move.w    (sp)+,$ffff8240.w
          rts
          ENDPART
          >PART 'load'
load:
;in:
;a0.l: Zeiger auf Namen
;a6.l: Zeiger auf Buffer
;out:
;d7.b: 0=kein Fehler; -1=Fehler
          moveq     #0,d7
          clr.w     -(sp)
          pea       (a0)
          move.w    #$3d,-(sp)     ;Fopen
          trap      #1
          addq.l    #8,sp
          tst.w     d0
          smi       d7
          bmi.s     rausload
          move.w    d0,d6

          pea       (a6)
          move.l    #2000000,-(sp)
          move.w    d0,-(sp)
          move.w    #$3f,-(sp)
          trap      #1
          lea       $0c(sp),sp
          tst.l     d0
          smi       d7
          bmi.s     rausload
          move.l    d0,d6

          move.w    d6,-(sp)
          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp
rausload:
          rts
          ENDPART
          >PART 'relo'
;in:
;a3: Zeiger auf PRG ($601a...)
relo:     movea.l   2(a3),a0
          adda.l    6(a3),a0
          move.l    10(a3),d2
          lea       28(a0,a3.l),a1
          adda.l    14(a3),a0
          lea       28(a0,a3.l),a0
          lea       28(a3),a3
          move.l    a3,d0
          tst.l     (a0)
          beq.s     L012F
          adda.l    (a0)+,a3
          moveq     #0,d1
L012C:    add.l     d0,(a3)
L012D:    move.b    (a0)+,d1
          beq.s     L012F
          cmpi.b    #1,d1
          bne.s     L012E
          lea       254(a3),a3
          bra.s     L012D
L012E:    adda.l    d1,a3
          bra.s     L012C
L012F:    addq.l    #3,d2
          lsr.l     #2,d2
          moveq     #0,d0
L0130:    move.l    d0,(a1)+
          subq.l    #1,d2
          bgt.s     L0130
          rts
          ENDPART
          >PART 'laufwerksmotoroff'
laufwerksmotoroff:
          move.w    $ffff8604.w,d0
          btst      #7,d0
          bne.s     laufwerksmotoroff
;          tst.b     d0
;          bmi.s     intende
;          move.b    #14,$ffff8800.w
;          moveq     #7,d1
;          or.b      $ffff8800.w,d1
;          move.b    d1,$ffff8802.w
;          bra.s     laufwerksmotoroff
intende:
;          bclr      #6,$fffffa0f.w
          rts
          ENDPART
          >PART 'bombenabfangrouty'
bombenabfangrouty:
          lea       bombenreset-cmptext+$0600+8.w,a0
bombenabfangrouty2:
          move.l    a0,8.w
          move.l    a0,$0c.w
          move.l    a0,$10.w
          move.l    a0,$18.w
          move.l    a0,$1c.w
          move.l    a0,$20.w
          lea       $30.w,a1
          moveq     #13-1,d0
bomb0:    move.l    a0,(a1)+
          dbra      d0,bomb0
          move.l    a0,$80.w
          lea       $8c.w,a1
          moveq     #9-1,d0
bomb2:    move.l    a0,(a1)+
          dbra      d0,bomb2
          lea       $c0.w,a1
          moveq     #16-1,d0
bomb3:    move.l    a0,(a1)+
          dbra      d0,bomb3
          rts
bombenabfangrouty512:
          lea       bombenreset2(pc),a0
          bra.s     bombenabfangrouty2
          ENDPART
          >PART 'varsave/varload'
varsave:
          move      sr,-(sp)
          move      #$2700,sr
          move.l    $0436.w,old436+2 ;_memtop
          move.l    $042e.w,old42e+2 ;_phystop
;          move.l    $047a.w,old47a.w ;_hdvboot
          move.l    $ffff8200.w,old8200+2
          move.l    $ffff8200.w,old82002+2
          move.b    $ffff820a.w,oldsync+3
          move.b    $ffff8260.w,oldres+3
;          move.b    $fffffa07.w,old07+3
;          move.b    $fffffa09.w,old09+3
;          move.b    $fffffa0b.w,old0b+3
;          move.b    $fffffa0d.w,old0d+3
;          move.b    $fffffa0f.w,old0f+3
;          move.b    $fffffa11.w,old11+3
;          move.b    $fffffa13.w,old13+3
;          move.b    $fffffa15.w,old15+3
;          move.b    $fffffa17.w,old17+3
;          move.b    $fffffa19.w,old19+3
;          move.b    $fffffa1b.w,old1b+3
;          move.b    $fffffa1d.w,old1d+3
          move.b    $fffffa1f.w,old1f+3
          move.b    $fffffa21.w,old21+3
          move.b    $fffffa25.w,old25+3
          movem.l   $ffff8240.w,d0-d7
          movem.l   d0-d7,oldcols

          lea       a0dat(pc),a0
          lea       a2dat(pc),a2
          moveq     #21-1,d0
d0dbra2:  movea.w   (a2)+,a1
          move.b    (a1),(a0)+
          dbra      d0,d0dbra2
          move.b    #3,$fffffc00.w ;ACIA-Reset
          lea       $0600.w,a0
          lea       _600rettbereich(pc),a1
          moveq     #512/4-1,d0
rettebereich600:
          move.l    (a0)+,(a1)+
          dbra      d0,rettebereich600

          lea       $08.w,a0
          lea       _8rettbereich(pc),a1
          moveq     #(512-8)/4-1,d0
rettebereich8:
          move.l    (a0)+,(a1)+
          dbra      d0,rettebereich8
          lea       $ffff8800.w,a0
          lea       soundchipregbereich(pc),a1
          moveq     #16-1,d0
soundchipregisterrett:
          move.b    d0,(a0)
          move.b    2(a0),(a1)+
          dbra      d0,soundchipregisterrett
;          lea       soundchipregisterrett+6(pc),a0 ;+6, weil rÅckwÑrts!
;          clr.b     (a0)+          ;LautstÑrkeregister auf 0
;          clr.b     (a0)+
;          clr.b     (a0)+
          move.b    #$96,$fffffc00.w ;AS-Overscan aus und ACIA-reinitialisieren
          move      (sp)+,sr
          rts
;*********
varload:
          move      #$2700,sr
oldsync:  move.b    #2,$ffff820a.w
old82002: move.l    #'SETH',$ffff8200.w
;old07:    move.b    #'O',$fffffa07.w
;old09:    move.b    #'S',$fffffa09.w
;old0b:    move.b    #' ',$fffffa0b.w
;old0d:    move.b    #'O',$fffffa0d.w
;old0f:    move.b    #'F',$fffffa0f.w
;old11:    move.b    #' ',$fffffa11.w
;old13:    move.b    #'A',$fffffa13.w
;old15:    move.b    #'N',$fffffa15.w
;old17:    move.b    #'I',$fffffa17.w
;old19:    move.b    #'M',$fffffa19.w
;old1b:    move.b    #'A',$fffffa1b.w
;old1d:    move.b    #'L',$fffffa1d.w
old1f:    move.b    #'O',$fffffa1f.w
old21:    move.b    #'S',$fffffa21.w
old25:    move.b    #'!',$fffffa25.w

          lea       $ffff8800.w,a0
          lea       soundchipregbereich(pc),a1
          moveq     #16-1,d0
soundchipregisterrettz:
          move.b    d0,(a0)
          move.b    (a1)+,2(a0)
          dbra      d0,soundchipregisterrettz

          lea       a0dat(pc),a0
          lea       a2dat(pc),a2
          moveq     #$14,d0
d0dbra1:  movea.w   (a2)+,a1
          move.b    (a0)+,(a1)
          dbra      d0,d0dbra1
          move.b    #3,$fffffc00.w
;          not.w     $ffff8240.w
;          move.w    #65535,d0
;nop:      nop
;          nop
;          dbra      d0,nop
;          not.w     $ffff8240.w
          move.b    #$96,$fffffc00.w
          move.b    #3,$fffffc04.w
          move.b    #$95,$fffffc04.w

          movem.l   oldcols(pc),d0-d7
          movem.l   d0-d7,$ffff8240.w
;die gesamten Systemvariablen zurÅckschreiben:
          lea       $08.w,a0
          lea       _8rettbereich(pc),a1
          moveq     #(512-8)/4-1,d0
rettebereich8zurÅck:
          move.l    (a1)+,(a0)+
          dbra      d0,rettebereich8zurÅck

oldres:   move.b    #'N',$ffff8260.w

;          move.l    #again,$042a.w ;resvector
;          move.l    #$31415926,$0426.w ;resvalid
          lea       $ffff8800.w,a0
          move.l    #$08000000,(a0) ;LautstÑrkeregister lîschen
          move.l    #$09000000,(a0)
          move.l    #$0a000000,(a0)
          move      #$2300,sr
          rts
a0dat:
          DC.B 9,$ff,4,0,$1e,$64,0,$20
          DC.B 0,0,$1e,$64,$48,0,0,$51
          DC.B 0,$88,1,$81,$ff
          EVEN
a2dat:    DC.W $8001,$fa01,$fa03,$fa05
          DC.W $fa07,$fa09,$fa0b,$fa0d
          DC.W $fa0f,$fa11,$fa13,$fa15
          DC.W $fa17,$fa19,$fa1b,$fa1d
          DC.W $fa27,$fa29,$fa2b,$fa2d
          DC.W $fa2f
          ENDPART
pexecroutyend:
          >PART ' destallbiospatch'
destallbiospatch:
          movea.l   trap13.w,a0
          cmpi.l    #"XBRA",-12(a0)
          bne.s     noXBRA
          cmpi.l    #"AM13",-8(a0)
          bne.s     noXBRA
;Der BIOSpatch ist jetzt noch installiert:
          move.l    -4(a0),trap13.w ;destallieren des BIOSpatches!
noXBRA:
          rts
          ENDPART
          >PART 'installtest'
installtest:
          cmpi.l    #$deadface,unbenutztertrap.w ;wenn das Loading-system schon installiert ist!
          seq       sofortendeflag

          movea.l   $042e.w,a0     ;_phystop
          moveq     #0,d0          ;als installflag
          cmpa.l    #$080000,a0
          ble.s     notinstalled   ;bei 512K-Rechnern das MenÅ NICHT installieren!
          moveq     #-1,d0         ;sonst darf das Menu installiert werden

;          lea       $0600.w,a0     ;hier muû die resetfeste Seite stehen!
;          movea.l   a0,a3
;          cmpi.l    #$12123456,(a0)+
;          bne.s     notinstalled
;          move.l    a3,d1
;          cmp.l     (a0)+,d1       ;Zeiger auf Speicherseite abtesten
;          bne.s     notinstalled

;          lea       cmptext(pc),a1
;          moveq     #cmptextende-cmptext-1,d0
;cmpagain: cmpm.b    (a0)+,(a1)+
;          dbne      d0,cmpagain
;          addq.b    #1,d0
notinstalled:
          move.b    d0,menuinstalliertflag ;0=nicht installieren,<>0=installieren
          rts
          ENDPART
;*********
          DATA
          BSS
sofortendeflag:DS.B 1
          EVEN
own_basepage:DS.L 1
          DS.L 200
own_stack:
ende:
buffer:   DS.W 200000/2
          END
