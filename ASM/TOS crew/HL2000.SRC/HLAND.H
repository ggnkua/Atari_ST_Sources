#ifndef __HLAND_H__
#define __HLAND_H__

/*
//  Er zijn 273 coins, 32 flesjes, 9 teleports en 4 kaarten.
//  Totaal dus 417 (=420) deletable objecten.
*/

typedef unsigned int word;
typedef unsigned char byte;

extern const int baan[];
extern const byte carddata_pac[];   /* kaarten data */
extern char y_info[];
extern char x_info[];
extern char color_info[];
extern byte munt_ani[];
extern char fles_ani[];
extern char punt_ani[];
extern int teleport[];
extern const byte ploing[];
extern const byte ploing_end[];
extern const byte rinkel[];
extern const byte rinkel_end[];
extern const byte ploef[];
extern const byte ploef_end[];
extern const byte pjoew[];
extern const byte pjoew_end[];
extern const byte card_pac[];
extern const byte veeg[];
extern const byte veeg_end[];
extern const byte gameover_pac[];
extern const byte welldone_pac[];
extern const byte sample_pac[];
extern const byte musix_pac[];
extern const byte font[];
extern const byte eggs[];
extern const byte balk[];
extern const byte wolk[];
extern const byte *egg_seq[];
extern const int  egg_seq_select[];
extern const byte ani_base[];
extern byte ani_table[];
extern signed char game_map[];
extern signed char game_map2[];
extern signed char intropic[];
extern signed char dead_pac[];
extern signed char endpic_pac[];
extern byte work_space[];
extern void* masks_0;
extern void* masks_1;
extern void* masks_2;
extern void* masks_3;
extern struct gamestruct game;


/* game defines */
#define MCH_ST 0     /* ST hardware */
#define MCH_STE 1    /* STE hardware */
#define MCH_TT 2     /* TT hardware */
#define MCH_FALCON 3 /* Falcon hardware */
#define STD_SR 0x2300 /* standard interrupt level */
#define OK 0
#define STOP 1
#define DEAD 2
#define WIN 3
#define FULL_LINES 10 /* aantal sprite lines */
#define MAPLEN 540 /* maplengte is 540 words */
#define MAPHEIGHT 100UL /* map hoogte */
#define ANI_LEN 16 /* animatie lengte is 16 stappen */
#define ANIMATED_OBJECTS 3 /* aantal verschillende geanimeerde objecten */
#define EGG_ANI_LEN 8 /* animatie lengte van egghead */
#define EGG_SIZE (22*5*4) /* groote van een egg in longs */
#define X_BASE 3 /* x-offset die we nul noemen */
#define JUMP_HEIGHT 4 /* sprong hoogte in sprites */
#define JOY_UP 1
#define JOY_LEFT 4
#define JOY_RIGHT 8
#define JOY_DOWN 2
#define JOY_FIRE 128
#define MAX_LIFE 232
#define COIN_SCORE 10
#define FLES_LIFE 17
#define LEGE_FLES 15
#define LUCHT 14
#define ZAND 16
#define SAMPLE_LEN 69022UL /* lengte sample */
#define MUS_LEN 75250UL /* lengte chip music */
#define CARD_LEN 10570
#define GAMEOVER_LEN 15120L
#define WELLDONE_LEN 3080
#define DEL_OBJECTS 420
#define DEAD_LEN 8513

#define AIR 0
#define SOLID 1
#define FD_RIGHT 2
#define FD_LEFT 3
#define FLES 2
#define PUNT 3
#define MUNT 4
#define AAS 5
#define KONING 6
#define QUEEN 7
#define JACK 8
#define TPT_A 9
#define TPT_B 10
#define TPT_C 11

#define C_LUCHT   1 /* lucht */
#define C_GROND   2 /* grond */
#define C_FLONDER 3 /* houten flonder */
#define C_GRAS    4 /* gras */
#define C_STEEN   5 /* steen */
#define C_MUNT    6 /* munt */
#define C_DEUR    7 /* deur */
#define C_FLES    2 /* fles (vol of leeg) */




void starfield(void* coord, void* scr);
void card2scr(int count, void* src, void* dst);
void scr2sb(void *src, void *dst);
void sb2scr(void *src, void *dst);
void update_screen(void);
void draw_main_sprite(void);
void init_blocks(void);
void key_interrupt(void);
void vbl_code(void);
void timer_d_code(void);
void trap3_handler(void);
void print(char *text, void *scr, int color);
void make_mask_list(unsigned long **list);
void decode(long origsize, void* depack_space, void* packed_data);

/* game struct */

struct gamestruct
{
  /* 
    Eerste deel van deze struct moet het zelfde blijven
    omdat assembley routines de variabelen ook gebruiken
  */
  int music;               /* 0: no sound, 1:effects, 2: chipsound, 3: DMA_Sound */
  char *musp;              /* current chip music adres */
  byte *ridel;             /* ridel pointer */
  byte *ridelend;          /* einde ridel */

  int life;                /* dood zodra kleiner dan 0 */
  int score;               /* game score */

  int vbl_count;           /* deze variabele wordt iedere vbl met een verlaagd */
  
  void* egg_ptr;           /* adres egg_data */
  
  unsigned long *d_screen; /* screen displayed */
  unsigned long d_reg;     /* display screen register data */
  unsigned long *w_screen; /* working screen */
  unsigned long w_reg;     /* working screen register data */
  int x_pos;               /* x positie */
  int y_pos;               /* y positie */
  int x_offs;              /* x offset */
  int y_offs;              /* y offset */
  int ani_count;
  int card_status[13];     /* is kaart reeds gevonden? */

  /* end of assembley part */
  int *deck_p;     /* pointer naar pak met kaarten */
  int status;      /* current game status */
  int machine;     /* machine type */
  int sound;       /* sound coockie */
  int joypad;
  int rasters;     /* show vbl rasters? */
  int maincount;
  int object_count; /* number of deleted objects */
  int user_direction; /* user direction */
  int sprite_direction; /* sprite direction */
  int sprite_ani_count; /* sprite animation counter */
  int forced_move; /* 0:= no problem, <0 forced move links, > 0 forced move rechts */
  int jump; /* als >0 zijn we bezig met sprong */
  int kaarten; /* aantal gevonden speelkaarten */
  int sazzy;   /* 1=she and red, 0 is he and green */
  char *dma_sound;     /* dma sound pointer */
  unsigned long old_screen_reg; /* old screen register data */
  byte old_res;        /* oude resolutie */
  word old_tt_res;
  int old_falcon_res;
  byte old_iea;        /* interrupt enable A */
  byte old_ieb;        /* interrupt enable B */
  byte old_ima;        /* interrupt mask A */
  byte old_imb;        /* interrupt mask B */
  byte old_eoim;       /* old end of interrupt mode */
  long old_cache;      /* old 68030 cache */
  void *old_kbd;       /* old keyboard vector */
  void *old_vbl;       /* old vbl routine */
  void *old_timer_d;   /* old timer d routine */
  void *old_trap3;     /* old trap #3 routine */
  byte old_tdc;        /* timer d control */
  byte old_tdd;        /* timer d data */
  char *key_conv; /* key table */
  char old_colors[32];
  int *current_teleport;
};

#endif
