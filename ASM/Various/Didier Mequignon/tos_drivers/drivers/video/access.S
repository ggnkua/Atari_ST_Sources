/* Utility functions calls provided by the fVDI engine
 * some libc functions for the Coldfire needed by GCC
 * and PCI bios calls from _PCI cookie
 *
 * Didier Mequignon 2005-2007, e-mail: aniplay@wanadoo.fr
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
 
#include "config.h"
 
#define func_copymem 0
#define func_next_line 4
#define func_skip_space 8
#define func_get_token 12
#define func_equal 16
#define func_length 20
#define func_copy 24
#define func_cat 28
#define func_numeric 32
#define func_atol 36
#define func_error 40
#define func_malloc 44
#define func_free 48
#define func_puts 52
#define func_ltoa 56
#define func_get_cookie 60
#define func_set_cookie 64
#define func_fixup_font 68
#define func_unpack_font 72
#define func_insert_font 76
#define func_get_size 80
#define func_allocate_block 84
#define func_free_block 88
#define func_cache_flush 92
#define func_misc 96
#define func_event 100

	.global _access,save_d0,__bzero,_bzero,_memset,_memmove,_memcpy
#ifndef COLDFIRE
	.global _cpush_dc
#endif
	.global _Funcs_copymem,_Funcs_next_line,_Funcs_skip_space,_Funcs_get_token
	.global _Funcs_equal,_Funcs_length,_Funcs_copy,_Funcs_cat,_Funcs_numeric
	.global _Funcs_atol,_Funcs_error,_Funcs_malloc,_Funcs_free,_Funcs_puts
	.global _Funcs_ltoa,_Funcs_get_cookie,_Funcs_set_cookie,_Funcs_fixup_font
	.global _Funcs_unpack_font,_Funcs_insert_font,_Funcs_get_size,_Funcs_allocate_block
	.global _Funcs_free_block,_Funcs_cache_flush,_Funcs_misc,_Funcs_event
#ifdef COLDFIRE
	.global _SMUL_DIV
#endif
	.global _Isin,_Icos,_isqrt,_swap_short,_swap_long,__swap_short,__swap_long
	.global _tab_funcs_pci,_Find_pci_device,_Find_pci_classcode,_Read_config_byte,_Read_config_word,_Read_config_longword
	.global _Fast_read_config_byte,_Fast_read_config_word,_Fast_read_config_longword,_Write_config_byte,_Write_config_word,_Write_config_longword
	.global _Hook_interrupt,_Unhook_interrupt,_Special_cycle,_Get_routing,_Set_interrupt
	.global _Get_resource,_Get_card_used,_Set_card_used,_Read_mem_byte,_Read_mem_word,_Read_mem_longword
	.global _Fast_read_mem_byte,_Fast_read_mem_word,_Fast_read_mem_longword,_Write_mem_byte,_Write_mem_word,_Write_mem_longword
	.global _Read_io_byte,_Read_io_word,_Read_io_longword,_Fast_read_io_byte,_Fast_read_io_word,_Fast_read_io_longword
	.global _Write_io_byte,_Write_io_word,_Write_io_longword,_Get_machine_id
	.global _Get_pagesize,_Virt_to_bus,_Bus_to_virt,_Virt_to_phys,_Phys_to_virt

	.data

__bzero:
_bzero:
	lea -32(SP),SP	
	movem.l D2-D6/A2-A4,(SP)
	move.l 4+32(SP),A4  // ptr
	moveq #0,D0         // fill
	move.l 8+32(SP),D5  // size
	bra.s _fill
	
_memset:

	lea -32(SP),SP	
	movem.l D2-D6/A2-A4,(SP)
	move.l 4+32(SP),A4  // ptr
	move.l 8+32(SP),D0  // fill
	move.l 12+32(SP),D5 // size
_fill:
	ble .ms1
	move.b D0,D1
	asl.l #8,D0
	move.b D1,D0
	move.w D0,D1
	swap D0
	move.w D1,D0
	move.l D0,D1
	move.l D0,D2
	move.l D0,D3
	move.l D0,A0
	move.l D0,A1
	move.l D0,A2
	move.l D0,A3
	move.l A4,D4
	bclr #0,D4
	beq.s .ms9
	move.b D0,(A4)+
	subq.l #1,D5
.ms9:
	move.l D5,D6
	move.l #256,D4
	bra.s .ms7
.ms8:
		movem.l D0-D3/A0-A3,(A4)
		movem.l D0-D3/A0-A3,32(A4)
		movem.l D0-D3/A0-A3,64(A4)
		movem.l D0-D3/A0-A3,96(A4)
		movem.l D0-D3/A0-A3,128(A4)
		movem.l D0-D3/A0-A3,160(A4)
		movem.l D0-D3/A0-A3,192(A4)
		movem.l D0-D3/A0-A3,224(A4)
		add.l D4,A4
.ms7:
	sub.l D4,D5
	bpl.s .ms8
	add.l D4,D5
	beq.s .ms1
	lsr.l #1,D5
	moveq #32,D4
	lsr.l #5,D5              // / 32
	bcs.s .ms4
	beq.s .ms6
	bra.s .ms5
.ms3:
		movem.l D0-D3/A0-A3,(A4)
		add.l D4,A4
.ms4:
		movem.l D0-D3/A0-A3,(A4)
		add.l D4,A4
.ms5:
	subq.l #1,D5
	bpl.s .ms3
.ms6:
	moveq #31,D0
	and.l D6,D0
	lea .ms2(PC),A0
	move.l D0,D2
	bclr #0,D2
	sub.l D2,A0
	jmp (A0)
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
	move.w D1,(A4)+
.ms2:
	bclr #0,D0
	beq.s .ms1
	move.b D1,(A4)+
.ms1:
	movem.l (SP),D2-D6/A2-A4
	lea 32(SP),SP
	rts
	
_memmove:
	lea -36(SP),SP	
	movem.l D2-D6/A2-A5,(SP)
	move.l 4+36(SP),A5       // d
	move.l 8+36(SP),A4       // s
	move.l 12+36(SP),D5      // size
	ble.s .mm1
	cmp.l A4,A5
	bls.s .cp0
	move.l A4,A0             // s
	add.l D5,A0              // + size
	cmp.l A0,A5
	bcc.s .cp0
	move.l A5,A1             // d, if inc copy overlap
	add.l D5,A1              // + size
.mm2:
		move.b -(A0),-(A1)
	subq.l #1,D5
	bgt.s .mm2
	bra.s .mm1
.mm3:
	cmp.l #16,D5
	bhi.s .cp0               // fast memcpy
.mm4:
		move.b (A4)+,(A5)+
	subq.l #1,D5
	bgt.s .mm4
.mm1:
	movem.l (SP),D2-D6/A2-A5
	lea 36(SP),SP
	rts

_memcpy:

	lea -36(SP),SP	
	movem.l D2-D6/A2-A5,(SP)
	move.l 4+36(SP),A5       // d
	move.l 8+36(SP),A4       // s
	move.l 12+36(SP),D5      // size
	ble .cp1
.cp0:
	move.l D5,D6
	move.l #256,D4
#if 0 // #ifndef COLDFIRE
	move.l A5,D0             // d
	move.l A4,D1             // s
	or.l D1,D0
	moveq #15,D1	
	and.l D1,D0
	bne .cp7                 // test d & s alignment on 16 bytes
	bra.s .cp11
.cp10:
		move16 (A4)+,(A5)+
		move16 (A4)+,(A5)+	
		move16 (A4)+,(A5)+
		move16 (A4)+,(A5)+
		move16 (A4)+,(A5)+
		move16 (A4)+,(A5)+	
		move16 (A4)+,(A5)+
		move16 (A4)+,(A5)+
		move16 (A4)+,(A5)+
		move16 (A4)+,(A5)+	
		move16 (A4)+,(A5)+
		move16 (A4)+,(A5)+
		move16 (A4)+,(A5)+
		move16 (A4)+,(A5)+	
		move16 (A4)+,(A5)+
		move16 (A4)+,(A5)+
.cp11:
	sub.l D4,D5
	bpl.s .cp10
	bra.s .cp9
#else /* COLDFIRE */
	bra.s .cp7
#endif /* COLDFIRE */
.cp8:
		movem.l (A4),D0-D3/A0-A3
		movem.l D0-D3/A0-A3,(A5)
		movem.l 32(A4),D0-D3/A0-A3
		movem.l D0-D3/A0-A3,32(A5)
		movem.l 64(A4),D0-D3/A0-A3
		movem.l D0-D3/A0-A3,64(A5)
		movem.l 96(A4),D0-D3/A0-A3
		movem.l D0-D3/A0-A3,96(A5)
		movem.l 128(A4),D0-D3/A0-A3
		movem.l D0-D3/A0-A3,128(A5)
		movem.l 160(A4),D0-D3/A0-A3
		movem.l D0-D3/A0-A3,160(A5)
		movem.l 192(A4),D0-D3/A0-A3
		movem.l D0-D3/A0-A3,192(A5)
		movem.l 224(A4),D0-D3/A0-A3
		movem.l D0-D3/A0-A3,224(A5)
		add.l D4,A4
		add.l D4,A5
.cp7:
	sub.l D4,D5
	bpl.s .cp8
.cp9:
	add.l D4,D5
	beq.s .cp1
	moveq #32,D4
	lsr.l #6,D5              // / 64
	bcs.s .cp4
	beq.s .cp6
	bra.s .cp5
.cp3:
		movem.l (A4),D0-D3/A0-A3
		movem.l D0-D3/A0-A3,(A5)
		add.l D4,A4
		add.l D4,A5
.cp4:
		movem.l (A4),D0-D3/A0-A3
		movem.l D0-D3/A0-A3,(A5)
		add.l D4,A4
		add.l D4,A5
.cp5:
	subq.l #1,D5
	bpl.s .cp3
.cp6:
	moveq #31,D0
	and.l D6,D0
	lea .cp2(PC),A0
	move.l D0,D2
	bclr #0,D2
	sub.l D2,A0
	jmp (A0)
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
	move.w (A4)+,(A5)+
.cp2:
	bclr #0,D0
	beq.s .cp1
	move.b (A4)+,(A5)+
.cp1:
	movem.l (SP),D2-D6/A2-A5
	lea 36(SP),SP
	rts

#ifndef COLDFIRE	
_cpush_dc:
	move.l 8(SP),D0          // size
	beq.s .csh1
	move.l 4(SP),A0          // base
	move.l A0,D1
	and.l #15,D1
	sne.b D1
	and.l #1,D1
	lsr.l #4,D0              // 16
	add.l D1,D0
	cmp.l #256,D0            // cache lines
	bcc.s .csh3              // flush all
	move.l A0,D1             // line alignment
	and.b #0xF0,D1
	move.l D1,A0 
	subq.l #1,D0
.csh2:                                // flush lines loop
		cpushl dc,(A0)
		lea 16(A0),A0
	dbf D0,.csh2
	rts
.csh3:
	cpusha dc                // flush all
.csh1:
	rts
#endif

_Funcs_copymem:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D2
	move.l D2,-(SP)
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_copymem(A2),A2 
	jsr (A2)
	lea 12(SP),SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts
	
_Funcs_next_line:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l 12(SP),D0
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_next_line(A2),A2
	jsr (A2)
	addq.l #4,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_skip_space:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l 12(SP),D0
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_skip_space(A2),A2
	jsr (A2)
	addq.l #4,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts
	
_Funcs_get_token:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D2
	move.l D2,-(SP)
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_get_token(A2),A2
	jsr (A2)
	lea 12(SP),SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts	

_Funcs_equal:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_equal(A2),A2
	jsr (A2)
	addq.l #8,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts	

_Funcs_length:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l 12(SP),D0
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_length(A2),A2
	jsr (A2)
	addq.l #4,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_copy:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_copy(A2),A2
	jsr (A2)
	addq.l #8,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_cat:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_cat(A2),A2
	jsr (A2)
	addq.l #8,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts
	
_Funcs_numeric:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l 12(SP),D0
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_numeric(A2),A2
	jsr (A2)
	addq.l #4,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts	

_Funcs_atol:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l 12(SP),D0
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_atol(A2),A2
	jsr (A2)
	addq.l #4,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_error:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_error(A2),A2
	jsr (A2)
	addq.l #8,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts
	
_Funcs_malloc:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_malloc(A2),A2
	jsr (A2)
	addq.l #8,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_free:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l 12(SP),D0
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_free(A2),A2
	jsr (A2)
	addq.l #4,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_puts:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l 12(SP),D0
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_puts(A2),A2
	jsr (A2)
	addq.l #4,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts
	
_Funcs_ltoa:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D2
	move.l D2,-(SP)
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_ltoa(A2),A2
	jsr (A2)
	lea 12(SP),SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts
	
_Funcs_get_cookie:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_get_cookie(A2),A2
	jsr (A2)
	addq.l #8,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts	

_Funcs_set_cookie:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_set_cookie(A2),A2
	jsr (A2)
	addq.l #8,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_fixup_font:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D2
	move.l D2,-(SP)
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_fixup_font(A2),A2
	jsr (A2)
	lea 12(SP),SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_unpack_font:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_unpack_font(A2),A2
	jsr (A2)
	addq.l #8,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_insert_font:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_insert_font(A2),A2
	jsr (A2)
	addq.l #8,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_get_size:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l 12(SP),D0
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_get_size(A2),A2
	jsr (A2)
	addq.l #4,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_allocate_block:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l 12(SP),D0
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_allocate_block(A2),A2
	jsr (A2)
	addq.l #4,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_free_block:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l 12(SP),D0
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_free_block(A2),A2
	jsr (A2)
	addq.l #4,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_cache_flush:
	move.l D2,-(SP)
	move.l A2,-(SP)
	move.l _access,A2
	move.l func_cache_flush(A2),A2
	jsr (A2)
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts
	
_Funcs_misc:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D2
	move.l D2,-(SP)
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_misc(A2),A2
	jsr (A2)
	lea 12(SP),SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

_Funcs_event:
	move.l D2,-(SP)
	move.l A2,-(SP)
	movem.l 12(SP),D0-D1
	move.l D1,-(SP)
	move.l D0,-(SP)
	move.l _access,A2
	move.l func_event(A2),A2
	jsr (A2)
	addq.l #8,SP
	move.l (SP)+,A2
	move.l (SP)+,D2
	rts

#ifdef COLDFIRE
_SMUL_DIV:
	move.l 4(SP),D0 // x
	muls 10(SP),D0  // y
	.chip 68060
	divs 14(SP),D0  // z
	.chip 5200
	rts
#endif

#define HALFPI 900 
#define PI    1800
#define TWOPI 3600

/* Sines of angles 1 - 90 degrees normalized between 0 and 32767. */

sin_tbl:	// 92 values
	dc.w     0,   572,  1144,  1716,  2286,  2856,  3425,  3993 
	dc.w  4560,  5126,  5690,  6252,  6813,  7371,  7927,  8481 
	dc.w  9032,  9580, 10126, 10668, 11207, 11743, 12275, 12803
	dc.w 13328, 13848, 14364, 14876, 15383, 15886, 16383, 16876
	dc.w 17364, 17846, 18323, 18794, 19260, 19720, 20173, 20621
	dc.w 21062, 21497, 21925, 22347, 22762, 23170, 23571, 23964
	dc.w 24351, 24730, 25101, 25465, 25821, 26169, 26509, 26841
	dc.w 27165, 27481, 27788, 28087, 28377, 28659, 28932, 29196
	dc.w 29451, 29697, 29934, 30162, 30381, 30591, 30791, 30982
	dc.w 31163, 31335, 31498, 31650, 31794, 31927, 32051, 32165
	dc.w 32269, 32364, 32448, 32523, 32587, 32642, 32687, 32722
	dc.w 32747, 32762, 32767, 32767 

/*
 * Returns integer sin between -32767 and 32767.
 * Uses integer lookup table sintable^[].
 * Expects angle in tenths of degree 0 - 3600.
 * Assumes positive angles only.
 */
_Isin:

	move.l 4(SP),D0
	and.l #0xffff,D0         // angle
	moveq #0,D1              // half
.ls1:
		cmp.l #PI,D0
		bcs.s .ls2
		bchg #0,D1  // half
		sub.l #PI,D0
	bra.s .ls1
.ls2:
	move.l D1,A1             // half
	cmp.l #HALFPI,D0
	bcs.s .ls3
	neg.l D0                 // angle
	add.l #PI,D0
.ls3:
#ifdef COLDFIRE
	.chip 68060
	divu #10,D0
	.chip 5200
#else
	divu #10,D0
#endif
	move.l D0,D1             // index
	swap D1                  // remainder
	move.w D0,A0
	add.l A0,A0
	add.l #sin_tbl,A0
	moveq #0,D0
	move.w (A0)+,D0          // tmpsin
	tst.w D1                 // remainder
	beq.s .ls4
	move.l D2,-(SP)
	moveq #0,D2
	move.w (A0),D2
	sub.l D0,D2              // [table] - tmpsin
	mulu D1,D2               // * remainder
#ifdef COLDFIRE
	mulu #6554,D2
	swap D2                  // / 10
#else
	divu #10,D2
#endif
	ext.l D2
	add.l D2,D0              // + tmpsin
	move.l (SP)+,D2
.ls4:
	move.l A1,D1
	beq.s .ls5
	neg.l D0
.ls5:
	move.l 8(SP),D1          // * rad
	muls D1,D0
	asr.l #8,D0              // / 32768
	asr.l #7,D0
	rts	

/*
 * Return integer cos between -32767 and 32767.
 */
_Icos:

	move.l 4(SP),D0
	move.l 8(SP),D1
	add.l #HALFPI,D0
	move.l D1,-(SP)
	move.l D0,-(SP)
	bsr _Isin
	addq.l #8,SP
	rts

_isqrt:

	move.l 4(SP),D0
	cmp.l #2,D0
	bge .is1
	rts
.is1:
	move.l D2,-(SP)
	move.l D0,D1
	moveq #2,D2
.is2:
		lsr.l #1,D1
		add.l D2,D2
	cmp.l D2,D1
	bhi.s .is2
	lsr.l #1,D2
	add.l D1,D2
	lsr.l #1,D2
.is3:
		move.l D2,D1
		move.l D0,D2
#ifdef COLDFIRE
		.chip 68060
		divu.l D1,D2
		.chip 5200
#else
		divu.l D1,D2
#endif
		add.l D1,D2
		lsr.l #1,D2
	cmp.l D2,D1
	bhi.s .is3
	move.l D1,D0
	move.l (SP)+,D2
	ext.l D0
	rts

__swap_short:
_swap_short:

	move.l 4(SP),D0
#ifdef COLDFIRE
	move.w D0,D1
	asl.l #8,D0
	lsr.l #8,D1
	and.l #0xff00,D0
	and.l #0x00ff,D1
	or.l D1,D0
#else
	ror.w #8,D0
#endif
	ext.l D0
	rts

__swap_long:
_swap_long:

	move.l 4(SP),D0
#ifdef COLDFIRE
	move.l D0,D1
	asl.l #8,D0
	lsr.l #8,D1
	and.l #0xff00ff00,D0
	and.l #0x00ff00ff,D1
	or.l D1,D0
	swap D0
#else
	ror.w #8,D0
	swap D0
	ror.w #8,D0
#endif
	rts

_Find_pci_device:

	move.l 4(SP),D0          // ID
	move.l 8(SP),D1          // index
	move.l _tab_funcs_pci,A1
	move.l (A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Find_pci_classcode:

	move.l 4(SP),D0          // class
	move.l 8(SP),D1          // index
	move.l _tab_funcs_pci,A1
	move.l 4(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Read_config_byte:

	movem.l 4(SP),D0-D1/A0   // handle, PCI register, pointer to space for read data
	move.l _tab_funcs_pci,A1
	move.l 8(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Read_config_word:

	movem.l 4(SP),D0-D1/A0   // handle, PCI register, pointer to space for read data
	move.l _tab_funcs_pci,A1
	move.l 12(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Read_config_longword:

	movem.l 4(SP),D0-D1/A0   // handle, PCI register, pointer to space for read data
	move.l _tab_funcs_pci,A1
	move.l 16(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Fast_read_config_byte:

	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // PCI register
	move.l _tab_funcs_pci,A1
	move.l 20(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Fast_read_config_word:

	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // PCI register
	move.l _tab_funcs_pci,A1
	move.l 24(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Fast_read_config_longword:

	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // PCI register
	move.l _tab_funcs_pci,A1
	move.l 28(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Write_config_byte:

	move.l D2,-(SP)
	movem.l 8(SP),D0-D2      // handle, PCI register, data to write
	move.l _tab_funcs_pci,A1
	move.l 32(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_Write_config_word:

	move.l D2,-(SP)
	movem.l 8(SP),D0-D2      // handle, PCI register, data to write
	move.l _tab_funcs_pci,A1
	move.l 36(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_Write_config_longword:

	move.l D2,-(SP)
	movem.l 8(SP),D0-D2      // handle, PCI register, data to write
	move.l _tab_funcs_pci,A1
	move.l 40(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_Hook_interrupt:
	
	movem.l 4(SP),D0/A0/A1   // handle, pointer to interrupt handler, parameter for interrupt handler
	move.l A2,-(SP)
	move.l _tab_funcs_pci,A2
	move.l 44(A2),A2
	move.l D2,-(SP)
	jsr (A2)
	move.l (SP)+,D2
	move.l (SP)+,A2
	rts

_Unhook_interrupt:
	
	move.l 4(SP),D0          // handle
	move.l _tab_funcs_pci,A1
	move.l 48(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Special_cycle:

	move.l 4(SP),D0          // bus number
	move.l 8(SP),D1          // special cycle data
	move.l _tab_funcs_pci,A1
	move.l 52(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Get_routing:
	
	move.l 4(SP),D0          // handle
	move.l _tab_funcs_pci,A1
	move.l 56(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Set_interrupt:
	
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // mode
	move.l _tab_funcs_pci,A1
	move.l 60(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Get_resource:

	move.l 4(SP),D0          // handle	
	move.l _tab_funcs_pci,A1
	move.l 64(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Get_card_used:

	move.l 4(SP),D0          // handle
	move.l 8(SP),A0          // address
	move.l _tab_funcs_pci,A1
	move.l 68(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Set_card_used:

	move.l 4(SP),D0          // handle
	move.l 8(SP),A0          // callback
	move.l _tab_funcs_pci,A1
	move.l 72(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts	
	
_Read_mem_byte:

	movem.l 4(SP),D0-D1/A0    // handle, address to access (in PCI memory address space), pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 76(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Read_mem_word:

	movem.l 4(SP),D0-D1/A0    // handle, address to access (in PCI memory address space), pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 80(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Read_mem_longword:

	movem.l 4(SP),D0-D1/A0    // handle, address to access (in PCI memory address space), pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 84(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Fast_read_mem_byte:

	move.l 8(SP),D1          // address to access (in PCI memory address space)
	move.l _tab_funcs_pci,A1
	move.l 88(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Fast_read_mem_word:

	move.l 8(SP),D1          // address to access (in PCI memory address space)
	move.l _tab_funcs_pci,A1
	move.l 92(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Fast_read_mem_longword:

	move.l 8(SP),D1          // address to access (in PCI memory address space)
	move.l _tab_funcs_pci,A1
	move.l 96(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Write_mem_byte:

	move.l D2,-(SP)
	movem.l 8(SP),D0-D2      // handle, address to access (in PCI memory address space), data to write
	move.l _tab_funcs_pci,A1
	move.l 100(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Write_mem_word:

	move.l D2,-(SP)
	movem.l 8(SP),D0-D2      // handle, address to access (in PCI memory address space), data to write
	move.l _tab_funcs_pci,A1
	move.l 104(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Write_mem_longword:

	move.l D2,-(SP)
	movem.l 8(SP),D0-D2      // handle, address to access (in PCI memory address space), data to write
	move.l _tab_funcs_pci,A1
	move.l 108(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Read_io_byte:

	movem.l 4(SP),D0-D1/A0   // handle, address to access (in PCI I/O address space), pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 112(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Read_io_word:

	movem.l 4(SP),D0-D1/A0   // handle, address to access (in PCI I/O address space), pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 116(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Read_io_longword:

	movem.l 4(SP),D0-D1/A0   // handle, address to access (in PCI I/O address space), pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 120(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Fast_read_io_byte:

	move.l 8(SP),D1          // address to access (in PCI I/O address space)
	move.l _tab_funcs_pci,A1
	move.l 124(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Fast_read_io_word:

	move.l 8(SP),D1          // address to access (in PCI I/O address space)
	move.l _tab_funcs_pci,A1
	move.l 128(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Fast_read_io_longword:

	move.l 8(SP),D1          // address to access (in PCI I/O address space)
	move.l _tab_funcs_pci,A1
	move.l 132(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Write_io_byte:
	
	move.l D2,-(SP)
	movem.l 8(SP),D0-D2      // handle, address to access (in PCI I/O address space), data to write
	move.l _tab_funcs_pci,A1
	move.l 136(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_Write_io_word:

	move.l D2,-(SP)
	movem.l 8(SP),D0-D2      // handle, address to access (in PCI I/O address space), data to write
	move.l _tab_funcs_pci,A1
	move.l 140(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_Write_io_longword:

	move.l D2,-(SP)
	movem.l 8(SP),D0-D2      // handle, address to access (in PCI I/O address space), data to write
	move.l _tab_funcs_pci,A1
	move.l 144(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts
	
_Get_machine_id:

	move.l _tab_funcs_pci,A1
	move.l 148(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Get_pagesize:

	move.l _tab_funcs_pci,A1
	move.l 152(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Virt_to_bus:
	
	movem.l 4(SP),D0-D1/A0   // handle, address in virtual CPU space, ptr
	move.l _tab_funcs_pci,A1
	move.l 156(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Bus_to_virt:
	
	movem.l 4(SP),D0-D1/A0   // handle, PCI bus address, ptr
	move.l _tab_funcs_pci,A1
	move.l 160(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Virt_to_phys:

	move.l 4(SP),D0          // address in virtual CPU space  
	move.l 8(SP),A0          // ptr
	move.l _tab_funcs_pci,A1
	move.l 164(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_Phys_to_virt:

	move.l 4(SP),D0          // physical CPU address 
	move.l 8(SP),A0          // ptr
	move.l _tab_funcs_pci,A1
	move.l 168(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
	
	.lcomm save_d0,4
	.lcomm _tab_funcs_pci,4

