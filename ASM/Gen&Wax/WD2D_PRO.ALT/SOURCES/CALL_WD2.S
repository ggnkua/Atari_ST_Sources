MOD_BOX=1
MOD_BOX2=0
MOD_WIND=0
MOD_MENU=0
MOD_HEXA=0
MOD_DECI=0
MOD_ACC=0

NR_WINDOWS_MAX=1

	include guw_mac3.s
	output d:\assemble\sources.wax\direct4d.pro\call_wpr.gtp

debut:	init_prg 64
	move.l a5,command_line

	appl_find #name_wax_professional
	move d0,num_app
	bmi didnot_findwax

	move.l command_line,a5
	clr d0
	move.b $80(a5),d0		; ligne de commande ?
	beq no_message

	move #2*8,to_send
	clr add_length
	cmp.w #2*5-1,d0
	ble.s .less10
	move d0,to_send
	add #3*2+1,to_send
	move d0,add_length
	add #1,add_length
	sub #2*5,add_length
.less10:
	subq #1,d0
	lea $81(a5),a0
	lea data_msg,a1
copy_name:	move.b (a0)+,(a1)+
	dbf d0,copy_name
	clr.b (a1)+

	move.w #224,num_message
	move.w global+4,sender_id
	appl_write num_app,to_send,#num_message

	lea error_occured,a0
	tst d0
	beq.s .erreur

	lea all_right,a0

.erreur:	bsr alert_box

fin:	restore_prg

didnot_findwax:
	lea wheres_wax,a0
	bsr alert_box
	bra.s fin

no_message:	lea not_message,a0
	bsr alert_box
	bra.s fin

	section DATA
error_occured:dc.b "[3][Error sending| the message ][ HOOPS ]",0
all_right:	dc.b "[2][ Message Nr 224 | send normally ][ OK ]",0
wheres_wax:dc.b "[3][I haven't found| WD2D_PRO in | application list ][STRANGE]",0
not_message:dc.b "[3][ No command line | detected : no | message send ][ BYE ]",0

name_wax_professional:
	dc.b 'WD2D_PRO',0
 even

	section BSS
command_line:ds.l 1
num_app:	ds.w 1

to_send:	ds.w 1

num_message:ds.w 1
sender_id:	ds.w 1
add_length:	ds.w 1	; nombre d'octets … envoyer en plus (total-5*2)
data_msg:	ds.b 256

	END

; dc.b 'conv=1,file1.trk,file2.trk,'	; st‚r‚o -> mono
; dc.b 'conv=2,file1.trk,file2.trk,file3.trk,'	; st‚r‚o -> R & L
; dc.b 'conv=3,file1.trk,file2.trk,'	; mono -> st‚r‚o
; dc.b 'conv=4,table.tab,'		; choose compression table
; dc.b 'conv=5,file1.trk,file2.dvs,'	; TRK st‚r‚o -> DVS
; dc.b 'conv=6,file1.trk,file2.dvs,'	; TRK mono -> DVS
; dc.b 'conv=7,file1.dvs,file2.trk,'	; DVS -> TRK
