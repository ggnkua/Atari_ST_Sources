;***********************************************************
;*        ROB NORTHERN UNPACK ROUTINE FOR RNC1             *
;***********************************************************
;*                                                         *
;*Assembler: MIPS R4300 / ASMN64 (PSY-Q)                   *
;*By : Icarus/TRSi&LFC                                     *
;*Version  : 2.00                                          *
;*Amiga Original Code by: Rob/Quartex                      *
;*                                                         *
;*Thanks to Wild Fire for some help/idea                   *
;*                                                         *
;*Okay.. I cleaned up the routine a little bit..           *
;*You dont have to save any registers to stack, coz the    *
;*will do it for you!                                      *
;*                                                         *
;***********************************************************

;***********************************************************
;*                                                         *
;* INPUT:                                                  *
;* a0 = source, pointer to the packed data!                *
;* a1 = destination, pointer to the dest. address in ram!  *
;*                                                         *
;***********************************************************


		opt at-

		opt h-

		opt ae+



depackrnc:
	move	a3,a0
	move	s0,a1
	addiu 	sp,sp,0xffffffc0  
	sw 	ra,0x0020(sp) 
	jal 	_5b8
	nop
	lw 	ra,$20(sp)
	nop
	addiu 	sp,sp,0x0040
	jr	ra
	nop

_5b8: 
	sw 	s0,0x0018(sp)  
	sw 	ra,0x001c(sp) 
	jal 	_640
	nop
	lw	ra,0x001c(sp) 
	lw 	s0,0x0018(sp)
	jr 	ra
	nop

_640:
	addi 	sp,sp,0xffffffa8
	sw 	a0,0x0000(sp) 
	sw 	a1,0x0004(sp)
	sw 	a2,0x0008(sp) 
	sw 	a3,0x000c(sp)
	sw 	t0,0x0010(sp)
	sw 	t1,0x0014(sp)
	sw 	t2,0x0018(sp)
	sw 	t3,0x001c(sp)
	sw 	t4,0x0020(sp)
	sw 	t5,0x0024(sp)
	sw 	t6,0x0028(sp)
	sw 	t7,0x002c(sp)
	sw 	s0,0x0030(sp)
	sw 	s1,0x0034(sp)
	sw 	s2,0x0038(sp)
	sw 	s3,0x003c(sp)
	sw 	s4,0x0040(sp)
	sw 	s5,0x0044(sp) 
	sw 	s6,0x0048(sp)
	sw 	s7,0x004c(sp)
	sw 	ra,0x0050(sp)
	move 	s0,a0
	move 	s1,a1
	jal 	_708
	nop
	lw 	a0,0x0000(sp)
	lw 	a1,0x0004(sp)
	lw 	a2,0x0008(sp) 
	lw 	a3,0x000c(sp)
	lw 	t0,0x0010(sp)
	lw 	t1,0x0014(sp)
	lw 	t2,0x0018(sp)
	lw 	t3,0x001c(sp)
	lw 	t4,0x0020(sp) 
	lw 	t5,0x0024(sp)
	lw 	t6,0x0028(sp)
	lw 	t7,0x002c(sp)
	lw 	s0,0x0030(sp)
	lw 	s1,0x0034(sp)
	lw 	s2,0x0038(sp)
	lw 	s3,0x003c(sp)
	lw 	s4,0x0040(sp)
	lw 	s5,0x0044(sp)
	lw 	s6,0x0048(sp) 
	lw 	s7,0x004c(sp)
	lw 	ra,0x0050(sp)
	addi 	sp,sp,0x0058
	jr 	ra 
	nop

_708: 
	addi 	v1,zero,0xffffffff  
	andi 	v1,v1,0x00ff 
	sll 	a0,v1,0x18
	sll 	a1,v1,0x1f 
	srl 	a3,a1,0x10 
	nor 	a2,zero,v1 
	addi 	sp,sp,0xfffffe80 
	move 	s2,sp
	addi 	sp,sp,0xfffffff8
	sw 	ra,0x0000(sp)
	addi 	s0,s0,0x0004
	jal 	_a04
	nop
	addi 	s3,s0,0x000a
	move 	s4,s1
	lbu 	t6,0x0001(s3) 
	lbu 	at,0x0000(s3)
	move 	t7,zero 
	sll 	t6,t6,0x8
	or 	t6,t6,at
	add 	s5,s4,t0
	addi 	t0,zero,0x0002
	addi 	t1,zero,0x0002
	jal 	_994
	nop 
	lw 	ra,0x0000(sp)
	addi 	sp,sp,0x0008
_774:
	 addi 	sp,sp,0xfffffff8
	 sw 	ra,0x0000(sp)
	move 	s0,s2
	jal 	_a28
	nop  
	addi 	s0,s2,0x0080
	jal 	_a28
	nop
	addi 	s0,s2,0x0100
	jal 	_a28
	nop 
	addi 	t0,zero,0xffffffff
	addi 	t1,zero,0x0010
	jal 	_994 
	nop
	lw 	ra,0x0000(sp)
	addi 	sp,sp,0x0008  
	move 	t4,t0 
	addi 	at,zero,0xffffffff 
	srl 	at,at,0x10 
	addi 	t4,t4,0xffffffff
	and 	t4,at,t4
	j 	_834
	nop
_7d4: 
	addi 	s0,s2,0x0080
	addi 	sp,sp,0xfffffff8
	sw 	ra,0x0000(sp)
	move 	t0,zero
	jal 	_8bc
	nop
	negu 	t0,t0
	add 	s1,s4,t0 
	addi 	s1,s1,0xffffffff 
	addi 	s0,s2,0x0100
	jal 	_8bc
	nop 
	lw 	ra,0x0000(sp) 
	addi 	sp,sp,0x0008 
	addi 	s4,s4,0x0001
	lbu 	at,0x0000(s1) 
	addi 	s1,s1,0x0001 
	sb 	at,0xffffffff(s4)
_81c: 
	addi 	s4,s4,0x0001
	lbu 	at,0x0000(s1)
	addi 	s1,s1,0x0001 
	sb 	at,0xffffffff(s4) 
	bnez 	t0,_81c 
	addi 	t0,t0,0xffffffff 
_834:
	addi 	sp,sp,0xfffffff8
	sw 	ra,0x0000(sp) 
	move 	s0,s2 
	jal 	_8bc
	nop  
	lw 	ra,0x0000(sp) 
	addi 	sp,sp,0x0008
	addi 	t0,t0,0xffffffff 
	bltz 	t0,_89c
	nop  
	addi 	sp,sp,0xfffffff8
	sw 	ra,0x0000(sp)
	jal 	_ba8 
	nop 
	lw 	ra,0x0000(sp) 
	addi 	sp,sp,0x0008 
	lbu 	at,0x0001(s3) 
	lbu 	t0,0x0000(s3) 
	sll 	at,at,0x8
	or	t0,at,t0
	sllv 	t0,t0,t7
	addi 	t1,zero,0x0001 
	sllv 	t1,t1,t7 
	addiu 	t1,t1,0xffffffff
	and 	t6,t6,t1
	or 	t6,t0,t6 
_89c: 
	bnez 	t4,_7d4 
	addi 	t4,t4,0xffffffff 
	sub 	at,s4,s5
	bltz 	at,_774 
	nop 
	addi 	sp,sp,0x0180 
	jr 	ra
	nop 
_8bc: 
	lbu 	t0,0x0000(s0) 
	lbu 	at,0x0001(s0)
	addi 	s0,s0,0x0002
	sll 	t0,t0,0x8 
	or 	t0,at,t0 
	and 	t0,t0,t6 
	lbu 	at,0x0000(s0)
	lbu 	v0,0x0001(s0) 
	addi 	s0,s0,0x0002
	sll 	at,at,0x8
	or 	at,at,v0
	sub 	t0,t0,at  
	bnez 	t0,_8bc   
	nop
	lbu 	t1,0x003c(s0)
	nop  
	sub 	t7,t7,t1 
	bgez 	t7,_920
	nop 
	addi 	sp,sp,0xfffffff8
	sw 	ra,0x0000(sp)
	jal 	_9c8
	nop 
	lw 	ra,0x0000(sp)
	addi 	sp,sp,0x0008 
_920: 
	srlv 	t6,t6,t1
	lbu 	t0,0x003d(s0)
	nop
	addi 	at,t0,0xfffffffe 
	bltz 	at,_98c
	nop
	addi 	t0,t0,0xffffffff 
	move 	t1,t0
	move 	t2,t0
	lbu 	at,0x003e(s0) 
	lbu 	t0,0x003f(s0)
	sll 	at,at,0x8
	or 	t0,at,t0 
	and 	t0,t0,t6
	sub 	t7,t7,t1
	bgez 	t7,_97c
	nop
	addi 	sp,sp,0xfffffff8 
	sw 	ra,0x0000(sp)
	jal 	_9c8 
	nop  
	lw 	ra,0x0000(sp)
	addi 	sp,sp,0x0008 
_97c: 
	srlv 	t6,t6,t1  
	addi 	at,zero,0x0001
	sllv 	at,at,t2 
	or 	t0,at,t0 
_98c: 
	jr 	ra 
	nop

_994: 
	and 	t0,t6,t0 
	sub 	t7,t7,t1  
	bgez 	t7,_9bc
	nop
	addi 	sp,sp,0xfffffff8
	 sw 	ra,0x0000(sp) 
	jal 	_9c8
	nop  
	lw 	ra,0x0000(sp)  
	addi 	sp,sp,0x0008  
_9bc: 
	srlv 	t6,t6,t1 
	jr 	ra 
	nop 

_9c8: 
	add 	t7,t7,t1
	srlv 	t6,t6,t7 
	addi 	s3,s3,0x0004
	lbu 	at,0xfffffffe(s3) 
	lbu 	v0,0xffffffff(s3) 
	addi 	s3,s3,0xfffffffe
	sll 	at,at,0x10 
	sll 	v0,v0,0x18
	or 	t6,t6,v0 
	or 	t6,t6,at  
	sub 	t1,t1,t7 
	addi 	t7,zero,0x0010
	sub 	t7,t7,t1 
	jr 	ra 
	nop 

_a04: 
	addi 	t1,zero,0x0003
_a08: 
	sll 	t0,t0,0x8  
	lbu 	at,0x0000(s0) 
	addi 	s0,s0,0x0001
	or 	t0,at,t0
	bnez 	t1,_a08 
	addi 	t1,t1,0xffffffff 
	jr 	ra
	nop 

_a28: 
	addi 	t0,zero,0x001f  
	addi 	t1,zero,0x0005 
	addi 	sp,sp,0xfffffff8 
	sw 	ra,0x0000(sp) 
	jal 	_994
	nop  
	lw 	ra,0x0000(sp) 
	addi 	sp,sp,0x0008  
	addi 	t0,t0,0xffffffff  
	bltz 	t0,_ba0  
	nop
	move 	t2,t0
	move 	t3,t0
	addi 	sp,sp,0xfffffff0 
	move 	s1,sp    
_a64: 
	addi 	t0,zero,0x000f 
	addi 	t1,zero,0x0004
	addi 	sp,sp,0xfffffff8 
	sw 	ra,0x0000(sp) 
	jal 	_994
	nop
	lw 	ra,0x0000(sp)
	addi 	sp,sp,0x0008    
	sb 	t0,0x0000(s1)
	addi 	s1,s1,0x0001 
	bnez 	t2,_a64  
	addi 	t2,t2,0xffffffff  
	move 	t0,a1  
	addi 	t1,zero,0x0001 
	move 	t2,zero
	addi 	sp,sp,0xfffffff0
	sw 	t5,0x0000(sp)
	sw 	t6,0x0004(sp) 
	sw 	t7,0x0008(sp)  
_ab0: 
	move 	t4,t3  
	addi 	s1,sp,0x0010   
_ab8: 
	lbu 	at,0x0000(s1) 
	addi 	s1,s1,0x0001 
	bne 	t1,at,_b74
	nop  
	addi 	t5,zero,0x0001 
	sllv 	t5,t5,t1   
	addi 	t5,t5,0xffffffff   
	sb 	t5,0x0001(s0)
	srl 	at,t5,0x8  
	sb 	at,0x0000(s0) 
	addi 	s0,s0,0x0002  
	move 	t5,t2 
	sll 	at,t5,0x10   
	srl 	t5,t5,0x10 
	or 	t5,t5,at
	move 	t7,t1   
	addi 	t7,t7,0xffffffff
_afc: 
	addi 	at,zero,0xffffffff 
	srl 	at,at,0x10 
	and 	t6,at,t6 
	and 	at,t5,a3   
	sll 	t5,t5,0x1 
	srl 	t6,t6,0x1  
	beqz 	at,_b20 
	nop 
	or 	t6,t6,a3   
_b20: 
	bnez 	t7,_afc
	addi 	t7,t7,0xffffffff 
	addi	t5,zero,0x0010  
	sub 	t5,t5,t1 
	srlv 	t6,t6,t5
	sb 	t6,0x0001(s0)  
	srl 	at,t6,0x8  
	sb 	at,0x0000(s0) 
	addi 	s0,s0,0x0002 
	sb 	t1,0x003c(s0)  
	move 	t5,t3    
	subu 	t5,t5,t4   
	sb 	t5,0x003d(s0)   
	addi 	t6,zero,0x0001 
	addiu 	t5,t5,0xffffffff  
	sllv 	t6,t6,t5   
	addiu 	t6,t6,0xffffffff
	sb 	t6,0x003f(s0)
	srl 	at,t6,0x8   
	sb 	at,0x003e(s0)  
	addu 	t2,t2,t0   
_b74: 
	bnez 	t4,_ab8
	addi 	t4,t4,0xffffffff 
	srl 	t0,t0,0x1  
	addi 	t1,t1,0x0001
	addi 	at,zero,0x0011  
	bne 	t1,at,_ab0 
	lw 	t5,0x0000(sp) 
	lw 	t6,0x0004(sp) 
	lw 	t7,0x0008(sp) 
	addi 	sp,sp,0x0010   
	addi 	sp,sp,0x0010
_ba0: 
	jr 	ra  
	nop

_ba8: 
	lbu 	at,0x0000(s3)
	nop
	sb 	at,0x0000(s4) 
	addi 	s4,s4,0x0001 
	addi 	s3,s3,0x0001
	bnez	 t0,_ba8
	addi 	t0,t0,0xffffffff
	jr 	ra  
	nop 
