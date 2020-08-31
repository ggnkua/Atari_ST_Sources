; Projet de modularit‚ de 'RMV Player'

; Ce fichier s'adresse aux programmeurs.

; Stabylo / The Removers
; 2 ao–t 1998 - 31 octobre 1998

**********************************************
* modules codecs
**********************************************

; Table des matiŠres.
;--------------------
;	Introduction
;	Routine d'installation : 'init_module'.
;		Arguments, Action, Retours
;		Tableau d'entr‚e
;		Tableau de retour
;	Cr‚ation de pr‚calculs
;	Lib‚ration de pr‚calculs
;	Routine d‚codeuse
;	Routine de lib‚ration du module.

***************
* Introduction.
***************

; Afin d'int‚grer plus facilement de nouveaux types de fichiers d'animation,
; Animator est modulaire. Nous d‚crirons ici toutes les rŠgles de programmation
; … respecter pour construire soi-mˆme un module. Le but de cette
; description est ‚vident : des personnes autres que l'auteur peuvent
; am‚liorer Animator en ‚crivant des modules pour ce dernier.

; L'‚l‚ment fondateur de la complication de ces rŠgles de programmation,
; c'est la gestion de la m‚moire. En effet, chaque module a le droit
; d'allouer de la m‚moire, par exemple pour faire des pr‚calculs, mais
; dans le cas o— Animator doit faire appel … plusieurs modules, pour
; jouer une s‚rie d'animations, n'est-il pas dommage de devoir toujours
; recalculer ce qui a d‚ja ‚t‚ fait ?

; Par ailleurs, si on choisi de conserver ces pr‚calculs (comme le faisait
; AviPlayer) il serait dommage d'en venir … manquer de m‚moire, alors qu'il
; est probable que certains d'entre eux ne sont plus en service et qu'il
; constituent un bloc de m‚moire cons‚quent.

; C'est pour r‚pondre … la fois … ces deux problŠmes qu'a ‚t‚ mise en
; place une micro bibliothŠque de fonctions mises … la disposition du
; programmeur de modules.

; Les modules doivent donc d‚clarer leurs pr‚calculs au noyau au moyen
; de routines transmises en paramŠtres lors de l'initialisation du module.
; De mˆme, l'allocation de m‚moire se fera par le biais d'une fonction
; du noyau, afin de lib‚rer un pr‚calcul inutilis‚ en cas de manque de
; m‚moire. De surcroŒt, Animator se chargera de g‚n‚rer un message d'erreur
; si rien n'a pu ˆtre fait pour allouer un bloc. En reprennant la main, le
; noyau cesse le parcours de l'animation en cours et effectue un retour au
; burean GEM, sauf si l'erreur n'‚tait pas fatale et que l'option
; 'NoFail' a ‚t‚ activ‚e dans la ligne de commande.

; Si une erreur survient lors de la d‚compression d'une image ou d'un son,
; la routine 'erreur_survenue' permet de le signaler au noyau. Une telle
; erreur n'affecte aucunement le noyau dans la restitution de l'animation.

; Enfin, lorsqu'Animator a fini d'utiliser un module, il appelle une
; routine de ce dernier qui de charge de signaler que les pr‚calculs
; compterons un utilisateur de moins.

; En effet, il se peut qu'… un instant donn‚, plusieurs modules cohabient
; en m‚moire en utilisant les mˆmes pr‚calculs ! Cela se produit pour
; les fichiers AVI comportant plusieurs flux video. C'est pourquoi
; Animator compte le nombre d'utilisateurs d'un pr‚calcul donn‚ plut“t
; que de signaler si un pr‚calcul est utilis‚ ou non.

; Bien entendu, afin d'‚viter que deux modules ne cr‚‚ent deux fois le
; mˆme pr‚calcul - celui de conversion YUV->RGB, par exemple -, il est
; associ‚ un identifiant … chaque pr‚calcul. Cet identifiant comporte
; quatre caractŠres : c'est un mot long du type '_YUV' ou bien 'HCCV'
; (Hi Color ConVert) ou 'RSMP' (ReSaMPle).



*************************
* Routine d'installation : 'init_module'.
*************************

; Bien s–r, elle initialise le module. Elle est situ‚e au d‚but de
; celui-ci de telle sorte que l'on puisse l'appeler en sautant … la
; premiŠre instruction de la zone TEXT. Comme toutes les routines du
; module, elle se termine par l'instruction 'RTS'


; En gros.
;---------
; La routine d'initialistion
;	- prends connaissance de certaines variables cruciales pour le codec
;	- v‚rifie qu'elle est appel‚e … bon escient.
;	- signale quels sont les pr‚calculs qu'elle utilise.
;	- cr‚‚ des pr‚alculs si besoin.
;	- retourne les adresses des routines principales du module.

; En d‚tail.
;-----------

; 'init_module' est appel‚e par un saut (JSR) sur le d‚but du module.
; Elle doit donc se situer AU DBUT de la zone TEXT du module.

; Arguments.
;-----------
; d0.l : contient la longueur en octets du tableau d'entr‚e.
; a0.l : contient l'adresse d'un tableau d'entr‚e d‚crit plus loin.

; RŠgles de programation.
;------------------------
; 'init_module' n'a le droit de modifier QUE les registres d0/a0
; ( pour transmettre les valeurs de retour ).
; En cas d'erreur, elle s'occuppe de d‚sallouer les blocs qu'elle
; a r‚serv‚ le cas ‚ch‚ant : la routine de lib‚ration du module
; n'est pas transmise, donc elle ne sera pas appel‚e.

; La routine DOIT VRIFIER QUE LE TABLEAU EST ASSEZ GRAND pour comporter
; les variables dont elle a besoin ( voir le retour d'erreurs ci-dessous ).
; Ceci permettra d'allonger ce tableau plus tard sans p‚naliser les codecs
; ‚crits auparavant.

; Cette routine a la possibilit‚ de cr‚er des pr‚calculs ( voir m‚thode
; d‚taill‚e plus loin ) … l'aide de ces variables. Les adresses des
; pr‚calculs cr‚‚s peuvent ˆtre gard‚es dans des variables internes au
; module pour ˆtre utilis‚ plus simplement, mais elles doivent
; syst‚matiquement ˆtre r‚initialis‚e par 'init_module'.

****** Important ******
; Elle a l'obligation de copier toutes les valeurs qui peuvent lui ˆtre
; utile par la suite, car le contenu du tableau de paramŠres est suceptible
; d'ˆtre modifi‚ sans pr‚avis.

; Les valeurs ainsi copi‚es b‚n‚ficieront en outre d'un accŠs plus simple
; et plus rapide pour le module.


; retours
;--------
INIT_MOD_OK		equ	0
INIT_MOD_BAD_COMP	equ	-1
INIT_MOD_TOO_FEW_ARGS	equ	-2
INIT_MOD_UNWAITED_ERROR	equ	-3
; d0=0 : autorisation d'utiliser le module
; d0<>0 : utilisation du module interdite : erreur d'initialisation.
;	d0=-1 : compression non reconnue
; 	d0=-2 : pas assez de paramŠtres
;	d0=-3 : erreur inattendue ( valeurs incoh‚rentes... )

; a0 : adresse du tabeau de retour ( d‚crit plus loin )



; tableau d'entr‚e.
;------------------
info_init_codec		rsstruct
chemin_application	rs.l	1
adr_recherche_precalc	rs.l	1	; \
adr_mem_alloc		rs.l	1	; |-> d‚taill‚s ci-dessous
adr_libere_precalc	rs.l	1	; |
adr_erreur_survenue	rs.l	1	; /
type			rs.b	4
sizeof			rs	0
RESET_SIZEOF		equ	6*4

; Voici des explication sur ces vriables g‚n‚rales :

; adr_recherche_precalc
; C'est l'adresse d'une routine qui recherche le pr‚calcul correspondant
; … l'identificateur pass‚ en argument.
; Arguments.
;	d0 : identificateur FOURCC du pr‚calcul.
; Retour.
; Deux cas se pr‚sentent pour le retour.
;	d0=0 : pr‚calcul inexistant
;		a0 : pointe sur un decripteur vide prˆt … ˆtre rempli.
;		( structure d‚taill‚e plus loin)
;	d0>0 : pr‚calcul trouv‚
;		a0 : pointe sur le descripteur du pr‚calcul correspondant.
;	d0<0 : cr‚ation de pr‚calcul impossible (erreur fatale d‚ja produite)



; adr_mem_alloc
; Routine d'allocation de m‚moire.
; Arguments.
;	d0>0 : taille du bloc … r‚server. Produit une erreur le cas ‚ch‚ant.
;	d0<0 : ne pas utiliser cette possibilit‚.
;	d0=0 : voir remarques
;	d1.w : mode de Mxalloc
;		0=STramOnly, 1=TTramOnly, 2=PrefSTram, 3=PrefTTram.
; Retours.
;	d0=0  : plus de m‚moire disponible.
;	d0<>0 : adresse du bloc allou‚.
; Elle est appel‚e ainsi :
;	...
;	move.l	taille,d0
;	jsr	mem_alloc
;	tst.l	d0
;	beq	allocation_impossible
;	...
**** Remarques importantes. ****
; Si en argument d0=0, la taille du plus grand bloc disponible est retourn‚e
; dans d0.
; Comme pour la routine du GEMDOS, les registres d0-d2, et a0-a2 peuvent ˆtre
; modifi‚s sans crier gare.



; adr_libere_precalc
; C'est l'adresse d'une routine qui recherche le pr‚calcul correspondant
; … l'identificateur pass‚ en argument. S'il existe, elle le signale
; comme non utilis‚.
; Arguments.
;	d0 : identificateur FOURCC du pr‚calcul.
; But.
;	pr‚venir que le module n'utilise plus le pr‚calcul.
; Retours.
;	Aucun



; adr_erreur_survenue
; Cette routine signale au noyau qu'une erreur s'est produite lors de
; la d‚compression d'une image. Cette routine ne fait que prendre
; note de l'erreur survenue ; elle ne constitue en aucun cas une maniŠre
; d'interrompre la d‚compression.
; Puisqu'une erreur sur une image n'est pas sens‚e affecter le d‚codage
; de la suivante, le noyau continuera … jouer l'animation tant que lui-mˆme
; ne rencontrera de difficult‚ majeure.
; Arguments.
;	d0 : code d'erreur … signaler
; But.
; 	Signaler une erreur survenue, sans modifier l'ex‚cution en s‚quence
;	du programme.
; Retours.
;	Aucun

	; si le type vaut 'vids' (flux vid‚o)
compression		rs.b	4	; d‚taill‚ ci-dessous
bits_par_pixel		rs.w	1	; 2, 4, 8, 16, 24, 32 ...
largeur			rs.w	1	; dimensions du flux video
hauteur			rs.w	1
adr_ecran_centre	rs.l	1	; d‚taill‚ ci-dessous
x_ecran			rs.w	1	; dimensions de l'‚cran
y_ecran			rs.w	1
adr_palette		rs.l	1
video_sizeof		rs	0

; Voici des explication sur ces vriables sp‚cifiques … la video :

; compression
; c'est le FOURCC (four character code) qui identifie la compression.
; Pour ‚viter d'‚ventuelles erreurs de la part du noyau, 'init_module'
; DOIT VRIFIER qu'il s'agit bien d'une compression qu'elle reconnaŒt.

; adr_ecran_centree
; C'est est l'adresse du pixel situ‚ au coin sup‚rieur gauche de
; l'animation, calcul‚e de maniŠre … obtenir un affichage centr‚.
; Dans le cas d'une d‚compression de haut en bas, il s'agit l… de
; l'adresse … partir de laquelle la d‚compression se fait.


	; si le type vaut 'auds' (flux audio)
			rsset	info_init_codec.sizeof
format			rs.w	1	; 0=inconnu, 1=PCM, 2=ADPCM, ....
nb_voies		rs.b	1	; 1=mono, 2=st‚r‚o
bits_par_sample		rs.b	1	; en g‚n‚ral ‚gal … 4, 8 ou 16.
frequence		rs.l	1	; en g‚n‚ral ‚gal … 11025, 22050 ou 44100 (voire 88200)
format_sortie		rs.w	1	; voir d‚tails ci-dessous
nb_voies_sortie		rs.b	1
bits_sortie		rs.b	1
frequence_sortie	rs.w	1
audio_sizeof		rs	0
			rsend


; Voici des explication sur ces vriables sp‚cifiques … l'audio :

; Les variables 'format_sortie', 'nb_voies_sortie', 'bits_sortie' et
; 'frequence_sortie' d‚finissent le format du son en entr‚e.

; Les variables 'format_sortie', 'nb_voies_sortie', 'bits_sortie' et
; 'frequence_sortie' d‚finissent le format du son en sortie.

; format_sortie
; La routine d‚codeuse interprete le format PCM=1 8 bits en sortie comme
; sign‚ ( format PCM sur Atari ) et en entr‚e comme non sign‚ ( format
; PCM sur PC ).

; La routine encodeuse interprŠte … l'inverse : le PCM 8 bit est sign‚ en
; entr‚e et non sign‚ en sortie. Ceci permet la conversion au format PCM
; lors de la cr‚ation d'un fichier AVI.



; tableau de retour.
;-------------------

; L'adresse de ce tableau est retourn‚e dans a0.
information_module	rsstruct
adr_decodeur		rs.l	1
adr_encodeur		rs.l	1
adr_libere_module	rs.l	1
sizeof			rs	0
			rsend

; Si l'une des deux premiŠres routines est absente du module, alors
; l'adresse correspondante doit ˆtre mise … z‚ro ( NULL ).

; Si une erreur s'est produite lors de l'initialisation, on peut
; positionner 'adr_libere_module' … 0 ( NULL ).



*************************
* Cr‚ation de pr‚calculs
*************************

; Cette cr‚ation se fait … l'aide des routines 'recherche_precalc' et
; 'mem_alloc'.

; Dans le cas o— le pr‚calcul est d‚j… pr‚sent ( d0<>0 ), il est … la charge
; de 'init_module' d'incr‚menter d'une unit‚ le nombre d'utilisateurs de ce
; pr‚calcul pour signaler l'utilisation de ce dernier par le module.

; Dans le cas o— le pr‚calcul n'est pas d‚j… en m‚moire ( d0=0 ), la routine
; d'initialisation doit remplir le descripteur vide point‚ par a0.

descripteur_precalc	rsstruct
identificateur		rs.b	4
adresse_bloc		rs.l	1
nb_utilisateurs		rs.w	1
sizeof			rs	0
			rsend

; exemple de descripteur fraŒchement cr‚‚.
;	dc.b	'_YUV'		; Conversion YUV->RGB
;	dc.l	$35df54		; adresse du pr‚calcul
;	dc.w	1		; un seul utilisateur

; Remarques importantes.
;-----------------------
; Un pr‚calcul est inutilis‚ si 'nb_utilisateurs' vaut 0
; Un descripteur est dit VIDE si 'adresse_bloc' vaut 0 ( NULL ).
; Un descripteur dont l'identificateur est nul signale la fin de la liste.



**************************
* Lib‚ration de pr‚calculs
**************************

; IMPORTANT
; Les BLOCS allou‚s pour les pr‚calculs ne sont jamais explicitement lib‚r‚s
; par le module.
; C'est le gestionnaire de m‚moire s'en occupe selon les besoins auxquels il
; fait face.

; Le module signale qu'il cesse d'utiliser un pr‚calcul en appelant la
; routine 'libere_precalc' qui diminue d'une unit‚ le nombre d'utilisateurs
; du pr‚calcul.

*************************
* Routine d‚codeuse
*************************

; Codecs video.
;--------------
; Arguments
;	a0 : adresse du bloc … d‚compresser.
;	d0 : longueur de ce bloc.

; Format video d‚compress‚.
;	Le d‚codeur ‚crit … l'adresse indiqu‚e lors de l'initialisation
;	l'image d‚compress‚e au format ATARI True Color ( ou plut“t HiColor ).
;	Les champs RVB occupent respectivement 5, 6, et 5 bits d'un mot au
;	format Motorola, et s'y succŠdent dans cet ordre.

; Retours.
;	Aucun
;	TOUS les registres peuvent ˆtre modifi‚s par la routine d‚codeuse.



; Codecs audio.
;--------------
; Arguments
;	d0 : longueur du bloc source.
;	a0 : adresse du bloc source … d‚compresser.
;	a1 : adresse du bloc destination o— d‚compresser le son.

; Format audio d‚compress‚.
;	Le format de sortie est pr‚cis‚ … l'initialisation.
;	Le d‚codeur ‚crit … l'adresse indiqu‚e en paramŠtre le bloc de
;	son d‚compress‚ et r‚‚chantionn‚ … la fr‚quence demand‚e.

; Retours.
;	d0 : longueur du bloc destination
;	TOUS les registres peuvent ˆtre modifi‚s par la routine d‚codeuse.



*************************
* Routine encodeuse
*************************

; Pas de sp‚cifications. Ne pas se servir de cette possibilit‚.



**********************************
* Routine de lib‚ration du module.
**********************************

; Elle a pour r“le essentiel de lib‚rer chaque pr‚calcul par un appel
; … la routine 'libere_precalc'.


; En gros.
;---------
;	- Elle signale que les pr‚calculs dont le module avait besoin
;	  ne sont plus utilis‚s.
;	- Elle libŠre la m‚moire ‚ventuellement allou‚e par le module.

; RŠgles de programation.
;------------------------

; CHAQUE pr‚calcul utilis‚ par le module DOIT ˆtre l'objet d'un appel …
; 'libere_precalc'.

; Toute m‚moire allou‚e en douce avec le GEMDOS doit ˆtre lib‚r‚e.
; ( Nota : pr‚f‚rez 'Mxalloc #3' au traditionnel Malloc pour les allouer )

; Seuls les registres d0/a0 peuvent ˆtre modifi‚s.




**********************************************
* modules de format de fichier
**********************************************

; Contient
;	une routine reconnaissant le type du fichier.
;	une routine jouant l'animation
;	une routine de lib‚ration









