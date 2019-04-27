/*
	Revised version of Cmanship Chapter 10 listing,
	to permit compilation on Firebee with AHCC.
	Revision by Peter Lane, 2012.
*/

#include <aes.h>
#include <tos.h>
#include <vdi.h>

int work_in[11], work_out[57];
int handle;
int contrl[12], intin[128];
int ptsin[128], intwk[128], ptsout[128];
int gr_hwchar, gr_hhchar, gr_hwbox, gr_hhbox;

void open_vwork (void);
void do_pline (void);
void do_roundrec (void);
void do_froundrec (void);
void do_circle (void);
void do_pmarker (void);
void do_bar (void);
void do_ellipse (void);
void do_arc (void);
void do_pieslice (void);
void do_fills (void);
void my_clrwk (int handle); // replaces call to v_clrwk which crashes

int main ()
{
	appl_init ();
	open_vwork ();
	do_pline ();
	do_roundrec ();
	do_froundrec ();
	do_circle ();
	do_pmarker ();
	do_bar ();
	do_ellipse ();
	do_arc ();
	do_pieslice ();
	do_fills ();
	v_clsvwk (handle);
	appl_exit ();

	return 0;
}

void open_vwork (void)
{
	int i;
	for (i = 0; i < 10; work_in[i++] = 1);
	work_in[2] = 2;
	handle = graf_handle (&gr_hwchar, &gr_hhchar, &gr_hwbox, &gr_hhbox);
	v_opnvwk (work_in, &handle, work_out);
}

void do_pline (void)
{
	int pxy [] = {30, 20, 280, 20};
	int colour, end, type, width;

	end = 0; width = 1;
	my_clrwk (handle);
	for (colour = 1; colour < 5; colour += 1) {
		vsl_color (handle, colour);
		vsl_ends (handle, end, end);
		vsl_width (handle, width);
		v_pline (handle, 2, pxy);
		pxy[1] += 10; pxy[3] += 10;
		end += 1; width += 2;
	}
	vsl_width (handle, 1);
	vsl_ends (handle, 0, 0);
	vsl_color (handle, 1);
	for (type = 1; type < 7; type += 1) {
		vsl_type (handle, type);
		pxy[1] += 10; pxy[3] += 10;
		v_pline (handle, 2, pxy);
	}
	Cconin ();
}

void do_roundrec (void)
{
	int pxy [] = { 10, 10, 300, 190 };
	int colour, width;

	width = 1;
	my_clrwk (handle);
	vsl_type (handle, 1);
	for (colour = 1; colour < 7; colour += 1) {
		vsl_width (handle, width);
		vsl_color (handle, colour);
		v_rbox (handle, pxy);
		width += 2;
		pxy[0] += 20; pxy[2] -= 20;
		pxy[1] += 10; pxy[3] -= 10;
	}
	Cconin ();
}

void do_froundrec (void)
{
	int pxy [] = { 10, 10, 300, 190 };
	int colour;

	my_clrwk (handle);
	for (colour = 1; colour < 7; colour += 1) {
		vsf_color (handle, colour);
		v_rfbox (handle, pxy);
		pxy[0] += 20; pxy[2] -= 20;
		pxy[1] += 10; pxy[3] -= 10;
	}
	Cconin ();
}

void do_circle (void)
{
	int colour, radius;

	my_clrwk (handle);
	radius = 100;
	for (colour = 1; colour < 8; colour += 1) {
		vsf_color (handle, colour);
		v_circle (handle, 150, 100, radius);
		radius -= 15;
	}
	Cconin ();
}

void do_pmarker (void) // not working, only producing dots
{
	int colour, height, type;
	int pxy [] = { 10, 10 };

	my_clrwk (handle);
	for (type = 1; type < 7; type += 1) {
		vsm_type (handle, type);
		height = 2; pxy[0] = 10;
		for (colour = 1; colour < 6; colour += 1) {
			vsm_color (handle, colour);
			vsm_height (handle, height);
			v_pmarker (handle, 1, pxy);
			height += 16; pxy[0] += 60;
		}
		pxy[1] += 35;
	}
	Cconin ();
}

void do_bar (void)
{
	int pxy [] = {10, 190, 200, 10};
	int colour;

	my_clrwk (handle);
	for (colour = 1; colour < 6; colour += 1) {
		vsf_color (handle, colour);
		v_bar (handle, pxy);
		pxy[0] += 25; pxy[1] -= 20;
		pxy[2] -= 20; pxy[3] += 10;
	}
	Cconin ();
}

void do_ellipse (void)
{
	int xradius, yradius, colour;

	my_clrwk (handle);
	xradius = 150; yradius = 100;
	for (colour = 1; colour < 11; colour += 1) {
		vsf_color (handle, colour);
		v_ellipse (handle, 150, 100, xradius, yradius);
		xradius -= 15;
	}
	Cconin ();
}

void do_arc (void)
{
	int bang, eang, radius, colour;

	my_clrwk (handle);
	vsl_width (handle, 3);
	bang = 900; eang = 10; radius = 10;
	for (colour = 1; colour < 6; colour += 1) {
		vsl_color (handle, colour);
		v_arc (handle, 150, 100, radius, bang, eang);
		bang += 60; eang -= 60; radius += 20;
	}
	Cconin ();
}

void do_pieslice (void)
{
	int bang, eang, radius, colour;

	my_clrwk (handle);
	vsl_width (handle, 3);
	bang = 3200; eang = 600; radius = 100;
	for (colour = 1; colour < 6; colour += 1) {
		vsf_color (handle, colour);
		v_pieslice (handle, 150, 100, radius, bang, eang);
		bang -= 200; eang -= 100; radius -= 15;
	}
	Cconin ();
}

void do_fills (void)
{
	int pxy [] = { 50, 30, 250, 170 };
	int i, num, style;

	num = 25;
	for (i = 2; i < 4; i += 1) {
		vsf_interior (handle, i);
		for (style = 1; style < num; style += 1) {
			vsf_style (handle, style);
			my_clrwk (handle);
			vsf_color (handle, i);
			v_bar (handle, pxy);
			Cconin ();
		}
		num = 13;
	}
}

void my_clrwk (int handle)
{
	int pxy [] = {0, 0, 310, 200 };
	vsf_color (handle, 0);
	v_rfbox (handle, pxy);
}
