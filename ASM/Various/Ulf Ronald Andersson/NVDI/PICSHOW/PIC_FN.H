typedef	void	IMG_REF;

IMG_REF	*img_open( int8 *name );									/* Bild ”ffnen */
int16		img_close( IMG_REF *img_handle );						/* Bild schliežen */
int16		img_get_info( IMG_REF *img_handle, int32 *width, int32 *height, int32 *bits );	/* Bildinfos */
int16	img_needs_dither( IMG_REF *pic, int16 vdi_handle );
int16		img_show( IMG_REF *pic, 
						 GCBITMAP *dst, RECT16 *dst_rect, int16 mode, 
						 RECT16 *clip_rect, int16 vdi_handle );
int16		img_copy( IMG_REF *pic, GCBITMAP *dst, int16 vdi_handle );
