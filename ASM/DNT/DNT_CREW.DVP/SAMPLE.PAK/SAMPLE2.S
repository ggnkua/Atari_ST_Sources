; ********************************************************************
; *  Proggy qui convertit un sample du format incremental en format: *
; *    "Comecetaiavan"! La encore c'est assez simple.                *
; *                                            Dracula/Positivity    *
; ********************************************************************
;
; Pour convertir un fichier, mettre dans loadname le nom du fichier de
;   depart, dans savename celui d' arrivee et mettre la longueur du
;          fichier a convertir comme equivalent de length!

length	equ	25808	

;*************
  Section TEXT
  
load_file: 		; Tout d' abord chargeons le fichier, 
  move.w	#$0,-(sp)	; et mettons le dans le buffer!
  pea	loadname
  move.w	#$3d,-(sp)	; Fonction Fopen, ouvre le fichier en
  trap	#$1	; lecture uniquement!
  add.l	#$8,sp
  tst.w	d0	; Si d0 est negatif, c'est qu'il y a
  bmi	error	; une erreur, sinon d0 contient le
  move.w	d0,d7	; numero de canal.
  
  pea	buffer
  move.l	#length,-(sp)
  move.w	d7,-(sp)
  move.w	#$3f,-(sp)	; Fonction Fread, met les 'length' bytes
  trap	#$1	; lus dans buffer.
  add.l	#$c,sp
  tst.w	d0	; Si d0 est negatif, c'est qu'il y a
  bmi	error	; une erreur.
 
  move.w	d7,-(sp)
  move.w	#$3e,-(sp)	; Fonction Fclose, ferme le canal!
  trap	#$1
  addq.l	#$4,sp
  tst.w	d0	; Comme d' hab!
  bmi	error
 
convert_file:		; Ici, vient le processus qui fait l'inverse
  move.l	#buffer,a0	; du fichier 'sample1.s'.
  move.b	(a0)+,d0	; d0 contiendra la valeur de l'increment.
  move.l	#length,d7  	; d7=longueur-2, a cause du premier
  subq.l	#$2,d7	; byte et du dbra.
  move.b	d0,d1	; d1 contiendra la valeur du byte.
.one_byte:		
  move.b	(a0),d0	; d0=valeur de l'increment courant.
  add.b	d0,d1	; d1=byte precedent+increment.
  move.b	d1,(a0)+	; Sauver ce byte.
  dbra	d7,.one_byte

save_file: 		; Le fichier est convertit, sauvons le! 
  move.w	#$0,-(sp)
  pea	savename
  move.w	#$3c,-(sp)	; Fonction Fcreate, cree le fichier en
  trap	#$1	; mode normal!
  add.l	#$8,sp
  tst.w	d0	; Si d0 est negatif, c'est qu'il y a
  bmi	error	; une erreur, sinon d0 contient le
  move.w	d0,d7	; numero de canal.
  
  pea	buffer
  move.l	#length,-(sp)
  move.w	d7,-(sp)
  move.w	#$40,-(sp)	; Fonction Fwrite, met les 'length' bytes
  trap	#$1	; du buffer dans le fichier.
  add.l	#$c,sp
  tst.w	d0	; Si d0 est negatif, c'est qu'il y a
  bmi	error	; une erreur.
 
  move.w	d7,-(sp)
  move.w	#$3e,-(sp)	; Fonction Fclose, ferme le canal!
  trap	#$1
  addq.l	#$4,sp
  tst.w	d0	; Comme d' hab!
  bmi	error
  
  clr.w	-(sp)	; Fonction Pterm, finis le proggy.
  trap	#$1	; Ici, c' est pas la peine de tester
  		; d0, car si il y a une erreur a ce
  		; niveau ca veut dire big problemos!
  			  
error:		; Comme je suis sympa ( n'est ce pas? )
  pea	errormsg	; je vous previens si il y a une erreur.
  move.w	#$9,-(sp)
  trap	#$1	; Fonction Printline, affiche un texte
  addq.l	#$6,sp  	; entier! Ake c' est cool!
  
  move.w	#$7,-(sp)	; Comme le user n' est peut-etre pas
  trap	#$1	; Superman, il veut mieux que le texte
  addq.l	#$2,sp   	; ne parte pas trop viiiiiiiite!
  
  clr.w	-(sp)
  trap	#$1
 

;*************
  Section DATA

loadname:
  dc.b	'a:\woaha.xxx',$0
savename:
  dc.b	'a:\wooahaha.xxx',$0
errormsg:
  dc.b	' Ake il y a une erreur, ake c' est pacool!',$d,$a
  dc.b	'  Pressez la touche "Any" pour continuer!',$d,$a,$0
   
;************
  Section BSS
  
buffer:		; Normalement, ce buffer devrait avoir une
  ds.l	$8000  	; taille suffisante, sinon changez le.
  
  
