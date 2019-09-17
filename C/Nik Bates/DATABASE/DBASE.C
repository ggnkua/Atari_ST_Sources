/**********************************/
/*        iCTARi Database         */
/* Produced for iCTARi USER GROUP */
/* (c) Nik Bates 1993             */
/* Not a complete program         */
/**********************************/

/* INCLUDE FILES */

#include "DBASE.h"
#include <osbind.h>

/* GEM VARIABLES */

int work_in[11], work_out[57],
	pxarray[10], contrl[12],
	intin[128], ptsin[128],
	intout[128], ptsout[128];
	
/* GLOBAL VARIABLES */

int handle, dum;
int dial_x,dial_y,dial_w,dial_h;
/* Dialogue x,y cordinates,width,height */

/* Object Description Structure */
typedef struct object
{
	int ob_next;
	int ob_head;
	int ob_tail;
	unsigned int ob_type;
	unsigned int ob_flags;
	unsigned int ob_state;
	char *ob_spec;
	int ob_x;
	int ob_y;
	int ob_w;
	int ob_h;
}OBJECT;

OBJECT*tree_addr; /* POINTER TO OBJECT STRUCTURE */

/* STRRUCTURE TO HOLD TEXT INFO */
typedef struct text_edinfo
{
	char *te_ptext;
	char *te_ptmplt;
	char *te_pvalid;
	int te_font;
	int te_junk1;
	int te_just;
	int te_color;
	int te_junk2;
	int te_thickness;
	int te_txtlen;
	int	te_tmplen;
}TEDINFO;

main()
{
	int num=1;
	appl_init();
	while (num)
	{
		num = dialog_main();
		if (num) dialog_address();
	}
	rsrc_free();
	appl_exit();
}

open_vwork()
{
	int i;

	/* Get Handle */	
	handle = graf_handle(&dum, &dum, &dum, &dum);

    /* Initialise Variables */
    for (i=0;i<10;work_in[i++] = 1);
	work_in[10] = 2;
    /* Open Virtual Workstation */
	v_opnvwk(work_in,&handle,work_out);
}

dialog_main()
{
	int choice,num=0;
	
	open_vwork();
    /* Load Resource File */
	if (!rsrc_load("B:\DBASE.RSC"))
		form_alert(1,"[1][Resource File Missing!][Please insert disk]");
	else
	{
	 	/* Draw Dialogue - GROW */
		rsrc_gaddr(0,MAIN,&tree_addr);
		form_center(tree_addr,&dial_x,&dial_y,&dial_w,&dial_h);
		form_dial(0,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
		form_dial(1,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
		objc_draw(tree_addr,0,2,dial_x,dial_y,dial_w,dial_h);
		graf_mouse (3,&dum); /* Mouse = Finger */		
        /* Wait for Button */
		do
		{
			choice = form_do(tree_addr,MAIN);
		}
		while (!choice);
	    /* Remove Dialogue - Shrink */
		form_dial(2,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
		form_dial(3,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
		if (choice == ADD || choice == EDIT) num=1;
		else if (choice != QUIT) num=2;
		return(num);
	}	
}
dialog_address()
{
    int choice;
	open_vwork();
	/* Draw 2nd Dialogue */
	rsrc_gaddr(0,ADDRESS,&tree_addr);
	form_center(tree_addr,&dial_x,&dial_y,&dial_w,&dial_h);
	form_dial(0,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
	form_dial(1,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
	objc_draw(tree_addr,0,2,dial_x,dial_y,dial_w,dial_h);
		
	do
	{
		choice = form_do(tree_addr,MAIN);
		
	}
	while (choice != OK && choice != CANCEL);
		
	form_dial(2,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
	form_dial(3,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
}	

