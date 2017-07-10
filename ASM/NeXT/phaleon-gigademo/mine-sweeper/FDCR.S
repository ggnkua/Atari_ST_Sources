*** loading
* d3 nb secteur to read
* d4 nb piste to begin
* d5 nb secteur to begin
disk_read
 moveq #0,d1
 move.l a0,a4
 bsr drive

 moveq #1,d7
 bsr waitinf0
 bsr fdc_waitread
 tst d1
 bmi .erreur

 bra.s .loopr0a
.loopr0
 moveq #1,d5
.loopr0a

* on met n piste ds data reg. puis seek sur la piste
 move #$86,$ffff8606.w
 move d4,$ffff8604.w
 bsr wait

* seek
 move #$80,$ffff8606.w
 moveq #$10,d7
 bsr waitinf0a
 bsr fdc_waitread

.loopr
** fo mettre a jour le registre de secteur
 move #$84,$ffff8606.w
 bsr wait
 move d5,$ffff8604.w
 bsr wait

* on met l'adr. de destination ds les reg. du dma..
 move.l a4,d6
 move.b d6,$ffff860d.w
 lsr #8,d6
 move.b d6,$ffff860b.w
 swap d6
 move.b d6,$ffff8609.w

* on s'amuse avec le dma sect count
 move #$190,$ffff8606.w
 move #$90,$ffff8606.w
 move #$1f,$ffff8604.w

 move #$80,$ffff8606.w
 move #$80,d7
 bsr waitinf0a
 bsr fdc_waitread
 tst d1
 bmi.s .erreur
 lea 512(a4),a4

 
 subq #1,d3
 beq.s .erreur
 addq #1,d5
 cmp #10,d5
 ble.s .loopr
 addq #1,d4
 bra .loopr0
.erreur
 bsr fina

 rts
