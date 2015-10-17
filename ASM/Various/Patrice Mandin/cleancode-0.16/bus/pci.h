/*
	PCIBIOS calling functions

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#ifndef _PCI_H
#define _PCI_H

/*--- Defines ---*/

/* Cookie _PCI */
#define C__PCI 0x5f504349L

/* Error codes for PCI BIOS */
#define PCI_SUCCESSFUL			0x00000000L
#define PCI_FUNC_NOT_SUPPORTED	0xfffffffeL
#define PCI_BAD_VENDOR_ID		0xfffffffdL
#define PCI_DEVICE_NOT_FOUND	0xfffffffcL
#define PCI_BAD_REGISTER_NUMBER	0xfffffffbL
#define PCI_SET_FAILED			0xfffffffaL
#define PCI_BUFFER_TOO_SMALL	0xfffffff9L
#define PCI_GENERAL_ERROR		0xfffffff8L
#define PCI_BAD_HANDLE			0xfffffff7L

/*--- Some defines, from <linux/pci.h> ---*/

/*
 * Under PCI, each device has 256 bytes of configuration address space,
 * of which the first 64 bytes are standardized as follows:
 */
#define PCI_VENDOR_ID		0x00	/* 16 bits */
#define PCI_DEVICE_ID		0x02	/* 16 bits */
#define PCI_COMMAND		0x04	/* 16 bits */
#define  PCI_COMMAND_IO		0x1	/* Enable response in I/O space */
#define  PCI_COMMAND_MEMORY	0x2	/* Enable response in Memory space */
#define  PCI_COMMAND_MASTER	0x4	/* Enable bus mastering */
#define  PCI_COMMAND_SPECIAL	0x8	/* Enable response to special cycles */
#define  PCI_COMMAND_INVALIDATE	0x10	/* Use memory write and invalidate */
#define  PCI_COMMAND_VGA_PALETTE 0x20	/* Enable palette snooping */
#define  PCI_COMMAND_PARITY	0x40	/* Enable parity checking */
#define  PCI_COMMAND_WAIT 	0x80	/* Enable address/data stepping */
#define  PCI_COMMAND_SERR	0x100	/* Enable SERR */
#define  PCI_COMMAND_FAST_BACK	0x200	/* Enable back-to-back writes */

#define PCI_STATUS		0x06	/* 16 bits */
#define  PCI_STATUS_CAP_LIST	0x10	/* Support Capability List */
#define  PCI_STATUS_66MHZ	0x20	/* Support 66 Mhz PCI 2.1 bus */
#define  PCI_STATUS_UDF		0x40	/* Support User Definable Features [obsolete] */
#define  PCI_STATUS_FAST_BACK	0x80	/* Accept fast-back to back */
#define  PCI_STATUS_PARITY	0x100	/* Detected parity error */
#define  PCI_STATUS_DEVSEL_MASK	0x600	/* DEVSEL timing */
#define  PCI_STATUS_DEVSEL_FAST	0x000	
#define  PCI_STATUS_DEVSEL_MEDIUM 0x200
#define  PCI_STATUS_DEVSEL_SLOW 0x400
#define  PCI_STATUS_SIG_TARGET_ABORT 0x800 /* Set on target abort */
#define  PCI_STATUS_REC_TARGET_ABORT 0x1000 /* Master ack of " */
#define  PCI_STATUS_REC_MASTER_ABORT 0x2000 /* Set on master abort */
#define  PCI_STATUS_SIG_SYSTEM_ERROR 0x4000 /* Set when we drive SERR */
#define  PCI_STATUS_DETECTED_PARITY 0x8000 /* Set on parity error */

#define PCI_CLASS_REVISION	0x08	/* High 24 bits are class, low 8
					   revision */
#define PCI_REVISION_ID         0x08    /* Revision ID */
#define PCI_CLASS_PROG          0x09    /* Reg. Level Programming Interface */
#define PCI_CLASS_DEVICE        0x0a    /* Device class */

#define PCI_CACHE_LINE_SIZE	0x0c	/* 8 bits */
#define PCI_LATENCY_TIMER	0x0d	/* 8 bits */
#define PCI_HEADER_TYPE		0x0e	/* 8 bits */
#define  PCI_HEADER_TYPE_NORMAL	0
#define  PCI_HEADER_TYPE_BRIDGE 1
#define  PCI_HEADER_TYPE_CARDBUS 2

#define PCI_BIST		0x0f	/* 8 bits */
#define PCI_BIST_CODE_MASK	0x0f	/* Return result */
#define PCI_BIST_START		0x40	/* 1 to start BIST, 2 secs or less */
#define PCI_BIST_CAPABLE	0x80	/* 1 if BIST capable */

/*
 * Base addresses specify locations in memory or I/O space.
 * Decoded size can be determined by writing a value of 
 * 0xffffffff to the register, and reading it back.  Only 
 * 1 bits are decoded.
 */
#define PCI_BASE_ADDRESS_0	0x10	/* 32 bits */
#define PCI_BASE_ADDRESS_1	0x14	/* 32 bits [htype 0,1 only] */
#define PCI_BASE_ADDRESS_2	0x18	/* 32 bits [htype 0 only] */
#define PCI_BASE_ADDRESS_3	0x1c	/* 32 bits */
#define PCI_BASE_ADDRESS_4	0x20	/* 32 bits */
#define PCI_BASE_ADDRESS_5	0x24	/* 32 bits */
#define  PCI_BASE_ADDRESS_SPACE	0x01	/* 0 = memory, 1 = I/O */
#define  PCI_BASE_ADDRESS_SPACE_IO 0x01
#define  PCI_BASE_ADDRESS_SPACE_MEMORY 0x00
#define  PCI_BASE_ADDRESS_MEM_TYPE_MASK 0x06
#define  PCI_BASE_ADDRESS_MEM_TYPE_32	0x00	/* 32 bit address */
#define  PCI_BASE_ADDRESS_MEM_TYPE_1M	0x02	/* Below 1M [obsolete] */
#define  PCI_BASE_ADDRESS_MEM_TYPE_64	0x04	/* 64 bit address */
#define  PCI_BASE_ADDRESS_MEM_PREFETCH	0x08	/* prefetchable? */
#define  PCI_BASE_ADDRESS_MEM_MASK	(~0x0fUL)
#define  PCI_BASE_ADDRESS_IO_MASK	(~0x03UL)
/* bit 1 is reserved if address_space = 1 */

/*--- Header type 0 (normal devices) ---*/
#define PCI_CARDBUS_CIS		0x28
#define PCI_SUBSYSTEM_VENDOR_ID	0x2c
#define PCI_SUBSYSTEM_ID	0x2e  
#define PCI_ROM_ADDRESS		0x30	/* Bits 31..11 are address, 10..1 reserved */
#define  PCI_ROM_ADDRESS_ENABLE	0x01
#define PCI_ROM_ADDRESS_MASK	(~0x7ffUL)

#define PCI_CAPABILITY_LIST	0x34	/* Offset of first capability list entry */

/* 0x35-0x3b are reserved */
#define PCI_INTERRUPT_LINE	0x3c	/* 8 bits */
#define PCI_INTERRUPT_PIN	0x3d	/* 8 bits */
#define PCI_MIN_GNT		0x3e	/* 8 bits */
#define PCI_MAX_LAT		0x3f	/* 8 bits */

/*--- Header type 1 (PCI-to-PCI bridges) ---*/
#define PCI_PRIMARY_BUS		0x18	/* Primary bus number */
#define PCI_SECONDARY_BUS	0x19	/* Secondary bus number */
#define PCI_SUBORDINATE_BUS	0x1a	/* Highest bus number behind the bridge */
#define PCI_SEC_LATENCY_TIMER	0x1b	/* Latency timer for secondary interface */
#define PCI_IO_BASE		0x1c	/* I/O range behind the bridge */
#define PCI_IO_LIMIT		0x1d
#define  PCI_IO_RANGE_TYPE_MASK	0x0f	/* I/O bridging type */
#define  PCI_IO_RANGE_TYPE_16	0x00
#define  PCI_IO_RANGE_TYPE_32	0x01
#define  PCI_IO_RANGE_MASK	~0x0f
#define PCI_SEC_STATUS		0x1e	/* Secondary status register, only bit 14 used */
#define PCI_MEMORY_BASE		0x20	/* Memory range behind */
#define PCI_MEMORY_LIMIT	0x22
#define  PCI_MEMORY_RANGE_TYPE_MASK 0x0f
#define  PCI_MEMORY_RANGE_MASK	~0x0f
#define PCI_PREF_MEMORY_BASE	0x24	/* Prefetchable memory range behind */
#define PCI_PREF_MEMORY_LIMIT	0x26
#define  PCI_PREF_RANGE_TYPE_MASK 0x0f
#define  PCI_PREF_RANGE_TYPE_32	0x00
#define  PCI_PREF_RANGE_TYPE_64	0x01
#define  PCI_PREF_RANGE_MASK	~0x0f
#define PCI_PREF_BASE_UPPER32	0x28	/* Upper half of prefetchable memory range */
#define PCI_PREF_LIMIT_UPPER32	0x2c
#define PCI_IO_BASE_UPPER16	0x30	/* Upper half of I/O addresses */
#define PCI_IO_LIMIT_UPPER16	0x32
/* 0x34 same as for htype 0 */
/* 0x35-0x3b is reserved */
#define PCI_ROM_ADDRESS1	0x38	/* Same as PCI_ROM_ADDRESS, but for htype 1 */
/* 0x3c-0x3d are same as for htype 0 */
#define PCI_BRIDGE_CONTROL	0x3e
#define  PCI_BRIDGE_CTL_PARITY	0x01	/* Enable parity detection on secondary interface */
#define  PCI_BRIDGE_CTL_SERR	0x02	/* The same for SERR forwarding */
#define  PCI_BRIDGE_CTL_NO_ISA	0x04	/* Disable bridging of ISA ports */
#define  PCI_BRIDGE_CTL_VGA	0x08	/* Forward VGA addresses */
#define  PCI_BRIDGE_CTL_MASTER_ABORT 0x20  /* Report master aborts */
#define  PCI_BRIDGE_CTL_BUS_RESET 0x40	/* Secondary bus reset */
#define  PCI_BRIDGE_CTL_FAST_BACK 0x80	/* Fast Back2Back enabled on secondary interface */

/*--- Header type 2 (CardBus bridges) ---*/
/* 0x14-0x15 reserved */
#define PCI_CB_SEC_STATUS	0x16	/* Secondary status */
#define PCI_CB_PRIMARY_BUS	0x18	/* PCI bus number */
#define PCI_CB_CARD_BUS		0x19	/* CardBus bus number */
#define PCI_CB_SUBORDINATE_BUS	0x1a	/* Subordinate bus number */
#define PCI_CB_LATENCY_TIMER	0x1b	/* CardBus latency timer */
#define PCI_CB_MEMORY_BASE_0	0x1c
#define PCI_CB_MEMORY_LIMIT_0	0x20
#define PCI_CB_MEMORY_BASE_1	0x24
#define PCI_CB_MEMORY_LIMIT_1	0x28
#define PCI_CB_IO_BASE_0	0x2c
#define PCI_CB_IO_BASE_0_HI	0x2e
#define PCI_CB_IO_LIMIT_0	0x30
#define PCI_CB_IO_LIMIT_0_HI	0x32
#define PCI_CB_IO_BASE_1	0x34
#define PCI_CB_IO_BASE_1_HI	0x36
#define PCI_CB_IO_LIMIT_1	0x38
#define PCI_CB_IO_LIMIT_1_HI	0x3a
#define  PCI_CB_IO_RANGE_MASK	~0x03
/* 0x3c-0x3d are same as for htype 0 */
#define PCI_CB_BRIDGE_CONTROL	0x3e
#define  PCI_CB_BRIDGE_CTL_PARITY	0x01	/* Similar to standard bridge control register */
#define  PCI_CB_BRIDGE_CTL_SERR		0x02
#define  PCI_CB_BRIDGE_CTL_ISA		0x04
#define  PCI_CB_BRIDGE_CTL_VGA		0x08
#define  PCI_CB_BRIDGE_CTL_MASTER_ABORT	0x20
#define  PCI_CB_BRIDGE_CTL_CB_RESET	0x40	/* CardBus reset */
#define  PCI_CB_BRIDGE_CTL_16BIT_INT	0x80	/* Enable interrupt for 16-bit cards */
#define  PCI_CB_BRIDGE_CTL_PREFETCH_MEM0 0x100	/* Prefetch enable for both memory regions */
#define  PCI_CB_BRIDGE_CTL_PREFETCH_MEM1 0x200
#define  PCI_CB_BRIDGE_CTL_POST_WRITES	0x400
#define PCI_CB_SUBSYSTEM_VENDOR_ID 0x40
#define PCI_CB_SUBSYSTEM_ID	0x42
#define PCI_CB_LEGACY_MODE_BASE	0x44	/* 16-bit PC Card legacy mode base address (ExCa) */
/* 0x48-0x7f reserved */

/*--- Types ---*/

/* Header 0, normal devices */
typedef struct {
	/* 0x14-0x27 */
	unsigned char address[20];

	/* 0x28-0x2f */
	unsigned char cardbus_cis[4];
	unsigned char subvendor_id[2];
	unsigned char subdevice_id[2];

	/* 0x30-0x33 */
	unsigned char rom_address[4];

	/* 0x34 */
	unsigned char capability_list;

	/* 0x35-0x3b */
	unsigned char reserved1[7];

	/* 0x3c-0x3f */
	unsigned char int_line;
	unsigned char int_pin;
	unsigned char min_gnt;
	unsigned char max_lat;

	/* 0x40-0x7f */
	unsigned char reserved2[64];
} pci_config_header0_t;

/* Header 1, PCI-PCI bridges */
typedef struct {
	/* 0x14-0x17 */
	unsigned char address[4];

	/* 0x18-0x1b */
	unsigned char primary_bus;
	unsigned char secondary_bus;
	unsigned char subordinate_bus;
	unsigned char sec_latency_timer;

	/* 0x1c-0x1f */
	unsigned char io_base;
	unsigned char io_limit;
	unsigned char sec_status;
	unsigned char reserved1;

	/* 0x20-0x33 */
	unsigned char mem_base[2];
	unsigned char mem_limit[2];
	unsigned char pref_mem_base[2];
	unsigned char pref_mem_limit[2];
	unsigned char pref_base_u32[4];
	unsigned char pref_limit_u32[4];
	unsigned char io_base_u16[2];
	unsigned char io_limit_u16[2];

	/* 0x34-0x3f */
	unsigned char capability_list;
	unsigned char reserved2[3];
	unsigned char rom_address[4];
	unsigned char bridge_control[2];
	
	/* 0x40-0x7f */
	unsigned char reserved3[64];
} pci_config_header1_t;

/* Header 2, cardbus bridges */
typedef struct {
	/* 0x14-0x1b */
	unsigned char reserved1[2];
	unsigned char secondary_status[2];
	unsigned char primary_bus;
	unsigned char card_bus;
	unsigned char subordinate_bus;
	unsigned char latency_timer;

	/* 0x1c-0x2b */
	unsigned char mem_base0[4];	
	unsigned char mem_limit0[4];	
	unsigned char mem_base1[4];	
	unsigned char mem_limit1[4];	

	/* 0x2c-0x3b */
	unsigned char io_base0[2];
	unsigned char io_base0_hi[2];
	unsigned char io_limit0[2];
	unsigned char io_limit0_hi[2];
	unsigned char io_base1[2];
	unsigned char io_base1_hi[2];
	unsigned char io_limit1[2];
	unsigned char io_limit1_hi[2];

	/* 0x3c-0x45 */
	unsigned char reserved2[2];
	unsigned char bridge_control[2];
	unsigned char subvendor_id[2];
	unsigned char subdevice_id[2];
	unsigned char legacy_base[2];

	/* 0x46-0x7f */
	unsigned char reserved3[58];
} pci_config_header2_t;

/* Configuration registers */
typedef struct {
	/* 0x00-0x03 */
	unsigned char vendor_id[2];
	unsigned char device_id[2];

	/* 0x04-0x07 */
	unsigned char command[2];
	unsigned char status[2];

	/* 0x08-0x0b */
	unsigned char revision_id;
	unsigned char classcode[3];

	/* 0x0c-0x0f */
	unsigned char cache_line_size;
	unsigned char latency_timer;
	unsigned char header_type;
	unsigned char are;

	/* 0x10-0x13 */
	unsigned char address[4];

	/* 0x14-0x7f */
	union {
		pci_config_header0_t header0;
		pci_config_header1_t header1;
		pci_config_header2_t header2;
	};
} pci_config_t;

typedef struct {
	void *address;
	unsigned long length;
} pcibios_mmu_memstruct_t;

/*--- Functions prototypes ---*/

long pci_init(void);

long pci_find_device(unsigned long device_vendor_id, unsigned short index);
long pci_find_classcode(unsigned long class_code, unsigned short index);
long pci_read_config_byte(unsigned long device_handle, void *data, unsigned char num_register);
long pci_read_config_word(unsigned long device_handle, void *data, unsigned char num_register);
long pci_read_config_long(unsigned long device_handle, void *data, unsigned char num_register);
unsigned char pci_read_config_byte_fast(unsigned long device_handle, unsigned char num_register);
unsigned short pci_read_config_word_fast(unsigned long device_handle, unsigned char num_register);
unsigned long pci_read_config_long_fast(unsigned long device_handle, unsigned char num_register);
long pci_write_config_byte(unsigned long device_handle, unsigned char num_register, unsigned char value);
long pci_write_config_word(unsigned long device_handle, unsigned char num_register, unsigned short value);
long pci_write_config_long(unsigned long device_handle, unsigned char num_register, unsigned long value);
long pci_hook_interrupt(unsigned long device_handle, void (*data)(), unsigned long parameter); 
long pci_unhook_interrupt(unsigned long device_handle); 
long pci_special_cycle(unsigned char num_bus, unsigned long data); 
/* pci_get_routing */
/* pci_set_interrupt */
long pci_get_resource(unsigned long device_handle); 
long pci_get_card_used(unsigned long device_handle, unsigned long *callback);
long pci_set_card_used(unsigned long device_handle, unsigned long callback);
long pci_read_mem_byte(unsigned long device_handle, unsigned long pci_address, unsigned char *data);
long pci_read_mem_word(unsigned long device_handle, unsigned long pci_address, unsigned short *data);
long pci_read_mem_long(unsigned long device_handle, unsigned long pci_address, unsigned long *data);
unsigned char pci_read_mem_byte_fast(unsigned long device_handle, unsigned long pci_address);
unsigned short pci_read_mem_word_fast(unsigned long device_handle, unsigned long pci_address);
unsigned long pci_read_mem_long_fast(unsigned long device_handle, unsigned long pci_address);
long pci_write_mem_byte(unsigned long device_handle, unsigned long pci_address, unsigned char value);
long pci_write_mem_word(unsigned long device_handle, unsigned long pci_address, unsigned short value);
long pci_write_mem_long(unsigned long device_handle, unsigned long pci_address, unsigned long value);
long pci_read_io_byte(unsigned long device_handle, unsigned long pci_address, unsigned char *data);
long pci_read_io_word(unsigned long device_handle, unsigned long pci_address, unsigned short *data);
long pci_read_io_long(unsigned long device_handle, unsigned long pci_address, unsigned long *data);
unsigned char pci_read_io_byte_fast(unsigned long device_handle, unsigned long pci_address);
unsigned short pci_read_io_word_fast(unsigned long device_handle, unsigned long pci_address);
unsigned long pci_read_io_long_fast(unsigned long device_handle, unsigned long pci_address);
long pci_write_io_byte(unsigned long device_handle, unsigned long pci_address, unsigned char value);
long pci_write_io_word(unsigned long device_handle, unsigned long pci_address, unsigned short value);
long pci_write_io_long(unsigned long device_handle, unsigned long pci_address, unsigned long value);
long pci_get_machine_id(void);
unsigned long pci_get_pagesize(void);
long pci_virt_to_bus(unsigned long device_handle, void *virt_cpu_address, void *data);
long pci_bus_to_virt(unsigned long device_handle, unsigned long pci_address, void *data);
long pci_virt_to_phys(void *virt_cpu_address, void *data);
long pci_phys_to_virt(void *phys_cpu_address, void *data);

/*--- More functions ---*/

/* <0 if error, or >0: number of config bytes read */
long pci_read_config(unsigned long device_handle, pci_config_t *device_config);

/* 0 if error, <>0 if size read */
unsigned long pci_read_mem_size(unsigned long device_handle, int config_register);

/* return a masked address, with only useful bits */
unsigned long pci_read_mem_base(unsigned long adr, int *memtype);

#endif /* _PCI_H */
