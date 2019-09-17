/************************************************************************/
/* A simple Form handler routine (probably not as elegant as possible!) */
/* Thanks to Hisoft Lattice C5 example program for help and guidance.   */
/* Written by MORF - for Ictari.                                        */
/* Alter, re-write, use as-is, or destroy as you wish !!                */
/* THE RSC FILE is written in WERCS. COMPILE WITH GEM LIBRARIES !       */
/* Hmmmmmmmmmmmm                                                        */
/* I'm not sure if this will compile on another C compiler. I used :-   */
/*  L       A   TTTTT TTTTT IIIII CCCCC EEEEE      CCCCC  55555         */
/*  L      A A    T     T     I   C     E          C      5             */
/*  L     AAAAA   T     T     I   C     EEEEE      C      55555         */
/*  L     A   A   T     T     I   C     E          C          5 ..      */
/*  LLLLL A   A   T     T   IIIII CCCCC EEEEE      CCCCC  55555 ..      */
/*														  */
/* And a damn good compiler it is to !                                  */
/* TABS SET TO 5 if you are having problems with alligning of comments  */
/* See ya !                                                             */
/***************************** INCLUDE FILES ****************************/
#include  <osbind.h>
#include 	<stdio.h>
#include 	<stdlib.h>
#include 	<string.h>
#include 	<aes.h>
#include 	<vdi.h>
#include 	"test.h"
/************************* FUNCTION PROTOTYPES **************************/
void set_tedinfo(OBJECT *tree,int obj,char *source);
void get_tedinfo(OBJECT *tree, int obj, char *dest);
void handle_form(OBJECT *dlog);
void initialise(void);
void deinitialise(void);
void set_button(OBJECT *tree,int parent,int button);
/**************************** GLOBAL VARIABLES **************************/
long error;	/* return val from proggy, or negative (error) */
short vdi;	/* Virtual Device Number */
/********************************* PROGRAM ******************************/
int main(void)
{
OBJECT *dlog;	/* used to ID the form */

	initialise();
	
	rsrc_gaddr(R_TREE,EXAMPLE,&dlog);	/* get address of form in dlog */
	handle_form(dlog);				/* Do the stuff */
	
	deinitialise();
	return EXIT_SUCCESS;
}
/****************** SET UP GEM - LOAD RSC. ALLOCATE MEMORY **************/
void initialise(void)
{
short work_in[11]={1,1,1,1,1,1,1,1,1,1,2};
short work_out[57];
short junk;
short screenx,screeny,screenw,screenh;
	
	if (appl_init())				/* open aes application */
		exit(EXIT_FAILURE);
	vdi = graf_handle(&junk, &junk, &junk, &junk); /* get temp. vdi no */
	v_opnvwk(work_in, &vdi, work_out);	/* update vdi id number */
	if (!vdi)
		exit(EXIT_FAILURE);			/* vdi failure */
		
	if (Getrez() != 0)
	{
		if (!rsrc_load("test.RSC"))	/* load resource file */
		{
			form_alert(1,"[3][RESOURCE FILE ERROR][ QUIT ]");
			exit(EXIT_FAILURE);
		}
	}
	else
	{
		form_alert(1,"[3][SORRY MEDIUM | OR HIGH RES. ONLY][ QUIT ]");
		exit(EXIT_FAILURE);
	}

	wind_get(DESK,WF_WORKXYWH,&screenx,&screeny,&screenw,&screenh);
		/* get screen size co-ords */
	graf_mouse(ARROW,NULL);	/* put mouse on screen */
}
/*********************** SHUT DOWN - CLOSE WORK BASE ********************/
void deinitialise(void)
{
	rsrc_free();		/* free up resource file */
	v_clsvwk(vdi);		/* close work station */
	appl_exit();		/* close aes application */
}
/***************************** MAIN SUB-ROUTINE *************************/
void handle_form(OBJECT *dlog)
{
	char ok;			/* response from keyboard */
	short x,y,w,h;		/* screen co-ords */
	int but;			/* but = what button pressed */
	int radio = ONE;	/* set radio button highlight memo to ONE */
	char what_radio[40];/* output string for what radio button pressed*/
	char edit[20];		/* string to hold output of EDITFIELD */
	char output[35];	/* string for alertbox output from edit */
	
	*edit=0;			/* clear the string */
	
	form_center(dlog,&x,&y,&w,&h); /* get centre form on screen co-ords */
	form_dial(FMD_START,0,0,0,0,x,y,w,h);		/* grow from 0,0,0,0 */
	form_dial(FMD_GROW,x+w/2,y+h/2,0,0,x,y,w,h); /* do grow */

	set_button(dlog,FOURBUTTONS,radio); /* highlight a radio but */
	set_tedinfo(dlog,EDITFIELD,edit);	 /* Blank out editable field*/

	objc_draw(dlog,ROOT,MAX_DEPTH,x,y,w,h);	/* draw form */
	

	but = form_do(dlog,EDITFIELD);		/* let user interact */

	switch (but)		/* what button was pressed */
	{
		case DEFEXIT: /* do you wana leave */
			ok = form_alert(1,"[1][ Thats ALL folks ][ BYE ]");
			break;
				
		break;		
	}
	dlog[but].ob_state&=~SELECTED;		/* de-select exit button */
	
	radio = get_button(dlog,FOURBUTTONS);	/* get the radio button */
	get_tedinfo(dlog,EDITFIELD,edit);		/* editable field in edit */

	form_dial(FMD_SHRINK,x+w/2,y+h/2,0,0,x,y,w,h);	/* close form */
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);

	switch (radio)
	{
		case ONE:
			strcpy(what_radio, "[1][One selected][ OK ]");
			break;
		case TWO:
			strcpy(what_radio, "[1][Two selected][ OK ]");
			break;
		case THREE:
			strcpy(what_radio, "[1][Three selected][ OK ]");
			break;
		case FOUR:
			strcpy(what_radio, "[1][Four selected][ OK ]");
			break;
			
		break;
	}
	form_alert(1,what_radio);	/* write what radio button */

	strcpy (output, "[1][");		/* write the editable field */
	strncat (output, edit, 20);
	strncat (output, "][ FINE ]",10);
	form_alert(1,output);

}
/************************** SORT OUT RADIO BUTTONS **********************/
void set_button(OBJECT *tree,int parent,int button)
{
	int b;
	
	for (b=tree[parent].ob_head; b!=parent; b=tree[b].ob_next)
		if (b==button)
			tree[b].ob_state|=SELECTED;
		else
			tree[b].ob_state&=~SELECTED;
}
int get_button(OBJECT *tree,int parent)
{
	int b;

	b=tree[parent].ob_head;
	for (; b!=parent && !(tree[b].ob_state&SELECTED); b=tree[b].ob_next)
		;

	return b;
}
/********************** SORT OUT EDITABLE FIELD STUFF ********************/
/* copy a string into a TEDINFO structure. */
/* DON'T ASK ME WHAT A TEDINFO STRUCTURE IS CUZ I DON'T CARE !!! */
/* IT WORKS AND THATS THAT */

void set_tedinfo(OBJECT *tree,int obj,char *source)
{
	char *dest;
	
	dest=((TEDINFO *)tree[obj].ob_spec)->te_ptext;
	strcpy(dest,source);
}

/* copy the string from a TEDINFO into another string */

void get_tedinfo(OBJECT *tree, int obj, char *dest)
{
	char *source;

	source=((TEDINFO *)tree[obj].ob_spec)->te_ptext;	/* extract address */
	strcpy(dest,source);
}
/******************************** FINIS *********************************/