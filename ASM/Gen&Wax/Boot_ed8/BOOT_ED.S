MOD_BOX=0
MOD_BOX2=1
MOD_HEXA=0
MOD_DECI=1
MOD_WIND=1
MOD_MENU=1
MOD_ACC=0

NR_WINDOWS_MAX=1

	output \assemble\sources.guw\boot_edi.2\boot_ed8.prg

	include guw_mac3.s

	; GENUWAX Boot Editor for GEM
	; 6-03-1994 / 12-03 / 13-03 / 23-03 / 26/03
	
	
debut:	init_prg 64,#name_rsc

	bsr show_menu

	lea window1,a0
	bsr create_page
	tst d7
	bmi errare
	move d7,index1

	move index1,d0
	bsr open_window

	get_drive
	set_drive d0
	move d0,drive_actif	; quels drives sont dispo ?

	clr drive
	clr.l ad_buffer
	clr.l ad_loading

begin:	move.w #510,offset_check	; par d‚faut
	bsr load_new_boot

menu:	bsr calcule_si_exec	; savoir meme si on n'actualise pas le disque
	lea texte,a0
	move index1,d0
	bsr write_in_window

boucle_gem_principale:
	clr d0
	bset #EVNT_KEYBD,d0
	bset #EVNT_MESAG,d0
	bsr traite_evenement_gem

	btst #EVNT_KEYBD,d0
	bne.s keyboard
	btst #EVNT_MESAG,d0
	bne.s message
	bra.s boucle_gem_principale

fin:	lea messfin,a0
	move index1,d0
	bsr write_in_window
	move #55,d7
.wait_a_sec:syncro
*	dbf d7,.wait_a_sec

	bsr rends_memoire

errare:	restore_prg

message_inconnu:
	neg.w d1
	cmp.w #AP_TERM,d1
	beq fin
	bra.s boucle_gem_principale

keyboard:	lea conversion,a0
	bsr convert_key_in_event
	tst d7
	bne boucle_gem_principale

message:	tst d1
	bmi message_inconnu

	cmp.w #ACTIONS_QUIT,d1
	beq fin

	cmp.w #ACTIONS_KILL,d1
	bne.s .pas1
	bsr tuer
	bra menu
.pas1:
	cmp.w #ACTIONS_VALIDATE,d1
	bne.s .pas2
	bsr valide		; valide cheksum
	bra menu
.pas2:
	cmp.w #ACTIONS_LOAD,d1
	bne.s .pas3
	bra begin
.pas3:
	cmp.w #ACTIONS_UPDATE,d1
	bne.s .pas4
	bsr ecrit
	bra boucle_gem_principale
.pas4:
	cmp.w #SPECIAL_RANDOM,d1
	bne.s .pas5
	bsr serie
	bra menu
.pas5:
	cmp.w #ACTIONS_WORKINGD,d1
	bne.s .pas6
	bsr chg_lecteur
	tst d7
	beq begin
	bra boucle_gem_principale
.pas6:
	cmp.w #SPECIAL_DUMP,d1
	bne.s .pas7
	bsr dump
	bra boucle_gem_principale
.pas7:
	cmp.w #ACTIONS_TESTVIR,d1
	bne.s .pas8
	bsr test_vir
	bra boucle_gem_principale
.pas8:
	cmp.w #DATA_ARCHIVE,d1
	bne.s .pas9
	bsr archiver
	bra boucle_gem_principale
.pas9:
	cmp.w #DATA_INTEGRATEBS,d1
	bne.s .pas10
	bsr intergrate_bs
	bra menu
.pas10:
	cmp.w #INTEGRATE_IBM,d1
	bne.s .pas11
	lea avirus8,a0
	bsr intergrate_from_mem
	bra menu
.pas11:
	cmp.w #INTEGRATE_UNIX,d1
	bne.s .pas12
	lea avirus11,a0
	bsr intergrate_from_mem
	bra menu
.pas12:
	cmp.w #INTEGRATE_WAX,d1
	bne.s .pas13
	lea avirus10,a0
	bsr intergrate_from_mem
	bra menu
.pas13:
	cmp.w #INTEGRATE_JEREMY,d1
	bne.s .pas14
	lea avirus12,a0
	bsr intergrate_from_mem
	bra menu
.pas14:
	cmp.w #INTEGRATE_PLASMA,d1
	bne.s .pas17
	lea avirus13,a0
	bsr intergrate_from_mem
	bra menu
.pas17:
	cmp.w #DATA_INTEGRATEGW,d1
	bne.s .pas15
	bsr maxiboot
	bra menu
.pas15:
	cmp.w #INFO_MENU,d1
	bne.s .pas16
	move #INFORMATIONS,d0
	bsr traite_formulaire
	bra boucle_gem_principale
.pas16:
	cmp.w #SPECIAL_DEFINE_O,d1
	bne.s .pas18
	bsr ask_check
	bra boucle_gem_principale
.pas18:

	bra boucle_gem_principale
;-----------------------------------------------------------
load_new_boot:
	move drive,d0
	cmp.w #2,d0
	bge.s .hard_disk
	lea alert,a0
	bsr alert_box
.hard_disk:	bsr litinfo
	rts
;----------------------------------------------------------------
ask_check:	move #ASK_CHECKSUM_OFF,d0
	bsr traite_formulaire

	move.w #ASK_CHECKSUM_OFF,d0
	lea add_tree,a0
	bsr get_addr_tree
	move.l add_tree,a0		; a0
	move.w #CHECKSUM_OFFSET,d0
	bsr get_text_add		; a1

	clr.l d1
.calc:	move.b (a1)+,d0
	beq.s .fin
	sub #'0',d0
	mulu #10,d1
	add.w d0,d1
	bra.s .calc
.fin:	btst #0,d1		; adresse impaire ?
	bne.s ask_check
	tst.w d1
	beq.s ask_check

	move.w d1,offset_check
	rts
***************** Lit le boot-sector d'un disque ****************

litinfo:
*	move.w #1,-(sp)	; nombre
*	clr.w -(sp)		; face
*	clr.w -(sp)		; piste
*	move.w #1,-(sp)	; secteur
*	move drive,-(sp)	; lecteur A
*	clr.l -(sp)		; inutilis‚
*	pea buffer(pc)
*	appel xbios,8,20	; lit le boot

	bsr rends_memoire

	move.w drive,-(sp)
	appel bios,7,4	; Getbpb
	tst.l d0
	beq .errlec	

	move.l d0,a0
	move.w (a0),d0
	ext.l d0
	move.l d0,taille_secteur
	malloc d0
	tst.l d0
	ble.s .finlit
	move.l d0,ad_buffer

	move drive,-(sp)	; device
	move #0,-(sp)	; No 1er secteur
	move #1,-(sp)	; 1 secteur
	move.l ad_buffer,-(sp)
	move.w #2,-(sp)	; lire & ignorer
	appel bios,4,14

	tst d0
	beq.s .finlit

.errlec	lea errorl,a0	; erreur de lecture ?
	bsr alert_box
	bra litinfo
.finlit:	rts

rends_memoire:
	move.l ad_buffer,d0
	beq.s .no
	mfree d0
.no:	rts
***************** Lit le boot-sector d'un disque ****************
calcule_si_exec:
	move.l ad_buffer,a0
	move #$1234,d0	; somme = $1234 ?
	move #512/2-1,d1
.exec:	sub (a0)+,d0
	dbf d1,.exec
	lea exe(pc),a0
	move.b #'N',(a0)	; pour l'afficher … l'utilisateur
	move.b #'O',1(a0)
	move.b #' ',2(a0)
	clr executable
	tst d0		; exec oui ou non ?
	bne.s .non_execu
	move #1,executable
	move.b #'Y',(a0)
	move.b #'E',1(a0)
	move.b #'S',2(a0)
.non_execu:	rts
************** Rend cheksum inex‚cutable **********************

tuer:	move.l ad_buffer,a6
	move.w offset_check,d0
	clr.w (a6,d0.w)
*	bsr.s ecrit
	rts
************** ‚crit le boot secteur d'un disque ************

ecrit:
*	move.w #1,-(sp)	; nombre
*	clr.w -(sp)		; face
*	clr.w -(sp)		; piste
*	move.w #1,-(sp)	; secteur
*	move drive,-(sp)	; lecteur A
*	clr.l -(sp)		; inutilis‚
*	pea buffer(pc)
*	appel xbios,9,20	; ecrit secteur

	move drive,-(sp)	; device
	move #0,-(sp)	; No 1er secteur
	move #1,-(sp)	; 1 secteur
	move.l ad_buffer,-(sp)
	move.w #3,-(sp)	; ‚crire & ignorer
	appel bios,4,14

	tst d0
	beq.s .ecr_ok	; erreur ecriture ?

	lea errore,a0
	bsr alert_box
.ecr_ok:	rts
************** Rend le cheksum executable [et ‚crit secteur] *****

valide:	move offset_check,d0
	move.l ad_buffer,a0
	clr.w (a0,d0.w)
	move.w #512/2-1,d1
	move #$1234,d2
.check:	sub.w (a0)+,d2
	dbf d1,.check

	move.l ad_buffer,a0
	move.w d2,(a0,d0.w)

*	move.w #1,-(sp)	; executable
*	move.w #-1,-(sp)	; type disque (80*9)
*	move.l #-1,-(sp)	; nø S‚rie
*	move.l ad_buffer,-(sp)
*	appel xbios,18,14	; cr‚e un boot-secteur ex‚cutable
*	bsr.s ecrit		; et l'‚crit sur le disque
	rts
*************** Met un num‚ro de s‚rie al‚atoire *****************

serie:	appel xbios,17,2
	move.l ad_buffer,a0
	add.l #8,a0		; position du num‚ro de s‚rie
	move.w d0,(a0)
	swap d0
	move.b d0,2(a0)
	rts		; ne rien ‚crire
*********** Change de lecteur ***************

chg_lecteur:lea texte_fsl,a0
	bsr copy_in2_select
	bsr fileselect
	moveq #-1,d7
	tst d4
	beq.s .annule

	get_drive
	move drive_actif,d1
	btst d0,d1
	bne.s .pas_de_pb
*	lea drive_non,a0
*	bsr alert_box
*	rts
.pas_de_pb:	move d0,drive
	add.b #'A',d0
	move.b d0,lecteur	; pour afficher
	clr d7
.annule	rts
************** Effectue un dump du boot **************

dump:	move.l taille_secteur,d0
	lea info_dump11,a1
	bsr deci2

	lea info_dump1,a0
	move.w index1,d0
	bsr write_in_buffer

	lea lf_rc,a0
	move.w index1,d0
	bsr write_in_buffer

	move.l ad_buffer,a0
	move.l taille_secteur,d7
	divu #256,d7
	subq #1,d7

.redox:	save a0/d7
	lea info_dump2,a0	; en deux pages
	move.w index1,d0
	bsr write_in_buffer
	load a0/d7

	save d7
	bsr.s half_16	; les 16 en deux fois 8
	load d7
	dbf d7,.redox

	move.w index1,d0
	bsr write_buffer_in_window	; actualise la fenˆtre
	rts

half_16:	moveq #16-1,d7	; 16 lignes de 16
seize_l:	moveq #2-1,d6	; 2 parties
two_p:	move.l (a0),d0
	move #32,d1
	bsr hex
	move.l 4(a0),d0
	move #32,d1
	bsr hex

	save a0
	lea temp_txt,a0
	move.w #'-'*256,(a0)
	move.w index1,d0
	bsr write_in_buffer
	load a0

	add #8,a0
	dbf d6,two_p

	move.l a0,a1	; puis les caractŠres asc II
	sub #16,a1
	moveq #16-1,d6
caracts:	clr.w d0
	move.b (a1),d0
	cmp.b #32,d0	; les 32 d'un coup
	bge.s ok_aff
	move.b #'.',d0	; pas si < #32
ok_aff:	save a0-a1
	lea temp_txt,a0
	move.b d0,(a0)
	clr.b 1(a0)
	move.w index1,d0
	bsr write_in_buffer
	load a0-a1
	addq #1,a1
	dbf d6,caracts

	save a0
	lea lf_rc,a0
	move.w index1,d0
	bsr write_in_buffer
	load a0

	dbf d7,seize_l
	rts
********* Sous-routine d'affichage en hexad‚cimal

hex:	sub #4,d1		; sous routine d'affichage hexa d'1 registre
	move.l d0,d2	; d1=nb bits
	lsr.l d1,d2		; d0=donn‚e
	and.w #$f,d2
	cmp #$a,d2
	bge.s lettr
	add.b #'0',d2
	bra.s fin_lettr
lettr:	add.b #'A'-$a,d2
fin_lettr:	save d0-d2/a0
	lea temp_txt,a0
	move.b d2,(a0)
	clr.b 1(a0)
	move.w index1,d0
	bsr write_in_buffer
	load d0-d2/a0
	tst d1
	bgt.s hex
	rts

************** V‚rifie si un virus est pr‚sent sur le disque *********

test_vir:	bsr litinfo

	tst executable
	bne.s exec_oui

	lea no_virus2,a0	; si pas executable
	move.w index1,d0
	bsr write_in_window
	rts

exec_oui:	lea table_boots(pc),a6

tester_tous:
	move.l ad_buffer,a0
	move.l (a6)+,d0	; table d'adresses virus
	bmi fini_tester
	move.l d0,a1

cont:	move (a0),d0	; header boot actuel
	move (a1),d1	; header virus
	cmp.w d0,d1
	bne pas_vir
	move d0,d2
	and #$ff00,d2
	cmp #$6000,d2	; est-ce un bra.s ?
	beq.s ist_bra
	addq.l #2,a0	: mot par mot
	addq.l #2,a1
	move.l ad_buffer,d7
	add.l #2+6+4,d7
	cmp.l a0,d7
	blt.s cont
	bra.s pas_vir	; si aucun bra dans 12 1ers octets
ist_bra:	and.l #$ff,d0	; ex. : $60.1c 
	add.l #2,d0		; d0 pointe debut virus : $1c + 2
	add.l d0,a0
	add.l d0,a1
	move #200-1,d7	; on verifie 200 octets
compare:	cmp.b (a0)+,(a1)+
	bne.s pas_vir
	dbf d7,compare

	tst (a6)
	bne.s pas_1		; c'est un virus connu

	save d0/a0
	lea virus,a0
	move.w index1,d0	; previent le spectateur
	bsr write_in_window
	load d0/a0
	bra.s label1

pas_1:	*cmp #2,(a6)	; pas 1 virus !
	*bne.s label1

	save d0/a0		; 1=antivirus, 2=rien
	lea antivirus,a0
	move.w index1,d0	; c'est un anti-virus connu
	bsr write_in_window
	load d0/a0
	bra.s label1
label1:
	save d0/a0
	lea 2(a6),a0	; c'est un boot connu
	move.w index1,d0
	bsr write_in_window
	load d0/a0
	rts

pas_vir:	add #2+22,a6
	bra tester_tous

fini_tester:		; TEST PREMIER
	move #1,attention	; ruse
	move.l ad_buffer,a0
	move #512/2-1-1,d0
reset_proof1:
	cmp.l #$31415926,(a0)	; on teste certains mots ...
	beq.s attention1
	addq #2,a0
	dbf d0,reset_proof1
	sub #1,attention
attention1:

	add #2,attention
	move.l ad_buffer,a0
	move #512/2-1-1,d0
reset_proof2:
	cmp.l #$12123456,(a0)	; on teste certains mots ...
	beq.s attention2
	addq #2,a0
	dbf d0,reset_proof2
	sub #2,attention
attention2:

	save d0/a0
	lea test1,a0
	move.w index1,d0
	bsr write_in_window
	load d0/a0
pas1:	cmp #1,attention	; $31415926
	bne.s pas2

	save d0/a0
	lea vir_reset,a0
	move.w index1,d0
	bsr write_in_window
	load d0/a0
	bra.s finito
pas2:	cmp #2,attention	; $12345678
	bne.s pas3
	save d0/a0
	lea vir_magic,a0
	move.w index1,d0
	bsr write_in_window
	load d0/a0
	bra.s finito
pas3:	cmp #3,attention	; les deux chiffres … la fois
	bne.s pas4
	save d0/a0
	lea vir_booth,a0
	move.w index1,d0
	bsr write_in_window
	load d0/a0
	bra.s finito
pas4:	save d0/a0
	lea no_virus,a0
	move.w index1,d0
	bsr write_in_window
	load d0/a0

finito:	
	save d0/a0
	lea test2,a0	; TEST SECOND
	move.w index1,d0
	bsr write_in_window
	load d0/a0

	move #1,attention	; ruse
	move.l ad_buffer,a0
	move #512/2-1-1,d0
write_on_disk:
	cmp.l #$00094e4e,(a0)	; on teste certains mots ...
	beq.s attention3
	cmp.l #$00284e4e,(a0)	; qui correspondent … ‚criture du disque
	beq.s attention3
	cmp.l #$00044e4d,(a0)
	beq.s attention3
	addq #2,a0
	dbf d0,write_on_disk
	sub #1,attention
attention3:
	cmp #1,attention
	bne.s label2
	save d0/a0
	lea virus_2,a0	; test positif
	move.w index1,d0
	bsr write_in_window
	load d0/a0
	bra.s finito2
label2:	save d0/a0
	lea no_virus2,a0	; rien du tout : est-il crypt‚ ??
	move.w index1,d0
	bsr write_in_window
	load d0/a0

finito2:	rts

*********** Sauvegarde d'un boot en fichier ************

archiver:	
	move.l #'*.BS',whato
	tst.l sltr_adress
	beq.s .no_trix
	move.l #',*.A',whato+4
	move.w #'V'*256,whato+8		; *.BS,*.AV 0
	bra.s .zap
.no_trix:	clr.b whato+4
.zap:
	lea texte_fsl2,a0		; 35 chars max.
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq.s tout_ok

	file_open write,params_it
	tst d0
	bmi.s tss_tss	; erreur
	move.l d0,d7

	file_write ad_buffer,taille_secteur,d7
	move d0,d6
	file_close d7
	cmp.l taille_secteur,d6
	beq.s tout_ok	; plus de place

tss_tss:	lea pb_ecr_fich,a0
	bsr alert_box
tout_ok:	rts
************* Integrer un fichier quelconque (meme PRG) **********
intergrate_bs:
pasimpaire:	
	move #ASK_OFFSET,d0
	bsr traite_formulaire

	move.w #ASK_OFFSET,d0
	lea add_tree,a0
	bsr get_addr_tree
	move.l add_tree,a0		; a0
	move.w #ASK_OFFSET_NUM,d0
	bsr get_text_add		; a1

	move.l #$6000,d6
	clr.l d4		; calcul de l'offset avec caractŠres
	clr.l d5
	tst 1(a1)
	bne.s .ok
	move.b (a1),d5
	bra.s .p
.ok:	move.b (a1),d4	; dizaine
	move.b 1(a1),d5	; unite
	sub.b #48,d4	; cod‚s en asc II
.p:	sub.b #48,d5
	mulu #10,d4		; * 10 pour dizaines
	add.l d4,d6
	add.l d5,d6
	btst #0,d6		; adresse impaire ?
	bne.s pasimpaire
	cmp.b #$1c+2,d6	; = 60.1c (minimum)
	bge.s .enc		; pas de PB
	save d0-a6
	lea alerteff,a0	; risque d'effacement des octets vitaux
	bsr alert_box	; mais laisser (remplacer tout le boot)
	load d0-a6

.enc:	move.l #'*.BS',whato
	tst.l sltr_adress
	beq.s .no_trix
	move.l #',*.A',whato+4
	move.w #'V'*256,whato+8		; *.BS,*.AV 0
	bra.s .zap
.no_trix:	clr.b whato+4
.zap:
	save d0-a6
	lea texte_fsl3,a0		; 35 chars max.
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq .fin

	malloc taille_secteur
	tst.l d0
	ble .fin
	move.l d0,ad_loading
	load d0-a6

	lea params_it,a4	; nom
	move.l ad_buffer,a5
	sub.w #2,d6		; -2
	move.w d6,(a5)	; bra pc + (1e) = $20 - 2
	add.l d4,a5		; offset de $20
	add.l d5,a5		; nom : a4 , adr. : a5
	move.l a5,a6
	move.l ad_loading,a5	; d‚tourne chargement

			; a4=nom , a5=adresse
	save d1-a6		; sauve les registres
	file_open read,(a4)
	load d1-a6
	tst d0		; test validit‚
	bpl.s ouvert_ok	; le fichier est ouvert correctement ?

	save d0-a6
	lea errorf,a0	; si d0 <0
	bsr alert_box
	mfree ad_loading
.fin:	load d0-a6
	rts

ouvert_ok:	move.w d0,d7	; d7 = handle
	save d1-a6
	file_read a5,#512+50,d7
	file_close d7
	load d1-a6		; charge les registres

	cmp #$6000,d6	; (d‚ja enlev‚ 2) $60.00 est impossible
	ble.s tout_le_boot	; si offset = 0 mais 60.xx en tete
	cmp.b #$60,(a5)	; pour comparer si header PRG ou BS
	bne.s jump
	moveq #2,d0
	add.b 1(a5),d0
	add.l d0,a5
	save d0-a6
	lea warning_zap,a0	: previent du saut du header
	bsr alert_box
	load d0-a6
tout_le_boot:
jump:	move #512-1,d0
.copy:	move.b (a5)+,(a6)+
	dbf d0,.copy
	mfree ad_loading
	rts

*********** Mettre une intro ***************
intergrate_from_mem:
	move.l ad_buffer,a1
	move.l (a0),(a1)
	move.l 4(a0),4(a1)
	move.w 8(a0),8(a1)
	add #$1e,a0
	add #$1e,a1
	move #512-$1e-1,d0
put_intr:	move.b (a0)+,(a1)+
	dbf d0,put_intr

	rts

*************** IntŠgre le boot : Genuwax *********************

maxiboot:	lea genuwax+295(pc),a1	; pointe le message dans le boot	
	move #40-1,d7	
copy1:	move.b #32,(a1)+	; met des espaces dans le boot
	dbf d7,copy1

	move.w #INTEGRATE_GUW,d0
	lea add_tree,a0
	bsr get_addr_tree
	move.l add_tree,a0		; a0
	move.w #INTEGRATE_GUW_TX,d0
	bsr get_text_add		; a1

	lea but_mess,a0
	move #40-1,d0
.cp:	move.b (a0)+,(a1)+
	dbf d0,.cp

	move #INTEGRATE_GUW,d0
	bsr traite_formulaire

	move.l add_tree,a0		; a0
	move.w #INTEGRATE_GUW_TX,d0
	bsr get_text_add		; a1
	
	move.l a1,a0
.z0:	tst.b (a1)+
	bne.s .z0
	sub.l a0,a1
	subq.l #1,a1
	move a1,d6

*	lea titre+2(pc),a0	; debut du texte entr‚
*	clr.l d6
*	move.b -1(a0),d6	; d6 = longueur du texte

	move #40,d7		; pour le centrage du texte
	sub.b d6,d7
	lsr.w #1,d7

	tst.b d6		; si longueur du texte entr‚ = 0
	bne.s text_ok
	lea but_mess(pc),a0
	move #40,d6		; recopier 40 caracteres
	clr.l d7		; pas de decalage
	
text_ok:	lea genuwax+295(pc),a1	; pointe le message dans le boot
	add.l d7,a1
	sub.w #1,d6
copy2:	move.b (a0)+,(a1)+	; recopier le message dans le boot
	dbf d6,copy2

	bsr litinfo		; lit nouveau boot
	move.l ad_buffer,a0
	lea genuwax(pc),a1
	add.l #$1c,a1	; car header de prg
	move.w #$601e,(a0)	; offset : $20
	add.l #$20,a0
	move #478-1,d0	; long prg … int‚grer 478 MAXI
recopie:	move.b (a1)+,(a0)+
	dbf d0,recopie
	bsr serie		; en profite pour mettre num‚ro s‚rie
	bsr valide		; rend exec & ‚crit
	bsr ecrit
	rts

	include d:\assemble\sources.guw\boot_edi.2\guw_boot.hs

	section DATA
conversion:	dc.w 'V'-'A'+1,ACTIONS_VALIDATE
	dc.w 'K'-'A'+1,ACTIONS_KILL
	dc.w 'U'-'A'+1,ACTIONS_UPDATE
	dc.w 'L'-'A'+1,ACTIONS_LOAD
	dc.w 'W'-'A'+1,ACTIONS_WORKINGD
	dc.w 'T'-'A'+1,ACTIONS_TESTVIR
	dc.w 'Q'-'A'+1,ACTIONS_QUIT
	dc.w 'I'-'A'+1,DATA_INTEGRATEBS
	dc.w 'A'-'A'+1,DATA_ARCHIVE
	dc.w 'G'-'A'+1,DATA_INTEGRATEGW
	dc.w 'R'-'A'+1,SPECIAL_RANDOM
	dc.w 'D'-'A'+1,SPECIAL_DUMP
	dc.l 0

window1:	dc.w 1
	dc.w %111111111101
	dc.w 70,200		; taille int
	dc.w 70,200		; taille max
	dc.w -1,0
	dc.w 70,20		; taille … l'ouverture
	dc.l title_wind,info_wind

title_wind:	dc.b 'GENUWAX Boot Editor version 8.0',0
info_wind:	dc.b 'Infos : We are the best...',0

name_rsc:	dc.b 'd:\assemble\sources.guw\boot_edi.2\guw_boot.rsc',0

errorl:	dc.b '[3][Read error.|Insert a disk.][OK]',0
errore:	dc.b '[3][Write error.|Check your disk.][OK]',0
alert:	dc.b '[3][Insert disk to|be modified.][OK]',0
*drive_non:	dc.b '[3][Impossible :|this drive is non-actif.][OK]',0
pb_ecr_fich:dc.b '[3][Error while|writting/opening|the file.][OK]',0
alerteff:	dc.b '[3][This offset|shall destroy|BPB datas.][OK]',0
errorf:	dc.b '[3][This file|cannot be|found.][OK]',0
warning_zap:dc.b '[3][Warning :|jumping over|the header|$1A+2 bytes][OK]',0

texte:	dc.b lf,rc,'Boot sector of drive : '
lecteur:	dc.b 'A',lf,rc
	dc.b 'It is executable : '
exe:	dc.b 'YES',lf,rc,0

info_dump1:	dc.b lf,rc,'Dump of the buffer : '
info_dump11:dcb.b 5,' '
	dc.b lf,rc,0
info_dump2:	dc.b lf,rc,'Dump of 256 bytes :'
lf_rc:	dc.b lf,rc,0

virus:	dc.b lf,rc,"It's a VIRUS : ",0
virus_2:	dc.b lf,rc,"It's a VIRUS !",0
antivirus:	dc.b lf,rc,"It's an anti-virus/cool boot : ",0
test1:	dc.b lf,rc,'First analysis ...',0
test2:	dc.b lf,rc,'Second analysis ...',0
no_virus:	dc.b lf,rc,'No known virus on this disk!',0
no_virus2:	dc.b lf,rc,'No virus on this disk!',0
no_virus3:	dc.b lf,rc,'I don''t think it''s a virus.',0
vir_reset:	dc.b lf,rc,'This disk uses reset : Protection,Demo,Virus ?',0
vir_magic:	dc.b lf,rc,'Probability of virus presence : 90 %',0
vir_booth:	dc.b lf,rc,'Probability of virus presence : 99.9 %',0

 even
virus1:	incbin ghost.vir	; tous les incbin doivent faire 512 octets
virus2:	incbin green.vir	; avec le 'bra.s' compris

avirus1:	incbin fuzion3.av
avirus2:	incbin genuwax.av
avirus3:	incbin titanium.av
avirus4:	incbin antighos.av
avirus5:	incbin fcopypro.av
avirus6:	incbin ska_colr.av
avirus7:	incbin cresson.av
avirus8:	incbin msdos.bs
avirus9:	incbin keinviru.av
avirus10:	incbin bootwax.bs
avirus11:	incbin unix.bs
avirus12:	incbin bootfrac.bs
avirus13:	incbin plasma.bs
avirus14:	incbin shdriver.bs

table_boots:dc.l virus1			;  4
	dc.w 0			;+ 2  (0=virus,1=anti,2=rien)
	dc.b 'Ghost Virus          ',0	;+22=28

	dc.l virus2
	dc.w 0
	dc.b 'Green Virus (toubab) ',0

	dc.l avirus1
	dc.w 1
	dc.b 'Fuzion Anti-Virus III',0

	dc.l avirus2
	dc.w 1
	dc.b 'Genuwax Boot-Utils 3 ',0

	dc.l avirus3
	dc.w 1
	dc.b 'Titanium             ',0

	dc.l avirus4
	dc.w 1
	dc.b 'TDT Anti-Ghost 4.0   ',0

	dc.l avirus5
	dc.w 1
	dc.b 'Guardian (Fcopy-PRO) ',0

	dc.l avirus6
	dc.w 1
	dc.b 'SKA color test       ',0

	dc.l avirus7
	dc.w 1
	dc.b 'Anti-Edith Cresson   ',0

	dc.l avirus8
	dc.w 2
	dc.b 'MS-DOS compatib. Boot',0

	dc.l avirus9
	dc.w 1
	dc.b 'Kein Virus im Bootsec',0

	dc.l avirus10
	dc.w 1
	dc.b 'Wax config. Optimizer',0

	dc.l avirus11
	dc.w 2
	dc.b 'IBM RS 6000 UNIX Boot',0

	dc.l avirus12
	dc.w 1
	dc.b 'Moon-cactus Fractal. ',0

	dc.l avirus13
	dc.w 1
	dc.b 'DNT Plasma boot sec. ',0

	dc.l avirus14
	dc.w 1
	dc.b 'SH-DRIVER 6.061      ',0

	dc.l -1

genuwax:	incbin gen_wax7.bs

but_mess:	dc.b " The Boot-intro from Genuwax greats you "
messfin:	dc.b lf,rc,'(c) 1992-94 by Gen & Wax. Bye bye ...',lf,rc,0

texte_fsl:	dc.b 'Choose your drive :',0
texte_fsl2:	dc.b 'Choose name for archive :',0
texte_fsl3:	dc.b 'Choose boot-file to integrate :',0

	section BSS
index1:	ds.w 1

drive:	ds.w 1
drive_actif:ds.w 1
executable:	ds.w 1		; 0=non , 1=oui
attention:	ds.w 1

temp_txt:	ds.w 1


offset_check:ds.w 1
taille_secteur:	ds.l 1
ad_buffer:	ds.l 1
ad_loading:	ds.l 1

*buffer:	ds.b 16384
*.safe:	ds.b 50
*loading:	ds.b 16384
*.safe:	ds.b 50
	END
