#include <aes.h>

TEDINFO rs_tedinfo[] = {
/*0*/	{" PINSKI ", "", "", IBM,0,TE_CNTR,0x1181,0,1,9,1},
/*1*/	{"Written by G Greenway", "", "", IBM,0,TE_LEFT,0x1181,0,0,22,1},
/*2*/	{"Do with it what thou wilt...", "", "", IBM,0,TE_LEFT,0x1181,0,0,29,1},
/*3*/	{" SET OPTIONS: ", "", "", IBM,0,TE_CNTR,0x1181,0,1,15,1},
/*4*/	{"002", "Modulo: ___", "999", IBM,0,TE_CNTR,0x1181,0,1,4,12},
/*5*/	{"4", "Depth: _", "9", IBM,0,TE_CNTR,0x1181,0,1,2,9},
};

OBJECT PIN_ABT[] = {
/*0*/	{-1,1,4,G_BOX,0x0,0x0,(void *)0x21181,1815,517,32,10},
/*1*/	{2,-1,-1,G_BOXTEXT,0x0,0x20,&rs_tedinfo[0],11,1,10,2},
/*2*/	{3,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[1],6,4,21,1},
/*3*/	{4,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[2],2,6,28,1},
/*4*/	{0,-1,-1,G_BUTTON,0x27,0x0,"I Shall", 12,8,9,1},
};

OBJECT PIN_FRM[] = {
/*0*/	{-1,1,11,G_BOX,0x0,0x0,(void *)0x21181,791,256,31,21},
/*1*/	{2,-1,-1,G_BOXTEXT,0x0,0x0,&rs_tedinfo[3],2,1,27,2},
/*2*/	{3,-1,-1,G_FBOXTEXT,0x8,0x0,&rs_tedinfo[4],2,16,13,2},
/*3*/	{6,4,5,G_BOX,0x0,0x0,(void *)0x11181,2,12,27,3},
/*4*/	{5,-1,-1,G_BUTTON,0x11,0x1,"Normal", 2,1,10,1},
/*5*/	{3,-1,-1,G_BUTTON,0x11,0x0,"Inverse", 15,1,10,1},
/*6*/	{7,-1,-1,G_BUTTON,0x7,0x0,"Okay", 12,19,6,1},
/*7*/	{11,8,10,G_BOX,0x0,0x0,(void *)0x11181,2,4,27,7},
/*8*/	{9,-1,-1,G_BUTTON,0x11,0x1,"Cellular Automata", 3,1,21,1},
/*9*/	{10,-1,-1,G_BUTTON,0x11,0x0,"Monte Carlo", 3,3,21,1},
/*10*/	{7,-1,-1,G_BUTTON,0x11,0x0," Recursive ", 3,5,21,1},
/*11*/	{0,-1,-1,G_FBOXTEXT,0x28,0x0,&rs_tedinfo[5],16,16,13,2},
};

OBJECT PIN_MEN[] = {
/*0*/	{-1,1,5,G_IBOX,0x0,0x0,(void *)0x0,0,0,160,25},
/*1*/	{5,2,2,G_BOX,0x0,0x0,(void *)0x1100,0,0,160,513},
/*2*/	{1,3,4,G_IBOX,0x0,0x0,(void *)0x0,2,0,12,769},
/*3*/	{4,-1,-1,G_TITLE,0x0,0x0," Desk ", 0,0,6,769},
/*4*/	{2,-1,-1,G_TITLE,0x0,0x0," File ", 6,0,6,769},
/*5*/	{0,6,15,G_IBOX,0x0,0x0,(void *)0x0,0,769,160,19},
/*6*/	{15,7,14,G_BOX,0x0,0x0,(void *)0xff1100,2,0,20,8},
/*7*/	{8,-1,-1,G_STRING,0x0,0x0,"  About PINSKI ", 0,0,20,1},
/*8*/	{9,-1,-1,G_STRING,0x0,0x8,"--------------------", 0,1,20,1},
/*9*/	{10,-1,-1,G_STRING,0x0,0x0,"1", 0,2,20,1},
/*10*/	{11,-1,-1,G_STRING,0x0,0x0,"2", 0,3,20,1},
/*11*/	{12,-1,-1,G_STRING,0x0,0x0,"3", 0,4,20,1},
/*12*/	{13,-1,-1,G_STRING,0x0,0x0,"4", 0,5,20,1},
/*13*/	{14,-1,-1,G_STRING,0x0,0x0,"5", 0,6,20,1},
/*14*/	{6,-1,-1,G_STRING,0x0,0x0,"6", 0,7,20,1},
/*15*/	{5,16,18,G_BOX,0x0,0x0,(void *)0xff1100,8,0,13,3},
/*16*/	{17,-1,-1,G_STRING,0x0,0x0,"  Quit ", 0,2,13,1},
/*17*/	{18,-1,-1,G_STRING,0x0,0x0,"  Options ", 0,0,13,1},
/*18*/	{15,-1,-1,G_STRING,0x20,0x0,"  Save Image ", 0,1,13,1},
};



static void fix_tree(OBJECT *s,int max)
{
	int i;

	for(i=0; i<=max; i++)
		rsrc_obfix(s,i);
}

void rsrc_init(void)
{
	fix_tree(PIN_ABT,4);
	fix_tree(PIN_FRM,11);
	fix_tree(PIN_MEN,18);
}
