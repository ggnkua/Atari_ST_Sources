/*********************************************************************/
/* ST Star-Raiders GEM Resource File				     */
/*	Copyright 1986 ATARI Corp.				     */
/* Modified from Mike Schmal's Original Menu Resource File	     */
/*********************************************************************/

#define COPYRIGHT	8
#define COPY_OK		8

#define	START		17
#define	COMMANDER	19
#define	WARRIOR		20
#define	PILOT		21
#define	NOVICE		22
#define	QUIT		24

#define HIGHSCOR	26
#define	HIGH_OK		17

#define LASTSCOR	27
#define	LAST_OK		2


OBJECT menu[] = {
-1,1,6,G_IBOX, NONE, NORMAL,0x0L,0,0,320,200,
6,2,2,G_BOX, NONE, NORMAL,0x1100L,0,0,320,11,
1,3,5,G_IBOX, NONE, NORMAL,0x0L,16,0,184,11,
4, -1, -1, G_TITLE, NONE, NORMAL, " Desk ",0,0,48,11,
5, -1, -1, G_TITLE, NONE, NORMAL, " Options ",48,0,72,11,
2, -1, -1, G_TITLE, NONE, NORMAL, " Scores ",120,0,64,11,
0,7,25,G_IBOX, NONE, NORMAL,0x0L,0,11,320,72,

/* MENU1 */
16,8,15,G_BOX, NONE, NORMAL ,0xFF1100L,17,0,160,64,
9,-1,-1,G_STRING, NONE, NORMAL, "  Star Raiders Info ",0,0,160,8,
10,-1,-1,G_STRING, NONE, DISABLED, "--------------------",0,8,160,8,
11,-1,-1,G_STRING, NONE, DISABLED, 0x0L,0,16,160,8,
12,-1,-1,G_STRING, NONE, DISABLED, 0x0L,0,24,160,8,
13,-1,-1,G_STRING, NONE, DISABLED, 0x0L,0,32,160,8,
14,-1,-1,G_STRING, NONE, DISABLED, 0x0L,0,40,160,8,
15,-1,-1,G_STRING, NONE, DISABLED, 0x0L,0,48,160,8,
7,-1,-1,G_STRING, NONE, DISABLED, 0x0L,0,56,160,8,

/* MENU 2 */
25,17,24,G_BOX, NONE, NORMAL ,0xFF1100L,65,0,96,64,
18,-1,-1,G_STRING, NONE, NORMAL, "  Start",0,0,96,8,
19,-1,-1,G_STRING, NONE, DISABLED, "------------",0,8,96,8,
20,-1,-1,G_STRING, NONE, NORMAL, "  Commander ",0,16,96,8,
21,-1,-1,G_STRING, NONE, NORMAL, "  Warrior",0,24,96,8,
22,-1,-1,G_STRING, NONE, NORMAL, "  Pilot",0,32,96,8,
23,-1,-1,G_STRING, NONE, NORMAL | CHECKED, "  Novice",0,40,96,8,
24,-1,-1,G_STRING, NONE, DISABLED, "------------",0,48,96,8,
16,-1,-1,G_STRING, NONE, NORMAL, "  Quit",0,56,96,8,

/* MENU 3 */
6,26,27,G_BOX, NONE, NORMAL,0xFF1100L,137,0,112,16,
27,-1,-1,G_STRING, NONE, NORMAL, "  High Scores ",0,0,112,8,
25,-1,-1,G_STRING, NONE, NORMAL, "  Last Score ",0,8,112,8,
};


OBJECT copy_dia[] = {
-1,1,8, G_BOX, NONE, NORMAL | OUTLINED, 0x21000L,0,0,240,88,
2, -1, -1, G_STRING, NONE, NORMAL, "STAR RAIDERS" ,72,8,96,8,
3, -1, -1, G_STRING, NONE, NORMAL, "Copyright 1986 ATARI Corp." ,16,16,208,8,
4, -1, -1, G_STRING, NONE, NORMAL, "----------------------------" ,8,24,224,8,
5, -1, -1, G_STRING, NONE, NORMAL, "Designed & Programmed By:" ,16,32,200,8,
6, -1, -1, G_STRING, NONE, NORMAL, "Rob Zdybel" ,24,40,80,8,
7, -1, -1, G_STRING, NONE, NORMAL, "Graphics & Animation By:" ,16,48,200,8,
8, -1, -1, G_STRING, NONE, NORMAL, "Jerome Domurat" ,24,56,112,8,
0, -1, -1, G_BUTTON, 0x27, NORMAL, " OK ",104,72,32,10,
};

OBJECT high_dia[] = {
-1,1,17, G_BOX, NONE, NORMAL | OUTLINED, 0x21000L,0,0,312,160,
2, -1, -1, G_STRING, NONE, NORMAL, "STAR RAIDERS HALL OF FAME" ,56,6,200,8,
3, -1, -1, G_STRING, NONE, NORMAL, "-------------------------" ,56,16,200,8,
4, -1, -1, G_STRING, NONE, NORMAL, "    Name   Level        Rank" ,4,24,304,8,
5, -1, -1, G_STRING, NONE, NORMAL, "--------------------------------------" ,4,32,312,8,
6, -1, -1, G_STRING, NONE, NORMAL, 0x0L ,4,40,312,8,
7, -1, -1, G_STRING, NONE, NORMAL, 0x0L ,4,48,312,8,
8, -1, -1, G_STRING, NONE, NORMAL, 0x0L ,4,56,312,8,
9, -1, -1, G_STRING, NONE, NORMAL, 0x0L ,4,64,312,8,
10, -1, -1, G_STRING, NONE, NORMAL,0x0L ,4,72,312,8,
11, -1, -1, G_STRING, NONE, NORMAL,0x0L ,4,80,312,8,
12, -1, -1, G_STRING, NONE, NORMAL,0x0L ,4,88,312,8,
13, -1, -1, G_STRING, NONE, NORMAL,0x0L ,4,96,312,8,
14, -1, -1, G_STRING, NONE, NORMAL,0x0L ,4,104,312,8,
15, -1, -1, G_STRING, NONE, NORMAL,0x0L ,4,112,312,8,
16, -1, -1, G_STRING, NONE, NORMAL,0x0L ,4,120,312,8,
17, -1, -1, G_STRING, NONE, NORMAL,0x0L ,4,128,312,8,
0, -1, -1, G_BUTTON, 0x27, NORMAL, " WELL DONE ",116,144,88,10,
};

OBJECT last_dia[] = {
-1,1,2, G_BOX, NONE, NORMAL | OUTLINED, 0x21000L,0,0,248,40,
2, -1, -1, G_STRING, NONE, NORMAL, 0x0L ,4,6,240,8,
0, -1, -1, G_BUTTON, 0x27, NORMAL, " OK ",108,24,32,10,
};
