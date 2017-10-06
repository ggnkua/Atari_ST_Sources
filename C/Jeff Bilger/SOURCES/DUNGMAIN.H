/* last modified : august 8 1993 */
/* note:
     If you want to add more pics. ie add more wall pics. 
     you NEED to check for the line

      if(check_for_new_pal > nn) then ...

    and change nn to the # of the LAST pic before
    pic#27..(thats MISC3.dat) 
    if you need to , change pick#27 to a higher #.. 
    BUT also remember that you must change the 
    HIT_TABLE array size (currently at a max of 0->27!!)
    and you need to reinit it(its initialized in the 
    module start() in t5.c

*/

/*#define	Random()	(int)xbios(17)         
extern	long	xbios();*/
int hold_xy[8];   /* for other misc pix xy coords */
#define rnd(t) abs(Random()%(t))   /*returns a number from 0 to (t-1) */
int mssg_count=0;
long time=0;  /* timekeeping */
int way=1;   /*time*/
int count=1;weather=0;
                 /* 1st emtry is 1AM */
int change[] = { 000,000,000,000,001,002,004,006,007,047,047,067,077,
                 077,067,057,047,047,037,027,007,006,005,003,001
                };
static char *weather_list[]={"Normal  ","Windy   ","Cool    ","Hot!    ","Rainy   ","Cold    ","Overcast"};

char n[40];

char	null[2] = {0,0} ;

/* savepal is the sys default pallette. 
   newpal  is the games pallette #1
  
   pal4    is pal      for misc3.dat  (pic25)*/
int savepal[16],newpal[16],junkbuff[46],pal4[16];

struct {
unsigned int which_pal : 1;    /* 0 for sys, 1-3 for other */
       } flags;

char	 temp_[32001],		             /* Temp buffer where file is read in	*/
         *hld,
		 *iff_in, *iff_out;	              /* Pointers for DEGAS unpack() routine	*/



int mode;



/*
    Define VDI Global Variables
*/
int contrl[12];
int intin[256],  ptsin[256];
int intout[256], ptsout[256];

   int i,filehandle;
    int fd ;
    
    int x,z,w;
    int y;


 int     handle;     /*  Virtual Workstation Handle   */
  char word[10];
    char title[] ="MAIN_SCR.DAT";            /* declares an array that holds the string "MAIN.DAT/0" */ 
    char pix1[] = "DMWALLS1.DAT";
    char pix2[] = "DMWALLS2.DAT";
    char pix3[] = "DMWALLS3.DAT";
    char pix4[] = "DMWALLS4.DAT";
    char pix5[] = "FLOOR1.DAT";
    char pix6[] = "FLOOR2.DAT";
    char pix7[] = "gate.DAT";






 
   

  

#define max_rooms 250                   /* its 249 rooms right now*/

/****************************************************************/
#define max_x 27     /* o to 24  = 25 rooms*/
#define max_y 27      /* 0 to 25   = 26 rooms */ 

struct field_data
    {
    int Field1,
        Field2,
        Field3,
        Field4,
        Field5,
        Field6,
        Field7,
        floor;
    };

 struct pic_data
   {
    struct field_data N,
                      S,
                      E,
                      W;
  
   }roomrec[250];

struct stuff
       {
       int room;
       int n,s,e,w;
       };

       /* if more rooms added make this bigger!!!! (max x and y )*/ 
       /* map[]  */
#define ROOMS 300
 struct stuff map[ROOMS];     

 char dir;
  
   int loc;   
   long command;    
    



char string[30];
	
int runner;
int hrt[20];  /* the hit roll table allocation */
int mhrt[20];  /* the hrt for monsters */

struct mon_
        {
        char name[20];
        int ac;
        int hd;
        int hp;
        int weapon;
        int spell;
        int lvl;
        };

struct mon_ mon;  /* storage for the data of the monster you are fighting*/

struct mon_ monsters[51];  /* 0->50 monsters */ 

  /* stores the monsters, its an array of records!*/
  /* to access hp. --->  MONSTERs[2].hp = xxx; */


struct character
        {
         char name[15]; /* NO! Set these to char *name and then */
         char align[15]; /* name = "blahh.." OR do char name[]="blah!" */
         char class[15];  /* you're defining an array of one element */
         int lvl;         /* thats a ptr to a char! too redundant! */
         long int exp;
         long int hp;
         int ac,str,inte,wis,dex,con;
         int weapon_num,armor_num;
         int backpack[10];       /* holds unique #. I'll have 1 main array that will hold number,name so we can look it up */
         char weapon[15];
         char armor[15];
         char spell[15];
         long int max_hp,max_sp;
         int spell_num;
         long int sp;
         long int gold;
         int user_items[25];  /* holds food,h2o,keys,etc.. */
         int current_spells_active[5]; /*0=treasure Finding, 1=Fleetness, 2=Protection
                                         3=Strength 4=Charm */
         int hunger_thurst_status[2];  /*0 not hungry/thirsty.. 10 FAMISHED */
                                       /* 0 is hunger 1 is thirst */
         long int bank_balance;  
         int x_loc,y_loc,        /* current x,y location */
             weather,count,way,time,loc,current_sky,
             current_sound,clock,am_pm,sound;
         char dir; 
         };


 struct character user;

   
 int who_goes,mon_alive,char_alive,mon_num,mon_lvl;

 MFDB t_mf;

/* hit table declrations. */
struct vm_table
       {
         int loaded;
         int pix_lookup_cell;
       };
struct vm_table hit_table[31];   /* for virtual memory hit table[1] stands for pic
                        1. If table[1] = 1 then pic 1 is in memory. If
                        its =0 then its not in memory so a pic must be removed, and this 
                        pic must be loaded into its place */

#define max_items 50      /* back pack lookup data structs */
struct i_look
       {
        char name[15];
        int points;          /*pts damage for this weapon */
       }unique_item[max_items];

/* define street array */
struct street_def
     {
      char street_name[15];  /*14 chars max! */
      int  room;
     }intersection[40];
char street_hold[15];  /* hold streetname so after encounter,etc you*/
                       /* can redisplay the street name  */

/* for sound invokage */
long addr;                             /* Basepage addr of TSR prg */

int CURRENT_CLOUD;
int CURRENT_SKY=0;       /* holds current value of sky color */
int CURRENT_SOUND=0;     /* if 1-wind, 4-Rain, else no sound */

/* SOME TIME DEFS */ /* Initial time is 1pm in the afternoon */
int clock=1;   /* when == 12 a clock tolls , also tells time of day */
int am_pm=1;   /* if == 1 then its pm. at midnight change to am, at noon change to pm */
 
int cell = 0; /* the current room you are in */

int sound = 1; /* to turn sound on/off. default is ON */
