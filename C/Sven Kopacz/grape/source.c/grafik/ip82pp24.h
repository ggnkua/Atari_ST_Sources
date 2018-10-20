/* C-Protos fÅr Assemblermodul, Doku s. ip82pp24.s */

extern int hi, wi, add_pix, amode;
extern uchar *src, *dbuf, *cpal, *cp, *mp, *yp;
extern long	add_src, add_buf, add_dest;

/* Konvertiere 8 BitInterleaved Planes in 8Bit PixelPacked Plane */
extern void ip82pp24(void);

/* Kopiere 8 Bit PixelPacked Plane via Farbpalette nach 24 Bit 
	 PixelPacked Byte Planes */
extern void pp82pp24(void);