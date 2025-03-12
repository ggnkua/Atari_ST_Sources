/*
 * July 5, 1991
 * Copyright 1991 Lance Norskog And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Lance Norskog And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools raw format file.
 *
 * Includes .ub, .uw, .sb, .sw, and .ul formats at end
 */

/*
 * Notes: most of the headerless formats set their handlers to raw
 * in their startread/write routines.  
 *
 */

#include "st.h"
#include "libst.h"

IMPORT int summary, verbose;

rawstartread(ft) 
ft_t ft;
{
}

rawstartwrite(ft) 
ft_t ft;
{
}

rawread(ft, buf, nsamp) 
ft_t ft;
long *buf, nsamp;
{
	register long datum;
	int done = 0;

	switch(ft->info.size) {
		case BYTE: switch(ft->info.style) {
			case SIGN2:
				while(done < nsamp) {
					datum = getc(ft->fp);
					if (feof(ft->fp))
						return done;
					/* scale signed up to long's range */
					*buf++ = LEFT(datum, 24);
					done++;
				}
				return done;
			case UNSIGNED:
				while(done < nsamp) {
					datum = getc(ft->fp);
					if (feof(ft->fp))
						return done;
					/* Convert to signed */
					datum ^= 128;
					/* scale signed up to long's range */
					*buf++ = LEFT(datum, 24);
					done++;
				}
				return done;
			case ULAW:
				/* grab table from Posk stuff */
				while(done < nsamp) {
					datum = getc(ft->fp);
					if (feof(ft->fp))
						return done;
					datum = st_ulaw_to_linear(datum);
					/* scale signed up to long's range */
					*buf++ = LEFT(datum, 16);
					done++;
				}
				return done;
			case ALAW:
				fail("No A-Law support");
				return done;
			}
		case WORD: switch(ft->info.style) {
			case SIGN2:
				while(done < nsamp) {
					datum = rshort(ft);
					if (feof(ft->fp))
						return done;
					/* scale signed up to long's range */
					*buf++ = LEFT(datum, 16);
					done++;
				}
				return done;
			case UNSIGNED:
				while(done < nsamp) {
					datum = rshort(ft);
					if (feof(ft->fp))
						return done;
					/* Convert to signed */
					datum ^= 0x8000;
					/* scale signed up to long's range */
					*buf++ = LEFT(datum, 16);
					done++;
				}
				return done;
			case ULAW:
				fail("No U-Law support for shorts");
				return done;
			case ALAW:
				fail("No A-Law support");
				return done;
			}
		}
	fail("Drop through in rawread!");
}

void
rawwrite(ft, buf, nsamp) 
ft_t ft;
long *buf, nsamp;
{
	register int datum;
	int done = 0;

	switch(ft->info.size) {
		case BYTE: switch(ft->info.style) {
			case SIGN2:
				while(done < nsamp) {
					/* scale signed up to long's range */
					datum = RIGHT(*buf++, 24);
					putc(datum, ft->fp);
					done++;
				}
				return;
			case UNSIGNED:
				while(done < nsamp) {
					/* scale signed up to long's range */
					datum = RIGHT(*buf++, 24);
					/* Convert to unsigned */
					datum ^= 128;
					putc(datum, ft->fp);
					done++;
				}
				return;
			case ULAW:
				/* grab table from Posk stuff */
				while(done < nsamp) {
					/* scale signed up to long's range */
					datum = RIGHT(*buf++, 16);
					datum = st_linear_to_ulaw(datum);
					putc(datum, ft->fp);
					done++;
				}
				return;
			case ALAW:
				fail("No A-Law support");
				return;
			}
		case WORD: switch(ft->info.style) {
			case SIGN2:
				while(done < nsamp) {
					/* scale signed up to long's range */
					datum = RIGHT(*buf++, 16);
					wshort(ft, datum);
					done++;
				}
				return;
			case UNSIGNED:
				while(done < nsamp) {
					/* scale signed up to long's range */
					datum = RIGHT(*buf++, 16);
					/* Convert to unsigned */
					datum ^= 0x8000;
					wshort(ft, datum);
					done++;
				}
				return;
			case ULAW:
				fail("No U-Law support for shorts");
				return;
			case ALAW:
				fail("No A-Law support");
				return;
			}
		}
	/* My, there's a lot of code missing! */
	fail("Drop through in rawwrite!");
}


/*
 * Set parameters to the fixed parameters known for this format,
 * and change format to raw format.
 */

static  rawdefaults();

/* Signed byte */
sbstartread(ft) 
ft_t ft;
{
	ft->info.size = BYTE;
	ft->info.style = SIGN2;
	rawdefaults(ft);
}

sbstartwrite(ft) 
ft_t ft;
{
	ft->info.size = BYTE;
	ft->info.style = SIGN2;
	rawdefaults(ft);
}

ubstartread(ft) 
ft_t ft;
{
	ft->info.size = BYTE;
	ft->info.style = UNSIGNED;
	rawdefaults(ft);
}

ubstartwrite(ft) 
ft_t ft;
{
	ft->info.size = BYTE;
	ft->info.style = UNSIGNED;
	rawdefaults(ft);
}

uwstartread(ft) 
ft_t ft;
{
	ft->info.size = WORD;
	ft->info.style = UNSIGNED;
	rawdefaults(ft);
}

uwstartwrite(ft) 
ft_t ft;
{
	ft->info.size = WORD;
	ft->info.style = UNSIGNED;
	rawdefaults(ft);
}

swstartread(ft) 
ft_t ft;
{
	ft->info.size = WORD;
	ft->info.style = SIGN2;
	rawdefaults(ft);
}

swstartwrite(ft) 
ft_t ft;
{
	ft->info.size = WORD;
	ft->info.style = SIGN2;
	rawdefaults(ft);
}

ulstartread(ft) 
ft_t ft;
{
	ft->info.size = BYTE;
	ft->info.style = ULAW;
	rawdefaults(ft);
}

ulstartwrite(ft) 
ft_t ft;
{
	ft->info.size = BYTE;
	ft->info.style = ULAW;
	rawdefaults(ft);
}

static
rawdefaults(ft)
ft_t ft;
{
	if (ft->info.rate == 0)
		ft->info.rate = 8000;
	if (ft->info.channels == -1)
		ft->info.channels = 1;
}


