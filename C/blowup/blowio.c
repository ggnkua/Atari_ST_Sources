#include <stdio.h>
#include <stdlib.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <math.h>
#include <string.h>
#include "blowconf.h" 

typedef struct
 {
char monitor[12];
int xres,yres;
int interlace;
int tc;
int clock;
double clock_Mhz;
int width,leb,rib,hsync;
int height,upb,lob,vsync;
int flags;
int own;
} config_type;

extern config_type configuration[256];
extern int config_nr;

extern int xres,yres,interlace,tc,tc_sel;
extern int vsync,hsync,y_off,ww,hh;
extern int u1,u2;
extern int pix_doub;
extern int pl_idx,x_start;
extern int clock,monitor_type;
extern double clock_Mhz,clock_tab[3];

char *monname[4]={"SM124","TV","VGA","TV"};
/*---------------------------------------------------*/
void load_own_conf(char* name)
{
FILE *file;
config_type *cnf;

int anz,conf_ok=0;

file=fopen(name,"r");
if (file==0) 
	return;
	
do
	{
	cnf=&configuration[config_nr];
	cnf->clock=0;
	anz=fscanf(file,"%s %i %i %i %i %i %i %i %i %i %i %i %i %i %lf",
	&cnf->monitor,&cnf->xres,&cnf->yres,&cnf->interlace,&cnf->clock,
	&cnf->width,&cnf->leb,&cnf->rib,&cnf->hsync,
	&cnf->height,&cnf->upb,&cnf->lob,&cnf->vsync,&cnf->flags,
	&cnf->clock_Mhz);
	cnf->own=1;
	switch (monitor_type)
	{
	case 0: if (!strncmp(cnf->monitor,"SM124",2))
			conf_ok=1;
		break;
	case 1:
	case 3: if (!strncmp(cnf->monitor,"TV",2))
			conf_ok=1;
		break;
	case 2:
		if (strncmp(cnf->monitor,"TV",2)||strncmp(cnf->monitor,"SM124",5))
			conf_ok=1;
	}
	if ((anz==15)&&(conf_ok)) config_nr++;
	conf_ok=0;
	} while(anz==15);


fclose(file);
}
/*---------------------------------------------------*/
void save_own_conf(char* name)
{
FILE *file;
config_type cnf;

int anz;

	file=fopen(name,"a");
	if (file==0) 
		return;

	cnf.clock=clock;
	if (monitor_type==0) strcpy(cnf.monitor,"SM124");
	else
	if (monitor_type==2) strcpy(cnf.monitor,"MS ");
	else	
	 strcpy(cnf.monitor,"TV");
	cnf.xres=xres;
	cnf.yres=yres*(1+(interlace==1));
	cnf.interlace=interlace;
	cnf.clock=clock;
	cnf.width=ww;
	cnf.leb=u1;
	cnf.rib=u2;
	cnf.hsync=hsync;
	cnf.height=hh;
	cnf.upb=y_off;
	cnf.lob=hh-y_off;
	cnf.vsync=vsync;
	cnf.clock_Mhz=clock_tab[clock];
	cnf.flags=(1<<pl_idx)+128;
	
	fprintf(file,"%s %i %i %i %i %i %i %i %i %i %i %i %i %i %lf\n",
	cnf.monitor,cnf.xres,cnf.yres,cnf.interlace,cnf.clock,
	cnf.width,cnf.leb,cnf.rib,cnf.hsync,
	cnf.height,cnf.upb,cnf.lob,cnf.vsync,cnf.flags,
	cnf.clock_Mhz);

	fclose(file);
}
/*---------------------------------------------------*/
int remove_conf(int nr)
{
FILE *file1,*file2;
int nc;
char buffer[256];
if (!configuration[nr].own)
	{putc(7,stderr);return 0;}
/* nr Zeilennr-1, die weg muss */
if ((file1=fopen("DEFAULT.BCF","r"))==0) return 0;
if ((file2=fopen("DEFAULT.BAK","w"))==0) return 0;
while (fgets(buffer,255,file1)
			&&(fputs(buffer,file2)!=EOF));
fclose(file1);
fclose(file2); 
if ((file1=fopen("DEFAULT.BAK","r"))==0) return 0;
if ((file2=fopen("DEFAULT.BCF","w"))==0) return 0;
nc=0;
while(fgets(buffer,255,file1)&&((nc==nr)||(fputs(buffer,file2)!=EOF))) nc++;
fclose(file1);
fclose(file2); 
return 1;
}
/*---------------------------------------------------*/
void do_save_conf()
{
save_own_conf("DEFAULT.BCF");
load_configuration_file();
}
