	
#include "osbind.h"
#include "gemdefs.h"
#include "a:words.h"

extern int i0(),i1(),i2(),i3(),i4(),i5(),i6(),i7(),i8(),i9();
extern int i10(),i11(),i12(),i13(),i14();
extern int o0(),o1(),o2(),o3(),o4(),o5(),o6(),o7(),o8(),o9();
extern int o10(),o11(),o12(),o13(),o14();
FDB psrc,pdes;
char *savname[] = {"OUTSIDE.DAT\0","DEMON.DAT\0","TROND.DAT\0","CAVE.DAT\0",
                   "DDEMON.DAT\0","DTROND.DAT\0","DCAVE.DAT\0"};
int pxy[] = {12,136,319-75,199,12,134,319-75,197};
int bxy[] = {12,197,319-75,199};
int lxy[] = {0,127,319-75,128};
int vxy[] = {255,0,255,199};
int fromout = 0,new = 0,lev = 0;
int monster = 0,hold = 0,police = 0;
int usedline = 0,prev =0,prevy = 0,row,col=2,grflist[13],winroom;
int (*inverb[])()  = {i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14};
int (*outverb[])() = {o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14};
int winker = 0, winktime = 0,combat = 0;
char *posture[] = {"All Out","Standard","Defensive","Fall Back"};
char *wordmod[] = {"None","Low","Medium","Severe","Dead","Panicked"};
                      /* chance,damage,weight */
char specbuf[40],putbuf[320],monbuf[320],junk[20];
char weapon[][3] = { {0,0,0},                                 /* no weapon */
                     {60,12,10},                              /* broad sword */
                     {60,8,5},                              /* scimitar  */
                     {60,6,5},                                  /* mace */
                     {40,3,1},                                  /* dagger */
                     {-1,12,8}};                                  /* bow */
char *wepname[] = {"","Broadsword","Scimitar","Mace","Dagger","Bow"};
char wepmatx[4][4] = { {0,-40,-40,-40},
                       {40,0,20,-20},
                       {40,-20,0,20},
                       {40,20,-20,0} };
char *statword[] = {"Points","Spell","Good Hand",
                    "Other Hand"," OPTIONS:","Good Hand",
                    "Other Hand","Inventory","  Quit"};
long int saddr;
int fillpic[41][65];
int mode = 0,dismax;
int pursuit[] = {0,0,0};
int oldpal[16],newpal[16] = {-1912,-120,-1905,-600,-536,-1832,-55,-820,-8,-1793,
                      -311,-1912,-113,-19,-627,-1};
char trigval[80][6];
char invtrig[20];
char path[] = "a:*.SAV\0",filename[] = "________.___\0";
char *spell[] = {"Cure","Search","Freeze","Unvenom","Vorpal",
                 "Speed","Armor","Disarm","Bolt","Thief",
                 "Fear","Fireball","Blink","Reveal","Heal",
                 "Prism","Block","Charm","Wallfire","Destroy",
                 "Summon","Death","Life","Teleport",
                 "CANCEL"};
char spelunit[] = {0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5};
char *name[] = {"goblin","skeleton","spider","firewolf","ghost","thrang",
                "ghoul","snake","vampire","gork","Melkthrop","merchant",
                "bat","Eirik","guard","pedestrian","Mage Leveth",
                "orc","crusher","flamer","rat","bartender","rogue"};
char curmon[12][60] = { {1,4,50,0,81,5,60,8,0,0,0,4,3,90,10} };
char invnpc[4][20]; 
char permon[][23] = { {0,0},
     /* spider */    {1,0,20,2,83,6,100,0,0,0,0,4,2,95,0,13,1,30,0,0,1,0,0},
     /* skelly */    {1,0,10,1,85,6,100,0,0,0,0,5,0,101,0,8,0,50,0,0,1,0,0},
     /* snyke  */    {1,0,50,7,87,6,60,4,100,0,0,5,2,101,0,13,2,40,10,0,1,0,0},
     /* dogs   */    {1,0,8,3,89,6, 100,0,0,0,0,3,0,90,0,8,0,30,0,0,1,0,0},
     /* goblins */  {1,0,14,0,91,10,20,6,80,4,100,4,2,90,0,10,0,30,50,60,1,0,0},
     /* bats   */    {1,0,10,12,93,8,20,4,100,0,0,2,0,97,0,5,0,30,60,0,1,0,0},
     /* thrang */    {1,0,70,5,95,9,12,0,0,0,0,6,0,101,42,8,0,0,0,0,1,0,0},
     /* Babaran */ {1,0,50,13,97,0,0,0,0,0,0,3,3,101,0,20,0,0,2,0},
     /* Alph? */ {0},
     /* Millie */ {0},
     /* spooks */  {1,0,20,4,103,6,40,0,40,4,100,2,0,100,0,0,0,40,0,40,1,52,1},
     /* ghouls */   {1,0,20,6,105,10,40,0,0,6,100,5,2,100,0,12,1,40,0,60,1,0,0},
     /*vampire*/{1,0,60,8,107,20,60,20,80,10,100,3,0,90,0,20,0,40,60,20,1,56,1},
     /* gork */ {1,0,80,9,109,40,50,30,100,0,0,3,4,100,0,20,1,30,70,0,1,47,1},
  /* merchant*/ {1,0,10,11,108,0,0,0,0,0,0,6,0,0,0,1,0,0,0,0,5,0,0},
   /* Melkthrop */{1,0,50,10,111,22,16,12,0,0,0,4,100,110,100,5,0,0,0,0,1,0,1},
     /* cop */  {1,0,20,14,106,10,40,6,80,4,100,4,1,85,0,8,0,30,50,30,1,0,0},
   /* pedest */ {1,0,10,15,110,0,0,0,0,0,0,5,0,10,0,2,0,0,0,0,6,0,0},
/* Lev */ {1,0,100,16,112,12,16,22,0,0,0,6,100,110,126,2,0,0,0,0,7,0,1},
/* orc */ {1,0,18,17,102,24,30,16,70,12,100,4,2,96,0,12,0,30,60,10,1,0,0},
/* crusher */ {1,0,60,18,113,20,100,0,0,0,0,3,4,101,0,20,0,50,0,0,1,0,1},
/* flamer */ {1,0,20,19,114,12,0,0,0,0,0,3,0,101,50,0,0,0,0,0,1,0,1},
/* rat */ {1,0,12,20,119,10,20,0,0,6,100,2,0,101,0,4,0,50,0,80,1,0,0},
/* barten */ {1,0,20,21,115,8,100,0,0,0,0,4,1,95,0,10,0,40,0,0,7,0,0},
/* rogue */ {1,0,35,22,120,20,30,16,70,12,100,3,4,96,0,12,0,60,60,60,7,0,0} };
char selllist[][4] = { {81,3,5,0},
                        {42,10,20,0},
                        {69,25,35,0},
                        {45,20,30,0} };
char weight[41] = {0,-1,4,7,10,17,-1,18,8,-1,-1,20,-1,-1,16,8,8,-1,7,8,
                   -1,-1,16,20,-1,-1,-1,8,-1,14,-1,-1,-1,-1,-1,-1,-1,-1,-1,
                   -1,12};
char *mod[] = {"0","L","M","H","X","P","C"};
int crudbuf[65];
char *stuff[] = {"","                    "};
char  *errmsg[] = {"",
                   "[1][That path is blocked!|     Try again!][OK]",
                   "[1][That's the same square!|      Try again!][OK]",
                   "[1][ That square can't be | seen. Try again!][OK]",
                   "[1][ There is nothing to  | examine. Try again!][OK]",
                   "[1][  The object must be  | adjacent. Try again!][OK]",
                   "[1][ There is nothing to  |  take.  Try again!][OK]",
                   "[1][ The inventory is too | full.  Drop something.][OK]",
                   "[1][ There is no character|  there. Try again!][OK]", 
                   "[1][  The target must be  | adjacent. Try again!][OK]",
                   "[1][ The inventory is empty.|  Try something else!][OK]",
                   "[1][ The location must be | adjacent. Try again!][OK]",
                   "[1][ The object | is closed!][OK]",
                   "[1][  Insufficent spell  |  units!  Try again!][OK]",
                   "[1][ There is nothing to | disarm! Try again!][OK]",
                   "[1][ There is no exit! |   Try again!][OK]",
                   "[2][ Will the object  |    be taken? ][Yes| No]",
                   "[2][ Do you wish to  ][Abort|Quit|File]",
                   "[1][ Read/Write failure. ][OK]",
                   "[2][ Do you wish to      ][Stop|Save|Load]",
 /* #20 errmsg */  "[1][  No weapon in hand! ][OK]",
                   "[1][ A bow must be FIRED!][OK]",
                   "[1][  A bow requires  | two free hands!][OK]",
                   "[1][ There is no   | object there!][OK]",
                   "[1][ This object is   | immoveable!][OK]",
                   "[1][ There is nothing | to rook/snoop!][OK]",
                   "[1][   There are no   | torches left!][OK]",
                   "[1][ There is nothing |   in hand!][OK]",
/* 28 */           "[1][ Insufficient   | magic ability!][OK]",
                   "[1][  Hands are full! ][OK]",
                   "[1][ No bow or arrows ][OK]",
"[2][  Which hand's object? ][Good |Other]",
"[1][ Insufficient Disk Space! |    Fatal Error! | Program Shutdown!][OK]",
"[1][ The attempted restore does |  NOT match current dungeon! ][OK]"};
            /* target - domsg index - speltime */
char spelinfo[24][3] = { {3, 3, 6 }, /* cure light wounds */
                         {0, 0, 6 }, /* search */
                         {1, 3, 6 }, /* freeze */
                         {3, 3, 6 }, /* unvenom */
                         {3, 3, 6 }, /* vorpal */
                         {3, 3, 6 }, /* speed */
                         {3, 3, 6 },  /* armor */
                         {2, 2, 6 }, /* disarm */
                         {1, 3, 6 }, /* bolt */
                         {2, 2, 6 }, /* unlock */
                         {1, 3, 6 }, /* fear */
                         {1, 3, 8 }, /* fireball */
                         {3, 3, 8 }, /* blink */
                         {0, 0, 10 }, /* reveal */
                         {3, 2, 15 }, /* heal */
                         {1, 3, 10 }, /* prism */
                         {2, 2, 6 }, /* block */
                         {1, 3, 10 }, /* charm */
                         {0, 3, 10 }, /* firewall */
                         {2, 2, 8 }, /* destroy */
                         {0, 1, 20 }, /* summon */
                         {1, 3, 8 }, /* death */
                         {2, 3, 30 }, /* life */
                         {0, 0, 10}}; /* teleport */
char *com[] = {"the ",
               "  place",
               "  object",
               "  target",
               "   spot",
               "   exit",
               "   item",
               "   item"};
char fname[] = "grafx.dat\0";
char pname[20];
/* load the collection of trees into memory */
char *verblist[] = {"Cast ","Examine","Drag/Eat","Search","Take/Drop","Wait",
                    "X-it","Rook/Snoop","Fire Arrow","Burn/Snuff","Give",
                    "Voice","Quit/File"};
char zline[16][8][7],rumdata[80][157],triglist[25],crumobj[18][9];
char *att[][4] = { {"","","",""},
/*spidey*/         {"","bite/all","",""},
/*skelly*/         {"","blade/all","",""},
/*snake */         {"","crush/all","bite/std","bite/def"},
/*dogs */          {"","bite/all","",""},
/*goblin*/         {"","mace/all","mace/std","mace/def"},
/*bat*/            {"","bite/all","claw/std",""},
/*thrang*/         {"","","",""},
/* Bab */          {"","","",""},
/* */              {"","","",""},
/* */              {"","","",""},
/* spook */        {"","drain/all","","drain/def"},
/* ghoul */        {"","bite/all","","claw/def"},
/* vampire */      {"","bite/all","strike/std","glare/def"},
/* gork */         {"","spray/all","slash/std",""},
/* merchant */      {"","","",""},
/* melkthrop */     {"","","",""},
/* cop */          {"","club/all","club/std","club/def"},
/* ped */         {"","","",""},
/* Lev */         {"","","",""},
/* orc */         {"","slash/all","slash/std","slash/def"},
/* crush */       {"","crush/all","",""},
/* flamer */      {"","","",""},
/* rat */         {"","bite/all","","bite/def"},
/* bar */         {"","club/all","",""},
/* rogue */       {"","blade/all","blade/std","blade/def"}
};
char *monmsg[] = {
"-> The goblin, a look of inhuman brutality gripping its face, \
storms toward %s swinging a mace and chanting 'Melkthrop! Melkthrop!'.",
"-> The skeleton lurches crazily across the floor, brandishing its \
rusty scimitar at %s, an unholy light emanating from its empty eyesockets.",
"-> The spider exudes a rank odor, a mixture of decomposing flesh and \
venom.  Its seven red eyes gleam malevolently as it scuttles across the \
floor toward %s.",
"-> The firewolf, its fangs bared in a vicious snarl, bounds across the floor \
toward %s.",
"-> The ghost wails an ethereal cry of insatiable hunger for life as it floats \
toward %s.",
"-> The thrang, a dessicated corpse clad in rotting regal garments, glares at \
%s with glowing red eyes set in sunken sockets. Once a great mage, it has \
passed into a state of undead through arcane and evil magics.",
"-> The ghoul slavers, a charnel house stench reeking from its mottled flesh, \
as it staggers after %s.",
"-> The snake writhes in a reptilian frenzy as it slithers after %s.",
"-> The vampire, its eyes glowing in a once-patrician face, advances toward \
%s, exuding a paralyzing charm.",
"-> The enormous gork, a constant stream of poisonous saliva coursing from its \
mouth and its talons flicking, advances after %s. Gorks are renowned for their\
 resistance to magic of all forms.",
"-> Melkthrop, a major but somewhat small-minded demon from the lower planes \
of Hell, prepares to hurl a spell at %s.",
"-> The merchant, a look of avarice apparent despite an unctuous smile, \
peers hopefully at %s's goldpouch.",
"-> The screeching bat, slavering and gnashing its sharp ratlike teeth, \
flutters after %s!",
"-> Eirik Bloodaxe, heir to the western provinces of Nordheim, stands stolidly \
surveying the room. His incredible strength is already a legend throughout \
Avecta, as is his loyalty to friends and his hatred toward foes.",
"-> The taciturn guard, armed with a large truncheon, comes directly at \
%s!",
"-> The pedestrian is busy about some urgent affair.",
"",
"-> The orc, a definite bruiser, ambles toward %s, confidently brandishing \
his tulwar!",
"-> The enormous crusher, gigantic and simple-minded, has only one thought: \
to heave his bulk on top of %s, inflicting vast damage!",
"-> The flamer, formerly sole tenant of the cavern, is a sentient fire. \
It hisses and crackles at %s!",
"-> The rat, its sharp teeth snapping, rears on its backlegs, hissing and \
spitting at %s!",
"-> The bartender has a rosy glow from sampling too much of his wares.  Closer \
examination reveals a fair amount of strength beneath an amiable surface.",
"-> The rogue, noticing %s's interest, issues a gesture of contempt."};
int crum,objnum,bitmap[200][65];
int storbuf[12][130],num,time=0,animate(),vbl(),off();
int firebuff[130];
int contrl[12], intin[128], intout[128], ptsin[128], ptsout[128];
int  work_in[11], work_out[57];
int  handle, dum1, dum2, dum3, dum4;
char *obj[] = {"","door","chair","bed","desk","stove","altar","bookshelf",
                   "table","fireplace","statue","garbage heap","trapdoor",
                   "tapestry","throne","urn","chest","hole",
                   "barrel","skeleton",
                   "stairs which go down","stairs which go up",
                   "laboratory table","bathtub",
                   "lamp post","ectoplasmic converter","fountain","bench",
                   "iron gate","table with food","bush",
                 /*31*/  "orc machine","X-shaped rune","sign","announcement",
                   "Red Lion","fire","wrecked wagon","","","dead Eirik",
                   "broadsword","scimitar","mace","dagger","bow",
                   "bone key","button","old key","rune","black key",
                   "tongs","rod","bottle","poster","potion",
                   "garlic bud","device","bag","note","note",
                   "old bone","large book","vile key","magic tome","mask",
                   "black ball","note","note","power vial","bag",
                   "","","","","",
                   "","","","","seekshard","torch","","","",""
};
int outside,dungeon;
char eats[] = {0,0,0,0,0,0,1,1,1,0,1,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,
               0,0,0,0,0,0,0,0,0,0};
long int addr;

main() 
{
int old,i,j,x,y;
char *c = curmon[0];
if(stinit() == 0 || ruminit() == 1)
  goto end;
graf_mouse(0,intin);
j = Random();
srand(j);
i = title();
if(i == 1) 
  new = 0;
else
  new = 1;
specbuf[29] = new;
crum = -1;
while (i != 0){
   j = 1;
   switch(i) {
       case 1:
          i = init(0);
          break;
       case 2:
          if((j=fileio(2)) == -1) {
            raton();
            form_alert(1,errmsg[18]);
            rausmaus();
            }
          i = 0;
          break;
       default:
          i = 0;
          break;
       }
    while(i == 0 && j > 0) {
      i = switchrum();
      if(i > 0) {
        xbios(37);
        xbios(38,off);
        continue;
        }
      i = tacmode();
      xbios(37);
      xbios(38,off);
      }
    switch(i) {
      case -5:
          if((j=fileio(2)) == -1) {
            raton();
            form_alert(1,errmsg[18]);
            rausmaus();
            }
          if(j == 0) {
            raton();
            form_alert(1,errmsg[33]);
            rausmaus();
            }
          i = 3;
          break;
      case -4: /* this is the store game option */
         if((j=fileio(1)) == -1) 
            form_alert(1,errmsg[18]);
         i = 3;
         break;
      case -2:
         i = 0;
         break;
      case -1:
         i = console();
         break;
      case 1: 
         congratulate();
         i = 0;
         break;
      case 2: /* dungeon switch */
         old = dungeon;
         if(dungeon != 0) {
            *(c+54) = *(c+4);
            *(c+59) = 0;
            }
         else {
            police = 0;
            if(*(c+46) == 81)
              *(c+46) = 0;
            *(c+52) = *(c+53) = 0;
            *(c+56) = *(c+24);
            *(c+57) = *(c+25);
            *(c+55) = crum;
            }
         if(loadnew() == 0) {
            raton();
            i = 0;
            form_alert(1,errmsg[32]);
	            rausmaus();
            break;
            }
         if(old != 0) {
           *(c+30) = *(c+55);
           *(c+4) = 125;
           *(c+24) = *(c+56);
           *(c+25) = *(c+57);
           outside = 1;
           }
         else {
           *(c+4) = *(c+54);
           outside = 0;
           *(c+54) = 0;
           }
         i = 3;
         break;  
      default:
         i = title();
         break;
      }
}
end:Setpallete(oldpal);
raton();
v_clsvwk(handle);
appl_exit();
}


extern int prnt(s1,s2,s3,s4,s5,s6,s7)
char *s1,*s2,*s3,*s4,*s5,*s6,*s7;
{
extern int off(),vbl(),hold,usedline,lxy[],pxy[],bxy[],handle,row,col;
int per = 0,i=0,j,k=0,l,len,m,lines = 1;
char buffer[30],*c[6];
vsf_interior(handle,1);
vsf_color(handle,0);
v_bar(handle,lxy);
vsf_interior(handle,1);
vsf_color(handle,1);
c[0] = s2;
c[1] = s3;
c[2] = s4;
c[3] = s5;
c[4] = s6;
c[5] = s7;
l = strlen(s1);
col = 2;
row++;
rausmaus();
xbios(37);
xbios(38,off);
v_rvon(handle);
while( l - i > 0) {
   j = 0;
   while( *(s1+i) != 32 && *(s1+i) != '%' && l-i > 0) {
      buffer[j++] = *(s1+i);
      i++;
      }
   if( *(s1+i) == 32 || l-i == 0 ) { 
      buffer[j] = '\0';
      len = strlen(buffer);
      }
   if( *(s1+i) == '%') {
      i++;
      len = strlen(c[k]);
      k++;
      if(*(s1+i+1) != 32)
        per = 1;
      }
   if(len + col + per > 41) {
      col = 2;
      lines++;
      row++;
      per = 0;
      xbios(37);
      }
   per = 0;
   if(row > 25) {
      vs_curaddress(handle,17,2);
      printf("                              ");
      vsf_interior(handle,1);
      vsf_color(handle,0);
      v_bar(handle,lxy);
      vsf_interior(handle,1);
      vsf_color(handle,1);
      for(m=0;m<4;m++) {
         pxy[1] = 136-2*m;
         pxy[3] = 199-2*m;
         pxy[5] = 134-2*m;
         pxy[7] = 197-2*m;
         bxy[1] = 198-2*m;
         bxy[3] = 199-2*m;
         vro_cpyfm(handle,3,pxy,&psrc,&pdes);
         v_bar(handle,bxy);
         }
      row = 25;
      if((usedline+lines > 7 && hold == 1 && l-i > 40) || usedline+lines > 8) {
         textsix(1,204,8*24,6,"[More]");
         hold = 0;
         usedline = 0;
         xbios(38,vbl);
         Bconin(2);
         xbios(37);
         xbios(38,off);
         lines = 1;
         vs_curaddress(handle,25,2);
         printf("                              ");
         }
      }
    if(*(s1+i) == ' ' || l-i == 0) {
       textsix(1,6*col,8*(row-1),len,buffer);
       }
    else {
       textsix(1,6*col,8*(row-1),len,c[k-1]);
       col--;
       }
    col += len + 1;
    i++;
    }
v_rvoff(handle);
usedline += lines;
xbios(38,vbl);
raton();
hold = 1;
return(i);
}   

extern int stinit()
{
extern int handle,newpal[],oldpal[];
int i;
int savpal(),rgb[3];
appl_init();
handle = graf_handle(&dum1, &dum2, &dum3, &dum4);
for (i = 0; i < 10; work_in[i++] = 1);
work_in[10] = 2;
v_opnvwk(work_in, &handle, work_out);
psrc.fd_w = pdes.fd_w = work_out[0] + 1;
psrc.fd_h = pdes.fd_h = work_out[1] + 1;
psrc.fd_wdwidth = pdes.fd_wdwidth = psrc.fd_w>>4;
psrc.fd_stand = pdes.fd_stand = 1;
psrc.fd_addr = pdes.fd_addr = (long)0;
rausmaus();
vs_curaddress(handle,1,1);
v_eeos(handle);
xbios(38,savpal);
if(Getrez() != 0) {
  raton();
  form_alert(1,"[1][Reboot in Low Rez!][OK]");
  rausmaus();
  return(0);
  }
Setpallete(newpal);
xbios(37);
addr = Logbase();
vq_extnd(handle,1,work_out);
psrc.fd_nplanes = pdes.fd_nplanes = work_out[4];
i = Dgetdrv();
path[0] = 'a' + i;
num = 1;
rgb[0] = rgb[1] = rgb[2] = 0;
vs_color(handle,0,rgb);
xbios(37);
return(1);  
}
