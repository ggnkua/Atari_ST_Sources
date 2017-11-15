* uptade 1.0 sorry there were some bugs in the first patch
* little programm made by MIT from NeXT
* it catch the gfa lprint routine...
* because befor it was a fwrite with a handle -3.w
* ,so that's didn't work on FALCON 030 .......
* enjoy the gfa....

 bra debut
routine_lprint
 movem d0/d7,-(sp)
 move d0,d7
 subq #1,d7
 bmi.s .suite1
.loop
 movem.l d7/a1,-(sp)
 moveq #0,d0
 move.b (a1),d0
 move d0,-(sp)
 move #5,-(sp)
 trap #1
 addq #4,sp
 movem.l (sp)+,d7/a1
 addq #1,a1
 dbra d7,.loop
 move d0,d1
 movem (sp)+,d7/d0
 cmp.l #-1,d1
 beq.s .suite
 move.l d1,d0
.suite
 rts
.suite1
 movem (sp)+,d7/d0
 rts
debut0
 lea fincopy-copy(sp),sp
debut
 lea adr(pc),a0
 lea debut(pc),a1
 bsr reloge


 lea adr(pc),a0
 lea fin_adr,a1
.ch
 cmp.l a1,a0
 bge.s .quite_ch
 addq #2,a0
 cmp.l #$48512f00,(a0)
 bne.s .ch
 cmp.l #$3f3cfffd,4(a0)
 bne.s .ch
 cmp.l #$3f3c0040,8(a0)
 bne.s .ch
 cmp #$4e41,12(a0)
 bne.s .ch
 lea routine_lprint(pc),a1
 move #$4ef9,(a0)+
 move.l a1,(a0)+
.quite_ch
 
 
 lea copy(pc),a0
 lea fincopy(pc),a1
.cop
 move -(a1),-(sp)
 cmp.l a0,a1
 bne.s .cop
 lea adr+$1c(pc),a0
 lea debut(pc),a1
 lea fin_adr,a2
 lea debut0(pc),a3
 jmp (sp)

copy
 move.l (a0)+,(a1)+
 cmp.l a2,a0
 blt.s copy
 jmp (a3)
fincopy

reloge
* a0 truc a reloger
* a1 adr. ou reloger

* retour
* a2 adresse tableau symbolique

 move.l a0,a6
 add.l 2(a0),a6
 add.l 6(a0),a6
 move.l a6,a2 * tableau symbolique
 tst.l 14(a0)
 bne.s .pas_de_symbole
 move.l #-1,a2
.pas_de_symbole
 lea $1c(a6),a6
 add.l 14(a0),a6
 add.l (a6)+,a0
 lea $1c(a0),a0
 move.l a1,d1
 moveq #0,d0
.loop
 move.b (a6)+,d0
 beq.s .fin
 cmp.b #1,d0
 bne.s .rel
 lea 254(a0),a0
 bra.s .loop
.rel
 lea (a0,d0.w),a0
 add.l d1,(a0)
 bra.s .loop
.fin
 rts
 data
adr incbin gfabasic.prg
fin_adr
