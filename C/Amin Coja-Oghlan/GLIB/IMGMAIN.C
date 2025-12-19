#include<glib.h>
#include<stdlib.h>
#include<ext.h>
#include<string.h>
#define KIND (NAME|CLOSER|MOVER|FULLER|SIZER|DNARROW|UPARROW|INFO|VSLIDE|LFARROW|RTARROW|HSLIDE)

static MFDB mfdb;
static IMGHEADER hdr;
static char path[1024] = "",name[16] = "";

int wclose(void);
void clear(int slot);
void wclear(void);

int wclose(void) {return(TRUE);}

void clear(int slot)
	{
	static MFDB dummy = {NULL};
	static int col[] = {1,0};
	
	pxyarray[4] = pxyarray[0];
	pxyarray[5] = pxyarray[1];
	pxyarray[6] = pxyarray[2];
	pxyarray[7] = pxyarray[3];
	pxyarray[0] += slots[0].fwx - slots[0].workx;
	pxyarray[1] += slots[0].fwy - slots[0].worky;
	pxyarray[2] += slots[0].fwx - slots[0].workx;
	pxyarray[3] += slots[0].fwy - slots[0].worky;
	if(pxyarray[0] >= hdr.im_scanwidth)
		pxyarray[0] = hdr.im_scanwidth;
	if(pxyarray[2] >= hdr.im_scanwidth)
		pxyarray[2] = hdr.im_scanwidth;
	if(pxyarray[1] >= hdr.im_nlines)
		pxyarray[1] = hdr.im_nlines;
	if(pxyarray[3] >= hdr.im_nlines)
		pxyarray[3] = hdr.im_nlines;
	vrt_cpyfm(vdi_handle,MD_REPLACE,pxyarray,&mfdb,&dummy,col);
	if(slots[slot].fwx + slots[slot].workw - 1 - 
		slots[slot].dw > 0)
		{
		vswr_mode(vdi_handle,MD_REPLACE);
		vsf_interior(vdi_handle,FIS_PATTERN);
		vsf_style(vdi_handle,4);
		vsf_color(vdi_handle,1);
		vsf_perimeter(vdi_handle,0);
		pxyarray[0] = slots[slot].workx - slots[slot].fwx + 
			 		  slots[slot].dw;
		pxyarray[1] = slots[slot].worky;
		pxyarray[2] = slots[slot].workx + slots[slot].workw - 1;
		pxyarray[3] = slots[slot].worky + slots[slot].workh - 1;
		v_bar(vdi_handle,pxyarray);
		}
	if(slots[slot].fwy + slots[slot].workh - 1 - 
		slots[slot].dh > 0)
		{
		vswr_mode(vdi_handle,MD_REPLACE);
		vsf_interior(vdi_handle,FIS_PATTERN);
		vsf_style(vdi_handle,4);
		vsf_color(vdi_handle,1);
		vsf_perimeter(vdi_handle,0);
		pxyarray[0] = slots[slot].workx;
		pxyarray[1] = slots[slot].worky - slots[slot].fwy +
					  slots[slot].dh;
		pxyarray[2] = slots[slot].workx + slots[slot].workw - 1;
		pxyarray[3] = slots[slot].worky + slots[slot].workh - 1;
		v_bar(vdi_handle,pxyarray);
		}
	}

void wclear(void)
	{
	int slot = g_find_handle(msgbuff[3]);
	
	msgbuff[4] = slots[slot].workx;
	msgbuff[5] = slots[slot].worky;
	msgbuff[6] = slots[slot].workw;
	msgbuff[7] = slots[slot].workh;
	g_redraw(slot,clear);
	}

void cut_string(char *inpath)
	{
	int i = strlen(inpath);

	while(inpath[--i] != '\\');
	inpath[i + 1] = '\0';
	}

int main()
	{
	FILE *h;
	void *mem,*dest;
	long int len;
	int exit;

	g_init(1,-1,-1,-1,-1,KIND);
	all_a1f = clear;
	all_b1f = wclear;
	slots[0].free[7] = KIND;
	getcwd(path,1020);
	fsel_input(strcat(path,"\\*.IMG"),name,&exit);
	if(!exit) return -1;
	cut_string(path);
	h = fopen(strcat(path,name),"rb");
	mem = malloc(len = filelength(h->Handle) + 16);
	fread(mem,1,len,h);
	fclose(h);
	dest = g_load_image(mem,&hdr);
	free(mem);
	mfdb.fd_addr = dest;
	mfdb.fd_w = hdr.im_scanwidth;
	mfdb.fd_h = hdr.im_nlines;
	mfdb.fd_wdwidth = mfdb.fd_w / 16 + (mfdb.fd_w % 16 != 0);
	mfdb.fd_nplanes = hdr.im_nplanes;
	g_structset(0,-2,-2,-2,x_desk + 16,y_desk + 16,w_desk - 32,
		h_desk - 32,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,32,32,0,0,mfdb.fd_w,
		mfdb.fd_h,0,0,0,0,"SHOW-IMG"," \275 by Amin Coja-Oghlan",NULL,
		NULL);
	g_owind(0,KIND);
	graf_mouse(ARROW,0L);
	g_multi(MU_MESAG,g_dummy,g_windall,g_windall,wclose,g_windall,g_windall,g_windall,g_windall,
		g_windall,g_windall,(int (*)(int))g_dummy);
	g_update(FALSE);
	g_exit();
	return 0;
	}