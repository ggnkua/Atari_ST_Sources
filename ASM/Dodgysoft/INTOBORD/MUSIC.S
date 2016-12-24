* archipelagos music- on line labelled 'playmus', values of d0 can
* be 0 for death tune, 1 for new screen tune, 2 for completed screen tune,
* 3 for countdown tune and 4,5,6,7,8,9,10,11 and 12 for different tunes.

music	INCBIN	"a:\intobord\music.mus"
playmus	moveq.l	#4,d0
	bsr	music
	move.l	$456.w,a0
	move.l	#music+14,4(a0)
	rts