optel=7
lijn=2
s:
bsr superon
;bclr #6,$fffa09
bclr #5,$fffa09
move.w #$2300,sr
bsr initb
bsr superof
illegal
initb:
move.l #tim_b,$120
or.b #1,$fffa07
or.b #1,$fffa13
move.l $70,old4+2
move.l #new4,$70
move.b #0,$fffa1b
rts
new4:
move.b #0,$fffa1b
move.b #lijn,$fffa21
move.b #8,$fffa1b
move.w #4,$ff8240
old4:
jmp $0

tim_b:
addq.w #optel,$ff8240
move.l a4,-(sp)
move.l #$fffffa1b,a4
;clr.b (a4)
move.b #lijn,6(a4)
;move.b #8,(a4)
bclr #0,$fffa0f
move.l (sp)+,a4
rte

superon:
clr.l -(sp)
move.w #$20,-(sp)
trap #1
addq.l #6,sp
move.l d0,save_st
rts
superof:
move.l save_st,-(sp)
move.w #$20,-(sp)
trap #1
addq.l #6,sp
rts
save_st:
blk.l 1,0

