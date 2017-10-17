/* TOS 4.04 Xbios for the Coldfire boards
*  Didier Mequignon 2011, e-mail: aniplay@wanadoo.fr
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

#ifndef	_RAM_CF68KLIB_H
#define	_RAM_CF68KLIB_H

#define OFFSET_INT_CF68KLIB   64

#define CF68KLIB              0x00E90000

#ifdef MCF5445X
#define RAM_BASE_CF68KLIB     0x4FE00000 /* last MB of 256MB - 1MB */
#else
#ifdef MCF547X
#define RAM_BASE_CF68KLIB     0x1FE00000 /* last MB of 512MB -1MB */
#else /* MCF548X */
#define RAM_BASE_CF68KLIB     0x03E00000 /* last MB of 64MB - 1MB */
#endif /* MCF547X */
#endif /* MCF5445X */
#define ZONE_CF68KLIB         0x00010000
#define coldfire_vector_base  RAM_BASE_CF68KLIB // 1024 bytes (256 vectors) - 1M alignment
#define library_data_ptr      RAM_BASE_CF68KLIB+0x400 // 4 bytes
#define library_data_temp     RAM_BASE_CF68KLIB+0x404 // 4 bytes
#define save_pc               RAM_BASE_CF68KLIB+0x408 // 4 bytes (debug)
#define save_sr               RAM_BASE_CF68KLIB+0x40C // 4 bytes (debug)
#define psc_uimr              RAM_BASE_CF68KLIB+0x40E // 2 bytes
#define pseudo_nvram_data     RAM_BASE_CF68KLIB+0x410 // 48 bytes
#define lock_cacr             RAM_BASE_CF68KLIB+0x440 // 1 byte
#define serial_mouse          RAM_BASE_CF68KLIB+0x441 // 1 byte
#define type_serial_mouse     RAM_BASE_CF68KLIB+0x442 // 2 bytes
#define id_serial_mouse       RAM_BASE_CF68KLIB+0x444 // 2 bytes
#define count_serial_mouse    RAM_BASE_CF68KLIB+0x446 // 2 bytes
#define data_serial_mouse     RAM_BASE_CF68KLIB+0x448 // 4 bytes
#define old_gemdos            RAM_BASE_CF68KLIB+0x44C // 4 bytes
#define old_hdv_bpb_hd        RAM_BASE_CF68KLIB+0x450 // 4 bytes
#define old_hdv_rw_hd         RAM_BASE_CF68KLIB+0x454 // 4 bytes
#define old_hdv_mediach_hd    RAM_BASE_CF68KLIB+0x458 // 4 bytes
#define old_cacr              RAM_BASE_CF68KLIB+0x45C // 4 bytes
#define counter_1ms           RAM_BASE_CF68KLIB+0x460 // 4 bytes
#define fire_engine_hw_rev    RAM_BASE_CF68KLIB+0x464 // 1 byte, for IDE test
#define psg_save_port_a       RAM_BASE_CF68KLIB+0x465 // 1 byte
#define stop_mfp_ikbd         RAM_BASE_CF68KLIB+0x466 // 1 byte
#define boot_tos              RAM_BASE_CF68KLIB+0x467 // 1 byte
// #define save_ide_registers    RAM_BASE_CF68KLIB+0x464 // 8 bytes
#define old_access_error      RAM_BASE_CF68KLIB+0x46C // 4 bytes
#define save_registers        RAM_BASE_CF68KLIB+0x470 // 60 bytes
#define save_sp               RAM_BASE_CF68KLIB+0x4AC // 4 bytes
#define save_coldfire_vector  RAM_BASE_CF68KLIB+0x4B0 // 4 bytes
#define handler_fault         RAM_BASE_CF68KLIB+0x4B4 // 4 bytes
#define address_fault         RAM_BASE_CF68KLIB+0x4B8 // 4 bytes
#define save_pc_cf68klib      RAM_BASE_CF68KLIB+0x4C0 // 4 bytes
#define debug_cf68klib        RAM_BASE_CF68KLIB+0x4C4 // 1 bytes
#define debug_cf68klib_count  RAM_BASE_CF68KLIB+0x4C5 // 1 bytes
#define save_format           RAM_BASE_CF68KLIB+0x4C6 // 2 bytes
#define v_breakpoint_install  RAM_BASE_CF68KLIB+0x4C8 // 4 bytes
#define v_breakpoint_deinstall RAM_BASE_CF68KLIB+0x4CC // 4 bytes
#define v_breakpoint_add      RAM_BASE_CF68KLIB+0x4D0 // 4 bytes
#define v_breakpoint_remove   RAM_BASE_CF68KLIB+0x4D4 // 4 bytes
#define cpu_step_over         RAM_BASE_CF68KLIB+0x4D8 // 4 bytes
#define cpu_trace_count       RAM_BASE_CF68KLIB+0x4DC // 4 bytes
#define cpu_trace_thru        RAM_BASE_CF68KLIB+0x4E0 // 4 bytes
#define user_triggered        RAM_BASE_CF68KLIB+0x4E4 // 4 bytes
#define v_suspend_task        RAM_BASE_CF68KLIB+0x4E8 // 4 bytes
#define debug_trap            RAM_BASE_CF68KLIB+0x4EC // 1 bytes
#define debug_trap_count      RAM_BASE_CF68KLIB+0x4ED // 1 bytes
#define trap_breakpoint       RAM_BASE_CF68KLIB+0x4EE // 1 bytes
#define debug_int7            RAM_BASE_CF68KLIB+0x4EF // 1 bytes
#define save_mmuar            RAM_BASE_CF68KLIB+0x4F0 // 4 bytes
#define save_regs             RAM_BASE_CF68KLIB+0x4F4 // 158 bytes
#define mac_address           RAM_BASE_CF68KLIB+0x594 // 4 bytes
#define ip_address            RAM_BASE_CF68KLIB+0x598 // 4 bytes
#define server_ip_address     RAM_BASE_CF68KLIB+0x59C // 4 bytes
#define fpu_area              RAM_BASE_CF68KLIB+0x5A0 // 16 bytes

#define access_fault_stack    RAM_BASE_CF68KLIB+0x800
#define ustack_aes            RAM_BASE_CF68KLIB+0xC00 // top
#define library_data_area     RAM_BASE_CF68KLIB+0xC00 // 1024 bytes

#define current_tcb           RAM_BASE_CF68KLIB+0x1000 // 4 bytes (FreeRTOS, defined also inside dirvers_cf.lk !)
#define tid_tos               RAM_BASE_CF68KLIB+0x1004 // 4 bytes (FreeRTOS, defined also inside drivers_cf.lk !)

#endif
