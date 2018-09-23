; REMBRANDT 3.0 - ½  Dbug II
;
; Module de gestion des drivers RIM. (1.0)
;
; - Localisation et comptage des fichiers RIM pr‚sents dans le r‚pertoire
; - Evaluation de la place m‚moire n‚c‚ssaire pour les charger en entier
; - R‚servation d'un bloc m‚moire de la bonen taille
; - Chargement des RIM dans le buffer:
;     Si il n'est pas du type [READ_IMG,_VDI] on ne le m‚morise pas.
;
;EN-TETE DES RIMS:
; dc.b "READ_IMG"     Driver de lecture d'image
; dc.b "_VDI"         Qui les traite au format VDI
; dc.w 0              0->RIM Total, 1-> RIM Partiel, 2-> RIM g‚n‚rateur
; dc.b "DEGA_PAC"     Ici c'est du Degas compact‚
; dc.w 100            Num‚ro de version
; dc.b "Image Degas Compact‚          ",0,0  30 caractŠres d‚crivant la fonction de ce fichier RIM, suivis de 2 octets nuls. 
; bra teste_fichier   	V‚rification du fichier
; bra extrait_palette
; bra traite_fichier
;
; [Nb: La DTA (Disk Transfert Area) de Rembrandt est en MY_DTA]
;
 rsreset
rim_type_driver		rs.l 2  ["READ_IMG"]
rim_format_driver	rs.l 1	["_VDI"]
rim_type_chargement	rs.w 1	0=Total / 1=Partiel
rim_identifiant		rs.l 2  ["DEGA_PAC"] ou ["ARTDIREC"] ou...
rim_num_version		rs.w 1  commence … $0100
rim_type_fichier	rs.b 32
rim_routine_teste	rs.l 1
rim_routine_palette	rs.l 1
rim_routine_image	rs.l 1

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc
 
 section TEXT

exc
execute_driver_rim
 pea table_mfdb				La taille de param‚trage
 move.l extension,-(sp)			Extension du fichier
 move.l taille_fichier,-(sp)		Taille du fichier 
 move.l taille_fichier,-(sp)		Taille charg‚e (=taille fichier)
 move.l buffer_fichier,-(sp)		Adresse du fichier source
 clr -(sp)				Code=0 (1er appel) (Si on avait Code=1, cela serait un autre appel...)
 move.l adresse_rim,a0			Adresse du driver RIM
 jsr rim_routine_teste(a0)		Appelle la routine de test +56
 lea 22(sp),sp
 tst d0
 bne.s .fichier_reconnu
 boite_alerte #1,#alert_image_non_reconnue
 bra .error_exec

.fichier_reconnu
 cmp #1,d0
 bne.s .ya_assez_d_infos
 boite_alerte #1,#alert_pas_asser_info
 bra .error_exec
 
.ya_assez_d_infos
 bsr get_info_rim

 cmp #2,d0
 bne.s .ya_pas_palette
;
; On traite la palette
;
;** Get_palette() **
;retour%=C:driver%+60(code&,     L:adr_source%,    L:size_source%, 
;L:adr_destination%, L:nombre_couleurs%,L:adr_MFDB%)
;Avec le saut de 60 on saute sur la routine de r‚cup‚ration de  la 
;palette.
;
;Valeurs de retour%:
;0  ->  Erreur.  Donn‚es ne correspondant pas  …  la  palette,  ou 
;palette absente de ce fichier.
;1 -> Quantit‚ de donn‚es trop faible.  Rappel:  l… encore le  PRG 
;Appelant doit charger au moins 512 octets. Pour un RIMs total, il 
;faut envoyer le totalit‚ des donn‚es.
;2 -> Succ‚s.
;
;code&  Comme pour Test_file() 
;
;adr_source%  Adresse  …  laquelle le PRG Appelant  …  d‚pos‚  les 
;donn‚es.
;
;size_source% Taille de ces donn‚es
;
;adr_destination%  Adresse  … partir de laquelle la  routine  doit 
;d‚poser la palette apr‚s traitement.
;
;nombre_couleur%  c'est le nombre de couleurs que le PRG  Appelant 
;veut  voir traiter par la routine.  Il est ainsi possible que  le 
;PRG  ne demande que les premiŠres couleurs de la palette.  Si  le 
;PRG  veut une couleur sur deux,  il est de sa  responsabilit‚  de 
;demander toutes les couleurs et de les traiter ensuite.
;
;A  l'appel le PRG doit remplir a nouveau la MFDB en placant  dans 
;le  premier  long  mot de celle-ci la taille du  fichier  sur  le 
;disque.  En  retour,  le  RIM aura rempli cette MFDB  comme  pour 
;l'appel  TEST_FILE(),  c'est … dire dans le premier long  mot  le 
;"seek"  pour les donn‚es de l'image et dans les octets  14-17  la 
;taille de ces donn‚es.
;     Si  le fichier ne comporte pas de palette ou bien si le  PRG 
;ne veut pas de traitement de celle-ci,  il doit n‚anmoins appeler 
;cette routine afin de connaitre le seek et la taille des  donn‚es 
;composant  l'image.  Il  suffit  pour cela de  faire  l'appel  en 
;donnant 0 comme nombre de couleurs … traiter.
;
;     Le format des couleurs est tr‚s important:  ‚tant donn‚  que 
;nous  travaillons au format VDI,  la routine devra  d‚poser  dans 
;adr_destination%,  les  couleurs dans l'ordre et avec  le  codage 
;VDI.  Ce  codage est du type RGB,  mais avec des valeurs de  0  … 
;1000,  tenant  chacune sur un mot.  Ainsi un vert 362 devra  ˆtre 
;cod‚ comme ceci:
;(3*1000)/7=428
;(6*1000)/7=857
;(2*1000)/7=285
;Donc au format VDI: 428-857-285
;     Il  faut  ‚galement  faire attention au  fait  que  certains 
;fichiers peuvent contenir un codage de palette pr‚vu pour le STE, 
;et donc avoir des composantes not‚es de 0 … F et pas de 0 … 7. Il 
;faudra alors faire:
;(valeur_composante_system*1000)/15=valeur composante.VDI
;     L'adresse destination pointera donc sur une zone destin‚e  … 
;recevoir  les couleurs au format VDI c'est … dire avec un  codage 
;sur 3 mots (6 octets) par couleur.

 pea table_mfdb			Adresse MFDB
 moveq #0,d0
 move nombre_couleurs,d0
 move.l d0,-(sp)		Nombre de couleurs
 move.l #adresse_palette+4,adresse_palette
 pea adresse_palette+4		Adresse de la palette finale
 move.l mfdb_taille_palette,-(sp)	Taille de la palette
 move.l buffer_fichier,a0	Adresse de la palette source
 add.l mfdb_seek,a0
 pea (a0)
 clr -(sp)			Code
 move.l adresse_rim,a0		Adresse du driver RIM
 jsr rim_routine_palette(a0)
 lea 22(sp),sp
 tst d0
 beq .error_exec

.ya_pas_palette

;** Do_file() **
;retour%=C:driver%+64(code&,     L:adr_source%,    L:size_source%, 
;L:adr_MFDB%)
;Avec le saut de 64 on saute sur la routine traite_fichier

;Valeur possible pour retour%:
;0 -> Erreur (fichier abim‚, mauvais type etc...)
;1  -> Toutes les donn‚es fournies ont ‚t‚ trait‚es,  il  faut  en 
;recharger d'autres.  Mais attention,  toutes les lignes du buffer 
;"standard"  n'ont  pas ‚t‚ remplies,  le PRG Appelant  doit  donc 
;recharger   des   donn‚es,    mais   ne   doit   pas   faire   de 
;Transform_form().
;2 -> Toutes les lignes du buffer "standard" ont ‚t‚ remplies.  Le 
;PRG Appelant doit donc faire un Transform_form() mais ne doit pas 
;recharger  de  donn‚es  dans le buffer "source"  car  toutes  ces 
;donn‚es n'ont pas ‚t‚ lues.
;3 -> C'est le cas de 1 ET de 2 en mˆme temps:  toutes les donn‚es 
;ont ‚t‚ lues,  et en plus toutes les lignes du buffer  "standard" 
;ont   ‚t‚  remplies.   Le  PRG  Appelant  doit  donc   faire   un 
;Transform_form() et en plus il doit recharger des donn‚es dans le 
;buffer  "source".  C'est le seul cas qui doit normalement  arriv‚ 
;avec  les RIMs "total" puisque ceux-ci re‡oivent la totalit‚  des 
;informations.
;
;code& 0->Premier appel, sinon code&=1.
;
;adr_source%  Adresse  des donn‚es  du  fichier.
;
;size_source%  Taille de ces donn‚es.
;
;adr_MFBD%  Adresse  de la structure MFDB  d‚finissant  le  buffer 
;"standard" dans lequel on doit tranf‚rer les donn‚es de l'image.
;Cette  structure a ‚t‚ modifi‚e par le PRG Appelant  et  contient 
;d‚sormais  l'adresse du buffer "standard" dans les deux  premiers 
;mots:
;     DC.L      adresse du buffer standard
;     DC.W      320     ; sa largeur en pixels
;     DC.W      200     ; son nombre de ligne
;     DC.W      80      ; la largeur d'un plan en mot
;     DC.W      0       ; inutilis‚ par la routine
;     DC.W      4       ; nombre de plans
;     DC.W      0       ; r‚serv‚     
;     DC.W      0       ; r‚serv‚     
;     DC.W      0       ; r‚serv‚
;
;     La  routine  va donc devoir d‚poser les donn‚es  de  l'image 
;dans  le  buffer "standard",  en faisant attention au  nombre  de 
;ligne  de  celui-ci,  et … sa largeur en mot,  qui  permettra  de 
;sauter  du lieu de d‚pot des donn‚es plan1 au lieu de  d‚pot  des 
;donn‚es plan2 etc...  Ainsi,  si le buffer standard fait 5 lignes 
;de haut et que la largeur d'un plan en mot est de 40, la distance 
;s‚parant  le d‚but de la premiŠre ligne plan1,  du d‚but  de  la 
;premiŠre ligne plan2 sera de (40*2)*5=400 octets. Il faut refaire 
;ce  calcul  apr‚s chaque Transform_form()  du  PRG  Appelant.  En 
;effet,  si l'image fait par exemple 250 lignes,  et que la  place 
;m‚moire  disponible permet de r‚server un buffer standard de  120 
;lignes,  le PRG Appelant demandera … la routine, 2 op‚rations sur 
;120  lignes  et pour terminer une op‚ration  sur  10  lignes.  La 
;structure  MFDB  d‚finissant  le  buffer  "standard"  sera   donc 
;diff‚rent lors du troisi‚me appel. Cela ne vaut que pour les RIMs 
;partiel.  En  effet,  le  PRG  appelant …  la  responsabilit‚  de 
;r‚server  un  buffer assez gros pour recevoir  l'image  une  fois 
;trait‚e.

 move mfdb_largeur_image,d0
 mulu mfdb_hauteur_image,d0	Nombre de pixels de l'image
 lsr.l #3,d0			/8 -> Nombre d'octets par plan
 mulu nombre_plans,d0		Nombre d'octets total composant l'image
 lea buffer_d‚packing,a0	R‚serve un bloc pour que le RIM ‚crive
 bsr.l r‚serve_bloc		l'image au format VDI...
 bmi erreur_m‚moire_d‚packing
 
 pea table_mfdb			Adresse MFDB
 move.l taille_fichier,-(sp)	Taille du fichier 
 move.l buffer_fichier,a0	Adresse de l'image
 add.l mfdb_seek,a0
 pea (a0)
 clr -(sp)			Code
 move.l buffer_d‚packing,mfdb_adresse_buffer
 move.l adresse_rim,a0		Adresse du driver RIM
 jsr rim_routine_image(a0)
 lea 14(sp),sp
 tst d0

 lea buffer_fichier,a0
 bsr.l libŠre_bloc

 bsr recode_palette_vdi
 bsr.l pr‚pare_buffer_image
 bsr transforme_image_vdi
    
.fin_exec
 moveq #0,d0
 rts

.error_exec
 moveq #-1,d0
 rts

;
; R‚cupŠre les infos de la MFDB
;
get_info_rim
 movem.l d0-a6,-(sp)
 move mfdb_largeur_image,d0
 add d0,d0
 move d0,largeur_image

 move mfdb_hauteur_image,d0
 move d0,hauteur_image

 move mfdb_nombre_plans,d1
 move d1,nombre_plans
 subq #1,d1
 moveq #2,d0
 lsl d1,d0
 move d0,nombre_couleurs

 move mfdb_largeur_plan,d0
 add d0,d0
 move d0,largeur_plan		Largeur d'un plan en octets...
 movem.l (sp)+,d0-a6
 rts



transforme_image_vdi
 move.l adresse_palette,a0	La palette TrueBidouill‚e !
 move.l buffer_d‚packing,a1	L'image … convertir
 move.l fichier,a2		Le buffer pour stocker l'image

 move largeur_plan,d0		largeur d'un plan en mot
 mulu hauteur_image,d0		La taille totale d'un plan en octets.
     
 move.l d0,d4
 lsr.l d4			Nombre de mots … traiter.

 move nombre_plans,d2
 subq #1,d2
  
.bloc_suivant

 moveq #16-1,d6			Il y … 16 pixels par bloc
.pixel_suivant
 move.l a1,a3			D‚but du bloc du premier plan.
 move d2,d7			Le nombre de plans (de 1 … n)
 moveq #0,d3			La couleur est mise … 0
.plan_suivant
 roxl.w (a3)			Teste le bit
 addx d3,d3			M‚morise le bit
 add.l d0,a3			Passe au plan suivant.
 dbra d7,.plan_suivant
 and #%11111111,d3
 move d2,d7			Le nombre de plans (de 1 … n)
 moveq #0,d5
.plan_suivant2
 roxr d3
 addx d5,d5
 dbra d7,.plan_suivant2
 move (a0,d5.w*2),(a2)+		Affiche le pixel
 dbra d6,.pixel_suivant

 addq #2,a1			Passe au bloc suivant (2*nombre de plans)

 subq.l #1,d4
 bne .bloc_suivant		Passe au multiple de 16 suivant...
 moveq #0,d0
 rts


 

 
chargement_rim_choisi
 move.l adresse_drivers_rim,a5
 move num‚ro_rim_courant,d0
 mulu #50,d0
 add d0,a5			D‚but de la zone d'infos du RIM.

 lea adresse_rim,a0		Descripteur
 move.l 34(a5),d0		Taille du fichier
 bsr.l r‚serve_bloc
 bne erreur_rim_m‚moire

 move.l adresse_nom_rim,a0	Recopie le nom … la fin du chemin d'accŠs
 move.l 38(a5),(a0)+
 move.l 42(a5),(a0)+
 move.l 46(a5),(a0)+ 
 
 move #1,-(sp)			Ouvre en lecture
 pea chemin_drivers_rim		Nom du fichier
 move #$3d,-(sp)		> FOPEN
 trap #1
 addq #8,sp
 tst d0
 bmi erreur_rim_chargement
 move d0,handle

 move.l adresse_rim,-(sp)	Adresse de chargement du RIM
 move.l 34(a5),-(sp)		56 octets … charger
 move handle,-(sp)
 move #$3f,-(sp)		> FREAD
 trap #1
 lea 12(sp),sp
 tst.l d0
 bmi erreur_rim_chargement

 move handle,-(sp)		On ferme le fichier
 move #$3e,-(sp)		> FCLOSE
 trap #1
 addq #4,sp
 tst d0
 bmi erreur_rim_chargement

 move.l #execute_driver_rim,adresse_routine_chargement

 move.l a5,adresse_txt_chargement
 moveq #0,d0
 rts
 


;
; On commence par compter les RIM, on ‚value la place m‚moire n‚c‚ssaire...
; En bref, on fait un recensement !
;
charge_drivers_rim
 sf flag_drivers_rim
 tst.b flag_utiliser_rim
 bne.s .effectue_chargement_rim
 rts
 
.effectue_chargement_rim
 clr position_s‚lection_rim


 move #0,-(sp)			Fichier normal
 pea chemin_drivers_rim
 move #$4e,-(sp)		> FSFIRST
 trap #1
 addq #8,sp
 tst d0
 bne erreur_rim_absent

 moveq #0,d7
 moveq #0,d6
 lea my_dta,a6

.compte_drivers_rim
 addq #1,d7			Un driver de plus
 add.l #50,d6			Rajoute 50 octets pour m‚moriser l'info
 move #$4f,-(sp)		> FSNEXT
 trap #1
 addq #2,sp
 tst d0
 beq.s .compte_drivers_rim

 move d7,nombre_drivers_rim	M‚morise le nombre de RIM
 move.l d6,taille_drivers_rim	Ainsi que la place totale maximale occup‚e

 move.l taille_drivers_rim,d0	On essaye de r‚server un bloc de la taille n‚c‚ssaire
 lea adresse_drivers_rim,a0	pour pouvoir stocker les RIM de fa‡on confortable...
 bsr.l r‚serve_bloc
 bmi erreur_rim_m‚moire

;
; On charge les RIM maintenant !
;
 move #0,-(sp)			Fichier normal
 pea chemin_drivers_rim
 move #$4e,-(sp)		> FSFIRST
 trap #1
 addq #8,sp
 tst d0
 bne erreur_rim_chargement

.continue_chargement
 lea chemin_drivers_rim,a6	Recherche le d‚but du nom du fichier
.cherche_fin_chemin
 cmp.b #'*',(a6)+
 bne.s .cherche_fin_chemin
 subq #1,a6
 move.l a6,adresse_nom_rim
 
 move.l adresse_drivers_rim,a5	Adresse du buffer de chargement des RIM
 move nombre_drivers_rim,d7	Nombre de fichiers … charger...
 subq #1,d7	
.boucle_chargement_rim
 move.l my_dta+26,d6		M‚morise la taille du RIM en cours de chargement.
 move.l d6,d5			Pour le chargement -->

 lea my_dta+30,a0		Recopie le nom … la fin du chemin d'accŠs
 move.l (a0)+,(a6)
 move.l (a0)+,4(a6)
 move.l (a0)+,8(a6)
 
 move #1,-(sp)			Ouvre en lecture
 pea chemin_drivers_rim		Nom du fichier
 move #$3d,-(sp)		> FOPEN
 trap #1
 addq #8,sp
 tst d0
 bmi erreur_rim_chargement
 move d0,handle

 pea buffer_entete_rim		Adresse de chargement
 pea 56.w			56 octets … charger
 move handle,-(sp)
 move #$3f,-(sp)		> FREAD
 trap #1
 lea 12(sp),sp
 tst.l d0
 bmi erreur_rim_chargement

 move handle,-(sp)		On ferme le fichier
 move #$3e,-(sp)		> FCLOSE
 trap #1
 addq #4,sp
 tst d0
 bmi erreur_rim_chargement

 lea buffer_entete_rim,a0
 cmp.l #'READ',rim_type_driver(a0)	RIM de chargement image ???
 bne .ignore_rim
 cmp.l #'_IMG',rim_type_driver+4(a0)
 bne .ignore_rim
 cmp.l #'_VDI',rim_format_driver(a0)	Uniquement au format VDI
 bne .ignore_rim
 tst rim_type_chargement(a0)		0=Total / 1=Partiel
 bne .ignore_rim

 lea rim_type_fichier(a0),a1		Recopie la d‚signation du driver
 rept 8
 move.l (a1)+,(a5)+			(32 octets)
 endr
 move rim_num_version(a0),(a5)+		Ainsi que le num‚ro de version
 move.l d6,(a5)+			Taille du fichier driver  
 move.l (a6),(a5)+			Ainsi que son nom
 move.l 4(a6),(a5)+
 move.l 8(a6),(a5)+
 bra.s .rim_suivant  

.ignore_rim
 subq #1,nombre_drivers_rim

.rim_suivant  
 move #$4f,-(sp)		> FSNEXT	Pr‚pare le chargement du prochain
 trap #1			fichier RIM.
 addq #2,sp
 tst d0
 dbne d7,.boucle_chargement_rim

 st flag_drivers_rim
 
; lea adresse_nombre_rim,a0
; move nombre_drivers_rim,d0	Nombre de drivers
; ext.l d0
; jsr inscrit_chaine
; move.b #'',(a0)
; boite_alerte #1,#alert_nombre_rim
    
 moveq #0,d0
 rts



erreur_rim_absent
 boite_alerte #1,#alert_rim_absent
 moveq #-1,d0
 rts

erreur_rim_m‚moire
 boite_alerte #1,#alert_rim_m‚moire
 moveq #-1,d0
 rts

erreur_rim_chargement
 boite_alerte #1,#alert_rim_chargement	On pr‚vient l'utilisateur que ca merde...
 lea adresse_drivers_rim,a0		et on libŠre la m‚moire r‚serv‚e.
 jsr libŠre_bloc
 moveq #-1,d0
 rts

 section BSS

;adr_MFBD%  Adresse  de  la structure MFDB que  la  routine  devra 
;remplir si elle reconnait le format du fichier qu'on lui propose.
;
;     La structure MFDB est une liste de quelques octets d‚crivant 
;l'image.  Cette structure est utilis‚e dans les op‚rations GEM de 
;copie  d'image  et son remplissage doit ˆtre fait  avec  le  plus 
;grand  soin.  Notre routine devra donc remplir  cette  structure, 
;afin de communiquer au PRG appelant le maximum d'informations sur 
;l'image  telle qu'elle sera une fois lue.  Voici par  exemple  la 
;structure  MFDB qui devra ˆtre renvoy‚e par une routine  traitant 
;des images au format N‚ochrome:
;     DC.L      4       ; seek palette   
;     DC.W      320     ; largeur de l'image en pixels
;     DC.W      200     ; hauteur de l'image en pixels
;     DC.W      20      ; largeur d'un plan en mot
;     DC.W      0       ; les donn‚es sont au format standard
;     DC.W      4       ; nombre de plans
;     DC.L      32      ; nbr d'octets de la palette     
;     DC.W      0       ; r‚serv‚
;             
;Normalement,  la MFDB ne doit pas donner le "seek" pour atteindre 
;la palette,  ni la taille des donn‚es de celle-ci. Normalement le 
;premier  long  mot devrait contenir l'adresse  de  l'image,  mais 
;comme  c'est au PRG Appelant de r‚server un bloc m‚moire et  donc 
;de  connaitre cette adresse,  nous en profitons pour  communiquer 
;des informations. La connaissance du saut n‚cessaire pour pointer 
;dans le fichier sur les donn‚es de la palette,  permettra au  PRG 
;appelant  de  faire un SEEK sur ce fichier,  et donc  de  ne  pas 
;charger de donn‚es inutiles.  S'il n'y a pas de palette,  il faut 
;mettre 0 pour le seek et la taille puisque le code de retour sera 
;3 au lieu de 2.

table_mfdb
mfdb_adresse_buffer
mfdb_seek		ds.l 1	seek palette 
mfdb_largeur_image	ds.w 1	largeur de l'image en pixels
mfdb_hauteur_image	ds.w 1	hauteur de l'image en pixels
mfdb_largeur_plan	ds.w 1	largeur d'un plan en mot
mfdb_type_format	ds.w 1	les donn‚es sont au format standard
mfdb_nombre_plans	ds.w 1	nombre de plans
mfdb_taille_palette	ds.l 1	nbr d'octets de la palette 
mfdb_r‚serv‚		ds.w 1	r‚serv‚
			ds.l 500	Par s‚curit‚ pour l'instant

flag_drivers_rim	ds.w 1	Indique si les RIM sont disponibles

adresse_nom_rim		ds.l 1
 
nombre_drivers_rim	ds.w 1	Nombre de drivers en m‚moire
nombre_drivers		ds.w 1

taille_drivers_rim	ds.l 1	Taille totale occup‚e par le buffer les contenant
adresse_drivers_rim	ds.l 1	Descripteur du bloc contenant les entetes de drivers RIM
adresse_rim		ds.l 1	Descripteur du bloc du RIM courant.

buffer_entete_rim	ds.b 56	Pour charger le d‚but du RIM

position_s‚lection_rim	ds.w 1
num‚ro_rim_courant	ds.w 1
num‚ro_driver_courant	ds.w 1

  