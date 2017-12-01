; M.C.S Software Presente Kung-Fu Master II(titre non def.)
; Programmation by Bouvier pascal , gfx by solo ,end mus by ???
 
; Jeu extrait du celebre kung-fun master et du dessin animee Dragon ball.
; Ce jeu est exlusivement edutier pour fonctionner sur 520/1040 STE
; Car le jeu utilise le scrooling hardware, le blitter, et le sond en DMA,
; et les 4096 couleurs.   Tous le jeu se joue en 50/s.
; Une convertion serras peut etres fait sur stf plus tard.
; NE FAITES PAS ATTENTIONS AUX FAUTES D'HORTOGRAPHES Humm humm...

;Voici une liste du debut des differentes idees du jeu en generale:
;(DEFINITIVES)

;	-SCROOLING HORIZONTAL 2*2 PIX 4 PLANS ou 4*4 selon situation
;	-RASTERS 4096 COULEUR(CIEL,EAU, ECT...)
;	-EFFETS DE REFLET DANS L'EAU (CHANGEMENT D'ADRESSE VIDEO+PAL)
;	-FIN DE NIVEAU UN ADVERSAIRE TRES FORT(SUIVANT UNE ARME+NIV)
;	-PENDANT LE JEU DES MONTRES,HOMMES,ANIMAUX VOUS ATTAQUES
;	-BORDER BAS POUR VIE,POSITION,ENNERGIE COUPS DISPONIBLE & OPT.
;	-
;	-
;	-
;	-
;	-

;(NON DEFINITIVES)

;	-Chargement pendants l'action(Si manques de Memoire)
;	-Differents Mod sndtrk ou sonds suivants la mem disponible.
;	-
;	-
;	-
;	-
;	-
;	-
;	-



;COMMANTAIRE SUR LA PROGRAMMATION:

***FORMAT DES SPRITE(ENNEMIES OU ANIMATION)***
	
1er FOR BLITTER:	-TYPE DE COURBE 1OCT	
		-NB D'UNITEES D'ENERGIES  
		-NB DE SEQ ANIMEE(ANIMATION) '*'
		QUI DONNE LES BLOCKS A PRENDRE(TOUJOURS DANS L'ORDRE SI DESSOUS)
		
		-REPARTITION DES POINT DE TOUCHE SUPRESIVE D'ENERGIES
		SUR LES EXTREMINTER DES SPRITE VOIR EXEMPLES.
		
-TAILLE EN H(BLOCK DE 16)	EX:    036 =>L:3 H:3  P.TOUCHE=>01235678
-TAILLE EN L(BLOCK DE 16)	       147 LA NUMEROTATION EST L'ORDRE DES BLOCKS A AFFICHEES
=>DETERMINE LA TAILLE DE LA      258
=>GRILLE POUR LE NB DE PLANS DE CHAQUES BLOCK.+MASK(OUI/NON)+NB PLANS(0-3)

		-ADRESSE SOURCE(BASE DE TOUS LES BLOCKS)
		-ADRESSE DESTINATION+MODULO 16
		
		
		

