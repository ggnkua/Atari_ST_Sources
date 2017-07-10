*** loading
disk_write
 lea buffer_disk,a0
 moveq #0,d1
 move.l a0,a4
 bsr drive

 moveq #1,d7
 bsr waitinf0
 bsr fdc_wait
 tst d1
 bmi .erreur
* moveq #1,d7
* bsr waitinf0
* bsr fdc_wait
* tst d1
* bmi .erreur

 moveq #1,d4
.loopr0

* on met n piste ds data reg. puis seek sur la piste
 move #$86,$ffff8606.w
 move d4,$ffff8604.w
 bsr wait

* seek
 move #$80,$ffff8606.w
 moveq #$10,d7
 bsr waitinf0a
 bsr fdc_wait

 moveq #1,d5
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
 move #$90,$ffff8606.w
 move #$190,$ffff8606.w
 move #$1f,$ffff8604.w

 move #$180,$ffff8606.w
 move #$a0,d7
 bsr waitinf0a
 bsr fdc_wait
 tst d1
 bmi.s .erreur
 lea 512(a4),a4
 addq #1,d5
 cmp #10,d5
 ble.s .loopr
 addq #1,d4
 cmp #2,d4
 ble.s .loopr0
.erreur
 bsr fina
 rts

fina
 move #$80,$ffff8606.w
.fon
 bsr wait
 move $ffff8604.w,d0
 btst #7,d0
 bne.s .fon
 bsr driveoff
 rts

 
wait
 moveq #5,d6
.loop
 dbra d6,.loop
 rts

waitinf0
 move #$80,$ffff8606.w
waitinf0a
 bsr wait
 move d7,$ffff8604.w
 bsr wait
 rts

fdc_wait
 moveq #6,d7 * on gagne de la place..
 swap d7    *  et du temps... m'enfin!
.waitinf1
 subq.l #1,d7   * test si time out...
 beq.s .timeout  * si oui , aille ! time out
 btst #5,$fffffa01.w
 bne.s .waitinf1
 bsr .test_dma
 rts
.timeout
 moveq #-1,d1
 rts
.test_dma
* take status register
 move #$80,$ffff8606.w
 move $ffff8604.w,d0
 btst #0,d0      * erreur dma
 bne.s .timeout
 btst #6,d0      * protection ecriture 
 bne.s .timeout
 btst #4,d0      * erreur CRC
 bne.s .timeout
 rts

fdc_waitread
 moveq #6,d7 * on gagne de la place..
 swap d7    *  et du temps... m'enfin!
.waitinf1
 subq.l #1,d7   * test si time out...
 beq.s .timeout  * si oui , aille ! time out
 btst #5,$fffffa01.w
 bne.s .waitinf1
 bsr .test_dma
 rts
.timeout
 moveq #-1,d1
 rts
.test_dma
* take status register
 move #$80,$ffff8606.w
 move $ffff8604.w,d0
 btst #0,d0      * erreur dma
 bne.s .timeout
 btst #4,d0      * erreur CRC
 bne.s .timeout
 rts



* selction des drive et de la face
* bits : 
* 0: face 0/1
* 1:lecteur A
* 2:lecteur B
driveoff
 moveq #0,d6
 bra.s drive1
drive
 move n_drive,d6
drive1
 eor #%111,d6
 moveq #14,d7
 swap d7
 move d6,d7
 lsl.l #8,d7
 lea $ffff8800.w,a6
 move.l d7,(a6)
 rts
