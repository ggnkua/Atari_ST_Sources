*************************************************
**                                             **
** ... on steadfastly 			       **
**       holding your ground                   **
**             against the relentless 	       **
**                  onslaught of the masses... **
**                                             **
*************************************************


	output	.tos

	section	text

demo:
		lea	code(pc),a0
		moveq	#-1,d7
.cgen:			move.l	#$46788240,(a0)+
			dbf	d7,.cgen
		move.l	#$6000fffe-128*15,(a0)
	
		move.w	#32,-(sp)
		trap	#1
		move.w	#$2700,sr

	section	bss

code:		ds.b	300000
