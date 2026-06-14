       section     text
put:
       move.l      4(sp),a0   ;sp%
       move.l      8(sp),a1   ;gt%
       move.w      12(sp),d0  ;ax%
       muls        #100,d0
       adda.l      d0,a0
       move.w      14(sp),d0  ;ay%
       ext.l       d0
       divs        #8,d0
       adda.w      d0,a0
       swap        d0         ;Bitverschiebung(Divisionsrest)
       moveq       #7,d2
       sub.w       d0,d2      ;Bitverschiebung andersrum
       move.l      d2,d0
       move.l      a0,a2      ;linke obere Ecke(Zieladresse)
       move.w      (a1),d1    ;Breite
       add.w       12(sp),d1
       cmpi.w      #1279,d1   ;BereichsÅberschreitung?
       ble.s       l0(pc)
       move.w      #1279,d1
       sub.w       12(sp),d1
       bcc.s       l1(pc)
l0:
       move.w      (a1),d1    ;SchleifenzÑhler quer
l1:
       addq.l      #2,a1
       move.w      (a1),d3    ;SchleifenzÑhler senkrecht
       move.w      d3,d6
       ext.l       d6
       divs        #8,d6
       addq.w      #1,d6 
       add.w       14(sp),d3
       cmpi.w      #799,d3     ;BereichsÅberschreitung?
       ble.s       l3(pc)
       move.w      #799,d3
       sub.w       14(sp),d3
       bcc.s       l4(pc)
l3:
       move.w      (a1),d3
l4:
       addq.l      #2,a1
       move.l      a1,a3
       move.w      d3,d4 
       cmpi.w      #0,16(sp)  ;putmodus
       bgt.s       l2(pc)
loop0:
       bclr        d2,(a0)
       cmpi.w      #0,d2
       bgt.s       lo0(pc)
       moveq       #8,d2
       addq.l      #1,a0
lo0:
       subq.w      #1,d2
       dbra        d3,loop0(pc)
       adda.l      #100,a2
       move.l      a2,a0
       move.w      d4,d3
       move.w      d0,d2
       dbra        d1,loop0(pc)
       bra         exit(pc)
l2:
       moveq       #7,d5
       cmpi.w      #3,16(sp)
       bgt.s       loop2(pc)
loop1:
       btst        d5,(a1)
       beq.s       lo1(pc)
       bset        d2,(a0)
       bcc.s       lo2(pc)
lo1:
       bclr        d2,(a0)
lo2:
       cmpi.l      #0,d2
       bgt.s       lo3(pc)
       moveq       #8,d2
       addq.l      #1,a0
lo3:
       subq.l      #1,d2
       cmpi.l      #0,d5
       bgt.s       lo4(pc)
       moveq       #8,d5
       addq.l      #1,a1
lo4:
       subq.l      #1,d5
       dbra        d3,loop1(pc)
       adda.l      #100,a2
       move.l      a2,a0
       move.w      d4,d3
       move.l      d0,d2
       moveq       #7,d5
       adda.w      d6,a3
       move.l      a3,a1
       dbra        d1,loop1(pc)  
       bra.s       exit(pc)
loop2:
       btst        d5,(a1)
       beq.s       lo5(pc)
       bset        d2,(a0)
lo5:
       cmpi.l      #0,d2
       bgt.s       lo6(pc)
       moveq       #8,d2
       addq.l      #1,a0
lo6:
       subq.w      #1,d2
       cmpi.l      #0,d5
       bgt.s       lo7(pc)
       moveq       #8,d5
       addq.l      #1,a1
lo7:
       subq.w      #1,d5
       dbra        d3,loop2(pc)
       adda.l      #100,a2
       move.l      a2,a0
       move.l      d0,d2 
       move.w      d4,d3
       moveq       #7,d5
       adda.w      d6,a3
       move.l      a3,a1

       dbra        d1,loop2(pc)  
exit:
       rts
       end 
