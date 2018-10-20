#if !defined(uchar)
#define uchar	unsigned char
#endif

typedef struct
{
	uchar	*sc, *sm, *sy;	/* Sourceplane(s), wenn sm=sy=NULL, dann grey */
	uchar	*dc, *dm, *dy;	/* Destplane(s), wenn dm=dy=NULL, dann grey */
	int		dw, dh;					/* Destwidth/Height */
	long	sldif, dldif;		/* Line-Diffs */
	int		mode;						/* Bits:
													 1=Use Mask
													 2=Transparent
													 4=Deckend ohne weiž
													 2+4=Deckend mit weiž
												*/
	uchar	*mask;					/* Maskplane, falls mode|=1 */
	long	mldif;					/* Mask Line-Diff */
}COPY_DSCR;

void 	vary_copy(COPY_DSCR *cd);
void	add_masks(uchar *s1, uchar *s2, uchar *ds, long s1dif, long s2dif, long ddif, int w, int h);