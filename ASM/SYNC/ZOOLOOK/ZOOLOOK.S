* Zoolook muzak by Mad Max
* Ripped by Red Fox of Sync
* Must be loaded on $72000!!!
* Jsr $72000 to start it -
* Jsr $72006 to stop it...
*
* (Old but good muzak...)
*
* Written looong time ago. I was a member in PWC. Of course you can
* play it on an other adress. But only if you can relocate it!
* 
* -- GIVE RED FOX THE CREDITS FOR THE RIPPING AND MAD MAX FOR THE MUZAX -- 		
*
* SYNC SYNC SYNC SYNC SYNC SYNC SYNC SYNC SYNC SYNC SYNC SYNC SYNC SYNC *
*
start:	clr.l	-(sp)		* set supervisor
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	move.l	d0,ssp

	move.l	#muzak,a0		* muzak to $72000
	move.l	#$72000,a1
	move.l	#$981,d0
muzloop:	move.l	(a0)+,(a1)+
	dbf	d0,muzloop

	jsr	$72000

wait_key:	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	jsr	$72006

	move.l	ssp,-(sp)		* set user
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp

	clr.l	-(sp)
	trap	#1

ssp:	ds.l	1
muzak:	incbin	'a:\zoolook\zoolook.msc'
	