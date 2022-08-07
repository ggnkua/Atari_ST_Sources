
overlay "reader"

#ifdef SLUFFED
#include "..\\include\\lists.h"
#include "..\\include\\acts.h"
#include "..\\include\\addr.h"
#include "..\\include\\script.h"
#endif SLUFFED

#ifdef SLUFFED
scale_tween(tween, scalep, scaleq)
Tween *tween;
register WORD scalep, scaleq;
{
register int i,j;
register WORD **acts, *act, *scratch;

i = tween->act_count;
acts = tween->act_list;
while (--i >= 0)
	{
	act = *acts++;
	switch (function_type[act[1] ]  )
	{
	case MOVE_OP:
	case ROT_OP:
	case SIZE_OP:
		scratch = act + op_offset(act);
		*scratch = (scalep * *scratch + scaleq/2)/scaleq;
		scratch++;
		*scratch = (scalep * *scratch + scaleq/2)/scaleq;
		scratch++;
		*scratch = (scalep * *scratch + scaleq/2)/scaleq;
		scratch++;
		break;
	case SAMPLE_OP:
		{
		scratch = act + op_offset(act);
		j = *scratch++ * 3;
		while (--j >= 0)
		{
		*scratch = (scalep * *scratch + scaleq/2)/scaleq;
		scratch++;
		}
		}
		break;
	default:
		switch(act[1])
		{
		case INSERT_POLY:
			j = act[5];
			scratch = act+9;
			while (--j >= 0)
			{
			*scratch = (scalep * *scratch + scaleq/2)/scaleq;
			scratch++;
			*scratch = (scalep * *scratch + scaleq/2)/scaleq;
			scratch++;
			*scratch = (scalep * *scratch + scaleq/2)/scaleq;
			scratch += 2;
			}
			break;
		case INSERT_RASTER:
		case INSERT_STENCIL:
			scratch = act+5;
			*scratch = (scalep * *scratch + scaleq/2)/scaleq;
			scratch++;
			*scratch = (scalep * *scratch + scaleq/2)/scaleq;
			scratch++;
			*scratch = (scalep * *scratch + scaleq/2)/scaleq;
			scratch++;
			break;
		}
		break;
	}
	}
}
#endif SLUFFED


#ifdef SLUFFED
scale_script(ss, scalep, scaleq)
Script *ss;
register WORD scalep, scaleq;
{
int i;
register Tween **tweens;

i = ss->tween_count;
tweens = ss->tween_list;
while (--i >= 0)
	{
	scale_tween(*tweens++, scalep, scaleq);
	}
ss->level_z = (ss->level_z * scalep + scaleq/2)/scaleq;
}
#endif SLUFFED

