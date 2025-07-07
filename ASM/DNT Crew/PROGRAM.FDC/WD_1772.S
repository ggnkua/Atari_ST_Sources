	SECTION	TEXT
	include	hard_sys.s
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
Crc_error	set	$08	;Diff‚rentes erreurs possibles
Rnf_error	set	$10	;
Wrt_error	set	$40	;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
__stat	set	0	;Num‚ro des diff‚rents registres
__comm	set	0	;
__trak	set	1	;
__sect	set	2	;
__data	set	3	;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
__MO	set	$08	;Motor ON Test (0/1=On/Off)
__V	set	$04	;Verify (SEEK/RESTORE) (0/1=Off/On)
__2ms	set	$02	;Step rates.
__3ms	set	$03	;
__5ms	set	$00	;
__6ms	set	$01	;
__u	set	$10	;Update (Step) (0/1=Off/On)
__m	set	$10	;Multiple Sector (Read/Write Sector)
__a0	set	$01	;Data Adress Mark (0/1=normale/effac‚e)
__E	set	$04	;30ms Setting Delay (0/1=On/Off)
__P	set	$02	;Write Precompensation

__restore	set	$00|__V|__3ms	;On peut enlever le __V
__seek	set	$10|__V|__3ms	;sans problŠmes, ‡a peut
__step	set	$20|__V|__u|__3ms	;acc‚l‚rer un peu les
__stepin	set	$40|__V|__u|__3ms	;choses, mais c'est (un peu)
__stepout	set	$60|__V|__u|__3ms	;moins s–r.

__readse	set	$80
__readsem	set	__readse|__m
__writse	set	$a0
__writsem	set	__writse|__m

__readad	set	$c0
__readtr	set	$e0
__writtr	set	$f0
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;Chargement complet d'un ensemble de secteurs.
;La routine se charge de tout. Lorsqu'elle rend la main, le chargement
;est lanc‚. Il faut tester End_Flag pour savoir si le chargement est
;fini. Alors appeler la fonction Unset_drive pour ‚teindre la lampe
;du drive (attention, dans sa version actuelle, Unset_drive ne rend la
;main que quand la lampe est ‚teinte. Y'a qu'… la mettre en VBL en la
;modifiant un peu).
;En D0, le 1er secteur … charger, en D1 le dernier secteur.
;En A0, l'adresse de chargement
;Ce sont des secteurs logiques (entre 0 et 799 pour du simple face
;80 pistes 10 sect/face, par exemple).Les secteurs sont d'abord sur
;la face 0 puis sur la face 1 (donc 799=secteur 10 piste 80 face 0
;et 800=secteur 1 piste 0 face 1) pour g‚rer sans modifications des
;disks simple face ou … faces s‚par‚es.
;Il faut auparavant avoir rempli les donn‚es suivantes:
Drive	dc.w	0	;drive 0 ou 1
Sect_Side	dc.w	10	;nombre de secteurs par piste
Nb_Tracks	dc.w	80	;et de piste par faces
Error	dc.w	0	;erreur d‚tect‚e (0=ok)
__IntErr	dc.w	0	;erreur autoris‚e (util. interne)
End_Flag	dc.w	0	;0 si transfert fini.
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight Nullos//DNT-Crew 1992-1993÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
Load_Block	movem.l	d0-a6,-(sp)	;
	tst.w	End_Flag		;pas de transfert en cours ?
	bne.s	*-6		;si, attendre
	move.l	a0,d0		;fixe l'adresse DMA de d‚part
	bsr	Set_dma		;
	move.l	(sp),d0		;
	lea	Wd_Com_Buf-16,a1	;buffer de commande
	move.l	a1,Wd_Com_Pnt	;incr‚ment‚ d'abord=>-16 compense
	lea	16(a1),a1		;
	move.w	Nb_Tracks(pc),d2	;
	mulu	Sect_Side(pc),d2	;
	cmp.l	d2,d0		;Le 1er secteur est sur quelle
	sge.b	d2		;face ?
	neg.b	d2		;range en D2 le n0 de face
	ext.w	d2		;
	move.w	d2,-(sp)		;conserve pour le seek final
	divu	Sect_Side(pc),d0	;=>d0=start_sect-1|track
	divu	Sect_Side(pc),d1	;=>d1=end_sect-1|track
	cmp.w	d0,d1		;sur la mˆme piste ?
	bne.s	LB_multi		;non

LB_mono	tst.w	d2		;Quelle face ?
	beq.s	*+6		;face 0,ok
	sub.w	Nb_Tracks(pc),d0	;non, corrige start_track
	move.w	Drive(pc),(a1)+	;->Drive|Track
	move.w	d0,(a1)+		;
	move.l	d2,(a1)+		;->?????|Side
	clr.l	(a1)+		;paramŠtre dummy
	move.l	#Seek_track,(a1)+	;->Seek
;Explication: on r‚cupŠre les commmandes par un movem.l (a0)+,d0-d2/a0
;donc il faut regarder la routine que l'on veut appeler (ici Seek_track)
;et que l'on passe en dernier (->r‚cup‚r‚e en A0 pour un jsr (a0)).
;On y trouvera la liste des paramŠtres demand‚s dans D0-D2 (ici,
;D0=Drive|Track et D1=????|Side) que l'on met dans le buffer, dans
;l'ordre D0-D2.

	move.w	Drive(pc),(a1)+	;->drive|side
	move.w	d2,(a1)+		;
	swap	d0		;d0=track|start_sector-1
	swap	d1		;d1=track|end_sector-1
	sub.w	d0,d1		;d1=track|nb_sector
	addq.w	#1,d0		;
	move.l	d0,(a1)+		;->track|start_sector
	addq.w	#1,d1		;
	move.l	d1,(a1)+		;->Nombre de secteurs
	move.l	#Read_sector_root,(a1)+ ;->Read_sector
	bra.s	LB_final		;lance le FDC

;rappel: D0=start_sect-1.w|start_track.w
;        D1= end_sect-1.w |end_track.w
LB_multi	sub.w	d0,d1		;Ecart end_track-start_track
	subq.w	#1,d1		;-1 pour le dbf qui va suivre
	tst.w	d2		;Quelle face ?
	beq.s	*+6		;face 0,ok
	sub.w	Nb_Tracks(pc),d0	;non, corrige start_track
	move.w	Drive(pc),(a1)+	;->Drive|start_track
	move.w	d0,(a1)+		;
	move.l	d2,(a1)+		;->?????|side
	clr.l	(a1)+		;paramŠtre dummy
	move.l	#Seek_track,(a1)+	;->Seek

	move.w	Drive(pc),(a1)+	;drive|side
	move.w	d2,(a1)+		;
	swap	d0		;d0=start_track|start_sector-1
	addq.w	#1,d0		;
	move.l	d0,(a1)+		;->start_track|start_sector
	sub.w	Sect_Side(pc),d0	;nb … lire sur start_track
	neg.w	d0		;
	addq.w	#1,d0		;
	move.l	d0,(a1)+		;->Nombre de secteurs
	move.l	#Read_sector_root,(a1)+;->Read_sector
	swap	d0		;d0=current_track=start_track


LB_mbcl	addq.w	#1,d0		;une piste plus loin !
	cmp.w	Nb_Tracks(pc),d0	;Change de face ?
	blt.s	*+6		;non !
	addq.w	#1,d2		;si..
	clr.w	d0		;donc piste 0, face chang‚e
	move.w	Drive(pc),(a1)+	;mˆme drive
	move.w	d0,(a1)+		;nouvelle piste
	move.l	d2,(a1)+		;et nouvelle face
	clr.l	(a1)+		;
	move.l	#Seek_track,(a1)+	;->Seek_track
;Nb: on peut aussi se servir d'un step au lieu d'un seek.
;A vous de faire la routine step out n‚cessaire (elle est
;tout ce qu'y a de plus simple) et de changer cet appel.
	
	move.w	Drive(pc),(a1)+	;
	move.w	d2,(a1)+		;drive.w|side.w
	move.w	d0,(a1)+		;
	move.w	#1,(a1)+		;track.w|start_sector=1.w
	move.w	Sect_Side(pc),d3	;toute la piste
	tst.w	d1		;on est sur end_track ?
	bne.s	.LB_mnext		;non
	move.l	d1,d3		;si, alors ne charge que
	swap	d3		;jusqu'… end_sect.w
	addq.w	#1,d3		;(D0.h contient end_sect-1)
.LB_mnext	move.l	d3,(a1)+		;hop!
	move.l	#Read_sector_root,(a1)+;->Read sector
	dbf	d1,LB_mbcl		;piste suivante

LB_final	clr.l	(a1)+		;
	clr.l	(a1)+		;
	clr.l	(a1)+		;
	move.l	#BreakOut,(a1)+	;fin du transfert.
	lea	MFP_base.w,a0	;pr‚pare l'IT du DMA
	move.l	#IT_FDC,V_DMA.w	;son vecteur
	ori.b	#$80,IERB(a0)	;on l'autorise 
	ori.b	#$80,IMRB(a0)	;et on la d‚masque
	clr.w	Error		;pas d'erreur apparue
	clr.w	__IntErr		;ou tol‚rable.

	move.w	#$80,__write_mode	;mode lecture
	move.l	Drive(pc),d0	;On lance un Restore_track
	clr.w	d0		;Drive.w|Track=79.w
	move.w	(sp)+,d1		;side
	bsr	Seek_track		;quand il est fini, la chaine
	st.b	End_Flag		;des commandes se poursuit..
	movem.l	(sp)+,d0-a6	;\Indique que le DMA travaille
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;;;;;;;;;;;;;;;;; Routine de traitement de la chaŒne de commande ;;;;;;;;;;
_FDC_IPL	set	$2400		;niveau d'ipl restitu‚
IT_FDC	move.w	#_FDC_IPL,sr	;autorise les autres ITs
	movem.l	d0-2/a0,-(sp)	;
.IFDC_stat	moveq	#0,d0		;status de la commande
	bsr	Wd_read		;pr‚c‚dente...
	andi.w	#$18,d0		;CRC,RNF ?
	beq.s	.IFDC_ok		;non,ca roule
	move.w	__IntErr(pc),d1	;
	clr.w	__IntErr		;plus d'erreur autoris‚e
	cmp.w	d0,d1		;celle-l… l'‚tait ?
	beq.s	.IFDC_ok		;oui (Rnf en multi-secteur)
	move.w	d0,Error		;non, coupe chargement
	bsr.s	BreakOut		;
	movem.l	(sp)+,d0-2/a0	;
	andi.b	#%01111111,ISRB+MFP_base.w;<-cf plus bas
	rte			;
.IFDC_ok	move.l	Wd_Com_Pnt(pc),a0	;pointeur actuel
	lea	16(a0),a0		;commande suivante
IFDC_entry	move.l	a0,Wd_Com_Pnt	;point d'entr‚e
	movem.l	(a0),d0-2/a0	;r‚cupŠre celle en cours
	jsr	(a0)		;go!
	movem.l	(sp)+,d0-2/a0	;
	andi.b	#%01111111,ISRB+MFP_base.w;<-Peut ˆtre enlev‚e si
	rte			;le MFP est en mode AEI (VR=$40)
;;;;;;;;;;;;;;;;; La chaine de commandes est finie ;;;;;;;;;;;;;;;;;;;;;;;;
BreakOut	clr.w	End_Flag		;Simple,non ?
	rts			;
;;;;;;;;;;;;;;; Flag lecture/‚criture et pointeur de commande ;;;;;;;;;;;;;
__write_mode	dc.w	$80	;$80=lecture $180=ecriture
Wd_Com_Pnt	dc.l	0		;pointeur de commandes
;;;;;;;;;;;;;;;;;;;;;;;;; Mise en lecture de la pile DMA ;;;;;;;;;;;;;;;;;;
Dma_in	move.w	#$90,dma_ctrl.w	;passe le DMA en lecture
	move.w	#$190,dma_ctrl.w	;‚criture
	move.w	#$90,dma_ctrl.w	;lecture =>pile vid‚e
	move.w	#64,dma_data.w	;maxi 64*512 octets transf‚r‚s
	rts	;(mais on fait moins en fait: on met suffisament
		;pour que le DMA aille au bout dans tous les cas)
;;;;;;;;;;;;;;;;;;;;;;; Mise en ecriture de la pile DMA ;;;;;;;;;;;;;;;;;;;
Dma_out	move.w	#$190,dma_ctrl.w	;idem, mais dans l'autre sens
	move.w	#$90,dma_ctrl.w	;
	move.w	#$190,dma_ctrl.w	;
	move.w	#64,dma_data.w	;
	rts			;
;;;;;;;;;;;;;;;;;;;;;;; Fixe l'adresse des transferts DMA ;;;;;;;;;;;;;;;;;
;en D0, l'adresse … fixer		;
Set_dma	move.l	d0,-(sp)		;il faut fixer l'adresse
	move.b	d0,dma_low.w	;… rebours sinon problŠmes
	lsr.w	#8,d0		;
	move.b	d0,dma_mid.w	;
	swap	d0		;
	move.b	d0,dma_high.w	;
	move.l	(sp)+,d0		;
	rts			;
;;;;;;;;;;;;;;;;;;; Lit l'adresse actuelle des transferts DMA ;;;;;;;;;;;;;
;Renvoie l'adresse en D0		;
Get_dma	moveq	#0,d0		;rien … signaler
	move.b	dma_high.w,d0	;
	swap	d0		;
	move.b	dma_mid.w,d0	;
	lsl.w	#8,d0		;
	move.b	dma_low.w,d0	;
	rts			;
;;;;;;;;;;;;;;;;;;;;;; Lit un registre du WD1772 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;en D0, le num‚ro du registre, renvoie en D0 sa valeur
Wd_read	add.w	d0,d0		;*2 pour rentrer le No dans les
	add.w	__write_mode(pc),d0	;bits 2-1 + mask d'‚criture
	move.w	d0,dma_ctrl.w	;demande
	move.w	dma_data.w,d0	;et recoit
	andi.w	#$ff,d0		;formate
	rts			;
;;;;;;;;;;;;;;;;;;;; Ecrit un registre du WD1772 ;;;;;;;;;;;;;;;;;;;;;;;;;;
;En D0 le num‚ro de registre, et en D1 la valeur … attribuer
;D0 n'est pas sauvegard‚.		;
Wd_write	add.w	d0,d0		;idem formattage de demande
	add.w	__write_mode(pc),d0	;du registre
	move.w	d0,dma_ctrl.w	;
	andi.w	#$ff,d1		;masque pour parasites
	move.w	d1,dma_data.w	;envoie le tout
	rts			;
;;;;;;;;;;;;;;;;;;;; Selectionne un lecteur et une face ;;;;;;;;;;;;;;;;;;;
;D0=drive.w|side.w			;
Set_drive	move.w	d1,-(sp)		;
	move.l	d0,-(sp)		;
	move.w	sr,-(sp)		;sauve le sr
	move.w	d0,d1		;calcul marrant,car on a:
	swap	d0		;bit2=drive B
	andi.w	#1,d0		;bit1=drive A
	addq.w	#1,d0		;bit0=Face 0/1
	add.w	d0,d0		;le tout invers‚ (eor)
	andi.w	#1,d1		;
	or.w	d1,d0		;
	eori.w	#%00000111,d0	;
	move.w	#$2700,sr		;pour acc‚der au yamaha
	move.b	#14,yam_ctrl.w	;faut bloquer les gˆneurs
	move.b	yam_read.w,d1	;dans le registre multi-usage
	andi.b	#$f8,d1		;annule les 0-2
	or.b	d0,d1		;puis les selectionne
	move.b	d1,yam_write.w	;
	move.w	(sp)+,sr		;Remet l'IPL originel.
	move.l	(sp)+,d0		;
	move.w	(sp)+,d1		;
	rts			;
;;;;;;;;;;;;;;;;;;;;;;; Deselectionne les lecteurs ;;;;;;;;;;;;;;;;;;;;;;;;
Unset_drive			;
	move.w	d0,-(sp)		;
.unsdbcl	clr.w	d0		;Lire le SR du drive
	bsr.s	Wd_read		;
	tst.b	d0		;bit 7=motor on
	bmi.s	.unsdbcl		;actif ?
	move.b	#14,yam_ctrl.w	:non, alors on peut
	move.b	yam_read.w,d0	;enlever les drives
	ori.b	#7,d0		;en mettant tout … z‚ro
	move.b	d0,yam_write.w	;hop-la
	move.w	(sp)+,d0		;
	rts
;;;;;;;;;;;;;;;;; Transmet l'‚tat du drive (aprŠs une commande) ;;;;;;;;;;;
;En D0 sort l'‚tat aprŠs la commande (0=ok ou bien Crc_error ou Rnf_error)
;On a Z=1 si tout est ok.
;Cette routine n'est utile que si vous voulez tester vous-mˆme
;simplement le registre d'‚tat.
;WdGetState moveq	#__stat,d0		;status
;	bsr	Wd_read		;
;	andi.w	#$18,d0		;CRC,RNF
;	rts			;
;;;;;;;;;;;;;;;; Attente manuelle de la fin d'une commande ;;;;;;;;;;;;;;;;
;Cette routine n'est utile que si vous vous servez des autres
;routines en dehors des interruptions (ce qui est possible, je
;le signale).
;Wait_done	movem.l	d0/d1,-(sp)	;Inutilis‚ ici
;	move.l	_hz_200.w,d0	;
;.wdbcl	btst	#5,GPIP+MFP_base.w	;test si commande finie
;	beq.s	.wdend		;
;	move.l	_hz_200.w,d1	;ou si le d‚lai de 2
;	sub.l	d0,d1		;seconde est ‚coul‚
;	cmpi.l	#400,d1		;
;	ble.s	.wdbcl		;
;.wdend	movem.l	(sp)+,d0/d1	;
;	rts			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; D‚placement de la tˆte de lecture et choix de la face ;;;;;;;;;;;;
;D0=drive.w|track.w			;
;D1=?????.w|side.w			;
;D2 est modifi‚			;
;ATTENTION: LES FONCTIONS DE LECTURE ET D'ECRITURE SECTEUR DOIVENT ETRE
;PRECEDEE D'UN Seek_track POUR SELECTIONNER LA FACE VOULUE.
Seek_track	move.w	d0,d2		;
	move.w	d1,d0		;
	bsr.s	Set_drive		;Commence par choisir le
	move.w	d2,d1		;drive & face
	bne.s	.seeksuite		;
	moveq	#__trak,d0		;Si piste z‚ro, alors on
	moveq	#255,d1		;fait un restore.
	bsr.s	Wd_write		;Track register … 255 au d‚but
	moveq	#__restore,d1	;pour ‚viter les problŠmes.
	bra.s	.seekfin		;
.seeksuite	moveq	#__data,d0		;Ecrire le No de piste voulue
	bsr	Wd_write		;dans le Data Register
	moveq	#__seek,d1		;
.seekfin	moveq	#__comm,d0		;Hop, lance la commande.
	bsr	Wd_write		;
	rts			;
;;;;;;;;;;;;;; Lecture de la piste courante (placer d'abord la tˆte ;;;;;;;
;;;;;;;;;;;;;; comme il faut,SVP)                           ;;;;;;;;;;;;;;;
;D0=adresse buffer m‚moire		;
;D1=drive.w|side.w			;
Read_track				;
	tst.l	d0		;
	ble.s	.rtsuite		;Si nouvelle adresse, alors
	bsr	Set_dma		;on la donne DMA.
.rtsuite	move.l	d1,d0		;
	bsr	Set_drive		;Choisi le drive,
	bsr	Dma_in		;DMA en lecture (logique!)
	moveq	#__comm,d0		;
	moveq	#__readtr,d1	;Et hop.
	bsr	Wd_write		;
	rts			;
;;;;;;;;;;;;;; Ecriture de la piste courante (Rq: idem -^) ;;;;;;;;;;;;;;;;
;D0=adresse buffer m‚moire		;
;D1=drive.w|side.w			;
Write_track			;R.A.S.
	tst.l	d0		;
	ble.s	.wtsuite		;
	bsr	Set_dma		;
.wtsuite	move.l	d1,d0		;
	bsr	Set_drive		;
	bsr	Dma_out		;
	moveq	#__comm,d0		;
	moveq	#__writtr,d1	;
	bsr	Wd_write		;
	rts			;
;;;;;;;;;;;; Racine de lecture des secteurs, pour d‚multiplier ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; les commandes de lecture ;;;;;;;;;;;;;;;;;;;;;;;;;;
;D0=drive.w|side.w			;
;D1=track.w|start_sector.w		;
;D2=nb_sect.w			;
;Si nb_sect.w<0 alors lecture en secteurs multiples (et sortie RNF)
;sinon nb_sect lectures de secteurs simples sont g‚n‚r‚es
Read_sector_root			;
	movem.l	d0-2,.Rsr_d0	;sauve les paramŠtres
	neg.w	d2		;lecture multiple ?
	bgt.s	.rsmulti		;oui, directement
	movea.l	Wd_Com_Pnt(pc),a0	;pointeur actuel
	move.l	#.Rsr_entry,12(a0)	;remplace la commande
	bra.s	.Rsr_1		;Hop, on y va.

.Rsr_d0	dc.l	0
.Rsr_d1	dc.l	0
.Rsr_d2	dc.l	0

.Rsr_entry	movem.l	.Rsr_d0(pc),d0-1	;reprendre les paramŠtres
	addq.w	#1,d1		;start_sector suivant
	move.w	d1,.Rsr_d1+2	;
.Rsr_1	subq.w	#1,.Rsr_d2+2	;un secteur en moins
	ble.s	.Rsr_2		;Si ce n'est pas le dernier,
	subi.l	#16,Wd_Com_Pnt	;remet pointeur sur nous
.Rsr_2	moveq	#1,d2		;Un secteur … la fois...
;;;;;;;;;;;;;; Lire un/les secteur(s) de la piste courante ;;;;;;;;;;;;;;;;
;D0=drive.w|side.w			;
;D1=track.w|start_sector.w		;
;D2=nb_sect.w			;
Read_sector equ	*		;<-Transparent pour labels locaux
	subq.w	#1,d2		;
	ble.s	.rsunseul		;Combien de secteurs ?
.rsmulti	move.w	d1,-(sp)		;
	add.w	d2,d1		;Plusieurs, alors passe
	moveq	#__data,d0		;ce nombre au FDC dans
	bsr	Wd_write		;le Data Register.
	move.w	(sp)+,d1		;Quand on est en multiple,
	moveq	#__readsem,d2	;le FDC s'arrˆte sur un Rnf
	move.w	#Rnf_error,__IntErr	;donc Rnf autoris‚.
	bra.s	.rsfin		;
.rsunseul	moveq	#__readse,d2	;
.rsfin	bsr	Dma_in		;Logique, non?
	moveq	#__sect,d0		;
	bsr	Wd_write		;Envoie le No de secteur
	moveq	#__trak,d0		;
	swap	d1		;
	bsr	Wd_write		;puis de piste.
	moveq	#__comm,d0		;
	move.w	d2,d1		;Et hop, roulez jeunesse.
	bsr	Wd_write		;
	rts			;
;;;;;;;;;;;;;; Ecrit un/les secteur(s) de la piste courante ;;;;;;;;;;;;;;;
;D0=drive.w|side.w			;
;D1=track.w|start_sector.w		;
;D2=nb_sect.w			;
Write_sector equ	*		;
	subq.w	#1,d2		;R.A.S.
	ble.s	.wsunseul		;
.wsmulti	move.w	d1,-(sp)		;
	add.w	d2,d1		;
	moveq	#__data,d0		;
	bsr	Wd_write		;
	move.w	(sp)+,d1		;
	moveq	#__writsem,d2	;
	move.w	#Rnf_error,__IntErr	;
	bra.s	.wsfin		;
.wsunseul	moveq	#__writse,d2	;
.wsfin	bsr	Dma_out		;
	moveq	#__sect,d0		;
	bsr	Wd_write		;
	moveq	#__trak,d0		;
	swap	d1		;
	bsr	Wd_write		;
	moveq	#__comm,d0		;
	move.w	d2,d1		;
	bsr	Wd_write		;
	rts			;

	SECTION	BSS
Wd_Com_Buf	ds.b	(16*2)*(80*2)	;Buffer de commandes
;Il est ici dimensionn‚ au maximum possible. Vous pouvez le r‚duire
;si vous ne comptez pas charger toute une disquette d'un coup.
;Sa taille sera alors le nombre maximal de pistes acc‚d‚es en un
;seul chargement, multipli‚ par 16*2.