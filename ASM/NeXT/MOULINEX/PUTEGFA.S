de
*** pour le dbuging
 jmp aille(pc)
adrdebut
 dc.l 0  *adr debut buffer
adrfin
 dc.l 0  *adr fin buffer
adrdebutboucle
 dc.l 0  *adr debut boucle
adrfinboucle
 dc.l 0  *adr fin boucle
ordre
 dc.w 0  *ordre ???? 

aille
 opt w-,o+,d+

 pea debut(pc)
 move #$26,-(sp)
 trap #14
 addq.l #6,sp
 rts
debut

* type de support exterieur present ...
 move #$2700,sr
 lea adr_replay(pc),a0
 move.l adrdebut(pc),(a0)
 
 lea s_smfp(pc),a1
 move.b $fffffa07.w,(a1)+
 move.b $fffffa09.w,(a1)+
 move.b $fffffa13.w,(a1)+
 move.b $fffffa17.w,(a1)+
 clr.b $fffffa07.w
 clr.b $fffffa09.w

* init yamaha ...
 lea $ffff8800.w,a0
 move.l #00000000,(a0)
 move.l #01000000,(a0)
 move.l #02000000,(a0)
 move.l #03000000,(a0)
 move.l #04000000,(a0)
 move.l #05000000,(a0)
 move.l #06000000,(a0)
 move.b #7,(a0)
 lea sym(pc),a1
 move.b 2(a0),(a1)
 move.b #$ff,2(a0)

 move.b #2,$fffffa19.w
 move.b #24,$fffffa1f.w
 bclr #3,$fffffa17.w
 bset #5,$fffffa07.w
 bset #5,$fffffa13.w
; bset #6,$fffffa09.w
; bset #6,$fffffa15.w

 lea s_134(pc),a0
 move.l $134.w,(a0)

 lea routine_timer_a(pc),a0
 move.l a0,$134.w

; lea s_118(pc),a0
; move.l $118.w,(a0)
; lea n118(pc),a0
; move.l a0,$118.w

; lea s_70(pc),a0
; move.l $70.w,(a0)
; lea vbl(pc),a0
; move.l a0,$70.w

 lea space(pc),a0
 clr (a0)
 move #$2300,sr
att
; tst.b (a0)
 ;beq.s att
 dcb 100,$4e71
 cmp #$b9,$fffffc02.w
 bne att
; move #7,-(sp)
; trap #1
; addq.l #2,sp

 move.w #$2700,sr
 lea $ffff8800.w,a0
 move.b #7,(a0)
 move.b sym,2(a0)

 move #$777,$ffff8240.w 

; lea s_118(pc),a0
; move.l (a0),$118.w

 lea s_134(pc),a0
 move.l (a0),$134.w

; lea s_70(pc),a0
 ;move.l (a0),$70.w

 move.b s_smfp(pc),$fffffa07.w
 move.b s_smfp+1(pc),$fffffa09.w
 move.b s_smfp+2(pc),$fffffa13.w
 move.b s_smfp+3(pc),$fffffa17.w
 move.w #$2300,sr
 rts

Routine_timer_a
 movem.l d0-d2/a0-a2,-(sp)
 
 lea adr_replay(pc),a0
 move.l (a0),a1
 lea adrfin(pc),a2
 cmp.l (a2),a1
 blt.s ok
 lea ordre(pc),a2
 tst (a2)
 beq.s oups
 lea space(pc),a2
 move.b #1,(a2)
 bra end_timer
oups
 move.l adrdebutboucle(pc),(a0)
 move.l adrfinboucle(pc),(a2)
ok
 addq.l #1,(a0)

 tst (a2)
 beq.s rep
 move.b $fffb0001,(a1)
rep
 moveq #0,d0
 move.b (a1)+,d0
 lsl #3,d0
 lea $ffff8800.w,a0
 move.l digitab(pc,d0.w),(a0)
 move.l digitab+4(pc,d0.w),d1
 movep.l d1,(a0)
end_timer
 movem.l (sp)+,d0-d2/a0-a2
 rte

n118
 move.l a0,-(sp)
 btst #5,$fffffc00.w
 bne.s end_118
 btst #0,$fffffc00.w
 beq.s end_118
 cmp.b #$b9,$fffffc02.w
 bne.s end_118
 lea space(pc),a0
 move.b #1,(a0)
end_118
 move.l (sp)+,a0
vbl
 rte
 
digitab  incbin digital.bin
 even

adr_replay ds.l 1
s_smfp ds.l 1
space ds.w 1
sym ds.w 1  
s_70 ds.l 1
s_134 ds.l 1
s_118 ds.l 1
fin