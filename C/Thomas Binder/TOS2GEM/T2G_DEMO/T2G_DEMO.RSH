#define M_TITLE1 3
#define M_TITLE2 4
#define M_TITLE3 5
#define M_ABOUT  8
#define M_RUNTTP 17
#define M_RUNTOS 18
#define M_PRINT  20
#define M_DELETE 22
#define M_QUIT   24
#define M_FONT   26
#define M_CURSOR 28
#define M_WRAP   29
#define C_PRGNAM 4
#define C_CLINE1 5
#define C_CLINE2 6
#define C_CLINE3 7
#define C_CLINE4 8
#define C_ABBR   9
#define C_OK     10
#define E_PRGNAM 4
#define E_ERRTXT 5
#define E_OK     6
#define F_HBOX   4
#define F_HEIGHT 5
#define F_UP     6
#define F_DOWN   7
#define F_ABBR   8
#define F_OK     9

char T2G_ENDE[]="[2][TOS2GEM-Demo schon|verlassen?][ Abbruch |OK]";

char T2G_PRNT[]="[1][TOS2GEM-Demo:|Drucker nicht bereit!][ Abbruch |Nochmal]";

char T2G_PLCK[]="[3][TOS2GEM-Demo:|Drucker kann nicht f\201r|Ausgabe ge\224ffnet werden!][ Abbruch ]";

char T2G_INIT[]="[3][TOS2GEM-Demo:|Fehler bei Initialisierung|des Programms!][ Abbruch ]";

char T2G_NOCK[]="[3][TOS2GEM-Demo:|TOS2GEM ist nicht|installiert!][ Abbruch ]";

char T2G_LOCK[]="[3][TOS2GEM-Demo:|TOS2GEM ist zur Zeit|blockiert!][ Abbruch ]";

char T2G_DEL[]="[2][TOS2GEM-Demo:|Ausgabefenster wirklich|l\224schen?][ Abbruch |L\224schen]";

char T2G_WIND[]="[3][TOS2GEM-Demo:|Keine Fenster mehr|frei!][ Abbruch ]";

char T2G_MEM[]="[3][TOS2GEM-Demo:|Nicht gen\201gend Speicher|frei!][ Abbruch ]";

char T2G_NVIS[]="[3][TOS2GEM-Demo:|Arbeitsbereich des Fensters|mu\236 komplett sichtbar sein!][ Abbruch ]";

char T2G_VERS[]="[3][TOS2GEM-Demo:|Es wird mindestens|TOS2GEM vom 03.01.1995|ben\224tigt!][ Abbruch ]";

char T2G_UKWN[]="[3][TOS2GEM-Demo:|init_t2g lieferte eine|unbekannte Fehlernummer|(%d) zur\201ck!][ Abbruch ]";

TEDINFO rs_tedinfo[]={
    "1234567890123456789012345678901234","__________________________________","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",3,6,2,4480,0,-1,35,35,
    "1234567890123456789012345678901234","__________________________________","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",3,6,2,4480,0,-1,35,35,
    "1234567890123456789012345678901234","__________________________________","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",3,6,2,4480,0,-1,35,35,
    "1234567890123456789012","______________________","XXXXXXXXXXXXXXXXXXXXXX",3,6,2,4480,0,-1,23,23};

OBJECT T2G_MENU[]={
    -1,1,6,G_IBOX,0x00,0x00,0x0000L,0,0,80,25,
    6,2,2,G_BOX,0x00,0x00,0x1100L,0,0,80,513,
    1,3,5,G_IBOX,0x00,0x00,0x0000L,2,0,27,769,
    4,-1,-1,G_TITLE,0x00,0x00,(long)" T2G-DEMO",0,0,10,769,
    5,-1,-1,G_TITLE,0x00,0x00,(long)" Datei",10,0,7,769,
    2,-1,-1,G_TITLE,0x00,0x00,(long)" Optionen",17,0,10,769,
    0,7,25,G_IBOX,0x00,0x00,0x0000L,0,769,80,23,
    16,8,15,G_BOX,0x00,0x00,0x00FF1100L,2,0,23,8,
    9,-1,-1,G_STRING,0x00,0x00,(long)"  \232ber TOS2GEM-Demo... ",0,0,23,1,
    10,-1,-1,G_STRING,0x00,0x08,(long)"-----------------------",0,1,23,1,
    11,-1,-1,G_STRING,0x00,0x00,(long)"  Desk Accessory 1 ",0,2,23,1,
    12,-1,-1,G_STRING,0x00,0x00,(long)"  Desk Accessory 2 ",0,3,23,1,
    13,-1,-1,G_STRING,0x00,0x00,(long)"  Desk Accessory 3 ",0,4,23,1,
    14,-1,-1,G_STRING,0x00,0x00,(long)"  Desk Accessory 4 ",0,5,23,1,
    15,-1,-1,G_STRING,0x00,0x00,(long)"  Desk Accessory 5 ",0,6,23,1,
    7,-1,-1,G_STRING,0x00,0x00,(long)"  Desk Accessory 6 ",0,7,23,1,
    25,17,24,G_BOX,0x00,0x00,0x00FF1100L,12,0,24,8,
    18,-1,-1,G_STRING,0x00,0x00,(long)"  .TTP starten...    ^O ",0,0,24,1,
    19,-1,-1,G_STRING,0x00,0x00,(long)"  .TOS starten...   \001^O ",0,1,24,1,
    20,-1,-1,G_STRING,0x00,0x08,(long)"------------------------",0,2,24,1,
    21,-1,-1,G_STRING,0x00,0x00,(long)"  Fenster drucken    ^P ",0,3,24,1,
    22,-1,-1,G_STRING,0x00,0x08,(long)"------------------------",0,4,24,1,
    23,-1,-1,G_STRING,0x00,0x00,(long)"  Fenster l\224schen  ^Del ",0,5,24,1,
    24,-1,-1,G_STRING,0x00,0x08,(long)"------------------------",0,6,24,1,
    16,-1,-1,G_STRING,0x00,0x00,(long)"  Ende               ^Q ",0,7,24,1,
    6,26,29,G_BOX,0x00,0x00,0x00FF1000L,19,0,18,4,
    27,-1,-1,G_STRING,0x00,0x00,(long)"  Fontgr\224\236e... ^Z ",0,0,18,1,
    28,-1,-1,G_STRING,0x00,0x08,(long)"------------------",0,1,18,1,
    29,-1,-1,G_STRING,0x00,0x00,(long)"  Cursor       \007C ",0,2,18,1,
    25,-1,-1,G_STRING,0x20,0x00,(long)"  Wrap         \007W ",0,3,18,1};

OBJECT T2G_INFO[]={
    -1,1,9,G_BOX,0x00,0x10,0x00021100L,0,0,38,16,
    2,-1,-1,G_BUTTON,0x00,0x20,(long)"TOS2GEM-Demo",11,1,16,2,
    3,-1,-1,G_STRING,0x00,0x00,(long)"Eine einfache GEM-Shell  f\201r  TOS-",2,4,34,1,
    4,-1,-1,G_STRING,0x00,0x00,(long)"Programme, die  als  Demonstration",2,5,34,1,
    5,-1,-1,G_STRING,0x00,0x00,(long)"der M\224glichkeiten von TOS2GEM die-",2,6,34,1,
    6,-1,-1,G_STRING,0x00,0x00,(long)"nen soll.",2,7,9,1,
    7,-1,-1,G_STRING,0x00,0x00,(long)"Geschrieben 1994 - 1995 in  Pure C",2,9,34,1,
    8,-1,-1,G_STRING,0x00,0x00,(long)"von Thomas Binder  mit  Hilfe  der",2,10,34,1,
    9,-1,-1,G_STRING,0x00,0x00,(long)"TOS2GEM-Library von Dirk Klemmt.",2,11,32,1,
    0,-1,-1,G_BUTTON,0x27,0x00,(long)"OK",15,14,8,1};

OBJECT T2G_CMDL[]={
    -1,1,10,G_BOX,0x00,0x10,0x00021100L,0,0,38,13,
    2,-1,-1,G_STRING,0x00,0x00,(long)"Kommandozeile",2,1,13,1,
    3,-1,-1,G_IBOX,0x00,0x00,0x00011100L,2,2,13,256,
    4,-1,-1,G_STRING,0x00,0x00,(long)"f\201r",2,3,3,1,
    5,-1,-1,G_STRING,0x00,0x00,(long)"abcdefghijklmnopqrstuvwxyzabc:",6,3,30,1,
    6,-1,-1,G_FTEXT,0x08,0x00,(long)&rs_tedinfo[0],2,5,34,1,
    7,-1,-1,G_FTEXT,0x08,0x00,(long)&rs_tedinfo[1],2,6,34,1,
    8,-1,-1,G_FTEXT,0x08,0x00,(long)&rs_tedinfo[2],2,7,34,1,
    9,-1,-1,G_FTEXT,0x08,0x00,(long)&rs_tedinfo[3],2,8,22,1,
    10,-1,-1,G_BUTTON,0x05,0x00,(long)"Abbruch",16,11,9,1,
    0,-1,-1,G_BUTTON,0x27,0x00,(long)"OK",27,11,9,1};

OBJECT T2G_ERR[]={
    -1,1,6,G_BOX,0x00,0x10,0x00021100L,0,0,38,11,
    2,-1,-1,G_STRING,0x00,0x00,(long)"Fehler aufgetreten!",2,1,19,1,
    3,-1,-1,G_IBOX,0x00,0x00,0x00011100L,2,2,19,256,
    4,-1,-1,G_STRING,0x00,0x00,(long)"Nach Aufruf von",2,3,15,1,
    5,-1,-1,G_STRING,0x00,0x00,(long)"123456789012345678901234567890123:",2,4,34,1,
    6,-1,-1,G_STRING,0x00,0x00,(long)"1234567890123456789012345678901234",2,6,34,1,
    0,-1,-1,G_BUTTON,0x27,0x00,(long)"OK",27,9,9,1};

OBJECT T2G_FONT[]={
    -1,1,9,G_BOX,0x00,0x10,0x00021100L,0,0,33,8,
    2,-1,-1,G_STRING,0x00,0x00,(long)"Fontgr\224\236e bestimmen",2,1,19,1,
    3,-1,-1,G_IBOX,0x00,0x00,0x00011100L,2,2,19,256,
    4,-1,-1,G_STRING,0x00,0x00,(long)"Zeichenh\224he in Punkt:",2,3,21,1,
    6,5,5,G_BOX,0x00,0x00,0x11F0L,24,3,2,1,
    4,-1,-1,G_STRING,0x00,0x00,(long)"10",0,0,2,1,
    7,-1,-1,G_BOXCHAR,0x40,0x00,0x01FF1100L,27,3,2,1,
    8,-1,-1,G_BOXCHAR,0x40,0x00,0x02FF1100L,29,3,2,1,
    9,-1,-1,G_BUTTON,0x05,0x00,(long)"Abbruch",11,6,9,1,
    0,-1,-1,G_BUTTON,0x27,0x00,(long)"OK",22,6,9,1};

static void fix_tree(OBJECT *tree,WORD nobjs)
{
    WORD i;

    for (i=0;i<nobjs;i++)
        rsrc_obfix(tree,i);
}

void rsrc_init(void)
{
    fix_tree(T2G_MENU,30);
    fix_tree(T2G_INFO,10);
    fix_tree(T2G_CMDL,11);
    fix_tree(T2G_ERR,7);
    fix_tree(T2G_FONT,10);
}
