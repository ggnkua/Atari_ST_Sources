
*********************************************************
* dastart.s -- desk accessory startup code for Atari ST *
* public domain -- July 1989 by Steve Yelvington        *
* written for Sozobon C and jas.ttp assembler           *
*********************************************************

	.bss
	.even
stackbottom:
	.ds.b 	1024	* Set up a small stack
initstack:
	.ds.l	1	* and a top for it
saveret:
	.ds.l	1	* A place to store PC during OS traps

	.text			* Watch closely; this won't last long!
begin_acc:			* We start
	move.l	#initstack,sp	* by loading the stack pointer
	jsr _main		* jump to main()
	clr.w	(sp)		* Shouldn't get here! Put a zero on the stack
	trap	#1		* and terminate (Pterm0)

	**********************************************************
	* That's all there is to it. The rest of this file       *
	* provides gemdos, xbios and bios hooks on the assumption*
	* that your DA might actually do something. :-)          *
	* Note: I'm not checking the stack here. See DSTART.S by *
	* Dale Schumacher if you want to do that sort of thing   *
	**********************************************************
	.globl	_gemdos
_gemdos:
	move.l	(sp)+,saveret	* save return address
	trap	#1		* hand off to the operating system
	move.l	saveret,-(sp)	* restore the natural order of things
	rts

	.globl	_bios
_bios:
	move.l	(sp)+,saveret
	trap	#13		
	move.l	saveret,-(sp)
	rts

	.globl	_xbios
_xbios:
	move.l	(sp)+,saveret	
	trap	#14		
	move.l	saveret,-(sp)
	rts

	.globl _crystal
	* NOTICE: this is an AES binding needed with the GEMQ library...
	* just comment it out if you use only GEMFAST.
_crystal:
	move.l	4(sp),d1	* load aes parameter block ptr into d1
	move.w	#$C8,d0		* load magic number into d0
	trap	#2		* kick AES into action
	rts

