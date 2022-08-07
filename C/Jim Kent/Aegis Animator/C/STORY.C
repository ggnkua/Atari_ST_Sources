
overlay "wtools"

#include "..\\include\\lists.h"
#include "..\\include\\format.h"
#include "..\\include\\io.h"
#include "..\\include\\script.h"
#include "..\\include\\raster.h"
#include "..\\include\\replay.h"
#include "..\\include\\story.h"
#include "..\\include\\animath.h"
#include "..\\include\\menu.h"
#include "..\\include\\clip.h"

#define TITLE_STRIP_DY 5

extern WORD ssc_xoff, ssc_yoff, sys_scale, story_xoff, story_yoff;


struct story story_board[STORY_COUNT] =
	{
	{
	NULL,
	0,
	SPX, 1*SPY + SWY + TITLE_STRIP_DY,
	SPX + SWX, 1*SPY + 2*SWY + TITLE_STRIP_DY,
	NULL,
	},

	{
	NULL,
	0,
	2*SPX + SWX,  1*SPY + SWY + TITLE_STRIP_DY,
	2*SPX + 2*SWX,  1*SPY + 2*SWY + TITLE_STRIP_DY,
	NULL,
	},

	{
	NULL,
	0,
	3*SPX + 2*SWX, 1*SPY + SWY + TITLE_STRIP_DY,
	3*SPX + 3*SWX, 1*SPY + 2*SWY + TITLE_STRIP_DY,
	NULL,
	},

	{
	NULL,
	0,
	SPX, 2*SPY + 2*SWY + TITLE_STRIP_DY,
	SPX + SWX, 2*SPY + 3*SWY + TITLE_STRIP_DY,
	NULL,
	},

	{
	NULL,
	0,
	2*SPX + SWX,  2*SPY + 2*SWY + TITLE_STRIP_DY,
	2*SPX + 2*SWX,  2*SPY + 3*SWY + TITLE_STRIP_DY,
	NULL,
	},

	{
	NULL,
	0,
	3*SPX + 2*SWX, 2*SPY + 2*SWY + TITLE_STRIP_DY,
	3*SPX + 3*SWX, 2*SPY + 3*SWY + TITLE_STRIP_DY,
	NULL,
	},
	};



#ifdef ATARI
make_story_frame(story)
struct story *story;
{
struct s_sequence *s;
struct square sq;

if ((s = story->sequence) != NULL)
	{
	set_d2_back();
	colblock(0, story->x_min_pos, story->y_min_pos,
	story->x_max_pos, story->y_max_pos);
	sq.x = story_xoff = story->x_min_pos;
	sq.y = story_yoff = story->y_min_pos;
	make_frame(s);
	set_d2_front();
	sq.X = story->x_max_pos;
	sq.Y = story->y_max_pos;
	restore_from_back(&sq);
	}
}
#endif ATARI

#ifdef AMIGA
make_story_frame(story)
struct story *story;
{
struct s_sequence *s;
struct BitMap *temp_raster;

s = story->sequence;
if (s)
	{
	temp_raster = init_BitMap(SWX, SWY, BITPLANES);
	if (temp_raster)
	{
	set_draw_to_BitMap(temp_raster);
	color_screen(0);
	make_frame(s);
	set_d2_front();
	draw_BitMap(temp_raster, story->x_min_pos, story->y_min_pos);
	WaitBlit();
	free_BitMap(temp_raster);
	}
	}
}
#endif AMIGA

#ifdef SUN
make_story_frame(story)
struct story *story;
{
Script *s;
struct byte_plane *temp_raster;

s = story->sequence;
if (s)
	{
	temp_raster = init_byte_plane(SWX, SWY, BITPLANES);
	if (temp_raster)
	{
	set_draw_to_byteplane(temp_raster);
	make_frame(s);
	set_d2_front();
	draw_byteplane(temp_raster, story->x_min_pos, story->y_min_pos);
	free_byte_plane(temp_raster);
	}
	}
}
#endif SUN

startup_story_board()
{
struct story *story;
struct s_sequence *s;
WORD i;
WORD color;
extern WORD cur_sequ_ix;

i = STORY_COUNT;
story = story_board + i;
while ( --i >= 0 )
	{
	--story;
	s = story->sequence;
	if (s)
	{
	s->xscale = s->yscale = 
		(story->x_max_pos - story->x_min_pos) * SCALE_ONE / XMAX;
	s->xoff = 0;   /*since draw first into own raster */
	s->yoff = 0;
	s->width = scale_mult( XMAX, s->xscale);
	s->height = scale_mult(YMAX, s->yscale);
	make_story_frame(story);
	}
	if (i == cur_sequ_ix)
	color = hi_color;
	else
	color = back_color;
	draw_frame(color, story->x_min_pos - 1, story->y_min_pos - 1,
	story->x_max_pos + 1, story->y_max_pos + 1);
	}
}



struct virtual_input *
advance_story_board()
{
struct story *story;
struct s_sequence  *s;
WORD i;
static unsigned long last_time;
unsigned long time;
long toff;
struct virtual_input *vis;

#ifdef AMIGA
extern struct RastPort *cur_pix;
#endif AMIGA

time = real_time();
if (time - last_time > 10000)
	toff = 0;
else
	toff = time - last_time;
/*if it takes more that 10000 milliseconds between calls to this
  guy don't advance timer at all*/

story = story_board;
i = STORY_COUNT;
while (i--)
	{
	if (story->is_active)
	{
	s = story->sequence;
	advance_timer(s,(toff*s->speed)>>5, REPLAY_LOOP);
#ifdef AMIGA
	WaitTOF(cur_pix);
#endif AMIGA
	make_story_frame(story);
	}
	story++;
	}
last_time = time;
find_colors();
#ifdef AMIGA
visible_pulldowns();
#endif AMIGA
vis = quick_input(USE_CURSOR);
return(vis);
}

