*	Created by TT-Digger v7.1
*	Wed Oct 17 15:04:06 2007

	globl	_ulmul, _uldiv, _ulmod, _lmul, _ldiv, _lmod
.MODULE _ulmul

	move.l	d0,d2
	swap	d2
	tst	d2
	bne.s	L18898
	move.l	d1,d2
	swap	d2
	tst	d2
	bne.s	L18888
	mulu	d1,d0
	rts

L18888:
	mulu	d0,d2
	swap	d2
	mulu	d1,d0
	add.l	d2,d0
	rts

L18898:
	mulu	d1,d2
	swap	d2
	mulu	d1,d0
	add.l	d2,d0
	rts

.ENDMOD
.MODULE _uldiv

	move.l	d1,d2
	swap	d2
	tst	d2
	bne.s	L18956
	move.l	d0,d2
	swap	d2
	tst	d2
	bne.s	L18934
	divu	d1,d0
	swap	d0
	clr	d0
	swap	d0
	rts

L18934:
	clr	d0
	swap	d0
	swap	d2
	divu	d1,d0
	movea	d0,a0
	move	d2,d0
	divu	d1,d0
	swap	d0
	move	a0,d0
	swap	d0
	rts

L18956:
	movea.l	d1,a0
	swap	d0
	moveq	#0,d1
	move	d0,d1
	clr	d0
	moveq	#15,d2
	add.l	d0,d0
	addx.l	d1,d1
L18972:
	sub.l	a0,d1
	bcc.s	L18978
	add.l	a0,d1
L18978:
	addx.l	d0,d0
	addx.l	d1,d1
	dbf	d2,L18972
	not	d0
	rts

.ENDMOD
.MODULE _ulmod

	move.l	d1,d2
	swap	d2
	tst	d2
	bne.s	L19032
	move.l	d0,d2
	swap	d2
	tst	d2
	bne.s	L19014
	divu	d1,d0
	clr	d0
	swap	d0
	rts

L19014:
	clr	d0
	swap	d0
	swap	d2
	divu	d1,d0
	move	d2,d0
	divu	d1,d0
	clr	d0
	swap	d0
	rts

L19032:
	movea.l	d1,a0
	move.l	d0,d1
	clr	d0
	swap	d0
	swap	d1
	clr	d1
	moveq	#15,d2
	add.l	d1,d1
	addx.l	d0,d0
L19050:
	sub.l	a0,d0
	bcc.s	L19056
	add.l	a0,d0
L19056:
	addx.l	d1,d1
	addx.l	d0,d0
	dbf	d2,L19050
	roxr.l	#1,d0
	rts

.ENDMOD
.MODULE _lmul

	move.l	d0,d2
	bpl.s	L19074
	neg.l	d0
L19074:
	eor.l	d1,d2
	movea.l	d2,a0
	tst.l	d1
	bpl.s	L19084
	neg.l	d1
L19084:
	move.l	d0,d2
	swap	d2
	tst	d2
	bne.s	L19126
	move.l	d1,d2
	swap	d2
	tst	d2
	bne.s	L19110
	mulu	d1,d0
	move.l	a0,d2
	bpl.s	L19108
	neg.l	d0
L19108:
	rts

L19110:
	mulu	d0,d2
	swap	d2
	mulu	d1,d0
	add.l	d2,d0
	move.l	a0,d2
	bpl.s	L19124
	neg.l	d0
L19124:
	rts

L19126:
	mulu	d1,d2
	swap	d2
	mulu	d1,d0
	add.l	d2,d0
	move.l	a0,d2
	bpl.s	L19140
	neg.l	d0
L19140:
	rts

.ENDMOD
.MODULE _ldiv

	move.l	d0,d2
	bpl.s	L19148
	neg.l	d0
L19148:
	eor.l	d1,d2
	movea.l	d2,a1
	tst.l	d1
	bpl.s	L19158
	neg.l	d1
L19158:
	move.l	d1,d2
	swap	d2
	tst	d2
	bne.s	L19218
	move.l	d0,d2
	swap	d2
	tst	d2
	bne.s	L19190
	divu	d1,d0
	swap	d0
	clr	d0
	swap	d0
	move.l	a1,d2
	bpl.s	L19188
	neg.l	d0
L19188:
	rts

L19190:
	clr	d0
	swap	d0
	swap	d2
	divu	d1,d0
	movea	d0,a0
	move	d2,d0
	divu	d1,d0
	swap	d0
	move	a0,d0
	swap	d0
	move.l	a1,d2
	bpl.s	L19216
	neg.l	d0
L19216:
	rts

L19218:
	movea.l	d1,a0
	swap	d0
	moveq	#0,d1
	move	d0,d1
	clr	d0
	moveq	#15,d2
	add.l	d0,d0
	addx.l	d1,d1
L19234:
	sub.l	a0,d1
	bcc.s	L19240
	add.l	a0,d1
L19240:
	addx.l	d0,d0
	addx.l	d1,d1
	dbf	d2,L19234
	not	d0
	move.l	a1,d2
	bpl.s	L19256
	neg.l	d0
L19256:
	rts

.ENDMOD
.MODULE _lmod

	movea.l	d0,a1
	move.l	d0,d2
	bpl.s	L19266
	neg.l	d0
L19266:
	tst.l	d1
	bpl.s	L19272
	neg.l	d1
L19272:
	move.l	d1,d2
	swap	d2
	tst	d2
	bne.s	L19326
	move.l	d0,d2
	swap	d2
	tst	d2
	bne.s	L19302
	divu	d1,d0
	clr	d0
	swap	d0
	move.l	a1,d2
	bpl.s	L19300
	neg.l	d0
L19300:
	rts

L19302:
	clr	d0
	swap	d0
	swap	d2
	divu	d1,d0
	move	d2,d0
	divu	d1,d0
	clr	d0
	swap	d0
	move.l	a1,d2
	bpl.s	L19324
	neg.l	d0
L19324:
	rts

L19326:
	movea.l	d1,a0
	move.l	d0,d1
	clr	d0
	swap	d0
	swap	d1
	clr	d1
	moveq	#15,d2
	add.l	d1,d1
	addx.l	d0,d0
L19344:
	sub.l	a0,d0
	bcc.s	L19350
	add.l	a0,d0
L19350:
	addx.l	d1,d1
	addx.l	d0,d0
	dbf	d2,L19344
	roxr.l	#1,d0
	move.l	a1,d2
	bpl.s	L19366
	neg.l	d0
L19366:
	rts


