/*
	PCIBIOS calling functions

	Copyright (C) 2002	Patrice Mandin
	Some parts (in the utility functions), from the Linux kernel

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

#include <stdio.h>
#include <stdlib.h>

#include <mint/osbind.h>
#include <mint/cookie.h>

#include "pci.h"
#include "endian.h"

/*--- Defines ---*/

#define PCIBIOS_BEGIN(stack) \
	stack=NULL; \
	if (Super(1)==0) { \
		stack=(void *)Super(NULL); \
	}

#define PCIBIOS_END(stack) \
	if (stack!=NULL) { \
		Super(stack); \
	}

/*--- PCI bios function calls ---*/

#define PCIBIOSCALL_l_d0ld1w(func_ptr,p1,p2)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movw	%3,d1;\n\t"	\
		"movl	%2,d0;\n\t"	\
		"jbsr	%1@;"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2)		/* inputs  */	\
		: "d0", "d1"			 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define PCIBIOSCALL_l_d0la0ld1b(func_ptr,p1,p2,p3)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movb	%4,d1;\n\t"	\
		"movl	%3,a0;\n\t"	\
		"movl	%2,d0;\n\t"	\
		"jbsr	%1@;"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2), "g"(p3)		/* inputs  */	\
		: "d0", "d1", "a0"			 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define PCIBIOSCALL_l_d0ld1b(func_ptr,p1,p2)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movb	%3,d1;\n\t"	\
		"movl	%2,d0;\n\t"	\
		"jbsr	%1@;"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2)		/* inputs  */	\
		: "cc", "d0", "d1"			 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define PCIBIOSCALL_l_d0ld1bd2(func_ptr,p1,p2,p3)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%4,d2;\n\t"	\
		"movb	%3,d1;\n\t"	\
		"movl	%2,d0;\n\t"	\
		"jbsr	%1@;"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2), "g"(p3)		/* inputs  */	\
		: "d0", "d1", "d2"			 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define PCIBIOSCALL_l_d0la0ld1l(func_ptr,p1,p2,p3)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%4,d1;\n\t"	\
		"movl	%3,a0;\n\t"	\
		"movl	%2,d0;\n\t"	\
		"jbsr	%1@;"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2), "g"(p3)		/* inputs  */	\
		: "d0", "d1", "a0"			 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define PCIBIOSCALL_l_d0l(func_ptr,p1)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%2,d0;\n\t"	\
		"jbsr	%1@;"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(func_ptr), "g"(p1)		/* inputs  */	\
		: "d0"			 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define PCIBIOSCALL_l_d0bd1l(func_ptr,p1,p2)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%3,d1;\n\t"	\
		"movb	%2,d0;\n\t"	\
		"jbsr	%1@;"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2)		/* inputs  */	\
		: "d0", "d1"			 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define PCIBIOSCALL_l_d0la0l(func_ptr,p1,p2)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%3,a0;\n\t"	\
		"movl	%2,d0;\n\t"	\
		"jbsr	%1@;"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2)		/* inputs  */	\
		: "d0", "a0"			 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define PCIBIOSCALL_l_d0ld1l(func_ptr,p1,p2)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%3,d1;\n\t"	\
		"movl	%2,d0;\n\t"	\
		"jbsr	%1@;"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2)		/* inputs  */	\
		: "d0", "d1"			 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define PCIBIOSCALL_l_d0ld1ld2(func_ptr,p1,p2,p3)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%4,d2;\n\t"	\
		"movl	%3,d1;\n\t"	\
		"movl	%2,d0;\n\t"	\
		"jbsr	%1@;"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2), "g"(p3)		/* inputs  */	\
		: "d0", "d1", "d2"			 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define PCIBIOSCALL_l_void(func_ptr)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"jbsr	%1@;"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(func_ptr)		/* inputs  */	\
		: "d0"			 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

/*--- Types ---*/

typedef void (*pci_routine_t)(void);

typedef struct {
	unsigned long *subcookie;
	unsigned long version;
	pci_routine_t pci_routines[43];
} pci_cookie_t;

/*--- Variables ---*/

static pci_cookie_t *cookie_pci;

/*--- Functions prototypes ---*/

static unsigned long pci_size(unsigned long base, unsigned long mask);

/*--- Functions ---*/

long pci_init(void)
{
	if (Getcookie(C__PCI, (unsigned long *)&cookie_pci) != C_FOUND) {
		return PCI_FUNC_NOT_SUPPORTED;
	}

	if ( (((cookie_pci->version)>>16)&0xffff) != 0x0001) {
		return PCI_FUNC_NOT_SUPPORTED;
	}

	return PCI_SUCCESSFUL;
}

long pci_find_device(unsigned long device_handle, unsigned short index)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1w(cookie_pci->pci_routines[0], device_handle, index);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_find_classcode(unsigned long class_code, unsigned short index)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1w(cookie_pci->pci_routines[1], class_code, index);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_read_config_byte(unsigned long device_handle, void *data, unsigned char num_register)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1b(cookie_pci->pci_routines[2], device_handle, data, num_register);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_read_config_word(unsigned long device_handle, void *data, unsigned char num_register)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1b(cookie_pci->pci_routines[3], device_handle, data, num_register);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_read_config_long(unsigned long device_handle, void *data, unsigned char num_register)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1b(cookie_pci->pci_routines[4], device_handle, data, num_register);
	PCIBIOS_END(oldstack);
	return result;
}

unsigned char pci_read_config_byte_fast(unsigned long device_handle, unsigned char num_register)
{
	unsigned char result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1b(cookie_pci->pci_routines[5], device_handle, num_register);
	PCIBIOS_END(oldstack);
	return result;
}

unsigned short pci_read_config_word_fast(unsigned long device_handle, unsigned char num_register)
{
	unsigned short result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1b(cookie_pci->pci_routines[6], device_handle, num_register);
	PCIBIOS_END(oldstack);
	return result;
}

unsigned long pci_read_config_long_fast(unsigned long device_handle, unsigned char num_register)
{
	unsigned long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1b(cookie_pci->pci_routines[7], device_handle, num_register);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_write_config_byte(unsigned long device_handle, unsigned char num_register, unsigned char value)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1bd2(cookie_pci->pci_routines[8], device_handle, num_register, value);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_write_config_word(unsigned long device_handle, unsigned char num_register, unsigned short value)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1bd2(cookie_pci->pci_routines[9], device_handle, num_register, value);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_write_config_long(unsigned long device_handle, unsigned char num_register, unsigned long value)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1bd2(cookie_pci->pci_routines[10], device_handle, num_register, value);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_hook_interrupt(unsigned long device_handle, void (*data)(), unsigned long parameter)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1l(cookie_pci->pci_routines[11], device_handle, data, parameter);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_unhook_interrupt(unsigned long device_handle)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0l(cookie_pci->pci_routines[12], device_handle);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_special_cycle(unsigned char num_bus, unsigned long data)
{
	long result=PCI_FUNC_NOT_SUPPORTED;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0bd1l(cookie_pci->pci_routines[13], num_bus, data);
	PCIBIOS_END(oldstack);
	return result;
}

/* pci_get_routing() */

/* pci_set_interrupt() */

long pci_get_resource(unsigned long device_handle)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0l(cookie_pci->pci_routines[16], device_handle);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_get_card_used(unsigned long device_handle, unsigned long *callback)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0l(cookie_pci->pci_routines[17], device_handle, callback);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_set_card_used(unsigned long device_handle, unsigned long callback)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0l(cookie_pci->pci_routines[18], device_handle, callback);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_read_mem_byte(unsigned long device_handle, unsigned long pci_address, unsigned char *data)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1l(cookie_pci->pci_routines[19], device_handle, data, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_read_mem_word(unsigned long device_handle, unsigned long pci_address, unsigned short *data)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1l(cookie_pci->pci_routines[20], device_handle, data, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_read_mem_long(unsigned long device_handle, unsigned long pci_address, unsigned long *data)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1l(cookie_pci->pci_routines[21], device_handle, data, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

unsigned char pci_read_mem_byte_fast(unsigned long device_handle, unsigned long pci_address)
{
	unsigned char result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1l(cookie_pci->pci_routines[22], device_handle, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

unsigned short pci_read_mem_word_fast(unsigned long device_handle, unsigned long pci_address)
{
	unsigned short result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1l(cookie_pci->pci_routines[23], device_handle, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

unsigned long pci_read_mem_long_fast(unsigned long device_handle, unsigned long pci_address)
{
	unsigned long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1l(cookie_pci->pci_routines[24], device_handle, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_write_mem_byte(unsigned long device_handle, unsigned long pci_address, unsigned char value)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1ld2(cookie_pci->pci_routines[25], device_handle, pci_address, value);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_write_mem_word(unsigned long device_handle, unsigned long pci_address, unsigned short value)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1ld2(cookie_pci->pci_routines[26], device_handle, pci_address, value);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_write_mem_long(unsigned long device_handle, unsigned long pci_address, unsigned long value)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1ld2(cookie_pci->pci_routines[27], device_handle, pci_address, value);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_read_io_byte(unsigned long device_handle, unsigned long pci_address, unsigned char *data)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1l(cookie_pci->pci_routines[28], device_handle, data, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_read_io_word(unsigned long device_handle, unsigned long pci_address, unsigned short *data)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1l(cookie_pci->pci_routines[29], device_handle, data, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_read_io_long(unsigned long device_handle, unsigned long pci_address, unsigned long *data)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1l(cookie_pci->pci_routines[30], device_handle, data, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

unsigned char pci_read_io_byte_fast(unsigned long device_handle, unsigned long pci_address)
{
	unsigned char result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1l(cookie_pci->pci_routines[31], device_handle, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

unsigned short pci_read_io_word_fast(unsigned long device_handle, unsigned long pci_address)
{
	unsigned long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1l(cookie_pci->pci_routines[32], device_handle, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}


unsigned long pci_read_io_long_fast(unsigned long device_handle, unsigned long pci_address)
{
	unsigned long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1l(cookie_pci->pci_routines[33], device_handle, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_write_io_byte(unsigned long device_handle, unsigned long pci_address, unsigned char value)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1ld2(cookie_pci->pci_routines[34], device_handle, pci_address, value);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_write_io_word(unsigned long device_handle, unsigned long pci_address, unsigned short value)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1ld2(cookie_pci->pci_routines[35], device_handle, pci_address, value);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_write_io_long(unsigned long device_handle, unsigned long pci_address, unsigned long value)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0ld1ld2(cookie_pci->pci_routines[36], device_handle, pci_address, value);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_get_machine_id(void)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_void(cookie_pci->pci_routines[37]);
	PCIBIOS_END(oldstack);
	return result;
}

unsigned long pci_get_pagesize(void)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_void(cookie_pci->pci_routines[38]);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_virt_to_bus(unsigned long device_handle, void *virt_cpu_address, void *data)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1l(cookie_pci->pci_routines[39], device_handle, data, virt_cpu_address);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_bus_to_virt(unsigned long device_handle, unsigned long pci_address, void *data)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0ld1l(cookie_pci->pci_routines[40], device_handle, data, pci_address);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_virt_to_phys(void *virt_cpu_address, void *data)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0l(cookie_pci->pci_routines[41], virt_cpu_address, data);
	PCIBIOS_END(oldstack);
	return result;
}

long pci_phys_to_virt(void *phys_cpu_address, void *data)
{
	long result;
	void *oldstack;

	PCIBIOS_BEGIN(oldstack);
	result = PCIBIOSCALL_l_d0la0l(cookie_pci->pci_routines[42], phys_cpu_address, data);
	PCIBIOS_END(oldstack);
	return result;
}

/* Now some utility functions */

long pci_read_config(unsigned long device_handle, pci_config_t *device_config)
{
	long result=PCI_SUCCESSFUL;
	int i;
	unsigned char *buffer;

	/* bytes 0x00 to 0x3f */
	buffer = (unsigned char *)device_config;
	for (i=0; i<0x40; i++) {
		result = pci_read_config_byte(device_handle, buffer, i);
		if (result<0) {
			return result;
		}
		buffer++;
	}

	/* bytes 0x40 to 0x7f */
	buffer = (unsigned char *)device_config;
	buffer += 0x40;
	for (i=0x40; i<0x7f; i++) {
		result = pci_read_config_byte(device_handle, buffer, i);
		if (result<0) {
			return 0x40;
		}
		buffer++;
	}

	return 0x80;
}

static unsigned long pci_size(unsigned long base, unsigned long mask)
{
	unsigned long size;
	
	size = mask & base;		/* Find the significant bits */
	size = size & ~(size-1);	/* Get the lowest of them to find the decode size */
	return size-1;			/* extent = size - 1 */
}

unsigned long pci_read_mem_size(unsigned long device_handle, int config_register)
{
	unsigned long old_register, size;
	unsigned long oldreg_be, size_be;
	
	/* Read current register value */
	pci_read_config_long(device_handle, &old_register, config_register);

	/* Write not(0) */
	pci_write_config_long(device_handle, config_register, 0xffffffff);

	/* Read value */
	pci_read_config_long(device_handle, &size, config_register);

	/* Write previous register value */
	pci_write_config_long(device_handle, config_register, old_register);

	if (!size || size== 0xffffffff) {
		return 0;
	}

	if (old_register == 0xffffffff) {
		old_register = 0;
	}

	oldreg_be = LE_LONG(old_register);
	size_be = LE_LONG(size);

	if ((oldreg_be & PCI_BASE_ADDRESS_SPACE) == PCI_BASE_ADDRESS_SPACE_MEMORY) {
		size_be = pci_size(size_be, PCI_BASE_ADDRESS_MEM_MASK);
	} else {
		size_be = pci_size(size_be, PCI_BASE_ADDRESS_IO_MASK & 0xffff);
	}

	return size_be;
}

unsigned long pci_read_mem_base(unsigned long adr, int *memtype)
{
	*memtype = ((adr & PCI_BASE_ADDRESS_SPACE) == PCI_BASE_ADDRESS_SPACE_MEMORY);

	if (memtype) {
		adr &= PCI_BASE_ADDRESS_MEM_MASK;
	} else {
		adr &= PCI_BASE_ADDRESS_IO_MASK;
	}

	return adr;
}
