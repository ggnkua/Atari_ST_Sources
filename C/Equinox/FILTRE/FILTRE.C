
#define	PI		3.14159265359
#define	RAIDEUR		0.1

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>
#include<aes.h>
#include<vdi.h>
#include<ext.h>
#include<tos.h>
#include"filtre.h"
#include"filtre.rsh"

/* Prototypes */

void create_window(void);
void open_window(void);
void close_window(void);
void deselect(int,int);
void menu_selected(void);
void init_rsc(void);
void close_rsc(void);
void open_rsc(int);
void end_prog(void);
void redraw_window(void);
char *get_ptext(int,int);
void change_infoline(void);
void load_sample(void);
void save_sample(void);
void convert_sample(int,int, int *,long);
void affiche_grille(void);
void draw_sample(int *,int);
void redraw_all(void);
int min(int,int);
int max(int,int);
float input(char *,float);
int passe_bas(double);
int passe_haut(double);
int passe_bande(double);
int coupe_bande(double);
void convolution(void);
int calc_one_data(int *,int *,long,int,long);

/* Globales */

OBJECT	*tree_adr,*menu_tree;
int	message[8],appl_id,max_x,max_y,gr_hwchar,gr_hhchar,gr_hwbox,gr_hhbox,
	phys_handle,handle,work_in[11],work_out[57],whandle,
	rsc_x,rsc_y,rsc_w,rsc_h,
	algo=BANDPASS,*base_mem,*work_mem,*filter,filter_size=0,
	format=8,signe=0x80,pos1,pos2;
float	freq=7.680,amplification=1.00;
long	sample_size=0L,offset;
char	infoline[80]="",work_path[80]="",sample_name[13]="",window_name[80]=" Sans Nom ";


void main()
{
int	i;
appl_id=appl_init();
for(i=0;i<10;i++) work_in[i]=1;
work_in[10]=2;
phys_handle=graf_handle(&gr_hwchar,&gr_hhchar,&gr_hwbox,&gr_hhbox);
handle=phys_handle;
v_opnvwk(work_in,&handle,work_out);
if(!handle) exit(1);
max_x=work_out[0];
max_y=work_out[1];
if(max_x<639){
	form_alert(1,"[1][|Ne fonctionne qu'en|  640x200 minimum.][Ben v'la]");
	exit(1);}
vsf_color(handle,0);
vswr_mode(handle,1);
init_rsc();
work_path[0]=(int)Dgetdrv()+'A';
work_path[1]=':';
Dgetpath((char *)&work_path[2],Dgetdrv()+1);
strcat(work_path,"\\");
graf_mouse(ARROW,(void*)0);
menu_tree=(OBJECT *)rs_trindex[MENU];
menu_bar(menu_tree,1);
create_window();
open_window();
do{
	evnt_mesag(message);
	wind_update(BEG_UPDATE);
	switch(message[0])
		{
		case MN_SELECTED:
			menu_selected();
			break;
		case WM_REDRAW:
			redraw_window();
			break;		
		case WM_TOPPED:
			wind_set(whandle,WF_TOP,0,0,0,0);
			break;
		case WM_HSLID:
			wind_set(whandle,WF_HSLIDE,message[4],0,0,0);
			offset=(sample_size/1000)*message[4];
			redraw_all();
			break;
		}
	wind_update(END_UPDATE);
}while(message[0]!=WM_CLOSED);
end_prog();
}
void menu_selected()
{
int objct,menu;
char *string;
menu=message[3];
switch(message[4]){
	case LOAD:
		close_window();
		load_sample();
		open_window();
		break;
	case SAVE:
		save_sample();
		break;
	case SETFREQ:
		freq=input("Nouvelle fr‚quence en Khz ?",freq);
		change_infoline();
		break;
	case SETAMPLI:
		amplification=input("Facteur d'amplification ?",amplification);
		change_infoline();
		break;
	case PREFS:
		open_rsc(SETUP);
		objct=form_do(tree_adr,0);
		if((tree_adr+LSIGN)->ob_state==SELECTED) signe=0x00;
		else signe=0x80;
		if((tree_adr+L8BITS)->ob_state==SELECTED) format=8;
		else format=16;
		deselect(objct,0);
		close_rsc();
		break;
	case BYEBYE:
		end_prog();
		break;
	case INFORM:
		string=get_ptext(ABOUT,FREEMEM);
		sprintf(string,"%8Ld",(char *)Malloc(-1L));
		open_rsc(ABOUT);
		objct=form_do(tree_adr,0);
		deselect(objct,0);
		close_rsc();
		break;
	case LOWPASS:
		algo=LOWPASS;
		menu_icheck(menu_tree,LOWPASS,1);
		menu_icheck(menu_tree,HIGHPASS,0);
		menu_icheck(menu_tree,BANDPASS,0);
		menu_icheck(menu_tree,BANDCUT,0);
		break;			
	case HIGHPASS:
		algo=HIGHPASS;
		menu_icheck(menu_tree,LOWPASS,0);
		menu_icheck(menu_tree,HIGHPASS,1);
		menu_icheck(menu_tree,BANDPASS,0);
		menu_icheck(menu_tree,BANDCUT,0);
		break;			
	case BANDPASS:
		algo=BANDPASS;
		menu_icheck(menu_tree,LOWPASS,0);
		menu_icheck(menu_tree,HIGHPASS,0);
		menu_icheck(menu_tree,BANDPASS,1);
		menu_icheck(menu_tree,BANDCUT,0);
		break;			
	case BANDCUT:
		algo=BANDPASS;
		menu_icheck(menu_tree,LOWPASS,0);
		menu_icheck(menu_tree,HIGHPASS,0);
		menu_icheck(menu_tree,BANDPASS,0);
		menu_icheck(menu_tree,BANDCUT,1);
		break;			
	case DOFILTER:
		free(filter);
		free(work_mem);
		switch(algo)
			{
			case LOWPASS:
				filter_size=passe_bas((double) freq);
				break;
			case HIGHPASS:
				filter_size=passe_haut((double) freq);
				break;
			case BANDPASS:
				filter_size=passe_bande((double) freq);
				break;
			case BANDCUT:
				filter_size=coupe_bande((double) freq);
				break;
			}
		work_mem=malloc(sample_size*2);
		convolution();
		close_window();
		open_window();
		break;
	}
menu_tnormal(menu_tree,menu,1);
}
void close_rsc(void)
{
form_dial(FMD_SHRINK,0,0,0,0,rsc_x,rsc_y,rsc_w,rsc_h);
form_dial(FMD_FINISH,0,0,0,0,rsc_x,rsc_y,rsc_w,rsc_h);
evnt_mesag(message);
redraw_window();
}
void open_rsc(int form_num)
{
tree_adr=(OBJECT *)rs_trindex[form_num];
form_center(tree_adr,&rsc_x,&rsc_y,&rsc_w,&rsc_h);
form_dial(FMD_START,0,0,0,0,rsc_x,rsc_y,rsc_w,rsc_h);
form_dial(FMD_GROW,0,0,0,0,rsc_x,rsc_y,rsc_w,rsc_h);
objc_draw(tree_adr,0,4,rsc_x,rsc_y,rsc_w,rsc_h);
}
void create_window()
{
int x,y,w,h;
wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);
whandle=wind_create(NAME|CLOSER|LFARROW|RTARROW|INFO|HSLIDE,x,y,w,h);
}
void open_window()
{
int x,y,w,h;
long hsize;
wind_set(whandle,WF_VSLSIZE,1000);
wind_set(whandle,WF_NAME,window_name);
if(sample_size<638) hsize=1000;
else hsize=1000/(sample_size/638);
wind_set(whandle,WF_HSLSIZE,(int)hsize);
change_infoline();
wind_get(whandle,WF_FULLXYWH,&x,&y,&w,&h);
form_dial(FMD_GROW,0,0,0,0,x,y,w,h);
wind_open(whandle,x,y,w,h);
}
void close_window()
{
int x,y,w,h;
wind_get(whandle,WF_FULLXYWH,&x,&y,&w,&h);
wind_close(whandle);
form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h);
}
void redraw_window(void)
{
int clip[4],x,y,w,h;
if(message[3]!=whandle) return;
graf_mouse(M_OFF,(void *)0);
wind_get(whandle,WF_FIRSTXYWH,&x,&y,&w,&h);
do
{
	w=min(x+w,message[6]+message[4]);
	h=min(y+h,message[7]+message[5]);
	x=max(x,message[4]);
	y=max(y,message[5]);
	if((w>x) &&(h>y))
	{
		w=w-x;
		h=h-y;
		clip[0]=x;		clip[1]=y;
		clip[2]=x+w-1;	clip[3]=y+h-1;
		vs_clip(handle,1,clip);
		vr_recfl(handle,clip);
		affiche_grille();
		draw_sample(base_mem,pos1);
		draw_sample(work_mem,pos2);
	}
	wind_get(whandle,WF_NEXTXYWH,&x,&y,&w,&h);
}while(w!=0);
graf_mouse(M_ON,(void *)0);
}
void redraw_all()
{
int clip[4];
wind_get(whandle,WF_WORKXYWH,&clip[0],&clip[1],&clip[2],&clip[3]);
clip[2]+=clip[0]-1;	clip[3]+=clip[1]-1;
vs_clip(handle,1,clip);
vr_recfl(handle,clip);
affiche_grille();
draw_sample(base_mem,pos1);
draw_sample(work_mem,pos2);
}
void end_prog(void)
{
wind_close(whandle);
wind_delete(whandle);
wind_update(0);
menu_bar(menu_tree,0);
rsrc_free();
v_clsvwk(handle);
appl_exit();
exit(0);
}
void deselect(int objc_num,int state)
{
objc_change(tree_adr,objc_num,0,rsc_x,rsc_y,rsc_w,rsc_h,0x0000,state);
}
char *get_ptext(int arbre,int fils)
{
unsigned long tree,point1,**point2;
tree=rs_trindex[arbre];
point1=tree+sizeof(OBJECT)*fils+12;
point2=(unsigned long **)point1;
return((char *)**point2);
}
void change_infoline()
{
sprintf(infoline,"Taille: %Ld octets, Fr‚quence: %.2f Khz, Amplification: %.2f",sample_size,freq,amplification);
wind_set(whandle,WF_INFO,infoline);
}
void load_sample()
{
char	pathname[80],filename[13],select[]="*.SPL",*str_ptr;
int button,fhandle;
strcpy(pathname,work_path);
strcat(pathname,select);
strcpy(filename,sample_name);
fsel_input(pathname, filename, &button);
if( (filename=="") || (button==0)) return;
str_ptr=strchr(pathname,'*');
*str_ptr=0;
strcpy(work_path,pathname);
strcpy(sample_name,filename);
strcpy(str_ptr,filename);
strcpy(window_name,pathname);
fhandle=open(pathname,O_RDONLY);
sample_size=filelength(fhandle);
offset=0L;
free(base_mem);
free(work_mem);
work_mem=NULL;
base_mem=malloc(sample_size*2);
sample_size=read(fhandle,base_mem,sample_size);
close(fhandle);
convert_sample(format,signe,base_mem,sample_size);
graf_mouse(ARROW,(void *)0);
}
void save_sample()
{
int	i,fhandle,e,*ptr;
ptr=work_mem;
tree_adr=(OBJECT *)rs_trindex[SETUP];
fhandle=open(window_name,O_WRONLY);
for(i=0;i<sample_size;i++){
e=*ptr++;
if((tree_adr+SSIGN)->ob_state!=SELECTED) e+=0x8000;
if((tree_adr+S8BITS)->ob_state==SELECTED) write(fhandle,&e,1);
else write(fhandle,&e,2);
}
close(fhandle);
}
void affiche_grille()
{
int pxyarray[4],x,y,w,h,i,ystep;
wind_get(whandle,WF_WORKXYWH,&x,&y,&w,&h);
if(max_y<=200) ystep=16;
else ystep=32;
vsl_udsty(handle,0x5555);
vsl_type(handle,7);
y+=5*ystep-6;
for(i=1;i<=5;i++)
	{
	pxyarray[0]=x;		pxyarray[1]=y;
	pxyarray[2]=x+w;	pxyarray[3]=y;
	v_pline(handle,2,pxyarray);
	pxyarray[0]=x;		pxyarray[1]=y+5*ystep;
	pxyarray[2]=x+w;	pxyarray[3]=y+5*ystep;
	v_pline(handle,2,pxyarray);
	y-=ystep;
	}
y+=ystep;
for(i=0;i<=w/32;i++)
	{
	pxyarray[0]=x;		pxyarray[1]=y;
	pxyarray[2]=x;		pxyarray[3]=y+4*ystep;
	v_pline(handle,2,pxyarray);
	pxyarray[0]=x;		pxyarray[1]=y+5*ystep;
	pxyarray[2]=x;		pxyarray[3]=y+9*ystep;
	v_pline(handle,2,pxyarray);
	x+=32;
	}
v_gtext(handle,2,y-(ystep>>3),"Echantillon de base:");
v_gtext(handle,2,y-(ystep>>3)+(5*ystep),"Echantillon filtr‚:");
pos1=y+2*ystep;
pos2=y+7*ystep;
}
void draw_sample(int *sample_ptr,int y)
{
int	pxyarray[4];
register int x,rotbit;
if(max_y<=200) rotbit=10;
else rotbit=9;
if(sample_ptr!=0)
{
	sample_ptr+=offset;
	vsl_type(handle,1);
	pxyarray[0]=0;
	pxyarray[1]=y;
	for(x=1;x<max_x;x++)
	{
		pxyarray[2]=x;
		pxyarray[3]=((*sample_ptr++)>>rotbit)+y;
		v_pline(handle,2,pxyarray);
		pxyarray[0]=pxyarray[2];
		pxyarray[1]=pxyarray[3];
	}
}
}
int max(int a,int b)
{
return( (a>b) ? a:b);
}
int min(int a,int b)
{
return( (a<b) ? a:b);
}
float input(char *input_text,float value)
{
int	i;
char	*str_ptr;
str_ptr=get_ptext(INPUT,TEXTINP);
strcpy(str_ptr,input_text);
str_ptr=get_ptext(INPUT,VALUE);
for(i=0;i<4;i++) *str_ptr++=0;
open_rsc(INPUT);
deselect(form_do(tree_adr,0),0);
close_rsc();
str_ptr=get_ptext(INPUT,VALUE);
if(*str_ptr==0) return(value);
if(*str_ptr==' ') *str_ptr='0';
if((*(str_ptr+1)==' ') || (*(str_ptr+1)==0)){
	*(str_ptr+1)=*str_ptr;
	*str_ptr='0';}
if(*(str_ptr+2)==0) *(str_ptr+2)='0';
if(*(str_ptr+3)==0) *(str_ptr+3)='0';
sscanf(str_ptr,"%f",&value);
value/=100;
return(value);
}
/* calcul du passe bas */
passe_bas(double fe)
{
double	f1,p,value;
int	n,k;
do{
f1=input("Fr‚quence maximum en Khz ?",0);
}while(f1>=fe/2);
p=f1/fe;
n=(int) ceil(2*fe/(RAIDEUR));
if(n%2==0)	n++;
filter=(int *) malloc(sizeof(int)*(n));
for(k=0;k<n;k++)
	{
	if(k==(n-1)/2) value=(double) 2*p;
	else value=(double) 2*p*sin(2*(k-n/2)*PI*p)/(2*(k-n/2)*PI*p);
	filter[k]=(int) ceil(value*32767);
	}
return(n);
}
/* calcul du passe haut */
passe_haut(double fe)
{
double	f1,p,value;
int	n,k;
do{
f1=input("Fr‚quence minimum en Khz ?",100);
}while(f1>=fe/2);
p=f1/fe;
n=(int) ceil(2*fe/(RAIDEUR));
if(n%2==0)	n++;
filter=(int *)malloc(sizeof(int)*(n));
for(k=0;k<n;k++)
{
	if(k==(n-1)/2) value=(double) 1-2*p;
	else value=(double) -2*p*sin(2*(k-n/2)*PI*p)/(2*(k-n/2)*PI*p);
	filter[k]=(int) ceil(value*32767);
}
return(n);
}
/* calcul du passe bande */
passe_bande(double fe)
{
double	f1,f2,p,fg,value;
int	n,k;
do{
f1=input("Fr‚quence 1 en Khz ?",100);
}while(f1>=fe/2);
do{
f2=input("Fr‚quence 2 en Khz ?",100);
}while(f2>=fe/2);
p=(f2-f1)/(2*fe);
fg=f1+(f2-f1)/2;
n=(int) ceil(2*fe/(RAIDEUR));
if(n%2==0)	n++;
filter=(int *)malloc(sizeof(int)*(n));
for(k=0;k<n;k++)
{
	if(k==(n-1)/2) value=(double) 4*p;
	else value=(double) 2*cos(2*PI*(k-n/2)*fg/fe)*sin(2*(k-n/2)*PI*p)/((k-n/2)*PI);
	filter[k]=(int) ceil(value*32767);
}
return(n);
}
/* calcul du coupe bande */
coupe_bande(double fe)
{
double	f1,f2,p,fg,value;
int	n,k;
do{
f1=input("Fr‚quence 1 en Khz ?",100);
}while(f1>=fe/2);
do{
f2=input("Fr‚quence 2 en Khz ?",100);
}while(f2>=fe/2);
p=(f2-f1)/(2*fe);
fg=f1+(f2-f1)/2;
n=(int) ceil(2*fe/(RAIDEUR));
if(n%2==0)	n++;
filter=(int *)malloc(sizeof(int)*(n));
for(k=0;k<n;k++)
{
	if(k==(n-1)/2) value=(double) 1-4*p;
	else value=(double) -2*cos(2*PI*(k-n/2)*fg/fe)*sin(2*(k-n/2)*PI*p)/((k-n/2)*PI);
	filter[k]=(int) ceil(value*32767);
}
return(n);
}
void convolution()
{
register int *sample1_ptr,*sample2_ptr;
register long i,step,count,amplif;
tree_adr=(OBJECT *)rs_trindex[STATUS];
(tree_adr+STATBOX)->ob_width=0;
open_rsc(STATUS);
sample1_ptr=base_mem;
sample2_ptr=work_mem;
count=step=sample_size/320;
amplif=(long) ceil(amplification*65536L);
for(i=0;i<sample_size;i++)
{
	*sample2_ptr++=calc_one_data(sample1_ptr,filter,sample_size,filter_size,amplif);
	sample1_ptr+=1;
	if(i==count)
		{
			count+=step;
			(tree_adr+STATBOX)->ob_width+=1;
			objc_draw(tree_adr,STATBOX,1,rsc_x,rsc_y,rsc_w,rsc_h);
		}
}
close_rsc();
}
void init_rsc()
{
int i;
for(i=0;i<NUM_TI;i++){
	rs_tedinfo[i].te_ptext=rs_strings[rs_tedinfo[i].te_ptext];
	rs_tedinfo[i].te_ptmplt=rs_strings[rs_tedinfo[i].te_ptmplt];
	rs_tedinfo[i].te_pvalid=rs_strings[rs_tedinfo[i].te_pvalid];}
for(i=0;i<NUM_OBS;i++){
	switch(rs_object[i].ob_type){
	case G_TITLE:
	case G_STRING:
	case G_BUTTON:
		rs_object[i].ob_spec.index=rs_strings[rs_object[i].ob_spec.index];
		break;
	case G_TEXT:
	case G_FTEXT:
	case G_BOXTEXT:
		rs_object[i].ob_spec.index=&rs_tedinfo[rs_object[i].ob_spec.index];
		break;
	}
rsrc_obfix(&rs_object[0],i);}
}
