/***************************************************************************
 *   Copyright (C) 1998-1999 Michael Schwingen                             *
 *   michael@schwingen.org                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.           *
 ***************************************************************************/
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <portab.h>
#include <osbind.h>
#include "pci_lib.h"
#include "xtypes.h"
#include "ncrreg.h"
#include "cache.h"
#include "proto.h"
#include "globals.h"

#define MAX_SCATTER 16  /* must fit definitions in script */

#define TIMEOUT (10L*200L)

UBYTE my_scsi_id;
UWORD scsi_scan_mask;

#define DEBUG_SCATTER 0
#define DEBUG_COMMAND 1
#define DEBUG_TRACE 1
#define TESTIT 0

void fix_scripts(void);
void testit(void);
void setup_plx(void);

ULONG pagesize;

struct ncr_reg *ncr_base;

typedef struct
{
	UBYTE resvd;
	UBYTE sxfer;
	UBYTE id;
	UBYTE scntl3;
	ULONG unused;
	ULONG unused1_cnt;
	ULONG unused1_data;
	ULONG msgout_cnt;
	ULONG msgout_data;
	ULONG command_cnt;
	ULONG command_adr;
	struct scr_tblmove data[MAX_SCATTER];

	/* these are used by the host processor only */
	ULONG virt_start;
	ULONG length_left;
} DSA;

static struct
{
	ULONG status;
	ULONG command[20/4];
	DSA dsa;
	UBYTE msgin_buf[20];
	UBYTE msgout_buf[20];
	UBYTE scratch_buf[4];
} ncr_data;

#define scsi_status ncr_data.status
#define msgin_buf ncr_data.msgin_buf
#define msgout_buf ncr_data.msgout_buf
#define scratch_buf ncr_data.scratch_buf

#include "script.h"
int demo_mode;

#define virt_to_phys(a) (ULONG)(a)

void fix_scripts(void)
{
	static int did_init = 0;

	dprintf(DB_SCRIPT,"fix_scripts: did_init=%d\r\n",did_init);	
	if (did_init == 0)
	{
		int i;
		ULONG script_adr = virt_to_phys(&SCRIPT);
		did_init = 1;
		
//		dprintf(DB_SCRIPT,"script: log $%08lX, phys $%08lX",(ULONG) &SCRIPT,script_adr);
		for(i=0; i<PATCHES; i++)
		{
			SCRIPT[LABELPATCHES[i]] += script_adr;
		}
		for(i=0; i<EXTERNAL_PATCHES_LEN; i++)
		{
			SCRIPT[EXTERNAL_PATCHES[i].offset] += 
				virt_to_phys(EXTERNAL_PATCHES[i].address);
		}
		for(i=0;i<sizeof(SCRIPT)/sizeof(SCRIPT[0]); i++)
			SCRIPT[i] = end32(SCRIPT[i]);
		CacheCtrl(3);	/* Flush data/instr. cache */
	}
}

void hexdump(UBYTE *buffer, int len)
{
	int adr;
	for(adr=0; adr<len; adr += 16)
	{
		int i;
		dprintf(DB_DATA,"$%02X: ",adr);
		for(i=0;i<16; i++)
			dprintf(DB_DATA,"%02X ",buffer[adr+i]);
		dprintf(DB_DATA,"\"");
		for(i=0;i<16; i++)
			dprintf(DB_DATA,"%c",buffer[adr+i] >= 0x20 ? buffer[adr+i] : ' ');
		dprintf(DB_DATA,"\"\n");
	}
}

/* Der SCSI-2-Standard fordert:
   RESET hold time 25us, 
   RESET-to-selection time 250ms */
static void BusReset(void)
{
	dprintf(DB_COMMAND,"doing SCSI BUS reset\n");
	OUTB(nc_istat, 0x00);
	(void) INB(nc_istat);
	(void) INW(nc_sist);
	(void) INB(nc_dstat);
	OUTB(nc_istat, 0x00);
	OUTB(nc_scntl0, 0xCA);   /* clear START bit */
	OUTB(nc_scntl1, 0x00);   /* Connected etc. l”schen */
	OUTB(nc_scntl1, CRST);   /* Reset aktiv */
	mydelay(2);              /* mindestens 1 echter Tick = 5ms */            
	OUTB(nc_scntl1, 0x00);   /* Reset inaktiv */
	mydelay(250/5);
	post_busreset();
}

static int init_ncr(ULONG handle)
{
	int i;
	PCI_RSC_DESC *rsc = get_resource(handle);
//	bprintf("RSC 0 at $%08lx, length %ld, next %d\n",rsc->start, rsc->length, 
//		rsc->next);

	NEXT_RSC(rsc);	/* get mem-mapped regs */
	ncr_base = (struct ncr_reg *)(rsc->start + rsc->offset);

	if ((ULONG)ncr_base < 0x60000000L)
	{
		bprintf("ERROR: PCI base too low. Get newer botblock.\n");
		return 1;
	}
	bprintf("Registers memory mapped at $%p\n",ncr_base);
#if 0
	bprintf("register dump:\n");
	bprintf("scntl0: $%02X\n",INB(nc_scntl0));
	bprintf("scntl1: $%02X\n",INB(nc_scntl1));
	bprintf("scntl2: $%02X\n",INB(nc_scntl2));
	bprintf("scntl3: $%02X\n",INB(nc_scntl3));
#endif
	/* init chip */
	OUTB(nc_scntl0, 0xCA);   /* Full arb., Parity Enable, parity error -> ATN */
	OUTB(nc_scntl1, 0x00);
	OUTB(nc_scntl2, 0x09);
	OUTB(nc_scntl3, 0x03);
	OUTB(nc_scid, my_scsi_id|RRE);
	OUTB(nc_sxfer, 0x00);
	OUTB(nc_gpreg, 0x00);
	OUTB(nc_ctest3, CLF);    /* Clear FIFOs */
	OUTB(nc_ctest4, MPEE);   /* Master Parity Error Enable */
	OUTB(nc_ctest5, 0x00);

	OUTB(nc_dmode, BL_2|BL_1|BOF); /* 16-transfer burst, burst opcode fetch */
	OUTB(nc_dien, 0x00);     /* mask all interrupts */
	OUTB(nc_dcntl, NOCOM);   /* no 53C7xx compatibility, protect sfbr while reselect */
	OUTW(nc_sien, 0 /*STO|HTH|PAR|SGE|MA*/ ); /* set interrupts */
	OUTB(nc_stime0, 0x00);
	OUTB(nc_stime1, 0x00);
	OUTW(nc_respid, 1<<my_scsi_id);
	OUTB(nc_stest1, 0x00);
	OUTB(nc_stest2, 0x00);   /* TODO: check for differential mode */
	OUTB(nc_stest3, TE|CSF);
	fix_scripts();
	BusReset();
	for(i=0; i<=MAX_DEVICE; i++)
		dev_flags[i].DeviceOK = 1;
	return 0; /* OK */
}

#if 0
/* new version */
static int build_scatter(DSA *dsa)
{
	PCI_CONV_ADR cr;
	int index = 0;
	ULONG blk_start, blk_len;

#if DEBUG_SCATTER
	dprintf(DB_SCATTER,"\nbuild_scatter: data at $%lx, len $%lx\n",dsa->virt_start, dsa->length_left);
#endif	
	memset(&dsa->data, 0, sizeof(dsa->data));
	blk_start = -1L;
	blk_len = 0;
	while(dsa->length_left && index <= MAX_SCATTER)
	{
		LONG status;
		status = virt_to_bus(0L, dsa->virt_start, &cr);
		if (status != PCI_SUCCESSFUL)
			return 0;
		if (cr.len > dsa->length_left)
			cr.len = dsa->length_left;
#if DEBUG_SCATTER
		dprintf(DB_SCATTER,"scatter: block at $%lx, len $%lx\n",cr.adr, cr.len);
#endif
		dsa->data[index].size = end32(cr.len);
		dsa->data[index++].addr = end32(cr.adr);
		dsa->length_left -= cr.len;
		dsa->virt_start += cr.len;
	}
#if DEBUG_SCATTER
	if (dsa->length_left)
		dprintf(DB_SCATTER,"scatter: will need more data\n");
#endif
	return 1; /* OK */	
}
#else
static int build_scatter(DSA *dsa)
{
	PCI_CONV_ADR cr;
	int index = 0;

#if DEBUG_SCATTER
	dprintf(DB_SCATTER,"\nbuild_scatter: data at $%lx, len $%lx\n",dsa->virt_start, dsa->length_left);
#endif	
	memset(&dsa->data, 0, sizeof(dsa->data));
	while(dsa->length_left && index < MAX_SCATTER)
	{
		LONG status;
		status = virt_to_bus(0L, dsa->virt_start, &cr);
		if (status != PCI_SUCCESSFUL)
			return 0;
		if (cr.len > dsa->length_left)
			cr.len = dsa->length_left;
#if DEBUG_SCATTER
		dprintf(DB_SCATTER,"scatter: block at $%lx, len $%lx\n",cr.adr, cr.len);
#endif
		dsa->data[index].size = end32(cr.len);
		dsa->data[index++].addr = end32(cr.adr);
		dsa->length_left -= cr.len;
		dsa->virt_start += cr.len;
	}
#if DEBUG_SCATTER
	if (dsa->length_left)
		dprintf(DB_SCATTER,"scatter: will need more data\n");
#endif
	return 1; /* OK */	
}
#endif

static volatile UBYTE semaphor = 0;

static inline void lock(void)
{
  asm volatile (
    "0: tas _semaphor;"
		"bne.s 0b;"
	       : 			    /* output register */
	       :          /* input registers */
	       : "cc"			/* clobbered */ );
}

static inline void unlock(void)
{
	semaphor = 0;
}

long DoCommand(UBYTE id, UBYTE *command, UBYTE *data, ULONG data_len, ULONG to)
{
	ULONG entry;
	UBYTE status;
	LONG x, int_status;
	UWORD sist;
	UBYTE dstat;
	int cmd_done = 0;
	volatile ULONG *hz_200 = (volatile ULONG*) 0x4baL;
	ULONG timeout;
	int regdump, do_reset;
	
	static ULONG cmd_lengths[] = {
		0x06000000L, /* Group 0: 6 Bytes */
		0x0a000000L, /* Group 1: 10 bytes */
		0x0a000000L, /* Group 2: 10 bytes */
		0x00000000L, /* Group 3: reserved */
		0x00000000L, /* Group 4: reserved */
		0x0c000000L, /* Group 5: 12 bytes */
		0x00000000L, /* Group 6: reserved */
		0x00000000L  /* Group 7: reserved */
	};

	if (!command)
	{
		dprintf(DB_COMMAND,"NULL command pointer - ignored!\n");
		return -1;
	}
	
	if(demo_mode && id != 0)
		return -1;
	if(demo_mode && (command[0] == 0x0a || 
	                 command[0] == 0x2a || 
	                 command[0] == 0x2e || 
	                 command[0] == 0x3b || 
	                 command[0] == 0x3f || 
	                 command[0] == 0x41))
		return -1;

	if (id > MAX_DEVICE || dev_flags[id].DeviceOK == 0)
	{
		dprintf(DB_COMMAND,"SCSI: id %d is invalid.\n", id);
		return -1;
	}
	if (((1<<id) & scsi_scan_mask) == 0)
	{
		dprintf(DB_COMMAND,"ID %d is excluded in scan mask - ignoring!\n",id);
		return -1;
	}
		
//	lock();
	memcpy(ncr_data.command, command, 12);
#	if DEBUG_COMMAND	
	dprintf(DB_COMMAND,"SCSI: id %d, command %02X %02X %02X %02X %02X %02X "
                     "%02X %02X %02X %02X %02X %02X, %ld bytes data at $%p\n",
	        id, command[0], command[1], command[2], command[3], command[4], command[5], 
	        command[6], command[7], command[8], command[9], command[10], command[11],
	        data_len, data);
	if ((debug_flags & DB_DATA) && data_len && data)
	{
		hexdump(data, data_len);
	}

#	endif	
	/* *(volatile UBYTE*) 0xc0000080L = command[0]; */
	command = (UBYTE*) &ncr_data.command;

	scsi_status = -1;
	OUTB(nc_ctest3, CLF);   /* Clear FIFO (self clearing) */
	(void) INB(nc_istat);
	(void) INW(nc_sist);
	(void) INB(nc_dstat);
	OUTB(nc_istat, 0);
	OUTL(nc_dsps, 0l);
	OUTB(nc_stime0, 0xDD);
	OUTB(nc_stime1, 0xD0);
	//	serprintf("vor CMD: ISTAT: $%02X\n",INB(nc_istat));
	//	serprintf("DSTAT=$%02X\n",INB(nc_dstat));

	/* Setup DSA structure for this command */
	ncr_data.dsa.scntl3 = 0;
	ncr_data.dsa.id=id;
	ncr_data.dsa.sxfer = 0;

	{
		int lun = (command[1] >>5) & 7;
		ncr_data.dsa.msgout_cnt = end32(1L);
		ncr_data.dsa.msgout_data = end32((ULONG) msgout_buf);
		msgout_buf[0] = 0x80 | lun; 	/* send identify message */
	}

	ncr_data.dsa.command_cnt = cmd_lengths[(command[0] >> 5) & 7];
	ncr_data.dsa.command_adr = end32((ULONG) command);
	
	ncr_data.dsa.virt_start = (ULONG) data;
	ncr_data.dsa.length_left = data_len;


	if(build_scatter(&ncr_data.dsa) == 0)
	{
		unlock();
		dprintf(DB_COMMAND,"error in build_scatter - aborting command!\n");
		return -1;
	}

	entry = (ULONG) &SCRIPT[Ent_Command/4];
	
	while(!cmd_done)
	{
		CacheCtrl(1);	/* Flush data cache */
		OUTL(nc_dsa, (ULONG) &ncr_data.dsa);
		OUTL(nc_dsps, 0x11223344);
#if 0
		dprintf(DB_SCRIPT,"Starting script at $%p\n",entry);
#endif		
		OUTL(nc_dsp, entry);

		do_reset = 0;
		timeout = *hz_200 + to; /* Set TIMEOUT */
		do
		{
			status = INB(nc_istat);
		} while((status & 3) == 0 && *hz_200 < timeout);

		if ((status & 3) == 0) /* timeout */
		{
			dprintf(DB_COMMAND,"Timeout. Aborting command!\n");
			OUTB(nc_istat, 0x80); /* set ABORT bit */
			timeout = *hz_200 + 200;
			do
			{
				status = INB(nc_istat);
			} while((status & 3) == 0 && *hz_200 < timeout);
			dprintf(DB_COMMAND,"Abort: status=$%x",status);
			OUTB(nc_istat, 0x00); /* clear ABORT bit */
			dprintf(DB_COMMAND,", SOCL=$%02X SBCL=$%02X\n",INB(nc_socl), INB(nc_sbcl));
			if (status & CON) /* still connected to bus! */
				do_reset = 1;
		}
		
		CacheCtrl(1);	/* Flush data cache */
		x = INL(nc_dsp);
		int_status = INL(nc_dsps);
		sist = INW(nc_sist);
		dstat = INB(nc_dstat);

		if (sist & MA)
		{
//			ULONG pos = x-(LONG)SCRIPT-4;
			dprintf(DB_COMMAND,"PHASE MISMATCH! phase=$%02X\n", INB(nc_sbcl) & 7);
			dprintf(DB_COMMAND,"\nDSTAT=$%02X, dsp=$%08lX(script+$%lX, index $%08lX)\n",
				dstat, x, x-(LONG)SCRIPT, (x-(LONG)SCRIPT)/4);
			dstat |= DFE; /* don't wait for FIFOS to clear */
			sist &= ~MA;
			entry = (ULONG) &SCRIPT[Ent_cmd2/4];
			OUTB(nc_ctest3, INB(nc_ctest3) | CLF);   /* Clear DMA FIFO (self clearing) */
			OUTB(nc_stest3, INB(nc_stest3) | CSF);   /* Clear SCSI FIFO (self clearing) */
			continue;
		}

		timeout = *hz_200 + 2;
		while((dstat & DFE) == 0 && *hz_200 < timeout)	/* Wait until FIFO is empty */
		{
//			serprintf("F");
			dstat=INB(nc_dstat);
		}
		if (sist & STO)
		{
			dprintf(DB_COMMAND,"ID %d: selection timeout!\n", id);
			dprintf(DB_COMMAND,"error in build_scatter - aborting command!\n");
			unlock();
			return -1;
		}

	 	if (((sist & ~(CMP)) != 0) && int_status != A_R_TRACE)
	 		regdump = 1;
	 	else
	 		regdump = 0;

		switch(int_status)
		{
			case A_R_TRACE:
#				if DEBUG_TRACE			
				dprintf(DB_SCRIPT,"TRACE: at $%08lX\n",(x-(LONG)SCRIPT-8)/4);
#				endif				
				entry = x;
				break;
			case A_R_NEEDMORE:
#				if DEBUG_SCATTER 	
	 			dprintf(DB_SCATTER,"need more data: sist=$%02X",sist);
#				endif 		
				if(build_scatter(&ncr_data.dsa) == 0)
				{
					BusReset();
					dprintf(DB_COMMAND,"error in build_scatter - aborting command!\n");
					unlock();
					return -1;
				}
				entry = (ULONG) &SCRIPT[Ent_cmd2/4];
				break;
			case A_R_OK:
#				if DEBUG_COMMAND
				dprintf(DB_COMMAND,"Command completed OK!\n");
#				endif
				cmd_done = 1;
				break;
			case A_R_NOSELECT:
				dprintf(DB_COMMAND,"error during SELECT!\n");
				cmd_done=1;
				break;
			case A_R_UNKNMESSAGE:
				dprintf(DB_COMMAND,"unknown message %02X %02X %02X %02X %02X %02X %02X %02X\n",
					msgin_buf[0],msgin_buf[1],msgin_buf[2],msgin_buf[3],
					msgin_buf[4],msgin_buf[5],msgin_buf[6],msgin_buf[7]);
				entry = x;
				break;
			case A_R_SENDREJECT:
				dprintf(DB_COMMAND,"reject message %02X %02X %02X %02X %02X %02X %02X %02X\n",
					msgin_buf[0],msgin_buf[1],msgin_buf[2],msgin_buf[3],
					msgin_buf[4],msgin_buf[5],msgin_buf[6],msgin_buf[7]);
				entry = x;
				ncr_data.dsa.msgout_cnt = end32(1L);
				msgout_buf[0] = 0x07; 	/* send REJECT message */
				break;
			case A_R_DISCONNECT:
				{
					ULONG left = 0l;
					int index;
					for(index=0; index < MAX_SCATTER; index++)
						left += end32(ncr_data.dsa.data[index].size);
					dprintf(DB_COMMAND,"DISCONNECT: %ld bytes left - waiting for reselect ...", left);
					ncr_data.dsa.virt_start -= left;
					ncr_data.dsa.length_left += left;
					if(build_scatter(&ncr_data.dsa) == 0)
					{
						unlock();
						dprintf(DB_COMMAND,"error in build_scatter - aborting command!\n");
						return -1;
					}
					entry = (ULONG) &SCRIPT[Ent_wait_reselect/4];
				}
				break;
			case A_R_GOT_WDTR:
				dprintf(DB_COMMAND,"got WDTR: %02X %02X %02X %02X %02X %02X %02X %02X\n",
					msgin_buf[0],msgin_buf[1],msgin_buf[2],msgin_buf[3],
					msgin_buf[4],msgin_buf[5],msgin_buf[6],msgin_buf[7]);
				entry = x;
				break;
			case A_R_GOT_SDTR:
				dprintf(DB_COMMAND,"got SDTR: %02X %02X %02X %02X %02X %02X %02X %02X\n",
					msgin_buf[0],msgin_buf[1],msgin_buf[2],msgin_buf[3],
					msgin_buf[4],msgin_buf[5],msgin_buf[6],msgin_buf[7]);
				entry = x;
				break;
			case A_R_GOT_IGNRESIDUE:
				dprintf(DB_COMMAND,"got IGNORE RESIDUE: %02X %02X %02X %02X %02X %02X %02X %02X\n",
					msgin_buf[0],msgin_buf[1],msgin_buf[2],msgin_buf[3],
					msgin_buf[4],msgin_buf[5],msgin_buf[6],msgin_buf[7]);
				entry = x;
				break;
			case A_R_UNKNPHASE:
				dprintf(DB_COMMAND,"UNKNOWN PHASE in dispatch! phase=$%02X\n", INB(nc_sbcl) & 7);
				entry = x;
				break;
			default:
				dprintf(DB_COMMAND,"Unknown status $%08lx\n", int_status);
				cmd_done=2;
				break;
		}

		if ((dstat & IID)) /* illegal instruction - move with count 0? */
		{
			ULONG pos = x-(LONG)SCRIPT-4;
			if ((pos >= Ent_data_in && pos <= Ent_data_in_end) ||
	        (pos >= Ent_data_out && pos <= Ent_data_out_end))
	    {
				dprintf(DB_COMMAND,"Target wants more data than available!\n");
				entry = (ULONG) &SCRIPT[Ent_cleanup_data/4];
				cmd_done &= ~2;
			}
			else
			{
				dprintf(DB_COMMAND,"ILLEGAL COMMAND IN SCRIPT at $%08lX\n",pos);
				cmd_done = 1;
				regdump = 1;
				do_reset = 1;
			}
		}
#if 0		
		if (sist & MA)
		{
			dprintf(DB_COMMAND,"PHASE MISMATCH!\n");
			BusReset();
			entry = (ULONG) &SCRIPT[Ent_cmd2/4];
			cmd_done &= ~2;
		}
#endif		
		if (regdump)
		{
			dprintf(DB_COMMAND,"\nDSTAT=$%02X, dsp=$%08lX(script+$%lX, index $%08lX)\n",
				dstat, x, x-(LONG)SCRIPT, (x-(LONG)SCRIPT)/4);
			dprintf(DB_COMMAND,"DSPS=$%08lX, DCMD=$%08lX, TEMP=$%08lX, DWT=$%02X\n",int_status,
				INL(nc_dbc), INL(nc_temp), INB(nc_dwt));
			dprintf(DB_COMMAND,"SIST=$%04X ", sist);
			dprintf(DB_COMMAND,"SCSI Status: $%08lX\n",scsi_status);
		}
		if (do_reset)
			BusReset();
	} /* while !cmd_done */
	
#	if DEBUG_COMMAND	
	if ((debug_flags & DB_DATA) && data_len && data)
	{
		hexdump(data, data_len);
	}
#	endif	
	
	
	unlock();
	return *(BYTE*) &scsi_status;
}

#if TESTIT
char *sensekey[] = {
	"NO SENSE",
	"RECOVERED ERROR",
	"NOT READY",
	"MEDIUM ERROR",
	"HARDWARE ERROR",
	"ILLEGAL REQUEST",
	"UNIT ATTENTION",
	"DATA PROTECT",
	"BLANK CHECK",
	"Vendor specific (9)",
	"COPY ABORTED",
	"ABORTED COMMAND",
	"EQUAL",
	"VOLUME OVERFLOW",
	"MISCOMPARE",
	"RESERVED (15)"
};

void reqsense(int id)
{
	static UBYTE reqsense[] = { 0x03, 0,0,0,128,0};
	UBYTE buffer[128];
	int result;
	
	memset(buffer, 0, sizeof(buffer));
	result = DoCommand(id, reqsense, buffer, 128, TIMEOUT);
	bprintf("Request Sense: result %d\n",result);
	hexdump(buffer, 128);
	if (result == 0)
	{
		bprintf("Sense key: %s, add. code/qual $%02X/$%02X\n",sensekey[buffer[2] & 0x0f], buffer[12], buffer[13]);
	}
	
}

void testit(void)
{
	int result, id=3;
//	static UBYTE test_unit_ready[] = { 0,0,0,0,0,0 };
	static UBYTE inquiry[] = { 0x12,0,0,0,36,0 };
//	static UBYTE read6[] = { 0x08,0,0,0,1,0 };
	static UBYTE read6b[] = { 0x08,0,0,0,1,0 };
	char *buffer = Malloc(512L*1024L);
	
	if (buffer == 0)
	{
		bprintf("not enough memory for Test!\n");
		return;
	}

	memset(buffer, 0x55, 512);
	
	result = DoCommand(id, inquiry, buffer, 36, TIMEOUT);
	bprintf("Result: %d\n",result);
	hexdump(buffer, 0x40);

	result = DoCommand(id, read6b, buffer, 2048L*read6b[4], TIMEOUT);
	bprintf("result: %d\n",result);
	if (result == 2)
		reqsense(id);
	else
		hexdump(buffer, 0x200);
#if 0
	result = DoCommand(id, read6b, buffer, 2048L*read6b[4], TIMEOUT);
	bprintf("result: %d\n",result);
	if (result == 2)
		reqsense(id);
	else
		hexdump(buffer, 0x200);
#endif
	Mfree(buffer);
}

void testit2(void)
{
	int result,i;
	ULONG l;
	int id=2;
	static UBYTE inquiry[] = { 0x12,0,0,0,36,0 };
//	static UBYTE read6[] = { 0x08,0,0,0,1,0 };
//	static UBYTE read6b[] = { 0x08,0,0,0,10,0 };
	static UBYTE load[] = { 0x1B, 0x00, 0x00, 0x00, 0x01, 0x00 };
	static UBYTE rewind[] = { 0x01, 0x00, 0x00, 0x00, 0x01, 0x00 };
	static UBYTE readpos[] = { 0x34, 0x01, 0x00, 0x00, 0x00, 0x00,
	                           0x00, 0x00, 0x00, 0x00 };
	static UBYTE write[] = { 0x0A,1,0,0,0,0 };
	char *buffer = Malloc(512L*1024L);
	
	if (buffer == 0)
	{
		bprintf("not enough memory for Test!\n");
		return;
	}

	memset(buffer, 0x55, 512L);
	
	result = DoCommand(id, inquiry, buffer, 36, TIMEOUT);
	bprintf("Result: %d\n",result);
	hexdump(buffer, 0x40);

	result = DoCommand(id, load, buffer, 0, TIMEOUT);
	bprintf("load result: %d\n",result);

	result = DoCommand(id, load, buffer, 0, TIMEOUT);
	bprintf("load result: %d\n",result);

	for(i=0; i<3; i++)
	{
	memset(buffer, 0x55, 512L);
	result = DoCommand(id, readpos, buffer, 20, TIMEOUT);
	bprintf("read position result: %d\n",result);
	hexdump(buffer, 20);

	memset(buffer, 0x55, 512L*1024L);
	write[4] = 20;
	result = DoCommand(id, write, buffer, 20*512L, TIMEOUT);
	bprintf("write data result: %d\n",result);
	}

	Mfree(buffer);
}

void ScanBus(void)
{
	int result, id;
	static UBYTE test_unit_ready[] = { 0,0,0,0,0,0 };
	static UBYTE inquiry[] = { 0x12,0,0,0,36,0 };
//	static UBYTE read6[] = { 0x08,0,0,0,1,0 };

	UBYTE buffer[40];

	for(id=0; id<7; id++)
	{
		result = DoCommand(id, test_unit_ready, buffer, 0, TIMEOUT);
		bprintf("TUR ID%d: %d\n",id,result);
		result = DoCommand(id, inquiry, buffer, 36, TIMEOUT);
		if(result >= 0)
		{
			buffer[0x24] = 0;
			bprintf("ID%d: '%s'\n", id, buffer+8);
		}
	}
}

void pmmutest(void)
{
	PCI_CONV_ADR cr;
	LONG status;
	
	memset(&cr, 0, sizeof(cr));
	status = virt_to_bus(0L, 0x01000000L, &cr);
	bprintf("virt_to_bus result: %ld\n",status);
	bprintf("physical address: $%08lX, length $%08lX\n", cr.adr, cr.len);
}
#endif


/* check for a working virt_to_bus in the PCI BIOS */
int CheckPCIBios(void)
{
	PCI_CONV_ADR cr;

	if(virt_to_bus(0L, 0x00e00000L, &cr) != PCI_SUCCESSFUL)
	{
//		serprintf("pcibios fail 1\r\n");
		return 1; /* not OK */
	}
	if (cr.adr != 0x00e00000L || cr.len != pagesize)
	{
//		serprintf("pcibios fail 2: $%08lx $%08lx\r\n",cr.adr, cr.len);
		return 1;
	}

	memset(&cr, 0, sizeof(cr));
	if(virt_to_bus(0L, 0x00100000L, &cr) != PCI_SUCCESSFUL)
	{
//		serprintf("pcibios fail 3\r\n");
		return 1; /* not OK */
	}
	if (cr.adr != 0x00100000L || cr.len != pagesize)
	{
//		serprintf("pcibios fail 4\r\n");
		return 1;
	}
	return 0;
}

/* this used to be an external check - removed for free version release */
static inline int serial_ok(ULONG serial)
{
	return 0;
}

int main(void)
{
	LONG handle;
	UWORD index;
	ULONG old_ssp;
	ULONG devId;
	ULONG serial;
	int	CardCount = 0;

	bprintf("\033p"
#if BETA
		"SCSI8XX V1.3 BETA " __DATE__ " (C) 1998-99 M. Schwingen"
#else
		"SCSI8XX V1.3 " __DATE__ " (C) 1998-99 M. Schwingen"
#endif
		"\033q\n");

	if (pcibios_init() != PCI_SUCCESSFUL)
	{
		bprintf("PCI initialization error.\n");
		return 1;
	}

	if(1)
	{
		UBYTE tmp;
		if(NVMaccess(0, 12, 1, &tmp) == 0)
			scsi_scan_mask = 0xff00 | tmp;
		else
			scsi_scan_mask = 0xffff;
	}
	check_debug();
	old_ssp = Super(0l);
	serial = get_machine_id();
	if(NVMaccess(0, 16, 1, &my_scsi_id) != 0 || (my_scsi_id & 0x80) == 0)
	{
		bprintf("No valid SCSI ID set in NVRAM. Using ID 7!\n");
		my_scsi_id = 7;
	}
	else
	{
		my_scsi_id &= 15;
		/* bprintf("using SCSI ID %d.\n",my_scsi_id); */
	}
	pagesize = get_pagesize();
//	bprintf("PMMU Pagesize is %ld bytes.\n",pagesize);

	if((ULONG) main > 0x00e00000L)
	{
		bprintf("ERROR: this driver must be loaded in ST-RAM.\n");
		return -1;
	}
	if (CheckPCIBios())
	{
		bprintf("ERROR: this TOS does not have a working PCI BIOS. please get an update.\n");
		Super(old_ssp);
		return -1;
	}
	for(index=0, handle=0; handle>=0 && index<10; index++)
	{
		handle = find_pci_device(0xffffffff, index);
//		handle = find_pci_classcode(0x01010000, index);
		handle = find_pci_classcode(0x0f010000, index);
//		bprintf("index %d: handle %p\n",index, handle);
		if (handle>0)
		{
			devId=fast_read_config_longword(handle, 0);
			if (devId == 0x00011000)
			{
				extern ULONG _PgmSize;
				ULONG cb_adr;
				ULONG cfg;

				bprintf("Found SYM53C810: ");

				if(1 == get_card_used(handle, &cb_adr))
				{
					bprintf("Error: card is already in use!\n");
#if 0
					bprintf("Beta release: continuing anyway ...\n");
#else
					continue;
#endif
				}

				cfg = fast_read_config_longword(handle, 4);
//			bprintf("initial config: $%08lx\n",cfg);
				cfg &= ~1;
				cfg |= 6; /* enable mem, busmaster, disable IO */
				write_config_longword(handle, 4, cfg);

				if(init_ncr(handle))
					return -1;
#if TESTIT
				ScanBus();
				bprintf("serial: $%08lx $%08lX\n",serial, serial_ok(serial));
//					sd_init();
//				pmmutest();
//				testit();
#else				
//				ScanBus();
//				bprintf("PgmSize is %ld\n",_PgmSize);
				demo_mode = (serial_ok(serial) != 0L);
				sd_init();
				CardCount++;
				if(demo_mode)
					bprintf("not licensed for this machine - DEMO MODE!\n");
				if(1) /* Install_HDEX() == 0) - old private interface, removed for public release*/
				{
					set_card_used(handle, (void*) 1L);
					Super(old_ssp);
					//bprintf("cookie installed OK - staying resident.\n");
					bprintf("\033p%d card(s) found.\033q\n", CardCount);
					Ptermres(_PgmSize, 0);
				}
				else
					bprintf("set cookie failed. not resident!\n");
#endif				
				handle = -1; /* stop looking - handle only one adapter for now */
			}
//			else
//				bprintf("unknown device: $%08lX\n",devId);
		}
	}
	check_debug();
	Super(old_ssp);

	bprintf("\033p%d cards found.\033q\n", CardCount);

	return 0;
}

void __main(void)
{
}
