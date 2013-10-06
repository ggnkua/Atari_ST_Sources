;
; REMBRANDT 3.0 - ½  Dbug II
;
; Gestion des interuptions
;
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT

;
; Cette routine provient d'un source de demo STE ½ Atari Corp !!!
; Adaptations par moi...
; Cela permet d'abaisser le niveau d'IPL de l'interruption clavier,
; et donc par consequent permet d'executer les HBL (entre autre),
; sans avoir de perturbations.
;
;   ATARI: On est tous des dieux !!!
;
var set 0
routines_patch‚es
 andi #$f8ff,sr		Masque le niveau d'IPL
 ori #$500,sr		Puis valide un niveau 5
 jmp ([sauve_mfp_rout+var])
taille_patche=*-routines_patch‚es
var set var+4
 rept 16
 andi #$f8ff,sr		Masque le niveau d'IPL
 ori #$500,sr		Puis valide un niveau 5
 jmp ([sauve_mfp_rout+var])
var set var+4
 endr


adr_zoomer_0	dc.l 1

adr_syncr_0	dc.b 1
adr_syncr_1	dc.b 1
adr_syncr_2	dc.b 1
adr_syncr_3	dc.b 1


routine_hbl_1
 iif cpu_time not.l $ffff9800.w
 movem.l d0-d2/a0,-(sp)
 lea $ffff8203.w,a0
 move.l adr_syncr_0,d1
 move.l #$00ffff00,d2
 and.l d2,d1
 add.l #256*2,d1
.sync_hbl
 movep.l (a0),d0
 and.l d2,d0
 cmp.l d1,d0
 blt.s .sync_hbl

 move.l adr_zoomer_0(pc),d1
 movep.l d1,(a0)
 clr $ffff820e.w		; Largeur de ligne nulle...
 move $ffff82c2.w,d0		; Passe en non entrelac‚ !
 bclr #1,d0
 move d0,$ffff82c2.w
 
 iif cpu_time not.l $ffff9800.w

;$FF82C2|word |VCO                                BIT 2 1 0|R/W (F030)
;       |     |Halve pixel width (double pixels) -----' | ||
;       |     |Skip line (interlace) -------------------' ||
;       |     |Line doubling -----------------------------'|
  
* move.l d0,a0
* move #-1,(a0)

 clr $ffff820e.w			Change la longueur de la ligne
 sf $fffffa1b.w
 bclr #0,$fffffa0f.w
 movem.l (sp)+,d0-d2/a0
 rte

fuck_hbl
 move.l ‚cran,a0
 move largeur_‚cran,d0
 move d0,d1
 moveq #0,d2
 mulu position_hbl,d0
 add.l d0,a0
 lsr d1
 bclr #0,d1 
 lea -20(a0),a0
 move.l a0,adr_syncr_0
 rts


r‚glage_hbl
 getmouse
 move mousey,d7

.boucle
 lea ‚tat_touches,a0
 tst.b (a0,$1d)
 beq.s .fin_r‚glage
 getmouse 
 move mousey,d0
 sub d7,d0
 move mousey,d7

 add position_hbl,d0
 
 cmp #100,d0
 bgt.s .pas_haut

 moveq #100,d0
.pas_haut 
 move hauteur_visible,d1
 sub #10,d1
 cmp d1,d0
 blt.s .pas_bas
 move d1,d0
.pas_bas

 bsr vsync
 move sr,-(sp)
 move #$2700,sr
 move d0,position_hbl
 bsr fuck_hbl
 move (sp)+,sr
 bra .boucle
 
.fin_r‚glage
 rts

   
routine_vbl
 move #$2100,sr
 movem.l d0-a6,-(sp)	Sauve les registres

 bsr calcule_position_curseur

 lea routine_it_dummy,a0
 tst.b flag_curseur
 beq.s .curseur_invisible
 lea routine_hbl_hard,a0
.curseur_invisible
 move.l a0,$68.w

 move mousey_118,d0
 tst.b flag_double_hauteur
 beq.s .pas_double_hauteur
 lsr d0
.pas_double_hauteur
 add offset_hbl,d0
 sub #16,d0
 move d0,compteur_hbl_hard

 bsr gŠre_scrolling

 move.l ‚cran_scroll,d0
 
 move.b d0,d1
 lsr.l #8,d0
 move.b d0,$ffff8203.w
 lsr #8,d0
 move.b d0,$ffff8201.w
 move.b d1,$ffff820d.w

 move linewidth,$ffff820e.w
 move sauve_vco,$ffff82c2.w


 sf $fffffa1b.w
 tst.b flag_affiche_zoomer
 beq .no_hbl_zoom
 move.l #routine_hbl_1,$120.w
 move position_hbl,d0
 subq #5,d0
 move.b d0,$fffffa21.w
 move.l adresse_zoomer,adr_zoomer_0
 move.b #8,$fffffa1b.w
 bsr fuck_hbl
.no_hbl_zoom 

 bsr demande_position_souris

 st flag_vsync		Pour la routine de synchro verticale
 addq.l #1,compteur_vbl

 movem.l (sp)+,d0-a6	Restaure les registres

 and #$f8ff,2(sp)	Force le degr‚ IPL … 1.
 or #$100,2(sp)		Ca reconnecte la HBL hard
 rte

* jmp ([sauve_70])	On r‚ex‚cute la VBL systŠme... *** Hum...!

