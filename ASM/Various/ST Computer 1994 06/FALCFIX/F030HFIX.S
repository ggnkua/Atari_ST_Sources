; f030hfix.s
;
; Klinkt sich in den GEMDOS-Trap ein (XBRA FHFX)
; und fÑngt die Aufrufe Fforce, Fread, Fseek und
; Fwrite ab. Wird diesen ein negatives Handle
; Åbergeben (zwischen -1 und -3), wird es durch
; ein Ausweichhandle ersetzt, wodurch ein Fehler
; im Falcon-GEMDOS umgangen wird. Bei Fopen und
; Fcreate mit PRN:, AUX: oder CON: wird das rich-
; tige dazugehîrige negative Handle zurÅckgegeben
; (der Falcon vergibt hier fÑlschlicherweise
; normale Dateikennungen). Auûerdem werden noch
; die Aufrufe Pterm und Pterm0 abgefangen,
; allerdings nur fÅr interne Verwaltungszwecke.
;
; History:
; 18.03.-
; 19.03.1994: Erstellung
; 20.03.1994: Verbesserung der Suche in proctab
; 22.03.1994: Registerrettung eingebaut (weil
;             Pure C 1.0 seine Hilfe-Dateien
;             nicht mehr îffnen konnte)
; 03.04.-
; 05.04.1994: Auch Fopen und Fcreate werden
;             jetzt korrigiert (bei CON:, AUX:
;             und PRN: wird das richtige (nega-
;             tive) Handle geliefert). Entspre-
;             chend wird Fclose bei den negativen
;             GerÑtehandles zur Dummy-Funktion.

    super
    mc68030

    equ     _longframe, $59e
    equ     _sysbase,   $4f2
; In maxtab steht die maximale Anzahl von Pro-
; zessen, die in der internen Tabelle (proctab)
; verwaltet werden. 100 sollte dicke genug sein,
; zumal ja nur die Prozesse darin aufgefÅhrt wer-
; den, die einen GEMDOS-Aufruf mit negativem
; Filehandle gemacht haben.
    equ     maxtab,     100
    equ     Fcreate,    60
    equ     Fopen,      61
    equ     Fclose,     62
    equ     Fread,      63
    equ     Fwrite,     64
    equ     Fseek,      66
    equ     Fforce,     70

    text

; Ist die Routine bereits installiert?
    pea     is_installed(pc)
    move.w  #38,-(sp)       ; Supexec
    trap    #14
    addq.l  #6,sp
    tst.w   d0
    bne.s   already_installed
; Ist der Rechner wirklich ein F030?
    pea     check_f030(pc)
    move.w  #38,-(sp)       ; Supexec
    trap    #14
    addq.l  #6,sp
    tst.w   d0
    beq.s   no_falcon
; Checken, ob das GEMDOS den Patch Åberhaupt
; braucht
    pea     check_gemdos(pc)
    move.w  #38,-(sp)
    trap    #14             ; Supexec
    addq.l  #6,sp
    tst.w   d0
    beq.s   not_needed
; Neue GEMDOS-Routine einklinken
    pea     new_gemdos(pc)
    move.w  #33,-(sp)
    move.w  #5,-(sp)        ; Setexc
    trap    #13
    addq.l  #8,sp
    move.l  d0,old_gemdos
; Die proctab lîschen
    lea     proctab(pc),a0
    clr.w   d0
clear:
    clr.l   (a0)+
    clr.l   (a0)+
    clr.w   (a0)+
    addq.w  #1,d0
    cmpi.w  #maxtab,d0
    bne.s   clear
; Erfolgsmeldung ausgeben
    pea     patch_text(pc)
    move.w  #9,-(sp)        ; Cconws
    trap    #1
    addq.l  #6,sp
; Grîûe des resident zu haltenden Speicherbereichs
; berechnen und Programm mit Ptermres beenden
    move.l  #$100,d0
    move.l  4(sp),a0
    add.l   $c(a0),d0
    add.l   $14(a0),d0
    add.l   $1c(a0),d0
    clr.w   -(sp)
    move.l  d0,-(sp)
    move.w  #49,-(sp)       ; Ptermres
    trap    #1
; Meldung ausgeben, daû die Routine bereits in-
; stalliert ist
already_installed:
    pea     already_installed_text(pc)
    bra.s   out
; Meldung ausgeben, daû der Rechner kein Falcon
; ist
no_falcon:
    pea     no_falcon_text(pc)
    bra.s   out
; Meldung ausgeben, daû dieser Falcon den Patch
; nicht mehr braucht
not_needed:
    pea     not_needed_text(pc)
out:
    move.w  #9,-(sp)        ; Cconws
    trap    #1
; Programm verlassen (1 fÅr allgemeinen Fehler
; zurÅckgeben)
    move.w  #1,-(sp)
    move.w  #76,-(sp)       ; Pterm
    trap    #1

; Die neue GEMDOS-Routine
    dc.b    "XBRAFHFX"
old_gemdos:
    dc.l    0
new_gemdos:
    move.l  usp,a0
    btst    #5,(sp)
    beq.s   goon
; Die BerÅcksichtigung von _longframe ist beim
; F030 eigentlich unnîtig, aber es sollte immer
; so gemacht werden!
    lea     6(sp),a0
    tst.w   _longframe.w
    beq.s   goon
    addq.l  #2,a0
goon:
; Register retten (obwohl eigentlich nicht nîtig,
; aber manche unsauberen Programme bereiten da
; Schwierigkeiten, leider z.B. auch Pure C 1.0)
    movem.l a0-a2/d1-d2,-(sp)
; ZunÑchst auf Pterm bzw. Pterm0 testen, da hier
; der Eintrag in der Tabelle entfernt werden muû
; (*nicht* bei Ptermres!)
    tst.w   (a0)
    beq.s   yep
    cmpi.w  #76,(a0)
    bne.s   check
yep:
    bsr.w   remove_entry
    bra.s   back
; Auf die zu patchenden Routinen prÅfen und ggf.
; den Ersatzcode anspringen
check:
    cmpi.w  #Fopen,(a0)
    beq.s   my_fopen
    cmpi.w  #Fcreate,(a0)
    beq.s   my_fopen
    move.w  #4,d0
    cmpi.w  #Fforce,(a0)
    beq.s   check_handle
    move.w  #6,d0
    cmpi.w  #Fseek,(a0)
    beq.s   check_handle
    move.w  #2,d0
    cmpi.w  #Fread,(a0)
    beq.s   check_handle
    cmpi.w  #Fwrite,(a0)
    beq.s   check_handle
    cmpi.w  #Fclose,(a0)
    bne.s   back
check_handle:
; Liegt das Filehandle zwischen -1 und -3?
    move.w  (a0,d0.w),d1
    cmpi.w  #-3,d1
    blt.s   back
    cmpi.w  #-1,d1
    bge.s   back
; Wenn ja, war es der Fclose-Auruf? Dann Return-
; Code auf 0 setzen und ohne Aktion zurÅck
    cmpi.w  #Fclose,(a0)
    bne.s   replace
    moveq   #0,d0
    bra.s   no_action
; Sonst: Ausweichhandle ermitteln und einsetzen
replace:
    bsr.s   get_handle
    tst.w   d1
    bmi.s   back
    move.w  d1,(a0,d0.w)
back:
    movem.l (sp)+,a0-a2/d1-d2
    move.l  old_gemdos(pc),-(sp)
    rts
no_action:
    movem.l (sp)+,a0-a2/d1-d2
    rte

; Dies ist die Ersatzroutine fÅr Fopen und
; Fcreate. Ist der Filename gleich CON:, AUX: oder
; PRN:, wird das entsprechende negative GerÑte-
; handle zurÅckgeliefert. Bei gesetztem Flag
; no_fopen wird die alte Routine angesprungen. Der
; Filename muû Åbrigens komplett groû oder kom-
; plett klein geschrieben sein, gemischte Schreib-
; weisen wie CoN: werden vom GEMDOS nicht akzep-
; tiert, also machen wir das auch nicht...
my_fopen:
    move.l  a3,-(sp)
    tst.w   no_fopen
    bne.s   fo_back
    lea     filenames(pc),a2
    moveq   #0,d0
    moveq   #0,d1
; Ist der erste Buchstabe des Åbergebenen Namens
; kleingeschrieben, ein Flag setzen, daû in allen
; Zeichen des Namens Bit 5 gewechselt werden muû
; (damit Mischschreibweisen abgelehnt werden).
    move.l  2(a0),a1
    btst    #5,(a1)
    beq.s   compare1
    moveq   #32,d1
; Den Filenamen mit den mîglichen vergleichen
compare1:
    move.l  2(a0),a1
    move.l  a2,a3
compare2:
; Eventuell Bit 5 des zu vergleichenden Zeichens
; wechseln (nicht bei 0 (= Ende des Filenames)
; oder ':')
    move.b  (a1)+,d2
    beq.s   no_convert
    cmpi.b  #':',d2
    beq.s   no_convert
    eor.b   d1,d2
no_convert:
    cmp.b   (a3),d2
; Wenn sich die Zeichen unterscheiden, mit dem
; naechsten Vergleichsnamen weitermachen
    bne.s   naechster_name
; Ansonsten weitermachen, bis der Vergleichs-
; name abgearbeitet wurde
    tst.b   (a3)+
    bne.s   compare2
; Der Filename war gleich, Register d0 enthÑlt die
; Nummer. Dazu wird 1 addiert und das ganze
; negiert, und schon haben wir das nîtige GerÑte-
; handle ;) Negiert wird Åbrigens nur das untere
; Wort, da negative Longs einen Fehler signali-
; sieren! Merke: Nur wenn auch das Hi-Word negativ
; ist, ist wirklich ein Fehler aufgetreten. Des-
; halb deklarieren die meisten neueren Compiler
; den RÅckgabewert von Fopen/Fcreate als Long.
    addq.w  #1,d0
    neg.w   d0
    move.l  (sp)+,a3
    bra.s   no_action
; Der Filename war unterschiedlich, also muû der
; nÑchste mîgliche ÅberprÅft werden. Wurden
; bereits alle getestet, die normale Fopen- bzw.
; Fcreate-Routine anspringen
naechster_name:
    addq.l  #5,a2
    addq.w  #1,d0
    cmpi.w  #3,d0
    bne.s   compare1
fo_back:
    clr.w   no_fopen
    move.l  (sp)+,a3
    bra.s   back

; get_handle liefert fÅr das in d1 Åbergebene
; Standardhandle einen Ersatz, der in d1 zurÅck-
; gegeben wird. Ein negativer RÅckgabewert zeigt
; an, daû kein Ersatz geschaffen werden konnte
get_handle:
; ZunÑchst mal ein paar Register retten...
    movem.l a0/a3-a4/d0/d3-d4,-(sp)
    move.l  d1,d4
; Den Zeiger auf den laufenden GEMDOS-Prozeû aus
; dem Systemheader auslesen und die aktuelle
; Basepage nach a0 laden
    move.l  _sysbase.w,a0
    move.l  8(a0),a0
    move.l  40(a0),a0
    move.l  (a0),d1
; Suchen, ob der aktuelle Prozeû bereits in der
; proctab vorhanden ist.
    lea     -1.w,a1
    lea     proctab(pc),a0
    clr.w   d0
get1:
    cmp.l   (a0),d1
; Wenn ja, gleich das Ersatzhandle auslesen
    beq.s   found
; Sonst nachschauen, ob das bisherige Ende der
; Liste erreicht ist, wenn ja, dort einen neuen
; Eintrag erzeugen.
    tst.l   (a0)
    beq.s   get4
; Ist der Eintrag = -1, diesen fÅr spÑter merken
    cmpi.l  #-1,(a0)
    bne.s   get2
    move.l  a0,a1
; Jetzt solange weitersuchen, bis die gesamte
; Liste abgearbeitet wurde (in diesem Fall gibt es
; keinen leeren Eintrag mehr)
get2:
    lea     10(a0),a0
    addq.w  #1,d0
    cmpi.w  #maxtab,d0
    bne.s   get1
; Da es keinen leeren Eintrag mehr gibt, muû jetzt
; der vorher hoffentlich gefundene freie Eintrag
; (Basepage-Wert = -1) neu belegt werden
    move.l  a1,a0
    cmpa.l  #-1,a0
    bne.s   new_entry
; Wenn auch kein freier Eintrag mehr da war, ist
; die Liste wirklich voll, es kann also vorerst
; nichts mehr gemacht werden (allerdings ist
; dieser Fall recht unwahrscheinlich, denn es
; mÅûten mehr als 100 GEMDOS-Prozesse aktiv sein)
    move.w  a0,d1
    bra.s   exit_get
get4:
; a0 enthÑlt hier den ersten leeren Eintrag. Wenn
; es aber bereits vorher einen freien Eintrag gab
; (dann ist in a0 ein Wert != -1), soll natÅrlich
; dieser benutzt werden, um die Tabelle besser zu
; nutzen.
    cmpa.l  #-1,a1
    beq.s   new_entry
    move.l  a1,a0
; Hier wird jetzt ein neuer Eintrag in der proctab
; angelegt (bzw. ein freier Åberschrieben)
new_entry:
    move.l  a0,a3
; Die Basepage-Adresse merken
    move.l  d1,(a3)+
; Dann dreimal Fopen aufrufen, um jeweils Ersatz-
; handles fÅr CON:, AUX: und PRN: zu bekommen.
; Wichtig: Hier muû vorher das Flag no_fopen
; gesetzt werden, damit der Fopen-Aufruf nicht von
; unserer eigenen Routine abgefangen wird (sonst
; wÑre ja Åberhaupt nichts erreicht...) Es darf
; hier Åbrigens gefahrlos ein trap #1-Aufruf ge-
; macht werden, da man sich ja noch nicht direkt
; im GEMDOS befindet, also ist es unbedeutend, daû
; das GEMDOS nicht reentrant ist.
    move.w  #2,d3
    lea     filenames(pc),a4
get5:
    move.w  #1,no_fopen
    move.w  #2,-(sp)
    pea     (a4)
    move.w  #61,-(sp)
    trap    #1
    addq.l  #8,sp
; Die Ersatzhandles auch in der Liste vermerken.
; Trat beim Fopen-Aufruf ein Fehler auf, ist das
; gelieferte Handle (auch als Word) negativ und
; wird daher ohne weitere öberprÅfung eingetragen
; (ein negatives Ersatz-Handle wird ja nicht be-
; nutzt)
    move.w  d0,(a3)+
    addq.l  #5,a4
    dbra    d3,get5
    lea     -10(a3),a3
    move.l  a3,a0
; Ab hier wird dann fÅr das Handle in d4 das
; Ersatzhandle aus der proctab ausgelesen und in
; d1 zurÅckgeliefert
found:
    tst.l   (a0)+
    neg.w   d4
    subq.w  #1,d4
    move.w  (a0,d4.w*2),d1
exit_get:
    movem.l (sp)+,a0/a3-a4/d0/d3-d4
    rts

; Den aktuellen Prozeû aus proctab lîschen (soweit
; vorhanden). Diese Unterroutine wird aufgerufen,
; wenn ein Pterm- oder Pterm0-Aufruf abgefangen
; wurde, damit die nicht mehr benîtigten PlÑtze in
; der proctab als frei gekennzeichnet werden
remove_entry:
    move.l  _sysbase.w,a0
    move.l  8(a0),a0
    move.l  40(a0),a0
    move.l  (a0),d1
; Wieder suchen, ob die Basepage des aktuellen
; GEMDOS-Prozesses in der Liste vorhanden ist
    lea     proctab(pc),a0
    clr.w   d0
remove1:
    cmp.l   (a0),d1
; Wenn ja, den Eintrag mit -1 Åberschreiben und
; ihn somit als frei kennzeichnen
    beq.s   overwrite
; Ansonsten die Liste bis zum ersten leeren Ein-
; trag (oder auch bis zum Ende) durchsuchen und
; dann ohne énderungen zurÅckkehren
    tst.l   (a0)
    beq.s   schluss
    lea     10(a0),a0
    addq.w  #1,d0
    cmpi.w  #maxtab,d0
    bne.s   remove1
schluss:
    rts
overwrite:
    move.l  #-1,(a0)
    rts

; Diese Routine prÅft, ob der Falcon den Patch
; Åberhaupt braucht
check_gemdos:
; Ist MiNT installiert, wird der Patch nicht
; benîtigt
    move.l  #'MiNT',d0
    bsr.s   get_cookie
    tst.w   d0
    bne.s   no_patch
; Liefert der Aufruf Fopen("CON:", 2) nicht -1
; (als Word) zurÅck, hat das GEMDOS den Fehler
    move.w  #2,-(sp)
    pea     filenames(pc)
    move.w  #Fopen,-(sp)
    trap    #1
    addq.l  #8,sp
    cmpi.l  #65535,d0
    beq.s   no_patch
; Wenn nicht -1, die dadurch belegte Dateikennung
; wieder freigeben
    move.w  d0,-(sp)
    move.w  #Fclose,-(sp)
    trap    #1
    addq.l  #4,sp
    moveq   #1,d0
    rts
no_patch:
    clr.w   d0
    rts
    
; Diese Routine prÅft anhand des _MCH-Cookies, ob
; der Rechner ein Falcon ist
check_f030:
    move.l  #'_MCH',d0
    bsr.s   get_cookie
    tst.w   d0
    beq.s   ch_back
    cmpi.l  #$30000,d1
    beq.s   ch_back
    clr.w   d0
ch_back:
    rts

; Ermittelt, ob der Cookie in d0 existiert und
; gibt dessen Inhalt in d1 zurÅck. d0 enthÑlt
; dann 1, sonst 0. Muû im Supervisor-Mode auf-
; gerufen werden!
get_cookie:
    move.l  $5a0,d1
    beq.s   nixis
    move.l  d1,a0
gc1:
    tst.l   (a0)
    beq.s   nixis
    cmp.l   (a0)+,d0
    bne.s   gc2
    move.l  (a0),d1
    moveq   #1,d0
    bra.s   gc_back
nixis:
    clr.l   d0
gc_back:
    rts
gc2:
    addq.l  #4,a0
    bra.s   gc1

; Diese Routine prÅft, ob in der XBRA-Kette des
; GEMDOS-Vektors die Patch-Routine bereits einge-
; klinkt ist
is_installed:
    move.l  33*4.w,a0       ; GEMDOS-Vektor
loop:
    tst.l   a0
    beq.s   not_installed
    cmp.l   #'XBRA',-12(a0)
    bne.s   not_installed
    cmp.l   #'FHFX',-8(a0)
    beq.s   installed
    move.l  -4(a0),a0
    bra.s   loop
installed:
    moveq   #1,d0
    rts
not_installed:
    clr.w   d0
    rts

    data

no_falcon_text:
    dc.b    13,10,"Machine is not a Falcon030!"
    dc.b    13,10,0
    even
patch_text:
    dc.b    13,10,"F030-GEMDOS-Handle-Fix "
    dc.b    "installed!",13,10,0
    even
already_installed_text:
    dc.b    13,10,"F030-GEMDOS-Handle-Fix "
    dc.b    "already installed!",13,10,0
not_needed_text:
    dc.b    13,10,"This GEMDOS doesn't need the "
    dc.b    "F030-GEMDOS-Handle-Fix!",13,10,0

    even

filenames:
    dc.b    "CON:",0,"AUX:",0,"PRN:",0

    bss

; Ist no_fopen ungleich Null, darf Fopen nicht
; abgefangen werden (da Fopen einmal intern in der
; "Originalform" benîtigt wird)
no_fopen:
    ds.w    1

; In proctab werden Prozesse aufgefÅhrt, fÅr die
; bereits ein Ersatzhandle geschaffen wurde. Jeder
; Eintrag enthÑlt Basepage, Ersatzhandle fÅr -1,
; -2 und -3 (zusammen also 10 Bytes)
; Ist der Wert fÅr die Basepage = 0, ist das bis-
; herige Ende der Liste erreicht; ist sie -1 (als
; Long-Wert), ist der Eintrag nicht belegt.
proctab:
    ds.b    10*maxtab
