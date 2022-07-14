/* pci_bios.c - Access to PCI-BIOS functions from USB TOS drivers
 *
 * Copyright (C) 2019 David Galvez

 * This file is distributed under the GPL, version 2.
 * See /COPYING.GPL for details.
 */

#include "../../global.h"


/* PCI_BIOS structure definition */

struct pcibios {
	unsigned long subjar;
	unsigned long version;
	/* Although we declare this functions as standard gcc functions (cdecl),
	 * they expect paramenters inside registers (fastcall) unsupported by gcc m68k.
	 * Caller will take care of parameters passing convention.
	 */
	long (*Find_pci_device)	(unsigned long id, unsigned short index);
	long (*Find_pci_classcode)	(unsigned long class, unsigned short index);
	long (*Read_config_byte)	(long handle, unsigned short reg, unsigned char *address);
	long (*Read_config_word)	(long handle, unsigned short reg, unsigned short *address);
	long (*Read_config_longword)	(long handle, unsigned short reg, unsigned long *address);
	unsigned char (*Fast_read_config_byte)	(long handle, unsigned short reg);
	unsigned short (*Fast_read_config_word)	(long handle, unsigned short reg);
	unsigned long (*Fast_read_config_longword)	(long handle, unsigned short reg);
	long (*Write_config_byte)	(long handle, unsigned short reg, unsigned short val);
	long (*Write_config_word)	(long handle, unsigned short reg, unsigned short val);
	long (*Write_config_longword)	(long handle, unsigned short reg, unsigned long val);
	long (*Hook_interrupt)	(long handle, unsigned long *routine, unsigned long *parameter);
	long (*Unhook_interrupt)	(long handle);
	long (*Special_cycle)	(unsigned short bus, unsigned long data);
	long (*Get_routing)	(long handle);
	long (*Set_interrupt)	(long handle);
	long (*Get_resource)	(long handle);
	long (*Get_card_used)	(long handle, unsigned long *address);
	long (*Set_card_used)	(long handle, unsigned long *callback);
	long (*Read_mem_byte)	(long handle, unsigned long offset, unsigned char *address);
	long (*Read_mem_word)	(long handle, unsigned long offset, unsigned short *address);
	long (*Read_mem_longword)	(long handle, unsigned long offset, unsigned long *address);
	unsigned char (*Fast_read_mem_byte)	(long handle, unsigned long offset);
	unsigned short (*Fast_read_mem_word)	(long handle, unsigned long offset);
	unsigned long (*Fast_read_mem_longword)	(long handle, unsigned long offset);
	long (*Write_mem_byte)	(long handle, unsigned long offset, unsigned short val);
	long (*Write_mem_word)	(long handle, unsigned long offset, unsigned short val);
	long (*Write_mem_longword)	(long handle, unsigned long offset, unsigned long val);
	long (*Read_io_byte)	(long handle, unsigned long offset, unsigned char *address);
	long (*Read_io_word)	(long handle, unsigned long offset, unsigned short *address);
	long (*Read_io_longword)	(long handle, unsigned long offset, unsigned long *address);
	unsigned char (*Fast_read_io_byte)	(long handle, unsigned long offset);
	unsigned short (*Fast_read_io_word)	(long handle, unsigned long offset);
	unsigned long (*Fast_read_io_longword)	(long handle, unsigned long offset);
	long (*Write_io_byte)	(long handle, unsigned long offset, unsigned short val);
	long (*Write_io_word)	(long handle, unsigned long offset, unsigned short val);
	long (*Write_io_longword)	(long handle, unsigned long offset, unsigned long val);
	long (*Get_machine_id)	(void);
	long (*Get_pagesize)	(void);
	long (*Virt_to_bus)	(long handle, unsigned long address, PCI_CONV_ADR *pointer);
	long (*Bus_to_virt)	(long handle, unsigned long address, PCI_CONV_ADR *pointer);
	long (*Virt_to_phys)	(unsigned long address, PCI_CONV_ADR *pointer);
	long (*Phys_to_virt)	(unsigned long address, PCI_CONV_ADR *pointer);
	long reserved[2];
};

/* Declarations */
struct pcibios *pcibios;

void *tab_funcs_pci;
unsigned long pcibios_installed = 0;

/* External declarations */
extern long x_Find_pci_device(unsigned long id, unsigned short index);
extern long x_Find_pci_classcode(unsigned long class, unsigned short index);
extern long x_Read_config_byte(long handle, unsigned short reg, unsigned char *address);
extern long x_Read_config_word(long handle, unsigned short reg, unsigned short *address);
extern long x_Read_config_longword(long handle, unsigned short reg, unsigned long *address);
extern unsigned char x_Fast_read_config_byte(long handle, unsigned short reg);
extern unsigned short x_Fast_read_config_word(long handle, unsigned short reg);
extern unsigned long x_Fast_read_config_longword(long handle, unsigned short reg);
extern long x_Write_config_byte(long handle, unsigned short reg, unsigned short val);
extern long x_Write_config_word(long handle, unsigned short reg, unsigned short val);
extern long x_Write_config_longword(long handle, unsigned short reg, unsigned long val);
extern long x_Hook_interrupt(long handle, unsigned long *routine, unsigned long *parameter);
extern long x_Unhook_interrupt(long handle);
extern long x_Special_cycle(unsigned short bus, unsigned long data);
extern long x_Get_routing(long handle);
extern long x_Set_interrupt(long handle);
extern long x_Get_resource(long handle);
extern long x_Get_card_used(long handle, unsigned long *address);
extern long x_Set_card_used(long handle, unsigned long *callback);
extern long x_Read_mem_byte(long handle, unsigned long offset, unsigned char *address);
extern long x_Read_mem_word(long handle, unsigned long offset, unsigned short *address);
extern long x_Read_mem_longword(long handle, unsigned long offset, unsigned long *address);
extern unsigned char x_Fast_read_mem_byte(long handle, unsigned long offset);
extern unsigned short x_Fast_read_mem_word(long handle, unsigned long offset);
extern unsigned long x_Fast_read_mem_longword(long handle, unsigned long offset);
extern long x_Write_mem_byte(long handle, unsigned long offset, unsigned short val);
extern long x_Write_mem_word(long handle, unsigned long offset, unsigned short val);
extern long x_Write_mem_longword(long handle, unsigned long offset, unsigned long val);
extern long x_Read_io_byte(long handle, unsigned long offset, unsigned char *address);
extern long x_Read_io_word(long handle, unsigned long offset, unsigned short *address);
extern long x_Read_io_longword(long handle, unsigned long offset, unsigned long *address);
extern unsigned char x_Fast_read_io_byte(long handle, unsigned long offset);
extern unsigned short x_Fast_read_io_word(long handle, unsigned long offset);
extern unsigned long x_Fast_read_io_longword(long handle, unsigned long offset);
extern long x_Write_io_byte(long handle, unsigned long offset, unsigned short val);
extern long x_Write_io_word(long handle, unsigned long offset, unsigned short val);
extern long x_Write_io_longword(long handle, unsigned long offset, unsigned long val);
extern long x_Get_machine_id(void);
extern long x_Get_pagesize(void);
extern long x_Virt_to_bus(long handle, unsigned long address, PCI_CONV_ADR *pointer);
extern long x_Bus_to_virt(long handle, unsigned long address, PCI_CONV_ADR *pointer);
extern long x_Virt_to_phys(unsigned long address, PCI_CONV_ADR *pointer);
extern long x_Phys_to_virt(unsigned long address, PCI_CONV_ADR *pointer);

/* Function prototypes */
long pcibios_init(void);


/* Function definitions */

long pcibios_init(void)
{
	long t = 0;

	/* Get PCI cookie */
	if (!getcookie(COOKIE__PCI, &t))
	{
		(void)Cconws("USB: Failed to get _PCI cookie\r\n");
		return -1;
	}
	pcibios = (struct pcibios *)t;
	pcibios_installed = pcibios->version;
	/* First function in jump table */
	tab_funcs_pci = &pcibios->Find_pci_device;

	return 0;
}


long Find_pci_device(unsigned long id, unsigned short index)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Find_pci_device(id, index);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Find_pci_classcode(unsigned long class, unsigned short index)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Find_pci_classcode(class, index);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Read_config_byte(long handle, unsigned short reg, unsigned char *address)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Read_config_byte(handle, reg, address);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Read_config_word(long handle, unsigned short reg, unsigned short *address)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Read_config_word(handle, reg, address);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Read_config_longword(long handle, unsigned short reg, unsigned long *address)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Read_config_longword(handle, reg, address);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

unsigned char Fast_read_config_byte(long handle, unsigned short reg)
{
	char r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Fast_read_config_byte(handle, reg);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

unsigned short Fast_read_config_word(long handle, unsigned short reg)
{
	unsigned short r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Fast_read_config_word(handle, reg);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

unsigned long Fast_read_config_longword(long handle, unsigned short reg)
{
	unsigned long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r= x_Fast_read_config_longword(handle, reg);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Write_config_byte(long handle, unsigned short reg, unsigned short val)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Write_config_byte(handle, reg, val);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Write_config_word(long handle, unsigned short reg, unsigned short val)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Write_config_word(handle, reg, val);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Write_config_longword(long handle, unsigned short reg, unsigned long val)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Write_config_longword(handle, reg, val);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Hook_interrupt(long handle, unsigned long *routine, unsigned long *parameter)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Hook_interrupt(handle, routine, parameter);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Unhook_interrupt(long handle)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Unhook_interrupt(handle);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Special_cycle(unsigned short bus, unsigned long data)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Special_cycle(bus, data);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Get_routing(long handle)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Get_routing(handle);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Set_interrupt(long handle)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Set_interrupt(handle);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Get_resource(long handle)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Get_resource(handle);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Get_card_used(long handle, unsigned long *address)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Get_card_used( handle, address);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Set_card_used(long handle, unsigned long *callback)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Set_card_used( handle, callback);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Read_mem_byte(long handle, unsigned long offset, unsigned char *address)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Read_mem_byte(handle, offset, address);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Read_mem_word(long handle, unsigned long offset, unsigned short *address)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Read_mem_word(handle, offset, address);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Read_mem_longword(long handle, unsigned long offset, unsigned long *address)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Read_mem_longword(handle, offset, address);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

unsigned char Fast_read_mem_byte(long handle, unsigned long offset)
{
	char r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Fast_read_mem_byte( handle, offset);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

unsigned short Fast_read_mem_word(long handle, unsigned long offset)
{
	unsigned short r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Fast_read_mem_word( handle, offset);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

unsigned long Fast_read_mem_longword(long handle, unsigned long offset)
{
	unsigned long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Fast_read_mem_longword( handle, offset);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Write_mem_byte(long handle, unsigned long offset, unsigned short val)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Write_mem_byte( handle, offset, val);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Write_mem_word(long handle, unsigned long offset, unsigned short val)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Write_mem_word( handle, offset, val);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Write_mem_longword(long handle, unsigned long offset, unsigned long val)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Write_mem_longword( handle, offset, val);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Read_io_byte(long handle, unsigned long offset, unsigned char *address)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Read_io_byte(handle, offset, address);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Read_io_word(long handle, unsigned long offset, unsigned short *address)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Read_io_word(handle, offset, address);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Read_io_longword(long handle, unsigned long offset, unsigned long *address)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Read_io_longword(handle, offset, address);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

unsigned char Fast_read_io_byte(long handle, unsigned long offset)
{
	char r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Fast_read_io_byte(handle, offset);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

unsigned short Fast_read_io_word(long handle, unsigned long offset)
{
	unsigned short r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Fast_read_io_word(handle, offset);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

unsigned long Fast_read_io_longword(long handle, unsigned long offset)
{
	unsigned long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Fast_read_io_longword(handle, offset);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Write_io_byte(long handle, unsigned long offset, unsigned short val)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Write_io_byte(handle, offset, val);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Write_io_word(long handle, unsigned long offset, unsigned short val)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Write_io_word(handle, offset, val);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Write_io_longword(long handle, unsigned long offset, unsigned long val)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Write_io_longword(handle, offset, val);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Get_machine_id(void)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Get_machine_id();
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Get_pagesize(void)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Get_pagesize();
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Virt_to_bus(long handle, unsigned long address, struct pci_conv_adr *pointer)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Virt_to_bus(handle, address, pointer);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Bus_to_virt(long handle, unsigned long address, struct pci_conv_adr *pointer)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Bus_to_virt(handle, address, pointer);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Virt_to_phys(unsigned long address, struct pci_conv_adr *pointer)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Virt_to_phys(address, pointer);
	if (oldmode) SuperToUser(oldmode);
	return r;
}

long Phys_to_virt(unsigned long address, struct pci_conv_adr *pointer)
{
	long r;
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	r = x_Phys_to_virt(address, pointer);
	if (oldmode) SuperToUser(oldmode);
	return r;
}
