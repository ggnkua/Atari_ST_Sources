* Test, ob GDOS anwesend ist; RÅckgabe: 1 (Ja) oder 0 in d0

          xdef      GDOS_HERE
GDOS_HERE:move.w    #-2,d0
          trap      #2
          cmp.w     #-2,d0
          sne       d0
          ext.w     d0
          rts
