* Modify addr references of code and data segments based on GEMDOS relocation
* information format:
*    a3 points to the buffer which store the relocation info;
*    d1 keeps the byte count processed in the buffer; when d1 becomes negative
*	more relocation info was read into buffer;
*    a2 points to the address to be modified;
*    d5 keeps the difference to be added to the content pointed by a2;
reloc:
    	move.l basepg, a3		* a3 points to the buffer
    	bsr	readseq			* read relocation info into buffer
    	tst.l	d1			* if reads ok?
    	blt	rdbad			* no, goto rdbad
    	subq.l	#1, d1			* d1 loop count
    	tst.l	(a3)			* if there any reloc info?
    	beq	lddone			* no, done
    	adda.l	(a3), a2		* the offset to the text seg
    	tst.b	(a3)+			* just advance a3
    	bra	reloc2
readrel:
    	move.l basepg, a3		* a3 points to the buffer
    	bsr	readseq			* read relocation info into buffer
    	tst.l	d1			* if reads ok?
    	blt	rdbad			* no, goto rdbad
    	subq.l	#1, d1			* d1 loop count
reloc1:
    	clr.l	d3			* d3, relocation byte from buffer
    	move.b	(a3)+, d3		* get it from buffer
    	tst.b	d3			* if it is the end of rel info?
    	beq	lddone			* done
    	cmpi.b	#1, d3			* if it = 1?
    	beq	add254			* goto add254
    	andi.l	#255, d3		* 0xff & d3
    	adda.l	d3, a2			* add the offset 
reloc2:					* modify the code
    	move.l	(a2),d6	
    	add.l	d5, d6			* d5 contains the (cseg - tstart)
    	move.l	d6, (a2)		
count:
    	dbf	d1, reloc1		* if more in buffer, goto reloc1
    	bra 	readrel			* read more reloc info into buffer
add254:
    	addi.l	#254, a2		* add 254 to a2
    	bra 	count			* goto loop counter
