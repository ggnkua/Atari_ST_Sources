/* TOS 4.04 PCI init for the CT60/CTPCI & Coldfire boards
 * Didier Mequignon 2005-2011, e-mail: aniplay@wanadoo.fr
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
#include <mint/osbind.h>
#include <mint/falcon.h>
#include <mint/sysvars.h>
#include <string.h>
#include "driver.h" /* fVDI */
#include "fb.h"
#include "radeon/radeonfb.h"
#include "lynx/smi.h"
#include "usb/usb.h"
#include "mod_devicetable.h"
#include "m68k_disasm.h"
#include "ct60.h"
#include "vidix.h"

// #define BETA_VERSION "beta 8"

#undef DEBUG

#ifndef Vsetscreen
#ifdef VsetScreen
#define Vsetscreen VsetScreen
#else
#warning Bad falcon.h
#endif
#endif

#ifndef Montype
#ifdef VgetMonitor
#define Montype VgetMonitor
#else
#warning Bad falcon.h
#endif
#endif

#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
extern void board_printf(const char *fmt, ...);
#else
#define board_printf kprint
extern void kprint(const char *fmt, ...);
#endif
extern int sprintD(char *s, const char *fmt, ...);

#ifdef NETWORK

// #define TEST_NETWORK

#define uint8 unsigned char
#define uint16 unsigned short
#define uint32 unsigned long
#ifdef LWIP
#include "lwip/net.h"
#include "lwip/sockets.h"
#include "lwip/tftp.h"
extern int tftpreceive(unsigned char *server, char *sname, short handle, long *size);
extern int tftpsend(unsigned char *server, char *sname, short handle);
extern int usb_load_files(void);
typedef unsigned char IP_ADDR[4];
#else
#include "net/eth.h"
#include "net/nbuf.h"
#include "net/nif.h"
#include "net/ip.h"
#include "net/udp.h"
#include "net/tftp.h"
#endif
#include "get.h"

extern long install_ram_disk(void);
#ifdef MCF547X
extern long check_sd_card(void);
extern long install_sd_card(void);
#endif
extern void init_dma(void);
extern int init_network(void);
#ifndef LWIP
extern void end_network(void);
#endif
extern int alert_tos(char *string);
extern void init_dma_transfer(void);
extern void minus(char *s);
extern int InitSound(long gsxb);

unsigned long write_protect_ram_disk;

#endif /* NETWORK */

extern void init_resolution(long modecode);
extern long find_best_mode(long modecode);
extern const struct fb_videomode *get_db_from_modecode(long modecode);

typedef struct
{
	unsigned short bootpref;
	char reserved[4];
	unsigned char language;
	unsigned char keyboard;
	unsigned char datetime;
	char separator;
	unsigned char bootdelay;
	char reserved2[3];
	unsigned short vmode;
	unsigned char scsi;
} NVM;

typedef struct
{
	long ident;
	union
	{
		long l;
		short i[2];
		char c[4];
	} v;
} COOKIE;

typedef struct
{
	long xbra;
	long ident;
	long old_address;
	short jump[3];
} XBRA;

extern void ltoa(char *buf, long n, unsigned long base);

extern Virtual *init_var_fvdi(void);
extern void det_xbios(void);
extern void det_linea(void);
extern void init_det_vdi(Virtual *vwk);
extern void det_vdi(void);
extern long init(Access *access, Driver *driver, Virtual *vwk, char *opts);
extern void init_screen(void);
extern COOKIE *get_cookie(long id);
extern int add_cookie(COOKIE *cook);
extern int eddi_cookie(int);
extern long initialize_pool(long size, long n);
extern void display_atari_logo(void);
extern void display_ati_logo(void);
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_INTERRUPT_POLLING)
extern void install_vbl_timer(void *func, int remove);
#endif

/* global */
extern unsigned short VERSION[];
extern unsigned short DATE[];
extern long second_screen;
extern struct mode_option resolution;
extern short accel_s, accel_c;
COOKIE vidix;
extern char monitor_layout[];
extern short default_dynclk;
extern short ignore_edid;
extern short mirror;
extern short virtual;
extern short force_measure_pll;
extern short zoom_mouse;
extern struct pci_device_id radeonfb_pci_table[]; /* radeon_base.c */
extern struct pci_device_id lynxfb_pci_table[]; /* smi_base.c */
extern struct pci_device_id ohci_usb_pci_table[]; /* ohci-hcd.c */
extern struct pci_device_id ehci_usb_pci_table[]; /* ehci-hcd.c */
extern Access *access;      /* fVDI */
Access _access_;            /* fVDI */
extern struct fb_info *info_fvdi;
extern long blocks,block_size;
extern long fix_modecode;
Virtual *base_vwk;
long old_vector_xbios,old_vector_linea,old_vector_vdi;
short video_found, usb_found, ata_found;
short use_dma, restart, redirect, os_magic, memory_ok, drive_ok, video_log, swi;
#if defined(COLDFIRE) && defined(MCF547X) && defined(NETWORK) && defined(LWIP)
short boot_os;
#endif
NVM nvm;
COOKIE eddi;
void (**mousevec)(void *);
_IOREC *iorec;
void (**ikbdvec)();
unsigned char **keytbl;
long debug_traps[16];
extern void trace_tos(void);
m68k_word *old_address;
extern unsigned char _bss_start[];
extern unsigned char _end[];
void empty(void) {}

#ifndef COLDFIRE
static char mess_ignore[] = 
	"Press 'CTRL' or 'ALT' before this screen for ignore CTCM/CTPCI\r\n"
	"Press 'V' before this screen for use VIDEL\r\n"
	"   or 'D' for use the default mode / monitor layout\r\n"
	"          and turn on debug information\r\n";
#endif

unsigned long get_hex_value(void)
{
	unsigned long val;
	int i=0,j=0;
	char c;
	char buf[8];
	while(1)
	{
		c = (char)Crawcin();
		if(c == '\r')
			break;
		if((c == 8) && ( i > 0))
		{
			Cconout(c);
			i--;
		}
		else if((c >= '0') && (c <= '9'))
		{
			Cconout(c);
			buf[i++] = c & 0xF;
		}
		else if(((c >= 'a') && (c <= 'F')) || ((c >= 'A') && (c <= 'f')))
		{
			Cconout(c);
			buf[i++] = (c & 0xF) + 9;
		}
	}
	val = 0;
	while(--i >= 0)
	{
		val <<= 4;
		val |= (unsigned long)buf[j++];
	}
	return(val);
}

long boot_alloc(long size) /* without free */
{
#ifdef COLDFIRE
	long ret;
#else /* !COLDFIRE */
	if((os_magic == 1) && !memory_ok)
	{
		long ret = *_membot;
#endif /* COLDFIRE */
#define BOOT_MEM_SIZE 0x10000
		static char boot_mem[BOOT_MEM_SIZE];
		static char *pt_boot_mem;
		if(pt_boot_mem == NULL)
			pt_boot_mem = boot_mem;
		if(&pt_boot_mem[size] <= &boot_mem[BOOT_MEM_SIZE]) /* try to use driver's memory */
		{
			ret = (long)pt_boot_mem;
			pt_boot_mem += size;
			return(ret);
		}
#ifndef COLDFIRE
		*_membot += size;
		return(ret);
	}
#endif
	return((long)Mxalloc(size, 3));
}

long install_xbra(short vector, void *handler)
{
	XBRA *xbra = (XBRA *)boot_alloc(sizeof(XBRA));
	if(xbra != NULL)
	{
		xbra->xbra = 'XBRA';
		xbra->ident = '_PCI';
		xbra->jump[0] = 0x4EF9; /* JMP */
		*(long *)&xbra->jump[1] = (long)handler;
#ifdef COLDFIRE
#if (__GNUC__ > 3)
		asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5485\n\t"); /* from CF68KLIB */
#else
		asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5200\n\t"); /* from CF68KLIB */
#endif
#else /* 68060 */
		asm volatile (" cpusha BC\n\t");
#endif /* COLDFIRE */
		xbra->old_address = (long)Setexc(vector,(void(*)())&xbra->jump[0]);
		return(xbra->old_address);
	}
	return(0);
}

#ifdef NETWORK

int tftp_load_file(int drive, char *name, char *path_server, IP_ADDR server, long free, long *size)
{
	int ch, i, ret;
	long handle, err;
	static char sname[80], fname[80], data[1024];
	char *p;
	*size = 0;
	strcpy(sname, path_server);
	strcat(sname, name);
	minus(sname);
	fname[0] = (char)drive+'A'; fname[1] = ':'; fname[2] = '\\';
	if(name[0] == '/' || name[0] == '\\')
		strcpy(&fname[2], name);
	else
		strcpy(&fname[3], name);
#ifdef LWIP
	(void)ch;
	(void)data;
	i=3;
	while(fname[i])
	{
		if(fname[i] == '/' || fname[i] == '\\')
		{
			fname[i]=0;
			(void)Dcreate(fname);
			fname[i]='\\';
		}
		i++;	
	}
	err = handle = (long)Fcreate(fname, 0);
	ret = TRUE;
	if(err >= 0)
	{
		if((ret = tftpreceive((unsigned char *)server, sname, (short)handle, size)) == TRUE)
			Fclose((short)handle);
		else
		{
			Fclose((short)handle);
			Fdelete(fname);
		}
#else
	if((ret = tftp_read(&nif[ETHERNET_PORT], sname, server)) == TRUE)
	{
		i=3;
		while(fname[i])
		{
			if(fname[i] == '/' || fname[i] == '\\')
			{
				fname[i]=0;
				Dcreate(fname);
				fname[i]='\\';
			}
			i++;	
		}
		err = handle = (long)Fcreate(fname, 0);
		i = 0;
		while(((ch = tftp_in_char()) != -1) && (err >= 0))
		{
			data[i++] = (char)ch;
			if(i >= 1024)
			{
				*size += (long)i;
				err = Fwrite((short)handle, i, data);
				i = 0;
			}
		}
		if((err >= 0) && i)
		{
			*size += (long)i;
			err = Fwrite((short)handle, i, data);
		}
		if(handle >= 0) 
			Fclose((short)handle);
		tftp_end(1);
#endif
		p = tftp_get_error();
		if(*p)
			ret = FALSE;
	}
	return(ret);
}

int tftp_write_file(int drive, char *name, char *path_server, IP_ADDR server)
{
	long handle, len;
	int ret = TRUE;
	char *buf;
	static char sname[80], fname[80];
	strcpy(sname, path_server);
	strcat(sname, name);
	minus(sname);
	fname[0] = (char)drive+'A'; fname[1] = ':'; fname[2] = '\\';
	strcpy(&fname[3], name);
	handle = (long)Fopen(fname, 2);
	if(handle >=  0)
	{
#ifndef LWIP
		len = Fseek(0, (short)handle, 2);
		if(len > 0)
		{
			Fseek(0, (short)handle, 0);
			buf = (char *)Mxalloc(len, 3);
			if(buf)
			{
				if(Fread((short)handle, len, buf) >= 0)
					ret = tftp_write(&nif[ETHERNET_PORT], sname, server, (unsigned long)buf, (unsigned long)&buf[len]);			
				Mfree(buf);
			}
		}
#else
		if(len);
		if(buf);
		ret = tftpsend((unsigned char *)server, sname, (short)handle);
#endif
		Fclose((short)handle);
	}
	return(ret);
}

#endif

#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
#ifdef CONFIG_USB_INTERRUPT_POLLING
void vbl_usb_event_poll(void)
{
	usb_event_poll(1);
}
#endif
#endif

static short fix_boot_modecode(short vmode)
{
	vmode &= ~VIRTUAL_SCREEN; /* fix boot modecode */
	if(!(vmode & DEVID)) /* modecode normal */
	{
		vmode &= ~(STMODES|OVERSCAN);
		vmode |= PAL;
		if((video_found == 1) && ((vmode & NUMCOLS) == BPS1) && !os_magic) /* VBL monochrome emulation */
		{
			switch(vmode & (VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG|VERTFLAG|VGA|COL80))
			{
				case (VERTFLAG+VGA):                      /* 320 * 240 */
				case 0:                                                                      
				case (VGA+COL80):                         /* 640 * 480 */
				case (VERTFLAG+COL80):
				case (VESA_600+HORFLAG2+VGA+COL80):       /* 800 * 600 */
				case (VESA_768+HORFLAG2+VGA+COL80):       /* 1024 * 768 */
					break;
				default:
					vmode = PAL | VGA | COL80 | BPS1;       /* 640 * 480 * 1 */
					break;
			}
		}
		else if((vmode & NUMCOLS) < BPS8 || ((vmode & NUMCOLS) > BPS32))
		{
			if(!video_found)
				vmode = PAL | VGA | COL80 | BPS16; /* 640 x 480 * 16 */
			else
				vmode = VERTFLAG | PAL | VGA | BPS8; /* 320 * 240 * 8 */
		}
		if(vmode & VGA)
		{
			if(vmode & COL80)
				vmode &= ~VERTFLAG;
			else
				vmode |= VERTFLAG;
		}
		else
		{
			if(vmode & COL80)
				vmode |= VERTFLAG;
			else
				vmode &= ~VERTFLAG;
		}
	}
	else /* bits 11-3 used for DevID */
	{
		const struct fb_videomode *db = get_db_from_modecode(vmode);
		if(db == NULL)
			vmode = VERTFLAG | PAL | VGA | BPS8; /* 320 * 240 * 8 */
		else if((video_found == 1) && ((vmode & NUMCOLS) == BPS1) /* Radeon - VBL monochrome emulation */
		 && ((db->xres > MAX_WIDTH_EMU_MONO) || (db->yres > MAX_HEIGHT_EMU_MONO)))
			vmode = PAL | VGA | COL80 | BPS1; /* 640 * 480 * 1 */
	}
	return(vmode);
}

static void wait_key(void)
{
	Cconws("Press a key...\r\n");
	Crawcin();
}

#if defined(COLDFIRE) && defined(MCF547X) && defined(NETWORK) && defined(LWIP)

int boot_menu(int index, int nb_lines, char *title, char *lines[])
{
#define DELAY_MENU 400 /* 2 seconds */
	int i, j, end = 0;
	char key;
	long ret;
	unsigned long start_hz_200 = *_hz_200;
	unsigned long delay_menu = (unsigned long)nvm.bootdelay * 200;
	if(delay_menu < DELAY_MENU)
		delay_menu = DELAY_MENU;
	Cconws(title);
	while(1)
	{
		i = 0;
		j = 0;
		for(i = 0; i < nb_lines; i++)
		{
			Cconout(' ');
			Cconout(' ');	
			if(i == index)
			{
				Cconout(27); /* invert display */
				Cconout('p');
			}
			Cconout(' ');
			Cconout('1' + (char)i);
			Cconout(':');			
			Cconws(lines[i]);
			if(i == index)
			{
				Cconout(27);
				Cconout('q');
				j = i;
			}
			Cconout('\r');
			Cconout('\n');
		}
		while(1)
		{
			if((( *_hz_200 - start_hz_200) >= delay_menu) || end)
			  return(index);
			if(Cconis())
			{
				start_hz_200 = *_hz_200;
				ret = Crawcin();
				key = (char)ret;
				if((key == ' ') || (key == '\r'))
				  return(index);
				if((key >= '1') && (key <= ((char)nb_lines + '1')))
				{
					j = (int)(key - '1');
					end = 1;
					break;
				}
				ret >>= 16; /* scancode */
				if(ret ==  0x48) /* UP */
				{
					j--;
					if(j < 0)
						j = nb_lines - 1;
					break;
				}
				if(ret == 0x50) /* DOWN */
				{
					j++;
					if(j >= nb_lines)
						j = 0;
					break;
				}
			}
		}
		for(i = 0; i < nb_lines; i++)
		{
			Cconout(27);
			Cconout('A');
		}
		Cconout('\r');
		index = j;
	}
}

void boot_os_menu(void)
{
	static char atari[] = { 0x1B,0x62,0x34,0x41,0x1B,0x62,0x32,0x54,0x1B,0x62,0x33,0x41,0x1B,0x62,0x31,0x52,0x1B,0x62,0x35,0x49,0x20,0x1B,0x62,0x3F };
	static char title[] = "Start with...\r\n";
	static char title_fr[] = "D‚marrer avec...\r\n";
	static char *menu[] = {" TOS404 "," EMUTOS "};
	static char *menu2[] = {" TOS404 for MiNT "," EMUTOS          "," TOS404 full     "};
	static char *menu2_fr[] = {" TOS404 pour MiNT "," EMUTOS           "," TOS404 complet   "};
	static char *menu3[] = {" TOS404 (at 0xE0000000 - boot)   "," EMUTOS (at 0xE0600000)          "," TOS404 (at 0xE0400000 - normal) "};
	Cconws(atari);
	Cconws("FIREBEE\r\n\n");
	if(!(swi & 0x40) || !(swi & 1)) /* !SW5 (UP) */
	{
		if(swi & 0x80) /* SW6 (DOWN) */
			boot_os = boot_menu(0, 2, (nvm.language == 2) ? title_fr : title, menu);
		else /* SW6 (UP) */
		{
			boot_os = boot_menu(0, 3, (nvm.language == 2) ? title_fr : title, (nvm.language == 2) ? menu2_fr : menu2);
			if(boot_os == 2)
			{
				Cconout(27);
				Cconout('E');
			}
		}
	}
	else /* SW5 (DOWN) */
		boot_os = boot_menu(0, 3, "Rescue boot, start with...\r\n", menu3);
	if(!boot_os)
	{
		Cconout(27);
		Cconout('E');
	}
	else
		vTaskDelay(10); /* wait a little bit than ROOT task reboot on choice */
}
             
#endif /* defined(COLDFIRE) && defined(MCF547X) && defined(NETWORK) && defined(LWIP) */

void get_mouseikbdvec(void) /* for USB drivers and HTTP server (screen view) */
{
	_KBDVECS *kbdvecs = (_KBDVECS *)Kbdvbase();
	void **kbdvecs2 = (void **)kbdvecs;
	mousevec = &kbdvecs->mousevec; 
	ikbdvec = (void (**)())&kbdvecs2[-1]; /* undocumented */
	iorec = (_IOREC *)Iorec(1);
	keytbl = (unsigned char **)Keytbl(-1,-1,-1);
}

/* Init TOS call is here ... */

int init_devices(int no_reset, unsigned long hardware_flags) /* after the original setscreen with the modecode from NVRAM */
{
#ifdef COLDFIRE
	COOKIE *p;
#ifdef LWIP
	extern void *run;
	extern void *start_run;
#endif
	extern void osinit(void);
	long end_used_stram = (long)Mxalloc(16, 0);
	memset(_bss_start, 0, (int)(_end - _bss_start));
 	*_membot = end_used_stram;
	osinit();        /* BDOS */
#ifdef LWIP
	start_run = run; /* PD for BDOS malloc */
#endif
#else /* 68060 - use GEMDOS */
	if(*((unsigned short *)0xE80000) < 0x200) /* check boot version  */
		return(0);
	memset(_bss_start, 0, (int)(_end-_bss_start));
#endif /* COLDFIRE */
	get_mouseikbdvec();
	restart = (short)no_reset;
	swi = 0;
	(void)NVMaccess(0, 0, sizeof(NVM), (void *)&nvm);
#ifdef COLDFIRE
	p = get_cookie('_SWI');
	if(p != NULL)
		swi = (short)p->v.l; /* B7: SW6, B6: SW5, B0: BOOT from 0xE0000000 */
#endif
	if(restart == 2)
	{
		memory_ok = 0; /* not use M(x)alloc */
		os_magic = 1;
	}
	else
	{
		memory_ok = 1; /* use M(x)alloc */
		os_magic = 0;
	}
	drive_ok = 0;
	redirect = 0; /* for debug to memory during boot (redirection impossible to file by GEMDOS) */
	do
	{
		static char *spec_monitor_layout[] = {"CRT,NONE","CRT,CRT","CRT,TMDS","TMDS,CRT","TMDS,TMDS"};
		int loop_counter = 0;
		unsigned long temp;
		short index, vmode = 0, key = 0;
		long handle, err, ret;
		struct pci_device_id *board;
		old_address = (m68k_word *)0xFFFFFFFF; /* dbug */
		access = &_access_;
		base_vwk = init_var_fvdi();
#ifdef DEBUG
		debug = 1;
#else
		debug = 0;
#endif
		video_found = usb_found = ata_found = video_log = 0;
		/* init options Radeon */
		use_dma = (short)ct60_rw_parameter(CT60_MODE_READ, CT60_PARAM_CTPCI, 0);
		strcpy(monitor_layout, DEFAULT_MONITOR_LAYOUT); /* CRT, TMDS, LVDS */
		if(use_dma >= 0)
		{
			int mlayout = (int)(use_dma >> 2) - 1;
			if((mlayout >= 0) && (mlayout < 5))
				strcpy(monitor_layout, spec_monitor_layout[mlayout]);
			use_dma = (use_dma >> 1) & 1;
		}
		else
			use_dma = 0;
		default_dynclk = -2;
		ignore_edid = 0;
		mirror = 1;
		virtual = 0;
		zoom_mouse = 1;
		force_measure_pll = 0;
    /* XBIOS */
		fix_modecode = 0;  /* XBIOS 95 used by AES */
		second_screen = 0;
		if(!os_magic && Cconis())
		{
			key = Crawcin() & 0xFF;
			while(Cconis())
				Crawcin();
		}
		temp = ct60_rw_parameter(CT60_MODE_READ, CT60_VMODE, (unsigned long)vmode);
		if((temp == 0xFFFFFFFF) || (key == 'D') || (key == 'd')) /* default mode */
		{
//			vmode = PAL | VGA | COL80 | BPS16;
#if !(defined(COLDFIRE) && defined(MCF547X))
			vmode = VESA_768 | HORFLAG2 | PAL | VGA | COL80 | BPS16;
#endif
			strcpy(monitor_layout, DEFAULT_MONITOR_LAYOUT); /* CRT, TMDS, LVDS */
			debug = 1;
 		}
		else
		{
			vmode = (short)temp;
			if(!debug && !(ct60_rw_parameter(CT60_MODE_READ, CT60_BOOT_LOG, 0) & 2))
				debug = redirect = video_log = 1;
		}
		/* PCI devices detection */ 
		do
		{
			index = 0;
			do
			{
				handle = find_pci_device(0x0000FFFFL, index++);
				if(handle >= 0)
				{
					unsigned long id = 0;
					err = read_config_longword(handle, PCIIDR, &id);
#if 1
					/* test Radeon ATI devices */
					if((err >= 0) && !video_found && (key != 'V') && (key != 'v')) /* V => Videl use */
					{
						if(!loop_counter)
						{
							board = radeonfb_pci_table; /* compare table */
							while(board->vendor)
							{
								if((board->vendor == (id & 0xFFFF))
								 && (board->device == (id >> 16)))
								{
#ifndef COLDFIRE
									if(!os_magic)
										Cconws(mess_ignore);
#endif
									resolution.used = 1;									
									init_resolution(PAL|VGA|COL80|BPS16); /* for monitor */
									if(radeonfb_pci_register(handle, board) >= 0)
 										video_found = 1;
									resolution.used = 0;
									break;
								}
								board++;
							}
						}
#ifdef CONFIG_VIDEO_SMI_LYNXEM
						else if(loop_counter == 1) /* motherboard PCI video */
						{
							board = lynxfb_pci_table; /* compare table */
							while(board->vendor)
							{
								if((board->vendor == (id & 0xFFFF))
								 && (board->device == (id >> 16)))
								{
									resolution.used = 1;
									init_resolution(PAL|VGA|COL80|BPS16); /* for monitor */
									board_printf("Mark, now you have 60 seconds before the Lynx driver start\r\nFor see Lynx mmio register use: dm.l 0xA0700300\r\n(fb_base + 0x400000 + 0x300000 + 0x300 - VGA registers)\r\n");
									wait_ms(60000);
									if(lynxfb_pci_register(handle, board) >= 0)
 										video_found = 2;
									resolution.used = 0;
									break;
								}
								board++;
							}
						}
#endif /* CONFIG_VIDEO_SMI_LYNXEM */
					}
#endif
					/* test USB devices */
					if((err >= 0) && !os_magic && loop_counter && (usb_found < USB_MAX_BUS))
					{
						unsigned long class;
						if(read_config_longword(handle, PCIREV, &class) >= 0
						 && ((class >> 16) == PCI_CLASS_SERIAL_USB))
						{	
							if(loop_counter == 2) /* install EHCI before */
							{
								if((class >> 8) == PCI_CLASS_SERIAL_USB_OHCI)
								{
#ifdef CONFIG_USB_OHCI
									board = ohci_usb_pci_table; /* compare table */
									while(board->vendor)
									{
										if((board->vendor == (id & 0xFFFF))
										 && (board->device == (id >> 16)))
										{
											if(usb_init(handle, board) >= 0)
												usb_found++;
											break;
										}
										board++;
									}
#endif /* CONFIG_USB_OHCI */
								}
							}
							else if((class >> 8) == PCI_CLASS_SERIAL_USB_EHCI)
							{
#ifdef CONFIG_USB_EHCI
								board = ehci_usb_pci_table; /* compare table */
								while(board->vendor)
								{
									if((board->vendor == (id & 0xFFFF))
									 && (board->device == (id >> 16)))
									{
										if(usb_init(handle, board) >= 0)
											usb_found++;
										break;
									}
									board++;
								}
#endif /* CONFIG_USB_EHCI */
							}
						}
					}
					/* test ATA device */
					if((err >= 0) && !ata_found)
					{
						if(id == 0x12345678)  /* device / vendor */
							ata_found = 1;	
					}
				}    
			}
			while(handle >= 0);
			loop_counter++;
		}
		while(loop_counter <= 2);
		old_vector_xbios = old_vector_linea = old_vector_vdi = 0;
		if(usb_found)
		{
#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
#ifdef CONFIG_USB_INTERRUPT_POLLING
			install_vbl_timer(vbl_usb_event_poll, 0);
#else
			usb_enable_interrupt(1);
#endif
#endif /*  defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI) */
		}
		if(video_found)
		{
			extern void *write_pixel_r, *read_pixel_r, *set_colours_r, *get_colours_r, *get_colour_r;
#if 0
			COOKIE *p;
			p = get_cookie('_VDO');
			if(p != NULL)
				p->v.l = 0x00040000;  /* like MILAN, bad idea, less compatible */
#endif
			/* fVDI spec */
			accel_s = 0;  
			accel_c = A_SET_PIX | A_GET_PIX | A_MOUSE | A_LINE | A_BLIT | A_FILL | A_EXPAND | A_FILLPOLY | A_TEXT | A_SET_PAL | A_GET_COL;
			read_pixel_r = write_pixel_r = set_colours_r = get_colours_r = get_colour_r = empty;
			if(!os_magic)
			{
				long screen_addr = Mxalloc(32000 + 256, 0) + 255; /* STRAM - use Mxalloc because Srealloc can be used by monochome emulation later */
				screen_addr &= ~0xFF;
#ifndef COLDFIRE
				if(debug && !redirect)
					wait_key();
#endif
				ret = Vsetscreen(screen_addr, screen_addr, 2, 0);  /* for reduce F030 Videl bus load */
#ifndef COLDFIRE
				Cconws(mess_ignore);
#endif
			}
			old_vector_xbios = install_xbra(46, det_xbios); /* TRAP #14 */
			vidix.ident = 'VIDX';
			vidix.v.l = VIDIX_VERSION;
			add_cookie(&vidix);
#if 0 // #ifndef COLDFIRE
			if(use_dma)
			{
				Cconws("\rDMA (y/n)");
				if((Cconin() & 0xFF) != 'y')
				{
					use_dma = 0;
					Cconout(27);
					Cconout('E');
				}			
			}
#endif
			if(!vmode)
			{
				vmode = (short)find_best_mode((long)vmode);
				if(!vmode)
					vmode = PAL | VGA | COL80 | BPS16;
				else
					vmode |= BPS16;
			}
			vmode = fix_boot_modecode(vmode);
			ret = Vsetscreen(0, 0, 3, vmode); /* new Vsetscreen with internal driver installed */
			if(!os_magic)
			{
#if defined(COLDFIRE) && defined(MCF547X) && defined(NETWORK) && defined(LWIP)
				boot_os_menu();
#endif
				display_atari_logo();
				if(vmode & (DEVID|VERTFLAG2|VESA_768|VESA_600|HORFLAG2|HORFLAG)) 
					display_ati_logo();
			}
			old_vector_linea = install_xbra(10,det_linea);
		}
#ifdef COLDFIRE
		else /* no PCI video board found => install VIDEL fVDI driver else TOS404 VDI crashes (blitter only) */
		{
#if defined(COLDFIRE) && defined(MCF547X)
			extern void init_videl_i2c(void);
			init_videl_i2c();
//			use_dma = 0; /* not works on Flexbus - FPGA */
#endif
			/* fVDI spec */
			accel_s = A_MOUSE;
			accel_c = A_SET_PIX | A_GET_PIX | A_BLIT | A_EXPAND | A_SET_PAL | A_GET_COL;
			resolution.used = 1;
			if(!vmode)
			{
				vmode = (short)find_best_mode((long)vmode);
				if(!vmode)
					vmode = PAL | VGA | COL80 | BPS16;
				else
					vmode |= BPS16;
			}
			vmode = fix_boot_modecode(vmode);
			init_resolution((long)vmode & 0xFFFF);
			info_fvdi = framebuffer_alloc(0); /* => info_fvdi->par == NULL */
			if(!info_fvdi)
				continue;
			info_fvdi->var.xres = info_fvdi->var.xres_virtual = resolution.width;
			info_fvdi->var.yres = info_fvdi->var.yres_virtual = resolution.height;
			info_fvdi->var.bits_per_pixel = resolution.bpp;
			if(!old_vector_xbios)
				old_vector_xbios = install_xbra(46, det_xbios); /* TRAP #14 */
			(void)Vsetscreen(0, 0, 3, vmode);
			if(!os_magic)
			{
#if defined(COLDFIRE) && defined(MCF547X) && defined(NETWORK) && defined(LWIP)
				boot_os_menu();
#endif
				display_atari_logo();
			}
		}
#endif /* COLDFIRE */
		if(redirect)
	  	debug = redirect = 0;
	}
	while(0);
#if defined(NETWORK) && defined(LWIP) && !defined(MCF5445X) && defined(SOUND_AC97)
	if(old_vector_xbios)
		InitSound(1); // AC97
#endif /* defined(NETWORK) && defined(LWIP) && !defined(MCF5445X) && defined(SOUND_AC97) */
	return((int)video_found);
}

void init_with_sdram(void) /* before booting, after the SDRAM init and the PCI devices list */
{
	short key = 0;
#ifdef BETA_VERSION
	int i;
	char buf[8];
	ltoa(buf, (long)VERSION[0], 16);
	Cconout(27);
	Cconws("p TOS drivers v");
	Cconout(buf[0]);
	Cconout('.');
	Cconws(&buf[1]);
	Cconws(" " BETA_VERSION " ");
	for(i = 0; i < 5; i++) /* day, month, date, hour, min */
	{
		ltoa(buf, (long)DATE[i] + 10000, 10);
		if(i < 2)
		{
			Cconws(&buf[3]);
			Cconout('/');
		}
		else if(i == 2)
		{
			Cconws(&buf[1]);
			Cconout(' ');
		}
		else
		{
			Cconws(&buf[3]);
			if(i == 3)
				Cconout(':');
		}
	}
	Cconout(' ');
	Cconout(27);
	Cconout('q');
	Cconws(" (build with GCC ");
	ltoa(buf, (long)__GNUC__, 10);
	Cconws(buf);
//	Cconout('.');
//	ltoa(buf, (long)__GCC_MINOR__, 10);
//	Cconws(buf);
	Cconws(")\r\n");
#endif /* BETA_VERSION */
	memory_ok = 1; /* use M(x)alloc */
	if(os_magic)
		drive_ok = 1;
	if(!os_magic && Cconis())
	{
		key = Crawcin() & 0xFF;
		while(Cconis())
			Crawcin();
	}
#ifdef COLDFIRE
	if((info_fvdi != NULL) /* Videl / Radeon / Lynx driver */
#else /* !COLDFIRE */
	if(*((unsigned short *)0xE80000) < 0x200) /* check boot version  */
		return;
	if(video_found /* Radeon driver */
#endif /* COLDFIRE */
	 && initialize_pool(block_size, blocks)
	 && init(access, base_vwk->real_address->driver, base_vwk, ""))
	{
		init_det_vdi(base_vwk->real_address->driver->default_vwk);
		old_vector_vdi = install_xbra(34, det_vdi); /* TRAP #2 */
		eddi.ident = 'EdDI';
		eddi.v.l = (long)&eddi_cookie;
		add_cookie(&eddi); /* infos about screen with vq_scrninfo() */		
	}
#ifdef COLDFIRE
	else if(info_fvdi != NULL) /* Videl / Radeon / Lynx driver */
#else
	else if(video_found) /* Radeon driver */
#endif
	{
		Cconws("VDI init error\r\n");
		Crawcin();
	}
#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
	if(usb_found)
	{
		int error = 0;
		if(usb_error_str[0])
		{
			Cconws(usb_error_str);
			if(strstr(usb_error_str, "CTL:TIMEOUT") == NULL)
			{
				wait_key();
				error = 1;
			}
		}
		if(!error)
		{
			int uif_cmd_usb(int argc, char **argv);
			char *argv[] = { "usb", "tree" };
			uif_cmd_usb(2, argv);		
		}
	}
#endif
	if(ata_found)
	{
		if(!old_vector_xbios)
			old_vector_xbios = install_xbra(46, det_xbios); /* TRAP #14 */

	}
#if defined(NETWORK) && !defined(LWIP)
	init_dma();
#if !defined(MCF5445X) && defined(SOUND_AC97)
	if(old_vector_xbios)
		InitSound(1); // AC97
#endif /* !defined(MCF5445X) && defined(SOUND_AC97) */
#endif /* defined(NETWORK) && !defined(LWIP) */
#ifdef COLDFIRE
#ifdef MCF547X
	check_sd_card();
#endif
#endif
#ifdef DEBUG
#ifndef COLDFIRE
	if(os_magic)
	{
		Cconws("Debug Magic\r\n");
		/* debug on videl output */
//		debug_traps[1] = install_xbra(33, trace_tos);  /* TRAP #1 */
//		debug_traps[2] = install_xbra(34, trace_tos);  /* TRAP #2 */
//		debug_traps[13] = install_xbra(45, trace_tos); /* TRAP #13 */
//		debug_traps[14] = install_xbra(46, trace_tos); /* TRAP #14 */
	}
#endif
#endif
}

void init_before_autofolder(void) /* after booting, before start AUTO folder */
{
#ifdef NETWORK
	IP_ADDR server;
	char path_server[80], name[80], speed[10];
	char *buf;
	long handle, len, free, cluster_size, size, info[4];
	int i, j, drive;
#endif
#ifndef COLDFIRE
	if(*((unsigned short *)0xE80000) < 0x200) /* check boot version  */
		return;
#endif
	Cconws("\r\n");
#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
#ifdef CONFIG_USB_STORAGE
	if(usb_found)
		usb_stor_scan();
#endif /* CONFIG_USB_STORAGE */
#endif /* CONFIG_USB_UHCI || CONFIG_USB_OHCI || CONFIG_USB_EHCI */	
#ifdef COLDFIRE
#ifdef MCF547X
	install_sd_card();
#endif
#endif
#ifdef NETWORK
#ifdef MCF547X
	if(((swi & 0x80) || (boot_os == 2)) /* SW6 (DOWN) */
	  && ((drive = install_ram_disk()) != 0))
#else /* MCF548X */
	if((drive = install_ram_disk()) != 0)
#endif /* MCF547X */
	{
		Dfree(info, drive + 1);
		cluster_size = info[2] * info[3];
		free = info[0] * cluster_size;
		board_get_filename(path_server);
		i = j = 0;
		while(path_server[i])
		{
			if(path_server[i] == '/' || path_server[i] == '\\')
				j = i+1;
			i++;	
		}
		path_server[j] = 0;
		board_get_server((unsigned char *)server);
		if(init_network() == TRUE)
		{
			write_protect_ram_disk = TRUE;
			Cconws("TFTP load tftp.inf\r\n");
			name[0] = (char)drive + 'A';
			name[1] = ':';
			name[2] = '\\';
			strcpy(&name[3], "tftp.inf");
			if(tftp_load_file(drive, &name[3], path_server, server, free, &size) == TRUE)
			{			
				handle = Fopen(name, 2);
				if(handle >=  0)
				{
					len = Fseek(0, handle, 2);
					if(len > 0)
					{
						Fseek(0, handle, 0);
						buf = (char *)Mxalloc(len, 3);
						if(buf)
						{
							if(Fread(handle, len, buf) >= 0)
							{
								i=0;
#ifdef LWIP
								if((len >= 3) && (buf[0] == 'U') && (buf[1] == 'S') && (buf[2] == 'B'))
								{
									write_protect_ram_disk = FALSE;
									Cconws("Waiting USB link...\r\n");
									if(usb_load_files() == TRUE)
									{
										len  = 0;
										Cconws("Ram-disk loaded from USB\r\n");
									}
									else
									{
										write_protect_ram_disk = TRUE;
										i += 3;
										len -= 3;
									}
								}
#endif
								free -= ((size + cluster_size) & ~cluster_size);
								while(len > 0)
								{
									j=0;
									while(buf[i]!=0 && buf[i]!='\r' && buf[i]!='\n')
									{
										name[j++]=buf[i++];
										len--;
									}
									name[j]=0;
									while(j)
									{
										unsigned long start_hz_200 = *_hz_200;
				  					Cconws("TFTP load ");
								  	Cconws(name);
								  	Cconws(" ... ");	
										if(tftp_load_file(drive, name, path_server, server, free, &size) != TRUE)
										{
											Cconws("\r\n");
											Cconws(tftp_get_error());
											Cconws("\r\n");
											break;
										}
										else
										{
											int i;
											char fname[80];
											unsigned long tps = *_hz_200 - start_hz_200;
											fname[0] = (char)drive+'A'; fname[1] = ':'; fname[2] = '\\';
											if(name[0] == '/' || name[0] == '\\')
												strcpy(&fname[2], name);
											else
												strcpy(&fname[3], name);
											i=3;
											while(fname[i])
											{
												if(fname[i] == '/')
													fname[i]='\\';
												i++;	
											}
											free -= ((size + cluster_size) & ~cluster_size);
											if(size < 0)
												size = 0;
                      size /= tps;
                      size /= 5;
											ltoa(speed, size, 10);
											Cconws(speed);
									  	Cconws("KB/S\r\n");																			
											if((free < 0) && (drive > 2)) /* not enough space and not drive C */
											{
												Cconws("Not enough space on Ram-disk => try again on drive C\r\n");
												drive = 2; /* try again on drive C */
											}
											else
												j = 0;
										}
									}		
									if(buf[i]==0)
										break;
									if(buf[i]=='\r')
									{
										i++;
										len--;
									}
									if(buf[i]=='\n')
									{
										i++;
										len--;
									}
								}
							}
							Mfree(buf);
						}
					}
					Fclose(handle);
				}
			}
			else
			{
				Cconws(tftp_get_error());
				Cconws("\r\n");
			}
			if(Fsfirst("C:\\tftpsend",0x10) != 0)
				(void)Dcreate("C:\\tftpsend");      /* for later */
#ifndef LWIP
#ifdef TEST_NETWORK
			{
				static char sname[80],data[1024],buf[10];
				int i=0,j,ch;
				char *p;
				Cconws("Network test...\r\n");
				strcpy(sname, path_server);
				strcat(sname, "tftpsend\\test.bin");
				minus(sname);
				for(j = 0; j < 10; j++)
				{
					Cconws("Send TOS...\r\n");
					if(tftp_write(&nif[ETHERNET_PORT], sname, server, 0xE00000, 0xEF0000) == TRUE)
					{
						Cconws("Get TOS...\r\n");
					  if(tftp_read(&nif[ETHERNET_PORT], sname, server) == TRUE)
						i = 0;
						p = (char *)0xE00000;
						while((ch = tftp_in_char()) != -1)
						{
							data[i++] = (char)ch;
							if(i >= 1024)
							{
								for(i = 0; i < 1024; i++)
								{
									if(*p++ != data[i])
									{
										Cconws("Error at offset 0x");
										ltoa(buf,(long)p & 0xFFFFF,16);
										Cconws(buf);
										Cconws("\r\n");
									}
								}
								i = 0;
							}
						}
						p = tftp_get_error();
						if(*p)
						{
							Cconws(tftp_get_error());
							Cconws("\r\n");
						}
					}
					else
					{
						Cconws(tftp_get_error());
						Cconws("\r\n");				
					}
				}
				wait_key();
			}
#endif /* TEST_NETWORK */
			end_network();
#endif /* LWIP */
			write_protect_ram_disk = FALSE;
		}
	}
#ifdef MCF547X
	else if(!(swi & 0x80)) /* !SW6 (UP) */
		init_network();
#else
	else
		wait_key();
#endif /* MCF547X */
#endif /* NETWORK */
	drive_ok = 1;
}

#ifdef DBUG
static void init_disassembler(struct DisasmPara_68k *dp, char *opcode, char *operands)
{
	dp->instr = NULL;              /* pointer to instruction to disassemble */
	dp->iaddr = NULL;              /* instr.addr., usually the same as instr */
	dp->opcode = opcode;           /* buffer for opcode, min. 16 chars. */
	dp->operands = operands;       /* operand buffer, min. 128 chars. */
	dp->radix = 16;                /* base 2, 8, 10, 16 ... */
/* call-back functions for symbolic debugger support */
	dp->get_areg = NULL;           /* returns current value of reg. An */
	dp->find_symbol = NULL;        /* finds closest symbol to addr and */
	                               /*  returns (positive) difference and name */
/* changed by disassembler: */
	dp->type = 0;                  /* type of instruction, see below */
	dp->flags = 0;                 /* additional flags */
	dp->reserved = 0;
	dp->areg = 0;                  /* address reg. for displacement (PC=-1) */
	dp->displacement = 0;          /* branch- or d16-displacement */
}
#endif

long dbug(long key)
{
#ifdef DBUG
	static struct DisasmPara_68k dp;
	static char buffer[16];
	m68k_word *p,*ip;
	static char opcode[16];
	static char operands[128];
	static char iwordbuf[32];
	int n,i;
	char *s;
#ifndef COLDFIRE
#ifdef DEBUG
	if((char)key == 'v')
	{
		extern void display_char(char c);
		if(video_found)
			display_char((key >> 16) & 0xFF);
		return(0);
	}
#endif /* DEBUG */
#endif /* !COLDFIRE */
	switch((char)key)
	{
		case '\r':
			if(old_address != (m68k_word *)0xFFFFFFFF)
			{
				p = old_address;
				goto disassemble;
			}
			break;
		case 'd':
			Cconws("\r\nDisassemble memory (hex) ? ");
			p=(m68k_word *)(get_hex_value() & ~1);
disassemble:
			db_radix = 16;
			init_disassembler(&dp, opcode, operands);
			for(i = 0;i < 8; i++)
			{					
				for(n = 0; n < sizeof(opcode)-1; opcode[n++] = ' ');
				opcode[n] = 0;
				for(n = 0; n < sizeof(operands); operands[n++] = 0);
				dp.instr = dp.iaddr = p;
				p = M68k_Disassemble(&dp);
				/* print up to 5 instruction words */
				for(n = 0; n < 26; iwordbuf[n++] = ' ');
			  iwordbuf[26] = 0;
				if((n = (int)(p - dp.instr)) > 5)
					n = 5;
				ip = dp.instr;
				s = iwordbuf;
				while(n--)
				{
					ltoa(buffer,(((unsigned long)*(unsigned char *)ip)<<8) | ((unsigned long)*((unsigned char *)ip+1)) | 0x10000UL,16);
					*s++ = buffer[1];
					*s++ = buffer[2];
					*s++ = buffer[3];
					*s++ = buffer[4];
					s++;
					ip++;
				}
				ltoa(buffer,(unsigned long)dp.iaddr,16);
				Cconout('\r');
				Cconout('\n');
				Cconws(buffer);
				Cconout(':');
				Cconout(' ');
				Cconws(iwordbuf);
				strcpy(buffer, "       ");
				n = 0;
				while(opcode[n])
				{
					buffer[n] = opcode[n];
					n++;
				}
				buffer[n] = 0;
				Cconws(buffer);
				Cconout(' ');
				Cconws(operands);
			}
			old_address = p;
			key = 0;
			break;
		case 'h':
		case '?':
			Cconws("\r\nList of commands:");
			Cconws("\r\n (D)isassemble memory");
			Cconws("\r\n (M)emory dump");
			Cconws("\r\n (P)atch memory");
			key = 0;
			break;
		case 'm':
		case 'p':
			old_address = (m68k_word *)0xFFFFFFFF;
			break;
	}
#endif
	return(key);
}

void event_aes(void)
{
#ifdef COLDFIRE
#ifdef NETWORK
	static int lock = 0;
	static long mem_size = 0;
	static unsigned long old_hz_200 = 0;
	IP_ADDR server;
	_DTA *save_dta;
	_DTA tp_dta;
	static char subdir[] = "C:\\tftpsend\\";
	static char path[80], path_server[80], name[80], buf_alert[256];
	char *p, *p2;
	char c;
	int i, j, ok, nb_files;
	long total_size;
#ifdef MCF547X
	if(!(swi & 0x80))
		return;
#endif
	if((*_hz_200 - old_hz_200) < 200) /* 1 second */
		return;
	if(lock)
		return;
	lock = 1;
	old_hz_200 = *_hz_200;
	nb_files = 0;
	total_size = 0;
	save_dta=Fgetdta();
	Fsetdta(&tp_dta);
	strcpy(path, subdir);
	strcat(path, "*.*");
	if(Fsfirst(path,1) == 0)
	{
		do
		{
			if((tp_dta.dta_name[0] != '.') && tp_dta.dta_size)
			{
				total_size += tp_dta.dta_size;
				nb_files++;
			}
		}
		while(Fsnext() == 0);
	}
	if(nb_files && (total_size == mem_size))
	{
		if(nvm.language == 2)
			i = alert_tos("[1][Envoi des fichiers|au serveur TFTP ?][Oui|Non]");
		else	
			i = alert_tos("[1][Send files to|the TFTP server?][Yes|No]");
		if(i == 1)
		{
			board_get_filename(path_server);
			i = j = 0;
			while(path_server[i])
			{
				if(path_server[i] == '/' || path_server[i] == '\\')
					j = i+1;
				i++;	
			}
			path_server[j] = 0;
			board_get_server((unsigned char *)server);
#ifndef LWIP
			if(init_network())
			{
#endif
				if(Fsfirst(path, 1) == 0)
				{
					ok = TRUE;
					do
					{
						if((tp_dta.dta_name[0] != '.') && tp_dta.dta_size)
						{
							strcpy(name, subdir);
							strcat(name, tp_dta.dta_name);
							if(ok == TRUE)
							{
								ok = tftp_write_file((int)(name[0]-'A'), name+3, path_server, server);
								if(ok != TRUE)
								{
									i = j = 0;
									p = tftp_get_error();
									strcpy(buf_alert, "[3][");
									p2 = &buf_alert[4];
									while(*p && j < 5) /* build alert */
									{
										c = *p2++ = *p++;
										i++;
										if(i >= 20 && c == ' ')
										{
											if(j < 4)
											{
												p2[-1] = '|'; /* separator */
												i = 0;
											}
											j++;            /* next line */
										}
									}
									*p2 = 0;
									if(nvm.language == 2)
										strcat(buf_alert, "][Suivant|Abandon]");
									else
										strcat(buf_alert, "][Next|Cancel]");
									if(alert_tos(buf_alert) == 1)
										ok = TRUE;
								}
							}
						}
					}
					while(Fsnext() == 0);
				}
#ifndef LWIP
				end_network();
			}
			else
			{
				if(nvm.language == 2)
					alert_tos("[3][Ethernet en d‚faut!][Abandon]");
				else	
					alert_tos("[3][Ethernet failure!][Cancel]");			
			}
#endif
		}
		/* if cancel or finished transfer, delete files in the tftp directory */
		if(Fsfirst(path, 1) == 0)
		{
			do
			{
				if((tp_dta.dta_name[0] != '.') && tp_dta.dta_size)
				{
					strcpy(name, subdir);
					strcat(name, tp_dta.dta_name);
					(void)Fattrib(name, 1, 0);
					Fdelete(name);
				}
			}
			while(Fsnext() == 0);
		}
	}
	else if(!nb_files)
		mem_size = 0;
	else
		mem_size = total_size;
	Fsetdta(save_dta);
	lock = 0;
#endif
#endif
}

char *disassemble_pc(unsigned long pc)
{
	static char line[80];
#ifdef DBUG
	static struct DisasmPara_68k dp;
	static char buffer[16];
	m68k_word *ip, *p = (m68k_word *)pc;
	static char opcode[16];
	static char operands[128];
	static char iwordbuf[32];
	int n;
	char *s;
	db_radix = 16;
	init_disassembler(&dp, opcode, operands);
	for(n = 0; n < sizeof(opcode)-1; opcode[n++]=' ');
	opcode[n] = 0;
	for(n = 0; n < sizeof(operands); operands[n++]=0);
	dp.instr = dp.iaddr = p;
	p = M68k_Disassemble(&dp);
	/* print up to 5 instruction words */
	for(n = 0; n<26; iwordbuf[n++]=' ');
	iwordbuf[26] = 0;
	if((n = (int)(p-dp.instr)) > 5)
		n = 5;
	ip = dp.instr;
	s = iwordbuf;
	while(n--)
	{
		ltoa(buffer, (((unsigned long)*(unsigned char *)ip) << 8) | ((unsigned long)*((unsigned char *)ip+1)) | 0x10000UL, 16);
		*s++ = buffer[1];
		*s++ = buffer[2];
		*s++ = buffer[3];
		*s++ = buffer[4];
		s++;
		ip++;
	}
	ltoa(buffer,(unsigned long)dp.iaddr,16);
	strcpy(line, buffer);
	strcat(line, ": ");
	strcat(line, iwordbuf);
	strcpy(buffer, "       ");
	n = 0;
	while(opcode[n])
	{
		buffer[n] = opcode[n];
		n++;
	}
	buffer[n++] = ' ';
	buffer[n] = '\0';
	strcat(line, buffer);
	strcat(line, operands);
#else
	line[0] ='\0';
#endif
	return(line);
}

