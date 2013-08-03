; Yehoo !.
; Bon, ben aprŠs le MandBoot, qui ‚tait d‚j… un petit bonus,
; voici un petit boot qui va ravir les gentils utilisateurs
; de STE qui n'ont pas de disque dur. Peut-ˆtre en avez vous
; marre de devoir attendre pendant des heures … l'allumage
; de votre STE, lorsque vous n'avez pas de disque dur.
; Voici le remŠde. Le but est simple: la routine de d‚tection
; de disque dur lui laisse une dizaine de secondes … l'allumage
; pour r‚pondre pr‚sent. Si pass‚ ce d‚lai il ne re‡oit aucune
; reponse, il passe … la suite. Mais comme vous n'avez pas de
; disque dur, vous ˆtes oblig‚ de suporter ca … chaque allumage.
; Pas de problŠme, il suffit de faire sauter l'appel au d‚tecteur
; de disque dur, dans la ROM !.
; La ruse … employer est assez simple.
; Dans la ROM, depuis les TOS 1.0 jusqu'aux TOS les plus r‚cents,
; il y a vers la fin de la routine d'initialisation, trois appels
; regroupes:
;
;boot1:   BSR  fboot        <-boot sur disquette
;boot2:   BSR  hboot       <-boot sur disque dur
;boot3:   BSR  mboot       <-soft-boot en RAM.
;
; Voyons comment est faite la routine xxxxxx de boot sur disquette:
;
;fboot: MOVEQ.L   #3,D0           !detecter une ‚ventuelle cartouche
;       BSR       $12345678       !de diagnostic (a'chment utile pour nous!)
;       MOVEA.L   $47A,A0         !Adresse routine de lecture du boot-secteur
;       JSR       (A0)            !Execute
;       TST.W     D0              !Le Boot contient-il un programme ?
;       BNE       *+$0A           !Non
;       LEA       $1234,A0        !Si, adresse du boot-secteur
;       JSR       (A0)            !Execute le
;fend:  RTS                       !Retour
;
; Donc quand notre boot sera appel‚, on aura sur la pile:
;  4(A7)=boot2
;   (A7)=fend
;
; Or une instruction BSR prend 4 octets en m‚moire. Donc on a boot2+4=boot3
; Il suffit donc d'ajouter 4 … l'adresse contenue dans 4(SP) pour sauter le
; BSR hboot qui nous gˆne. Simple, non ?
; C'est aussi utile pour ceux-ces qui ont un dur et qui veulent pouvoir le
; d‚sactiver sans l'‚teindre, au reset.
; Dans le boot qui suit, si vous appuyez sur Shift gauche, le disque dur
; sera ignor‚,et le lecteur de boot (pour vos accessoires et fichiers AUTO)
; sera le lecteur A:\.
; Si vous appuyez sur Shift droit, le lecteur de boot sera B:\ (ca vous
; fait un freeboot logiciel pour pas cher).
; (Si les deux shifts sont enfonc‚s, c'est le droit qui l'emporte)
;
; Evidement, ceux qui n'ont pas de disque dur n'ont pas besoin de ca, et
; pourront se contenter d'un boot simple (mettez l'‚tiquette SIMPLE … 0
; pendant l'assemblage sur disque) qui vire les routines de disque dur
; … chaque fois, ce qui permet d'avoir un boot rapide sur STE.
;

TEST	equ	1
SIMPLE	equ	1

	IFEQ	TEST
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)
	bsr	start_boot
	trap	#1
	clr.w	(sp)
	trap	#1
	ENDC

start_boot
	IFEQ	SIMPLE
	addq.l	#4,4(sp)		;Pour STE sans disk dur..
	ELSEIF
	move.l	#$000bffff,-(sp)	;demande ‚tat alt/control/shift
	trap	#13		;
	addq.l	#4,sp		;
	lea	$446.w,a0		;adresse _bootdev
	lsr.b	#1,d0		;shift droit ?
	bcc.s	next1		;non
	move.w	#1,(a0)		;si, B:\
	bra.s	next2
next1	lsr.b	#1,d0		;shift gauche ?
	bcc.s	next3		;toujours pas, ‚vite le reste
	clr.w	(a0)		;si, A:\
next2	addq.l	#4,4(sp)		;saute le disk dur
	move.w	(a0),-(sp)		;fixe le drive par d‚faut (il
	move.w	#14,-(sp)		;vient d'ˆtre fix‚ par le TOS
	trap	#1		;au reset, donc y'a un d‚calage
	addq.l	#4,sp		;… rattraper)
	ENDC
next3	pea	message(pc)	;message de bienvenue
	move.w	#9,-(sp)		;
	trap	#1		;
	addq.l	#6,sp		;
	rts



message	dc.b	"     Hello, I'm the harddisk killer..",$d,$a
	dc.b	"      (C)oderight NulloS//DNT 1992",$d,$a
	dc.b	"    Don't panic, I'm NOT a virus !!!",$d,$a,$a,$a

	IFNE	SIMPLE
	dc.b	"Next time, press left-Shift to avoid",$d,$a
	dc.b	"the DMA-boot and set the AUTO folder",$d,$a
	dc.b	"and ACC files on drive A:\ .",$d,$a
	dc.b	"Press right-Shift for the same effect,",$d,$a
	dc.b	"but with _bootdev=B:\ .",$d,$a,$a,0
	ELSEIF
	dc.b	0
	ENDC