 dc.w $a000

 move #160,-602(a0) 
loop
 move -602(a0),d0
 lsr d0
 move d0,-602(a0)

 tst -596(a0)
 beq loop 
   
 clr -(sp)
 trap #1
 
 
string
 dc.b $0C,1,10
string_end 