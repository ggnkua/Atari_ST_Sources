	move.l $4(a7),a5
	move.l #$300,-(sp)
	move.l a5,-(sp)
	clr.w -(sp)
	move.w #$4a,-(sp)
	trap #1
	pea text
	move.w #9,-(sp)
	trap #1
nei	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	cmp.b #$31,d0
	bne.s not31
	lea spit,a0
	bra.s load
not31	cmp.b #$32,d0
	bne nei
	lea spid,a0
load	pea xxx
	pea xxx
	move.l a0,-(sp)
	clr.w -(sp)
	move.w #$4b,-(sp)
	trap #1
xxx	dc.l $0,$f0f1f0f1
spit	dc.b "spitfire.prg",$0
spid	dc.b "ball.prg",$0
text	dc.b $d,$a,$d,$a,$d,$a,"Press 1 for Spitfire 40."
	dc.b $d,$a,$d,$a,"      2 for Spidertronic.",$d,$a
	dc.b $d,$a,"Hello 42-Crew,if you think the Blade",$d,$a
	dc.b "Runners are Europes No.1 cracking group",$d,$a
	dc.b "then go to hell.When you are undefeated",$d,$a
	dc.b "by the software companies then you can",$d,$a
	dc.b "boast.The Blade Runners consist of The",$d,$a
	dc.b "42-Crew,Hotline,STCS,MMC,Sirius,Mr Atari",$d,$a
	dc.b "TNT and The Gigabyte Crew,which makes a",$d,$a
	dc.b "hell of a lot of individuals.How many of",$d,$a
	dc.b "these individuals have perfectly cracked",$d,$a
	dc.b "such progs as for example,any release by",$d,$a
	dc.b "FTL? Well,I'll tell you.The answer is ",$d,$a
	dc.b "all of them,because they are Europes ",$d,$a
	dc.b "No.1 cracking group.All i want to know ",$d,$a
	dc.b "is who replaced 'plonkers' with ",$d,$a
	dc.b "'cracking group'." 