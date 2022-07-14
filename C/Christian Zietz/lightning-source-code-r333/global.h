/*
 * Modified for the FreeMiNT USB subsystem by David Galvez. 2010 - 2011
 *
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *                                        2004 F.Naumann & O.Skancke
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _global_h
#define _global_h

#include "cookie.h"

#ifndef TOSONLY
#include "libkern/libkern.h"
#include "mint/module.h"

typedef char Path[PATH_MAX];

/* XXX -> kassert */
#define FATAL KERNEL_FATAL

/* XXX -> dynamic mapping from kernel */
//#define USB_MAGIC    0x5553425FL
//#define USB_MAGIC_SH 0x55534253L

/*
 * debug section
 */

#ifdef DEV_DEBUG

# define FORCE(x)       KERNEL_FORCE x
# define ALERT(x)       KERNEL_ALERT x
# define DEBUG(x)       KERNEL_DEBUG x
# define TRACE(x)       KERNEL_TRACE x
# define ASSERT(x)      assert x

#else

# define FORCE(x)       KERNEL_FORCE x
# define ALERT(x)       KERNEL_ALERT x
# define DEBUG(x)
# define TRACE(x)
# define ASSERT(x)      assert x

#endif

#define getcookie(x,y) get_toscookie(x,(long unsigned int*)y)

#else /* TOSONLY */
#include <mint/osbind.h> /* Setexc, SuperToUser */
#include <stdarg.h>

#include "mint/pcibios.h"

/* BIOS */

/* DavidGZ: changedrv doesn't seem equivalent to Mediach BIOS function.
 * I don't know why this was done, just in case I'm missing something
 * I've commented the define instead of removing it.
 */
#undef changedrv
#define changedrv(x) /* (void)Mediach */
#undef b_setexc
#define b_setexc Setexc

/* XBIOS */
#undef s_version
#define s_version Sversion
#undef b_kbdvbase
#define b_kbdvbase Kbdvbase
#undef b_uiorec
#define b_uiorec Iorec
#undef b_supexec
#define b_supexec(x0,x1,x2,x3,x4,x5) Supexec(x0)
#undef b_getrez
#define b_getrez Getrez

/* GEMDOS */
#undef c_conws
#define c_conws (void)Cconws
#undef c_conout
#define c_conout (void)Cconout
#undef d_getdrv
#define d_getdrv Dgetdrv
#undef d_setdrv
#define d_setdrv Dsetdrv
#undef d_getpath
#define d_getpath Dgetpath
#undef d_setpath
#define d_setpath Dsetpath
#undef kmalloc
#define kmalloc Malloc
#undef kfree
#define kfree Mfree
#undef f_open
#define f_open Fopen
#undef f_read
#define f_read Fread
#undef f_close
#define f_close Fclose

/* PCI-BIOS */

long Find_pci_device(unsigned long id, unsigned short index);
long Find_pci_classcode(unsigned long class, unsigned short index);
long Read_config_byte(long handle, unsigned short reg, unsigned char *address);
long Read_config_word(long handle, unsigned short reg, unsigned short *address);
long Read_config_longword(long handle, unsigned short reg, unsigned long *address);
unsigned char Fast_read_config_byte(long handle, unsigned short reg);
unsigned short Fast_read_config_word(long handle, unsigned short reg);
unsigned long Fast_read_config_longword(long handle, unsigned short reg);
long Write_config_byte(long handle, unsigned short reg, unsigned short val);
long Write_config_word(long handle, unsigned short reg, unsigned short val);
long Write_config_longword(long handle, unsigned short reg, unsigned long val);
long Hook_interrupt(long handle, unsigned long *routine, unsigned long *parameter);
long Unhook_interrupt(long handle);
long Special_cycle(unsigned short bus, unsigned long data);
long Get_routing(long handle);
long Set_interrupt(long handle);
long Get_resource(long handle);
long Get_card_used(long handle, unsigned long *address);
long Set_card_used(long handle, unsigned long *callback);
long Read_mem_byte(long handle, unsigned long offset, unsigned char *address);
long Read_mem_word(long handle, unsigned long offset, unsigned short *address);
long Read_mem_longword(long handle, unsigned long offset, unsigned long *address);
unsigned char Fast_read_mem_byte(long handle, unsigned long offset);
unsigned short Fast_read_mem_word(long handle, unsigned long offset);
unsigned long Fast_read_mem_longword(long handle, unsigned long offset);
long Write_mem_byte(long handle, unsigned long offset, unsigned short val);
long Write_mem_word(long handle, unsigned long offset, unsigned short val);
long Write_mem_longword(long handle, unsigned long offset, unsigned long val);
long Read_io_byte(long handle, unsigned long offset, unsigned char *address);
long Read_io_word(long handle, unsigned long offset, unsigned short *address);
long Read_io_longword(long handle, unsigned long offset, unsigned long *address);
unsigned char Fast_read_io_byte(long handle, unsigned long offset);
unsigned short Fast_read_io_word(long handle, unsigned long offset);
unsigned long Fast_read_io_longword(long handle, unsigned long offset);
long Write_io_byte(long handle, unsigned long offset, unsigned short val);
long Write_io_word(long handle, unsigned long offset, unsigned short val);
long Write_io_longword(long handle, unsigned long offset, unsigned long val);
long Get_machine_id(void);
long Get_pagesize(void);
long Virt_to_bus(long handle, unsigned long address, struct pci_conv_adr *pointer);
long Bus_to_virt(long handle, unsigned long address, struct pci_conv_adr *pointer);
long Virt_to_phys(unsigned long address, struct pci_conv_adr *pointer);
long Phys_to_virt(unsigned long address, struct pci_conv_adr *pointer);

/* library declarations from libkern */

# if __KERNEL__ == 3	/* These declarations are only needed for TOS drivers,
						 * usbtool.acc is linked against LIBCMINI
						 */
void *	_cdecl memcpy		(void *dst, const void *src, unsigned long nbytes);
void *	_cdecl memset		(void *dst, int ucharfill, unsigned long size);
long	_cdecl _mint_memcmp	(const void *s1, const void *s2, ulong size);

long	_cdecl _mint_memcmp	(const void *s1, const void *s2, ulong size);
long	_cdecl _mint_strncmp	(const char *str1, const char *str2, long len);
char *	_cdecl _mint_strcpy	(char *dst, const char *src);
char *	_cdecl _mint_strncpy	(char *dst, const char *src, long len);
char *	_cdecl _mint_strcat	(char *dst, const char *src);
long	_cdecl _mint_strlen	(const char *s);

long	_cdecl kvsprintf(char *buf, long buflen, const char *fmt, va_list args) __attribute__((format(printf, 3, 0)));
long	_cdecl ksprintf		(char *buf, long buflen, const char *fmt, ...) __attribute__((format(printf, 3, 4)));

# define strlen			_mint_strlen
# define strncmp		_mint_strncmp
# define strcpy			_mint_strcpy
# define strncpy		_mint_strncpy
# define strcat			_mint_strcat
# define memcmp			_mint_memcmp

#define sprintf			ksprintf

#endif /* __KERNEL__ */

#ifdef DEV_DEBUG

/* Debug console output for TOS */
static char tos_debugbuffer[512];

#define AUX	1	/* Serial */
#define CON	2	/* Console */
#define DEV	CON

static void tos_printmsg(const char *fmt, ...) __attribute__((unused)) __attribute__((format(printf, 1, 2)));

static void tos_printmsg(const char *fmt, ...)
{
	va_list args;

	va_start (args, fmt);
	kvsprintf (tos_debugbuffer, sizeof(tos_debugbuffer)-1, fmt, args);
	va_end (args);

	int i = 0;

	do {
		Bconout(DEV, (short)tos_debugbuffer[i]);
		i++;
	} while(tos_debugbuffer[i] != '\0');
	Bconout(DEV,'\r');
	Bconout(DEV,'\n');
}

# define FORCE(x)       tos_printmsg x
# define ALERT(x)       tos_printmsg x
# define DEBUG(x)       tos_printmsg x
# define TRACE(x)
# define ASSERT(x)

#else /* !DEV_DEBUG */

# define FORCE(x)
# define ALERT(x)
# define DEBUG(x)
# define TRACE(x)
# define ASSERT(x)
#endif /* !DEV_DEBUG */


/* cookie jar definition
 */

#define _USB 0x5f555342L

static inline int getcookie(long target,long *p_value)
{
	long oldssp;
	struct cookie *cookie_ptr;

	if (Super((void *)1L) == 0L)
		oldssp = Super(0L);
	else
		oldssp = 0;

	cookie_ptr = *CJAR;

	if (oldssp)
		SuperToUser((void *)oldssp);

	if (cookie_ptr) {
		do {
			if (cookie_ptr->tag == target) {
				if (p_value)
					*p_value = cookie_ptr->value;
				return 1;
			}
		} while ((cookie_ptr++)->tag != 0L);
	}

	return 0;
}

static inline int setcookie (long tag, long value)
{
	long oldssp;
	struct cookie *cjar;
	long n = 0;

	if (Super((void *)1L) == 0L)
		oldssp = Super(0L);
	else
		oldssp = 0;

	cjar = * CJAR;

	if (oldssp)
		SuperToUser((void *)oldssp);

	if (cjar)
	{
		while (cjar->tag)
		{
			n++;
			if (cjar->tag == tag)
			{
				cjar->value = value;
				return 1;
			}
			cjar++;
		}

		n++;
		if (n < cjar->value)
		{
			n = cjar->value;
			cjar->tag = tag;
			cjar->value = value;

			cjar++;
			cjar->tag = 0L;
			cjar->value = n;
			return 1;
		}
	}

	return 0;
}

/* Precise delays functions for TOS USB drivers */
#include "tos-common/tosdelay.c"

#endif /* TOSONLY */

static inline void hex_nybble(int n)
{
	char c;

	c = (n > 9) ? 'A'+n-10 : '0'+n;
	c_conout(c);
}

static inline void hex_byte(uchar n)
{
	hex_nybble(n>>4);
	hex_nybble(n&0x0f);
}

static inline void hex_word(ushort n)
{
	hex_byte(n>>8);
	hex_byte(n&0xff);
}

static inline void hex_long(ulong n)
{
	hex_word(n>>16);
	hex_word(n&0xffff);
};

/* 
 * Returns TOS version from OS header. 
 * Additionally, MSB will be for EmuTOS.
 */

typedef struct _usb_osheader
{
	ushort    os_entry;       /* BRAnch instruction to Reset-handler  */
  ushort    os_version;     /* TOS version number                   */
  void       *reseth;         /* Pointer to Reset-handler             */
  struct _osheader *os_beg;   /* Base address of the operating system */
  void       *os_end;         /* First byte not used by the OS        */
  ulong     os_rsvl;        /* Reserved                             */
 	void/*GEM_MUPB*/   *os_magic;       /* GEM memory-usage parameter block     */
  long     os_date;        /* TOS date (English !) in BCD format   */
  ushort    os_conf;        /* Various configuration bits           */
  ushort    os_dosdate;     /* TOS date in GEMDOS format            */

    /* The following components are available only as of TOS Version
       1.02 (Blitter-TOS)               */
  uchar    **p_root;         /* Base address of the GEMDOS pool      */
  uchar    **pkbshift;       /* Pointer to BIOS Kbshift variable
                                  (for TOS 1.00 see Kbshift)           */
  BASEPAGE  **p_run;          /* Address of the variables containing
                                 a pointer to the current GEMDOS
                                 process.                             */
  ulong     p_rsv2;         /* Reserved, always 'ETOS', if EmuTOS present     */
} _USB_OSHEADER;

static inline unsigned short get_tos_version(void)
{
	unsigned short version;
	_USB_OSHEADER *osheader;
	long *sysbase = (long *)0x4f2;

#ifdef TOSONLY
	long oldssp;
	if (Super((void *)1L) == 0L)
		oldssp = Super(0L);
	else
		oldssp = 0;
#endif

	osheader = (_USB_OSHEADER *)*sysbase;
	version = osheader->os_version;

	if (0x45544F53L == (long)osheader->p_rsv2) /* ETOS */
		version |= 0x8000;

#ifdef TOSONLY
	if (oldssp)
		SuperToUser((void *)oldssp);
#endif

	return version;
}

#endif /* _global_h */
