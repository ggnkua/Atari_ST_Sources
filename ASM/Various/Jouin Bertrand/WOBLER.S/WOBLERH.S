* affichage de sprite en monochrome
* utilisation des instruction de manipulation de champ de bit
* par Golio Junior pour Falk'mag 7

* D‚finition de l'image
Video_mode		equ %000101100	* 80 col, 200 lig, 65536 cou, TV Pal
Taille_ecran	equ 640*200*2
ecran_largeur	equ 640
ecran_hauteur	equ 200
Pas_Fond		equ 0

* information pour le wobler
pas_1	equ 3
pas_2	equ 5

	include "principa.s"
prg_init
	move.l #table1,adr_tab_p
	move.l #table2,adr_tab_s
	move.w #0,posit_1
	move.w #0,posit_2

	lea table1,a0
	move.w #ecran_hauteur,d0
	move.l #wobler,d1
prg_init_b1
	move.l d1,(a0)+
	dbra d0,prg_init_b1
	rts

prg
	move.l adr_tab_p,pt_table
			* installation de la hbl
	move.w sr,-(sp)
	move.w #$2700,sr		* stoppe toutes les interruptions
				* sauvegarde du MFP
	lea mfp,a0
	move.b $FFFA07,(a0)+
	move.b $FFFA0B,(a0)+
	move.b $FFFA0F,(a0)+
	move.b $FFFA13,(a0)+

	move.b $FFFA09,(a0)+
	move.b $FFFA0D,(a0)+
	move.b $FFFA11,(a0)+
	move.b $FFFA07,(a0)+
				* initialisation du MFP
				* => aucune interruption
	clr.b $FFFA07
	clr.b $FFFA0B
	clr.b $FFFA0F
	clr.b $FFFA13

	clr.b $FFFA09
	clr.b $FFFA0D
	clr.b $FFFA11
	clr.b $FFFA07

	move.l $68,-(sp)
	move.l #hbl_rout,$68
				* attente debut de l'affichage
	move.w $ff82a8,d0
prg_attente_b1
	cmp.w $ff82a0,d0
	bne prg_attente_b1
	
	move.w #$2100,sr		* toutes les interruptions sont autoris‚es

			* calcul de la prochaine table
	movea.l adr_tab_s,a0
	lea data1,a1
	lea data2,a2
	move.w #ecran_hauteur,d0
	move.w posit_1,d1
	move.w posit_2,d2
prg_b1
	move.w (a1,d1.w*2),d3
	move.w (a2,d2.w*2),d4
	subq.b #3,d1
	addq.b #1,d2
	add.w d3,d4
	move.l #wobler,d5
	mulu.w #ecran_largeur*2,d4
	add.l d4,d5
	move.l d5,(a0)+
	dbra d0,prg_b1

	move.w posit_1,d0
	add.w #pas_1,d0
	andi.w #$FF,d0
	move.w d0,posit_1

	move.w posit_2,d0
	add.w #pas_2,d0
	andi.w #$FF,d0
	move.w d0,posit_2

			* attente de la fin de l'affichage
	move.w $ff82aa,d0
prg_attente
	cmp.w $ff82a0,d0
	bhi prg_attente
			* desintallation de la hbl
	move.w #$2700,sr		* stoppe toutes les interruptions
	move.l (sp)+,$68

	lea mfp,a0
	move.b (a0)+,$FFFA07
	move.b (a0)+,$FFFA0B
	move.b (a0)+,$FFFA0F
	move.b (a0)+,$FFFA13

	move.b (a0)+,$FFFA09
	move.b (a0)+,$FFFA0D
	move.b (a0)+,$FFFA11
	move.b (a0)+,$FFFA07

	move.w (sp)+,sr		* on repete les interruptions

				* invertion des tables
	move.l adr_tab_s,d0
	move.l adr_tab_p,adr_tab_s
	move.l d0,adr_tab_p
	rts

* routine tournant a chaque HBL
hbl_rout
	move.w d0,-(sp)
	move.l a0,-(sp)
	movea.l pt_table,a0
	addq.l #1,a0
	move.b (a0)+,$ff8205
	move.b (a0)+,$ff8207
	move.b (a0)+,$ff8209
	move.l a0,pt_table
	move.l (sp)+,a0
	move.w (sp)+,d0
	rte

	include "principh.s"
	
	section DATA
wobler_bin	incbin "wobler.tpi"
wobler	equ wobler_bin+128

data1	include "dat1.dat"
data2	include "dat2.dat"

	section BSS
table1	ds.l ecran_hauteur+1
table2	ds.l ecran_hauteur+1
adr_tab_p	ds.l 1
adr_tab_s	ds.l 1
pt_table	ds.l 1
posit_1	ds.w 1
posit_2	ds.w 1
hbl_flag	ds.b 1
mfp	ds.b 8