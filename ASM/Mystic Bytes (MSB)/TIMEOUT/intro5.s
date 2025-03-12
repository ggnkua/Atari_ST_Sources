    	    output	m2.dat
	    
	    cmp.w	#1,d0
	    beq.b	prepare_table

	    move.l 	sp,sav_sp
;--------------------------------------------------            
	    lea		$3ca000,a0
	    move.w	#384*2*100/4-1,d7
	    moveq	#0,d0
clr_it	    move.l	d0,(a0)+
	    dbf		d7,clr_it	     
	    
	    lea		$3ca000-256*152*2,a0
	    move.w	#384*2*100/4-1,d7
	    moveq	#0,d0
clr_it2	    move.l	d0,(a0)+
	    dbf		d7,clr_it2	     

	    move.l 	#$3ca000,d0
            lsr.w 	#8,d0
            move.l 	d0,$ffff8200.w                               
	    
	    bclr	#0,$fffffa13.w
	    move.w	#37,-(sp)
	    trap 	#14
	    addq.l 	#2,sp
	    	    	    
	    moveq	#5,d0
	    trap	#4	    	
	    bset	#0,$fffffa13.w    
	    
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
	    
	    lea 	offs2,a0
 	    move.w 	#320*200/2-1,d7
he2	    move.l 	(a0),d0  	               
	    swap.w 	d0	
	    move.l 	d0,(a0)+
	    dbf 	d7,he2	    
	    
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
	    tst.b	skip_f
	    bne		yeep_skip
	    
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
	    
	    moveq	#0,d0
	    move.w	how_many,d0
	    mulu	#320*2,d0
	    add.l	d0,a1
	    moveq	#0,d0
	    move.w	how_many,d0
	    mulu	#384*2,d0
	    add.l	d0,a0 
	    
	    move.w   	how_2(pc),d6	    
	    tst.w	d6
	    bpl.b	line
	    moveq	#0,d6	    	    
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
yeep_skip   tst.b	check
            bne.b	it_wos

	    moveq	#4,d0
	    trap	#4
	    cmp.w	#9,d0
	    bne 	chuj_ci
	    st.b	check
;----------------------------------------------------------               
it_wos	    cmp.w	#100,how_many
 	    ble.b	yeep
            st.b	skip_f 	    
 	    bra.b	skip_ad
 	    move.w	#99,how_many
 	    
yeep        add.w 	#10,how_many
	    sub.w 	#10,how_2
skip_ad
	    move.l 	scren_p(pc),a0
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
	    move.w   	how_many(pc),d6	    
	    subq.w	#1,d6
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
 	    tst.b	skip_f
	    beq		chuj_ci
	    
	    move.l	tab_p,a0
	    
	    move.w	(a0)+,d2
	    move.w	(a0)+,d3
	    
	    moveq	#4,d0
	    trap	#4
	    cmp.w	d2,d0
	    blt		chuj_ci
	    
	    cmp.w	d3,d1
	    ble		chuj_ci
	    
	    cmp.w	#12,d2
	    bne.b	eee
	    cmp.w	#0,d3
	    bne		r
	    	    
eee	    move.l	a0,a6	  
	    
	    lea		sinus2+2,a0
 	    moveq	#0,d0
 	    moveq	#0,d1
 	    move.b	pointer2(pc),d1
 	    move.b	(a0,d1.w),d0
 	    sub.l	#60*2,d0
 	    asl.l	d0
 	    
 	    move.l	d0,scroler
 	    
 	    moveq	#0,d0 
 	    move.b	(a0,d1.w),d0
 	    not.b	d0
 	    add.l	#90*2,d0
 	    asl.l	d0 	    
 	    move.l	d0,scroler2
 	    
 	    cmp.b	#249,pointer2
 	    bhs		chuj_ci_2
 	    add.b	#9,pointer2
 	    
	    
	    move.l	scren_p(pc),a1
	    move.l	(a6)+,a0
	    move.l	scroler,d0	    
	    bsr		bob2
	    
	    move.l	scren_p(pc),a1
	    add.l	#384*2*(100-45),a1
	    move.l	(a6)+,a0
	    move.l	scroler2,d0	    
	    bsr		bob1
	    bra.b	chuj_ci 
chuj_ci_2   addq.l	#4+4,a6	    
	    move.l	a6,tab_p
	    
	    clr.b	pointer2
 	    
;----------------------------------------------------------               
chuj_ci	    
	    bra.b	not_end

r	    bra		end	
		    
not_end	    move.l 	scren_p,d0
            move.l 	scren_l,scren_p
            move.l 	d0,scren_l
            lsr.w 	#8,d0
            move.l 	d0,$ffff8200.w                               
            add.l 	#258+10,aaa
            and.l 	#$ffff,aaa            
            cmp.b 	#1,$ffffffc02.w
            bne 	yeah                        
;----------------------------------------------------------                                     
end	    move.l 	sav_sp,sp
	    rts
;----------------------------------------------------------                                     	    
bob1	    move.l	a1,a2
	    lea		384*2-2(a2),a3
	    move.l	#384*2,a4	    
	    move.l	#384*2-90*4,a5
	    add.l	d0,a1
	    	    
	    move.w	#45-1,d6
line_it_4   moveq	#90-1,d7	    
clr_it4	    move.w	(a0)+,d0
	    beq.b	clear_pix			
	    
	    cmp.l	a1,a2
	    bge.b	clear_pix
	    cmp.l	a1,a3
	    ble.b	clear_pix
	    
	    move.w	d0,(a1)
	    move.w	d0,2(a1)
clear_pix   addq.l	#4,a1	    
	    dbf		d7,clr_it4
	    add.l	a5,a1
	    add.l	a4,a2
	    add.l	a4,a3
	    dbf 	d6,line_it_4 	    
	    rts
;----------------------------------------------------------                                     	    
bob2	    move.l	a1,a2
	    lea		384*2-2(a2),a3
	    move.l	#384*2,a4	    
	    move.l	#384*2-60*4,a5
	    add.l	d0,a1
	    	    
	    move.w	#30-1,d6
line_it_42  moveq	#60-1,d7	    
clr_it42    move.w	(a0)+,d0
	    beq.b	clear_pix2			
	    
	    cmp.l	a1,a2
	    bge.b	clear_pix2
	    cmp.l	a1,a3
	    ble.b	clear_pix2
	    
	    move.w	d0,(a1)
	    move.w	d0,2(a1)
clear_pix2   addq.l	#4,a1	    
	    dbf		d7,clr_it42
	    add.l	a5,a1
	    add.l	a4,a2
	    add.l	a4,a3
	    dbf 	d6,line_it_42 	    
	    rts	    
;----------------------------------------------------------                                               
mode        dc.w 	0   
aaa 	    ds.l 	1	
sav_sp	    ds.l	1
scroler	    dc.l 	0
scroler2    dc.l 	0
pointer	    dc.w 	1
lx	    ds.w 	1
ly	    ds.w 	1	    
how_many    dc.w	1
how_2	    dc.w	99
raws	    dc.w	0
check	    ds.b	1
skip_f	    ds.b	1	    
pointer2    dc.b	0

tab_p	    dc.l	tab_lica

tab_lica    dc.w	9,$20
	    dc.l	i1,i2
	    dc.w	10,0
	    dc.l	i3,i4	
	    dc.w	10,$20
	    dc.l	i5,i6	
	    dc.w	11,0
	    dc.l	i7,i8	    
	    dc.w	11,$20
	    dc.l	i9,i10
	    dc.w	12,0
	    dc.l	i11,i10
	    
	    dc.w	12,$20
	    dc.w	12,$25
	    dc.w	12,$2a
	    dc.w	12,$35
	    dc.w	12,$3a
	    
	    	    	    
	    
	    dc.w	$ffff


scren_l     dc.l 	$3ca000
scren_p     dc.l 	$3ca000-256*152*2 
sinus2      incbin 	d:\sinus\a_sin.prg   
sinus  	    incbin 	d:\sinus\b_sin.prg   
offs	    incbin 	d:\hohoho\stargate.dat
offs2	    incbin 	d:\re.dat
pic         incbin 	d:\hohoho\mess2.565
i1	    incbin	d:\time_out\i1.565
i2	    incbin	d:\time_out\i2.565

i3	    incbin	d:\time_out\i3.565
i4	    incbin	d:\time_out\i4.565

i5	    incbin	d:\time_out\i5.565
i6	    incbin	d:\time_out\i6.565

i7	    incbin	d:\time_out\i7.565
i8	    incbin	d:\time_out\i8.565

i9	    incbin	d:\time_out\i9.565
i10	    incbin	d:\time_out\i10.565

i11	    incbin	d:\time_out\i11.565
i12	    incbin	d:\time_out\i10.565


	    section 	bss
out 	    ds.l 	256*256
out2 	    ds.l 	256*256                
