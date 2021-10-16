|******************
|  
|  $Id: screen.s 3279 2021-09-03 20:13:24Z trevor $
|  
|  replacement screen.sys screen driver to redefine the dpi rez
|
|  for gnu c compile with:
|     cc -nostdlib -s -o screen90.sys screen.s
|  
|*****************


| vdi opcodes

V_OPENWK	= 1
V_OPENVWK	= 100
VINQ_WK		= 102


| dot sizes in microns for 80 & 90 dpi
| 25400/80 = 317.5 = 0x013d
| 25400/90 = 282.2 = 0x011a

dpixy90		= 0x011a011a
dpixy80		= 0x013d013d

	.data
	.even
address:	.long	0	| save address of vdi screen driver

	.text
	.even

	movel	a0,sp@-		| save regs
	movel	d0,sp@-
	movel	d1,a0		| &vdi param block
	movel	a0@,a0		| & contrl[]
	movew	a0@,d0		| opcode
	cmpiw	#V_OPENWK,d0	| v_openwk()?
	bne	not_open
	moveq	#-1,d0		| yes
	trap	#2		| get address of screen driver routine in ROM
	movel	d0,address	| save it
	bra     mod_dpi

not_open:
	cmpiw	#V_OPENVWK,d0	| v_openvwk() ?
	beq	mod_dpi
        cmpiw	#VINQ_WK,d0	| vinq_wk() ?
	bne	over1
	movel	d1,a0		| address of vdi param block
	movel	a0@(4),a0	| address of intin[]
	tstw	a0@		| modify only for mode 0
	bne	over1
mod_dpi:
        movel	sp@+,d0         | restore d0
	movel	address,a0
	jsr     a0@		| call screen driver
	movel	d1,a0		| address of vdi param block
	movel	a0@(12),a0	| address of intout[]
	movel	#dpixy90,a0@(6) | set x & y res to 90 dpi
        movel	sp@+,a0         | restore a0
	rts


over1:
        movel	sp@+,d0         | restore d0
	movel	address,a0
	jsr     a0@		| call screen driver
        movel	sp@+,a0         | restore a0
	rts
	
	
|=============== end of file ===============

