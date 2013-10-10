// interupt handlers
Int1_A1_H::
	push   R17
	in	   R17,0x13		// read from ACSI

	push   R16			// save registers

	in	   R16,0x3f		// get SREG content
	push   R16			// put it on the stack
	
	ldi	   R16,1	   	// load value of A1
//---------
	push   R0
	push   R2
	push   R3
	push   R24
	push   R25
	push   R30
	push   R31
//---------
	call   _int1_isr   	// call C function
//---------
	pop	   R31
	pop	   R30
	pop	   R25
	pop	   R24
	pop	   R3
	pop	   R2
	pop	   R0
//---------
	pop	   R16			// get the content of SREG
	out	   0x3f,R16		// restore the SREG
	
	pop	   R16
	pop	   R17			// restore registers
	reti
//-------------------------
Int1_A1_L::
	push   R17
	in	   R17,0x13		// read from ACSI

	push   R16			// save registers

	in	   R16,0x3f		// get SREG content
	push   R16			// put it on the stack
	
	ldi	   R16,0	   	// load value of A1
//---------
	push   R0
	push   R2
	push   R3
	push   R24
	push   R25
	push   R30
	push   R31
//---------
	call   _int1_isr   	// call C function
//---------
	pop	   R31
	pop	   R30
	pop	   R25
	pop	   R24
	pop	   R3
	pop	   R2
	pop	   R0
//---------
	pop	   R16			// get the content of SREG
	out	   0x3f,R16		// restore the SREG
	
	pop	   R16
	pop	   R17			// restore registers
	reti
//-------------------------

