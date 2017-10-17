/* VDI Videl modes
 * Didier Mequignon 2009-2010, e-mail: aniplay@wanadoo.fr
 * Thanks to MiKRO and his help for HDB / HDE registers !
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
 * along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
 
#include "config.h"
#include <mint/osbind.h>
#include <mint/sysvars.h>
#include <string.h>
#include "fb.h"
#include "edid.h"
#ifdef COLDFIRE
#include "../../include/fire.h"
#endif

#if defined(NETWORK) && defined(LWIP) && defined(DEBUG)
extern void board_printf(const char *fmt, ...);
#endif

#ifndef Screalloc
#define Screalloc(size) (void *)trap_1_wl((short)(0x15),(long)(size))
#endif

#if defined(COLDFIRE) && defined(MCF547X)
#define ACP_MODES_ONLY
#endif

#define MT_DFP 1
#define MT_CRT 0

#define TFP_ADDR 0x7A
#define DCC_ADDR 0xA0
#define TEMPO_US 5
#define TIMEOUT (100000 * SYSTEM_CLOCK) /* 100 mS */
#define TIMEOUT_PLL (1000 * SYSTEM_CLOCK) /* 1 mS */

#define SCREEN_POS_ACP (*(volatile unsigned char *)0xFFFF8200)
#define SCREEN_POS_HIGH (*(volatile unsigned char *)0xFFFF8201)
#define SCREEN_POS_MID (*(volatile unsigned char *)0xFFFF8203)
#define VIDEO_SYNC (*(volatile unsigned char *)0xFFFF820A)
#define SCREEN_POS_LOW (*(volatile unsigned char *)0xFFFF820D)
#define OFF_NEXT_LINE (*(volatile unsigned short *)0xFFFF820E)
#define VWRAP (*(volatile unsigned short *)0xFFFF8210)
#define CLUT ((volatile unsigned short *)0xFFFF8240)
#define SHIFT (*(volatile unsigned char *)0xFFFF8260)
#define SPSHIFT (*(volatile unsigned short *)0xFFFF8266)
#define HHC (*(volatile unsigned short *)0xFFFF8280) // Horizontal Hold Counter
#define HHT (*(volatile unsigned short *)0xFFFF8282) // Horizontal Hold Timer
#define HBB (*(volatile unsigned short *)0xFFFF8284) // Horizontal Border Begin
#define HBE (*(volatile unsigned short *)0xFFFF8286) // Horizontal Border End
#define HDB (*(volatile unsigned short *)0xFFFF8288) // Horizontal Display Begin
#define HDE (*(volatile unsigned short *)0xFFFF828A) // Horizontal Display End
#define HSS (*(volatile unsigned short *)0xFFFF828C) // Horizontal Sync Start
#define HFS (*(volatile unsigned short *)0xFFFF828E)
#define HEE (*(volatile unsigned short *)0xFFFF8290)
#define VFC (*(volatile unsigned short *)0xFFFF82A0) // Vertical Frequency Counter
#define VFT (*(volatile unsigned short *)0xFFFF82A2) // Vertical Frequency Timer
#define VBB (*(volatile unsigned short *)0xFFFF82A4) // Vertical Border Begin
#define VBE (*(volatile unsigned short *)0xFFFF82A6) // VBlankOff / Vertical Border End
#define VDB (*(volatile unsigned short *)0xFFFF82A8) // Vertical Display Begin
#define VDE (*(volatile unsigned short *)0xFFFF82AA) // Vertical Display End
#define VSS (*(volatile unsigned short *)0xFFFF82AC) // Vertical Sync Start
#define VCO (*(volatile unsigned short *)0xFFFF82C0) // Video Control
#define VCTRL (*(volatile unsigned short *)0xFFFF82C2) // Video Mode
#define VCLUT ((volatile unsigned long *)0xFFFF9800)

#define TFP410_CTL1_MODE 0x08
#define TFP410_CTL2_MODE 0x09
#define TFP410_CTL3_MODE 0x0A
#define TFP410_CFG       0x0B
#define TFP410_DE_DLY    0x32
#define TFP410_DE_CTL    0x33
#define TFP410_DE_TOP    0x34
#define TFP410_DE_CNTL   0x36
#define TFP410_DE_CNTH   0x37
#define TFP410_DE_LINL   0x38
#define TFP410_DE_LINH   0x39

#define VESA_MODES 34
extern long total_modedb;
extern struct fb_videomode modedb[];
extern int asm_set_ipl(int level);
extern void udelay(long usec);
extern long get_timer(void);

struct videl_table {
#define FLAGS_ST_MODES 1
#define FLAGS_ACP_MODES 2
	short width, height; 
	unsigned char frq, clk, bpp, flags;
//     nb_h  BK  BK  DE  DE  top  nb_v BK  BK  DE  DE  top   
	short hht, hbb, hbe, hdb, hde, hss, vft, vbb, vbe, vdb, vde, vss, vctrl, vco;
};

/* Videl native VGA modes */
static struct videl_table table_rez[] = {
	{ 320, 200, 60, 25,  4, FLAGS_ST_MODES, 0x017, 0x012, 0x001, 0x20E, 0x00D, 0x011, 0x419, 0x3AF, 0x08F, 0x08F, 0x3AF, 0x415, 5, 0x186 }, // ST-LOW 25 MHz
	{ 640, 200, 60, 25,  2, FLAGS_ST_MODES, 0x017, 0x012, 0x001, 0x20E, 0x00D, 0x011, 0x419, 0x3AF, 0x08F, 0x08F, 0x3AF, 0x415, 9, 0x186 }, // ST-MED 25 MHz
	{ 640, 400, 60, 25,  1, FLAGS_ST_MODES, 0x0C6, 0x08D, 0x015, 0x273, 0x050, 0x096, 0x419, 0x3AF, 0x08F, 0x08F, 0x3AF, 0x415, 8, 0x186 }, // ST-HIG 25 MHz
	{ 640, 240, 60, 25,  1, 0, 0x0C6, 0x08D, 0x015, 0x273, 0x050, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 9, 0x186 }, // 25 MHz
	{ 320, 240, 60, 25,  2, 0, 0x017, 0x012, 0x001, 0x20A, 0x009, 0x011, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 5, 0x186 }, // 25 MHz
	{ 640, 240, 60, 25,  2, 0, 0x017, 0x012, 0x001, 0x20E, 0x00D, 0x011, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 9, 0x186 }, // 25 MHz
	{ 320, 240, 60, 25,  4, 0, 0x0C6, 0x08D, 0x015, 0x28A, 0x06B, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 5, 0x186 }, // 25 MHz
	{ 640, 240, 60, 25,  4, 0, 0x0C6, 0x08D, 0x015, 0x2A3, 0x07C, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 9, 0x186 }, // 25 MHz
	{ 320, 240, 60, 25,  8, 0, 0x0C6, 0x08D, 0x015, 0x29A, 0x07B, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 5, 0x186 }, // 25 MHz
	{ 640, 240, 60, 25,  8, 0, 0x0C6, 0x08D, 0x015, 0x2AB, 0x084, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 9, 0x186 }, // 25 MHz
	{ 320, 240, 60, 25, 16, 0, 0x0C6, 0x08D, 0x015, 0x2AC, 0x091, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 5, 0x186 }, // 25 MHz
	{ 640, 240, 60, 25, 16, 0, 0x0C6, 0x08D, 0x015, 0x2AC, 0x091, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 9, 0x186 }, // 25 MHz
	{ 640, 480, 60, 25,  1, 0, 0x0C6, 0x08D, 0x015, 0x273, 0x050, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 8, 0x186 }, // 25 MHz
	{ 320, 480, 60, 25,  2, 0, 0x017, 0x012, 0x001, 0x20A, 0x009, 0x011, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 4, 0x186 }, // 25 MHz
	{ 640, 480, 60, 25,  2, 0, 0x017, 0x012, 0x001, 0x20E, 0x00D, 0x011, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 8, 0x186 }, // 25 MHz
	{ 320, 480, 60, 25,  4, 0, 0x0C6, 0x08D, 0x015, 0x28A, 0x06B, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 4, 0x186 }, // 25 MHz
	{ 640, 480, 60, 25,  4, 0, 0x0C6, 0x08D, 0x015, 0x2A3, 0x07C, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 8, 0x186 }, // 25 MHz
	{ 320, 480, 60, 25,  8, 0, 0x0C6, 0x08D, 0x015, 0x29A, 0x07B, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 4, 0x186 }, // 25 MHz
	{ 640, 480, 60, 25,  8, 0, 0x0C6, 0x08D, 0x015, 0x2AB, 0x084, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 8, 0x186 }, // 25 MHz
	{ 320, 480, 60, 25, 16, 0, 0x0C6, 0x08D, 0x015, 0x2AC, 0x091, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 4, 0x186 }, // 25 MHz
	{ 640, 480, 60, 25, 16, 0, 0x0C6, 0x08D, 0x015, 0x2AC, 0x091, 0x096, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 8, 0x186 }, // 25 MHz
//	{ 640, 480, 60, 50, 16, 0, 0x189, 0x126, 0x031, 0x000, 0x160, 0x135, 0x419, 0x3FF, 0x03F, 0x03F, 0x3FF, 0x415, 4, 0x182 }, // 50 MHz
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
//	{ 1280, 1024, 60, 137, 16, FLAGS_ACP_MODES, 1800, 1380, 99, 100, 1379, 1500, 1150, 1074, 49, 50, 1073, 1100, 0, 0 }, // 137 MHz
//	{ 1280, 1024, 60, 137, 32, FLAGS_ACP_MODES, 1800, 1380, 99, 100, 1379, 1500, 1150, 1074, 49, 50, 1073, 1100, 0, 0 }  // 137 MHz
#endif
};

#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */

extern int acp_new_hardware(void);
struct fb_videomode *videl_modedb;	/* mode database */
unsigned long videl_modedb_len;		/* mode database length */
int videl_monitor_type;

/*
 * I2Cinit: I2C initilazation as master
 *
 * Parameters: None.
 *
 * Return : None.
 */
void I2Cinit()
{
	unsigned char temp;		 
	*(volatile unsigned char *)MCF_I2C_I2FDR = 0x11; /* set the frequency near 400KHz */ 
	/* start the module */
	*(volatile unsigned char *)MCF_I2C_I2CR = MCF_I2C_I2CR_IEN;
	/* if bit busy set, send a stop condition to slave module */
	if(*(volatile unsigned char *)MCF_I2C_I2SR & MCF_I2C_I2SR_IBB)
	{
		*(volatile unsigned char *)MCF_I2C_I2CR = 0;            /* clear control register */
		*(volatile unsigned char *)MCF_I2C_I2CR = MCF_I2C_I2CR_IEN |	MCF_I2C_I2CR_MSTA; /*  enable module & send a START condition */
		temp = *(volatile unsigned char *)MCF_I2C_I2DR;         /* dummy read */
		*(volatile unsigned char *)MCF_I2C_I2SR = 0;            /* clear status register */
		*(volatile unsigned char *)MCF_I2C_I2CR = 0;            /* clear control register */
		*(volatile unsigned char *)MCF_I2C_I2CR = MCF_I2C_I2CR_IEN;	/* enable the module again */
	}
}

/*
 * I2CreceiveByte: I2C read byte
 *
 * Parameters: address: address to read
 *			   id: I2C device to read
 *
 * Return : data: byte read it from device
 */
unsigned char I2CreceiveByte(unsigned char address, unsigned char id)
{
  unsigned long timeout;
	unsigned char data;
	*(volatile unsigned char *)MCF_I2C_I2CR |= MCF_I2C_I2CR_MTX;			/* setting in Tx mode */
	/* send start condition */
	*(volatile unsigned char *)MCF_I2C_I2CR |= MCF_I2C_I2CR_MSTA;
	*(volatile unsigned char *)MCF_I2C_I2DR = id;                     /* device ID to write */
	/* wait until one byte transfer completion */
	timeout = get_timer();
	while(!(*(volatile unsigned char *)MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(get_timer()-timeout >= TIMEOUT)
    {
      board_printf("Timeout I2CreceiveByte (1)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	*(volatile unsigned char *)MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;
	/* Wait for a bit */
	udelay(TEMPO_US);
	*(volatile unsigned char *)MCF_I2C_I2DR = address;					       /* memory address */
	/* wait until one byte transfer completion */
	timeout = get_timer();
	while(!(*(volatile unsigned char *)MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(get_timer()-timeout >= TIMEOUT)
    {
      board_printf("Timeout I2CreceiveByte (2)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	*(volatile unsigned char *)MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;	 	
	*(volatile unsigned char *)MCF_I2C_I2CR |= MCF_I2C_I2CR_RSTA;			/* resend start */
	*(volatile unsigned char *)MCF_I2C_I2DR = id | 0x01;      /* device id to read */
	/* wait until one byte transfer completion */
	timeout = get_timer();
	while(!(*(volatile unsigned char *)MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(get_timer()-timeout >= TIMEOUT)
    {
      board_printf("Timeout I2CreceiveByte (3)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	*(volatile unsigned char *)MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;
	*(volatile unsigned char *)MCF_I2C_I2CR &= ~MCF_I2C_I2CR_MTX;			/* setting in Rx mode */
	*(volatile unsigned char *)MCF_I2C_I2CR |= MCF_I2C_I2CR_TXAK;			/* send NO ACK */
	/* Wait for a bit */
	udelay(TEMPO_US);
	data = *(volatile unsigned char *)MCF_I2C_I2DR;						/* dummy read */
	/* wait until one byte transfer completion */
	timeout = get_timer();
	while(!(*(volatile unsigned char *)MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(get_timer()-timeout >= TIMEOUT)
    {
      board_printf("Timeout I2CreceiveByte (4)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	*(volatile unsigned char *)MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;
	/* Wait for a bit */
	udelay(TEMPO_US);
	data = *(volatile unsigned char *)MCF_I2C_I2DR;						/* read data received */
	/* wait until one byte transfer completion */
	timeout = get_timer();
	while(!(*(volatile unsigned char *)MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(get_timer()-timeout >= TIMEOUT)
    {
      board_printf("Timeout I2CreceiveByte (5)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	*(volatile unsigned char *)MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;
	/* generates stop condition */
	*(volatile unsigned char *)MCF_I2C_I2CR &= ~MCF_I2C_I2CR_MSTA;
	/* Wait for a bit */
	udelay(TEMPO_US);
	/* send the received data */
	return data;
}

/*
 * I2CsendByte: send byte to I2C device
 *
 * Parameters: data: byte to write
 *			   address: address to write
 *			   id: I2C device to write
 *
 * Return : None.
 */
void I2CsendByte(unsigned char data, unsigned char address, unsigned char id)
{
  unsigned long timeout;
	*(volatile unsigned char *)MCF_I2C_I2CR |= MCF_I2C_I2CR_MTX;			/* setting in Tx mode */
	/* generates start condition */
	*(volatile unsigned char *)MCF_I2C_I2CR |= MCF_I2C_I2CR_MSTA;
	*(volatile unsigned char *)MCF_I2C_I2DR = id;                    /* set device ID to write */
	/* wait until one byte transfer completion */
	while(!(*(volatile unsigned char *)MCF_I2C_I2SR & MCF_I2C_I2SR_IIF));
	/* clear the completion transfer flag */
	*(volatile unsigned char *)MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;
	/* Wait for a bit */
	udelay(TEMPO_US);
	*(volatile unsigned char *)MCF_I2C_I2DR = address;				/* memory address */
	/* wait until one byte transfer completion */
	timeout = get_timer();
	while(!(*(volatile unsigned char *)MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(get_timer()-timeout >= TIMEOUT)
    {
      board_printf("Timeout I2CsendByte (1)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	*(volatile unsigned char *)MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;	
	/* Wait for a bit */
	udelay(TEMPO_US);
	*(volatile unsigned char *)MCF_I2C_I2DR = data;						/* memory data */
	/* wait until one byte transfer completion */
	timeout = get_timer();
	while(!(*(volatile unsigned char *)MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(get_timer()-timeout >= TIMEOUT)
    {
      board_printf("Timeout I2CsendByte (2)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	*(volatile unsigned char *)MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;	
	/* generates stop condition */
	*(volatile unsigned char *)MCF_I2C_I2CR &= ~MCF_I2C_I2CR_MSTA;
	/* Wait for a bit */
	udelay(TEMPO_US);
	return;
}


static struct fb_videomode *find_mode(long width, long height, long clock, long refresh)
{
	int i, j, k, start, nb;
	struct fb_videomode *db, *best_db = NULL;
	long diff = 9999;
	if(!clock) /* has pll */
	{
		if(videl_modedb_len)
		{
			nb = (int)videl_modedb_len;
			db = videl_modedb;			
			start = 0;
		}
		else
		{
			nb = VESA_MODES;
			db = (struct fb_videomode *)vesa_modes;
			start = 1;
		}
		for(j = start; j < 3; j++)
		{
			for(k = 0; k < nb; k++, db++)
			{
				if(((long)db->xres != width) || ((long)db->yres != height))
					continue;
				if(db->vmode & (FB_VMODE_DOUBLE | FB_VMODE_INTERLACED))
				 	continue; 
				if((long)db->refresh == refresh)
					return(db);
				else
				{
					long abs = (long)db->refresh - refresh;
					if(abs < 0)
						abs = -abs;
					if(diff > abs)
					{
						diff = abs;
						best_db = db;
					}
				}
			}
			if(!j)
			{
				nb = VESA_MODES;
				db = (struct fb_videomode *)vesa_modes;
			}
			else
			{
				nb = (int)total_modedb;
				db = modedb;		
			}
		}
	}
	else /* old hardware: fixed clocks */
	{
		for(i = 0; i < 2; i++)
		{
			if(videl_modedb_len)
			{
				nb = (int)videl_modedb_len;
				db = videl_modedb;			
				start = 0;
			}
			else
			{
				nb = VESA_MODES;
				db = (struct fb_videomode *)vesa_modes;
				start = 1;
			}
			for(j = start; j < 3; j++)
			{
				for(k = 0; k < nb; k++, db++)
				{
					if(((long)db->xres != width) || ((long)db->yres != height))
						continue;
					if(db->vmode & (FB_VMODE_DOUBLE | FB_VMODE_INTERLACED))
					 	continue;
#if defined(NETWORK) && defined(LWIP) && defined(DEBUG)
//					board_printf(" %dx%d@%d %dMHz i:%d j:%d k:%d\r\n", db->xres, db->yres, db->refresh, (int)(PICOS2KHZ(db->pixclock)/1000), i, j, k);
#endif			
					if(i) // second loop
					{
						long abs = (long)(PICOS2KHZ(db->pixclock)/1000) - clock;
						if(abs < 0)
							abs = -abs;
						if(refresh == -1) /* ignore refresh */
						{
							if(abs > 5)
								continue;
						}
						else
						{
							if(abs > 2)
								continue;
						}
					}
					else if((PICOS2KHZ(db->pixclock)/1000) != clock)
						continue;
					if(refresh == -1)
						return(db);
					if((long)db->refresh == refresh)
						return(db);
					else
					{
						long abs = (long)db->refresh - refresh;
						if(abs < 0)
							abs = -abs;
						if(diff > abs)
						{
							diff = abs;
							best_db = db;
						}
#if defined(NETWORK) && defined(LWIP) && defined(DEBUG)
//						board_printf(" ref:%d abs:%d diff:%d best:%08X j:%d k:%d\r\n",  db->refresh, abs, diff, best_db, j, k);
#endif			
					}							
				}
				if(!j)
				{
					nb = VESA_MODES;
					db = (struct fb_videomode *)vesa_modes;
				}
				else
				{
					nb = (int)total_modedb;
					db = modedb;		
				}
			}
		}
	}
	if(best_db == NULL)
		return(NULL);
#if defined(NETWORK) && defined(LWIP) && defined(DEBUG)
//	board_printf(" best:%08X\r\n",  best_db);
#endif			
	return(best_db);
}

static void wait_pll()
{
	unsigned long timeout = get_timer();
	while((*(volatile short *)ACP_VIDEO_PLL_RECONFIG) < 0) /* busy */
  {
    if(get_timer()-timeout >= TIMEOUT_PLL)
			break;
	}
}

#endif /* defined(COLDFIRE) && defined(MCF547X) */

void setrgb_videl(long index, long rgb, long type)
{
	index &= 255;
#if defined(COLDFIRE) && defined(MCF547X)
	switch(type)
	{
		case 0: /* ST palette */
			CLUT[index] = (unsigned short)(((rgb >> 13) & 0x700) + ((rgb >> 9) & 0x70) + ((rgb >> 5) & 0x7));
			break;
		case 1: /* FALCON palette */
			VCLUT[index] = (unsigned long)(((rgb << 8) & 0xFFFF0000) + (rgb & 0xFF));
			break;
#if defined(COLDFIRE) && defined(MCF547X)
		case 2: /* FIREBEE palette */
			{
				volatile unsigned long *clut = (volatile unsigned long *)ACP_VIDEO_CLUT;
				clut[index] = (unsigned long)rgb;
			}
			break;
#endif
		}
#else
	if(type);
	if(rgb);
#endif	
}

#if defined(COLDFIRE) && defined(MCF547X)

#ifndef ACP_MODES_ONLY

static void calcul_videl_mode(struct videl_table *new_rez, struct fb_videomode *db, unsigned long htotal, unsigned long vtotal, long width, long bpp)
{
	long hdb_offset = 0, hde_offset = 0, cycles_par_pixel = 1, divider = 2;
 if(width < 640)
  	cycles_par_pixel = 2;
	/*
	         |  video base clock       |
	HHT = int|--------------------- - 2|
	         |Hz freq * divider * 2    |
	*/
	new_rez->hht = (short)(htotal / ((long)divider * 2)) - 2;
	/*
	                   |hsync impulse dur in us * video base clock|
	HSS = HHT + 1 - int|------------------------------------------|
	                   |                   divider                |
	*/
	new_rez->hss = new_rez->hht - (short)((long)db->hsync_len / divider)	- 1;
	/*
	                   |right border dur in us * video base clock|
	HBB = HHT + 1 - int|-----------------------------------------|
	                   |                  divider                |
	*/
	new_rez->hbb = new_rez->hss - (short)((long)db->right_margin / divider) - 1;
	/*
	         |left border dur in us * video base clock|
	HBE = int|----------------------------------------|
	         |                 divider                |
	*/
	new_rez->hbe = (short)((long)db->left_margin / divider) - 1;
	/*
	       hdb-off                            hde-off
	------+-------+-------------*------------+-------+-------
	      hbe=hdb  ...active display area... hde     hbb

	                 |     |8 words*16 pixels         |               |
	                 |64 + |----------------- + 16 + 2| * Cycles/pixel|
	                 |     |  No. of planes           |               |
	HDB offset = int |------------------------------------------------| + 1
	in F030 BP mode  |                     divider                    |

	                 |      |8 words*16 pixels    |               |
	                 |128 + |----------------- + 2| * Cycles/pixel|
	                 |      |  No. of planes      |               |
	HDB offset = int |--------------------------------------------| + 1
	in STE BP mode   |                 divider                    |

	                 |64 + 16 pixels * Cycles/pixel|
	HDB offset = int |-----------------------------| + 1
	in TC mode       |            divider          |
	*/
	if(bpp <= 8)
		hdb_offset = ((64 + (((8 * 16) / bpp) + 16 + 2) * cycles_par_pixel) / divider) + 1;
	else
		hdb_offset = ((64 + 16 * cycles_par_pixel) / divider) + 1;
	/*
	HDB = HBE - HDB offset; if you get negative value:
	HDB = HBE - HDB offset + HHT+2 and set bit 9 of HDB register
	*/
	new_rez->hdb = (short)((long)new_rez->hbe - hdb_offset);
	if(new_rez->hdb < 0)
		new_rez->hdb = (short)((long)new_rez->hbe - hdb_offset + (long)new_rez->hht + 2 + 0x200);
	/*
	                     ||8 words*16 pixels    |               |
	                     ||----------------- + 2| * Cycles/pixel|
	                     ||  No. of planes      |               |
	HDE offset = int     |--------------------------------------|
	in F030/STE BP mode  |               divider                |

	HDE offset = 0 in TC mode
	*/
	if(bpp <= 8)
		hde_offset = ((((8 * 16) / bpp) + 2) * cycles_par_pixel) / divider;
	else
		hde_offset = 0;
	/* HDE = HBB - HDE offset */
	new_rez->hde = (short)((long)new_rez->hbb + hde_offset);
	/* calcul vertical registers */
	new_rez->vft = (short)(vtotal << 1) | 1;
	new_rez->vbb = (short)((db->upper_margin + db->yres) << 1) | 1;
	new_rez->vbe = (short)(db->upper_margin << 1) | 1;
	new_rez->vdb = new_rez->vbe;
	new_rez->vde = new_rez->vbb;
	new_rez->vss = (short)((vtotal - db->lower_margin) << 1) | 1;
	if(cycles_par_pixel == 2)
		new_rez->vctrl = 4;			  
	else
		new_rez->vctrl = 8;
	if(db->vmode & FB_VMODE_DOUBLE)
		new_rez->vctrl |= 1; 
	if(db->vmode & FB_VMODE_INTERLACED)
	{
		new_rez->vft &= ~1;
		new_rez->vdb &= ~1;				
		new_rez->vde &= ~1;
		new_rez->vctrl |= 2;
	}
}

#endif /* ACP_MODES_ONLY */

static void calcul_acp_mode(struct videl_table *new_rez, struct fb_videomode *db, unsigned long htotal, unsigned long vtotal)
{
	/* calcul horizontal registers */
	new_rez->hht = (short)htotal;
	new_rez->hde = (short)(db->left_margin + db->xres);
	new_rez->hbe = (short)db->left_margin;
	new_rez->hdb = new_rez->hbe;
	new_rez->hbb = new_rez->hde;
	new_rez->hbe -= 1;
	new_rez->hde -= 1;					
	new_rez->hss = (short)(htotal - db->hsync_len);
	/* calcul vertical registers */
	new_rez->vft = (short)vtotal;
	new_rez->vde = (short)(db->upper_margin + db->yres);
	new_rez->vbe = (short)db->upper_margin;
	new_rez->vdb = new_rez->vbe;
	new_rez->vbb = new_rez->vde;
	new_rez->vbe -= 1;
	new_rez->vde -= 1;
	new_rez->vss = (short)(vtotal - db->vsync_len);
#if 0
#if 0
	I2CsendByte((unsigned char)db->left_margin, TFP410_DE_DLY, TFP_ADDR);
	I2CsendByte((unsigned char)db->upper_margin, TFP410_DE_TOP, TFP_ADDR);
	I2CsendByte((unsigned char)db->xres, TFP410_DE_CNTL, TFP_ADDR);
	I2CsendByte((unsigned char)(db->xres>>8), TFP410_DE_CNTH, TFP_ADDR);
	I2CsendByte((unsigned char)db->yres, TFP410_DE_LINL, TFP_ADDR);
	I2CsendByte((unsigned char)(db->yres>>8), TFP410_DE_LINH, TFP_ADDR);
	data = (unsigned char)(0x40 + ((db->left_margin >> 8) & 1)); /* de_gen */
#else
	data = 0;
#endif
	if(db->sync & FB_SYNC_HOR_HIGH_ACT)
		data |= 0x10; /* hs_pol */
	else
		data &= ~0x10; /* hs_pol */
	if(db->sync & FB_SYNC_VERT_HIGH_ACT)
		data |= 0x20; /* vs_pol */
	else
		data &= ~0x20; /* vs_pol */
	I2CsendByte(data, TFP410_DE_CTL, TFP_ADDR);
#endif
	new_rez->vctrl = 0;
}

#endif /* defined(COLDFIRE) && defined(MCF547X) */

long get_videl_base(void) /* return 0 for an ACP mode */
{
	long ret = 0;
#if !defined(COLDFIRE) || defined(MCF547X)
#if defined(COLDFIRE) && defined(MCF547X)
	ret = (unsigned long)SCREEN_POS_ACP;
	ret <<= 8;
#endif
	ret |= (unsigned long)SCREEN_POS_HIGH;
	ret <<= 8;
	ret |= (unsigned long)SCREEN_POS_MID;
	ret <<= 8;
	ret |= (unsigned long)SCREEN_POS_LOW;
#if defined(COLDFIRE) && defined(MCF547X)
	if(*(volatile unsigned long *)ACP_VIDEO_CONTROL & (ACP_COLOR_8 | ACP_COLOR_16 | ACP_COLOR_24 | ACP_VIDEO_ON))
		ret = 0;
  if(!(*(volatile unsigned long *)ACP_VIDEO_CONTROL & (ACP_ST_SHIFT_MODE | ACP_FALCON_SHIFT)))
		ret = 0;
#endif
  if(ret >= 0xE00000)
  	ret = 0;
#endif
	return(ret);
}

long get_videl_bpp(void)
{
	unsigned long bpp = 1;
#if !defined(COLDFIRE) || defined(MCF547X)
	unsigned short spshift = SPSHIFT;
	if(spshift & 0x400)
		bpp = 1;
	else if(spshift & 0x10)
		bpp = 8;
	else if(spshift & 0x100)
		bpp = 16;
	else
	{
		switch(SHIFT)
		{
			case 0: bpp = 4; break;
			case 1: bpp = 2; break;
			default: bpp = 1; break;
		}
	}
#endif
	return(bpp);
}

long get_videl_width()
{
#if !defined(COLDFIRE) || defined(MCF547X)
  return(((long)VWRAP * 16)/ get_videl_bpp());
#else
	return(0);
#endif
}

long get_videl_height(void)
{
#if !defined(COLDFIRE) || defined(MCF547X)
	return((long)(VDE - VDB) / 2);
#else
	return(0);
#endif
}

long get_videl_size(void)
{
#if !defined(COLDFIRE) || defined(MCF547X)
	return(get_videl_height() * (long)VWRAP * 2);
#else
	return(0);
#endif
}

void *get_videl_palette(void)
{
#if !defined(COLDFIRE) || defined(MCF547X)
	long bpp = get_videl_bpp();
	switch(bpp)
	{
		case 1:
		case 2:
		case 4: return((void *)CLUT);
		case 8: return((void *)VCLUT); /* to fix acp palette */
		default: return(NULL);
	}
#else
	return(NULL);
#endif
}

void videl_blank(long blank)
{
#if defined(COLDFIRE) && defined(MCF547X)
	if(blank)
		*(volatile unsigned long *)ACP_VIDEO_CONTROL &= ~ACP_VIDEO_DAC_ON;
	else
		*(volatile unsigned long *)ACP_VIDEO_CONTROL |= ACP_VIDEO_DAC_ON;
#else
	if(blank);
#endif
}

void init_videl_i2c(void)
{
#if defined(COLDFIRE) && defined(MCF547X)
#ifdef CONFIG_FB_MODE_HELPERS
	static unsigned char edid[EDID_LENGTH];
	static struct fb_monspecs specs;
#endif /* CONFIG_FB_MODE_HELPERS */
	unsigned char data;
	int x;
 	I2Cinit();
	I2CsendByte(0xBF, TFP410_CTL1_MODE, TFP_ADDR); /* ctl1: power on, T:M:D:S: enable */
 	if((data = I2CreceiveByte(TFP410_CTL1_MODE, TFP_ADDR)) != 0xBF)
 	{
#if defined(NETWORK) && defined(LWIP) && defined(DEBUG)
		board_printf("init_videl TFP410 failure ctl1 write 0xBF => read 0x%02X\r\n", data);
	}
	else
	{
		board_printf("init_videl TFP410 OK\r\n");
#endif /* defined(NETWORK) && defined(LWIP) && defined(DEBUG) */
	}
#ifdef CONFIG_FB_MODE_HELPERS
	if(I2CreceiveByte(8, DCC_ADDR) || I2CreceiveByte(9, DCC_ADDR)) /* Manufactor ID */
	{
		for(x = 0; x < EDID_LENGTH; edid[x] = I2CreceiveByte(x, DCC_ADDR), x++);
		fb_edid_to_monspecs(edid, &specs);
		videl_modedb = specs.modedb;
		videl_modedb_len = specs.modedb_len;
		if(edid[0x14] & 0x80)
			videl_monitor_type = MT_DFP;
		else
			videl_monitor_type = MT_CRT;
	}
#if defined(NETWORK) && defined(LWIP) && defined(DEBUG)
	else
		board_printf("init_videl EDID read failure\r\n");
#endif
#endif /* CONFIG_FB_MODE_HELPERS */
#endif /* defined(COLDFIRE) && defined(MCF547X) */
}

long init_videl(long width, long height, long bpp, long refresh, long extended)
{
#if defined(COLDFIRE) && defined(MCF547X)
	static struct acp_table {
		unsigned long clk;
		long clock;
	} video_control[] = {
		{ ACP_CLK25, 25 },
		{ ACP_CLK33, 33 },
		{ ACP_CLK48, 48 },
		{ ACP_CLK55, 55 },
		{ ACP_CLK60, 60 },
		{ ACP_CLK69, 69 },
		{ ACP_CLK75, 75 },
		{ ACP_CLK83, 83 },
		{ ACP_CLK92, 92 },
		{ ACP_CLK100, 100 },
		{ ACP_CLK109, 109 },
		{ ACP_CLK120, 120 },
		{ ACP_CLK137, 137 },
		{ ACP_CLK150, 150 },
		{ ACP_CLK166, 166 }
	};
	struct fb_videomode *db = NULL;
	int level;
	unsigned long acp_video_control = ACP_FIFO_ON | ACP_REFRESH_ON | ACP_VCS | ACP_VCKE | ACP_VIDEO_DAC_ON | ACP_VIDEO_ON;
	struct videl_table new_rez;
	int acp_has_pll = 0;
#endif /* defined(COLDFIRE) && defined(MCF547X) */
	long addr = 0;
	int x, st_mode = 0, falcon_mode = 0, acp_mode =0;
	unsigned short vwrap;
	struct videl_table *videl_rez = NULL;
	if(!width || !height || !bpp || !refresh)
		return(0);		
#if defined(COLDFIRE) && defined(MCF547X)
	if(extended >= 0xD00000)
	{
		addr = extended;
		extended = 0;
	}		
//	init_videl_i2c();
#else
	if((width > 640) || (height > 480) || (bpp > 16))
		return(0);
#endif
#if defined(NETWORK) && defined(LWIP) && defined(DEBUG)
#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */
	board_printf("init_videl search in videl list %dx%dx%d@%dHz on %s\r\n", (int)width, (int)height, (int)bpp, (int)refresh, (videl_monitor_type == MT_DFP) ? "DFP" : "CRT");
#else
	board_printf("init_videl search in videl list %dx%dx%d@%dHz\r\n", (int)width, (int)height, (int)bpp, (int)refresh);
#endif
#endif
#if defined(COLDFIRE) && defined(MCF547X)
	if(acp_new_hardware())
		acp_has_pll = 1;
#if defined(NETWORK) && defined(LWIP) && defined(DEBUG)
	 board_printf("init_videl PLL%s detected\r\n", acp_has_pll ? "" : " not");
#endif
	if(!extended)
#endif /* defined(COLDFIRE) && defined(MCF547X) */
	for(x = 0; x < (sizeof(table_rez) / sizeof(struct videl_table)); x++)
	{
		if(((long)table_rez[x].width == width) && ((long)table_rez[x].height == height) && ((long)table_rez[x].bpp == bpp))
		{
			st_mode = (int)table_rez[x].flags & FLAGS_ST_MODES;
			acp_mode = (int)table_rez[x].flags & FLAGS_ACP_MODES;
#if defined(COLDFIRE) && defined(MCF547X)
			switch(table_rez[x].clk)
			{
				case 25: acp_video_control |= ACP_CLK25; break;
				case 32: acp_video_control |= ACP_CLK33; break;
				default:
					if(acp_has_pll)
					{
						acp_video_control |= ACP_CLK_PLL;
						break;
					}
					else /* old hardware */
					{
						int i;
						unsigned long clock = (unsigned long)table_rez[x].clk;
						for(i = 0; i < (sizeof(video_control) / sizeof(struct acp_table)); i++)
						{
							if(clock == (unsigned long)video_control[i].clock)
							{
								acp_video_control |= video_control[i].clk;
								break;
							}
						}
						if(i >=  (sizeof(video_control) / sizeof(struct acp_table)))
							return(0);
					}
					break;
			}
#endif /* defined(COLDFIRE) && defined(MCF547X) */
			videl_rez = &table_rez[x];
			falcon_mode = 1;
			break;		
		}		
	}
	if(videl_rez == NULL)
	{
#if defined(COLDFIRE) && defined(MCF547X)
		if(acp_has_pll)
		{
			if((db = find_mode(width, height, 0, refresh)) != NULL)
			{
				long clock = PICOS2KHZ(db->pixclock)/1000;
#if defined(NETWORK) && defined(LWIP) && defined(DEBUG)
				board_printf("init_videl found in modedb list %dx%dx%d with clock %dMHz\r\n", (int)width, (int)height, (int)bpp, (int)clock);
#endif
				unsigned long hfreq, vfreq, htotal, vtotal, pixclock;
				pixclock = PICOS2KHZ(db->pixclock) * 1000; /* Hz */
				htotal = db->xres + db->right_margin + db->hsync_len + db->left_margin;
				vtotal = db->yres + db->lower_margin + db->vsync_len + db->upper_margin;
				if(db->vmode & FB_VMODE_INTERLACED)
					vtotal >>= 1;
				if(db->vmode & FB_VMODE_DOUBLE)
					vtotal <<= 1;
				hfreq = pixclock/htotal;
				vfreq = hfreq/vtotal;
				/* calcul horizontal registers */
				new_rez.width = (short)width;
				new_rez.height = (short)height;
				new_rez.frq = (char)vfreq;
				new_rez.clk = (char)(pixclock / 1000000);
				new_rez.flags = 0;
#ifndef ACP_MODES_ONLY
				if(clock > 25)
				{
#else
					if(clock);
#endif
					calcul_acp_mode(&new_rez, db, htotal, vtotal);
					acp_mode = 1;				
#ifndef ACP_MODES_ONLY
				}				
				else /* Videl 25 MHz */
					calcul_videl_mode(&new_rez, db, htotal, vtotal, width, bpp);
#endif /* ACP_MODES_ONLY */
				new_rez.vco = 0x182;
#if !(defined(COLDFIRE) && defined(MCF547X)) /* not works, no signal on monitor */
				if(db->sync & FB_SYNC_HOR_HIGH_ACT)
					new_rez.vco |= 0x40;
#endif
				if(db->sync & FB_SYNC_VERT_HIGH_ACT)
					new_rez.vco |= 0x20;
#if 0 // #if defined(COLDFIRE) && defined(MCF547X) /* sync inverted for DVI outputs ??? */
				if(videl_monitor_type == MT_DFP)
					new_rez.vco ^= 0x60;
#endif
				acp_video_control |= (ACP_CLK_PLL | ACP_SYNC);
#if 0
				wait_pll();
				*(volatile unsigned short *)(ACP_VIDEO_PLL_CONFIG+0x48) = 27; // loopfilter r
				wait_pll();
				*(volatile unsigned short *)(ACP_VIDEO_PLL_CONFIG+0x08) = 1; // charge pump I
				wait_pll();
				*(volatile unsigned short *)(ACP_VIDEO_PLL_CONFIG+0x00) = 12; // N counter high
				wait_pll();
				*(volatile unsigned short *)(ACP_VIDEO_PLL_CONFIG+0x40) = 12; // N counter low
				wait_pll();
				*(volatile unsigned short *)(ACP_VIDEO_PLL_CONFIG+0x114) = 1; // ck1 bypass
				wait_pll();
				*(volatile unsigned short *)(ACP_VIDEO_PLL_CONFIG+0x118) = 1; // ck2 bypass
				wait_pll();
				*(volatile unsigned short *)(ACP_VIDEO_PLL_CONFIG+0x11C) = 1; // ck3 bypass
				wait_pll();
				*(volatile unsigned short *)(ACP_VIDEO_PLL_CONFIG+0x10) = 1; // ck0 high
				wait_pll();
				*(volatile unsigned short *)(ACP_VIDEO_PLL_CONFIG+0x50) = 1;	// ck0 low
				wait_pll();
				*(volatile unsigned short *)(ACP_VIDEO_PLL_CONFIG+0x144) = 1; // M odd division
				wait_pll();
				*(volatile unsigned short *)(ACP_VIDEO_PLL_CONFIG+0x44) = 1; // M low
#endif
				wait_pll();
				*(volatile unsigned short *)ACP_VIDEO_PLL_CLK = (unsigned short)(clock - 1);
				wait_pll();
				*(volatile unsigned char *)ACP_VIDEO_PLL_RECONFIG = 0;
				videl_rez = &new_rez;
			}
		}
		else /* old hardware - list of clocks */
		{
			int loop;
			for(loop = 0; loop < 2; loop++)
			{
				for(x = 0; x < (sizeof(video_control) / sizeof(struct acp_table)); x++)
				{
					long clock = video_control[x].clock;
#if defined(NETWORK) && defined(LWIP) && defined(DEBUG)
					if(loop)
						board_printf("init_videl search in modedb list %dx%dx%d with clock %dMHz +/- 5MHz\r\n", (int)width, (int)height, (int)bpp, (int)clock);
					else
						board_printf("init_videl search in modedb list %dx%dx%d@%dHz with clock %dMHz +/- 2MHz\r\n", (int)width, (int)height, (int)bpp, loop ? -1 : (int)refresh, (int)clock);
#endif
					if((db = find_mode(width, height, clock, loop ? -1 : refresh)) != NULL)
					{
						unsigned long hfreq, vfreq, htotal, vtotal, pixclock;
						pixclock = PICOS2KHZ(db->pixclock) * 1000; /* Hz */
						htotal = db->xres + db->right_margin + db->hsync_len + db->left_margin;
						vtotal = db->yres + db->lower_margin + db->vsync_len + db->upper_margin;
						if(db->vmode & FB_VMODE_INTERLACED)
							vtotal >>= 1;
						if(db->vmode & FB_VMODE_DOUBLE)
							vtotal <<= 1;
						hfreq = pixclock/htotal;
						vfreq = hfreq/vtotal;
						/* calcul horizontal registers */
						new_rez.width = (short)width;
						new_rez.height = (short)height;
						new_rez.frq = (char)vfreq;
						new_rez.clk = (char)(pixclock / 1000000);
						new_rez.flags = 0;
#ifndef ACP_MODES_ONLY
						if(clock > 25)
						{
#else
							if(clock);
#endif
							calcul_acp_mode(&new_rez, db, htotal, vtotal);
							acp_mode = 1;				
#ifndef ACP_MODES_ONLY
						}				
						else /* Videl 25 MHz */
							calcul_videl_mode(&new_rez, db, htotal, vtotal, width, bpp);
#endif /* ACP_MODES_ONLY */
						new_rez.vco = 0x182;
						if(db->sync & FB_SYNC_HOR_HIGH_ACT)
							new_rez.vco |= 0x40;
						if(db->sync & FB_SYNC_VERT_HIGH_ACT)
							new_rez.vco |= 0x20;
						acp_video_control |= video_control[x].clk;
						videl_rez = &new_rez;
						break;
					}
				}
				if(videl_rez != NULL)
					break;
			}
		}
		if(videl_rez == NULL)
#endif /* ACP_MODES_ONLY */
		return(0);
	}
	if(bpp <= 8)
	{
		/*
		                             8 Words * 16 Pixels
		Horizontal pixel multiple =  -------------------
		                                No. of planes	
		*/
		if((width % ((8 * 16) / bpp)) != 0)
			return(0);
	}
	switch(bpp)
	{
		case 1: vwrap = width >> 4; break;
		case 2: vwrap = width >> 3; break;
		case 4: vwrap = width >> 2; break;
		case 8: vwrap = width >> 1; break;
		case 16: vwrap = width; break; // words/line
		case 32: vwrap = width << 1; break;
		default : return(0);
	}
	if(!addr && !acp_mode)
	{
#define MIN_VIDEO_RAM 0xD00000
#define BLOCK_STEP_RAM 0x10000
#define NUM_BLOCKS_RAM (MIN_VIDEO_RAM/BLOCK_STEP_RAM)
		long *tab = (long *)Mxalloc(NUM_BLOCKS_RAM * sizeof(long), 2);
		int i = -1, j;
		(void)Screalloc(BLOCK_STEP_RAM/2);
		/* try to get a screen above MIN_VIDEO_RAM */
		if(tab != NULL)
		{
			for(i = 0; i < NUM_BLOCKS_RAM; i++)
			{
				tab[i] = Mxalloc(BLOCK_STEP_RAM, 0); /* ST-RAM */
				if(!tab[i])
					break;
				if(tab[i] >= MIN_VIDEO_RAM)
					break;
			}
			if(!tab[i])
			{
				for(j = 0; j < i; j++)
				{
					if(tab[j])
						Mfree(tab[j]);
				}
				i = -1;
			}
		}
		addr = (long)Screalloc(width * height * (bpp >> 3));
		for(j = 0; j <= i; j++)
		{
			if(tab[j])
				Mfree(tab[j]);
		}
		if(!addr)
			addr = (long)Screalloc(width * height * (bpp >> 3));
		if(tab != NULL)
			Mfree(tab);
		if(!addr)
			return(0);
	}
#if defined(COLDFIRE) && defined(MCF547X)
	else if(acp_mode)
		addr = ACP_VIDEO_CFG; // ACP_VIDEO_RAM;
	else if(!acp_mode)
	{
		volatile unsigned long *p = (unsigned long *)ACP_ST_MODES;
		/* 25 MHz */
 		p[0] = 0x032002ba; /* hor 640x480 */
		p[1] = 0x020c020a; /* vert 640x480 */
		p[2] = 0x0190015d; /* hor 320x240 */
		p[3] = 0x020C020A; /* vert 320x240 */
	}
#endif
	*((char **)_v_bas_ad) = (char *)addr;
#if defined(NETWORK) && defined(LWIP) && defined(DEBUG)
#if defined(COLDFIRE) && defined(MCF547X)
	if(db != NULL)
		board_printf("init_videl %dx%dx%d@%dHz %dMHz %s %s\r\n", (int)width, (int)height, (int)bpp, (int)videl_rez->frq, (int)videl_rez->clk,
		 db->sync & FB_SYNC_HOR_HIGH_ACT ? "HSYNC:HIGH" : "HSYNC:LOW", db->sync & FB_SYNC_VERT_HIGH_ACT ? "VSYNC:HIGH" : "VSYNC:LOW");
	else
#endif
		board_printf("init_videl %dx%dx%d@%dHz %dMHz\r\n", (int)width, (int)height, (int)bpp, (int)videl_rez->frq, (int)videl_rez->clk);
	board_printf(" HHT:%03X HBB:%03X HBE:%03X HDB:%03X HDE:%03X HSS:%03X\r\n", (int)videl_rez->hht, (int)videl_rez->hbb, (int)videl_rez->hbe, (int)videl_rez->hdb, (int)videl_rez->hde, (int)videl_rez->hss);
	board_printf(" VFT:%03X VBB:%03X VBE:%03X VDB:%03X VDE:%03X VSS:%03X\r\n", (int)videl_rez->vft, (int)videl_rez->vbb, (int)videl_rez->vbe, (int)videl_rez->vdb, (int)videl_rez->vde, (int)videl_rez->vss);
	board_printf(" ADDR:%08X VWRAP:%04X VCTRL:%03X VCO:%03X\r\n", (int)addr, (int)vwrap, (int)videl_rez->vctrl, (int)videl_rez->vco);
#endif
#if defined(COLDFIRE) && defined(MCF547X)
	level = asm_set_ipl(7); // mask interrupts
	/* horizontal */
	HHT = videl_rez->hht;
	HBB = videl_rez->hbb;
	HBE = videl_rez->hbe;
	HDB = videl_rez->hdb;
	HDE = videl_rez->hde;
	HSS = videl_rez->hss;
	/* vertical */
	VFT = videl_rez->vft;
	VBB = videl_rez->vbb;
	VBE = videl_rez->vbe;                         
	VDB = videl_rez->vdb;
	VDE = videl_rez->vde;
	VSS = videl_rez->vss;
	SCREEN_POS_HIGH = (unsigned char)((addr >> 16) & 0xFF);
	SCREEN_POS_MID = (unsigned char)((addr >> 8) & 0xFF);
	SCREEN_POS_LOW = (unsigned char)(addr & 0xFF);
#if defined(COLDFIRE) && defined(MCF547X)
	if(!acp_mode)
	{
#endif
		OFF_NEXT_LINE = 0; // offset for next line (in words)
		VIDEO_SYNC &= ~1; // internal clock
		VWRAP = vwrap; // words/line
		VCTRL = videl_rez->vctrl; // pred video clock (pixel)
		VCO = videl_rez->vco; // clock and monitor
		SPSHIFT = 0;
#if defined(COLDFIRE) && defined(MCF547X)
		*(volatile unsigned long *)ACP_VIDEO_CONTROL = (acp_video_control &= ~ACP_VIDEO_ON); 
	}
	else
	{
		SCREEN_POS_ACP = (unsigned char)((addr >> 24) & 0xFF); /* line alignment */
		VCO = videl_rez->vco; // clock and monitor
	}
#endif
	switch(bpp)
	{
		case 1: /* 2 colors => FALCON palette */
			if(!acp_mode)
				SPSHIFT = 0x400;
			break;	
		case 2: /* 4 colors => ST palette */
			if(!acp_mode)
			{
				SHIFT = 1;
				VWRAP = vwrap; // words/line
				VCTRL = videl_rez->vctrl; // pred video clock (pixel)
			}
			break;
		case 4: /* 16 colors */
			if(st_mode && !acp_mode) // ST palette
			{
				VWRAP = vwrap; // words/line
				VCTRL = videl_rez->vctrl; // pred video clock (pixel)
			}
			break;
		case 8: /* 256 colors */
			if(!acp_mode)
				SPSHIFT = 0x10; // FALCON palette
#if defined(COLDFIRE) && defined(MCF547X)
			else/* FIREBEE palette */
				*(volatile unsigned long *)ACP_VIDEO_CONTROL = (acp_video_control |= ACP_COLOR_8);
#endif
			break;
		case 16: /* 65536 colors => no palette */
			SPSHIFT = 0x100;
			*VCLUT = 0; // black border
#if defined(COLDFIRE) && defined(MCF547X)
			if(acp_mode)
				*(volatile unsigned long *)ACP_VIDEO_CONTROL = (acp_video_control |= ACP_COLOR_16);
#endif
			break;
		case 32: /* 16M colors => no palette */
#if defined(COLDFIRE) && defined(MCF547X)
			if(acp_mode)
				*(volatile unsigned long *)ACP_VIDEO_CONTROL = (acp_video_control |= ACP_COLOR_24);
#endif
			break;
	}
	asm_set_ipl(level); // restore interrupts
#if defined(NETWORK) && defined(LWIP) && defined(DEBUG) && defined(COLDFIRE) && defined(MCF547X)
	board_printf(" ACP_VIDEO_CONTROL:%08X (%08X)\r\n", *(volatile unsigned long *)ACP_VIDEO_CONTROL, acp_video_control);
#endif
#endif /* defined(COLDFIRE) && defined(MCF547X) */
	return(addr);
}
