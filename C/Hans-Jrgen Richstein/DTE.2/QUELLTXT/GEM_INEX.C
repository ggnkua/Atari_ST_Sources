/****************************************/
/*   Include-Datei 1 von Michael Haar   */
/*   Geschrieben am 06.04.1992          */
/****************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <vdi.h>
#include <aes.h>

#define FL3DNONE 0x0000
#define FL3DIND 0x0200
#define FL3DBAK 0x0400
#define FL3DACT 0x0600

#define ECKENGROESSE 16

#define		Min(a,b)		(a<b)? a:b
#define		Max(a,b)		(a>b)? a:b

/* Globale Variablen: */

int work_in[12],work_out[57],e_work_out[57];
int handle,phys_handle;
int gl_hchar,gl_wchar,gl_hbox,gl_wbox;
int ap_id;
GRECT desk;
MFDB screen_mfdb;
MFDB dia_mfdb;

#include "BUT_MNGE.C"

/* Prototypen: */
int gem_init(void);
void gem_exit(void);
int rc_intersect( GRECT *p1, GRECT *p2);
int rc_equal(GRECT *p1, GRECT *p2);
int do_extdialog(OBJECT *tree, int *ob_x, int *ob_y, void (*andere_buttons)(OBJECT *tree, GRECT *r, int b_nr));

/*************************/
/*   GEM-Init-Prozedur   */
/*************************/
int gem_init(void)
{
	register int i;
	long len;

	if((ap_id = appl_init()) > -1)
	{
		for(i = 1; i < 10; work_in[i++] = 1)
			;
		work_in[10] = 2;
		phys_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
		work_in[0] = handle = phys_handle;
		v_opnvwk(work_in, &handle, work_out);
		vq_extnd(handle, 1, e_work_out);
	}

	wind_get(0, WF_WORKXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h);

	screen_mfdb.fd_addr = 0;
	if(handle)
	{
		len = (long)(work_out[0] + 8) / 8L * (long)(work_out[1] + 1) * (long)e_work_out[4];
		dia_mfdb.fd_addr = malloc(len);
		if(!dia_mfdb.fd_addr)
		{
			v_clsvwk(handle);
			appl_exit();
			return(-1);
		}
	}
	dia_mfdb.fd_w = screen_mfdb.fd_w = work_out[0];
	dia_mfdb.fd_h = screen_mfdb.fd_h = work_out[1];
	dia_mfdb.fd_wdwidth = screen_mfdb.fd_wdwidth = (work_out[0] + 1) / 16;
	dia_mfdb.fd_stand = screen_mfdb.fd_stand = 0;
	dia_mfdb.fd_nplanes = screen_mfdb.fd_nplanes = e_work_out[4];

	if(handle)
		return(0);

	free(dia_mfdb.fd_addr);
	return(-1);
}

/*************************/
/*   GEM-Exit-Prozedur   */
/*************************/
void gem_exit(void)
{       
		free(dia_mfdb.fd_addr);

        v_clsvwk(handle);
        appl_exit();
}

/***********************************/
/* Rechtecks-šberlappungs-FUNKTION */
/***********************************/
int rc_intersect(GRECT *p1, GRECT *p2)
{
	int tx, ty, tw, th;

	tw = Min(p1->g_x + p1->g_w, p2->g_x + p2->g_w);
	th = Min(p1->g_y + p1->g_h, p2->g_y + p2->g_h);
	tx = Max(p1->g_x, p2->g_x);
	ty = Max(p1->g_y, p2->g_y);

	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;

	return ((tw > tx) && (th > ty));
}

/*-------------------------------------------------*/
/* vergleicht zwei GRECT-Strukturen auf Gleichheit */
/*-------------------------------------------------*/

int rc_equal(GRECT *p1, GRECT *p2)
{
  if((p1->g_x != p2->g_x) ||
     (p1->g_y != p2->g_y) ||
     (p1->g_w != p2->g_w) ||
     (p1->g_h != p2->g_h)) return(0);
  return(1);
}

int do_extdialog(OBJECT *tree, int *ob_x, int *ob_y, void (*andere_buttons)(OBJECT *tree, GRECT *r, int b_nr))
{
	GRECT r1;
	int r, mx, my, mk, st;
	int xy[8];
	OBJECT *trees[2];

	trees[0] = tree;
	trees[1] = (void *)0L;
	init_buttons(trees);

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	graf_mouse(ARROW, 0);
	form_center(tree, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	if(*ob_x > -1)
	{
		r1.g_x += *ob_x - tree[0].ob_x;
		tree[0].ob_x = *ob_x;
	}
	if(*ob_y > -1)
	{
		r1.g_y += *ob_y - tree[0].ob_y;
		tree[0].ob_y = *ob_y;
	}

	/* Retten des Hintergrunds */
	xy[0] = r1.g_x;
	xy[1] = r1.g_y;
	xy[2] = r1.g_x + r1.g_w;
	xy[3] = r1.g_y + r1.g_h;
	xy[4] = 0;
	xy[5] = 0;
	xy[6] = r1.g_w;
	xy[7] = r1.g_h;
	graf_mouse(M_OFF, 0);
	vro_cpyfm(handle, S_ONLY, xy, &screen_mfdb, &dia_mfdb);
	graf_mouse(M_ON, 0);
	
	form_dial(FMD_START, r1.g_x, r1.g_y, r1.g_w, r1.g_h, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
	objc_draw(tree, ROOT, MAX_DEPTH, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
	vsf_perimeter(handle, 1);
	vsf_color(handle, 1);
	vsf_interior(handle, 0);
	vsf_style(handle, 0);
	graf_mouse(M_OFF, 0);
	xy[0] = r1.g_x;
	xy[1] = r1.g_y;
	xy[2] = xy[0] + r1.g_w;
	xy[3] = xy[1] + r1.g_h;
	vs_clip(handle, 1, xy);
	xy[0] = tree[0].ob_x + tree[0].ob_width - 1 - ECKENGROESSE;
	xy[1] = tree[0].ob_y;
	xy[2] = tree[0].ob_x + tree[0].ob_width - 1;
	xy[3] = tree[0].ob_y + ECKENGROESSE;
	v_bar(handle, xy);
	xy[0] = tree[0].ob_x + tree[0].ob_width - ECKENGROESSE;
	xy[3] = tree[0].ob_y + ECKENGROESSE - 1;
	v_bar(handle, xy);
	xy[0] = tree[0].ob_x + tree[0].ob_width - 1 - ECKENGROESSE;
	xy[1] = tree[0].ob_y;
	xy[2] = tree[0].ob_x + tree[0].ob_width - 1;
	xy[3] = tree[0].ob_y + ECKENGROESSE;
	v_pline(handle, 2, xy);
	vs_clip(handle, 0, xy);
	graf_mouse(M_ON, 0);

	do
	{
		r = form_do(tree, ROOT) & 0x7FFF;
		if((tree[r].ob_type == G_BOXCHAR) && ((tree[r].ob_spec.obspec.character == 1) || (tree[r].ob_spec.obspec.character == 2)))
		{
			/* Pfeile nach oben/unten */
			if(andere_buttons)
				andere_buttons(tree, &r1, r);
			evnt_button(0, 1, 0, &mx, &my, &mk, &st);
		}
		else if(r == 0)
		{
			graf_mkstate(&mx, &my, &mk, &st);
			if((mx > tree[0].ob_x + tree[0].ob_width - ECKENGROESSE) && (mx < tree[0].ob_x + tree[0].ob_width - 1))
				if((my > tree[0].ob_y) && (my < tree[0].ob_y + ECKENGROESSE))
				{
					/* Hintergrund zurck */
					xy[0] = 0;
					xy[1] = 0;
					xy[2] = r1.g_w;
					xy[3] = r1.g_h;
					xy[4] = r1.g_x;
					xy[5] = r1.g_y;
					xy[6] = r1.g_x + r1.g_w;
					xy[7] = r1.g_y + r1.g_h;
					graf_mouse(M_OFF, 0);
					vro_cpyfm(handle, S_ONLY, xy, &dia_mfdb, &screen_mfdb);
					graf_mouse(M_ON, 0);

					form_dial(FMD_FINISH, r1.g_x, r1.g_y, r1.g_w, r1.g_h, r1.g_x, r1.g_y, r1.g_w, r1.g_h);

/*					wind_update(END_UPDATE);
					wind_update(END_MCTRL);
					evnt_timer(0, 0);
					wind_update(BEG_UPDATE);
					wind_update(BEG_MCTRL); */

					graf_mouse(FLAT_HAND, 0);
					graf_dragbox(tree[0].ob_width, tree[0].ob_height,
								tree[0].ob_x, tree[0].ob_y,
								desk.g_x + 3, desk.g_y + 3, desk.g_w - 6, desk.g_h - 6,
								ob_x, ob_y);
					r1.g_x += *ob_x - tree[0].ob_x;
					r1.g_y += *ob_y - tree[0].ob_y;
					tree[0].ob_x = *ob_x;
					tree[0].ob_y = *ob_y;

					/* Retten des Hintergrunds */
					xy[0] = r1.g_x;
					xy[1] = r1.g_y;
					xy[2] = r1.g_x + r1.g_w;
					xy[3] = r1.g_y + r1.g_h;
					xy[4] = 0;
					xy[5] = 0;
					xy[6] = r1.g_w;
					xy[7] = r1.g_h;
					graf_mouse(M_OFF, 0);
					vro_cpyfm(handle, S_ONLY, xy, &screen_mfdb, &dia_mfdb);
					graf_mouse(M_ON, 0);

					graf_mouse(ARROW, 0);
					form_dial(FMD_START, r1.g_x, r1.g_y, r1.g_w, r1.g_h, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
					objc_draw(tree, ROOT, MAX_DEPTH, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
					graf_mouse(M_OFF, 0);
					xy[0] = r1.g_x;
					xy[1] = r1.g_y;
					xy[2] = xy[0] + r1.g_w;
					xy[3] = xy[1] + r1.g_h;
					vs_clip(handle, 1, xy);
					vsf_perimeter(handle, 1);
					vsf_color(handle, 1);
					vsf_interior(handle, 0);
					vsf_style(handle, 0);
					xy[0] = tree[0].ob_x + tree[0].ob_width - 1 - ECKENGROESSE;
					xy[1] = tree[0].ob_y;
					xy[2] = tree[0].ob_x + tree[0].ob_width - 1;
					xy[3] = tree[0].ob_y + ECKENGROESSE;
					v_bar(handle, xy);
					xy[0] = tree[0].ob_x + tree[0].ob_width - ECKENGROESSE;
					xy[3] = tree[0].ob_y + ECKENGROESSE - 1;
					v_bar(handle, xy);
					xy[0] = tree[0].ob_x + tree[0].ob_width - 1 -ECKENGROESSE;
					xy[1] = tree[0].ob_y;
					xy[2] = tree[0].ob_x + tree[0].ob_width - 1;
					xy[3] = tree[0].ob_y + ECKENGROESSE;
					v_pline(handle, 2, xy);
					vs_clip(handle, 0, xy);
					graf_mouse(M_ON, 0);
				}
		}
		else
		{
			tree[r].ob_state &= (~SELECTED);
			evnt_button(0, 1, 0, &mx, &my, &mk, &st);
			objc_draw(tree, r, MAX_DEPTH, tree[r].ob_x, tree[r].ob_y, tree[r].ob_width, tree[r].ob_height);
		}
	}
	while(r == 0);

	form_dial(FMD_FINISH, r1.g_x, r1.g_y, r1.g_w, r1.g_h, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	return(r);
}