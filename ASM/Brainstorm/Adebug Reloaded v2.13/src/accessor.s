;
; Copyright 1990-2006 Alexandre Lemaresquier, Raphael Lemoine
;                     Laurent Chemla (Serial support), Daniel Verite (AmigaOS support)
;
; This file is part of Adebug.
;
; Adebug is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; Adebug is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Adebug; if not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;

	 ;#[ Acc init:
 lea acc_stack,sp
my_appl_init:
 lea Gem_appl_init,a0
 bsr Aes_Call
 move.w d0,Ap_id			; store the application id
my_menu_register:
 move.w Ap_id,Int_in
 move.l #adebug_menu,Addr_in
 lea Gem_menu_register,a0
 bsr Aes_Call
 bsr install_catch
	 ;#] Acc init:
	 ;#[ Acc loop:
waitforevent:
 lea Messagebuf,a0
 move.l a0,Addr_in
 lea	Int_in,a0
 move.w	#%110001,(a0)+
 clr.w	(a0)+
 clr.l	(a0)+
 clr.l	(a0)+
 clr.l	(a0)+
 clr.l	(a0)+
 clr.l	(a0)+
 clr.l	(a0)+
 clr.l	(a0)
 lea Gem_evnt_multi,a0
 clr.w	Messagebuf
; bsr Aes_Call
 moveq #0,d0
 moveq #0,d1
 lea Control,a1
 move.b (a0)+,d1
.1:
 move.b (a0)+,d0
 move.w d0,(a1)+
 dbf d1,.1
 clr.w (a1)
 lea Aes_params,a0
 move.l a0,d1
 move.w #$c8,d0
 trap #2
 tst.w	evnt_multi_sem
 bne real_start_of_adebug
 cmp.w #40,Messagebuf
 bne	waitforevent
 st	evnt_multi_sem
 bra real_start_of_adebug
	 ;#] Acc loop:
	 ;#[ Call_aes:
Aes_Call:
	moveq #0,d0
	moveq #0,d1
	lea Control,a1
	move.b (a0)+,d1
.1:
	move.b (a0)+,d0
	move.w d0,(a1)+
	dbf d1,.1
	clr.w (a1)
	lea Aes_params,a0
	move.l a0,d1
	move.w #$c8,d0
	trap #2
	move.w Int_out,d0
	tst.w d0
	rts
	 ;#] Call_aes:
	 ;#[ Install_kbd_catch:
install_catch:
	lea	catch_for_kbd(pc),a0
	bra	supexec

catch_for_kbd:
	move.l	$4f2.w,a0
	move.l	36(a0),ksh_addr
	cmp.w	#$100,2(a0)
	bne.s	.tos12
	move.w	#$22,-(sp)
	trap	#14
	addq.w	#2,sp
	add.w	#$4f,d0
	move.l	d0,ksh_addr
.tos12:
	move	#$22,-(sp)
	trap	#14
	addq.w	#2,sp
	move.l	d0,a0
	move.l	32(a0),external_keyboard
	move.l	#my_keyboard,32(a0)
	move	#1,-(sp)
	move	#14,-(sp)
	trap	#14		iorec clavier
	addq.w	#4,sp
	move.l	d0,io_ikbd
	rts

my_keyboard:
	movem.l	d0/a0-a1,-(sp)
	move.l	external_keyboard,a0
	jsr	(a0)
	tst	evnt_multi_sem
	bne.s	.non

	move.l	ksh_addr,a0
	btst	#0,(a0)
	beq.s	.non
	btst	#1,(a0)
	beq.s	.non
	move.l	io_ikbd,a0
	move.l	(a0),a1
	add	8(a0),a1
	cmpi.b	#'D',3(a1)
	bne.s	.non
	clr.l	(a1)
	move.l	6(a0),8(a0)	plus rien a lire!
	st	evnt_multi_sem
	move.l	ksh_addr,a0
	sf	30(a0)		code repeat
	sf	31(a0)
	sf	32(a0)		compteurs repeat
************
; Note importante:
; On doit annuler le Repeat_code a cause de GEM. Celui-ci va visiblement
; chercher la derniŠre touche appuy‚e dans cette variable et pas dans le
; buffer clavier. Quel bordel.
************
.non	movem.l	(sp)+,d0/a0-a1
	rts
	 ;#] Install_kbd_catch:
	IFNE catchgen
	include	catchgen.s
	ENDC	;de catchgen
	 ;#[ Create_false_basepage:
create_false_basepage:
	move.l	a5,-(sp)
	lea	false_basepage(a6),a5
	move.l	a5,p0_basepage_addr(a6)
	;ptr sur basepage
	;$8	text @
	;$c	text size
	;$10	data
	;$14	data
	;$18	bss
	;$1c	bss
	;$20	dta @
	lea	my_dta(a6),a0
	move.l	a0,$20(a5)
	;$24	parent basepage @
	;$2c	ptr sur chaine d'environnement
	;$30	octet = handle de l'entree standard (-1)
	st	$30(a5)
	;$31	" = handle sortie standard (-1)
	st	$31(a5)
	;$32	" = handle aux (-2)
	st	$32(a5)
	;$37	" octet(s ?) drive actuel
	;$40	" table de 16 octets pour gestion des fichiers
	;$68	resultat de trap
	;$6c	save a3 dans trap #1
	;$70	a4
	;$74	a5
	;$78	a6
	;$7c	a7
	;$7d	nb de car sur ligne de commande
	;$7e	ligne de commande
	move.l	(sp)+,a5
	rts
	 ;#] Create_false_basepage:

