/* TOS 4.04 header for for the CT60/CF boards drivers
*  Didier Mequignon 2006-2010, e-mail: aniplay@wanadoo.fr
*
*  This library is free software; you can redistribute it and/or
*  modify it under the terms of the GNU Lesser General Public
*  License as published by the Free Software Foundation; either
*  version 2.1 of the License, or (at your option) any later version.
*
*  This library is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*  Lesser General Public License for more details.
*
*  You should have received a copy of the GNU Lesser General Public
*  License along with this library; if not, write to the Free Software
*  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include "config.h"
#include "version.h"

	.global	Start,_init_devices,_init_with_sdram,_init_before_autofolder
	.global	_clear_screen,_move_screen,_print_screen
	.global	_dbug,_event_aes,_disassemble_pc
	.global	_init_rtos,_set_video
	.global	_VERSION,_DATE

	.text

	.long	0x5F504349              // _PCI - ID
Start:
	jmp	_init_devices           //  4 - 0
	jmp	_init_with_sdram        // 10 - 1
	jmp	_init_before_autofolder // 16 - 2
	jmp	_clear_screen           // 22 - 3
	jmp	_move_screen            // 28 - 4
	jmp          _print_screen           // 34 - 5
	jmp	_dbug                   // 40 - 6
	jmp	_event_aes              // 46 - 7
	jmp	_disassemble_pc         // 52 - 8
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
	jmp	_init_rtos              // 58 - 9
#else
	rts
	nop
	nop
#endif
	jmp	_set_video              // 64 - 10
	rts	                        // 70 - 11
	nop
	nop
	rts	                        // 76 - 12
	nop
	nop
	rts	                        // 82 - 13
	nop
	nop
	rts	                        // 88 - 14
	nop
	nop
	rts	                        // 94 - 15
	nop
	nop
		                        // 100
_VERSION:
	.short	VERSION                 // 2 bytes
_DATE:
	.short	DATE                    // 10 bytes
