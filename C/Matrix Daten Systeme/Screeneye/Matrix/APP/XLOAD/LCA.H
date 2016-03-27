/* lca.h / MATRIX / WA / 1.4.93 */

# include <stdlib.h>

typedef struct
{
		int	number,	gates, clbs, iobs, ffs, bits, frames ;
} LCAdevice ;

typedef LCAdevice *PLCAdevice ;


extern void Print ( PLCAdevice lca ) ;
extern long ProgDataSize ( PLCAdevice lca ) ;
extern long PromSize ( PLCAdevice lca ) ;
extern BYTE *MallocDataBuffer ( PLCAdevice lca ) ;
extern void FreeDataBuffer ( PLCAdevice lca, void *buffer ) ;

extern LCAdevice *GetLcaFromNumber ( int number ) ;

enum LCAtype { LCA3020, LCA3030, LCA3042, LCA3064, LCA3090 } ;

typedef struct
{
		BYTE *Buffer,
			 *Current ;	/* points to current input byte */
		long BitCount ;
		PLCAdevice Lca ;

} LCAchip ;

typedef LCAchip *PLCAchip ;

extern void AddDataLine ( PLCAchip lcac, char *line ) ;
extern int  LoadFromFile ( PLCAchip lcac, char *rbtfile ) ;
extern void LCAchipPrint ( PLCAchip lcac ) ;
extern void Free ( PLCAchip lcac ) ;
extern void LCAchipStore ( PLCAchip lcac, char *codfilnam, char *info ) ;

extern void PrintStatus ( unsigned lcaport ) ;
extern int  LoadChip ( PLCAchip lcac, unsigned lcaport ) ;
extern int  ProgramLcaFromFile  ( char *filename, unsigned lcaport ) ;
