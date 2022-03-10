/* GEMTRRSC 
   Resource source file
*/

#include <aes.h>

#if defined ( OBSPEC )
#undef OBSPEC
#endif
#define OBSPEC      unsigned long

#define RSH_VRSN    1
#define RSH_NOBS    71
#define RSH_NTREE   3
#define RSH_NTED    25
#define RSH_NIB     0
#define RSH_NBB     0
#define RSH_NSTRING 3
#define RSH_NIMAGES 0

char *rs_frstr[] = {
"[3][Kein Fenster frei.][Abbruch]",
"[2][Pause...][Weiter|Stop]",
"[2][GEMtris|beenden?][OK|Abbruch]" };

TEDINFO rs_tedinfo[] = {
"W„hrend eines Spiels:","","",5,6,2,4480,0,-1,22,1,
"RSC-File eingebunden von HJ 22.10.91","","",5,6,2,4480,0,-1,37,1,
"(langsam)","","",3,6,2,384,0,0,10,1,
"(schnell)","","",3,6,2,384,0,0,10,1,
"","1 : ________________","XXXXXXXXXXXXXXXX",3,6,0,4480,0,-1,17,21,
"","2 : ________________","XXXXXXXXXXXXXXXX",3,6,0,4480,0,-1,17,21,
"","3 : ________________","XXXXXXXXXXXXXXXX",3,6,0,4480,0,-1,17,21,
"","4 : ________________","XXXXXXXXXXXXXXXX",3,6,0,4480,0,-1,17,21,
"","5 : ________________","XXXXXXXXXXXXXXXX",3,6,0,4480,0,-1,17,21,
"","6 : ________________","XXXXXXXXXXXXXXXX",3,6,0,4480,0,-1,17,21,
"","7 : ________________","XXXXXXXXXXXXXXXX",3,6,0,4480,0,-1,17,21,
"","8 : ________________","XXXXXXXXXXXXXXXX",3,6,0,4480,0,-1,17,21,
"","9 : ________________","XXXXXXXXXXXXXXXX",3,6,0,4480,0,-1,17,21,
"","10 : ________________","XXXXXXXXXXXXXXXX",3,6,0,4480,0,-1,17,22,
"","________","XXXXXXXX",3,6,0,4480,0,-1,9,9,
"","________","XXXXXXXX",3,6,0,4480,0,-1,9,9,
"","________","XXXXXXXX",3,6,0,4480,0,-1,9,9,
"","________","XXXXXXXX",3,6,0,4480,0,-1,9,9,
"","________","XXXXXXXX",3,6,0,4480,0,-1,9,9,
"","________","XXXXXXXX",3,6,0,4480,0,-1,9,9,
"","________","XXXXXXXX",3,6,0,4480,0,-1,9,9,
"","________","XXXXXXXX",3,6,0,4480,0,-1,9,9,
"","________","XXXXXXXX",3,6,0,4480,0,-1,9,9,
"","________","XXXXXXXX",3,6,0,4480,0,-1,9,9,
"???","Ihr Name : ________________","XXXXXXXXXXXXXXXX",3,6,0,4480,0,-1,17,28 };

OBJECT rs_object[] = {
-1,1,5,25,0,0,(OBSPEC) 0X0L,0,0,80,25,
5,2,2,20,0,0,(OBSPEC) 0X1100L,0,0,80,513,
1,3,4,25,0,0,(OBSPEC) 0X0L,2,0,19,769,
4,-1,-1,32,0,0,(OBSPEC) " GEMtris",0,0,9,769,
2,-1,-1,32,0,0,(OBSPEC) " Optionen",9,0,10,769,
0,6,15,25,0,0,(OBSPEC) 0X0L,0,769,80,19,
15,7,14,20,0,0,(OBSPEC) 0XFF1100L,2,0,23,8,
8,-1,-1,28,0,0,(OBSPEC) "  šber GEMtris (Help)",0,0,23,1,
9,-1,-1,28,0,8,(OBSPEC) "-----------------------",0,1,23,1,
10,-1,-1,28,0,0,(OBSPEC) "  Desk Accessory 1  ",0,2,23,1,
11,-1,-1,28,0,0,(OBSPEC) "  Desk Accessory 2  ",0,3,23,1,
12,-1,-1,28,0,0,(OBSPEC) "  Desk Accessory 3  ",0,4,23,1,
13,-1,-1,28,0,0,(OBSPEC) "  Desk Accessory 4  ",0,5,23,1,
14,-1,-1,28,0,0,(OBSPEC) "  Desk Accessory 5  ",0,6,23,1,
6,-1,-1,28,0,0,(OBSPEC) "  Desk Accessory 6  ",0,7,23,1,
5,16,22,20,0,0,(OBSPEC) 0XFF1100L,11,0,30,7,
17,-1,-1,28,0,0,(OBSPEC) "  Spiel starten (F1)",0,0,30,1,
18,-1,-1,28,0,0,(OBSPEC) "  Bestenliste (F2)",0,1,30,1,
19,-1,-1,28,0,0,(OBSPEC) "  Bestenliste speichern (F3)",0,2,30,1,
20,-1,-1,28,0,8,(OBSPEC) "------------------------------",0,3,30,1,
21,-1,-1,28,0,0,(OBSPEC) "  Schnell (F10)",0,4,30,1,
22,-1,-1,28,0,8,(OBSPEC) "------------------------------",0,5,30,1,
15,-1,-1,28,32,0,(OBSPEC) "  Programmende (^C)",0,6,30,1,
-1,1,19,20,0,16,(OBSPEC) 0X21100L,1,1,41,18,
2,-1,-1,28,0,0,(OBSPEC) "Tetris, programmiert von R. Grothmann",2,1,37,1,
3,-1,-1,28,0,0,(OBSPEC) "GEM-Kosmetik von Kurt Karlst”tter",6,2,33,1,
4,-1,-1,28,0,0,(OBSPEC) "'GEMtris'",2,3,9,1,
5,-1,-1,28,0,0,(OBSPEC) "Version",20,3,7,1,
6,-1,-1,28,0,0,(OBSPEC) "Dec 31 1999",28,3,11,1,
7,-1,-1,28,0,0,(OBSPEC) "F1: Spiel starten",2,5,17,1,
8,-1,-1,28,0,0,(OBSPEC) "F2: Bestenliste",2,6,15,1,
9,-1,-1,28,0,0,(OBSPEC) "F3: Bestenliste speichern",2,7,25,1,
10,-1,-1,28,0,0,(OBSPEC) "F10: Schnell",2,8,12,1,
11,-1,-1,20,0,4,(OBSPEC) 0X43001180L,15,8,2,1,
12,-1,-1,28,0,0,(OBSPEC) "^C: Ende",2,9,8,1,
13,-1,-1,28,0,0,(OBSPEC) "Help: Information",21,9,17,1,
14,-1,-1,21,0,0,(OBSPEC) &rs_tedinfo[0],2,11,1551,1,
15,-1,-1,28,0,0,(OBSPEC) "Mit 4/6 bzw. / Stein links/rechts.",2,12,36,1,
16,-1,-1,28,0,0,(OBSPEC) "Mit 5 bzw.  drehen.",2,13,20,1,
17,-1,-1,28,0,0,(OBSPEC) "Mit 2 bzw.  fallenlassen.",2,14,26,1,
18,-1,-1,28,0,0,(OBSPEC) "Mit ESC beenden.",2,15,16,1,
19,-1,-1,26,7,0,(OBSPEC) " OK ",31,16,8,1,
0,-1,-1,21,32,0,(OBSPEC) &rs_tedinfo[1],1025,3843,38,1,
-1,1,27,20,0,16,(OBSPEC) 0X21100L,0,1,38,18,
2,-1,-1,28,0,0,(OBSPEC) "Die besten 10 :",2,1,15,1,
3,-1,-1,21,128,0,(OBSPEC) &rs_tedinfo[2],27,1,9,1,
4,-1,-1,21,0,0,(OBSPEC) &rs_tedinfo[3],27,1,9,1,
15,5,14,25,0,0,(OBSPEC) 0X1000L,1,3,21,10,
6,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[4],1,0,20,1,
7,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[5],1,1,20,1,
8,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[6],1,2,20,1,
9,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[7],1,3,20,1,
10,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[8],1,4,20,1,
11,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[9],1,5,20,1,
12,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[10],1,6,20,1,
13,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[11],1,7,20,1,
14,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[12],1,8,20,1,
4,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[13],0,9,21,1,
26,16,25,25,0,0,(OBSPEC) 0X1000L,28,3,8,10,
17,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[14],0,0,8,1,
18,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[15],0,1,8,1,
19,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[16],0,2,8,1,
20,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[17],0,3,8,1,
21,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[18],0,4,8,1,
22,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[19],0,5,8,1,
23,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[20],0,6,8,1,
24,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[21],0,7,8,1,
25,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[22],0,8,8,1,
15,-1,-1,29,0,0,(OBSPEC) &rs_tedinfo[23],0,9,8,1,
27,-1,-1,29,8,0,(OBSPEC) &rs_tedinfo[24],1,14,27,1,
0,-1,-1,26,39,0,(OBSPEC) "Ok",28,16,8,1 };

OBJECT *rs_tree[] = {
&rs_object[0],
&rs_object[23],
&rs_object[43] };

void rsc_init(void)
{
    int i;

    for (i=0; i < RSH_NOBS; i++)
        rsrc_obfix(rs_object,i);
    * (OBJECT ***) (&_GemParBlk.global[5]) = rs_tree;
}

void rsc_exit(void)
{
    * (OBJECT ***) (&_GemParBlk.global[5]) = 0L;
}

/* End of module */
