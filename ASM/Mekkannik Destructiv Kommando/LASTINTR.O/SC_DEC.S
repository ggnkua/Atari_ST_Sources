
*----------------------------------------------------------------
*               Gestion du scrolling horizontal
*----------------------------------------------------------------

Scroll  move.w branch,D2     
        addq.w #1,branch
        and.w  #3,branch     
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
        movea.l #lettre1,a1     

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

scrolh  moveq   #12,d0      
scrolh4 movem.l 8(a6),d1-a4 
        movem.l d1-a4,0(a6) 
        movem.l $38(a6),d1-a4
        movem.l d1-a4,$30(a6) 
        movem.l $68(a6),d1-a4 
        movem.l d1-a4,$60(a6)
        movem.l $98(a6),d1-d2
        movem.l d1-d2,$90(a6)
        lea     $98(a6),a6
        move.l  (a5)+,(a6)+   
        move.l  (a5)+,(a6)+   
        dbra    d0,scrolh4
        rts

masque  movem.l d0-d6/a0-a2,-(sp)
        move.l  mem1,d4      
        move.l  mem2,d5      
masq1   moveq   #12,d0       
        move.l  d5,a1        
        movea.l #st1,a0      
masq2   move.l  (a1),(a0)+  
        move.l  4(a1),(a0)+  
        lea     160(a1),a1
        dbra    d0,masq2

        moveq #3,d2          
        moveq #4,d3          
        moveq #12,d6         
masq3   movea.l #tab1,a0     
        movea.l (a0,d6.w),a0 
        movea.l d4,a1         
        movea.l d5,a2         
        moveq   #12,d0        
masq4   move.w (a1),d1
        swap d1
        move.w (a2),d1
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


scroh   movea.l #$78000+160*82,a5      
        moveq   #12,d0         
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
