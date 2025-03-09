/* RCLIB.S
   (c) 1991 MAXON Computer
*/
         globl rc_equal
         globl rc_copy
         globl rc_intersect
         globl rc_inside
         globl rc_grect_to_array


g_x=0;
g_y=2;
g_w=4;
g_h=6;

xmin1 = -16
ymin1 = -14
xmin2 = -12
ymin2 = -10
xmax1 = -8
ymax1 = -6
xmax2 = -4
ymax2 = -2


         text

rc_equal:
         move.l (a0)+,d0
         cmp.l (a1)+,d0
         bne notequal      ;x- und y-Koordinaten unterschiedlich
         move.l (a0),d0
         cmp.l (a1),d0
         bne notequal      ;Breite und Hîhe unterschiedlich
         moveq #1,d0       ;Flag fÅr Gleichheit
         rts
notequal:
         clr d0            ;Flag fÅr Ungleichheit
         rts


rc_copy:
         move.l (a0)+,(a1)+
         move.l (a0),(a1)
         rts


rc_intersect:
         link a6,#-16
         move g_y(a0),d0
         cmp g_y(a1),d0
         bcc skip
         move.l g_x(a0),xmin1(a6)
         move g_x(a0),d0
         add g_w(a0),d0
         move d0,xmax1(a6)
         move g_y(a0),d0
         add g_h(a0),d0
         move d0,ymax1(a6)
         move.l g_x(a1),xmin2(a6)
         move g_x(a1),d0
         add g_w(a1),d0
         move d0,xmax2(a6)
         move g_y(a1),d0
         add g_h(a1),d0
         move d0,ymax2(a6)
         bra skp
skip:
         move.l g_x(a0),xmin2(a6)
         move g_x(a0),d0
         add g_w(a0),d0
         move d0,xmax2(a6)
         move g_y(a0),d0
         add g_h(a0),d0
         move d0,ymax2(a6)
         move.l g_x(a1),xmin1(a6)
         move g_x(a1),d0
         add g_w(a1),d0
         move d0,xmax1(a6)
         move g_y(a1),d0
         add g_h(a1),d0
         move d0,ymax1(a6)
skp:     move ymin2(a6),d0
         cmp ymax1(a6),d0
         bcc ret
         move xmin1(a6),d0
         cmp xmax2(a6),d0
         bcc ret
         move xmin2(a6),d0
         cmp xmax1(a6),d0
         bcc ret
         move xmin1(a6),d0
         move xmin2(a6),d1
         cmp d1,d0
         bcc.b (*)+4
         move d1,d0
         move d0,g_x(a1)
         move ymin1(a6),d0
         move ymin2(a6),d1
         cmp d1,d0
         bcc.b (*)+4
         move d1,d0
         move d0,g_y(a1)
         move xmax1(a6),d0
         move xmax2(a6),d1
         cmp d1,d0
         bcs.b (*)+4
         move d1,d0
         move d0,g_w(a1)
         move ymax1(a6),d0
         move ymax2(a6),d1
         cmp d1,d0
         bcs.b (*)+4
         move d1,d0
         move d0,g_h(a1)
         move g_x(a1),d0
         sub d0,g_w(a1)
         move g_y(a1),d0
         sub d0,g_h(a1)
         moveq #1,d0       ;Flag fÅr öberlappung
         unlk a6
         rts
ret:     clr d0            ;Flag fÅr keine öberlappung
         unlk a6
         rts


rc_inside:
         move g_x(a0),d2
         cmp d2,d0
         bcs outside
         add g_w(a0),d2
         cmp d2,d0
         bcc outside
         move g_y(a0),d2
         cmp d2,d1
         bcs outside
         add g_h(a0),d2
         cmp d2,d1
         bcc outside
         moveq #1,d0       ;TRUE, falls innerhalb
         rts
outside: clr d0            ;FALSE, falls auûerhalb
         rts


rc_grect_to_array:
         move.l g_x(a0),(a1)+
         movem (a0)+,d0-d1
         add (a0)+,d0
         subq #1,d0
         add (a0),d1
         subq #1,d1
         movem d0-d1,(a1)
         rts
