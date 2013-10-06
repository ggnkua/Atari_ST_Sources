;;;;;;;;;;;;;;;;;;;;;;;;;;
; formateur de disquette ;
; by tchoom/arkham	 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;

 move.w #7,-(sp)
 trap #1
 addq.l #2,sp
 
 move.w #79,d7
format
 move.w #$e5e5,-(sp)
 move.l #$87654321,-(sp)
 move.w #1,-(sp)
 move.w #0,-(sp)
 move.w d7,-(sp)
 move.w #9,-(sp)
 move.w #0,-(sp)
 clr.l -(sp)
 pea buffer
 move.w #10,-(sp)
 trap #14
 add.l #26,sp

 move.w #$e5e5,-(sp)
 move.l #$87654321,-(sp)
 move.w #1,-(sp)
 move.w #1,-(sp)
 move.w d7,-(sp)
 move.w #9,-(sp)
 move.w #0,-(sp)
 clr.l -(sp)
 pea buffer
 move.w #10,-(sp)
 trap #14
 add.l #26,sp

 dbf d7,format

 move.w #7,-(sp)
 trap #1
 addq.l #2,sp
 clr -(sp)
 trap #1

buffer
 ds.b $2000 