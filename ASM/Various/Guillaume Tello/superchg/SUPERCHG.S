; ***************************************
; Exemple d'utilisation de la TOOL BOX
; de Supercharger
; 1997, Guillaume Tello gtello@wanadoo.fr
; ***************************************

; Assembl‚ avec ASSEMBLE (Brainstorm)

	text
	
	; initialise le TOS et l'AES

	move.l 4(sp),a0
	move.l $18(a0),a1
	add.l $1c(a0),a1
	add.l #$200,a1
	move.l a1,sp
	sub.l a0,a1
	move.l a1,-(sp)
	move.l a0,-(sp)
	clr.w -(sp)
	move #$4a,-(sp)
	trap #1						; r‚duit la m‚moire utilis‚e
	add.w #12,sp
	
	move.l #appl_init,d1		; bonjour … l'AES
	move #$c8,d0
	trap #2					
	
	clr mf_int					; souris en flŠche
	move.l #graf_mouse,d1
	move #$c8,d0
	trap #2
	
	move #256,mf_int			; puis souris d‚sactiv‚e
	move.l #graf_mouse,d1
	move #$c8,d0
	trap #2
	
DMA equ 3					; constante 3 pour le num‚ro de p‚riph‚rique

	move.l #'\*.*',chemin
	bsr charge_tool_box	; charge la TOOL_BOX en zone BSS
	
	sf inst_ok
	bsr installe			; installe les routines sur le TRAP #4
	st inst_ok
	
	bsr boot					; passe en mode 'Esclave'
	
	lea p_c,a4				; zone ou charger
	lea pc_fich,a3			; nom du fichier
	move.l #200,d3			; taille maxi
	bsr lire_fichier		; charge le programme PC (PC_PROG.BIN)
	move.l d0,pc_taille	; taille r‚elle renvoy‚e
	
	lea p_c,a0
	move.l pc_taille,d2
	move.l #$03000000,d3
	bsr ecrire_donnees	; envoit PC_PROG c“t‚ PC … l'adresse 0300:0000
	
	move.l #$03000000,d3
	bsr exec_prog			; puis l'ex‚cute (toujours adresse 0300:0000)
	
boucle_principale:
	pea message1
	move #9,-(sp)			; message de chargement
	trap #1
	addq.l #6,sp
	
	bsr file_select		; sl‚ectionne le fichier texte d'entr‚e
	beq fin					; renvoit 0 si 'ANNULER' ou si file=""
			
	lea texte,a4				; zone o— charger
	lea file,a3					; nom du fichier
	move.l #32000,d3			; taille maxi
	bsr lire_fichier			; charge le texte en RAM
	move.l d0,txt_taille		; et garde sa taille

									; envoie sa taille sur deux octets	
	move.b txt_taille+2,d2	; 1 octet a envoyer
	bsr envoie_octet
	
	move.b txt_taille+3,d2	; 2 octet … envoyer
	bsr envoie_octet
	
	lea texte,a0
	move.l txt_taille,d2    ; puis envoie tout le fichier c“t‚ PC
	bsr envoie_donnees
	
				; pendant que Supercharger s'occupe de Majuscules
				; on peut s‚lectionner le fichier de sortie
	
	pea message2				; message de sauvegarde
	move #9,-(sp)
	trap #1
	addq.l #6,sp

	bsr file_select			; s‚lectionne le fichier de sortie
	seq ne_pas_sauver			; … $FF pour annuler
	
	lea texte,a0
	move.l txt_taille,d2		; maintenant, r‚cupŠre le texte transform‚
	bsr recoit_donnees		; une fois que PC_PROG s'en est occup‚
	
	tst.b ne_pas_sauver
	bne boucle_principale	; pas de sauvegarde, boucler!

	lea texte,a4				; zone … sauver
	lea file,a3					; nom du fichier
	move.l txt_taille,d3		; taille du fichier
	bsr sauve_fichier			; sauve le nouveau texte en Majuscules!
	bra boucle_principale	; sauvegarde, puis boucle

fin:	
	move.b #0,d2				; envoit $0001 sur 2 octets pour un
	bsr envoie_octet			; RESET de Supercharger
	move.b #1,d2
	bsr envoie_octet
	
	bsr desinstalle			; puis d‚sinstalle la TOOL_BOX

sortie:	
	move #257,mf_int			; r‚activer souris
	move.l #graf_mouse,d1
	move #$c8,d0
	trap #2
	
	move.l #appl_exit,d1		; aurevoir … l'AES
	move #$c8,d0
	trap #2
	
	clr -(sp)					; puis au TOS
	trap #1

; ************************************
; routines de communication
; ************************************

; pour la programmation en assembleur, on peut se passer du remplissage
; de la zone en tool_box+2 et utiliser directement les registres du 68000
; ainsi que l'appel au trap #4. C'est plus rapide. Il faut alors avoir en
; tˆte les correspondances suivantes:
; ID      = D0.w, numero de fonction
; DMA     = D1.w, numero de p‚riph‚rique
; TAILLE  = D2.L, taille a transmettre, ou octet … envoyer
; PC_ADR  = D3.L, adresse c“t‚ PC
; TOS_ADR = A0.L, adresse c“t‚ Atari
; RETOUR  = D0.L, valeur retourn‚e
; OCTET   = D2.b, octet renvoy‚

; seules Installe et Desinstalle sont appel‚es par la m‚thode classique
; puisque pour ces deux fonctions, on ne peut pas compter
; sur le Trap #4!!!

installe:
	lea tool_box,a0
	move #-1,2(a0)		; ID fonction
	jsr (a0)				; ex‚cution
	lea tool_box,a0
	move.l 18(a0),d0	; valeur retourn‚e
	bra verif
	
desinstalle:
	lea tool_box,a0
	move #-2,2(a0)
	jsr (a0)
	move.l 18(a0),d0
	bra verif
	
boot:
	moveq #DMA,d1
	moveq #3,d0
	trap #4
	bra verif
	
envoie_donnees:
	moveq #DMA,d1
	moveq #4,d0
	trap #4
	bra verif
	
recoit_donnees:
	moveq #DMA,d1
	moveq #5,d0
	trap #4
	bra verif
	
envoie_octet:
	moveq #DMA,d1
	moveq #9,d0
	trap #4
	bra verif
	
recoit_octet:
	moveq #DMA,d1
	moveq #10,d0
	trap #4
	bra verif
	
ecrire_donnees:
	moveq #DMA,d1
	moveq #6,d0
	trap #4
	bra verif
	
lire_donnees:
	moveq #DMA,d1
	moveq #7,d0
	trap #4
	bra verif
	
exec_prog:
	moveq #DMA,d1
	moveq #8,d0
	trap #4
	bra verif

; routine g‚rant les codes d'erreur
; ENTREE: D0.l, 0 (ok) ou code d'erreur (-1 … -11)
	
verif:
	tst.l d0				; teste le code
	bne.s .erreur		; non nul? c'est une erreur
	rts					; sinon, on continue
.erreur:
	lea err1,a0
	cmp #-1,d0			; erreur -1?
	beq .aff	
	lea err2,a0
	cmp #-2,d0			; erreur -2?
	beq .aff
	lea err3,a0
	cmp #-3,d0			; erreur -1?
	beq .aff	
	lea err4,a0
	cmp #-4,d0			; erreur -2?
	beq .aff
	lea err5,a0
	cmp #-5,d0			; erreur -1?
	beq .aff	
	lea err6,a0
	cmp #-6,d0			; erreur -2?
	beq .aff
	lea err7,a0
	cmp #-7,d0			; erreur -1?
	beq .aff	
	lea err8,a0
	cmp #-8,d0			; erreur -2?
	beq .aff
	lea err9,a0
	cmp #-9,d0			; erreur -1?
	beq .aff	
	lea err10,a0
.aff:
	move.l a0,ab_addrin	; adresse chaine pour alerte
	move #257,mf_int		; r‚activer souris
	move.l #graf_mouse,d1
	move #$c8,d0
	trap #2
	move.l #alert_box,d1	; boite d'alerte
	move #$c8,d0
	trap #2
	move #256,mf_int		; d‚sactiver souris
	move.l #graf_mouse,d1
	move #$c8,d0
	trap #2
	tst.b inst_ok
	beq.s .fin
	bsr desinstalle
.fin:
	bra sortie	

charge_tool_box:
	move.l #18000,d3			; taille maxi pour la tool_box
	lea tool_box,a4			; adresse o— charger
	lea tb_fich,a3				; nom du fichier
	bsr lire_fichier
	rts
	
file_select:
	move #257,mf_int		; r‚activer souris
	move.l #graf_mouse,d1
	move #$c8,d0
	trap #2
	move.l #fileselect,d1 ; s‚lecteur
	move #$c8,d0
	trap #2
	move.l intout,d7		; garde la valeur en retour
	move #256,mf_int		; d‚sactiver souris
	move.l #graf_mouse,d1
	move #$c8,d0
	trap #2
	tst d7
	beq.s .annule			; si 0, bouton annuler
	swap d7
	beq.s .annule			; si 0, erreur d‚tect‚e
	tst.b file				; premier octet du fichier
.annule:
	rts						; renvoit Z=0 (Ok) ou Z=1 (annuler)

; A3: chaine du fichier
; A4: zone … sauver
; D3: nombre d'octets

sauve_fichier:
	bsr chemin_plus_fichier

	clr -(sp)
	pea (a1)
	move #$3C,-(sp)		; FCREATE, cr‚e le fichier
	trap #1
	addq.l #8,sp	

	move d0,d7
	bpl.s .ok
	moveq #-11,d0
	bra verif				; erreur -11: fichier non ouvrable
	
.ok:
	pea (a4)
	move.l d3,-(sp)
	move d7,-(sp)
	move #$40,-(sp)		; FWRITE avec un maxi de D3 octets
	trap #1
	add.w #12,sp
	
	move d7,-(sp)
	move #$3E,-(sp)		; FCLOSE, referme le fichier ‚crit
	trap #1
	addq.l #4,sp

	rts		

; A3: chaine du fichier
; A4: adresse ou charger
; D3: taille maxi

lire_fichier:
	bsr chemin_plus_fichier
	
	clr -(sp)
	pea (a1)
	move #$3d,-(sp)		; FOPEN, ouvre le fichier
	trap #1
	addq.l #8,sp	

	move d0,d7
	bpl.s .ok
	moveq #-11,d0
	bra verif				; erreur -11: fichier non ouvrable
	
.ok:
	pea (a4)
	move.l d3,-(sp)
	move d7,-(sp)
	move #$3f,-(sp)		; FREAD avec un maxi de D3 octets
	trap #1
	add.w #12,sp
	
	move.l d0,-(sp)		; sauve la taille lue
	
	move d7,-(sp)
	move #$3E,-(sp)		; FCLOSE, referme le fichier lu
	trap #1
	addq.l #4,sp
	
	move.l (sp)+,d0		; renvoit la longueur
	rts

; exemple: chemin="D:\TEXTES\*.TXT"
;      et: file = "ESSAI.TXT"
; alors A1 pointera sur : "D:\TEXTES\ESSAI.TXT"
	
chemin_plus_fichier:
	lea chemin,a0
	lea path,a1
	move.l a1,a2
lb1:
	move.b (a0)+,d0
	beq.s .copie_nom
	move.b d0,(a1)+
	cmp.b #'\',d0
	bne.s lb1
	move.l a1,a2
	bra.s lb1
.copie_nom:
	move.b (a3)+,(a2)+
	bne.s .copie_nom
	lea path,a1
.oter_slash:
	cmp.b #'\',(a1)+
	beq.s .oter_slash	
	subq.l #1,a1
	rts
	
	data

	; donn‚es pour fonctions AES utilis‚es
	
appl_init: dc.l ai_cont,global,dum,appl_id,dum,dum
ai_cont: dc.w 10,0,1,0,0
appl_id: dc.w 0
	
graf_mouse: dc.l mf_cont,global,mf_int,intout,mouse_def,dum
mf_cont: dc.w 78,1,1,1,0
mf_int: dc.w 0
mouse_def: dc.l 0
	
appl_exit: dc.l ae_cont,global,dum,intout,dum,dum
ae_cont: dc.w 19,0,1,0,0

alert_box: dc.l ab_cont,global,ab_int,intout,ab_addrin,dum
ab_cont: dc.w 52,1,1,1,0
ab_int: dc.w 1
ab_addrin: dc.l 0

fileselect: dc.l fs_cont,global,dum,intout,fs_addrin,dum
fs_cont: dc.w 90,0,2,2,0
fs_addrin: dc.l chemin,file

message1: dc.b 27,"EChoisir un fichier texte",0
message2: dc.b 27,"ESauver le fichier transform‚",0	
err1: dc.b "[1][ToolBOX non charg‚e ][ Fin! ]",0
err2: dc.b "[1][ Erreur -2 | (R‚serv‚e...)][ Fin! ]",0
err3: dc.b "[1][ Supercharger non branch‚ ][ Fin! ]",0
err4: dc.b "[1][ Time out: pas de r‚ponse ][ Fin! ]",0
err5: dc.b "[1][ Erreur de protocole ][ Fin! ]",0
err6: dc.b "[1][ Hot Key ABIO reconnue ][ Fin! ]",0
err7: dc.b "[1][ Erreur -7 | (R‚serv‚e...) ][ Fin! ]",0
err8: dc.b "[1][ Appel de fonction ill‚gal ][ Fin! ]",0
err9: dc.b "[1][ ToolBOX d‚j… install‚e ][ Fin! ]",0
err10: dc.b "[1][ Le trap #4 est d‚j… | en service ][ Fin! ]",0
err11: dc.b "[1][ Erreur fichier, | ouverture impossible ][ Fin! ]",0

pc_fich: dc.b "PC_PROG.BIN",0		; nom du programme PC
tb_fich: dc.b "TOOL_BOX.BIN",0	; nom de la TOOL_BOX
	even
	
	bss
global: ds.l 10			; pour AES
dum: ds.l 10				; pour AES
intout ds.l 10				; pour AES
path: ds.b 214				; chemin+file
chemin: ds.b 200			; pour FILESELECT
file: ds.b 14				; nom du fichier texte dans FILESELECT
pc_taille: ds.l 1			; taille du programme PC
txt_taille: ds.l 1		; taille du fichier texte
inst_ok: ds.b 1			; $FF si 'installe' r‚ussi
ne_pas_sauver: ds.b 1	; $FF si 'Annuler' sauvegarde
tool_box: ds.b 18000		; zone pour charger la TOOL BOX
p_c: ds.b 200				; zone pour le programme PC
texte: ds.b 32000			; zone pour le fichier texte

	END