; REMBRANDT 3.0 - Ω  Dbug II
;
; Module de gestion des formulaires GEM. (1.0)
;
;
 ifeq _main_part
 <pREMB_xxx.S>q doit àtre assemblÇ !!!
 END
 endc

	TEXT
 
affiche_formulaire
 wind_update #1
 form_center adresse_formulaire		Centre la ressource
 move int_out+2,x_form	RÇcupäre les coordonnÇes
 move int_out+4,y_form
 move int_out+6,l_form
 move int_out+8,h_form
 form_dial #0,#0,#0,#0,#0,x_form,y_form,l_form,h_form
 tst.b flag_shrink_box
 beq.s .pas_grow_box
 form_dial #1,#0,#0,#0,#0,x_form,y_form,l_form,h_form
.pas_grow_box
 objc_draw adresse_formulaire,premier_objet,#2,x_form,y_form,l_form,h_form
 wind_update #0
 rts

ferme_formulaire
 movem.l d0-a6,-(sp)
 wind_update #1
 tst.b flag_shrink_box
 beq.s .pas_shrink_box
 form_dial #2,#0,#0,#0,#0,x_form,y_form,l_form,h_form
.pas_shrink_box
 form_dial #3,#0,#0,#0,#0,x_form,y_form,l_form,h_form
 wind_update #0
 movem.l (sp)+,d0-a6
 rts


; Il semble que le Form-Do rajoute +$8000 lors d'un double click sur
; un objet Ætouch exitØ
 
gere_formulaire
 form_do adresse_formulaire,#0
 move #-1,-(sp)		Signification des bits de D0:
 move #11,-(sp)		0 - SHIFT droit		4 - CAPS LOCK
 trap #13		1 - SHIFT gauche	5 - CLR HOME (bouton droit)
 addq #4,sp		2 - CONTROL		6 - INSERT (bouton gauche)
 move d0,touches_mortes	3 - ALTERNATE
 move int_out,objet_exit
 and #$0fff,objet_exit
 move int_out,d0
 and #$f000,d0
 sne flag_double_click
 objc_change adresse_formulaire,objet_exit,x_form,y_form,l_form,h_form,#0,#1
 rts


*
* Permet de changer la valeur d'un drapeau en fonction du flag
* SÇlected affectÇ Ö un bouton. Bref, si le bouton est enfonáÇ, alors
* le flag est Ö TRUE sinon, il est Ö FALSE.
*
* A0-> Adresse du formulaire
* A1-> Adresse du drapeau
* D0-> NumÇro (*24) du bouton
*
mÇmorise_bouton 
 btst.b #0,ob_state+1(a0,d0.w)
 sne (a1)
 rts

*
* Permet de changer le flag SELECTED affectÇ Ö un bouton selon la valeur
* d'un drapeau. Bref, si le FLAG est Ö zÇro, le bouton est relevÇ, sinon
* il est enfoncÇ.
*
* A0-> Adresse du formulaire
* A1-> Adresse du drapeau
* D0-> NumÇro (*24) du bouton
*
positionne_bouton 
 tst.b (a1)
 beq.s .reläve_bouton
.enfonc_bouton
 bset #0,ob_state+1(a0,d0.w)	SÇlectionne objet
 rts
.reläve_bouton
 bclr #0,ob_state+1(a0,d0.w)	DÇselectionne objet
 rts

