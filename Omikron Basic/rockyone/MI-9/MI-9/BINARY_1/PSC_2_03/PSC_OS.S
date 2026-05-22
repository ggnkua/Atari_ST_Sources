;rockyone			pour MI-3  and MI-9  		  25/01/2017
;
;
;  		   	OPEN	PAINTSHOP v2.03  FILE.psc
;		   	---------------------------------
;Op%  0 = open
;     1 = save
;		open  call psc_open( L source, L but, W op% )
;		SAVE  call psc_open( L but, L source, W op% )
;
;RETURN
;  In low d0 	-2 if error header
;		-5 if unknown order
;	 	 0 if not error
;		 The size of the file if Op% = 1
;  In high d0	 0 or the value of the byte that caused the error -5
;--------------------------------------------------------------------------
;+ 0 B  'tm89PS'
;+ 6 B 	$00 $cb $02 $01 $02 $7f $01 $8f
;+14 B   $0	file unpacked
;+14 B	$63     file packed
;--------------------------------------------------------------------------
;d0  return eror
;d1  cmd
;
;d6  cpt byte
;d7  cpt line  or repeat byte

		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1
		
		lea.l	header(pc),a2
		moveq.l	#13,d6

		tst.w	68(sp)
		bne	save_psc

;-----------------------------------------------OPEN SPC--------------

		moveq.l	#-2,d0			;R. bad file			
test_h:		cmpm.b	(a2)+,(a0)+		; test header
		bne	end_prg
		dbra.w	d6,test_h
	
		moveq.l	#0,d0			;R. not error

		move.w	#2,(a1)+		; write resol image
		move.l	#$fff0000,(a1)+		; write color 0 et 1
		lea.l	28(a1),a1

;................................................
;a0 a2 source
;a1 but
;a1

cod_63:		cmpi.b	#$63,(a0)		; fille  compressed ?
		bne.s	read_cmd		; yes

		addq.l	#1,a0
		move.w	#31999,d6		; number of repetition
		bsr.s	loop3			; literaly
		bra	end_prg

;------------------------------------------------COMPRESSED FILE---------

repeat_byte:	move.w	#79,d6
loop1:		move.b	d7,(a1)+
		dbra.w	d6,loop1

;................................................

read_cmd:	moveq.l	#$0,d7			

		move.b	(a0)+,d1		; read bytes of control

cmd_0:		beq.s	repeat_byte		; blalck line 

cmd_ff:		cmpi.b	#$ff,d1			; end of file
		beq.s	end_prg	

cmd_6e:		cmpi.b	#$6e,d1			; literal line
		bne.s	cmd_c8
		bsr.s	literaly
		bra.s	read_cmd

;...............................................REPEAT BYTE

cmd_c8:		cmpi.b	#$c8,d1
		bne.s	read_next_byte
		move.b	#$ff,d7			; white line
		bra.s	repeat_byte

read_next_byte:	move.b	(a0)+,d7		; repeat number of line
;						; or repeat byte 

cmd_64:		cmpi.b	#$64,d1			; line with the next_byte
		beq.s	repeat_byte

cmd_66:		cmpi.b	#$66,d1			; line with two bytes
		bne.s	cmd_a								

		move.w	#39,d6			; number of repetition
loop2:		move.b	d7,(a1)+		; repeat byte
		move.b	(a0),(a1)+		; repeat byte
		dbra.w	d6,loop2
		addq.l	#1,a0
		bra.s	read_cmd

;................................................RECOPY PREVIOUS LINE

cmd_a:		cmpi.b	#$a,d1			; number of copy
		beq.s	repeat_line

		addi.w	#256,d7			  
cmd_c:		cmpi.b	#$c,d1
		beq.s	repeat_line

		bra.s	UNKNOWN_CMD		; or bad file...

;................................................

literaly:	move.w	#79,d6		
loop3:		move.b	(a0)+,(a1)+
		dbra.w	d6,loop3
		rts

repeat_line:	movea.l	a0,a2
		lea.l	-80(a1),a0

loop7:		bsr.s	literaly		
		dbra.w	d7,loop7
		movea.l	a2,a0	
		bra.s	read_cmd
		
;.........................................................................

UNKNOWN_CMD:	moveq.l	#-5,d0				;R. error
		swap d0
		move.b	d1,d0				; cmd  ??
		swap d0
end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts

;*****************************************************-SAVE PSC-********
;
; Retrun the size of the file in low d0
:
;--------------------------------------------------------------------------

save_psc:	exg.l	a0,a1	

		lea.l	34(a0),a0
		lea.l	32000(a0),a4	; end source
		movea.l	a1,a6		; to calculate the file of the size

write_header:	move.b	(a2)+,(a1)+	
		dbra.w	d6,write_header
	
;..............................................
;a0 a2 a3 a4    source
;a1 a6 		but
;d0		cpt equal line
;d1		cpt loop
;d2     	compares words or bytes
;d3		cmd


loop_pic:	movea.l	a0,a2		; to compare 

						
;...............................................COMPARE BYTE ON A LINE

		move.w	(a2),d2		
		lea.l	2(a2),a3

		moveq.l	#38,d1		; 80 bytes by line
loop_1:		cmp.w	(a3)+,d2
		bne.s	s_literaly
		dbra.w	d1,loop_1

		lea.l	80(a0),a0
	
		cmp.b	(a2),d2		; cmp firts and second byte
		bne.s	two_byte

		tst.b	d2
		beq.s	black_line

		cmpi.b	#$ff,d2
		beq.s	white_line
;					write the control byte of this line
other_line:	move.b	#$64,(a1)+		; cmd_64
		move.b	d2,(a1)+
		bra.s 	compare_line

white_line:	move.b	#$c8,(a1)+		; cmd_c8
		bra.s	compare_line

black_line:	move.b	#$0,(a1)+		; cmd_0
		bra.s	compare_line

two_byte:	move.b	#$66,(a1)+		; cmd_66
		move.b	(a2),(a1)+
		move.b	1(a2),(a1)+	
		bra.s	compare_line

s_literaly:	move.b	#$6e,(a1)+		; cmd_6e
		moveq.l	#79,d1		
write_line:	move.b	(a0)+,(a1)+
		dbra.w	d1,write_line

;...............................................	

compare_line:	movea.l	a0,a3	

		moveq.l	#0,d0			; reset cpt equal line

next_line:	moveq.l	#19,d1			; 80 bytes by line			

cmp_lines:	cmpm.l	(a2)+,(a3)+
		bne.s	not_equal
		dbra.w	d1,cmp_lines

		lea.l	80(a0),a0
		addq.b	#1,d0

		cmp.l	a0,a4			; end pic ?
		bhi.s	next_line							

not_equal:	tst.w	d0
		beq.s	test_eof_pic

		moveq.l	#$a,d3
		subq.l	#1,d0		
		cmpi.w	#256,d0
		bmi.s	s_cmd_a

		move.b	#$c8,d3			; cmd_8
		subi.w	#256,d0
s_cmd_a:	move.b	d3,(a1)+		; cmd_a
		move.b	d0,(a1)+
		
test_eof_pic:	cmp.l	a0,a4
		bhi	loop_pic

;.......................................

		bsr.s	eof_pic
		cmp.l	#32017,a1	; compressing useful ?
		bmi.s	size_ok		; valid compressed file
					
;.......................................uncompressed file  
;					if size file > 32016
		move.l	60(sp),a1
		move.l	64(sp),a0
		lea.l	34(a0),a0
		lea.l	14(a1),a1
		move.b	#$63,(a1)+	; uncopressed code

		move.l	#31999,d1
recopy:		move.b	(a0)+,(a1)+
		dbra.w	d1,recopy

		bsr.s	eof_pic

;.......................................

size_ok:	move.l	a1,d0
		bra	 end_prg
;.......................................
eof_pic:	move.b	#$ff,(a1)+		eof code
		suba.l	a6,a1
		rts

;---------------------------------------
	
header:		dc.b	'tm89PS',$00,$cb,$02,$01,$02,$7f,$01,$8f
	
		
		end
;			***************************



		

		


