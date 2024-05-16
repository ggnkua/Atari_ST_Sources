* STe DMA looping sounds.
* A little demonstration by earx/fun.
* Please run in ST-LOW.

* Change to supervisor-mode.
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

* Play sample.
* First we set the sound-mode control register. We set it to mono, 12.5 KHz.
* We set bit 7, set the bit 1 and clear bit 0.
	andi.b	#%01111100,$ffff8921
	ori.b	#%10000001,$ffff8921
* Then we set the startaddress
	move.l	#sample_start,d0		* Move startaddress into d0.
	swap	d0				* Bring the high byte in d0.b.
* I moved the high byte into d0.b because first of all we MUST do the high
* byte!
	move.b	d0,$ffff8903			* Move the high byte of the address.
* Then we do the mid byte of the address.
	rol.l	#8,d0				* Bring the mid byte in d0.b.
	move.b	d0,$ffff8905			* Move the mid byte of the address.
* Finally, we do the low byte.
	rol.l	#8,d0				* Bring the low byte in d0.b.
	move.b	d0,$ffff8907			* Move the low byte of the address.
* OK, the startaddress is done, now for the endaddress.
* It's basicly the same as the startaddress, but with a different label and
* different registers.
	move.l	#sample_end,d0			* Move endaddress into d0.
	swap	d0				* Bring the high byte in d0.b.
* I moved the high byte into d0.b because first of all we MUST do the high
* byte!
	move.b	d0,$ffff890f			* Move the high byte of the address
* Then we do the mid byte of the address.
	rol.l	#8,d0				* Bring the mid byte in d0.b.
	move.b	d0,$ffff8911			* Move the mid byte of the address.
* Finally, we do the low byte.
	rol.l	#8,d0				* Bring the low byte in d0.b.
	move.b	d0,$ffff8913			* Move the low byte of the address.
* Now to trigger the playback of the sample.
* We set bit 0 to trigger playback and set bit 1 to turn looping on.
	ori.w	#%0000000000000011,$ffff8900

* Execute the main loop.
main_loop:
	cmpi.b	#$39,$fffffc02.w		* Spacebar pressed?
	bne	main_loop			* If not, keep looping.

* Stop playing sample.
* We clear bit 0 to stop playing.
	andi.w	#%0000000000000001,$ffff8900

* Terminate program.
	clr.w	-(sp)
	trap	#1

	DATA

sample_start:
	INCBIN	LEXOHOND.SPL			* This is the sample we want.
sample_end: