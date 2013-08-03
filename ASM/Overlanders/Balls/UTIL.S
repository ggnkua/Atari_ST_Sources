
* defin. ds .equivalences *
esc         equ   $1B  procedure d'echappement
rc          equ   $0D  retour chario
lf          equ   $0A  desc.ligne

neo	    equ  128
degas       equ  34
dos         equ  1
vdi         equ  2
aes         equ  2
bios        equ  13
xbios       equ  14

* def ds macro-instructions *

VSYNC	macro
	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7
	endm
SAVE    macro
        movem.l  d0-d7/a0-a6,-(sp)
        endm

APPEL  macro
       move.w  #\2,-(sp)
       trap    #\1
       add.l   #\3,sp
       ifc     '\4','save'
       movem.l (sp)+,d0-d7/a0-a6
       endc
       endm

OUT    macro
       APPEL dos,2,4,save
       endm

LFCR   macro
       SAVE
       move.w  #$a,-(sp)
       OUT
       SAVE
       move.w #rc,-(sp)
       OUT
       endm

WAIT   macro
       movem.l  d0-d7/a0-a6,-(sp)
       APPEL    dos,1,2,save
       endm

BIN     macro                 
        movem.l   d0-d7/a0-a6,-(sp)   "boucle"
        move.l    \1,d1
        move.l    #31,d2
        move.l    #$30,d0
        lsl.l     #1,d1
        dc.w      $6402
        addq.b    1,d0
        SAVE
        move.w    d0,-(sp)
        OUT
        dc.l      $51CAFFDB     equivaut a dbf d2,"boucle"
        movem.l   (sp)+,d0-d7/a0-a6
        endm
START    macro
         bra      hhh
pile     ds.l     1 
hhh      move.l   a7,a5
         lea.l    pile,a7
         move.l   4(a5),a5
         move.l   $c(a5),d0
         add.l    $14(a5),d0
         add.l    $1c(a5),d0
         add.l    #$100,d0
         move.l   d0,-(sp)
         move.l   a5,-(sp)
         move     #0,-(sp)
         move     #$4a,-(sp)
         trap     #1
         add.l    #12,sp
         endm
ECRIRE   macro
         SAVE
         move.l   \1,-(sp)
         APPEL    dos,9,6,save
         endm
HEX      macro
         movem.l  d0-d7/a0-a6,-(sp)
         move.l   #28,d1
         ifc      '\2','w'
         move.l   #12,d1
         endc
         move.l   \1,d0
         lsr.l    d1,d0
         and.l    #$f,d0
         cmp.b    #9,d0
         dc.w     $6E08
         add.b    #$30,d0
         dc.l     $60000006
         add.b    #$37,d0
         SAVE
         move.w   d0,-(sp)
         OUT
         subq     #4,d1
         dc.w     $6CCA
         movem.l  (sp)+,d0-d7/a0-a6
         endm
BMOVE    macro
         move.w   \3,d1
         move.l   \1,a0
         move.l   \2,a1
         subq.w   #1,d1
boucle   move.b   (a0)+,(a1)+
         dbeq     d1,boucle
         endm
         
FIN	 macro
	 APPEL	  1,0,2
	 endM
	 
OFF_MOUSE  macro	
        SAVE
        bra		ddd
eff_so	dc.b		$12
ddd	pea		eff_so(pc)
	move		#0,-(sp)
	APPEL		14,$19,8
	movem.l  (sp)+,d0-d7/a0-a6
	endm
	
ON_MOUSE   macro	
        SAVE
	bra		dddf
re_so	dc.b		$8	
dddf	pea		re_so(pc)
	move		#0,-(sp)
	APPEL		14,$19,8
	movem.l  (sp)+,d0-d7/a0-a6
	endm

CHAR_ECR1    macro     
        SAVE          
        OFF_MOUSE
        move.w         #2,-(sp)
        pea            filename(pc)
        APPEL          dos,$3d,8                  Fopen
        cmpi.w         #0,d0
        bmi            erreur
        lea            hand(pc),a0
        move.w         d0,(a0)
        APPEL	      14,2,2
	lea            phys(pc),a0
	move.l	      d0,(a0)
	APPEL	      14,3,2
	lea	      log(pc),a0
	move.l	      d0,(a0)
	move.w	      #0,-(sp)
	move.l	      phys(pc),-(sp)
        move.l         log(pc),-(sp)
        APPEL	      14,5,12
        pea            buffer(pc)              charge palette
        move.l         #\2,-(sp)            
        move.w         hand(pc),-(sp)       
        APPEL          dos,$3f,12               Fread
        move.l         phys(pc),-(sp)       
        move.l         #32000,-(sp)             charge ecran
        move.w         hand(pc),-(sp)       
        APPEL          dos,$3f,12   
         
        move.w         hand(pc),-(sp)
        APPEL          dos,$3e,4                   Fclose
        lea	      buffer(pc),a0
        
        ifc           '\2','degas'
        add.l	      #2,a0
        endc
        ifc           '\2','neo'
        add.l	      #4,a0
        endc
        move.l         a0,-(sp)
        APPEL	      14,6,6
        bra            fin
         ifc            '\2','degas'
buffer	 ds.b	        34
         endc
         ifc            '\2','neo'
buffer	 ds.b	        128
         endc
pal	 dc.w	        $777,$700,$070,0
phys	 ds.l           1
log      ds.l           1
mess     dc.b           'FICHIER INTROUVABLE,appuyer sur une touche .',0
hand     ds.w           1
filename dc.b            \1,0

erreur   lea            mess(pc),a4
         ECRIRE         A4
         FIN
fin      movem.l  (sp)+,d0-d7/a0-a6
         endm         
CHAR_ECR2   macro
         SAVE         
         ON_MOUSE
         pea	      pal(pc)
         APPEL	      14,6,6
         move.w	      #1,-(sp)
	 move.l	      phys(pc),-(sp)
         move.l       log(pc),-(sp)
         APPEL	      14,5,12
         movem.l  (sp)+,d0-d7/a0-a6
         endm
CHARG          macro
               SAVE
               move.w         #2,-(sp)
               pea            filename1(pc)
               APPEL          dos,$3d,8                  Fopen
               cmpi.w         #0,d0
               bmi            erreur1
               lea            hand1(pc),a0
               move.w         d0,(a0)

               pea            \3                          buffer de chargement
               move.l         #\2,-(sp)                  nb octet a charger
               move.w         hand1(pc),-(sp)              handle
               APPEL          dos,$3f,12                  Fread

               move.w         hand1(pc),-(sp)
               APPEL          dos,$3e,4                   Fclose

               bra            fin1

mess1           dc.b           'FICHIER INTROUVABLE,appuyer sur une touche .',0
hand1           ds.w           1
filename1       dc.b           \1,0
erreur1         lea            mess1(pc),a4
                 ECRIRE         A4
fin1             movem.l  (sp)+,d0-d7/a0-a6
                 endm