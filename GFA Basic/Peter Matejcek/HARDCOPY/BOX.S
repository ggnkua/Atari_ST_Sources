                  section      text 
box:      
            move.l       4(sp),a0      ;varptr(sp%(0)) 
            move.l       a0,a1 
            clr.l        d0 
            move.w       8(sp),d0      ;ax% 
            move.w       12(sp),d2     ;ex% 
            cmp.w        d0,d2 
            bge.s        l1(pc) 
            exg          d0,d2         ;fÅr positive differenz sorgen 
l1: 
            move.w       d0,d1 
            muls         #100,d1 
            adda.l       d1,a0         ;erste Punktspalte 
            move.w       d2,d7 
            muls         #100,d7 
            adda.l       d7,a1         ;letzte Punktspalte 
            sub.w        d0,d2          
            clr.l        d1 
            move.w       10(sp),d1     ;ay% 
            move.w       14(sp),d3     ;ey% 
            cmp.w        d1,d3 
            bge.s        l2(pc) 
            exg          d1,d3 
l2:  
            ext.l        d3 
            divs         #8,d3  
            move.l       d3,d7         ;ey% div 8 retten,wird noch gebraucht  
            moveq        #7,d6 
            moveq        #7,d0 
            swap         d7 
            sub.w        d7,d6         ;7 - ey% mod 8 
            ext.l        d1 
            divs         #8,d1 
            sub.w        d1,d3          
            subq.w       #2,d3         ;ZÑhler in y-Richtung 
            adda.w       d1,a0         ;erstes Byte ermitteln 
            move.l       a0,a2         ;linke obere Ecke retten 
            adda.w       d1,a1 
            swap         d1            ;ay% mod 8 
            sub.w        d1,d0         ;7 - ay% mod 8  
            move.w       16(sp),d4     ;Graphikmodus 
            move.b       #255,d5 
            lsr.b        d1,d5         ;Maske fÅr erstes byte 
            cmpi.w       #1,d4 
            bgt.s        l8(pc) 
            or.b         d5,(a0)       ;mit Maske odern 
            or.b         d5,(a1) 
            bcc.s        l9(pc) 
l8: 
            eor.b        d5,(a0) 
            eor.b        d5,(a1) 
l9: 
            cmpi.w       #0,d3 
            blt.s        l4(pc) 
l3: 
            addq.l       #1,a0 
            addq.l       #1,a1 
            cmpi.w       #1,d4 
            bgt.s        l10(pc) 
            move.b       #255,(a0)      ;ein schwarzes senkrechtes Strichi 
            move.b       #255,(a1) 
            bcc.s        l11(pc) 
l10: 
            eori.b       #255,(a0) 
            eori.b       #255,(a1) 
l11: 
            dbra         d3,l3(pc) 
l4:       
            cmpi.w       #-1,d3 
            blt.s        l5(pc) 
            addq.l       #1,a0 
            addq.l       #1,a1 
l5: 
            move.b       #255,d5 
            asl.b        d6,d5          ;Maske fÅr letztes Byte 
            cmpi.w       #1,d4 
            bgt.s        l12(pc) 
            or.b         d5,(a0) 
            or.b         d5,(a1) 
            bcc.s        l13(pc) 
l12: 
            eor.b        d5,(a0) 
            eor.b        d5,(a1) 
l13: 
            cmpi.w       #2,d2 
            blt.s        l7(pc)  
            subq.w       #2,d2 
l6: 
            adda.l       #100,a0 
            adda.l       #100,a2 
            cmpi.w       #1,d4
            bgt.s        l14(pc)
            bset         d6,(a0) 
            bset         d0,(a2) 
            bcc.s        l15(pc)
l14:        
            bchg         d6,(a0)
            bchg         d0,(a2) 
l15:
            dbra         d2,l6(pc) 
l7: 
            rts 
            end   

