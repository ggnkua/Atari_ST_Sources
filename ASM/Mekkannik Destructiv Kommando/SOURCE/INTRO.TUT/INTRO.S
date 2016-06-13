*                     MEKANNIK DESTRUCTIV KOMMANDO
		
		OPT O+,W-

*----------------------------------------------------------------
*     Buffers pour le scolling du bas et lettres sur ecran
*----------------------------------------------------------------

* occupation des buf(i) = 15360 octets = $3C00
tab_buf  equ $70000 

buf1     equ tab_buf+160*26*0     
buf2     equ tab_buf+160*26*1
buf3     equ tab_buf+160*26*2
buf4     equ tab_buf+160*26*3

* occupation des st(i) = 768 octets = $300

tab_st   equ tab_buf+160*26*4
st1      equ tab_st+8*26*0
st2      equ tab_st+8*26*1
st3      equ tab_st+8*26*2
st4      equ tab_st+8*26*3   

* occupation total des tabst(i)+tabbuf(i)+bufsp(i) =  $3F00

*----------------------------------------------------------------
*          Adresse des pages DEGAS decompactees
*----------------------------------------------------------------
* une image = 32000 octets = $7D00

degas1     equ $68000       * reste $300 octets jusqu'a $70000
lettre     equ $78000-420
*----------------------------------------------------------------
*               Constantes dues au chargement 
*----------------------------------------------------------------
adscreen equ $78000

*----------------------------------------------------------------
*                  Debut du programme  INTRO
*----------------------------------------------------------------

reserv	move.l  sp,pile       
	movea.l $04(sp),a5
        move.l  $08(a5),begin
	movea.l #$80000,sp    
	
	clr.l   -(sp)         
	move.w  #$20,-(sp)    
	trap    #1
	addq.l  #6,sp
	move.l  d0,stack      
 
        movem.l $FF8240,d0-d7
        movem.l d0-d7,coulsys
        movem.l buffer1,d0-d7
	movem.l d0-d7,$FF8240
	    
        dc.w    $A00A
        move.b  #$12,$FFFC02
        
	clr.w   -(sp)         
	move.l  #adscreen,-(sp)
	move.l  #adscreen,-(sp)
	move.w  #$05,-(sp)
	trap    #14
	lea     12(sp),sp
               
	lea     degas1,a3                * decompacte l'image degas
	lea     pic1+34,a5
	bsr     Compact
       
        BSR     L18E66   * decompactage
	bsr     depzic
	bsr     Razbuf			*efface les buffers
	bsr     table			*init table d'adresse des lettres
	jsr  $5091E
        bsr     bande
	bsr     detour
       
Debut  	move.b  $FFFC02,d0
        cmpi.b  #$39,d0
        bne     Debut
       
Fin    	lea     $4CE,a1
	lea     buffer1,a0
	move.l  (a0)+,$452
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.w  (a0)+,$4EE
	move.l  (a0)+,$502
        move.l  (a0)+,$70
        move.l  (a0)+,$118

	move.b #$07,$FF8800
	ori.b  #$3F,$FF8802
	move.b #3,$484
	
	clr.w   -(sp)        
	move.l  #-1,-(sp)
	move.l  #-1,-(sp)
	move.w  #$05,-(sp)
	trap    #14
	add.l   #12,sp
	movem.l coulsys,d0-d7
	movem.l d0-d7,$FF8240
	
	dc.w    $A009
	move.b  #$08,$FFFC02
       
       
*----------------------------------------------------------*
*              RELOCATION DE L'EXECUTABLE                  *
*----------------------------------------------------------*
       
reloc  move.l   #fblock-dblock,d0   * mise hors de porter du soft de
       movea.l  #$70000,a0       * relocation
       movea.l  #dblock,a1
dsds   move.b   (a1)+,(a0)+
       dbra     d0,dsds
       jmp      $70000
       
*-----------------------------------------------------------*
*                     Soft de relocation                    *
*-----------------------------------------------------------*
loading equ $20000
longexe equ 90000

dblock lea      soft(pc),a0   * chargement du fichier binaire
       movea.l  #loading,a1   * a l'adresse $20000
       movea.l  #longexe,a2
       jsr      Load(pc)
       
       move.l   begin(pc),a6
       
*-----------------------------------------------------------*
*  reloger le fichier par rapport a son adresse veritable   *
*-----------------------------------------------------------*
    
       movea.l  loading+02,a0    * longueur du code
       adda.l   loading+06,a0    * + longueur des data
       move.l   a6,d1            * adresse de base de la relocation
       move.l   #loading+28,d2   * adresse de debut du prog
        
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
       move.l   loading+2,$C(a6)    * long du texte
       move.l   loading+6,$14(a6)   * long des data
       move.l   loading+10,$1C(a6)  * long des BSS
       move.l   $8(a6),$10(a6)
       move.l   $C(a6),d0
       add.l    d0,$10(a6)         * adresse des DATA
       move.l   $10(a6),$18(a6)
       move.l   $14(a6),d0
       add.l    d0,$18(a6)         * adresse des BSS       
       
       movea.l #loading+28,a0
       movea.l a0,a1
       adda.l  #longexe,a1
       movea.l begin(pc),a2
rel1   move.l  (a0)+,(a2)+
       cmpa.l  a0,a1
       bge     rel1
       
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

soft	dc.b 	"T_LORE.MDK",0
 even
fblock

*--------------------------------------------------------------
*           effacer les 4 buffers de scrolling 
*--------------------------------------------------------------

Razbuf movea.l #tab_buf,a0
       moveq   #0,d1
       move.w  #16128/16-1,d0
Razbu1 move.l  d1,(a0)+
       move.l  d1,(a0)+
       move.l  d1,(a0)+
       move.l  d1,(a0)+
       dbra    d0,Razbu1
       rts
        
*-------------------------------------------------------------*
*  vecteur des lettres
*-------------------------------------------------------------*
       
table  movea.l #degas1,a0
       movea.l #lettre,a2
       moveq   #4,d0
ta2    movea.l a0,a3
       moveq   #19,d1
ta1    move.l  a0,(a2)+
       adda.l  #8,a0
       dbra    d1,ta1
       move.l  a3,a0
       adda.l  #26*160,a0
       dbra    d0,ta2
       rts

bande  lea     degas1+160*136,a4
       lea     adscreen+160*148,a5
       lea     adscreen+160*190,a6
       moveq   #8,d0
bande1 movem.l (a4)+,d1-a2
       movem.l d1-a2,(a5)
       movem.l d1-a2,(a6)
       movem.l (a4)+,d1-a2
       movem.l d1-a2,40(a5)
       movem.l d1-a2,40(a6)
       movem.l (a4)+,d1-a2
       movem.l d1-a2,80(a5)
       movem.l d1-a2,80(a6)
       movem.l (a4)+,d1-a2
       movem.l d1-a2,120(a5)
       movem.l d1-a2,120(a6)
       lea     160(a5),a5
       lea     160(a6),a6
       dbra    d0,bande1
       rts       
*----------------------------------------------------------------
*          Detournement des interruption VBL et HBL 
*----------------------------------------------------------------

detour	move.w  sr,-(sp)
	ori.w   #$700,sr
	lea     $4CE,a0
	lea     buffer1,a1
	move.l  $452,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0),(a1)+
	move.w  $4EE,(a1)+
	move.l  $502,(a1)+
	move.l  $70,(a1)+
	move.l  $118,(a1)+
               
        move.l  $118.W,acia1+2
        move.l  #acia,$118.W
        
        move.l  #alt,$502.W
        move.w  #1,$4EE.W
	move.l  #L18F66,$4CE.W
        move.l  #choose,$4D2.W             
 	move.l  #$50F94,$4D6.W
	move.l  #$00010003,$452.W
	move.w  (sp)+,sr
	rts
	
buffer1	dc.l 0	* 452 et 454
        dc.l 0  * 4CE
        dc.l 0  * 4D2
        dc.l 0  * 4D6
        dc.l 0  * 4DA
        dc.l 0  * 4DE
        dc.w 0  * 4EE
        dc.l 0  * 502
        dc.l 0  * 70
        dc.l 0  * 118
coulsys ds.w 16        
*----------------------------------------------------------------
*            Interruption acia ( clavier ou midi )
*----------------------------------------------------------------

acia   move.w  #$2500,sr
acia1  jmp     $00000000

alt    rts

*      DIFFERENTES   TACHES   SOUS   INTERRUPTION   VBL         
*     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*----------------------------------------------------------------
*               Gestion du scrolling horizontal
*----------------------------------------------------------------
choose  move.b $FFFC02,d0
        cmpi.b #$39,d0
        bne    Scroll
        rts


Scroll  move.w branch,D2     
        addq.w #1,branch     
        cmpi.w #3,d2         
        bne scroll1        
        clr.w branch         
scroll1 asl.w #2,d2          
        movea.l #adresse,a2   
        movea.l 0(a2,d2.w),a2 
        jmp (A2)              

ad1     movea.l #buf4,a6    
        bsr scroh
        movea.l #buf3,a6    
        movea.l #st3,a5
        bra scrolh

ad2     movea.l #buf3,a6
        bsr scroh
        movea.l #buf2,a6
        movea.l #st2,a5
        bra scrolh

ad3     movea.l #buf2,a6
        bsr scroh
        movea.l #buf1,a6
        movea.l #st1,a5
        bra scrolh

ad4     movea.l #buf1,a6    
        bsr scroh

        movea.l #texte,a0     
        movea.l #lettre,a1     

scrolh1 move.w  cmpt_let,d0 
        move.b  (a0,d0.w),d1 
        cmpi.b  #96,d1       
        bne    scrolh2       
        clr.w  cmpt_let      
        bra scrolh1          

scrolh2 ext.w d1             
        asl.w #2,d1          
        move.l 0(a1,d1.w),mem1
        addq.w #1,cmpt_let     
        move.w cmpt_let,d0
        move.b  (a0,d0.w),d1   
        cmpi.b  #96,d1         
        bne    scrolh3         
        move.b (a0),d1         
scrolh3 ext.w d1               
        asl.w #2,d1
        move.l 0(a1,d1.w),mem2 
        bsr masque     

        movea.l #buf4,a6 
        movea.l #st4,a5       

scrolh  moveq   #25,d0      
scrolh4 movem.l 8(a6),d1-a4 
        movem.l d1-a4,0(a6) 
        movem.l $38(a6),d1-a4
        movem.l d1-a4,$30(a6) 
        movem.l $68(a6),d1-a4 
        movem.l d1-a4,$60(a6)
        movem.l $98(a6),d1-d2
        movem.l d1-d2,$90(a6)
        adda.l #$98,a6
        move.l  (a5)+,(a6)+   
        move.l  (a5)+,(a6)+   
        dbra    d0,scrolh4
        rts

masque  movem.l d0-d6/a0-a2,-(sp)
        move.l  mem1,d4      
        move.l  mem2,d5      
masq1   moveq   #25,d0       
        move.l  d5,a1        
        movea.l #st1,a0      
masq2   move.l  0(a1),(a0)+  
        move.l  4(a1),(a0)+  
        adda.l  #160,a1
        dbra    d0,masq2

        moveq #3,d2          
        moveq #4,d3          
        moveq #12,d6         
masq3   movea.l #tab1,a0     
        movea.l 0(a0,d6.w),a0 
        movea.l d4,a1         
        movea.l d5,a2         
        moveq   #25,d0        
masq4   move.w 0(a1),d1
        swap d1
        move.w 0(a2),d1
        rol.l d3,d1
        swap d1
        move.w d1,(a0)+
        move.w 2(a1),d1
        swap d1
        move.w 2(a2),d1
        rol.l d3,d1
        swap d1
        move.w d1,(a0)+
        move.w 4(a1),d1
        swap d1
        move.w 4(a2),d1
        rol.l d3,d1
        swap d1
        move.w d1,(a0)+
        move.w 6(a1),d1
        swap d1
        move.w 6(a2),d1
        rol.l d3,d1
        swap d1
        move.w d1,(a0)+

        lea    160(a1),a1        
        lea    160(a2),a2        
        dbra   d0,masq4
        addq.l   #4,d3        
        subq.l   #4,d6        
        subq.l   #1,d2        
        bne masq3
        movem.l (sp)+,d0-d6/a0-a2
        rts


scroh   movea.l #$78000+160*161,a5      
        moveq   #25,d0         
scro1   movem.l $00(a6),d1-a4  
        movem.l d1-a4,$00(a5)
        movem.l $30(a6),d1-a4
        movem.l d1-a4,$30(a5)
        movem.l $60(a6),d1-a4
        movem.l d1-a4,$60(a5)
        movem.l $90(a6),d1-d4
        movem.l d1-d4,$90(a5)
        lea     160(a5),a5
        lea     160(a6),a6
        dbra    d0,scro1
        rts

        
*---------------------------------------------------------------*
*         Decompacteur d'images au format DEGAS (PC1)           *
*                    en basse resolution                        *
* Par  - Metal68 -  from  MEKANNIK DESTRUCTIV KOMMANDO          *
* Le 02/10/1988                                                 *
*---------------------------------------------------------------*
        
Compact move.l  #199,d4
        movea.l #6,a0
        moveq   #4,d6
        moveq   #40,d7
Compac1 clr.b   d1
        movea.l a3,a4
Compac3 move.l  a4,-(sp)
        clr.b   d3
Compac2 move.b  (a5)+,d0
        tst.b   d0
        bmi     Compac6
        addq.b  #1,d0
Compac4 move.b  (a5)+,(a4)+
        addq.b  #1,d3
        move.l  a4,d5
        btst    #0,d5
        bne     Compac8
        add.l   a0,a4
Compac8 subq.b  #1,d0
        bne     Compac4
        bra     Compac7
Compac6 neg.b   d0
        addq.b  #1,d0
        move.b  (a5)+,d2
Compac5 move.b  d2,(a4)+
        addq.b  #1,d3
        move.l  a4,d5
        btst    #0,d5
        bne     Compac9
        add.l   a0,a4
Compac9 subq.b  #1,d0
        bne     Compac5
Compac7 cmp.b   d7,d3
        bne     Compac2
        move.l  (sp)+,a4
        addq.l  #2,a4
        addq.b  #1,d1
        cmp.b   d6,d1
        bne     Compac3
        add.l   #160,a3
        dbra    d4,Compac1              
        rts

*-------------------------*
* deplace music           *
*-------------------------*
depzic	lea $60000,a0
	lea code,a1
	lea music,a2
b1	move.w (a1)+,(a0)+
	cmpa.l a1,a2
	bne b1
	
	lea $5091E,a0
	lea music,a1
	lea texte,a2
b2	move.w (a1)+,(a0)+
	cmpa.l a1,a2
	bne b2
	rts
	
*-------------------------------------------------------------*
*             Decompactage de l'image spectrum                *
*-------------------------------------------------------------*

L18E66	MOVEM.L	D0-D7/A0-A5,-(A7)
       	lea     image+12,a0
       	lea     adscreen,a1
	MOVE.W	#1,D1
	MOVE.W	#7,D7
	LEA	$7D00(A1),A2
	LEA	8(A2),A3
L18E86	LEA	-$7C60(A2),A1
L18E8A	MOVE.B	(A0)+,D6
	EXT.W	D6
	BMI.S	L18E9C
L18E90	MOVE.B	(A0)+,(A1)
	ADDA.W	D1,A1
	EXG	D1,D7
	DBF	D6,L18E90
	BRA.S	L18EAC
L18E9C	NEG.W	D6
	ADDQ.W	#1,D6
	MOVE.B	(A0)+,D0
L18EA2	MOVE.B	D0,(A1)
	ADDA.W	D1,A1
	EXG	D1,D7
	DBF	D6,L18EA2
L18EAC	CMPA.L	A2,A1
	BCS.S	L18E8A
	ADDQ.L	#2,A2
	CMPA.L	A3,A2
	BCS.S	L18E86

*-------------------------------------------------------------*
*             Decompactage  des couleurs de l'image           *
*-------------------------------------------------------------*
        movea.l image+4,a0
        adda.l  #image+12,a0	
	lea     buffer,A1   * ad.palette
	MOVE.W	#$254,D7
	CLR.W	D0
L18EC4	MOVE.W	#$D,D6
	MOVE.W	(A0)+,D1
	LSR.W	#1,D1
	MOVE.W	D0,(A1)+
L18ECE	LSR.W	#1,D1
	BCC.S	L18EDA
	MOVE.W	(A0)+,(A1)+
	DBF	D6,L18ECE
	BRA.S	L18EE0
L18EDA	MOVE.W	D0,(A1)+
	DBF	D6,L18ECE
L18EE0	MOVE.W	D0,(A1)+
	DBF	D7,L18EC4
	MOVEM.L	(A7)+,D0-D7/A0-A5
	RTS

* routine spectrum
	
L18F66	TST.W	$43E.W
	BNE	L190EE
	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	LEA	$FF8240,A4
	LEA	$FF8209,A5
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	LEA	L18FA2(PC),A6
	MOVEA.L	L190F0(pc),A3
	MOVE.W	#200-61,D7 	*nbre ligne ($c4)
	MOVEQ	#0,D0
L18F94	TST.B	(A5)
	BEQ.S	L18F94
	MOVE.B	(A5),D0
	ADDA.L	D0,A6
	ADDA.L	L18E62(pc),A6
	JMP	(A6)
L18FA2	rept 76
        NOP
        endr
L1903A	NOP
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	rept 8
	MOVE.L	(A3)+,(A0)+
	endr
	rept 8
	MOVE.L	(A3)+,(A1)+
	endr
	rept 8
	MOVE.L	(A3)+,(A2)+
	endr
	NOP
	DBF	D7,L1903A
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	rept 8
	MOVE.L	(A3)+,(A0)+
	endr
	rept 8
	MOVE.L	(A3)+,(A1)+
	endr
	rept 8
	MOVE.L	(A3)+,(A2)+
	endr
	LEA	(A4),A0
	LEA	(A4),A1
	LEA	(A4),A2
	LEA	-$4A60(A3),A4
	NOP
	NOP
	rept 8
	MOVE.L	(A3)+,(A0)+
	endr
	rept 8
	MOVE.L	(A3)+,(A1)+
	endr
	rept 8
	MOVE.L	(A3)+,(A2)+
	endr
	MOVE.W	(A7)+,SR
	movem.l color,d0-d7
	movem.l d0-d7,$FF8240
L190EE	RTS
color dc.w $000,$530,$777,$655,$433,$554,$443,$640,$232
      dc.w $750,$760,$770,$220,$110,$211,$000
      

*----------------------------------------------------------------
*                             Data
*----------------------------------------------------------------
               
L18E62	 dc.l 00000
L190F0	dc.l buffer

cmpt_let dc.w 0000
branch   dc.w 0000
mem1     dc.l 0000
mem2     dc.l 0000
tab1     dc.l st1
         dc.l st2
         dc.l st3
         dc.l st4
adresse  dc.l ad4
         dc.l ad1
         dc.l ad2
         dc.l ad3


image   incbin  INTRO.TUT\tu2.spc
pic1    incbin  INTRO.TUT\fntvid1.pc1         
code    incbin  INTRO.TUT\code.zic
music   incbin  INTRO.TUT\music.bin
texte   incbin  INTRO.TUT\texte.mdk
buffer  
	
