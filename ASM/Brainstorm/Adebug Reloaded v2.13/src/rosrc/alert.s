	output	.ro
	text
	bra.s	main
	;to get logic screen
	dc.l	'PHYS'
	;to be called in USER mode
	dc.l	'USER'
	;end of flags
	dc.l	0
main:
	;form_alert
	move.w	#52,control
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#1,control+6

	;any parameters ?
	subq.w	#1,d0
	bmi.s	.no_parameters
	;first (optional) parameter is default button number
	move.l	(a1)+,d1
	ble.s	.no_parameters
	cmp.w	#3,d1
	bgt.s	.no_parameters
	move.w	d1,intin
	;second (optional) parameter is alert string
	subq.w	#1,d0
	bmi.s	.only_one_parameter
	move.l	(a1)+,addrin
	bra.s	.two_parameters
.no_parameters:
	move.w	#1,intin
.only_one_parameter:
	move.l	#alert_string,addrin
.two_parameters:
	move.l	#gem_array,d1
	move.w	#$c8,d0
	trap	#2
	;d0 is selected button number
	move.w	intout(pc),d0
	rts
	data
	even
gem_array:
	dc.l	control
	dc.l	global
	dc.l	intin
	dc.l	intout
	dc.l	addrin
	dc.l	addrout
alert_string:
	dc.b	"[1][Sample gem routine|(called in user)|(see logic screen too!)][1|2|3]",0
	bss
	even
control:	ds.w	4
global:	ds.w	14
intin:	ds.w	16
intout:	ds.w	7
addrin:	ds.w	6
addrout:	ds.w	6
	end

