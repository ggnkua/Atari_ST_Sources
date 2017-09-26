/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#ifndef AP_DRAGDROP
#define	AP_DRAGDROP	63
#endif

#define	DD_OK		0
#define	DD_NAK	1
#define	DD_EXT	2
#define	DD_LEN	3

#define	DD_TIMEOUT	4000												/* Timeout in ms */

#define	DD_NUMEXTS	8													/* Anzahl der Formate */
#define	DD_EXTSIZE	32													/* L„nge des Formatfelds */


#define	DD_NAMEMAX	128												/* maximale L„nge eines Formatnamens */
#define	DD_HDRMIN	9													/* minmale L„nge des Drag&Drop-Headers */
#define	DD_HDRMAX	( 8 + DD_NAMEMAX )							/* maximale L„nge des Drag&Drop-Headers */

WORD	ddcreate( WORD	app_id, WORD rcvr_id, WORD window, WORD mx, WORD my, WORD kbstate, ULONG format[8], void **oldpipesig, WORD Global[15] );
WORD	ddstry( WORD handle, ULONG format, BYTE *name, LONG size );
WORD	ddopen( BYTE *pipe, ULONG *format, void **oldpipesig );
void	ddclose( WORD handle, void *oldpipesig );
WORD	ddrtry( WORD handle, BYTE *name, ULONG *format, LONG *size );
WORD	ddreply( WORD handle, WORD msg );
int	 parse_ARGS( char *str );