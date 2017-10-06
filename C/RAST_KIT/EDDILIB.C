/*														*/
/*	Binding fÅr zusÑtzliche VDI-Funktionen */
/*														*/

#include <portab.h>
#include <vdi.h>
#include	"EDDILIB.H"

WORD	contrl[12],
		intin[128],
		intout[128],
		ptsin[128],
		ptsout[128];

VDIPB	pb = { contrl, intin, ptsin, intout, ptsout };

/* OPEN BITMAP (VDI 100, 1) */
void  v_opnbm( WORD *work_in, MFDB *bitmap, WORD *handle, WORD *work_out )
{
   pb.intin = work_in;
   pb.intout = work_out;
   pb.ptsout = work_out + 45;

   contrl[0] = 100;
   contrl[1] = 0;
   contrl[3] = 20;
   contrl[5] = 1;
	contrl[6] = *handle;
   *((ULONG *)(&contrl[7])) = (ULONG) bitmap;

   vdi( &pb );

   *handle = contrl[6];
   pb.intin = intin;
   pb.intout = intout;
   pb.ptsout = ptsout;
}

/* CLOSE BITMAP (VDI 101, 1)  */
void  v_clsbm( WORD handle )
{
   contrl[0] = 101;
   contrl[1] = 0;
   contrl[3] = 0;
   contrl[5] = 1;
   contrl[6] = handle;
   vdi( &pb );
}

/* VQ_SCRNINFO( 102, 1 )   */
void  vq_scrninfo( WORD handle, WORD *work_out )
{
   pb.intout = work_out;

   intin[0] = 2;
   contrl[0] = 102;
   contrl[1] = 0;
   contrl[3]  = 1;
   contrl[5] = 1;
   contrl[6] = handle;
   
   vdi( &pb );

   pb.intout = intout;
}

/* V_BEZ( 6, 13 )   */
void	_v_bez( WORD handle, WORD count, WORD *xyarr,
				 BYTE *bezarr, WORD *extent, WORD *totpts,
				 WORD *totmoves )
{
	BYTE	*tmp;
	WORD	i;
	
	pb.ptsin = xyarr;
	pb.ptsout = extent;
	
	contrl[0] = 6;
	contrl[1] = count;
	contrl[3] = (count+1)>>1;
	contrl[5] = 13;
	contrl[6] = handle;
	
	tmp = (BYTE *) intin;
	
	for( i = 0; i < count; i += 2, bezarr += 2 )
	{
		*tmp++ = bezarr[1];
		*tmp++ = bezarr[0];
	}
	
	vdi( &pb );
	
	*totpts = intout[0];
	*totmoves = intout[1];
	
	pb.ptsin = ptsin;
	pb.ptsout = ptsout;
}

/* V_BEZ_FILL( 9, 13 )   */
void	_v_bez_fill( WORD handle, WORD count, WORD *xyarr,
				 BYTE *bezarr, WORD *extent, WORD *totpts,
				 WORD *totmoves )
{
	BYTE	*tmp;
	WORD	i;
	
	pb.ptsin = xyarr;
	pb.ptsout = extent;
	
	contrl[0] = 9;
	contrl[1] = count;
	contrl[3] = (count+1)>>1;
	contrl[5] = 13;
	contrl[6] = handle;
	
	tmp = (BYTE *) intin;
	
	for( i = 0; i < count; i += 2, bezarr += 2 )
	{
		*tmp++ = bezarr[1];
		*tmp++ = bezarr[0];
	}
	
	vdi( &pb );
	
	*totpts = intout[0];
	*totmoves = intout[1];
	
	pb.ptsin = ptsin;
	pb.ptsout = ptsout;
}

WORD	vqt_xfntinfo( WORD handle, WORD flags, WORD id, WORD index, XFNT_INFO *info )
{
	info->size = (LONG) sizeof( XFNT_INFO );

	intin[0] = flags;
	intin[1] = id;
	intin[2] = index;
	*(XFNT_INFO **)&intin[3] = info;

	contrl[0] = 229;
	contrl[1] = 0;
	contrl[3] = 5;
	contrl[5] = 0;
	contrl[6] = handle;

	vdi( &pb );

	return( intout[1] );
}
