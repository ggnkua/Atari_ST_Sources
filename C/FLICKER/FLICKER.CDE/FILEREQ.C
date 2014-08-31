
#include <osbind.h>
#include "flicker.h"

extern WORD gem_mrez;

static char wild_buf[75];
static char fold_buf[70];
static char tbuf[16];
static char title_buf[16] = "FLICKER";
static char path_buf[90];
WORD current_drive;
static char current_dir[68];	/*64 in the docs, I'm just paranoid */

extern char *make_file_name();

init_fname()
{
current_drive = Dgetdrv();
Dgetpath(current_dir, 0);
fold_buf[0] = current_drive + 'A';
fold_buf[1] = ':';
strcat(fold_buf, current_dir);
strcat(fold_buf, "\\");
}

static
get_folder(wildbuf, foldbuf)
char *wildbuf, *foldbuf;
{
register char c;
register char lastc = 0;
register char *wild, *fold;

wild = wildbuf;
fold = foldbuf;
for (;;)
	{
	c = *wild++;
	switch (c)
		{
		case '*':
			for (;;)
				{
				if (fold == foldbuf)
					{
					*fold = 0;
					return;
					}
				c = *(--fold);
				switch(c)
					{
					case '\\':
					case ':':
						fold++;
						*fold = 0;
						return;
					}
				}
			break;
		case 0:
			if (lastc != ':' && lastc != '\\' && lastc != 0)
				*fold++ = '\\';
			*fold++ = 0;
			return;
		default:
			*fold++ = c;
		}
	lastc = c;
	}
}

static
get_title(s, d)
char *s;
register char *d;
{
register char c;

strcpy(d, s);
for (;;)
	{
	if ( (c = *d++) == 0)
		break;
	if (c == '.')
		{
		*(--d) = 0;
		break;
		}
	}
return;
}


char *
get_fname(suff)
char *suff;
{
WORD fs_ireturn, fs_iexbutton;

sprintf(wild_buf, "%s*.%s", fold_buf, suff);
sprintf(tbuf,"%s.%s", title_buf, suff);
fs_ireturn = fsel_input(wild_buf, tbuf, &fs_iexbutton);
if (fs_ireturn == 0 || fs_iexbutton == 0)
	return(NULL);
get_folder(wild_buf, fold_buf);	/* update folder with user things */
get_title(tbuf, title_buf);	/* update the "non-suffix" part */
strcpy(path_buf, fold_buf);
strcat(path_buf, tbuf);
}

