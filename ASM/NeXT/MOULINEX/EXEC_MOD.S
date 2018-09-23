 opt d-,w-,o+
 output pres.prg
 jmp ok
; ds.b 100000           * c nul mais g pas le temps...
 					 * securite pour reciopie
ok
* module player
 pea debut(pc)
 move #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1
debut

 move #0,-(sp)
 move.l #-1,-(sp)
 move.l #-1,-(sp)
 move #5,-(sp)
 trap #14
 lea 12(sp),sp 
 
 move #$2300,sr
 lea $ffff8240.w,a6
 move #$777,(a6)
 moveq #6,d7
cou0
 rept 3
 move #$25,-(sp)
 trap #14
 addq.l #2,sp
 endr
 sub #$111,(a6)
 dbra d7,cou0   
* okay now exec mod file
 move #$2700,sr
 lea $7fffe,a7 
 lea file,a0
 lea $80.w,a1 
 move.l #(ffile-file)/4,d0 
.rec
 move.l (a0)+,(a1)+
 subq.l #1,d0
 bne.s .rec
 jsr $80.w
 move #$700,$ffff8240.w
.toi
 addq #1,$ffff8240.w 
 bra.s .toi
file
 incbin f:\krom_mit.prg\pres.dat
ffile