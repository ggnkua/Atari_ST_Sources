***********************************************************************
*                                                                     *
*                STE Volume & Tone Control                            *
*                                                                     *
*                   by Morf, April 1993                               *
*                                                                     *
***********************************************************************
* system equates

gemdos		equ	$01
super		equ	$20
term		equ	$00

voltone_mask		equ	$ff8924
voltone_data		equ	$ff8922
**********************************************************************
* main program

* put data in variable space
	move.w	#$C0,(VT_data)		*set master vol to -80 dB

* enter super
	clr.l	-(SP)
	move.w	#super,-(SP)
	trap	#gemdos
	addq.l	#$06,SP
	move.l	D0,-(SP)

	move.w	VT_data,d0		*get value to send to VTC

	move.w	#$07ff,voltone_mask	*send mask to VTC
	or.w	#$400,d0		* put $04 in high byte
	move.w	d0,voltone_data

* exit supervisor mode
	move.w	#super,-(SP)
	trap	#gemdos
	addq.w	#$06,SP

* terminate
	move.w	#term,-(SP)
	trap	#gemdos

*************************************************************************
* variables for sample playback

VT_data		ds.w	$01	*data to send to volume+tone cnt
	end	
