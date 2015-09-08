/*
	This routine will search for the desired voice in all the bulk
	file data
*/

#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <string.h>
#include "dx.h"
#include "dxed.h"

extern char temp[];
extern int res;


int search_v(b_buff,edit,name,vw)
char b_buff[],edit[],name[];
int vw;
{
	int wh,x,y,w,h;	/*	data for a window	*/
	int row,col,inc,drive,exit;
	char in_path[128],in_file[14],path[128],*ptr;
	long temp_dta;
	char dta[60];
	extern gl_hchar,gl_wchar;

	x = 20; y = 20; w = gl_wchar * 54; h = gl_hchar * 16;
	wind_calc(WC_BORDER,NAME,x,y,w,h,&x,&y,&w,&h);
	wh = wind_create(NAME,x,y,w,h);
	wind_set(wh,WF_NAME,"SEARCHING ...",0,0);
	wind_open(wh,x,y,w,h);
	wind_get(wh,WF_WORKXYWH,&x,&y,&w,&h);
	clr_wind(wh,vw);
	inc = 8 * res;
	row = x + inc;
	col = y + 16;
	v_gtext(vw,row,col,"*** Select Path Name Only ****");
	form_alert(1,"[1][Use the following | dialog box to select | only the path for | the search][OK]");
	in_file[0] = '\0';
	drive = Dgetdrv();
	sprintf(in_path,"%c:\\",drive + 'A');
	Dgetpath(temp,drive);
	strcat(in_path,temp);
	strcat(in_path,"*.VCE");
	do
	{
		fsel_input(in_path,in_file,&exit);
		if(exit == 0)
		{
			wind_close(wh);	/*	action is canceled	*/
			wind_delete(wh);
			return(-1);
		}
	}while(exit != 1);
	temp_dta = (long)Fgetdta();
	Fsetdta(dta);
	strcpy(path,in_path);
	ptr = rindex(path,'\\');
	++ptr;
	*ptr = '\0';
	if(Fsfirst(in_path,0) < 0)
	{
		form_alert(1,"[3][Cannot find any bulk files][OK]");
			wind_close(wh);	/*	action is canceled	*/
			wind_delete(wh);
			return(-1);
	}
	do
	{
		strcpy(in_path,path);
		strcat(in_path,&dta[30]);
		sprintf(temp,"First file %s",in_path);
		clr_wind(wh,vw);
		v_gtext(vw,row,col,temp);
		exit = do_search(name,in_path,b_buff,vw,wh);	/*	search the buffer	*/
	}while((Fsnext() >= 0) && (exit < 0));
	wind_close(wh);	/*	action is canceled	*/
	wind_delete(wh);
	return(exit);
}

do_search(name,file,bulk,vw,wh)
char name[],bulk[],file[];
{
	int fd,i,index,j;
	char b_name[11];
	int x,y,w,h,r,c,n,nr;
	extern gl_hchar,gl_wchar;

	wind_get(wh,WF_WORKXYWH,&x,&y,&w,&h);
	r = y + 32;
	c = x;
	n = h / gl_hchar - 2;
	fd = Fopen(file,0);	/*	open read only	*/
	Fread(fd,4096L,bulk);	/*	read into bulk buffer	*/
	index = 118;
	nr = 0;
	for(i=0;i<32;++i)
	{
		for(j=0;j<10;++j)
			b_name[j] = bulk[index + j];
		b_name[10] = '\0';
		sprintf(temp,"VOICE: %s",b_name);
		v_gtext(vw,c,r,temp);
		r = r + gl_hchar;
		nr++;
		if (nr == n)
		{
			r = y + 32;
			c = c + 18 * gl_wchar;
			nr = 0;
		}
		if(strcmp(name,b_name) == 0)
			return(i);
		index += 128;
	}
	return(-1);
}

clr_wind(wh,vw)
int wh,vw;
{
	int pxy[4];
	int x,y,w,h;

	wind_get(wh,WF_WORKXYWH,&x,&y,&w,&h);
	pxy[0] = x;
	pxy[1] = y;
	pxy[2] = x + w -1;
	pxy[3] = y + h - 1;
	vsf_interior(vw,2);
	vsf_style(vw,8);
	vsf_color(vw,0);
	v_bar(vw,pxy);
}

