/*============================================================================================*/
/* RG.TESTGAME                                                                                */
/*
/* This is a very quick demonstration of my Falcon libraries!
/*
/* Comments & Queries : mrpink.rg@zetnet.co.uk
/*============================================================================================*/

#pragma warn -pro
#pragma warn -ucp
#pragma warn -sig
#pragma warn -rng
#pragma warn -sus
#pragma warn -cln

#include "d:\gods\library\pure_c.lib\base.h"
#include "d:\gods\library\pure_c.lib\screen.h"
#include "d:\gods\library\pure_c.lib\vector.h"
#include "d:\gods\library\pure_c.lib\keyboard.h"
#include "d:\gods\library\pure_c.lib\depack.h"
#include "d:\gods\library\pure_c.lib\disk.h"
#include "d:\gods\library\pure_c.lib\sound.h"
#include "d:\gods\library\pure_c.lib\tracker.h"

#include <string.h>
#include "testgame.h"

void test_loop();
void load_all_files();
void init_screen_space();
void init_game();

void restore_sprites();
void add_sprite(SPRITE_STRUCT * s_ptr);
void draw_sprites();
void do_ikbd();

void main()
{
 Super(0);
 rlvc_open_system();
 rlkb_open_keyboard();
/* rlkb_debug_on();        un-rem this for debuggers! */
 rlsc_open_video();
 rlsd_open_sound();
 rltrk_open_tracker();

 init_screen_space();
 load_all_files();
 test_loop();
 
 rltrk_close_tracker();
 rlsd_close_sound();
 rlsc_close_video();	
 rlkb_close_keyboard();
 rlvc_close_system();
}

void load_all_files()
{
 backscreen=load_allocate_file("BACKSCRN.GOD");  /* background gfx */
 sprite1=load_allocate_file("SPRITE1.GOD");      /* sprite */
}

/*============================================================================================*/
/* Screen Routines                                                                            */
/*============================================================================================*/

void init_screen_space()
{

/* Reserve memory for screen buffers */

 my_screen_space=(U32)(calloc((640L*240L*2L)+255L,1)); 
 my_screen_space=(((my_screen_space)+255L)&0x00FFFF00L);
 my_physic=my_screen_space;
 my_logic=(my_physic + (640L*240L));

/* Set new physical screen */

 rlsc_set_new_physic(my_physic);
 rlvc_wait_vbl();

/* Set videl mode: 320x240xTrueColour */

 rlsc_set_screen_mode(320,240,4);
}

void swap_screens()
{
 U32 temp;
 PHYSLOG_STRUCT * pl_temp;

/* Swap physic & logic screens */

 temp=my_physic;
 my_physic=my_logic;
 my_logic=temp;

/* Swap physic/logic data blocks containing sprite infos etc. */

 pl_temp=pl_physic_ptr;
 pl_physic_ptr=pl_logic_ptr;
 pl_logic_ptr=pl_temp;

/* set new physical screen and wait for vertical blank */

 rlsc_set_screen_address(my_physic);
 rlsc_set_new_physic(my_physic);
 rlvc_wait_vbl();
}


/*============================================================================================*/
/* Game Routines                                                                            */
/*============================================================================================*/

void init_game()
{

/* Flush sprite restore buffers */

 physlog1.sprites=0;
 physlog2.sprites=0;

/* Copy godpaint gfx to screen */

 memcpy((void *)my_logic,backscreen->data,640L*240L);
 memcpy((void *)my_physic,backscreen->data,640L*240L);

/* Initialise a single sprite */

 my_sprites[0].x=(ScreenX>>1)-(sprite1->x>>1);
 my_sprites[0].y=(ScreenY>>1)-(sprite1->y>>1);
 my_sprites[0].gfx=sprite1;
}

void test_loop()
{
 U8 exit_flag=0;

 init_game();

 while(!exit_flag)
 {
  swap_screens();                       /* swap physic<->logic */
  restore_sprites();                    /* restore sprite list */
  do_ikbd();                            /* process keyboard input */
  add_sprite(&my_sprites[0]);           /* add sprite1 to list */
  draw_sprites();                       /* draw sprite list */
  if(rlkb_test_key(0x44)) exit_flag=1;  /* exit if F10 pressed */
 }
}

void do_ikbd()
{
 if(rlkb_test_key(0x4B)) my_sprites[0].x--; /* left cursor pressed */
 if(rlkb_test_key(0x4D)) my_sprites[0].x++; /* right cursor pressed */
 if(rlkb_test_key(0x48)) my_sprites[0].y--; /* up cursor pressed */
 if(rlkb_test_key(0x50)) my_sprites[0].y++; /* down cursor pressed */
}


/*============================================================================================*/
/* Sprite Routines                                                                            */
/*============================================================================================*/

void restore_sprites()
{
 U16 i,y,x;
 U16 * d_ptr, *s_ptr;
 U32 offset;
 
 for(i=0;i<pl_logic_ptr->sprites;i++)
 {

/* Offset into screen buffer */

  offset=pl_logic_ptr->rect[i].y;
  offset*=320L;
  offset+=pl_logic_ptr->rect[i].x;

  s_ptr=backscreen->data;
  d_ptr=(U16 *)my_logic;

/* Source=background gfx, dest=logical screen */

  s_ptr+=offset;
  d_ptr+=offset;

/* Restore entire sprite: */

  for(y=0;y<pl_logic_ptr->rect[i].height;y++)
  {
   for(x=0;x<pl_logic_ptr->rect[i].width;x++)
   {
    d_ptr[x]=s_ptr[x];
   }
   s_ptr+=320L;
   d_ptr+=320L;
  }
 }
 pl_logic_ptr->sprites=0;
}

void add_sprite(SPRITE_STRUCT * s_ptr)
{
 SPRITERECT_STRUCT * r_ptr;

 r_ptr=&pl_logic_ptr->rect[pl_logic_ptr->sprites++];

/* Place Sprite Info In List */

 r_ptr->x=s_ptr->x;
 r_ptr->y=s_ptr->y;
 r_ptr->width=s_ptr->gfx->x;
 r_ptr->height=s_ptr->gfx->y;
 r_ptr->gfx=s_ptr->gfx;


/* Now Clip Sprite */
 
 if(r_ptr->x < 0)
 {
  r_ptr->xclip=-r_ptr->x;
  r_ptr->width+=r_ptr->x;
  r_ptr->x=0;  
 }
 else r_ptr->xclip=0;

 if(r_ptr->x+r_ptr->width > ScreenX)
 {
  r_ptr->width=ScreenX-r_ptr->x;
 }

 if(r_ptr->y < 0)
 {
  r_ptr->yclip=-r_ptr->y;
  r_ptr->height+=r_ptr->y;
  r_ptr->y=0;  
 }
 else r_ptr->yclip=0;

 if(r_ptr->y+r_ptr->height > ScreenY)
 {
  r_ptr->height=ScreenY-r_ptr->y;
 }

/* If Sprite is clipped off screen, remove from list */

 if( (r_ptr->width <=0) || (r_ptr->height <=0) ) pl_logic_ptr->sprites--;

}

void draw_sprites()
{
 U16 i,x,y;
 U16 * s_ptr, * d_ptr;
 U32 offset; 

 for(i=0;i<pl_logic_ptr->sprites;i++)
 {

/* Offset into screen buffer */

  offset=pl_logic_ptr->rect[i].y;
  offset*=320L;
  offset+=pl_logic_ptr->rect[i].x;

  d_ptr=(U16 *)my_logic;
  d_ptr+=offset;  

/* Offset into sprite (with clipping if needed!) */

  offset=pl_logic_ptr->rect[i].yclip;
  offset*=pl_logic_ptr->rect[i].gfx->y;
  offset+=pl_logic_ptr->rect[i].xclip;

  s_ptr=&pl_logic_ptr->rect[i].gfx->data[offset];
  offset=pl_logic_ptr->rect[i].gfx->y;

/* Draw sprite */

  for(y=0;y<pl_logic_ptr->rect[i].height;y++)  
  {
   for(x=0;x<pl_logic_ptr->rect[i].width;x++)  
   {
    if(s_ptr[x]) d_ptr[x]=s_ptr[x];
   }
   d_ptr+=ScreenX;
   s_ptr+=offset;   
  }
 }

}


