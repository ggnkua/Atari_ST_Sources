MOD_BOX=1
MOD_BOX2=0
MOD_WIND=1
MOD_MENU=0
MOD_HEXA=0
MOD_DECI=0
MOD_ACC=0

NR_WINDOWS_MAX=1

	include guw_mac3.s
	output d:\assemble\asources.wax\direct2d\call_wax.prg
	
debut:	init_prg 64

	appl_find #name_wax2play
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

name_wax2play:
	dc.b 'WAX2PLAY',0
 even

	section BSS
num_app:	ds.w 1

	END
