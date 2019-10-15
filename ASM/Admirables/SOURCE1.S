* Little Code By Moksha of Admirables!
* Here is a little Shrink for Degas picture and included is also
* Mad Max Chip music Player! Code Contains also loader routs to
* load some programs!
* If we see Lamers using this code then we will get mad!
* Otherwise code is free to everyone!
* Don't forget to credit Moksha!


pal_start equ  $ff8240  

get_rez	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
set     move.w  d0,res
        move.w  #0,rez
        lea     piccy+34,a5
        move.l  a5,kuva
        lea     piccy+2,a5
        move.l  a5,u_pal
        move.l  #160,offs
        move.l  #39,kerr
        move.l  #199,kier
        bra     main              
main
	movea.l	sp,a5
	move.l	sp,store
	lea	end,sp
	movea.l	4(a5),a5
	move.l	12(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$300,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	move.l	#0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,a7
	move.l	d0,oldstk
	bsr mouse_off
	bsr musik
        bsr settings
        bsr black_pal
        bsr move_picture
        bsr new
        bsr show_picture        
get_key
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,a7
k1	cmp.b	#$31,d0
	bne	k2
	bsr	load1
	bra	get_key
k2	cmp.b	#$32,d0
	bne	k3
	bsr	load2
	bra	get_key
k3	cmp.b	#$33,d0
	bne	space
	bsr	load3
	bra	get_key
space	swap	d0
	cmp.b	#$20,d0
	bsr	desktop
	bra	get_key
desktop     
        jsr	sound_off
	jsr 	mouse_on
	bsr 	restore
        move.l  oldstk,-(sp)
        move.w  #$20,-(sp)      
        trap    #1              
        addq.l  #6,sp
	move.l	store,sp
        clr.w   -(sp)
	pea	$5000  
	move.w	#$31,-(sp)
	trap	#1
settings
        move.w  #2,-(sp)  
        trap    #14
        move.l  d0,phybase
        move.w  #3,-(sp)        
        trap    #14
        move.l  d0,logbase
        addq.l  #4,sp
        movea.l #pal_start,a5       
        lea      vpal,a6
        bsr     pal_move
        rts
pal_move
        moveq.l #15,d0
pal	move.w  (a5)+,(a6)+
        dbf     d0,pal
        rts
black_pal
        movea.l #pal_start,a6
        moveq.l #15,d0
mp      move.w  #$0000,(a6)+
        dbf     d0,mp
        rts
new
        movea.l #pal_start,a6        
        move.l  u_pal,a5
        bsr     pal_move
        rts
move_picture
        lea     piccy_alue,a0
        move.l  a0,d0
        clr.b   d0
        move.l  d0,piccy_buf     
        move.w  rez,-(sp)
        move.l  d0,-(sp)
        move.l  d0,-(sp)
        move.w  #5,-(sp)       
        trap    #14
        lea     12(sp),sp
        rts
restore
        move.w  res,-(sp)
        move.l  phybase,-(sp)
        move.l  logbase,-(sp)
        move.w  #5,-(sp)               
        trap    #14
        lea     12(sp),sp
        movea.l #pal_start,a6        
        lea      vpal,a5
        bsr     pal_move
        rts
show_picture   
        move.l  piccy_buf,a0     
        move.l  piccy_buf,a2
        move.l  kuva,a1         
        move.l  kuva,a4
        move.l  kier,d6        
        move.l  kier,d3  
dsilm   move.l  d3,d2        
psilm   move.l  a4,a1
        move.l  kerr,d5
esilm   move.l  (a1)+,(a0)+ 
        dbf     d5,esilm
        dbf     d2,psilm        
        move.l  offs,d4
        adda.l  d4,a4
        adda.l  d4,a2
        move.l  a2,a0
        subq.l  #1,d3
        dbf     d6,dsilm	       
        rts
load1
	bsr	restore
	bsr	sound_off
        lea     progi1,a5 
	pea	str
	pea	str                            
        move.l  a5,-(sp)                
        clr.w   -(sp)                   
        move.w  #$4B,-(sp)            
        trap    #1                
        lea     16(sp),sp               
load2	bsr	restore
	bsr	sound_off
	lea	progi2,a5
	pea	str
	pea	str
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	lea	16(sp),sp
load3	bsr	restore
	bsr	sound_off
	lea	progi3,a5
	pea	str
	pea	str
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4B,-(sp)
	trap	#1
	lea	16(sp),sp
sound_off
	move.l	oldint,$70.w
	move.l	#$8080000,$ff8820
	move.l	#$9090000,$ff8820
	move.l	#$a0a0000,$ff8820
	rts
musik	
	move.l	$70.w,oldint
	bclr	#0,$484.w
	moveq	#1,d0           ;Change number for diffy tune!
	bsr	music
	move.l	#sam,$70.w
	rts	
sam	movem.l	d0-a6,-(sp)
	bsr	(music+8)
	movem.l	(sp)+,d0-a6
	move.l	oldint,-(sp)
	rts
music  incbin "max.mus"      ;change Mad Max music file name here!

mouse_off
	dc.w	$a000
	dc.w	$a00a
	rts
	

mouse_on
	dc.w	$a000
	dc.w	$a009
	rts
oldint	   dc.l	0
rez	   dc.w	0      
res        dc.w 0 
var1	   dc.b	0             
var2       dc.w 0
logbase    dc.l 0
phybase    dc.l 0
piccy_buf  dc.l 0
kuva       dc.l 0
offs	   dc.l	0
kerr       dc.l 0
kier       dc.l 0
u_pal      dc.l 0
vpal       ds.w 16
store 	   dc.l	0
oldstk     dc.l 0
str        dc.l 0   

     even
progi1	  dc.b	"MBJ.PRG",0               ;PRG Names to load
progi2	  dc.b	"esionst.prg",0
progi3	  dc.b	"esionste.prg",0	               
		 even
                
env_str         dc.b    0,0      
cmd_str         dc.b    0,0     
    even
t„yte	ds.b   256
piccy_alue  ds.b 32000
piccy      incbin "picture.pi1"          ;Degas pictures file name here!
        even
stack   ds.w 399
end     dc.w 0
     end
        

