#include <aes.h>

TEDINFO rs_tedinfo[] = {
/*0*/	{"FLAKEY", "", "", IBM,0,TE_CNTR,0x1181,0,1,7,1},
/*1*/	{"Written by G Greenway", "", "", IBM,0,TE_CNTR,0x1181,0,0,22,1},
/*2*/	{"This program may be kept", "", "", IBM,0,TE_LEFT,0x1181,0,0,25,1},
/*3*/	{"until needed or sold.", "", "", IBM,0,TE_LEFT,0x1181,0,0,22,1},
/*4*/	{"4", "Depth: _", "9", IBM,0,TE_CNTR,0x1181,0,1,2,9},
};

OBJECT FLK_ABT[] = {
/*0*/	{-1,1,5,G_BOX,0x0,0x0,(void *)0x21181,27,517,28,11},
/*1*/	{2,-1,-1,G_BOXTEXT,0x0,0x0,&rs_tedinfo[0],10,1,8,2},
/*2*/	{3,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[1],3,4,21,1},
/*3*/	{4,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[2],2,6,24,1},
/*4*/	{5,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[3],3,7,21,1},
/*5*/	{0,-1,-1,G_BUTTON,0x27,0x0,"Fair 'nuff", 8,9,12,1},
};

OBJECT FLK_FRM[] = {
/*0*/	{-1,1,2,G_BOX,0x0,0x0,(void *)0x21181,1055,1030,15,6},
/*1*/	{2,-1,-1,G_FBOXTEXT,0x8,0x0,&rs_tedinfo[4],2,1,11,2},
/*2*/	{0,-1,-1,G_BUTTON,0x27,0x0,"Okay", 2,4,11,1},
};

OBJECT FLK_MEN[] = {
/*0*/	{-1,1,5,G_IBOX,0x0,0x0,(void *)0x0,0,0,160,25},
/*1*/	{5,2,2,G_BOX,0x0,0x0,(void *)0x1100,0,0,160,513},
/*2*/	{1,3,4,G_IBOX,0x0,0x0,(void *)0x0,2,0,12,769},
/*3*/	{4,-1,-1,G_TITLE,0x0,0x0," Desk ", 0,0,6,769},
/*4*/	{2,-1,-1,G_TITLE,0x0,0x0," File ", 6,0,6,769},
/*5*/	{0,6,15,G_IBOX,0x0,0x0,(void *)0x0,0,769,160,19},
/*6*/	{15,7,14,G_BOX,0x0,0x0,(void *)0xff1100,2,0,20,8},
/*7*/	{8,-1,-1,G_STRING,0x0,0x0,"  About FLAKEY ", 0,0,20,1},
/*8*/	{9,-1,-1,G_STRING,0x0,0x8,"--------------------", 0,1,20,1},
/*9*/	{10,-1,-1,G_STRING,0x0,0x0,"1", 0,2,20,1},
/*10*/	{11,-1,-1,G_STRING,0x0,0x0,"2", 0,3,20,1},
/*11*/	{12,-1,-1,G_STRING,0x0,0x0,"3", 0,4,20,1},
/*12*/	{13,-1,-1,G_STRING,0x0,0x0,"4", 0,5,20,1},
/*13*/	{14,-1,-1,G_STRING,0x0,0x0,"5", 0,6,20,1},
/*14*/	{6,-1,-1,G_STRING,0x0,0x0,"6", 0,7,20,1},
/*15*/	{5,16,17,G_BOX,0x0,0x0,(void *)0xff1100,8,0,12,2},
/*16*/	{17,-1,-1,G_STRING,0x0,0x0,"  Quit", 0,1,12,1},
/*17*/	{15,-1,-1,G_STRING,0x20,0x0,"  Set Depth ", 0,0,12,1},
};



static void fix_tree(OBJECT *s,int max)
{
	int i;

	for(i=0; i<=max; i++)
		rsrc_obfix(s,i);
}

void rsrc_init(void)
{
	fix_tree(FLK_ABT,5);
	fix_tree(FLK_FRM,2);
	fix_tree(FLK_MEN,17);
}
