	move.l a7,a5
	move.l #our_stack,a7
	
	bra main
	
	move.l #0,-(a7)
	trap #1
	
aes	move.l #aespb,d1	* put address of aes parameter block in d1
	move.w #$c8,d0		* aes function number call for op system
	Trap #2			* call extended bdos
	rts			* return from subroutine
	
vdi	move.l #vdipb,d1	* put address of vdi parameter block in d1
	move.w #$73,d0		* vdi function number call for op system
	trap #2			* call extended bdos
	rts
	
main	move.w #10,opcode	* aes op 10= APPL_INIT
	move.w #0,size_intin	* no integer inputs
	move.w #1,size_intout	* 1 integer output i.e ap_id (see later)
	move.w #0,size_addrin	* no address inputs
	move.w #0,size_addrout	* no address outputs
	move.l #0,global_res1	* initialise global reserved variables
	move.l #0,global_res2	* to 0
	move.l #0,global_res3
	move.l #0,global_res4
	jsr aes			* perform aes routine
	move.w intout,ap_id	* save application identifier

	move.w #77,opcode	* aes op 77= graf_handle
	move.w #0,size_intin	* no integers input
	move.w #5,size_intout	* 5 integers output 
	move.w #0,size_addrin	* no addresses input
	move.w #0,size_addrout	* no addresses output
	jsr aes			* perform aes routine
	
	move.w intout,gr_handle	* store graphics handle for future ref
	
	move.w #35,opcode	* aes op 35= menu_register
	move.w #1,size_intin	* one integer passed in intin
	move.w #1,size_intout	* one integer output via intout
	move.w #1,size_addrin	* address passed via adrrin
	move.w #0,size_addrout	* no addresses output
	
	move.w ap_id,intin	* pass application identifier to vdi
	move.l #accname,addrin	* pass accessory name to vdi
	
	jsr aes
	move.w intout,menu_id	* save menu identifier for future ref
	
loop_ever	move.w #25,contrl	* aes op 25= evnt_multi
	move.w #16,size_intin	* 16 inputs
	move.w #7,size_intout	* 7 outputs
	move.w #1,size_addrin	* 1 address passed to function
	move.w #0,size_addrout	* 0 addresses out
	
	move.w #%00010011,intin	* set flags for multi
	move.w #1,intin+2	* mouse clicks
	move.w #1,intin+4	* mouse buttons mask
	move.w #1,intin+6	* mouse button state
	move.l #intin+8,a0	* load address of intin into a0
	move.w #10,d0		* load counter
loop1	move.w #0,(a0)+		* set integers to zero
	dbra d0,loop1		* loop to next integer
	move.l #msgbuff,addrin	* pass address of buffer to vdi
	jsr aes			* perform operation
	move.w #%00010000,d0	* bit 4 mesage event flag
	cmp.w intout,d0  	* has a message event occurred
	beq acc_open		* check if message is call acc
	bra loop_ever		* if not loop forever
	
acc_open	move.w #40,d0	* AC_OPEN=40
	cmp.w msgbuff,d0	* is event acc open
	beq this_acc		* yes
	bra loop_ever		* no
	
this_acc	move.w menu_id,d0	
	cmp.w msgbuff+8,d0	* Is it ours
	beq op_work		* yes
	bra loop_ever		* no
	
	
	
	
op_work	move.w #100,opcode	* vdi op 100= open virtual workstation
	move.w #0,contrl+2		* no co-ordinates passedto function
	move.w #11,contrl+6	* no of parameters passed through intin
	move.w gr_handle,contrl+12	* pass handle to vdi
	
	move.w #9,d0		* set counter to 9
	move.l #intin,a0	* put address of intin array into a0
loop	move.w #1,(a0)+		* store 1 in first intin positon
	dbra d0,loop		* loop until first 9 integers initialised
	move.w #2,intin+20	* store 2 in intin(10)
	jsr vdi			* perform vdi routine
	
* screen is now ready for your gem program 
* normally we would open a window with only title and a closer
* but let's do something simple e.g an alert mesage
	move.w #52,opcode	* aes op 52= form_alert
	move.w #1,size_intin
	move.w #1,size_intout
	move.w #1,size_addrin
	move.w #0,size_addrout
	
	move.w #1,intin		* make button 1 default exit
	move.l #alert_msg,addrin	* pass string address to aes
	jsr aes

* normally after checking for mouse event & click on closer
* we would close window 	
	move.w #101,opcode	* vdi op 101= close virtual workstaion
	move.w #0,contrl+2
	move.w #0,contrl+4
	move.w #0,contrl+6
	move.w #0,contrl+8
	move.w gr_handle,contrl+12
	
	jsr vdi
	bra loop_ever
	
* variable storage
* arrays required by gem
aespb	dc.l contrl,global,intin,intout,addrin,addrout
contrl	
opcode	ds.w 1
size_intin	ds.w 1
size_intout	ds.w 1
size_addrin	ds.w 1
size_addrout	ds.l 1
		ds.w 5

global
version		ds.w 1
count		ds.w 1
apid		ds.w 1
private		ds.l 1
tree_pointer	ds.l 1
global_res1	ds.l 1
global_res2	ds.l 1
global_res3	ds.l 1
global_res4	ds.l 1

intin		ds.w 128
intout		ds.w 128
ptsin		ds.w 128
ptsout		ds.w 128
addrin		ds.w 128
addrout		ds.w 128

vdipb		dc.l contrl,intin,ptsin,intout,ptsout

* variables required by program

gr_handle	ds.w 1
menu_id		ds.w 1
msgbuff		ds.w 16
ap_id		ds.w 1


accname		dc.b "  OUR_ACC",0
alert_msg	dc.b "[0][HOORAY][ok]",0

* reserve space for temporary stack for accessory use
	
		ds.l 64	* should be sufficient
our_stack	ds.l 1
	
* Assemble with Devpac
