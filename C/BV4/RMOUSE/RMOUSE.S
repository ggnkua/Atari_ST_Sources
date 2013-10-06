;*******************************************************************************
;	This program is free software; you can redistribute it and/or modify it
;	under the terms of the GNU General Public License as published by the Free
;	Software Foundation; either version 2 of the License, or any later version.
;	This program is distributed in the hope that it will be useful, but WITHOUT
;	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
;	more details.
;	You should have received a copy of the GNU General Public License along
;	with this program; if not, write to the Free Software Foundation, Inc.,
;	675 Mass Ave, Cambridge, MA 02139, USA.
;******************************************************************************


;PUT RELATIVE MOUSE by Megar/BNR (Gilles Bouthenot)

;struct:
; ACT_X		L ;sortie, adresse o— prendre la position X.W
; ACT_Y		L ;sortie, adresse o— prendre la position Y.W
; ACT_BUT		L ;sortie, adresse o— prendre la position bouton (%rl)

; XDEF RMOUSE_ON
; XDEF RMOUSE_OFF

EXPORT RMOUSE_ON
EXPORT RMOUSE_OFF

;UTILISATION: Si le bouton reste appuy‚: appelle RMOUSE_ON
;la rout va te renvoyer l'adresse les adresses o— sont les donn‚es
;de la souris.

;La position actuelle sera en 16383,16383.
;ensuite, tu boucles: 
; tu regardes si le bouton est appuy‚, si oui; tu r‚cupŠre les coordonn‚es
; et si ca a chang‚, tu r‚affiche, juste aprŠs avoir v‚rifi‚ que le bouton
; est toujours appuy‚.
;C'est tout simple hein ?

;si par exemple tu recois la coord 16380,16390, la souris aura ‚t‚
;d‚plac‚e de -3,7. Tu r‚ffiche et tu stocke ces valeurs. Ensuite,
;si tu re‡ois 16380,16384, la souris aura ‚t‚ d‚plac‚e de 0,-6.
;Voil…, c'est tout ce qu'il y a … savoir !

;Pour inactiver la souris relative, il te suffit d'appeler RMOUSE_OFF !

RMOUSE_ON:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,a5		;a5=struct
	dc.w	$a000		;Linea Init
	move.l	d0,a6		;a6=Linea Vars
	dc.w	$a00a		;Hide Cursor
	lea	Linea_Sav,a4

	move.w	-12(a6),(a4)+	;save max x
	move.w	-4(a6),(a4)+	;save max y
	move.l	-602(a6),(a4)+	;save act x&y
	move.w	#$7fff,-12(a6)	;put new max_x
	move.w	#$7fff,-4(a6)	;put new max_y

	lea	-602(a6),a4	;act_x
	move.l	a4,(a5)+
	move.w	#$3fff,(a4)+
	move.l	a4,(a5)+
	move.w	#$3fff,(a4)
	addq.l	#4,a4
	move.l	a4,(a5)+
	movem.l	(sp)+,d0-d7/a0-a6
	rts

Linea_Sav:	dc.l	0
	dc.l	0

RMOUSE_OFF:
	movem.l	d0-d7/a0-a6,-(sp)
	dc.w	$a000		;Linea Init
	move.l	d0,a6		;a6=Linea Vars
	lea	Linea_Sav,a4

	move.w	(a4)+,-12(a6)	;restore max x
	move.w	(a4)+,-4(a6)	;restore max y
	move.l	(a4)+,-602(a6)

	dc.w	$a009		;Show Cursor
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	