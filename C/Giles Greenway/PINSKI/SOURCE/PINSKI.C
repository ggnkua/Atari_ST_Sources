// PINSKI - A program to draw Sierpinski Gaskets. //
// Perpetrated in Lattice C by Giles Greenway. //

#include<aes.h>
#include<vdi.h>
#include<osbind.h>
#include<stdlib.h>
#include<string.h>
#include<stdio.h>
#include<dos.h>
// The resource file has been de-compiled using DERCS. //
#include"pin_res.h"
#include"pin_res.c"

#define KIND NAME|CLOSE|FULL|INFO|MOVE|SIZE
#define CEL 0
#define MONT 1
#define REC 2
#define NRMAL 0
#define INVRS 1
#define MED 1

void do_menu(short);
void ego_trip();
void set_up();
void fill_win(short,short,short,short);
void cell_auto();
void monte_carlo();
void recurse();
void do_rec(short*,int);
void win_change(short,short,short,short,short);
void save_img();

short vdi_hand,wx,wy,ww,wh,wwx,wwy,www,wwh,wfx,wfy,wfw,wfh,wwfw,wwfh,
nplanes,pix_w,pix_h;

int id,win_hand,run,mode,mod,plt_mode,any_data,res,max_dep;

MFDB crt,paste;

char infstr[80];

int main()
{
	
	short msg[8],wrk_in[11],wrk_out[57],junk;

	int xpix,ypix,paste_w,paste_ww,x,y,w,h;

	run = 1; mode = CEL; mod = 2; max_dep =4;
	plt_mode = NRMAL; any_data = 0;   

// start up GEM, rsrc_init() is provided by DERCS. //

	id = appl_init();
	rsrc_init();
	menu_bar(PIN_MEN,1);
	
	graf_mouse(0,0);

	vdi_hand = graf_handle(&junk,&junk,&junk,&junk);
	wrk_in[10] = 2;
	v_opnvwk(wrk_in,&vdi_hand,wrk_out);

	pix_w = wrk_out[3]; pix_h = wrk_out[4];

	vsf_color(vdi_hand,WHITE);
	vsf_interior(vdi_hand,8);
	vsf_style(vdi_hand,2);
 	vsm_color(vdi_hand,BLACK);
	vsm_type(vdi_hand,1);

// See what sort of screen we're dealing with... //

	xpix = wrk_out[0]; ypix = wrk_out[1];

	if (xpix > 3 * ypix) res = MED; else res = 0;

	vq_extnd(vdi_hand,1,wrk_out);
	nplanes = wrk_out[4];

	if (xpix > 639 || ypix > 399)
	{
		ww = 639; wh = 399; wx = (xpix - ww) / 2; wy = (ypix - wh) / 2;
	}
	else
	{
		wind_get(DESK,WF_WXYWH,&wx,&wy,&ww,&wh);
	}

	x = wx; y = wy; w = ww; h = wh;

	wind_calc(WC_WORK,KIND,x,y,w,h,&wwx,&wwy,&www,&wwh);

	wfx = wx; wfy = wy; wfw = ww; wfh = wh; wwfw = www; wwfh = wwh;

	crt.fd_addr = NULL;

	paste_ww = (www + 15) / 16;
	paste_w = paste_ww * 16;

// Reserve enough memory to store a full-size window. //

	paste.fd_addr = calloc(paste_ww * wwh * nplanes,2); 
	paste.fd_w = paste_w;
	paste.fd_h = wwh;
	paste.fd_wdwidth = paste_ww;
	paste.fd_stand = 0;
	paste.fd_nplanes = nplanes;
	

	win_hand = wind_create(KIND,x,y,w,h);

	if (win_hand < 0)
	{
		form_alert(1,"[1][Couldn't open the window !][ DRAT !]");
		goto NO_WIN;
	}

	wind_open(win_hand,x,y,w,h);
	wind_title(win_hand," PINSKI ");

// Main Loop. //

	while(run)
	{

		evnt_mesag(msg);

		switch(msg[0])
		{
			case MN_SELECTED: do_menu(msg[4]); 
			menu_tnormal(PIN_MEN,msg[3],1); break;

			case WM_CLOSED: if (msg[3] == win_hand) run = 0; break;
			
			case WM_REDRAW: if (msg[3] == win_hand)
			fill_win(msg[4],msg[5],msg[6],msg[7]); break;

			case WM_TOPPED: 
			if (msg[3] == win_hand)
			{
				wind_set(win_hand,WF_TOP,&junk,&junk,&junk,&junk);
				wind_info(win_hand,infstr);
			}		
			break;

			case WM_MOVED: 
			case WM_SIZED:
			if (msg[3] == win_hand)									
			win_change(msg[0],msg[4],msg[5],msg[6],msg[7]);
			break;

			case WM_FULLED:
			if (msg[3] == win_hand)
			{
				if (ww >= wfw && wh >= wfh)
				{
					wind_get(win_hand,WF_PXYWH,&wx,&wy,&ww,&wh);
					win_change(WM_SIZED,wx,wy,ww,wh);
				}
				else
					win_change(WM_SIZED,wfx,wfy,wfw,wfh);	
			}
		}	
			
	}


// Shut things down. //

	wind_close(win_hand);
	wind_delete(win_hand);

	NO_WIN:

	free(paste.fd_addr);

	v_clsvwk(vdi_hand);	

	menu_bar(PIN_MEN,0);
	appl_exit();

	return 0;

}

// Deal with menu events. //

void do_menu(short item)
{

	switch(item)
	{
		case QUIT: run = 0; break;
		case ABOUT: ego_trip(); break;
		case SETNGS: set_up(); break;
		case SAVE: save_img();
	}

}

// Say hello... //

void ego_trip()
{
	short x1,y1,w1,h1;
	int x,y,w,h,junk;

	
	form_center(PIN_ABT,&x1,&y1,&w1,&h1);
	x = x1; y = y1; w = w1; h = h1; 
	form_dial(FMD_START,junk,junk,junk,junk,x,y,w,h);
	objc_draw(PIN_ABT,ROOT,MAX_DEPTH,x,y,w,h);
	form_do(PIN_ABT,0);
	form_dial(FMD_FINISH,junk,junk,junk,junk,x,y,w,h);
	PIN_ABT[IWILT].ob_state &= ~SELECTED;
}

// Get information from the dialogue box. //

void set_up()
{

	short x1,y1,w1,h1,msg[8];

	int x,y,w,h,junk,old_mod,old_dep,old_mode,old_plt,redraw;

	TEDINFO *txt;

	form_center(PIN_FRM,&x1,&y1,&w1,&h1);
	x = x1; y = y1; w =w1; h = h1; 
	form_dial(FMD_START,junk,junk,junk,junk,x,y,w,h);
	objc_draw(PIN_FRM,ROOT,MAX_DEPTH,x,y,w,h);
	form_do(PIN_FRM,0);
	form_dial(FMD_FINISH,junk,junk,junk,junk,x,y,w,h);
	PIN_FRM[SET_OK].ob_state &= ~SELECTED;

	txt = PIN_FRM[MOD_BOX].ob_spec;

	old_mod = mod;
	mod = atoi(txt->te_ptext);

	if (mod == 0)
	{
		mod = 2;
		txt->te_ptext = "002";
	}	
	
	txt = PIN_FRM[DEP_BOX].ob_spec;

	old_dep = max_dep;	
	max_dep = atoi(txt->te_ptext);

	old_mode = mode;

	if(PIN_FRM[CELL].ob_state == SELECTED)
	mode = CEL;

	if(PIN_FRM[RECUR].ob_state == SELECTED)
	mode = REC;

	if(PIN_FRM[MONTE].ob_state == SELECTED)
	mode = MONT;

	old_plt = plt_mode;
	
	if (PIN_FRM[NORM].ob_state == SELECTED)
	plt_mode = NRMAL; else plt_mode = INVRS;

	redraw = 0;

	if (old_mode != mode) redraw = 1;
	if (mode == CEL && old_mod != mod) redraw = 1;
	if (mode == CEL && old_plt != plt_mode) redraw = 1;
	if (mode == REC && old_dep != max_dep) redraw = 1;

	if (redraw == 1)
	{
		any_data = 0; 
		msg[0] = WM_REDRAW; msg[1] = id;
		msg[2] = 0; msg[3] = win_hand; 
		msg[4] = wwx; msg[5] = wwy; 
		msg[6] = www; msg[7] = wwh;

		appl_write(id,sizeof(msg),msg);
	}


}

// Deal with redraw events. //

void fill_win(short x, short y, short w, short h)
{

	short box[8],top_win,junk;

	GRECT rec1,rec2;
	
	wind_update(BEG_UPDATE);
	graf_mouse(256,0);

// Produce a new image. //

	if (any_data == 0)
	{

		wind_info(win_hand,"");

		wind_get(win_hand,WF_TOP,&top_win,&junk,&junk,&junk);

		if (win_hand != top_win)
		wind_set(win_hand,WF_TOP,&junk,&junk,&junk,&junk);

		box[0] = wwx; box[1] = wwy; 
		box[2] = wwx + www - 1; box[3] = wwy + wwh - 1;
		v_bar(vdi_hand,box);
	
		if (mode == CEL) cell_auto();
		if (mode == MONT) monte_carlo();
		if (mode == REC) recurse(); 

		box[0] = wwx; box[1] = wwy;
		box[2] = wwx + www - 1; box[3] = wwy + wwh - 1;
		box[4] = 0; box[5] = 0;
		box[6] = www - 1; box[7] = wwh - 1;

// Copy the new image to memory. //

		vro_cpyfm(vdi_hand,S_ONLY,box,&crt,&paste);

		any_data = 1;

	}
	else
	{

// Fill in the window according to the rectanlge list. //

		rec1.g_x = x; rec1.g_y = y;
		rec1.g_w = w; rec1.g_h = h;

		wind_get(win_hand,WF_FIRSTXYWH,&rec2.g_x,&rec2.g_y,
		&rec2.g_w,&rec2.g_h);

		while (rec2.g_w && rec2.g_h)
		{
			if (rc_intersect(&rec1,&rec2))
			{
			
				box[0] = rec2.g_x - wwx; 
				box[1] = rec2.g_y - wwy;
				box[2] = box[0] + rec2.g_w - 1; 
				box[3] = box[1] + rec2.g_h - 1;
				box[4] = rec2.g_x; 
				box[5] = rec2.g_y;
				box[6] = rec2.g_x + rec2.g_w - 1; 
				box[7] = rec2.g_y + rec2.g_h - 1;

				vro_cpyfm(vdi_hand,S_ONLY,box,&paste,&crt);

			}
				
			wind_get(win_hand,WF_NEXTXYWH,&rec2.g_x,&rec2.g_y,
			&rec2.g_w,&rec2.g_h);
		
		}
	}
	wind_info(win_hand,infstr);
	graf_mouse(257,0);
	wind_update(END_UPDATE);

}

// Draw the gasket using the cellular automaton method. //

void cell_auto()
{

	short dot[4];

	int *c,*p,*swap,centre,x_loop,y_loop,x_min,x_max,x,n_dots;

	if (res == MED) n_dots = 2; else n_dots = 1;

	centre = wwx + www / 2;

	x_min = wwx; x_max = x_min + www - 1;
 

	p = calloc(wwh + 1,sizeof(int));
	c = calloc(wwh + 1,sizeof(int));
	
	p[0] = 1; c[0] = 1;

	for(y_loop = 0;y_loop <= wwh;y_loop++)
	{
		dot[1] = wwy + y_loop; dot[3] = dot[1];

		for(x_loop = 1;x_loop < y_loop;x_loop++)
		{
			c[x_loop] = (p[x_loop] + p[x_loop - 1]) % mod;
		}

		for (x_loop = 0;x_loop < y_loop;x_loop++)
		{
			if (res != MED)
			x = x_loop + centre - y_loop / 2;
			else
			x = 2 * x_loop + centre - y_loop;

			if (x >= x_min && x <= x_max)
			{
				dot[0] = x; dot[2] = x + 1;
				
				if (c[x_loop] == 0 && plt_mode == NRMAL)
				{v_pmarker(vdi_hand,n_dots,dot);}

				if (c[x_loop] != 0 && plt_mode == INVRS)
				{v_pmarker(vdi_hand,n_dots,dot);}

			}

		}

		swap = p; p = c; c = swap; 

		
	}
	
	if (plt_mode == NRMAL)
	sprintf(infstr," Pascal's triangle modulo %d.",mod);
	else
	sprintf(infstr," Pascal's triangle modulo %d. (inverse)",mod);
	
	
	free(p); free(c);

}

// Draw the gasket using a Monte-Carlo method. //

void monte_carlo()
{
	short xy[3][2],dot[2],junk,button;

	int gate;

	unsigned short seed;	

	long time;

	time = 1 + Gettime();

	seed = time & 65535;

	srand(seed);
	
	gate = rand() / 10922;

	xy[0][0] = wwx; xy[0][1] = wwy + wwh - 1;
	xy[1][0] = wwx + www - 1; xy[1][1] = xy[0][1];
	xy[2][0] = wwx + www / 2; xy[2][1] = wwy;

	dot[0] = xy[gate][0]; dot[1] = xy[gate][1];

	button = 0;

	wind_info(win_hand," Press the mouse button to stop:");	

	while(button == 0)
	{
		v_pmarker(vdi_hand,1,dot);
		gate = rand() / 10922;
		dot[0] = (dot[0] + xy[gate][0]) / 2;
		dot[1] = (dot[1] + xy[gate][1]) / 2;
		graf_mkstate(&junk,&junk,&button,&junk);
	}

	sprintf(infstr," Sierpinski Gasket. (random method)");

}

// Draw the gaket by a recursive method. //

void recurse()
{
	short tri[8];

	vsl_color(vdi_hand,BLACK);

	tri[0] = wwx + www / 2; tri[1] = wwy;
	tri[2] = wwx; tri[3] = wwy + wwh - 1;
	tri[4] = wwx + www - 1; tri[5] = tri[3];
	tri[6] = tri[0]; tri[7] = tri[1];	

	do_rec(tri,0);
	
	sprintf(infstr," Sierpinski Gasket recursion depth %d.",max_dep);

}				

// This function call itself. //

void do_rec(short *tri_in,int depth)
{
	short tri_out[8];	

	if (depth == max_dep)
	{
		v_pline(vdi_hand,4,tri_in);
	}
	else
	{
		tri_out[0] = tri_in[0]; 
		tri_out[1] = tri_in[1];
		tri_out[2] = (tri_in[0] + tri_in[2]) / 2;
		tri_out[3] = (tri_in[1] + tri_in[3]) / 2;
		tri_out[4] = (tri_in[0] + tri_in[4]) / 2;
		tri_out[5] = (tri_in[1] + tri_in[5]) / 2;
		tri_out[6] = tri_out[0];
		tri_out[7] = tri_out[1];

		do_rec(tri_out,depth+1);

		tri_out[0] = (tri_in[0] + tri_in[2]) / 2;
		tri_out[1] = (tri_in[1] + tri_in[3]) / 2;
		tri_out[2] = tri_in[2];
		tri_out[3] = tri_in[3];
		tri_out[4] = (tri_in[2] + tri_in[4]) / 2;
		tri_out[5] = (tri_in[3] + tri_in[5]) / 2;
		tri_out[6] = tri_out[0];
		tri_out[7] = tri_out[1];

		do_rec(tri_out,depth+1);

		tri_out[0] = (tri_in[0] + tri_in[4]) / 2;
		tri_out[1] = (tri_in[1] + tri_in[5]) / 2;
		tri_out[2] = (tri_in[2] + tri_in[4]) / 2;
		tri_out[3] = (tri_in[3] + tri_in[5]) / 2;
		tri_out[4] = tri_in[4];
		tri_out[5] = tri_in[5];
		tri_out[6] = tri_in[0];
		tri_out[7] = tri_in[1];

		do_rec(tri_out,depth+1);
	
	}

} 	

// Size and move the window. //

void win_change(short mes,short x,short y,short w,short h)
{
	short msg[8];

	if (w >= 160 && h >= 100)
	{
	
		wind_set(win_hand,WF_CXYWH,x,y,w,h);
		wx = x; wy = y; ww = w; wh = h;	

		wind_get(win_hand,WF_WXYWH,&wwx,&wwy,&www,&wwh);

		if (mes == WM_SIZED)
		{
			any_data = 0;
			msg[0] = WM_REDRAW; msg[1] = id; msg[2] = 0; msg[3] = win_hand;
			msg[4] = wwx; msg[5] = wwy; msg[6] = www; msg[7] = wwh;
			appl_write(id,sizeof(msg),msg);
		}
	}
}

// Save the window's contents in .IMG format. //

void save_img()
{

	char path[FMSIZE],fname[FNSIZE];

	int tmp_w,tmp_ww,tmp_bw,loop1,line_ptr,byte_count,
	dat_ptr,byte_wid,count,count_ptr;

	short fsel,but,head[8];

	unsigned char scan_line[160],*addr;
	
	MFDB tmp;

	FILE *f_ptr;

	sprintf(fname,"PINSKI.IMG");

	Dgetpath(path,0);
	strcat(path,"\\*.IMG");

// Get the filename. //

	fsel = fsel_exinput(path,fname,&but,"Save .IMG file:");

	if (fsel && but)
	{
		chdir(path);

		tmp_ww = (wwfw + 15) / 16;
		tmp_w = tmp_ww * 16;
		tmp_bw = tmp_ww * 2;

		tmp.fd_addr = calloc(tmp_ww * wwfh * nplanes,2);
		tmp.fd_w = tmp_w;
		tmp.fd_h = wwh;
		tmp.fd_wdwidth = tmp_ww;
		tmp.fd_stand = 1;
		tmp.fd_nplanes = nplanes;

		addr = tmp.fd_addr;
		byte_wid = (www + 7) / 8;

		vr_trnfm(vdi_hand,&paste,&tmp);

// Open the file. //

		graf_mouse(2,0);
		f_ptr = fopen(fname,"wb");

		if (f_ptr)
		{
			head[0] = 1; head[1] = 8; head[2] = 1; head[3] = 0;
			head[4] = pix_w; head[5] = pix_h; 
			head[6] = www; head[7] = wwh;
	
			fwrite(head,16,1,f_ptr);		
			
// All images are mono. Only the first bit-plane is needed. //

			for (loop1=1;loop1 <= wwh;loop1++)
			{
				dat_ptr = tmp_bw * (loop1 - 1); 
				line_ptr = 0;
				byte_count = 0;

				new_run:
	
// Do the run-length encoding. //

				switch(addr[dat_ptr])
				{
				case 0:
					dat_ptr++; count = 1; byte_count++;
					while (byte_count < byte_wid && addr[dat_ptr] == 0)
					{
						dat_ptr++; count++; byte_count++;
					}
					scan_line[line_ptr] = count; line_ptr++;
					break;

				case 255:
					dat_ptr++; count = 1; byte_count++;
					while (byte_count < byte_wid && addr[dat_ptr] == 255)
					{
						dat_ptr++; count++; byte_count++;
					}
					scan_line[line_ptr] = 128 | count;	line_ptr++;
					break;

					default:
					scan_line[line_ptr] = 128; line_ptr++;
					count_ptr = line_ptr; line_ptr++;
					scan_line[line_ptr] = addr[dat_ptr]; line_ptr++;
					count = 1; dat_ptr++; byte_count++;
					while (addr[dat_ptr] != 255 && addr[dat_ptr] != 0 &&
					byte_count < byte_wid)
					{
						scan_line[line_ptr] = addr[dat_ptr]; line_ptr++;
						dat_ptr++; count++; byte_count++;
					}
					scan_line[count_ptr] = count;
					break;			

				}

				if (byte_count < byte_wid) goto new_run;
					
				fwrite(scan_line,line_ptr,1,f_ptr);


			}

			fclose(f_ptr);
			graf_mouse(0,0);
		}
	
		free(tmp.fd_addr);
	}

}