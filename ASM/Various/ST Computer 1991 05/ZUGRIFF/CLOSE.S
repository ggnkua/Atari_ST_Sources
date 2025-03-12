GEMDOS  = 1
SETBLOCK= $4a


        text

        move.l sp,a0
        lea stack+200,sp        ;Stackpointer initialisieren
        move.l 4(a0),a0
        move.l 12(a0),a1
        add.l 20(a0),a1
        add.l 28(a0),a1
        lea $100(a1),a1
        move.l a1,-(sp)
        move.l a0,-(sp)
        clr -(sp)
        move #SETBLOCK,-(sp)
        trap #GEMDOS            ;ÅberzÑhligen Speicher freigeben
        lea 12(sp),sp
        tst.l d0                ;alles klar?
        bne error               ;leider nein-

        lea intin,a5            ;Pointer auf INTIN-Array
        lea intout,a6           ;Pointer auf INTOUT-Array
        moveq #10,d0            ;appl_init
        move.l #$00010000,d1
        bsr.s aes
        tst (a6)                ;Fehler?
        bmi.s error             ;ja-

        lea deskinf,a4          ;Puffer fÅr Desktop-Info
        moveq #122,d0           ;shel_get
        move.l #$01010100,d1
        move #1024,(a5)         ;1024 Bytes kopieren
        move.l a4,addrin        ;Pufferadresse eintragen
        bsr.s aes               ;AES-Puffer auslesen

loop:   move.b (a4)+,d0
        beq.s einfo
        cmp.b #26,d0            ;CTRL-Z?
        beq.s einfo             ;ja-
        cmp.b #'#',d0
        bne loop
        cmp.b #'W',(a4)         ;folgen Fensterdaten?
        bne loop                ;nein-
        lea 23(a4),a4           ;Pointer auf Fensternamen
        move.b (a4),d0
        cmp.b #'@',d0           ;Fenster offen?
        beq loop                ;nein-
        cmp.b #'C',d0           ;Floppy-Fenster?
        bcs loop                ;ja-
        move.b #'@',(a4)        ;Fenster desaktivieren
        bra loop

einfo:  moveq #123,d0           ;shel_put
        move.l #$01010100,d1
        move #1024,(a5)         ;1024 Bytes schreiben
        move.l #deskinf,addrin
        bsr.s aes               ;neuen Pufferinhalt zurÅckschreiben

        moveq #19,d0            ;appl_exit
        move.l #$00010000,d1
        bsr.s aes

error:  clr -(sp)
        trap #GEMDOS            ;das war's

*AES-Aufruf
*Funktionsnummer in D0, Parameter in D1
aes:
        lea contrl,a0
        move d0,(a0)
        movep.l d1,3(a0)        ;4 Parameter Åbertragen
        move.l #aespb,d1
        move #$c8,d0
        trap #2
        rts


        data

*Pointer auf AES-Arrays

aespb:  dc.l contrl,global,intin,intout,addrin,addrout


        bss

*Definitionen der AES-Arrays

contrl: ds.w 11

global: ds.w 15

intin:  ds.w 64

intout: ds.w 64

addrin: ds.w 64

addrout:ds.w 64

deskinf:ds.b 1024               ;Puffer fÅr Desktop-Daten

stack:  ds.l 50                 ;sollte fÅr Stack reichen
