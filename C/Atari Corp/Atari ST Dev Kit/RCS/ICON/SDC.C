/*********************************************************************/
/* SAMPLE APPLICATION: 						     */
/* Draws a bouncing ball demo same as one in assembler		     */	
/*********************************************************************/

/*********************************************************************/
/* INCLUDE FILES						     */
/*********************************************************************/

#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"


/*********************************************************************/
/* EXTERNALS						   	     */
/*********************************************************************/

extern 	int	gl_apid;
extern	int	page_num;

/*********************************************************************/
/* GLOBAL VARIABLES					   	     */
/*********************************************************************/


int 	phys_handle;	/* physical workstation handle */
int 	handle;		/* virtual workstation handle */

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];	/* storage wasted for idiotic bindings */

int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */
int pxyarray[10];	/* input point array */

int	i;


/* ShIcEd Form Definition Data */
#define SHAP1_W 0x0008
#define SHAP1_H 0x000F
#define DATASIZE 0x0078
int sh1_data[DATASIZE] = 
{ 0x07F0, 0x07F0, 0x07F0, 0x07F0, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x180C, 0x180C, 0x1FFC, 0x180C, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x2002, 0x2002, 0x3FFE, 0x2002, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x4001, 0x4001, 0x7D5F, 0x4001, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x4001, 0x4001, 0x7D5F, 0x4001, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x8000, 0x8000, 0xFD5F, 0x8000, 
  0x8000, 0x8000, 0x8000, 0x8000, 
  0x8000, 0x8000, 0xFD5F, 0x8000, 
  0x8000, 0x8000, 0x8000, 0x8000, 
  0x8000, 0x8000, 0xFD5F, 0x8000, 
  0x8000, 0x8000, 0x8000, 0x8000, 
  0x8000, 0x8000, 0xFD5F, 0x8000, 
  0x8000, 0x8000, 0x8000, 0x8000, 
  0x8000, 0x8000, 0xFB6F, 0x8000, 
  0x8000, 0x8000, 0x8000, 0x8000, 
  0x4001, 0x4001, 0x6773, 0x4001, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x4001, 0x4001, 0x7FFF, 0x4001, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x2002, 0x2002, 0x3FFE, 0x2002, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x180C, 0x180C, 0x1FFC, 0x180C, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x07F0, 0x07F0, 0x07F0, 0x07F0, 
  0x0000, 0x0000, 0x0000, 0x0000
};


/* ShIcEd Form Definition Mask */
int sh1_mask[DATASIZE] = 
{ 0x07F0, 0x07F0, 0x07F0, 0x07F0, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x1FFC, 0x1FFC, 0x1FFC, 0x1FFC, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x3FFE, 0x3FFE, 0x3FFE, 0x3FFE, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0x8000, 0x8000, 0x8000, 0x8000, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0x8000, 0x8000, 0x8000, 0x8000, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0x8000, 0x8000, 0x8000, 0x8000, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0x8000, 0x8000, 0x8000, 0x8000, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0x8000, 0x8000, 0x8000, 0x8000, 
  0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x3FFE, 0x3FFE, 0x3FFE, 0x3FFE, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x1FFC, 0x1FFC, 0x1FFC, 0x1FFC, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x07F0, 0x07F0, 0x07F0, 0x07F0, 
  0x0000, 0x0000, 0x0000, 0x0000
};

int	sh1_bk1[DATASIZE];	/* shapes background on page 1 */
int	sh1_bk2[DATASIZE];	/* shapes background on page 2 */

int	s1xpath[48] =
{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1
};

int	s1ypath[48] =
{ -2,-2,-2,-2,-2,-2,-2,-2,2,2,2,2,2,2,2,2,
  -2,-2,-2,-2,-2,-2,-2,-2,2,2,2,2,2,2,2,2,
  0,-3,-3,-2,-2,-2,-2,-1,0,0,2,2,2,3,3,3
};

int	rez_save;		/* resolution save variable */
int	path_num;		/* path number variable */
int	shap1_x,shap1_y;	/* x and y shapes cooridinates */
int	sh1_ox,sh1_oy;		/* old x and y cooridinates */
int	key_in;			/* key input */


/****************************************************************/
/*		Main routine to control everything		*/
/****************************************************************/
main()
{
	appl_init();

	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	handle=phys_handle;
	v_opnvwk(work_in,&handle,work_out);	/* open a work station */

	graf_mouse(M_OFF,0x0L);

	rez_save = Getrez();		/* get current resolution */
	Setscreen(-1L,-1L,0);		/* set only low resolution */
	get_screen();			/* set to screens */

	page_num = 0;			/* set first page number /*
	path_num = 0;			/* set start of path */
	page_flip();			/* so we can set-up shapes */
	clr_scr();			/* clear the hirez screens */
	draw_init();			/* go draw the first shapes */

	do
	  { do
	      { ball_draw();		/* draw the ball to screen */
	    	page_flip();		/* flip the page */
		delay();		/* wait for eye to catch up */
	   	ball_erase();		/* go erase the ball */
	    	shap1_x = shap1_x + s1xpath[path_num]; /* get next x path */
	    	shap1_y = shap1_y + s1ypath[path_num]; /* get y path next */
		path_num = path_num + 1;
		if (path_num >= 48)
		  path_num = 32;
	      }
	    while (shap1_x < 300);
	    path_num = 0;
	    shap1_x = 20;
	    shap1_y = 100;		/* reset everything */
	    key_in = Bconstat(2);	/* is there a key? */
	  }
	while (!key_in);		/* keep going until */

	Bconin(2);			/* get the key pressed */
	clean_up();			/* go clean-up screen */
	
	Setscreen(-1L,-1L,rez_save);
	graf_mouse(M_ON,0x0L);
}

/*********************************************************************/
/*		Ball_draw draws the ball at the x,y location	     */
/*********************************************************************/
ball_draw()

{ if (!page_num)
    shap_draw(shap1_x,shap1_y,SHAP1_W,SHAP1_H,&sh1_data,&sh1_mask,&sh1_bk2);
  else
    shap_draw(shap1_x,shap1_y,SHAP1_W,SHAP1_H,&sh1_data,&sh1_mask,&sh1_bk1);
}

/*********************************************************************/
/*		Ball_erase erases the ball at the x,y location	     */
/*********************************************************************/
ball_erase()

{ if (!page_num)
    shap_erase(sh1_ox,sh1_oy,SHAP1_W,SHAP1_H,&sh1_bk2);
  else
    shap_erase(sh1_ox,sh1_oy,SHAP1_W,SHAP1_H,&sh1_bk1);

  sh1_ox = shap1_x;
  sh1_oy = shap1_y;		/* shapes update old x and y */
}

/********************************************************************/
/*		draw_init draws the shapes to begin with	    */
/********************************************************************/
draw_init()

{ shap1_x = 20;
  shap1_y = 100;
  sh1_ox = 20;
  sh1_oy = 100;		/* init variables */

  shap_draw(shap1_x,shap1_y,SHAP1_W,SHAP1_H,&sh1_data,&sh1_mask,&sh1_bk1);

  page_flip();		/* draw the first shapes to initialize */
}

/********************************************************************/
/*	delay for a little bit so the eye catches the shape	    */
/********************************************************************/
delay()

{ int	counter;

  for (counter=0;counter<0x1000;counter++);

}
