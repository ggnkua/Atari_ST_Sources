/*#include <aes.h>*/
#include "global.h"
#include "titleimg.c"

#define	WORD	int
#define LONG	long


struct _popup_menu popup_app_menu[MAX_BENUTZER_POPUP];


/* ******************************************************************* */


CICON rs_cicon[] =
{ 4, NULL, NULL, NULL, NULL, NULL
};

CICONBLK rs_ciconblk[] =
{ NULL, NULL, "\0\000", 0x1000|'\0',
   14,  21,   0,   0,  16,  16,  0,  0,   0,   0, &rs_cicon[0]
};

OBJECT *apppopup;
OBJECT apppopup_magic[] =
{
	{-1,1,16,G_BOX,FL3DBAK,OS_NORMAL,(long)0x00ff1100L,0,0,28,16},
	{2,-1,-1,G_STRING,FL3DBAK,OS_DISABLED,(long)						"  Name.......               ",0,0,28,1},
	{3,-1,-1,G_STRING,FL3DBAK,OS_NORMAL,(long)							"  Memory                    ",0,1,28,1},
	{4,-1,-1,G_STRING,FL3DBAK,OS_DISABLED,(long)						"----------------------------",0,2,28,1},
	{5,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Terminate1                ",0,3,28,1},
	{6,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Quit                      ",0,4,28,1},
	{7,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Hide other                ",0,5,28,1},
	{8,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Hide                      ",0,6,28,1},
	{9,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Show all                  ",0,7,28,1},
	{10,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Show                      ",0,8,28,1},
	{11,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Freezy                    ",0,9,28,1},
	{12,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Unfreezy                  ",0,10,28,1},
	{13,-1,-1,G_STRING,FL3DBAK,OS_DISABLED,(long)					"----------------------------",0,11,28,1},
	{14,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Vorbergehend verstecken  ",0,12,28,1},
	{15,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Dauerhaft verstecken      ",0,13,28,1},
	{16,-1,-1,G_STRING,FL3DBAK,OS_DISABLED,(long)					"----------------------------",0,14,28,1},
	{0,-1,-1,G_STRING,OF_LASTOB|FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Fenster                   ",0,15,28,1},
};

OBJECT apppopup_mint[] =
{
	{-1,1,13,G_BOX,FL3DBAK,OS_NORMAL,(long)0x00ff1100L,0,0,18,13},
	{2,-1,-1,G_STRING,FL3DBAK,OS_DISABLED,(long)						"  Name            ",0,0,18,1},
	{3,-1,-1,G_STRING,FL3DBAK,OS_NORMAL,(long)							"  Memory2         ",0,1,18,1},
	{4,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Priority      ->",0,2,18,1},
	{5,-1,-1,G_STRING,FL3DBAK,OS_DISABLED,(long)						"------------------------------",0,3,18,1},
	{6,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Kill1           ",0,4,18,1},
	{7,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Quit1           ",0,5,18,1},
	{8,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Top             ",0,6,18,1},
	{9,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Hide other1     ",0,7,18,1},
	{10,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Hide1           ",0,8,18,1},
	{11,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Show1           ",0,9,18,1},
	{12,-1,-1,G_STRING,FL3DBAK,OS_DISABLED,(long)					"--Do not show-----------------",0,10,18,1},
	{13,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Temproraly3     ",0,11,18,1},
	{0,-1,-1,G_STRING,OF_LASTOB|FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)	"  Permanently3    ",0,12,18,1},
};

OBJECT startpopup[] =
{
	{-1,1,11,G_BOX,FL3DBAK,OS_NORMAL,(long)0x00ff1100L,0,0,26,11},
	{2,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)"  Info...              ^I ",0,0,26,1},
	{3,-1,-1,G_STRING,FL3DBAK,OS_DISABLED,(long)"-------------------",0,1,26,1},
	{4,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)"  Starten...           ^O ",0,2,26,1},
	{5,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)"  Zeige alles             ",0,3,26,1},
	{6,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)"  Lese .SET neu           ",0,4,26,1},
	{7,-1,-1,G_STRING,FL3DBAK,OS_DISABLED,(long)"-------------------",0,5,26,1},
	{8,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)"  Optionen...             ",0,6,26,1},
	{9,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)"  Beenden...              ",0,7,26,1},
	{10,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)"  Ausschalten             ",0,8,26,1},
	{11,-1,-1,G_STRING,FL3DBAK,OS_DISABLED,(long)"-------------------",0,9,26,1},
	{0,-1,-1,G_STRING,OF_LASTOB|FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)"  Hilfe...    Help ",0,10,26,1},
};

OBJECT monthspopup[] =
{
	{-1,1,12,G_BOX,FL3DBAK,OS_NORMAL,(long)0x00ff1100L,0,0,13,12},
	{2,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" Januar      ",0,0,13,1},
	{3,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" Februar     ",0,1,13,1},
	{4,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" M„rz        ",0,2,13,1},
	{5,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" April       ",0,3,13,1},
	{6,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" Mai         ",0,4,13,1},
	{7,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" Juni        ",0,5,13,1},
	{8,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" Juli        ",0,6,13,1},
	{9,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" August      ",0,7,13,1},
	{10,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" September   ",0,8,13,1},
	{11,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" Oktober     ",0,9,13,1},
	{12,-1,-1,G_STRING,FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" November    ",0,10,13,1},
	{0,-1,-1,G_STRING,OF_LASTOB|FL3DBAK|OF_SELECTABLE,OS_NORMAL,(long)" Dezember    ",0,11,13,1},
};


OBJECT popup_app_icon[] =
{
	{-1,1,4,G_BOX,FL3DBAK,OS_NORMAL,(long)0x00ff1100L,0,0,0x0f,4},
	{2,-1,-1,G_STRING,FL3DBAK,OS_NORMAL,(long)										"  L”sche1a     ",0,0,0x0f,1},
	{3,-1,-1,G_STRING,FL3DBAK,OS_NORMAL,(long)										"  L”sche       ",0,1,0x0f,1},
	{4,-1,-1,G_STRING,FL3DBAK,OS_NORMAL,(long)										"  Neue Icon    ",0,2,0x0f,1},
	{0,-1,-1,G_STRING,OF_LASTOB|FL3DBAK,OS_NORMAL,(long)						"  Lokalisation ",0,3,0x0f,1},
};



/* *******************************************	*/
/* **** KALENDARZ													****	*/
/* *******************************************	*/


TEDINFO rs_tedinfo_calender[] =
{ "Januar  , 2004 xxxx  ",	"\0",	"\0",	IBM  , 0, TE_CNTR , 0x1180, 0, -1, 21, 1,					/* Objekt 1	*/
  "Mo  Di  Mi  Do  Fr  Sa  So y",	"\0",	"\0",	IBM  , 0, TE_LEFT , 0x1180, 0, -1, 27, 1,		/* Objekt 4	*/
  " 11  Di  Mi  Do  Fr  Sa  Soy",	"\0",	"\0",	IBM  , 0, TE_LEFT , 0x1180, 0, -1, 27, 1,		/* Objekt 5	*/
  " 22  Di  Mi  Do  Fr  Sa  Soy",	"\0",	"\0",	IBM  , 0, TE_LEFT , 0x1180, 0, -1, 27, 1,		/* Objekt 6	*/
  " 33  Di  Mi  Do  Fr  Sa  Soy",	"\0",	"\0",	IBM  , 0, TE_LEFT , 0x1180, 0, -1, 27, 1,		/* Objekt 7	*/
  " 44  Di  Mi  Do  Fr  Sa  Soy",	"\0",	"\0",	IBM  , 0, TE_LEFT , 0x1180, 0, -1, 27, 1,		/* Objekt 8	*/
  " 55  Di  Mi  Do  Fr  Sa  Soy",	"\0",	"\0",	IBM  , 0, TE_LEFT , 0x1180, 0, -1, 27, 1		/* Objekt 9	*/
};

OBJECT calender[] =
{ 
  /******** Tree 0 FORM2 ****************************************************/
	-1,1,5,G_BOX,FL3DBAK, OS_OUTLINED,(LONG)0x00001100L,0x0000, 0x0000, 0x061B, 0x0608,										/* Object 0  */
  2, -1, -1, G_BOXTEXT, FL3DBAK|FLAGS10, OS_NORMAL, (LONG)&rs_tedinfo_calender[0], 0x0404, 0x0400, 0x000F, 0x0001,	   /* Object 1  */
  3, -1, -1, G_BUTTON, FL3DBAK|OF_SELECTABLE|OF_EXIT, OS_NORMAL, (LONG)"<<", 0x0500, 0x0400, 0x0002, 0x0001,		/* Object 2  */
	4, -1, -1, G_BUTTON, FL3DBAK|OF_SELECTABLE|OF_EXIT, OS_NORMAL, (LONG)">>", 0x0319, 0x0400, 0x0002, 0x0001,		/* Object 3  */
	5, -1, -1, G_TEXT, FL3DBAK, OS_NORMAL, (LONG)&rs_tedinfo_calender[1], 0x0200, 0x0B01, 0x001B, 0x0001,	/* Object 4  */
	0, -1, -1, G_TEXT, OF_LASTOB|FL3DBAK, OS_NORMAL, (LONG)&rs_tedinfo_calender[2], 0x0200, 0x0203, 0x001B, 0x0006,	/* Object 5  */
	7, -1, -1, G_TEXT, FL3DBAK, OS_NORMAL, (LONG)&rs_tedinfo_calender[3], 0x0200, 0x0204, 0x001B, 0x0001,	/* Object 6  */
	8, -1, -1, G_TEXT, FL3DBAK, OS_NORMAL, (LONG)&rs_tedinfo_calender[4], 0x0200, 0x0205, 0x001B, 0x0001,	/* Object 7  */
	9, -1, -1, G_TEXT, FL3DBAK, OS_NORMAL, (LONG)&rs_tedinfo_calender[5], 0x0200, 0x0206, 0x001B, 0x0001,	/* Object 8  */
	0, -1, -1, G_TEXT, OF_LASTOB|FL3DBAK, OS_NORMAL, (LONG)&rs_tedinfo_calender[6], 0x0200, 0x0207, 0x001B, 0x0001	/* Object 9  */
};


OBJECT icon1[]=
{ 
  /******** Tree 0 FORM2 ****************************************************/
        -1,        1,        1, G_BOX             ,   /* Object 0  */
  NONE, OS_OUTLINED, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0302, 0x0501,
         0,       -1,       -1, G_CICON           ,   /* Object 1  */
  NONE, OS_NORMAL, (LONG)&rs_ciconblk[0],
  0x0000, 0x0000, 0x0302, 0x0501
};


TEDINFO rs_tedinfo = {"MyTask","","",SMALL,0,TE_CNTR,0x1100,0,-1,6,1};

TEDINFO rs_tedinfo_appl01 = { NULL,	"\0",	"\0",	IBM  , 0, TE_CNTR , 0x1180, 0, -1, 9, 1	};


OBJECT button={
	10,-1,-1,G_BOXTEXT,OF_SELECTABLE|OF_EXIT|FLAGS10,OS_NORMAL,(long)&rs_tedinfo_appl01,0x052A, 0x0900, 0x0008, 0x0001
	};

OBJECT icon={
       0,       -1,       -1, G_CICON           ,   /* Object 1  */
  NONE, OS_NORMAL, (LONG)&rs_ciconblk[0],
  0x0000, 0x0000, 0x0302, 0x0501
};

/*
----------------------------------------------------------------
|xxxxx  I  I   O O O O                             I I  zzzzzz |
----------------------------------------------------------------
| |     |  |   | | | |                             | |   |
| |     |  |   | | | |                             | |   +-> zegarek - nr 3 (TIME_OBJECT)
| |     |  |   | | | |                             | +-> separator - nr 2 (TIME_SEPARATOR)
| |     |  |   | | | |                             +-> separator - nr 6 (SEPARATOR_3)
| |     |  |   | | | +-> przyciski - max nr 88
| |     |  |   | | +->
| |     |  |   | +->
| |     |  |   +-> przyciski - min nr 8 (APPLICATION_1)
| |     |  +-> separator - nr 5 (SEPARATOR_2)
| |     +-> separator - nr 4 (SEPARATOR_1)
| +-> Przycisk - nr 1 (START_BUTTON)
+-> bigbutton - nr 0
*/


OBJECT bigbutton[] =
	{{-1,1,7,G_BOX,FL3DBAK,OS_NORMAL,(long)0x00001100L,0x0000, 0x0000, 640, 0x0801},
	{2,-1,-1,G_BUTTON,OF_SELECTABLE|OF_DEFAULT|OF_EXIT|FL3DACT,OS_DISABLED,(long)"MyTask",0x0403, 0x0400, 0x0008, 0x0001},			/* Przycisk															*/
	{3,-1,-1,G_BOX,NONE,OS_NORMAL,(long)"",0x0503, 0x0400, 0x0001, 0x0001},																						/* Separator z lewej strony zegarka	3		*/
	{4,-1,-1,G_TEXT|OF_EXIT|FLAGS10,OS_NORMAL,0L,0x052A, 0x0900, 0x0005, 0x0801-3},														/* Zegarek															*/

	{5,-1,-1,G_BOX,NONE,OS_NORMAL,(long)"",0x0503, 0x0400, 0x0001, 0x0001},																						/* Separator z prawej strony przycisku	*/
	{6,-1,-1,G_BOX,NONE,OS_NORMAL,(long)"",0x0503, 0x0400, 0x0001, 0x0001},																						/* Separator srodkowy-lewy							*/
	{7,-1,-1,G_BOX,NONE,OS_NORMAL,(long)"",0x0503, 0x0400, 0x0001, 0x0001},																						/* Separator srodkowy-prawy							*/

	{8,-1,-1,G_BUTTON,OF_SELECTABLE|OF_EXIT|FL3DACT,OS_DISABLED,(long)"a",0x0403, 0x0400, 0x0008, 0x0001},						/* Obiekt specjalny lewy								*/

	{0,-1,-1,G_BUTTON,OF_LASTOB|OF_SELECTABLE|OF_EXIT|FL3DACT,OS_NORMAL,(long)"a",0x0403, 0x0400, 0x0008, 0x0001},	/* Chowanie MyTask											*/

/* Przyciski aplikacji od 9 do 50)		*/
	{-1}, {0},
	{0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0},
	{0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, 
	{0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0},
	{0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {-1},								/* Tyle moze byc przyciskow aplikacji	(do obiektu nr 50 (42 obiekty)) */

	{-2}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0},								/* Ikonki aplikacji (od 51 do 70)	*/
	{0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {-2},

	{-3}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0},								/* Ikonki systemowe (od 71 do 90)	*/
	{0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {0}, {-3}
};


/* ************************************************************	*/
/* INFO DIALOG																									*/
/* ************************************************************	*/

TEDINFO tedinfo_info[] =
{ "MyTask",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 7, 1,
  "v.0.45",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 7, 1,
  "28.04.2004",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 11, 1,
  "Copyright by Dr. R. Kawecki, 2004",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 34, 1,
  "MyTask is based on StartMeUp",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 29, 1,
  "by Thomas Much (1996-1998)",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 27, 1,
  "MyTask is freeware!",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1480, 0, -1, 20, 1,
  "Any comments, ideas, bug reports send to:",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 42, 1,
  "rafaelkawecki@web.de",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1480, 0, -1, 20, 1,
  "Thanks for testing goes to:",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 28, 1,
  "Sascha Uhlig",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 13, 1,
  "http://mypdf.atari-users.net/mytask/",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1480, 0, -1, 37, 1,
  "GEMLib version: 00.00.00 ",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 26, 1
};

extern CICON rs_cicon[];
extern CICONBLK rs_ciconblk[];

OBJECT object_info[] =
{ 
  /******** Tree 0 TITLE ****************************************************/
        -1,        1,       15, G_BOX             ,   /* Object 0  */
  FLAGS10, OS_NORMAL, (LONG)0x00011100L,
  0x0000, 0x0000, 0x022E, 0x0210,
         2,       -1,       -1, G_TEXT            ,   /* Object 1  */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[0],
  0x0002, 0x0800, 0x0006, 0x0001,
         3,       -1,       -1, G_TEXT            ,   /* Object 2  */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[1],
  0x000A, 0x0B00, 0x0006, 0x0001,
         4,       -1,       -1, G_TEXT            ,   /* Object 3  */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[2],
  0x0010, 0x0B00, 0x0407, 0x0001,
         5,       -1,       -1, G_TEXT            ,   /* Object 4  */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[3],
  0x0002, 0x0002, 0x0618, 0x0001,
         6,       -1,       -1, G_TEXT            ,   /* Object 5  */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[4],
  0x0501, 0x0007, 0x0015, 0x0001,
         7,       -1,       -1, G_TEXT            ,   /* Object 6  */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[5],
  0x0501, 0x0008, 0x0413, 0x0001,
         8,       -1,       -1, G_TEXT            ,   /* Object 7  */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[6],
  0x010A, 0x0006, 0x020E, 0x0001,
         9,       -1,       -1, G_TEXT            ,   /* Object 8  */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[7],
  0x0501, 0x000C, 0x061E, 0x0001,
        10,       -1,       -1, G_TEXT            ,   /* Object 9  */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[8],
  0x0108, 0x000D, 0x020E, 0x0001,
        11,       -1,       -1, G_TEXT            ,   /* Object 10  */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[9],
  0x0501, 0x0809, 0x0214, 0x0001,
  INFO_OK         ,       -1,       -1, G_TEXT            ,   /* Object 11  */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[10],
  0x010C, 0x080A, 0x0009, 0x0001,
  INFO_URL        ,       -1,       -1, G_BUTTON          ,   /* Object 12 INFO_OK */
  OF_SELECTABLE|OF_DEFAULT|OF_EXIT|OF_TOUCHEXIT|FLAGS10, OS_NORMAL, (LONG)"OK",
  0x0118, 0x080E, 0x0008, 0x0001,
  INFO_GEMLIB   ,       -1,       -1, G_TEXT            ,   /* Object 13 INFO_URL */
  OF_SELECTABLE|OF_EXIT|FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[11],
  0x0601, 0x0804, 0x001B, 0x0001,
  15,       -1,       -1, G_TEXT            ,   /* Object 14 TIINFO_GEMLIB */
  FLAGS10, OS_NORMAL, (LONG)&tedinfo_info[12],
  0x0701, 0x0103, 0x0612, 0x0001,
	/* Rysunek tytulowy w pliku titleimg.c	*/
         0,       -1,       -1, G_CICON           ,   /* Object 15  */
  OF_LASTOB, OS_NORMAL, (LONG)&rs_ciconblk_title[0],
  0x0720, 0x0D01, 0x000C, 0x000A

};

/* ************************************************************	*/
