CCONWS    equ 9
CNECIN    equ 8

START:    pea       clear
          move.w    #CCONWS,-(sp)
          trap      #1
          addq.l    #6,sp
          move.w    #22,d6
loop:     pea       STRING
          move.w    #CCONWS,-(sp)
          trap      #1
          addq.l    #6,sp
          addi.b    #1,y
          dbf       d6,loop
          move.w    #CNECIN,-(sp)
          trap      #1
          addq.l    #2,sp
          clr.w     -(sp)
          trap      #1

          .DATA 
clear:    .DC.b 27,"E",0
STRING:   .DC.b 27,"Y"
y:        .DC.b 32
x:        .DC.b 42
          .DC.b "DIES IST EIN TESTPROGRAMM ZUM DEMONSTRIEREN DER ESC-CODES"
          .DC.b 10,13,0
          .END 

