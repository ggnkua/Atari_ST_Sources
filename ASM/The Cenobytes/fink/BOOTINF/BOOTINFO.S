*********************************************
*             Bootinfo.acc v4.00            *
*         (C) J.B. Lancashire 1989          *
*        assemble as 'BOOTINFO.ACC'.        *
*********************************************

****************************************
* Initialisation only done at boot up. *
****************************************
start   move.l	#mystack,a7	Set up stack.
	
	move.w	#10,control	Initialise application.
	move.w	#0,control+2
	move.w	#1,control+4	
	move.w	#0,control+6
	bsr	aes
	move.w	d0,ap_id
	
	move.w	ap_id,int_in	Register accessory in menu.
	move.l	#name,addr_in
	move.w	#35,control
	move.w	#1,control+2
	move.w	#1,control+4	
	move.w	#1,control+6	
	bsr	aes

	move.w	#17,d4		Convert main dialog coordinates.
	move.l	#tree1,addr_in
	bsr	obfix
	bsr	fcent

***************************************
* The start of the main program loop. *
***************************************

wait	move.l	#message,addr_in	Wait for a menu call.
	move.w	#23,control
	move.w	#0,control+2
	move.w	#1,control+4	
	move.w	#1,control+6	
	bsr	aes
	move.l	#message,a0
	move.w	(a0),d0
	cmpi.w	#40,d0
	bne	wait		Not a call for us, carry on waiting.
	
	move.w	#0,int_in	Prepare to display dialog.
	bsr	fdial
	
	move.l	#tree1,addr_in	Draw the dialog box.
	move.w	#0,int_in
	move.w	#3,int_in+2
	bsr	obdraw
	
*****************
* Info routine. *
*****************

info	move.w	#0,-(sp)	Read bios parameter block.
	move.w	#7,-(sp)
	trap	#13
	addq.l	#4,sp
	cmpi.l	#0,d0
	beq	err		Failed to find bios block etc.
	move.l	d0,a0		Save address of parameter block.

	move.b	#12,d1
	lea	drecsiz,a1	Convert bios info to text.
iloop	move.w	(a0)+,d0	
	bsr	conv
	adda.l	#24,a1
	dbra	d1,iloop
	
draw	move.l	#tree1,addr_in	Redraw dialog box.
	move.w	#7,int_in
	move.w	#1,int_in+2
	bsr	obdraw
			
wait1	move.l	#tree1,addr_in	Wait for event.
	bsr	formdo
	cmpi	#1,d0		Evaluate user input.
	beq	about
	cmpi	#5,d0
	beq	info
	cmpi	#6,d0
	beq	exit
	bra	wait1		Non valid input, return.

********************************
* Misc functions and routines. *
********************************

conv	move.l	#$30303000,(a1)	Convert a hex word in D0 into
				* an ascii decimal string.
coma	cmp.w	#100,d0		Calculate 100's.
	blt	comb
	addi.b	#1,0(a1)
	sub.w	#100,d0
	bra	coma
comb	cmp.w	#10,d0		Calculate 10's.
	blt	comc
	addi.b	#1,1(a1)
	sub.w	#10,d0
	bra	comb
comc	add.b	d0,2(a1)	Whats left must be 1's.

	cmp.b	#48,0(a1)	Supress leading zero.
	bne	econ
	sub.b	#16,0(a1)
	cmp.b	#48,1(a1)	Supress next zero.
	bne	econ
	sub.b	#16,1(a1)	
econ	move.b	#0,3(a1)
	rts

****
exit	move.w	#3,int_in
	bsr	fdial
	bra	wait		Return to the desktop.

*****
about	move.w	#1,int_in	Show about alert box.
	move.l	#alert,addr_in#
	bsr	falert
	bra	wait1

*****
err	move.w	#1,int_in
	move.l	#error,addr_in
	bsr	falert
	bra	wait1	

*******************************
* Operating system functions. *
*******************************

obdraw	move.w	#42,control	Draw a dialog box.
	move.w	#6,control+2
	move.w	#1,control+4	
	move.w	#1,control+6	
	move.w	fcx,int_in+4
	move.w	fcx+2,int_in+6
	move.w	fcx+4,int_in+8
	move.w	fcx+6,int_in+10
	bsr	aes
	rts
*****
obfix	move.w	#114,control	Fix object tree1 coordinates.
	move.w	#1,control+2
	move.w	#1,control+4	
	move.w	#1,control+6	
fix	move.w	d4,int_in	Repeat for all objects in tree.
	bsr	aes
	dbra	d4,fix
	rts
******
formdo	move.w	#50,control	Handle returns from dialog box.
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	move.w	#0,int_in
	bsr	aes
	rts
*****	
fcent	move.w	#54,control	Center a dialog box.
	move.w	#0,control+2
	move.w	#5,control+4
	move.w	#1,control+6
	bsr	aes
	move.w	int_out+2,fcx
	move.w	int_out+4,fcx+2
	move.w	int_out+6,fcx+4
	move.w	int_out+8,fcx+6	
	rts
*****		
fdial	move.w	#51,control	Prepare to draw a dialog box.
	move.w	#9,control+2
	move.w	#1,control+4	
	move.w	#1,control+6	
	move.w	#0,int_in+2
	move.w	#0,int_in+4
	move.w	#0,int_in+6
	move.w	#0,int_in+8
	move.w	fcx,int_in+10
	move.w	fcx+2,int_in+12
	move.w	fcx+4,int_in+14
	move.w	fcx+6,int_in+16
	bsr	aes
	rts
******
falert	move.w	#52,control	Display an alert box.
	move.w	#1,control+2
	move.w	#1,control+4
	move.w	#1,control+6
	bsr	aes
	rts
***
aes	move.w	#0,control+8	Call aes routine.
	move.l	#aespb,d1
	move.l	#$c8,d0
	trap	#2
	move.w	int_out,d0
	rts
	
**********************************
* The data arrays and variables. *
**********************************

* The name of the accessory.

name	dc.b	32,14,15,' Bootinfo v4.00',0

* The alert boxes.

alert 	dc.b	'[0][ Bootinfo v4.00 (C) 1989|'
	dc.b	'   by J.B. Lancashire.|'
	dc.b	'------------------------  |'
	dc.b	'     Disk analyzer.]'
	dc.b	'[ ok ]',0

error	dc.b	'[0][ Bootinfo v4.00 (C) 1989|'
	dc.b	'   by J.B. Lancashire.|'
	dc.b	'------------------------  |'
	dc.b	'     Error reading|'
	dc.b	' bios parammeter block.]'
	dc.b	'[ abort ]',0

* General data and arrays.
	even

aespb	dc.l	control,global,int_in,int_out,addr_in,addr_out

ap_id		ds.w 	1	Application I.D.
message		ds.b 	16	Message pipe.
		ds.l	100
mystack		ds.w	1	User defined stack (goes backwards). 
global		ds.w	15
control		ds.w	5
int_in		ds.w	16
addr_in		ds.l	2
int_out		ds.w	7
addr_out	ds.l	1

*****************************				
* Data for the  dialog box. *
*****************************
	even
fcx	ds.w	4		Storage for form center.

* Data for main dialog.
tree1	dc.l	$ffff0001,$00070014,$00000000
	dc.l	$000211a2
	dc.l	$00000000,$001e0011

	dc.l	$00050002,$00040014,$00400000
	dc.l	$00fe1033
	dc.l	$00020001,$00120003

	dc.l	$0003ffff,$ffff001c,$00000000
	dc.l	titstr
	dc.l	$00020000,$00000001

	dc.l	$0004ffff,$ffff001c,$00000000
	dc.l	titstr1
	dc.l	$00050001,$00000001

	dc.l	$0001ffff,$ffff001c,$00200000
	dc.l	titstr2
	dc.l	$00010002,$00000001

	dc.l	$0006ffff,$ffff001a,$00400000
	dc.l	infostr
	dc.l	$00160001,$00060001

	dc.l	$0007ffff,$ffff001a,$00420000
	dc.l	exitstr
	dc.l	$00160003,$00060001

	dc.l	$00000008,$00110014,$00000000
	dc.l	$000211a3
	dc.l	$00020005,$001a000b

	dc.l	$0009ffff,$ffff001c,$00200000
	dc.l	recsiz
	dc.l	$00020001,$001a0000

	dc.l	$000affff,$ffff001c,$00200000
	dc.l	clsiz
	dc.l	$00020002,$001a0000

	dc.l	$000bffff,$ffff001c,$00200000
	dc.l	rdlen
	dc.l	$00020003,$001a0000

	dc.l	$000cffff,$ffff001c,$00200000
	dc.l	fsiz
	dc.l	$00020004,$001a0000

	dc.l	$000dffff,$ffff001c,$00200000
	dc.l	fatrec
	dc.l	$00020005,$001a0000

	dc.l	$000effff,$ffff001c,$00200000
	dc.l	datrec
	dc.l	$00020006,$001a0000

	dc.l	$000fffff,$ffff001c,$00200000
	dc.l	numcl
	dc.l	$00020007,$001a0000

	dc.l	$0010ffff,$ffff001c,$00200000
	dc.l	sides
	dc.l	$00020008,$001a0000

	dc.l	$0011ffff,$ffff001c,$00200000
	dc.l	tracks
	dc.l	$00020009,$001a0000

	dc.l	$0007ffff,$ffff001c,$00200000
	dc.l	sectrk
	dc.l	$0002000a,$001a0000

* Text for dialog box.

titstr	dc.b 'Bootinfo v4.00',0
titstr1	dc.b '(C) 1989',0
titstr2	dc.b 'J.B. Lancashire.',0
infostr	dc.b 'info',0	
exitstr	dc.b 'exit',0

	even
recsiz	dc.b	'Bytes per sector.   '
drecsiz	ds.l	1
clsiz	dc.b	'Secs per cluster.   '
	ds.l	7
rdlen	dc.b	'Secs per dir.       '
	ds.l	1
fsiz	dc.b	'Secs per FAT.       '
	ds.l	1
fatrec	dc.b	'Sec No of 2nd FAT.  '
	ds.l	1
datrec	dc.b	'First data sec.     '
	ds.l	1
numcl	dc.b	'Data clusters.      '
	ds.l	7
tracks	dc.b	'No of tracks.       '
	ds.l	1
sides	dc.b	'No of sides.        '
	ds.l	7
sectrk	dc.b	'Secs per track.     '
	ds.l	1
