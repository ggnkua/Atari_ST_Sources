
overlay "reader"

#ifdef NEVER
#define NOSAVE
#endif NEVER

#include <stdio.h>
#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "..\\include\\raster.h"
#include "..\\include\\script.h"
#include "..\\include\\acts.h"
#include "..\\include\\format.h"
#include "..\\include\\animath.h"
#include "..\\include\\menu.h"


extern char *op_name[];
extern char *make_file_name();

#ifndef NOSAVE
c_points(fp, point, point_count, num_count, in_line)
FILE *fp;
register WORD *point;
register WORD point_count, num_count;
WORD in_line;
{
register WORD line_count = 0;
register WORD i;

#ifdef DEBUG
printf("c_points(%ld %lx %d %d %d)\n", fp, point, point_count, num_count,
	in_line);
#endif DEBUG

while (--point_count >= 0)
	{
	if ( --line_count <= 0)
		{
		lfprintf(fp,"\n\t");
		line_count = in_line;
		}
	putc( '(', fp);
	i = num_count;
	while (--i >= 0)
		lfprintf(fp, "%d ", *(point++) );
	putc( ')', fp);
	}
lfprintf(fp,"\n");
}

c_act(fp, act, ss, stripit)
FILE *fp;
WORD *act;
Script *ss;
WORD stripit;
{
WORD i,j,k;
WORD *pt;
WORD type;
WORD every_3;
WORD p_in_f;

#ifdef DEBUG
printf("c_act(%ld %lx)\n", fp, act);
#endif DEBUG

if (stripit && act[2] < 0)	/*if it's a color or a background op...*/
	return(1);

lfprintf(fp,"*act ");
type = act[1];
lfprintf(fp, "%s ", op_name[type]);

	
switch ( type )
	{
	case INSERT_POLY:
		i = lof_type(type) - 2;
		pt = act+2;
		while (--i >= 0)
			lfprintf(fp,"%d ",*(pt++) );
		c_points( fp, act + lof_type(type), act[5], 4, 3);
		break;
	case PATH_SEGMENT:
		i = lof_type(type) - 2;
		pt = act+2;
		while (--i >= 0)
			lfprintf(fp,"%d ",*(pt++) );
		c_points( fp, act + lof_type(type), act[6], 3, 4);
		break;
	case PATH_POLY:
		i = lof_type(type) - 2;
		pt = act+2;
		while (--i >= 0)
			lfprintf(fp,"%d ",*(pt++) );
		c_points( fp, act + lof_type(type), act[3], 3, 4);
		break;
	case PATH_POINT:
	case PATH_POLYS:
		i = lof_type(type) - 2;
		pt = act+2;
		while (--i >= 0)
			lfprintf(fp,"%d ",*(pt++) );
		c_points( fp, act + lof_type(type), act[4], 3, 4);
		break;
	case INIT_COLORS:
		i = lof_type(type) - 2;
		pt = act+2;
		while (--i >= 0)
			lfprintf(fp,"%d ",*(pt++) );
		c_points( fp, act + lof_type(type), act[4], 3, 4);
		break;
	case INSERT_RASTER:
	case INSERT_STENCIL:
		{
		struct raster_list *rl = *((struct raster_list **)(act+3));
		lfprintf(fp, "%d %s ", act[2], rl->name);
		i = lof_type(type) - 5;
		pt = act+5;
		while (--i >= 0)
			lfprintf(fp,"%d ",*(pt++) );
		lfprintf(fp,"\n");
		}
		break;
	case INSERT_STRIP:
		{
		ss = ss->child_scripts[ act[3] ];
		lfprintf(fp, "%d %s ", act[2], ss->name);
		i = lof_type(type) - 4;
		pt = act+4;
		while (--i >= 0)
			lfprintf(fp,"%d ",*(pt++) );
		lfprintf(fp,"\n");
		}
		break;
	case LOAD_BACKGROUND:
		lfprintf(fp, "%d %s\n", act[2], act+3);
		break;
	default:
		i = act[0] - 2;
		pt = act+2;
		while (--i >= 0)
			lfprintf(fp,"%d ",*(pt++) );
		lfprintf(fp,"\n");
		break;
	}
if (ferror(fp) )
	return(0);
else
	return(1);
}

c_tween(fp,tween, ss, stripit)
FILE *fp;
struct tween *tween;
Script *ss;
WORD stripit;
{
register WORD **acts;
WORD i;

#ifdef DEBUG
printf("c_tween(%ld %lx)\n", fp, tween);
#endif DEBUG

lfprintf(fp, "\n*tween %ld %d %ld %d\n", tween->start_time, tween->tweening, tween->stop_time, tween->act_count);

acts = tween->act_list;
i = tween->act_count;
while(--i >= 0)
	if (!c_act(fp, *(acts++), ss, stripit))
		{
		write_error();
		return(0);
		}
return(1);
}



c_script(fp, ss, name, stripit)
FILE *fp;
struct s_sequence *ss;
char *name;
WORD stripit;
{
extern struct n_slider clock_sl;
extern struct raster_list *raster_master;
struct item_list *script_rasters;
struct raster_list *rp;
struct tween **tweens, *tween;
char *type_name;
WORD i;

#ifdef DEBUG
printf("c_script(%s)\n", name);
lsleep(1);
#endif DEBUG

if (ss)
	{
	lfprintf(fp, "*script %s %d %d %d\n",name, ss->tween_count,
	XMAX, YMAX);
	lfprintf(fp, "*version %d\n",ss->type);
	lfprintf(fp, "*ground_z %d\n", ss->level_z);
	lfprintf(fp, "*speed %d\n", ss->speed);
	script_rasters = ss->script_rasters;
	while ( script_rasters )
		{
		rp = (struct raster_list *)script_rasters->item;
		switch( rp->type)
			{
			case BITPLANE_RASTER:
				type_name = "BITPLANE_RASTER";
				break;
			case BYPLANE_RASTER:
				type_name = "BYPLANE_RASTER";
				break;
			case AMIGA_BITMAP:
				type_name = "AMIGA_BITMAP";
				break;
			case ATARI_CEL:
				type_name = "ATARI_CEL";
				break;
			case ANI_STRIP:
				type_name = "ANI_STRIP";
				break;
			default:
				type_name = "UNKNOWN_TYPE";
				break;
			}
		lfprintf(fp, "*define %s %s\n",type_name, rp->name);
		script_rasters = script_rasters->next;
		}
	tweens = ss->tween_list;
	i = ss->tween_count;

	while (--i >= 0)
		if (!c_tween(fp, *(tweens++), ss, stripit))
			return(0);
	}
}
#endif NOSAVE

sv_scr(name, ss, stripit)
char *name;
struct s_sequence *ss;
WORD stripit;
{
FILE *fp;

#ifndef NOSAVE
name = make_file_name(name);
fp = fopen(name, "w");
if (fp == NULL)
	ldprintf("can't open %s",name);
else
	{
	ldprintf("saving %s",name);
	c_script(fp, ss, name, stripit);
	fclose(fp);
	}
#endif NOSAVE
}

