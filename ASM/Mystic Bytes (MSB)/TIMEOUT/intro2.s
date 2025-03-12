	    cmp.w	#1,d0
	    beq.b	prepare_table

	    move.l 	sp,sav_sp
;--------------------------------------------------            
	    lea		$3ca000,a0
	    move.w	#384*2*100/4-1,d7
	    moveq	#0,d0
clr_it	    move.l	d0,(a0)+
	    dbf		d7,clr_it	     
	    
	    lea		$3ca000-256*149*2,a0
	    move.w	#384*2*100/4-1,d7
	    moveq	#0,d0
clr_it2	    move.l	d0,(a0)+
	    dbf		d7,clr_it2	     

	    move.l 	#$3ca000,d0
            lsr.w 	#8,d0
            move.l 	d0,$ffff8200.w                               
	    

	    move.w	#37,-(sp)
	    trap 	#14
	    addq.l 	#2,sp

	    
	    
	    moveq	#5,d0
	    trap	#4	    	    
wait_music	    
	    moveq	#4,d0
	    trap	#4
	    cmp.w	#5,d0
	    bne.b	wait_music
	    bra         yeah
;--------------------------------------------------                        
prepare_table	    lea 	pic,a0
	    lea 	out,a1
	    lea 	out2,a3
	    moveq 	#0,d0
	    move.w 	#256-1,d6
sec 	    move.w 	#256-1,d7
fir 	    move.w 	(a0)+,d0
 	    move.w 	d0,(a1)+
 	    move.w 	d0,(a3)+
 	    move.w 	d0,(a1)+
 	    move.w 	d0,(a3)+
            dbf    	d7,fir
            dbf 	d6,sec 
;--------------------------------------------------                                   
 	    lea 	offs,a0
 	    move.w 	#320*200/2-1,d7
he	    move.l 	(a0),d0  	               
	    swap.w 	d0	
	    move.l 	d0,(a0)+
	    dbf 	d7,he	    
	    rts
;--------------------------------------------------                                    
yeah
            moveq 	#0,d0
            lea 	sinus2+2(pc),a1           
            lea 	sinus+2(pc),a0           
            move.b 	pointer+1(pc),d0
            moveq 	#0,d1
            move.b 	(a1,d0.w),d1           
            lsr.b 	#1,d1            
            and.w 	#$ff,d1
            cmp.b 	#100,d1
            blt.b 	lo
            moveq 	#100,d1
lo          move.w 	d1,ly                                    
            moveq 	#0,d1
            move.b 	(a0,d0.w),d1           
            lsr.b 	#2,d1	
            move.w 	d1,lx
;----------------------------------------------------------               
            addq.w 	#4,pointer
            and.w 	#$ff,pointer
;----------------------------------------------------------               
	    move.l 	scren_p(pc),a0
	    lea    	offs(pc),a1
	    lea    	out+256*4*128,a2
	    move.l 	aaa(pc),d0
	    lsl.l 	#2,d0
	    add.l  	d0,a2
	    moveq 	#0,d0
	    move.l  	#320*2-192*2,a3	    
	    moveq  	#0,d1
	    moveq  	#0,d2
	    move.w 	ly(pc),d1
	    mulu   	#320*2,d1
	    move.w 	lx(pc),d2
	    lsl.w  	#2,d2
	    add.w  	d2,d1
	    lea    	(a1,d1.l),a1		
	    moveq   	#50*2-1,d6	    
line	    move.w  	#192/2/8-1,d7
mk_tunn     rept 	8 
            move.l 	(a1)+,d0
 	    move.l 	(a2,d0.w*4),(a0)+
 	    swap.w 	d0
 	    move.l 	(a2,d0.w*4),(a0)+
 	    endr  
 	    dbf 	d7,mk_tunn 
 	    add.l 	a3,a1       
 	    dbf 	d6,line 
;----------------------------------------------------------               
            tst.b	check
            bne.b	it_wos

	    moveq	#4,d0
	    trap	#4
	    cmp.w	#9,d0
	    bne 	chuj_ci
	    st.b	check
;----------------------------------------------------------               
it_wos	    move.l 	scren_p(pc),a0
	    lea    	offs2,a1
	    lea    	out+256*4*128,a2
	    move.l 	aaa(pc),d0
	    lsl.l 	#2,d0
	    add.l  	d0,a2
	    moveq 	#0,d0
	    move.l  	#320*2-192*2,a3	    
	    moveq  	#0,d1
	    moveq  	#0,d2
	    move.w 	ly(pc),d1
	    mulu   	#320*2,d1
	    move.w 	lx(pc),d2
	    lsl.w  	#2,d2
	    add.w  	d2,d1
	    lea    	(a1,d1.l),a1		
	    moveq   	#50*2-1,d6	    
line2	    move.w  	#192/2/8-1,d7
mk_tunn2     rept 	8 
            move.l 	(a1)+,d0
 	    move.l 	(a2,d0.w*4),(a0)+
 	    swap.w 	d0
 	    move.l 	(a2,d0.w*4),(a0)+
 	    endr  
 	    dbf 	d7,mk_tunn2 
 	    add.l 	a3,a1       
 	    dbf 	d6,line2 
;----------------------------------------------------------               
chuj_ci
	    move.l 	scren_p,d0
            move.l 	scren_l,scren_p
            move.l 	d0,scren_l
            lsr.w 	#8,d0
            move.l 	d0,$ffff8200.w                               
            add.l 	#259+11,aaa
            and.l 	#$ffff,aaa            
            cmp.b 	#1,$ffffffc02.w
            bne 	yeah                        
;----------------------------------------------------------                                     
	    move.l 	sav_sp,sp
	    rts
;----------------------------------------------------------                                               
mode        dc.w 	0   
aaa 	    ds.l 	1	
sav_sp	    ds.l	1
pointer	    dc.w 	1
lx	    ds.w 	1
ly	    ds.w 	1	    
check	    ds.b	1
	    even
scren_l     dc.l 	$3ca000
scren_p     dc.l 	$3ca000-256*149*2 
sinus2      incbin 	d:\sinus\a_sin.prg   
sinus  	    incbin 	d:\sinus\b_sin.prg   
offs	    incbin 	d:\hohoho\stargate.dat
offs2	    incbin 	d:\well.dat
pic         incbin 	d:\hohoho\mess2.565
	    section 	bss
out 	    ds.l 	256*256
out2 	    ds.l 	256*256                
