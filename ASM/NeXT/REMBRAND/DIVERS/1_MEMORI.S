gemdos_init
 lea d‚but_bss,a0	Au cas o— il y aurait des vilains packeurs
 lea fin_bss,a1		ou que la m‚moire soit crade... On ne sait jamais !
.efface_bss
 clr.l (a0)+
 cmpa.l a1,a0
 blt.s .efface_bss
 
 move.l 4(a7),a5	LibŠre la m‚moire g‚n‚reusement allou‚e
 lea nouvelle_pile,a7	par le GEMDOS
 move.l 12(a5),d0	TEXT
 add.l 20(a5),d0	+DATA
 add.l 28(a5),d0	+BSS
 add.l #256,d0		+PAGE DE BASE	> TAILLE TOTALE NECESSAIRE
 move.l d0,-(sp)
 move.l a5,-(sp)
 clr -(sp)
 move #$4a,-(sp)
 trap #1
 lea 12(sp),sp

 bsr r‚serve_m‚moire_globale		R‚servation m‚moire globale
 bmi quitte_programme

aaa
 lea fichier,a0
 move.l #32000,d0
 bsr r‚serve_bloc

 lea fichier,a0
 bsr libŠre_bloc
 




quitte_programme
 clr -(sp)
 trap #1



 include FICHIERS.INC\MEMOIRE.S		Le gestionnaire de blocs m‚moire

 DATA
 
 BSS
d‚but_bss

buffer_vide		ds.w 1024	2ko remplis de 0 pour faire du nettoyage.

‚cran			ds.l 3	Descripteurs de blocs. Voir le module
‚cran_undo		ds.l 3	MEMOIRE.S
fichier			ds.l 3		

			ds.l 30000
nouvelle_pile		ds.l 1

fin_bss			ds.l 1 
 END
  