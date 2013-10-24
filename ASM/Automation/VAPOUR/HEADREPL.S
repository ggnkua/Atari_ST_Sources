;ok now tht disk b has been packed we need to put the headers back
;on the front of the files which are still as original format on disk a
;assemble code to memory and run with disk a in drive to begin with
;all files in tab will be loaded (headers only) into memory and will
;then be put on the front of the disk b files
;now that you have done all this assembly your trap depack code and
;all being well the game should work fine
;setup is for stos *.mbk files with header #$12
	lea tab(pc),a5
	lea $80000,a6
cnt
	bsr read
	lea $12(a6),a6	;$12 is header size
lp2	tst.b (a5)+
	bne.s lp2
	cmp.b #$ff,(a5)	;ff is end of table
	bne.s cnt
;after read there should be a table of headers for all files in
;tab now stashed at $80000 to....
	lea tab(pc),a5
	move.l a6,a4
	lea $80000,a6
;insert disk b of packed data and the headers will be added and the
;files resaved with header on the front
cnt2	bsr read2
	bsr write
lp	tst.b (a5)+
	bne.s lp
	cmp.b #$ff,(a5)
	bne.s cnt2
	clr.w -(sp)
	trap #1	;return to genst
read	move.b #$41,(a5)	
	clr.w -(sp)
	pea (a5)
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
	move.w d0,d5
	pea (a6)
	pea $12		;alter for size of header being used
	move.w d5,-(sp)
	move.w #$3f,-(sp)
	trap #1
	lea 12(sp),sp
	move.w d5,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	rts
read2	move.b #$42,(a5)	
	clr.w -(sp)
	pea (a5)
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
	move.w d0,d5
	pea (a4)
	pea $7ffff
	move.w d5,-(sp)
	move.w #$3f,-(sp)
	trap #1
	lea 12(sp),sp
	move.l d0,d7
	move.w d5,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	rts
write	move.b #$42,(a5)	
	clr.w -(sp)
	pea (a5)
	move.w #$3c,-(sp)
	trap #1
	addq.l #8,sp
	move.w d0,d5
	pea (a6)
	move.l #$12,-(sp)	;alter for size of header being used
	move.w d5,-(sp)
	move.w #$40,-(sp)
	trap #1
	lea 12(sp),sp
	pea (a4)
	move.l d7,-(sp)
	move.w d5,-(sp)
	move.w #$40,-(sp)
	trap #1
	lea 12(sp),sp
	move.w d5,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	lea $12(a6),a6	;wading thru table at $80000 plus so
;alter $12 to size of header being used
;mookie - compare my gp manager files to those of your version
;and you will see the benefits of this packing method
	rts

tab
	dc.b 'A:logo.mbk',0
	dc.b 'A:title.mbk',0
	dc.b 'A:titlemsk.mbk',0
	dc.b 'A:rm00.mbk',0
	dc.b 'A:rm00msk.mbk',0
	dc.b 'A:rm01.mbk',0
	dc.b 'A:rm01msk.mbk',0
	dc.b 'A:rm02.mbk',0
	dc.b 'A:rm02msk.mbk',0
	dc.b 'A:rm03.mbk',0
	dc.b 'A:rm03msk.mbk',0
	dc.b 'A:rm04.mbk',0
	dc.b 'A:rm04msk.mbk',0
	dc.b 'A:rm05.mbk',0
	dc.b 'A:rm05msk.mbk',0
	dc.b 'A:rm06.mbk',0
	dc.b 'A:rm07.mbk',0
	dc.b 'A:rm07msk.mbk',0
	dc.b 'A:rm08.mbk',0
	dc.b 'A:rm08msk.mbk',0
	dc.b 'A:rm09.mbk',0
	dc.b 'A:rm09msk.mbk',0
	dc.b 'A:rm10.mbk',0
	dc.b 'A:rm10msk.mbk',0
	dc.b 'A:rm11.mbk',0
	dc.b 'A:rm11msk.mbk',0
	dc.b 'A:rm12.mbk',0
	dc.b 'A:rm12msk.mbk',0
	dc.b 'A:rm13.mbk',0
	dc.b 'A:rm14.mbk',0
	dc.b 'A:rm14msk.mbk',0
	dc.b 'A:rm17.mbk',0
	dc.b 'A:rm17msk.mbk',0
	dc.b 'A:rm18.mbk',0
	dc.b 'A:rm18msk.mbk',0
	dc.b 'A:rm19.mbk',0
	dc.b 'A:rm19msk.mbk',0
	dc.b 'A:rm20.mbk',0
	dc.b 'A:rm20msk.mbk',0
	dc.b 'A:rm21.mbk',0
	dc.b 'A:rm21msk.mbk',0
	dc.b 'A:rm22.mbk',0
	dc.b 'A:rm22msk.mbk',0
	dc.b 'A:rm23.mbk',0
	dc.b 'A:rm23msk.mbk',0
	dc.b 'A:rm24.mbk',0
	dc.b 'A:rm25.mbk',0
	dc.b 'A:rm25msk.mbk',0
	dc.b $ff	;table terminator	