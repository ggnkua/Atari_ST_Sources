* d0 nb de secteurs a load‚ du disk...
* d1 numero de la piste a partir de laquelle il faut load‚
* d2 numero du secteur … partir duquel il faut load‚
* d3 drive et face
*     bit 0 face 0 ou 1
*     bit 1 drive 0 on ou off
*     bit 2 drive 1 on ou off
* a0 adresse … partir de laquel il faut load‚

*** loading
load_from_disk
 move.l a0,a4
nbsec=10

 lea $ffff8604.w,a0
 lea $ffff8606.w,a1
 lea $ffff8609.w,a2
 lea $ffff8800.w,a6

 bsr drive

 moveq #1,d7         * restore ;
 bsr waitinf0
 moveq #1,d7         * restore ;
 bsr waitinf0


* on met l'adr. de destination ds les reg. du dma..
 move.l a4,d6
 move.b d6,4(a2)
 lsr #8,d6
 move.b d6,2(a2)
 swap d6
 move.b d6,(a2)

.loop0

* on met n piste ds data reg. puis seek sur la piste
 move #$86,(a1)
 move d1,(a0)
 bsr wait

* seek

 move #$80,(a1)
 moveq #$10,d7
 bsr waitinf0

.loop1
* move d0,-(sp)
* bsr vsync
* move (sp)+,d0

* on s'amuse avec le dma sect count
 move #$190,(a1)
 move #$90,(a1)
 move #1,(a0)

** fo mettre a jour le registre de secteur
 move #$84,(a1)
 move d2,(a0)
 bsr wrd2

 move #$80,d7
 bsr waitinf0

 subq #1,d0
 bmi.s .fin_load
 addq #1,d2
 cmp #nbsec,d2
 ble.s .loop1

 moveq #1,d2
 addq #1,d1
 cmp #82,d1
 blt .loop0
 or #1,d3
 moveq #0,d1
 bsr drive
 bra .loop0
.fin_load

 bsr fin
 rts

fin
 move #$80,(a1)
.fon
 bsr wait
 move (a0),d0
 btst #7,d0
 bne.s .fon
 moveq #%00,d3  *tt off..
 bsr drive
 rts

 
wait
 moveq #40,d6
.loop
 dbra d6,.loop
 rts

wrd1
* d7 est ce ki il y a a mettre en 04.
 move d7,(a0)
 bsr wait
wrd2
 rts
 
waitinf0
 move #$80,(a1)
 move d7,(a0)
waitinf
 moveq #6,d7 * on gagne de la place..
 swap d7    *  et du temps... m'enfin!
*
waitinf1
 subq.l #1,d7   * test si time out...
 beq.s timeout  * si oui , aille ! time out
 btst #5,$fffffa01.w
 bne.s waitinf1
okinf
 rts
timeout
 rts

* selction des drive et de la face
* bits : 
* 0: face 0/1
* 1:lecteur A
* 2:lecteur B
drive
 moveq #%0,d6
 or d3,d6
 eor #%111,d6
 moveq #14,d7
 swap d7
 move d6,d7
 lsl.l #8,d7
 move.l d7,(a6)
 rts
