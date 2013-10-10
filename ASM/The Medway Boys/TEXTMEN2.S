	opt s-
	bra.s start
	dc.b "Little menu by GL 06/07/90",0,0
start	move.l a7,a6
	move.l 4(a6),a6
	pea $200
	pea (a6)
	pea $4a0000
	trap #1
	lea 12(sp),sp
	pea $0
	move.w #7,-(sp)
	trap #14
	lea 6(sp),sp
	pea $f0777
	move.w #7,-(sp)
	trap #14
	lea 6(sp),sp
	lea text(pc),a6
	bsr prtload
key	move.w #7,-(sp)
	trap #1
	lea 2(sp),sp
	cmp.b #'1',d0
	beq run1
	cmp.b #'2',d0
	beq run2
	cmp.b #'3',d0
	bne key
run3	lea load(pc),a6
	bsr prtload
	clr.b (text+118)
	lea (text+95)(pc),a6
	bsr prtload
	lea wait(pc),a6
	bsr prtload
	lea name3(pc),a6
	bra go
run2	lea load(pc),a6
	bsr prtload
	clr.b (text+81)
	lea (text+63)(pc),a6
	bsr prtload
	lea wait(pc),a6
	bsr prtload
	lea name2(pc),a6
	bra go
run1	lea load(pc),a6
	bsr prtload
	clr.b (text+49)
	lea (text+40)(pc),a6
	bsr prtload
	lea wait(pc),a6
	bsr prtload
	lea name1(pc),a6
go	pea env(pc)
	pea com(pc)
	pea (a6)
	pea $4b0000
	trap #1
	lea 16(sp),sp
	clr.w -(sp)
	trap #1
prtload	pea (a6)
	move.w #9,-(sp)
	trap #1
	lea 6(sp),sp
	rts
env	dc.l 0
com	dc.l 0
name1	dc.b 'starwars.prg',0,0
name2	dc.b 'return.prg',0,0
name3	dc.b 'empire.prg',0,0
load	dc.b 27,'f',27,'E'
	dc.b "Loading - ",0,0
wait	dc.b 10,10,13,'Please wait...',0
text	dc.b 27,'f',27,'E'
	dc.b 10,10,10,10,10,13
	dc.b "       Options:",10,10,10,13
	dc.b "       1 - Star Wars",10,10,13
	dc.b "       2 - Return of the Jedi",10,10,13
	dc.b "       3 - The Empire Strikes Back",10,10,10,13
	dc.b "       Please select 1 to 3",0
