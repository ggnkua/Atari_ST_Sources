
*----------------------------------------------------------*
*              RELOCATION DE L'EXECUTABLE                  *
*----------------------------------------------------------*
       
reloc  move.l   #(fblock-dblock)/2,d0   * mise hors de porter du soft de
       movea.l  #$70000,a0       * relocation
       movea.l  #dblock,a1
dsds   move.w   (a1)+,(a0)+
       dbra     d0,dsds
       jmp      $70000
       
*-----------------------------------------------------------*
*                     Soft de relocation                    *
*-----------------------------------------------------------*
longexe equ 300000

dblock lea      soft(pc),a0	* chargement du fichier binaire
       movea.l  begin(pc),a1
       suba.l   #28,a1		* a l'adresse $20000
       movea.l  #longexe,a2
       jsr      Load(pc)
dbb1   move.l   begin(pc),a6
       
*-----------------------------------------------------------*
*  reloger le fichier par rapport a son adresse veritable   *
*-----------------------------------------------------------*
       movea.l  02(a1),a0    * longueur du code
       adda.l   06(a1),a0    * + longueur des data
       move.l   a6,d1            * adresse de base de la relocation
       move.l   a6,d2   * adresse de debut du prog
        
       movea.l  d2,a2       
       movea.l  d2,a3
       adda.l   a0,a3
       move.l   (a3)+,d0        * 1er offset sur un mot long
       beq      reloc3          * si = 0 alors pas de relocation
       clr.l    -4(a3)
reloc1 adda.l   d0,a2           * pointer sur la prochaine adresse a changer 
       moveq    #0,d0           
       add.l    d1,(a2)         * ajouter l'adresse de base
reloc2 move.b   (a3),d0      
       beq      reloc3          * si = 0 alors fin de la relocation
       clr.b    (a3)+
       cmp.b    #1,d0           * si = 1 alors saut de 254 octets
       bne      reloc1
       adda.l   #254,a2
       bra      reloc2
reloc3 lea      -$100(a6),a6
       move.l   2(a1),$C(a6)    * long du texte
       move.l   6(a1),$14(a6)   * long des data
       move.l   10(a1),$1C(a6)  * long des BSS
       move.l   $8(a6),$10(a6)
       move.l   $C(a6),d0
       add.l    d0,$10(a6)         * adresse des DATA
       move.l   $10(a6),$18(a6)
       move.l   $14(a6),d0
       add.l    d0,$18(a6)         * adresse des BSS       
       
	move.l  stack(pc),-(sp)         * passage en utilisateur
	move.w  #$20,-(sp)              * restitution de la pile superviseur
	trap    #1
	addq.l  #6,sp
	move.l  pile(pc),sp             * retitution de la pile systeme
        movem.l zero(pc),d0-a6
        move.l  begin(pc),a0
        suba.l  #$100,a0
	move.l  a0,4(sp)       * adresse du header dans pile+4
	jmp     $100(a0)
begin dc.l 0
pile  dc.l 0
stack dc.l 0     
zero  ds.l 16
*---------------------------------------------------------------
*               Chargement d'un fichier 
*--------------------------------------------------------------

;      a0: adresse du nom
;      a1: adresse du buffer
;      a2: longueur

Load  move.w  #0,-(sp)
      move.l  a0,-(sp)
      move.w  #$3D,-(sp)
      trap    #1
      addq.l  #8,sp
      tst.w   d0
      bpl     read

error clr.l   -(sp)
      trap    #1
      
read  move.w  d0,d3
      move.l  a1,-(sp)
      move.l  a2,-(sp)
      move.w  d3,-(sp)
      move.w  #$3F,-(sp)
      trap    #1
      adda.l  #12,sp

close move.w  d3,-(sp)
      move.w  #$3E,-(sp)
      trap    #1
      addq.l  #4,sp
      rts

soft	dc.b 	"new.prg",0
 even
fblock
