#include <stdio.h>
#include <tos.h>
#include <ext.h>
#include <math.h>
#include <graphgem.h>
#include <stdlib.h>
#include <string.h>
#include "surf3d3.h"

int intersect(int x1,int y1,int w1,int h1,int x2,int y2,int w2,int h2);
void sys_redraw(void);
void mn_selected(void);
void wm_redraw(void);
void wm_topped(void);
void wm_closed(void);
void wm_fulled(void);
void wm_arrowed(void);
void wm_hslide(void);
void wm_vslide(void);
void wm_sized(void);
void wm_moved(void);
void show_dialog(OBJECT *arbre);
void show_acqui(void);
void show_angle(void);

struct window win;

int message[8];
char eq[60]={"exp(-3*x*x)*exp(-3*y*y)-.3"};

/*  variables---------------------------------------------*/
double x,y,z,oldX,oldY,newX,newY,incr,cosH,sinH,cosR,sinR;
int H=30,R=30,haut,larg,depx,depy;
int coulr,n;
double * tablX,* tablY,* p1,* p2;
int * tablC,* p3,cas=Z1,cas2=PAL1,axes=1;
OBJECT *adr_menu,*adr_info,*adr_acqui,*adr_angle;
short no_redraw=0;

/*  variables propres … "eval()"  */
short j;
char c;
char chaine[30];


/*  fonctions "eval()"  */
double eval1(short,short);
double eval2(short,short);
double eval3(short,short);

/*  "eval1()": ‚value une (sous-)fonction  */
double eval1(short d,short f)
{
  double loc=0;  /*  r‚sultat local  */
  short i,i_prec;

  i=d;
  while(i<f+2)
  {
    /*  d‚coupe la fonction en somme de termes  */
    j=0;  /*  compte les "()"  */
    i_prec=i;
    do  /*  recherche '+' ou '-'  */
    {
      c=eq[i++];
      j+=(c=='(')-(c==')');
    }
    while(j || (c!='+' && c!='-' && i<=f));
    if(i>f) i++;

    /*  ‚value le terme  */
    if(eq[i_prec-1]=='+' || i_prec==d) loc+=eval2(i_prec,i-2);
    if(eq[i_prec-1]=='-') loc-=eval2(i_prec,i-2);
  }
  return loc;
}

/*  "eval2()": ‚value un produit ou une division  */
double eval2(short d,short f)
{
  double loc=1;
  short i,i_prec;

  i=d;
  while(i<f+2)
  {
    /*  d‚coupe la fonction en produit de termes  */
    j=0;  /*  compte les "()"  */
    i_prec=i;
    do  /*  recherche '*' ou '/'  */
    {
      c=eq[i++];
      j+=(c=='(')-(c==')');
    }
    while(j || (c!='*' && c!='/' && i<=f));
    if(i>f) i++;

    /*  ‚value le terme  */
    if(eq[i_prec-1]=='*' || i_prec==d) loc*=eval3(i_prec,i-2);
    if(eq[i_prec-1]=='/') loc/=eval3(i_prec,i-2);
  }
  return loc;
}

/*  "eval3()": ‚value un terme qui peut etre soit une fonction math., soit
une variable simple, soit une constante, soit une fonction entre "()"  */
double eval3(short d,short f)
{
  double loc=1,loc2=1;
  int k,k_prec;

  if(eq[d]=='(')
  { /*  cas de la fonction entre "()"  */
    return eval1(d+1,f-1);
  }

  if(d==f && eq[d]>'e')
  { /*  cas de la variable simple  */
    c=eq[d];
    if(c=='x') return x; else return y;
  }

  for(k=d;eq[k]!='(' && k<=f;k++);  /*  recherche '('  */

  if(k>f)
  { /*  cas d'une constante  */
    strncpy(chaine,&eq[d],f-d+1);
    chaine[f-d+1]=0;
    return atof(chaine);
  }
  else
  { /*  cas d'une fonction math.  */
    k_prec=k;

    for(j=0;;)  /*  recherche ',' ou ')'  */
    {
      c=eq[++k];
      if(c==',' && j==0) break;
      if(c=='(') {  j++;  continue;  }
      if(c!=')') continue;
      if(j) {  j--;  continue;  } else break;
    }

    if(c==',')
    { /*  ‚value le 2Šme paramŠtre  */
      loc2=eval1(k+1,f-1);
    }

    loc=eval1(k_prec+1,k-1);  /*  ‚value le 1er paramŠtre  */
    
    /*  d‚termine de quelle fonction math il s'agit  */
    switch(eq[d])
    {
    case 'a':
      if(eq[d+1]=='b') return fabs(loc);  /*  abs()   */
      else                                /*  angle(,)*/
      return fabs(loc)<.0001? (loc2>0? M_PI_2:-M_PI_2)
                            : atan(loc2/loc)+(loc<0? M_PI:0);
    case 'c': return cos(loc);            /*  cos()   */
    case 'e': return exp(loc);            /*  exp()   */
    case 'h': return sqrt(loc*loc+loc2*loc2);  /*  hyp(,)  */
    case 'i':
      if(eq[d+1]=='n') return floor(loc); /*  int()   */
      else return trunc(loc);             /*  ipart() */
    case 'l': return log(loc);            /*  log()   */
    case 'm': return fmod(loc,loc2);      /*  mod(,)  */
    case 'p':
      if(eq[d+2]=='w') return pow(loc,trunc(loc2));  /*  pow(,)  */
      else return loc>0? loc:0;           /*  pos()   */
    case 's':
      switch(eq[d+1])
      {
      case 'i': return sin(loc);          /*  sin()   */
      case 'q': return sqrt(loc);         /*  sqr()   */
      default : return loc>0? 1:-1;       /*  sgn()   */
      }
    case 't': return tan(loc);            /*  tan()   */
    case '=': return fabs(loc-loc2)<.0001;/*  =(,)    */
    case '>': return loc>loc2;            /*  >(,)    */
    default : return loc<loc2;            /*  <(,)    */
    }
  }
}


/*  fonctions---------------------------------------------*/
double f(double x,double y)
{
	switch(cas)
	{
  	case Z1 :
  	  return(x*x*y*y-.3);
  	case Z2 :
  	  return(x*x*x*y*y*y);
  	case Z3 :
  	  return(cos(16*sqrt(x*x+y*y))/8);
  	case Z4 :
  	  return(cos(5*x)*cos(5*y)/6);
  	case Z5 :
  	  return(y*sqrt(fabs(x))*(x>0? 1:-1)/1.5);
  	case Z6 :
  	  return((y<0 && y+incr>0)*x/2);
  	case Z7 :
  	  return(sqrt(fabs(1-x*x-y*y))*(x*x+y*y<=1));
  	case Z8 :
  	  return((y<0 && y+incr>0)*x/3+(x<0 && x+incr>0)*y/3);
  	case Z9 :
  	  return(0.2-y*y*sqrt(fabs(4*x))/3);
  	case Z10 :
  	  return(x*y*y*y);
    default :
      return(eval1(0,strlen(eq)-1));
  }
}

int X(void)
{
  return(depx+larg/2+240*(x*sinR+y*cosR)*larg/640);
}

int Y(void)
{
  return(depy+haut/2-290*(z*cosH+sinH*(-x*cosR+y*sinR))*haut/480);
}

void couleur(void)
{
  coulr=cas2==PAL1? (fabs(z)<1? (z>=0? 107+z*21:107+z*27)
                              : (z>0? 127:80) )
                  : (fabs(z)<1? (z>=0? 68+sqrt(z)*15:55-sqrt(-z)*16)
                              : (z>0? 82:40) );
}


void wm_redraw(void)
{
  int i,j,X0,Y0;

  wind_calc(1,CLOSER | MOVER | NAME | SIZER | FULLER,win.x,win.y,win.l,win.h,&depx,&depy,&larg,&haut);
  n=(larg>haut? larg:haut)/20+1;   /*  nombre de lignes de cot‚  */
  incr=2/(double)(n-1);
  cosR=cos(R*M_PI/180);
  sinR=sin(R*M_PI/180);
  cosH=cos(H*M_PI/180);
  sinH=sin(H*M_PI/180);

  /*  alloue 3 tableaux pour m‚moriser X, Y, et la couleur  */
  i=n*n;
  if((tablX=(double *)malloc(i*sizeof(double)))==0) return;
  if((tablY=(double *)malloc(i*sizeof(double)))==0) return;
  if((tablC=(int *)malloc(i*sizeof(int)))==0) return;

	pbox(depx,depy,depx+larg-1,depy+haut-1,0);  /*  cls  */

  if(axes)
  { /*  trac‚ des axes  */
    x=0;  /*  point O(0,0,0)  */
    y=0;
    z=0;
    X0=X();
    Y0=Y();
  
    x=1;  /*  axe x  */
    y=0;
    z=0;
    line(X0,Y0,X(),Y(),4);
    text_color(12);
    text_type(GRAS);
    outtextxy(X(),Y(),"x");

    x=0;  /*  axe y  */
    y=1;
    z=0;
    line(X0,Y0,X(),Y(),4);
    outtextxy(X(),Y(),"y");

    x=0;  /*  axe z  */
    y=0;
    z=1;
    line(X0,Y0,X(),Y(),4);
    outtextxy(X(),Y(),"z");
  }

  /*  trace dans un 1er sens en m‚morisant les valeurs  */
  p1=tablX;
  p2=tablY;
  p3=tablC;
  for(x=-1;x<1.001;x+=incr)
  {
    y=-1;
    z=f(x,y);
    couleur();
    *(p3++)=coulr;
    oldX=X();
    oldY=Y();
    *(p1++)=oldX;
    *(p2++)=oldY;

    for(y+=incr;y<1.001;y+=incr)
    {
      z=f(x,y);
      newX=X();
      newY=Y();
      couleur();
      *(p3++)=coulr;
      line(oldX,oldY,newX,newY,coulr);
      oldX=newX;
      oldY=newY;

      *(p1++)=newX;
      *(p2++)=newY;
    }
  }

  /*  trace dans un 2Šme sens en rappellant les valeurs  */
  for(i=0;i<n;i++)
  {
    p1=tablX+i;
    p2=tablY+i;
    p3=tablC+i;

    oldX=*p1;
    oldY=*p2;

    for(j=1;j<n;j++)
    {
      p1+=n;
      p2+=n;
      newX=*p1;
      newY=*p2;

      line(oldX,oldY,newX,newY,*p3);
      p3+=n;
      oldX=newX;
      oldY=newY;
    }
  }


  free(tablX);
  free(tablY);
  free(tablC);
}


void main()
{
	 char temp[100];
	 TEDINFO *ted;

   /*****   Initilisation de la station de travail   *****/
   if(init_gem()!=1)
   {
      form_alert(1,"[3][ Impossible d'ouvrir | la station de travail ][Dommage!]");
      exit(0);
   }
   /*****   Initialisation de ou des fenŠtre(s)   *****/
   defmouse(0);
   if(rsrc_load("surf3d3.rsc")==0)
   {
   	form_alert(1,"[3][Impossible d'ouvrir | le fichier RSC][Dommage!]");
   	exit(0);
   }
   rsrc_gaddr(0,MENU,&adr_menu);
   rsrc_gaddr(0,ACQUI,&adr_acqui);
   ted=(TEDINFO *)adr_acqui[ACQUIEDI].ob_spec.tedinfo;
	 strcpy(ted->te_ptext,eq);/* recopi de la chaine dan tableau*/

   menu_bar(adr_menu,1);
   win.fullx=param_gem.ecran_l;
   win.fully=param_gem.ecran_h;
   win.handle=wind_create(CLOSER | MOVER | NAME | SIZER |FULLER,20,20,win.fullx,win.fully);
   if(win.handle<0)
   {
      form_alert(1,"[3][ Impossible d'ouvrir | la fenetre de travail ][Dommage!]");
      close_gem();
      exit(0);
   }
   /*****   Ouverture de la fenŠtre de travail   *****/
   win.x=20;
   win.y=20;
   win.l=200;
   win.h=200;
   sprintf(temp,"Traceur de surface");
   wind_set(win.handle,2,temp,0,0);
   wind_open(win.handle,win.x,win.y,win.l,win.h);
   /*****   Gestion des ‚v‚nements   *****/
   while(1)
   {
      evnt_mesag(message);
      switch(message[0])
      {
         case 10 :
            mn_selected();
            break;
         case 20 :
         		if(no_redraw==0)
         			sys_redraw();
         		else
         			no_redraw=0;
				    break;
         case 21 :
            wm_topped();
            break;
         case 22 :
            wm_closed();
            break;
         case 23 :
            wm_fulled();
            break;
         case 24 :
            wm_arrowed();
            break;
         case 25 :
            wm_hslide();
            break;
         case 26 :
            wm_vslide();
            break;
         case 27 :
            wm_sized();
            break;
         case 28 :
            wm_moved();
            break;
      }
   }
}


void mn_selected()
{
	switch(message[4])
	{
		case MINFO :
	    rsrc_gaddr(0,BOXINFO,&adr_info);
	    show_dialog(adr_info);
			break;
		case MQUIT :
			wm_closed();
			break;
		case PAL1 :
			menu_icheck(adr_menu,cas2,0);
			cas2=PAL1;
			menu_icheck(adr_menu,cas2,1);
			wind_calc(1,CLOSER | MOVER | NAME | SIZER | FULLER,win.x,win.y,win.l,win.h,&depx,&depy,&larg,&haut);
			clip_on(depx,depy,larg,haut);
			hidem();  
			wm_redraw();
			showm();
			clip_off();
			break;
		case PAL2 :
			menu_icheck(adr_menu,cas2,0);
			cas2=PAL2;
			menu_icheck(adr_menu,cas2,1);
			wind_calc(1,CLOSER | MOVER | NAME | SIZER | FULLER,win.x,win.y,win.l,win.h,&depx,&depy,&larg,&haut);
			clip_on(depx,depy,larg,haut);
			hidem();  
			wm_redraw();
			showm();
			clip_off();
			break;
		case ANG :
			rsrc_gaddr(0,DANGLE,&adr_angle);
	    show_angle();
	    wind_calc(1,CLOSER | MOVER | NAME | SIZER | FULLER,win.x,win.y,win.l,win.h,&depx,&depy,&larg,&haut);
			clip_on(depx,depy,larg,haut);
			hidem();  
			wm_redraw();
			showm();
			clip_off();
			break;
		case AXES :
			axes^=1;
			menu_icheck(adr_menu,AXES,axes);
			wind_calc(1,CLOSER | MOVER | NAME | SIZER | FULLER,win.x,win.y,win.l,win.h,&depx,&depy,&larg,&haut);
			clip_on(depx,depy,larg,haut);
			hidem();  
			wm_redraw();
			showm();
			clip_off();
			break;
		case Z11 :
			menu_icheck(adr_menu,cas,0);
			cas=message[4];
			menu_icheck(adr_menu,cas,1);
			
	    show_acqui();
	    
	    wind_calc(1,CLOSER | MOVER | NAME | SIZER | FULLER,win.x,win.y,win.l,win.h,&depx,&depy,&larg,&haut);
			clip_on(depx,depy,larg,haut);
			hidem();  
			wm_redraw();
			showm();
			clip_off();
			break;
		default :
			menu_icheck(adr_menu,cas,0);
			cas=message[4];
			menu_icheck(adr_menu,cas,1);
			wind_calc(1,CLOSER | MOVER | NAME | SIZER | FULLER,win.x,win.y,win.l,win.h,&depx,&depy,&larg,&haut);
			clip_on(depx,depy,larg,haut);
			hidem();  
			wm_redraw();
			showm();
			clip_off();
			break;
	}
  menu_tnormal(adr_menu,message[3],1);		
}

int intersect(int x1,int y1,int w1,int h1,int x2,int y2,int w2,int h2)
{
	int aa,bb,cc,dd;
	aa=(x2 > x1) ? x2 : x1;
	bb=(y2 > y1) ? y2 : y1;
	cc=(x2+w2 < x1+w1) ? x2+w2 : x1+w1;
	dd=(y2+h2 < y1+h1) ? y2+h2 : y1+h1;
	clip_on(aa,bb,cc-aa,dd-bb);
	return(cc > aa && dd > bb);
}

void sys_redraw()
{
	int xx,yy,ww,hh,rx,ry,rw,rh;
	
	wind_update(1);
  xx=message[4];
  yy=message[5];
  ww=message[6];
  hh=message[7];
  
  wind_get(win.handle,11,&rx,&ry,&rw,&rh);
	hidem();
	while(rw!=0)
	{
		if(intersect(xx,yy,ww,hh,rx,ry,rw,rh))
  		wm_redraw();
  	wind_get(win.handle,12,&rx,&ry,&rw,&rh);
  }
	showm();
	clip_off();
  wind_update(0);          
}

void wm_topped()
{
	wind_set(win.handle,10,0,0,0,0);
}
void wm_closed()
{
   wind_close(win.handle);
   close_gem();
   exit(0);
}
void wm_fulled()
{
	win.x=1;
	win.y=20;
  win.l=win.fullx;
  win.h=win.fully-20;
  wind_set(win.handle,5,win.x,win.y,win.l,win.h);
}
void wm_arrowed()
{

}
void wm_hslide()
{

}
void wm_vslide()
{

}
void wm_sized()
{
	 int flag=1;
	 if(message[6]>win.l || message[7]>win.h) flag=0;
   win.l=message[6];
   if(win.l<50)
      win.l=50;
   win.h=message[7];
   if(win.h<50)
      win.h=50;
   wind_set(win.handle,5,win.x,win.y,win.l,win.h);
   if(flag) sys_redraw();
}

void wm_moved()
{
   wind_set(win.handle,5,message[4],message[5],win.l,win.h);
   win.x=message[4];
   win.y=message[5];
}

void show_dialog(OBJECT *arbre)
{
	int tx,ty,tw,th;
	form_center(arbre,&tx,&ty,&tw,&th);
	form_dial(0,tx,ty,tw,th,tx,ty,tw,th);
	form_dial(1,tx,ty,1,1,tx,ty,tw,th);
	objc_draw(arbre,0,20,tx,ty,tw,th);
	form_do(arbre,-1);
	form_dial(2,tx,ty,1,1,tx,ty,tw,th);
	form_dial(3,tx,ty,tw,th,tx,ty,tw,th);
	arbre[BOXOK].ob_state &=-2;
}

void show_acqui()
{
	char txt[50];
	char file[14];
	int but;
	TEDINFO *ted;
	int tx,ty,tw,th;
	ted=(TEDINFO *)adr_acqui[ACQUIEDI].ob_spec.tedinfo;
	strcpy(ted->te_ptext,eq);
	acqui:
	form_center(adr_acqui,&tx,&ty,&tw,&th);
	form_dial(0,tx,ty,tw,th,tx,ty,tw,th);
	form_dial(1,tx,ty,1,1,tx,ty,tw,th);
	objc_draw(adr_acqui,0,20,tx,ty,tw,th);
	form_do(adr_acqui,ACQUIEDI);
	form_dial(2,tx,ty,1,1,tx,ty,tw,th);
	form_dial(3,tx,ty,tw,th,tx,ty,tw,th);
	if(intersect(win.x,win.y,win.l,win.h,tx,ty,tw,th) )
	{
		no_redraw=1;
  }
  clip_off();
	if(adr_acqui[ACQUIOK].ob_state &0x1)
	{
  	adr_acqui[ACQUIOK].ob_state &=0xfe;
		ted=(TEDINFO *)adr_acqui[ACQUIEDI].ob_spec.tedinfo;
		strcpy(eq,ted->te_ptext);
	}
	if(adr_acqui[ACQUIANU].ob_state &0x1)
	{
		adr_acqui[ACQUIANU].ob_state &=0xfe;
	}
	file[0]=0;
	if(adr_acqui[ACQUISAV].ob_state &0x1)
	{
		adr_acqui[ACQUISAV].ob_state &=0xfe;
		ted=(TEDINFO *)adr_acqui[ACQUIEDI].ob_spec.tedinfo;
		Dgetpath(txt,0);
		strcat(txt,"\\*.S3D");
		fsel_input(txt,file,&but);
		if(strchr(file,'.'))
		{
			strcpy(strchr(file,'.'),".s3d");
		}
		else
		{
			strcat(file,".s3d");
		}
		strcpy(strchr(txt,'*'),file);
		if(but)
		{ 
			but=creat(txt);
			write(but,&R,sizeof(int));
			write(but,&H,sizeof(int));
			write(but,ted->te_ptext,strlen(ted->te_ptext)+1);
			close(but);
		}
		goto acqui;
	}
	if(adr_acqui[ACQUIOUV].ob_state &0x1)
	{
		adr_acqui[ACQUIOUV].ob_state &=0xfe;
		ted=(TEDINFO *)adr_acqui[ACQUIEDI].ob_spec.tedinfo;
		Dgetpath(txt,0);
		strcat(txt,"\\*.S3D");
		fsel_input(txt,file,&but);
		strcpy(strchr(txt,'*'),file);
		if(but)
		{
			but=open(txt,O_RDONLY);
			read(but,&R,sizeof(int));
			read(but,&H,sizeof(int));
			read(but,ted->te_ptext,50);
			close(but);
		}
		goto acqui;
	}
}

void show_angle()
{
	TEDINFO *ted;
	int tx,ty,tw,th;
	ted=(TEDINFO *)adr_angle[AROTA].ob_spec.tedinfo;
	if(R<0)
		sprintf(ted->te_ptext,"%d",R);
	else
		sprintf(ted->te_ptext,"+%d",R);
	ted=(TEDINFO *)adr_angle[AHAUT].ob_spec.tedinfo;
	if(H<0)
		sprintf(ted->te_ptext,"%d",H);
	else
		sprintf(ted->te_ptext,"+%d",H);

	
	form_center(adr_angle,&tx,&ty,&tw,&th);
	form_dial(0,tx,ty,tw,th,tx,ty,tw,th);
	form_dial(1,tx,ty,1,1,tx,ty,tw,th);
	objc_draw(adr_angle,0,20,tx,ty,tw,th);
	form_do(adr_angle,AROTA);
	form_dial(2,tx,ty,1,1,tx,ty,tw,th);
	form_dial(3,tx,ty,tw,th,tx,ty,tw,th);
	if(intersect(win.x,win.y,win.l,win.h,tx,ty,tw,th))
		no_redraw=1;

	if(adr_angle[DAO].ob_state &0x1)
	{
		adr_angle[DAO].ob_state &=0xfe;
		ted=(TEDINFO *)adr_angle[AROTA].ob_spec.tedinfo;
		R=atoi(ted->te_ptext);
		ted=(TEDINFO *)adr_angle[AHAUT].ob_spec.tedinfo;
		H=atoi(ted->te_ptext);
	}
	else
		adr_angle[DAA].ob_state &=0xfe;
}