;
;           Source du MGG Loader, int‚gr‚ dans MEGAMIR.
;
; Ce programme est install‚ dans le boot sector dans le cas o— le
; chargement d'un fichier est demand‚. Tout autre boot programme
; ne peut alors prendre place dans le boot sector.
; Le fichier … charger et … ‚x‚cuter ne doit comporter aucun
; header et doit etre totalement relogeable. Le lancement se fait
; bien sur … partir du debut du fichier.
; -------------------------------------------------------------------
; Et maintenant un exemple simple:
; Sur la disquette de MEGAMIR... vous avez le fichier "MEGAMIR.BIN" qui
; ne sert … rien si ce n'est … vous montrer les possibilit‚s du 
; MGG Loader... Pour cela, formatez un disk et copiez "MEGAMIR.BIN" dessus.
; Lancez MEGAMIR.PRG, mettez votre disk (o— vous avez fait la copie)
; dans le drive et choisissez l'option "MODIFIER le boot en loader"
; Maintenant faites un reset: et vous voyez le logo de notre fabuleux
; groupe apparaitre avant de revenir sur le desktop...
;
; Notes: ce programme ne tient pas compte de 'FATbuf'.
; Pour revenir au DeskTop, terminez votre programme par RTS.
; Si vous voulez revenir au DeskTop, faites attention aux
; corrections que vous apportez … la pile...
; Les accessoires, DESKTOP.INF et un ‚ventuel dossier AUTO seront
; alors g‚r‚s normalement.
; Si vous d‚sirez charger un fichier, il doit se trouver dans le
; r‚pertoire principal...

param:
       dc.w    0                 ; block de paramŠtres
       dc.w    0
       dc.w    0
       dc.w    0
       dc.l    0
       dc.l    0
       ds.b    11
       dc.b    255

execflg=0
ldmode=2
ssect=4
sectcnt=6
ldaddr=8
fatbuf=12
fname=16
res=27
       movem.l d0-d7/a0-a6,-(sp) ; sauvegarde registres

       pea     set_param(pc)     ; installation cmd_load et r‚cup‚ration
       move.w  #38,-(sp)         ; du drive en $446
       trap    #14
       addq.l  #6,sp

       lea     param(pc),a6      ; type de chargement … ‚ffectuer
       tst.w   ldmode(a6)
       beq     load_file

load_sect:                       ; chargement de secteurs logiques
       lea     param(pc),a6
       moveq   #0,d6
       move.b  res(a6),d6
       move.w  d6,-(sp)          ; boot drive
       move.w  ssect(a6),-(sp)   ; secteur d‚but
       move.w  sectcnt(a6),-(sp) ; sector-count
       move.l  ldaddr(a6),-(sp)  ; load-address
       clr.w   -(sp)             ; lecture avec media change
       move.w  #4,-(sp)
       trap    #13
       adda.l  #14,sp
       bra     load_end          ; erreur ‚ventuelle...
load_file:                       ; chargement d'un fichier
       lea     param(pc),a6
       clr.w   -(sp)             ; ouverture en lecture
       pea     fname(a6)         ; nom...
       move.w  #$3d,-(sp)
       trap    #1
       addq.l  #8,sp
       tst.w   d0                ; erreur... ou handle
       bmi     load_end
       move.w  d0,d7             ; d7=handle
       move.l  ldaddr(a6),-(sp)  ; adresse
       move.l  #99999990,-(sp)   ; on charge tout
       move.w  d7,-(sp)
       move.w  #$3f,-(sp)
       trap    #1
       adda.l  #12,sp
       tst.w   d0                ; erreur?
       bmi     load_end
       move.w  d7,-(sp)          ; fermeture...
       move.w  #$3e,-(sp)
       trap    #1
       addq.l  #4,sp

load_end:
       tst.w   d0
       bmi     error             ; msg erreur et retour au desktop

       moveq   #0,d0             ; mise … 0 des registres de donn‚es
       moveq   #0,d1
       moveq   #0,d2
       moveq   #0,d3
       moveq   #0,d4
       moveq   #0,d5
       moveq   #0,d6
       moveq   #0,d7

       lea     param(pc),a6      ; mise en place de l'adresse de saut
       lea     jump(pc),a0
       move.l  ldaddr(a6),(a0)

       dc.w    $4EB9             ; code JSR
jump:  dc.l    0

byebye:                          ; on remet les registres
       movem.l (sp)+,d0-d7/a0-a6
       rts

error:                           ; en cas d'erreur (fichier absent,...)
       pea     message(pc)       ; message
       move.w  #9,-(sp)          ; affichage
       trap    #1
       addq.l  #6,sp
       move.w  #1,-(sp)          ; wait key
       trap    #1
       addq.l  #2,sp
       bra     byebye            ; retour au DeskTop

set_param:
       lea     param(pc),a6      ; mise en place et test des paramŠtres
       move.w  execflg(a6),$482  ; COMMAND.PRG
       move.b  $446,res(a6)      ; res=current drive...
       rts
message:
       dc.b    13,10," ** MGG Loader 1.05 Error **",13,10,13,10
       dc.b          "     Check your disk !!",13,10,13,10
       dc.b          "   Please press a key ...",13,10,13,10,0

end

*****************************************************************

;
; Maintenant,voici un exemple de relocateur de fichier...
;	
	
	lea	debut(pc),a0	 ; a0=debut header
	lea	$1C(a0),a1	 ; a1=debut segment prg
	lea	(a1),a2
	adda.l	2(a0),a2
	adda.l	6(a0),a2	 ; a2=debut tab de reloc
	move.l	a1,d1
	move.l	(a2)+,d0
f0:	cmpi.b	#1,d0
	bne.s	f1
	adda.l	#254,a1
	move.b	(a2)+,d0
	bra.s	f0
f1:
	adda.l	d0,a1
	move.l	(a1),a0
	adda.l	d1,a0
	move.l	a0,(a1)
	move.b	(a2)+,d0
	bne.s	f0
	
debut:
 incbin "PROG.PRG"
 	
	
