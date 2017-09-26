/*	@(#)vmecr.h	1.5		*/
/*
 *	VME/10 Control Map Definitions
 */

/* 	used to describe character and attribute generator RAM */
typedef struct
{
	BYTE	fill;
	BYTE	mem;
} GENRAM;

/*	Character Generator RAM */
#define	CGENADR	((BYTE *)0xf14000)
#define	CGENSZ	4096
typedef GENRAM (*CGENRAM)[CGENSZ];

/*	Attribute Generator RAM */
#define	AGENADR	((BYTE *)0xf15000)
#define	AGENSZ	4096
typedef GENRAM (*AGENRAM)[AGENSZ];

/*	Display RAM */
#define	DISPADR	((WORD *)0xf17000)
#define DISPSZ	8192
/* typedef	WORD (*DISPRAM)[DISPSZ]; defined in v10con.h */

/*	information necessary to access the CRTC (the screen controller)     */

typedef struct			/* map of the registers for the CRTC  */
{
	char	addr_reg;	/* address register selects which 
				 * register to write in register file
				 */
	char	fill2;
	char	reg_file;	/* data to registers goes here	     */
} crtc_map;

#define CRTC_ADDR	((crtc_map *)0xf1a021) /* address of the CRTC	     */
#define CURHIGH		14
#define CURLOW		15

/*
 *	VME/10 Control Register block.
 */


typedef	struct
{
	WORD	grafvcurs;	/* graphics cursor positioning vertical */
	WORD	grafhcurd;	/* graphics cursor positioning horizontal */
	BYTE	fill0;
	BYTE	cr0;		/* control register 0 */
	BYTE	fill1;
	BYTE	cr1;		/* control register 1 */
	BYTE	fill2;
	BYTE	cr2;		/* control register 2 */
	BYTE	fill3;
	BYTE	cr3;		/* control register 3 */
	BYTE	fill4;
	BYTE	cr4;		/* control register 4 */
	BYTE	fill5;
	BYTE	cr5;		/* control register 5 */
	BYTE	fill6;
	BYTE	cr6;		/* control register 6 */
	BYTE	fill7;
	BYTE	grafofst;
} *VMECRP ;



	/*
	**  Control Register Values
	**	for more precise definitions, see the VME/10 MICROCOMPUTER 
	**	SYSTEM REFERENCE MANUAL.
	*/

/*  cr0									*/
#	define	C0_CDIS		0x0e0	/*  mask for Char Disab bits	*/
#	define	C0_CURBK	0x010	/*  T: char cursor blinks	*/
#	define	C0_DUTYCYCLE	0x008	/*  T: correct bx syndrome 	*/
#	define	C0_IVS		0x004	/*  T: Invert Video		*/
#	define	C0_TIMIMSK	0x002	/*  T: Enable RTC Interrupts 	*/
#	define	C0_DMAIMSK	0x001	/*  T: Enable DMA IRQ		*/
/*  cr1									*/
#	define	C1_RES		0x080	/*  Reserved; keep cleared	*/
#	define	C1_SEL		0x060	/*  Mask For Cursor Selec (0-3)	*/
#	define	C1_HIRES	0x010	/*  Affects SCM Sys RAM Mapping	*/
#	define	C1_GRE		0x00e	/*  Graphics Enable.		*/
#	define	C1_UNSWAP	0x001	/*  RAM/ROM swap control 	*/
/*  cr2									*/
#	define	C2_RXIENAB	0x080	/*  F: Inhibit RXRDY* ints	*/
#	define	C2_SYSFENAB	0x040	/*  F: Inhibit SYSFAIL ints	*/
#	define	C2_WENAB	0x020	/*  F: Inhibit wr to SCM RAM 	*/
#	define	C2_KBDRST	0x010	/*  F: Keyboard Reset (KBDRST*)	*/
#	define	C2_VMEAVENAB	0x008	/*  F: Inhibit buss avail ints	*/
#	define	C2_BCLRENAB	0x004	/*  F: Inhibit BCLR* ints	*/
#	define	C2_TXIENAB	0x002	/*  F: Inhibit TXRDY* ints	*/
#	define	C2_MMUIENAB	0x001	/*  F: Inhibit MMUIRQ* ints	*/
/*  cr3									*/
#	define	C3_IRQ7ENAB	0x080	/*  F: Inhibit IRQ7 ints	*/
#	define	C3_IRQ6ENAB	0x040	/*  F: Inhibit IRQ6 ints	*/
#	define	C3_IRQ5ENAB	0x020	/*  F: Inhibit IRQ5 ints	*/
#	define	C3_IRQ4ENAB	0x010	/*  F: Inhibit IRQ4 ints	*/
#	define	C3_IRQ3ENAB	0x008	/*  F: Inhibit IRQ3 ints	*/
#	define	C3_IRQ2ENAB	0x004	/*  F: Inhibit IRQ2 ints	*/
#	define	C3_IRQ1ENAB	0x002	/*  F: Inhibit IRQ1 ints	*/
#	define	C3_VBIAENAB	0x001	/*  F: Inhibit SCM ints		*/
/*  cr5									*/
#	define	C5_BRDFAIL	0x080	/*  T: Drives SYSFAIL* low	*/
#	define	C5_AMA		0x040	/*  Alter addr mod line logic	*/
#	define	C5_VMETOOEN	0x020	/*  T: Enable bus time-out	*/
#	define	C5_LTOEN	0x010	/*  T: enable loc rsrc time out	*/
#	define	C5_BRC		0x00c	/*  bus req clear mask		*/
#		define	C5B_ROR		0x000	/*  rel on request	*/
#		define	C5B_ROBC	0x004	/*  rel on bus clear	*/
#		define	C5B_RWD		0x008	/*  rel when done	*/
#		define	C5B_RN		0x00c	/*  release never	*/
#	define	C5_BRL		0x003	/*  bus req level mask		*/
/*  cr6									*/
#	define	C6_IMSK		0x080	/*  F: Inhibit all SCM MPU ints	*/
#	define	C6_I4MSK	0x040	/*  F: Inhibit INT4 ints	*/
#	define	C6_I3MSK	0x020	/*  F: Inhibit INT3 ints	*/
#	define	C6_I2MSK	0x010	/*  F: Inhibit INT2 ints	*/
#	define	C6_I1MSK	0x008	/*  F: Inhibit INT1 ints	*/
#	define	C6_GENINT	0x007	/*  Mask for gen'g interrupts	*/
/*  status register							*/
#	define	ST_SWTCH	0x0e0	/*  always set			*/
#	define	ST_KBDENAB	0x010	/*  T: Keyboard Unlocked	*/
#	define	ST_IOCHEN	0x008	/*  always set			*/
#	define	ST_SYSFAIL	0x004	/*  T: drive SYSFAIL* low	*/
#	define	ST_VBIACK	0x002	/*  F: int gen'd by SCM is ackd	*/
#	define	ST_VMEAV	0x001	/*  T: SCM has bus mastership	*/

/*
**  address and size of control register
**	VME10CR - old style mnemonic for reg base addr
**	VMECRADDR - base address for vme-10 control register
**	VME10CRSZ - ?
*/

#define	VME10CR		((BYTE *)0xf19f00)
#define	VMECRADDR	((VMECRP)(0xf19f00))
#define VME10CRSZ	20

/*
 *	status register for the VME/10 - VMEC1 Processor Board
 */

#define VME10ST		((BYTE *)0xf19f85)
#define	VMESTADDR	VME10ST
#define VME10STSZ	1

typedef BYTE *VMESTP;

