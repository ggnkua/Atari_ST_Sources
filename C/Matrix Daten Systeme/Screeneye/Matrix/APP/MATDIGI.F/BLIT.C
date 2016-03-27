# include "linea.h"

extern LINEA *Linea;
extern VDIESC *Vdiesc;
extern FONTS *Fonts;
extern LINEA_FUNP *Linea_funp;

BITBLT  PortBitBlt =
{
	720, 576, 16,	/* w x h x p	*/
	0, 0, 			/* fg, bg */
	{ REPLACE, REPLACE, REPLACE, REPLACE },	/* optab */
	0, 0,			/* s_x/ymin	*/
	MDFport,
    void *s_form;                   /* Adresse des Quellrasters     */
    int s_nxwd,                     /* Offset zum n„chsten Wort     */
        s_nxln,                     /* Breite des Quellrasters      */
        s_nxpl,                     /* Offset zur n„chsten Plane    */
        d_xmin,                     /* X-Zielraster                 */
        d_ymin;                     /* Y-Zielraster                 */
    void *d_form;                   /* Adresse des Zielrasters      */
    int d_nxwd,                     /* Offset zum n„chsten Wort     */
        d_nxln,                     /* Breite des Quellrasters      */
        d_nxpl;                     /* Offset zur n„chsten Plane    */
    void *p_addr;                   /* 16-Bit-Masken zum Undieren   */
    int p_nxln,                     /* Breite der Maske in Bytes    */
        p_nxpl,                     /* Offset zur n„chsten Plane    */
        p_mask;                     /* H”he der Maske in Zeilen     */
    char filler[24];                /* Interner Buffer              */
}   BITBLT;
b_wd:           dc.w   29      ; width of saucer is 29 pixels
b_ht:           dc.w   11      ; height of saucer is 11 pixels
plane_ct:       ds.w   1       ; number of bit planes
fg_col:         ds.w   1       ; Foreground color - (not used)
bk_col:         ds.w   1       ; Background color - (not used)
op_tab:         ds.l   1       ; logic operations for BLT
s_xmin:         dc.w   0       ; source x coordinate
s_ymin:         dc.w   0       ; source y coordinate
s_form:         ds.l   1       ; base address of source form
s_nxwd:         dc.w   8       ; offset to next word in source form in bytes
s_nxln:         dc.w   16      ; offset to next line in source form (29/2)
s_nxpl:         dc.w   2       ; offset to next plane (always 2)
d_xmin:         ds.w   1       ; destination x coordinate
d_ymin:         ds.w   1       ; destination y coordinate
d_form:         ds.l   1       ; base address of destination form
d_nxwd:         dc.w   8       ; offset to next word in destination form
d_nxln:         dc.w   160     ; offset to next line (320/2 pixels per bytes)
d_nxpl:         dc.w   2       ; offset to next plane (always 2)
p_addr:         dc.l   0       ; address of pattern buffer (0=no pattern)
p_nxln:         dc.w   0       ; offset to next line in pattern (not used)
p_nxpl:         dc.w   0       ; offset to next plane in pattern (not used)
p_mask:         dc.w   0       ; pattern index mask (not used)
filler:         ds.b   24      ; usused portion of parameter block

void bit_blt(BITBLT *bitblt);
