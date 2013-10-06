* TCHOOM COPY
*************
 
 bra main

print macro \1
 pea \1
 move.w #9,-(sp)
 trap #1
 addq.l #6,sp
 endm
 
pushkey macro
 move.w #7,-(sp)
 trap #1
 addq.l #2,sp
 endm

read macro \1,\2
 lea.l $1d000,a6
 move.w #79,d7
 move.w #\1,d6
 move.w #\2,d5
 bsr read2
 endm

read2
 move.w #9,-(sp)
 move.w d5,-(sp)
 move.w d6,-(sp)
 move.w #1,-(sp)
 move.w #0,-(sp)
 clr.l -(sp)
 move.l a6,-(sp)
 move.w #8,-(sp)
 trap #14
 adda.l #20,sp
 cmpi.w #0,d0
 beq read3
 print error
 pushkey
read3
 adda.l #4608,a6
 addi.w #1,d6
 dbf d7,read2
 rts 

write macro \1,\2
 lea.l $1d000,a6
 move.w #79,d7
 move.w #\1,d6
 move.w #\2,d5
 bsr write2
 endm

write2
 move.w #9,-(sp)
 move.w d5,-(sp)
 move.w d6,-(sp)
 move.w #1,-(sp)
 move.w #0,-(sp)
 clr.l -(sp)
 move.l a6,-(sp)
 move.w #9,-(sp)
 trap #14
 adda.l #20,sp
 cmpi.w #0,d0
 beq write3
 print error2
 pushkey
write3
 adda.l #4608,a6
 addi.w #1,d6
 dbf d7,write2
 rts 

* initialise

main

 dc.w $a00a
* reserve memoire
* pour le buffer
 lea.l $1d000,a0
 move.w #23040,d0
reserve clr.l (a0)+
 clr.l (a0)+
 dbf d0,reserve

 move.w #1,-(sp)
 pea $78000
 pea $78000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp
 pea palette
 move.w #6,-(sp)
 trap #14
 addq.l #6,sp
 print intro_txt
 lea.l $60000,a0
 move.w #$18000/4-1,d0
clr clr.l (a0)+
 dbf d0,clr
 
* programme principal

 pushkey
 read 0,0
 print dest
 pushkey
 write 0,0
 print source
 pushkey
 read 0,1
 print dest
 pushkey
 write 0,1

 print fin
 pushkey

 clr -(sp)
 trap #1

palette even
 dc.w 0,$777,$700,$770
 dc.w $777,$777,$777,$777
 dc.w $777,$777,$777,$777
 dc.w $777,$777,$777,$777
intro_txt even
 dc.b "TCHOOM COPY:fast copy for unprotected disks. (C) 1992  TCHOOMSOFT"
 dc.b 10,10,10,13
 dc.b "> insert disk SOURCE"
 DC.B 10,10,13
 dc.b 0
dest even
 dc.b "> insert disk DESTINATION",10,10,13,0
source even
 dc.b "> insert disk SOURCE",10,10,13,0
error even
 dc.b "Erreur de lecture....",10,10,13,0
error2 even
 dc.b "Erreur d'ecriture....",10,10,13,0
fin even
 dc.b "> Copie terminee...",10,10,13,0
