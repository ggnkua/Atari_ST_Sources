        section    text
get:
        move.l     4(sp),a0     ;Anfangsadresse d.Speichers
        move.l     8(sp),a1     ;Anfangsadresse d. get-Strings
        clr.l      d0
        move.w     12(sp),d0    ;ax%
        muls       #100,d0
        adda.l     d0,a0        ;Anfangsadresse+100Byte pro Punktspalte
        move.w     16(sp),d0
        sub.w      12(sp),d0
        move.w     d0,(a1)+     ;Breite (ex%-ax%)in get-String eintragen
        addq.w     #1,d0
        move.w     18(sp),d1
        sub.w      14(sp),d1
        move.w     d1,(a1)+     ;Hîhe (ey%-ay%)in get-String eintragen
        ext.l      d1
        divs       #8,d1        ;Hîhe/8+1= Anzahl Bytes(SchleifenzÑhler)
        addq.w     #1,d1
        move.w     d1,d6        ;retten fÅr nÑchste Punktspalte
        move.w     14(sp),d2
        ext.l      d2
        divs       #8,d2
        adda.w     d2,a0        ;senkrechte Verschiebung(ay% div 8)Bytes
        move.l     a0,a2        ;Anfang retten fÅr nÑchste Punktspalte
        swap       d2           ;senkrechte Bitverschiebung:Divisionsrest
        move.w     #8,d3
        sub.w      d2,d3        ;Komplement zu 8
l0:
        move.b     (a0)+,d4     ;Byte holen
        asl.b      d2,d4
        move.b     (a0),d5      ;nÑchstes Byte holen
        lsr.b      d3,d5
        add.b      d5,d4
        move.b     d4,(a1)+     ;in get-String eintragen
        subq.w     #1,d1
        bgt.s      l0(pc)
        move.w     d6,d1
        adda.l     #100,a2      ;nÑchste Punktspalte
        move.l     a2,a0
        subq.w     #1,d0
        bgt.s      l0(pc) 
        rts
        end
