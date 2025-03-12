;Why More Pacman Games When There Are Plenty Of Them Out There.
;There Are Two Things Why I Did This (enough for me):
;
;				o I Haven't Seen Any 4k Pacman To STe
;				o And It's A Classic Game
;
;STE 4k Pacman v.0.3 By îDGî Of TCW (Maybe On F030 At ST Compatibility Mode)
;Uses Blitter (sorry, maybe a ST version later)
;Thanks To Pookie And Domeday for testing.
;
;This code can easily optimize a lot more and change the ghost routines
;to a more random move path instead of searching for the pacman.
;I had a star sweet that pacman could get so the ghost run away from
;you but that seems to be a bit harder to play so I removed it as
;a request from the testers.
;
;Infact I have already started to code a new and better one. 
;I try to figure out how to fix the key buffer.
;
;But feel free to change or rip off gfx. I hope this can educate to
;code some game routs. Or make a better one than this piece of
;Q & D coded crap. And sorry the lack of comments. (boring)
;
;It is not Impossible to complete this level trust me 3 of us have manage it.
;      --------------
;Hint! Try to control the ghost so you can get them stuck. (I say no more :) )
;And try to make sure that you does not get killed at your own start position.

	opt	x+,o+

level_width	equ	36	;How many 8 pixels blocks at X line (eeh playground)
level_height	equ	22 	;       ----  "  " ----      Y line
ani_speed	equ	6 	;And how fast ghost runs & animation 
				;speed of pacman
score_dot	equ	8	;X pointes for every Sweet pacman eats
num_of_lives	equ	2	;number of pacman lives to start with.

topx	equ	160-((8*level_width)/2)		;We want the playground 
topy	equ	100-((8*level_height)/2)	;in middle of the Screen

	move.w	#0,-(sp)
	move.w	#$20,-(sp)		;Super Mode
	trap	#1
	addq.l	#4,sp
	move.l	d0,old_usp

	bsr	vsync			;Smaller metode
	move.b	#0,$ffff8260.w

	move.w	#0,-(sp)		;Use This For F030 If the Upper code
	pea	-1.l			;wont work.
	pea	-1.l
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	movem.l	col,d0-7		;U may change this to 
	movem.l	d0-7,$ffff8240.w	;XBios #6 
					;(I think so it works fine on F030)

	move.b	#$12,$fffffc02.w	;Mouse off
	move.b	#2,$484.w		;Key clicks Off

	move.l	$44e.w,a0		;Get logical Screen Address
	move.l	#gfx,a1
*	move.l	#(160/4)*8-1,d0
	moveq.l	#8-1,d0			;remove this
draw_img
*	move.l	(a1)+,(a0)+
	move.l	152(a1),152(a0)		;remove this
 	move.l	156(a1),156(a0)		;& this
	add.l	#160,a1			;& this
	add.l	#160,a0			;& this to display gfx
	dbf	d0,draw_img

	move.l	#pacman_pek,a0		;Get pacman And ghost out of the map
	moveq	#8,d4			;
	moveq	#8,d6			;
	moveq	#4-1,d5			;
find_ghost:
	moveq	#0,d0
	moveq	#0,d1
	move.l	#level1,a3
.loop	move.b	(a3)+,d3
	cmp.b	d4,d3
	beq.s	.found_ghost
	addq.w	#8,d0
 	cmp.w	#8*(level_width-1),d0
	ble.s	.no_reset
	moveq	#0,d0
	addq.w	#8,d1
.no_reset:bra.s	.loop
.found_ghost:subq.w	#1,a3
 	move.b	d6,(a3)			;
	move.l	a3,(a0)+		;
	move.w	d0,(a0)+		;
	move.w	d1,(a0)+
	addq.w	#1,d4
	moveq	#1,d6
	dbf	d5,find_ghost

	move.l	pacman_pek,(old_pac_pek)
	move.w	pacman_x,(old_pac_x)
	move.w	pacman_y,(old_pac_y)

	bsr	draw_play_ground	;Yepp let draw plygrnd
cont_game:
	bsr	pacman_lives_ctrl	

	move.l	old_pac_pek,pacman_pek
	move.w	old_pac_x,pacman_x
	move.w	old_pac_y,pacman_y

loop
	move.b	#$0000,$ffff8240.w
.nope	bsr	vsync				;Suger En VSync Ibland
	move.b	$fffffc02.w,d0
	cmp.b	#$80,d0
	blt.s	.nope
	move	#$0002,$ffff8240.w
	
	bsr	key_ctrl			;Reads keyb for Pacman moves

	move.w	(max_score),d0
	cmp.w	(score),d0
	beq.s	level_complete
	
	addq.b	#1,(ani_cnt)		;Animation Counter 
					;Counts Up To Specific Number
					;And Then It Changes Bitmap Offset 
	move.b	ani_cnt,d0		;Moves The Counted # Into D0
	cmp.b	#ani_speed,d0		;Check If It Has Reached The Wanted 
	bne.s	.no_ani_chg		;Number. If Not Skip It.
	bsr	swap_ani_offs		;Here We Rotate Animation Offsets
	move.b	#0,(ani_cnt)		;Zero 'ani_cnt' Variable
	bsr	move_ghosts		;Moves Ghost At Every x VBL 
					;To Slow It Down A Bit
	bra.s	.laa
.no_ani_chg	
	bsr	every_vbl_ghost_check	;(Almost true (If the keys hangs))
.laa
	cmp.b	#$39,$fffffc02.w
	beq	exit
	bra.s	loop

level_complete
	move.l	#level_complete_txt,a0
	bra.s	disp
exit_dead
	move.b	pacman_lives,d0
	subq.w	#1,d0
	cmp.b	#-1,d0
	beq.s	game_over
	move.b	d0,pacman_lives

	move.l	pacman_pek,a0
	move.b	#0,(a0)
	move.l	$44e.w,a1		;Get Physical Screen Address
	move.l	#gfx+8*18,a0		;Svart ruta
	move.l	#blk16x8,a2		;Blitter Data
	move.w	pacman_x,d0
	move.w	pacman_y,d1
	bsr	undo_pacman		;Now Delete Dead Pacman
	
	bra	cont_game
game_over
	move.l	#game_over_txt,a0
disp	bsr	text
	move.l	#ply_score_txt,a0
	bsr	text
	move.w	score,d0
	bsr	dec
	move.l	#max_score_txt,a0
	bsr	text
 	move.w	(max_score),d0
	bsr	dec
.wait_kii:
	cmp.b	#57,$fffffc02.w		;Space???
	bne.s	.wait_kii		;nop still waiting

exit	move.w	#$0fff,$ffff8240.w
	move.w	#$0000,$ffff8246.w
	move.w	#$0000,$ffff825e.w

	move.b	#$08,$fffffc02.w	;mouse on

	move.l	old_usp,-(sp)		;Back to User Mode
	move.w	#$20,-(sp)	
	trap	#1
	addq.l	#4,sp

	clr	-(sp)			;Aaarrghhh.... bluurrpp...
	trap	#1			;Desktop

vsync	move.w	$468.w,d0
.vsync	cmp.w	$468.w,d0
	beq.s	.vsync
	rts

;One really problem with this code, is that keys hangs (buffer filled)
;and make it hard to control pacman. but if you change key read to joystick
;and everything sorted out, but I would like to have a key controlled pacman.
;Hope to sort this little problem soon.

key_ctrl
	moveq	#0,d0
	moveq	#0,d1
	move.w	pacman_x,d0		:D0 = Stores Pacman X Coordinate
	move.w	pacman_y,d1		;D1 = Stores Pacman Y Coordinate
	move.l	pacman_pek,a3		;A3 = Pointes Where Pacman Is 
					;On The Map (Map Position).

	move.b	1(a3),d2		;East Of Pacman. D2 = Map Data
	move.b	-1(a3),d3		;West Of Pacman. D3 = Map Data
	add.w	#level_width,a3		;Add Offset On Map Pos.
	move.b	(a3),d4			;South Of Pacman. D4 = Map Data
	sub.w	#level_width*2,a3	;Sub Offset On Map Pos.
	move.b	(a3),d5			;North Of Pacman. D5 = Map Data
	add.w	#level_width,a3		;Normalize Map Position

	move.l	$44e.w,a1		;Get Physical Screen Address
	move.l	#gfx+8*18,a0		;Svart ruta
	move.l	#blk16x8,a2		;Blitter Data

	cmp.b	#1,d2			;Is It Possible To Go There?
	bgt.s	.no_w			;No It Is A Wall There So Skip Routine
	cmp.b	#77,$fffffc02.w		;Is Right Key Pressed
	bne.s	.no_w			;No Skip Routine
	addq.w	#8,d0			;Add 8 pixel to X  
	addq.w	#1,a3			;Add One Byte Right On Current 
					;Map Position.
	cmp.b	#1,(a3)			;Is There Any Sweet On That Square
	bne.s	.no_sweet		;Not, Then Skip Add Score
	addq.w	#score_dot,(score)	;Add Score To Player
.no_sweet
	move.b	#0,-1(a3)		;Set Zero On The Map Position So 
					;We Know That Player Already Got 
					;His Score That Square.
	move.b	#8,(a3)			;Set New Pacman Position On The Map
	subq.w	#8,d0			;We Have To Sub 8 Pixels X To 
	bsr	undo_pacman		
	addq.w	#8,d0			;Restore Pacmans X Coordinate 
	move.l	#right_ani_offs,(ani_pointer)	;New Animation Pointer
	bra	.fin			;Now Right Routine Is Finished
.no_w	cmp.b	#1,d3
	bgt.s	.no_h
	cmp.b	#75,$fffffc02.w		;Left
	bne.s	.no_h
	subq.w	#8,d0
	subq.w	#1,a3
	cmp.b	#1,(a3)
	bne.s	.no_sweet2
	addq.w	#score_dot,(score)
.no_sweet2
	move.b	#0,1(a3)
	move.b	#8,(a3)
	addq.w	#8,d0

	bsr	undo_pacman

	subq.w	#8,d0
	move.l	#left_ani_offs,(ani_pointer)
	bra	.fin
.no_h	cmp.b	#1,d4		
	bgt.s	.no_q
	cmp.b	#80,$fffffc02.w		;Ned	
	bne.s	.no_q
	addq.w	#8,d1
	move.b	#0,(a3)
	add.w	#level_width,a3		;Offset +20
	cmp.b	#1,(a3)
	bne.s	.no_sweet3
	addq.w	#score_dot,(score)
.no_sweet3
	move.b	#8,(a3)			;syd
	subq.w	#8,d1
	bsr	undo_pacman

	addq.w	#8,d1
	move.l	#down_ani_offs,(ani_pointer)
	bra.s	.fin
.no_q	cmp.b	#1,d5
	bgt.s	.no_z
	cmp.b	#72,$fffffc02.w
	bne.s	.no_z
	subq.w	#8,d1
	move.b	#0,(a3)
	sub.w	#level_width,a3		;Map Offset -20
	cmp.b	#1,(a3)
	bne.s	.no_sweet4
	addq.w	#score_dot,(score)
.no_sweet4
	move.b	#8,(a3)		;norr??? okej eller
	addq.w	#8,d1
	bsr.s	undo_pacman
	subq.w	#8,d1
	move.l	#up_ani_offs,(ani_pointer)
	bra.s	.fin
.no_z
	add.w	#topx,d0
	add.w	#topy,d1
.fin	move.l	$44e.w,a1	
	move.l	#gfx,a0
	move.l	(ani_pointer),a4
	add.w	(a4),a0
	bsr	convert	
	add.w	offset,a1
	move.l	#blk16x8,a2
	bsr	blit_sprite

	sub.w	#topx,d0
	sub.w	#topy,d1
	move.w	d0,pacman_x
	move.w	d1,pacman_y
	move.l	a3,(pacman_pek)
	rts

undo_pacman
	add.w	#topx,d0		;Add Center X To Pacmans X
	add.w	#topy,d1		;Add Center Y To Pacmans Y
					;Get The Coordinates For The Blank 
					;Box To Clear Where Pacman Stood 
					;Before He Moved.         
	bsr	convert			;Calculate Offset And Skew Data   
	add.w	offset,a1		;Add Offset Att Destination Adr.  
	bsr	blit_sprite		;Now Blitt Black Square Sprite       
	rts

pacman_lives_ctrl
	move.w	#9,d0
	move.w	#0,d1
	moveq	#2,d2

.clear	move.l	$44e.w,a1	
	move.l	#gfx,a0
	add.w	#18*8,a0
	bsr	convert	
	add.w	offset,a1
	move.l	#blk16x8,a2
	bsr	blit_sprite
	move.w	#18,d0
	dbf	d2,.clear

	moveq	#0,d2
	move.w	#0,d0
	move.b	pacman_lives,d2
.draw_live
	move.l	$44e.w,a1	
	move.l	#gfx,a0
	bsr	convert	
	add.w	offset,a1
	move.l	#blk16x8,a2
	bsr	blit_sprite
	add.w	#9,d0
	dbf	d2,.draw_live
	rts

;/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
move_ghosts:
	moveq	#0,d0
	moveq	#0,d1
	move.l	ghost_pek,a3
	move.w	ghost_x,d0
	move.w	ghost_y,d1
	bsr.s 	ghost_engine
	move.l	a3,(ghost_pek)
	move.w	d0,(ghost_x)
	move.w	d1,(ghost_y)
   
	moveq	#0,d0
	moveq	#0,d1
	move.l	ghost_pek2,a3
	move.w	ghost_x2,d0
	move.w	ghost_y2,d1
	bsr.s 	ghost_engine
	move.l	a3,(ghost_pek2)
 	move.w	d0,(ghost_x2)
	move.w	d1,(ghost_y2)

	moveq	#0,d0
	moveq	#0,d1
	move.l	ghost_pek3,a3
	move.w	ghost_x3,d0
	move.w	ghost_y3,d1
	bsr.s 	ghost_engine
	move.l	a3,(ghost_pek3)
 	move.w	d0,(ghost_x3)
	move.w	d1,(ghost_y3)
	rts	
	
;Really Dumb Zombie Routine Checks. (Will Improve It Soon)

ghost_engine
	move.l	#gfx,a0
	cmp.b	#0,(a3)
	bne.s	.no_blank
	add.w	#18*8,a0
.no_blank:cmp.b	#1,(a3)
	bne.s	.no_godis
	add.w	#13*8,a0
.no_godis:add.w	#topx,d0
	add.w	#topy,d1

	move.l	$44e.w,a1	
	bsr	convert	
	add.w	offset,a1
	move.l	#blk16x8,a2
	bsr	blit_sprite
	sub.w	#topx,d0
	sub.w	#topy,d1
	
	bsr	hit?		

	add.w	#level_width,a3		;Normalize map Pointer
	move.w	pacman_y,d6
	cmp.w	d1,d6
BGT_Y	bgt.s	.s
	beq.s	.y_fin
.n	cmp.b	#1,d2
	bgt.s	.no_north
	subq.w	#8,d1
	sub.w	#level_width,a3
	bra.s	x_fin
.no_north
.s	cmp.b	#1,d4
	bgt.s	.no_syd
	addq.w	#8,d1
	add.w	#level_width,a3
	bra.s	x_fin
.no_syd
.y_fin	move.w	pacman_x,d6
	cmp.w	d6,d0
BGT_X	bgt.s	.we
	beq.s	x_fin
.e	cmp.b	#1,d3
	bgt.s	.no_east
	addq.w	#8,d0
	addq.w	#1,a3
	bra.s	x_fin
.no_east
.we	cmp.b	#1,d5
	bgt.s	.no_west
	subq.w	#8,d0
	subq.w	#1,a3
.no_west
x_fin
	add.w	#topx,d0
	add.w	#topy,d1
	move.l	$44e.w,a1	
	move.l	#gfx+8*9,a0
	bsr.s	convert	
	add.w	offset,a1
	move.l	#blk16x8,a2
	bsr	blit_sprite
	sub.w	#topx,d0
	sub.w	#topy,d1
	rts
;/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
every_vbl_ghost_check
	move.l	ghost_pek,a3
	bsr.s 	hit?
	move.l	ghost_pek2,a3
   	bsr.s 	hit?
	move.l	ghost_pek3,a3
	bsr.s 	hit?
	rts

;checks if ghost has hit pacman. 
;This one could change to one 'cmp.b' command instead of four compares.

hit?	move.b	1(a3),d3		
	move.b	-1(a3),d5		
	add.w	#level_width,a3
	move.b	(a3),d4			
	sub.w	#level_width*2,a3
	move.b	(a3),d2			
	cmp.b	#8,d2
	beq	exit_dead
	cmp.b	#8,d3
	beq	exit_dead
	cmp.b	#8,d4
	beq	exit_dead
	cmp.b	#8,d5
	beq	exit_dead
	rts
* In:							
*    	d0.w = 	x
* 	d1.w = 	y
* Ut:
*	skew		;shift v„rde
*	offset

convert	
	movem.l	d0-d1,-(sp)	
	divu	#16,d0
	lsl.w	#3,d0
	move.w	d0,offset
	swap	d0
	move.b	d0,skew
	move.l	d1,d0
	mulu	#160,d0
	add.w	d0,offset
	movem.l	(sp)+,d0-d1
	rts

; 3 bitplane blitting with mask

* a0.l =	source adressen
* a1.l =	destinatio n adressen
* a2.l =	sprite data adressen
*
* d0-d1	uses
blit_sprite:
	movem.l	a0-a2/d0-d1,-(sp)
	move.w	(a2)+,COUNTX     ;x count 1 ord + en extra f”r att skifta
 	move.w	(a2)+,SRCINCX    ;source x inc 8= en bitplan
	move.w	(a2)+,SRCINCY    ;source y inc (24 = 2*8 (COUNTX*SRCINCX))
	move.w	(a2)+,DESTINCX   ;dest x inc
	move.w	(a2)+,DESTINCY   ;dest y inc

	move.w	#$ffff,d1
	moveq	#0,d0
	move.b	skew,d0 	
	lsr.w	d0,d1
	move.w	d1,ENDMASK1        	;endmask 1
	not.w	d1	
	move.w	d1,ENDMASK3     	;endmask 3
	move.w	#$ffff,ENDMASK2 	;endmask 2
	move.b	#2,HOP   		;hop (source direct)
	move.b	skew,SKEW_ADR      
	move.b	#1,OP    		;logiska operanden = AND
	moveq	#3,d0			;fyra bitplan som skall blittas
.mask	move.l	a0,SRCADDR          	;source adress
	move.l	a1,DESTADDR 		;dest adress
	move.w	(a2),COUNTY  		;y count 
	move.b	#%11000000,LINENUM 	;f”rst hog mode sedan buzy
	addq	#2,a1			;n„sta bitplan p† dest
	dbra	d0,.mask
	subq	#6,a1
	move.b	#7,OP    		;op = OR
 	addq	#2,a0			;skip first plane
	moveq	#2,d0		
.blitta	move.l	a0,SRCADDR        	;source adress
	move.l	a1,DESTADDR 		;dest adress
	move.w	(a2),COUNTY  		;y count 
	move.b	#%11000000,LINENUM 	;f”rst hog mode sedan buzy
	addq	#2,a0			;n„sta bitplan fr†n src
	addq	#2,a1			;n„sta bitplan p† dest
	dbra	d0,.blitta	
	movem.l	(sp)+,a0-a2/d0-d1
	rts

;Changes low word offsets with high word offsets
swap_ani_offs:
	move.l	#right_ani_offs,a0	
	move.l	(a0),d0
	swap	d0	
	move.l	d0,(a0)
	move.l	4(a0),d0
	swap	d0	
	move.l	d0,4(a0)
	move.l	8(a0),d0
	swap	d0	
	move.l	d0,8(a0)
	move.l	12(a0),d0
	swap	d0	
	move.l	d0,12(a0)
	rts

;This Routine sets up playground area but is quite big code
;so here could you re-code to smaller one. And the best thing is to
;swap places with pacman gfx and wall (tube) gfx.

draw_play_ground
	move.w	#0,(max_score)
	moveq	#0,d5
	move.l	#level1,a3
	moveq	#topx,d0
	moveq	#topy,d1
	move.l	#(level_width*level_height)-1,d4
.loop	move.l	#gfx,a0
	move.l	$44e.w,a1
	move.l	#blk16x8,a2
	move.b	(a3)+,d3
	cmp.b	#0,d3
	bne.s	.no_blank
	add.w	#18*8,a0
.no_blank
	cmp.b	#1,d3
	bne.s	.no_godis
	add.w	#13*8,a0
	addq.w	#score_dot,(max_score)
.no_godis
	cmp.b	#8,d3
	bne.s	.no_start
	add.w	#0,a0
.no_start
	cmp.b	#9,d3
	bne.s	.no_red_ghost
	add.w	#9*8,a0
.no_red_ghost
	cmp.b	#2,d3
	bne.s	.vu_kant
	add.w	#16*8,a0
.vu_kant
	cmp.b	#3,d3
	bne.s	.u_kant
	add.w	#11*8,a0
.u_kant
	cmp.b	#4,d3
	bne.s	.hu_kant
	add.w	#17*8,a0
.hu_kant
	cmp.b	#5,d3
	bne.s	.vn_kant
	add.w	#15*8,a0
.vn_kant
	cmp.b	#6,d3
	bne.s	.s_kant
	add.w	#14*8,a0
.s_kant
	cmp.b	#7,d3
	bne.s	.hn_kant
	add.w	#12*8,a0
.hn_kant
	bsr	convert
	add.w	offset,a1
	bsr	blit_sprite	
	addq.w	#8,d0
	addq.w	#8,d5
 	cmp.w	#8*(level_width-1),d5
	ble.s	.no_reset
	moveq	#0,d5
	moveq	#topx,d0
	addq.w	#8,d1
.no_reset
	dbf	d4,.loop
	rts

;In D0-tal f”r att omvandla	

dec	move.l	#score_bin,a0		;vart den f„rdiga v„rdet skall vara
	move.b	#' ',d1
	move.b	d1,(a0)+
	adda.l	#5,a0
	move.w	#4,d1
.loopy	ext.l	d0
	divs	 #10,d0
	swap	d0
	move.b	d0,-(a0)
	add.b	#'0',(a0)
	swap	d0
	dbra	d1,.loopy
*	moveq	#0,d0
	moveq	#6,d6
	move.l	#score_bin,a5
.num	move.b	(a5)+,d0
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	dbf	d6,.num	
	rts

	data
score_bin	dc.l	00000000

	text
text	move.l	a0,-(sp)		;Using Internal Atari Text output
	move.w	#9,-(sp)		;Saves A lot of mem. but very slow.
	trap	#1
	addq.l	#6,sp	
	rts

		bss
old_usp		ds.l	1
offset		ds.w	1
skew		ds.b	1
ani_cnt		ds.b	1
max_score	ds.w	1
score		ds.w	1

		data

right_ani_offs:	dc.w	0,8		;animations offsets
left_ani_offs:	dc.w	16,24	
down_ani_offs:	dc.w	32,40
up_ani_offs:	dc.w	48,56

ani_pointer	dc.l	right_ani_offs		;we start to display 
						;pacman face to the right
pacman_lives	dc.b	num_of_lives

old_pac_pek	dc.l	0
old_pac_x	dc.w	0
old_pac_y	dc.w	0

pacman_pek	dc.l	0
pacman_x	dc.w	0
pacman_y	dc.w	0
ghost_pek	dc.l	0
ghost_x		dc.w	0
ghost_y		dc.w	0
ghost_pek2	dc.l	0
ghost_x2	dc.w	0
ghost_y2	dc.w	0
ghost_pek3	dc.l	0
ghost_x3	dc.w	0
ghost_y3	dc.w	0

temp_x	dc.w	0
temp_y	dc.w	0

;Uses for Blitter

blk16x8	dc.w	2		;COUNT X		(16x8)
	dc.w	8		;SRCINCX
	dc.w	160-((2*8)-8)	;SRCINCY
	dc.w	8		;DESTINCX
	dc.w	160-((2*8)-8)	;DESTINCY
	dc.w	8		;COUNT Y

;Palette of PACMAN.PI1: Saved by NEOchrome V2.10 by Chaos, Inc.
col		dc.w	$0000,$0003,$0770,$0000,$0777,$0BBB,$0BB0,$0AAA
		dc.w	$000F,$0001,$0B00,$0000,$0D00,$0000,$000D,$0777

;uuuuuugghghhh  atari build in text codes (hurry hurry!)

game_over_txt		dc.b	27,'Y',31+10,31+17,'GAME OVER'
			dc.b	0
level_complete_txt	dc.b	27,'Y',31+10,31+14,'LEVEL COMPLETED'
			dc.b	0

ply_score_txt		dc.b	27,'Y',31+11,31+12,'YOUR SCORE :'
			dc.b	0
max_score_txt		dc.b	27,'Y',31+12,31+12,' MAX SCORE :'
			dc.b	0

gfx	incbin	'copyb5.img'	;160*8=1280 bytes (8 pixel height)

;//////////////////////////////////////////////////////////////////////////
;0 - Cleared Square 	1 - Snack
;    __					    __
;2 - |	     		3 - ---		4 -  | 
;5 - |	     		6 - |		7 -  | 
;    --					    --
;8 - START for PACMAN
;9 - Ghost 1		10 - Ghost 2	11 - Ghost 3 
;//////////////////////////////////////////////////////////////////////////
;               1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6 

level1 	dc.b	2,3,3,3,3,3,3,4,0,2,3,3,3,3,3,4,0,0,0,2,3,3,3,3,3,4,0,0,2,3,3,3,3,3,3,4		;1
	dc.b	6,1,1,1,1,1,11,6,0,6,1,1,1,1,1,5,4,0,2,7,1,1,1,1,1,5,4,0,6,1,1,1,10,1,1,6	;2
	dc.b	6,1,2,3,3,3,3,7,0,6,1,2,3,4,1,1,6,0,6,1,1,2,3,4,1,1,6,0,6,1,2,3,3,3,3,7		;3
	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,5,4,1,5,3,7,1,2,7,0,5,4,1,6,0,6,1,6,0,0,0,0,0		;4
	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,0,6,1,1,1,1,1,6,0,0,0,6,1,6,0,6,1,6,0,0,0,0,0		;5
 	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,0,6,1,2,3,4,1,6,0,0,0,5,3,7,0,6,1,6,0,0,0,0,0		;6
	dc.b	6,1,5,3,3,3,3,4,0,6,1,6,0,0,6,1,6,0,6,1,6,0,0,0,0,0,0,0,6,1,5,3,3,3,3,4		;7
	dc.b	6,1,1,1,1,1,1,6,0,6,1,6,0,0,6,1,6,0,6,1,6,0,0,0,0,0,0,0,6,1,1,1,1,1,1,6		;8
	dc.b	6,1,2,3,3,3,3,7,0,6,1,6,0,0,6,1,6,0,6,1,6,0,0,0,0,0,0,0,6,1,2,3,3,3,3,7		;9
 	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,0,6,1,6,0,6,1,6,0,0,0,0,0,0,0,6,1,6,0,0,0,0,0		;10
	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,0,6,1,6,0,6,1,6,0,2,3,3,3,4,0,6,1,6,0,0,0,0,0		;11
	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,0,6,1,6,0,6,1,6,0,6,9,1,1,6,0,6,1,6,0,0,0,0,0		;12
	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,0,6,1,6,0,6,1,6,0,5,3,4,1,6,0,6,1,6,0,0,0,0,0		;13
	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,0,6,1,6,0,6,1,6,0,0,0,6,1,6,0,6,1,6,0,0,0,0,0		;14
	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,0,6,1,6,0,6,1,6,0,0,0,6,1,6,0,6,1,6,0,0,0,0,0		;15
	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,0,6,1,6,0,6,1,6,0,0,0,6,1,6,0,6,1,6,0,0,0,0,0		;16
	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,0,6,1,6,0,6,1,6,0,0,0,6,1,6,0,6,1,6,0,0,0,0,0		;17
	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,0,6,1,6,0,6,1,6,0,0,0,6,1,5,3,7,1,6,0,0,0,0,0		;18
	dc.b	6,1,6,0,0,0,0,0,0,6,1,6,0,2,7,1,6,0,6,1,5,4,0,2,7,1,1,1,1,1,6,0,0,0,0,0		;19
	dc.b	6,1,5,3,3,3,3,3,3,7,1,5,3,7,1,1,6,0,6,1,1,5,3,7,1,1,2,3,4,1,5,3,3,3,3,4		;20
	dc.b	6,1,1,1,1,1,1,1,1,1,8,1,1,1,1,2,7,0,5,4,1,1,1,1,1,2,7,0,6,1,1,1,1,1,1,6		;21
	dc.b	5,3,3,3,3,3,3,3,3,3,3,3,3,3,3,7,0,0,0,5,3,3,3,3,3,7,0,0,5,3,3,3,3,3,3,7		;22

HALFTONE	EQU	$FF8A00
SRCINCX		EQU	$FF8A20
SRCINCY		EQU	$FF8A22
SRCADDR		EQU	$FF8A24
ENDMASK1	EQU	$FF8A28
ENDMASK2	EQU	$FF8A2A 
ENDMASK3	EQU	$FF8A2C
DESTINCX	EQU	$FF8A2E
DESTINCY	EQU	$FF8A30
DESTADDR	EQU	$FF8A32
COUNTX		EQU	$FF8A36
COUNTY		EQU	$FF8A38
HOP		EQU	$FF8A3A
OP		EQU	$FF8A3B
LINENUM		EQU	$FF8A3C
SKEW_ADR	EQU	$FF8A3D

	end