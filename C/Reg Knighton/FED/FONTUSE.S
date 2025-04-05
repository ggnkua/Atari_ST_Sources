* fontuse.s by Reg Knighton 3-5-86
*
* external references: contrl, vdi() (contained in vdibind)
*
* usage from 'C':
*
* void v_regf(handle, &fontheader, &effects_buffer, half_of_effects_buffer);
* int			handle;
* struct font_hdr	fontheader;
* unsigned short	effects_buffer[];
* int			half_of_effects_buffer;
*
* void v_initf(&font)
* struct font_hdr *font;
*

* positions of members in font header structure

ADE_lo		=	36
ADE_hi		=	38
wcel_wdt	=	52
flags		=	66
hz_ofst		=	68
ch_ofst		=	72
fnt_dta		=	76
frm_wdt		=	80
frm_hgt		=	82
nxt_fnt		=	84

		.text

		.globl	_v_regf
		.globl	_v_initf

*		v_regf() registers font list with GEM VDI

_v_regf:
		move.w	14(sp),_contrl+18	;half #bytes effect buffer size
		move.l	10(sp),_contrl+14	;effects buffer address
		move.l	6(sp),_contrl+20	;font header address
		move.w	4(sp),_contrl+12	;handle
		move.w	#119,_contrl		;VDI function opcode #
		jsr	_vdi			;yo, VDI
		rts				;return to caller
		
*		v_initf() updates pointers to chr offset table & font data
*		also updates pointer to horizontal offset table if present

_v_initf:	

* 		pass header address to VDI and update ptr to chr offset table

		move.l	4(sp),a2	* get address of font header

		move.l	a2,a1		* make copy
		add.l	#88,a1		* add in font header size
 		move.l	a1,ch_ofst(a2)	* update pointer_to_offset_table

*		update ptr to font data by determining chr offset table size

		move	ADE_hi(a2),d0	* get ADE hi
		sub	ADE_lo(a2),d0	* ADE_hi - ADE_lo -> d0	
		addq	#2,d0		* adjust for ADE_hi, ADE_hi + 1 
		add	d0,d0		* 2 bytes ber table element
		ext.l	d0		* clean out high word
		add.l	d0,a1		* point to font_data
		move.l	a1,fnt_dta(a2)	* update pointer_to_font_data		

*		update horizontal offset table ptr if table present

		clr.l	hz_ofst(a2)	* NULLify horiz offset table pointer

		move	flags(a2),d0	* get status flags for testing
		andi	#2,d0		* does horizontal table exist?
		beq.s	apre_hz		* no, skip over pointer arithmetic

		move	frm_wdt(a2),d0	* yes, get form width
		mulu	frm_hgt(a2),d0	* multiply it by form height
		ext.l	d0		* clean out junk
		add.l	d0,a1		* add it to address of font data
		move.l	a1,hz_ofst(a2)	* update horizontal offset table ptr

*		effects buffer size rule: 4 bytes per pixel of biggest char

apre_hz:	rts
		.end
