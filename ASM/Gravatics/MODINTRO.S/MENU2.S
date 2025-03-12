
        opt     d+

* macros

super   MACRO                   ;macro to go to supervisor
        clr.l   -(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  d0,oldsp
        ENDM

unsuper MACRO                   ;macro to go to user
        move.l  oldsp,-(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp
        ENDM

* main program

        move.l  4(a7),a3        ; base page
        move.l  #mystack,a7
        move.l  $c(a3),d0       ; text len
        add.l   $14(a3),d0      ; data len
        add.l   $1c(a3),d0      ; BSS len
        add.l   #$100,d0        ; basepage
        move.l  d0,-(sp)
        move.l  a3,-(sp)
        clr.w   -(sp)
        move.w  #$4a,-(sp)
        trap    #1              ; release memory
        add.l   #12,sp

        super

	jmp	bmain

	lea	mod_nm1,a4		; load song
	lea	module,a5
	move.l	#150000,a6
	bsr	open

	lea	rot_nm1,a4		; load song
	lea	replay_rot,a5
	move.l	#50000,a6
	bsr	open

	jmp	bmain

*	*	*	*	*	*	*	*	*	*

open	clr.w	-(sp)			; load a file
	move.l	a4,-(sp)		; a4 -> filename
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	diskerr
	move.w	d0,-(sp)		; store file handle

read	move.l	a5,-(sp)		; read file to data area
	move.l	a6,-(sp)
	move.w	d0,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.w	#12,sp
	move.l	d0,d7			; store length

close	move.w	#$3e,-(sp)		; close file
	trap	#1			; handle already on stack
	addq.l	#4,sp
	move.l	d7,d0
	tst.l	d0			; d0=bytes loaded, -ve=err
diskerr	rts

*	*	*	*	*	*	*	*	*	*

bmain   ;move.l  #-1,-(sp)       ;disable mouse
        ;move.l  #-1,-(sp)
        ;clr.l   -(sp)
        ;trap    #14
        ;add     #12,sp
	
	move	#12,-(sp)
	move	#4,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	dc.w	$A00A


	move.w	#2,-(sp)
	trap	#14
	move.l	d0,scr_addr
	addq	#2,sp

        move.l  scr_addr,a0      ;copy screen
        move.l  #(main+34),a1
        move.l  #7999,d7
p_cpy_2 move.l  (a1)+,(a0)+
        dbf     d7,p_cpy_2

        move.l  #$ff8240,a0     ;copy palette
        move.l  #(main+2),a1
        move.l  #7,d7
c_pal_2 move.l  (a1)+,(a0)+
        dbf     d7,c_pal_2

        moveq.l #1,d1           ;for interupts
        jsr     resmes          ;scroll once normally
        movem.l d0-d5/a0-a1,vb2_reg

************************************************************************
* Replay routine that replays -TCB TRACKER- modules  in normal ST mode *
* Made by Anders Nilsson  10/8/90                                      *
* Uses d6-d7/a2-a6 and usp                                             *
************************************************************************
x:
	jmp	amain			*jump to main
save_ints:
	move.b	$fffffa07.w,mfpa07	*save interrupts
	move.b	$fffffa09.w,mfpa09
	move.b	$fffffa13.w,mfpa13
	move.b	$fffffa15.w,mfpa15
	move.b	$fffffa19.w,mfpa19
	move.b	$fffffa1f.w,mfpa1f
	move.l	$134,old134
	move.l	$70.w,oldvbl
	rts
init_ints:	
	clr.b	$fffffa09.w		*init interrupts
	clr.b	$fffffa15.w
	move.w	module+$90,d0
	lea	mfp_freqs,a0
	move.b	(a0,d0.w),$fffffa1f.w
	move.b	#2,$fffffa19.w
	move.b	#32,$fffffa07.w
	move.b	#32,$fffffa13.w
	bclr	#3,$fffffa17.w
	move.l	#replay_rot+$8918,$134
	move.l	#vbl2,$70
	rts
ret_ints:	
	move.b	mfpa07,$fffffa07.w	*restore interrupts
	move.b	mfpa09,$fffffa09.w
	move.b	mfpa13,$fffffa13.w
	move.b	mfpa15,$fffffa15.w
	move.b	mfpa19,$fffffa19.w
	move.b	mfpa1f,$fffffa1f.w
	move.l	old134,$134
	move.l	oldvbl,$70.w
	rts

amain:
	move.l	usp,a0			*save usp
	move.l	a0,save_usp

	lea	module,a0		*a0=module start
	moveq	#0,d0			*-1=the default soundtable 0=the other
	jsr	replay_rot+$24		*init. replay routine
	
	jsr	save_ints		*save interrupts
	jsr	init_ints		*init. interrupts
	clr.w	wfnc
demo_loop:
	cmp.w	#1,wfnc			*wait for video
	bne	demo_loop
	clr.w	wfnc

	* your routines here..... remember d0-d5/a0-a1 !!!!!!

;	cmp.b	#185,$fffc02		*space

;	cmp.b	#'1',$fffffc02.w
;	bne	demo_loop		*yes/no
;	jsr	ret_ints		*restore interrupts

	cmp.b	#59,$fffffc02.w
	bne	check2
	bra	go1

check2
	cmp.b	#60,$fffffc02.w
	bne	check3
	bra	go2

check3
	cmp.b	#61,$fffffc02.w
	bne	demo_loop
	bra	go3

go1
	move.l	#mess1,l_message
	move.l	#name1,nm_ptr
	jmp	shutdown	

go2	
	move.l	#mess2,l_message
	move.l	#name2,nm_ptr
	jmp	shutdown

go3
	move.l	#mess3,l_message
	move.l	#name3,nm_ptr


shutdown:
	jsr	ret_ints
	move.l	save_usp,a0
	move.l	a0,usp

reset:
	

	move	#8,-(sp)
	move	#4,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	dc.w	$A009

	jsr	mouseon

	jmp	load

*exit:
	move.w	#20,-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	
fin     bra.s   fin

* vbl 2 routine

vbl2    movem.l d0-d5/a0-a1,-(sp)
	jsr	replay_rot+$28		*call replay routine
	move.w	#1,wfnc			*set video flag
	jsr	vol_bar
	move.l	#950,d0			;How to waste god knows
wt	dbf	d0,wt			;how many clock cycles.
        movem.l vb2_reg,d0-d5/a0-a1
        jsr     cnt
        movem.l d0-d5/a0-a1,vb2_reg
        movem.l (sp)+,d0-d5/a0-a1
        rte

* Volume Bar routine (ah-hem)

vol_bar	move.b	replay_rot+$562,bar1
	move.b	replay_rot+$564,bar2
	move.b	replay_rot+$566,bar3
	move.b	replay_rot+$568,bar4
	moveq.l	#0,d2
	tst.b	bar1
	beq	b1dec
	move.b	#20,bar1v
	bra	b1inc
b1dec	tst.b	bar1v
	beq	b1inc
	move.b	bar1v,d2
	subq	#1,d2
	move.b	d2,bar1v
b1inc	tst.b	bar2
	beq	b2dec
	move.b	#20,bar2v
	bra	b2inc
b2dec	tst.b	bar2v
	beq	b2inc
	move.b	bar2v,d2
	subq	#1,d2
	move.b	d2,bar2v
b2inc	tst.b	bar3
	beq	b3dec
	move.b	#20,bar3v
	bra	b3inc
b3dec	tst.b	bar3v
	beq	b3inc
	move.b	bar3v,d2
	subq	#1,d2
	move.b	d2,bar3v
b3inc	tst.b	bar4
	beq	b4dec
	move.b	#20,bar4v
	bra	b4inc
b4dec	tst.b	bar4v
	beq	b4inc
	move.b	bar4v,d2
	subq	#1,d2
	move.b	d2,bar4v
b4inc	nop

b1drw	move.l	scr_addr,a0
	add.l	#24008,a0
	moveq.l	#0,d2
	moveq.l	#21,d3
	move.b	bar1v,d2
	sub.b	bar1v,d3
l1drw	move.w	#$7ffe,(a0)
	move.w	#$7ffe,-160(a0)
	sub.l	#320,a0
	subq	#1,d2
	bmi	l1c
	bra	l1drw
l1c	move.w	#$0000,(a0)
	move.w	#$0000,-160(a0)

b2drw	move.l	scr_addr,a0
	add.l	#24016,a0
	moveq.l	#0,d2
	moveq.l	#21,d3
	move.b	bar2v,d2
	sub.b	bar2v,d3
l2drw	move.w	#$7ffe,(a0)
	move.w	#$7ffe,-160(a0)
	sub.l	#320,a0
	subq	#1,d2
	bmi	l2c
	bra	l2drw
l2c	move.w	#$0000,(a0)
	move.w	#$0000,-160(a0)

b3drw	move.l	scr_addr,a0
	add.l	#24024,a0
	moveq.l	#0,d2
	moveq.l	#21,d3
	move.b	bar3v,d2
	sub.b	bar3v,d3
l3drw	move.w	#$7ffe,(a0)
	move.w	#$7ffe,-160(a0)
	sub.l	#320,a0
	subq	#1,d2
	bmi	l3c
	bra	l3drw
l3c	move.w	#$0000,(a0)
	move.w	#$0000,-160(a0)

b4drw	move.l	scr_addr,a0
	add.l	#24032,a0
	moveq.l	#0,d2
	moveq.l	#21,d3
	move.b	bar4v,d2
	sub.b	bar4v,d3
l4drw	move.w	#$7ffe,(a0)
	move.w	#$7ffe,-160(a0)
	sub.l	#320,a0
	subq	#1,d2
	bmi	l4c
	bra	l4drw
l4c	move.w	#$0000,(a0)
	move.w	#$0000,-160(a0)

rt	rts

* scroll routine, (from menu 3)(edited)

resmes  move.l  #message,mes_p  ;move message addr to mes pointer
nxtlet  movea.l mes_p,a1        ;move pointer to a1
        moveq.l #0,d0           ;clear d reg
        move.b  (a1)+,d0        ;get char and increment pointer
        cmpi.w  #$ff,d0         ;end of message?
        beq     resmes          ;yes? restart
        subi.l  #32,d0
        move.l  a1,mes_p        ;copy pointer back to buffer
        asl.w   #2,d0           ;multi by 4, use l-words not bytes
        movea.l #fnt_tbl,a1     ;font table addr
        adda.l  d0,a1           ;plus char no=addr of offset
        move.l  #font,a0        ;font data
        adda.l  (a1),a0         ;plus offset
        adda.l  #34,a0          ;miss palette data
        move.l  a0,chr_ptr      ;move font ops to buffer

****************************scroll routine*********************

        moveq.l #1,d4
tbc     moveq.l #1,d1
tcb     movea.l scr_addr,a1      ;move scr addr for working with
        moveq.l #31,d5           ;no of lines-1 to scroll
lines   nop
        move.b  1(a1),(a1)
        move.b  8(a1),1(a1)     
        move.b  9(a1),8(a1)     
        move.b  16(a1),9(a1)    
        move.b  17(a1),16(a1)   
        move.b  24(a1),17(a1)   
        move.b  25(a1),24(a1)   
        move.b  32(a1),25(a1)   
        move.b  33(a1),32(a1)   
        move.b  200(a1),33(a1)  
        move.b  361(a1),200(a1) 
        move.b  528(a1),361(a1) 
        move.b  369(a1),528(a1) 
        move.b  216(a1),369(a1) 
        move.b  57(a1),216(a1)  
        move.b  224(a1),57(a1)  
        move.b  385(a1),224(a1) 
        move.b  552(a1),385(a1) 
        move.b  713(a1),552(a1) 
        move.b  560(a1),713(a1)         
        move.b  401(a1),560(a1)         
        move.b  248(a1),401(a1)         
        move.b  89(a1),248(a1)          
        move.b  256(a1),89(a1)          
        move.b  417(a1),256(a1)         
        move.b  584(a1),417(a1) 
        move.b  425(a1),584(a1) 
        move.b  272(a1),425(a1) 
        move.b  113(a1),272(a1) 
        move.b  120(a1),113(a1) 
        move.b  121(a1),120(a1) 
        move.b  128(a1),121(a1) 
        move.b  129(a1),128(a1) 
        move.b  136(a1),129(a1) 
        move.b  137(a1),136(a1) 
        move.b  144(a1),137(a1) 
        move.b  145(a1),144(a1) 
        move.b  152(a1),145(a1) 
        move.b  153(a1),152(a1) 
        move.b  3(a1),2(a1)
        move.b  10(a1),3(a1)    
        move.b  11(a1),10(a1)   
        move.b  18(a1),11(a1)   
        move.b  19(a1),18(a1)   
        move.b  26(a1),19(a1)   
        move.b  27(a1),26(a1)   
        move.b  34(a1),27(a1)   
        move.b  35(a1),34(a1)   
        move.b  202(a1),35(a1)  
        move.b  363(a1),202(a1) 
        move.b  530(a1),363(a1) 
        move.b  371(a1),530(a1) 
        move.b  218(a1),371(a1) 
        move.b  59(a1),218(a1)
        move.b  226(a1),59(a1)  
        move.b  387(a1),226(a1) 
        move.b  554(a1),387(a1) 
        move.b  715(a1),554(a1) 
        move.b  562(a1),715(a1)         
        move.b  403(a1),562(a1)         
        move.b  250(a1),403(a1)         
        move.b  91(a1),250(a1)          
        move.b  258(a1),91(a1)          
        move.b  419(a1),258(a1)         
        move.b  586(a1),419(a1) 
        move.b  427(a1),586(a1) 
        move.b  274(a1),427(a1) 
        move.b  115(a1),274(a1) 
        move.b  122(a1),115(a1) 
        move.b  123(a1),122(a1) 
        move.b  130(a1),123(a1) 
        move.b  131(a1),130(a1) 
        move.b  138(a1),131(a1) 
        move.b  139(a1),138(a1) 
        move.b  146(a1),139(a1) 
        move.b  147(a1),146(a1) 
        move.b  154(a1),147(a1) 
        move.b  155(a1),154(a1) 
        move.b  5(a1),4(a1)
        move.b  12(a1),5(a1)    
        move.b  13(a1),12(a1)   
        move.b  20(a1),13(a1)   
        move.b  21(a1),20(a1)   
        move.b  28(a1),21(a1)   
        move.b  29(a1),28(a1)   
        move.b  36(a1),29(a1)   
        move.b  37(a1),36(a1)   
        move.b  204(a1),37(a1)  
        move.b  365(a1),204(a1) 
        move.b  532(a1),365(a1) 
        move.b  373(a1),532(a1) 
        move.b  220(a1),373(a1) 
        move.b  61(a1),220(a1)
        move.b  228(a1),61(a1)  
        move.b  389(a1),228(a1) 
        move.b  556(a1),389(a1) 
        move.b  717(a1),556(a1) 
        move.b  564(a1),717(a1)         
        move.b  405(a1),564(a1)         
        move.b  252(a1),405(a1)         
        move.b  93(a1),252(a1)          
        move.b  260(a1),93(a1)          
        move.b  421(a1),260(a1)         
        move.b  588(a1),421(a1) 
        move.b  429(a1),588(a1) 
        move.b  276(a1),429(a1) 
        move.b  117(a1),276(a1) 
        move.b  124(a1),117(a1) 
        move.b  125(a1),124(a1) 
        move.b  132(a1),125(a1) 
        move.b  133(a1),132(a1) 
        move.b  140(a1),133(a1) 
        move.b  141(a1),140(a1) 
        move.b  148(a1),141(a1) 
        move.b  149(a1),148(a1) 
        move.b  156(a1),149(a1) 
        move.b  157(a1),156(a1) 

        move.b  (a0),153(a1)    ;start copying new char
        move.b  2(a0),155(a1)
        move.b  4(a0),157(a1)
        adda.l  #160,a0         ;position to start of next line
        adda.l  #160,a1         ;do same with screen
        dbf     d5,lines        ;do all rows
        rts

cnt     addq.l  #1,chr_ptr      ;second half pos on big chars
        move.l  chr_ptr,a0      ;put it in the correct register
        subq.l  #1,d1           ;done both halfs of big char?
        bmi     d1_off1
        bra     tcb             ;loop back to do it again

d1_off1 addq.l  #6,chr_ptr
        move.l  chr_ptr,a0
        subq.l  #1,d4
        bmi     nxtlet
        bra     tbc

* labels n prog space

        ds.l    100             stack space
mystack ds.w    1               (stacks go backwards)
oldint  dc.l    0
oldsp   dc.l    0

* message + other scrolltext stuff
message	DC.B	" WELCOME TO G.R.A.V.A.T.I.C.S. CD 74...IMPORTANT..SHADOWLANDS IS A BIT BOTCHY ON SOME ST'S..TRY LOADING IT WITH OR WITHOUT THE INTRO OR EVEN FROM THE DESKTOP!..."
	DC.B      ".THIS IS A VERY SPECIAL MENU AS IT IS DEDICATED TO THE GREATEST LAMER OF ALL TIMES...BARRY ROJACK..OR SHOUD WE SAY RATJACK OF CONSPIRACY?...THIS LITTLE PRICK THINKS HE IS COOL BECAUSE A) HE HAS"
	DC.B      " GOTTON HOLD OF SOME RIPPED MENU SOURCE CODE. B) BECAUSE HE RIP OTHER PEOPLES CRACKS AND PACKS USING A TEXT EDITOR (REMEMBER ANOTHER WORLD BARRY???)..C) BECAUSE HE THINKS HE CAN NOW SLAG ANYONE HE WANTS (SLAGGING FUZION AND IMPACT "
	DC.B      "IS NOT A GOOD IDEA BARRY!)..D) HE NOW THINKS HE CAN TAKE OVER FROM US SINCE HE QUITE APPARANTLY IS THE SUPERIOR GROUP (11 SECTORS,84 TRACKS?..GET A GRIP FATRATJACK!)...OH WELL TIME FOR SOME GREETS NOW AND AFTER THAT THE WORST EVER "
	DC.B      "SLAGGINGS BY ANY ST GROUP!!....HELLOS SMASH OUT MY WINDOW...KILL THE POSTMAN...BURN DOWN THE DOOR..AND MUTILATE THE FOLLOWING ULTRACOOL PEOPLE......TOXIC OF IMPACT,SIGNET OF X-STATIC,FERIS,ANTSMAN,CHIMERA,PAT CASH OF FUZION,ICS,"
	DC.B      "ELITE,POMPEY PIRATES(HI ALIEN),SFX,THE FOX,THE VISIONARIES,CIMP,TEXACO,FLOG,BLIP,GOLF,GAVIN,MY GERBILS,MY GOLDFISH,MY ST,MY BODY(?),EVRYTHING ON THIS PLANET EXCEPT BARRY ROJACK!!.......READ ON ONLY IF YOUR NAME IS BARRY ROJACK AS "
	DC.B      "THE FOLLOWING COMMENTS ARE GOING TO BE PRETTY NASTY AND CRUDE..........HERE GOES ...NASTY SLAGS.........BARRY YOU ARE A QUEER BOY...WE HATE YOU TO NO END...WHAT IS IT LIKE KNOWING YOU ARE GOING TO DIE THE NEXT TIME I SEE YOU??...WHY"
	DC.B      " ARE YOU SUCH A LITTLE DICKHEAD...AN ALIEN MUST HAVE SUPPLIED THE SPERM FOR YOUR TEST TUBE AS IT IS IMPOSSIBLE TO THINK OF ANOTHER REASON WHY YOU ARE ON THIS PLANET!!...I THINK I SHOULD DO THE ST SCENE A BIG FAVOUR AND INCINERATE YOU! "
	DC.B      "YOU LITTLE BOLLOCKS!..BY THE WAY LOOK OUT FOR SOME MEGA SLAGS FROM LOADS OF OTHER GROUPS BATFOY!!(WORK THAT OUT FOR YOURSELF BARRY!)...OH YEAH RIP ANOTHER GAME OFF OUR MENUS AND YOUR DEATH WILL BE EVEN MORE PAINFULL....EVERY MEMBER "
	DC.B      "OF GRAVATICS THINKS YOU ARE SCUM OF THE EARTH...SANDMAN WANTS TO SACRIFICE YOU,I WANT TO BREAK YOUR NECK AND INCINERATE YOU,CAPTAIN TRIPPS WANTS YOUR TO CHOKE ON A BILLION 'HELP' KEYS (?),AND OUR ARTISTS WANT TO KILL YOU TOO!.."
	DC.B      "MAYBE I WILL DEDICATE A DEMO TO YOU..I'LL CALL IT 'ROJACK DEATH!'...YEAH THAT SOUNDS GOOD!...I WOULD REALLY LOVE TO STUFF YOUR PUDGY FACE INTO A MICROWAVE..WHAT FUN THAT "
	DC.B      "WOULD BE..WATCHING YOUR HEAD EXPLODE INTO A MILLION PARTICLES!!.......THAT WILL DO FOR THIS MENU...WATCH OUT FOR MENU 75 WITH THE ROJACK DEATH DEMO ON IT!!..........CREDITS FOR THIS MENU GO TO :-SLIPPERY SID AND THE SLIMEBALLS FOR "
	DC.B      "THE BASIC MENU CODE..THANKS TO THE MEGA MIGHTY CAPTAIN TRIPPS FOR ALTERING IT TO SUIT OUR PURPOSES(NICE ONE!)...PICTURE IS BY JONO...MUSIC IS RIPPED FROM THE JUST BUGGIN DEMO...TIME TO WRAP.........BUDD GUY........ENJOY LIFE WHILE "
	DC.B      "IT STILL EXISTS FOR YOU BARRY...........WARP................CALC...ZOOMPIE.....DIKABOO......VOLLAS.......                          WRAP                                                   " 


        dc.b    $ff
fnt_tbl dc.l    0,16,32,48,64,80,96,112,128,144
        dc.l    5120,5136,5152,5168,5184,5200,5216,5232,5248,5264
        dc.l    10240,10256,10272,10288,10304,10320,10336,10352,10368,10384
        dc.l    15360,15376,15392,15408,15424,15440,15456,15472,15488,15504
        dc.l    20480,20496,20512,20528,20544,20560,20576,20592,20608,20624
        dc.l    25600,25616,25632,25648,25664,25680,25696,25712,25728,25744
mes_p   dc.l    0
	dc.w	0
chr_ptr dc.l    0
	dc.w	0
vb2_reg ds.l    15              ;buffs for vbl2 regs
scr_addr:
	dc.l	0
mfp_freqs:
	dc.b	24			*10 and 8.3 Khz
	dc.b	29
bar1	dc.b	0
bar2	dc.b	0
bar3	dc.b	0
bar4	dc.b	0
bar1v	dc.b	0
bar2v	dc.b	0
bar3v	dc.b	0
bar4v	dc.b	0
save_usp:
	dc.l	0
wfnc:
	dc.w	0
save_stk:
	dc.l	0
replay_rot:				*the replay routine
	incbin	"a:\tracker.rot",0
;	ds.b	50000
	even
module:					*the module
	incbin	"a:\buggin.mod",0

;	ds.b	80000


mod_nm1	;incbin	"A:\buggin.mod",0
rot_nm1	;incbin	"A:\tracker.rot",0
	even
mfpa07:	dc.b	0			*vars for interrupt saving
mfpa09:	dc.b	0
mfpa13:	dc.b	0
mfpa15:	dc.b	0
mfpa19:	dc.b	0
mfpa1f:	dc.b	0
old134:	dc.l	0
oldvbl:	dc.l	0

* include files

main    incbin  "a:\landmenu.pi1"
        even
font    incbin  "a:\font.pi1"





mouseon:
	move	#8,-(sp)
	move	#4,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	dc.w	$A009
	rts


test:
	cmp.b	#57,$fffffc02.w
	beq	prep
	jmp	test

prep:
	move.l	#name1,nm_ptr
	bra	load

;	cmp.w	#0,2000
;	bne	nx1			;goto desktop
;	move.l	#men_nm,nm_ptr
;	bra	load			;load	
;nx1	cmp.w	#1,2000
;	bne	term
;	move.l	#tcb_nm,nm_ptr
;	bra	load

term	unsuper
	clr.w	-(sp)
	trap	#1

load	clr.w	2000
	unsuper
	pea	env_str
	pea	cmd_str
	move.l	nm_ptr,-(sp)
	move.l	#$4b0000,-(sp)
	trap	#1
	add	#16,sp
	clr.w	-(sp)
	trap	#1	

	ds.l	50			stack space
;mystack	ds.w	1			(stacks go backwards)
tcb_nm	dc.b	"99.sss"
name1	dc.b	"SHADOW.PRG"
name2	dc.b	"ISLAND.prg"
name3	dc.b	"CJUSA.prg"
nm_ptr	dc.l	0
;oldsp	dc.l	0
env_str	dc.b	0,0
cmd_str	dc.b	0,0
l_message	ds.l	1
mess1	dc.b	13,'Loading 1st PRG file...',0
mess2	dc.b	13,'Loading 2nd PRG file...',0
mess3	dc.b	13,'Loading 3rd PRG file...',0