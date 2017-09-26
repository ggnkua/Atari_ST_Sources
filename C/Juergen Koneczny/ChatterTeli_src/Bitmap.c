#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STDIO.H>
#include	<STRING.H>

#include	<atarierr.h>

#include	"main.h"
#include	"Bitmap.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD		AesHandle, VqExtnd[48];
extern ULONG	ScreenColors;
extern GRECT	ScreenRect;
extern int		EdDI;

BITMAP	*BitmapNew( WORD Xmax, WORD Ymax )
{
	WORD	WorkOut[57];
	BITMAP	*Bitmap = malloc( sizeof( BITMAP ));
	if( !Bitmap )
		return( NULL );

	Bitmap->BmHandle = 0;
	Bitmap->GcBitmap = NULL;
	Bitmap->Bitmap = NULL;

	if(( Bitmap->VdiHandle = OpenScreenWk( AesHandle, WorkOut )) <= 0 )
	{
		free( Bitmap );
		return( NULL );
	}

	if( BitmapResize( Bitmap, Xmax, Ymax ) != E_OK )
	{
		v_clsvwk( Bitmap->VdiHandle );
		free( Bitmap );
		return( NULL );
	}
	return( Bitmap );
}

void	BitmapDelete( BITMAP *Bitmap )
{
	if( vq_gdos())
		vst_unload_fonts( Bitmap->BmHandle, 0 );

	if( Bitmap->GcBitmap )
		if( Bitmap->GcBitmap->ctab )
			v_delete_ctab( Bitmap->BmHandle, Bitmap->GcBitmap->ctab );

	v_clsbm( Bitmap->BmHandle );
	v_clsvwk( Bitmap->VdiHandle );

	if( Bitmap->GcBitmap )
		free( Bitmap->GcBitmap );
	if( Bitmap->Bitmap )
		free( Bitmap->Bitmap );	
	free( Bitmap );
}

WORD	BitmapResize( BITMAP	*Bitmap, WORD Xmax, WORD Ymax )
{
	WORD		OldBmHandle = Bitmap->BmHandle;
	GCBITMAP	*OldGcBitmap = Bitmap->GcBitmap;
	MFDB		*OldBitmap = Bitmap->Bitmap;

/*	if( /*EdDI >= 0x0120 && */( VqExtnd[30] & 0x0002 ) && ( ScreenColors == 0 || ScreenColors >= 256 ) )*/
	if( VqExtnd[30] & 0x0002 )
	{
		uint32	format, colors;
		if( ScreenColors == 0 || ScreenColors >= 256 )
		{
			format = PX_PREF8;
			colors = 256;
		}
		else	if( ScreenColors == 2 )
		{
			format = PX_PREF1;
			colors = 2;
		}
		else	if( ScreenColors == 4 )
		{
			format = PX_PREF2;
			colors = 4;
		}
		else	if( ScreenColors == 16 )
		{
			format = PX_PREF4;
			colors = 16;
		}
		if(( Bitmap->GcBitmap = malloc( sizeof( GCBITMAP ))) == NULL )
		{
			Bitmap->GcBitmap = OldGcBitmap;
			return( ENSMEM );
		}
		Bitmap->GcBitmap->magic = CBITMAP_MAGIC;
		Bitmap->GcBitmap->length = sizeof( GCBITMAP );
		Bitmap->GcBitmap->format = 0;
		Bitmap->GcBitmap->reserved = 0L;
		Bitmap->GcBitmap->addr = NULL;
		Bitmap->GcBitmap->width = 0;
		Bitmap->GcBitmap->bits = format & PX_BITS;
		Bitmap->GcBitmap->px_format = format;
		Bitmap->GcBitmap->xmin = 0;
		Bitmap->GcBitmap->ymin = 0;
		Bitmap->GcBitmap->xmax = Xmax + 1;
		Bitmap->GcBitmap->ymax = Ymax + 1;
		Bitmap->GcBitmap->ctab = v_create_ctab( Bitmap->VdiHandle, CSPACE_RGB, format );
		vq_ctab( Bitmap->VdiHandle, sizeof( COLOR_TAB ) + colors * sizeof( COLOR_ENTRY ), Bitmap->GcBitmap->ctab );
		Bitmap->GcBitmap->itab = NULL;
		Bitmap->GcBitmap->reserved0 = 0L;
		Bitmap->GcBitmap->reserved1 = 0L;
		if(( Bitmap->BmHandle = v_open_bm( Bitmap->VdiHandle, Bitmap->GcBitmap, 1, 0, 0, 0 )) == 0 )
		{
			free( Bitmap->GcBitmap );
			Bitmap->GcBitmap = OldGcBitmap;
			Bitmap->BmHandle = OldBmHandle;
			return( ERROR );
		}
		Bitmap->Bitmap = NULL;
	}
	else
	{
		if(( Bitmap->Bitmap = malloc( sizeof( MFDB ))) == NULL )
		{
			Bitmap->Bitmap = OldBitmap;
			return( ENSMEM );
		}
		if(( Bitmap->BmHandle = OpenBitmap( Xmax + 1, Ymax + 1, Bitmap->VdiHandle, Bitmap->Bitmap )) <= 0 )
		{
			free( Bitmap->Bitmap );
			Bitmap->Bitmap = OldBitmap;
			Bitmap->BmHandle = OldBmHandle;
			return( ERROR );
		}
		Bitmap->GcBitmap = NULL;
	}	

	if( vq_gdos())
		vst_load_fonts( Bitmap->BmHandle, 0 );
	vswr_mode( Bitmap->BmHandle, MD_REPLACE );
	vsf_perimeter( Bitmap->BmHandle, 0 );
	vsf_interior( Bitmap->BmHandle, FIS_SOLID );

	if( OldBmHandle )
	{
		WORD	Text[10], Fill[5], D;
		vqt_attributes( OldBmHandle, Text );
		vqf_attributes( OldBmHandle, Fill );
		vsf_color( Bitmap->BmHandle, Fill[1] );
		vst_color( Bitmap->BmHandle, Text[1] );
		vst_font( Bitmap->BmHandle, Text[0] );
		vst_height( Bitmap->BmHandle, Text[7], &D, &D, &D, &D );
		
		if( OldGcBitmap )
			if( OldGcBitmap->ctab )
				v_delete_ctab( Bitmap->VdiHandle, OldGcBitmap->ctab );
		v_clsbm( OldBmHandle );
		if( OldGcBitmap )
			free( OldGcBitmap );
		if( OldBitmap )
			free( OldBitmap );
	}
	else
	{
		WORD	D;
		vsf_color( Bitmap->BmHandle, 0 );
		vst_color( Bitmap->BmHandle, 1 );
		vst_point( Bitmap->BmHandle, 10, &D, &D, &D, &D );
	}
	return( E_OK );
}

void	BitmapCopyOnScreen( BITMAP *Bitmap, RECT16 *Clip, RECT16 *Source, RECT16 *Dest )
{
	vs_clip( Bitmap->VdiHandle, 1, ( WORD * ) Clip );
	if( Bitmap->GcBitmap )
		vr_transfer_bits(( int16 ) Bitmap->VdiHandle, Bitmap->GcBitmap, NULL, ( int16 * ) Source, ( int16 * ) Dest, T_REPLACE );
	else	if( Bitmap->Bitmap )
	{
		WORD	Pxy[8];
		MFDB	WindowMfdb;
		WindowMfdb.fd_addr = NULL;
		Pxy[0] = Source->x1;
		Pxy[1] = Source->y1;
		Pxy[2] = Source->x2;
		Pxy[3] = Source->y2;
		Pxy[4] = Dest->x1;
		Pxy[5] = Dest->y1;
		Pxy[6] = Dest->x2;
		Pxy[7] = Dest->y2;
		vro_cpyfm( Bitmap->VdiHandle, S_ONLY, Pxy, Bitmap->Bitmap, &WindowMfdb );
	}
	vs_clip( Bitmap->VdiHandle, 0, ( WORD * ) Clip );
}