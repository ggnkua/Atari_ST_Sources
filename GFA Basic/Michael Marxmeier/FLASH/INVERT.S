*invert screen
 move.w #2,-(sp)
 trap #14
 adda.1 #2,sp
 movea.l d0,a0
 move.w #8000-1,d0
 loop
 not.l (a0)+
 dbra d0,loop
 rts
 
