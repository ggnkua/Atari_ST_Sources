start   bra atex 
   dc.b "* LITTLE PROTECTION NUMBER 2.06 BY GL! *" 
atex   lea (start-$100)(pc),a6 
   lea (super+2)(pc),a5 
   move.l sp,(a5) 
   move.w sr,d0 
   btst #$d,d0 
   bne super 
   clr.l -(sp) 
   move.w #$20,-(sp) 
   trap #1 
   move.l d0,(a5) 
   bra super 
setup   move.l a6,$43a.w 
   lea saved(pc),a0 
   move.b $fffffa07.w,(a0)+ 
   move.b $fffffa09.w,(a0)+ 
   move.l $70.w,(a0)+ 
   move.b #2,$ffff820a.w 
   move.w #$2700,sr 
   clr.b $fffffa07.w 
   clr.b $fffffa09.w 
   lea int(pc),a0 
   move.l a0,$70.w 
   lea trace(pc),a0 
   lea super(pc),a1 
   lea $77000,a2 
.1   move.w (a0)+,(a2)+ 
   cmp.l a1,a0 
   bne.s .1 
   rts 
trace   add.w (sp),d7 
   sub.b (a0),d7 
   move.l $24.w,a1 
   lea super(pc),a2 
.1   move.w (a1)+,d0 
   eor.w d0,d7 
   ror.l #3,d7 
   add.l a0,d7 
   add.l a2,d7 
   sub.l a3,d7 
   add.l a4,d7 
   move.l a1,d1 
   eor.l d1,d7 
   eor.l d0,d7 
   eor.l d2,d7 
   eor.l d3,d7 
   eor.l d4,d7 
   eor.l d5,d7 
   eor.l d6,d7 
   not.l d7 
   cmp.l a2,a1 
   bne.s .1 
   add.l $10.w,d6 
   eor.l d6,d7 
   rol.l #7,d6 
   eor.l d6,$10.w 
   eor.l d7,d6 
   eor.l d7,d5 
   eor.l d7,d4 
   eor.l d7,d3 
   eor.l d7,d2 
   eor.l d7,d1 
   eor.l d7,d0 
   add.l d7,a3 
   sub.l a3,a4 
   sub.b (a0),d0 
   and.w #$ff,d0 
.2   dbf d0,.2 
   eor.l d7,(a5) 
   ror.l #7,d7 
   move.l 2(sp),a6 
   add.b (a0),d7 
   move.w sr,d0 
   eor.b d0,d7 
   eor.l d7,(a6) 
   move.l a6,a5 
int   rte 
super   lea 0,sp 
   bsr setup 
   move.l #$77000,$24.w 
   move.l #$12345678,$10.w 
   movem.l regs(pc),d0-a6 
   stop #$2300 
   stop #$2300 
   move.w #$2700,sr 
wp   move.b (a0),d1 
   beq.s wp 
   sub.b d1,d0 
   lsl.b d0,d0 
   lea super(pc),a5 
   move.w #$a700,sr 
   bra.s tracer 
regs   dc.l $10,'ENJO','Y TH','E TR','ACE/','SYNC' 
   dc.l ' ROU','TINE',$ffff8209,'AND ','HAVE' 
   dc.l 'A NI','CE D','AY!!','*GL*' 
tracer   dc.l $d3a3a2ef,$09b8e923,$24d0d210,$7ba80828 
   dc.l $9abba91b,$0732bbf8,$a5abad01,$027a0247 
   dc.l $a73b5768,$10fa556f,$3ab83a03,$bde93fa5 
   dc.l $f8e2319e,$5a45f8a2,$490df9c9,$41220d6a 
   dc.l $a8a81c43,$5bb9cb38,$8ae83eb5,$d61cbea7 
   dc.l $11573290,$5b6c398b,$c79cc0a1,$43b1a8b7 
   dc.l $28a31fd3,$704a35fb,$3048704c,$c1865baa 
   dc.l $ebb0bb7b,$704258d8,$e5ebfa29,$2cd61013 
   dc.l $701602e5,$55e16a26,$e4b57044,$19077c76 
   dc.l $37344169,$c6495dae,$5a833fe0,$74a3e3ef 
   dc.l $dff33bc5,$76234251,$071b6508,$c38ee84c 
   dc.l $620385f2,$55cad363,$80d9c07c,$16251da0 
   dc.l $c50db123,$8e425afe,$7094bbe6,$1c42aaf3 
   dc.l $90b6b87e,$1659c023,$efa3ad9c,$05a0be21 
   dc.l $40614dab,$a1dded5b,$e31650c8,$a0f8a73c 
   dc.l $a1d57f73,$8eb83eb0,$0f59338d,$aad5af83 
   dc.l $9e62e1d8,$8fdb045a,$45f89879,$eb7e1628 
   dc.l $4708ec69,$f90281ed,$80a7e8cc,$628fc9af 
   dc.l $ddce07f4,$aebb1a3a,$cfdd4efe,$76dfef3b 
   dc.l $23413e78,$c0dc1d4e,$187c449c,$3196917f 
   dc.l $ce855b73,$2657513e,$74c44e69,$3bf96bf6 
   dc.l $094f5571,$07f49458,$9b2cd9a8,$a1fd39f8 
   dc.l $0fdd089d,$f71d7795,$6b9f523a,$56bf78d5 
   dc.l $40d3ea18,$5fb895b2,$b157c45b,$cf1535ed 
   dc.l $f48099d1,$ffd612f3,$7f78e665,$aaa22859 
   dc.l $adf62384,$8230a812,$0ffea911,$1f317abc 
   dc.l $a931cb0f,$2246a818,$23489ac9,$0a19fecb 
   dc.l $8416f31b,$9ac6601d,$891dde80,$a81ad945 
   dc.l $453819ac,$bce8af50,$a9f5e632,$c5a09d71 
   dc.l $9a83a8cb,$c8ea944a,$9a7bce42,$338a3bc0 
   dc.l $516c6abe,$92710c1b,$018bcd7a 
   dc.w $912c

