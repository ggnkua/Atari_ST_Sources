************************************************
*                                              *
* << Amethyste 4.6 : >>                        *
* ---------------------                        *
*                                              *
* << Code : GT Turbo (GT) >>                   *
*                                              *
* << Mouse Sprite, Font : RAZ(TheLAB) >>       *
*                                              *
*                      << C.V.S.D. 1995 >>     *
*                                              *
* Last featurings :                            *
* -----------------                            *
*                                              *
* - New Save and Restore Rout                  *
* - Winx Support (Backdrop command)            *
* - Xbra Support                               *
*                                              *
* Little revision : 14/04/2004                 *
*                                              *
* C U Soon you on : CEREBRAL-VORTEX.NET        *
*                                              *
*                                              *
************************************************

	opt	a+,d-

************************************************
*                                              *
************************************************

G_box	EQU	20
G_text	EQU	21
G_boxtext	EQU	22
G_image	EQU	23
G_userdef	EQU	24
G_ibox	EQU	25
G_button	EQU	26
G_boxchar	EQU	27
G_string	EQU	28	
G_ftext	EQU	29
G_fboxtext	EQU	30
G_icon	EQU	31
G_title	EQU	32

Selectable	EQU	1
Default	EQU	2
Exit	EQU	4
Editable	EQU	8
Rbutton	EQU	16
Lastob	EQU	32
Touchexit	EQU	64
Hidetree	EQU	128
Indirect	EQU	256

Selected	EQU	1
Crossed	EQU	2
Checked	EQU	4
Disabled	EQU	8
Outlined	EQU	16
Shadowed	EQU	32

* This flag must bet set to -1, if you want to put this .ACC
* on the disk, else the code will be assembled like a .PRG !!
* 

Acc	EQU	0	

************************************************
*                                              *
* This rout is here only for some debugging !! *
* If you want to use them, here comes a        *
* example :                                    *
*                                              *
* E.G. : Display_hex	10,10,d4       *
*                                              *
* Display the value of d4 in hex at 10,10 on   *
* the screen                                   *
*                                              *
* E.G. : Display_dec	10,10,d4       *
*                                              *
* Display the value of d4 in dec at 10,10 on   *
* the screen                                   *
*                                              *
************************************************

Print_hex	MACRO
	movem.l	d0-d7,-(a7)
	move.l	\3,d0
	move.b	#\1,d1
	move.b	#\2,d2
	bsr	Display_hex
	movem.l	(a7)+,d0-d7
	ENDM

Print_dec	MACRO
	movem.l	d0-d7,-(a7)
	move.l	\3,d0
	move.b	#\1,d1
	move.b	#\2,d2
	bsr	Display_dec
	movem.l	(a7)+,d0-d7
	ENDM

************************************************
*                                              *
************************************************

	move.l	a7,a6
	lea	New_stack(pc),a7

	IFEQ	Acc

	move.l	4(a6),a6
	move.l	$c(a6),d0
	add.l	$14(a6),d0
	add.l	$1c(a6),d0
	add.l	#$100,d0
	move.l	d0,d1
	add.l	a6,d1
	and.l	#-2,d1
	move.l	d1,a7
	
	move.l	d0,-(a7)
	move.l	a6,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7

	ENDC

	jsr	Save_everything(pc)

	lea	Install_new_trap(pc),a0
	jsr	Super(pc)

	lea	Cookies_jar(pc),a0
	jsr	Super(pc)

	pea	Intro_txt(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.w	#6,a7

	jsr	Appl_init(pc)
	move.w	Int_out(pc),Ap_id	* Ap_id (!)

************************************************
*                                              *
************************************************

	moveq	#0,d0
	moveq	#4,d1
	
	jsr	Wind_get(pc)

	movem.l	Int_out+2(pc),d0-d1
	movem.l	d0-d1,X_desk

	IFNE	Acc

	move.w	Ap_id,d0
	move.l	#Title,d1
	jsr	Menu_register(pc)

	ENDC	

************************************************
*                                              *
************************************************

	lea	Tree0(pc),a0
	jsr	Reloge_xy(pc)

Gere_acc:
	IFNE	Acc

	move.l	#Buff_mess,d0
	jsr	Evnt_mesag(pc)
	
	cmp.w	#40,Buff_mess
	bne.s	Gere_acc

	ENDC

************************************************
*                                              *
************************************************

Acc_open:
	move.b	#-1,d0
	move.l	#Mouse_struct,d1
	jsr	Graf_mouse(pc)

	cmp.w	#"GT",Handle_wind
	bne.s	Open_it_0	

	move.l	#Tree0,d0
	jsr	Form_center(pc)

	lea	Int_out+2(pc),a0
	moveq	#0,d0
	moveq	#$0b,d1
	move.l	(a0)+,d2
	move.l	Tree0_xy+4(pc),d3
	jsr	Wind_calc(pc)
	lea	Int_out+2(pc),a0	

	move.l	(a0)+,X_wind
	move.l	(a0)+,W_wind


Open_it_0:
	moveq	#$0b,d0
	movem.w	X_wind(pc),d1-d4

	jsr	Wind_create(pc)
	tst.w	Int_out
	bgt.s	No_window_error
	move.l	#Window_error_txt,d0
	moveq	#1,d1
	jsr	Form_alert(pc)
	bra	Exit_error
No_window_error:
	move.w	Int_out(pc),Handle_wind

	move.w	Handle_wind(pc),d0
	moveq	#2,d1
	move.l	#Title,d2
	jsr	Wind_set(pc)

	move.w	Handle_wind(pc),d0
	movem.w	X_wind(pc),d1-d4
	jsr	Wind_open(pc)

************************************************
*                                              *
************************************************

	st	Actif

Main_code:
	lea	Control(pc),a0
	move.w	#25,(a0)+
	move.w	#16,(a0)+
	move.w	#7,(a0)+
	move.w	#1,(a0)+
	clr.w	(a0)

	lea	Int_in(pc),a0
	move.w	#%010011,(a0)
	move.w	#1,2(a0)	* Nb click
	move.w	#1,4(a0)	* Msk click
	move.w	#1,6(a0)	* Ev Bstate
	move.l	#Buff_mess,Addr_in

	jsr	Call_aes(pc)

	movem.w	Int_out(pc),d0-d7
	movem.w	d0-d7,Evnt_mask

************************************************
*                     Mesag                    *
************************************************

	move.w	Evnt_mask(pc),d0
	btst	#4,d0
	beq	No_mesag

	lea	Buff_mess(pc),a0
	move.w	(a0),Cmd

	move.w	6(a0),d0
	cmp.w	Handle_wind(pc),d0
	bne	Acc_closed

	cmp.w	#20,Cmd
	bne.s	No_redraw

	move.w	8(a0),X_redraw
	move.w	10(a0),Y_redraw

	move.w	8(a0),d0
	add.w	12(a0),d0
	subq.w	#1,d0
	move.w	d0,X1_redraw	

	move.w	10(a0),d0
	add.w	14(a0),d0
	subq.w	#1,d0
	move.w	d0,Y1_redraw	

	jsr	Redraw(pc)

No_redraw:

	cmp.w	#21,Cmd
	beq.s	Topped_cmd
	cmp.w	#40,Cmd
	bne.s	Not_topped_cmd
Topped_cmd:	

	move.w	Handle_wind(pc),d0
	moveq	#$a,d1
	jsr	Wind_set(pc)

Not_topped_cmd:

	cmp.w	#22,Cmd
	beq	Exit_normal

	cmp.w	#28,Cmd
	bne.s	Dont_move

	move.l	8(a0),X_wind
	move.l	12(a0),W_wind

	move.w	Handle_wind(pc),d0
	moveq	#5,d1
	movem.l	X_wind(pc),d2-d3

	jsr	Wind_set(pc)

	moveq	#1,d0
	moveq	#$b,d1
	movem.l	X_wind(pc),d2-d3
 	jsr	Wind_calc(pc)

	move.l	Int_out+2(pc),Tree0_xy

Dont_move:

	tst.b	Winx_flag
	beq.s	Pas_backdrop_cmd

	cmp.w	#33,Cmd
	bne.s	Pas_backdrop_cmd

	move.w	Handle_wind(pc),d0
	moveq	#25,d1
	moveq	#0,d2
	moveq	#0,d3
	bsr	Wind_set

Pas_backdrop_cmd:
	
	
Acc_closed:

	cmp.w	#41,Cmd
	bne.s	No_mesag
	sf	Actif
	jmp	Gere_acc(pc)
No_mesag:

************************************************
*                   Keyboard                   *
************************************************

	move.w	Evnt_mask(pc),d0
	btst	#0,d0
	beq	No_key

	pea	-1.w
	pea	-1.w
	pea	-1.w
	move.w	#$10,-(a7)
	trap	#14
	lea	14(a7),a7
	move.l	d0,a0
	move.l	8(a0),a2
	move.w	Key_return(pc),d0
	lsr.w	#8,d0
	move.b	0(a2,d0.w),Key_asc_2

* 0=Shift Left
* 1=Shift Right
* 2=Control
* 3=Alternate

	move.w	Rab_key(pc),d0
	btst	#2,d0
	beq	No_control

	cmp.b	#"S",Key_asc_2	
	bne.s	K_dont_modify_state

	lea	Tree0(pc),a0
	moveq	#6,d3
	moveq	#7,d0
	moveq	#0,d1
	jsr	Read_objc_state(pc)
	bne.s	Modify_state
	moveq	#7,d3
Modify_state:

	move.l	#Tree0,d0
	move.w	d3,d1
 	moveq	#1,d2
	jsr	Form_button(pc)

	lea	Gicle_vectors(pc),a0
	jsr	Super(pc)

	cmp.w	#6,d3
	bne.s	Pas_install_vectors
	lea	Install_vectors(pc),a0
	jsr	Super(pc)
Pas_install_vectors:


K_dont_modify_state:

	cmp.b	#"R",Key_asc_2	
	bne.s	K_dont_modify_reset

	lea	Tree0(pc),a0
	moveq	#10,d2
	moveq	#11,d0
	moveq	#0,d1
	jsr	Read_objc_state(pc)
	bne.s	Modify_reset
	moveq	#11,d2
Modify_reset:

	move.l	#Tree0,d0
	move.w	d2,d1
 	moveq	#1,d2
	bsr	Form_button

	lea	Gicle_reset(pc),a0
	jsr	Super(pc)

	cmp.w	#10,d3
	bne.s	Pas_install_reset
	lea	Install_reset(pc),a0
	jsr	Super(pc)
Pas_install_reset:

K_dont_modify_reset:

	cmp.b	#"E",Key_asc_2	
	bne.s	K_dont_save

	jsr	Save_everything(pc)

K_dont_save:

	cmp.b	#"Q",Key_asc_2
	beq	Exit_normal	

	cmp.b	#"C",Key_asc_2
	beq	Exit_normal	

No_control:

No_key:


************************************************
*                Mouse Button                  *
************************************************

	move.w	Evnt_mask(pc),d0
	btst	#1,d0
	beq	No_button

	move.l	#Tree0,d0
	moveq	#0,d1
	moveq	#3,d2
	move.w	X_mouse(pc),d3
	move.w	Y_mouse(pc),d4
  	jsr	Objc_find(pc)
	move.w	Int_out(pc),Objc_selected
	cmp.w	#-1,Objc_selected
	beq	No_button	

	move.l	#Tree0,d0
	move.w	Objc_selected(pc),d1
 	moveq	#1,d2
	jsr	Form_button(pc)

	cmp.w	#6,Objc_selected
	bne.s	Pas_install_vectors_0
	lea	Install_vectors(pc),a0
	jsr	Super(pc)
Pas_install_vectors_0:

	cmp.w	#7,Objc_selected
	bne.s	Pas_gicle_vectors_0
	lea	Gicle_vectors(pc),a0
	jsr	Super(pc)
Pas_gicle_vectors_0:

	cmp.w	#10,Objc_selected
	bne.s	Pas_install_reset_0
	lea	Install_reset(pc),a0
	jsr	Super(pc)
Pas_install_reset_0:

	cmp.w	#11,Objc_selected
	bne.s	Pas_gicle_reset_0
	lea	Gicle_reset(pc),a0
	jsr	Super(pc)
Pas_gicle_reset_0:

	cmp.w	#12,Objc_selected
	bne.s	Dont_resave_state

	jsr	Save_everything(pc)

	move.l	#Tree0,d0
	moveq	#12,d1
	jsr	Unselect_it(pc)

	moveq	#1,d0
	moveq	#1,d1
	moveq	#0,d2
	jsr	Evnt_button(pc)

Dont_resave_state:

No_button:

	jmp	Main_code(pc)

************************************************
*                                              *
************************************************

Exit_normal:
	move.w	Handle_wind(pc),d0
	jsr	Wind_close(pc)
	move.w	Handle_wind(pc),d0
	jsr	Wind_delete(pc)

Exit_error:
	sf	Actif

	moveq	#0,d0
	jsr	Graf_mouse(pc)

	IFNE	Acc

	jmp	Gere_acc(pc)

	ENDC

	IFEQ	Acc

	jsr	Appl_exit(pc)

	clr.w	-(a7)	* No comment !
	trap	#1	* ?!#$

	ENDC

***************************************************************
*                                                             *
*                           Aes                               *
*                         --------                            *
*                                                             *
***************************************************************

Call_aes:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	#Aes_table,d1
	move.w	#$c8,d0
	trap	#2
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Appl_init :                                  *
* -----------                                  *
*                                              *
* Exit : Ap_id in Int_out                      *
*                                              *
************************************************

Appl_init:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.l	#$000a0002,(a0)+	* Appl_init
	move.l	#$00010000,(a0)+
	clr.w	8(a0)
	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Appl_exit :                                  *
* -----------                                  *
*                                              *
************************************************


Appl_exit:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#19,(a0)	* Appl_exit
	clr.w	2(a0)
	move.w	#1,4(a0)
	clr.w	6(a0)
	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Menu_register :                              *
* ---------------                              *
*                                              *
* d0.w : Your Ap_id                            *
* d1.l : Accessory Title String Adr            *
*                                              *
************************************************


Menu_register:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#35,(a0)
	move.w	#1,2(a0)
	move.w	#1,6(a0)
	move.w	d0,Int_in
	move.l	d1,Addr_in

	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Form_center :                                *
* -------------                                *
*                                              *
* d0.l : Adresse de l'arbre                    *
*                                              *
************************************************

Form_center:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#54,(a0)+
	clr.w	(a0)+
	move.w	#5,(a0)+
	move.w	#1,(a0)+
	clr.w	(a0)
	move.l	d0,Addr_in

	jsr	Call_aes(pc)
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Form_alert :                                 *
* ------------                                 *
*                                              *
* d0.l : Tree adr                              *
* d1.w : Defaut Button                         *
*                                              *
************************************************

Form_alert:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#52,(a0)
	move.w	#1,2(a0)
	move.w	#1,4(a0)
	move.w	#1,6(a0)
	move.w	d1,Int_in
	move.l	d0,Addr_in
	
	jsr	Call_aes(pc)
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Form_button :                                *
* -------------                                *
*                                              *
* d0.l : Tree adr                              *
* d1.w : Object clicked                        *
* d2.w : Nb click                              *
*                                              *
************************************************

Form_button:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#56,(a0)
	move.w	#2,2(a0)
	move.w	#2,4(a0)
	move.w	#1,6(a0)
	clr.w	8(a0)
	movem.w	d1-d2,Int_in
	move.l	d0,Addr_in
	
	jsr	Call_aes(pc)
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Form_keybd :                                 *
* ------------                                 *
*                                              *
* d0.l : Tree adr                              *
* d1.w : Current editable object               *
* d2.w : Key to treat                          *
*                                              *
************************************************

Form_keybd:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#55,(a0)
	move.w	#2,2(a0)
	move.w	#3,4(a0)
	move.w	#1,6(a0)
	clr.w	8(a0)
	movem.w	d1-d2,Int_in
	move.l	d0,Addr_in
	
	jsr	Call_aes(pc)
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Graf_mouse :                                 *
* ------------                                 *
*                                              *
* d0.w : Forme de la souris                    *
* d1.l : Adresse du bloc souris (d0=255)       *
*                                              *
************************************************

Graf_mouse:	movem.l	d0-d7/a0-a6,-(a7)
	
	lea	Control(pc),a0
	move.w	#78,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	d0,Int_in
	move.l	d1,Addr_in
	jsr	Call_aes(pc)
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Wind_update :                                *
* -------------                                *
*                                              *
* d0.w : Fonction number                       *
*                                              *
************************************************

Wind_update:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#107,(a0)
	move.w	#1,2(a0)
	clr.w	6(a0)
	move.w	d0,Int_in

	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Wind_calc :                                  *
* -----------                                  *
*                                              *
* d0.w : Int / Ext flag                        *
* d1.w : Bit mask                              *
* d2.w : X , d2.w+2 : Y                        *
* d3.w : W , d3.w+2 : H                        *
*                                              *
************************************************

Wind_calc:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#108,(a0)+
	move.w	#6,(a0)+
	move.w	#5,(a0)+
	clr.l	(a0)
	lea	Int_in(pc),a0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+

	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Wind_create :                                *
* -------------                                *
*                                              *
* d0.w : Attrb mask                            *
* d1.w : X                                     *
* d2.w : Y                                     *
* d3.w : W                                     *
* d4.w : H                                     *
*                                              *
************************************************

Wind_create:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#100,(a0)+
	move.w	#5,(a0)+
	move.w	#1,(a0)+
	clr.l	(a0)
	movem.w	d0-d4,Int_in

	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Wind_open :                                  *
* -----------                                  *
*                                              *
* d0.w : Window handle                         *
* d1.w : X                                     *
* d2.w : Y                                     *
* d3.w : W                                     *
* d4.w : H                                     *
*                                              *
************************************************

Wind_open:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#101,(a0)+
	move.w	#5,(a0)+
	move.w	#1,(a0)+
	clr.w	(a0)
	movem.w	d0-d4,Int_in

	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Wind_close :                                 *
* ------------                                 *
*                                              *
* d0.w : Handle window                         *
*                                              *
************************************************

Wind_close:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#102,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	clr.l	(a0)
	move.w	d0,Int_in

	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Wind_delete :                                *
* -------------                                *
*                                              *
* d0.w : Handle window                         *
*                                              *
************************************************

Wind_delete:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#103,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	clr.w	(a0)
	move.w	d0,Int_in

	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Wind_get :                                   *
* ----------                                   *
*                                              *
* d0.w : Window handle                         *
* d1.w : Command word                          *
*                                              *
************************************************

Wind_get:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#104,(a0)+
	move.w	#2,(a0)+
	move.w	#5,(a0)+
	clr.w	(a0)
	movem.w	d0-d1,Int_in
	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Wind_set :                                   *
* ----------                                   *
*                                              *
* d0.w : Window handle                         *
* d1.w : Command word                          *
* d2.w : Param1                                *
* d2.w+2 : Param2                              *
* d3.w : Param3                                *
* d3.w+2 : Param4                              *
*                                              *
************************************************

Wind_set:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#105,(a0)
	move.w	#6,2(a0)
	move.w	#1,4(a0)
	clr.w	6(a0)
	clr.w	8(a0)

	lea	Int_in(pc),a0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+

	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Objc_draw :                                  *
* -----------                                  *
*                                              *
* d0.l : Tree adr                              *
* d1.w : Start object                          *
* d2.w : End Object                            *
* d3.w : X_clip , d3.w+2 : Y_clip              *
* d4.w : W_clip , d4.w+2 : H_clip              *
*                                              *
************************************************

Objc_draw:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#42,(a0)+
	move.w	#6,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)
	lea	Int_in(pc),a0
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.l	d3,(a0)+
	move.l	d4,(a0)+
	move.l	d0,Addr_in

	jsr	Call_aes(pc)
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Objc_find :                                  *
* -----------                                  *
*                                              *
* d0.l : Tree adr                              *
* d1.w : Start Object number                   *
* d2.w : End Object number                     *
* d3.w : X mouse                               *
* d4.w : Y mouse                               *
*                                              *
************************************************

Objc_find:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#43,(a0)+
	move.w	#4,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	clr.w	(a0)
	movem.w	d1-d4,Int_in
	move.l	d0,Addr_in		
		
	jsr	Call_aes(pc)
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Evnt_button :                                *
* -------------                                *
*                                              *
* d0.w : Nb clic maximun                       *
* d1.w : Button Bit Mask                       *
* d2.w : Button State to Verify                *
*                                              *
************************************************

Evnt_button:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#21,(a0)
	move.w	#3,2(a0)
	clr.w	6(a0)
	movem.w	d0-d2,Int_in
		
	jsr	Call_aes(pc)
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* Evnt_mesag :                                 *
* ------------                                 *
*                                              *
* d0.l : Buffer Adr                            *
*                                              *
************************************************

Evnt_mesag:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Control(pc),a0
	move.w	#23,(a0)
	clr.w	2(a0)
 	move.w	#1,6(a0)
	move.l	d0,Addr_in
	
	jsr	Call_aes(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

***************************************************************
*                                                             *
*                      All the rest.....                      *
*                         --------                            *
*                                                             *
***************************************************************

Read_objc_state:
	movem.l	d0-d7/a0-a6,-(a7)

	mulu	#24,d0
	move.w	10(a0,d0.w),d2
	btst	d1,d2
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
************************************************

Redraw:	movem.l	d0-d7/a0-a6,-(a7)

	moveq	#1,d0
	jsr	Wind_update(pc)

	moveq	#1,d0
	moveq	#$0b,d1
	movem.l	X_wind(pc),d2-d3
 	jsr	Wind_calc(pc)
	move.l	Int_out+2(pc),Tree0_xy

	move.w	Handle_wind(pc),d0
	moveq	#11,d1
	jsr	Wind_get(pc)

Bcl_redraw:
	movem.l	Int_out+2(pc),d0-d1
	movem.l	d0-d1,P1

	tst.l	P3	* W=0 and H=0
	beq.s	End_redraw	* Fin

	lea	X_tab(pc),a0
	move.w	X_redraw(pc),(a0)+
	move.w	X1_redraw(pc),(a0)+

	move.w	P1(pc),(a0)+

	move.w	P1(pc),d0	* X
	add.w	P3(pc),d0	* +W
	subq.w	#1,d0
	move.w	d0,(a0)+	* X1

	lea	Y_tab(pc),a0
	move.w	Y_redraw(pc),(a0)+
	move.w	Y1_redraw(pc),(a0)+
	move.w	P2(pc),(a0)+

	move.w	P2(pc),d0	* Y
	add.w	P4(pc),d0	* +H
	subq.w	#1,d0
	move.w	d0,(a0)+	* Y1

	jsr	CV_intersect(pc)
	tst.w	d0
	beq.s	Fin_redraw

	move.w	X_tab(pc),d3
	swap	d3
	move.w	Y_tab(pc),d3

	move.w	X_tab+2(pc),d4
	sub.w	X_tab(pc),d4
	addq.w	#1,d4
	swap	d4
	move.w	Y_tab+2(pc),d4
	sub.w	Y_tab(pc),d4
	addq.w	#1,d4

	move.l	#Tree0,d0
	moveq	#0,d1
	moveq	#4,d2
	jsr	Objc_draw(pc)

Fin_redraw:

	move.w	Handle_wind(pc),d0
	moveq	#12,d1
	jsr	Wind_get(pc)

	bra	Bcl_redraw

End_redraw:
	moveq	#0,d0
	jsr	Wind_update(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
* CV_intersect :                               *
* --------------                               *
*                                              *
* X_tab+$00 : X0                               *
* X_tab+$02 : X1                               *
* X_tab+$04 : X2                               *
* X_tab+$06 : X3                               *
*                                              *
* Y_tab+$00 : Y0                               *
* Y_tab+$02 : Y1                               *
* Y_tab+$04 : Y2                               *
* Y_tab+$06 : Y3                               *
*                                              *
* Out :                                        *
* -----                                        *
* d0.w : =0 if not, else <>0                   *
* X_tab+$00 : X0                               *
* X_tab+$02 : X1                               *
* Y_tab+$00 : Y0                               *
* y_tab+$02 : Y1                               *
*                                              *
************************************************

CV_intersect:	movem.l	d1-d7/a0-a6,-(a7)

	moveq	#0,d0

	lea	X_tab(pc),a0
	move.w	(a0),d7
	move.w	2(a0),d6

	cmp.w	d7,d6
	bgt.s	Dont_swap_x0
	move.w	d7,2(a0)
	move.w	d6,(a0)
Dont_swap_x0:

	move.w	4(a0),d7
	move.w	6(a0),d6

	cmp.w	d7,d6
	bgt.s	Dont_swap_x1
	move.w	d7,6(a0)
	move.w	d6,4(a0)
Dont_swap_x1:

	lea	Y_tab(pc),a0

	move.w	(a0),d7
	move.w	2(a0),d6

	cmp.w	d7,d6
	bgt.s	Dont_swap_y0
	move.w	d7,2(a0)
	move.w	d6,(a0)
Dont_swap_y0:
	
	move.w	4(a0),d7
	move.w	6(a0),d6

	cmp.w	d7,d6
	bgt.s	Dont_swap_y1
	move.w	d7,6(a0)
	move.w	d6,4(a0)
Dont_swap_y1:

	lea	X_tab(pc),a0

	move.w	4(a0),d7
	cmp.w	2(a0),d7
	bgt.s	CV_end_intersect

	move.w	6(a0),d7
	cmp.w	(a0),d7
	blt.s	CV_end_intersect

	lea	Y_tab(pc),a0

	move.w	4(a0),d7
	cmp.w	2(a0),d7
	bgt.s	CV_end_intersect

	move.w	6(a0),d7
	cmp.w	(a0),d7
	blt.s	CV_end_intersect

	lea	X_tab(pc),a0
	lea	Y_tab(pc),a1
	moveq	#0,d7
CV_sort_bcl:
	move.w	d7,d6
CV_sort_bcl1:
	move.w	0(a0,d7.w),d2
	move.w	0(a0,d6.w),d3

	cmp.w	d3,d2
	blt.s	CV_dont_swap_x
	move.w	d3,0(a0,d7.w)
	move.w	d2,0(a0,d6.w)
CV_dont_swap_x:

	move.w	0(a1,d7.w),d2
	move.w	0(a1,d6.w),d3

	cmp.w	d3,d2
	blt.s	CV_dont_swap_y
	move.w	d3,0(a1,d7.w)
	move.w	d2,0(a1,d6.w)
CV_dont_swap_y:

	addq.w	#2,d6
	cmp.w	#8,d6
	bne.s	CV_sort_bcl1	

	addq.w	#2,d7
	cmp.w	#8,d7
	bne.s	CV_sort_bcl

	move.l	X_tab+2(pc),X_tab
	move.l	Y_tab+2(pc),Y_tab

	moveq	#-1,d0	
CV_end_intersect:
	movem.l	(a7)+,d1-d7/a0-a6
	rts

************************************************
*                                              *
************************************************

Unselect_it:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	d0,a0
	move.w	d1,d2
	mulu	#24,d2
	and.w	#$fffe,$a(a0,d2.w)

	moveq	#0,d2
	movem.l	X_desk(pc),d3-d4
	jsr	Objc_draw(pc)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

	IFEQ	Acc

************************************************
*                                              *
* Display_dec :                                *
* -------------                                *
*                                              *
* d0.l : Number to display                     *
* d1.b : X Display                             *
* d2.b : Y Display                             *
************************************************

Display_dec:	movem.l	d0-d7/a0-a6,-(a7)

	add.b	#$20,d1
	move.b	d1,X_locate

	add.b	#$20,d2
	move.b	d2,Y_locate

	lea	Number(pc),a0
	lea	Number_tab(pc),a1
	moveq	#9,d6
En_entier:
	move.l	(a1)+,d7
	move.w	#$d0,d5
Sous_tract:
	sub.l	d7,d0
	dbmi	d5,Sous_tract
	add.l	d7,d0
	neg.b	d5
	move.b	d5,(a0)+
	dbra	d6,En_entier

	pea	Locate_txt(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.w	#6,a7

	movem.l	(a7)+,d0-d7/a0-a6
	rts

Locate_txt:
	dc.b	27,"Y"
Y_locate:
	dc.b	0
X_locate:
	dc.b	0		
Number:
	ds.b	10
	dc.b	0
	dc.b	0
Number_tab
	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	1

************************************************
*                                              *
* Display_hex :                                *
* -------------                                *
*                                              *
* d0.l : Number to display                     *
* d1.b : X Display                             *
* d2.b : Y Display                             *
************************************************


Display_hex:	movem.l	d0-d7/a0-a6,-(a7)

	add.b	#$20,d1
	move.b	d1,X_locate

	add.b	#$20,d2
	move.b	d2,Y_locate

	lea	Number(pc),a0
	moveq	#7,d6
H_en_entier:
	move.l	d0,d1
	and.b	#$f,d1
	cmp.b	#10,d1
	blt.s	Inf_a_9
	sub.b	#10,d1
	add.b	#"A",d1
	bra.s	Range_it
Inf_a_9:
	add.b	#"0",d1		

Range_it:
	move.b	d1,0(a0,d6.w)
	lsr.l	#4,d0
	dbra	d6,H_en_entier

	pea	Locate_txt(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.w	#6,a7

	movem.l	(a7)+,d0-d7/a0-a6
	rts

	ENDC

************************************************
*                                              *
************************************************

Reloge_xy:	movem.l	d0-d7/a0-a6,-(a7)
	
	lea	Control(pc),a1
	move.l	#$00720001,(a1)
	move.w	#1,6(a1)

	move.l	a0,Addr_in
	moveq	#0,d1
Ob_fix:
	move.w	d1,Int_in
	jsr	Call_aes(pc)
	move.w	d1,d2
	addq.w	#1,d1
	mulu	#24,d2
	btst	#5,9(a0,d2.w)
	beq.s	Ob_fix
	subq.w	#1,d1
	move.w	d1,4(a0)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
************************************************

Save_everything:
	movem.l	d0-d7/a0-a6,-(a7)

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.w	#6,a7
	move.l	d0,User_stack

	lea	Exceptions(pc),a0
	move.l	$08.w,(a0)+	* Bus Error
	move.l	$0c.w,(a0)+	* Adress Error
	move.l	$10.w,(a0)+	* Illegal
	move.l	$14.w,(a0)+	* Div by zero
	move.l	$20.w,(a0)	* Privilege violation

	lea	$fffffa00.w,a0
	lea	Mfp_save(pc),a1
	move.b	$1(a0),(a1)+
	move.b	$3(a0),(a1)+
	move.b	$5(a0),(a1)+
	move.b	$7(a0),(a1)+
	move.b	$9(a0),(a1)+
	move.b	$13(a0),(a1)+
	move.b	$15(a0),(a1)+
	move.b	$17(a0),(a1)+
	move.b	$19(a0),(a1)+
	move.b	$1b(a0),(a1)+
	move.b	$1d(a0),(a1)+

	lea	Yamaha_save(pc),a0
	moveq	#12,d0
Save_yamaha:
	move.b	d0,$ffff8800.w
	move.b	$ffff8800.w,(a0)+	
	dbra	d0,Save_yamaha

	lea	Vector_save,a0
	move.l	$110.w,(a0)+
	move.l	$114.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.l	$134.w,(a0)+
	move.l	$70.w,(a0)

	lea	Video(pc),a0
	move.b	$ffff8201.w,(a0)+
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820a.w,(a0)+
	move.b	$ffff8260.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

	lea	System(pc),a0
	move.l	$44e.w,(a0)+
	move.w	$452.w,(a0)+
	move.l	$456.w,(a0)+
	move.l	$45a.w,(a0)+

	lea	$4ce.w,a1
	moveq	#7,d0
Recopy_vbl_vec:
	move.l	(a1)+,(a0)+
	dbra	d0,Recopy_vbl_vec

	jsr	Install_vectors(pc)
	jsr	Install_reset(pc)

	cmp.l	#$e00000,$4f2.w
	seq	Ste_flag

	move.l	User_stack,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.w	#6,a7

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
************************************************

Restore_all:	movem.l	d0-d7/a0-a7,Save_registers

	lea	New_stack_prg(pc),a7

	lea	Mfp_save(pc),a0
	lea	$fffffa00.w,a1
	move.b	(a0)+,$01(a1)
	move.b	(a0)+,$03(a1)
	move.b	(a0)+,$05(a1)
	move.b	(a0)+,$07(a1)
	move.b	(a0)+,$09(a1)
	move.b	(a0)+,$13(a1)
	move.b	(a0)+,$15(a1)
	move.b	(a0)+,$17(a1)
	move.b	(a0)+,$19(a1)
	move.b	(a0)+,$1b(a1)
	move.b	(a0)+,$1d(a1)

	lea	Yamaha_save(pc),a0
	moveq	#12,d0
Restore_yamaha:
	move.b	d0,$ffff8800.w
	move.b	(a0)+,$ffff8802.w
	dbra	d0,Restore_yamaha

	lea	Vector_save(pc),a0
	move.l	(a0)+,$110.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$134.w

	lea	System(pc),a0
	move.l	(a0)+,$44e.w
	move.w	(a0)+,$452.w
	move.l	(a0)+,$456.w
	move.l	(a0)+,$45a.w

	lea	$4ce.w,a1
	moveq	#7,d0
Restore_vbl_vec:
	move.l	(a0)+,(a1)+
	dbra	d0,Restore_vbl_vec

	move.l	#Rte,$70.w

	move.w	#$80,$ffff8606.w
Wait_drive_off:
	moveq	#$20,d5
Tst:	
	dbra	d5,Tst
	
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	Wait_drive_off

	lea	$ffff8800.w,a0
	move.b	#$e,d0
	move.b	d0,(a0)
	or.b	#7,d0
	move.b	d0,2(a0)

	move.w	#$2300,sr

	lea	Video(pc),a0	
	move.b	(a0)+,$ffff8201.w
	move.b	(a0)+,$ffff8203.w
	move.b	(a0)+,$ffff820a.w
	move.b	(a0)+,$ffff8260.w
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	tst.b	Ste_flag
	beq.s	Pas_ste
	sf	$ffff8901.w
	sf	$ffff820d.w
	sf	$ffff8265.w
	sf	$ffff820f.w
Pas_ste:

	move.l	Vbl_save(pc),$70.w

	move.b	#$03,$fffffc00.w
	move.b	#$96,$fffffc00.w

	lea	$e1b.w,a0
	cmp.w	#$0100,$2.w
	beq.s	Tos_100
	move.l	$4.w,d0
	move.b	#$24,d0
	move.l	d0,a0
	move.l	(a0),a0
Tos_100:
	sf	(a0)
	
	move.w	#$22,-(a7)
	trap	#14
	addq.w	#2,a7
	move.l	d0,a0
	clr.l	$6c(a0)

	jsr	Aff_registers

	move.w	#7,-(a7)
	trap	#1
	addq.w	#2,a7

	tst.b	Retour
	beq.s	Pas_de_retour
	sf	Retour
	move.l	Return_adr(pc),a0
	jmp	(a0)
Pas_de_retour:

	clr.w	-(a7)
	trap	#1

************************************************
*                                              *
************************************************

Install_vectors:
	move.l	$8.w,Old_bus_err
	move.l	#Bus_error,$8.w

	move.l	$c.w,Old_adr_err
	move.l	#Adress_error,$c.w

	move.l	$10.w,Old_ill_err
	move.l	#Illegal,$10.w

	move.l	$14.w,Old_div_err
	move.l	#Div_by_zero,$14.w

	move.l	$20.w,Old_vio_err
	move.l	#Violation,$20.w

	rts

************************************************
*                                              *
************************************************

Gicle_vectors:	move.l	a0,-(a7)

	lea	Exceptions(pc),a0
	move.l	(a0)+,$08.w	* Bus Error
	move.l	(a0)+,$0c.w	* Adress Error
	move.l	(a0)+,$10.w	* Illegal
	move.l	(a0)+,$14.w	* Div by zero
	move.l	(a0)+,$20.w	* Privilege violation

	move.l	(a7)+,a0
	rts

************************************************
*                                              *
************************************************

Install_reset:
	move.l	$42a.w,Old_reset
	move.l	#Reset,$42a.w
	move.l	#$31415926,$426.w
	rts

************************************************
*                                              *
************************************************

Gicle_reset:	clr.l	$42a.w
	clr.l	$426.w
	rts

************************************************
*                                              *
************************************************

	dc.b	"XBRA"
	dc.b	"AM44"
Old_bus_err:	dc.l	0
Bus_error:	or.w	#$700,sr
	move.w	#2,Nb_bombes
	jmp	Restore_all(pc)

************************************************
*                                              *
************************************************

	dc.b	"XBRA"
	dc.b	"AM44"
Old_adr_err:	dc.l	0
Adress_error:	or.w	#$700,sr
	move.w	#3,Nb_bombes
	jmp	Restore_all(pc)
	
************************************************
*                                              *
************************************************

	dc.b	"XBRA"
	dc.b	"AM44"
Old_ill_err:	dc.l	0
Illegal:	or.w	#$700,sr
	move.w	#4,Nb_bombes
	jmp	Restore_all(pc)
	
************************************************
*                                              *
************************************************

	dc.b	"XBRA"
	dc.b	"AM44"
Old_div_err:	dc.l	0
Div_by_zero:	or.w	#$700,sr
	move.w	#5,Nb_bombes
	jmp	Restore_all(pc)
	
************************************************
*                                              *
************************************************

	dc.b	"XBRA"
	dc.b	"AM44"
Old_vio_err:	dc.l	0
Violation:	or.w	#$700,sr
	move.w	#8,Nb_bombes
	jmp	Restore_all(pc)
	
************************************************
*                                              *
************************************************

	dc.b	"XBRA"
	dc.b	"AM44"
Old_reset:	dc.l	0
Reset:	or.w	#$700,sr
	move.w	#12,Nb_bombes
	jmp	Restore_all(pc)

************************************************
*                                              *
************************************************

Rte:	rte

************************************************
*                                              *
* Aff_number_hexa :                            *
* -----------------                            *
*                                              *
* d0.l : Number to display                     *
* a0.l : Screen Adr                            *
*                                              *
************************************************

Aff_number_hexa:
	movem.l	d0-d7/a0-a6,-(a7)

	moveq	#7,d7
Make_all_the_register:
	move.l	d0,d1
	and.w	#$f,d1
	move.b	d1,0(a0,d7.w)
	lsr.l	#4,d0
	dbra	d7,Make_all_the_register

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
************************************************

Aff_registers:	movem.l	d0-d7/a0-a6,-(a7)

	lea	Save_registers(pc),a1
	lea	Reg_map+16+6(pc),a0
	moveq	#7,d1
Scan_all_registers:
	move.l	(a1)+,d0
	jsr	Aff_number_hexa(pc)
	add.w	#16,a0
	dbra	d1,Scan_all_registers

	lea	Reg_map+16+6+9*16(pc),a0
	moveq	#7,d1
Scan_all_registers_0:
	move.l	(a1)+,d0
	jsr	Aff_number_hexa(pc)
	add.w	#16,a0
	dbra	d1,Scan_all_registers_0

	lea	Reg_map+16*19+2(pc),a0
	moveq	#11,d0
Clr_cars:
	move.b	#19,(a0)+
	dbra	d0,Clr_cars

	lea	Reg_map+16*19+2(pc),a0
	move.w	Nb_bombes(pc),d0
	subq.w	#1,d0
Aff_cars:
	move.b	#18,(a0)+
	dbra	d0,Aff_cars

	move.l	$44e.w,a0
	add.w	#16*160+128,a0
	lea	Font(pc),a1
	lea	Reg_map(pc),a2
	moveq	#1,d2
	moveq	#20,d3
Print_map_y:
	moveq	#$f,d0
	move.l	a0,a3
Print_map_x:
	moveq	#0,d1
	move.b	(a2)+,d1
	lsl.w	#3,d1

	move.b	0(a1,d1.w),(a3)
	move.b	0(a1,d1.w),2(a3)

	move.b	1(a1,d1.w),160(a3)
	move.b	1(a1,d1.w),160+2(a3)

	move.b	2(a1,d1.w),320(a3)
	move.b	2(a1,d1.w),320+2(a3)

	move.b	3(a1,d1.w),480(a3)
	move.b	3(a1,d1.w),480+2(a3)

	move.b	4(a1,d1.w),640(a3)
	move.b	4(a1,d1.w),640+2(a3)

	move.b	5(a1,d1.w),800(a3)
	move.b	5(a1,d1.w),800+2(a3)

	move.b	6(a1,d1.w),960(a3)
	move.b	6(a1,d1.w),960+2(a3)

	move.b	7(a1,d1.w),1120(a3)
	move.b	7(a1,d1.w),1120+2(a3)

	add.w	d2,a3
	eor.w	#2,d2

	dbra	d0,Print_map_x
	add.w	#8*160,a0
	dbra	d3,Print_map_y

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
************************************************

Super:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	a0,-(a7)
	move.w	#$26,-(a7)
	trap	#14
	addq.w	#6,a7
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
************************************************

	dc.b	"XBRA"
	dc.b	"AM44"
Old_trap_4:	dc.l	0

New_trap_4:	st	Retour
	move.l	a0,Return_adr
	rte

Install_new_trap:
	move.l	$90.w,Old_trap_4
	move.l	#New_trap_4,$90.w
	rts

************************************************
*                                              *
************************************************

Cookies_jar:	movem.l	d0-d7/a0-a6,-(a7)

	move.l	$5a0.w,a0

Find_all_cookies:		* Miam !
	movem.l	(a0)+,d0-d1

	tst.l	d0
	beq.s	No_cookie_jar

	cmp.l	#"WINX",d0
	bne.s	Pas_cookie_winx
	st	Winx_flag
Pas_cookie_winx:
	bra.s	Find_all_cookies
No_cookie_jar:	

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
************************************************

	SECTION	DATA

Aes_table:	dc.l	Control,Global
	dc.l	Int_in,Int_out
	dc.l	Addr_in,Addr_out

Window_error_txt:
	dc.b	"[1][ | A window error has happened,|      close one window    |   and retry to open me ! ][ !!! ]",0

Tree0:
	dc.w	-1,1,12	*Object 0
	dc.w	G_box
	dc.w	0
	dc.w	Shadowed
	dc.b	$0,$0,$00,$43
Tree0_xy:
	dc.w	0,0
	dc.w	37,15

	dc.w	2,-1,-1	* Object 1
	dc.w	G_text
	dc.w	0
	dc.w	Outlined|Shadowed
	dc.l	Title_struct
	dc.w	6,$0400
	dc.w	25,1

	dc.w	3,-1,-1	* Object 2
	dc.w	G_text
	dc.w	0
	dc.w	Outlined|Shadowed
	dc.l	Title_struct1
	dc.w	1,$0602
	dc.w	35,1

	dc.w	4,-1,-1	* Object 3
	dc.w	G_text
	dc.w	0
	dc.w	Outlined|Shadowed
	dc.l	Title_struct2
	dc.w	5,$0005
	dc.w	27,1

	dc.w	5,-1,-1	* Object 4
	dc.w	G_button
	dc.w	0
	dc.w	Shadowed
	dc.l	State_txt
	dc.w	1,8
	dc.w	10,$0201

	dc.w	8,6,7	* Object 5
	dc.w	G_ibox
	dc.w	0
	dc.w	0
	dc.l	0
	dc.w	13,8
	dc.w	21,1

	dc.w	7,-1,-1	* Object 6
	dc.w	G_button
	dc.w	Selectable|Rbutton
	dc.w	Shadowed|Selected
	dc.l	Install_txt
	dc.w	0,0
	dc.w	10,$0201

	dc.w	5,-1,-1	* Object 7
	dc.w	G_button
	dc.w	Selectable|Rbutton
	dc.w	Shadowed
	dc.l	Removed_txt
	dc.w	12,0
	dc.w	10,$0201

	dc.w	9,-1,-1	* Object 8
	dc.w	G_button
	dc.w	0
	dc.w	Shadowed
	dc.l	Reset_txt
	dc.w	1,10
	dc.w	10,$0201

	dc.w	12,10,11	* Object 9
	dc.w	G_ibox
	dc.w	0
	dc.w	0
	dc.l	0
	dc.w	13,10
	dc.w	21,1

	dc.w	11,-1,-1	* Object 10
	dc.w	G_button
	dc.w	Selectable|Rbutton
	dc.w	Shadowed|Selected
	dc.l	Install_txt
	dc.w	0,0
	dc.w	10,$0201

	dc.w	9,-1,-1	* Object 11
	dc.w	G_button
	dc.w	Selectable|Rbutton
	dc.w	Shadowed
	dc.l	Removed_txt
	dc.w	12,0
	dc.w	10,$0201

	dc.w	0,-1,-1	* Object 12
	dc.w	G_button
	dc.w	Selectable|Lastob
	dc.w	Shadowed
	dc.l	Save_state
	dc.w	6,13
	dc.w	25,$0201

****************************************************************

Title_struct:	dc.l	Title
	dc.l	0
	dc.l	0
	dc.w	3
	dc.w	0
	dc.w	2	* Justif
	dc.b	$12,%10000000
	dc.w	0
	dc.w	-2
	dc.w	33	
	dc.w	0		

Title_struct1:	dc.l	Title1
	dc.l	0
	dc.l	0
	dc.w	3
	dc.w	0
	dc.w	2	* Justif
	dc.b	$12,%10000000
	dc.w	0
	dc.w	-2
	dc.w	33	
	dc.w	0		

Title_struct2:	dc.l	Title2
	dc.l	0
	dc.l	0
	dc.w	3
	dc.w	0
	dc.w	2	* Justif
	dc.b	$12,%10000000
	dc.w	0
	dc.w	-2
	dc.w	33	
	dc.w	0		

Save_state:	dc.b	"<< R(e)save state >>",0
	EVEN
Title:	dc.b	" << Amethyste . >> ",0
	EVEN
Title1:	dc.b	" << Cerebral Vortex Software >> ",0
	EVEN
Title2:	dc.b	" << Development >> ",0
	EVEN
State_txt:	dc.b	"(S)tate :",0
	EVEN
Install_txt:	dc.b	"Installed",0
	EVEN
Removed_txt:	dc.b	"Removed",0
	EVEN
Reset_txt:	dc.b	"(R)eset :",0
	EVEN

Handle_wind:	dc.b	"GT"

Mouse_struct:	dc.w	0
	dc.w	0
	dc.w	1
	dc.w	1
	dc.w	0
	
	dc.w	$ffff,$ffff,$ffff,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$e000

	dc.w	$0000,$7ffe,$4004,$5fe8,$5fd4,$5fac,$5f54,$5ea4
	dc.w	$5d54,$5ab4,$5574,$4af4,$5404,$6ffc,$4000,$0000

Font:	dc.b	$7C,$FE,$CE,$D6,$E6,$FE,$7C,$00
	dc.b	$18,$38,$78,$18,$18,$FE,$FE,$00
	dc.b	$7C,$FE,$C6,$1C,$70,$FE,$FE,$00
	dc.b	$7C,$FE,$C6,$0C,$C6,$FE,$7C,$00
	dc.b	$30,$60,$D8,$FE,$7C,$18,$18,$00
	dc.b	$7E,$FE,$C0,$FC,$06,$FE,$7C,$00
	dc.b	$7E,$FE,$C0,$FC,$C6,$FE,$7C,$00
	dc.b	$7C,$FE,$06,$3C,$18,$30,$60,$00
	dc.b	$7C,$FE,$C6,$7C,$C6,$FE,$7C,$00
	dc.b	$7C,$FE,$C6,$7E,$06,$FE,$FC,$00
	dc.b	$7C,$FE,$C6,$FE,$C6,$C6,$44,$00
	dc.b	$7C,$FE,$C6,$FC,$C6,$FE,$7C,$00
	dc.b	$7C,$FE,$C6,$C0,$C6,$FE,$7C,$00
	dc.b	$FC,$FE,$C6,$C6,$C6,$FE,$FC,$00
	dc.b	$7C,$FE,$C6,$E0,$C6,$FE,$7C,$00
	dc.b	$7C,$FE,$C6,$E0,$C0,$C0,$40,$00
	dc.b	$00,$18,$18,$00,$18,$18,$00,$00
	dc.b	$92,$54,$38,$FE,$38,$54,$92,$00
	dc.b	$00,$70,$68,$FE,$FE,$44,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

Reg_map:	dc.b	17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17
	dc.b	17,19,13,00,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,13,01,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,13,02,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,13,03,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,13,04,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,13,05,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,13,06,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,13,07,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17
	dc.b	17,19,10,00,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,10,01,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,10,02,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,10,03,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,10,04,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,10,05,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,10,06,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,19,10,07,19,16,19,19,19,19,19,19,19,19,19,17
	dc.b	17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17
	dc.b	17,19,19,19,19,19,19,19,19,19,19,19,19,19,19,17
	dc.b	17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17

Intro_txt:	dc.b	27,"p"
	dc.b	"<< Amethyste 4.6 : C.V. 2004 >>",13,10
	dc.b	7,27,"q",0
	EVEN

************************************************
*                                              *
************************************************

	SECTION	BSS

Mfp_save:	ds.b	12	* Mfp
Yamaha_save:	ds.b	14	* Yamaha 

Vector_save:	ds.l	1	* Kbd
	ds.l	1	* Timer D
	ds.l	1	* Timer C
	ds.l	1	* Timer B
	ds.l	1	* Timer A
Vbl_save:	ds.l	1	* Vbl

System:	ds.l	1	* V_bas_ad
	ds.w	1	* Vbl_sem
	ds.l	1	* Vbl_queue
	ds.l	1	* 
	ds.l	8	* Vbls list

Video:	ds.b	1	* Video 1
	ds.b	1	* Video 2
	ds.b	1	* Resol
	ds.b	1	* Freq
	ds.w	16	* Palette

Exceptions:	ds.l	5	* Vecteurs d'exceptions
Save_registers:	ds.l	16
Nb_bombes:	ds.w	1

************************************************
*                    AES var                   *
************************************************

Global:	ds.w	3
	ds.l	6
Control:	ds.w	5

Int_in:	ds.w	32
Int_out:	ds.w	8
Addr_in:	ds.l	3
Addr_out:	ds.l	1

************************************************
*                                              *
************************************************

Ap_id:	ds.w	1
Buff_mess:	ds.w	8
X_desk:	ds.w	1
Y_desk:	ds.w	1
W_desk:	ds.w	1
H_desk:	ds.w	1

Window_nb:	ds.w	1
Curr_handle:	ds.w	1
X_wind:	ds.w	1
Y_wind:	ds.w	1
W_wind:	ds.w	1
H_wind:	ds.w	1

X_tab:	ds.w	4
Y_tab:	ds.w	4

P1:	ds.w	1
P2:	ds.w	1
P3:	ds.w	1
P4:	ds.w	1
X_redraw:	ds.w	1
Y_redraw:	ds.w	1
X1_redraw:	ds.w	1
Y1_redraw:	ds.w	1
X_clip:	ds.w	1
Y_clip:	ds.w	1
W_clip:	ds.w	1
H_clip:	ds.w	1

Evnt_mask:	ds.w	1
X_mouse:	ds.w	1
Y_mouse:	ds.w	1	
B_mouse:	ds.w	1	
Rab_key:	ds.w	1
Key_return:	ds.w	1
M_mouse:	ds.w	1

Objc_selected:	ds.w	1
Retour:	ds.b	1
Actif:	ds.b	1
Cmd:	ds.w	1
X_disp:	ds.w	1
Y_disp:	ds.w	1

Key_asc_2:	ds.b	1
Ste_flag	ds.b	1
Return_adr:	ds.l	1
Winx_flag:	ds.b	1
	ds.b	1

User_stack:	ds.l	1

	ds.l	256
New_stack_prg:

	ds.l	256
New_stack:

************************************************
*                                              *
************************************************

	END
