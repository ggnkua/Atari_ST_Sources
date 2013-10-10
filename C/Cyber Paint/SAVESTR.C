
#include <osbind.h>
#include <stdio.h>
#include "flicker.h"
#include "flicmenu.h"

extern char tbuf[], title_buf[], path_buf[], fold_buf[];
extern struct slidepot speed_sl;

digits_needed(i)
unsigned int i;
{
int needed = 1;

for (;;)
	{
	if (i >= 10)
		{
		i /= 10;
		needed+=1;
		}
	else
		break;
	}
return(needed);
}

char *
itoa_zpad(i, digits)
int i, digits;
{
static char buf[12];
static char fmt[] = "%xd";

fmt[1] = digits+'0';
sprintf(buf, fmt, i);
tr_string(buf, ' ', '0');
return(buf);
}


save_str(name)
char *name;
{
char bufff[108];
char nbuf[10];
FILE *strip_file;
int i;
int hold_time;
int digits;
WORD success = 1;
long start_time = 0;

if ((strip_file = fopen(name, "w")) == NULL)
	{
	couldnt_open(name);
	return(0);
	}
digits = digits_needed(screen_ct);
hold_time = (speed_sl.value*200L+30)/60;
fprintf(strip_file, "*script %s 320 200 %d\n",  name, screen_ct);
fprintf(strip_file, "*version 16\n");
fprintf(strip_file, "*ground_z 512\n");
fprintf(strip_file, "*speed 32\n\n");
strcpy(nbuf, title_buf);
nbuf[8-digits] = 0;	/* leave room for some numbers... */
for (i=1; i<= screen_ct; i++)
	{
	fprintf(strip_file, "*define ATARI_CEL %s%s.CEL\n", nbuf, 
		itoa_zpad(i, digits) );
	}
sub_ram_deltas(bscreen);
abs_tseek(0, bscreen);
for (i=1; i<=screen_ct; i++)
	{
	copy_screen(bscreen, cscreen);
	sprintf(bufff, "%s%s%s.CEL", fold_buf, nbuf, itoa_zpad(i, digits) );
	free_cel(clipping);
	clipping = NULL;
	if (!find_clip(bscreen))
		{
		clipping = init_cel(0, 0);
		}
	else
		{
		if (!snipit(bscreen))
			{
			outta_memory();
			success = 0;
			break;
			}
		if (!save_cel(bufff))
			{
			success = 0;
			break;
			}
		}
	fprintf(strip_file, "\n*tween %ld %d %ld %d\n", start_time, hold_time,
		start_time+hold_time, (i==1 ? 1 : 2));
	if (i != 1)
		fprintf(strip_file, "*act KILL_POLY 0\n");
	fprintf(strip_file, "*act INSERT_RASTER 0 %s%s.CEL %d %d 512\n",
		nbuf, itoa_zpad(i, digits), clipping->xoff+clipping->width/2,
		clipping->yoff+clipping->height/2);
	start_time += hold_time;
	do_deltas(ram_screens[i], bscreen);
	qput_cmap(ram_screens[i]);
	}
fclose(strip_file);
abs_tseek(screen_ix, bscreen);
free_cel(clipping);
clipping = NULL;
return(success);
}

