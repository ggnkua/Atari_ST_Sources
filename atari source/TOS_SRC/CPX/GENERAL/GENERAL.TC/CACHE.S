*
*	turns the cache on or off
*	or status

	.text
	.globl	cacheon
	.globl	cacheoff
	.globl	cacheinq
	

CACHE_ON	equ	$00003919
CACHE_OFF	equ	$00000808

*
*	donoise	Set console noise bits
*
*	param 0 = click on/off (word)
*	param 1 = bell on/off (word)
*
cacheon:   move.l   #CACHE_ON,d0	;Enable data/instruc caches 
	   .dc.w    $4e7b, $0002	;MOVEC.L d0,CACR turn on cache
	   rts

cacheoff:  move.l   #CACHE_OFF,d0	;Disable data/instruc caches
	   .dc.w    $4e7b, $0002	;MOVEC.L d0,CACR turn off cache
	   rts

cacheinq:  .dc.w    $4e7a,$0002		; Inquire data/instruc caches
	   rts				; value returned in D0
	   
	.end

