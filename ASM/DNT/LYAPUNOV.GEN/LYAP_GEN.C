#include	<AES.H>
#include	<VDI.H>
#include	<STDIO.H>
#include	<TOS.H>
#include	<MATH.H>
#include	<STRING.H>
#include	"lyap_gen.h"

#define		min(a,b)			( (a)<(b)  ?  (a) : (b) )
#define		max(a,b)			( (a)>(b)  ?  (a) : (b) )
#define		abs(a)				( (a)>=0   ?  (a) :-(a) )
#define		get_ptext(tree,a)	( tree[a].ob_spec.tedinfo->te_ptext )

int		gem_init(void);
void	gem_exit(void);
char	*read_ftext(char *dest,OBJECT *tree,int objc);

int		main(void);
void	pipo_fill(void);
void	show_space(int,int,int);
int		out_info(float p);
void	save_pi1(int *buf);
void	save_space(void);
void	load_space(void);
int		fileselect(char *masque,char *predef,char *name);
int		lyap_space(int sx,int sy,
                   double xc,double yc,double dxc,double xyc,
                   int   inca,int incb,
                   char	 *seq,
                   float space[320][200],
                   int   (*info)(float),
                   double start_x);

typedef	struct	{
				int screen_w;				/*largeur ‚cran				*/
				int	screen_h;				/*hauteur ‚cran				*/
				
				int	nb_color;				/*nb de couleurs simultan‚es*/
				int	nb_planes;				/*nb de plans de couleurs	*/
				int	pal_size;				/*taille de la palette		*/
				}	VWORK_INFO;				/*yeah !					*/


int				work_in[12],work_out[57];	/*Tableaux VDI*/
int				handle;						/*handle   VDI*/
int				appl_id;					/*handle   AES*/
VWORK_INFO		vwk_info;					/*en retour...*/

float		g_space[320][200];	/*univers calcul‚*/
int			couleurs[16]=
			 	{0x000,0x200,0x300,0x620,0x400,0x730,0x500,0x740,
			 	 0x750,0x760,0x770,0x775,0x772,0x777,0x774,0x100};

int			pixel_size[10]={1,2,4,5,8,10,20,40,40,40};
int			save_col[16];
int			pic[16033];



int gem_init(void)
{
	int	i;
	appl_id=appl_init();
	if (appl_id!=-1)
	{
		for (i=0;i<10;i++)
			work_in[i]=1;
		work_in[10]=2;
		handle=graf_handle(&i,&i,&i,&i);
		v_opnvwk(work_in,&handle,work_out);
		vwk_info.screen_w=work_out[0];
		vwk_info.screen_h=work_out[1];
		vwk_info.nb_color=work_out[13];
		vwk_info.pal_size=work_out[39];
		vq_extnd(handle,1,work_out);
		vwk_info.nb_planes=work_out[4];
		return 1;
	}
	return	0;
}



void gem_exit(void)
{
	v_clsvwk(handle);
	appl_exit();
}
/*:::::::::::::::::::::::::::::::*/
char *read_ftext(char *dest,OBJECT *tree,int objc)
{
	register char *text,*tmpt,*vlid;
	char	*save=dest;
	text=tree[objc].ob_spec.tedinfo->te_ptext;
	tmpt=tree[objc].ob_spec.tedinfo->te_ptmplt;
	vlid=tree[objc].ob_spec.tedinfo->te_pvalid;

	while ( *tmpt && *text)
	{
		*dest=*(tmpt++);
		if	( *dest=='_' )
		{
			*dest=*(text++);
			if	( *dest==' ' &&
				  (*vlid=='9' ||
				   (*vlid | 0x20 )=='f' ||
				   (*vlid | 0x20 )=='p'
				  )
				)
				dest--;
			vlid++;
		}
		dest++;
	}
	*dest=0;
	return	save;
}
/*:::::::::::::::::::::::::::::::*/
int main(void)
{
	int	ret=CALC,inca,incb,i,*hard_pal=(int *)0xFF8240;
	int x,y,w,h;
	long stack;
	float	x_centre,y_centre,h_size,v_size;
	int pc,col1,col2,pg;
	OBJECT	*tree;
	char	save_seq[40];
	char	dummy[20];
/*	if	( Getrez()!=0 )
	{
		printf("Ne fonctionne qu'en basse r‚solution\n");
		return	-1;
	}*/
	if	( gem_init() )
		if	( rsrc_load("lyap_gen.rsc") )
		{	
			stack=Super((void *)0);
			for (i=0;i<16;i++)
				save_col[i]=hard_pal[i];
			Super((void *)stack);
			rsrc_gaddr(0,TREE1,&tree);
			form_center(tree,&x,&y,&w,&h);
			graf_mouse(3,(MFORM *)0);
			while	( ret!=QUIT )
			{
				form_dial(FMD_START,0,0,0,0,x,y,w,h);
				objc_draw(tree,0,1000,0,0,1024,1024);
				ret=(form_do(tree,XCENT) & 0x7fff);
				tree[ret].ob_state^=SELECTED;
				form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
				sscanf(strchr(read_ftext(dummy,tree,XCENT),'0'),"%f",&x_centre);
				sscanf(strchr(read_ftext(dummy,tree,YCENT),'0'),"%f",&y_centre);
				sscanf(strchr(read_ftext(dummy,tree,HSIZE),'0'),"%f",&h_size);
				sscanf(strchr(read_ftext(dummy,tree,VSIZE),'0'),"%f",&v_size);
				sscanf(get_ptext(tree,CPREC),"%d",&pc);
				sscanf(get_ptext(tree,GPREC),"%d",&pg);
				pg=pixel_size[pg];
				sscanf(get_ptext(tree,COLOR1),"%d",&col1);
				sscanf(get_ptext(tree,COLOR2),"%d",&col2);
				strcpy(save_seq,get_ptext(tree,SEQUENCE));
				switch	(ret)	{
				case CALC:
					graf_mouse(2,(void *)0);
					inca=600/(0.036199*(1000-(float)pc));
					incb=4000/(0.036199*(1000-(float)pc));
					h_size=min(h_size,x_centre);
					v_size=min(v_size,y_centre);
					if	( h_size && v_size )
						lyap_space(320/pg,200/pg,
								   x_centre*4,y_centre*4,
								   h_size*4,v_size*4,
								   inca,incb,
								   save_seq,g_space,
								   out_info,
								   (double)8/10);
					else
						form_alert(1,"[1][Taille de visualisation|nulle sur X ou Y][ OK ]");
					graf_mouse(3,(void *)0);
					break;
				case SHOW:
					v_hide_c(handle);
					show_space(pg,col1,col2);
					v_show_c(handle,1);
					break;
				case SAVEPI1:
					save_pi1(pic);
					break;
				case SAVELYS:
					save_space();
					break;
				case LOADLYS:
					load_space();
					break;
				}
			}
			rsrc_free();
		}	
	gem_exit();
	return	0;
				
}


/*:::::::::::::::::::::::::::::::*/
int		lyap_space(int sx,int sy,
                   double xc,double yc,double dxc,double dyc,
                   int   incx,int incy,
                   char	 *seq,
                   float space[][200],
                   int   (*info)(float),
                   double start_x)
{
	double	wx,x,y,dx,dy,lyap;
	double	real_seq[100];
	int		sl,i,j;
	int		x_idx,y_idx;
	dx=2*dxc/sx;
	dy=2*dyc/sy;
	sl=strlen(seq);
	for	(i=0;i<sl;i++)
		if	( seq[i]=='A' )
			seq[i]=0;
		else
			seq[i]=1;
	x_idx=0;
	if	( info )
		(*info)((float)0);
	for (x=xc-dxc;x<=xc+dxc;x+=dx)
	{
		y_idx=0;
		for	(y=yc-dyc;y<=yc+dyc;y+=dy)
		{
			wx=start_x;
			j=0;
			for	(i=0;i<=sl;i++)
				if	( seq[i] )
					real_seq[i]=x;
				else
					real_seq[i]=y;
			for	(i=0;i<incx;i++)
			{
				wx=real_seq[j]*wx*(1-wx);
				if	( (++j)>=sl )
					j=0;
			}
			lyap=1;
			for	(i=0;i<incy;i++)
			{
				wx=real_seq[j]*wx*(1-wx);
				lyap*=abs(real_seq[j]-2*real_seq[j]*wx);
				if	( (++j)>=sl )
					j=0;
			}
			space[x_idx][y_idx++]=log(lyap)/(incy*log(2));
		}
		x_idx++;
		if	( info )
			if ( !(*info)((dxc+x-xc)/(2*dxc)) )
				return 0;
	}
	return 1;
}
/*:::::::::::::::::::::::::::::::*/
int	out_info(float p)
{
	OBJECT	*tree;
	int		i,dummy;
	rsrc_gaddr(0,TREE2,&tree);
	form_center(tree,&i,&i,&i,&i);
	sprintf(tree[WINFO].ob_spec.tedinfo->te_ptext,"%d",(int)(100*p+0.5));
	i=0;
	if	(p)
		i=WINFO;
	objc_draw(tree,i,2,0,0,1024,1024);
	graf_mkstate(&dummy,&dummy,&i,&dummy);
	if	(i)
		return	0;
	else
		return	1;
}
/*:::::::::::::::::::::::::::::::*/
void show_space(int pg,int col1,int col2)
{
	int	x,y,c,ix,iy,clip[4]={0,0,319,199};
	float	c_col=(float)col1/1500,o_col=(float)col2/333-15.0;
	int		*ecran;
	printf("\033E\n");
	Setpalette(couleurs);
	vs_clip(handle,1,clip);
	vsf_interior(handle,1);
	ix=0;
	for	(x=0;x<320;x+=pg)
	{
		iy=0;
		for (y=0;y<200;y+=pg)
		{
			c=(int)max(0,min(o_col-c_col*g_space[ix][iy],15.1));
			if	( g_space[ix][iy]>=0 )
				c=0;
			else
				c=15-c;
			vsf_color(handle,c);
			clip[0]=x;
			clip[1]=199-y;
			clip[2]=x+pg-1;
			clip[3]=199-(y+pg-1);
			v_bar(handle,clip);
			iy++;
		}
		ix++;
	}
	ecran=(int *)Physbase();
	y=0;
	pic[y++]=0;
	for	(x=0;x<16;x++)
		pic[y++]=couleurs[x];
	for	(x=0;x<16000;x++)
		pic[y++]=ecran[x];
	do
		graf_mkstate(&x,&x,&y,&x);
	while  ( !y );
	Setpalette(save_col);
}
/*:::::::::::::::::::::::::::::::*/
void save_pi1(int	*buf)
{
	char	name[80];
	int		fh;
	if	( fileselect("*.PI1","",name) )
	{
		fh=Fcreate(name,0);
		if	( fh>=0 )
		{
			Fwrite(fh,32066,(void *)buf);
			Fclose(fh);
		}
	}
}
/*:::::::::::::::::::::::::::::::*/
void save_space(void)
{
	char	name[80];
	int	fh;
	if	( fileselect("*.LYS","",name) )
	{
		fh=Fcreate(name,0);
		if	( fh>=0 )
		{
			Fwrite(fh,sizeof(g_space),(void *)g_space);
			Fclose(fh);
		}
	}
}
/*:::::::::::::::::::::::::::::::*/
void load_space(void)
{
	char	name[80];
	int	fh;
	if	( fileselect("*.LYS","",name) )
	{
		fh=Fopen(name,0);
		if	( fh>=0 )
		{
			Fread(fh,sizeof(g_space),(void *)g_space);
			Fclose(fh);
		}
	}
}
/*:::::::::::::::::::::::::::::::*/
int	fileselect(char *masque,char *predef,char *name)
{
	char	path[128],work[13];
	register char *test;
	int		button;
	strcpy(work,predef);
	path[0]='A'+Dgetdrv();
	path[1]=':';
	Dgetpath(path+2,0);
	strcat(path,"\\");
	strcat(path,masque);
	fsel_input(path,work,&button);
	if	( !button || !(*work) )
		return 0;
	test=strchr(path,0);
	while ( *(--test)!='\\' )
		*test=0;
	strcat(path,work);
	strcpy(name,path);
	return 1;
}