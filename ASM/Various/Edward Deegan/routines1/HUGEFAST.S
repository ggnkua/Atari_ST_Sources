* This code was written by Edd Deegan, redistribution is encouraged,
* but must bear my name...

* \This version scrolls VERY FAST but the fetch routine to fill the
*  gap created is much faster.

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
		jmp	show

clear_all:	move.w	#7999,D0	* Clear screens
		move.l	b_screen,A2
clear:		clr.l	(A2)+
		dbf	D0,clear
		rts

show:		move.l	#pic_buf,A0	* Palette
		add.l	#$02,A0
		move.l	A0,-(sp)
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp

		move.w	#7999,D0
		move.l	#pic_buf,A0
		add.l	#34,A0
		move.l	logic,A1
		move.l	physic,A2
show_loop:	move.l	(A0),(A1)+
		move.l	(A0)+,(A2)+
		dbf	D0,show_loop

		move.w	#$007,$FF8242	* Blue characters

		move.w	#3999,D0	* Clear plane1
		move.l	physic,A0
		move.l	logic,A1
clear_1:	clr.w	(A0)
		clr.w	(A1)
		add.l	#$08,A0
		addq.l	#$08,A1
		dbf	D0,clear_1


		move.l	#const_adds,A0
		move.l	b_screen,D0
set_loop:	move.l	(A0),D1
		add.l	D0,D1
		move.l	D1,(A0)+
		cmp.l	#$9999,(A0)	* End of table?
		beq	done_set
		jmp	set_loop

done_set:	move.w	#$2700,sr	* Disable interrupts

* \Set up the put_char routine

		move.l	#hugetext,A6	* Point to text
		move.l	b_screen,D7	* Screen to place them on

* \Scroll routine calls go here

		move.l	b_screen,A3	* Point to character screen
		clr.b	even_flag	* Now, A3 --> consecutive words
		
		jsr	put_char
mainloop:	move.w	#8,D4	
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
		add.l	#2560,D3
		clr.l	D2		* Offset
		move.w	#184,D1		* Line counter
	
six_tn:		move.l	D3,A0		* Point to screen
		add.l	D2,A0		* Add in the offset
		move.l	A0,A1
		lea	16(A1),A1	* Point to fourth word
		move.w	#8,D0		* Word counter
six_tn1:	move.w	(A1),(A0)
		lea	8(A0),A0
		lea	8(A1),A1	* Point to next pair of words
		move.w	(A1),(A0)	* Copy them
		lea	8(A0),A0
		lea	8(A1),A1	* Point to next words
		dbf	D0,six_tn1	* Repeat for whole line
		add.l	#160,D2		* Increase the offset
		dbf	D1,six_tn	

* \Now grab two words from A3, and place on logic in last column

		move.l	A3,A4		* Store old A3 value
		move.l	logic,A1
		lea	144(A1),A1	* Point to last column
		move.w	#181,D1		* Line counter

fill:		move.w	(A3),(A1)	* Place on screen
		lea	8(A1),A1	* Next gap
		lea	8(A3),A3	* Similarly, next gap
		move.w	(A3),(A1)
		lea	152(A1),A1	* Down a line	
		lea	152(A3),A3	* Down a line
		dbf	D1,fill
		move.l	A4,A3		
		lea	8(A3),A3	* Next time from two words further
		
		movem.l	(sp)+,D0-D3/A0-A2	* Restore 'em
		rts
		

* \Take ASCII char and generate a full screen character from it.
*  The character must be generated on screen specified.

* \A6 -> text
* \D7 -> screen address

put_char:	move.l	b_screen,A3
		clr.b	even_flag
		clr.w	count		* Reset counter
		tst.b	(A6)		* End of text?
		beq	reset
		cmp.b	#$20,(A6)	* Space?
		beq	put_space
		clr.l	D6
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

reset:		lea	hugetext,A6
		jmp	do_char
put_space:	lea	space_dat,A0
		lea	1(A6),A6
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
		jmp	put_a

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
		cmp.b	#90,D6
		beq	put_z

put_a:		lea	a_data,A0	* Point to data
		jmp	do_list	
put_b:		lea	b_data,A0
		jmp	do_list
put_c:		lea	c_data,A0
		jmp	do_list
put_d:		lea	d_data,A0
		jmp	do_list
put_e:		lea	e_data,A0
		jmp	do_list
put_f:		lea	f_data,A0
		jmp	do_list
put_g:		lea	g_data,A0
		jmp	do_list
put_h:		lea	h_data,A0
		jmp	do_list
put_i:		lea	i_data,A0
		jmp	do_list
put_j:		lea	j_data,A0
		jmp	do_list
put_k:		lea	k_data,A0
		jmp	do_list
put_l:		lea	l_data,A0
		jmp	do_list
put_m:		lea	m_data,A0
		jmp	do_list
put_n:		lea	n_data,A0
		jmp	do_list
put_o:		lea	o_data,A0
		jmp	do_list
put_p:		lea	p_data,A0
		jmp	do_list
put_q:		lea	q_data,A0
		jmp	do_list
put_r:		lea	r_data,A0
		jmp	do_list
put_s:		lea	s_data,A0
		jmp	do_list
put_t:		lea	t_data,A0
		jmp	do_list
put_u:		lea	u_data,A0
		jmp	do_list
put_v:		lea	v_data,A0
		jmp	do_list
put_w:		lea	w_data,A0
		jmp	do_list
put_x:		lea	x_data,A0
		jmp	do_list
put_y:		lea	y_data,A0
		jmp	do_list
put_z:		lea	z_data,A0
		jmp	do_list
		rts


* ---> Address lists for characters

const_adds:	dc.l	2568,2576,2584,2592,2600,2608,2616
		dc.l	5128,5136,5144,5152,5160,5168,5176
		dc.l	7688,7696,7704,7712,7720,7728,7736
		dc.l	10248,10256,10264,10272,10280,10288,10296
		dc.l	12808,12816,12824,12832,12840,12848,12856
		dc.l	15368,15376,15384,15392,15400,15408,15416
		dc.l	17928,17936,17944,17952,17960,17968,17976
		dc.l	20488,20496,20504,20512,20520,20528,20536
		dc.l	23048,23056,23064,23072,23080,23088,23096
		dc.l	25608,25616,25624,25632,25640,25648,25656
		dc.l	28168,28176,28184,28192,28200,28208,28216
		dc.l	$9999

space_dat:	dc.b	0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0

a_data:		dc.b	0,1,1,1,1,1,0
		dc.b	1,1,1,0,1,1,1
		dc.b	1,1,0,0,0,1,1		
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1		
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,1		
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1		
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1		

b_data:		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,0
		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,0,0,0,1,0
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,0


c_data:		dc.b	0,0,1,1,1,0,0
		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,1,0,0,1,1
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,1,0,0,1,1
		dc.b	1,1,1,1,1,1,0
		dc.b	0,0,1,1,1,0,0

d_data:		dc.b	1,1,1,1,1,0,0
		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,0,0

e_data:		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,1,1,1,0,0
		dc.b	1,1,1,1,1,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,1


f_data:		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,1,1,1,0,0
		dc.b	1,1,1,1,1,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0

g_data:		dc.b	0,0,1,1,1,1,1
		dc.b	0,1,1,1,1,1,1
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,1,1,1,1
		dc.b	1,1,0,1,1,1,1
		dc.b	1,1,0,0,1,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,1,0,1,1,1
		dc.b	0,1,1,0,1,1,0
		dc.b	0,0,1,1,1,0,0

h_data:		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1

i_data:		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,0

j_data:		dc.b 	1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	0,0,0,0,0,1,1
		dc.b	0,0,0,0,0,1,1
		dc.b	0,0,0,0,0,1,1
		dc.b	0,0,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,1,0,0,1,1
		dc.b	0,1,1,1,1,1,1
		dc.b	0,1,1,1,1,1,1


k_data:		dc.b	1,1,0,0,0,1,0
		dc.b	1,1,0,0,1,1,0
		dc.b	1,1,0,1,1,0,0
		dc.b	1,1,1,1,0,0,0
		dc.b	1,1,1,0,0,0,0
		dc.b	1,1,1,0,0,0,0
		dc.b	1,1,1,1,0,0,0
		dc.b	1,1,0,1,1,0,0
		dc.b	1,1,0,0,1,1,0
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1

l_data:		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,1

m_data:		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,1,0,1,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1

n_data:		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,1,0,0,1,1
		dc.b	1,1,1,0,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,0,1,1,1
		dc.b	1,1,0,0,1,1,1
		dc.b	1,1,0,0,0,1,1

o_data:		dc.b	0,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,0,1,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,1,0,1,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	0,1,1,1,1,1,0

p_data:		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,0,0,1,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,1,1,1
		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0

q_data:		dc.b	0,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,0,1,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,1,1,1,1
		dc.b	1,1,1,0,1,1,1
		dc.b	0,1,1,1,1,1,1

r_data:		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,0,0,1,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,1,1,1
		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,0,0,1,1,0
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1

s_data:		dc.b	0,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0
		dc.b	0,1,1,1,1,1,0
		dc.b	0,0,1,1,1,1,1
		dc.b	0,0,0,0,0,1,1
		dc.b	0,0,0,0,1,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,0

t_data:		dc.b	1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0

u_data:		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,1,0,1,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	0,1,1,1,1,1,0

v_data:		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	0,1,1,0,1,1,0
		dc.b	0,0,1,1,1,0,0
		dc.b	0,0,0,1,0,0,0

w_data:		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,0,1,0,1,1
		dc.b	1,1,1,0,1,1,1
		dc.b	1,1,0,0,0,1,1

x_data:		dc.b	1,1,0,0,0,1,1
		dc.b	1,1,1,0,1,1,1
		dc.b	0,1,1,0,1,1,0
		dc.b	0,1,1,1,1,1,0
		dc.b	0,0,1,1,1,0,0
		dc.b	0,0,1,1,1,0,0
		dc.b	0,0,1,1,1,0,0
		dc.b	0,0,1,1,1,0,0
		dc.b	0,1,1,0,1,1,0
		dc.b	0,1,1,0,1,1,0
		dc.b	1,1,0,0,0,1,1

y_data:		dc.b	1,1,0,0,1,1,0
		dc.b	1,1,0,0,1,1,0
		dc.b	1,1,0,0,1,1,0
		dc.b	1,1,0,0,1,1,0
		dc.b	1,1,0,0,1,1,0
		dc.b	0,1,1,1,1,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0

z_data:		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,1
		dc.b	0,0,0,0,0,1,1
		dc.b	0,0,0,0,1,1,0
		dc.b	0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0
		dc.b	0,1,1,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,0,0,0,0,0
		dc.b	1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,1


* \Take a list of addresses, and place a 16x16 block at each
*  until $02 is reached.
* \If address in A0 = 0 then clear block, else put block

do_list:	move.w	#$FFFF,D3
		lea	const_adds,A1	* Point to constant adds
		move.l	#76,D1		* No of blocks

do_list2:	move.l	(A1)+,A2	* Get address
		tst.b	(A0)+		* A0 --> Char data
		beq	clear_block

put_block:	moveq.w	#15,D0		* Line counter
		move.w	D3,(A2)
		lea	160(A2),A2
		move.w	D3,(A2)
		lea	160(A2),A2
		move.w	D3,(A2)
		lea	160(A2),A2
		move.w	D3,(A2)
		lea	160(A2),A2
		move.w	D3,(A2)
		lea	160(A2),A2
		move.w	D3,(A2)
		lea	160(A2),A2
		move.w	D3,(A2)
		lea	160(A2),A2
		move.w	D3,(A2)
		dbf	D1,do_list2
		rts

clear_block:	move.w	#15,D0
		clr.w	(A2)
		lea	160(A2),A2
		clr.w	(A2)
		lea	160(A2),A2
		clr.w	(A2)
		lea	160(A2),A2
		clr.w	(A2)
		lea	160(A2),A2
		clr.w	(A2)
		lea	160(A2),A2
		clr.w	(A2)
		lea	160(A2),A2
		clr.w	(A2)
		lea	160(A2),A2
		clr.w	(A2)
		dbf	D1,do_list2
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
		lea	12(A7),A7

		move.l	physic,temp
		move.l	logic,physic
		move.l	temp,logic	* Swap pointers
		move.w	status,sr
		move.b	$FFFC02,D0	* Look at keyboard
		cmp.b	#$39,D0		* SPACE?
		beq	to_gem
		move.w	#$2700,sr	* Disable interrupts
		rts

debug:		movem.l	A0-A2/D0-D2,-(sp)
		move.w	status,sr
		move.w	#$08,-(sp)
		trap	#1
		addq.l	#2,sp
		move.w	#$2700,sr
		movem.l	(sp)+,A0-A2/D0-D2
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

hugetext:	dc.b	"   VERY FAST SCROLLER    USE IT IF YOU LIKE    "

pic_buf:	INCBIN	"HUGEBACK.PI1",0
