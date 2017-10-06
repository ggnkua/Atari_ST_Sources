				.globl	_aes
				.globl	_vdi
				.globl	_vq_gdos
				.globl	_vq_vgdos

_aes:		movel	sp@(4), d1		| hier kommt pb Åber den Stack!
				movew	#200, d0
				trap	#2
				rts

_vdi:			movel	sp@(4), d1
				movew	#115, d0
				trap	#2
				rts

_vq_gdos:		movew	#-2,d0
				trap	#2
				cmpw	#-2,d0
				sne		d0
				extw	d0
#ifndef __MSHORT__
				extl	d0
#endif
				rts

_vq_vgdos:		moveq	#-2,d0
 				trap    #2
				rts
