/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */



#include <osbind.h>
#include "flicker.h"

extern WORD gem_mrez;

static char wild_buf[75];
char tbuf[20];
char fold_buf[70];
char title_buf[16] = "";
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
fold_buf[2] = 0;
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

char *
find_end_path(p)
register char *p;
{
register char *s;
register char c;

s = p;
for (;;)
	{
	c = *s++;
	if (c == ':' || c == '\\')
		p = s;
	if (c == 0)
		return(p);
	}
}


static
extract_title(s, d)
char *s;
register char *d;
{
register char c;

strcpy(d, s);
d = find_end_path(d);
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
char sbuf[5];

sprintf(sbuf, ".%s", suff);
sprintf(wild_buf, "%s*%s", fold_buf, sbuf);
sprintf(tbuf,"%s%s", title_buf, sbuf);
fs_ireturn = fsel_input(wild_buf, tbuf, &fs_iexbutton);
if (fs_ireturn == 0 || fs_iexbutton == 0)
	return(NULL);
get_folder(wild_buf, fold_buf);	/* update folder with user things */
if (fold_buf[1] == ':')
	current_drive = fold_buf[0] - 'A';
extract_title(tbuf, title_buf);	/* update the "non-suffix" part */
strcpy(path_buf, fold_buf);
strcat(path_buf, tbuf);
return(path_buf);
}

