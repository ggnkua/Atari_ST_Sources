;*************************************************
;* Modulname      : ASSEM.S                      *
;* Autor          : Thomas Binder                *
;* Zweck          : EnthÑlt den Assemblerteil    *
;*                  von GAMEFIX, insbesondere    *
;*                  die Routinen mpack und set,  *
;*                  die die im Artikel beschrie- *
;*                  benen Manipulationen zeigen  *
;* Compiler       : Pure Assembler 03.02.1992    *
;* Erstellt am    : 12.08.1993                   *
;* Letzte énderung: 03.09.1993                   *
;*************************************************

    export  _gemdos,mpack,reset,ramsize
    export  settings,get_settings,gdrout,set
    export  ramsizes,new_pmmu_tree,mtype
    export  rootpointer,checksum,get_ram
    export  mtype

    ; Benîtigte Systemvariablen und Hardware-
    ; Register
    equ     trap_1,$84
    equ     memvalid,$420
    equ     memcntrl,$424
    equ     resvalid,$426
    equ     phystop,$42e
    equ     _memtop,$436
    equ     _bootdev,$446
    equ     sshiftmd,$44c
    equ     _v_bas_ad,$44e
    equ     _dskbufp,$4c6
    equ     _sysbase,$4f2
    equ     _longframe,$59e
    equ		memconf,$ffff8001
    
    ; Indizes fÅr das Settings-Feld
    equ     datacache,0
    equ     instcache,2
    equ     blit8mhz,4
    equ     cpu8mhz,6
    equ     busmode,8
    equ     timera,10
    equ     mfpi7,12
    equ     speaker,14
    equ     scrbase,16
    equ     volume,18
    equ     ramconfig,20
    
    text

    ; Resetroutine fÅr das Booten
    ; Setzt die gewÅnschte Ramgrîûe und fÅhrt
    ; einen Reset aus
MODULE reset
    lea     settings,a0
    ; Zur Ramgrîûe gehîrigen Wert nach
    ; memcntrl und memconf schreiben
    move.w  ramconfig(a0),d0
    lea     ramcntrls,a0
    move.b  (a0,d0.w),memcntrl.w
    move.b  (a0,d0.w),memconf.w
    lea     ramsizes,a0
    move.l  (a0,d0.w*4),phystop.w
    ; eventuelle andere Resetroutinen ausklinken
    clr.l   resvalid.w
    ; und ab zum Reset
    move.l  _sysbase.w,a0
    jmp     (a0)

    ; Werte fÅr memcntrl und memconf fÅr 512K,
    ; 1MB, 2MB und 4MB
ramcntrls:
    dc.b    4,5,8,10
    ; Die dazugehîrigen Ramgrîûen
ramsizes:
    dc.l    $80000,$100000,$200000,$400000
ENDMOD

    ; Liest, soweit mîglich, die alten Ein-
    ; stellungen aus
MODULE get_settings
    lea     settings,a3
    ; Testen, ob CPU mit 8MHz lÑuft
    ; Nicht dokumentiert!
    btst    #0,$ffff8007.w
    bne.s   gs1
    move.w  #1,cpu8mhz(a3)
gs1:
    ; BLiTTER mit 8MHz?
    ; Nicht dokumentiert!
    btst    #2,$ffff8007.w
    bne.s   gs2
    move.w  #1,blit8mhz(a3)
gs2:
    ; ST(E)-Busmodus aktiv?
    ; Nicht dokumentiert!
    btst    #5,$ffff8007.w
    bne.s   gs3
    move.w  #1,busmode(a3)
gs3:
    movec   cacr,d0
    ; Befehlscache aktiv?
    btst    #0,d0
    beq.s   gs4
    move.w  #1,instcache(a3)
gs4:
    ; Datencache aktiv?
    btst    #8,d0
    beq.s   gs5
    move.w  #1,datacache(a3)
gs5:
    ; Interner Lautsprecher an?
    ; Nicht dokumentiert!
    move.w  #14,-(sp)
    move.l  #$1c0000,-(sp)
    trap    #14
    addq.l  #6,sp
    btst    #6,d0
    bne.s   gs6
    move.w  #1,speaker(a3)
gs6:
    ; Timer A fÅr DMA-Sound?
    ; Nicht dokumentiert!
    btst    #2,$ffff8900.w
    beq.s   gs7
    move.w  #1,timera(a3)
gs7:
    ; MFP-Interrupt 7 fÅr DMA-Sound?
    ; Nicht dokumentiert!
    btst    #0,$ffff8900.w
    beq.s   gs8
    move.w  #1,mfpi7(a3)
gs8:
    ; Welchen Monitor haben wir denn?
    move.w  #89,-(sp)
    trap    #14
    addq.l  #2,sp
    move.w  d0,mtype
    jmp     get_ram(pc)
ENDMOD

MODULE get_ram
    ; Ramgrîûe des Falcon bestimmen
    ; Nicht dokumentiert!
    move.w  $ffff8006.w,d0
    lsr.w   #8,d0
    lsr.b   #1,d0
    move.b  d0,d1
    andi.b  #1,d1
    lsr.b   #2,d0
    andi.b  #6,d0
    or.b    d0,d1
    move.l  #$80000,d0
    asl.l   d1,d0
    cmpi.b  #5,d1
    bne.s   no16mb
    ; Wenn es 16MB sind, "klaut" uns das TOS
    ; durch seine Lage 2 Megabyte :-(
    move.l  #$e00000,d0
no16mb:
    rts
ENDMOD

    data

    ; Diese Routine wird im Speicher als
    ; "Magic-Pack" plaziert und nach dem Reset
    ; vor den AUTO-Ordner-Programmen ausgefÅhrt
    ; Hier werden dann die Einstellungen vorge-
    ; nommen und auf Wunsch ein Diskettenboot-
    ; sektor ausgefÅhrt
mpack:
    movem.l d0-d3/a0-a4,-(sp)
    ; Den neuen PMMU-Baum installieren
    lea     rootpointer(pc),a0
    pmove   (a0),crp
    ; Sicherheitshalber den ATC lîschen
    pflusha
    ; DafÅr sorgen, daû die PrÅfsumme des
    ; "Magic Pack" zerstîrt wird
    lea     checksum(pc),a0
    clr.l   (a0)
    ; NÑchster Reset wird ein Kaltstart (aus
    ; SicherheitsgrÅnden)
    clr.l   memvalid.w
    ; Eventuell die GEMDOS-Routine einklinken,
    ; die dafÅr sorgt, daû die Bildschirmadresse
    ; die gleiche wie beim ST(E) ist
    lea     settings(pc),a4
    tst.w   scrbase(a4)
    beq.s   mp1
    movec   vbr,a0
    move.l  gdrout(pc),a3
    move.l  trap_1(a0),-4(a3)
    move.l  a3,trap_1(a0)
mp1:
    ; Die restlichen Einstellungen vornehmen
    bsr.w   set
    ; Je nach Monitortyp den richtigen Bildschirm-
    ; modus einstellen (ST-hoch bei Monochrommoni-
    ; tor, sonst ST-niedrig)
    move.w  mtype(pc),d3
    lea     modecodes(pc),a3
    move.w  (a3,d3.w*2),-(sp)
    move.w  #3,-(sp)
    clr.l   -(sp)
    clr.l   -(sp)
    move.w  #5,-(sp)
    trap    #14
    lea     14(sp),sp
    move.w  (a3,d3.w*2),-(sp)
    move.w  #88,-(sp)
    trap    #14
    addq.l  #4,sp
    ; Die Nachricht von GAMEFIX ausgeben und
    ; auf Tastendruck warten
    pea     msg(pc)
    move.w  #9,-(sp)
    trap    #1
    addq.l  #6,sp
    move.w  #8,-(sp)
    trap    #1
    addq.l  #2,sp
    ; Wurde ESC gedrÅckt? Wenn ja, dann gleich
    ; aufhîren
    cmp.b   #27,d0
    beq.s   to_gem
    ; Ansonsten Diskettenbootsektor einlesen und
    ; ausfÅhren, wenn er die richtige PrÅfsumme
    ; hat
    move.l  _dskbufp,a3
    pea     1.w
    clr.w   -(sp)
    pea     1.w
    clr.l   -(sp)
    pea     (a3)
    move.w  #8,-(sp)
    trap    #14
    lea     20(sp),sp
    move.w  #255,d0
    moveq   #0,d1
mp2:
    add.w   (a3)+,d1
    dbra    d0,mp2
    cmpi.w  #$1234,d1
    bne.s   to_gem
    ; Bootdrive auf A: Ñndern und Bootsektor
    ; ausfÅhren
    clr.w   _bootdev
    jsr     -512(a3)
to_gem:
    movem.l (sp)+,d0-d3/a0-a4
    rts

checksum:
    dc.w    0

    ; Hier werden die Einstellungen vorgenommen,
    ; die auch ohne Booten mîglich sind
set:
    tst.w   mtype(pc)
    bne.s   nomono
    ; Am Monochrommonitor die Systemvariable
    ; sshiftmd korrigieren
    move.b  #$2,sshiftmd.w
nomono:
    lea     settings(pc),a4
    ; Caches (de)aktivieren
    move.l  #$0808,d0
    or.w    datacache(a4),d0
    or.w    instcache(a4),d0
    movec   d0,cacr
    ; CPU- und BLiTTER-Takt und Busmodus
    ; setzen
    ; Nicht dokumentiert!
    move.b  #$40,d0
    or.w    cpu8mhz(a4),d0
    or.w    blit8mhz(a4),d0
    or.w    busmode(a4),d0
    move.b  d0,$ffff8007.w
    ; Lautsprecher ein- bzw. ausschalten
    ; Nicht dokumentiert!
    move.w  #14,-(sp)
    move.l  #$1c0000,-(sp)
    trap    #14
    addq.l  #6,sp
    bclr    #6,d0
    or.w    speaker(a4),d0
    move.w  #$8e,-(sp)
    move.w  d0,-(sp)
    move.w  #$1c,-(sp)
    trap    #14
    addq.l  #6,sp
    ; Wird alte Screenadresse gewÅnscht, vom
    ; Betriebssystem die dazu nîtige Anzahl von
    ; Bytes anforden (undokumentierter GEMDOS-
    ; Call) und die zurÅckerhaltene Adresse mit
    ; Setscreen einstellen
    tst.w   scrbase(a4)
    beq.s   s1
    pea     $7f00.w
    move.w  #$15,-(sp)
    trap    #1
    addq.l  #6,sp
    move.w  #-1,-(sp)
    move.l  d0,-(sp)
    move.l  d0,-(sp)
    move.w  #5,-(sp)
    trap    #14
    lea     12(sp),sp
s1:
    ; Das Soundsubsystem korrekt fÅr STE-DMA-
    ; Sound initialisieren
    move.w  #1,-(sp)
    clr.l   -(sp)
    pea     8.w
    move.w  #$8b,-(sp)
    trap    #14
    lea     12(sp),sp
    move.w  #3,-(sp)
    move.l  #$820006,-(sp)
    trap    #14
    addq.l  #6,sp
    move.w  #3,-(sp)
    move.l  #$820005,-(sp)
    trap    #14
    addq.l  #6,sp
    move.w  #3,-(sp)
    move.l  #$820004,-(sp)
    trap    #14
    addq.l  #6,sp
    ; Die gewÅnschte LautstÑrke einstellen
    move.w  volume(a4),-(sp)
    move.l  #$820000,-(sp)
    trap    #14
    addq.l  #6,sp
    move.w  volume(a4),-(sp)
    move.l  #$820001,-(sp)
    trap    #14
    addq.l  #6,sp
    ; GewÅnschte(n) DMA-Interrupt(s)
    ; einstellen
    move.w  timera(a4),-(sp)
    move.l  #$870000,-(sp)
    trap    #14
    addq.l  #6,sp
    move.w  mfpi7(a4),-(sp)
    move.l  #$870001,-(sp)
    trap    #14
    addq.l  #6,sp
    ; _memtop auf ST(E)-Åblichen Wert korrigieren
    move.l  _v_bas_ad.w,_memtop.w
    rts

mtype:
    dc.w    0
modecodes:
    ; Die Codes fÅr den Bildschirmmodus fÅr
    ; alle Monitortypen (Mono, RGB, VGA, TV)
    ; Den 2. und 4. Wert in %10000010 Ñndern,
    ; wenn 60Hz bzw. NTSC-Modus am RGB/TV
    ; gewÅnscht ist
    dc.w    %110001000,%10100010,%110010010
    dc.w    %10100010
    dc.w    $abdc
    ; Hier stehen spÑter die gewÅnschten
    ; Einstellungen
settings:
    dc.w    0,0,0,0,0,0,0,0,0,0,0
    ; Die Nachricht
msg:
    dc.b    27,"EGAMEFIX V1.00",13,10
    dc.b    13,10,"Einstellungen vorgenommen,"
    dc.b    "  zum  Booten"
    dc.b    13,10,"jetzt die Disk einlegen und"
    dc.b    " eine  Taste"
    dc.b    13,10,"drÅcken (ESC zum direkten"
    dc.b    "  Weitermachen"
    dc.b    13,10,"ohne Booten)!"
    dc.b    7,0
    
    even

    ; Adresse der GEMDOS-Routine fÅr alte
    ; Bildschrimadresse
gdrout:
    dc.l    0
    ; Der neue PMMU-Rootpointer
rootpointer:
    dc.l    $80000002,$700
    dc.w    $abcd

    ; Die GEMDOS-Routine, die fÅr die alte
    ; Bildschirmadresse sorgt
_gemdos:
    dc.b    "XBRAGfix"
old_gemdos:
    dc.l    0
new_gemdos:
    move.l  usp,a0
    btst    #5,(sp)
    beq.s   goon
    
    ; WÑre eigentlich nicht nîtig, aber man
    ; sollte es eigentlich immer so machen
    lea     6(sp),a0
    tst.w   _longframe.w
    beq.s   goon
    addq.l  #2,a0
goon:
    ; Wird die undokumentierte GEMDOS-Routine
    ; mit der Screengrîûe fÅr ST-kompatible
    ; Modi aufgerufen, einfach $200 addieren,
    ; um 512 Bytes mehr zu erhalten und somit
    ; die resultierende Adresse nach unten
    ; zu drÅcken
    cmpi.w  #$15,(a0)
    bne.s   no_scrmem
    cmp.l   #$7d00,2(a0)
    bne.s   no_scrmem
    addi.l  #$200,2(a0)
no_scrmem:
    move.l  old_gemdos(pc),-(sp)
    rts
    dc.w    $abcd

    ; Der PMMU-Baum, eine leicht geÑnderte Kopie
    ; aus dem ROM: Alle mit $ffff beginnenden
    ; Werte werden spÑter als Offsets zur Baum-
    ; adresse genommen, aus $ffff0042 wird also
    ; Baumadresse + $40, die 2 ist ein PMMU-Flag
    ; fÅr 4-Byte-groûe TabelleneintrÑge
    ; Wer also will, kann den Baum auf diese Weise
    ; abÑndern ;-)
    ; Sollen beide Caches deaktiviert werden, wird
    ; jeder Nicht-Offset-Wert mit $40 geodert, um
    ; ein Cache-Inhibit zu erzielen
new_pmmu_tree:
    dc.l   $ffff0042,$10000001,$20000001,$30000001
    dc.l   $40000001,$50000001,$60000001,$70000001
    dc.l   $80000041,$90000041,$a0000041,$b0000041
    dc.l   $c0000041,$d0000041,$e0000041,$ffff0082
    dc.l   $ffff00c2,$01000001,$02000001,$03000001
    dc.l   $04000001,$05000001,$06000001,$07000001
    dc.l   $08000001,$09000001,$0a000001,$0b000001
    dc.l   $0c000001,$0d000001,$0e000001,$0f000001
    dc.l   $f0000041,$f1000041,$f2000041,$f3000041
    dc.l   $f4000041,$f5000041,$f6000041,$f7000041
    dc.l   $f8000041,$f9000041,$fa000041,$fb000041
    dc.l   $fc000041,$fd000041,$fe000041,$ffff00c2
    dc.l   $00000001,$00100001,$00200001,$00300001
    dc.l   $00400001,$00500001,$00600001,$00700001
    dc.l   $00800001,$00900001,$00a00001,$00b00001
    dc.l   $00c00001,$00d00001,$00e00001,$00f00041

; Modulende
