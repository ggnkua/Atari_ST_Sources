            output	m4.dat
            
            ;--------------------------- 
            move.l	sp,sav_sp
            ;----------------                        
            lea.l	DSPbin.start(pc),a0
	    moveq.l     #(DSPbin.end-DSPbin.start)/3,d0
            moveq	#6,d0
            trap	#4
            
            ;bsr		MGTK_P56_Loader
            
            ;Dsp_ExecProg	#DSPbin.start,#(DSPbin.end-DSPbin.start)/3,#'NC'                            
            ;----------------
            lea 	$2f0000,a0
            lea 	$2f0000-372*256,a1
            move.l 	#384*2*120*2/4-1,d7
            moveq 	#0,d0	
clr_s       move.l 	d0,(a0)+
            move.l 	d0,(a1)+
            subq.l 	#1,d7
            dbf 	d7,clr_s         
;-------------------------------------------            
            lea 	pic,a0
	    lea 	out_put,a1
	    moveq 	#0,d0
	    move.w 	#256-1,d6
sec 	    move.w 	#256-1,d7
fir 	    move.w 	(a0)+,d0
 	    move.w 	d0,(a1)+
 	    move.w 	d0,(a1)+
            dbf    	d7,fir
            dbf 	d6,sec 
;-------------------------------------------                        
            ;move.l  #bus,8.w
;-------------------------------------------                                    
wide	    =  384
            lea 	adr_yt-(64*4),a0
            move.l  	#64*(-384*2),d0    
            move.w 	#250-1,d7
doo_adr     move.l 	d0,(a0)+
            add.l 	#wide*2,d0
            dbf 	d7,doo_adr                                 
;-----------------------------------                  
env_main
            ;bra ooo
wait                            
            move.l 	scren_p(pc),a0            
            move.w 	#384*2*99/4/64-1,d7
            move.l 	#$00000000,d0
clr_scren   rept 	64            
            move.l 	d0,(a0)+ 
            endr
            dbf 	d7,clr_scren
ooo     
;---------------------------------------  
          add.w #4,ad_x
          add.w #6,ad_y
          add.w #6,ad_z
          and.w #$1ff,ad_x
          and.w #$1ff,ad_y 
          and.w #$1ff,ad_z          
;--------------------------------------- 
            cmp.w	#120/2,pop2+2
            blt.b	draw
            sub.w	#10,pop2+2
             
            
draw        lea  cos,a3
            lea  sin,a4
            move.l  actual,a6
            move.w #14,d7                       
            move.w 4(a6),add_to_z+2
            add.w #8,a6
            lea output__(pc),a5 
            lea zety(pc),a0                                                                                                                             
            move.w ad_x(pc),a1
            ;move.w ad_y(pc),a1
            move.w ad_z(pc),a2 
loop    
            movem.w (a6)+,d0-d2                 


os_y        move.w d1,d3
            move.w d2,d4
            muls (a4,d6.w),d3
            muls (a3,d6.w),d4
            sub.l d3,d4
            asr.l #8,d4
            move.w d4,d5
            move.w d1,d3
            move.w d2,d4
            muls (a3,d6.w),d3
            muls (a4,d6.w),d4
            add.l d3,d4
            asr.l #8,d4
            move.w d4,d2
            move.w d5,d1  
os_x        move.w d0,d3
            move.w d2,d4
            muls (a4,a1.w),d3
            muls (a3,a1.w),d4
            sub.l d3,d4
            asr.l #8,d4
            move.w d4,d5
            move.w d0,d3
            move.w d2,d4
            muls (a3,a1.w),d3
            muls (a4,a1.w),d4
            add.l d3,d4
            asr.l #8,d4
            move.w d4,d2 
            move.w d5,d0                 
os_z        move.w d0,d3        
            move.w d1,d4
            muls (a4,a2.w),d3
            muls (a3,a2.w),d4
            sub.l d3,d4
            asr.l #8,d4
            move.w d4,d5
            move.w d0,d3
            move.w d1,d4
            muls (a3,a2.w),d3
            muls (a4,a2.w),d4
            add.l d3,d4
            asr.l #8,d4
            move.w d4,d1
            move.w d5,d0 
        
            move.w d2,(a0)+
add_to_z    add.w #520,d2
            
            ext.l d0                  
            ext.l d1     
            asl.l  #7,d0
            asl.l  #7,d1     
            divs d2,d0
            divs d2,d1 
                
pop         add.w #192/2,d0
pop2        add.w #250,d1
                   
            move.w d0,(a5)+
            move.w d1,(a5)+
            
            subq.w #1,d7
            bne loop 
;-----------------------------------------            
fff            
            lea     output__(pc),a0
            lea     rot_norms,a4
            move.w  #25,d7            
            lea     fejsy,a3
            lea     kolej(pc),a2                                    
d_loop                                    
            move.w (a3)+,d6                                       
            movem.w (a0,d6.w*4),d0/d3                                                       
            
            
            move.w (a3)+,d6                                     
            movem.w (a0,d6.w*4),d1/d4                                          
            
            move.w (a4,d6.w*4),xt2
                        
            move.w (a3)+,d6                                                          
            movem.w (a0,d6.w*4),d2/d5
            addq.l #2,a3
            
            lea xt1(pc),a6
            move.w #10,(a6)+
            move.w #128-1,(a6)+
            move.w #10,(a6)+
            move.w #0,(a6)+
            move.w #0,(a6)+
            move.w #128-1,(a6)+
           
                      
dalej_ho_3              
            move.l d0,x1
            move.l d1,x2
            move.l d2,x3
            move.l d3,y1
            move.l d4,y2
            move.l d5,y3                                                                                                                                     
            
                                                                                                                  
            sub.l d1,d2
            sub.l d0,d1
            sub.l d4,d5
            sub.l d3,d4
            muls d1,d5
            muls d4,d2
            sub.l d2,d5
            bmi.b nie_rysuj
            
omin                              
            movem.l d0-a6,-(sp)                        
            bsr recgo
            movem.l (sp)+,d0-a6            
            
nie_rysuj   
            dbf d7,d_loop                          
        
;------------------------------------------                  
            move.l scren_p,d0
            move.l scren_l,scren_p
            move.l d0,scren_l
            lsr.w #8,d0
            move.l d0,$ffff8200.w
    
            cmp.b #1,$ffffffffc02.w
            bne env_main
;------------------------------------------                               
fin                 
exit 
;-------------------------------------
                                                                                  
           move.l	sav_sp,sp
           rts
;-------------------------------           
recgo    
           move.l  x1(pc),d0          
           move.l  y1(pc),d1            
           move.l  x2(pc),d2
           move.l  y2(pc),d3             
           move.l  x3(pc),d4
           move.l  y3(pc),d5
           lea     xt1(pC),a4
           
           cmp.w   d5,d1
           blt.b   w_1            
           exg.l   d0,d4     ;1&3
           exg.l   d1,d5  
            
           move.w  4(a4),d6
           move.w  (a4),4(a4)
           move.w  d6,(a4)
            
           move.w  4+6(a4),d6
           move.w  6(a4),4+6(a4)
           move.w  d6,6(a4)
                                                                                                                               
w_1        cmp.w   d5,d3
           blt.b   w_3            
           exg.l   d2,d4     ;2&3 
           exg.l   d3,d5   
                        
           move.w  4(a4),d6
           move.w  2(a4),4(a4)
           move.w  d6,2(a4)              
            
           move.w  4+6(a4),d6
           move.w  2+6(a4),4+6(a4)
           move.w  d6,2+6(a4)                          
                                                   
w_3        cmp.w   d3,d1
           blt.b   w_2            
           exg.l   d1,d3     ;1&2
           exg.l   d0,d2   
            
           move.w  2+6(a4),d6
           move.w  6(a4),2+6(a4)
           move.w  d6,6(a4)                               
                                    
           move.w  2(a4),d6
           move.w  (a4),2(a4)
           move.w  d6,(a4)                                                                                                                           
w_2        
           cmpi.w  #99,d1
           blt.b   faraway           
back       rts     

faraway    cmp.w #192,d0 
           bhs.b outside 
           cmp.w #192,d2
           bhs.b outside
           cmp.w #192,d4
           bhs.b outside
           cmp.w #99,d1
           bhs.b outside
           cmp.w #99,d3
           bhs.b outside
           cmp.w #99,d5
           bhs.b outside
           bra fitt 

outside    lea     save_ar(pc),a0
           move.w  d1,(a0)+
           move.w  d3,(a0)+
           move.w  d5,(a0)+
           move.w  d0,(a0)+
           move.w  d2,(a0)+
           move.w  d4,(a0)+
           
           move.l  d2,a3
           move.l  d3,a4
           move.l  d4,a5
           move.l  d5,a6             
;licz przyrost miedzy (x1,y1) a (x2,y2)
           lea     dane(pc),a0
           move.w  d0,d6
           sub.w   d0,d2
           sub.w   d1,d3
           move.w  d3,tem1(a0)
           bne.b   ok_zero_1            
           moveq   #1,d3   
ok_zero_1  swap.w  d2           
           ext.l   d3
           divs.l  d3,d2                                                                
           move.l  d2,tyle+2
           move.w  d3,d7 
;licz przyrost miedzy (x1,y1) a (x3,y3)        
           sub.w   d0,d4
           sub.w   d1,d5
           move.w  d5,tem2(a0)               
           bne.b   ok_zero_2
           moveq   #1,d5                         
ok_zero_2  swap.w  d4
           ext.l   d5           
           divs.l  d5,d4                                      
           move.l  d4,mod10+2
           move.l  d4,mod11+2             
;licz przyrost miedzy (x2,y2) a (x3,y3)                                             
           move.l  a5,d4
           move.l  a6,d5              
           sub.w   a3,d4
           sub.w   a4,d5         
           bne.b   ok_zero_3
           moveq   #1,d5   
ok_zero_3  swap.w  d7           
           move.w  d5,d7
           swap.w  d7                                    
           swap.w  d4 
           ext.l   d5
           divs.l  d5,d4                                            
           move.l  d4,tyle2+2                         
;-----------------------------------------                          
           move.l  scren_p(pc),a6            
           lea     adr_yt,a5                                                                                                       
           tst.w   d1
           bpl.b   y_is_ok 
           moveq   #0,d1    
y_is_ok    add.l   (a5,d1.w*4),a6                                                                                                                                                                                         
           move.l  a0,a4 
           swap.w  d0                      
           move.l  d0,a0
           move.l  d0,a1                                  
           moveq   #0,d0
           moveq   #0,d1          
                    
           move.w  tem1(a4),d3
           move.w  tem2(a4),d4                                                                                
           ext.l   d3
           ext.l   d4
           ***** 
           move.w  xt2(pc),d0
           sub.w   xt1(pc),d0                                                        
           swap.w  d0
           divs.l  d3,d0                        
           move.l  d0,d_x1
           *****      
           move.w  xt3(pc),d0
           sub.w   xt1(pc),d0                                                
           swap.w  d0
           divs.l  d4,d0                        
           move.l  d0,d_x2           
           *****        
           move.w  xt3(pc),d0
           sub.w   xt2(pc),d0                                    
           swap.w  d0            
           divs.l  d5,d0                                             
           move.l  d0,d_x3
           *****       
           move.w  yt2(pc),d0
           sub.w   yt1(pc),d0                                    
           swap.w  d0           
           divs.l  d3,d0                                    
           move.l  d0,d_y1
           *****                    
           move.w  yt3(pc),d0
           sub.w   yt1(pc),d0                                             
           swap.w  d0
           divs.l  d4,d0                       
           move.l  d0,d_y2           
           *****                     
           move.w  yt3(pc),d0
           sub.w   yt2(pc),d0                                  
           swap.w  d0            
           divs.l  d5,d0                        
           move.l  d0,d_y3
           *****                                                                            
;---------------------------------                      
oy1         =      0
oy2         =      2
oy3         =      4
ox1         =      6
ox2         =      8
ox3         =      10 
           moveq   #0,d0
           moveq   #0,d1           
           lea     save_ar(pc),a2 
;------------------------------------------------           
;                   (y2-y1) << 16
;          temp = --------------
;                      y3-y1
;------------------------------------------------                      
           move.w  oy2(a2),d0
           sub.w   oy1(a2),d0 
           swap.w  d0
           move.w  oy3(a2),d1
           sub.w   oy1(a2),d1
           ext.l   d1
           tst.l   d1
           bne.b   div_ok_01
           moveq   #1,d1  
div_ok_01  divs.l  d1,d0 
;------------------------------------------------           
;    width = temp * (x3-x1) + ((x1-x2) << 16)
;------------------------------------------------           
           moveq   #0,d1 
           move.w  ox3(a2),d1
           sub.w   ox1(a2),d1
           ext.l   d1
           muls.l  d0,d1             
           moveq   #0,d2           
           move.w  ox1(a2),d2
           sub.w   ox2(a2),d2
           swap.w  d2
           add.l   d2,d1 
           cmp.l   #-640*10*65535,d1
           ble     d_3            
           tst.l   d1
           bne.b ok_1
           moveq #1,d1
ok_1
;----------------------------------------------------------           
;           ( temp * (p3-p1) + ((p1-p2) << 16) ) << 10
;  delta p = --------------------------------------------
;                              width  
;----------------------------------------------------------           
;         d0 = temp
;         d1 = width
;-----------------------------------------------------------
;calc u
;----------------------------------------------------------
           moveq  #0,d2
           move.w xt3(pc),d2 
           sub.w  xt1(pc),d2
           ext.l  d2  
           muls.l d0,d2
           moveq  #0,d3
           move.w xt1(pc),d3
           sub.w  xt2(pc),d3
           swap.w d3
           add.l  d3,d2
           asl.l  #8,d2                     
           divs.l d1,d2                      
           move.l d2,_u3+2
;-----------------------------------------------------------
;calc y
;----------------------------------------------------------            
           moveq  #0,d2
           move.w yt3(pc),d2 
           sub.w  yt1(pc),d2
           ext.l  d2  
           muls.l d0,d2
           moveq  #0,d3
           move.w yt1(pc),d3
           sub.w  yt2(pc),d3
           swap.w d3
           add.l  d3,d2          
           asl.l  #8,d2
           divs.l d1,d2                     
           move.l d2,_v3+2          
           
           swap.w d1
           tst.w d1
           bpl.b width_ok
           neg.w d1                      
width_ok   
;-----------------------------------------------------------            
           ;-----------------------------;
           ;  make lookup table! on DSP! ;
           ;-----------------------------;
	   addq.w  #1,d1
	   move.w  d1,d5
	   lea     $fffffa204.w,a5
	   lea     lookup(pc),a3
	   move.l  d1,(a5)
_u3        move.l  #0,(a5)
_v3        move.l  #0,(a5)                   
           nop
mk_lookup  move.l  (a5),(a3)+
           nop
           dbf     d5,mk_lookup
           clr.l   (a3)+
;-----------------------------------------------------------                                           
           move.w  xt1(pc),xd1(a4)                    
           move.w  yt1(pc),yd1(a4)                    
           movem.l xd1(a4),d3-d6   
           lea     xd1(a4),a4                                             
           move.l  tyle+2(pc),d0
           cmp.l   mod10+2(pc),d0           
           blt.b   cipa           
           move.l  tyle+2(pc),d0
           move.l  mod10+2(pc),tyle+2
           move.l  d0,mod10+2                                  
           move.l  tyle2+2(pc),d0
           move.l  mod11+2(pc),tyle2+2
           move.l  d0,mod11+2                                             
           move.l  d_x2(pc),d0
           move.l  d_y2(pc),d1                                 
           move.l  d0,mod1+2
           move.l  d1,mod2+2             
           move.l  d0,mod5+2
           move.l  d1,mod6+2             
           bra.b   wporzo                                                             
cipa       move.l  d_x1(pc),mod1+2
           move.l  d_y1(pc),mod2+2
           move.l  d_x3(pc),mod5+2
           move.l  d_y3(pc),mod6+2  
wporzo:
;-----------------------------------------------------------           
           move.w  oy1(a2),d1          ;upper cliping 
           tst.w   d1
           bpl.b   reset_
           neg.w   d1
           bra.b   reset_jump
reset_     moveq   #0,d1     
reset_jump move.w  d1,d4      
;-----------------------------------------------------------
           move.w  oy1(a2),d0         ;buttom cliping
           move.w  oy2(a2),d1 
           move.w  oy3(a2),d2
           moveq   #99,d3           
           cmp.w   d3,d0
           bgt     d_3        
           cmp.w   d3,d1
           blt.b   oops_y3           
           sub.w   d3,d1                       
           sub.w   d1,d7           
oops_y3    cmp.w   d3,d2
           blt.b   dalej_szalej
           sub.w   d3,d2     
           swap.w  d7
           sub.w   d2,d7
           swap.w  d7      
dalej_szalej:
;-----------------------------------------------------------
           move.l  #out_put,d6                                          
           move.l  #lookup+4,d2
           subq.w  #1,d7
           bmi     d_2             
           
half_1     dbf     d4,tyle
           moveq   #0,d4
           
           move.l  a0,d0
           move.l  a1,d1                       
           swap.w  d0
           swap.w  d1                                                                                                                                                                                                                      
           
           cmpi.w  #384/2-1,d1
           blt.b   lucky_one 
           move.w   #384/2-1,d1  
lucky_one  move.l  d2,a5 
           tst.w   d0
           bpl.b   _lucky_1 
           neg.w   d0
           lea     (a5,d0.w*4),a5
           moveq   #0,d0
_lucky_1                        
           sub.w   d0,d1                                     
           bmi.b   inc_it_1
           lea     (a6,d0.w*4),a3                                                                                                                                                 
           move.l  d6,a2 
           swap.w  d3       ;initial u           
           lsr.l   #8,d5    ;initial v                                                               
           move.b  d3,d5  
           lea     (a2,d5.w*4),a2
           moveq   #0,d3
fill       move.l  (a2,d3.l),(a3)+                          
           move.l  (a5)+,d3                                                         
           dbf     d1,fill    
           
inc_it_1   add.w   #wide*2,a6                                                                                                                                                                                         
tyle       add.l   #0,a0 
mod10      add.l   #0,a1   
                                
mod1       add.l   #0,(a4)+
mod2       add.l   #0,(a4)                        
           move.l  (a4),d5
           move.l  -(a4),d3
                                                                                                                                                                                           
           dbf     d7,half_1                                                                                                                                                                           
           ;----------------           
           move.w  xt2(pc),xd1(a4)                                  
           move.w  yt2(pc),yd1(a4)
                                            
d_2        swap.w  d7   
           subq.w  #1,d7
           bmi.b   d_3     
                                                                                       
half_2     dbf     d4,tyle2
           moveq   #0,d4
           move.l  a0,d0
           move.l  a1,d1            
           swap.w  d0
           swap.w  d1                                                                                                                                                                                                                    
           
           cmpi.w  #384/2-1,d1
           blt.b   lucky_two
           move.w  #384/2-1,d1  
lucky_two            
           move.l  d2,a5 
           tst.w   d0
           bpl.b   _lucky_2 
           neg.w   d0
           lea     (a5,d0.w*4),a5
           moveq   #0,d0
_lucky_2             
           sub.w   d0,d1                                     
           bmi.b   inc_it_2
           lea     (a6,d0.w*4),a3                                                                                                                                     
           
           move.l  d6,a2 
           swap.w  d3       ;initial u           
           lsr.l   #8,d5    ;initial v           
           move.b  d3,d5                                                             
           lea     (a2,d5.w*4),a2
           moveq   #0,d3
fill2      move.l  (a2,d3.l),(a3)+                  
           move.l  (a5)+,d3                                                       
           dbf     d1,fill2    
           
inc_it_2   add.w   #wide*2,a6                                                                                                                                                                                        
tyle2      add.l   #0,a0 
mod11      add.l   #0,a1   
                     
mod5       add.l   #0,(a4)+
mod6       add.l   #0,(a4)
           move.l  (a4),d5
           move.l  -(a4),d3                                                                                                                                                                                                               
           
           dbf     d7,half_2                                                                                                                                                                           
d_3        rts 
;-------------------------------------------------------------                          
;-------------------------------------------------------------                          
;-------------------------------------------------------------                          
fitt       lea     save_ar(pc),a0
           move.w  d1,(a0)+
           move.w  d3,(a0)+
           move.w  d5,(a0)+
           move.w  d0,(a0)+
           move.w  d2,(a0)+
           move.w  d4,(a0)+
           
           move.l  d2,a3
           move.l  d3,a4
           move.l  d4,a5
           move.l  d5,a6             
;licz przyrost miedzy (x1,y1) a (x2,y2)
           lea     dane(pc),a0
           move.w  d0,d6
           sub.w   d0,d2
           sub.w   d1,d3
           move.w  d3,tem1(a0)
           bne.b   ok_zero_1_f            
           moveq   #1,d3   
ok_zero_1_f swap.w  d2           
           ext.l   d3
           divs.l  d3,d2                                                                
           move.l  d2,tyle_f+2
           move.w  d3,d7 
;licz przyrost miedzy (x1,y1) a (x3,y3)        
           sub.w   d0,d4
           sub.w   d1,d5
           move.w  d5,tem2(a0)               
           bne.b   ok_zero_2_f
           moveq   #1,d5                         
ok_zero_2_f  swap.w  d4
           ext.l   d5           
           divs.l  d5,d4                                      
           move.l  d4,mod10_f+2
           move.l  d4,mod11_f+2             
;licz przyrost miedzy (x2,y2) a (x3,y3)                                             
           move.l  a5,d4
           move.l  a6,d5              
           sub.w   a3,d4
           sub.w   a4,d5         
           bne.b   ok_zero_3_f
           moveq   #1,d5   
ok_zero_3_f  swap.w  d7           
           move.w  d5,d7
           swap.w  d7                                    
           swap.w  d4 
           ext.l   d5
           divs.l  d5,d4                                            
           move.l  d4,tyle2_f+2                         
;-----------------------------------------                          
           move.l  scren_p(pc),a6            
           lea     adr_yt,a5                                                                                                       
           tst.w   d1
           bpl.b   y_is_ok_f 
           moveq   #0,d1    
y_is_ok_f  add.l   (a5,d1.w*4),a6                                                                                                                                                                                         
           move.l  a0,a4 
           swap.w  d0                      
           move.l  d0,a0
           move.l  d0,a1                                  
           moveq   #0,d0
           moveq   #0,d1          
                    
           move.w  tem1(a4),d3
           move.w  tem2(a4),d4                                                                                
           ext.l   d3
           ext.l   d4
           ***** 
           move.w  xt2(pc),d0
           sub.w   xt1(pc),d0                                                        
           swap.w  d0
           divs.l  d3,d0                        
           move.l  d0,d_x1
           *****      
           move.w  xt3(pc),d0
           sub.w   xt1(pc),d0                                                
           swap.w  d0
           divs.l  d4,d0                        
           move.l  d0,d_x2           
           *****        
           move.w  xt3(pc),d0
           sub.w   xt2(pc),d0                                    
           swap.w  d0            
           divs.l  d5,d0                                             
           move.l  d0,d_x3
           *****       
           move.w  yt2(pc),d0
           sub.w   yt1(pc),d0                                    
           swap.w  d0           
           divs.l  d3,d0                                    
           move.l  d0,d_y1
           *****                    
           move.w  yt3(pc),d0
           sub.w   yt1(pc),d0                                             
           swap.w  d0
           divs.l  d4,d0                       
           move.l  d0,d_y2           
           *****                     
           move.w  yt3(pc),d0
           sub.w   yt2(pc),d0                                  
           swap.w  d0            
           divs.l  d5,d0                        
           move.l  d0,d_y3
           *****                                                                            
;---------------------------------                      
           moveq   #0,d0
           moveq   #0,d1           
           lea     save_ar(pc),a2 
;------------------------------------------------           
;                   (y2-y1) << 16
;          temp = --------------
;                      y3-y1
;------------------------------------------------                      
           move.w  oy2(a2),d0
           sub.w   oy1(a2),d0 
           swap.w  d0
           move.w  oy3(a2),d1
           sub.w   oy1(a2),d1
           ext.l   d1
           tst.l   d1
           bne.b   div_ok_01_f
           moveq   #1,d1  
div_ok_01_f  divs.l  d1,d0 
;------------------------------------------------           
;    width = temp * (x3-x1) + ((x1-x2) << 16)
;------------------------------------------------           
           moveq   #0,d1 
           move.w  ox3(a2),d1
           sub.w   ox1(a2),d1
           ext.l   d1
           muls.l  d0,d1             
           moveq   #0,d2           
           move.w  ox1(a2),d2
           sub.w   ox2(a2),d2
           swap.w  d2
           add.l   d2,d1 
           cmp.l   #-640*10*65535,d1
           ble     d_3_f            
           tst.l   d1
           bne.b ok_1_f
           moveq #1,d1
ok_1_f
;----------------------------------------------------------           
;           ( temp * (p3-p1) + ((p1-p2) << 16) ) << 10
;  delta p = --------------------------------------------
;                              width  
;----------------------------------------------------------           
;         d0 = temp
;         d1 = width
;-----------------------------------------------------------
;calc u
;----------------------------------------------------------
           moveq  #0,d2
           move.w xt3(pc),d2 
           sub.w  xt1(pc),d2
           ext.l  d2  
           muls.l d0,d2
           moveq  #0,d3
           move.w xt1(pc),d3
           sub.w  xt2(pc),d3
           swap.w d3
           add.l  d3,d2
           asl.l  #8,d2                     
           divs.l d1,d2                      
           move.l d2,_u3_f+2
;-----------------------------------------------------------
;calc y
;----------------------------------------------------------            
           moveq  #0,d2
           move.w yt3(pc),d2 
           sub.w  yt1(pc),d2
           ext.l  d2  
           muls.l d0,d2
           moveq  #0,d3
           move.w yt1(pc),d3
           sub.w  yt2(pc),d3
           swap.w d3
           add.l  d3,d2          
           asl.l  #8,d2
           divs.l d1,d2                     
           move.l d2,_v3_f+2          
           
           swap.w d1
           tst.w d1
           bpl.b width_ok_f
           neg.w d1                      
width_ok_f   
;-----------------------------------------------------------            
           ;-----------------------------;
           ;  make lookup table! on DSP! ;
           ;-----------------------------;
	   move.w  d1,d5
	   lea     $fffffa204.w,a5
	   lea     lookup(pc),a3
	   move.l  d1,(a5)
_u3_f      move.l  #0,(a5)
_v3_f      move.l  #0,(a5)                   
           nop
mk_lookup_f move.l  (a5),(a3)+
           nop
           dbf     d5,mk_lookup_f
           clr.l   (a3)+
;-----------------------------------------------------------                                           
           move.w  xt1(pc),xd1(a4)                    
           move.w  yt1(pc),yd1(a4)                    
           movem.l xd1(a4),d3-d6   
           lea     xd1(a4),a4                                             
           move.l  tyle_f+2(pc),d0
           cmp.l   mod10_f+2(pc),d0           
           blt.b   cipa_f           
           move.l  tyle_f+2(pc),d0
           move.l  mod10_f+2(pc),tyle_f+2
           move.l  d0,mod10_f+2                                  
           move.l  tyle2_f+2(pc),d0
           move.l  mod11_f+2(pc),tyle2_f+2
           move.l  d0,mod11_f+2                                             
           move.l  d_x2(pc),d0
           move.l  d_y2(pc),d1                                 
           move.l  d0,mod1_f+2
           move.l  d1,mod2_f+2             
           move.l  d0,mod5_f+2
           move.l  d1,mod6_f+2             
           bra.b   wporzo_f                                                             
cipa_f     move.l  d_x1(pc),mod1_f+2
           move.l  d_y1(pc),mod2_f+2
           move.l  d_x3(pc),mod5_f+2
           move.l  d_y3(pc),mod6_f+2  
wporzo_f
;-----------------------------------------------------------           
           move.l  #out_put,d6                                          
           move.l  #lookup+4,d2
           subq.w  #1,d7
           bmi     d_2_f             
           
half_1_f                         
           move.l  a0,d0
           move.l  a1,d1                       
           swap.w  d0
           swap.w  d1                                                                                                                                                                                                                      
                      
           sub.w   d0,d1                                     
           bmi.b   inc_it_1_f
           lea     (a6,d0.w*4),a3                                                                                                                                                 
           move.l  d2,a5 
           move.l  d6,a2 
           swap.w  d3       ;initial u           
           lsr.l   #8,d5    ;initial v                                                               
           move.b  d3,d5  
           lea     (a2,d5.w*4),a2
           moveq   #0,d4
fill_f     move.l  (a2,d4.l),(a3)+                          
           move.l  (a5)+,d4                                                         
           dbf     d1,fill_f    
           
inc_it_1_f add.w   #wide*2,a6                                                                                                                                                                                         
tyle_f     add.l   #0,a0 
mod10_f    add.l   #0,a1   
                                
mod1_f     add.l   #0,(a4)+
mod2_f     add.l   #0,(a4)                        
           move.l  (a4),d5
           move.l  -(a4),d3
                                                                                                                                                                                           
           dbf     d7,half_1_f                                                                                                                                                                           
           ;----------------           
           move.w  xt2(pc),xd1(a4)                                  
           move.w  yt2(pc),yd1(a4)
                                            
d_2_f      swap.w  d7   
           subq.w  #1,d7
           bmi.b   d_3_f     
                                                                                       
half_2_f              
           move.l  a0,d0
           move.l  a1,d1            
           swap.w  d0
           swap.w  d1                                                                                                                                                                                                                    
                      
           sub.w   d0,d1                                     
           bmi.b   inc_it_2_f
           lea     (a6,d0.w*4),a3                                                                                                                                                
           move.l  d2,a5 
           move.l  d6,a2 
           swap.w  d3       ;initial u           
           lsr.l   #8,d5    ;initial v           
           move.b  d3,d5                                                             
           lea     (a2,d5.w*4),a2
           moveq   #0,d4
fill2_f    move.l  (a2,d4.l),(a3)+                  
           move.l  (a5)+,d4                                                       
           dbf     d1,fill2_f    
           
inc_it_2_f add.w   #wide*2,a6                                                                                                                                                                                        
tyle2_f    add.l   #0,a0 
mod11_f    add.l   #0,a1   
                     
mod5_f     add.l   #0,(a4)+
mod6_f     add.l   #0,(a4)
           move.l  (a4),d5
           move.l  -(a4),d3                                                                                                                                                                                                               
           
           dbf     d7,half_2_f                                                                                                                                                                           
d_3_f      rts 
;-----------------------------------------------------------
dod  dc.l 0
dod1 dc.l 0	
sav_sp	dc.l 0
old_vbl dc.l 0
ad_x dc.w 0
ad_y dc.w 0
ad_z dc.w 0
u       ds.l 1
v       dc.l 1
x1      dc.l 350
x2      dc.l 150
x3      dc.l 220
y1      dc.l 59
y2      dc.l 0
y3      dc.l 110
k3      dc.w 0
k2      dc.w 31
k1      dc.w 0
d_x1    dc.l 0
d_x2    dc.l 0
d_x3    dc.l 0
d_y1    dc.l 0
d_y2    dc.l 0
d_y3    dc.l 0
width   dc.w 0
next_nomber dc.w 0
;------------------------------------------
xt1      dc.w 0
xt2      dc.w 128/3
xt3      dc.w 0

yt1      dc.w 0
yt2      dc.w 0
yt3      dc.w 128/3
;------------------------------------------
save_ar  ds.l 32
dane    ds.l 64*2 
rx12    = 0
rx13    = 4
rx23    = 8
ry12    = 12
ry13    = 16
ry23    = 20
x11     = 24
x12     = 28  

xd1     = 32
yd1     = 36  

dx12    = 48
dx13    = 52
dx23    = 56
tem1    = 60
tem2    = 64
tem3    = 68



color   dc.w $ff
scren_l     dc.l 	$3ca000
scren_p     dc.l 	$3ca000-256*152*2 

mode dc.w 0	     
od_m dc.w 0
point  ds.b 1
       even
;-------------------------------------------------
DSPbin.start  
       incbin d:\lookup.p56
DSPbin.end            
;--------------------------------------------------
output__    ds.w 100*6
output__2    ds.w 100*6
;--------------------------------------------------
actual      dc.l box
;--------------------------------------------------             
    EVEN        
fnormals ds.w 256*5
pnormals ds.w 256*5
rot_norms ds.w 256*5
rot_norms2 ds.w 256*5
zety ds.w 256*5    
to_sort ds.w 256*5
kolej ds.w 256*5
        ds.w 1000
lookup  ds.l 640*10
;------------------------------------
  ;Tri-mesh, Vertices: 22     Faces: 40
box     
      dc.w  14
      dc.w  25
box_z dc.w  1150
      dc.w 14*2*3
      dc.w -500,500,500
      dc.w -500,-500,500
      dc.w 500,-500,500
      dc.w 500,500,500
to_b1 dc.w 0,0,900
      dc.w 500,500,-500
      dc.w 500,-500,-500
to_b2 dc.w 0,0,-900
      dc.w -500,500,-500
      dc.w -500,-500,-500
to_b3 dc.w -900,0,0 
to_b4 dc.w 0,900,0
to_b5 dc.w 0,-900,0     
to_b6 dc.w 900,0,0    
fejsy dc.w 0,1,4,$1234
      dc.w 4,1,2,$4355
      dc.w 3,4,2,$5545
      dc.w 0,4,3,$3454      ;1st face         
      dc.w 3,2,13,$3453
      dc.w 13,2,6,$3453
      dc.w 3,13,5,$3442
      dc.w 5,13,6,$1235     ;next face      
      dc.w 5,6,7,$3467
      dc.w 5,7,8,$6578
      dc.w 8,7,9,$4564
      dc.w 7,6,9,$2368       ;next face              
      dc.w 8,9,10,$0345
      dc.w 8,10,0,$0034
      dc.w 0,10,1,$0346
      dc.w 9,1,10,4      ;next face      
      dc.w 8,0,11,1 
      dc.w 11,0,3,2
      dc.w 11,3,5,3
      dc.w 11,5,8,4      ;next face       
      dc.w 1,9,12,1
      dc.w 12,9,6,2
      dc.w 12,6,2,3
      dc.w 12,2,1,4
     ds.w 100              
;----------------------------------------------
sin:
       dc.w 1,-5,-12,-18,-24,-30,-37,-43
       dc.w -49,-55,-61,-67,-73,-79,-85,-91
       dc.w -97,-103,-108,-114,-120,-125,-131,-136
       dc.w -141,-146,-151,-156,-161,-166,-171,-176
       dc.w -180,-184,-189,-193,-197,-201,-205,-208
       dc.w -212,-215,-219,-222,-225,-228,-230,-233
       dc.w -236,-238,-240,-242,-244,-246,-247,-249
       dc.w -250,-252,-252,-253,-254,-254,-255,-255
       dc.w -255,-255,-255,-254,-254,-253,-252,-251
       dc.w -250,-249,-247,-246,-244,-242,-240,-238
       dc.w -236,-233,-230,-228,-225,-222,-219,-215
       dc.w -212,-208,-205,-201,-197,-193,-189,-184
       dc.w -180,-176,-171,-166,-161,-156,-151,-146
       dc.w -141,-136,-131,-125,-120,-114,-108,-103
       dc.w -97,-91,-85,-79,-73,-67,-61,-61,-55
       dc.w -49,-43,-37,-30,-24,-18,-12,-5
       dc.w 1,6,13,25,31,38,44
       dc.w 50,56,62,68,74,80,86,92
       dc.w 97,103,108,114,120,125,131,136
       dc.w 141,146,151,156,161,166,171,176
       dc.w 180,184,189,193,197,201,205,208
       dc.w 212,215,219,222,225,228,230,233
       dc.w 236,238,240,242,244,246,247,249
       dc.w 250,252,252,253,254,254,255,255
       dc.w 255,255,255,254,254,253,252,251
       dc.w 250,249,247,246,244,242,240,238
       dc.w 236,233,230,228,225,222,219,215
       dc.w 212,208,205,201,197,193,189,184
       dc.w 180,176,171,166,161,156,151,146
       dc.w 141,136,131,125,120,114,108,103
       dc.w 97,91,85,79,73,67,61,61,55
       dc.w 49,43,37,30,24,18,12,5 
       rept 32
       dc.w 1
       endr
       
cos    
       dc.w 256,256,256,255,255,254,253,252
       dc.w 251,250,248,247,245,243,241,239
       dc.w 237,234,231,229,226,223,220,216
       dc.w 213,209,206,202,198,194,190,185
       dc.w 181,177,172,167,162,157,152,147
       dc.w 142,137,132,126,121,115,109,104
       dc.w 98,92,86,80,74,68,62,56
       dc.w 50,44,38,31,25,19,13,6
       dc.w 1,-5,-12,-18,-24,-30,-37,-43
       dc.w -49,-55,-61,-67,-73,-79,-85,-91
       dc.w -97,-103,-108,-114,-120,-125,-131,-136
       dc.w -141,-146,-151,-156,-161,-166,-171,-176
       dc.w -180,-184,-189,-193,-197,-201,-205,-208
       dc.w -212,-215,-219,-222,-225,-228,-230,-233
       dc.w -236,-238,-240,-242,-244,-246,-247,-249
       dc.w -250,-251,-252,-253,-254,-254,-255,-255
       dc.w -255,-255,-255,-254,-254,-253,-252,-251
       dc.w -250,-249,-247,-246,-244,-242,-240,-238
       dc.w -236,-233,-230,-228,-225,-222,-219,-215
       dc.w -212,-208,-205,-201,-197,-193,-189,-184
       dc.w -180,-176,-171,-166,-161,-156,-151,-146
       dc.w -141,-136,-131,-125,-120,-114,-108,-103
       dc.w -97,-91,-85,-79,-73,-67,-61,-55
       dc.w -49,-43,-37,-30,-24,-18,-12,-5
       dc.w 1,6,13,19,25,31,38,44
       dc.w 50,56,62,68,74,80,86,92
       dc.w 98,104,109,115,121,126,132,137
       dc.w 142,147,152,158,162,167,172,177
       dc.w 181,185,190,194,198,202,206,209
       dc.w 213,216,220,223,226,229,231,234
       dc.w 237,239,241,243,245,247,248,250
       dc.w 251,252,253,254,255,256,256,256
       rept 32
       dc.w 256
       endr
       even 
;-----------------------------                  
;tablica  rept 128*3
;         dc.w 0
;         endr      
;_----------------------------
         ds.w 100
adr_yt   ds.l 300*10      
mov_sin_1 incbin d:\sinus\v_sin.prg
mov_sin_2 incbin d:\sinus\g_sin.prg       
pic       incbin d:\hohoho\mess2.565
          even   
          section bss
          even
green2   ds.w 128*2              
out_put  ds.l 256*256