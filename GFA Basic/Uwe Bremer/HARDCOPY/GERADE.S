          section   text
gerade:
          clr.l     d0
          move.l    4(sp),a0     ;varptr(druck$(0))
          move.w    12(sp),d0    ;ex% 
          move.w    14(sp),d1    ;ey%
          sub.w     8(sp),d0     ;ex%-ax%=dx
          sub.w     10(sp),d1    ;ey%-ay%=dy
          move.w    d0,d2        ;dx nach d2 ...       
          move.w    d1,d3        ;   ... und dy nach d3 retten
          cmpi.w    #0,d0        ;absolutbetrag bilden
          bge.s     l1(pc)
          neg.w     d0 
l1:   
          cmpi.w    #0,d1
          bge.s     l2(pc)
          neg.w     d1
l2:
          cmp.w     d1,d0
          bge.s     l3(pc)
          move.w    d1,d0
l3:
          moveq     #0,d1
l4:
          move.w    d2,d4
          move.w    d3,d5
          muls      d1,d4
          muls      d1,d5
          divs      d0,d4
          divs      d0,d5
          add.w     8(sp),d4
          bmi.s     l6(pc)
          cmpi.w    #1279,d4
          bgt.s     l6(pc)
          add.w     10(sp),d5
          bmi.s     l6(pc)
          cmpi.w    #799,d5
          bgt.s     l6(pc) 
          ext.l     d5
          divs      #8,d5
          move.l    a0,a1
          adda.w    d5,a1
          muls      #100,d4

          adda.l    d4,a1
          swap      d5
          moveq     #7,d6
          sub.b     d5,d6
          cmpi.w    #1,16(sp)     ;graphmode
          bgt.s     l5(pc)
          bset      d6,(a1)
          bcc.s     l6(pc)
l5:
          bchg      d6,(a1)
l6: 
          addq.w    #1,d1
          cmp.w     d0,d1
          ble.s     l4(pc)

          rts
          end           
