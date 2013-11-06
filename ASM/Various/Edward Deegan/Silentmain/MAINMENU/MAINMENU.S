setblock:	movea.l A7,A5		* Save stack pointer
		move.l	#my_stack,A7	* Set up my own stack
		movea.l 4(A5),A5	* A5 now points to BasePage
		move.l	$C(A5),D0	* $C(A5) = program area length
		add.l	$14(A5),D0	* $14(A5) = data area length
		add.l	$1C(A5),D0
		add.l	#$100,D0	* Reserve $100 bytes BasePage
		move.l	D0,-(sp)	* D0 = length to be reserved
		move.l	A5,-(sp)	* A5 = start address to reserve
		move.w	#$00,-(sp)	* No meaning
		move.w	#$4A,-(sp)
		trap	#1
		add.l	#12,sp		* Correct the stack
		jmp	end_set 	* Jump over my stack!
		ds.l	200		* Space for my stack
my_stack:	ds.l	2		* Stacks go backwards....
		EVEN
end_set:	nop


		move.l	#$00,-(sp)	* Super mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,save_stack

		move.w	#3,-(sp)	* Get Logbase
		trap	#14
		addq.l	#2,sp
		move.l	D0,real_log

		move.w	#4,-(sp)	* Get rez
		trap	#14
		addq.l	#2,sp
		move.w	D0,old_rez
		jsr	msoff		* Disable rodent

		move.l	#$FF8240,A0	* Store old colours
		move.l	#old_pal,A1
		move.l	#15,D0
store_cols:	move.w	(A0)+,(A1)+
		dbf	D0,store_cols

		move.w	#2,-(sp)	* Get Physbase
		trap	#14
		addq.l	#2,sp
		move.l	D0,real_phys

		move.l	real_phys,D0
		sub.l	#6400,D0	* Space for lower border
		move.l	D0,physic
		sub.l	#32256,D0
		move.l	D0,logic

		move.w	#$00,-(sp)
		move.l	physic,-(sp)
		move.l	logic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

master: 	move.b	#53,point1
		move.b	#44,point2
		move.b	#2,v_logo
		
		move.l	real_phys,D0
		sub.l	#6400,D0	* Space for lower border
		move.l	D0,physic
		sub.l	#32256,D0
		move.l	D0,logic

		move.w	#-1,-(sp)	* Leave rez
		move.l	physic,-(sp)
		move.l	logic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

show:		move.l	physic,A0
		move.l	#menu_pic,A1
		add.l	#34,A1
		move.l	#7999,D0
show_loop:	move.l	(A1)+,(A0)+
		dbf	D0,show_loop

		move.l	#1599,D0
clear_lo:	clr.l	(A0)+
		dbf	D0,clear_lo

		move.l	#menu_pic,A0
		add.l	#2,A0
		move.l	A0,-(sp)
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp		* Set palette
	
	
pre_add:	move.l	#table1,A0
		move.l	#images_1,A1	
		add.l	#34,A1		* Point past header

pre_loop:	move.l	(A0),D0
		add.l	A1,D0
		move.l	D0,(A0)
		add.l	#$04,A0
		cmp.l	#$9999,(A0)	* End of table?
		beq	pre_add2
		jmp	pre_loop

pre_add2:	move.l	#table2,A0
		move.l	#images_2,A1
		add.l	#34,A1		* Point past header

pre_loop2:	move.l	(A0),D0
		add.l	A1,D0
		move.l	D0,(A0)
		add.l	#$04,A0
		cmp.l	#$9999,(A0)
		beq	done_adds2
		jmp	pre_loop2

* \Pre-add copy data...
done_adds2:	move.l	#copy_data,A0
		lea	4(A0),A0
		move.l	physic,D0
loop3:		move.l	(A0),D1
		add.l	D0,D1		* Create actual address
		move.l	D1,(A0) 	* Put back into table
		add.l	#$04,A0 	* Point to next table entry
		cmp.l	#$99,(A0)	* EOT?
		beq	loop4
		bra.s	loop3

loop4:		move.l	#vob_data,A0	* Point to table
		lea	4(A0),A0	* Point past first entry
		move.l	physic,D0	* Number to add to all table contents
		add.l	#6,D0		* Addition factor
loop5:		move.l	(A0),D1 	* Table entry into D1	
		add.l	D0,D1		* Add physic to it
		move.l	D1,(A0)
		lea	4(A0),A0	* Point to next entry
		cmp.l	#98,(A0)	* EOT?
		beq	loopexit	* If so, end
		bra.s	loop5
		
loopexit:	move.l	logic,A0
		lea	16000(A0),A0	
		move.l	A0,vlogo_ptr

		move.l	#copy_data,A0
		add.l	#$04,A0
		move.l	A0,copy_ptr	* First item
		move.l	#vob_data,A0
		add.l	#$04,A0 	* First item
		move.l	A0,vob_ptr		

		move.w	sr,status	
		jsr	hblon

* \Now move the letters into the lower border....

		move.l	#5000,D0
delay:		move.l	#1234,D1
		mulu	#123,D1
		jsr	wait_vbl
		dbf	D0,delay

		move.l	physic,A1	* Point to screen
		add.l	#24480,A1	* Point to logo
		move.l	logic,A2	* Point to screen
		add.l	#8000,A2	* Point to storage
		move.l	A2,A5
		
		move.l	#1479,D0
get_logo_lp:	move.l	(A1)+,(A2)+
		dbf	D0,get_logo_lp

		move.l	physic,A3
		add.l	#24480,A3
	
		move.l	#46,D1
call_logo:	move.l	A3,A1
		jsr	wait_vbl
		jsr	put_logo
		add.l	#160,A3
		dbf	D1,call_logo
		
		move.b	#96,point1
		move.b	#1,point2
	
* \Now Store VOBRIEN on logical screen
* \Logo is stored in a sequence of words, NOT  as a proper image!

		move.l	physic,A0	* Point to logo
		move.l	logic,A1	* Storage
		add.l	#16000,A1
		move.l	A1,vobstore	* Point to storage
		move.l	#1999,D0	* Chunk counter
		lea	6(A0),A0	* Point to 4th plane
vob_store:	move.w	(A0),(A1)+	* Store consecutively
		lea	8(A0),A0	* Next chunk in plane
		dbf	D0,vob_store
		jmp	dist

* \Subroutine to copy logo
* \Destination in A1

put_logo:	move.l	#1479,D0
		move.l	A5,A2
put_logo1:	move.l	(A2)+,(A1)+
		dbf	D0,put_logo1
		rts

* \Routine to distort a 160x41 logo

dist:		move.l	#put_list,A3	* Point to list
call_loop:	clr.l	D0
		clr.l	D1
		clr.l	D2
		cmp.b	#$99,(A3)	* End of table?
		beq	reset
		cmp.b	#$FF,(A3)	* Copy request?
		beq	copy_logo
		
		move.b	(A3)+,D0	* Line no#
		move.b	(A3)+,D1	* Screen #
		move.b	(A3)+,D2	* image #
		
after_check:	jsr	get_address
		jmp	call_loop

reset:		lea	list_loop,A3
		jmp	after_check

copy_logo:	jsr	wait_vbl
		jsr	copy
		addq.l	#$01,A3 	* Point past request
		bra.s	call_loop

* --> Format! = line#,screen#,image#

* \First place the logo!

put_list:	dc.b	0,1,0,1,1,0,2,1,0,3,1,0,4,1,0,5,1,0,6,1,0
		dc.b	7,1,0,8,1,0,9,1,0,10,1,0,11,1,0,12,1,0,13,1,0
		dc.b	14,1,0,15,1,0,16,1,0,17,1,0,18,1,0,19,1,0,20,1,0
		dc.b	21,1,0,22,1,0,23,1,0,24,1,0,25,1,0,26,1,0,27,1,0
		dc.b	28,1,0,29,1,0,30,1,0,31,1,0,32,1,0,33,1,0,34,1,0
		dc.b	35,1,0,36,1,0,37,1,0,38,1,0,39,1,0,40,1,0
		dc.b	$FF
		EVEN
exec_list:	dc.b	0,1,1,$FF
		dc.b	0,1,2,1,1,1,$FF
		dc.b	0,1,3,1,1,2,2,1,1,$FF
		dc.b	0,1,4,1,1,3,2,1,2,3,1,1,$FF
		dc.b	0,1,5,1,1,4,2,1,3,3,1,2,4,1,1,$FF
		dc.b	0,1,6,1,1,5,2,1,4,3,1,3,4,1,2,5,1,1,$FF
		dc.b	0,1,7,1,1,6,2,1,5,3,1,4,4,1,3,5,1,2,6,1,1,$FF
		dc.b	0,2,0,1,1,7,2,1,6,3,1,5,4,1,4,5,1,3,6,1,2,7,1,1,$FF
		dc.b	0,2,1,1,2,0,2,1,7,3,1,6,4,1,5,5,1,4,6,1,3,7,1,2,8,1,1,$FF
		dc.b	0,2,2,1,2,1,2,2,0,3,1,7,4,1,6,5,1,5,6,1,4,7,1,3,8,1,2,9,1,1,$FF
		dc.b	0,2,3,1,2,2,2,2,1,3,2,0,4,1,7,5,1,6,6,1,5,7,1,4,8,1,3,9,1,2
		dc.b	10,1,1,$FF
		
		dc.b	0,2,4,1,2,3,2,2,2,3,2,1,4,2,0,5,1,7,6,1,6,7,1,5,8,1,4,9,1,3
		dc.b	10,1,2,11,1,1,$FF

		dc.b	0,2,5,1,2,4,2,2,3,3,2,2,4,2,1,5,2,0,6,1,7,7,1,6,8,1,5,9,1,4
		dc.b	10,1,3,11,1,2,12,1,1,$FF

		dc.b	0,2,6,1,2,5,2,2,4,3,2,3,4,2,2,5,2,1,6,2,0,7,1,7,8,1,6,9,1,5
		dc.b	10,1,4,11,1,3,12,1,2,13,1,1,$FF

		dc.b	0,2,7,1,2,6,2,2,5,3,2,4,4,2,3,5,2,2,6,2,1,7,2,0,8,1,7,9,1,6
		dc.b	10,1,5,11,1,4,12,1,3,13,1,2,14,1,1,$FF
* \Line 1 back
		dc.b	0,2,6,1,2,7,2,2,6,3,2,5,4,2,4,5,2,3,6,2,2,7,2,1,8,2,0,9,1,7
		dc.b	10,1,6,11,1,5,12,1,4,13,1,3,14,1,2,15,1,1,$FF

		dc.b	0,2,5,1,2,6,2,2,7,3,2,6,4,2,5,5,2,4,6,2,3,7,2,2,8,2,1,9,2,0
		dc.b	10,1,7,11,1,6,12,1,5,13,1,4,14,1,3,15,1,2,16,1,1,$FF

		dc.b	0,2,4,1,2,5,2,2,6,3,2,7,4,2,6,5,2,5,6,2,4,7,2,3,8,2,2,9,2,1
		dc.b	10,2,0,11,1,7,12,1,6,13,1,5,14,1,4,15,1,3,16,1,2,17,1,1,$FF

		dc.b	0,2,3,1,2,4,2,2,5,3,2,6,4,2,7,5,2,6,6,2,5,7,2,4,8,2,3,9,2,2
		dc.b	10,2,1,11,2,0,12,1,7,13,1,6,14,1,5,15,1,4,16,1,3,17,1,2,18,1,1,$FF

		dc.b	0,2,2,1,2,3,2,2,4,3,2,5,4,2,6,5,2,7,6,2,6,7,2,5,8,2,4,9,2,3
		dc.b	10,2,2,11,2,1,12,2,0,13,1,7,14,1,6,15,1,5,16,1,4,17,1,3,18,1,2
		dc.b	19,1,1,$FF

		dc.b	0,2,1,1,2,2,2,2,3,3,2,4,4,2,5,5,2,6,6,2,7,7,2,6,8,2,5,9,2,4
		dc.b	10,2,3,11,2,2,12,2,1,13,2,0,14,1,7,15,1,6,16,1,5,17,1,4,18,1,3
		dc.b	19,1,2,20,1,1,$FF

		dc.b	0,2,0,1,2,1,2,2,2,3,2,3,4,2,4,5,2,5,6,2,6,7,2,7,8,2,6,9,2,5
		dc.b	10,2,4,11,2,3,12,2,2,13,2,1,14,2,0,15,1,7,16,1,6,17,1,5,18,1,4
		dc.b	19,1,3,20,1,2,21,1,1,$FF

		dc.b	0,1,7,1,2,0,2,2,1,3,2,2,4,2,3,5,2,4,6,2,5,7,2,6,8,2,7,9,2,6
		dc.b	10,2,5,11,2,4,12,2,3,13,2,2,14,2,1,15,2,0,16,1,7,17,1,6,18,1,5
		dc.b	19,1,4,20,1,3,21,1,2,22,1,1,$FF

		dc.b	0,1,6,1,1,7,2,2,0,3,2,1,4,2,2,5,2,3,6,2,4,7,2,5,8,2,6,9,2,7
		dc.b	10,2,6,11,2,5,12,2,4,13,2,3,14,2,2,15,2,1,16,2,0,17,1,7,18,1,6
		dc.b	19,1,5,20,1,4,21,1,3,22,1,2,23,1,1,$FF

		dc.b	0,1,5,1,1,6,2,1,7,3,2,0,4,2,1,5,2,2,6,2,3,7,2,4,8,2,5,9,2,6
		dc.b	10,2,7,11,2,6,12,2,5,13,2,4,14,2,3,15,2,2,16,2,1,17,2,0,18,1,7
		dc.b	19,1,6,20,1,5,21,1,4,22,1,3,23,1,2,24,1,1,$FF

		dc.b	0,1,4,1,1,5,2,1,6,3,1,7,4,2,0,5,2,1,6,2,2,7,2,3,8,2,4,9,2,5
		dc.b	10,2,6,11,2,7,12,2,6,13,2,5,14,2,4,15,2,3,16,2,2,17,2,1,18,2,0
		dc.b	19,1,7,20,1,6,21,1,5,22,1,4,23,1,3,24,1,2,25,1,1,$FF

		dc.b	0,1,3,1,1,4,2,1,5,3,1,6,4,1,7,5,2,0,6,2,1,7,2,2,8,2,3,9,2,4
		dc.b	10,2,5,11,2,6,12,2,7,13,2,6,14,2,5,15,2,4,16,2,3,17,2,2,18,2,1
		dc.b	19,2,0,20,1,7,21,1,6,22,1,5,23,1,4,24,1,3,25,1,2,26,1,1,$FF

		dc.b	0,1,2,1,1,3,2,1,4,3,1,5,4,1,6,5,1,7,6,2,0,7,2,1,8,2,2,9,2,3
		dc.b	10,2,4,11,2,5,12,2,6,13,2,7,14,2,6,15,2,5,16,2,4,17,2,3,18,2,2
		dc.b	19,2,1,20,2,0,21,1,7,22,1,6,23,1,5,24,1,4,25,1,3,26,1,2,27,1,1,$FF

		dc.b	0,1,1,1,1,2,2,1,3,3,1,4,4,1,5,5,1,6,6,1,7,7,2,0,8,2,1,9,2,2
		dc.b	10,2,3,11,2,4,12,2,5,13,2,6,14,2,7,15,2,6,16,2,5,17,2,4,18,2,3
		dc.b	19,2,2,20,2,1,21,2,0,22,1,7,23,1,6,24,1,5,25,1,4,26,1,3,27,1,2,28,1,1,$FF

		dc.b	0,1,0,1,1,1,2,1,2,3,1,3,4,1,4,5,1,5,6,1,6,7,1,7,8,2,0,9,2,1
		dc.b	10,2,2,11,2,3,12,2,4,13,2,5,14,2,6,15,2,7,16,2,6,17,2,5,18,2,4
		dc.b	19,2,3,20,2,2,21,2,1,22,2,0,23,1,7,24,1,6,25,1,5,26,1,4,27,1,3,28,1,2,29,1,1,$FF
* Top at left
		dc.b	0,1,1,1,1,0,2,1,1,3,1,2,4,1,3,5,1,4,6,1,5,7,1,6,8,1,7,9,2,0
		dc.b	10,2,1,11,2,2,12,2,3,13,2,4,14,2,5,15,2,6,16,2,7,17,2,6,18,2,5
		dc.b	19,2,4,20,2,3,21,2,2,22,2,1,23,2,0,24,1,7,25,1,6,26,1,5,27,1,4,28,1,3,29,1,2
		dc.b	30,1,1,$FF

		dc.b	0,1,2,1,1,1,2,1,0,3,1,1,4,1,2,5,1,3,6,1,4,7,1,5,8,1,6,9,1,7
		dc.b	10,2,0,11,2,1,12,2,2,13,2,3,14,2,4,15,2,5,16,2,6,17,2,7,18,2,6
		dc.b	19,2,5,20,2,4,21,2,3,22,2,2,23,2,1,24,2,0,25,1,7,26,1,6,27,1,5,28,1,4,29,1,3
		dc.b	30,1,2,31,1,1,$FF

		dc.b	0,1,3,1,1,2,2,1,1,3,1,0,4,1,1,5,1,2,6,1,3,7,1,4,8,1,5,9,1,6
		dc.b	10,1,7,11,2,0,12,2,1,13,2,2,14,2,3,15,2,4,16,2,5,17,2,6,18,2,7
		dc.b	19,2,6,20,2,5,21,2,4,22,2,3,23,2,2,24,2,1,25,2,0,26,1,7,27,1,6,28,1,5,29,1,4
		dc.b	30,1,3,31,1,2,32,1,1,$FF

		dc.b	0,1,4,1,1,3,2,1,2,3,1,1,4,1,0,5,1,1,6,1,2,7,1,3,8,1,4,9,1,5
		dc.b	10,1,6,11,1,7,12,2,0,13,2,1,14,2,2,15,2,3,16,2,4,17,2,5,18,2,6
		dc.b	19,2,7,20,2,6,21,2,5,22,2,4,23,2,3,24,2,2,25,2,1,26,2,0,27,1,7,28,1,6,29,1,5
		dc.b	30,1,4,31,1,3,32,1,2,33,1,1,$FF

		dc.b	0,1,5,1,1,4,2,1,3,3,1,2,4,1,1,5,1,0,6,1,1,7,1,2,8,1,3,9,1,4
		dc.b	10,1,5,11,1,6,12,1,7,13,2,0,14,2,1,15,2,2,16,2,3,17,2,4,18,2,5
		dc.b	19,2,6,20,2,7,21,2,6,22,2,5,23,2,4,24,2,3,25,2,2,26,2,1,27,2,0,28,1,7,29,1,6
		dc.b	30,1,5,31,1,4,32,1,3,33,1,2,34,1,1,$FF

		dc.b	0,1,6,1,1,5,2,1,4,3,1,3,4,1,2,5,1,1,6,1,0,7,1,1,8,1,2,9,1,3
		dc.b	10,1,4,11,1,5,12,1,6,13,1,7,14,2,0,15,2,1,16,2,2,17,2,3,18,2,4
		dc.b	19,2,5,20,2,6,21,2,7,22,2,6,23,2,5,24,2,4,25,2,3,26,2,2,27,2,1,28,2,0,29,1,7
		dc.b	30,1,6,31,1,5,32,1,4,33,1,3,34,1,2,35,1,1,$FF

		dc.b	0,1,7,1,1,6,2,1,5,3,1,4,4,1,3,5,1,2,6,1,1,7,1,0,8,1,1,9,1,2
		dc.b	10,1,3,11,1,4,12,1,5,13,1,6,14,1,7,15,2,0,16,2,1,17,2,2,18,2,3
		dc.b	19,2,4,20,2,5,21,2,6,22,2,7,23,2,6,24,2,5,25,2,4,26,2,3,27,2,2,28,2,1,29,2,0
		dc.b	30,1,7,31,1,6,32,1,5,33,1,4,34,1,3,35,1,2,36,1,1,$FF

		dc.b	0,2,0,1,1,7,2,1,6,3,1,5,4,1,4,5,1,3,6,1,2,7,1,1,8,1,0,9,1,1
		dc.b	10,1,2,11,1,3,12,1,4,13,1,5,14,1,6,15,1,7,16,2,0,17,2,1,18,2,2
		dc.b	19,2,3,20,2,4,21,2,5,22,2,6,23,2,7,24,2,6,25,2,5,26,2,4,27,2,3,28,2,2,29,2,1
		dc.b	30,2,0,31,1,7,32,1,6,33,1,5,34,1,4,35,1,3,36,1,2,37,1,1,$FF

		dc.b	0,2,1,1,2,0,2,1,7,3,1,6,4,1,5,5,1,4,6,1,3,7,1,2,8,1,1,9,1,0
		dc.b	10,1,1,11,1,2,12,1,3,13,1,4,14,1,5,15,1,6,16,1,7,17,2,0,18,2,1
		dc.b	19,2,2,20,2,3,21,2,4,22,2,5,23,2,6,24,2,7,25,2,6,26,2,5,27,2,4,28,2,3,29,2,2
		dc.b	30,2,1,31,2,0,32,1,7,33,1,6,34,1,5,35,1,4,36,1,3,37,1,2,38,1,1,$FF

		dc.b	0,2,2,1,2,1,2,2,0,3,1,7,4,1,6,5,1,5,6,1,4,7,1,3,8,1,2,9,1,1
		dc.b	10,1,0,11,1,1,12,1,2,13,1,3,14,1,4,15,1,5,16,1,6,17,1,7,18,2,0
		dc.b	19,2,1,20,2,2,21,2,3,22,2,4,23,2,5,24,2,6,25,2,7,26,2,6,27,2,5,28,2,4,29,2,3
		dc.b	30,2,2,31,2,1,32,2,0,33,1,7,34,1,6,35,1,5,36,1,4,37,1,3,38,1,2,39,1,1,$FF

		dc.b	0,2,3,1,2,2,2,2,1,3,2,0,4,1,7,5,1,6,6,1,5,7,1,4,8,1,3,9,1,2
		dc.b	10,1,1,11,1,0,12,1,1,13,1,2,14,1,3,15,1,4,16,1,5,17,1,6,18,1,7
		dc.b	19,2,0,20,2,1,21,2,2,22,2,3,23,2,4,24,2,5,25,2,6,26,2,7,27,2,6,28,2,5,29,2,4
		dc.b	30,2,3,31,2,2,32,2,1,33,2,0,34,1,7,35,1,6,36,1,5,37,1,4,38,1,3,39,1,2,40,1,1,$FF

		dc.b	0,2,4,1,2,3,2,2,2,3,2,1,4,2,0,5,1,7,6,1,6,7,1,5,8,1,4,9,1,3
		dc.b	10,1,2,11,1,1,12,1,0,13,1,1,14,1,2,15,1,3,16,1,4,17,1,5,18,1,6
		dc.b	19,1,7,20,2,0,21,2,1,22,2,2,23,2,3,24,2,4,25,2,5,26,2,6,27,2,7,28,2,6,29,2,5
		dc.b	30,2,4,31,2,3,32,2,2,33,2,1,34,2,0,35,1,7,36,1,6,37,1,5,38,1,4,39,1,3,40,1,2,$FF

		dc.b	0,2,5,1,2,4,2,2,3,3,2,2,4,2,1,5,2,0,6,1,7,7,1,6,8,1,5,9,1,4
		dc.b	10,1,3,11,1,2,12,1,1,13,1,0,14,1,1,15,1,2,16,1,3,17,1,4,18,1,5
		dc.b	19,1,6,20,1,7,21,2,0,22,2,1,23,2,2,24,2,3,25,2,4,26,2,5,27,2,6,28,2,7,29,2,6
		dc.b	30,2,5,31,2,4,32,2,3,33,2,2,34,2,1,35,2,0,36,1,7,37,1,6,38,1,5,39,1,4,40,1,3,$FF

		dc.b	0,2,6,1,2,5,2,2,4,3,2,3,4,2,2,5,2,1,6,2,0,7,1,7,8,1,6,9,1,5
		dc.b	10,1,4,11,1,3,12,1,2,13,1,1,14,1,0,15,1,1,16,1,2,17,1,3,18,1,4
		dc.b	19,1,5,20,1,6,21,1,7,22,2,0,23,2,1,24,2,2,25,2,3,26,2,4,27,2,5,28,2,6,29,2,7
		dc.b	30,2,6,31,2,5,32,2,4,33,2,3,34,2,2,35,2,1,36,2,0,37,1,7,38,1,6,39,1,5,40,1,4,$FF
* Loop point! (Places top line at extreme right)
list_loop:	dc.b	0,2,7,1,2,6,2,2,5,3,2,4,4,2,3,5,2,2,6,2,1,7,2,0,8,1,7,9,1,6
		dc.b	10,1,5,11,1,4,12,1,3,13,1,2,14,1,1,15,1,0,16,1,1,17,1,2,18,1,3
		dc.b	19,1,4,20,1,5,21,1,6,22,1,7,23,2,0,24,2,1,25,2,2,26,2,3,27,2,4,28,2,5,29,2,6
		dc.b	30,2,7,31,2,6,32,2,5,33,2,4,34,2,3,35,2,2,36,2,1,37,2,0,38,1,7,39,1,6,40,1,5,$FF

		dc.b	0,2,6,1,2,7,2,2,6,3,2,5,4,2,4,5,2,3,6,2,2,7,2,1,8,2,0,9,1,7
		dc.b	10,1,6,11,1,5,12,1,4,13,1,3,14,1,2,15,1,1,16,1,0,17,1,1,18,1,2
		dc.b	19,1,3,20,1,4,21,1,5,22,1,6,23,1,7,24,2,0,25,2,1,26,2,2,27,2,3,28,2,4,29,2,5
		dc.b	30,2,6,31,2,7,32,2,6,33,2,5,34,2,4,35,2,3,36,2,2,37,2,1,38,2,0,39,1,7,40,1,6,$FF

		dc.b	0,2,5,1,2,6,2,2,7,3,2,6,4,2,5,5,2,4,6,2,3,7,2,2,8,2,1,9,2,0
		dc.b	10,1,7,11,1,6,12,1,5,13,1,4,14,1,3,15,1,2,16,1,1,17,1,0,18,1,1
		dc.b	19,1,2,20,1,3,21,1,4,22,1,5,23,1,6,24,1,7,25,2,0,26,2,1,27,2,2,28,2,3,29,2,4
		dc.b	30,2,5,31,2,6,32,2,7,33,2,6,34,2,5,35,2,4,36,2,3,37,2,2,38,2,1,39,2,0,40,1,7,$FF

		dc.b	0,2,4,1,2,5,2,2,6,3,2,7,4,2,6,5,2,5,6,2,4,7,2,3,8,2,2,9,2,1
		dc.b	10,2,0,11,1,7,12,1,6,13,1,5,14,1,4,15,1,3,16,1,2,17,1,1,18,1,0
		dc.b	19,1,1,20,1,2,21,1,3,22,1,4,23,1,5,24,1,6,25,1,7,26,2,0,27,2,1,28,2,2,29,2,3
		dc.b	30,2,4,31,2,5,32,2,6,33,2,7,34,2,6,35,2,5,36,2,4,37,2,3,38,2,2,39,2,1,40,2,0,$FF

		dc.b	0,2,3,1,2,4,2,2,5,3,2,6,4,2,7,5,2,6,6,2,5,7,2,4,8,2,3,9,2,2
		dc.b	10,2,1,11,2,0,12,1,7,13,1,6,14,1,5,15,1,4,16,1,3,17,1,2,18,1,1
		dc.b	19,1,0,20,1,1,21,1,2,22,1,3,23,1,4,24,1,5,25,1,6,26,1,7,27,2,0,28,2,1,29,2,2
		dc.b	30,2,3,31,2,4,32,2,5,33,2,6,34,2,7,35,2,6,36,2,5,37,2,4,38,2,3,39,2,2,40,2,1,$FF

		dc.b	0,2,2,1,2,3,2,2,4,3,2,5,4,2,6,5,2,7,6,2,6,7,2,5,8,2,4,9,2,3
		dc.b	10,2,2,11,2,1,12,2,0,13,1,7,14,1,6,15,1,5,16,1,4,17,1,3,18,1,2
		dc.b	19,1,1,20,1,0,21,1,1,22,1,2,23,1,3,24,1,4,25,1,5,26,1,6,27,1,7,28,2,0,29,2,1
		dc.b	30,2,2,31,2,3,32,2,4,33,2,5,34,2,6,35,2,7,36,2,6,37,2,5,38,2,4,39,2,3,40,2,2,$FF

		dc.b	0,2,1,1,2,2,2,2,3,3,2,4,4,2,5,5,2,6,6,2,7,7,2,6,8,2,5,9,2,4
		dc.b	10,2,3,11,2,2,12,2,1,13,2,0,14,1,7,15,1,6,16,1,5,17,1,4,18,1,3
		dc.b	19,1,2,20,1,1,21,1,0,22,1,1,23,1,2,24,1,3,25,1,4,26,1,5,27,1,6,28,1,7,29,2,0
		dc.b	30,2,1,31,2,2,32,2,3,33,2,4,34,2,5,35,2,6,36,2,7,37,2,6,38,2,5,39,2,4,40,2,3,$FF

		dc.b	0,2,0,1,2,1,2,2,2,3,2,3,4,2,4,5,2,5,6,2,6,7,2,7,8,2,6,9,2,5
		dc.b	10,2,4,11,2,3,12,2,2,13,2,1,14,2,0,15,1,7,16,1,6,17,1,5,18,1,4
		dc.b	19,1,3,20,1,2,21,1,1,22,1,0,23,1,1,24,1,2,25,1,3,26,1,4,27,1,5,28,1,6,29,1,7
		dc.b	30,2,0,31,2,1,32,2,2,33,2,3,34,2,4,35,2,5,36,2,6,37,2,7,38,2,6,39,2,5,40,2,4,$FF

		dc.b	0,1,7,1,2,0,2,2,1,3,2,2,4,2,3,5,2,4,6,2,5,7,2,6,8,2,7,9,2,6
		dc.b	10,2,5,11,2,4,12,2,3,13,2,2,14,2,1,15,2,0,16,1,7,17,1,6,18,1,5
		dc.b	19,1,4,20,1,3,21,1,2,22,1,1,23,1,0,24,1,1,25,1,2,26,1,3,27,1,4,28,1,5,29,1,6
		dc.b	30,1,7,31,2,0,32,2,1,33,2,2,34,2,3,35,2,4,36,2,5,37,2,6,38,2,7,39,2,6,40,2,5,$FF

		dc.b	0,1,6,1,1,7,2,2,0,3,2,1,4,2,2,5,2,3,6,2,4,7,2,5,8,2,6,9,2,7
		dc.b	10,2,6,11,2,5,12,2,4,13,2,3,14,2,2,15,2,1,16,2,0,17,1,7,18,1,6
		dc.b	19,1,5,20,1,4,21,1,3,22,1,2,23,1,1,24,1,0,25,1,1,26,1,2,27,1,3,28,1,4,29,1,5
		dc.b	30,1,6,31,1,7,32,2,0,33,2,1,34,2,2,35,2,3,36,2,4,37,2,5,38,2,6,39,2,7,40,2,6,$FF

		dc.b	0,1,5,1,1,6,2,1,7,3,2,0,4,2,1,5,2,2,6,2,3,7,2,4,8,2,5,9,2,6
		dc.b	10,2,7,11,2,6,12,2,5,13,2,4,14,2,3,15,2,2,16,2,1,17,2,0,18,1,7
		dc.b	19,1,6,20,1,5,21,1,4,22,1,3,23,1,2,24,1,1,25,1,0,26,1,1,27,1,2,28,1,3,29,1,4
		dc.b	30,1,5,31,1,6,32,1,7,33,2,0,34,2,1,35,2,2,36,2,3,37,2,4,38,2,5,39,2,6,40,2,7,$FF

		dc.b	0,1,4,1,1,5,2,1,6,3,1,7,4,2,0,5,2,1,6,2,2,7,2,3,8,2,4,9,2,5
		dc.b	10,2,6,11,2,7,12,2,6,13,2,5,14,2,4,15,2,3,16,2,2,17,2,1,18,2,0
		dc.b	19,1,7,20,1,6,21,1,5,22,1,4,23,1,3,24,1,2,25,1,1,26,1,0,27,1,1,28,1,2,29,1,3
		dc.b	30,1,4,31,1,5,32,1,6,33,1,7,34,2,0,35,2,1,36,2,2,37,2,3,38,2,4,39,2,5,40,2,6,$FF

		dc.b	0,1,3,1,1,4,2,1,5,3,1,6,4,1,7,5,2,0,6,2,1,7,2,2,8,2,3,9,2,4
		dc.b	10,2,5,11,2,6,12,2,7,13,2,6,14,2,5,15,2,4,16,2,3,17,2,2,18,2,1
		dc.b	19,2,0,20,1,7,21,1,6,22,1,5,23,1,4,24,1,3,25,1,2,26,1,1,27,1,0,28,1,1,29,1,2
		dc.b	30,1,3,31,1,4,32,1,5,33,1,6,34,1,7,35,2,0,36,2,1,37,2,2,38,2,3,39,2,4,40,2,5,$FF

		dc.b	0,1,2,1,1,3,2,1,4,3,1,5,4,1,6,5,1,7,6,2,0,7,2,1,8,2,2,9,2,3
		dc.b	10,2,4,11,2,5,12,2,6,13,2,7,14,2,6,15,2,5,16,2,4,17,2,3,18,2,2
		dc.b	19,2,1,20,2,0,21,1,7,22,1,6,23,1,5,24,1,4,25,1,3,26,1,2,27,1,1,28,1,0,29,1,1
		dc.b	30,1,2,31,1,3,32,1,4,33,1,5,34,1,6,35,1,7,36,2,0,37,2,1,38,2,2,39,2,3,40,2,4,$FF

		dc.b	0,1,1,1,1,2,2,1,3,3,1,4,4,1,5,5,1,6,6,1,7,7,2,0,8,2,1,9,2,2
		dc.b	10,2,3,11,2,4,12,2,5,13,2,6,14,2,7,15,2,6,16,2,5,17,2,4,18,2,3
		dc.b	19,2,2,20,2,1,21,2,0,22,1,7,23,1,6,24,1,5,25,1,4,26,1,3,27,1,2,28,1,1,29,1,0
		dc.b	30,1,1,31,1,2,32,1,3,33,1,4,34,1,5,35,1,6,36,1,7,37,2,0,38,2,1,39,2,2,40,2,3,$FF

		dc.b	0,1,0,1,1,1,2,1,2,3,1,3,4,1,4,5,1,5,6,1,6,7,1,7,8,2,0,9,2,1
		dc.b	10,2,2,11,2,3,12,2,4,13,2,5,14,2,6,15,2,7,16,2,6,17,2,5,18,2,4
		dc.b	19,2,3,20,2,2,21,2,1,22,2,0,23,1,7,24,1,6,25,1,5,26,1,4,27,1,3,28,1,2,29,1,1
		dc.b	30,1,0,31,1,1,32,1,2,33,1,3,34,1,4,35,1,5,36,1,6,37,1,7,38,2,0,39,2,1,40,2,2,$FF
 * \Top now at left: move it to right, then loop

		dc.b	0,1,1,1,1,0,2,1,1,3,1,2,4,1,3,5,1,4,6,1,5,7,1,6,8,1,7,9,2,0
		dc.b	10,2,1,11,2,2,12,2,3,13,2,4,14,2,5,15,2,6,16,2,7,17,2,6,18,2,5
		dc.b	19,2,4,20,2,3,21,2,2,22,2,1,23,2,0,24,1,7,25,1,6,26,1,5,27,1,4,28,1,3,29,1,2
		dc.b	30,1,1,31,1,0,32,1,1,33,1,2,34,1,3,35,1,4,36,1,5,37,1,6,38,1,7,39,2,0,40,2,1,$FF
		
		dc.b	0,1,2,1,1,1,2,1,0,3,1,1,4,1,2,5,1,3,6,1,4,7,1,5,8,1,6,9,1,7
		dc.b	10,2,0,11,2,1,12,2,2,13,2,3,14,2,4,15,2,5,16,2,6,17,2,7,18,2,6
		dc.b	19,2,5,20,2,4,21,2,3,22,2,2,23,2,1,24,2,0,25,1,7,26,1,6,27,1,5,28,1,4,29,1,3
		dc.b	30,1,2,31,1,1,32,1,0,33,1,1,34,1,2,35,1,3,36,1,4,37,1,5,38,1,6,39,1,7,40,2,0,$FF

		dc.b	0,1,3,1,1,2,2,1,1,3,1,0,4,1,1,5,1,2,6,1,3,7,1,4,8,1,5,9,1,6
		dc.b	10,1,7,11,2,0,12,2,1,13,2,2,14,2,3,15,2,4,16,2,5,17,2,6,18,2,7
		dc.b	19,2,6,20,2,5,21,2,4,22,2,3,23,2,2,24,2,1,25,2,0,26,1,7,27,1,6,28,1,5,29,1,4
		dc.b	30,1,3,31,1,2,32,1,1,33,1,0,34,1,1,35,1,2,36,1,3,37,1,4,38,1,5,39,1,6,40,1,7,$FF

		dc.b	0,1,4,1,1,3,2,1,2,3,1,1,4,1,0,5,1,1,6,1,2,7,1,3,8,1,4,9,1,5
		dc.b	10,1,6,11,1,7,12,2,0,13,2,1,14,2,2,15,2,3,16,2,4,17,2,5,18,2,6
		dc.b	19,2,7,20,2,6,21,2,5,22,2,4,23,2,3,24,2,2,25,2,1,26,2,0,27,1,7,28,1,6,29,1,5
		dc.b	30,1,4,31,1,3,32,1,2,33,1,1,34,1,0,35,1,1,36,1,2,37,1,3,38,1,4,39,1,5,40,1,6,$FF

		dc.b	0,1,5,1,1,4,2,1,3,3,1,2,4,1,1,5,1,0,6,1,1,7,1,2,8,1,3,9,1,4
		dc.b	10,1,5,11,1,6,12,1,7,13,2,0,14,2,1,15,2,2,16,2,3,17,2,4,18,2,5
		dc.b	19,2,6,20,2,7,21,2,6,22,2,5,23,2,4,24,2,3,25,2,2,26,2,1,27,2,0,28,1,7,29,1,6
		dc.b	30,1,5,31,1,4,32,1,3,33,1,2,34,1,1,35,1,0,36,1,1,37,1,2,38,1,3,39,1,4,40,1,5,$FF

		dc.b	0,1,6,1,1,5,2,1,4,3,1,3,4,1,2,5,1,1,6,1,0,7,1,1,8,1,2,9,1,3
		dc.b	10,1,4,11,1,5,12,1,6,13,1,7,14,2,0,15,2,1,16,2,2,17,2,3,18,2,4
		dc.b	19,2,5,20,2,6,21,2,7,22,2,6,23,2,5,24,2,4,25,2,3,26,2,2,27,2,1,28,2,0,29,1,7
		dc.b	30,1,6,31,1,5,32,1,4,33,1,3,34,1,2,35,1,1,36,1,0,37,1,1,38,1,2,39,1,3,40,1,4,$FF

		dc.b	0,1,7,1,1,6,2,1,5,3,1,4,4,1,3,5,1,2,6,1,1,7,1,0,8,1,1,9,1,2
		dc.b	10,1,3,11,1,4,12,1,5,13,1,6,14,1,7,15,2,0,16,2,1,17,2,2,18,2,3
		dc.b	19,2,4,20,2,5,21,2,6,22,2,7,23,2,6,24,2,5,25,2,4,26,2,3,27,2,2,28,2,1,29,2,0
		dc.b	30,1,7,31,1,6,32,1,5,33,1,4,34,1,3,35,1,2,36,1,1,37,1,0,38,1,1,39,1,2,40,1,3,$FF

		dc.b	0,2,0,1,1,7,2,1,6,3,1,5,4,1,4,5,1,3,6,1,2,7,1,1,8,1,0,9,1,1
		dc.b	10,1,2,11,1,3,12,1,4,13,1,5,14,1,6,15,1,7,16,2,0,17,2,1,18,2,2
		dc.b	19,2,3,20,2,4,21,2,5,22,2,6,23,2,7,24,2,6,25,2,5,26,2,4,27,2,3,28,2,2,29,2,1
		dc.b	30,2,0,31,1,7,32,1,6,33,1,5,34,1,4,35,1,3,36,1,2,37,1,1,38,1,0,39,1,1,40,1,2,$FF

		dc.b	0,2,1,1,2,0,2,1,7,3,1,6,4,1,5,5,1,4,6,1,3,7,1,2,8,1,1,9,1,0
		dc.b	10,1,1,11,1,2,12,1,3,13,1,4,14,1,5,15,1,6,16,1,7,17,2,0,18,2,1
		dc.b	19,2,2,20,2,3,21,2,4,22,2,5,23,2,6,24,2,7,25,2,6,26,2,5,27,2,4,28,2,3,29,2,2
		dc.b	30,2,1,31,2,0,32,1,7,33,1,6,34,1,5,35,1,4,36,1,3,37,1,2,38,1,1,39,1,0,40,1,1,$FF

		dc.b	0,2,2,1,2,1,2,2,0,3,1,7,4,1,6,5,1,5,6,1,4,7,1,3,8,1,2,9,1,1
		dc.b	10,1,0,11,1,1,12,1,2,13,1,3,14,1,4,15,1,5,16,1,6,17,1,7,18,2,0
		dc.b	19,2,1,20,2,2,21,2,3,22,2,4,23,2,5,24,2,6,25,2,7,26,2,6,27,2,5,28,2,4,29,2,3
		dc.b	30,2,2,31,2,1,32,2,0,33,1,7,34,1,6,35,1,5,36,1,4,37,1,3,38,1,2,39,1,1,40,1,0,$FF

		dc.b	0,2,3,1,2,2,2,2,1,3,2,0,4,1,7,5,1,6,6,1,5,7,1,4,8,1,3,9,1,2
		dc.b	10,1,1,11,1,0,12,1,1,13,1,2,14,1,3,15,1,4,16,1,5,17,1,6,18,1,7
		dc.b	19,2,0,20,2,1,21,2,2,22,2,3,23,2,4,24,2,5,25,2,6,26,2,7,27,2,6,28,2,5,29,2,4
		dc.b	30,2,3,31,2,2,32,2,1,33,2,0,34,1,7,35,1,6,36,1,5,37,1,4,38,1,3,39,1,2,40,1,1,$FF

		dc.b	0,2,4,1,2,3,2,2,2,3,2,1,4,2,0,5,1,7,6,1,6,7,1,5,8,1,4,9,1,3
		dc.b	10,1,2,11,1,1,12,1,0,13,1,1,14,1,2,15,1,3,16,1,4,17,1,5,18,1,6
		dc.b	19,1,7,20,2,0,21,2,1,22,2,2,23,2,3,24,2,4,25,2,5,26,2,6,27,2,7,28,2,6,29,2,5
		dc.b	30,2,4,31,2,3,32,2,2,33,2,1,34,2,0,35,1,7,36,1,6,37,1,5,38,1,4,39,1,3,40,1,2,$FF

		dc.b	0,2,5,1,2,4,2,2,3,3,2,2,4,2,1,5,2,0,6,1,7,7,1,6,8,1,5,9,1,4
		dc.b	10,1,3,11,1,2,12,1,1,13,1,0,14,1,1,15,1,2,16,1,3,17,1,4,18,1,5
		dc.b	19,1,6,20,1,7,21,2,0,22,2,1,23,2,2,24,2,3,25,2,4,26,2,5,27,2,6,28,2,7,29,2,6
		dc.b	30,2,5,31,2,4,32,2,3,33,2,2,34,2,1,35,2,0,36,1,7,37,1,6,38,1,5,39,1,4,40,1,3,$FF

		dc.b	0,2,6,1,2,5,2,2,4,3,2,3,4,2,2,5,2,1,6,2,0,7,1,7,8,1,6,9,1,5
		dc.b	10,1,4,11,1,3,12,1,2,13,1,1,14,1,0,15,1,1,16,1,2,17,1,3,18,1,4
		dc.b	19,1,5,20,1,6,21,1,7,22,2,0,23,2,1,24,2,2,25,2,3,26,2,4,27,2,5,28,2,6,29,2,7
		dc.b	30,2,6,31,2,5,32,2,4,33,2,3,34,2,2,35,2,1,36,2,0,37,1,7,38,1,6,39,1,5,40,1,4,$FF

		dc.b	$99		* Ensure end is noticed!

		EVEN

* \Accept number in D0.B (0-40). Also workscreen #(1-2) in D1.B
*  And image number desired on target screen in D2 (0-7)
*  Extract location of address of that line and place in A2.

get_address:	cmp.b	#$01,D1 	* Screen 1?
		beq	get_from1
get_from2:	move.l	#table2,D3	* Point to table2
		bra.s	do_table
get_from1:	move.l	#table1,D3	* Point to table 1

* \Get entry 
do_table:	move.l	D0,D4		* Save line number
		asl	#5,D0		* Point to LINE
		asl	#2,D2		* Point to ENTRY
		add.l	D2,D0
		add.l	D3,D0		* Do = target
		move.l	D0,A2
		move.l	(A2),A4
		move.l	A4,A2

* \Routine to extract line starting at (A2) and place on target screen
* \A2 needs to be supplied...

put_line:	move.l	logic,A0	* Target screen
		lea	800(A0),A0	* Go 5 lines down
		mulu	#160,D4
		add.l	D4,A0
		
put_loop:	move.l	(A2)+,(A0)+	* Place planes on screen
		move.w	(A2),(A0)
		lea	4(A2),A2
		lea	4(A0),A0
		move.l	(A2)+,(A0)+	* Place planes on screen
		move.w	(A2),(A0)
		lea	4(A2),A2
		lea	4(A0),A0
		move.l	(A2)+,(A0)+	* Place planes on screen
		move.w	(A2),(A0)
		lea	4(A2),A2
		lea	4(A0),A0
		move.l	(A2)+,(A0)+	* Place planes on screen
		move.w	(A2),(A0)
		lea	4(A2),A2
		lea	4(A0),A0
		move.l	(A2)+,(A0)+	* Place planes on screen
		move.w	(A2),(A0)
		lea	4(A2),A2
		lea	4(A0),A0
		move.l	(A2)+,(A0)+	* Place planes on screen
		move.w	(A2),(A0)
		lea	4(A2),A2
		lea	4(A0),A0
		move.l	(A2)+,(A0)+	* Place planes on screen
		move.w	(A2),(A0)
		lea	4(A2),A2
		lea	4(A0),A0
		move.l	(A2)+,(A0)+	* Place planes on screen
		move.w	(A2),(A0)
		lea	4(A2),A2
		lea	4(A0),A0
		move.l	(A2)+,(A0)+	* Place planes on screen
		move.w	(A2),(A0)
		lea	4(A2),A2
		lea	4(A0),A0
		move.l	(A2)+,(A0)+	* Place planes on screen
		move.w	(A2),(A0)
		
		rts

* \Routine to screen copy from logic to physic
copy_data:	dc.l	0,13640,13640,13640,13640,13640,13800
		dc.l	13960,14120,14280,14440,14600
		dc.l	14920,15240,15560,15880,16200
		dc.l	16680,17160,17640,18120,18600,19080
		dc.l	19720,20360,21000,21640,22280,23080
		dc.l	23880,$99

* \Routine to copy VOBRIEN logo in 4th plane from 'vobrien' to
*  vob_ptr	(list pointer)

vob_ptr:	ds.l	1		* Preset to vob_data

vob_data:	dc.l	0,160,320,480,640,800
		dc.l	1120,1440,1760,2080,2400,2720
		dc.l	3200,3680,4160,4640,5120,5600
		dc.l	6240,6880,7520,8160,8800,9440,10080
		dc.l	10880,11680,12480,13280,14080,14880
		dc.l	15680,16480,17280,18080,18880,19680
		dc.l	20480,21280,22080,22880,23680,24480
		dc.l	25280,26080,26880,27680,28480,29280
		dc.l	98	

vobrien:	ds.l	1
copy_ptr:	ds.l	1		* Space for pointer
copy_flag:	dc.b	0		* Down to start
vob_flag:	dc.b	0		* Preset to down
		
woff:		dc.l	14440
vobstore:	ds.l	1

* \First do VOBRIEN logo

copy:		movem.l A0-A1/D0-D1,-(sp)

		move.l	D0,-(sp)	
wait2:		move.b	$FF8207,temp
		move.b	$FF8209,temp2
		move.w	physic2,D0
		cmp.w	temp,D0
		beq	end_wait
		bra.s	wait2
end_wait:	move.l	(sp)+,D0

		move.l	vob_ptr,A0
		tst.b	vob_flag	* -->?
		beq	vob_down
vob_up: 	move.l	(A0),vobrien
		lea	4(A0),A0
		cmp.l	#98,(A0)	* EOL?
		bne	do_vob
		clr.b	vob_flag
		subq.w	#$04,A0
		bra.s	do_vob
vob_down:	move.l	(A0),vobrien
		subq.w	#$04,A0 	* Point back a longword
		tst.l	(A0)		* SOL?
		bne	do_vob
		addq.b	#$01,vob_flag
		lea	4(A0),A0					

do_vob: 	move.l	A0,vob_ptr
		
		move.l	vlogo_ptr,A0	* Point to logo in mem
		move.l	#199,D0 	* Chunks in logo
		move.l	vobrien,A1	* Screen to put it on

vob2:		move.w	(A0)+,(A1)	* Place word
		lea	8(A1),A1	* Next plane
		move.w	(A0)+,(A1)	* Place word
		lea	8(A1),A1	* Next plane
		move.w	(A0)+,(A1)	* Place word
		lea	8(A1),A1	* Next plane
		move.w	(A0)+,(A1)	* Place word
		lea	8(A1),A1	* Next plane
		move.w	(A0)+,(A1)	* Place word
		lea	8(A1),A1	* Next plane
		move.w	(A0)+,(A1)	* Place word
		lea	8(A1),A1	* Next plane
		move.w	(A0)+,(A1)	* Place word
		lea	8(A1),A1	* Next plane
		move.w	(A0)+,(A1)	* Place word
		lea	8(A1),A1	* Next plane
		
		dbf	D0,vob2 	
		
* \Now do wibble
		move.l	copy_ptr,A0
		tst.b	copy_flag	* -->?
		beq	copy_down
copy_up:	move.l	(A0),woff
		lea	4(A0),A0
		cmp.l	#$99,(A0)	* EOL?
		bne	copy2
		clr.b	copy_flag
		subq.w	#$04,A0
		bra.s	copy2
copy_down:	move.l	(A0),woff
		sub.w	#$04,A0 	* Point back a word
		tst.l	(A0)		* SOL?
		bne	copy2
		move.b	#$01,copy_flag
		lea	4(A0),A0					

copy2:		move.l	A0,copy_ptr	* Save for next time
		move.l	logic,A0	* Source
		move.l	woff,A1 	* Dest
		moveq.b #50,D0		* Lines
copy_loop1:	move.l	(A0),(A1)
		lea	4(A0),A0
		lea	4(A1),A1
		move.w	(A0),(A1)
		lea	4(A0),A0
		lea	4(A1),A1	* Skip 4th plane
		move.l	(A0)+,(A1)+
		move.w	(A0),(A1)
		lea	4(A0),A0
		lea	4(A1),A1	* Skip 4th plane
		move.l	(A0)+,(A1)+
		move.w	(A0),(A1)
		lea	4(A0),A0
		lea	4(A1),A1	* Skip 4th plane
		move.l	(A0)+,(A1)+
		move.w	(A0),(A1)
		lea	4(A0),A0
		lea	4(A1),A1	* Skip 4th plane
		move.l	(A0)+,(A1)+
		move.w	(A0),(A1)
		lea	4(A0),A0
		lea	4(A1),A1	* Skip 4th plane
		move.l	(A0)+,(A1)+
		move.w	(A0),(A1)
		lea	4(A0),A0
		lea	4(A1),A1	* Skip 4th plane
		move.l	(A0)+,(A1)+
		move.w	(A0),(A1)
		lea	4(A0),A0
		lea	4(A1),A1	* Skip 4th plane
		move.l	(A0)+,(A1)+
		move.w	(A0),(A1)
		lea	4(A0),A0
		lea	4(A1),A1	* Skip 4th plane
		move.l	(A0)+,(A1)+
		move.w	(A0),(A1)
		lea	4(A0),A0
		lea	4(A1),A1	* Skip 4th plane
		move.l	(A0)+,(A1)+
		move.w	(A0),(A1)
		lea	4(A0),A0
		lea	4(A1),A1	* Repetition > Iteration!

* \Copied current line, now down + repeat
		lea	80(A0),A0	* Down a line
		lea	80(A1),A1
		dbf	D0,copy_loop1
		movem.l (sp)+,A0-A1/D0-D1
		rts

* Table of offsets for images_1

table1: 	dc.l	0,80,8000,8080,16000,16080,24000,24080
		dc.l	160,240,8160,8240,16160,16240,24160,24240
		dc.l	320,400,8320,8400,16320,16400,24320,24400
		dc.l	480,560,8480,8560,16480,16560,24480,24560
		dc.l	640,720,8640,8720,16640,16720,24640,24720
		dc.l	800,880,8800,8880,16800,16880,24800,24880
		dc.l	960,1040,8960,9040,16960,17040,24960,25040
		dc.l	1120,1200,9120,9200,17120,17200,25120,25200
		dc.l	1280,1360,9280,9360,17280,17360,25280,25360
		dc.l	1440,1520,9440,9520,17440,17520,25440,25520
		dc.l	1600,1680,9600,9680,17600,17680,25600,25680
		dc.l	1760,1840,9760,9840,17760,17840,25760,25840
		dc.l	1920,2000,9920,10000,17920,18000,25920,26000
		dc.l	2080,2160,10080,10160,18080,18160,26080,26160
		dc.l	2240,2320,10240,10320,18240,18320,26240,26320
		dc.l	2400,2480,10400,10480,18400,18480,26400,26480
		dc.l	2560,2640,10560,10640,18560,18640,26560,26640
		dc.l	2720,2800,10720,10800,18720,18800,26720,26800
		dc.l	2880,2960,10880,10960,18880,18960,26880,26960
		dc.l	3040,3120,11040,11120,19040,19120,27040,27120
		dc.l	3200,3280,11200,11280,19200,19280,27200,27280
		dc.l	3360,3440,11360,11440,19360,19440,27360,27440
		dc.l	3520,3600,11520,11600,19520,19600,27520,27600
		dc.l	3680,3760,11680,11760,19680,19760,27680,27760	
		dc.l	3840,3920,11840,11920,19840,19920,27840,27920
		dc.l	4000,4080,12000,12080,20000,20080,28000,28080
		dc.l	4160,4240,12160,12240,20160,20240,28160,28240
		dc.l	4320,4400,12320,12400,20320,20400,28320,28400
		dc.l	4480,4560,12480,12560,20480,20560,28480,28560
		dc.l	4640,4720,12640,12720,20640,20720,28640,28720
		dc.l	4800,4880,12800,12880,20800,20880,28800,28880
		dc.l	4960,5040,12960,13040,20960,21040,28960,29040
		dc.l	5120,5200,13120,13200,21120,21200,29120,29200
		dc.l	5280,5360,13280,13360,21280,21360,29280,29360
		dc.l	5440,5520,13440,13520,21440,21520,29440,29520
		dc.l	5600,5680,13600,13680,21600,21680,29600,29680
		dc.l	5760,5840,13760,13840,21760,21840,29760,29840
		dc.l	5920,6000,13920,14000,21920,22000,29920,30000
		dc.l	6080,6160,14080,14160,22080,22160,30080,30160
		dc.l	6240,6320,14240,14320,22240,22320,30240,30320
		dc.l	6400,6480,14400,14480,22400,22480,30400,30480

end_adds1:	dc.l	$9999

* Table of offsets for images_2

table2: 	dc.l	0,80,8000,8080,16000,16080,24000,24080
		dc.l	160,240,8160,8240,16160,16240,24160,24240
		dc.l	320,400,8320,8400,16320,16400,24320,24400
		dc.l	480,560,8480,8560,16480,16560,24480,24560
		dc.l	640,720,8640,8720,16640,16720,24640,24720
		dc.l	800,880,8800,8880,16800,16880,24800,24880
		dc.l	960,1040,8960,9040,16960,17040,24960,25040
		dc.l	1120,1200,9120,9200,17120,17200,25120,25200
		dc.l	1280,1360,9280,9360,17280,17360,25280,25360
		dc.l	1440,1520,9440,9520,17440,17520,25440,25520
		dc.l	1600,1680,9600,9680,17600,17680,25600,25680
		dc.l	1760,1840,9760,9840,17760,17840,25760,25840
		dc.l	1920,2000,9920,10000,17920,18000,25920,26000
		dc.l	2080,2160,10080,10160,18080,18160,26080,26160
		dc.l	2240,2320,10240,10320,18240,18320,26240,26320
		dc.l	2400,2480,10400,10480,18400,18480,26400,26480
		dc.l	2560,2640,10560,10640,18560,18640,26560,26640
		dc.l	2720,2800,10720,10800,18720,18800,26720,26800
		dc.l	2880,2960,10880,10960,18880,18960,26880,26960
		dc.l	3040,3120,11040,11120,19040,19120,27040,27120
		dc.l	3200,3280,11200,11280,19200,19280,27200,27280
		dc.l	3360,3440,11360,11440,19360,19440,27360,27440
		dc.l	3520,3600,11520,11600,19520,19600,27520,27600
		dc.l	3680,3760,11680,11760,19680,19760,27680,27760	
		dc.l	3840,3920,11840,11920,19840,19920,27840,27920
		dc.l	4000,4080,12000,12080,20000,20080,28000,28080
		dc.l	4160,4240,12160,12240,20160,20240,28160,28240
		dc.l	4320,4400,12320,12400,20320,20400,28320,28400
		dc.l	4480,4560,12480,12560,20480,20560,28480,28560
		dc.l	4640,4720,12640,12720,20640,20720,28640,28720
		dc.l	4800,4880,12800,12880,20800,20880,28800,28880
		dc.l	4960,5040,12960,13040,20960,21040,28960,29040
		dc.l	5120,5200,13120,13200,21120,21200,29120,29200
		dc.l	5280,5360,13280,13360,21280,21360,29280,29360
		dc.l	5440,5520,13440,13520,21440,21520,29440,29520
		dc.l	5600,5680,13600,13680,21600,21680,29600,29680
		dc.l	5760,5840,13760,13840,21760,21840,29760,29840
		dc.l	5920,6000,13920,14000,21920,22000,29920,30000
		dc.l	6080,6160,14080,14160,22080,22160,30080,30160
		dc.l	6240,6320,14240,14320,22240,22320,30240,30320
		dc.l	6400,6480,14400,14480,22400,22480,30400,30480
end_adds2:	dc.l	$9999


wait_vbl:	move.l	D0,-(sp)	
wait_vbl2:	move.b	$FF8207,temp
		move.b	$FF8209,temp2
		move.w	physic2,D0
		cmp.w	temp,D0
		beq	end_vbl
		bra.s	wait_vbl2
end_vbl:	move.l	(sp)+,D0
		rts

temp:		ds.b	1
temp2:		ds.b	1

*****************************************************************

* \A routine that openes the lower border, AND consistently
* \changes lower screen palette...

hblon:		move.l	$120,oldtb		* Old TimerB Vector
		move.l	$70,old4		* Old VBL vector
		move.l	$70,new4b+2		* New VBL will jump to old
		move.b	$FFFFFA07,old07 	* Timer B enable
		move.b	$FFFFFA09,old09 	* Timer C enable
		move.b	$FFFFFA0f,old0f 	* Timer B in-service
		move.b	$FFFFFA11,old11 	* Timer C in-service
		move.b	$FFFFFA1b,old1b 	* Timer B control
		and.b	#$DF,$FFFA09		* Disable Timer C
		and.b	#$FE,$FFFA07		* Disable Timer B
		move.l	#newtb2,$120		* New Timer B vector
		move.l	#new4,$70		* New VBL vector
		or.b	#1,$FFFFFA07		* Enable Timer B
		or.b	#1,$FFFFFA13		* Set Timer B mask
		rts

hbloff: 	move.w	sr,-(sp)
		move.w	#$2700,sr
		move.b	old07(pc),$FFFFFA07
		move.b	old09(pc),$FFFFFA09
		move.b	old0f(pc),$FFFFFA0F
		move.b	old11(pc),$FFFFFA11
		move.b	old1b(pc),$FFFFFA1B
		move.l	oldtb,$120
		move.l	old4,$70
		move.w	(sp)+,sr
		rts

* \Storage for old Timer values....
old4:		dc.l	0
oldtb:		dc.l	0
old07:		dc.b	0
old09:		dc.b	0
old0f:		dc.b	0
old11:		dc.b	0
old1b:		dc.b	0

		EVEN

*\ This is the new VBL handler

new4:		move.l	A0,-(sp)
		clr.b	$FFFFFA1B.w	* Disable Timer B
		move.b	#$02,$FFFFFA21	* Time for interrupt 


		move.b	#8,$FFFFFA1B	* Enable Timer B again
		move.w	#$0,$FF8240	* Index 0 - BLACK
		move.l	#newtb1,$120	* Change vector for next interrupt
		lea	menu_pic,A0
		lea	4(A0),A0
		move.l	(A0)+,$FF8242
		move.l	(A0)+,$FF8246
		move.w	(A0),$FF824A		* Done cols
		lea	menu_pic,A0
		lea	20(A0),A0	* Replace upper cols
		move.l	(A0)+,$FF8252
		move.l	(A0)+,$FF8256
		move.w	(A0),$FF825A

		move.l	(sp)+,A0
new4b:		jmp	$12345678	* JMP to old routine....

* \The JMP $12345678 will have been replaced with the old address,
*  with move.l	old,new4b+2!

newtb1: 	clr.b	$FFFFFA1B.w		* Disable TimerB
		movem.l D0-D1/A0-A1,-(sp)	* Store Registers
		move.w	#$FA21,A1		* A1 = FFFFA21
		move.b	#20,(A1)		* Down another ? lines
		move.l	#newtb1a,$120		* Place the new vector address
		move.b	#8,$FFFFFA1B.w		* Enable Timer
* \Now create pretty rasters

		move.w	#11,D1		* Raster is 12 scanlines
		move.l	#pretty2,A0
nloop2: 	move.b	(A1),D0 	* Read TimerB into D0
nwait2: 	cmp.b	(A1),D0
		beq	nwait2		* Wait 1 scanline
		move.w	(A0)+,$FF8250	* And logo
		dbra	D1,nloop2

		movem.l (sp)+,D0-D1/A0-A1	* Restore registers
		bclr	#0,$FFFFFA0f.w		* Disable interrupt
		rte


newtb1a:	clr.b	$FFFFFA1B.w		* Disable TimerB
		movem.l D0-D1/A0-A1,-(sp)	* Store Registers
		move.w	#$FA21,A1		* A1 = FFFFA21
		move.b	#20,(A1)		* Down ? lines
		move.l	#newtb1b,$120		* Place the new vector address
		move.b	#8,$FFFFFA1B.w		* Enable Timer
* \Now create pretty rasters

		move.w	#11,D1		* Raster is 12 scanlines
		move.l	#pretty2,A0
nloop3: 	move.b	(A1),D0 	* Read TimerB into D0
nwait3: 	cmp.b	(A1),D0
		beq	nwait3		* Wait 1 scanline
		move.w	(A0)+,$FF8250	* And logo
		dbra	D1,nloop3

		movem.l (sp)+,D0-D1/A0-A1	* Restore registers
		bclr	#0,$FFFFFA0f.w		* Disable interrupt
		rte

newtb1b:	clr.b	$FFFFFA1B.w		* Disable TimerB
		movem.l D0-D1/A0-A1,-(sp)	* Store Registers
		move.w	#$FA21,A1		* A1 = FFFFA21
		move.b	#20,(A1)		* Down ? lines
		move.l	#newtb1c,$120		* Place the new vector address
		move.b	#8,$FFFFFA1B.w		* Enable Timer
* \Now create pretty rasters

		move.w	#11,D1		* Raster is 12 scanlines
		move.l	#pretty2,A0	* Point to palette
nloop4: 	move.b	(A1),D0 	* Read TimerB into D0
nwait4: 	cmp.b	(A1),D0
		beq	nwait4		* Wait 1 scanline
		move.w	(A0)+,$FF8250	* And logo
		dbra	D1,nloop4

		movem.l (sp)+,D0-D1/A0-A1	* Restore registers
		bclr	#0,$FFFFFA0f.w		* Disable interrupt
		rte

newtb1c:	clr.b	$FFFFFA1B.w		* Disable TimerB
		movem.l D0-D1/A0-A1,-(sp)	* Store Registers
		move.w	#$FA21,A1		* A1 = FFFFA21
		move.b	#20,(A1)		* Down ? lines
		move.l	#newtb1d,$120		* Place the new vector address
		move.b	#8,$FFFFFA1B.w		* Enable Timer
* \Now create pretty rasters

		move.w	#11,D1		* Raster is 12 scanlines
		move.l	#pretty2,A0
nloop5: 	move.b	(A1),D0 	* Read TimerB into D0
nwait5: 	cmp.b	(A1),D0
		beq	nwait5		* Wait 1 scanline
		move.w	(A0)+,$FF8250	* And logo
		dbra	D1,nloop5

		movem.l (sp)+,D0-D1/A0-A1	* Restore registers
		bclr	#0,$FFFFFA0f.w		* Disable interrupt
		rte

newtb1d:	clr.b	$FFFFFA1B.w		* Disable TimerB
		movem.l D0-D1/A0-A1,-(sp)	* Store Registers
		move.w	#$FA21,A1		* A1 = FFFFA21
		move.b	#20,(A1)		* Down ? lines
		move.l	#newtb1e,$120		* Place the new vector address
		move.b	#8,$FFFFFA1B.w		* Enable Timer
* \Now create pretty rasters

		move.w	#11,D1		* Raster is 12 scanlines
		move.l	#pretty2,A0
nloop6: 	move.b	(A1),D0 	* Read TimerB into D0
nwait6: 	cmp.b	(A1),D0
		beq	nwait6		* Wait 1 scanline
		move.w	(A0)+,$FF8250	* And logo
		dbra	D1,nloop6

		movem.l (sp)+,D0-D1/A0-A1	* Restore registers
		bclr	#0,$FFFFFA0f.w		* Disable interrupt
		rte

newtb1e:	clr.b	$FFFFFA1B.w		* Disable TimerB
		movem.l D0-D1/A0-A1,-(sp)	* Store Registers
		move.w	#$FA21,A1		* A1 = FFFFA21
		move.b	point1,(A1)		* Down ? lines
		move.l	#newtb2,$120		* Place the new vector address
		move.b	#8,$FFFFFA1B.w		* Enable Timer
* \Now create pretty rasters

		move.w	#11,D1		* Raster is 12 scanlines
		move.l	#pretty2,A0
nloop7: 	move.b	(A1),D0 	* Read TimerB into D0
nwait7: 	cmp.b	(A1),D0
		beq	nwait7		* Wait 1 scanline
		move.w	(A0)+,$FF8250	* And logo
		dbra	D1,nloop7

		movem.l (sp)+,D0-D1/A0-A1	* Restore registers
		bclr	#0,$FFFFFA0f.w		* Disable interrupt
		rte

pretty: 	dc.w	$002,$003,$004,$005,$006,$007
		dc.w	$006,$005,$004,$003,$002,$000

pretty2:	dc.w	$222,$332,$442,$552,$662,$772
		dc.w	$662,$552,$442,$332,$222,$007


newtb2: 	clr.b	$FFFFFA1B.w		* Disable TimerB
		movem.l D0-D1/A0-A1,-(sp)	* Store Registers
		move.w	#$FA21,A1		* A1 = FFFFA21
		move.b	point2,(A1)		* Down another 44 lines
		move.l	#killborder,$120	* Place the new vector address
		move.b	#8,$FFFFFA1B.w		* Enable Timer
		move.w	#$777,$FF8242		* Set new colours
		move.w	#$666,$FF8244
		move.w	#$555,$FF8246
		move.w	#$444,$FF8248
		move.w	#$333,$FF824A		* Done first 5

		move.w	#$600,$FF8252
		move.w	#$500,$FF8254
		move.w	#$400,$FF8256
		move.w	#$300,$FF8258
		move.w	#$200,$FF825A

		movem.l (sp)+,D0-D1/A0-A1	* Restore registers
		bclr	#0,$FFFFFA0f.w		* Disabel interrupt
		rte

* \Removes the lower border

killborder	clr.b	$FFFFFA1B.w	* Disable B
		movem.l D0-D1/A0-A1,-(sp)	* Store registers
		move.w	#$fA21,A1		* A1 = FFFFFA21
		move.b	#2,(A1)
		move.l	#lo_rasts,$120
		move.b	#8,$FFFFFA1B.w		* Enable TimerB

		move.b	(A1),D0
wait4:		cmp.b	(A1),D0 	* wait last scanline
		beq	wait4		
		clr.b	$FFFF820A.w	* 60 Hz
		moveq	#4,D0
nopi2:		nop			* wait a while
		dbf	D0,nopi2
		move.b	#2,$FFFF820A.w	* 50 Hz
		movem.l (sp)+,D0-D1/A0-A1	* Restore Registers	 
		bclr	#0,$FFFFFA0f.w	* End of interrupt
		rte

lo_rasts:	clr.b	$FFFFFA1B.w		* Disable TimerB
		movem.l D0-D1/A0-A2,-(sp)	* Store Registers
		move.w	#$FA21,A1		* A1 = FFFFA21
		move.b	#198,(A1)		* Down ? lines
		move.b	#8,$FFFFFA1B.w		* Enable Timer
* \Now create pretty rasters

		move.w	#34,D1		* Raster is 35 scanlines
		move.l	#pretty3,A0
		move.l	#pretty4,A2
nloop8: 	move.b	(A1),D0 	* Read TimerB into D0
nwait8: 	cmp.b	(A1),D0
		beq	nwait8		* Wait 1 scanline
		move.w	(A0)+,$FF8240	* And logo
		move.w	(A2)+,$FF8250
		dbra	D1,nloop8

		movem.l (sp)+,D0-D1/A0-A2	* Restore registers
		bclr	#0,$FFFFFA0f.w		* Disable interrupt
		rte

pretty3:	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
		dc.w	$600,$500,$400,$300,$200,$100,$000,$100
		dc.w	$200,$300,$400,$500,$600,$700,$600,$500
		dc.w	$400,$300,$200,$100,$000,$100,$200,$300
		dc.w	$400,$500,$000

pretty4:	dc.w	$000,$112,$222,$332,$442,$552,$662,$772
		dc.w	$662,$552,$442,$332,$222,$112,$000,$112
		dc.w	$222,$332,$442,$552,$662,$772,$662,$552
		dc.w	$442,$332,$222,$112,$000,$112,$222,$332
		dc.w	$442,$552,$000

*********************************

msoff:		move.l	#moff,-(sp)	* Disable mouse
		clr.w	-(sp)
		move.w	#25,-(sp)
		trap	#14
		addq.l	#8,sp
		dc.w	$A00A
		rts
		
mson:		move.l	#mon,-(sp)	* Re-enable mouse
		clr.w	-(sp)
		move.w	#25,-(sp)
		trap	#14
		addq.l	#8,sp
		dc.w	$A009
		rts
mon:		dc.b	$08
moff:		dc.b	$12

		EVEN

save_stack:	ds.l	1
real_phys:	ds.l	1
real_log:	ds.l	1
old_rez:	ds.w	1
old_pal:	ds.w	16
physic: 	ds.w	1
physic2:	ds.w	1
logic:		ds.l	1
status: 	ds.w	1
point1: 	dc.b	53
point2: 	dc.b	44
v_logo: 	dc.b	2
dummy:		ds.b	1
vlogo_ptr:	ds.l	1

images_1:	INCBIN		"A:\MAINMENU\SHIFTED3.PI1",0

images_2:	INCBIN		"A:\MAINMENU\SHIFTED4.PI1",0

menu_pic:	INCBIN		"A:\MAINMENU\MAINMENU.PI1",0


