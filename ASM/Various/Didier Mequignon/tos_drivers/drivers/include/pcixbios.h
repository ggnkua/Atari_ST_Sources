/* TOS 4.04 Xbios PCI for the CT60 board
*  Didier Mequignon 2005, e-mail: aniplay@wanadoo.fr
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

#ifndef	_CT60_XBIOS_PCI_H
#define	_CT60_XBIOS_PCI_H

#define PCIIDR                0x00   /* PCI Configuration ID Register       */
#define PCICSR                0x04   /* PCI Command/Status Register         */
#define PCICR                 0x04   /* PCI Command Register                */
#define PCISR                 0x06   /* PCI Status Register                 */
#define PCIREV                0x08   /* PCI Revision ID Register            */
#define PCICCR                0x09   /* PCI Class Code Register             */
#define PCICLSR               0x0C   /* PCI Cache Line Size Register        */
#define PCILTR                0x0D   /* PCI Latency Timer Register          */
#define PCIHTR                0x0E   /* PCI Header Type Register            */
#define PCIBISTR              0x0F   /* PCI Build-In Self Test Register     */
#define PCIBAR0               0x10   /* PCI Base Address Register for Memory
                                        Accesses to Local, Runtime, and DMA */
#define PCIBAR1               0x14   /* PCI Base Address Register for I/O
                                        Accesses to Local, Runtime, and DMA */
#define PCIBAR2               0x18   /* PCI Base Address Register for Memory
                                        Accesses to Local Address Space 0   */
#define PCIBAR3               0x1C   /* PCI Base Address Register for Memory
                                        Accesses to Local Address Space 1   */ 
#define PCIBAR4               0x20   /* PCI Base Address Register, reserved */
#define PCIBAR5               0x24   /* PCI Base Address Register, reserved */
#define PCICIS                0x28   /* PCI Cardbus CIS Pointer, not support*/
#define PCISVID               0x2C   /* PCI Subsystem Vendor ID             */
#define PCISID                0x2E   /* PCI Subsystem ID                    */
#define PCIERBAR              0x30   /* PCI Expansion ROM Base Register     */
#define CAP_PTR               0x34   /* New Capability Pointer              */
#define PCIILR                0x3C   /* PCI Interrupt Line Register         */
#define PCIIPR                0x3D   /* PCI Interrupt Pin Register          */
#define PCIMGR                0x3E   /* PCI Min_Gnt Register                */
#define PCIMLR                0x3F   /* PCI Max_Lat Register                */
#define PMCAPID               0x40   /* Power Management Capability ID      */
#define PMNEXT                0x41   /* Power Management Next Capability
                                        Pointer                             */
#define PMC                   0x42   /* Power Management Capabilities       */
#define PMCSR                 0x44   /* Power Management Control/Status     */
#define PMCSR_BSE             0x46   /* PMCSR Bridge Support Extensions     */
#define PMDATA                0x47   /* Power Management Data               */
#define HS_CNTL               0x48   /* Hot Swap Control                    */
#define HS_NEXT               0x49   /* Hot Swap Next Capability Pointer    */
#define HS_CSR                0x4A   /* Hot Swap Control/Status             */
#define PVPDCNTL              0x4C   /* PCI Vital Product Data Control      */
#define PVPD_NEXT             0x4D   /* PCI Vital Product Data Next
                                        Capability Pointer                  */
#define PVPDAD                0x4E   /* PCI Vital Product Data Address      */
#define PVPDATA               0x50   /* PCI VPD Data                        */

typedef struct
{
  unsigned long *subcookie;
  unsigned long version;
  long routine[45];
} PCI_COOKIE;

typedef struct                       /* structure of resource descriptor    */
{
	unsigned short next;               /* length of the following structure   */
	unsigned short flags;              /* type of resource and misc. flags    */
	unsigned long start;               /* start-address of resource           */
	unsigned long length;              /* length of resource                  */
	unsigned long offset;              /* offset PCI to phys. CPU Address     */
	unsigned long dmaoffset;           /* offset for DMA-transfers            */
} PCI_RSC_DESC;

typedef struct                       /* structure of address conversion     */
{
	unsigned long adr;                 /* calculated address (CPU<->PCI)      */
	unsigned long len;                 /* length of memory range              */
} PCI_CONV_ADR;

/******************************************************************************/
/*                          PCI-BIOS Error Codes                              */
/******************************************************************************/
#define PCI_SUCCESSFUL            0  /* everything's fine         */
#define PCI_FUNC_NOT_SUPPORTED   -2  /* function not supported    */
#define PCI_BAD_VENDOR_ID        -3  /* wrong Vendor ID           */
#define PCI_DEVICE_NOT_FOUND     -4  /* PCI-Device not found      */
#define PCI_BAD_REGISTER_NUMBER  -5  /* wrong register number     */
#define PCI_SET_FAILED           -6  /* reserved for later use    */
#define PCI_BUFFER_TOO_SMALL     -7  /* reserved for later use    */
#define PCI_GENERAL_ERROR        -8  /* general BIOS error code   */
#define PCI_BAD_HANDLE           -9  /* wrong/unknown PCI-handle  */

/******************************************************************************/
/*                      Flags used in Resource-Descriptor                     */
/******************************************************************************/
#define FLG_IO        0x4000         /* Ressource in IO range               */
#define FLG_ROM       0x2000         /* Expansion ROM */
#define FLG_LAST      0x8000         /* last ressource                      */
#define FLG_8BIT      0x0100         /* 8 bit accesses allowed              */
#define FLG_16BIT     0x0200         /* 16 bit accesses allowed             */
#define FLG_32BIT     0x0400         /* 32 bit accesses allowed             */
#define FLG_ENDMASK   0x000F         /* mask for byte ordering              */

/******************************************************************************/
/*                 Values used in FLG_ENDMASK for Byte Ordering               */
/******************************************************************************/
#define ORD_MOTOROLA       0         /* Motorola (big endian)               */
#define ORD_INTEL_AS       1         /* Intel (little endian), addr.swapped */
#define ORD_INTEL_LS       2         /* Intel (little endian), lane swapped */
#define ORD_UNKNOWN       15         /* unknown (BIOS-calls allowed only)   */

/******************************************************************************/
/*                   Status Info used in Device-Descriptor                    */
/******************************************************************************/
#define DEVICE_FREE        0         /* Device is not used                  */
#define DEVICE_USED        1         /* Device is used by another driver    */
#define DEVICE_CALLBACK    2         /* used, but driver can be cancelled   */
#define DEVICE_AVAILABLE   3         /* used, not available                 */
#define NO_DEVICE         -1         /* no device detected                  */

/******************************************************************************/
/*                            Callback-Routine                                */
/******************************************************************************/
 #define GET_DRIVER_ID      0        /* CB-Routine 0: Get Driver ID         */
 #define REMOVE_DRIVER      1        /* CB-Routine 1: Remove Driver         */

/******************************************************************************/
/*                              Functions                                     */
/******************************************************************************/
#ifndef OSBIND_CLOBBER_LIST
#define OSBIND_CLOBBER_LIST "d0", "d1", "d2", "a0", "a1", "a2", "memory"
#endif

#ifndef trap_14_wlw
#define trap_14_wlw(n, a, b)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	long  _a = (long) (a);	\
	short _b = (short) (b);	\
	\
	__asm__ volatile (	\
		"movw	%3,sp@-\n\t"	\
		"movl	%2,sp@-\n\t"	\
		"movw	%1,sp@-\n\t"	\
		"trap	#14\n\t"	\
		"lea	sp@(8),sp"	\
		: "=r"(retvalue)	\
		: "g"(n), "r"(_a), "r"(_b)	\
		: OSBIND_CLOBBER_LIST	\
	);	\
	retvalue;	\
})
#endif
#ifndef trap_14_wll
#define trap_14_wll(n, a, b)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	long _a = (long) (a);	\
	long _b = (long) (b);	\
	\
	__asm__ volatile (	\
		"movl	%3,sp@-\n\t"	\
		"movl	%2,sp@-\n\t"	\
		"movw	%1,sp@-\n\t"	\
		"trap	#14\n\t"	\
		"lea	sp@(10),sp"	\
		: "=r"(retvalue)	\
		: "g"(n), "r"(_a), "r"(_b)	\
		: OSBIND_CLOBBER_LIST	\
	);	\
	retvalue;	\
})
#endif
#ifndef trap_14_wlww
#define trap_14_wlww(n, a, b, c)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	long  _a = (long) (a);	\
	short _b = (short) (b);	\
	short  _c = (short) (c);	\
	\
	__asm__ volatile (	\
		"movl	%4,sp@-\n\t"	\
		"movw	%3,sp@-\n\t"	\
		"movw	%2,sp@-\n\t"	\
		"movw	%1,sp@-\n\t"	\
		"trap	#14\n\t"	\
		"lea	sp@(10),sp"	\
		: "=r"(retvalue)	\
		: "g"(n), "r"(_a), "r"(_b), "r"(_c)	\
		: OSBIND_CLOBBER_LIST	\
	);	\
	retvalue;	\
})
#endif
#ifndef trap_14_wlwl
#define trap_14_wlwl(n, a, b, c)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	long  _a = (long) (a);	\
	short _b = (short) (b);	\
	long  _c = (long) (c);	\
	\
	__asm__ volatile (	\
		"movl	%4,sp@-\n\t"	\
		"movw	%3,sp@-\n\t"	\
		"movl	%2,sp@-\n\t"	\
		"movw	%1,sp@-\n\t"	\
		"trap	#14\n\t"	\
		"lea	sp@(12),sp"	\
		: "=r"(retvalue)	\
		: "g"(n), "r"(_a), "r"(_b), "r"(_c)	\
		: OSBIND_CLOBBER_LIST	\
	);	\
	retvalue;	\
})
#endif
#ifndef trap_14_wlll
#define trap_14_wlll(n, a, b, c)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	long  _a = (long) (a);	\
	long  _b = (long) (b);	\
	long  _c = (long) (c);	\
	\
	__asm__ volatile (	\
		"movl	%4,sp@-\n\t"	\
		"movl	%3,sp@-\n\t"	\
		"movl	%2,sp@-\n\t"	\
		"movw	%1,sp@-\n\t"	\
		"trap	#14\n\t"	\
		"lea	sp@(14),sp"	\
		: "=r"(retvalue)	\
		: "g"(n), "r"(_a), "r"(_b), "r"(_c)	\
		: OSBIND_CLOBBER_LIST	\
	);	\
	retvalue;	\
})
#endif

#define find_pci_device(id,index) (long)trap_14_wlw((short)(300),(unsigned long)(id),(unsigned short)(index))
#define find_pci_classcode(classcode,index) (long)trap_14_wlw((short)(301),(unsigned long)(classcode),(unsigned short)(index))
#define read_config_byte(handle,reg,address) (long)trap_14_wlwl((short)(302),(long)(handle),(unsigned short)(reg),(unsigned char *)(address))
#define read_config_word(handle,reg,address) (long)trap_14_wlwl((short)(303),(long)(handle),(unsigned short)(reg),(unsigned short *)(address))
#define read_config_longword(handle,reg,address) (long)trap_14_wlwl((short)(304),(long)(handle),(unsigned short)(reg),(unsigned long *)(address))
#define fast_read_config_byte(handle,reg) (unsigned char)trap_14_wlw((short)(305),(long)(handle),(unsigned short)(reg))
#define fast_read_config_word(handle,reg) (unsigned short)trap_14_wlw((short)(306),(long)(handle),(unsigned short)(reg))
#define fast_read_config_longword(handle,reg) (unsigned long)trap_14_wlw((short)(307),(long)(handle),(unsigned short)(reg))
#define write_config_byte(handle,reg,data) (long)trap_14_wlww((short)(308),(long)(handle),(unsigned short)(reg),(unsigned short)(data))
#define write_config_word(handle,reg,data) (long)trap_14_wlww((short)(309),(long)(handle),(unsigned short)(reg),(unsigned short)(data))
#define write_config_longword(handle,reg,data) (long)trap_14_wlwl((short)(310),(long)(handle),(unsigned short)(reg),(unsigned long)(data))
#define hook_interrupt(handle,routine,parameter) (long)trap_14_wlll((short)(311),(long)(handle),(unsigned long *)(routine),(unsigned long *)(parameter))
#define unhook_interrupt(handle) (long)trap_14_wl((short)(312),(long)(handle))
#define special_cycle(bus_number,special_cycle) (long)trap_14_wwl((short)(313),(unsigned short)(bus_number),(unsigned long)(special_cycle))
#define get_routing(handle) (long)trap_14_wl((short)(314),(long)(handle))
#define set_interrupt(handle,mode) (long)trap_14_wlw((short)(315),(long)(handle),(short)(mode))
#define get_resource(handle) (long)trap_14_wl((short)(316),(long)(handle))
#define get_card_used(handle,callback) (long)trap_14_wll((short)(317),(long)(handle),(long *)(address))
#define set_card_used(handle,callback) (long)trap_14_wll((short)(318),(long)(handle),(long *)(callback))
#define read_mem_byte(handle,offset,address) (long)trap_14_wlll((short)(319),(long)(handle),(unsigned long)(offset),(unsigned char *)(address))
#define read_mem_word(handle,offset,address) (long)trap_14_wlll((short)(320),(unsigned long)(offset),(unsigned short *)(address))
#define read_mem_longword(handle,offset,address) (long)trap_14_wlll((short)(321),(unsigned long)(offset),(unsigned long *)(address))
#define fast_read_mem_byte(handle,offset) (unsigned char)trap_14_wll((short)(322),(long)(handle),(unsigned long)(offset))
#define fast_read_mem_word(handle,offset) (unsigned short)trap_14_wll((short)(323),(long)(handle),(unsigned long)(offset))
#define fast_read_mem_longword(handle,offset) (unsigned long)trap_14_wll((short)(324),(long)(handle),(unsigned long)(offset))
#define write_mem_byte(handle,offset,data) (long)trap_14_wllw((short)(325),(long)(handle),(unsigned long)(offset),(unsigned short)(data))
#define write_mem_word(handle,offset,data) (long)trap_14_wllw((short)(326),(long)(handle),(unsigned long)(offset),(unsigned short)(data))
#define write_mem_longword(handle,offset,data) (long)trap_14_wlll((short)(327),(long)(handle),(unsigned long)(offset),(unsigned long)(data))
#define read_io_byte(handle,offset,address) (long)trap_14_wlll((short)(328),(long)(handle),(unsigned long)(offset),(unsigned char *)(address))
#define read_io_word(handle,offset,address) (long)trap_14_wlll((short)(329),(long)(handle),(unsigned long)(offset),(unsigned short *)(address))
#define read_io_longword(handle,offset,address) (long)trap_14_wlll((short)(330),(long)(handle),(unsigned long)(offset),(unsigned long *)(address))
#define fast_read_io_byte(handle,offset) (unsigned char)trap_14_wll((short)(331),(long)(handle),(unsigned long)(offset))
#define fast_read_io_word(handle,offset) (unsigned short)trap_14_wll((short)(332),(long)(handle),(unsigned long)(offset))
#define fast_read_io_longword(handle,offset) (unsigned long)trap_14_wll((short)(333),(long)(handle),(unsigned long)(offset))
#define write_io_byte(handle,offset,data) (long)trap_14_wllw((short)(334),(long)(handle),(unsigned long)(offset),(unsigned short)(data))
#define write_io_word(handle,offset,data) (long)trap_14_wllw((short)(335),(long)(handle),(unsigned long)(offset),(unsigned short)(data))
#define write_io_longword(handle,offset,data) (long)trap_14_wlll((short)(336),(long)(handle),(unsigned long)(offset),(unsigned long)(data))
#define get_machine_id() (long)trap_14_w((short)(337))
#define get_pagesize() (long)trap_14_w((short)(338))
#define virt_to_bus(handle,address,pointer) (long)trap_14_wlll((short)(339),(long)(handle),(unsigned long)(address),(unsigned long *)(pointer))
#define bus_to_virt(handle,address,pointer) (long)trap_14_wlll((short)(340),(long)(handle),(unsigned long)(address),(unsigned long *)(pointer))
#define virt_to_phys(address,pointer) (long)trap_14_wll((short)(341),(unsigned long)(address),(unsigned long *)(pointer))
#define phys_to_virt(address,pointer) (long)trap_14_wll((short)(342),(unsigned long)(address),(unsigned long *)(pointer))
#define dma_setbuffer(pci_address,local_address,size) (long)trap_14_wlll((short)(350),(unsigned long)(pci_address),(unsigned long)(local_address),(unsigned long)(size))
#define dma_buffoper(mode) (long)trap_14_ww((short)(351),(short)(mode))
#define read_mailbox(mailbox,pointer)  (long)trap_14_wwl((short)(352),(short)(mailbox),(unsigned long *)(pointer))
#define write_mailbox(mailbox,data) (long)trap_14_wwl((short)(353),(short)(mailbox),(unsigned long)(data))

extern long Find_pci_device(unsigned long id, unsigned short index);
extern long Find_pci_classcode(unsigned long class, unsigned short index);
extern long Read_config_byte(long handle, unsigned short reg, unsigned char *address);
extern long Read_config_word(long handle, unsigned short reg, unsigned short *address);
extern long Read_config_longword(long handle, unsigned short reg, unsigned long *address);
extern unsigned char Fast_read_config_byte(long handle, unsigned short reg);
extern unsigned short Fast_read_config_word(long handle, unsigned short reg);
extern unsigned long Fast_read_config_longword(long handle, unsigned short reg);
extern long Write_config_byte(long handle, unsigned short reg, unsigned short val);
extern long Write_config_word(long handle, unsigned short reg, unsigned short val);
extern long Write_config_longword(long handle, unsigned short reg, unsigned long val);
extern long Hook_interrupt(long handle, unsigned long *routine, unsigned long *parameter);
extern long Unhook_interrupt(long handle);
extern long Special_cycle(unsigned short bus, unsigned long data);
extern long Get_routing(long handle);
extern long Set_interrupt(long handle);
extern long Get_resource(long handle);
extern long Get_card_used(long handle, unsigned long *address);
extern long Set_card_used(long handle, unsigned long *callback);
extern long Read_mem_byte(long handle, unsigned long offset, unsigned char *address);
extern long Read_mem_word(long handle, unsigned long offset, unsigned short *address);
extern long Read_mem_longword(long handle, unsigned long offset, unsigned long *address);
extern unsigned char Fast_read_mem_byte(long handle, unsigned long offset);
extern unsigned short Fast_read_mem_word(long handle, unsigned long offset);
extern unsigned long Fast_read_mem_longword(long handle, unsigned long offset);
extern long Write_mem_byte(long handle, unsigned long offset, unsigned short val);
extern long Write_mem_word(long handle, unsigned long offset, unsigned short val);
extern long Write_mem_longword(long handle, unsigned long offset, unsigned long val);
extern long Read_io_byte(long handle, unsigned long offset, unsigned char *address);
extern long Read_io_word(long handle, unsigned long offset, unsigned short *address);
extern long Read_io_longword(long handle, unsigned long offset, unsigned long *address);
extern unsigned char Fast_read_io_byte(long handle, unsigned long offset);
extern unsigned short Fast_read_io_word(long handle, unsigned long offset);
extern unsigned long Fast_read_io_longword(long handle, unsigned long offset);
extern long Write_io_byte(long handle, unsigned long offset, unsigned short val);
extern long Write_io_word(long handle, unsigned long offset, unsigned short val);
extern long Write_io_longword(long handle, unsigned long offset, unsigned long val);
extern long Get_machine_id(void);
extern long Get_pagesize(void);
extern long Virt_to_bus(long handle, unsigned long address, PCI_CONV_ADR *pointer);
extern long Bus_to_virt(long handle, unsigned long address, PCI_CONV_ADR *pointer);
extern long Virt_to_phys(unsigned long address, PCI_CONV_ADR *pointer);
extern long Phys_to_virt(unsigned long address, PCI_CONV_ADR *pointer);

#endif
