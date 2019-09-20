#include <aes.h>

static TEDINFO rs_tedinfo[] = {
/*0*/	{"This program recognises and lists these font formats:", "", "", SMALL,0,TE_LEFT,0x1180,0,0,54,1},
/*1*/	{"Calamus (CFN), Postscript (PFA, PFB & PS), Ghostscript (GSF),", "", "", SMALL,0,TE_LEFT,0x1180,0,0,62,1},
/*2*/	{"Bitstream Speedo (SPD), TrueType (TTF), GEM Bitmap (FNT), Calligrapher (LAC),", "", "", SMALL,0,TE_LEFT,0x1180,0,0,78,1},
/*3*/	{"12345678901234567890123456789012345678901234567890123456789", "___________________________________________________________", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", IBM,6,TE_CNTR,0x1180,0,-1,60,60},
/*4*/	{"12345678901234567890123456789012345678901234567890123456789", "___________________________________________________________", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", IBM,6,TE_CNTR,0x1180,0,-1,60,60},
/*5*/	{"Matthew Carey (c) 1995, Freeware - A rough hack to help keep track of fonts.", "", "", SMALL,6,TE_LEFT,0x1180,0,-1,77,1},
/*6*/	{"Pagestream (DMF/FM) & Compugraphic (CG).", "", "", SMALL,0,TE_LEFT,0x1180,0,0,41,1},
};

OBJECT MAINDIAL[] = {
/*0*/	{-1,1,18,G_BOX,0x0,0x10,(void *)0x22100,0,0,66,2068},
/*1*/	{2,-1,-1,G_STRING,0x0,0x0,"Select the target path and the output file:", 2,7,43,1},
/*2*/	{3,-1,-1,G_STRING,0x0,0x0,"List all the fonts within a folder and sub-folders by", 2,1,53,1},
/*3*/	{4,-1,-1,G_STRING,0x0,0x0,"file name and font name.", 2,2,24,1},
/*4*/	{5,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[0],2,4,1575,1},
/*5*/	{6,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[1],2,2052,1581,1},
/*6*/	{7,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[2],2,5,1593,1},
/*7*/	{8,-1,-1,G_BUTTON,0x5,0x0,"Target Path", 2,9,14,1},
/*8*/	{9,-1,-1,G_BUTTON,0x5,0x0,"Listing file", 2,13,14,1},
/*9*/	{10,-1,-1,G_FTEXT,0x0,0x0,&rs_tedinfo[3],2,11,59,1},
/*10*/	{11,-1,-1,G_FTEXT,0x0,0x0,&rs_tedinfo[4],2,15,59,1},
/*11*/	{12,-1,-1,G_BUTTON,0x7,0x0,"Run", 2,17,15,1},
/*12*/	{13,-1,-1,G_BUTTON,0x5,0x0,"Quit ", 48,17,15,1},
/*13*/	{14,-1,-1,G_TEXT,0x0,0x0,&rs_tedinfo[5],2,19,57,1},
/*14*/	{18,15,17,G_IBOX,0x0,0x0,(void *)0xff1100,39,13,24,1},
/*15*/	{16,-1,-1,G_BUTTON,0x11,0x1,"Replace", 0,0,8,1},
/*16*/	{17,-1,-1,G_BUTTON,0x11,0x0,"Append", 8,0,8,1},
/*17*/	{14,-1,-1,G_BUTTON,0x11,0x0,"Dbase", 16,0,8,1},
/*18*/	{0,-1,-1,G_TEXT,0x20,0x0,&rs_tedinfo[6],2,2053,30,1},
};

OBJECT MAINMENU[] = {
/*0*/	{-1,1,5,G_IBOX,0x0,0x0,(void *)0x0,0,0,80,25},
/*1*/	{5,2,2,G_BOX,0x0,0x0,(void *)0x1100,0,0,80,513},
/*2*/	{1,3,4,G_IBOX,0x0,0x0,(void *)0x0,2,0,16,769},
/*3*/	{4,-1,-1,G_TITLE,0x0,0x0," LISTFONT", 0,0,10,769},
/*4*/	{2,-1,-1,G_TITLE,0x0,0x0," File", 10,0,6,769},
/*5*/	{0,6,15,G_IBOX,0x0,0x0,(void *)0x0,0,769,80,23},
/*6*/	{15,7,14,G_BOX,0x0,0x0,(void *)0xff1100,2,0,20,8},
/*7*/	{8,-1,-1,G_STRING,0x0,0x0,"  About Listfont... ", 0,0,20,1},
/*8*/	{9,-1,-1,G_STRING,0x0,0x8,"--------------------", 0,1,20,1},
/*9*/	{10,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 1 ", 0,2,20,1},
/*10*/	{11,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 2 ", 0,3,20,1},
/*11*/	{12,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 3 ", 0,4,20,1},
/*12*/	{13,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 4 ", 0,5,20,1},
/*13*/	{14,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 5 ", 0,6,20,1},
/*14*/	{6,-1,-1,G_STRING,0x0,0x0,"  Desk Accessory 6 ", 0,7,20,1},
/*15*/	{5,16,26,G_BOX,0x0,0x0,(void *)0xff1100,12,0,20,11},
/*16*/	{17,-1,-1,G_STRING,0x0,0x8,"--Select------------", 0,0,20,1},
/*17*/	{18,-1,-1,G_STRING,0x0,0x0,"  Target Path    ^T ", 0,1,20,1},
/*18*/	{19,-1,-1,G_STRING,0x0,0x0,"  Listing File   ^L ", 0,2,20,1},
/*19*/	{20,-1,-1,G_STRING,0x0,0x8,"--Listing File------", 0,3,20,1},
/*20*/	{21,-1,-1,G_STRING,0x0,0x4,"  Replace        ^R ", 0,4,20,1},
/*21*/	{22,-1,-1,G_STRING,0x0,0x0,"  Append         ^A ", 0,5,20,1},
/*22*/	{23,-1,-1,G_STRING,0x0,0x0,"  DataBase       ^D ", 0,6,20,1},
/*23*/	{24,-1,-1,G_STRING,0x0,0x8,"--------------------", 0,7,20,1},
/*24*/	{25,-1,-1,G_STRING,0x0,0x0,"  Run            ^M ", 0,8,20,1},
/*25*/	{26,-1,-1,G_STRING,0x0,0x8,"--------------------", 0,9,20,1},
/*26*/	{15,-1,-1,G_STRING,0x20,0x0,"  Quit           ^Q ", 0,10,20,1},
};


char ABORTMNSTR[] = "  Abort          ^Q ";
char QUITMNSTR[] = "  Quit           ^Q ";
char ABORTBUTSTR[] = "Abort";
char QUITBUTSTR[] = "Quit ";

static void fix_tree(OBJECT *s,int max)
{
	int i;

	for(i=0; i<=max; i++)
		rsrc_obfix(s,i);
}

void rsrc_init(void)
{
	fix_tree(MAINDIAL,18);
	fix_tree(MAINMENU,26);
}
