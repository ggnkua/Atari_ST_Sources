                                   
*-----------------------------------------------
* DeCenter Utility for the Atari TT
* by Oliver Scholz
* (c) MAXON 1991
*-----------------------------------------------
                super

* ASCII Konstanten

CR              equ     13
LF              equ     10

* Groûbildschirmauflîsung

HIRES           equ     6

* AES Konstanten

Trap2           equ     $88
AES_MAGIC       equ     $C8
Form_Center     equ     54


* GEMDOS Konstanten

Gemdos          equ     1
Pterm0          equ     0
Cconws          equ     9
Ptermres        equ     $31
Mshrink         equ     $4A


* XBIOS Konstanten

Xbios           equ     14
Getrez          equ     4
Supexec         equ     38


* Konstanten fÅr Bildschirmgrîûe

XRES2           equ     320     * 640/2
YRES2           equ     209     * 400/2+9


* Anfang des residenten Bereichs

res_anf: 
        bra     start

         .dc.b   'XBRA'
         .dc.b   'DCNT'         * XBRA-ID
old_trp: .ds.l   1

* neuer Trap 2 Handler

new_trp:
        cmp     #AES_MAGIC,d0   * AES-Aufruf ?
        bne     do_old          * nein...

        move.l  a0,-(sp)        * A0 retten

        move.l  d1,a0           * AES Parm. Block
        move.l  (a0),a0         * Contrl Array
        cmp     #Form_Center,(a0) * Opcode
        beq     new_center

        move.l  (sp)+,a0

do_old: move.l  old_trp,-(sp)   * alte Routine
        rts

* neue form_center() Routine

new_center:
        move.l  (sp)+,a0
        movem.l d0-d1/a0-a2,-(sp)

        move.l  d1,a0      * Parameterblock
        move.l  16(a0),a1  * addrin[] Array
        move.l  12(a0),a2  * intout[] Array

        move.l  (a1),a0    * Baumadresse
        move    #1,(a2)    * intout[0]

        move    20(a0),d1  * Baumbreite
        move    d1,6(a2)   * nach intout[3]
        lsr     #1,d1      * durch 2
        move    #XRES2,d0  * X-Bildschirmmitte
        sub     d1,d0      * Objekt X-Koordinate
        move    d0,2(a2)   * nach intout[1]
        move    d0,16(a0)  * in Baum eintragen

        move    22(a0),d1  * Baumhîhe
        move    d1,8(a2)   * nach intout[4]
        lsr     #1,d1      * durch 2
        move    #YRES2,d0  * Y-Bildschirmmitte
        sub     d1,d0      * Objekt Y-Koordinate
        move    d0,4(a2)   * nach intout[2]
        move    d0,18(a0)  * im Baum eintragen

        movem.l (sp)+,d0-d1/a0-a2
        rte                * Ende des Traps

res_end:
*------------- Ende des residenten Bereichs

* Beginn des eigentlichen Programms

start:  move.l  sp,a5      * Stackpointer retten
        move.l  4(a5),a5   * Basepage Adr. holen
        move.l  $c(a5),d0  * CodelÑnge
        add.l   $14(a5),d0 * +Data
        add.l   $1c(a5),d0 * +Bss
        add.l   #512,d0    * +Stackspace/Basepage
        move.l  d0,d1
        add.l   a5,d1      * Basepage+Length
        bclr    #0,d1      * gerade machen
        move.l  d1,sp      * Neuer SP
        move.l  d0,-(sp)   * ProgrammlÑnge
        move.l  a5,-(sp)   * Programmstart
        clr.w   -(sp)      * Dummy
        move    #Mshrink,-(sp)
        trap    #Gemdos    * Speicher freigeben
        add.l   #12,sp     * Clean up stack

        move    #Getrez,-(sp)  * erweiterte
        trap    #Xbios     * Auflîsung abfragen
        addq.l  #2,sp

        cmp     #HIRES,d0  * Groûbildschirm ?
        bne     fail       * nein...

* neuen AES Aufruf installieren

        pea     install    
        move    #Supexec,-(sp) 
        trap    #Xbios
        addq.l  #6,sp

* Installation erfolgreich ?

        tst     d0         
        bmi     fail2      * nein...

        lea     success,a0 * Meldung ausgeben
        move.l  a0,-(sp)
        move    #Cconws,-(sp)
        trap    #Gemdos
        addq.l  #6,sp

* angegebenen Teil des Programmes resident halten
* den Rest wieder freigeben und Programm beenden

        clr     -(sp)      * kein Fehler
        move.l  #256+res_end-res_anf,-(sp)
        move    #Ptermres,-(sp) 
        trap    #Gemdos

*----------------------------  

* DeCenter schon im Speicher: 
* nicht nochmal installieren

fail2:  lea     already,a0
        bra     print

* falsche Auflîsung: nicht installieren

fail:   lea     failure,a0 * Meldung ausgeben
print:  move.l  a0,-(sp)
        move    #Cconws,-(sp)
        trap    #Gemdos
        addq.l  #6,sp

        move    #Pterm0,-(sp) * Programm beenden
        trap    #Gemdos

*----------------------------

* Installationsroutine: muû im Supervisormodus
* ausgefÅhrt werden ! (Zugriff auf Trap2 Vektor)

install:
        move.l  Trap2,a0    * Alte AES Routine
        move.l  a0,old_trp  * schon mal merken

* nachsehen, ob DeCenter schon im Speicher ist

loop:   cmp.l   #'XBRA',-12(a0)
        bne     ok          * kein XBRA Protokoll
        cmp.l   #'DCNT',-8(a0)
        beq     schon_da    * DeCenter da ?
        move.l  -4(a0),a0   * nÑchste Routine
        bra     loop

* neue Routine eintragen

ok:     move.l  #new_trp,Trap2  

        clr     d0          * Default: ok
        rts

* Installation fehlgeschlagen: DeCenter schon da

schon_da:
        moveq   #-1,d0      * Fehler anzeigen
        rts

        .data

* und die Meldungen...

success: .dc.b  "DeCenter installiert"
         .dc.b  CR,LF,0
failure: .dc.b  "DeCenter nicht installiert"
         .dc.b  CR,LF,0
already: .dc.b  "DeCenter ist schon installiert"
         .dc.b  CR,LF,0



