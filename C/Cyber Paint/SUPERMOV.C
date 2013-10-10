
#include <osbind.h>
#include "flicker.h"
#include "flicmenu.h"

#define MAX_PPOINTS MAX_SCREENS

#define PATH_NONE	0
#define PATH_POINTS	1
#define PATH_SAMPLE	2
#define PATH_PROP	3

extern struct slidepot multiplier_sl, divisor_sl;
extern struct slidepot spra_x_sl, spra_y_sl, spra_z_sl;
extern struct slidepot sprc_x_sl, sprc_y_sl, sprc_z_sl;
extern struct slidepot spm_x_sl, spm_y_sl, spm_z_sl;
extern struct slidepot turns_sl, angle_sl;
extern Byte_cel *rs_bcel;
extern Cel *rs_cel;
extern WORD diamond_cursor[];

extern WORD spfirst_mode, screen_mode, tween_mode;

extern struct slidepot speed_sl;

char path_type;
WORD pdata_points;
Point pbuf[MAX_PPOINTS];

Super_settings first_settings =
	{
	-1, -1, -1,
	-1, -1, -1,
	99, 99,
	-1, -1, 99,
	-1, -1,
	};

Super_settings super_settings;

Vertex center_poly[6] = {
	{-5, 0, 0},
	{5, 0, 0},
	{0, -10, 0},
	{0, 10, 0},
	{0, 0, -5},
	{0, 0, -5},
	};

Vertex offset_center[6];
Point zcenter[7];


Vertex spoly[4];
static WORD rot_op[9];  /* hacked out of ani... */
static WORD rot_theta;
static WORD cenx, ceny, cenz;
Cel screen_cel =
	{
	0, 0, XMAX, YMAX,
	};

Vertex dpoly[4];

Point zpoly[5];

mouse_movexy(m)
Flicmenu *m;
{
Cel *oclip;
WORD ox, oy;
WORD dx, dy;

if (!check_clipping())
	return(0);
oclip = clipping;
if (screen_mode)
	{
	clipping = &screen_cel;
	screen_cel.image = NULL;
	}
ox = clipping->xoff;
oy = clipping->yoff;
msetup();
position_clip();
dx = clipping->xoff - ox;
dy = clipping->yoff - oy;
clipping->xoff = ox;
clipping->yoff = oy;
clipping = oclip;
spm_x_sl.value = dx-1;
spm_y_sl.value = dy-1;
mrecover();
}


save_sets()
{
if (spfirst_mode)
	settings_from_sliders(&first_settings);
else
	settings_from_sliders(&super_settings);
}

see_sets()
{
if (spfirst_mode)
	sliders_from_settings(&first_settings);
else
	sliders_from_settings(&super_settings);
}

load_ado(name)
char *name;
{
struct ado_settings ado;
WORD fd;
WORD success = 0;

if ((fd = Fopen(name, 0)) < 0)
	{
	couldnt_open(name);
	return(0);
	}
if ( Fread(fd, (long)sizeof(ado), &ado) < sizeof(ado) )
	{
	file_truncated(name);
	goto END;
	}
if (ado.magic != ADO_MAGIC)
	{
	bad_magic(name);
	goto END;
	}
pdata_points = ado.path_points;
if (Fread(fd, (long)pdata_points*sizeof(Point), pbuf) <
	(long)pdata_points * sizeof(Point) )
	{
	file_truncated(name);
	goto END;
	}
first_settings = ado.first;
super_settings = ado.motion;
see_sets();
success = 1;
END:
Fclose(fd);
return(success);
}

save_ado(name)
char *name;
{
struct ado_settings ado;
WORD fd;
WORD success = 0;

save_sets();
ado.magic = ADO_MAGIC;
ado.first = first_settings;
ado.motion = super_settings;
ado.path_points = pdata_points;
Fdelete(name);
if ((fd = Fcreate(name, 0)) < 0)
	{
	couldnt_open(name);
	return(0);
	}
if (Fwrite(fd, (long)sizeof(ado), &ado) < sizeof(ado) )
	{
	file_truncated(name);
	goto END;
	}
if (Fwrite(fd, (long)pdata_points*sizeof(Point), pbuf) <
	(long)pdata_points * sizeof(Point) )
	{
	file_truncated(name);
	goto END;
	}
success = 1;
END:
Fclose(fd);
return(success);
}


#ifdef JUST_FOR_DOCUMENTATION
act_interpolated_sample(point, op, scale)
register struct point *point;
register WORD *op;
WORD scale;
{
WORD samp0, samples, t0samp, little_scale;
WORD *samp_val0, *samp_val1;
WORD dx, dy, dz;

samples = *op++;
--samples;
samp0 = scale * samples/ SCALE_ONE;
t0samp = samp0 * SCALE_ONE / samples;
little_scale = (scale - t0samp)*samples;

samp_val0 = op + samp0*3;
samp_val1 = samp_val0 + 3;

--scale;
dx = scale_mult( *samp_val1++, little_scale)
	+ scale_mult(*samp_val0++, SCALE_ONE - little_scale);
dy = scale_mult( *samp_val1++, little_scale)
	+ scale_mult(*samp_val0++, SCALE_ONE - little_scale);
dz = scale_mult( *samp_val1++, little_scale)
	+ scale_mult(*samp_val0++, SCALE_ONE - little_scale);

point->x += dx;
point->y += dy;
point->z += dz;
return;
}
#endif JUST_FOR_DOCUMENTATION

interpolate_sample(scale, delta_array)
register WORD scale;
register Point *delta_array;
{
register WORD samp0, little_scale;
register Point *samp_val0, *samp_val1;
WORD samples, t0samp;

samples = pdata_points - 1;
if (samples < 1)
	{
	delta_array->x = delta_array->y = 0;
	return;
	}
if (scale == SCALE_ONE)
	{
	samp0 = samples - 1;
	little_scale = SCALE_ONE;
	}
else
	{
	samp0 = (long)scale * samples / SCALE_ONE;
	t0samp = (long)samp0 * SCALE_ONE / samples;
	little_scale = (scale - t0samp) * samples;
	}
#ifdef DEBUGG
printf("scale %d samples %d\n", scale, samples);
printf("samp0 %d, little_scale %d\n", samp0, little_scale);
wait_click();
#endif DEBUGG
samp_val0 = pbuf + samp0;
samp_val1 = samp_val0 + 1;

delta_array->x = scale_mult( samp_val1->x-pbuf[0].x, little_scale)
	+ scale_mult(samp_val0->x-pbuf[0].x, SCALE_ONE - little_scale);
delta_array->y = scale_mult( samp_val1->y-pbuf[0].y, little_scale)
	+ scale_mult(samp_val0->y-pbuf[0].y, SCALE_ONE - little_scale);
}



calc_center()
{
register Vertex  *v;
register Point *p;
register WORD i;

cenx = sprc_x_sl.value+1;
ceny = sprc_y_sl.value+1;
cenz = sprc_z_sl.value+1;
v = offset_center;
copy_structure(center_poly, v,  sizeof(offset_center) );
i = 6;
while (--i >= 0)
	{
	v->x += cenx;
	v->y += ceny;
	v->z += cenz;
	v++;
	}
calc_zpoly(offset_center, zcenter, 6);
offset_zpoly(zcenter, XMAX/2, YMAX/2, 6);
}

draw_center()
{
register Point *p;

set_acolor(oppositec[0]);
p = zcenter;
thin_polyline(p, 2);
thin_polyline(p+2, 2);
thin_polyline(p+4, 2);
}


settings_from_sliders(ss)
register Super_settings *ss;
{
ss->movex = spm_x_sl.value;
ss->movey = spm_y_sl.value;
ss->movez = spm_z_sl.value;
ss->cenx = sprc_x_sl.value;
ss->ceny = sprc_y_sl.value;
ss->cenz = sprc_z_sl.value;
ss->mul = multiplier_sl.value;
ss->div = divisor_sl.value;
ss->xax = spra_x_sl.value;
ss->yax = spra_y_sl.value;
ss->zax = spra_z_sl.value;
ss->turns = turns_sl.value;
ss->degrees = angle_sl.value;
}

sliders_from_settings(ss)
register Super_settings *ss;
{
spm_x_sl.value = ss->movex;
spm_y_sl.value = ss->movey;
spm_z_sl.value = ss->movez;
sprc_x_sl.value = ss->cenx;
sprc_y_sl.value = ss->ceny;
sprc_z_sl.value = ss->cenz;
multiplier_sl.value = ss->mul;
divisor_sl.value = ss->div;
spra_x_sl.value = ss->xax;
spra_y_sl.value = ss->yax;
spra_z_sl.value = ss->zax;
turns_sl.value = ss->turns;
angle_sl.value = ss->degrees;
}


init_spoly()
{
register Cel *c;

c = (screen_mode ? &screen_cel : clipping);
if (c == NULL)
	return;
spoly[0].x = spoly[1].x = spoly[2].x = spoly[3].x = c->xoff - XMAX/2;
spoly[0].y = spoly[1].y = spoly[2].y = spoly[3].y = c->yoff - YMAX/2;
spoly[1].y += c->height-1;
spoly[2].y += c->height-1;
spoly[2].x += c->width-1;
spoly[3].x += c->width-1;
spoly[0].z = spoly[1].z = spoly[2].z = spoly[3].z = 0;
}

super_center()
{
init_spoly();
sprc_x_sl.value = ((spoly[0].x + spoly[2].x)>>1);
sprc_y_sl.value = ((spoly[0].y + spoly[2].y)>>1);
sprc_z_sl.value = -1;
}


offset_zpoly(zp, x, y, i)
register Point *zp;
WORD x,y;
int i;
{

while (--i >= 0)
	{
	zp->x += x;
	zp->y += y;
	zp += 1;
	}
}

calc_zpoly(poly, zp, i)
register Vertex *poly;
register Point *zp;
int i;
{

while (--i >= 0)
	{
	zp->x = sscale_by(poly->x, GROUND_Z, poly->z+GROUND_Z);
	zp->y = sscale_by(poly->y, GROUND_Z, poly->z+GROUND_Z);
	zp += 1;
	poly += 1;
	}
}



size_dpoly(so_far, in_tween)
WORD so_far, in_tween;
{
register WORD mul, div;
WORD i;
WORD scale;
register Vertex  *d;

if (multiplier_sl.value == divisor_sl.value)
	return;

scale = uscale_by(SCALE_ONE, so_far, in_tween);
div = (divisor_sl.value+1) << 8;
mul = (multiplier_sl.value+1) << 8;
if (div == 0)	/* axe zero divide most cruelly */
	{
	div = 1;
	mul++;
	}
if (div < 32)	/* attempt to make things smoother for small div */
	{
	div <<= 4;
	mul <<= 4;
	}
mul = scale_mult(div, SCALE_ONE - scale)  +  scale_mult(mul, scale);
d = dpoly;
i = 4;
while (--i >= 0)
	{
	d->x = ((long)mul * (d->x - cenx ) ) /div + cenx; 
	d->y = ((long)mul * (d->y - ceny ) ) /div + ceny; 
	d->z = ((long)mul * (d->z - cenz ) ) /div + cenz; 
	d += 1;
	}
}

rot_dpoly(so_far, in_tween)
WORD so_far, in_tween;
{
WORD i;
register Vertex *d;
WORD scale;

d = dpoly;
i = 4;
rot_op[5] = rot_theta;
scale = uscale_by(SCALE_ONE, so_far, in_tween);
while (--i >= 0)
	{
	act_rotate( d, rot_op, scale);
	d += 1;
	}
}

mv_dpoly(dx, dy, dz)
WORD dx, dy, dz;
{
WORD i;
register Vertex *d;

d = dpoly;
i = 4;
while (--i >= 0)
	{
	d->x += dx;
	d->y += dy;
	d->z += dz;
	d++;
	}
}

move_dpoly(so_far, in_tween)
WORD so_far, in_tween;
{
mv_dpoly( sscale_by(spm_x_sl.value+1, so_far, in_tween),
	sscale_by(spm_y_sl.value+1, so_far, in_tween),
	sscale_by(spm_z_sl.value+1, so_far, in_tween) );
}

transform_dpoly(so_far, in_tween)
register WORD so_far, in_tween;
{
size_dpoly(so_far, in_tween);
rot_dpoly(so_far, in_tween);
move_dpoly(so_far, in_tween);
}

ptransform_dpoly(so_far, in_tween)
register WORD so_far, in_tween;
{
Point dxy;

if (!tween_mode)
	so_far = in_tween = 1;
transform_dpoly(so_far, in_tween);
#ifdef DEBUGG
printf("so_far %d in_tween %d\n", so_far, in_tween);
#endif DEBUGG
interpolate_sample(uscale_by(SCALE_ONE, so_far, in_tween), &dxy);
mv_dpoly(dxy.x, dxy.y, 0);
}

init_transform_dpoly()
{
rot_theta = (turns_sl.value+1)*TWO_PI + 
	sscale_by(angle_sl.value+1, TWO_PI, 360);
cenx = rot_op[0] = sprc_x_sl.value+1;
ceny = rot_op[1] = sprc_y_sl.value+1;
cenz = rot_op[2] = sprc_z_sl.value+1;
rot_op[6] = spra_x_sl.value+1;
rot_op[7] = spra_y_sl.value+1;
rot_op[8] = spra_z_sl.value+1;
find_conjugates(rot_op);
}

char *please_clip_text[] =
	{
	"Please put something in the,",
	"clip buffer, or switch clip",
	"to seq. Don't know what to move.",
	NULL,
	};

check_clipping()
{
if (!screen_mode && clipping == NULL)
	{
	continu_from_menu(please_clip_text);
	return(0);
	}
return(1);
}

super_startup()
{
if (!check_clipping())
	return(0);
hide_mouse();

/* save the sliders cause gonna stomp them soon... */
save_sets();
init_spoly();
sliders_from_settings(&first_settings);
init_transform_dpoly();
copy_structure(spoly, dpoly, sizeof(spoly) );
transform_dpoly(1, 1);
copy_structure(dpoly, spoly, sizeof(spoly) );
sliders_from_settings(&super_settings);
init_transform_dpoly();
find_start_stop();
return(1);
}

extern Cel *raster_transform();

super_paste()
{
if (screen_mode)
	{
	clear_screen();
	copy_celblit(minmax.xmin, minmax.ymin, rs_cel);
	}
else
	do_paste(rs_cel, minmax.xmin, minmax.ymin);
}

char *render_all_lines[] =
	{
	"Render over all frames?",
	"      (no undo)",
	NULL,
	};

really_render()
{
if (select_mode == 1)	/* over segment */
	return(really_segment("Render over segment?", "    (no undo)"));
else if (select_mode == 2) /* over all */
	return(yes_no_from(render_all_lines) );
return(1);
}

super_render(m)
Flicmenu *m;
{
Cel *source_cel;


if (!really_render())
	return;
if (!super_startup())
	return;
nohblanks();
dirty_file = 1;
if (select_mode == 0)
	dirty_frame = 1;
msetup();
hide_mouse();
if (screen_mode)
	{
	screen_cel.image = bscreen;
	source_cel = &screen_cel;
	}
else
	{
	source_cel = clipping;
	}
if ( (rs_bcel = cel_to_byte(source_cel)) == NULL)
	{
	outta_memory();
	goto OUTOFIT;
	}
if (select_mode == 0)	/* frames */
	{
	copy_structure(spoly, dpoly, sizeof(spoly) );
	ptransform_dpoly(1, 1);
	calc_zpoly(dpoly, zpoly, 4);
	offset_zpoly(zpoly, XMAX/2, YMAX/2, 4);
	if ((rs_cel = raster_transform(rs_bcel, zpoly)) == NULL)
		{
		outta_memory();
		goto OUTOFIT;
		}
	super_paste();
	}
else
	{
	multi_super();
	}
OUTOFIT:
rs_cleanup();
see_sets();
mrecover();
yeshblanks();
}

multi_super()
{
WORD start, end, count, ds;
WORD iangle;
WORD cenx, ceny;
WORD i;
WORD oscreen_ix;
WORD direction;

clean_ram_deltas(bscreen);
if (select_mode == 1)	/* over segment */
	{
	clip_trange();
	start = trange.v1-1;
	end = trange.v2-1;
	direction = ( start < end ? 1 : -1 );
	count  = ds = (end - start)*direction;
	}
else	/* over all */
	{
	start = 0;
	count = ds = end = screen_ct - 1;
	direction = 1;
	}
count += 1;
oscreen_ix = screen_ix;
copy_screen(bscreen, pscreen);
cscreen = pscreen;
tseek(start, cscreen);
for (i=0; i<count; i++)
	{
	if (abort_multi(i, count))
		break;
	free_cel(rs_cel);
	rs_cel = NULL;
	if (screen_mode)
		{
		free_byte_cel(rs_bcel);
		copy_screen(pscreen, bscreen);
		if ( (rs_bcel = cel_to_byte(&screen_cel)) == NULL)
			{
			outta_memory();
			break;
			}
		}
	copy_structure(spoly, dpoly, sizeof(spoly) );
	ptransform_dpoly(i, ds);
	calc_zpoly(dpoly, zpoly, 4);
	offset_zpoly(zpoly, XMAX/2, YMAX/2, 4);
	if ((rs_cel = raster_transform(rs_bcel, zpoly)) == NULL)
		{
		outta_memory();
		break;
		}
	super_paste();
	if (!sub_ram_deltas(cscreen))
		break;
	screen_ix += direction;
	if (screen_ix < 0 || screen_ix >= screen_ct)
		{
		screen_ix -= direction;
		break;
		}
	if (direction > 0)
		advance_next_prev(cscreen);
	else
		retreat_next_prev(cscreen);
	qsee_frame(cscreen, direction);
	}
hide_mouse(); /* just for error aborts */
abs_tseek(oscreen_ix, cscreen);
copy_screen(cscreen, bscreen);
}


super_preview(m)
Flicmenu *m;
{
WORD i;
WORD ticks;
register long desttime;

if (!super_startup())
	return;
nohblanks();
set_solid_line();
set_acolor(oppositec[0]);
calc_center();
ticks = speed_sl.value+1;
desttime = get60hz() + ticks;
for (i=0; i<=range_frames; i++)
	{
	copy_structure(spoly, dpoly, sizeof(spoly) );
	ptransform_dpoly(i, range_frames);
	calc_zpoly(dpoly, zpoly, 4);
	offset_zpoly(zpoly, XMAX/2, YMAX/2, 4);
	zpoly[4] = zpoly[0];
	copy_screen(bscreen, pscreen);
#ifdef LATER
	clear_screen();
#endif LATER
	thin_polyline(zpoly, 5);
	draw_center();
	for (;;)
		{
		check_input();
		if (RJSTDN || key_hit)
			goto enough;
		if (get60hz() >= desttime)
			break;
		}
	desttime += ticks;
	}
wait_a_jiffy(20);
enough:
see_sets();
redraw_menu_frame();
}

extern WORD spfirst_mode, screen_mode, tween_mode;
char *path_not_first[] =
	{
	"Path only works in",
	"motion mode.",
	NULL,
	};

first_path()
{
if (spfirst_mode)
	{
	continu_from(path_not_first);
	return(1);
	}
else
	return(0);
}


make_prop_path(m)
Flicmenu *m;
{
make_sample(PATH_PROP);
}

make_path(m)
Flicmenu *m;
{
make_sample(PATH_SAMPLE);
}

#define CLK_RAD 24

make_sample(op)
WORD op;
{
WORD i;
WORD ticks;
WORD sample;
WORD lastcx, lastcy;
Point clk;
WORD imax;
register long desttime;
WORD occolor;

if (first_path())
	return;
nohblanks();
if (sample = (op == PATH_SAMPLE))
	{
	ticks = speed_sl.value+1;
	polar(-TWO_PI/4, CLK_RAD, &clk);
	find_start_stop();
	imax = range_frames;
	set_xor_line();
	}
else
	{
	ticks = 2;
	imax = MAX_PPOINTS;
	}

hide_mouse();
#ifdef LATER
clear_screen();
#endif LATER
copy_screen(bscreen, pscreen);
show_clip_edge();
show_mouse();
wait_click();
if (RJSTDN)
	goto outta_here;
i = 0;
set_acolor(oppositec[0]);
desttime = get60hz() + ticks;
for (;;)
	{
	pbuf[i].x = mouse_x;
	pbuf[i].y = mouse_y;
	i++;
	hide_mouse();
	putdot(mouse_x, mouse_y, oppositec[0]);
	if (sample)
		{
		thin_line(XMAX/2, CLK_RAD, XMAX/2+clk.x, CLK_RAD+clk.y);
		polar(uscale_by(TWO_PI, i, imax)-TWO_PI/4, CLK_RAD, &clk);
		thin_line(XMAX/2, CLK_RAD, XMAX/2+clk.x, CLK_RAD+clk.y);
		}
	show_mouse();
	if (i >= imax)
		{
		break;
		}
	for (;;)
		{
		check_input();
		if (RJSTDN || !sample && !PDN)
			goto enough;
		if (get60hz() >= desttime)
			break;
		}
	desttime += ticks;
	}
enough:
pdata_points = i;
path_type = op;
outta_here:
hide_mouse();
redraw_menu_frame();
}

make_path_points(m)
Flicmenu *m;
{
WORD i;

if (first_path())
	return;
nohblanks();
hide_mouse();
copy_screen(bscreen, pscreen);
show_clip_edge();
#ifdef LATER
clear_screen();
#endif LATER
show_mouse();
set_xor_line();
i = 0;
for (;;)
	{
	check_input();
	if (RJSTDN)
		break;
	if (PJSTDN)
		{
		if (i >= MAX_PPOINTS-1)
			{
			flash_red();
			break;
			}
		hide_mouse();
		pbuf[i].x = mouse_x;
		pbuf[i].y = mouse_y;
		i++;
		pbuf[i].x = mouse_x;
		pbuf[i].y = mouse_y;
		draw_brush(diamond_cursor, mouse_x-8, mouse_y-8, oppositec[0] );
		thin_polyline(pbuf+i-1, 2);
		show_mouse();
		}
	else if (mouse_moved)
		{
		if (i != 0)
			{
			hide_mouse();
			thin_polyline(pbuf+i-1, 2);	/* erase old one... */
			pbuf[i].x = mouse_x;
			pbuf[i].y = mouse_y;
			thin_polyline(pbuf+i-1, 2);	/* draw new one... */
			}
		}
	}
path_type = PATH_POINTS;
pdata_points = i;
hide_mouse();
redraw_menu_frame();
}

clear_path(m)
Flicmenu *m;
{
hide_mouse();
hilight(m);
pdata_points = 0;
path_type = PATH_NONE;
draw_sel(m);
show_mouse();
}

