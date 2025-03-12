	opt s-
start	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,oldstk
	bclr #0,$484
	move.l $70,oldint
	moveq #1,d0
	bsr music	
	move.l #int,$70
	clr.w $ffff8240.w
	move.w #$777,$ffff825e.w
	clr.l $380.w
	lea crack(pc),a0
	lea $140.w,a1
	lea oldstk(pc),a2
cc	move.w (a0)+,(a1)+
	cmp.l a2,a0
	bne.s cc
	move.l #$140,$80.w
	lea text(pc),a0
	bsr print
	cmp.b #'t',d0
	bne.s notr
	lea train0(pc),a0
	bsr print
	cmp.b #'y',d0
	seq.b $380.w
	lea train1(pc),a0
	bsr print
	cmp.b #'y',d0
	seq.b $381.w
	lea train2(pc),a0
	bsr print
	cmp.b #'1',d0
	blt.s notr
	cmp.b #'4',d0
	bgt.s notr
	sub.b #'1',d0
	move.b d0,$383.w
notr	move.l oldint,$70
	bset #0,$484
	move.l #$08080000,$ffff8800.w
	move.l #$09090000,$ffff8800.w
	move.l #$0a0a0000,$ffff8800.w
	move.l oldstk,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp  
	clr.w -(sp)
	trap #1
print	pea (a0)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	or.b #$20,d0
	rts
int	movem.l d0-d7/a0-a6,-(sp)
	bsr (music+8)
	movem.l (sp)+,d0-d7/a0-a6
	move.l $84.w,$24.w
	move.l oldint,-(sp)
	rts
crack	move.l 2(sp),a0
	lea -2(a0),a0
	move.l a0,2(sp)
	move.w #$4eb9,(a0)
	move.w $382.w,$100(a0)
	tst.b $380.w
	beq.s .1
	move.w #$6006,$2d4(a0)
.1	tst.b $381.w
	beq.s .2
	add.l #$1489e,a0
	move.l #$4e714e71,(a0)
	move.w #$6004,$20(a0)
.2	rte
oldstk	dc.l 0
oldint	dc.l 0
music	incbin "c:\music\hmd.mus"
text	dc.b 27,'f',27,'E'
	dc.b "Cynix Present",10,13
	dc.b "~~~~~~~~~~~~~",10,10,13
	dc.b "Erik",10,10,13
	dc.b "Hacked and Trained by Absu",10,13
	dc.b "Original supplied by Quaser",10,10,13
	dc.b "Press 'T' for Trainer",10,10,10,13
	dc.b "Hi to:",10,13
	dc.b "Replicants (Are you guys still going?),",10,13
	dc.b "D-Bug (Good talking to you again Rob!),",10,13
	dc.b "Elite (Nice hack on Cool Croc Twins!!),",10,13
	dc.b "Next (Nice menus on Phaleon Demo!),",10,13
	dc.b "Superior (Great compacts),",10,13
	dc.b "Pompey Pirates (Nice Toxic Monst!!),",10,13
	dc.b "Sinister Developments (Great Asteroids",10,13
	dc.b "conversion.... Send them œ5 now!!!)",0
train0	dc.b 27,'f',27,'E'
	dc.b "Trainer Options",10,13
	dc.b "~~~~~~~~~~~~~~~",10,10,13
	dc.b "Do you want infinite lives (y/n) ?",0
train1	dc.b 10,10,13,"Do you want free items in shops (y/n) ?",0
train2	dc.b 10,10,13,"Enter your start level (1-4) ?",0

