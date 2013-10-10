
#include "flicker.h"
#include "gemfont.h"
#include <osbind.h>
#include <aline.h>


struct font_hdr cfont;
#ifdef SLUFFED
WORD *fnt_buf, buf_size;
#endif SLUFFED
WORD *cf_offsets;
long cf_offset_size;
WORD *cf_data;
long cf_data_size;
WORD got_cf;
struct font_hdr **fk;
WORD cfont_prop;



deintel_words(intel, count)
register char *intel;
register WORD count;
{
register char swap;

while (--count >= 0)
	{
	swap = intel[0];
	intel[0] = intel[1];
	intel[1] = swap;
	intel += 2;
	}
}

deintel_fhead(fh)
struct font_hdr *fh;
{
deintel_words(fh, 2);
deintel_words(&fh->ADE_lo, 26);
}


free_cfont()
{
if (got_cf)
	{
	*fk = cfont.nxt_fnt;
	free(cf_offsets);
	free(cf_data);
	got_cf = 0;
	cfont_prop = 0;
	}
}

is_font_mono(f)
struct font_hdr *f;
{
register WORD i;
register WORD *offsets;
register WORD first_off;

offsets = f->ch_ofst;
first_off = offsets[1] - offsets[0];
i = f->ADE_hi - f->ADE_lo;	/* there are i+2 offsets... */
while (--i >= 0)
	{
	offsets += 1;
	if (offsets[1] - offsets[0] != first_off)
		return(0);
	}
return(1);
}

load_cfont(name)
char *name;
{
WORD is_fnt;
struct font_hdr *f;
WORD fd;
WORD success = 0;
WORD i;

free_cfont();
fk =  (struct font_hdr **)(((char *)aline) - 456); /* point fk at 6x6 font */
upc(name);
is_fnt = suffix_in(name, ".FNT");
if ((fd = Fopen(name, 0))<0)
	{
	couldnt_open(name);
	return(0);
	}
if (Fread(fd, (long)sizeof(cfont), &cfont) < sizeof(cfont) )
	{
	file_truncated(name);
	goto END;
	}
if (is_fnt)
	{
	deintel_fhead(&cfont);
	}
cf_offset_size = cfont.ADE_hi - cfont.ADE_lo + 2;
cf_offset_size*= sizeof(WORD);
if ((cf_offsets = lbegmem(cf_offset_size)) == NULL)
	{
	goto END;
	}
if (Fread(fd, (long)cf_offset_size, cf_offsets) < cf_offset_size )
	{
	file_truncated(name);
	free(cf_offsets);
	}
if (is_fnt)
	{
	deintel_words(cf_offsets, (int)cf_offset_size/2);
	}
cf_data_size = cfont.frm_wdt;
cf_data_size *= cfont.frm_hgt;
if (cf_data_size >= 32L*1024)
	{
	continu_line("Font too big, sorry");
	free(cf_offsets);
	goto END;
	}
if ((cf_data = lbegmem(cf_data_size)) == NULL)
	{
	free(cf_offsets);
	goto END;
	}
if (Fread(fd, (long)cf_data_size, cf_data) < cf_data_size )
	{
	file_truncated(name);
	free(cf_offsets);
	free(cf_data);
	goto END;
	}
if (is_fnt)
	{
	if (cfont.flags & 4)
		{
		deintel_words(cf_data, (int)cf_data_size/2);
		}
	cfont.flags |= 4;	/* we've swapped it back dudes! */
	}

cfont.ch_ofst =  cf_offsets;
cfont.hz_ofst = NULL;
cfont.fnt_dta = cf_data;
cfont.id = CYP_CUSTOM_FONT;		/* face identifer */
cfont.flags &= ~2;	/* never have horizontal offset... */
cfont.nxt_fnt = *fk;
*fk = &cfont;
if (is_font_mono(&cfont) )
	cfont.flags |= 8;
cfont_prop = ((cfont.flags & 8) == 0);
success = 1;
got_cf = 1;
END:
Fclose(fd);
return(success);
}

