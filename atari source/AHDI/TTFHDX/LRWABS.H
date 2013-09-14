/* Lrwabs.h
 *
 * 14-Sep-89	ml.	Lrwabs() accept long recno.
 *
 */
 
extern	long	bios();

#define	Lrwabs(a,b,c,d,e)	bios(4,a,b,c,-1,e,d)

