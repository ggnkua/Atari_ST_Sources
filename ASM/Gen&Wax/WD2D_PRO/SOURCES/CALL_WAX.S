MOD_BOX=1
MOD_BOX2=0
MOD_WIND=1
MOD_MENU=0
MOD_HEXA=0
MOD_DECI=0
MOD_ACC=0

NR_WINDOWS_MAX=1

	include guw_mac3.s
	output d:\assemble\sources.wax\direct4d.pro\call_wpr.app
	
debut:	init_prg 64

	appl_find #name_wax_professional
	move d0,num_app
	bmi .erreur

	clr d0
	bset #EVNT_KEYBD,d0
	bsr traite_evenement_gem

	move.w global+4,my_num1
	appl_write num_app,#fin_message1-message1,#message1
	tst d0
	beq.s .erreur

	clr d0
	bset #EVNT_KEYBD,d0
	bsr traite_evenement_gem

	move.w global+4,my_num2
	appl_write num_app,#16,#message2
	tst d0
	beq.s .erreur

	clr d0
	bset #EVNT_KEYBD,d0
	bsr traite_evenement_gem

	move.w global+4,my_num3
	appl_write num_app,#fin_message3-message3,#message3
	tst d0
	beq.s .erreur

	clr d0
	bset #EVNT_KEYBD,d0
	bsr traite_evenement_gem

.erreur:	restore_prg

	section DATA
message1:	dc.w 224
my_num1:	dc.w 0
	dc.w fin_message1-deb_message1-5*2
deb_message1:dc.b 'play=d:\mepris.dvw',0
fin_message1:

message2:	dc.w 224
my_num2:	dc.w 0
	dc.w 0
	dc.b 'stop',0
fin_message2:

message3:	dc.w 224
my_num3:	dc.w 0
	dc.w fin_message3-deb_message3-5*2
deb_message3:dc.b 'conv=6,g:\boogiewl.trk,h:\boogiewl.dvs,'
fin_message3:

name_wax_professional:
	dc.b 'WD2D_PRO',0
 even

	section BSS
num_app:	ds.w 1

	END

; dc.b 'conv=1,file1.trk,file2.trk,'	; st‚r‚o -> mono
; dc.b 'conv=2,file1.trk,file2.trk,file3.trk,'	; st‚r‚o -> R & L
; dc.b 'conv=3,file1.trk,file2.trk,'	; mono -> st‚r‚o
; dc.b 'conv=4,table.tab,'		; choose compression table
; dc.b 'conv=5,file1.trk,file2.dvs,'	; TRK st‚r‚o -> DVS
; dc.b 'conv=6,file1.trk,file2.dvs,'	; TRK mono -> DVS
; dc.b 'conv=7,file1.dvs,file2.trk,'	; DVS -> TRK
