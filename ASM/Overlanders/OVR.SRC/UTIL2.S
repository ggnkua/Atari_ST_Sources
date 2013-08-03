
* defin. ds .equivalences *
esc         equ   $1B  procedure d'echappement
rc          equ   $0D  retour chario
lf          equ   $0A  desc.ligne

dos         equ  1
vdi         equ  2
aes         equ  2
bios        equ  13
xbios       equ  14

* def ds macro-instructions *

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
       APPEL    dos,8,2,save
       endm

TEST    macro
        movem.l  d0-D7/a0-a6,-(sp)

        ifc '\1','d'
        move.l    #$30,d3
        endc

        LFCR
        addi.b    #1,d3
        SAVE
        move.w    d3,-(sp)
        OUT
        WAIT
        movem.l   (sp)+,d0-d7/a0-a6
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
* initia. GEMDOS *
START    macro
         move.l   a7,a5
*         lea.l    pile,a7
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
*pile     dc.l  1
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
TRACE    macro
         SAVE
         clr.l    -(sp)
         APPEL    dos,$20,6
         move.l   do,memosp
         lea.l    visu(pc),a0
         move.l   a0,$024
         ori      #$8000,sr
         move.l   memosp,-(sp)
         APPEL    dos,$20,6,save
         endm
BMOVE    macro
         move.w   \3,d1
         move.l   \1,a0
         move.l   \2,a1
         subq.w   #1,d1
boucle   move.b   (a0)+,(a1)+
         dbeq     d1,boucle
         endm
SETCOLOR macro
         move.w   \2,-(sp)
         move.w   \1,-(sp)
         APPEL    xbios,7,6
         endm
VSYNC   macro
        APPEL   xbios,$25,2
        endm
HIDEM   macro
        dc.w    $a00a
        endm
SHOWM   macro
        dc.w    $a009
        endm
