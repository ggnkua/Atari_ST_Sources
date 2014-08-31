/* Resourceheader-Datei zu GAMEFIX.RSC */

#define DCACHE   5
#define ICACHE   7
#define CPU8MHZ  9
#define BLIT8MHZ 11
#define STEBUS   13
#define SPEAKER  15
#define SCRADR   17
#define TIMERA   20
#define MFPI7    22
#define RAM512K  25
#define RAM1MB   27
#define RAM2MB   29
#define RAM4MB   31
#define DOWN     34
#define SLIDER   35
#define VOLUME   36
#define UP       37
#define LIVE     38
#define SAVE     40
#define OK       41
#define ABBRUCH  42
#define W1OK     10
#define W1ABB    11
#define W2OK     9
#define W2ABB    10
#define W3OK     12
#define W3ABB    13
#define W4OK     8
#define W4ABB    9
#define BOOTPRG  3
#define SETPRG   5
#define SAVEOK   7
#define SAVEABB  8

char BOOTEN[]="[2][Neubooten oder nur  \232ber-|nehmen der Einstellungen?][Booten| \232bernehmen ]";

char RESET[]="[1][Es wird jetzt ein|Warmstart (Reset)|ausgel\224st!][OK| Abbruch ]";

char STOSONLY[]="[1][Bitte nur mit Single-|tasking-TOS benutzen!][ Abbruch ]";

char NOSTMODE[]="[1][F\201r das einmalige Einstellen|der alten  Bildschirmadresse|mu\236 ein Kompatibilit\204tsmodus|aktiv sein!][ Abbruch ]";

char NORAM[]="[1][Das Programm liegt an einer zu|hohen  Speicheradresse.  Bitte|alle Accessories und AUTO-Ord-|ner-Programme entfernen!][ Abbruch ]";

char DISKERR[]="[3][Beim Speichern ist ein|Fehler aufgetreten!][ Abbruch ]";

char LOADONE[]="[2][Soll das Einstell-|programm ein  wei-|teres    Programm|nachladen?][Ja| Nein ]";

char FEXISTS[]="[2][Die Datei existiert|bereits.  Soll  sie|\201berschrieben  wer-|den?][Ja| Nein ]";

char NOFALCON[]="[1][GAMEFIX l\204uft nur auf einem|Falcon030!][ Abbruch ]";

TEDINFO rs_tedinfo[]={
    "GAMEFIX V1.00","","",3,28516,2,4352,30066,-1,14,1,
    "von Thomas Binder","","",5,28516,2,4352,30066,-1,18,1,
    "00","","",3,6,2,4480,0,-1,3,1};

OBJECT MAINDIAL[]={
    -1,1,42,G_BOX,0x00,0x10,0x00021100L,0,0,40,22,
    4,2,3,G_BOX,0x00,0x30,0x00FE1100L,2,1,36,2,
    3,-1,-1,G_TEXT,0x00,0x00,(long)&rs_tedinfo[0],0,0,36,1,
    1,-1,-1,G_TEXT,0x00,0x00,(long)&rs_tedinfo[1],0,1,36,1,
    5,-1,-1,G_STRING,0x00,0x00,(long)"Einstellungen:",2,4,14,1,
    6,-1,-1,0xFF00|G_BOX,0x40,0x03,0x00011171L,2,5,2,1,
    7,-1,-1,G_STRING,0x40,0x00,(long)"Datencache aktiv",5,5,16,1,
    8,-1,-1,0xFF00|G_BOX,0x40,0x03,0x00011171L,2,6,2,1,
    9,-1,-1,G_STRING,0x40,0x00,(long)"Befehlscache aktiv",5,6,18,1,
    10,-1,-1,0xFF00|G_BOX,0x40,0x01,0x00011171L,2,7,2,1,
    11,-1,-1,G_STRING,0x40,0x00,(long)"68030 mit 
    8MHz",5,7,14,1,
    12,-1,-1,0xFF00|G_BOX,0x40,0x01,0x00011171L,2,8,2,1,
    13,-1,-1,G_STRING,0x40,0x00,(long)"BLiTTER mit 
    8MHz",5,8,16,1,
    14,-1,-1,0xFF00|G_BOX,0x40,0x01,0x00011171L,2,9,2,1,
    15,-1,-1,G_STRING,0x40,0x00,(long)"ST(E)-Busmodus",5,9,12,1,
    16,-1,-1,0xFF00|G_BOX,0x40,0x01,0x00011171L,2,10,2,1,
    17,-1,-1,G_STRING,0x40,0x00,(long)"Interner Lautsprecher an",5,10,24,1,
    18,-1,-1,0xFF00|G_BOX,0x40,0x03,0x00011171L,2,11,2,1,
    19,-1,-1,G_STRING,0x40,0x00,(long)"alte Bildschirmadresse",5,11,22,1,
    20,-1,-1,G_STRING,0x00,0x00,(long)"DMA-Sound-Interrupt \201ber:",2,12,25,1,
    21,-1,-1,0xFF00|G_BOX,0x40,0x03,0x00011171L,2,13,2,1,
    22,-1,-1,G_STRING,0x40,0x00,(long)"Timer A",5,13,7,1,
    23,-1,-1,0xFF00|G_BOX,0x40,0x01,0x00011171L,14,13,2,1,
    24,-1,-1,G_STRING,0x40,0x00,(long)"MFP-Interrupt 7",17,13,15,1,
    25,-1,-1,G_STRING,0x00,0x00,(long)"Ramgr\224\236e:",2,14,9,1,
    26,-1,-1,0xFF00|G_BOX,0x11,0x00,0x00011101L,2,15,2,1,
    27,-1,-1,G_STRING,0x40,0x00,(long)"512K",5,15,4,1,
    28,-1,-1,0xFF00|G_BOX,0x11,0x00,0x00011101L,11,15,2,1,
    29,-1,-1,G_STRING,0x40,0x00,(long)"1 MB",14,15,4,1,
    30,-1,-1,0xFF00|G_BOX,0x11,0x00,0x00011101L,20,15,2,1,
    31,-1,-1,G_STRING,0x40,0x00,(long)"2 MB",23,15,4,1,
    32,-1,-1,0xFF00|G_BOX,0x11,0x00,0x00011101L,29,15,2,1,
    33,-1,-1,G_STRING,0x40,0x00,(long)"4 MB",32,15,4,1,
    34,-1,-1,G_STRING,0x00,0x00,(long)"Vorgew\204hlte Lautst\204rke:",2,16,23,1,
    35,-1,-1,G_BOXCHAR,0x40,0x00,0x04FF1180L,2,17,2,1,
    37,36,36,G_BOX,0x40,0x00,0x00FF1191L,5,17,18,1,
    35,-1,-1,G_BOXTEXT,0x40,0x00,(long)&rs_tedinfo[2],0,0,3,1,
    38,-1,-1,G_BOXCHAR,0x40,0x00,0x03FF1180L,24,17,2,1,
    39,-1,-1,0xFF00|G_BOX,0x40,0x03,0x00011171L,28,17,2,1,
    40,-1,-1,G_STRING,0x40,0x00,(long)"live",31,17,4,1,
    41,-1,-1,G_BUTTON,0x05,0x00,(long)"Speichern",2,20,11,1,
    42,-1,-1,G_BUTTON,0x07,0x00,(long)"OK",17,20,9,1,
    0,-1,-1,G_BUTTON,0x25,0x00,(long)"Abbruch",29,20,9,1};

OBJECT WARNING1[]={
    -1,1,11,G_BOX,0x00,0x10,0x00021100L,0,0,40,16,
    2,-1,-1,G_STRING,0x00,0x00,(long)"VORSICHT!",2,1,9,1,
    3,-1,-1,G_STRING,0x00,0x00,(long)"Diese  Einstellung  erfordert   eine",2,3,36,1,
    4,-1,-1,G_STRING,0x00,0x00,(long)"Routine im einem  nicht  gesch\201tzten",2,4,36,1,
    5,-1,-1,G_STRING,0x00,0x00,(long)"Bereich des Speichers, es kann  also",2,5,36,1,
    6,-1,-1,G_STRING,0x00,0x00,(long)"zum  Absturz  kommen,  wenn   dieser",2,6,36,1,
    7,-1,-1,G_STRING,0x00,0x00,(long)"eventuell \201berschrieben wird!",2,7,29,1,
    8,-1,-1,G_STRING,0x00,0x00,(long)"Au\236erdem kann  der  PMMU-Baum  nicht",2,8,36,1,
    9,-1,-1,G_STRING,0x00,0x00,(long)"verschoben werden!",2,9,18,1,
    10,-1,-1,G_STRING,0x00,0x00,(long)"Trotzdem weitermachen?",2,11,22,1,
    11,-1,-1,G_BUTTON,0x07,0x00,(long)"Weiter",17,14,9,1,
    0,-1,-1,G_BUTTON,0x25,0x00,(long)"Abbruch",29,14,9,1};

OBJECT WARNING2[]={
    -1,1,10,G_BOX,0x00,0x10,0x00021100L,0,0,40,15,
    2,-1,-1,G_STRING,0x00,0x00,(long)"VORSICHT!",2,1,9,1,
    3,-1,-1,G_STRING,0x00,0x00,(long)"Bei dieser  Einstellung  bleibt  die",2,3,36,1,
    4,-1,-1,G_STRING,0x00,0x00,(long)"RAM-Konfiguration  unber\201cksichtigt,",2,4,36,1,
    5,-1,-1,G_STRING,0x00,0x00,(long)"da nur durch  einen  Warmstart  eine",2,5,36,1,
    6,-1,-1,G_STRING,0x00,0x00,(long)"korrekte  \232bernahme  der  Werte  er-",2,6,36,1,
    7,-1,-1,G_STRING,0x00,0x00,(long)"folgt! Deswegen kann auch der  PMMU-",2,7,36,1,
    8,-1,-1,G_STRING,0x00,0x00,(long)"Baum nicht gesch\201tzt werden!",2,8,28,1,
    9,-1,-1,G_STRING,0x00,0x00,(long)"Trotzdem weitermachen?",2,10,22,1,
    10,-1,-1,G_BUTTON,0x07,0x00,(long)"Weiter",17,13,9,1,
    0,-1,-1,G_BUTTON,0x25,0x00,(long)"Abbruch",29,13,9,1};

OBJECT WARNING3[]={
    -1,1,13,G_BOX,0x00,0x10,0x00021100L,0,0,40,18,
    2,-1,-1,G_STRING,0x00,0x00,(long)"VORSICHT!",2,1,9,1,
    3,-1,-1,G_STRING,0x00,0x00,(long)"Bei dieser  Einstellung  bleibt  die",2,3,36,1,
    4,-1,-1,G_STRING,0x00,0x00,(long)"RAM-Konfiguration  unber\201cksichtigt,",2,4,36,1,
    5,-1,-1,G_STRING,0x00,0x00,(long)"da nur durch  einen  Warmstart  eine",2,5,36,1,
    6,-1,-1,G_STRING,0x00,0x00,(long)"korrekte  \232bernahme  der  Werte  er-",2,6,36,1,
    7,-1,-1,G_STRING,0x00,0x00,(long)"folgt! Deswegen kann auch der  PMMU-",2,7,36,1,
    8,-1,-1,G_STRING,0x00,0x00,(long)"Baum nicht gesch\201tzt werden!",2,8,28,1,
    9,-1,-1,G_STRING,0x00,0x00,(long)"Au\236erdem bleibt die alte Bildschirm-",2,9,36,1,
    10,-1,-1,G_STRING,0x00,0x00,(long)"adresse nur bis zum n\204chsten  Aufl\224-",2,10,36,1,
    11,-1,-1,G_STRING,0x00,0x00,(long)"sungswechsel per Desktop erhalten!",2,11,34,1,
    12,-1,-1,G_STRING,0x00,0x00,(long)"Trotzdem weitermachen?",2,13,22,1,
    13,-1,-1,G_BUTTON,0x07,0x00,(long)"Weiter",17,16,9,1,
    0,-1,-1,G_BUTTON,0x25,0x00,(long)"Abbruch",29,16,9,1};

OBJECT WARNING4[]={
    -1,1,9,G_BOX,0x00,0x10,0x00021100L,0,0,40,14,
    2,-1,-1,G_STRING,0x00,0x00,(long)"VORSICHT!",2,1,9,1,
    3,-1,-1,G_STRING,0x00,0x00,(long)"Diese Einstellung l\204\236t es nicht  zu,",2,3,36,1,
    4,-1,-1,G_STRING,0x00,0x00,(long)"den PMMU-Baum in  einen  gesch\201tzten",2,4,36,1,
    5,-1,-1,G_STRING,0x00,0x00,(long)"Bereich des Speichers  zu  verschie-",2,5,36,1,
    6,-1,-1,G_STRING,0x00,0x00,(long)"ben, es kann also zu Problemen  kom-",2,6,36,1,
    7,-1,-1,G_STRING,0x00,0x00,(long)"men, wenn er \201berschrieben wird!",2,7,32,1,
    8,-1,-1,G_STRING,0x00,0x00,(long)"Trotzdem weitermachen?",2,9,22,1,
    9,-1,-1,G_BUTTON,0x07,0x00,(long)"Weiter",17,12,9,1,
    0,-1,-1,G_BUTTON,0x25,0x00,(long)"Abbruch",29,12,9,1};

OBJECT SAVEDIAL[]={
    -1,1,8,G_BOX,0x00,0x10,0x00021100L,0,0,37,10,
    2,-1,-1,G_STRING,0x00,0x00,(long)"Als was sollen die aktuellen Ein-",2,1,33,1,
    3,-1,-1,G_STRING,0x00,0x00,(long)"stellungen gespeichert werden?",2,2,30,1,
    4,-1,-1,0xFF00|G_BOX,0x11,0x01,0x00011101L,2,4,2,1,
    5,-1,-1,G_STRING,0x40,0x00,(long)"Bootprogramm",5,4,12,1,
    6,-1,-1,0xFF00|G_BOX,0x11,0x00,0x00011101L,2,5,2,1,
    7,-1,-1,G_STRING,0x40,0x00,(long)"Einstellprogramm",5,5,16,1,
    8,-1,-1,G_BUTTON,0x07,0x00,(long)"Speichern",13,8,10,1,
    0,-1,-1,G_BUTTON,0x25,0x00,(long)"Abbruch",26,8,9,1};

static void fix_tree(OBJECT *tree,WORD nobjs)
{
    WORD i;

    for (i=0;i<nobjs;i++)
        rsrc_obfix(tree,i);
}

void rsrc_init(void)
{
    fix_tree(MAINDIAL,43);
    fix_tree(WARNING1,12);
    fix_tree(WARNING2,11);
    fix_tree(WARNING3,14);
    fix_tree(WARNING4,10);
    fix_tree(SAVEDIAL,9);
}
