#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include <STDDEF.H>
#include <STDLIB.H>
#include <STDIO.H>
#include <MATH.H>

#include	<atarierr.h>

#include	"Bitmap.h"
#include	"SmIcons.h"


extern WORD		AesHandle, VdiHandle, VqExtnd[48];
extern ULONG	ScreenColors;
extern GRECT	ScreenRect;
extern int		EdDI;
extern WORD		magic_version;

WORD	SmIcons = 0;
GCBITMAP	SmIcon_Data[N_SIZE][N_SMILEYS];
GCBITMAP	SmIcon_Mask[N_SIZE][N_SMILEYS];

static void	Icon2Bitmap( CICONBLK *CiConBlk, GCBITMAP	*Data, GCBITMAP *Mask, WORD w, WORD h );
static void	Data2Bitmap( void *Data, GCBITMAP *Bitmap, WORD Plane, WORD w, WORD h );

void	SmIcons_Init( OBJECT	*TreeAddr )
{
	if( !( VqExtnd[30] & 0x0002 ) || !magic_version )
		return;
	else
	{
		int	i, j;
		for( i = 0; i < N_SIZE; i++ )
		{
			for( j = 0; j < N_SMILEYS; j++ )
			{
				Icon2Bitmap( TreeAddr[(i*N_SMILEYS)+j+1].ob_spec.ciconblk, &SmIcon_Data[i][j], &SmIcon_Mask[i][j], TreeAddr[(i*N_SMILEYS)+j+1].ob_width, TreeAddr[(i*N_SMILEYS)+j+1].ob_height );
				if( v_open_bm( VdiHandle, &SmIcon_Data[i][j], 1, 0, 0, 0 ) == 0 )
					return;
			}
		}
	}
	SmIcons = 1;
}

static void	Icon2Bitmap( CICONBLK *CiConBlk, GCBITMAP	*Data, GCBITMAP *Mask, WORD w, WORD h )
{
	void	*pData = NULL, *pMask = NULL;
	WORD	Plane = 0;
	if( ScreenColors == 2 )	/* monochrome Aufl”sung */
	{
		pData = CiConBlk->monoblk.ib_pdata;
		pMask = CiConBlk->monoblk.ib_pmask;
		Plane = 1;
	}
	else
	{
		CICON *CiCon = CiConBlk->mainlist, *Tmp = CiCon;
		while( CiCon )
		{
			if( pow(( double ) 2, ( double ) CiCon->num_planes ) <= ( double ) ScreenColors )
			{
				if( CiCon->num_planes > Tmp->num_planes )
					Tmp = CiCon;
			}
			CiCon = CiCon->next_res;
		}
		Plane = Tmp->num_planes;
		pData = Tmp->col_data;
		pMask = Tmp->col_mask;
	}
	if( pData )
		Data2Bitmap( pData, Data, Plane, w, h );
	if( pMask )
		Data2Bitmap( pMask, Mask, 1, w, h );
}

static void	Data2Bitmap( void *Data, GCBITMAP *Bitmap, WORD Plane, WORD w, WORD h )
{
	uint32	Format;
	switch( Plane )
	{
		case	1:
			Format = PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT;
			break;
		case	4:
			Format = PX_PLANES + PX_1COMP + PX_USES4 + PX_4BIT;
			break;
	}
	Bitmap->magic = CBITMAP_MAGIC;
	Bitmap->length = sizeof( GCBITMAP );
	Bitmap->format = 0;
	Bitmap->reserved = 0L;
	Bitmap->addr = Data;
	Bitmap->width = (( w + 15 ) & 0xfff0 ) * Plane / 8;
	Bitmap->bits = Plane;
	Bitmap->px_format = Format;
	Bitmap->xmin = 0;
	Bitmap->ymin = 0;
	Bitmap->xmax = w;
	Bitmap->ymax = h;
	Bitmap->ctab = v_create_ctab( VdiHandle, CSPACE_RGB, Plane );
	Bitmap->itab = NULL;
	Bitmap->reserved0 = 0L;
	Bitmap->reserved1 = 0L;

}
