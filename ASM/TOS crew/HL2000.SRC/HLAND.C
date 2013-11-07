/*
 * Game demo by Mr Ni!
 * edit 2008: fixed joypad code: Mega Ste doesn't have a joypad!
 */

#include <stdio.h>
#include <string.h>
#include <ext.h>
#include <tos.h>
#include <stdlib.h>
#include "hland.h"

struct gamestruct game;
byte orig_block[DEL_OBJECTS];
byte new_block[DEL_OBJECTS];
word pos_block[DEL_OBJECTS];

/* key handeler info */
struct key_handler_info_struct
{
  volatile byte joy0;
  volatile byte joy1;
  volatile byte joy2; /* cursor joystick */
  volatile byte last_key;
};

extern struct key_handler_info_struct key_info;

/* kaarten truuk gedoe */
byte work_space[0x12600L]; /* save buffer voor scherm, sounddata */

/* prototypes */

void main_game(void);
void vsync(void);
void tvsync(void);
void key_handle(void);
int init_game(void);
void restore(void);
void set_screen(void);
void get_user_actions(void);
void collision_detect(void);
void show_map(void);
byte read_joypad_a(void);
void kaarten(int newcard);
void do_starfield(void);
void schudden(void);
void s2s(void);
void game_over(void);
void game_win(void);

void move_sr(word value) 0x46c0; /* move D0,SR */

word gamecolors[]=
{
  0x000,
  0xfff,
  0xca9,
  0xdba,
  0xe00,
  0x8b8,
  0x0d8,
  0x8f8,
  0xff8,
  0xdde,
  0xc3c,
  0xbab,
  0x21a,
  0x88b,
  0x318,
  0xfff,
};

word mapcolors[]=
{
  0x000,  /* achtergrond kleur */
  0x002,  /* lucht kleur */
  0xba9,  /* grond kleur, fles kleur */
  0xcc8,  /* flonder kleur */
  0x8f8,  /* gras kleur */
  0xccc,  /* steen kleur */
  0xff8,  /* munt kleur */
  0xf8f,  /* deur kleur */
  0xff8,  /* not used */
  0xdde,
  0xcbc,
  0xbab,
  0xa9a,
  0x88b,
  0x318,
  0xfff,
};

word menucolors[]=
{
  0x888,
  0xfff,
  0xc21,
  0xd3a,
  0xe00,
  0x030,
  0x0d8,
  0x0f8,
  0xff8,
  0xdde,
  0xc3c,
  0x323,
  0x21a,
  0x003,
  0x318,
  0xfff,
};

int deck[]=
{
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12
}; 

int main(void)
{
  Supexec((long (*)( ))(main_game));
  return 0;
}

void main_game(void)
{
  if(init_game()!=0)
  {
    return;
  }
  tvsync();
  *(byte *)0xffff8260UL=0; /* set ST LOW video mode */
  /* do all lot of time consuming work during intro screen... */
  memset(game.card_status, 0, sizeof(game.card_status));
  memcpy(game.w_screen+40*187, balk, 160*13);
  memcpy(game.w_screen, wolk, 160*14);
  memcpy(game.w_screen+(FULL_LINES)*16*40+14*40, wolk, 160*13);
  memcpy(game_map2, game_map, 54000UL); /* duplicate game_map */
  schudden();
  init_blocks();
  memcpy(game.d_screen, game.w_screen, 32000);
  memcpy((void*)0xffff8240UL, gamecolors, 32);
  game.ridel=ploing;
  game.ridelend=ploing_end;
  for(;;)
  {
    game.maincount++;
    if((game.maincount&1)==0)
    {
      if(--game.ani_count<0)
      {
        game.ani_count=ANI_LEN-1;
      }
    }
    {
      const byte* ani_ptr=ani_base+game.ani_count*ANIMATED_OBJECTS;
      ani_table[0x78]=ani_ptr[-1];
      ani_table[0x70]=ani_ptr[-2];
      ani_table[0x1e]=ani_ptr[-3];
    }
    get_user_actions();
    collision_detect();
    game.egg_ptr=egg_seq[egg_seq_select[game.sprite_direction]+game.sprite_ani_count];
    update_screen();
    vsync();
    set_screen();
    if(game.status!=OK)
    {
      if(game.status == DEAD)
      {
        game_over();
      }
      if(game.status == WIN)
      {
        game_win();
      }
      if(game.status==STOP)
      {
        break;
      }
    }
  }
  tvsync();
  *(byte *)0xffff8260UL=game.old_res;
  if(game.machine==MCH_TT)
  {
    *(word*)0xffff8262UL=game.old_tt_res;
  }
  move_sr(0x2300); /* enable vbl */
  restore();
}


int set_falcon_video(void)
{ /* Zet falcon video op ST low */
  int montab[]=
  {
    0x0000, /* DC.W %0000 0000 0000 0000 ;mono      */
    0x01A2, /* DC.W %0000 0001 1010 0010 ;color mon */
    0x0092, /* DC.W %0000 0000 1001 0010 ;vga mon   */
    0x01A2, /* DC.W %0000 0001 1010 0010 ;tv        */
  };
  int current_mode;
  int monitor;
  current_mode=setmode(-1);
  game.old_falcon_res=current_mode;
  monitor=mon_type();
  monitor&=3; /* alleen de laatste twee bits nodig */
  if(monitor==0)
  { /* monochrome monitor */
    printf("This game needs an color monitor!\n");
    return -1;
  }
  setmode(montab[monitor]);
  return 0;
}

void restore_falcon_video(void)
{
  setmode(game.old_falcon_res);
}


int init_game(void)
{
  { /* detect machine type */
    long *jar=*(long**)0x5a0;
    printf("Heartland 2.0 alpha.\n"
           "Compile time: "__TIME__" date: "__DATE__"\n"
           "Debug info:\n");
    game.joypad=0; /* geen joypad */
    game.sound=1; /* chip sound altijd aanwezig */
    game.machine=MCH_ST; /* standard hardware */
    if(jar!=NULL)
    {
      printf("Cookie Jar found!\n");
      while(*jar!=0)
      {
        if(*jar=='_MCH')
        {
          game.machine=(int)((jar[1])>>16);
          printf("Machine type: %i\n", game.machine);
          if(game.machine&1)
          { /* Mega STe doesn't have joypad, so detect Falcon and STe only */
            if((game.machine==MCH_FALCON) || (jar[1]==0x10000L))
            {
              game.joypad=1;
            }
          }
        }
        if(*jar=='_SND')
        {
          game.sound=(int)(jar[1]);
          printf("Sound hardware: %i\n", game.sound);
        }
        jar+=2;
      }
    }
    else
    {
      printf("No cookie Jar found!\n");
    }
  }
  if(game.machine==MCH_FALCON)
  { /* set falcon video mode */
    if(set_falcon_video()!=0)
    {
      printf("Press any key to return to desktop\n");
      getch();
      return -1;
    }
  }
  game.music=1; /* sound effecten altijd mogelijk */
  if((game.sound&2)!=0)
  {
    game.dma_sound=work_space;
    game.music=3; /* DMA_SOUND = on */
  }
  else
  {
    game.dma_sound=NULL;
    decode(MUS_LEN, work_space, musix_pac);
    game.music=2; /* chipmusic aan */
  }
  { /* init some memory */
    { /* screen memory */
      unsigned long p=(unsigned long)intropic;
      p+=256;
      p&=0xffffff00UL;
      game.w_screen=(void *)p;
      game.w_reg=(p&0xff0000UL)+((p&0xff00UL)>>8);
      p=(unsigned long)Physbase();
      game.d_screen=(void *)p;
      memcpy((void *)p, intropic+34, 32000); /* display intropic */
      game.d_reg=(p&0xff0000UL)+((p&0xff00UL)>>8);
    }
    if(game.dma_sound!=NULL)
    { /* DMA_sound */
      unsigned long p=(unsigned long) game.dma_sound;
      unsigned long q;
      decode(SAMPLE_LEN, work_space, sample_pac);
      if(game.machine==MCH_FALCON)
      { /* init falcon sound */
        *(byte*)0xffff8934UL=0;
        *(byte*)0xffff8935UL=0;
        *(byte*)0xffff8920UL=0;
      }
      q=p;
      *(byte*)0xffff8907UL=(byte)q;
      q>>=8;
      *(byte*)0xffff8905UL=(byte)q;
      q>>=8;
      *(byte*)0xffff8903UL=(byte)q;
      q=(unsigned long)work_space+SAMPLE_LEN;
      *(byte*)0xffff8913UL=(byte)q;
      q>>=8;
      *(byte*)0xffff8911UL=(byte)q;
      q>>=8;
      *(byte*)0xffff890fUL=(byte)q;
      *(byte*)0xffff8921UL=0x81;
      *(byte*)0xffff8901UL=3;
    }
    game.musp=(void*)work_space;
  }
  game.old_screen_reg=*(unsigned long *)0xffff8200UL;
  if(game.machine==MCH_TT)
  {
    game.old_tt_res=*(word*)0xffff8262UL;
  }
  game.old_iea=*(byte*)0xfffffa07UL;
  game.old_ieb=*(byte*)0xfffffa09UL;
  game.old_ima=*(byte*)0xfffffa13UL;
  game.old_imb=*(byte*)0xfffffa15UL;
  game.old_eoim=*(byte*)0xfffffa17UL;
  game.old_tdc=*(byte*)0xfffffa1dUL;
  game.old_tdd=*(byte*)0xfffffa25UL;
  game.old_res=*(byte*)0xffff8260UL;
  game.old_vbl=*(void **)0x70;
  game.old_timer_d=*(void**)0110;
  game.old_kbd=*(void **)0x118;
  game.old_trap3=*(void **)0x8c;
  game.ridel=NULL;
  game.current_teleport=teleport;
  game.deck_p=deck;
  game.x_pos=9;
  game.y_pos=8;
  game.x_offs=X_BASE;
  game.y_offs=0;
  game.ani_count=0;
  game.object_count=0;
  game.forced_move=0;
  game.rasters=0;
  game.score=0;
  game.kaarten=0;
  game.sazzy=0;
  game.life=MAX_LIFE;
  game.status=OK;
  game.sprite_direction=0;
  game.sprite_ani_count=0;
  memcpy(game.old_colors, (void *)0xffff8240UL, 32);
  memcpy((void *)0xffff8240UL, intropic+2, 32); /* display intropic */
  game.key_conv=Keytbl((void*)-1,(void*)-1,(void*)-1)->unshift;
  Bconout(4, 0x12); /* disable mouse */
  Vsync();
  Vsync();
  Vsync();
  Vsync();
  Vsync(); /* Voodoo code */
  { /* flush keyboard, init interrupts */
    byte *p=(byte *)0xfffffc00UL;
    move_sr(0x2700);
    while(*p&1)
    {
      game.x_pos=p[2];
    }
    *(void**)0x70=vbl_code;
    *(void**)0x8c=trap3_handler;
    *(void**)0x110=timer_d_code;
    *(void**)0x118=key_interrupt;
    *(byte*)0xfffffa07UL=0;
    *(byte*)0xfffffa09UL=0x50; /* keyboard and timer d intterupt needed */
    *(byte*)0xfffffa13UL=0;    /* interrupt mask */
    *(byte*)0xfffffa15UL=0x50; /* keyboard and timer d intterupt needed */
    *(byte*)0xfffffa17UL=game.old_eoim&0xf0;
    *(byte*)0xfffffa1dUL=7;    /* timer d control */
    *(byte*)0xfffffa25UL=246;  /* timer d data */
  }
  move_sr(STD_SR);
  return 0;
}

void restore(void)
{
  move_sr(0x2700);
  { /* flush keyboard */
    byte *p=(byte *)0xfffffc00UL;
    while(*p&1)
    {
      game.x_offs=p[2];
    }
  }
  {
    byte *p=(byte *)0xfffffa00UL;
    p[0x0b]=0;
    p[0x0d]=0;
    p[0x0f]=0;
    p[0x11]=0;
    p[0x07]=game.old_iea;
    p[0x09]=game.old_ieb;
    p[0x17]=game.old_eoim;
    p[0x13]=game.old_ima;
    p[0x15]=game.old_imb;
    p[0x1d]=game.old_tdc;
    p[0x25]=game.old_tdd;
  }
  *(void **)0x118=game.old_kbd;
  *(void **)0x70=game.old_vbl;
  *(void **)0x110=game.old_timer_d;
  *(void **)0x8c=game.old_trap3;
  {
    byte *p=(byte*)0xffff8800UL;
    *p=8;
    p[2]=0;
    *p=9;
    p[2]=0;
    *p=10;
    p[2]=0;
  }
  if(game.music==3)
  {
    *(byte*)0xffff8901UL=0;
  }
  *(unsigned long *)0xffff8200UL=game.old_screen_reg;
  memcpy((void *)0xffff8240UL, game.old_colors, 32);
  restore_falcon_video();
  move_sr(0x2300);
  Bconout(4, 0x08); /* enable mouse */
  Vsync();
  Vsync();
  Vsync();
  Vsync();
  Vsync();
}

void vsync(void)
{
  if(game.rasters)
  {
    *(word *)0xffff8240UL=0x700;
  }
  {
    byte reg;
    long base;
    base=*(byte*)0xffff8201UL;
    base<<=8;
    base+=*(byte*)0xffff8203UL;
    base<<=8;
    base+=32000;
    reg=(base>>16)&0xff;
    while(*(byte*)0xffff8205UL!=reg)
    {
      (void)0;
    }
    reg=(base>>8)&0xff;
    while(*(byte*)0xffff8207UL!=reg)
    {
      (void)0;
    }
  }
  *(word *)0xffff8240UL=0x00;
}

void tvsync(void)
{
  game.vbl_count=1;
  while(game.vbl_count>0)
  {
    ;
  }
}

void get_user_actions(void)
{
  byte k;
  move_sr(0x2700);
  k=key_info.last_key;
  key_info.last_key=0;
  move_sr(STD_SR);
  if(k<128)
  {
    k=game.key_conv[k];
    switch(k)
    {
    case 27: /* escape */
      game.status=STOP;
      break;
    case 'c': /* toggle sizzy and sazzy */
      s2s();
      break;
    case 'h': /* toggle 50/60 Hz */
      if(game.machine<=MCH_STE) /* alleen voor ST's */
      {
        *(byte*)0xffff820aUL^=2;
      }
      break;
    case 'm': /* show map */
      show_map();
      break;
    case 'r': /* toggle rasters */
      game.rasters^=1;
      break;
    case 's': /* toggle sound */
      if(game.music==3)
      {
        move_sr(0x2700);
        game.music=0;
        move_sr(STD_SR);
        decode(MUS_LEN, work_space, musix_pac);
        move_sr(0x2700);
        game.musp=(void*)work_space;
        game.music=2;
        *(byte*)0xffff8901UL=0;
        move_sr(STD_SR);
      }
      else
      {
        if((--game.music)<0)
        {
          if(game.dma_sound!=NULL)
          { /* play DMA sound */
            move_sr(0x2700);
            game.music=3;
            move_sr(STD_SR);
            decode(SAMPLE_LEN, work_space, sample_pac);
            *(byte*)0xffff8901UL=3; /* sound on */
          }
          else
          {
            game.music=2;
          }
        }
      }
      break;
    case 'w':
      {
        byte tmp;
        tmp=key_info.last_key;
        while((tmp==0) || (tmp>127))
        {
          tmp=key_info.last_key;
        }
      }
      break;
      default:
      break;
    }
  }
  game.user_direction=key_info.joy2;
  game.user_direction|=key_info.joy1;
  game.user_direction|=read_joypad_a();
}

void wis_teleport(signed char* map)
{
  word pos=(word)(map-game_map);
  byte* q=orig_block+game.object_count;
  word* r=pos_block+game.object_count;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  map+=MAPLEN-4;
  pos+=MAPLEN-4;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  map+=MAPLEN-4;
  pos+=MAPLEN-4;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  *q++=*map;
  *r++=pos++;
  *map++=LUCHT;
  memset(new_block+game.object_count, LUCHT, 12);
  game.object_count+=12;
}

void wis_teleport2(signed char* map)
{
  int old_musmode;
  move_sr(0x2700);
  old_musmode=game.music;
  if(game.music==3)
  {
    *(byte*)0xffff8901UL=0;
  }
  if(game.music!=0)
  {
    game.music=1;
  }
  move_sr(STD_SR);
  decode(CARD_LEN, work_space, card_pac);
  move_sr(0x2700);
  game.ridel=work_space;
  game.ridelend=work_space+CARD_LEN;
  move_sr(STD_SR);
  *map++=LUCHT;
  *map++=LUCHT;
  *map++=LUCHT;
  *map++=LUCHT;
  map+=MAPLEN-4;
  *map++=LUCHT;
  *map++=LUCHT;
  *map++=LUCHT;
  *map++=LUCHT;
  map+=MAPLEN-4;
  *map++=LUCHT;
  *map++=LUCHT;
  *map++=LUCHT;
  *map++=LUCHT;
  game.x_offs=X_BASE;
  game.y_offs=0;
  game.x_pos=*game.current_teleport++;
  game.y_pos=*game.current_teleport++;
  game.jump=0;
  kaarten(*game.deck_p++);
  do_starfield();
  move_sr(0x2700);
  game.music=0;
  move_sr(STD_SR);
  if(old_musmode==3)
  { /* depack dma */
    decode(SAMPLE_LEN, work_space, sample_pac);
  }
  else
  { /* depack chip */
    decode(MUS_LEN, work_space, musix_pac);
  }
  move_sr(0x2700);
  game.music=old_musmode;
  if(game.music==3)
  {
    *(byte*)0xffff8901UL=3; /* sound on */
  }
  move_sr(STD_SR);
}

void special_kaart(int nr)
{
  int old_musmode;
  move_sr(0x2700);
  old_musmode=game.music;
  if(game.music==3)
  {
    *(byte*)0xffff8901UL=0;
  }
  if(game.music!=0)
  {
    game.music=1;
  }
  move_sr(STD_SR);
  decode(CARD_LEN, work_space, card_pac);
  move_sr(0x2700);
  game.ridel=work_space;
  game.ridelend=work_space+CARD_LEN;
  move_sr(STD_SR);
  kaarten(nr);
  move_sr(0x2700);
  game.music=0;
  move_sr(STD_SR);
  if(old_musmode==3)
  { /* depack dma */
    decode(SAMPLE_LEN, work_space, sample_pac);
  }
  else
  { /* depack chip */
    decode(MUS_LEN, work_space, musix_pac);
  }
  move_sr(0x2700);
  game.music=old_musmode;
  if(game.music==3)
  {
    *(byte*)0xffff8901UL=3; /* sound on */
  }
  move_sr(STD_SR);
}


void collision_detect(void)
{
  /* 
  //  first handle y direction
  //  if jump>0  ;er wordt gejumped
  //    y+=jump_delta
  //    jump--
  //  else
  //    kijk of gaan vallen
  //    zo niet begin sprong?
  //  vervolgens x richting
  //  if forced_x<0
  //    detect +- x beweging
  */
  /* positie van linkervoet van sprite */
  signed char* map=game_map+((long)game.x_pos)+ 10 +(((long)game.y_pos+6)*MAPLEN);
  signed char* map2;
  int spritedir=0;
  if(game.jump>0)
  { /* bezig met jump */
    if(--game.y_offs<0)
    {
      game.y_offs+=4;
      if((--game.y_pos)<0)
      {
        game.y_pos=0;
      }
    }
    game.jump--;
    spritedir=JOY_UP;
  }
  else
  { /* staan we op vaste grond? */
    if(game.y_offs>0)
    { /* y_offs > 0 => we zijn in de lucht */
      if(++game.y_offs>=4)
      {
        game.y_offs-=4;
        game.y_pos++;
      }
      spritedir=JOY_UP;
    }
    else
    { /* we zouden op vaste grond kunnen staan */
      int data;
      char element;
      data=*map;
      element=y_info[data];
      if((element!=SOLID) && (game.x_offs!=X_BASE))
      { /* second try... */
        data=map[-1];
        if(y_info[data]==SOLID)
        {
          element=SOLID;
        }
      }
      switch(element)
      {
        default:
      case AIR:
        game.forced_move=0;
        if(++game.y_offs>=4)
        {
          game.y_offs-=4;
          game.y_pos++;
        }
        spritedir=JOY_UP;
        break;
      case SOLID:
        game.forced_move=0;
        if((game.user_direction & (JOY_UP|JOY_FIRE))!=0)
        { /* jump! */
          if(--game.y_offs<0)
          {
            game.y_offs+=4;
            if((--game.y_pos)<0)
            {
              game.y_pos=0;
            }
          }
          game.sprite_ani_count=EGG_ANI_LEN-1;
          game.jump=JUMP_HEIGHT*4-1;
          spritedir=JOY_UP;
        }
        break;
      case FD_LEFT:
        game.forced_move=-1;
        if(++game.y_offs>=4)
        {
          game.y_offs-=4;
          game.y_pos++;
        }
        spritedir=JOY_UP;
        break;
      case FD_RIGHT:
        game.forced_move=1;
        if(++game.y_offs>=4)
        {
          game.y_offs-=4;
          game.y_pos++;
        }
        spritedir=JOY_UP;
        break;
      }
    }
  }
  /* nu x richting */
  map=game_map+((long)game.x_pos)+ 10 +(((long)game.y_pos+6)*MAPLEN);
  do
  {
    if(game.forced_move!=0)
    { /* forced move */
      if(game.forced_move<0)
      { /* move links */
        if(--game.x_offs<0)
        {
          game.x_offs+=4;
          game.x_pos--;
        }
        spritedir|=JOY_LEFT;
        break;
      }
      else
      { /* move rechts */
        if(++game.x_offs>=4)
        {
          game.x_offs-=4;
          game.x_pos+=1;
        }
        spritedir|=JOY_RIGHT;
        break;
      }
    }
    if(game.user_direction&JOY_RIGHT)
    { /* go right? */
      if(game.x_offs==X_BASE)
      { /* alleen moeilijk doen op deze positie */
        char element;
        int data;
        if(game.y_offs==0)
        {
          data=map[-MAPLEN+1];
        }
        else
        {
          data=map[1];
        }
        element=x_info[data];
        if(element==SOLID)
        {
          break;
        }
      }
      if(++game.x_offs>=4)
      {
        game.x_offs-=4;
        game.x_pos++;
      }
      spritedir|=JOY_RIGHT;
    }
    else
    {
      if(game.user_direction&JOY_LEFT)
      { /* go left? */
        if(game.x_offs==X_BASE)
        { /* alleen moeilijk doen op deze positie */
          char element;
          int data;
          if(game.y_offs==0)
          {
            data=map[-MAPLEN-1];
          }
          else
          {
            data=map[-1];
          }
          element=x_info[data];
          if(element==SOLID)
          {
            break;
          }
        }
        if(--game.x_offs<0)
        {
          game.x_offs+=4;
          game.x_pos-=1;
        }
        spritedir|=JOY_LEFT;
      }
    }
  }
  while(0);
  { /* handle a part of sprite animation */
    if(game.sprite_direction!=spritedir)
    { /* new animation, reset counter */
      game.sprite_direction=spritedir;
      game.sprite_ani_count=EGG_ANI_LEN-1;
    }
    else
    {
      if((game.maincount&3)==0)
      {
        if(--game.sprite_ani_count<0)
        {
          game.sprite_ani_count=EGG_ANI_LEN-1;
        }
      }
    }
  }
  { /* als laatste detectie van special opjects */
    char element;
    int data;
    map=game_map+((long)game.x_pos)+ 10 +(((long)game.y_pos+5)*MAPLEN);
    map2=game_map2+((long)game.x_pos)+ 10 +(((long)game.y_pos+5)*MAPLEN);
    data=*map;
    element=x_info[data];
    switch(element)
    {
    case FLES:
      game.life+=FLES_LIFE;
      if(game.life>MAX_LIFE)
      {
        game.life=MAX_LIFE;
      }
      move_sr(0x2700);
      game.ridel=pjoew;
      game.ridelend=pjoew_end;
      move_sr(STD_SR);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=LEGE_FLES;
      *map=LEGE_FLES;
      *map2=LEGE_FLES;
      break;
    case MUNT:
      game.score+=COIN_SCORE;
      move_sr(0x2700);
      game.ridel=rinkel;
      game.ridelend=rinkel_end;
      move_sr(STD_SR);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=LUCHT;
      *map=LUCHT;
      *map2=LUCHT;
      break;
    case PUNT:
      {
        if(game.y_offs==0)
        { /* alleen schadelijk op nul level */
          game.life--;
          move_sr(0x2700);
          game.ridel=ploef;
          game.ridelend=ploef_end;
          move_sr(STD_SR);
        }
        break;
      }
    case AAS:
      special_kaart(0);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case KONING:
      special_kaart(1);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case QUEEN:
      special_kaart(2);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case JACK:
      special_kaart(3);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    default:
      break;
    }
    map-=MAPLEN;
    map2-=MAPLEN;
    data=*map;
    element=x_info[data];
    switch(element)
    {
    case FLES:
      game.life+=FLES_LIFE;
      move_sr(0x2700);
      game.ridel=pjoew;
      game.ridelend=pjoew_end;
      move_sr(STD_SR);
      if(game.life>MAX_LIFE)
      {
        game.life=MAX_LIFE;
      }
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=LEGE_FLES;
      *map=LEGE_FLES;
      *map2=LEGE_FLES;
      break;
    case MUNT:
      game.score+=COIN_SCORE;
      move_sr(0x2700);
      game.ridel=rinkel;
      game.ridelend=rinkel_end;
      move_sr(STD_SR);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=LUCHT;
      *map=LUCHT;
      *map2=LUCHT;
      break;
    case AAS:
      special_kaart(0);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case KONING:
      special_kaart(1);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case QUEEN:
      special_kaart(2);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case JACK:
      special_kaart(3);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    default:
      break;
    }
  }
  if(game.x_offs!=X_BASE)
  { 
    /* 
      ook ff links detectie van de special objects, 
      behalve teleports, die komen altijd van rechts 
    */
    char element;
    int data;
    map+=MAPLEN-1;
    map2+=MAPLEN-1;
    data=*map;
    element=x_info[data];
    switch(element)
    {
    case FLES:
      game.life+=FLES_LIFE;
      move_sr(0x2700);
      game.ridel=pjoew;
      game.ridelend=pjoew_end;
      move_sr(STD_SR);
      if(game.life>MAX_LIFE)
      {
        game.life=MAX_LIFE;
      }
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=LEGE_FLES;
      *map=LEGE_FLES;
      *map2=LEGE_FLES;
      break;
    case MUNT:
      game.score+=COIN_SCORE;
      move_sr(0x2700);
      game.ridel=rinkel;
      game.ridelend=rinkel_end;
      move_sr(STD_SR);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=LUCHT;
      *map=LUCHT;
      *map2=LUCHT;
      break;
    case PUNT:
      if(game.y_offs==0)
      { /* alleen schadelijk op nul level */
        game.life--;
        move_sr(0x2700);
        game.ridel=ploef;
        game.ridelend=ploef_end;
        move_sr(STD_SR);
      }
      break;
    case AAS:
      special_kaart(0);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case KONING:
      special_kaart(1);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case QUEEN:
      special_kaart(2);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case JACK:
      special_kaart(3);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
      #if 0 /* disabled to prevent jumping into a teleport form a lower level */
      case TPT_C:
        wis_teleport(map-2*MAPLEN-2);
        break;
      #endif
    case TPT_B:
      wis_teleport(map-1*MAPLEN-2);
      wis_teleport2(map2-1*MAPLEN-2);
      break;
    case TPT_A:
      wis_teleport(map-2);
      wis_teleport2(map2-2);
      break;
      default:
      break;
    }
    map-=MAPLEN;
    map2-=MAPLEN;
    data=*map;
    element=x_info[data];
    switch(element)
    {
    case FLES:
      game.life+=FLES_LIFE;
      move_sr(0x2700);
      game.ridel=pjoew;
      game.ridelend=pjoew_end;
      move_sr(STD_SR);
      if(game.life>MAX_LIFE)
      {
        game.life=MAX_LIFE;
      }
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=LEGE_FLES;
      *map=LEGE_FLES;
      *map2=LEGE_FLES;
      break;
    case MUNT:
      game.score+=COIN_SCORE;
      move_sr(0x2700);
      game.ridel=rinkel;
      game.ridelend=rinkel_end;
      move_sr(STD_SR);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=LUCHT;
      *map=LUCHT;
      *map2=LUCHT;
      break;
    case AAS:
      special_kaart(0);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case KONING:
      special_kaart(1);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case QUEEN:
      special_kaart(2);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
    case JACK:
      special_kaart(3);
      orig_block[game.object_count]=*map;
      pos_block[game.object_count]=(word)(map-game_map);
      new_block[game.object_count++]=ZAND;
      *map=ZAND;
      *map2=ZAND;
      break;
      #if 0 /* disabled to prevent jumping into a teleport form a lower level */
      case TPT_C:
        wis_teleport(map-2*MAPLEN-1);
        break;
      #endif
    case TPT_B:
      wis_teleport(map-1*MAPLEN-2);
      wis_teleport2(map2-1*MAPLEN-2);
      break;
    case TPT_A:
      wis_teleport(map-2);
      wis_teleport2(map2-2);
      break;
      default:
      break;
    }
  }
  if(game.life<=0)
  {
    game.life=0;
    game.status=DEAD;
  }
}

void set_screen(void)
{
  unsigned long tmp=game.w_reg;
  unsigned long *tmp2;
  *(unsigned long *)0xffff8200UL=tmp;
  game.w_reg=game.d_reg;
  game.d_reg=tmp;
  tmp2=game.w_screen;
  game.w_screen=game.d_screen;
  game.d_screen=tmp2;
}

void show_map(void)
{
  word *p=(void*)game.w_screen;
  signed char *map=game_map;
  int i;
  int doors=0;
  int coins=0;
  memset(game.w_screen, 0, 32000);
  vsync();
  set_screen();
  memcpy((void*)0xffff8240UL, mapcolors, 32);
  i=100-4;
  p+=4;
  while(--i>=0)
  {
    int j=17;
    while(--j>=0)
    {
      word pl0=0;
      word pl1=0;
      word pl2=0;
      word pl3=0;
      int k=16;
      while(--k>=0)
      {
        char color;
        int data;
        data=*map++;
        color=color_info[data];
        if(color==C_MUNT)
        {
          coins++;
        }
        else
        {
          if(color==C_DEUR)
          {
            doors++;
          }
        }
        pl0+=pl0;
        pl1+=pl1;
        pl2+=pl2;
        pl3+=pl3;
        if(color&1)
        {
          pl0++;
        }
        if(color&2)
        {
          pl1++;
        }
        if(color&4)
        {
          pl2++;
        }
        if(color&8)
        {
          pl3++;
        }
      }
      *p++=pl0;
      *p++=pl1;
      *p++=pl2;
      *p++=pl3;
    }
    map+=MAPLEN-(17*16);
    p+=3*4;
  }
  p+=9*80;
  i=100-5;
  map=game_map+2*MAPLEN-(17*16);
  while(--i>=0)
  {
    int j=17;
    while(--j>=0)
    {
      word pl0=0;
      word pl1=0;
      word pl2=0;
      word pl3=0;
      int k=16;
      while(--k>=0)
      {
        char color;
        int data;
        data=*map++;
        color=color_info[data];
        if(color==C_MUNT)
        {
          coins++;
        }
        else
        {
          if(color==C_DEUR)
          {
            doors++;
          }
        }
        pl0+=pl0;
        pl1+=pl1;
        pl2+=pl2;
        pl3+=pl3;
        if(color&1)
        {
          pl0++;
        }
        if(color&2)
        {
          pl1++;
        }
        if(color&4)
        {
          pl2++;
        }
        if(color&8)
        {
          pl3++;
        }
      }
      *p++=pl0;
      *p++=pl1;
      *p++=pl2;
      *p++=pl3;
    }
    map+=MAPLEN-(17*16);
    p+=3*4;
  }
  {
    char txt[40];
    sprintf(txt,"Coins: %3i",coins);
    print(txt, game.d_screen+97*40+2, C_MUNT);
    sprintf(txt,"MAP");
    print(txt, game.d_screen+97*40+2*9, C_GRAS);
    sprintf(txt,"Doors: %i",(doors/9));
    print(txt, game.d_screen+97*40+2*14, C_DEUR);
  }
  move_sr(0x2700);
  key_info.last_key=0xff;
  move_sr(STD_SR);
  while((key_info.last_key>127)&&((read_joypad_a()|key_info.joy0|key_info.joy1|key_info.joy2)<128))
  { /* wait */
    vsync();
  }
  move_sr(0x2700);
  key_info.joy0&=0x7f;
  key_info.joy1&=0x7f;
  key_info.joy2&=0x7f;
  key_info.last_key=0;
  move_sr(STD_SR);
  vsync();
  set_screen();
  memcpy((void*)0xffff8240UL, gamecolors, 32);
  memcpy(game.w_screen, game.d_screen, 32000);
}


byte jptab[]=
{
  0,                   /* 0000         1111      nix           */
  0,                   /* 0001         1110      nix           */
  0,                   /* 0010         1101      nix           */
  0,                   /* 0011         1100      nix           */
  0,                   /* 0100         1011      nix           */
  JOY_RIGHT|JOY_DOWN,  /* 0101         1010      right & down  */
  JOY_RIGHT|JOY_UP,    /* 0110         1001      right & up    */
  JOY_RIGHT,           /* 0111         1000      right         */
  0,                   /* 1000         0111      nix           */
  JOY_LEFT|JOY_DOWN,   /* 1001         0110      left & down   */
  JOY_LEFT|JOY_UP,     /* 1010         0101      left & up     */
  JOY_LEFT,            /* 1011         0100      left          */
  0,                   /* 1100         0011      nix           */
  JOY_DOWN,            /* 1101         0010      down          */
  JOY_UP,              /* 1110         0001      up            */
  0,                   /* 1111 ~Joypad code   -> joystick code */
};


byte read_joypad_a(void)
{
  if(game.joypad)
  { /* falcon or STe */
    byte data;
    *(byte*)0xffff9203UL=0xee; /* write register */
    data=*(byte*)0xffff9202UL; /* read data */
    data=jptab[data&0x0f];
    *(byte*)0xffff9203UL=0xee; /* write register */
    data|=(~*(byte*)0xffff9201UL)<<6;
    return data;
  }
  else
  {
    return 0;
  }
}

void kaarten(int newcard)
{
  int i;
  decode(8960L, work_space+16384, carddata_pac);
  game.kaarten++;
  if(game.kaarten==13)
  {
    game.status=WIN;
  }
  memcpy(game.w_screen, game.d_screen, 32000); /* copy display screen naar werk screen */
  scr2sb(game.d_screen+14*40, work_space+32000); /* save screen */
  vsync();
  for(i=130;i<(130+130+95);i++)
  {
    int j;
    sb2scr(work_space+32000, game.w_screen+14*40);
    for(j=0;j<13;j++)
    {
      card2scr(baan[i-j*10], work_space+16384+game.card_status[j], game.w_screen+14*40+6+j*2);
    }
    vsync();
    set_screen();
  }
  {
    int i_magic=20*newcard+20+485;
    for(i=485;i<(485+260+40);i++)
    {
      int j;
      if(i==i_magic)
      {
        game.card_status[newcard]=(newcard+1)*640;
      }
      sb2scr(work_space+32000, game.w_screen+14*40);
      for(j=0;j<13;j++)
      {
        card2scr(baan[i-j*20], work_space+16384+game.card_status[j], game.w_screen+14*40+6+j*2);
      }
      vsync();
      set_screen();
    }
  }
  for(i=785;i<(785+55+130);i++)
  {
    int j;
    sb2scr(work_space+32000, game.w_screen+14*40);
    for(j=0;j<13;j++)
    {
      card2scr(baan[i-j*10], work_space+16384+game.card_status[j], game.w_screen+14*40+6+j*2);
    }
    vsync();
    set_screen();
  }
}

/* a0 = coordinaten pointer (x, y*64) == aanroep  */
#define STAR_COUNT 1650UL
static int stars[STAR_COUNT*2];

void make_stardata(void)
{
  int i;
  int *p=stars;
  for(i=0;i<STAR_COUNT;i++)
  {
    int x;
    int y;
    do
    {
      x=160-random(320);
      y=80-random(160);
    }
    while((x*x+y*y)<(30*30));
    *p++=x;
    *p++=y<<6;
  }
}

static char  he_land[]=" Where will he land?";
static char she_land[]="Where will she land?";

void do_starfield(void)
{
  int i;
  int old_x=game.x_pos;
  int old_y=game.y_pos;
  int ani_count=EGG_ANI_LEN-1;
  make_stardata();
  memset(game.w_screen+14*40, 0, 160*160);
  memset(game.d_screen+14*40, 0, 160*160);
  /* fake sprite pos for clear view */
  game.x_pos=9;
  game.y_pos=8;
  if(game.sazzy==0)
  {
    print(he_land, game.w_screen+53*40+10, 8);
    print(he_land, game.d_screen+53*40+10, 8);
  }
  else
  {
    print(she_land, game.w_screen+53*40+10, 8);
    print(she_land, game.d_screen+53*40+10, 8);
  }
  for(i=0;i<(STAR_COUNT-400);i+=5)
  {
    {
      int j;
      for(j=0;j<22;j++)
      {
        memset(game.w_screen+(13+6*16-j)*40+18, 0, 16);
      }
    }
    starfield(stars+i+i, game.w_screen+14*40+80*40+20);
    if((i&1)==0)
    {
      if(++ani_count==EGG_ANI_LEN)
      {
        ani_count=0;
      }
    }
    game.egg_ptr=egg_seq[egg_seq_select[JOY_DOWN]+ani_count];
    draw_main_sprite();
    vsync();
    set_screen();
  }
  /* restore sprite pos */
  game.x_pos=old_x;
  game.y_pos=old_y;
}

void schudden(void)
{
  int i;
  srand((unsigned)Random());
  for(i=0;i<81;i++)
  {
    /* eerst teleport */
    int src=random(9)<<1;
    int dst=random(9)<<1;
    int tmp=teleport[src];
    teleport[src]=teleport[dst];
    teleport[dst]=tmp;
    src++;
    dst++;
    tmp=teleport[src];
    teleport[src]=teleport[dst];
    teleport[dst]=tmp;
    /* dan kaarten */
    src=random(9);
    dst=random(9);
    tmp=deck[src];
    deck[src]=deck[dst];
    deck[dst]=tmp;
  }
}


void s2s(void)
{ /* maak van sizzy sassy en omgekeerd */
  int i;
  word *p=(void*)eggs;
  game.sazzy^=1; /* swicth gender */
  p+=2;
  for(i=0;i<33;i++)
  {
    int j;
    for(j=0;j<22;j++)
    {
      p[1]^=(~p[2])&(p[0]&p[3]);
      p+=4;
      p[1]^=(~p[2])&(p[0]&p[3]);
      p+=6;
    }
  }
}

void game_win(void)
{
  int old_musmode;
  int score=game.score;
  {
    move_sr(0x2700);
    old_musmode=game.music;
    if(game.music==3)
    {
      *(byte*)0xffff8901UL=0;
    }
    if(game.music!=0)
    {
      game.music=1;
    }
    move_sr(STD_SR);
    decode(32034, work_space, endpic_pac);
    memcpy(game.w_screen, work_space+34, 32000);
    #if 0
    {
      print("Well done, you have", game.w_screen+16*8*40+120+10, 4);
      print(" a new highscore!!", game.w_screen+17*8*40+200+10, 4);
      print("Enter your name: ", game.w_screen+18*8*40+280+10, 4);
    }
    #endif
    set_screen();
    vsync();
    memcpy((void *)0xffff8240UL, work_space+2, 32);
    decode(WELLDONE_LEN, work_space, welldone_pac);
    move_sr(0x2700);
    game.ridel=work_space;
    game.ridelend=work_space+WELLDONE_LEN;
    move_sr(STD_SR);
  }
  { /* restore game maps */
    int i;
    for(i=0; i<game.object_count; i++)
    {
      game_map[pos_block[i]]=orig_block[i];
      game_map2[pos_block[i]]=orig_block[i];
    }
    game.current_teleport=teleport;
    game.deck_p=deck;
    game.x_pos=9;
    game.y_pos=8;
    game.x_offs=X_BASE;
    game.y_offs=0;
    game.ani_count=0;
    game.object_count=0;
    game.forced_move=0;
    game.rasters=0;
    game.score=0;
    game.kaarten=0;
    game.life=MAX_LIFE;
    game.sprite_direction=0;
    game.sprite_ani_count=0;
    game.status=OK;
    memset(game.card_status, 0, sizeof(game.card_status));
    schudden();
  }
  { /* wachten */
    int cond;
    move_sr(0x2700);
    key_info.last_key=0xff;
    move_sr(STD_SR);
    vsync();
    do
    {
      vsync();
      move_sr(0x2700);
      cond=((key_info.last_key>127)
           &&((read_joypad_a()|key_info.joy0|key_info.joy1|key_info.joy2)<128));
      move_sr(STD_SR);
    }
    while(cond!=0);
  }
  { /* restart game */
    move_sr(0x2700);
    game.ridel=NULL;
    game.music=0;
    move_sr(STD_SR);
    if(old_musmode==3)
    { /* depack dma */
      decode(SAMPLE_LEN, work_space, sample_pac);
    }
    else
    { /* depack chip */
      decode(MUS_LEN, work_space, musix_pac);
    }
    move_sr(0x2700);
    game.music=old_musmode;
    if(game.music==3)
    {
      *(byte*)0xffff8901UL=3; /* sound on */
    }
    move_sr(STD_SR);
    move_sr(0x2700);
    game.musp=(void*)work_space;
    game.ridel=ploing;
    game.ridelend=ploing_end;
    move_sr(STD_SR);
    memcpy(game.w_screen+40*187, balk, 160*13);
    memcpy(game.w_screen, wolk, 160*14);
    memcpy(game.w_screen+(FULL_LINES)*16*40+14*40, wolk, 160*13);
    memcpy(game.d_screen, game.w_screen, 32000);
    memcpy((void*)0xffff8240UL, gamecolors, 32);
  }
}

void game_over(void)
{
  int old_musmode;
  {
    move_sr(0x2700);
    old_musmode=game.music;
    if(game.music==3)
    {
      *(byte*)0xffff8901UL=0;
    }
    if(game.music!=0)
    {
      game.music=1;
    }
    move_sr(STD_SR);
    decode(32034, work_space, dead_pac);
    memcpy(game.w_screen, work_space+34, 32000);
    set_screen();
    vsync();
    memcpy((void *)0xffff8240UL, work_space+2, 32);
    decode(GAMEOVER_LEN, work_space, gameover_pac);
    move_sr(0x2700);
    game.ridel=work_space;
    game.ridelend=work_space+GAMEOVER_LEN;
    move_sr(STD_SR);
  }
  { /* restore game maps */
    int i;
    for(i=0; i<game.object_count; i++)
    {
      game_map[pos_block[i]]=orig_block[i];
      game_map2[pos_block[i]]=orig_block[i];
    }
    game.current_teleport=teleport;
    game.deck_p=deck;
    game.x_pos=9;
    game.y_pos=8;
    game.x_offs=X_BASE;
    game.y_offs=0;
    game.ani_count=0;
    game.object_count=0;
    game.forced_move=0;
    game.rasters=0;
    game.score=0;
    game.kaarten=0;
    game.life=MAX_LIFE;
    game.sprite_direction=0;
    game.sprite_ani_count=0;
    game.status=OK;
    memset(game.card_status, 0, sizeof(game.card_status));
    schudden();
  }
  { /* wachten */
    int cond;
    move_sr(0x2700);
    key_info.last_key=0xff;
    move_sr(STD_SR);
    vsync();
    do
    {
      vsync();
      move_sr(0x2700);
      cond=(game.ridel!=NULL)&&((key_info.last_key>127)
           &&((read_joypad_a()|key_info.joy0|key_info.joy1|key_info.joy2)<128));
      move_sr(STD_SR);
    }
    while(cond!=0);
  }
  { /* restart game */
    move_sr(0x2700);
    game.ridel=NULL;
    game.music=0;
    move_sr(STD_SR);
    if(old_musmode==3)
    { /* depack dma */
      decode(SAMPLE_LEN, work_space, sample_pac);
    }
    else
    { /* depack chip */
      decode(MUS_LEN, work_space, musix_pac);
    }
    move_sr(0x2700);
    game.music=old_musmode;
    if(game.music==3)
    {
      *(byte*)0xffff8901UL=3; /* sound on */
    }
    move_sr(STD_SR);
    move_sr(0x2700);
    game.musp=(void*)work_space;
    game.ridel=ploing;
    game.ridelend=ploing_end;
    move_sr(STD_SR);
    memcpy(game.w_screen+40*187, balk, 160*13);
    memcpy(game.w_screen, wolk, 160*14);
    memcpy(game.w_screen+(FULL_LINES)*16*40+14*40, wolk, 160*13);
    memcpy(game.d_screen, game.w_screen, 32000);
    memcpy((void*)0xffff8240UL, gamecolors, 32);
  }
}

