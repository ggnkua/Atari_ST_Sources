	include	gemdos.i
	include	zlib.i
	include	structs.s

	include	..\macro.i

	XDEF	load_toolbar_rsc_file
	XREF	tool_bar_path
	text
* La fenetre contenant des objets a copier se sauvegarde. Simpa pour l'utilisateur non ?
* Chargement de la barre d'outils...
load_toolbar_rsc_file
	Fsfirst			#0,#tool_bar_path
	tst_rts
	charge_ressource	#tool_bar_path
	tst_rts
	move.l			d0,d6			; d6 = adresse de la table des pointeurs sur arbre

	move.l		d6,a6
	move.l		d6,a3
	add.w		rsh_object(a6),a3	; a5 pointe sur le premier objet du premier tree

.boucle_charge_tree
* on trouve l'adresse de l'arbre puis on le copi dans un buffer separer pour pouvoir
* y copier de nouveaux objets. On en profite pour Mallok‚ un blok par objet...
* ... plus simple pour les delete !
	Malloc		#24*256		; 256 objets, ca fait large non ?
	tst_rts
	move.l		d0,a2
	move.l		d0,d5

.boucle_copy_un_objet
	movem.l		(a3)+,d0-d4
	move.l		a2,a4
	move.l		d0,(a2)+	; 4
	move.l		d1,(a2)+	; 8
	move.l		d2,(a2)+	; 12
	move.l		d3,(a2)+	; 16
	move.l		d4,(a2)+	; 20
	move.l		(a3)+,(a2)+	; 24
	objc_real	a4		; macro magique qui malloc l'objet dans un bloc separe.
	btst		#16+LASTOB,d2	; dernier objet ?
	beq		.boucle_copy_un_objet

	Mfree		d6			; pas de blocs inutilement stokes...
	move.l		d5,d0
	rts
	text
