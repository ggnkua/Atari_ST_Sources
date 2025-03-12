*************************************************************************
*		File Integrity Checksum Creator				*
*		-------------------------------				*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*			½ Persistence Of Vision 1997			*
*************************************************************************
*
* Version 1 written Feb 1997
*
* Modification history:
*
* Name:		Mod:
*
*
*
* Description:
*             This program will calculate a file's CRC for use with the
*             POV's File Integrity Checker program.
*
*
*
*************************************************************************

	bra.s	advert
 dc.b	"********POV CRC CALCprog        (c)MSD  ********"
advert
	include	aesmakro.s

* First we have to let GEM know that it can use all memory except the
* memory this program is using
	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	$c(a5),d0	;text segment
	add.l	$14(A5),d0	;data segment
	add.l	$1c(A5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

	move.l	sp,old_stack	;store old stack
	move.l	#mystack,sp	;we have to make our own stack or this will bomb out!
main_loop
	dc.w	$a00a		;no mouse
	lea	cls,a0
	bsr	print_string
	lea	opening_message,a0
	bsr	print_string
	dc.w	$a009		;yes mouse
	lea	fil_extend(PC),a3	;let user select filename
	bsr	file_select
	move.w	int_out+2,button	;button number
	tst.b	button+1	;was CANCEL selected?
	beq.s	quit		;yes

	dc.w	$a00a		;no mouse
	lea	cls,a0
	bsr	print_string
	lea	opening_message,a0
	bsr	print_string
	dc.w	$a009		;yes mouse

	bsr	open_file
	tst.l	d0
	bmi	error_open
	bsr	read_file
	tst.l	d0
	bmi	error_read
	bsr	close_file
	lea	filename_txt,a0
	bsr	print_string
	lea	my_file,a0
	bsr	print_string
	lea	working,a0
	bsr	print_string
	bsr	calc_crc
	lea	crcis,a0
	bsr	print_string
	bsr	print_crc

	bsr	press_key	;wait for key
	bra	main_loop
quit	move.l	old_stack,a7	;restore old stack value
	clr.w	-(sp)		;get out of here
	trap	#1


calc_crc
	lea	filestart,a0
	move.l	file_length,d0
	moveq	#0,d1
loop	add.b	(a0)+,d1
	rol.l	#1,d1
	sub.l	#1,d0
	bne.s	loop
	move.l	d1,crc
	rts

open_file
	clr.w	-(sp)
	pea	my_file
	move.w	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	move.w	d0,handle
	rts

error_open
	lea	openerr,a0
	bsr	print_string
	bsr	press_key
	bra	main_loop

read_file
	pea	filestart
	move.l	#$ffffff,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	move.l	d0,file_length
	rts

error_read
	lea	readerr,a0
	bsr	print_string
	bsr	press_key
	bra	main_loop

close_file
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq	#4,sp
	rts



print_crc	lea	number8+1(pc),a4
		moveq	#0,d1
		move.l	crc,d2
		rept	4
		move.b	d2,d1
		and.b	#$f,d1
		move.b	d1,-(a4)
		move.b	d2,d1
		lsr.w	#4,d1
		move.b	d1,-(a4)
		lsr.l	#8,d2
		endr

	lea	number1(pc),a5
	rept	8
	move.l	a5,a0
	bsr	print_char
	add.w	#1,a5
	endr
		rts

;On entry needs the default extender address in A3
file_select
	movem.l	a0-a2/D1-d3,-(a7)
	bsr.s	get_dir
	lea	my_path(PC),a2
	tst.b	(a2)+
	beq.s	.2
.1	tst.b	(a2)+
	bne.s	.1
.2	move.b	#"\",-1(a2)
.3	move.b	(a3)+,(a2)+
	bne.s	.3
	fsel	my_path,my_file,label
	tst.w	int_out+2
	beq.s	.4
	bsr.s	set_dir
	moveq	#0,d0
	bra.s	.5
.4	moveq	#-1,d0
.5	movem.l	(a7)+,a0-a2/D1-d3
	rts

; get directory
get_dir	movem.l	a0-a2,-(a7)
	lea	my_path(PC),a1
	move.l	a1,a2
	move.w	#200-1,d0	;path can be 200 bytes long (for CD-ROM users)
.clr_path
	clr.b	(a1)+
	dbf	d0,.clr_path
	move.w	#$19,-(a7)	;get current drive
	trap	#1
	addq.w	#2,a7
	add.w	#"A",d0		;first device is always A
	move.b	d0,(a2)+	;store device letter in path
	move.b	#":",(a2)+	;now put ":" in path
	clr.w	-(a7)		;default drive number
	pea	(a2)		;address of buffer to store path
	move.w	#$47,-(a7)
	trap	#1		;get path
	addq.w	#8,a7
	movem.l	(a7)+,a0-a2
	rts

; set directory
set_dir	lea	my_path(pc),a1
	move.l	a1,a2
	moveq	#0,d0
	move.b	(a1)+,d0	;get first byte from my_path
	pea	(a1)		;put the address of the rest of path on stack
	subi.w	#"A",d0		;remove 'A' to get device number
	move.w	d0,-(sp)	;put device of stack
	move.w	#$E,-(sp)	;set default drive
	trap	#1
	addq.w	#4,sp
	move.l	(a7)+,a1	;get address of rest of path from stack
.1	move.b	(a1)+,d0	;end of path?
	beq.s	.2		;yes
	cmp.b	#"*",d0		;do we have a * yet
	bne.s	.1		;no
	clr.b	-(a1)		;yes so clear end of path
.2	pea	my_path(PC)	;path
	move.w	#$3B,-(a7)	;set current dir
	trap	#1
	addq.w	#6,a7
	rts


set_up_ctrl
	move.l	a0,-(a7)
	move.w	d0,control
	sub.w	#10,d0
	lea	gem_ctrl_list(pc),a0
	lsl.w	#2,d0
	move.l	(a0,d0.w),d0
	lea	control(pc),a0
	movep.l	d0,3(a0)
	move.l	(a7)+,a0
	rts	


call_aes
	lea	params(PC),a0
	move.l	a0,d1
	move.w	#$C8,d0
	trap	#2
	move.w	int_out(pc),d0
	rts

print_char
	move.b	(a0),d4		;get raw hex
	and.w	#$f,d4		;get so it is a byte
	cmp.b	#$a,d4		;is it 10?
	blt.s	.ok		;yes
	add.w	#7,d4		;no less than 10 so add a bit!
.ok	add.w	#"0",d4		
	move.b	d4,char
	lea	char,a0

print_string
	movem.l	d0-d7/a0-a6,-(sp)
	dc.w	$a00a
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	d0-d7/a0-a6,-(sp)
	dc.w	$a009
	movem.l	(sp)+,d0-d7/a0-a6
	rts

press_key
	lea	press_key_mess,a0
	bsr	print_string
get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

	SECTION DATA
cls	dc.b	27,'E',0,0
crlf	dc.b	13,10,0

opening_message
 dc.b	27,'E'
 dc.b	27,'Y',32+0,32+22,"File Integrity Checker CRC calculator"
 dc.b	27,'Y',32+1,32+22,"-------------------------------------"
 dc.b	27,'Y',32+3,32+14+20,"Version 1.0"
 dc.b	0

press_key_mess
 dc.b	27,'Y',32+20,32+28,"Press a key to continue.",0

filename_txt
 dc.b	27,'Y',32+8,32+29,"Filename: ",0

working
 dc.b	27,'Y',32+10,32+35,"Working...",0
	even

crcis
 dc.b	27,'Y',32+10,32+32,"CRC is:          ",27,'Y',32+10,32+40,0
	even

openerr
 dc.b	27,'Y',32+10,32+25,"ERROR opening file, try again.",0
	even

readerr
 dc.b	27,'Y',32+10,32+25,"ERROR reading file, try again.",0
	even

my_path		dc.b	"C:\folder\*.*",0
		ds.b	200
	even
my_file		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0
fil_extend	dc.b	'*.*',0		;default file extender
	even
label		dc.b	"Select a file",0
	even

*GEM stuff
params	dc.l	control
	dc.l	global
	dc.l	int_in
	dc.l	int_out
	dc.l	addr_in
	dc.l	addr_out
	dc.l	bye

gem_ctrl_list
	dc.b	0,1,0,0	10
	dc.b	2,1,1,0	11
	dc.b	2,1,1,0	12
	dc.b	0,1,1,0	13
	dc.b	2,1,1,0	14
	dc.b	1,1,1,0	15
	dc.b	0,0,0,0	16*
	dc.b	0,0,0,0	17*
	dc.b	0,0,0,0	18*
	dc.b	0,1,0,0	19
	dc.b	0,1,0,0	20
	dc.b	3,5,0,0	21
	dc.b	5,5,0,0	22
	dc.b	0,1,1,0	23
	dc.b	2,1,0,0	24
	dc.b	16,7,1,0	25
	dc.b	2,1,0,0	26
	dc.b	0,0,0,0	27*
	dc.b	0,0,0,0	28*
	dc.b	0,0,0,0	29*
	dc.b	1,1,1,0	30
	dc.b	2,1,1,0	31
	dc.b	2,1,1,0	32
	dc.b	2,1,1,0	33
	dc.b	1,1,2,0	34
	dc.b	1,1,1,0	35
	dc.b	0,0,0,0	36*
	dc.b	0,0,0,0	37*
	dc.b	0,0,0,0	38*
	dc.b	0,0,0,0	39*
	dc.b	2,1,1,0	40
	dc.b	1,1,1,0	41
	dc.b	6,1,1,0	42
	dc.b	4,1,1,0	43
	dc.b	1,3,1,0	44
	dc.b	2,1,1,0	45
	dc.b	4,2,1,0	46
	dc.b	8,1,1,0	47
	dc.b	0,0,0,0	48*
	dc.b	0,0,0,0	49*
	dc.b	1,1,1,0	50
	dc.b	9,1,0,0	51
	dc.b	1,1,1,0	52
	dc.b	1,1,0,0	53
	dc.b	0,5,1,0	54
	dc.b	3,3,1,0	55
	dc.b	2,2,1,0	56
	dc.b	0,0,0,0	57*
	dc.b	0,0,0,0	58*
	dc.b	0,0,0,0	59*
	dc.b	0,0,0,0	60*
	dc.b	0,0,0,0	61*
	dc.b	0,0,0,0	62*
	dc.b	0,0,0,0	63*
	dc.b	0,0,0,0	64*
	dc.b	0,0,0,0	65*
	dc.b	0,0,0,0	66*
	dc.b	0,0,0,0	67*
	dc.b	0,0,0,0	68*
	dc.b	0,0,0,0	69*
	dc.b	4,3,0,0	70
	dc.b	8,3,0,0	71
	dc.b	6,1,0,0	72
	dc.b	8,1,0,0	73
	dc.b	8,1,0,0	74
	dc.b	4,1,1,0	75
	dc.b	3,1,1,0	76
	dc.b	0,5,0,0	77
	dc.b	1,1,1,0	78
	dc.b	0,5,0,0	79
	dc.b	0,1,1,0	80
	dc.b	0,1,1,0	81
	dc.b	0,0,0,0	82*
	dc.b	0,0,0,0	83*
	dc.b	0,0,0,0	84*
	dc.b	0,0,0,0	85*
	dc.b	0,0,0,0	86*
	dc.b	0,0,0,0	87*
	dc.b	0,0,0,0	88*
	dc.b	0,0,0,0	89*
	dc.b	0,2,2,0	90
;	dc.b	0,2,3,0	91
;	dc.b	0,0,0,0	92*
;	dc.b	0,0,0,0	93*
;	dc.b	0,0,0,0	94*
;	dc.b	0,0,0,0	95*
;	dc.b	0,0,0,0	96*
;	dc.b	0,0,0,0	97*
;	dc.b	0,0,0,0	98*
;	dc.b	0,0,0,0	99*
;	dc.b	5,1,0,0	100
;	dc.b	5,1,0,0	101
;	dc.b	1,1,0,0	102
;	dc.b	1,1,0,0	103
;	dc.b	2,5,0,0	104
;	dc.b	6,1,0,0	105
;	dc.b	2,1,0,0	106
;	dc.b	1,1,0,0	107
;	dc.b	6,5,0,0	108
;	dc.b	0,0,0,0	109
;	dc.b	0,1,1,0	110
;	dc.b	0,1,0,0	111
;	dc.b	2,1,0,1	112 ** Control(4)=1 **
;	dc.b	2,1,1,0	113
;	dc.b	1,1,1,0	114
;	dc.b	0,0,0,0	115
;	dc.b	0,0,0,0	116
;	dc.b	0,0,0,0	117
;	dc.b	0,0,0,0	118
;	dc.b	0,0,0,0	119
;	dc.b	0,1,2,0	120
;	dc.b	3,1,2,0	121
;	dc.b	1,1,1,0	122
;	dc.b	1,1,1,0	123
;	dc.b	0,1,1,0	124
;	dc.b	0,1,3,0	125
;	even
;

	SECTION BSS
bssstart
control	ds.w	5
global	ds.w	16
int_in	ds.w	16
int_out	ds.w	7
addr_in	ds.l	2
addr_out	ds.l	1 
bye		ds.l	1
char		ds.b	2
button		ds.w	1
old_stack	ds.l	1
crc		ds.l	1	
handle	ds.w	1
file_length	ds.l	1
number1	ds.b	1
number2	ds.b	1
number3	ds.b	1
number4	ds.b	1
number5	ds.b	1
number6	ds.b	1
number7	ds.b	1
number8	ds.b	1

	ds.b	1024
mystack	ds.l	1

filestart

