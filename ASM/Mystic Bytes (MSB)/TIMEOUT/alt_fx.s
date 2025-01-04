            include  d:\macrodsp.s                          
            
            clr.l	-(sp)
            move.w	#$20,-(sp)
            trap	#1
            addq.l	#6,sp
            
            move.w #$24,d0            
            move.w  d0,-(a7)
            move.w  #3,-(a7)                ;VsetMode option
            pea     $3ca000
            pea     $3ca000
            move.w  #5,-(a7)
            trap    #14
            lea     14(a7),a7
            move.w d0,mode
            
            move.w #%0001,$ffff82c2.w
            move.w #20+10,$ffff8288.w 
            move.w #180,$ffff828a.w 
            move.w #170-35,$ffff82a8.w            
            move.w #550-35+2,$ffff82aa.w
            move.w #wide,$ff8210   
            
            clr.l	$ffff9800.w
wide        = 384

        	Dsp_ExecProg	#DSPbin.start,#(DSPbin.end-DSPbin.start)/3,#'NC'                            
;------------------------------------                        
	    lea pic,a0
	    lea out,a1
	    lea out2,a3
	    moveq #0,d0
	    move.w #256-1,d6
sec 	    move.w #256-1,d7
fir 	    move.w (a0)+,d0
 	    not.w	d0
 	    ;------------------
 	    move.w d0,d1
 	    move.w d0,d3 	    
 	    and.w #%011111,d0 	    
 	    lsr.w #5,d1
 	    and.w #%111111,d1 	    
 	    lsr.w #8,d3
 	    lsr.w #3,d3
 	    and.w #%011111,d3
 	    ;------------------
 	    
 	    addq.l #1,a1
 	    move.b d0,(a1)+
 	    move.b d1,(a1)+
 	    move.b d3,(a1)+
 	    
 	    addq.l #1,a3 	    
 	    move.b d0,(a3)+ 	     	     	    
 	    move.b d1,(a3)+
 	    move.b d3,(a3)+
 	    
            dbf    d7,fir
            dbf d6,sec 
;--------------------------------------------------                                
            lea   white,a0
            moveq #0,d0
            moveq #0,d4
            moveq #0,d5
            moveq #63-1,d7
white_pal   
            move.w d0,(a0)+
            move.w d0,(a0)+
            addq.w #1,d0
            dbf d7,white_pal
            move.w #182*2,d7
rep         move.w d0,(a0)+
            move.w d0,(a0)+
            dbf d7,rep
;------------------------------------------------                                                
	    lea offs,a1
	    lea offs2,a2
	    lea light,a0
	    move.w #320*200-1,d7
ddd	    move.b (a0)+,d0
            lsr.b #1,d0
            move.w (a1)+,(a2)+
            move.w d0,(a2)+            
            dbf d7,ddd	  
;--------------------------------------------------                                   
	    
;--------------------------------------------------                                    
yeah
            moveq #0,d0
            moveq #0,d4
            lea sinus2+2(pc),a1           
            lea sinus+2(pc),a0           
            lea sinus3+2,a2
            move.b pointer+1(pc),d0
            move.b pointer2+1(pc),d4
            
            ;lsr.b d0
            moveq #0,d1
            move.b (a1,d0.w),d1           
            lsr.b #1,d1            
            and.w #$ff,d1
            ;add.w #20-2,d1
            
            cmp.b #100,d1
            blt.b lo
            moveq #100,d1
lo          move.w d1,ly                        
            
            moveq #0,d1
            move.b (a0,d0.w),d1           
            lsr.b #2,d1
            ;and.w  #$ff,d1
            move.w d1,lx
            moveq #0,d0
            move.b (a2,d4.w),d0
            ;move.w d0,li 
            ;-----------------------
            addq.w #2,pointer
            and.w #$ff,pointer
            add.w #8*2,pointer2
            and.w #$ff,pointer2
;------------------------------------                                    
;     Tu jest glowna procedura....
;
;
;------------------------------------                                    
	    move.l scren_p,a0
	    sub.l	#12,a0
	    lea    offs2,a1
	    lea    out+256*4*128,a2
	  
	    
	    move.l aaa,d0
	    lsl.l #2,d0
	    add.l  d0,a2
	    moveq #0,d0
	    moveq  #0,d1
	    moveq  #0,d2
	    move.w ly,d1
	    mulu   #320*4,d1
	    move.w lx,d2
	    ;lsl.w  #2,d2
	    mulu #4,d2
	    add.w  d2,d1
	    lea    (a1,d1.l),a1
	    
		
            ;--------------------------------
            move.l	#$123456,$ffffa204.w
            ;--------------------------------
            move.w li(pc),d0	    
	    
	    move.l	d0,$ffffa204.w
	    	                
            lea		$fffffa204.w,a6
            lea		$fffffa206.w,a4
	    lea		$fffffa207.w,a5
	    moveq	#0,d3
	    moveq   #50*2-1,d6	    
line	    move.w  #192-1,d7
mk_tunn    
            move.w 	(a1)+,d5 	  	    
 	    move.w 	(a1)+,(a4)
 	    move.l 	(a2,d5.w*4),(a6)    	     	    
 	    nop
 	    nop 	     	    
	    move.w	(a4),d0
            move.w 	d0,(a0)+ 
            move.w 	d0,(a0)+  	    
 	    dbf 	d7,mk_tunn 
 	    
 	    add.l #320*4-192*4,a1       
 	    
 	    dbf d6,line 


	    move.l scren_p,d0
            move.l scren_l,scren_p
            move.l d0,scren_l
            lsr.w #8,d0
            move.l d0,$ffff8200.w                   
            
            add.l #256+4,aaa
            and.l #$ffff,aaa
            
            clr.w -(sp)
            pea name
            move.w #$3c,-(sp)
            trap #1
            addq.l #8,sp
            
            move.l	scren_p(pc),-(sp)
            move.l #384*2*100,-(sp)
            move.w d0,-(sp)
            move.w #$40,-(sp)
            trap #1
            lea 12(sp),sp
            
            
            ;cmp.b #1,$ffffffc02.w
            ;bne yeah
            
                        
                        
;------------------------------------               
                      
            move.w  mode,-(a7)
            move.w  #3,-(a7)                ;VsetMode option
            pea     -1
            pea     -1
            move.w  #5,-(a7)
            trap    #14
            lea     14(a7),a7
                                                          
            clr.l -(sp)
            trap #1 
;-------------------------------           
mode        dc.w 0   
;---------------------------------------------------------------------------
aaa 	    ds.l 1
pointer	    dc.w 1
pointer2    dc.w 1
lx	    ds.w 1
ly	    ds.w 1	    
li	    dc.w 100
scren_p     dc.l $3ca000
scren_l     dc.l $3ca000-256*149*2 
name	    dc.b "d:\town.565",0
	    even
DSPbin.start  
       incbin d:\light_05.p56
DSPbin.end       
sinus2  incbin d:\sinus\e_sin.prg   
sinus3  incbin d:\sinus\a_sin.prg   
sinus  incbin d:\sinus\k_sin.prg   
offs	    incbin d:\ra.dat
pic         incbin d:\hohoho\mess2.565
light       incbin d:\f2.img
	    section bss
            ds.l 256
white	    ds.l 256*4
            ds.l 256*4

steps_blue  ds.w 256*2
steps_red   ds.w 256*2
steps_green ds.w 256*2 
            
out 	    ds.l 256*256
out2 	    ds.l 256*256                
offs2 	    ds.b 320*200*3