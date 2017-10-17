#define RINFO_ONLY
#include "../../radeon/radeonfb.h"
#include <mint/osbind.h>
#include <mint/sysvars.h>
#include <string.h>
#include <pcixbios.h>
#include <x86emu/x86emu.h>
#include "../../include/pci_bios.h" /* for LITTLE_ENDIAN_LANE_SWAPPED */
// #include "vgatables.h"

#define USE_SDRAM

#ifdef COLDFIRE
#ifdef LITTLE_ENDIAN_LANE_SWAPPED /* PCI BIOS */
#define DIRECT_ACCESS
#endif
#ifndef PCI_XBIOS
#define PCI_XBIOS // else sometimes system is locked ???
#endif
#else /* !COLDFIRE */
#ifdef LITTLE_ENDIAN_LANE_SWAPPED /* PCI BIOS */
#define DIRECT_ACCESS
#endif
#endif /* COLDFIRE */

#define MEM_WB(where, what) wrb(where, what)
#define MEM_WW(where, what) wrw(where, what)
#define MEM_WL(where, what) wrl(where, what)

#define MEM_RB(where) rdb(where)
#define MEM_RW(where) rdw(where)
#define MEM_RL(where) rdl(where)

#define PCI_VGA_RAM_IMAGE_START 0xC0000
#define PCI_RAM_IMAGE_START     0xD0000
#define SYS_BIOS                0xF0000
#define SIZE_EMU               0x100000

#ifdef DIRECT_ACCESS
extern u16 swap_short(u16 val);
extern u32 swap_long(u32 val);
#endif

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

struct rom_header
{
	u16	signature;
	u8 size;
	u8 init[3];
	u8 reserved[0x12];
	u16	data;
};

struct pci_data
{
	u32 signature;
	u16 vendor;
	u16 device;
	u16 reserved_1;
	u16 dlen;
	u8 drevision;
	u8 class_lo;
	u16 class_hi;
	u16 ilen;
	u16 irevision;
	u8 type;
	u8 indicator;
	u16	reserved_2;
};

struct radeonfb_info *rinfo_biosemu;
u16 offset_port;
u32 offset_mem;
static u32 offset_io;
static u32 config_address_reg;

extern int pcibios_handler();
extern COOKIE *get_cookie(long id);
extern short restart, os_magic;

/* general software interrupt handler */
u32 getIntVect(int num)
{
	return MEM_RW(num << 2) + (MEM_RW((num << 2) + 2) << 4);
}

/* FixME: There is already a push_word() in the emulator */
void pushw(u16 val)
{
	X86_ESP -= 2;
	MEM_WW(((u32) X86_SS << 4) + X86_SP, val);
}

int run_bios_int(int num)
{
	u32 eflags;
	eflags = X86_EFLAGS;
	pushw(eflags);
	pushw(X86_CS);
	pushw(X86_IP);
	X86_CS = MEM_RW((num << 2) + 2);
	X86_IP = MEM_RW(num << 2);
	return 1;
}

u8 inb(u16 port)
{
	u8 val = 0;
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("inb(", port);
#endif
#ifdef DIRECT_ACCESS
		val = *(u8 *)(offset_io+(u32)port);
#else
#ifdef PCI_XBIOS
		val = fast_read_io_byte(rinfo_biosemu->handle,offset_io+(u32)port);
#else
		val = Fast_read_io_byte(rinfo_biosemu->handle,offset_io+(u32)port);
#endif
#endif
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
	}
	return val;
}

u16 inw(u16 port)
{
	u16 val = 0;
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("inw(", port);
#endif
#ifdef DIRECT_ACCESS
		val = swap_short(*(u16 *)(offset_io+(u32)port));
#else
#ifdef PCI_XBIOS
		val = fast_read_io_word(rinfo_biosemu->handle,offset_io+(u32)port);
#else
		val = Fast_read_io_word(rinfo_biosemu->handle,offset_io+(u32)port);
#endif
#endif
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
	}
	return val;
}

u32 inl(u16 port)
{
	u32 val = 0;
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("inl(", port);
#endif
#ifdef DIRECT_ACCESS
		val = swap_long(*(u32 *)(offset_io+(u32)port));
#else
#ifdef PCI_XBIOS
		val = fast_read_io_longword(rinfo_biosemu->handle, offset_io+(u32)port);
#else
		val = Fast_read_io_longword(rinfo_biosemu->handle, offset_io+(u32)port);
#endif
#endif
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
	}
	else if(port == 0xCF8)
	{
		val = config_address_reg;
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("inl(", port);
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
	}
	else if((port == 0xCFC) && ((config_address_reg & 0x80000000) !=0))
	{
		if((config_address_reg & 0xFC) == PCIBAR1)
			val = (u32)offset_port+1;
		else
		{
#ifdef DEBUG_X86EMU_PCI
			DPRINTVALHEX("inl(", port);
#endif
#ifdef PCI_XBIOS
			val = fast_read_config_longword(rinfo_biosemu->handle, config_address_reg & 0xFC);
#else
			val = Fast_read_config_longword(rinfo_biosemu->handle, config_address_reg & 0xFC);
#endif
#ifdef DEBUG_X86EMU_PCI
			DPRINTVALHEX(") = ", val);
			DPRINT("\r\n");
#endif
		}
	}
	return val;
}

void outb(u8 val, u16 port)
{
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("outb(", port);
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
#ifdef DIRECT_ACCESS
		*(u8 *)(offset_io+(u32)port) = val;
#else
#ifdef PCI_XBIOS
		write_io_byte(rinfo_biosemu->handle,offset_io+(u32)port,(u16)val);
#else
		Write_io_byte(rinfo_biosemu->handle,offset_io+(u32)port,(u16)val);
#endif
#endif
	}
}

void outw(u16 val, u16 port)
{
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("outw(", port);
		DPRINTVALHEX(") = ", val);
		DPRINT("\r\n");
#endif
#ifdef DIRECT_ACCESS
#ifndef COLDFIRE // write_io_word sometimes lock the system on the Coldfire ????
		*(u16 *)(offset_io+(u32)port) = swap_short(val);
#else
		*(u8 *)(offset_io+(u32)port) = val;
		port++;
		val>>=8;
		*(u8 *)(offset_io+(u32)port) = val;
#endif /* COLDFIRE */
#else /* !DIRECT_ACCESS */
#ifndef COLDFIRE // write_io_word sometimes lock the system on the Coldfire ????
#ifdef PCI_XBIOS
		write_io_word(rinfo_biosemu->handle,offset_io+(u32)port,val);
#else
		Write_io_word(rinfo_biosemu->handle,offset_io+(u32)port,val);
#endif
#else /* !COLDFIRE */
#ifdef PCI_XBIOS
		write_io_byte(rinfo_biosemu->handle,offset_io+(u32)port,(u16)val & 0xFF);
		port++;
		val>>=8;
		write_io_byte(rinfo_biosemu->handle,offset_io+(u32)port,(u16)val & 0xFF);	
#else
		Write_io_byte(rinfo_biosemu->handle,offset_io+(u32)port,(u16)val & 0xFF);
		port++;
		val>>=8;
		Write_io_byte(rinfo_biosemu->handle,offset_io+(u32)port,(u16)val & 0xFF);	
#endif
#endif /* COLDFIRE */
#endif /* DIRECT_ACCESS */
	}
}

void outl(u32 val, u16 port)
{
	if((port >= offset_port) && (port <= offset_port+0xFF))
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("outl(", port);
		DPRINTVALHEX(") = ", val);
#endif
#ifdef DIRECT_ACCESS
		*(u32 *)(offset_io+(u32)port) = swap_long(val);
#else
#ifdef PCI_XBIOS
		write_io_longword(rinfo_biosemu->handle,offset_io+(u32)port,val);
#else
		Write_io_longword(rinfo_biosemu->handle,offset_io+(u32)port,val);
#endif
#endif
	}
	else if(port == 0xCF8)
	{
#ifdef DEBUG_X86EMU_PCI
		DPRINTVALHEX("outl(", port);
		DPRINTVALHEX(") = ", val);
#endif
		config_address_reg = val;
	}
	else if((port == 0xCFC) && ((config_address_reg & 0x80000000) !=0))
	{
		if((config_address_reg & 0xFC) == PCIBAR1)
			offset_port = (u16)val & 0xFFFC;
		else
		{
#ifdef DEBUG_X86EMU_PCI
			DPRINTVALHEX("outl(", port);
			DPRINTVALHEX(") = ", val);
#endif
#ifdef PCI_XBIOS
			write_config_longword(rinfo_biosemu->handle, config_address_reg & 0xFC, val);
#else
			Write_config_longword(rinfo_biosemu->handle, config_address_reg & 0xFC, val);
#endif
		}
	}
#ifdef DEBUG_X86EMU_PCI
	DPRINT("\r\n");
#endif
}

/* Interrupt multiplexer */

void do_int(int num)
{
	int ret = 0;
//	DPRINTVAL("int ", num);
//	DPRINTVALHEX(" vector at ", getIntVect(num));
//	DPRINT("\r\n");
	switch (num)
	{
#ifndef _PC
	case 0x10:
	case 0x42:
	case 0x6D:
		if (getIntVect(num) == 0x0000)
			DPRINT("un-inited int vector\r\n");
		if (getIntVect(num) == 0xFF065)
		{
			//ret = int42_handler();
			ret = 1;
		}
		break;
#endif
	case 0x15:
		//ret = int15_handler();
		ret = 1;
		break;
	case 0x16:
		//ret = int16_handler();
		ret = 0;
		break;
	case 0x1A:
		ret = pcibios_handler();
		ret = 1;
		break;
	case 0xe6:
		//ret = intE6_handler();
		ret = 0;
		break;
	default:
		break;
	}
	if(!ret)
		ret = run_bios_int(num);
}

#if 0

void reset_int_vect(void)
{
	/*
	 * This table is normally located at 0xF000:0xF0A4.  However, int 0x42,
	 * function 0 (Mode Set) expects it (or a copy) somewhere in the bottom
	 * 64kB.  Note that because this data doesn't survive POST, int 0x42 should
	 * only be used during EGA/VGA BIOS initialisation.
	 */
	static const u8 VideoParms[] = {
		/* Timing for modes 0x00 & 0x01 */
		0x38, 0x28, 0x2d, 0x0a, 0x1f, 0x06, 0x19, 0x1c,
		0x02, 0x07, 0x06, 0x07, 0x00, 0x00, 0x00, 0x00,
		/* Timing for modes 0x02 & 0x03 */
		0x71, 0x50, 0x5a, 0x0a, 0x1f, 0x06, 0x19, 0x1c,
		0x02, 0x07, 0x06, 0x07, 0x00, 0x00, 0x00, 0x00,
		/* Timing for modes 0x04, 0x05 & 0x06 */
		0x38, 0x28, 0x2d, 0x0a, 0x7f, 0x06, 0x64, 0x70,
		0x02, 0x01, 0x06, 0x07, 0x00, 0x00, 0x00, 0x00,
		/* Timing for mode 0x07 */
		0x61, 0x50, 0x52, 0x0f, 0x19, 0x06, 0x19, 0x19,
		0x02, 0x0d, 0x0b, 0x0c, 0x00, 0x00, 0x00, 0x00,
		/* Display page lengths in little endian order */
		0x00, 0x08,	/* Modes 0x00 and 0x01 */
		0x00, 0x10,	/* Modes 0x02 and 0x03 */
		0x00, 0x40,	/* Modes 0x04 and 0x05 */
		0x00, 0x40,	/* Modes 0x06 and 0x07 */
		/* Number of columns for each mode */
		40, 40, 80, 80, 40, 40, 80, 80,
		/* CGA Mode register value for each mode */
		0x2c, 0x28, 0x2d, 0x29, 0x2a, 0x2e, 0x1e, 0x29,
		/* Padding */
		0x00, 0x00, 0x00, 0x00
	};
	int i;

	for(i = 0; i < sizeof(VideoParms); i++)
		MEM_WB(i + (0x1000 - sizeof(VideoParms)), VideoParms[i]);
	MEM_WW(0x1d << 2, 0x1000 - sizeof(VideoParms));
	MEM_WW((0x1d << 2) + 2, 0);

	DPRINT("SETUP INT\r\n");
	MEM_WW(0x10 << 2, 0xf065);
	MEM_WW((0x10 << 2) + 2, SYS_BIOS >> 4);
	MEM_WW(0x42 << 2, 0xf065);
	MEM_WW((0x42 << 2) + 2, SYS_BIOS >> 4);
	MEM_WW(0x6D << 2, 0xf065);
	MEM_WW((0x6D << 2) + 2, SYS_BIOS >> 4);
}

/*
 * here we are really paranoid about faking a "real"
 * BIOS. Most of this information was pulled from
 * dosemu.
 */
void setup_int_vect(void)
{
	int i;

	/* let the int vects point to the SYS_BIOS seg */
	for(i = 0; i < 0x80; i++)
	{
		MEM_WW(i << 2, 0);
		MEM_WW((i << 2) + 2, SYS_BIOS >> 4);
	}

	reset_int_vect();

	/* font tables default location (int 1F) */
	MEM_WW(0x1f << 2, 0xfa6e);
	/* int 11 default location (Get Equipment Configuration) */
	MEM_WW(0x11 << 2, 0xf84d);
	/* int 12 default location (Get Conventional Memory Size) */
	MEM_WW(0x12 << 2, 0xf841);
	/* int 15 default location (I/O System Extensions) */
	MEM_WW(0x15 << 2, 0xf859);
	/* int 1A default location (RTC, PCI and others) */
	MEM_WW(0x1a << 2, 0xff6e);
	/* int 05 default location (Bound Exceeded) */
	MEM_WW(0x05 << 2, 0xff54);
	/* int 08 default location (Double Fault) */
	MEM_WW(0x08 << 2, 0xfea5);
	/* int 13 default location (Disk) */
	MEM_WW(0x13 << 2, 0xec59);
	/* int 0E default location (Page Fault) */
	MEM_WW(0x0e << 2, 0xef57);
	/* int 17 default location (Parallel Port) */
	MEM_WW(0x17 << 2, 0xefd2);
	/* fdd table default location (int 1e) */
	MEM_WW(0x1e << 2, 0xefc7);

	/* Set Equipment flag to VGA */
	i = MEM_RB(0x0410) & 0xCF;
	MEM_WB(0x0410, i);
	/* XXX Perhaps setup more of the BDA here.  See also int42(0x00). */
}

#endif

static int setup_system_bios(void *base_addr)
{
	char *base = (char *) base_addr;
	int i;
	/*
	 * we trap the "industry standard entry points" to the BIOS
	 * and all other locations by filling them with "hlt"
	 * TODO: implement hlt-handler for these
	 */
//	for(i=0; i<0x10000; base[i++]=0xF4);
	for(i=0; i<SIZE_EMU; base[i++]=0xF4);
	/* set bios date */
	//strcpy(base + 0x0FFF5, "06/11/99");
	/* set up eisa ident string */
	//strcpy(base + 0x0FFD9, "PCI_ISA");
	/* write system model id for IBM-AT */
	//*((unsigned char *) (base + 0x0FFFE)) = 0xfc;
	return(1);
}

#if 0

static void memsetw(u32 addr, u16 value, u16 count)
{
	while(--count)
	{
		wrw(addr, value);
		addr += 2;
	}
}

static u8 find_vga_entry(u8 mode) 
{
	u8 i,line=0xFF;
	for(i=0;i<=MODE_MAX;i++)
	{
		if(vga_modes[i].svgamode==mode)
		{
			line=i;
			break;
		}
	}
	return(line);
}

void biosfn_set_video_mode(u8 mode)
{
	u8 line,mmask,*palette=0,vpti;
	u16 i,twidth,theightm1,cheight;
	u8 modeset_ctl=0;
	u16 crtc_addr;
	// find the entry in the video modes
	line=find_vga_entry(mode);
	if(line==0xFF)
  	return;
	vpti=line_to_vpti[line];
	twidth=video_param_table[vpti].twidth;
	theightm1=video_param_table[vpti].theightm1;
	cheight=video_param_table[vpti].cheight;
	// if palette loading (bit 3 of modeset ctl = 0)
	if((modeset_ctl&0x08)==0)
  {
  	// Set the PEL mask
		outb(vga_modes[line].pelmask,VGAREG_PEL_MASK);
		// Set the whole dac always, from 0
		outb(0x00,VGAREG_DAC_WRITE_ADDRESS);
		// From which palette
		switch(vga_modes[line].dacmodel)
    {
    	case 0: palette=palette0; break;
			case 1: palette=palette1; break;
			case 2: palette=palette2; break;
			case 3: palette=palette3; break;
    }
		// Always 256*3 values
		for(i=0;i<0x0100;i++)
		{
			if(i<=dac_regs[vga_modes[line].dacmodel])
      {
				outb(palette[(i*3)+0],VGAREG_DAC_DATA);
				outb(palette[(i*3)+1],VGAREG_DAC_DATA);
				outb(palette[(i*3)+2],VGAREG_DAC_DATA);
			}
			else
			{
				outb(0,VGAREG_DAC_DATA);
				outb(0,VGAREG_DAC_DATA);
				outb(0,VGAREG_DAC_DATA);
			}
		}
		if((modeset_ctl&0x02)==0x02)
		{
			u8 r,g,b;
			u16 i;
			u16 index,start=0;
			inb(VGAREG_ACTL_RESET);
			outb(0x00,VGAREG_ACTL_ADDRESS);
			for(index = 0; index < 0x100; index++) 
			{
				// set read address and switch to read mode
				outb(start,VGAREG_DAC_READ_ADDRESS);
				// get 6-bit wide RGB data values
				r=inb(VGAREG_DAC_DATA);
				g=inb(VGAREG_DAC_DATA);
				b=inb(VGAREG_DAC_DATA);
				// intensity = ( 0.3 * Red ) + ( 0.59 * Green ) + ( 0.11 * Blue )
				i = ((77*r + 151*g + 28*b) + 0x80) >> 8;
				if(i>0x3f)
					i=0x3f;
				// set write address and switch to write mode
				outb(start,VGAREG_DAC_WRITE_ADDRESS);
				// write new intensity value
				outb(i & 0xff,VGAREG_DAC_DATA);
				outb(i & 0xff,VGAREG_DAC_DATA);
				outb(i & 0xff,VGAREG_DAC_DATA);
				start++;
			}  
			inb(VGAREG_ACTL_RESET);
			outb(0x20,VGAREG_ACTL_ADDRESS);
		}
  }
	// Reset Attribute Ctl flip-flop
	inb(VGAREG_ACTL_RESET);
	// Set Attribute Ctl
	for(i=0;i<=0x13;i++)
  {
		outb(i,VGAREG_ACTL_ADDRESS);
		outb(video_param_table[vpti].actl_regs[i],VGAREG_ACTL_WRITE_DATA);
	}
	outb(0x14,VGAREG_ACTL_ADDRESS);
	outb(0x00,VGAREG_ACTL_WRITE_DATA);
	// Set Sequencer Ctl
	outb(0,VGAREG_SEQU_ADDRESS);
	outb(0x03,VGAREG_SEQU_DATA);
	for(i=1;i<=4;i++)
	{
		outb(i,VGAREG_SEQU_ADDRESS);
		outb(video_param_table[vpti].sequ_regs[i - 1],VGAREG_SEQU_DATA);
	}
	// Set Grafx Ctl
	for(i=0;i<=8;i++)
	{
		outb(i,VGAREG_GRDC_ADDRESS);
		outb(video_param_table[vpti].grdc_regs[i],VGAREG_GRDC_DATA);
	}
	// Set CRTC address VGA
	crtc_addr=VGAREG_VGA_CRTC_ADDRESS;
	// Disable CRTC write protection
	outw(crtc_addr,0x0011);
	// Set CRTC regs
	for(i=0;i<=0x18;i++)
	{
		outb(i,crtc_addr);
		outb(video_param_table[vpti].crtc_regs[i],crtc_addr+1);
	}
	// Set the misc register
	outb(video_param_table[vpti].miscreg,VGAREG_WRITE_MISC_OUTPUT);
	// Enable video
	outb(0x20,VGAREG_ACTL_ADDRESS);
	inb(VGAREG_ACTL_RESET);
	if(mode<0x0d)
		memsetw(vga_modes[line].sstart,0x0000,0x4000); // 32k
	else
	{
		outb(0x02,VGAREG_SEQU_ADDRESS);
		mmask = inb( VGAREG_SEQU_DATA );
		outb(0x0f,VGAREG_SEQU_DATA); // all planes
		memsetw(vga_modes[line].sstart,0x0000,0x8000); // 64k
		outb(mmask,VGAREG_SEQU_DATA);
	}
}

#endif

void run_bios(struct radeonfb_info *rinfo)
{
	long i, j;
	unsigned char *ptr;
	struct rom_header *rom_header;
	struct pci_data *rom_data;
	unsigned long rom_size=0;
	unsigned long image_size=0;
	unsigned long biosmem=0x01000000; /* when run_bios() is called, SDRAM is valid but not add to the system */
	unsigned long addr;
	unsigned short initialcs;
	unsigned short initialip;
	unsigned short devfn = (unsigned short)(rinfo->handle << 3); // was dev->bus->secondary << 8 | dev->path.u.pci.devfn;
	X86EMU_intrFuncs intFuncs[256];

	if((rinfo->mmio_base == NULL) || (rinfo->io_base == NULL))
		return;
#ifndef COLDFIRE
	/* try to not init the board with thr X86 VGA BIOS, too long on CT60 (more than 10 seconds, 2 seconds on Coldfire) */
	if(os_magic == 1)
		return;
	if(restart /* CTRL-ALT-DEL else 0 if reset */
	 && (*memvalid == MEMVALID_MAGIC) && (*memval2 == MEMVAL2_MAGIC)
	 && (*((unsigned long *) 0x51AL) == 0x5555AAAA)) /* memval3 */
		return;
#endif
	rinfo_biosemu = rinfo;
	config_address_reg = 0;
	offset_port = 0x300;
#ifdef DIRECT_ACCESS
	offset_io = (u32)rinfo->io_base-(u32)offset_port;
	offset_mem = (u32)rinfo->fb_base-0xA0000;
#else
	offset_io = rinfo->io_base_phys-(u32)offset_port;
	offset_mem = rinfo->fb_base_phys-0xA0000;
#endif
	rom_header = (struct rom_header *)0;
	do
	{
		rom_header = (struct rom_header *)((unsigned long)rom_header + image_size); // get next image
		rom_data = (struct pci_data *)((unsigned long)rom_header + (unsigned long)BIOS_IN16((long)&rom_header->data));
		image_size = (unsigned long)BIOS_IN16((long)&rom_data->ilen) * 512;
	}
	while((BIOS_IN8((long)&rom_data->type) != 0) && (BIOS_IN8((long)&rom_data->indicator) != 0));  // make sure we got x86 version
	if(BIOS_IN8((long)&rom_data->type) != 0)
		return;
	rom_size = (unsigned long)BIOS_IN8((long)&rom_header->size) * 512;
	if(PCI_CLASS_DISPLAY_VGA == BIOS_IN16((long)&rom_data->class_hi))
	{
#ifdef USE_SDRAM
#if 0
		if(os_magic == 1)
		{
			biosmem = Mxalloc(SIZE_EMU, 3);
			if(biosmem == 0)
				return;
		}
#endif
#else
		biosmem = Mxalloc(SIZE_EMU, 0);
		if(biosmem == 0)
			return;
#endif /* USE_SDRAM */
		memset((char *)biosmem, 0, SIZE_EMU);
		setup_system_bios((char *)biosmem);
		DPRINTVALHEX("Copying VGA ROM Image from ", (long)rinfo->bios_seg+(long)rom_header);
		DPRINTVALHEX(" to ", biosmem+PCI_VGA_RAM_IMAGE_START);
		DPRINTVALHEX(", ", rom_size);
		DPRINT(" bytes\r\n");
#if 0 // 8 bits copy
		ptr = (char *)biosmem;
		for(i = (long)rom_header, j = PCI_VGA_RAM_IMAGE_START; i < (long)rom_header+rom_size; ptr[j++] = BIOS_IN8(i++));
#if 0
		{
			extern u32 swap_long(u32 val);
			unsigned long sum = 0, data;
			unsigned char *ptr2;
			ptr = (char *)0x01100000;
			ptr2 = ptr;
			memset((char *)ptr, 0, SIZE_EMU);
			for(i = (long)rom_header, j = PCI_VGA_RAM_IMAGE_START; i < (long)rom_header+rom_size; i+=4, j+=4)
			{
				data = swap_long(BIOS_IN32(i));
				sum += data;
				*((unsigned long *)&ptr[j]) = data;
			}
			ptr = (char *)biosmem;
			for(i = (long)rom_header, j = PCI_VGA_RAM_IMAGE_START; i < (long)rom_header+rom_size; i++)
			{
			  if(ptr[j] != ptr2[j])
			  {
					DPRINTVALHEXBYTE("VGA ROM error read ", ptr[j]);
					DPRINTVALHEXBYTE(" / ", ptr2[j]);
					DPRINTVALHEXLONG(" at ", (long)&ptr[j]);
					DPRINT("\r\n");
			  }
			  j++;
			}
			DPRINTVALHEXLONG("VGA ROM checksum ", sum);
			DPRINT("\r\n");
		}
#endif
#else // 32 bits copy
		{
			extern u32 swap_long(u32 val);
			long bytes_align = (long)rom_header & 3;
			ptr = (unsigned char *)biosmem;
			i = (long)rom_header;
			j = PCI_VGA_RAM_IMAGE_START;
			if(bytes_align)
				for(; i < 4 - bytes_align; ptr[j++] = BIOS_IN8(i++));
			for(; i < (long)rom_header+rom_size; *((unsigned long *)&ptr[j]) = swap_long(BIOS_IN32(i)), i+=4, j+=4);
		}
#endif
		addr = PCI_VGA_RAM_IMAGE_START;	
	}
	else
	{
#ifdef USE_SDRAM
#if 0
		if(os_magic == 1)
		{
			biosmem = Mxalloc(SIZE_EMU, 3);
			if(biosmem == 0)
				return;
		}
#endif
#else
		biosmem = Mxalloc(SIZE_EMU, 0);
		if(biosmem == 0)
			return;
#endif /* USE_SDRAM */
		setup_system_bios((char *)biosmem);
		memset((char *)biosmem, 0, SIZE_EMU);
		DPRINTVALHEX("Copying non-VGA ROM Image from ", (long)rinfo->bios_seg+(long)rom_header);
		DPRINTVALHEX(" to ", biosmem+PCI_RAM_IMAGE_START);
		DPRINTVALHEX(", ", rom_size);
		DPRINT(" bytes\r\n");		
		ptr = (unsigned char *)biosmem;
		for(i = (long)rom_header, j = PCI_RAM_IMAGE_START; i < (long)rom_header+rom_size; ptr[j++] = BIOS_IN8(i++));
		addr = PCI_RAM_IMAGE_START;
	}
	initialcs = (addr & 0xF0000) >> 4;
	initialip = (addr + 3) & 0xFFFF;	
	X86EMU_setMemBase((void *)biosmem, SIZE_EMU);
	for(i = 0; i < 256; i++)
		intFuncs[i] = do_int;
	X86EMU_setupIntrFuncs(intFuncs);
	{
		char *date = "01/01/99";
		for(i = 0; date[i]; i++)
			wrb(0xffff5 + i, date[i]);
		wrb(0xffff7, '/');
		wrb(0xffffa, '/');
	}
	{
    /* FixME: move PIT init to its own file */
    outb(0x36, 0x43);
    outb(0x00, 0x40);
    outb(0x00, 0x40);
	}
//	setup_int_vect();
	/* cpu setup */
	X86_AX = devfn ? devfn : 0xff;
	X86_DX = 0x80;
	X86_EIP = initialip;
	X86_CS = initialcs;
	/* Initialize stack and data segment */
	X86_SS = initialcs;
	X86_SP = 0xfffe;
	X86_DS = 0x0040;
	X86_ES = 0x0000;
	/* We need a sane way to return from bios
	 * execution. A hlt instruction and a pointer
	 * to it, both kept on the stack, will do.
	 */
	pushw(0xf4f4);    /* hlt; hlt */
//	pushw(0x10cd);    /* int #0x10 */
//	pushw(0x0013);    /* 320 x 200 x 256 colors */
// //	pushw(0x000F);    /* 640 x 350 x mono */
//	pushw(0xb890);    /* nop, mov ax,#0x13 */
	pushw(X86_SS);
	pushw(X86_SP + 2);
#ifdef DEBUG_X86EMU
	X86EMU_trace_on();
  X86EMU_set_debug(DEBUG_DECODE_F | DEBUG_TRACE_F);
#endif
	DPRINT("X86EMU entering emulator\r\n");
	*vblsem = 0;
	X86EMU_exec();
	*vblsem = 1;
	DPRINT("X86EMU halted\r\n");
//	biosfn_set_video_mode(0x13); /* 320 x 200 x 256 colors */
#ifdef USE_SDRAM
#if 0
	if(os_magic == 1)
	{
		memset((char *)biosmem, 0, SIZE_EMU);
		Mfree(biosmem);
	}
#endif
#else
	memset((char *)biosmem, 0, SIZE_EMU);
	Mfree(biosmem);
#endif /* USE_SDRAM */
}
