
#include "flicker.h"
#include "flicmenu.h"


shift_line(shift, y)
register WORD shift, y;
{
if (shift != 0)
	{
	copy_blit(XMAX, 1, 0, y, cscreen, 160,
		shift, y, cscreen, 160);
	if (shift > 0)
		{
		hline(y, 0, shift-1, 0);
		}
	else if (shift < 0)
		{
		hline(y, XMAX+shift, XMAX-1, 0);
		}
	}
}


shatter_pic(shear)
register WORD shear;
{
register WORD i, count;

count = YMAX/2;
i = 0;
while (--count >= 0)
	{
	shift_line(shear, i++);
	shift_line(-shear, i++);
	}
}

shatter_one(so_far, in_tween)
WORD so_far, in_tween;
{
register WORD i, shear;

if (tween_mode)
	shatter_pic(uscale_by(XMAX, so_far, in_tween));
else
	shatter_pic(1);
return(1);
}

shatter()
{
hide_mouse();
if (select_mode == 0)
	{
	copy_screen(cscreen, uscreen); /* save undo */
	shatter_pic(1);
	dirtys();
	}
else
	qdo_many(shatter_one, 0);
show_mouse();
maybe_see_buffer();
}


mshatter()
{
msetup();
shatter();
mrecover();
}

#define QUARTERC	(TWO_PI/4)


ydiamond(rad, theta)
WORD rad, theta;
{
WORD sign, sub;

while (theta < 0)
	theta += TWO_PI;
theta &= (TWO_PI-1);
if (theta >= 2*QUARTERC)
	{
	sign = 1;
	theta -= 2*QUARTERC;
	}
else 
	{
	sign = 0;
	}
if (rad < 0)
	{
	sign = !sign;
	rad = -rad;
	}
if (theta >= QUARTERC)
	{
	theta -= QUARTERC;
	sub = 1;
	}
else
	sub = 0;
theta = ruscale_by(rad, theta, QUARTERC);
if (sub)
	theta = rad-theta;
if (sign)
	theta = -theta;
return(theta);
}

yproj(rad, theta)
WORD rad, theta;
{
WORD xybuf[2];

polar(theta, rad, xybuf);
return(xybuf[1]);
}

static WORD max_amp, pixels_wave;
static Vector sin_func;

wave_pic(shear)
register WORD shear;
{
register WORD i, theta;
long inc;

if (pixels_wave == 2)
	{
	shatter_pic(shear);
	return;
	}
for (i=0; i<YMAX; i++)
	{
	if (pixels_wave >= 8)
		theta = sscale_by(TWO_PI, (i-firsty), pixels_wave);
	else	/* take care of 16 bit overflow ... yuck */
		{
		inc = TWO_PI;
		inc *= (i-firsty);
		inc /= pixels_wave;
		if (inc < 0)
			{
			theta = -( (-inc)&(TWO_PI-1));
			}
		else
			theta = (inc&TWO_PI-1);
		}
	shift_line((*sin_func)(shear, theta), i);
	}
}

wave_one(so_far, in_tween)
WORD so_far, in_tween;
{
register WORD i, shear;

if (tween_mode)
	shear = (*sin_func)( max_amp, uscale_by(TWO_PI, so_far, in_tween) );
else
	shear = max_amp;
wave_pic(shear);
return(1);
}

wave()
{
hide_mouse();
if (select_mode == 0)
	{
	copy_screen(cscreen, uscreen); /* save undo */
	wave_pic(max_amp);
	dirtys();
	}
else
	qdo_many(wave_one, 0);
show_mouse();
maybe_see_buffer();
}


#ifdef SLUFFED
gen_wave()
{
msetup();
wave();
mrecover();
}
#endif SLUFFED

buzzwave()
{
msetup();
if (define_box())
	{
	max_amp = (x_1 - x_0);
	pixels_wave = (y_1 - y_0)<<1;
	wave();
	}
mrecover();
}

mbuzz()
{
sin_func = ydiamond;
buzzwave();
}

mwave()
{
sin_func = yproj;
buzzwave();
}

