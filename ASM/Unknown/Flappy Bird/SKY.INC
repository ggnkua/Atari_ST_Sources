
;Sky

	SECTION	TEXT
	
;----------------------------------
;Initialise sky
skyinit
	move.w	#0,skydaynight					;Always start with day sky
	move.l	#skydayimg,skyimg
	bra		skycreatepreshift				;(does RTS)

;----------------------------------
;Create random sky
skyrandomsky
	bsr		utilrandbyte					;Get random value in d0.b
	and.w	#3,d0							;25% chance of night sky
	beq.s	.nightsky
	move.w	#0,skydaynight
	move.l	#skydayimg,skyimg
	bra		skycreatepreshift				;(does RTS)
	
.nightsky
	move.w	#1,skydaynight
	move.l	#skynightimg,skyimg
	bra		skycreatepreshift				;(does RTS)
	
;----------------------------------
;Create sky preshifts combined with pipe column
skycreatepreshift
	moveq.w	#11,d0							;Height
	moveq.w	#8,d1							;Number of copies (ie repeat)
	lea		pipeskyspr,a0					;Source pipe column sprite
	move.l	skyimg,a1						;Source sky
	lea		80*17(a1),a1					;Starting line for clouds
	lea		pipesky1preshift,a2				;Destination preshift
	bsr		preshiftcalcpipesky

	moveq.w	#19,d0
	moveq.w	#2,d1
	lea		pipeskyspr,a0
	move.l	skyimg,a1
	lea		80*28(a1),a1
	lea		pipesky2preshift,a2
	bsr		preshiftcalcpipesky
	
	moveq.w	#9,d0
	moveq.w	#4,d1
	lea		pipeskyspr,a0
	move.l	skyimg,a1
	lea		80*47(a1),a1
	lea		pipesky3preshift,a2
	bra		preshiftcalcpipesky				;(does RTS)

;----------------------------------

	SECTION	BSS

skydaynight		ds.w	1					;0 for day, 1 for night
skyimg			ds.l	1					;Sky image, ie skydayimg or skynightimg
