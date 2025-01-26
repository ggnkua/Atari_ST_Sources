* \This code is TOTALLY ORIGINAL and was written by Edd Deegan.
*  You may re-distribute freely (PLEASE DO!) But it must bear my
*  name.

* \This version (3) uses chunkier characters, but is very fast at
*  generating them.

* \This program produces a half-screen character made from 8x8 blocks
*  and uses an 8 pixel scroll using swapped screens.

* \Header for Assembler programs. It basically puts all the available
*  memory at my disposal....
*

setblock:       movea.l A7,A5           * Save stack pointer
                move.l  #my_stack,A7    * Set up my own stack
                movea.l 4(A5),A5        * A5 now points to BasePage
                move.l  $C(A5),D0       * $C(A5) = program area length
                add.l   $14(A5),D0      * $14(A5) = data area length
                add.l   $1C(A5),D0
                add.l   #$100,D0        * Reserve $100 bytes BasePage
                move.l  D0,-(sp)        * D0 = length to be reserved
                move.l  A5,-(sp)        * A5 = start address to reserve
                move.w  #$00,-(sp)      * No meaning
                move.w  #$4A,-(sp)
                trap    #1
                add.l   #12,sp          * Correct the stack
                jmp     end_set         * Jump over my stack!
                ds.l    200             * Space for my stack
my_stack:       ds.l    2               * Stacks go backwards....
                EVEN
end_set:        nop

init:		move.w	#2,-(sp)	* Get physical address
		trap	#14
		addq.l	#2,sp
		move.l	D0,real_phys
		move.l	D0,physic

		move.w	#3,-(sp)	* And logical address
		trap	#14
		addq.l	#2,sp
		move.l	D0,real_log

		move.l	#32000,-(sp)	* Area for character generation
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,b_screen	* Point to area

		move.w	#4,-(sp)	* Get rez
		trap	#14
		addq.l	#2,sp
		move.w	D0,real_rez

		move.l	physic,D0
		sub.l	#32256,D0
		move.l	D0,logic	* Point to a logical screen

		move.l	#$00,-(sp)	* Super mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,save_stack

		jsr	msoff		* Disable mouse

		move.w	#15,D0
		move.l	#$FF8240,A0
		move.l	#old_pal,A1
save_pal:	move.w	(A0)+,(A1)+	* Store old colours
		dbf	D0,save_pal
		move.w	sr,status	* Store status contents
		
		move.w	#$00,-(sp)	* Low rez
		move.l	physic,-(sp)
		move.l	logic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		jsr	clear_all
		jmp	after_clear

clear_all:	move.w	#7999,D0	* Clear screens
		move.l	logic,A0
		move.l	physic,A1
		move.l	b_screen,A2
clear:		clr.l	(A0)+
		clr.l	(A1)+
		clr.l	(A2)+
		dbf	D0,clear
		rts

after_clear	move.w	#$00,$FF8240	* Set to black
		move.w	#$007,$FF8242	* Blue letters
		
		move.w	#$2700,sr	* Disable interrupts

* \Set up the put_char routine

		move.l	#hugetext,A6	* Point to text
		move.l	b_screen,D7	* Screen to place them on
		jsr	set_tables	* Pre-add b_screen to offsets

* \Scroll routine calls go here

		move.l	b_screen,A3	* Point to character screen
		clr.b	even_flag	* Now, A3 --> consecutive words
		
		jsr	put_char
mainloop:	move.w	#11,D4	
test:		jsr	sixteen 		* Scroll screen
		jsr	swap
		dbf	D4,test
		jsr	put_char
		jmp	mainloop


* --> Main routines to do all the work (poor things!)

* \Move screen left by a word in one plane. Fill right hand edge
*  from left hand edge of b_screen, and scroll b_screen left by one byte.

sixteen:	movem.l	D0-D3/A0-A2,-(sp)	* Save registers
		move.l	logic,D3	* Screen to scroll
		add.l	#2400,D3	* Dont need top 15 lines
		clr.l	D2		* Offset
		move.w	#107,D1		* Line counter
	
six_tn:		move.l	D3,A0		* Point to screen
		add.l	D2,A0		* Add in the offset
		move.l	A0,A1
		add.l	#$08,A1		* Point to second word
		move.w	#18,D0		* Word counter
six_tn1:	move.w	(A1),(A0)
		add.l	#$08,A0
		add.l	#$08,A1		* Point to next pair of words
		dbf	D0,six_tn1	* Repeat for whole line
		add.l	#160,D2		* Increase the offset
		dbf	D1,six_tn	

* \Now grab two bytes from A3, and place on logic in last column

		tst.b	even_flag	* Consecutive?
		beq	column_v2

column_v1:	move.l	A3,A4		* Store old A3 address
		clr.b	even_flag	* Next time - even boundary
		move.l	logic,A0	* Point to destination
		add.l	#152,A0		* Point to last column
		move.w	#107,D0		* Line counter
v1_loop:	move.b	(A3),(A0)+
		add.l	#$07,A3
		move.b	(A3),(A0)+	* Done word
		add.l	#158,A0		* Down a line
		add.l	#153,A3		* Point down from orig pos
		dbf	D0,v1_loop
		move.l	A4,A3
		add.l	#$07,A3		* Point to next pair
		movem.l	(sp)+,D0-D3/A0-A2	* Restore 'em
		rts

column_v2:	move.l	A3,A4		* Store A3 address
		move.b	#$01,even_flag	* Next time, spaced bytes
		move.l	logic,A0
		add.l	#152,A0		* Point to destination
		move.w	#107,D0		* Line counter
v2_loop:	move.w	(A3),(A0)	* Move word
		add.l	#160,A3
		add.l	#160,A0		* Down a line
		dbf	D0,v2_loop
		move.l	A4,A3
		add.l	#$01,A3		* Point to next byte
		movem.l	(sp)+,D0-D3/A0-A2	* Restore 'em
		rts
		

* \Take ASCII char and generate a full screen character from it.
*  The character must be generated on screen specified.

* \A6 -> text
* \D7 -> screen address

put_char:	move.l	b_screen,A3	* Reset pointer for scroll
		clr.b	even_flag
		clr.w	count		* Reset counter
		tst.b	(A6)
		beq	reset
		cmp.b	#$20,(A6)	* Space?
		beq	put_space
		cmp.b	#63,(A6)
		beq	put_ques
		cmp.b	#33,(A6)
		beq	put_excl
		cmp.b	#46,(A6)
		beq	put_full
		cmp.b	#44,(A6)
		beq	put_comm
		cmp.b	#40,(A6)
		beq	put_openb
		cmp.b	#41,(A6)
		beq	put_closeb	
do_char:	move.b	(A6)+,D6	* Get character
		cmp.b	#70,D6		* A-F?
		ble	a_f
		cmp.b	#76,D6		* G-L?
		ble	g_l
		cmp.b	#82,D6		* M-R?
		ble	m_r
		cmp.b	#88,D6		* S-X?
		ble	s_x

		jmp	y_z

reset:		move.l	#hugetext,A6
		jmp	do_char
put_space:	move.l	#space_dat,A0
		add.l	#$01,A6		* Point past the space
		jmp	do_list
put_ques:	move.l	#ques_dat,A0
		add.l	#$01,A6
		jmp	do_list
put_excl:	move.l	#excl_dat,A0
		add.l	#$01,A6
		jmp	do_list
put_full:	move.l	#full_dat,A0
		add.l	#$01,A6
		jmp	do_list
put_comm:	move.l	#comm_dat,A0
		add.l	#$01,A6
		jmp	do_list
put_openb:	move.l	#openb_dat,A0
		add.l	#$01,A6
		jmp	do_list
put_closeb:	move.l	#closeb_dat,A0
		add.l	#$01,A6
		jmp	do_list

a_f:		cmp.b	#65,D6		* A?
		beq	put_a
		cmp.b	#66,D6
		beq	put_b
		cmp.b	#67,D6
		beq	put_c
		cmp.b	#68,D6
		beq	put_d
		cmp.b	#69,D6
		beq	put_e	
		cmp.b	#70,D6
		beq	put_f
g_l:		cmp.b	#71,D6
		beq	put_g
		cmp.b	#72,D6
		beq	put_h
		cmp.b	#73,D6
		beq	put_i
		cmp.b	#74,D6
		beq	put_j
		cmp.b	#75,D6
		beq	put_k
		cmp.b	#76,D6
		beq	put_l
m_r:		cmp.b	#77,D6
		beq	put_m
		cmp.b	#78,D6
		beq	put_n
		cmp.b	#79,D6
		beq	put_o
		cmp.b	#80,D6
		beq	put_p
		cmp.b	#81,D6
		beq	put_q
		cmp.b	#82,D6
		beq	put_r
s_x:		cmp.b	#83,D6
		beq	put_s
		cmp.b	#84,D6
		beq	put_t
		cmp.b	#85,D6
		beq	put_u
		cmp.b	#86,D6
		beq	put_v
		cmp.b	#87,D6
		beq	put_w
		cmp.b	#88,D6
		beq	put_x
y_z:		cmp.b	#89,D6
		beq	put_y
		jmp	put_z

put_a:		move.l	#a_data,A0	* Point to data
		jmp	do_list	
put_b:		move.l	#b_data,A0
		jmp	do_list
put_c:		move.l	#c_data,A0
		jmp	do_list
put_d:		move.l	#d_data,A0
		jmp	do_list
put_e:		move.l	#e_data,A0
		jmp	do_list
put_f:		move.l	#f_data,A0
		jmp	do_list
put_g:		move.l	#g_data,A0
		jmp	do_list
put_h:		move.l	#h_data,A0
		jmp	do_list
put_i:		move.l	#i_data,A0
		jmp	do_list
put_j:		move.l	#j_data,A0
		jmp	do_list
put_k:		move.l	#k_data,A0
		jmp	do_list
put_l:		move.l	#l_data,A0
		jmp	do_list
put_m:		move.l	#m_data,A0
		jmp	do_list
put_n:		move.l	#n_data,A0
		jmp	do_list
put_o:		move.l	#o_data,A0
		jmp	do_list
put_p:		move.l	#p_data,A0
		jmp	do_list
put_q:		move.l	#q_data,A0
		jmp	do_list
put_r:		move.l	#r_data,A0
		jmp	do_list
put_s:		move.l	#s_data,A0
		jmp	do_list
put_t:		move.l	#t_data,A0
		jmp	do_list
put_u:		move.l	#u_data,A0
		jmp	do_list
put_v:		move.l	#v_data,A0
		jmp	do_list
put_w:		move.l	#w_data,A0
		jmp	do_list
put_x:		move.l	#x_data,A0
		jmp	do_list
put_y:		move.l	#y_data,A0
		jmp	do_list
put_z:		move.l	#z_data,A0
		jmp	do_list
		rts


* ---> Address lists for characters

const_ads:	dc.l	2568,2576,2584,2592,2600
		dc.l	3848,3856,3864,3872,3880
		dc.l	5128,5136,5144,5152,5160
		dc.l	6408,6416,6424,6432,6440
		dc.l	7688,7696,7704,7712,7720
		dc.l	8968,8976,8984,8992,9000
		dc.l	10248,10256,10264,10272,10280
		dc.l	11528,11536,11544,11552,11560
		dc.l	12808,12816,12824,12832,12840
		dc.l	14088,14096,14104,14112,14120
		dc.l	15368,15376,15384,15392,15400
		dc.l	16648,16656,16664,16672,16680
		dc.l	$9999
		

* \Take a list of constant addresses in A1, and a list of flags in A0.
*  Place a 8x8 block if flag is 1, else clear 8x8 block

do_list:	move.w	#59,D0		* No. of blocks (12x5)
		move.l	#const_ads,A1	* Point to list of addreses
do_loop:	tst.b	(A0)+		* Check flag
		beq	clear_block	* If 0, clear block
put_block:	move.w	#3,D1		* Line counter
		move.l	(A1)+,A2	* Working copy of address
put_loop:	move.w	#$F0F0,(A2)	* Color block
		add.l	#160,A2		* Down a line
		dbf	D1,put_loop	* Rest of block
		dbf	D0,do_loop	* Repeat for all blocks
		rts
clear_block:	move.w	#7,D1
		move.l	(A1)+,A2
clear_loop:	clr.w	(A2)
		add.l	#160,A2
		dbf	D1,clear_loop
		dbf	D0,do_loop	* Repeat for all blocks
		rts			
	

swap:		move.w	physic2,D0

wait_vbl:	move.b	$FF8207,video1
		move.b	$FF8209,video2
		cmp.w	video1,D0
		beq	end_vbl
		jmp	wait_vbl

end_vbl:	move.w	#-1,-(sp)	* Leave rez
		move.l	logic,-(sp)	* Swap screens
		move.l	physic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	physic,temp
		move.l	logic,physic
		move.l	temp,logic	* Swap pointers
		move.w	status,sr
		move.b	$FFFC02,D0	* Look at keyboard
		cmp.b	#$39,D0		* SPACE?
		beq	to_gem
		move.w	#$2700,sr	* Disable interrupts
		rts


to_gem:		move.w	status,sr	* Restore status reg
		move.w	real_rez,-(sp)	* Restore rez
		move.l	real_phys,-(sp)	* Restore physical screen
		move.l	real_log,-(sp)	* And logical screen
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	b_screen,-(sp)	* Release character area
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp

		move.w	#15,D0		* Restore colours
		move.l	#$FF8240,A0
		move.l	#old_pal,A1
restore_pal:	move.w	(A1)+,(A0)+
		dbf	D0,restore_pal
		jsr	mson		* Restore mouse

		move.l	save_stack,-(sp)	* User mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		clr.l	-(sp)
		trap	#1		 * Bye bye (at last!)

* \Subroutine to pre-add the b_screen value to all the tables
*  starting at a_data

set_tables:	move.l	#const_ads,A0	* Pointer to table
		move.l	b_screen,D7	* Value to add
set_loop:	move.l	(A0),D1		* Get offset
		add.l	D7,D1		* Add b_screen address
		move.l	D1,(A0)+	* Place back in table
		cmp.l	#$9999,(A0)	* End of table?
		beq	set_end
		jmp	set_loop
set_end:	rts

msoff:	        move.l  #moff,-(sp)      * Disable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A00A
		rts
                
mson:		move.l  #mon,-(sp)       * Re-enable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A009
		rts
mon:            dc.b    $08
moff:           dc.b    $12

space_dat:	dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0

ques_dat:	dc.b	0,1,1,1,0
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,1,1
		dc.b	0,0,1,1,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0


excl_dat:	dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0


full_dat:	dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,1,0,0,0
		dc.b	0,1,0,0,0

comm_dat:	dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,0,0
		dc.b	0,0,0,1,0
		dc.b	0,0,0,1,0
		dc.b	0,0,1,0,0

openb_dat:	dc.b	0,0,1,0,0
		dc.b	0,1,1,0,0
		dc.b	1,1,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,1,0,0,0
		dc.b	0,1,1,0,0
		dc.b	0,0,1,0,0

closeb_dat:	dc.b	0,0,1,0,0
		dc.b	0,0,1,1,0
		dc.b	0,0,0,1,1
		dc.b	0,0,0,0,1
		dc.b	0,0,0,0,1
		dc.b	0,0,0,0,1
		dc.b	0,0,0,0,1
		dc.b	0,0,0,0,1
		dc.b	0,0,0,0,1
		dc.b	0,0,0,1,1
		dc.b	0,0,1,1,0
		dc.b	0,0,1,0,0

a_data:		dc.b	0,1,1,1,0
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
	
b_data:		dc.b	1,1,1,1,0
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,1,1,0
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,0


c_data:		dc.b	0,1,1,1,1
		dc.b	1,1,1,1,1
		dc.b	1,1,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,1,0,0,0
		dc.b	0,1,1,1,1
		dc.b	0,1,1,1,1

d_data:		dc.b	1,1,1,1,0
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,0

e_data:		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,1,1,1,0
		dc.b	1,1,1,1,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,1

f_data:		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,1,1,1,0
		dc.b	1,1,1,1,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0


g_data:		dc.b	0,1,1,1,1
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,1,1,1
		dc.b	1,0,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,1,1,1
		dc.b	0,1,1,1,1

h_data:		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1

i_data:		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,1
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,1

j_data:		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,1
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	1,0,1,0,0
		dc.b	1,1,1,0,0
		dc.b	1,1,10,0,0

k_data:		dc.b	1,0,0,0,1
		dc.b	1,0,0,1,1
		dc.b	1,0,0,1,0
		dc.b	1,0,1,0,0
		dc.b	1,0,1,0,0
		dc.b	1,1,0,0,0
		dc.b	1,1,0,0,0
		dc.b	1,0,1,0,0
		dc.b	1,0,1,0,0
		dc.b	1,0,0,1,0
		dc.b	1,0,0,1,1
		dc.b	1,0,0,0,1

l_data:		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,1

m_data:		dc.b	1,1,0,1,1
		dc.b	1,1,1,1,1
		dc.b	1,0,1,0,1
		dc.b	1,0,1,0,1
		dc.b	1,0,1,0,1
		dc.b	1,0,1,0,1
		dc.b	1,0,1,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1

n_data:		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,0,0,1
		dc.b	1,1,1,0,1
		dc.b	1,0,1,1,1
		dc.b	1,0,0,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1

o_data:		dc.b	0,1,1,1,0
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,1,1,1
		dc.b	0,1,1,1,0

p_data:		dc.b	1,1,1,1,0
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0

q_data:		dc.b	0,1,1,1,0
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,1,0,1
		dc.b	1,0,1,1,1
		dc.b	1,0,0,1,1
		dc.b	1,1,1,1,1
		dc.b	0,1,1,1,1

r_data:		dc.b	1,1,1,1,0
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,0
		dc.b	1,0,0,1,0
		dc.b	1,0,0,1,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1

s_data:		dc.b	0,1,1,1,1
		dc.b	1,1,1,1,1
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,0,0,0,0
		dc.b	1,1,1,1,0
		dc.b	0,1,1,1,1
		dc.b	0,0,0,0,1
		dc.b	0,0,0,0,1
		dc.b	0,0,0,0,1
		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,0

t_data:		dc.b	1,1,1,1,1
		dc.b	1,1,1,1,1
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0

u_data:		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,1,1,1
		dc.b	0,1,1,1,0

v_data:		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,1,1,1,1
		dc.b	0,1,1,1,0
		dc.b	0,0,1,0,0

w_data:		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,1,0,1
		dc.b	1,0,1,0,1
		dc.b	1,0,1,0,1
		dc.b	1,0,1,0,1
		dc.b	1,0,1,0,1
		dc.b	1,0,1,0,1
		dc.b	1,1,1,1,1
		dc.b	1,1,0,1,1

x_data:		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	0,1,0,1,0
		dc.b	0,1,0,1,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,1,0,1,0
		dc.b	0,1,0,1,0
		dc.b	0,1,0,1,0
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1

y_data:		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	1,0,0,0,1
		dc.b	0,1,0,1,0
		dc.b	0,1,0,1,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0

z_data:		dc.b	1,1,1,1,0
		dc.b	1,1,1,1,0
		dc.b	0,0,0,1,0
		dc.b	0,0,0,1,0
		dc.b	0,0,0,1,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,0,1,0,0
		dc.b	0,1,0,0,0
		dc.b	1,1,0,0,0
		dc.b	1,1,1,1,0
		dc.b	1,1,1,1,0

*****************************

real_phys:	ds.l	1
real_log:	ds.l	1
real_rez:	ds.w	1
physic:		ds.w	1
physic2:	ds.w	1
logic:		ds.l	1
b_screen:	ds.l	1
save_stack:	ds.l	1
status:		ds.w	1
old_pal:	ds.w	16
video1:		ds.b	1
video2:		ds.b	1
temp:		ds.l	1
count:		ds.w	1
even_flag:	dc.b	0

hugetext:	dc.b	"   A FEW NOTES ABOUT THIS DISK!        "
		DC.B	"IT CONTAINS A FEW OF MY ROUTINES, AND A "
		DC.B	"FEW GRAPHICS FILES TO GO WITH THEM. THE "
		DC.B	"SOURCE CODE FOR ALL ROUTINES IS ON THE "
		DC.B	"DISK UNDER THE SAME NAME AS THE ASSEMBLED "
		DC.B	"VERSIONS.   !!WARNING!! ..... THESE ROUTINES "
		DC.B	"WERE MOSTLY WRITTEN BEFORE THE STE CAME ALONG "
		DC.B	"AND USE NAUGHTY LOCATIONS. THEREFORE STE OWNERS "
		DC.B	"WILL HAVE TO MODIFY THE SOURCE CODE..... THERE "
		DC.B	"IS A DOC FILE ON THIS DISK WHERE I HAVE SUGGESTED "
		DC.B	"WHERE CHANGES MIGHT HAVE TO BE MADE...... THIS "
		DC.B	"DISK WAS FIRST GIVEN TO TORBJORN OSE.  ALL REDISTRIBUTION "
		DC.B	"MUST BEAR MY NAME....        (WRAP..)     ",0
