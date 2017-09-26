/*  kb.c - interrupt driven keyboard driver				*/


/*
**  this code stolen from CDOS driver code.  so if it looks kind of funny
**  (calls to non-existent system routines), it's just for convenience...
**  the call is probably macro'd out to a dummy statement.
**	02 FEB 86 - ktb
*/

/*
**  CDOS - set this to true to enable CDOS/68k code.  This is mostly here
**	to comment out the CDOS specific code which can't possibly be
**	mapped into GEMDOS code.
*/

#define	CDOS	0

#if	CDOS
#	define	SETVEC	setvec
#else
#	define	mapphys(x)		null(x)
#	define	SETVEC(x,y)		null(x,y)
#	define	doasr(f,p1,p2,x)	f(p1,p2)
#	define	DVR_KEYBD		0L
#	define	E_SUCCESS		0L
	long	null() ;
#endif

/*=======================================================================*/
/*/---------------------------------------------------------------------\*/
/*|									|*/
/*|   Interrupt driven keyboard driver for Concurrent 4.0		|*/
/*|   for the VME/10							|*/
/*|			Copyright 1984, Motorola Inc.			|*/
/*|									|*/
/*\---------------------------------------------------------------------/*/
/*=======================================================================*/

#define	MAXUNITS	1

#include "portab.h"
#include "vmecr.h"
#include "vmkb.h"
/*  #include "system.h" */
/*  #include "io.h"	*/
/*  #include "vcdrv.h"	*/

/************************************************************************/
/*									*/
/*	Driver Header Table - must be first thing in data section	*/
/*									*/
/************************************************************************/

LONG kbinit();		LONG kbsubdrv();	LONG kbuninit();
LONG kbselect();	LONG kbflush();		LONG kbread();
LONG kbwrite();		LONG kbget();		LONG kbset();
LONG kbspecial();

#if	CDOS
DH	kbhdr =
	{
		NULL,
		MAXUNITS,
		DHF_DSYNC,		/* Driver Level Interface */
		kbinit,
		kbsubdrv,
		kbuninit,
		kbselect,
		kbflush,
		kbread,
		kbwrite,
		kbget,
		kbset,
		kbspecial,
		NULL, NULL, NULL,
		NULL,
		(LONG (**)())NULL,
	};
#endif

/*
 *	define the ISR and ASR routines.
 */

WORD	kbint();
WORD	kbasr();

#define KBVECNUM	((LONG)0x42)	/* vector number for keyboard ints */
#define KBASRPRI	((BYTE)200)	/* keyboard ASR priority */

/*
 *	SCCS identification string accessible at run-time.
 *	not referenced explicitly but appears in symbol table.
 */

BYTE	kbver[] = "@(#)vmkb.c	1.30";

/*
 *	static block to store the select info from the select blk
 */

#if	CDOS
static CDSELECT selblk;
#endif

/*
 *
 *	KEYBOARD -- ROUTINES FOR HANDLING THE VME/10 KEYBOARD.
 *
 *	ENVIRONMENT:  This is part of the VME/10 console driver for the
 *	  Concurrent DOS Operating System.
 *
 *	FUNCTION:  These routines provide initialization and interrupt
 *	  service for the VME/10 keyboard, which is connected to the
 *	  processor board through a 2661 half-duplex serial port.
 *
 *	NOTES:  This module is very much table-driven, so pains have been
 *	  taken to reduce the size of the tables.  You will find byte and
 *	  word offsets instead of longword addresses, and where feasible
 *	  calculations are used instead of tables to generate characters.
 *
 */

/*	DIAGRAM DEPICTING THE ROLES OF THE VARIOUS TABLES
 *
 * 
 *                                        routine
 *                                        offsets
 *         scan                             ---
 *         code            - is routine    |   |
 *         table               index       |   |
 *          ---             ,------------->|   |-------------> Alpha Keys
 *  scan   |   |           /               |   |               Function Keys
 *  code   |   |          /                 ---
 * ------->|   |---------<
 *         |   |   \      \                 ---
 *          ---     |      \               |   |
 *                  |       `------------->|   |--------.
 *                  |       + is group     |   |        |      char
 *                  |          index       |   |        |      table
 *                  |                       ---         `-----> ---
 *                  |                      group               |   |
 *                  | parameter           offsets              |   |
 *                  |                                  .------>|   |
 *                  |                                  |       |   |
 *                  `----------------------------------'        ---
 *
 *
 *
 * When a scan code is received, it is used as an index into the SCAN CODE
 * TABLE to get a group/routine index and a parameter.
 *
 * If the group/routine index is positive, then it is a group index.  The
 * corresponding offset is taken from the GROUP TABLE, giving the address
 * of the character table currently in effect for that group.  The parameter
 * is used as an index into the character table to retrieve the character.
 */

VOID		mode_chg();

typedef struct				/* entry in the scan code table	     */
{
	BYTE	grp_rout_x;		/* group/routine index		     */
	BYTE	arg;			/* a parameter			     */
} sc_tbl;

/*
 *	MODE TYPES
 *
 *	These bit flags are set in the "modes" byte
 *	based on the state of control keys on the keyboard
 *	(shift, alpha lock, control, alt, pad).
 *
 *	they currently must fit in a BYTE as they are used in
 *	the scan code decode table.
 *
 *	For Concurrent DOS 4.0
 *	the CTRL, ALT and SHIFT bits are also passed back through the return
 *	value as state information in some cases.  They are shifted left
 *	one byte to the high order control byte of the return value.
 *	Do not change the positions of the flags.
 */
 
#define CTRL	0x01			/* CTRL is down.		     */
#define ALT	0x02			/* ALT is down.			     */
#define SHIFT	0x04			/* one or both of shift keys is down */
#define PAD	0x08			/* FUNC/PAD is down (PAD).	     */
#define CAPS_LOCK 0x10			/* ALPHA LOCK is down. 		     */
#define BLANK	0x20		 	/* blank locking mode key is down    */
#define ALOCK_OR_SHIFT (CAPS_LOCK|SHIFT)  /* either lock or shift are down  */

/*
 *	macro for "getting the state" into the high byte.
 */

#define getstate(s)	((modes&(s))<<8)

/*
 *	Support for Concurrent DOS specific information.
 *
 *	the function key bit and the special key bit occupy
 *	the high order byte of the return value along with 
 *	possible state information.
 */

#define FUNCTION	0x1000
#define SPECIAL		0x2000

/*
 *	some defines to eliminate magic numbers...
 */

#define _ESC	0x1b			/* \033 - escape character */

#define _NULL	0x0			/* no character flag */

/*
 *	SPECIAL - special key return values
 */

#define _BREAK		0x05
#define _RESET		0x06		/* REDRAW Concurrent function */
#define _CLEAR		_NULL

#define _TEST		_NULL
#define _HELP		0x7F	/* TEMP KLUDGE - SHOULD BE 0, BUT 0 MEANS NO C */

#define	_ZERO	0x20
#define	_ONE	0x21
#define	_TWO	0x22
#define	_THREE	0x23
#define	_FOUR	0x24
#define	_FIVE	0x25
#define	_SIX	0x26
#define	_SEVEN	0x27
#define	_EIGHT	0x28
#define	_NINE	0x29
#define	_A	0x2A
#define	_B	0x2B
#define	_C	0x2C
#define	_D	0x2D
#define	_E	0x2E
#define	_F	0x2F
#define	_COMMA	0x31
#define _PERIOD	0x32

	/* Group 0 keys. */

#define _ENTER		0x30
#define _HOME		0x18
#define _UP		0x10
#define _DOWN		0x11
#define _LEFT		0x12
#define _RIGHT		0x13
#define _BACKTAB	_NULL	/* undefined */

	/*
	 * Don't know what to do with these EXORterm 155 specific
	 * codes.  They belong to group 2 under control of the
	 * "PAD/FUNC" locking key.  _NULL for now.
	 */

#define _DCHR	_NULL
#define _DLINE	_NULL
#define _PMODE	_NULL
#define _EOF	_NULL
#define _EOL	_NULL
#define _EOP	_NULL
#define _EAU	_NULL
#define _ICHR	_NULL
#define _ILINE	_NULL

/*
 *	Some special keys I need right away,
 *	mapping to keyboard not quite clean.
 */

#define _WIND	0x01
#define _NEXT	0x02
#define _PREV	0x03

/*
 *	static pointer to vme status register.
 */
	
static VMESTP vmec1_status;

/*
 *	static pointer to VME/10 control register block.
 */

static VMECRP	vmecr;		/* pointer to the vme/10 register blk */

#define KBD_UNLOCK 	0x10		/* status of the lock on the front 
					   panel, which we interpret as a 
					   keyboard lock: 0 if keyboard 
					   locked; 1 if unlocked  	     */

#define LEFT		0x01		/* left shift key is down	     */
#define RIGHT		0x02		/* right shift key is down	     */

static BYTE	 modes;			/* value of modes reflect the status
					   (up | down) of mode keys on 	     */
static BYTE	 shift_keys;		/* Bits in this byte reflect status
					   (up * or down) of two SHIFT keys. */

	/* Declarations for the 2661 (EPCI) connecting us to the keyboard.   */
 
#define EPCI_ADDR	0xf1a031	/* Base address of the 2661.	     */
 
typedef struct  			/* map of the 2661 registers	     */
{
	BYTE	data;			/* data register		     */
	BYTE	fill2, status;		/* status register		     */
	BYTE	fill4, mode;		/* mode register		     */
	BYTE	fill6, command;		/* command register		     */
} epci_map;
 
static epci_map	*epci;		/* pointer to the epci register blk */

	/* Bit definitions for the 2661 status register.		     */
 
#define CHAR_AVAIL 	0x02		/* a received char is in DATA reg.   */
#define PARITY		0x08 		/* received char had a parity error. */
#define OVERRUN		0x010		/* receive buffer was overrun.	     */
#define FRAMING		0x020		/* received char had a framing error.*/
#define ANY_ERROR	0x038		/* Mask selecting all 3 errors.      */
 
	/*  Initialization values for the 2661 control registers.	     */
 
#define MODE1_INIT	0x5e		/* Initialization for mode reg 1     */
#define MODE2_INIT	0x7b		/* Initialization for mode reg 2     */
#define COMM_INIT	0x15		/* Initialization for command reg    */
 
	/* Commands for keyboard.  In each, bits 0-3 = $0 are keyboard's ID. */
 
#define SELECT_KB	0x80		/* SELECT command.		     */
#define READ_KB		0xa0		/* READ   command.		     */
#define AGAIN_KB	0xd0		/* AGAIN  command; this causes last
                                           scan code sent to be repeated.    */
 
#define KB_RESET	0x10		/* when low, holds keyboard in reset.*/
#define KB_ENABLE	0x80		/* when high, enables receipt 
					   interrupts from the 2661 which 
					   connects us to the keyboard.	     */
 
	/* status values returned by keybd_read	     */

#define NOCHAR		0		/* no character was returned	     */
#define IN_CHAR		1		/* a real live character available   */

 
/******************************************************************************
   
	ROUTINE AND GROUP OFFSET TABLES
   
	FUNCTION:  Each entry in the scan code table contains a byte value
	  called the group/routine index.  If it is negative it is a routine 
	  index and is used as the index in a switch statement.
	  If is is positive, it is a group index and is
	  an offset into grp_tbl_ptr.  These tables contain word offsets to
	  routines or tables in this module.  The whole purpose for these guys
	  is to allow each scan code table entry to be just 2 bytes long.

******************************************************************************/

/*
 * If the group/routine index is negative, then it is a routine index.  The
 * index is one of the integral types "rtn_index" and is used as the 
 * switch index in a switch statement.  The parameter may or may not be 
 * used by the routine.
 *
 * Also note that rtn_index starts at 1 so that there is no entry #0 in 
 * the routine table; this is necessary since negative 0 is 0 and that index
 * would be indistinguishable from the positive 0 index in the group table.
 *
 * Note: the NONLOCKABLE define.  Routine indexes which
 * are less than or equal to it will not be executed while the keyboard
 * lock on the front panel is in the LOCKED position--only when it is
 * UNLOCKED.  Routines indexes greater than it are called regardless
 * of the keyboard lock's status.
 */
 
#define TWO_AT		1
#define ESC_RESET	2
#define BREAK_CLEAR	3
#define GEN_ALPHA	4
#define FNKEY		5
#define NONLOCKABLE	5
#define SET_SHIFT	6
#define CLR_SHIFT	7
#define SET_MODE	8
#define CLR_MODE	9
#define IGNORE		10

typedef WORD rtn_index;
 
/******************************************************************************
   
	SCAN CODE TABLE -- CONVERTS A SCAN CODE TO GROUP/ROUTINE INDEX
			   & PARAMETER.

	FUNCTION:  The scan code taken from the 2661 is
	  used as an index into this table.  This table contains a 2-byte
	  entry for each possible scan code:  a 1-byte group/routine index
	  (see the offset table, OFF_TBL) and a parameter.

******************************************************************************/
 
/*
 * The rtn macro is used to make entries in the scan code table for those
 * scan codes which will result in an entry in a switch statement being 
 * invoked.  The format is
 *
 *	 RTN (<routine_index>, <arguments>)
 *
 * The first argument is the name of the routine to go to when this scan
 * code is received.  The second argument, which is optional, is a parameter
 * to pass to the routine.  That is, the same routine may be used with many
 * different scan codes, each passing a different argument.
 */
 
#define RTN(ri, mode)	-ri, mode,

/*
 * The ALPHA macro is used to make entries in the scan code table for those
 * scan codes which will generate alphabetic characters.  The format is
 *
 *	ALPHA <uppercase alphabetic character>
 */
 
#define ALPHA(c)	-GEN_ALPHA,c,

/*
 * The GROUP macro is used to make entries in the scan code table for those
 * scan codes which have entries in character tables.  The format is
 *
 *   GROUP <group index>,<element # within group>
 *
 * Both arguments are required.  The first is 0,1,...whatever the highest
 * group index is.  The second argument is the index into the chosen 
 * character table for this scan code.
 */

#define GROUP(grpnm, index)	grpnm, index,

static sc_tbl			/* scan code      key		*/
	scan_code_tbl[] = {	/*   ----      ---------------	*/
	RTN(IGNORE,0)		/* 00 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 01 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 02 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 03 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 04 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 05 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 06 -- Ignore it.		*/
	RTN(SET_MODE,CAPS_LOCK) /* 07 -- ALPHA LOCK depressed.	*/
	RTN(SET_SHIFT,LEFT)	/* 08 -- Left  SHIFT depressed.	*/
	RTN(SET_SHIFT,RIGHT)	/* 09 -- Right SHIFT depressed.	*/
	RTN(SET_MODE,CTRL)	/* 0A -- CTRL depressed.	*/
	RTN(SET_MODE, ALT)	/* 0B -- ALT  depressed.	*/
	RTN(SET_MODE, BLANK)	/* 0C -- Blank locking mode key */
	RTN(IGNORE,0)		/* 0D -- Clacker mode key	*/ 
	RTN(SET_MODE, PAD)	/* 0E -- FUNC_PAD depressed.	*/
	RTN(CLR_MODE,CAPS_LOCK) /* 0F -- ALPHA LOCK released.	*/
	RTN(IGNORE,0)		/* 10 -- Ignore it.		*/
	GROUP(1,0 )		/* 11 -- ` ~ key.		*/
	GROUP(1,1 )		/* 12 -- 1 ! key.		*/
	RTN(TWO_AT, 0)		/* 13 -- 2 @ key.		*/
	GROUP(1,2 )		/* 14 -- 3 # key.		*/
	GROUP(1,13)		/* 15 -- TAB key on main keybd.	*/
	ALPHA('Q')		/* 16 -- Q key.			*/
	ALPHA('W')		/* 17 -- W key.			*/
	ALPHA('E')		/* 18 -- E key.			*/
	ALPHA('A')		/* 19 -- A key.			*/
	ALPHA('S')		/* 1A -- S key.			*/
	ALPHA('D')		/* 1B -- D key.			*/
	ALPHA('Z')		/* 1C -- Z key.			*/
	ALPHA('X')		/* 1D -- X key.			*/
	GROUP(1,23)		/* 1E -- Space bar.		*/
	RTN(CLR_SHIFT, LEFT)	/* 1F -- Left SHIFT key released.*/
	RTN(IGNORE,0)		/* 20 -- Ignore it.		*/
	RTN(FNKEY, 1)		/* 21 -- Function key 1.	*/
	RTN(FNKEY, 2)		/* 22 -- Function key 2.	*/
	RTN(FNKEY, 3)		/* 23 -- Function key 3.	*/
	GROUP(1,3 )		/* 24 -- 4 $ key.		*/
	GROUP(1,4 )		/* 25 -- 5 % key.		*/
	GROUP(1,5 )		/* 26 -- 6 ^ key.		*/
	ALPHA('R')		/* 27 -- R key.			*/
	ALPHA('T')		/* 28 -- T key.			*/
	ALPHA('Y')		/* 29 -- Y key.			*/
	ALPHA('F')		/* 2A -- F key.			*/
	ALPHA('G')		/* 2B -- G key.			*/
	ALPHA('C')		/* 2C -- C key.			*/
	ALPHA('V')		/* 2D -- V key.			*/
	ALPHA('B')		/* 2E -- B key.			*/
	RTN(CLR_SHIFT, RIGHT)	/* 2F -- Right SHIFT key released*/
	RTN(IGNORE,0)		/* 30 -- Ignore it.		*/
	RTN(FNKEY,4)		/* 31 -- Function key 4.	*/
	RTN(FNKEY,5)		/* 32 -- Function key 5.	*/
	RTN(FNKEY,6)		/* 33 -- Function key 6.	*/
	GROUP(1,6 )		/* 34 -- 7 & key.		*/
	GROUP(1,7 )		/* 35 -- 8 * key.		*/
	GROUP(1,8 )		/* 36 -- 9 ( key.		*/
	ALPHA('U')		/* 37 -- U key.			*/
	ALPHA('I')		/* 38 -- I key.			*/
	ALPHA('H')		/* 39 -- H key.			*/
	ALPHA('J')		/* 3A -- J key.			*/
	ALPHA('K')		/* 3B -- K key.			*/
	ALPHA('N')		/* 3C -- N key.			*/
	ALPHA('M')		/* 3D -- M key.			*/
	GROUP(1,20)		/* 3E -- , < key.		*/
	RTN(CLR_MODE,CTRL)	/* 3F -- CTRL key released.	*/
	RTN(IGNORE,0)		/* 40 -- Ignore it.		*/
	RTN(FNKEY,7)		/* 41 -- Function key 7.	*/
	RTN(FNKEY,8)		/* 42 -- Function key 8.	*/
	GROUP(1,9 )		/* 43 -- 0 ) key.		*/
	GROUP(1,10)		/* 44 -- - _ key.		*/
	GROUP(1,11)		/* 45 -- = + key.		*/
	ALPHA('O')		/* 46 -- O key.			*/
	ALPHA('P')		/* 47 -- P key.			*/
	GROUP(1,14)		/* 48 -- [ { key.		*/
	ALPHA('L')		/* 49 -- L key.			*/
	GROUP(1,17)		/* 4A -- : ; key.		*/
	GROUP(1,18)		/* 4B -- ' " key.		*/
	GROUP(1,21)		/* 4C -- .			*/
	GROUP(1,22)		/* 4D -- / ? key.		*/
	RTN(IGNORE,0)		/* 4E -- Ignore it.		*/
	RTN(CLR_MODE,ALT)	/* 4F -- ALT key released.	*/
	RTN(IGNORE,0)		/* 50 -- Ignore it.		*/
	RTN(FNKEY,9)		/* 51 -- Function key 9.	*/
	RTN(FNKEY,10)		/* 52 -- Function key 10.	*/
	RTN(FNKEY,11)		/* 53 -- Function key 11.	*/
	RTN(FNKEY,12)		/* 54 -- Function key 12.	*/
	GROUP(1,12)		/* 55 -- DEL key.		*/
	RTN(BREAK_CLEAR, 0)	/* 56 -- BREAK CLEAR key.	*/
	GROUP(1,15)		/* 57 -- ] } key.		*/
	GROUP(1,16)		/* 58 -- \ | key.		*/
	GROUP(0,1 )		/* 59 -- Home key.		*/
	GROUP(1,19)		/* 5A -- Return key.		*/
	GROUP(0,3 )		/* 5B -- Backarrow key.		*/
	GROUP(0,7)		/* 5C -- SEL key.		*/
	GROUP(0,9)		/* 5D -- Backtab key.		*/
	GROUP(0,6 )		/* 5E -- Downarrow key.		*/
	RTN(CLR_MODE,BLANK)	/* 5F -- lock mode key released.*/
	RTN(CLR_MODE,PAD)	/* 60 -- PAD key released.	*/
	RTN(FNKEY,13)		/* 61 -- Function key 13.	*/
	RTN(FNKEY,14)		/* 62 -- Function key 14.	*/
	RTN(FNKEY,15)		/* 63 -- Function key 15.	*/
	RTN(FNKEY,16)		/* 64 -- Function key 16.	*/
	RTN(ESC_RESET, 0)	/* 65 -- ESC RESET key.		*/
	GROUP(2,10)		/* 66 -- A DCHR key.		*/
	GROUP(0,2 )		/* 67 -- Uparrow key.		*/
	RTN(IGNORE,0)		/* 68 -- CLR TAB SET key.	*/
	GROUP(2,7 )		/* 69 -- 7 EOF key.		*/
	GROUP(0,4 )		/* 6A -- Rightarrow key.	*/
	GROUP(2,4 )		/* 6B -- 4 key on hexpad.	*/
	GROUP(0,8)		/* 6C -- Tab key on cursor pad.	*/
	GROUP(2,1 )		/* 6D -- 1 ICHR key.		*/
	GROUP(2,0 )		/* 6E -- 0 on hexpad.		*/
	RTN(IGNORE,0)		/* 6F -- Clacker mode key release*/
	RTN(IGNORE,0)		/* 70 -- Ignore it.		*/
	GROUP(2,11)		/* 71 -- B DLINE key.		*/
	GROUP(2,12)		/* 72 -- C on hexpad.		*/
	GROUP(2,13)		/* 73 -- D on hexpad.		*/
	GROUP(2,8 )		/* 74 -- 8 EOL key.		*/
	GROUP(2,9 )		/* 75 -- 9 EOP key.		*/
	GROUP(2,14)		/* 76 -- E EAU key.		*/
	GROUP(2,5 )		/* 77 -- 5 on hexpad.		*/
	GROUP(2,6 )		/* 78 -- 6 on hexpad.		*/
	GROUP(2,15)		/* 79 -- F on hexpad.		*/
	GROUP(2,2 )		/* 7A -- 2 ILINE key.		*/
	GROUP(2,3 )		/* 7B -- 3 on hexpad.		*/
	GROUP(2,16)		/* 7C -- TEST , key.		*/
	GROUP(2,17)		/* 7D -- HELP .			*/
	GROUP(0,0 )		/* 7E -- ENTER key.		*/
	RTN(IGNORE,0)		/* 7F -- Ignore it.		*/
};


/******************************************************************************
   
        GROUP 0 CHARACTER TABLE -- KEYS UNAFFECTED BY MODE KEYS
   
        FUNCTION:  This table contains the characters to return for scan
          codes which fall into group 0.  Use the parameter obtained from
          the scan code table as an index into this table.  A value of 0
          will cause no character to result.
   
          Table tbl___ is used regardless of any mode keys.
   
******************************************************************************/

				/* element #			     */
static BYTE	tbl___[] = {	/* ---------			     */
	_ENTER,			/* 0 -- the ENTER key.		     */
	_HOME,			/* 1 -- Home.			     */
	_UP,			/* 2 -- the uparrow key		     */
	_LEFT,			/* 3 -- the leftarrow key.	     */
	_RIGHT,			/* 4 -- the rightarrow key.	     */
	_BACKTAB,		/* 5 -- Backtab.		     */
	_DOWN,			/* 6 -- the downarrow key.	     */
	_WIND,			/* 7 -- SEL key - switch windows     */
	_NEXT,			/* 8 -- TAB on cursor pad - next window */
	_PREV			/* 9 -- BACKTAB on cursor pad - previous window */
};

/******************************************************************************

	GROUP 1 CHARACTER TABLES -- KEYS AFFECTED BY SHIFT AND CTRL KEYS.

	FUNCTION:  These tables contain the characters to return for scan
	  codes which fall into group 1.  Use the parameter obtained from
	  the scan code table as an index into these tables.  A value of 0
	  in the table entry (when in CTRL mode) means that no ASCII 
	  character exists for that mode (SHIFT/CTRL) and character.

	  For example: no SHIFT, CTRL, '1' .

	  In that case, we must extract the right character based on the
	  shift key (from table tblnn_ or tblyn_) and `or' in the
	  CTRL key to yield a 16 bit value.

	  Table tblnn_ is used when we're in neither SHIFT nor CTRL.
	  Table tblny_ is used when we're in CTRL mode not SHIFTed.
	  Table tblyy_ is used when we're in CTRL mode and SHIFTed.
	  Table tblyn_ is used when we're in SHIFT but not CTRL  mode.

	NOTE: The DEL, TAB and SPACE BAR are unaffected by the SHIFT key.

******************************************************************************/
 
				/* element #			*/
static BYTE	tblnn_[] = {	/* ---------			*/
	'`' ,			/* 0.				*/
	'1' ,			/* 1.				*/
	'3' ,			/* 2.				*/
	'4' ,			/* 3.				*/
	'5' ,			/* 4.				*/
	'6' ,			/* 5.				*/
	'7' ,			/* 6.				*/
	'8' ,			/* 7.				*/
	'9' ,			/* 8.				*/
	'0' ,			/* 9.				*/
	'-' ,			/* 10.				*/
	'=' ,			/* 11.				*/
	0x7F ,			/* 12 -- DEL.			*/
	'\t' ,			/* 13 -- Tab key on keyboard.   */
	'[' ,			/* 14.				*/
	']' ,			/* 15.				*/
	'\\' ,			/* 16.				*/
	';' ,			/* 17.				*/
	'\'' ,			/* 18 -- Apostrophe.		*/
	'\r' ,			/* 19 -- Carriage Return	*/
	',' ,			/* 20.				*/
	'.' ,			/* 21.				*/
	'/' ,			/* 22.				*/
	' ' ,			/* 23.				*/
	'\t'			/* 24 -- Tab key on Number Pad  */
};

				/* element #			*/
static BYTE	tblny_[] = {	/* ---------			*/
	0   ,			/* 0.				*/
	0   ,			/* 1.				*/
	0   ,			/* 2.				*/
	0   ,			/* 3.				*/
	0   ,			/* 4.				*/
	0   ,			/* 5.				*/
	0   ,			/* 6.				*/
	0   ,			/* 7.				*/
	0   ,			/* 8.				*/
	0   ,			/* 9.				*/
	0   ,			/* 10.				*/
	0   ,			/* 11.				*/
	0   ,			/* 12.				*/
	0   ,			/* 13.				*/
	_ESC ,			/* 14 -- CTRL [.		*/
	0x1d ,			/* 15 -- CTRL ].		*/
	0x1c ,			/* 16 -- CTRL \.		*/
	0   ,			/* 17.				*/
	0   ,			/* 18.				*/
	0   ,			/* 19.				*/
	0   ,			/* 20.				*/
	0   ,			/* 21.				*/
	0   ,			/* 22.				*/
	0   ,			/* 23.				*/
	0			/* 24.				*/
};

				/* element #			*/
static BYTE	tblyy_[] = {	/* ---------			*/
	0   ,			/* 0.				*/
	0   ,			/* 1.				*/
	0   ,			/* 2.				*/
	0   ,			/* 3.				*/
	0   ,			/* 4.				*/
	0x1e ,			/* 5  -- CTRL ^.		*/
	0   ,			/* 6.				*/
	0   ,			/* 7.				*/
	0   ,			/* 8.				*/
	0   ,			/* 9.				*/
	0x1f ,			/* 10 -- CTRL _.		*/
	0   ,			/* 11.				*/
	0   ,			/* 12.				*/
	0   ,			/* 13.				*/
	0   ,			/* 14.				*/
	0   ,			/* 15.				*/
	0   ,			/* 16.				*/
	0   ,			/* 17.				*/
	0   ,			/* 18.				*/
	0   ,			/* 19.				*/
	0   ,			/* 20.				*/
	0   ,			/* 21.				*/
	0   ,			/* 22.				*/
	0   ,			/* 23.				*/
	0			/* 24.				*/
};

	                      /* element #			*/
static BYTE	tblyn_[] = {  /* ---------			*/
	'~' ,			/* 0.				*/
	'!' ,			/* 1.				*/
	'#' ,			/* 2.				*/
	'$' ,			/* 3.				*/
	'%' ,			/* 4.				*/
	'^' ,			/* 5.				*/
	'&' ,			/* 6.				*/
	'*' ,			/* 7.				*/
	'(' ,			/* 8.				*/
	')' ,			/* 9.				*/
	'_' ,			/* 10.				*/
	'+' ,			/* 11.				*/
	0x7f ,			/* 12 -- DEL.			*/
	'\t' ,			/* 13 -- HT (tab key on main keyboard)*/
	'{' ,			/* 14.				*/
	'}' ,			/* 15.				*/
	'|' ,			/* 16.				*/
	':' ,			/* 17.				*/
	'"' ,			/* 18.				*/
	'\r' ,			/* 19 -- Carriage Return	*/
	'<' ,			/* 20.				*/
	'>' ,			/* 21.				*/
	'?' ,			/* 22.				*/
	' ' ,			/* 23.				*/
	'\t'			/* 24.				*/
};

/******************************************************************************

     GROUP 2 CHARACTER TABLES -- KEYS AFFECTED ONLY BY FUNC/PAD KEY.

     FUNCTION:  These tables contain the characters to return for scan
	codes which fall into group 2.  Use the parameter obtained from
	the scan code table as an index into these tables.  A value of 0
	will cause no character to result.

	Table tbl__n is used when we're not in PAD mode.
	Table tbl__y is used when we are in PAD mode.

	NOTE: when the "PAD/FUNC" key is up, we deafult to the numeric
	pad (this makes sense since the "PAD" mnemonic is on the top
	on the key above "FUNC").  When the key is depressed (it locks)
	we are in the "FUNC" mode.

	These tables contain characters associated with the hexpad.  Note,
	however, that the ENTER key is not in these tables.

******************************************************************************/
 
	                   	/* element #			*/
static BYTE	tbl__y[] = {    /* ---------			*/
	0 ,			/* 0.				*/
	_ICHR ,			/* 1  				*/
	_ILINE ,		/* 2  				*/
	0 ,			/* 3.				*/
	0 ,			/* 4.				*/
	0 ,			/* 5.				*/
	0 ,			/* 6.				*/
	_EOF ,			/* 7.				*/
	_EOL ,			/* 8  				*/
	_EOP ,			/* 9  				*/
	_DCHR ,			/* 10 				*/
	_DLINE ,		/* 11 				*/
	0 ,			/* 12 				*/
	0 ,			/* 13.				*/
	_EAU ,			/* 14.				*/
	0 ,			/* 15.				*/
	_TEST ,			/* 16.				*/
	_HELP			/* 17.				*/
};

	                   	/* element #			*/
static BYTE	tbl__n[] = {	/* ---------			*/
	_ZERO ,			/* 0.-- 0			*/
	_ONE ,			/* 1.-- 1			*/
	_TWO ,			/* 2.-- 2			*/
	_THREE ,		/* 3.-- 3			*/
	_FOUR ,			/* 4.-- 4			*/
	_FIVE ,			/* 5.-- 5			*/
	_SIX ,			/* 6.-- 6			*/
	_SEVEN ,		/* 7.-- 7			*/
	_EIGHT ,		/* 8.-- 8			*/
	_NINE ,			/* 9.-- 9			*/
	_A ,			/* 10.-- A			*/
	_B ,			/* 11.-- B			*/
	_C ,			/* 12.-- C			*/
	_D ,			/* 13.-- D			*/
	_E ,			/* 14.-- E			*/
	_F ,			/* 15.-- F			*/
	_COMMA ,		/* 16.-- ,			*/
	_PERIOD ,		/* 17.-- .			*/
};

/*
 * grp_tbl_ptr is used when the group/routine index for a scan code is 
 * positive ( >=0 ). As mode keys are pressed, the address in the table
 * may get replaced.
 */

static BYTE	*grp_tbl_ptr[3] = { 
	tbl___,			/* Group 0: no mode keys affect these.*/
	tblnn_,			/* Group 1: SHIFT and CTRL affect     */
	tbl__n 			/* Group 2: PAD affects these.	      */
};

/*
 * The following table is indexed by (modes&(CTRL|SHIFT) to yield the
 * correct table in effect for a given state (based on the modes variable)
 * for the group 1 keys.
 *
 * Selection is based on CTRL and SHIFT keys
 *
 * In the current implementation, the ALT KEY is a don't care state
 * and ignored, so we have some null entries.
 */

static BYTE	*grp1_off[] = {
	tblnn_,			/* no SHIFT, no CTRL		*/
	tblny_,			/* no SHIFT,    CTRL		*/
	0,			/* don't care			*/
	0,			/* don't care			*/
	tblyn_,			/*    SHIFT, no CTRL		*/
	tblyy_,			/*    SHIFT,    CTRL		*/
	0,			/* don't care			*/
	0			/* don't care			*/
};

/*
 *	we need to delay a couple of times in the keyboard
 *	initialization routine to wait for the keyboard to reset.
 *	we use a supif() call and acess the F_TIMER function giving
 *	it and argument of milliseconds.
 *
 *	we implement it in terms of a macro.
 *
 */

struct timeblk	tb = { 0, 0, 0, 0, 0 };

#define DELAY(t)	{ \
				tb.t_time = (t); \
				supif(F_TIMER,&tb); \
			}

/******************************************************************************

               kbinit -- INITIALIZE THE VME/10 KEYBOARD              

	FUNCTION:  This routine resets the keyboard,
	  configures the 2661 so we can communicate with the keyboard.

	  Currently, however, we are not checking the self-test status,
	  and therefore there is no possibility of an error return.  The
	  hooks are left in to facilitate later enhancements.


******************************************************************************/
 
LONG kbinit(unitx)
LONG	unitx;
{
	REG BYTE cr;		/* to hold contents of control reg.   */
	MAPPB	pmap;		/* physical map block for mapphys()   */

	if( (BYTE)unitx > MAXUNITS )
		return(0L);		/* KLUDGE CITY - RETURN ERROR!!! */

	/* get access to vme/10 control registers */
	pmap.mpzero = 0;
	pmap.pbegaddr = (BYTE *) VME10CR;
	pmap.plength = VME10CRSZ;
	vmecr = (VMECRP)mapphys(&pmap);

	/* map the epci control register */
	pmap.pbegaddr = (BYTE *) EPCI_ADDR;
	pmap.plength = sizeof(epci_map);
	epci = (epci_map *)mapphys(&pmap);

	/* map the VMEC1 status register */
	pmap.pbegaddr = (BYTE *) VME10ST;
	pmap.plength = VME10STSZ;
	vmec1_status = (VMESTP)mapphys(&pmap);
 
	/* reset the keyboard */
	vmecr->cr2 &= (BYTE)(~KB_ENABLE);	/* disable keybd interrupts */
	vmecr->cr2 &= (~KB_RESET);	 /* set RESET line to keyboard	     */
	DELAY(1L);			 /* need to wait about 5 usecs - 
					  * granularity is 1 millisecond     */
	vmecr->cr2 |= KB_RESET;
	DELAY(500L);			 /* allow keyboard to get it's act 
					    together; about 1/2 second	     */
	/*
	 * Initialize the 2661.  Because 2661 mode register is 
	 * really two registers and the one you're writing to 
	 * depends upon sequence of prior writes, we must do this 
	 * with dispatches disabled.
	 */
   
	cr = epci->command;		/* read command register, which causes 
				 	   the mode reg. to point to reg 1.   */
	epci->mode = MODE1_INIT;	/* initialize mode register 1	     */
	epci->mode = MODE2_INIT;	/* initialize mode register 2	     */
	epci->command = COMM_INIT;	/* initialize the command register   */

	SETVEC(kbint,KBVECNUM);		/* set up Concurrent vector for ISR */

	return(DVR_KEYBD);
}
 


/*
 *	kbselect() selects the keyboard, and enables keyboard interrupts.
 */

#if	CDOS
LONG kbselect(selblkptr)
CDSELECT *selblkptr;
#else
LONG	kbselect()
#endif
{
	BYTE		reg;		/* dummy to hold data register value  */

	/*
	 *	save the keyboard physical input routine address
	 */

#if	CDOS
	bcopy(selblkptr,&selblk,sizeof(CDSELECT));
#endif

	/*
	 *	initialize physical console 0.
	 */

	epci->data = SELECT_KB;		/* send command to select keyboard   */

	/* wait for reception of char */
	while( !(epci->status & CHAR_AVAIL) ) 
		;

	/*
	 * Read response; if it's not an ACK (0) ignore the status
	 * since it is possible that the self-test failed
	 * 'cause someone was holding down a key and we don't want 
	 * such a minor thing to prevent the system from booting.
	 */

	reg = epci->data;		
	vmecr->cr2 |= KB_ENABLE;	/* enable keyboard interrupts	*/
	epci->data = READ_KB;		/* send a READ command so keyboard will
					   send us first scan code	    */
	return(E_SUCCESS);
}
 
#if	CDOS	/*********************************************************/
LONG kbuninit()
{
	vmecr->cr2 &= (BYTE)(~KB_ENABLE);	/* disable keybd interrupts */
	setvec((LONG)0,KBVECNUM);		/* restore vector */
	return(E_SUCCESS);
}

LONG kbflush()
{
	vmecr->cr2 &= (BYTE)~KB_ENABLE;	/* disable keyboard interrupts	*/
	return(E_SUCCESS);
}

/*
 *	undefined entries for Concurrent DOS.
 */

LONG kbsubdrv()
{
	return(E_IMPLEMENT);
}

LONG kbread()
{
	return(E_IMPLEMENT);
}

LONG kbwrite()
{
	return(E_IMPLEMENT);
}

LONG kbget()
{
	return(E_IMPLEMENT);
}

LONG kbset()
{
	return(E_IMPLEMENT);
}

LONG kbspecial()
{
	return(E_IMPLEMENT);
}
#endif		/*********************************************************/


/*
 *	SUPPORT ROUTINES
 */

/******************************************************************************

	kbdecode -- DECODE A SCANCODE FROM THE KEYBOARD

	FUNCTION:  decode the scancode received from the keyboard
		   and return the corresponding character.

******************************************************************************/

UWORD kbdecode(scn_code,status)
BYTE	scn_code;
WORD	*status;
{
	REG BYTE	scn_tbl_arg;	/* save the scan table arg field */
	REG BYTE 	group_x;	/* group/routine index from table */
	REG rtn_index	rtn_x;		/* index in switch statement	 */
	REG WORD	rv;		/* 16 Bit return value		 */

	/* save arg from the scan table entry for later use */
	scn_tbl_arg = scan_code_tbl[scn_code].arg;

	/* Use scan code to get group/routine index and parameter. */
	group_x = scan_code_tbl[scn_code].grp_rout_x;

	rv = 0;				/* initialize return value here	      */
	*status = NOCHAR;	        /* initialize status to not character
					   returned to the caller	     */
	if (group_x < 0)		/* negative group_x indicates a switch 
					   routine is invoked		     */
	{
		group_x = -group_x;

		/* if routine is lockable and front panel locked
		 * ignore keystroke,
		 * else process the scan code.
		 */

		if ( (group_x <= NONLOCKABLE)	
		   && !(*vmec1_status & KBD_UNLOCK) ) 
			rtn_x = IGNORE;
		else
			rtn_x = (rtn_index)(group_x);

		switch ((WORD)rtn_x)
		{
		case TWO_AT :
   
        	/* TWO_AT -- HANDLE THE 2 @ KEY.
   		 *
		 * This code is entered when the "2/@" key is pressed.  
		 * Its purpose is to generate the appropriate character 
		 * code depending on the state of the SHIFT and CTRL 
		 * mode keys.  The reason this key can't be handled 
		 * by the tables is that if CTRL is pressed, a _NULL
		 * character must be generated.  A value of 0 in the 
		 * tables is reserved to mean NO CHARACTER.
		 *
		 */

			if (!(modes & CTRL))
			{		
				if (modes & SHIFT)
					rv = '@';	/* return @ char */
				else
					rv = '2';	/* return 2 char */
			}
			else
			{
				if( modes & SHIFT )
					rv = _NULL;
				else
					rv = '2' | getstate(CTRL);
			}

			*status = IN_CHAR;
			break;

		case ESC_RESET :
   
		/*  ESC_RESET -- HANDLE ESC RESET KEY.
   		 *
		 * This code is entered when the ESC RESET key is pressed.
		 * Its purpose is to generate the appropriate character code 
		 * depending on the state of the SHIFT mode keys.
		 */
		  
			if (modes & SHIFT)	/* is a SHIFT key down	     */
				rv = _RESET | SPECIAL | getstate(CTRL);
			else
				rv = _ESC;	/* character is an esc	     */
			*status = IN_CHAR;
			break;
 
		case BREAK_CLEAR :
   
		/* BREAK_CLEAR -- HANDLE BREAK CLEAR KEY
   		 *
		 * This code is entered when the BREAK CLEAR key is pressed.
		 * Its purpose is to generate the appropriate character code
		 * depending on the state of the SHIFT mode keys.
		 */
  
			if (modes & SHIFT)
				rv = _CLEAR | SPECIAL;
			else
				rv = _BREAK | SPECIAL;
			rv |= getstate(CTRL);
			*status = IN_CHAR;
			break;

		case GEN_ALPHA :
   
		/* GEN_ALPHA -- HANDLE ALPHABETIC KEYS.
 		 *
		 * This code is entered when an alphabetic key is pressed.
		 * Its purpose is to generate the appropriate character code
		 * depending on the state of the SHIFT, CAPS_LOCK, and CTRL
		 * mode keys.
		 *
		 */

			if (modes & CTRL)
				rv = scn_tbl_arg - ('A' - 1) | getstate(SHIFT);
			else if (modes & CAPS_LOCK) 
			{
				if (modes & SHIFT)
					rv = scn_tbl_arg + ('a' - 'A'); 
				else
					rv = scn_tbl_arg;
			}
			else if (modes & SHIFT)
				rv = scn_tbl_arg;
			else
				rv = scn_tbl_arg + ('a' - 'A'); 
		  
			*status = IN_CHAR;
			break;
 
		case FNKEY :
   
		/* FNKEY -- HANDLE FUNCTION KEYS.
		 *
		 * This code is entered when a function key is pressed.
		 */
   
			rv = scn_tbl_arg | FUNCTION | getstate(SHIFT|CTRL);
			*status = IN_CHAR;
			break;
 
		case SET_SHIFT :
   
		/* SET_SHIFT AND CLR_SHIFT - SET OR CLEAR 1 OF THE 2 SHIFT KEYS.
		 *
		 * Use these routines when a shift key is pressed or released
		 * to update the SHIFT_KEYS byte and make a mode change for 
		 * SHIFT if necessary.
		 */

			shift_keys |= scn_tbl_arg;	/* which shift hit   */
			modes |= SHIFT;
			mode_chg();
			break;

		case CLR_SHIFT :

		/*
		 * First, clear previous key. If both shift keys 
		 * are released clear the shift mode.
		 */

			shift_keys &= (~scn_tbl_arg);
			if (shift_keys == 0)	
			{
				modes &= (~SHIFT);
				mode_chg();
			}
			break;

		case SET_MODE :
   
		/* SET_MODE AND CLR_MODE -- SET OR CLEAR A MODE (E.G., SHIFT).
		 *
		 * Use these routines when a mode key is pressed or released
		 * to update the "modes" byte and set the appropriate table 
		 * offsets in the grp_tbl_ptr.
		 */

			modes |= scn_tbl_arg;
			mode_chg();
			break;
 
		case CLR_MODE :		/* Clear the specified mode   */
			modes &= (~scn_tbl_arg);
			mode_chg();
			break;

		case IGNORE :
			break;
		}  /* end of switch ((WORD)rtn_x)*/
	}
	else
	{
	/* It's not a routine, it's a group, so use the parameter to get */
	/* the char from the current table for that group. */
		if (*vmec1_status & KBD_UNLOCK) /* is keybd unlocked */
		{	
			rv = (grp_tbl_ptr[group_x])[scn_tbl_arg];
			switch(group_x)
			{
			case 0 :
				if( rv != _NULL )
				{
					rv |= getstate(CTRL|SHIFT) | SPECIAL;
					*status = IN_CHAR;
				}
				break;

			case 1 :
				/*
				 *	NOTE: a null entry only
				 *	occurs in group 1 when there
				 *	is no valid CTRL ASCII value
				 *	for the key coupled with the
				 *	SHIFT state.  We then make up
				 *	a 16 bit value to return,
				 *	with the CTRL bit in the high
				 *	byte set.
				 */

				if( rv == _NULL )
				{
					if( modes & SHIFT )
						rv = tblyn_[scn_tbl_arg];
					else
						rv = tblnn_[scn_tbl_arg];
					rv |= (CTRL << 8);
				}
				*status = IN_CHAR;
				break;
			
			case 2 :
				/*
				 *	here we take a value of NUL
				 *	to mean that no character exists
				 *	for that key given the "PAD/FUNC"
				 *	state.
				 */

				if( rv != _NULL )
				{
					if( rv == _HELP )
						rv = 0;		/* KLUDGE */
					rv |= getstate(CTRL|SHIFT) | SPECIAL;
					*status = IN_CHAR;
				}
				break;
			}
		}
	}

	/*
	 *	set the ALT bit based on state of the alternate key.
	 *	
	 *	valid for all keys, will be ignored on NOCHAR.
	 */

	rv |= getstate(ALT);

	return(rv);
}


VOID	mode_chg()
{
	grp_tbl_ptr[1] = grp1_off[modes & (CTRL | SHIFT)];

	if( modes & PAD )			/* is PAD key down	*/
		grp_tbl_ptr[2] = tbl__y;	/* address of FUNC table */
	else
		grp_tbl_ptr[2] = tbl__n;	/* address of PAD table */
   
	return;
}


/*
 *	kbint:
 *
 *	keyboard Interrupt Service Routine for VME/10.
 *	this routine is invoked upon receipt of an interrupt
 *	from the keyboard by the system.  it retrieves the
 *	scan code and, if no error was detected, invokes
 *	the Asynchronous Service Routine "kbasr()" to translate
 *	the scan code into a character or state change and post
 *	the result if necessary.
 *
 *	ISR's should be kept short in keeping with Concurrent DOS
 *	design philosophy.
 */
 
WORD kbint()
{
	REG BYTE	scn_code;	/* scan code received from keyboard   */

	/* Get scan code and check for errors. */

	if (!(epci->status & ANY_ERROR))/* NO errors from the keyboard */
	{
		/* get scan code from keyboard, if high bit set, then error */
		if( !((scn_code = epci->data) & 0x80) )
		{	
			/* good character - invoke ASR and issue another read */
			doasr(kbasr,(LONG)scn_code,(LONG)0,KBASRPRI);
			/* send another read to keybd */
			epci->data = READ_KB;
			return(0);	/* no dispatch required */
		}
	}

	/* 
	 * An error was detected in getting the scan code--try again.
	 *
	 * NOTE: both if's drop through to here from above if ANY_ERROR
	 * was detected or bit 8 was set on a scn_code (it is negative).
	 */

	scn_code = epci->data;		/* read char if haven't done it yet */
	epci->command = COMM_INIT;	/* reset the error in the 2661 */

	/*
	 * tell keyboard to send last scan code
	 * again; just ignore the present one
	 */

	epci->data = AGAIN_KB;
	return(0);	/* no dispatch required */
}


/************************************************************************/
/*									*/
/*	kbasr()								*/
/*									*/
/*	Asynchronous service routine invoked by kbint() on interrupt.	*/
/*	This routine is given the scan code, invokes the kbdecode()	*/
/*	function to decode th scan code from the keyboard, and posts	*/
/*	the character back - if any.					*/
/*									*/
/************************************************************************/

typedef LONG (*func)();

WORD kbasr(scn_code)
LONG	scn_code;
{
	UWORD	ch;
	WORD	status;

	ch = kbdecode((BYTE)scn_code,&status);

	/*
	 *	status values returned are:
	 *
	 *		NOCHAR - no character is to be queued. a mode change
	 *		IN_CHAR - an input character is to be queued.
	 *
	 *	we only test for IN_CHAR
	 */

	if( status == IN_CHAR )
#if	CDOS
		(*(func)selblk.kbd_pin)(selblk.pconid,(LONG)ch);
#else
		kbq( (int)(ch) ) ;
#endif
}
