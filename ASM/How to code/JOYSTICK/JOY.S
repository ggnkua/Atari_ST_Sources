*-------------------------------------------------------------------------*
*            Routine de gestion KEY/JOY par Major X                       *
*-------------------------------------------------------------------------*
*      Attention routine a modifier suivant son utilisation.              *
*-------------------------------------------------------------------------*
*       Bit 0 a 3 pour la position                                        *
*       Bit 7 pour bouton de feu                                          *
*                                                                         *
*  <*> Pour le clavier                                                    *
*       Adress du flag = keyboard + scancode                              *
*-------------------------------------------------------------------------*

	pea	00.w		* Superviseur
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
*-------------------------------------- desactive souris
	move.b	#$12,d0
	bsr	send_kbd
*-------------------------------------- Configure joystick 
	move.b	#$14,d0
	bsr	send_kbd
*-------------------------------------- Installe la nouvelle routine clavier
	lea	$118,a0
	move.l	(a0),old_kbd_vect
	move.l	#kbd_vect,(a0)

*--*    Exemple bas + fire

	*kk
	*move.b	joy1,d0
	*cmpi.b	#%10000010,d0
	*bne.s	kk

*-------------------------------------- Restitution des param de depart
	move.l	old_kbd_vect,$118
	move.b	#8,d0
	bsr	send_kbd
*-------------------------------------- Pterm
	clr.w	-(sp)
	trap	#1
*-------------------------------------------------------------------------*
* Subroutine
*-------------------------------------------------------------------------*

*-------------------------------------- Envoie un CHR au copro clavier
send_kbd:
	btst	#1,$fffffc00.w		* Attend ke le precedent CHR
	beq.s	send_kbd		* soit parti
	move.b	d0,$fffffc02.w		* envoie le CHR
	rts

kbd_vect:
	move.w	d0,-(sp)
	move.l	a0,-(sp)

	clr.w	d0
	move.b	$fffffc02.w,d0
	tst.w	packet
	bne.s	kbd_depacket
	cmpi.b	#$fe,d0
	beq.s	kbd_joy0
	cmpi.b	#$ff,d0
	beq	kbd_joy1
	lea	keyboard,a0
	btst	#7,d0			*- Si touche relever vas ailleur
	bne.s	kbd_supr		*/
	st.b	0(a0,d0.w)		* sinon set son flag
end:
	move.l	(sp)+,a0
	move.w	(sp)+,d0
	bclr	#6,$fffffa11.w		* end of interupt
	rte

kbd_joy0:
	st.b	packet			* positionne le pointeur sur joy0
	move.l	#joy0,kel_joy
	bra.s	end
kbd_joy1:				* positionne le pointeur sur joy1
	st.b	packet
	move.l	#joy1,kel_joy
	bra.s	end
kbd_depacket:				* lis le packet de data d'un joy
	clr.w	packet
	move.l	kel_joy,a0
	move.b	d0,(a0)
	bra.s	end	
kbd_supr:				* si la touche est relever
	bclr	#7,d0
	clr.b	0(a0,d0.w)		* D-set son flag
	bra.s	end
*--------------------------*
	SECTION	DATA
*--------------------------*

*--------------------------*
	SECTION	BSS
*--------------------------*
packet:
	ds.w	1
kel_joy:
	ds.l	1
joy0:	ds.b	1
joy1:	ds.b	1	
old_kbd_vect
	ds.l	1
keyboard:
	ds.b	128
