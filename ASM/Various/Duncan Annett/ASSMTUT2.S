startup		move.l 4(sp),a3
		move.l $c(a3),d0
		add.l $14(a3),d0
		add.l $1c(a3),d0
		add.l #500,d0
		add.l #$100,d0
		move.l a7,oldstack
		lea endstack(pc),a7
		move.l d0,-(a7)
		move.l a3,-(a7)
		clr -(a7)
		move #$4a,-(a7)
		trap #1
		lea 12(sp),sp
				
setstuff	move.l #0,-(sp)
		move.l #$78000,-(sp)
		move.l #$78000,-(sp)
		move #5,-(sp)
		trap #14
		add.l #14,sp


printline	move.l #text,-(sp)
		move #9,-(sp)
		trap #1
		add.l #6,sp

input		move.l #inpstart,-(sp)
		move #$a,-(sp)
		trap #1
		add.l #6,sp
		lea buff(pc),a1
		add.w d0,a1
		move.b #0,(a1)		
	
openfile	move #0,-(sp)
		move.l #buff,-(sp)
		move #$3d,-(sp)
		trap #1
		add.l #8,sp
		
		tst d0
		bmi end
		move d0,handle

readpal		move.l #paldat,-(sp)
		move.l #34,-(sp)
		move handle,-(sp)
		move #$3f,-(sp)
		trap #1
		add.l #12,sp

setpal		move.l #paldat+2,-(sp)
		move #6,-(sp)
		trap #14
		add.l #6,sp


readpic		move.l physbase,-(sp)
		move.l #32000,-(sp)
		move handle,-(sp)
		move #$3f,-(sp)
		trap #1
		add.l #12,sp
		
		tst d0
		bmi end

closefile	move handle,-(sp)
		move #$3e,-(sp)
		trap #1
		add.l #4,sp
		tst d0
		beq wait

end		move.l oldstack,a7
		clr -(sp)
		trap #1

wait		move #7,-(sp)
		trap #1
		add.l #2,sp
		bra end

	even

newstack	ds.l 100
endstack	dc.l 0
oldstack	dc.l 0
text		dc.b "Name of picture? ",0
	even
inpstart	dc.b 12,0
buff		ds.b 15
	even
handle		dc.w 0
physbase	dc.l $78000
paldat		ds.w 17
