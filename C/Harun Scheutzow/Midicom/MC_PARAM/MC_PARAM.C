#include <portab.h>			 /* Standard-Definitionen */
#include <aes.h>       	 /* AES */
#include <string.h>      /* String-Library */
#include <stddef.h>	     /* Standard-Definitionen */
#include <stdlib.h> 	     /* Standard-Definitionen */
#include <cpxdata.h>
#include <gemst2.h>
#include "..\mc_lib\mc_lib.h"

#include "mcparm.h"
#include "mcparm.c"

typedef struct
{
 int  mcdrv;
 int	sttim;
 char	nodnam[10];
 int	prconf;
 int	speed;
 int	timexx;
 int	timeff;
 int	ergff;
 int	priblocks;
 long	spbuff;
 int	errcnt;
} inffile;

inffile i_file={12,0,"USER",-1,50,100,50,0,1900,0,0};

#define WM_CLOSE 22
#define AC_CLOSE 41

void init_dia(OBJECT *tree)
{
	int 	i,fo_cx,fo_cy,fo_cw,fo_ch;

	for (i = 0; i < rs_numobs; i++)
		rsrc_obfix(tree,i); 

	i=form_center(tree,&fo_cx,&fo_cy,&fo_cw,&fo_ch );
}

void set_dialog(OBJECT *tree,	syspar	sys,all_proc	allprocs)
{
	int	wert;
	
	/* Stationsnummer setzen */
	itoa(sys->my_num,TedText(MYNUM),10);
	
	/* Rechnername */
	strcpy(TedText(RNAME),(*allprocs)[sys->my_num].r_name);
	/*	Timeout Ring */
	wert=(int) sys->timeout/200;
	itoa(wert,TedText(TIMER),10);
	
	/* Timer events */
	itoa(sys->mcspeed,TedText(MCTIMER),10);
	
	/* timeout Drucker */
	itoa(sys->time,TedText(PRXX),10);
	itoa(sys->timeff,TedText(PRFF),10);

	/* Block groesse */
	itoa(sys->prspeed,TedText(PRIBLOCK),10);

	Deselect(FULLDEB);
	Deselect(ERRDEB);
	Deselect(NODEB);
	
	switch (sys->errbell)
	{
	 case 0: Select(NODEB);break;
	 case 1: Select(ERRDEB);break;
	 case 2: Select(FULLDEB);break;
	}
	
	Deselect(PLUSFF);
	Deselect(NOFF);
	switch (sys->ergff)
	{
	 case 0:	Select(NOFF);break;
	 default:	Select(PLUSFF);
	}
}

void get_dialog(OBJECT *tree,	syspar	sys)
{
	int	wert;
	
	/*	Timeout Ring */
	wert=atoi(TedText(TIMER));
	sys->timeout=wert*200;

	/* Timer events */
	sys->mcspeed=atoi(TedText(MCTIMER));
	
	/* timeout Drucker */
	sys->time=atoi(TedText(PRXX));
	sys->timeff=atoi(TedText(PRFF));

	/* Block groesse */
	sys->prspeed=atoi(TedText(PRIBLOCK));
	if ((sys->prspeed<100) | (sys->prspeed>1900)) sys->prspeed=1900;

  if (IsSelected(NODEB)) sys->errbell=0;
  if (IsSelected(ERRDEB)) sys->errbell=1;
  if (IsSelected(FULLDEB)) sys->errbell=2;
  sys->reciev=0;
  sys->errcnt=0;
  
  if (IsSelected(PLUSFF)) sys->ergff=(char) -1;
  if (IsSelected(NOFF)) sys->ergff=(char) 0;
	
}

void app_dialog(OBJECT *tree,	syspar	sys,all_proc	allprocs)
{
	int i;

	form_dial(FMD_START,tree[ROOT].ob_x-4,tree[ROOT].ob_y-4,
			tree[ROOT].ob_width+8,tree[ROOT].ob_height+8,
			tree[ROOT].ob_x-4,tree[ROOT].ob_y-4,
			tree[ROOT].ob_width+8,tree[ROOT].ob_height+8);

		set_dialog(tree,sys,allprocs);

		objc_draw(tree,ROOT,MAX_DEPTH,0,0,0,0);

		i=form_do(tree,0);
  	SetNormal(i);

		if (i!=CANCEL) get_dialog(tree,sys);
 

	form_dial(FMD_FINISH,tree[ROOT].ob_x-4,tree[ROOT].ob_y-4,
			tree[ROOT].ob_width+8,tree[ROOT].ob_height+8,
			tree[ROOT].ob_x-4,tree[ROOT].ob_y-4,
			tree[ROOT].ob_width+8,tree[ROOT].ob_height+8);
 
	if (i==SPEICHER)
	{
	 
	}
}


void wait_loop(void)
{    
	syspar		sys;
  all_proc	allprocs;
	OBJECT 		*tree;
	WORD			msg[8];
	
	tree=( OBJECT *)rs_trindex[ SYS ];
	init_dia(tree);/* location and center */

	if (_app==0)			/* ACC	*/
	{
		menu_register( gl_apid,"  MC_PARAMETER");
		do
   	{
			evnt_mesag(msg);
      if (msg[0]==AC_OPEN)
      {
      	if (get_mc_sys(&sys,&allprocs))
      	{
    			app_dialog(tree,sys,allprocs);
    		}
    		else
    		{
    /*			form_alert(1,string_66);*/
    		};
    	};
   	}while (1);
	}
	else
	{
		if (get_mc_sys(&sys,&allprocs))
 		{
			app_dialog(tree,sys,allprocs);
	 	}
		else
		{
    /*	form_alert(1,string_66);*/
		};
	};
}


int main( void )
{
    wait_loop();
    return 0;
}

