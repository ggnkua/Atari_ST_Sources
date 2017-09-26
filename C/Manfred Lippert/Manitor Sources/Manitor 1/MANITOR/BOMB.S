.export new_2bomb
.export old_2bomb
.export new_3bomb
.export old_3bomb
.export new_4bomb
.export old_4bomb
.export new_5bomb
.export old_5bomb
.import fillbuf

.data
TXTLEN_2BOMB = 20
txt_2bomb: dc.b 13,10,13,10,"** BUS ERROR",13,10,13,10
TXTLEN_3BOMB = 25
txt_3bomb: dc.b 13,10,13,10,"*** ADDRESS ERROR",13,10,13,10
TXTLEN_4BOMB = 27
txt_4bomb: dc.b 13,10,13,10,"**** ILLEGAL OPCODE",13,10,13,10
TXTLEN_5BOMB = 30
txt_5bomb: dc.b 13,10,13,10,"***** DIVISION BY ZERO",13,10,13,10

.TEXT
.EVEN
.SUPER

/********* Neuer 2-Bomben-Vektor ***********/

dc.l 'XBRA'
dc.l 'MANI'
old_2bomb: ds.l 1
new_2bomb:
	movem.l d0-a6,-(sp)
	moveq #TXTLEN_2BOMB,d0
	lea.l txt_2bomb,a0
	bsr fillbuf
	movem.l (sp)+,d0-a6
	move.l old_2bomb, -(sp)
	rts

/********* Neuer 3-Bomben-Vektor ***********/

dc.l 'XBRA'
dc.l 'MANI'
old_3bomb: ds.l 1
new_3bomb:
	movem.l d0-a6,-(sp)
	moveq #TXTLEN_3BOMB,d0
	lea.l txt_3bomb,a0
	bsr fillbuf
	movem.l (sp)+,d0-a6
	move.l old_3bomb, -(sp)
	rts

/********* Neuer 4-Bomben-Vektor ***********/

dc.l 'XBRA'
dc.l 'MANI'
old_4bomb: ds.l 1
new_4bomb:
	movem.l d0-a6,-(sp)
	moveq #TXTLEN_4BOMB,d0
	lea.l txt_4bomb,a0
	bsr fillbuf
	movem.l (sp)+,d0-a6
	move.l old_4bomb, -(sp)
	rts

/********* Neuer 5-Bomben-Vektor ***********/

dc.l 'XBRA'
dc.l 'MANI'
old_5bomb: ds.l 1
new_5bomb:
	movem.l d0-a6,-(sp)
	moveq #TXTLEN_5BOMB,d0
	lea.l txt_5bomb,a0
	bsr fillbuf
	movem.l (sp)+,d0-a6
	move.l old_5bomb, -(sp)
	rts
