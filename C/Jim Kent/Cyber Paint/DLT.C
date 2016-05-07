

#include <osbind.h>
#include "flicker.h"
#include "flicmenu.h"

extern char *get_fname();
extern WORD *ram_dlt;
extern long rd_alloc;
extern long rd_count;
extern long pt_to_long();
extern char *find_end_path();

char rd_name[80];
WORD rd_frames;
WORD rd_more;
WORD rd_abort;

load_more_dlt()
{
return(l_dlt(rd_name, rd_frames) );
}


load_dlt(name)
char *name;
{
strcpy(rd_name, name);
rd_frames = 0;
return(l_dlt(name, 0));
}

l_dlt(name, start)
char *name;
WORD start;
{
int dlt_fd = -1;
int frames;
char pic_name[80];
char dlt_name[80];
int success = 0;
WORD deltas;
unsigned long del_length;
WORD i;
long try_file_size;
char *dlt_buf;
register WORD *dlt_pt;
WORD odegas = degas;

degas = 1;
sub_ram_deltas(bscreen);
strcpy(dlt_name, name);
cut_suffix(find_end_path(dlt_name));
sprintf(pic_name,"%s.PI1", dlt_name);

hide_mouse();
if (!lpic(pic_name, 0))
	{
	cut_suffix(find_end_path(pic_name));
	sprintf(pic_name,"%s.PC1", dlt_name);
	if (!rpc1(pic_name, 0))
		goto end_ldlt;
	}

copy_screen(bscreen, start_screen);
copy_screen(bscreen, cscreen);	/* make it visible */

strcpy(dlt_name, name);
if ((dlt_fd = Fopen(dlt_name, 0)) < 0)
	{
	couldnt_open(dlt_name);
	goto end_ldlt;
	}
copy_words(sys_cmap, prev_screen, COLORS);
for (i=0; i<start; i++)
	{
	if (Fread(dlt_fd, (long)sizeof(WORD), prev_screen+COLORS) < sizeof(WORD))
		{
		file_truncated(name);
		goto bad_end_ldlt;
		}
	del_length = 3L*sizeof(WORD)*prev_screen[COLORS];
	if (Fread(dlt_fd, del_length, prev_screen+COLORS+1) < del_length)
		{
		file_truncated(name);
		goto bad_end_ldlt;
		}
	do_deltas(prev_screen, start_screen);
	copy_screen(start_screen, cscreen);
	}
screen_ix = 0;
screen_ct = 1;
dlt_buf = (char *)ram_dlt - rd_alloc;
ram_screens[0] = dlt_pt = (WORD *)dlt_buf;
empty_frame(dlt_pt, sys_cmap);	/* 1st frame == first pic */
rd_count = empty_size;
dlt_pt += empty_size/sizeof(WORD);
try_file_size = 9*rd_alloc/10 - 2*empty_size;
rd_more = 0;
for (;;)
	{
	if (abort_load())
		{
		rd_abort = 1;
		break;
		}
	if (screen_ct >= MAX_SCREENS)
		{
		rd_more = 1;
		break;
		}
	if (rd_count + 2 + empty_size > rd_alloc)
		{
		rd_more = 1;
		break;
		}
	copy_words(sys_cmap, dlt_pt, COLORS);
	if (Fread(dlt_fd, (long)sizeof(WORD), dlt_pt+COLORS) < sizeof(WORD))
		{
		break;
		}
	if ((del_length = 3L*sizeof(WORD)*dlt_pt[COLORS]) == 0)
		{
		break;
		}
	if (rd_count + 2 + empty_size + del_length > rd_alloc)
		{
		rd_more = 1;
		break;
		}
	if (Fread(dlt_fd, del_length, dlt_pt+COLORS+1) < del_length)
		{
		file_truncated(name);
		break;
		}
	if (del_length >= 32000)
		{
		zero_screen(uscreen);
		ctr_dlts(dlt_pt+COLORS, uscreen);
		dlt_pt[COLORS] = 0xffff;
		copy_screen(uscreen, dlt_pt+COLORS+1);
		del_length = 32000;
		}
	ram_screens[screen_ct] = dlt_pt;
	screen_ct++;
	dlt_pt += del_length/2 + 1 + COLORS;
	rd_count += del_length + 2 + COLORS*sizeof(WORD);
	}
if (rd_count < 0)
	{
	goto bad_end_ldlt;
	}
if (screen_ct <= 0)
	{
	goto bad_end_ldlt;
	}
make_end_screen();
empty_frame( ram_screens[screen_ct] = 
	(WORD *)( (char *)dlt_buf + rd_count));
rd_count += empty_size;
copy_screen(start_screen, bscreen);
update_next_prev(bscreen);
copy_screen(bscreen, uscreen);
copy_lots(dlt_buf, (char *)ram_dlt - rd_count, rd_count);
offset_ram_screens(rd_alloc - rd_count);
rd_frames += screen_ct;
success = 1;
goto end_ldlt;
bad_end_ldlt:
_clear_seq();
end_ldlt:
if (dlt_fd >= 0)
	Fclose(dlt_fd);
degas = odegas;
return(success);
}

save_dlt(name)
char *name;
{
char pic_name[80];
char dlt_name[80];
WORD firstw;
WORD dlt_fd = -1;
WORD i;
WORD *pt;
WORD success = 0;
long size;

/* make up corresponding .pi1 name and save the first frame as .pi1 */
clean_ram_deltas(bscreen);
copy_screen(bscreen, cscreen);
top_print("Saving First Frame...");
multi_start_stop();	/* get section to save */
strcpy(dlt_name, name);
cut_suffix(find_end_path(dlt_name));
sprintf(pic_name,"%s.PI1", dlt_name);
strcpy(dlt_name, name);
_abs_tseek(start_frame, prev_screen);
if (!s_pic(pic_name, prev_screen))
	{
	goto ld_exit;
	}

top_print("Saving Deltas...");
/* create the .dlt file */
Fdelete(dlt_name);
if ((dlt_fd = Fcreate(dlt_name, 0)) < 0)
	{
	couldnt_open(dlt_name);
	goto ld_exit;
	}

for (i=start_frame+1; i<=stop_frame ; i++)
	{
	pt = ram_screens[i];
	firstw = pt[COLORS];
	if (firstw != 0xffff)
		{
		size = firstw*3*sizeof(WORD)+sizeof(WORD);
		if (Fwrite(dlt_fd, size, pt+COLORS) < size)
			goto trunc_exit;
		}
	else
		{
		size = exp_dlts(pt+1+COLORS, prev_screen+1);
		prev_screen[0] = size;
		size *= 3*sizeof(WORD);	/* 3 words/delta */
		size += sizeof(WORD);	/* word for delta count */
		if (Fwrite(dlt_fd, size, prev_screen) < size)
			goto trunc_exit;
		}
	}
firstw = 0;
if (Fwrite(dlt_fd, (long)sizeof(firstw), &firstw) < sizeof(firstw) )
	goto trunc_exit;
success = 1;
goto ld_exit;

trunc_exit:
file_truncated(dlt_name);
ld_exit:
if (dlt_fd >= 0)
	Fclose(dlt_fd);
update_next_prev(bscreen);
return(success);
}

