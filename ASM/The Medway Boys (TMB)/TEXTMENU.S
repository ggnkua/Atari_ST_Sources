	opt s-
	move.l 4(sp),a0
	pea $200
	pea (a0)
	move.w #0,-(sp)
	move.w #$4a,-(sp)
	trap #1
	add.l #12,sp
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,$20.w
	moveq #1,d0
	bsr music
	move.l $70.w,$24.w
	move.l #int,$70.w
	clr.w $ffff8240.w
	clr.w $ffff825e.w
	pea text
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #$777,$ffff825e.w
key	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	cmp.b #'1',d0
	beq op1
	cmp.b #'2',d0
	beq op2 
	cmp.b #'3',d0
	beq op3
	cmp.b #'4',d0
	beq op4
	cmp.b #'0',d0
	bne key
	bchg #1,$ffff820a.w
	bra key
op4	lea name4,a6
	bra jj
op3	lea name3,a6
	bra jj
op2	lea name2,a6
	bra jj
op1	lea name1,a6
jj	move.l $24.w,$70.w
	move.w #7,-(sp)
	move.w #2,-(sp)
	trap #1
	addq.l #4,sp
	move.l $20.w,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	pea env
	pea com
	pea (a6)
	move.w #0,-(sp)
	move.w #$4b,-(sp)
	trap #1
	add.l #16,sp
	clr.w -(sp)
	trap #1
int	movem.l d0-a6,-(sp)
	bsr music+8
	movem.l (sp)+,d0-a6
	move.l $24.w,-(sp)
	rts
music	incbin 'c:\music\hmd.mus'
env	dc.l 0
com	dc.l 0
name1	dc.b 'athletic.prg',0,0
name2	dc.b ' ',0
name3	dc.b 'quiz.prg',0,0
name4	dc.b 'car.prg',0
text	dc.b 27,'E',27,'f'
	dc.b "       The Bad Brew Crew Menu 52",10,13
	dc.b "       ~~~~~~~~~~~~~~~~~~~~~~~~~",10,10,13
	dc.b "Select:",10,10,13
	dc.b "1. International Championship Athletics",10,10,13
	dc.b "2. International Cricket",10,10,13
	dc.b "3. Arcade Trivia Quiz",10,10,13
	dc.b "4. Radio Controlled Car",10,10,13
	dc.b "0. Toggle 50/60 Hz",10,10,10,13
	dc.b "Sorry about this crap menu, but Radio",10,13
	dc.b "Controlled Car would not run from ANY",10,13
	dc.b "other intro I tried !!!",10,10,10,13
	dc.b "All Coding effort is currently going",10,13
	dc.b "into the BBC Mega Demo..... So look",10,13
	dc.b "out for it soon !!"
	even
	dc.w 0
