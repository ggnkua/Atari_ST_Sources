;*******************************************************************************
;	This program is free software; you can redistribute it and/or modify it
;	under the terms of the GNU General Public License as published by the Free
;	Software Foundation; either version 2 of the License, or any later version.
;	This program is distributed in the hope that it will be useful, but WITHOUT
;	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
;	more details.
;	You should have received a copy of the GNU General Public License along
;	with this program; if not, write to the Free Software Foundation, Inc.,
;	59 Temple Place - Suite 330, Boston, MA 02111, USA.
;******************************************************************************

EXPORT	_bmove

;******************************************************************************
;
;	void _bmove(long a,long b,long l);
;
;	Bmove. Rout by Megar/BNR (Gilles Bouthenot).
;		even addresses run faster than odd addresses
;
;	Plus d'obligation que les adresses soient paires, mais c'est quand
;	mˆme conseill‚ car ca prend BEAUCOUP moins de temps.
;	la longueur doit ˆtre pleinement g‚r‚e. (entre 0 et 2^32-1)
;
;	params:	a0:	source start address
;				a1:	target start address
;				d0:	lenght in bytes (1 means 1 byte copied)
;
;******************************************************************************
_bmove:
	tst.l		d2
	beq		END
	movem.l	a0-a6/d0-d7,-(sp)	;‚ventuellement, sauver en Ram plutot que dans la pile
	move.l	d0,a0
	move.l	d1,a1
	move.l	d2,d0
	move.l	a0,d2
	move.l	a1,d3

	cmpa.l	a0,a1
	blo.s	lower
noeven:						;higher: last byte first !
	lea.l		0(a0,d0.l),a0	;source end
	lea.l		0(a1,d0.l),a1	;target end
	moveq		#0,d1
	btst		#0,d2
	beq.s		.ok1
	addq.b	#1,d1
.ok1:
	btst		#0,d3
	beq.s		.ok2
	addq.b	#1,d1
.ok2:
	btst		#0,d0
	beq.s		.ok3
	addq.b	#1,d1
.ok3:
	tst.b		d1
	beq.s		.even
	cmp.b		#3,d1
	bne		hi_odd
	move.b	-(a0),-(a1)
	subq.l	#1,d0
	beq.s		.The_End
.even:
	divu		#48,d0	;d0=reste|nbr
	beq.s		.e
	subq.w	#1,d0
.nb:
	lea.l		-48(a0),a0
	movem.l	(a0),d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-(a1)
	dbf		d0,.nb
.e:
	swap		d0			;d1=reste
	tst.w		d0
	beq.s		.The_End
	subq.w	#2,d0
	bcs.s		.byte
	lsr.w		d0			;C mis si il reste un octet … transf‚rer
	bcs.s		.c2
.c:
	move.w	-(a0),-(a1)
	dbf		d0,.c
.The_End:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.c2:
	move.w	-(a0),-(a1)
	dbf		d0,.c2
.byte:
	move.b	-(a0),-(a1)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

lower:					;first byte first !
;a0=source
;a1=dest
;d0=len
	moveq		#0,d1
	btst		#0,d2
	beq.s		.ok1
	moveq		#1,d1
.ok1:
	btst		#0,d3
	beq.s		.ok2
	addq.b	#1,d1
.ok2:
	cmp.b		#1,d1
	blt.s		alleven
	beq.s		lo_odd
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	beq.s		The_End
	
alleven:
	divu		#48,d0	;d0=reste|nbr
	beq.s		.e
	subq.w	#1,d0
.nb:
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a1)
	lea.l		48(a1),a1
	dbf		d0,.nb
.e:
	swap		d0	;d1=reste
	tst.w		d0
	beq.s		The_End
	subq.w	#2,d0	;soustraire 2 … d0
	bcs.s		.byte
	lsr.w		d0		;C mis si il reste un octet … transf‚rer
	bcs		.c2
.c:
	move.w	(a0)+,(a1)+
	dbf		d0,.c
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.c2:
	move.w	(a0)+,(a1)+
	dbf		d0,.c2
.byte:
	move.b	(a0)+,(a1)+	

The_End:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

hi_odd:
	subq.l	#1,d0
	move.l	d0,d1
	swap		d1	
.c:
	move.b	-(a0),-(a1)
	dbf		d0,.c
	dbf		d1,.c
	movem.l	(sp)+,d0-d7/a0-a6
	rts

lo_odd:
	subq.l	#1,d0
	move.l	d0,d1
	swap		d1
.c:
	move.b	(a0)+,(a1)+
	dbf		d0,.c
	dbf		d1,.c
	
	movem.l	(sp)+,d0-d7/a0-a6
END:
	rts
