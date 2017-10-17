/*
 * (C) Copyright 1997-2002 ELTEC Elektronik AG
 * Frank Gottschling <fgottschling@eltec.de>
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

/*
 * smiLynxEM.h
 * Silicon Motion graphic interface for sm810/sm710/sm712 accelerator
 *
 *
 * modification history
 * --------------------
 * 04-18-2002 - Rewritten for U-Boot <fgottschling@eltec.de>.
 * 16-10-2009 - Rewrited for TOS <aniplay@wanadoo.fr>
 */

#ifndef _VIDEO_FB_H_
#define _VIDEO_FB_H_

#include <mint/osbind.h>
#include <mint/errno.h>
#include <string.h>
#include "pcixbios.h"
#include "mod_devicetable.h"
#include "pci_ids.h"
#include "fb.h"
#include "i2c.h"
#include "i2c-algo-bit.h"

#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

/* Device ID */
#define SMI_LYNX       PCI_DEVICE_ID_SMI_910
#define SMI_LYNXE      PCI_DEVICE_ID_SMI_810
#define SMI_LYNX3D     PCI_DEVICE_ID_SMI_820
#define SMI_LYNXEM     PCI_DEVICE_ID_SMI_710
#define SMI_LYNXEMplus PCI_DEVICE_ID_SMI_712
#define SMI_LYNX3DM    PCI_DEVICE_ID_SMI_720

/* 2D Engine commands */
#define SMI_TRANSPARENT_SRC	0x00000100
#define SMI_TRANSPARENT_DEST	0x00000300

#define SMI_OPAQUE_PXL		0x00000000
#define SMI_TRANSPARENT_PXL	0x00000400

#define SMI_MONO_PACK_8		0x00001000
#define SMI_MONO_PACK_16	0x00002000
#define SMI_MONO_PACK_32	0x00003000

#define SMI_ROP2_SRC		0x00008000
#define SMI_ROP2_PAT		0x0000C000
#define SMI_ROP3		0x00000000

#define SMI_BITBLT		0x00000000
#define SMI_RECT_FILL		0x00010000
#define SMI_TRAPEZOID_FILL	0x00030000
#define SMI_SHORT_STROKE    	0x00060000
#define SMI_BRESENHAM_LINE	0x00070000
#define SMI_HOSTBLT_WRITE	0x00080000
#define SMI_HOSTBLT_READ	0x00090000
#define SMI_ROTATE_BLT		0x000B0000

#define SMI_SRC_COLOR		0x00000000
#define SMI_SRC_MONOCHROME	0x00400000

#define SMI_GRAPHICS_STRETCH	0x00800000

#define SMI_ROTATE_CW		0x01000000
#define SMI_ROTATE_CCW		0x02000000

#define SMI_MAJOR_X		0x00000000
#define SMI_MAJOR_Y		0x04000000

#define SMI_LEFT_TO_RIGHT	0x00000000
#define SMI_RIGHT_TO_LEFT	0x08000000

#define SMI_COLOR_PATTERN	0x40000000
#define SMI_MONO_PATTERN	0x00000000

#define SMI_QUICK_START		0x10000000
#define SMI_START_ENGINE	0x80000000

#define SMI_ALIGN(x,bytes) (((x) + ((bytes) - 1)) & ~((bytes) - 1))

#define CONSOLE_BG_COL            0x00
#define CONSOLE_FG_COL            0xa0

#undef VGA_DDC_CLK_OUTPUT
#undef VGA_DDC_DATA_OUTPUT
#undef VGA_DDC_CLK_INPUT
#undef VGA_DDC_DATA_INPUT
#undef VGA_DDC_CLK_OUT_EN
#undef VGA_DDC_DATA_OUT_EN

/* GPIO bit constants */
#define VGA_DDC_CLK_OUTPUT  (1 <<  0)
#define VGA_DDC_DATA_OUTPUT (1 <<  1)
#define VGA_DDC_CLK_INPUT   (1 <<  2)
#define VGA_DDC_DATA_INPUT  (1 <<  3)
#define VGA_DDC_CLK_OUT_EN  (1 <<  4)
#define VGA_DDC_DATA_OUT_EN (1 <<  5)

/*
 * Graphic Data Format (GDF) bits for VIDEO_DATA_FORMAT
 */
#define GDF__8BIT_INDEX         0
#define GDF_15BIT_555RGB        1
#define GDF_16BIT_565RGB        2
#define GDF_32BIT_X888RGB       3
#define GDF_24BIT_888RGB        4
#define GDF__8BIT_332RGB        5

struct smi_i2c_chan
{
	struct smifb_info		*smiinfo;
	struct i2c_adapter		adapter;
	struct i2c_algo_bit_data	algo;
	unsigned char ddc_reg;
};

struct smifb_info {
	long handle;     /* PCI BIOS, must be 1st place */
	long big_endian; /* PCI BIOS */
	int bpp;
	int depth;
	int chipset;
	int videoout;
	struct fb_info *info;
	struct smi_i2c_chan i2c[2];
	unsigned char *mon1_EDID;
	struct fb_videomode	*mon1_modedb;
	int mon1_dbsize;
	struct fb_videomode	lcd_modedb;
	char name[50];
	unsigned long io_base_phys;
	unsigned long mmio_base_phys;
	unsigned long fb_base_phys;
	unsigned long bios_seg_phys;
	void *io_base;
	void *fb_base;
	void *bios_seg;
	unsigned long fb_offset;
	unsigned long cursor_start;
	unsigned long cursor_end;
	unsigned int dprBase;
	unsigned int vprBase;
	unsigned int cprBase;
	unsigned int memSize;
	unsigned int gdfIndex;
	unsigned int gdfBytesPP;
	unsigned int plnSizeX;
 	unsigned int plnSizeY;
	unsigned int winSizeX;
	unsigned int winSizeY;
  unsigned int lcdWidth;
	unsigned int lcdHeight;
	unsigned char *DataPortBase;	/* Base of data port */
	int DataPortSize;	/* Size of data port */
	/* accel additions */
	unsigned long	AccelCmd;	/* Value for DPR0C */
	unsigned long	ScissorsLeft;	/* Left/top of current scissors */
	unsigned long	ScissorsRight; /* Right/bottom of current scissors */
  int ClipTurnedOn;	/* Clipping was turned on by the previous command */
	int	GEResetCnt;	/* Limit the number of errors printed using a counter */
	int scanline_words;
	unsigned long *scanline_ptr;
};

#ifdef PCI_XBIOS

#define inb(addr)		fast_read_io_byte(smiinfo->handle,addr)
#define inw(addr)		fast_read_io_word(smiinfo->handle,addr)
#define inl(addr)		fast_read_io_longword(smiinfo->handle,addr)
#define outb(addr,val)	write_io_byte(smiinfo->handle,addr,val)
#define outw(addr,val)	write_io_word(smiinfo->handle,addr,val)
#define outl(addr,val)	write_io_longword(smiinfo->handle,addr,val)

#define MMIO_IN8(addr,port)		fast_read_mem_byte(smiinfo->handle,addr+port)
#define MMIO_IN16(addr,port)		fast_read_mem_word(smiinfo->handle,addr+port)
#define MMIO_IN32(addr,port)		fast_read_mem_longword(smiinfo->handle,addr+port)
#define MMIO_OUT8(addr,port,val)	write_mem_byte(smiinfo->handle,addr+port,val)
#define MMIO_OUT16(addr,port,val)	write_mem_word(smiinfo->handle,addr+port,val)
#define MMIO_OUT32(addr,port,val)	write_mem_longword(smiinfo->handle,addr+port,val)

#define BIOSIN8(v)  	(fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v))
#define BIOSIN16(v) 	((unsigned short)fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v) | \
			  ((unsigned short)fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v+1) << 8))
#define BIOSIN32(v) 	((unsigned long)fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v) | \
			  ((unsigned long)fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v+1) << 8) | \
			  ((unsigned long)fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v+2) << 16) | \
			  ((unsigned long)fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v+3) << 24))

#else /* !PCI_XBIOS */

extern long *tab_funcs_pci;

#define inb(addr)		Fast_read_io_byte(smiinfo->handle,addr)
#define inw(addr)		Fast_read_io_word(smiinfo->handle,addr)
#define inl(addr)		Fast_read_io_longword(smiinfo->handle,addr)
#define outb(addr,val)	Write_io_byte(smiinfo->handle,addr,val)
#define outw(addr,val)	Write_io_word(smiinfo->handle,addr,val)
#define outl(addr,val)	Write_io_longword(smiinfo->handle,addr,val)

#define MMIO_IN8(addr,port)		Fast_read_mem_byte(smiinfo->handle,addr+port)
#define MMIO_IN16(addr,port)		Fast_read_mem_word(smiinfo->handle,addr+port)
#define MMIO_IN32(addr,port)		Fast_read_mem_longword(smiinfo->handle,addr+port)
#define MMIO_OUT8(addr,port,val)	Write_mem_byte(smiinfo->handle,addr+port,val)
#define MMIO_OUT16(addr,port,val)	Write_mem_word(smiinfo->handle,addr+port,val)
#define MMIO_OUT32(addr,port,val)	Write_mem_longword(smiinfo->handle,addr+port,val)

#define BIOSIN8(v)  	(Fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v))
#define BIOSIN16(v) 	((unsigned short)Fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v) | \
			  ((unsigned short)Fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v+1) << 8))
#define BIOSIN32(v) 	((unsigned long)Fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v) | \
			  ((unsigned long)Fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v+1) << 8) | \
			  ((unsigned long)Fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v+2) << 16) | \
			  ((unsigned long)Fast_read_mem_byte(smiinfo->handle,smiinfo->bios_seg_phys+v+3) << 24))

#endif /* PCI_XBIOS */

/* ISA mapped regs */
#define VGA_SEQ_INDEX 0x03c4
#define VGA_SEQ_DATA  0x03c5
#define SMI_INDX_D4   0x03d4	   /* index reg */
#define SMI_DATA_D5   0x03d5	   /* data reg */
#define SMI_ISR1      0x03ca
#define SMI_INDX_CE   0x03ce	   /* index reg */
#define SMI_DATA_CF   0x03cf	   /* data reg */
#define SMI_LOCK_REG  0x03c3	   /* unlock/lock ext crt reg */
#define SMI_MISC_REG  0x03c2	   /* misc reg */
#define SMI_LUT_MASK  0x03c6	   /* lut mask reg */
#define SMI_LUT_START 0x03c8	   /* lut start index */
#define SMI_LUT_RGB   0x03c9	   /* lut colors auto incr.*/
#define SMI_INDX_ATTR	0x03c0	   /* attributes index reg */

/* I/O Functions */
unsigned char VGAIN8_INDEX(struct smifb_info *smiinfo, int indexPort, int dataPort, unsigned char index);
void VGAOUT8_INDEX(struct smifb_info *smiinfo, int indexPort, int dataPort, unsigned char index, unsigned char data);
unsigned char VGAIN8(struct smifb_info *smiinfo, int port);
void VGAOUT8(struct smifb_info *smiinfo, int port, unsigned char data);

#define WRITE_DPR(smiinfo, dpr, data) MMIO_OUT32(smiinfo->dprBase, dpr, data)
#define READ_DPR(smiinfo, dpr) MMIO_IN32(smiinfo->dprBase, dpr)
#define WRITE_VPR(smiinfo, vpr, data) MMIO_OUT32(smiinfo->vprBase, vpr, data)
#define READ_VPR(smiinfo, vpr) MMIO_IN32(smiinfo->vprBase, vpr)
#define WRITE_CPR(smiinfo, cpr, data) MMIO_OUT32(smiinfo->cprBase, cpr, data)
#define READ_CPR(smiinfo, cpr) MMIO_IN32(smiinfo->cprBase, cpr)

/* I2C Functions */
extern void lynx_create_i2c_busses(struct smifb_info *smiinfo);
extern void lynx_delete_i2c_busses(struct smifb_info *smiinfo);
extern int lynx_probe_i2c_connector(struct smifb_info *smiinfo, int conn, unsigned char **out_edid);

/* Accel functions */
extern void SMI_WaitIdle(struct smifb_info *smiinfo);
extern void SMI_GEReset(struct fb_info *info, int from_timeout);
extern void SMI_EngineReset(struct fb_info *info);
extern void SMI_SetupForSolidFill(struct fb_info *info, int color, int rop, unsigned int planemask);
extern void SMI_SubsequentSolidFillRect(struct fb_info *info, int x, int y, int w, int h);
extern void SMI_SubsequentSolidHorVertLine(struct fb_info *info, int x, int y, int len, int dir);
extern void SMI_SetupForScreenToScreenCopy(struct fb_info *info, int xdir, int ydir, int rop, unsigned int planemask, int trans_color);
extern void SMI_SubsequentScreenToScreenCopy(struct fb_info *info, int xa, int ya, int xb, int yb, int w, int h);
extern void SMI_ScreenToScreenCopy(struct fb_info *info, int x1, int y1, int x2, int y2, int w, int h, int rop);
extern void SMI_SetupForMono8x8PatternFill(struct fb_info *info, int patternx, int patterny, int fg, int bg, int rop, unsigned int planemask);
extern void SMI_SubsequentMono8x8PatternFillRect(struct fb_info *info, int patternx, int patterny, int x, int y, int w, int h);

extern void SMI_SetupForColor8x8PatternFill(struct fb_info *info, int, int, int, unsigned int, int);
extern void SMI_SubsequentColor8x8PatternFillRect(struct fb_info *info, int, int, int, int, int, int);
extern void SMI_SetupForImageWrite(struct fb_info *info, int, unsigned int, int, int, int);
extern void SMI_SubsequentImageWriteRect(struct fb_info *info, int, int, int, int, int);

extern void SMI_SetupForCPUToScreenColorExpandFill(struct fb_info *info, int fg, int bg, int rop, unsigned int planemask);
extern void SMI_SubsequentCPUToScreenColorExpandFill(struct fb_info *info, int x, int y, int w, int h, int skipleft);
extern void SMI_SubsequentScanline(struct fb_info *info, unsigned long *buf);
extern void SMI_SetClippingRectangle(struct fb_info *info, int xa, int ya, int xb, int yb);
extern void SMI_DisableClipping(struct fb_info *info);

/* Cursor functions */
extern void SMI_SetCursorColors(struct fb_info *info, int bg, int fg);
extern void SMI_SetCursorPosition(struct fb_info *info, int x, int y);
extern void SMI_LoadCursorImage(struct fb_info *info, unsigned short *mask, unsigned short *data, int zoom);
extern void SMI_HideCursor(struct fb_info *info);
extern void SMI_ShowCursor(struct fb_info *info);
extern long SMI_CursorInit(struct fb_info *info);

#define lynx_engine_init(smiinfo) SMI_EngineReset(smiinfo->info)
static inline int lynxfb_sync(struct fb_info *info)
{
	SMI_WaitIdle(info->par);
	return 0;
}
extern int lynxfb_pci_register(long handle, const struct pci_device_id *ent);

extern char monitor_layout[];
extern short ignore_edid;

#endif /*_VIDEO_FB_H_ */
