#include <aes.h>

static TEDINFO rs_tedinfo[] = {
/*0*/	{"012", "Size: ___ pt", "9", IBM,0,TE_CNTR,0x1181,0,0,4,13},
/*1*/	{"TestSpeedo", "", "", IBM,0,TE_CNTR,0x1181,0,0,11,1},
/*2*/	{"by M. J. Maisey", "", "", IBM,0,TE_CNTR,0x1181,0,0,16,1},
/*3*/	{"28/3/94", "", "", IBM,0,TE_CNTR,0x1181,0,0,8,1},
/*4*/	{"012", "Width: ___%", "9", IBM,0,TE_CNTR,0x1181,0,0,4,12},
};

OBJECT MAINMENU[] = {
/*0*/	{-1,1,6,G_IBOX,0x0,0x0,(void *)0x0,0,0,160,25},
/*1*/	{6,2,2,G_BOX,0x0,0x0,(void *)0x1100,0,0,160,513},
/*2*/	{1,3,5,G_IBOX,0x0,0x0,(void *)0x0,2,0,26,769},
/*3*/	{4,-1,-1,G_TITLE,0x0,0x0," TestSpeedo", 0,0,12,769},
/*4*/	{5,-1,-1,G_TITLE,0x0,0x0," File", 12,0,6,769},
/*5*/	{2,-1,-1,G_TITLE,0x0,0x0," Window", 18,0,8,769},
/*6*/	{0,7,18,G_IBOX,0x0,0x0,(void *)0x0,0,769,160,19},
/*7*/	{16,8,15,G_BOX,0x0,0x0,(void *)0xff1100,2,0,22,8},
/*8*/	{9,-1,-1,G_STRING,0x0,0x0,"  About TestSpeedo", 0,0,22,1},
/*9*/	{10,-1,-1,G_STRING,0x0,0x8,"----------------------", 0,1,22,1},
/*10*/	{11,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 1  ", 0,2,22,1},
/*11*/	{12,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 2  ", 0,3,22,1},
/*12*/	{13,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 3  ", 0,4,22,1},
/*13*/	{14,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 4  ", 0,5,22,1},
/*14*/	{15,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 5  ", 0,6,22,1},
/*15*/	{7,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 6  ", 0,7,22,1},
/*16*/	{18,17,17,G_BOX,0x0,0x0,(void *)0xff1100,14,0,8,1},
/*17*/	{16,-1,-1,G_STRING,0x0,0x0,"  Quit", 0,0,8,1},
/*18*/	{6,19,21,G_BOX,0x0,0x0,(void *)0xff1100,20,0,11,3},
/*19*/	{20,-1,-1,G_STRING,0x0,0x0,"  Font     ", 0,0,11,1},
/*20*/	{21,-1,-1,G_STRING,0x0,0x0,"  Size     ", 0,1,11,1},
/*21*/	{18,-1,-1,G_STRING,0x20,0x0,"  Width    ", 0,2,11,1},
};

OBJECT SIZEMENU[] = {
/*0*/	{-1,1,5,G_BOX,0x0,0x0,(void *)0xff1100,1283,3840,13,5},
/*1*/	{2,-1,-1,G_STRING,0x0,0x0,"  10 pt", 0,0,13,1},
/*2*/	{3,-1,-1,G_STRING,0x0,0x0,"  12 pt", 0,1,13,1},
/*3*/	{4,-1,-1,G_STRING,0x0,0x0,"  18 pt", 0,2,13,1},
/*4*/	{5,-1,-1,G_STRING,0x0,0x0,"  24 pt", 0,3,13,1},
/*5*/	{0,-1,-1,G_STRING,0x20,0x0,"  Other ...", 0,4,13,1},
};

OBJECT OTHERSIZE[] = {
/*0*/	{-1,1,3,G_BOX,0x400,0x10,(void *)0x21181,4,1,25,5},
/*1*/	{2,-1,-1,G_BUTTON,0x607,0x0,"OK", 3,3,8,1},
/*2*/	{3,-1,-1,G_BUTTON,0x605,0x0,"Cancel", 14,3,8,1},
/*3*/	{0,-1,-1,G_FTEXT,0x28,0x0,&rs_tedinfo[0],2,1,21,1},
};

OBJECT ABOUT[] = {
/*0*/	{-1,1,4,G_BOX,0x400,0x10,(void *)0x21181,768,2560,21,8},
/*1*/	{2,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[1],0,1,21,1},
/*2*/	{3,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[2],0,3,21,1},
/*3*/	{4,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[3],0,4,21,1},
/*4*/	{0,-1,-1,G_BUTTON,0x627,0x0,"OK", 6,6,9,1},
};

OBJECT WIDTHMENU[] = {
/*0*/	{-1,1,6,G_BOX,0x0,0x0,(void *)0xff1100,1,1,13,6},
/*1*/	{2,-1,-1,G_STRING,0x0,0x0,"  50%", 0,0,13,1},
/*2*/	{3,-1,-1,G_STRING,0x0,0x0,"  75%", 0,1,13,1},
/*3*/	{4,-1,-1,G_STRING,0x0,0x0,"  100%", 0,2,13,1},
/*4*/	{5,-1,-1,G_STRING,0x0,0x0,"  150%", 0,3,13,1},
/*5*/	{6,-1,-1,G_STRING,0x0,0x0,"  200%", 0,4,13,1},
/*6*/	{0,-1,-1,G_STRING,0x20,0x0,"  Other ...  ", 0,5,13,1},
};

OBJECT OTHERWIDTH[] = {
/*0*/	{-1,1,3,G_BOX,0x400,0x10,(void *)0x21181,4,1,25,5},
/*1*/	{2,-1,-1,G_BUTTON,0x607,0x0,"OK", 3,3,8,1},
/*2*/	{3,-1,-1,G_BUTTON,0x605,0x0,"Cancel", 14,3,8,1},
/*3*/	{0,-1,-1,G_FTEXT,0x28,0x0,&rs_tedinfo[4],2,1,21,1},
};



static void fix_tree(OBJECT *s,int max)
{
	int i;

	for(i=0; i<=max; i++)
		rsrc_obfix(s,i);
}

void rsrc_init(void)
{
	fix_tree(MAINMENU,21);
	fix_tree(SIZEMENU,5);
	fix_tree(OTHERSIZE,3);
	fix_tree(ABOUT,4);
	fix_tree(WIDTHMENU,6);
	fix_tree(OTHERWIDTH,3);
}
