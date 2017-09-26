typedef	struct
{
	WORD		VdiHandle;
	WORD		BmHandle;
	GCBITMAP	*GcBitmap;
	MFDB		*Bitmap;

}	BITMAP;

BITMAP	*BitmapNew( WORD Xmax, WORD Ymax );
WORD	BitmapResize( BITMAP	*Bitmap, WORD Xmax, WORD Ymax );
void	BitmapDelete( BITMAP *Bitmap );
void	BitmapCopyOnScreen( BITMAP *Bitmap, RECT16 *Clip, RECT16 *Source, RECT16 *Dest );