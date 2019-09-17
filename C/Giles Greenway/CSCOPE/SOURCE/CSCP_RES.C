#include <aes.h>

TEDINFO rs_tedinfo[] = {
/*0*/	{"z ^ 2 + u              ", "f(z) = _______________________", "XXXXXXXXXXXXXXXXXXXX", IBM,0,TE_CNTR,0x1181,0,1,24,31},
/*1*/	{"-2.000", "Re min: ______", "XXXXXX", IBM,0,TE_CNTR,0x1181,0,1,7,15},
/*2*/	{"0.5000", "Re max: ______", "XXXXXX", IBM,0,TE_CNTR,0x1181,0,1,7,15},
/*3*/	{"-1.250", "Im min: ______", "XXXXXX", IBM,0,TE_CNTR,0x1181,0,1,7,15},
/*4*/	{"1.2500", "Im max: ______", "XXXXXX", IBM,0,TE_CNTR,0x1181,0,1,7,15},
/*5*/	{"-0.740", "Re u: ______", "XXXXXX", IBM,0,TE_CNTR,0x1181,0,1,7,13},
/*6*/	{"0.1100", "Im u: ______", "XXXXXX", IBM,0,TE_CNTR,0x1181,0,1,7,13},
/*7*/	{"2.000", "Cut-off: _____", "XXXXX", IBM,0,TE_CNTR,0x1181,0,1,6,15},
/*8*/	{"040", "Max-its: ___", "999", IBM,0,TE_CNTR,0x1181,0,1,4,13},
/*9*/	{"COMPLEXOSCOPE was written", "", "", IBM,0,TE_LEFT,0x1181,0,0,26,1},
/*10*/	{"by G Greenway in May 1996", "", "", IBM,0,TE_LEFT,0x1181,0,0,26,1},
/*11*/	{"using Lattice C.", "", "", IBM,0,TE_LEFT,0x1181,0,0,17,1},
/*12*/	{" COMPLEXOSCOPE INFO: ", "", "", IBM,0,TE_CNTR,0x1181,0,1,22,1},
/*13*/	{"Do with it what thou wilt.", "", "", IBM,0,TE_LEFT,0x1181,0,0,27,1},
/*14*/	{"Further reading:", "", "", IBM,0,TE_LEFT,0x1181,0,0,17,1},
/*15*/	{"C. A. Pickover, \"Computers, Pattern,", "", "", SMALL,0,TE_LEFT,0x1181,0,0,37,1},
/*16*/	{"Chaos and Beauty\"", "", "", SMALL,0,TE_LEFT,0x1181,0,0,18,1},
/*17*/	{"Peitgen, J\201rgens, Saupe, \"Chaos and", "", "", SMALL,0,TE_LEFT,0x1181,0,0,36,1},
/*18*/	{"Fractals. New Frontiers of Science.\"", "", "", SMALL,0,TE_LEFT,0x1181,0,0,37,1},
};

OBJECT MAIN_FRM[] = {
/*0*/	{-1,1,14,G_BOX,0x0,0x0,(void *)0x21181,22,0,35,20},
/*1*/	{2,-1,-1,G_BUTTON,0x5,0x0," Info ", 3,18,8,1},
/*2*/	{3,-1,-1,G_BUTTON,0x5,0x0," Quit ", 13,18,9,1},
/*3*/	{4,-1,-1,G_BUTTON,0x7,0x0," Okay ", 24,18,8,1},
/*4*/	{5,-1,-1,G_BUTTON,0x11,0x1," Mandelbrot ", 2,16,15,1},
/*5*/	{6,-1,-1,G_BUTTON,0x11,0x0," Julia ", 18,16,15,1},
/*6*/	{7,-1,-1,G_FBOXTEXT,0x8,0x0,&rs_tedinfo[0],1,1,33,2},
/*7*/	{8,-1,-1,G_FBOXTEXT,0x8,0x0,&rs_tedinfo[1],1,4,16,2},
/*8*/	{9,-1,-1,G_FBOXTEXT,0x8,0x0,&rs_tedinfo[2],18,4,16,2},
/*9*/	{10,-1,-1,G_FBOXTEXT,0x8,0x0,&rs_tedinfo[3],1,7,16,2},
/*10*/	{11,-1,-1,G_FBOXTEXT,0x8,0x0,&rs_tedinfo[4],18,7,16,2},
/*11*/	{12,-1,-1,G_FBOXTEXT,0x8,0x0,&rs_tedinfo[5],1,10,16,2},
/*12*/	{13,-1,-1,G_FBOXTEXT,0x8,0x0,&rs_tedinfo[6],18,10,16,2},
/*13*/	{14,-1,-1,G_FBOXTEXT,0x8,0x0,&rs_tedinfo[7],1,13,16,2},
/*14*/	{0,-1,-1,G_FBOXTEXT,0x28,0x0,&rs_tedinfo[8],18,13,16,2},
};

OBJECT INF_FRM[] = {
/*0*/	{-1,1,11,G_BOX,0x0,0x0,(void *)0x21181,1561,768,29,20},
/*1*/	{2,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[9],2,4,25,1},
/*2*/	{3,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[10],2,5,25,1},
/*3*/	{4,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[11],7,6,16,1},
/*4*/	{5,-1,-1,G_BOXTEXT,0x0,0x0,&rs_tedinfo[12],3,1,23,2},
/*5*/	{6,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[13],2,8,26,1},
/*6*/	{7,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[14],6,10,16,1},
/*7*/	{8,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[15],1,12,27,1},
/*8*/	{9,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[16],1,13,13,1},
/*9*/	{10,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[17],1,15,27,1},
/*10*/	{11,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[18],1,16,27,1},
/*11*/	{0,-1,-1,G_BUTTON,0x27,0x0,"Okay", 2,18,25,1},
};



static void fix_tree(OBJECT *s,int max)
{
	int i;

	for(i=0; i<=max; i++)
		rsrc_obfix(s,i);
}

void rsrc_init(void)
{
	fix_tree(MAIN_FRM,14);
	fix_tree(INF_FRM,11);
}
