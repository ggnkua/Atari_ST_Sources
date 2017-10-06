			.TEXT
			.EXPORT aes, vdi
			.EXPORT vq_gdos, vq_vgdos

aes:	move.l	a0,d1		; pb in A0 und nicht auf Stack!
			move.w	#200,d0
			trap	#2
			rts

vdi:		move.l	a0,d1
			move.w	#115,d0
			trap	#2
			rts

vq_gdos:	move.w	#-2,d0
			trap	#2
			cmp.w	#-2,d0
			sne		d0
			ext.w	d0
			rts

vq_vgdos:	moveq	#-2,d0
 			trap    #2
			rts
