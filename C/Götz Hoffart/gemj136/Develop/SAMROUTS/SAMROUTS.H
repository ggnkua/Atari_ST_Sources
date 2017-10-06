/*******************************************************************
 *             SAMPLE-ROUTINEN 1.4 - Funktions-Deklarationen       *
 *******************************************************************/

#ifndef __SAMROUTS__
#define __SAMROUTS__

/************************** Konstanten-Definitionen ****************/

#define STEREO	0						/* Abspiel-Modi */
#define MONO	1

#define KHZ6	0						/* Sample-Frequenzen */
#define KHZ12	1
#define KHZ25	2
#define KHZ50	3

/************************** Funktions-Deklarationen ****************/

VOID			play_init(VOID);
VOID			play_exit(VOID);
VOID cdecl	play_sam(BYTE *start, LONG length, WORD freq);
VOID			stop_sam(VOID);

VOID cdecl	ste_play_sam(BYTE *start, LONG length, WORD freq, WORD mode);
BOOLEAN		ste_ready_sam(VOID);
VOID			ste_stop_sam(VOID);

VOID cdecl	convert8_sam(BYTE *start, LONG length);
VOID cdecl	convert16_sam(BYTE *start, LONG length);
VOID cdecl	fix_sam(BYTE *start, BYTE *dest, LONG length);

LONG cdecl	st_pack_sam(BYTE *start, LONG length, BYTE *dest);
LONG cdecl	st_depack_sam(BYTE *start, LONG length, BYTE *dest);
LONG cdecl	ste_pack_sam(BYTE *start, LONG length, BYTE *dest);
LONG cdecl	ste_depack_sam(BYTE *start, LONG length, BYTE *dest);

#endif

/*******************************************************************/
