;*********************************************
;                Q-DISK V 1.3                *
;*********************************************
; Programm sorgt dafr, daá Diskettenwechsel *
; im Desktop erkannt werden, sofern die Disk *
; nicht schreibgeschtzt ist.                *
;*********************************************
; by Martin Glodde  (c) 1992 MAXON Computer  *
;*********************************************
; Offsets fr Texte
info           equ 0      ;Titelinformation
err            equ 4      ;Text bei Installierungsfehler
taste          equ 8      ;'Bitte Taste drcken'
installed      equ 12     ;'Schon installiert'
; Offsets fr Variablen
nflops         equ 0      ;Anz. der Floppies
defdrv         equ 2      ;Standardlaufwerk
keyparam       equ 4      ;Tastaturpuffer-Parameterblock
WP             equ 8      ;Schreibschutz-Flags
nprgs          equ 10     ;Anz. gestarteter Programme
akt            equ 12     ;Flags zur Aktualisierung der Directories
save_area      equ 14     ;Zeiger auf Bereich zur Registerrettung bei TRAP #1
autostart      equ 18     ;Flag: Ist aus Autoordner gestartet worden ?
stk_offs       equ 20     ;wo liegen Params bei TRAP#1? (abh. vom Prozessor)
;
prg:
      movea.l    4(sp),a5      ;Zeiger auf Basepage
      move.l     $c(a5),d0     ;L„nge des Textsegments
      add.l      $14(a5),d0    ;+ L„nge des DATA-Segments
      add.l      $1c(a5),d0    ;+ L„nge des BSS-Segments
      addi.l     #$1100,d0     ;+ L„nge der Basepage + 1K fr Stack & Savearea
      move.l     d0,d1
      add.l      a5,d1
      andi.l     #-2,d1        ;Adresse des Stacks berechnen, runden ...
      movea.l    d1,sp         ;... und setzen
      lea.l      varfeld(pc),a5          ;Zeiger auf Variablenfeld
      move.l     sp,save_area(a5)        ;Stackbereich dient sp„ter als Save Area
;
      clr.w      -(sp)         ;kein Fehler
      move.l     d0,-(sp)      ;Bedarf (fr Ptermres)
      move.w     #$31,-(sp)    ;Ptermres()
;
      .DC.w $a00a              ;Maus ausschalten
      lea.l      texte(pc),a6  ;Texttabelle
      move.l     info(a6),-(sp)          ;1. Text ausgeben
      move.w     #9,-(sp)      ;Cconws()
      trap       #1            ;GEMDOS
      addq.l     #6,sp
;
      clr.l      -(sp)         ;Supervisor ein
      move.w     #32,-(sp)     ;Super()
      trap       #1            ;GEMDOS
      addq.l     #6,sp
      move.l     d0,-(sp)      ;alten Wert merken
;
      bsr        get_mc_type   ;Prozessortyp holen
;    (ab MC 68010 gibt's bei Exceptions mind. einen Parameter mehr)
      move.w     $4a6,d0       ;merken, wieviele Floppies existieren
      subq.w     #1,d0
      move.w     d0,nflops(a5)
      move.w     #25,-(sp)     ;Dgetdrv()
      trap       #1            ;GEMDOS
      addq.l     #2,sp
      move.w     d0,defdrv(a5) ;Default-Drive merken
      bsr        get_wp        ;Feststellen, ob Disk in A: oder B: schreibgeschtzt ist
;
      move.w     #1,-(sp)      ;Tastaturpuffer-Parameterblock
      move.w     #14,-(sp)     ;Iorec()
      trap       #14           ;XBIOS
      addq.l     #4,sp
      move.l     d0,keyparam(a5)         ;Zeiger auf Parameterblock merken
;
      lea.l      newtrap(pc),a3          ;neuer TRAP #1-Vektor
      move.l     $84,-4(a3)    ;alten Vektor in XBRA-Struktur eintragen
      move.l     a3,$84        ;neuen Vektor setzen
;
      movea.l    $456,a1       ;VBL-Queue
      move.w     $454,d6       ;_nvbls
      subq.w     #2,d6         ;-1 wg. dbra; -1 wg. reserviertem 1. Eintrag
      tst.l      0(a1)         ;Ist 1.Slot noch frei ?
      seq        autostart(a5) ;dann wurde aus AUTO-Ordner aufgerufen !
      moveq.l    #0,d1
vbl_lp:
      tst.l      4(a1,d1.w)    ;nach freiem Eintrag suchen
      beq.s      gefunden
      movea.l    4(a1,d1.w),a0
      cmpi.w     #$4d47,-2(a0) ;eigene Kennung (d.h. schon installiert ?)
      beq.s      schon_inst    ;ja, Abbruch
      addq.w     #4,d1         ;n„chster Slot
      dbra       d6,vbl_lp
;
;Fehler bei Installierung:
      movea.l    err(a6),a4    ;Fehlertext
      bra.s      w2
schon_inst:
      movea.l    installed(a6),a4        ;sonst anderen Text nehmen
w2:
      move.l     -4(a3),$84    ;alten TRAP #1-Vektor wieder herstellen
      move.w     #32,-(sp)     ;Super()
      trap       #1            ;GEMDOS (zurck in Usermodus)
      lea.l      $e(sp),sp     ;Stack aufr„umen: 6 fr GEMDOS #32, 8 fr
;                       nicht ben”tigte Parameter fr Ptermres()
      move.w     #-1,-(sp)     ;Prg.-Ende vorbereiten: Rckgabewert = Fehler!
      move.w     #76,-(sp)     ;Pterm()
;
      move.l     a4,-(sp)
      move.w     #9,-(sp)      ;Fehlermeldung ausgeben
      trap       #1
      addq.l     #6,sp
      bra.s      ok
;
gefunden:
      move.l     #vblrout,4(a1,d1.w)     ;sonst VBL-Routine installieren
      move.w     #32,-(sp)
      trap       #1            ;wie oben zurck in den Usermodus
      addq.l     #6,sp         ;aber Ptermres() lassen
;
ok:
      tst.w      autostart(a5)
      bne.s      auto          ;bei Aufruf aus Autoordner nicht auf Taste warten
      move.l     taste(a6),-(sp)         ;'Bitte Taste drcken' ausgeben
      move.w     #9,-(sp)      ;Cconws()
      trap       #1            ;GEMDOS
      addq.l     #6,sp
      move.w     #7,-(sp)      ;Crawcin()
      trap       #1            ;GEMDOS
      addq.l     #2,sp
      bra.s      ende
auto:
      subq.w     #1,nprgs(a5)  ;weil bei AUTO-Start noch das Desktop initiali-
;siert (= mit Pexec() gestartet) wird ...
ende:
      trap       #1            ;Programmende (bei Fehler durch Pterm(),
;sonst durch Ptermres() )
;
get_mc_type:
; Prozessortyp ermitteln (wichtig fr Stack-Aufbau beim TRAP #1)
      move.l     $5a0,d0       ;Zeiger auf Cookies
      beq.s      _68000        ;keiner da => altes TOS => MC 68000
      movea.l    d0,a0
search_lp:
      move.l     (a0)+,d1
      beq.s      _68000        ;keine Kennung => altes TOS (s.o.)
      cmpi.l     #'_CPU',d1    ;nach CPU-Cookie suchen
      beq.s      found
      addq.l     #4,a0         ;n„chsten Eintrag
      bra.s      search_lp
found:
      tst.l      (a0)          ;Welcher Prozessor ?
      beq.s      _68000        ;0=MC 68000, 10=MC 68010, ...
      move.w     #2,stk_offs(a5)         ;ggf. Stack-Offset erh”hen
_68000:
      rts
;
get_wp:
      tst.w      $43e          ;Zugriff erlaubt ?
      bne.s      get_wp        ;nein, warten
      moveq.l    #4,d0         ;Floppy A:
      lea.l      WP(a5),a4     ;WP-Statustabelle
      lea.l      $ffff8800,a3  ;(a3) -> Soundchip; 2(a3) -> PSG-Data (W)
      move.w     nflops(a5),d3
flop_lp:
      move.w     #$80,$ffff8606          ;FDC-Statusregister
      move.w     sr,-(sp)
      ori.w      #$700,sr      ;Interrupts sperren
      move.b     #$e,(a3)      ;PSG Port A selektieren
      move.b     (a3),d1       ;alten Wert merken
      move.b     d1,d4
      andi.b     #$f8,d1       ;die unteren 3 Bits
      or.b       d0,d1         ;d0=4 -> A: ; d0=2 -> B: (Seite egal)
      move.b     d1,2(a3)      ;in Port A schreiben
      move.w     $ffff8604,d2  ;FDC-Status nach d2
      move.b     (a3),d1
      andi.b     #$f8,d1
      btst       #7,d2         ;Floppy MOTOR ON ?
      bne.s      motor
      ori.b      #6,d1         ;beide Floppies deselektieren
      bra.s      set
motor:
      or.b       d4,d1         ;Bei MOTOR ON alten Status setzen
set:
      move.b     d1,2(a3)
      move.w     (sp)+,sr
      btst       #6,d2         ;Ist Floppy A: W.P. ?
      sne        (a4)+         ;Flag setzen
      subq.w     #2,d0         ;ggf. noch Floppy B:
      dbra       d3,flop_lp
      rts
;
      .DC.w $4d47
vblrout:
;um Registerrettung braucht man sich bei VBL-Routinen nicht zu
;kmmern, das macht schon das TOS !
      tst.w      $43e          ;Floppy-Zugriff erlaubt ?
      bne        exit          ;nein
      lea.l      varfeld(pc),a5          ;Zeiger auf Variablenfeld
      move.w     WP(a5),d5     ;alten WP-Status der Floppies merken
      bsr.s      get_wp        ;neuen Status ermitteln
      cmp.w      WP(a5),d5     ;hat sich was ver„ndert ?
      beq.s      weiter        ;nein!
      move.w     nflops(a5),d0 ;Anz. der angeschl. Floppies
      bne.s      testlp
      lsr.w      #8,d5         ;wenn nur Floppy A:, dann alten Wert verschieben
testlp:
      cmp.b      WP(a5,d0.w),d5          ;ist Floppy nicht mehr W.P. ? (alt=$FF,neu=$0)
      bpl.s      no_change     ;dann w„re das N-Flag gesetzt!
      st         akt(a5,d0.w)  ;Flag zur Aktualisierung
no_change:
      lsr.w      #8,d5         ;n„chste Floppy
      dbra       d0,testlp
;
weiter:
      tst.w      nprgs(a5)     ;im Moment Desktop ?
      bne.s      exit          ;nein: keine Aktualisierung
      move.w     defdrv(a5),d0 ;Default-Drive holen
      cmpi.w     #2,d0         ;Ist's auch keine Hard-/RAM-Disk ?
      bcc.s      exit          ;doch -> raus
      tst.b      akt(a5,d0.w)  ;Muá Inhaltsverzeichnis aktualisiert werden ?
      beq.s      exit          ;nein
      movea.l    keyparam(a5),a0         ;Zeiger auf Tastaturpuffer-Parameterblock
      move.w     8(a0),d1      ;n„chste Leseposition
      addq.w     #4,d1         ;Beim Rauchpilz-TOS durch "addq #2,d1" ersetzen
      cmp.w      4(a0),d1      ;L„nge berschritten ?
      bcs.s      erhoeh        ;nein
      moveq.l    #0,d1         ;sonst auf Pufferstart setzen
erhoeh:
      cmp.w      6(a0),d1      ;Schreibpos. = Lesepos. (=Puffer voll) ?
      beq.s      exit          ;ja
      movea.l    0(a0),a2      ;Zeiger auf Puffer
      move.l     #$1001b,0(a2,d1.w)      ;>ESC< (Scan- & ASCII-Code) in Puffer schr.
;Beim Rauchpilz-TOS durch "move #$11b,0(a2,d1.w)" ersetzen!
      move.w     d1,8(a0)      ;Zeiger korrigieren
      sf         akt(a5,d0.w)  ;Aktualisierungsflag l”schen
exit:
      rts
;
      .DC.l $58425241
      .DC.l $512d442e
old_trp:
      .DC.l 0
newtrap:
      movem.l    d1/d2/a0-a2,regs        ;Regs retten,
;  weil sich manche Programme darauf verlassen, daá sie unver„ndert bleiben
      lea.l      varfeld(pc),a1          ;Zeiger auf Variablenfeld
      move.w     stk_offs(a1),d0         ;Stack-Offset
      lea.l      6(sp,d0.w),a0 ;Parameterzeiger = Supervisor-Stack
      btst       #5,(sp)       ;Auf welchem Stack liegen die Param's ?
      bne.s      super_stack
      move.l     usp,a0        ;wenn Supervisor-Bit gel”scht ist, sind sie auf Userstack
super_stack:
      cmpi.w     #14,(a0)      ;Dsetdrv() ?
      beq.s      dsetdrv
      cmpi.w     #75,(a0)      ;Pexec() ?
      beq.s      pexec
normal:
      movem.l    regs,d1/d2/a0-a2        ;Reg. wieder herstellen (s.o.)
      move.l     old_trp,-(sp)
      rts                      ;normalen Trap aufrufen
;
dsetdrv:
      move.w     2(a0),defdrv(a1)        ;neues Defaultdrive merken
      tst.w      nflops(a1)    ;bei 2 phys. Laufwerken O.K.
      bne.s      normal
      cmpi.w     #1,2(a0)      ;bei 1 Floppy und neuem Def.Drv. B: ...
      bne.s      normal
      clr.w      defdrv(a1)    ;... dieses wie phys. Floppy A: behandeln
      bra.s      normal
;
pexec:
      tst.w      2(a0)         ;Exec-Modus = 'laden und starten' ?
      beq.s      prgstart      ;ja!
      cmpi.w     #4,2(a0)      ;Exec-Modus = 'starten' ?
      beq.s      prgstart      ;ja!
      cmpi.w     #6,2(a0)      ;Neuer Exec-Startmodus bei TOS 1.4 ?
      bne.s      normal        ;nein!
prgstart:
      movea.l    4(a0),a2      ;Zeiger auf Programmnamen holen
search0:
      cmpi.b     #46,(a2)      ;Punkt?
      beq.s      pktgef
      tst.b      (a2)+         ;String zu Ende
      bne.s      search0
      bra.s      aufruf
pktgef:
      addq.l     #1,a2
      move.b     (a2)+,d0      ;1. Zeichen
      andi.b     #$df,d0       ;Groábuchstabe
      cmpi.b     #65,d0        ;'A' ?
      bne.s      aufruf        ;nein!
      move.b     (a2)+,d0      ;2. Zeichen   (Wordzugriff nicht immer m”glich!)
      andi.b     #$df,d0       ;Groábuchstabe
      cmpi.b     #$43,d0       ;'C' ?
      bne.s      aufruf        ;nein
      move.b     (a2)+,d0      ;3. Zeichen
      andi.b     #$df,d0       ;Groábuchstabe
      cmpi.b     #$43,d0       ;'C' ?
      beq.s      normal        ;bei 'ACC' (=Accessory) normaler Prg.-Start
aufruf:
      addq.w     #1,nprgs(a1)  ;Anzahl der gestarteten Programme +1
      movea.l    save_area(a1),a2        ;save_area
      move.w     (sp)+,-(a2)   ;SR, ...
      move.l     (sp)+,-(a2)   ;... Rcksprungadresse
      tst.w      stk_offs(a1)  ;noch ein Parameter ?
      beq.s      mc_alt1       ;nein, alter Prozessor
      move.w     (sp)+,d0      ;sonst jenen merken
      move.w     d0,-(a2)      ;und retten
mc_alt1:
      movem.l    d3-d7/a3-a7,-(a2)       ;und Register retten
      move.l     a2,save_area(a1)        ;neue Save_area
      movea.l    a0,sp         ;Stack zeigt auf Parameterliste
      tst.w      stk_offs(a1)  ;ggf. noch weiteren Parameter ablegen
      beq.s      mc_alt2
      move.w     d0,-(sp)      ;auf Stack
mc_alt2:
      pea        ret           ;neue Rcksprungadr.
      move.w     sr,-(sp)      ;und akt. SR
      move.l     old_trp(pc),-(sp)
      rts                      ;alte TRAP-Routine aufrufen
ret:
      lea.l      varfeld(pc),a1
      clr.w      akt(a1)       ;bei Prg-Ende nicht 'ESC' simulieren *** !!! ***
      movea.l    save_area(a1),a2        ;save_area
      movem.l    (a2)+,d3-d7/a3-a7
      tst.w      stk_offs(a1)  ;ggf. auch hier zus. Parameter
      beq.s      mc_alt3
      move.w     (a2)+,-(sp)   ;wieder zurck
mc_alt3:
      move.l     (a2)+,-(sp)   ;Register,Rcksprungadr. und Statusreg.
      move.w     (a2)+,-(sp)
      move.l     a2,save_area(a1)        ;alte save_area
      subq.w     #1,nprgs(a1)  ;Anzahl der aufgerufenen Programme -1
      rte                      ;fertig
;
      .DATA
texte:
      .DC.l t1,t2,t3,t4
t1:
      .DC.b 27,"E",10,10,10,10,13,9
      .DC.b " Q - DISK  V 1.3 (Dezember '91)",10,13,9
      .DC.b " ------------------------------",10,10,13,9
      .DC.b "       von Martin Glodde.",10,10,10,13
      .DC.b "Das Programm erkennt Diskettenwechsel, wenn ...",10,13
      .DC.b "- ... die neue Disk nicht schreibgeschtzt ist.",10,13
      .DC.b "- ... man sich im Desktop befindet.",10,10,10,13,0
t2:
      .DC.b "ERROR: Kein Platz mehr in der VBL-Queue.",10,13
      .DC.b "Q-DISK ist nicht installiert.",10,10,10,13,0
t3:   .DC.b "Bitte Taste drcken!",0,0
t4:   .DC.b "Programm ist schon installiert!",10,10,10,13,0
;
      .BSS
varfeld:
      .DS.b 22
regs: .DS.l 5


