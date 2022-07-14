/* pci_xbios.S - PCI bios calls from _PCI cookie
 *
 * Reworked for USB TOS drivers by David Galvez 2019
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

	.global _tab_funcs_pci,_x_Find_pci_device,_x_Find_pci_classcode,_x_Read_config_byte,_x_Read_config_word,_x_Read_config_longword
	.global _x_Fast_read_config_byte,_x_Fast_read_config_word,_x_Fast_read_config_longword,_x_Write_config_byte,_x_Write_config_word,_x_Write_config_longword
	.global _x_Hook_interrupt,_x_Unhook_interrupt,_x_Special_cycle,_x_Get_routing,_x_Set_interrupt
	.global _x_Get_resource,_x_Get_card_used,_x_Set_card_used,_x_Read_mem_byte,_x_Read_mem_word,_x_Read_mem_longword
	.global _x_Fast_read_mem_byte,_x_Fast_read_mem_word,_x_Fast_read_mem_longword,_x_Write_mem_byte,_x_Write_mem_word,_x_Write_mem_longword
	.global _x_Read_io_byte,_x_Read_io_word,_x_Read_io_longword,_x_Fast_read_io_byte,_x_Fast_read_io_word,_x_Fast_read_io_longword
	.global _x_Write_io_byte,_x_Write_io_word,_x_Write_io_longword,_x_Get_machine_id
	.global _x_Get_pagesize,_x_Virt_to_bus,_x_Bus_to_virt,_x_Virt_to_phys,_x_Phys_to_virt

_x_Find_pci_device:
	move.l 4(SP),D0          // ID
	move.w 8(SP),D1          // index
	move.l _tab_funcs_pci,A1
	move.l (A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Find_pci_classcode:
	move.l 4(SP),D0          // class
	move.w 8(SP),D1          // index
	move.l _tab_funcs_pci,A1
	move.l 4(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Read_config_byte:
	move.l 4(SP),D0          // handle
	move.w 8(SP),D1          // PCI register
	move.l 10(SP),A0         // pointer to space for read data
	move.l _tab_funcs_pci,A1
	move.l 8(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Read_config_word:
	move.l 4(SP),D0          // handle
	move.w 8(SP),D1          // PCI register
	move.l 10(SP),A0         // pointer to space for read data
	move.l _tab_funcs_pci,A1
	move.l 12(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Read_config_longword:
	move.l 4(SP),D0          // handle
	move.w 8(SP),D1          // PCI register
	move.l 10(SP),A0         // pointer to space for read data
	move.l _tab_funcs_pci,A1
	move.l 16(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Fast_read_config_byte:
	move.l 4(SP),D0          // handle
	move.w 8(SP),D1          // PCI register
	move.l _tab_funcs_pci,A1
	move.l 20(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Fast_read_config_word:
	move.l 4(SP),D0          // handle
	move.w 8(SP),D1          // PCI register
	move.l _tab_funcs_pci,A1
	move.l 24(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Fast_read_config_longword:
	move.l 4(SP),D0          // handle
	move.w 8(SP),D1          // PCI register
	move.l _tab_funcs_pci,A1
	move.l 28(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Write_config_byte:
	move.l D2,-(SP)
	move.l 8(SP),D0          // handle
	move.w 12(SP),D1         // PCI register
	move.w 14(SP),D2         // data to write
	move.l _tab_funcs_pci,A1
	move.l 32(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Write_config_word:
	move.l D2,-(SP)
	move.l 8(SP),D0          // handle
	move.w 12(SP),D1         // PCI register
	move.w 14(SP),D2         // data to write
	move.l _tab_funcs_pci,A1
	move.l 36(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Write_config_longword:
	move.l D2,-(SP)
	move.l 8(SP),D0          // handle
	move.w 12(SP),D1         // PCI register
	move.l 14(SP),D2         // data to write
	move.l _tab_funcs_pci,A1
	move.l 40(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Hook_interrupt:
	move.l 4(SP),D0          // handle
	move.l 8(SP),A0          // pointer to interrupt handler
	move.l 12(SP),A1         // parameter for interrupt handler
	move.l A2,-(SP)
	move.l _tab_funcs_pci,A2
	move.l 44(A2),A2
	move.l D2,-(SP)
	jsr (A2)
	move.l (SP)+,D2
	move.l (SP)+,A2
	rts

_x_Unhook_interrupt:
	move.l 4(SP),D0          // handle
	move.l _tab_funcs_pci,A1
	move.l 48(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Special_cycle:
	move.w 2(SP),D0          // bus number
	move.l 6(SP),D1          // special cycle data
	move.l _tab_funcs_pci,A1
	move.l 52(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Get_routing:
	move.l 4(SP),D0          // handle
	move.l _tab_funcs_pci,A1
	move.l 56(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Set_interrupt:
	move.l 4(SP),D0          // handle
	move.l _tab_funcs_pci,A1
	move.l 60(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Get_resource:
	move.l 4(SP),D0          // handle
	move.l _tab_funcs_pci,A1
	move.l 64(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Get_card_used:
	move.l 4(SP),D0          // handle
	move.l 8(SP),A0          // address
	move.l _tab_funcs_pci,A1
	move.l 68(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Set_card_used:
	move.l 4(SP),D0          // handle
	move.l 8(SP),A0          // callback
	move.l _tab_funcs_pci,A1
	move.l 72(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Read_mem_byte:
	movem.l 4(SP),D0-D1/A0    // handle, address to access (in PCI memory address space), pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 76(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Read_mem_word:
	movem.l 4(SP),D0-D1/A0    // handle, address to access (in PCI memory address space), pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 80(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Read_mem_longword:
	movem.l 4(SP),D0-D1/A0    // handle, address to access (in PCI memory address space), pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 84(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Fast_read_mem_byte:
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // address to access (in PCI memory address space)
	move.l _tab_funcs_pci,A1
	move.l 88(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Fast_read_mem_word:
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // address to access (in PCI memory address space)
	move.l _tab_funcs_pci,A1
	move.l 92(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Fast_read_mem_longword:
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // address to access (in PCI memory address space)
	move.l _tab_funcs_pci,A1
	move.l 96(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Write_mem_byte:
	move.l D2,-(SP)
	move.l 8(SP),D0          // handle
	move.l 12(SP),D1         // address to access (in PCI memory address space)
	move.w 16(SP),D2         // data to write
	move.l _tab_funcs_pci,A1
	move.l 100(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Write_mem_word:
	move.l D2,-(SP)
	move.l 8(SP),D0          // handle
	move.l 12(SP),D1         // address to access (in PCI memory address space)
	move.w 16(SP),D2         // data to write
	move.l _tab_funcs_pci,A1
	move.l 104(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Write_mem_longword:
	move.l D2,-(SP)
	move.l 8(SP),D0          // handle
	move.l 12(SP),D1         // address to access (in PCI memory address space)
	move.l 16(SP),D2         // data to write
	move.l _tab_funcs_pci,A1
	move.l 108(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Read_io_byte:
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // address to access (in PCI I/O address space)
	move.l 12(SP),A0         // pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 112(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Read_io_word:
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // address to access (in PCI I/O address space)
	move.l 12(SP),A0         // pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 116(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Read_io_longword:
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // address to access (in PCI I/O address space)
	move.l 12(SP),A0         // pointer to data in memory
	move.l _tab_funcs_pci,A1
	move.l 120(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Fast_read_io_byte:
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // address to access (in PCI I/O address space)
	move.l _tab_funcs_pci,A1
	move.l 124(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Fast_read_io_word:
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // address to access (in PCI I/O address space)
	move.l _tab_funcs_pci,A1
	move.l 128(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Fast_read_io_longword:
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // address to access (in PCI I/O address space)
	move.l _tab_funcs_pci,A1
	move.l 132(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Write_io_byte:
	move.l D2,-(SP)
	move.l 8(SP),D0          // handle
	move.l 12(SP),D1         // address to access (in PCI I/O address space)
	move.w 16(SP),D2         // data to write
	move.l _tab_funcs_pci,A1
	move.l 136(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Write_io_word:
	move.l D2,-(SP)
	move.l 8(SP),D0          // handle
	move.l 12(SP),D1         // address to access (in PCI I/O address space)
	move.w 16(SP),D2         // data to write
	move.l _tab_funcs_pci,A1
	move.l 140(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Write_io_longword:
	move.l D2,-(SP)
	move.l 8(SP),D0          // handle
	move.l 12(SP),D1         // address to access (in PCI I/O address space)
	move.l 16(SP),D2         // data to write
	move.l _tab_funcs_pci,A1
	move.l 144(A1),A1
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Get_machine_id:
	move.l _tab_funcs_pci,A1
	move.l 148(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Get_pagesize:
	move.l _tab_funcs_pci,A1
	move.l 152(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Virt_to_bus:
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // address in virtual CPU space
	move.l 12(SP),A0         // ptr
	move.l _tab_funcs_pci,A1
	move.l 156(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Bus_to_virt:
	move.l 4(SP),D0          // handle
	move.l 8(SP),D1          // PCI bus address
	move.l 12(SP),A0         // ptr
	move.l _tab_funcs_pci,A1
	move.l 160(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Virt_to_phys:
	move.l 4(SP),D0          // address in virtual CPU space
	move.l 8(SP),A0          // ptr
	move.l _tab_funcs_pci,A1
	move.l 164(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts

_x_Phys_to_virt:
	move.l 4(SP),D0          // physical CPU address
	move.l 8(SP),A0          // ptr
	move.l _tab_funcs_pci,A1
	move.l 168(A1),A1
	move.l D2,-(SP)
	jsr (A1)
	move.l (SP)+,D2
	rts
