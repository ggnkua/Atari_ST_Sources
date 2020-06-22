
/* globals.h            - Contains all the external variables 
                         Its to be used with all the other modules 
                         Jan 24,1992 Jeff Bilger                */


/* extern ->> Just declares the var, it does NOT allocate storage */


extern	long	bios();
extern	long	xbios();
extern	long	gemdos();

#define	Dosound(a)	xbios(32,a)
#define Vsync()		xbios(37)
#define	Random()	(int)xbios(17)         /* int so we can use % */
#define	Bconin(a)	bios(2,a)
#define	Setcolor(a,b)	(int)xbios(7,a,b)
#define	Pexec(a,b,c,d)	gemdos(0x4b,a,b,c,d)

#define pos_rnd(t) abs(Random()%(t))   /*returns a number from 0 to (t-1) */

#define CH_A_TONE_L     0x00,   /* TONE PERIOD REGS. determines pitch*/  
#define CH_A_TONE_H     0x01,   /* period = 125,000 / freq (Hz) */
#define CH_B_TONE_L     0x02,   /* see page 76 Atari ST TOS */
#define CH_B_TONE_H     0x03,
#define CH_C_TONE_L     0x04,
#define CH_C_TONE_H     0x05,
#define NOISE_PERIOD    0x06,    /* LOW = Thin,static like HIGH = fast rushing (windlike) */
#define ENAB_TONE_NOISE 0x07,    
#define CH_A_VOL_AMP    0x08,
#define CH_B_VOL_AMP    0x09,
#define CH_C_VOL_AMP    0x0a,
#define ENV_PERIOD_L    0x0b,    /* Higher period = more slowly VOL changes and TONES are bell like*/
#define ENV_PERIOD_H    0x0c,    /* lower period  = VOL changes fast and TONES are very raspy! */
#define WAVEFORM        0x0d,    
#define PLACE           0x80,    /* For Ending, or loops */
#define INTO            0x81,
#define INCREMENT_BY
#define UNTIL


#define WHITE 0
#define BLACK 3
#define GREEN 2
#define RED   1
#define MAX   13
#define MIN   0
#define HOUR_VALUE 750        /* set this to change dT */
#define rnd(t) (abs(Random()%(t)))   /*returns a number from 0 to (t-1) */

typedef struct fdbstr
{
	long	fd_addr;
	int		fd_w;
	int		fd_h;
	int		fd_wdwidth;
	int		fd_stand;
	int		fd_nplanes;
	int		fd_r1;
	int		fd_r2;
	int		fd_r3;
} MFDB;	

extern  int     pal2[],pal3[],pal4[];


extern int weather; /* holds 0-6, used as index [7] as max*/

extern int count; /* for time */
extern int way;      /* for time */
extern int change[]; /* for dynamic sky */
long time;         /* for time keeping */
extern char string[30];

/*misc declarations*/

extern int runner;
extern int hrt[20];  /*0-19 the hit roll table allocation */
extern int mhrt[20];  /*0-19 the hrt for monsters */

extern struct mon_
        {
        char name[20];  /* this is bad, make it a char *name; not*/
        int ac;          /* char *name[20]! This creates an array */
        int hd;          /* of 20 ptrs to type CHAR */
        int hp;
        int weapon;
        int spell;
        int lvl;
        };

extern struct mon_ mon;  /* storage for the data of the monster you are fighting*/

extern struct mon_ monsters[51]; /* 51, or 0 to 50!!! */

  /* stores the monsters, its an array of records!*/
  /* to access hp. --->  MONSTERs[2].hp = xxx; */




extern struct character
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

extern struct character user;

   
extern int who_goes,mon_alive,char_alive,mon_num,mon_lvl;


extern char n[];
extern char null[2] ;
extern int savepal[16],newpal[16],junkbuff[46];

extern int handle;     /*  Virtual Workstation*/


extern int contrl[12];
extern int intin[256],  ptsin[256];
extern int intout[256], ptsout[256];



extern char dir;
extern   int x;
extern   int y;
extern   int loc;   
extern   char command;    
extern   int mssg_count;
    
   /* back pack lookup data structs */
extern struct i_look
       {
        char name[15];
        int points;
       }unique_item[];

/* sound invokage */
extern long addr;      /* points to addr that player is stored at */


extern int CURRENT_CLOUD;
extern int CURRENT_SKY;       /* holds current value of sky color */
extern int CURRENT_SOUND;     /* if 1-wind, 4-Rain, else no sound */

/* GLOBAL SOUNDS FOR DOSOUND() */

static unsigned char wind_sound[]={
CH_A_VOL_AMP     0x0b,
CH_B_VOL_AMP     0x11,
CH_C_VOL_AMP     0x03,
CH_A_TONE_H      0x01,
CH_A_TONE_L      0xff,
CH_B_TONE_H      0xff,
CH_B_TONE_L      0xff,
NOISE_PERIOD     0xff,
ENAB_TONE_NOISE  0x03,
ENV_PERIOD_L     0x22,
ENV_PERIOD_H     0xff,
WAVEFORM         0x0e,                         
PLACE 0x02,INTO 0x12, INCREMENT_BY 0x02, UNTIL 0x25};

static unsigned char quiet[] = {
CH_A_VOL_AMP     0x00,
CH_B_VOL_AMP     0x00,
CH_C_VOL_AMP     0x00,
CH_A_TONE_H      0x00,
CH_A_TONE_L      0x00,
CH_B_TONE_H      0x00,
CH_B_TONE_L      0x00,
NOISE_PERIOD     0x00,
ENAB_TONE_NOISE  0x00,
ENV_PERIOD_L     0xff,
ENV_PERIOD_H     0xff,
WAVEFORM         0x00,  
0xff,0x00};
	

static unsigned char rain_sound[]={
CH_A_VOL_AMP     0xff,
CH_B_VOL_AMP     0xff,
CH_C_VOL_AMP     0x03,
CH_A_TONE_H      0xff,
CH_A_TONE_L      0x00,
CH_B_TONE_H      0xff,
CH_B_TONE_L      0x00,
CH_C_TONE_H      0x09,
CH_C_TONE_L      0x00,
NOISE_PERIOD     0xff,
ENAB_TONE_NOISE  0x63,
ENV_PERIOD_L     0x22,
ENV_PERIOD_H     0x11,
WAVEFORM         0x0d,                         
PLACE 0x02,INTO 0x12, INCREMENT_BY 0x02, UNTIL 0x25};

/* SOME TIME DEFS */ /* Initial time is 1pm in the afternoon */
extern int clock;   /* when == 12 a clock tolls , also tells time of day */
extern int am_pm;   /* if == 1 then its pm. at midnight change to am, at noon change to pm */
 
extern int cell; /* room you are in */

extern struct field_data
    {
    int Field1,
        Field2,
        Field3,
        Field4,
        Field5,
        Field6;
    };

extern struct pic_data
   {
    struct field_data N,
                      S,
                      E,
                      W;
   

   }roomrec[250];



#define max_x 27     /* o to 24  = 25 rooms*/
#define max_y 27      /* 0 to 25   = 26 rooms */ 

extern struct stuff
       {
       int room;
       int n,s,e,w;
       };

       /* if more rooms added make this bigger!!!! (max x and y )*/ 
       /* map[][] uses map[0][0] to map[maxx][maxy] all other arrays
          starts at array[1] */
extern struct stuff map[max_y][max_x];     /* 2 d array in c is in form a[y][x] */

extern int sound;  /* to turn sound on/off, default is ON */
