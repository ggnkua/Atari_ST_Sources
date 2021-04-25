/ 
/  REL.S   Modified by S. CRUNK  11/1/89
/  
/  	original by Timothy Purves ,MICHTRON
/
/          Substitution for GFA's EXEC loader
/          Walks Fixup list for .PRG to relocate code 
/          This is absolutely necessary, UNLESS you have written
/          pure position independent code (branches, no jumps, etc.)
/          I use this to bind all my compiled C and assembly code
/          into GFA INLINE. 

magic	=	0
text_size	=	2
data_size	=	6
bss_size	=	10
sym_size	=	14
headsize	=	0x1c

	.globl	xmain           /we use xmain, since it must match with
	.shri			/the lable in the linked code.
dynamic:	
	lea	init(pc), a0
	tst	(a0)
	bne	init_done
	move	$1, (a0)
	lea	dynamic(pc), a0
	move.l	a0, d0          	/ text base
	movea.l	a0, a1
	suba	$headsize, a1     	/ points to header
	adda.l	text_size(a1), a0
	adda.l	data_size(a1), a0
	move.l	a0, -(sp)         	/ address BSS
	move.l	bss_size(a1), -(sp)   	/ length!
	adda.l	sym_size(a1), a0
	movea.l	(a0), a1          	/ a1 = rel_offset
	tst.l	(a0)+
	beq	clr_bss        		/ no relocation
	adda.l	d0, a1          	/ address to relocate
/
/
/ a1.l = relocation address
/ a0.l = relocation table ptr
/ d0.l = adjust factor (text_base)
/ d1.w offset to next
/
/
	clr	d1
relocate:	
	add.l	d0, (a1)       	/ relocate!
	move.b	(a0)+, d1
	beq	clr_bss        	/ end of table
	adda	d1, a1         	/ move to next location
	cmpi	$1, d1         	/ special case (254)
	bne	relocate
	adda	$253, a1       	/ case of 1 then add (254 - 1)
	bra	relocate

init:	.word	0

clr_bss:	
	move.l	(sp)+, d0
	movea.l	(sp)+, a0
	bra	over
clr_loop:	
	clr.b	(a0)+
over:	
	dbf	d0, clr_loop

init_done:	
	jmp	xmain      		/this jumps into our code     


