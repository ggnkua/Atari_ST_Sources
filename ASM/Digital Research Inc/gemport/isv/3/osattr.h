
/****************************************************************************
* OSATTR.H - include file to define abilities of the O.S. the program is
*	executing on.
*
* Last modified:
*       4/25/84 as      added pcdos version definitions
*	2/28/84 whf	add 'os_interrupts'
*	1/24/84 whf	handle link problem on 68K
*	1/5/84 whf & rsw add CPMZ8KV11
*	12/29/83 whf	add os_truncates
*	11/4/83 whf	handle CCPM 3.1 & networking
****************************************************************************/
#ifndef OSATTR
extern	unsigned short	os_version;		/* A contrived version num  */
extern	unsigned short	os_abilities;		/* Flags indicating abilitys*/
#endif

/*****************************************************************************
* OS Ability Bits definitions
*****************************************************************************/
#define _os_multitasking	0x0001		/* multi tasking OS	    */
#define _os_netinstalled	0x0002		/* Net installed locally?   */
#define _os_interrupts		0x0004		/* O.S. supports CTRL C?    */
#define _os_0x0008		0x0008
#define _os_is8087		0x0010		/* Machine has real 8087    */
#define _os_oldmultisec 	0x0020		/* does 3.0 multi-sector i/o*/
#define _os_newmultisec 	0x0040		/* does 3.1 multi-sector i/o*/
#define _os_multisectorio	0x0060		/* does multi-sector i/o    */
#define _os_truncates		0x0080		/* truncate file func	    */
#define _os_unixlike		0x0100		/* Unix like I/O	    */

/* capabilities for OSATTR.C documentation (not used in RTL): */
#define _os_f_parse		0x0000		/* F_PARSE func available?  */
#define _os_filesharing 	0x0000		/* BDOS File Sharing funcs? */
#define _os_loadtime		0x0000		/* OS supports load time fix*/
#define _os_swaps8087		0x0000		/* OS swaps 8087 registers? */
#define _os_fastconio		0x0000		/* CPM+ fast Con I/O funcs  */
#define _os_datetime		0x0000		/* OS keeps system time     */


/****************************************************************************
* OS Ability Test Macros
****************************************************************************/
#define os_multitasking 	(os_abilities & _os_multitasking)
#define os_netinstalled 	(os_abilities & _os_netinstalled)
#define os_interrupts		(os_abilities & _os_interrupts)
#define os_datetime		(os_abilities & _os_datetime)
#define os_fastconio		(os_abilities & _os_fastconio)
#define os_is8087		(os_abilities & _os_is8087)
#define os_multisectorio	(os_abilities & _os_multisectorio)
#define os_oldmultisec		(os_abilities & _os_oldmultisec)
#define os_newmultisec		(os_abilities & _os_newmultisec)
#define os_truncates		(os_abilities & _os_truncates)
#define os_f_parse		(os_abilities & _os_f_parse)
#define os_filesharing		(os_abilities & _os_filesharing)
#define os_loadtime		(os_abilities & _os_loadtime)
#define os_swaps8087		(os_abilities & _os_swaps8087)
#define os_unixlike		(os_abilities & _os_unixlike)
/****************************************************************************
* OS (Func 12) version numbers
*****************************************************************************/
#define CPM86V11		0x1022		/* CP/M-86 v1.0, v1.1	    */
#define CPM68KV11		0x2022		/* CP/M-68K v1.1	    */
#define CCPM86V10		0x1430		/* CCP/M-86 PC v1.0	    */
#define CCPM86V20		0x1431		/* CCP/M-86 v2.0	    */
#define MPM86V21		0x1130		/* MP/M-86 v2.0, v2.1	    */
#define CPM86V31		0x1031		/* CP/M-86 Plus 	    */
#define CPMZ8KV11		0x3022		/* CP/M-Z8000 v1.1	    */

/*  end of osattr.h  ********************************************************/
