
overlay "player"

#include "..\\include\\lists.h"
#include "..\\include\\format.h"
#include "..\\include\\animath.h"
#include "..\\include\\perspect.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\control.h"
#include "..\\include\\story.h"


struct s_sequence generic_sequence =
	{
	16,  /*version of scripts this ani makes*/
	0,0,  /*x,y offset*/
	XMAX,YMAX,  /*depth*/
	SCALE_ONE,SCALE_ONE,	  /* xscale,yscale scaling*/
	NEW_GROUND_Z,	  /* so as initted like original SUN ani ones */
	32,			/*speed*/
	0,			/*local_time */
	0,			/*start_time */
	BIG_LONG,		/*stop_time */
	0,			/*forward_offset */
	0,			/*backwards_offset */
	0, 			/*since_last_tween */
	0,			/*to_next_tween */
	0,		/*tween_count*/
	0,		/*tween_alloc*/
	NULL, /*tween_list*/
	NULL,  /*next_tween*/
	NULL, /*poly_list*/
	NULL, /*script_rasters*/
	NULL, /* name */
	NULL, /*child_scripts*/
	0,	/*child_count*/
	};



struct tween grc_tween =
	{
	0, 200, 0,   /*start, dur, end*/
	0, NULL,	/*act count, list*/
	NULL,	/*poly_list */
	};

struct poly grc_poly =
	{
	OUT_LINE,  /*type*/
	1,  /*color*/
	3,  /*line_width*/
	{ 0, 0, NEW_GROUND_Z, 0},
	0,  /*pt_count*/
	0,  /*pt_alloc*/
	NULL, /*pt_list*/
	NULL, /*clipped_list*/
	};


struct poly_list grc_poly_list =
	{
	0,  /*count*/
	0,  /*alloc*/
	NULL,  /*list*/
	NULL,  /*zlist*/
	NULL,  /*cmap*/	
	NULL,	/*bg_name*/
	};

struct point grc_point =
	{
	XMAX/2, YMAX/2, NEW_GROUND_Z,  /*x,y,z*/
	0,			/*level*/
	};

