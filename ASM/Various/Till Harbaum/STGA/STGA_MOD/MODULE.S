;
;  STGA-SM124-Emulation-ROM-Modul
;

        .globl start_emu

        shift_md   equ  $ff8260

        Bconstat   equ  $01
        Bconin     equ  $02
        Bconout    equ  $03
        Setscren   equ  $05
        Dosound    equ  $20

        sshiftmd   equ  $44c
        swv_vec    equ  $46e
        _hz_200    equ  $4ba
        _smagic    equ  $3fa
        _smode     equ  $3fe

        MAGIC      equ  $12345678
        VGA        equ  0
        MONO       equ  1
        COLOR      equ  2
        OFF        equ  4
        CON        equ  2

        dc.l    $abcdef42               ; CA_MAGIC

        ; erster Header
        dc.l    0                       ; naechster Header
        dc.l    $2000000+init_stga      ; CA_INIT
        dc.l    stga_msg                ; CA_RUN
        dc.w    0                       ; CA_TIME
        dc.w    0                       ; CA_DATE
        dc.l    42                      ; CA_SIZE
        dc.b    "STGA_MOD.TOS",0,0      ; CA_NAME
        dc.w    0x0101                  ; Version 1.1
        .align

; das hier ist das Programm, das man vom Desktop unter c: (klein!) sieht
stga_msg:
        pea     msg(pc)
        move    #9,-(sp)
        trap    #1
        move    #8,-(sp)
        trap    #1
        addq.l  #8,sp
        clr     -(sp)
        trap    #1

msg:
        dc.b    "STGA-ROM-Modul V1.1",13,10
        dc.b    "(c) 1997 Till Harbaum",13,10,0
        .align

put_string:
        tst.b   (a3)
        beq.s   psback
        clr     d0
        move.b  (a3)+,d0
        move    d0,-(sp)
        move    #CON,-(sp)        ; CON
        move    #Bconout,-(sp)
        trap    #13
        addq.l  #6,sp
        bra.s   put_string
psback: rts


keymsg: dc.b   13,10,9,9,9,27,"p - STGA-ROM-Modul V1.1 - ",27,"q",13,10,10
        dc.b   9,9,9
        dc.b   "select ",27,"pV",27,"qGA, ",27,"pM",27,"qONO or "
        dc.b   27,"pC",27,"qOLOR",13,10,0

; ein Dingdong fuer XBios32
sound:  dc.b    0,150, 1,1, 2,151, 3,1, 4,0, 5,0, 6,0, 7,252
        dc.b    8,16, 9,16, 10,0, 11,0, 12,63, 13,0, 130,50
        dc.b    0,250, 1,1, 2,252, 3,1, 13,0, 130,0

init_stga:
        cmp.l   #MAGIC,_smagic
        bne.s   nomag1
        move    _smode,d0
        and     #4,d0
        bne     return                  ; Modul ausgeschaltet
nomag1:
        movem.l d0-d7/a0-a6,-(sp)

        ; kein Reset bei Video-Wechsel
        move.l  #return, swv_vec

        ; beim ersten Boot kleinen Text ausgeben
        cmp.l   #MAGIC,_smagic
        beq.s   no_text
        lea     keymsg(pc),a3
        bsr     put_string

no_text:
        ; Ding-Dong machen
        pea     sound(pc)
        move    #Dosound,-(sp)
        trap    #14
        addq.l  #6,sp

        ; eine Sekunde warten
        move.l  _hz_200,d0
        add.l   #1*200,d0
waitlp: cmp.l   _hz_200,d0
        bhi.s   waitlp

        ; ist eine Taste gedrueckt?
        move    #CON,-(sp)
        move    #Bconstat,-(sp)
        trap    #13
        addq.l  #4,sp
        tst     d0
        beq.s   no_key          ; keine Taste

        ; Taste lesen
        move    #CON,-(sp)
        move    #Bconin,-(sp)
        trap    #13
        addq.l  #4,sp

        ; entsprechend handeln
        cmp.b   #'V',d0         ; V wie VGA
        beq.s   set_vga
        cmp.b   #'v',d0
        beq.s   set_vga

        cmp.b   #'M',d0         ; M wie Mono
        beq.s   set_mono
        cmp.b   #'m',d0
        beq.s   set_mono

        cmp.b   #'C',d0         ; C wie Color
        beq.s   set_color
        cmp.b   #'c',d0
        beq.s   set_color

        bra.s   no_key          ; falsche Taste -> keine Taste

; Modus speichern und einstellen
set_mono:
        move.l  #MAGIC,_smagic
        move    #MONO,_smode
        bra.s   do_mono

set_color:
        move.l  #MAGIC,_smagic
        move    #COLOR,_smode
        bra.s   do_color

set_vga:
        move.l  #MAGIC,_smagic
        move    #VGA,_smode
        bra.s   do_vga

; hier sollte der Defaultwert gelesen werden
no_key: cmp.l   #MAGIC,_smagic
        bne.s   set_vga         ; kein Magic? Default=VGA
        cmp     #MONO,_smode
        beq.s   do_mono         ; SM124 an
        cmp     #COLOR,_smode
        beq.s   do_color        ; SC1224 an
        bra.s   do_vga          ; sonst VGA-SM124-Emulation

        ; hier kann man per Software den Monitor wechseln
        ; funktioniert mit einer Auto-Switch-Box o.ae.
do_color:
        move.w  #0,-(sp)           ; niedrige Aufl”sung
        pea     -1                 ; einschalten
        pea     -1
        move.w  #Setscren,-(sp)
        trap    #14
        lea     12(sp),sp

        move.b  #$0e,$ff8800       ; Soundchip Port A
        bset.b  #$06,$ff8802       ; Bit 6 an=LoRez, aus=HiRez
        bra.s   the_end            ; lorez -> keine VGA

do_vga:
        ; SM124-Emulation einschalten
        jsr     start_emu

do_mono:
the_end:
        movem.l (sp)+,d0-d7/a0-a6
return: rts