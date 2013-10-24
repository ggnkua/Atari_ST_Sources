;assemble to memory then run with source disk in drive and a blank
;disk ready as disk b
;when finished pack disk b as data and goto headrepl.s
;enter filenames into tab
;all files must have the same size header to be removed
;assemble several times if doing various sized headers or rewrite
;this code accordingly
;src is currently setup to remove #$12 bytes from front of stos *.mbk files

	lea tab(pc),a5
cnt
	bsr read	;read in file off disk a
	bsr write	;save without header to disk b
lp	tst.b (a5)+
	bne.s lp
	cmp.b #$ff,(a5)	;ff is end of table
	bne.s cnt
	clr.w -(sp)
	trap #1		;back to genst
read	move.b #$41,(a5)	
	clr.w -(sp)
	pea (a5)
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
	move.w d0,d5
	pea $80000
	pea $70000
	move.w d5,-(sp)
	move.w #$3f,-(sp)
	trap #1
	lea 12(sp),sp
	move.l d0,d7
	sub.l #$12,d7	;subtract header size from total size
;to leave filesize to save to disk b
;alter #$12 to suit header to be removed
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
	pea $80012	;save address.note header stored at $80000-$80011
;alter this address to suit header being removed
	move.l d7,-(sp)
	move.w d5,-(sp)
	move.w #$40,-(sp)
	trap #1
	lea 12(sp),sp
	move.w d5,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
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
	dc.b $ff	;all done	