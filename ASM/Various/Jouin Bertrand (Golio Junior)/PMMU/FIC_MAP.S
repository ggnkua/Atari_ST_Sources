* fichier de visualisation des contenus des registres de la PMMU
* modification de la table de la pmmu
* Par Golio Junior

					* structure qui contient tous les registres de la pmmu
	rsreset
reg_tc	rs.l	1			* registre tc de la pmmu
reg_crp	rs.l	2			* registre crp de la pmmu
reg_srp	rs.l	2			* registre srp de la pmmu
reg_tt0	rs.l	1			* registre tt0 de la pmmu
reg_tt1	rs.l	1			* registre tt1 de la pmmu
pmmu_reg	equ	__RS

					* structure qui d‚crit une pages physique
	rsreset
des_suiv	rs.l	1		* pointeur sur le suivant
des_page	rs.l	1		* adresse de la page physique
des_descr	rs.l	1		* adresse du descripteur de page
					* ce dernier champ vaut 0 lorsque le descripteur de
					* page ne d‚crit rien
des_page_log	rs.l	1		* adresse logique que repr‚sente cette page
descr_page	equ	__RS

					* d‚finition de la structure de la tables de
					* traduction
taille_1er	equ	16		* 16 mots longs pour la table de 1er niveau
nb_1er		equ	1		* 1 table de 1er niveau (!!)
taille_2nd	equ	16		* 16 mots longs pour la table de 2nd niveau
nb_2nd		equ	3		* 2 tables de 2nd niveau
taille_3ieme	equ	16		* 16 mots longs pour la table de 3ieme niveau
nb_3ieme	equ	1		* 1 table de 3ieme niveau
taille_4ieme	equ	256		* 256 mots longs pour la table de 4ieme niveau
nb_4ieme	equ	1		* 1 table de 4ieme niveau

					* d‚finition de l'adresse de la zone de m‚moire virtuelle
					* adresse en $800?????
index_1er	equ	8		* index dans la 1ere table : 8
index_2nd	equ	0		* index dans la 2nd table : 0
index_3ieme	equ	0		* index dans la 3ieme table : 0

					* d‚finition de la m‚moire virtuelle manipul‚e
taille_page	equ	4096		* taille d'une page
masque_pages	equ	$FFFFF000	* masque pour l'adresse des pages soit sur un multiple de page
nb_page_p	equ	4		* nombre de pages physique pour la m‚moire virtuelle
nb_page_l	equ	256		* nombre de pages logique pour la m‚moire virtuelle

	section TEXT
programme
					* passage en superviseur
	clr.l -(sp)
	move.w #32,-(sp)
	trap #1
	addq.l #6,sp
					* sauvegarde des registres de la PMMU
	bsr	sauve_pmmu
					* cr‚ation des nouvelles tables de translation
	bsr	creer_tables
					* cr‚ation de la tables de vecteurs d'exeptions
	bsr	creer_vecteurs
					* installation de la table des vecteurs
	bsr	creer_pmmu
					* ajout des tables pour la gestion
					* de la m‚moire virtuelle
	bsr	ajout_tables
					* initialisation des descripteurs de pages physiques
	bsr	init_descripteur

					* ouverture du fichier qui va etre mapp‚
					* en m‚moire virtuelle
	move.w	#0,-(sp)
	move.l	#fichier,-(sp)
	move.w	#61,-(sp)		* F_open
	trap	#1
	adda.l	#8,sp

	move.w	d0,swap_handle		* sauvegarde du handle
	bmi	erreur_ouverture

					* test des tables de la pmmu
	ptestr	#%001,(a0),#7,a6	* a6 contient l'adresse de l'entr‚e de la table
					* de traduction correspondant … l'adresse a0

					* g‚n‚ration d'une "erreur bus"
	move.l	#$80000000,a0		* une adresse bien exotique!
	ptestr	#%001,(a0),#7,a6	* cf avant
	move.l	(a0),d0			* normalement, cela a provoqu‚ le chargement
					* de la premiŠre page du fichier en m‚moire

					* sauvegarde du contexte video
	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14			* VsetMode
	addq.l	#4,sp
	move.w	d0,s_videmod
					* changement de la video
	move.w	#89,-(sp)
	trap	#14
	addq.l	#2,sp

	lea	mode_video,a0
	cmp.w	#2,d0			* on suppose que l'on se trouve
					* sur VGA ou RGB
					*         --
	beq	.VGA
	addq.l	#2,a0
.VGA
	move.w	s_videmod,d1
	and.w	#%0000000000110000,d1
	or.w	(a0),d1

	move.w	d1,-(sp)
	move.w	#3,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14			* Setscreen
	lea	(14,sp),sp
					* r‚cup‚ration de l'adresse physique
					* de l'‚cran dans d0
	move.w	#2,-(sp)
	trap	#14			* PhysBase
	addq.l	#2,sp

					* "chargement" et affichage!
	move.l	#$80000000+18,a0	* l'image affich‚e est un 320*200 en 24 bits
					* donc on ne regarde pas les informations du header
					* header de 18 octets pour les TGA
	move.l	d0,a1
	move.w	#200-1,d0		* compteur des y
prg_init_b_y
	move.w	#320-1,d1		* compteur des x
prg_init_b_x
					* conversion d'un point : 3 octets
					* composante rouge
	move.b	(a0)+,d4

	lsl.l	#8,d4
	andi.w	#%1111100000000000,d4

	move.b	(a0)+,d5		* composante verte
	lsl.w	#3,d5
	andi.w	#%0000011111100000,d5
	or.w	d5,d4
	
	move.b	(a0)+,d5		* composante bleu
	lsr.w	#3,d5
	andi.w	#%0000000000011111,d5
	or.w	d5,d4

	move.w	d4,(a1)+		* sauvegarde et affichage du r‚sultat

	dbra	d1,prg_init_b_x

	dbra	d0,prg_init_b_y

					* attente d'un touche pour admirer
	move.w	#7,-(sp)
	trap	#1			* Crawcin
	addq.l	#2,sp

					* restauration de la video
	move.w	s_videmod,-(sp)
	move.w	#3,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14			* Setscreen
	lea	(14,sp),sp

	move.w	swap_handle,-(sp)
	move.w	#62,-(sp)
	trap	#1			* F_close
	addq.l	#4,sp

erreur_ouverture
					* restauration de la PMMU
	bsr	restaure_pmmu
					* restauration des vecteurs d'exceptions
	bsr	restaure_vecteurs

					* retour au mode utilisateur
	clr.l -(sp)
	move.w #32,-(sp)
	trap #1
	addq.l #6,sp

					* retour systŠme
	move.w #0,-(sp)
	trap #1



* -------------------------------------------------------------------
*		routine de sauvegarde de la pmmu
* -------------------------------------------------------------------
sauve_pmmu
					* sauvegarde des registres de la pmmu
	lea	pmmu,a0
	pmove.l	tc,(reg_tc,a0)		* utilisation de pmove pour l'accŠs aux
	pmove.d	crp,(reg_crp,a0)	* registres de la pmmu
	pmove.d	srp,(reg_srp,a0)	* tiens un registre de 64 bits
	pmove.l	tt0,(reg_tt0,a0)
	pmove.l	tt1,(reg_tt1,a0)
	rts

* -------------------------------------------------------------------
*		restauration des registres pmmu
* -------------------------------------------------------------------
restaure_pmmu
	lea	pmmu,a0
	move.l	(reg_tc,a0),d0
	move.l	#0,(reg_tc,a0)
	pmove.l	(reg_tc,a0),tc		* plus de PMMU !
	pmove.d	(reg_crp,a0),crp
	pmove.d	(reg_srp,a0),srp
	pmove.l	(reg_tt0,a0),tt0
	pmove.l	(reg_tt1,a0),tt1

	move.l	d0,(reg_tc,a0)
	pmove.l	(reg_tc,a0),tc		* on remet la PMMU
					* on peut se permettre cette acrobatie, car
					* sur un falcon bien constitu‚, la m‚moire logique
					* correspond … la m‚moire physique (sur les 16 premiers Mo)
	pflusha				* invalidation du cache de traduction

	rts

* -------------------------------------------------------------------
*		routine de cr‚ation des tables
* -------------------------------------------------------------------
creer_tables
					* pour cr‚er la table, on utilise
					* la table d‚j… pr‚sente pour la PMMU
					* en la d‚calant pour coller avec notre emplacement
					* elle fait 64 entr‚e, et se situe
					* … l'adresse $700
	move.l	#tables+256,d0		* l'adresse de d‚but de table
	and.l	#$ffffff00,d0		* doit etre un multiple de 256
	move.l	d0,a0			* donc, on invalide les 8 bits
	move.l	d0,adr_tables		* de poids faibles

					* on utilise la table par d‚faut du systŠme
					* situ‚e … l'adresse contenue dans crp
	move.w	#64-1,d7
	lea	pmmu,a1
	move.l	(reg_crp+4,a1),d6	* r‚cup‚ration de l'adresse dans l'ancien crp
	move.l	d6,a1
.b1
	move.l	(a1)+,d1		* r‚cup‚ration du descripteur
	btst	#1,d1			* adresse d'une table de niveau inf‚rieur?
	beq	.s1			* non alors on passe son chemein
	sub.l	d6,d1			* sinon soustraction de la base
					* on obtient donc un offset
	add.l	d0,d1			* addition … l'offset de la nouvelle base
.s1
	move.l	d1,(a0)+		* sauvegarde dans la nouvelle table
	dbra	d7,.b1

	rts

* -------------------------------------------------------------------
*		Ajout des tables pour la gestion de la m‚moire virtuelle
* -------------------------------------------------------------------
ajout_tables
					* modification de la table de 1er niveau
	move.l	adr_tables,d0		* on ajoute … la fin des tables
	move.l	d0,a0			* les tables servant … la description
					* de la m‚moire virtuelle, utilis‚e
					* pour le mapping de fichier
	add.l	#taille_1er*4*1+taille_2nd*4*2+taille_3ieme*4*1,d0
	move.l	d0,d1
	or.b	#%00000010,d1		* d1 : pointe sur une table
					* de descripteur court
	move.l	d1,(a0,index_1er*4)	* modification de la table de 1er niveau

					* cr‚ation de la table de second niveau
	move.l	d0,a0			* a0 : adresse de d‚but de la table de second niveau
	add.l	#taille_2nd*4*1,d0	* d0 : adresse de d‚but de la table de 3iŠme niveau
	move.l	d0,d1
	or.b	#%00000010,d1		* pointe sur une table
					* de descripteur court
	move.l	d1,(a0)+		* il n'y a que la premiŠre entr‚e qui est valide
	move.w	#taille_2nd-1-1,d7	* le reste n'est constitu‚
	move.l	#0,d1			* que de descripteurs invalides
.b1
	move.l	d1,(a0)+
	dbra	d7,.b1
					* cr‚ation de la table de 3iŠme niveau
	add.l	#taille_3ieme*4*1,d0	* d0 : adresse de la table de 4iŠme niveau
	move.l	d0,d1
	or.b	#%00000010,d1		* d1 : pointe sur une table
					* de descripteur court
	move.l	d1,(a0)+		* et il n'y a que la premiŠre
	move.w	#taille_3ieme-1-1,d7	* entr‚e qui est valide
	move.l	#0,d1			* le reste : que des descripteurs invalides
.b2
	move.l	d1,(a0)+
	dbra	d7,.b2
					* cr‚ation de la table de 4iŠme niveau
					* ici que des descripteur de page invalides !
					* car aucune page n'est charg‚e
	move.w	#taille_4ieme-1,d7
	move.l	#0,d1
.b3
	move.l	d1,(a0)+
	dbra	d7,.b3
	rts

* -------------------------------------------------------------------
*		Cr‚ation de la nouvelle configuration m‚moire
* -------------------------------------------------------------------
creer_pmmu
	lea	new_pmmu,a0
	move.l	#$80C04448,(reg_tc,a0)
					* mmu valid‚e
					* page de 4Ko !
					* tous les bits significatifs pour la
					* translation d'adresse
					* 4 bits pour le premier niveau
					* 4 bits pour le second
					* 4 bits pour le troisiŠme
					* 8 bits pour le quatriŠme
	move.l	#$80000002,(reg_crp,a0)
	move.l	#$80000002,(reg_srp,a0)
					* limite descendante
					* limite de 0 : pas de limite
					* pointe sur un descripteur de 4 octets
	move.l	adr_tables,d0
	move.l	d0,(reg_crp+4,a0)
	move.l	d0,(reg_srp+4,a0)
					* adresse de la table
	move.l	#$00000000,(reg_tt0,a0)
	move.l	#$00000000,(reg_tt1,a0)
					* pas de transparence

					* Installation de la nouvelle
					* configuration m‚moire
	lea	new_pmmu,a0		* chargement des registres
	pmove.l	(reg_tc,a0),tc		* de la pmmu
	pmove.d	(reg_crp,a0),crp
	pmove.d	(reg_srp,a0),srp
	pmove.l	(reg_tt0,a0),tt0
	pmove.l	(reg_tt1,a0),tt1
	pflusha				* et invalidation du cache de traduction

	rts

* -------------------------------------------------------------------
*		Cr‚ation de la nouvelle tables des vecteurs de saut
* -------------------------------------------------------------------
creer_vecteurs
						* sauvegarde de l'ancienne adresse
						* de la table des vecteurs
	movec.l	vbr,d0				* adresse de la table des vecteurs
	move.l	d0,adr_vecteurs			* est contenue dans vbr
						* copie de l'ancienne table
	move.l	d0,a0
	lea	vecteurs,a1
	move.w	#256-1,d0
.b1
	move.l	(a0)+,(a1)+
	dbra	d0,.b1

						* installation des vecteurs pour la pmmu
	lea	vecteurs,a0
	move.l	(a0,2*4),adr_erreur_bus
	move.l	#erreur_bus,(a0,2*4)
	move.l	(a0,56*4),erreur_pmmu
	move.l	#erreur_pmmu,(a0,56*4)
						* installation de la nouvelle tables
	lea	vecteurs,a0
	movec.l	a0,vbr
	rts

* -------------------------------------------------------------------
*		Restauration de l'ancienne table de vecteurs
* -------------------------------------------------------------------
restaure_vecteurs
						* on remet vbr … sa valeur initiale
	move.l	adr_vecteurs,d0
	movec.l	d0,vbr
	rts

* -------------------------------------------------------------------
*		Initialisation de la table de descripteur
* -------------------------------------------------------------------
init_descripteur
						* chaque descripteur pointe sur
						* le suivant dans la liste
						* ils sont donc chain‚s circulairement
	lea	desc_pages,a0			* descripteur courant
	lea	(descr_page,a0),a1		* descripteur suivant
	move.l	#pages+taille_page,d0		* calcul de l'adresse de la premiŠre
	andi.l	#masque_pages,d0		* page physiques, les pages sont sur des adresses
	move.l	d0,a2				* multiple de la taille des pages
	move.w	#nb_page_p-1-1,d0
.b1
	move.l	a1,(des_suiv,a0)		* adresse du descripteur suivant
	move.l	a2,(des_page,a0)		* adresse de la page physique
						* d‚crite par ce descripteur
	move.l	#0,(des_descr,a0)		* adresse de l'entr‚e dans la table de traduction
						* du descripteur utilisant cette page
						* ici, c'est initialis‚ … 0 par convention, pour savoir si une page
						* est occup‚e ou pas
	move.l	#0,(des_page_log,a0)		* l'adresse logique de cette page, initialis‚e … 0
						* passage au suivant
	lea	(descr_page,a0),a0
	lea	(descr_page,a1),a1
	lea	(taille_page,a2),a2
	dbra	d0,.b1

						* cas du dernier descripteur
	lea	desc_pages,a1			* dont le suivant est le premier
	move.l	a1,(des_suiv,a0)
	move.l	a2,(des_page,a0)
	move.l	#0,(des_descr,a0)
	move.l	#0,(des_page_log,a0)

	move.l	#desc_pages,desc_courant	* stockage du descripteur courant
						* pour l'algorithme de r‚cup‚ration de page
	rts

* -------------------------------------------------------------------
*		Gestion d'une erreur de bus
* -------------------------------------------------------------------
erreur_bus
	movem.l	d0-d2/a0-a2,-(sp)
						* test de l'adresse d'erreur bus
	move.l	($10+6*4,sp),d0			* d0 : adresse qui a caus‚ l'erreur
	move.l	d0,d1
	andi.l	#$FFF00000,d1			* on regarde si elle appatient … la m‚moire virtuelle
	cmp.l	#$80000000,d1
	beq	erreur_bus_memoire_virtuelle	* et on passe la main … la routine de gestion
						* adresse pas en m‚moire virtuelle alors
						* on redonne la main au systŠme
						* aprŠs avoir biensur restaur‚ le contexte
	pea	erreur_bus_message
	move.w	#9,-(sp)
	trap	#1				* affichage d'un petit message
	addq.l	#6,sp
	bsr	restaure_vecteurs
	bsr	restaure_pmmu
	movem.l	(sp)+,d0-d2/a0-a2
	jmp	([adr_erreur_bus])

erreur_bus_memoire_virtuelle
						* d‚termination du No de page logique
	move.l	d0,d1
	and.l	#$000FF000,d1			* le num‚ro de la page logique
	lsl.l	#4,d1				* se trouve dans les bits 20..12
	swap	d1				* No de la page fautive dans d1.w
	
						* allocation d'une page physique
	move.l	desc_courant,a0
	move.l	(des_suiv,a0),desc_courant	* passage au descripteur suivant pour la prochaine page

	tst.l	(des_descr,a0)			* la page est occup‚e?
	beq	.descripteur_vide		* non alors on la prend
						* sinon l'ancienne page ne
						* sera plus pr‚sente
	move.l	#0,([des_descr,a0])		* le descripteur logique de l'ancienne page
						* indique qu'il n'y a pas de page
	pflush	#%000,#%000,([des_page_log,a0])
						* invalidation de l'ATC

.descripteur_vide
						* chargement de la page en m‚moire

	move.l	d0,-(sp)			* sauvegarde de l'adresse fautive
	move.l	a0,-(sp)			* sauvegarde de l'adresse du descripteur utilis‚
	move.l	a0,-(sp)			* en deux exemplaires

						* d‚termination de l'adresse dans le fichier
	mulu.w	#taille_page,d1			* d1 : offset de la page

	move.w	#0,-(sp)			* positionnement du pointeur
	move.w	swap_handle,-(sp)		* sur le fichier
	move.l	d1,-(sp)			* au bon endroit
	move.w	#66,-(sp)			* F_seek
	trap	#1
	adda.l	#10,sp
	tst.l	d0
	bmi	erreur_bus_memoire_virtuelle_erreur
						* chargement de la page
	move.l	(sp)+,a0			* r‚cup‚ration du descripteur de page
	move.l	(des_page,a0),-(sp)		* r‚cup‚ration de l'adresse 
						* de la page physique
	move.l	#taille_page,-(sp)
	move.w	swap_handle,-(sp)
	move.w	#63,-(sp)			* F_read
	trap	#1
	adda.l	#12,sp
	tst.l	d0
	bmi	erreur_bus_memoire_virtuelle_erreur

	move.l	(sp)+,a0			* adresse du descripteur utilis‚
	move.l	(sp)+,a2			* r‚cup‚ration de l'adresse fautive
						* modification de la table
	ptestr	#%001,(a2),#7,a1		* adresse du descripteur de la 
						* page fautive dans a1
	move.l	(des_page,a0),d0		* r‚cup‚ration de l'adresse physique
	andi.b	#%00000000,d0
	ori.b	#%00000001,d0			* descripteur de page, non utilis‚e, non modifi‚e
						* pas prot‚g‚ en ‚criture
	move.l	d0,(a1)				* modification de la table de traduction
	move.l	a1,(des_descr,a0)		* modification du descripteur physique
	move.l	a2,(des_page_log,a0)		* sauvegarde de l'adresse logique de la page

						* c'est fini !
	movem.l	(sp)+,d0-d2/a0-a2
	rte

erreur_bus_memoire_virtuelle_erreur
						* si il y a eu une erreur,
						* on redonne la main au systeme
						* restauration de la video
	move.w	s_videmod,-(sp)
	move.w	#3,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14				* Setscreen
	lea	(14,sp),sp

	move.w	swap_handle,-(sp)
	move.w	#62,-(sp)
	trap	#1				* F_close
	addq.l	#4,sp

	pea	erreur_bus_message_3
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	restaure_vecteurs
	bsr	restaure_pmmu
	movem.l	(sp)+,d0-d2/a0-a2
	jmp	([adr_erreur_bus])	

* -------------------------------------------------------------------
*		Gestion d'une erreur de pmmu
* -------------------------------------------------------------------
erreur_pmmu
						* on affiche un petit message
						* et on redonne la main au systŠme
						* pour qu'il affiche de joli bombe !
	movem.l	d0-d2/a0-a2,-(sp)
	pea	erreur_pmmu_message
	move.w	#9,-(sp)
	trap	#1				* affichage du message
	addq.l	#6,sp
						* restauration des vecteurs
	bsr	restaure_vecteurs
						* restauration de la pmmu
	bsr	restaure_pmmu
	movem.l	(sp)+,d0-d2/a0-a2
	jmp	([adr_erreur_pmmu])		* poursuite de l'erreur de PMMU par le systŠme


* -------------------------------------------------------------------
*		Constantes globales
* -------------------------------------------------------------------
erreur_pmmu_message	dc.b	"erreur de configuration de la pmmu",13,10,0
erreur_bus_message	dc.b	"erreur bus",13,10,0
erreur_bus_message_2	dc.b	"acc‚s … la m‚moire virtuelle",13,10,0
erreur_bus_message_3	dc.b	"erreur dans la m‚moire virtuelle",13,10,0

fichier	dc.b	"falk'mag.tga",0

						* 320*200 True color
mode_video	dc.w	%0000000100000100	* configuration VGA
		dc.w	%0000000000000100	* configuration RGB

reg_vide	dcb.b	pmmu_reg,0

* -------------------------------------------------------------------
*		Variables globales
* -------------------------------------------------------------------
	section	bss
	even
vbr	ds.l	1					* sauvegarde du registre vbr
pmmu		ds.b	pmmu_reg			* configuration de l'ancienne pmmu
new_pmmu	ds.b	pmmu_reg			* configuration de la nouvelle pmmu
adr_tables	ds.l	1				* adresse de la 1ere tables
adr_vecteurs	ds.l	1				* adresse de l'ancienne table des vecteurs
adr_erreur_bus	ds.l	1				* adresse de l'ancienne routine d'erreur bus
adr_erreur_pmmu	ds.l	1				* adresse de l'ancienne routine d'erreur pmmu
desc_courant	ds.l	1				* adresse du descripteur courant pour l'algo de remplacement
vecteurs	ds.l	256				* tables de vecteurs d'exceptions
tables	ds.l	taille_1er*nb_1er+taille_2nd*nb_2nd+taille_3ieme*nb_3ieme+taille_4ieme*nb_4ieme+256/4
							* zones des tables de la pmmu
pages	ds.b	taille_page*nb_page_p+taille_page	* m‚moire pour les pages physiques
desc_pages	ds.b	descr_page*nb_page_p		* m‚moire pour les descripteurs de pages
swap_handle	ds.w	1				* handle du fichier de swap
s_videmod	ds.w	1