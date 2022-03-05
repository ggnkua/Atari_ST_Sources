

/*  Karma, a game for the ST
 *  started 6 June 1987
 */

#include <osbind.h>
#include <vdibind.h>
#include <define.h>
#include <gemdefs.h>

#define HIDE_MOUSE graf_mouse(256,&dummy)
#define SHOW_MOUSE graf_mouse(257,&dummy)

extern struct shape
{  int num_corners; int corners[12];
      int num_neighbors; int neighbors[4];
      int owner; int renters; int update;
}  karma[];

extern int diagonal[92][4];

extern int translate[14][14];

int contrl[12],intin[256],ptsin[256],intout[256],ptsout[256]; /* GEM Stuff */
int work_in[12], work_out[57];
int handle,wind_handle,dum;
int pxy[12];
int dummy;
int box_hi, box_wide, x_offset, y_offset;
int bh_2, bw_2, xo_2, yo_2;
char *screen[2];
int cur_screen;
int rez;  /* resolution of the monitor */
int game;
int winner = 0;
int restart;
int sfx_counter = 0;
int attrib[4];
int old_colors[16];
int new_colors[] =
   {0x0777,0x0000,0x0721,0x0147,0x0656,0x0760,0x0372,0x0526,
    0x0234,0x0056,0x0775,0x0760,0x0372,0x0526,0x0234,0x0000};
int expl_colors[] =
   {0x0777,0x0000,0x0621,0x0146,0x0656,0x0760,0x0372,0x0526,
    0x0234,0x0056,0x0775,0x0760,0x0372,0x0526,0x0234,0x0000};
int cycle[6] = {0x056,0x456,0x345,0x256,0x036,0x007};
int smooth[6][4] =
   {  {0x760, 0x372, 0x526, 0x234},
      {0x700, 0x454, 0x615, 0x257},
      {0x642, 0x533, 0x434, 0x347},
      {0x553, 0x612, 0x354, 0x436},
      {0x665, 0x751, 0x373, 0x615},
      {0x776, 0x760, 0x372, 0x526}
   };
int score[3];

int start[20] =
{4,13,5,14,11,15,23,33,24,34,25,35,18,8,30,20,37,36,39,38};

int sfx[12][23] =
{ {0x006A, 0x0109, 0x02FC, 0x0308, 0x0400, 0x0500, 0x060A, 0x07EE,
   0x081E, 0x0903, 0x0A00, 0x0B17, 0x0C56, 0x0D0F, 0x8000, 0x8101,
   0x0100, 0xFF1E, 0x0800, 0x0900, 0x0A00, 0x073F, 0xFF00},

  {0x0029, 0x0101, 0x022F, 0x0301, 0x047B, 0x0500, 0x0614, 0x07F8,
   0x081A, 0x0919, 0x0A1A, 0x0B08, 0x0C20, 0x0D00, 0x8002, 0x8101,
   0x0200, 0xFF1E, 0x0800, 0x0900, 0x0A00, 0x073F, 0xFF00},

  {0x0008, 0x0102, 0x0284, 0x0303, 0x0484, 0x0503, 0x060A, 0x07F8,
   0x081A, 0x0913, 0x0A1A, 0x0BF8, 0x0C2A, 0x0D0E, 0x8000, 0x8102,
   0xFE02, 0xFF0A, 0x0800, 0x0900, 0x0A00, 0x073F, 0xFF00},

  {0x0054, 0x010D, 0x02D2, 0x0307, 0x04E9, 0x0503, 0x0614, 0x07C5,
   0x081A, 0x091D, 0x0A1A, 0x0B38, 0x0C18, 0x0D0F, 0x8002, 0x8102,
   0x0200, 0xFF0A, 0x0800, 0x0900, 0x0A00, 0x073F, 0xFF00},

  {0x00FF, 0x010F, 0x02EA, 0x0303, 0x04E9, 0x0503, 0x0614, 0x07F8,
   0x081A, 0x091D, 0x0A1A, 0x0B08, 0x0C20, 0x0D00, 0x8002, 0x8101,
   0x0200, 0xFF1E, 0x0800, 0x0900, 0x0A00, 0x073F, 0xFF00},

  {0x00E8, 0x0103, 0x02EB, 0x0303, 0x04EF, 0x0503, 0x061F, 0x07F8,
   0x0810, 0x0910, 0x0A10, 0x0BD4, 0x0C17, 0x0D04, 0xFF23, 0x0010,
   0x0101, 0xFF00},

  {0x00FF, 0x0101, 0x02FE, 0x0303, 0x04FC, 0x0507, 0x061F, 0x07F8,
   0x0810, 0x0910, 0x0A10, 0x0BB4, 0x0C46, 0x0D00, 0x8000, 0x8100,
   0x05FF, 0xFF00},

  {0x00FF, 0x0103, 0x02FF, 0x0301, 0x0442, 0x0502, 0x061F, 0x07F8,
   0x080D, 0x0910, 0x0A10, 0x0B44, 0x0C2F, 0x0D08, 0x8000, 0x8100,
   0x0AF6, 0xFF0A, 0x073F, 0x0900, 0x0A00, 0xFF00},

  {0x0043, 0x0101, 0x02C5, 0x0304, 0x04DE, 0x0501, 0x061F, 0x07F8,
   0x080C, 0x0918, 0x0A02, 0x0BF4, 0x0C65, 0x0D00, 0x803A, 0x8100,
   0x7FE8, 0x073F, 0xFF00},

  {0x0063, 0x0104, 0x025A, 0x0304, 0x046E, 0x0504, 0x0601, 0x07F0,
   0x081C, 0x091A, 0x0A1E, 0x0BFC, 0x0C3A, 0x0D00, 0xFF00},

  {0x0043, 0x0101, 0x0244, 0x0301, 0x0408, 0x0501, 0x0601, 0x07F8,
   0x081C, 0x091A, 0x0A1E, 0x0B54, 0x0C01, 0x0D0A, 0xFF28, 0x073F,
   0x0800, 0x0900, 0x0A00, 0xFF00},

  {0x00D1, 0x0102, 0x02CF, 0x0302, 0x0482, 0x0502, 0x060E, 0x07D8,
   0x081C, 0x091A, 0x0A1E, 0x0B0C, 0x0C0D, 0x0D0B, 0xFF28, 0x073F,
   0x0800, 0x0900, 0x0A00, 0xFF00}
};


int zounds[60] =
{ 0,11, 9, 1, 3, 7,10, 2, 6, 8, 7,11,
  4, 2, 0, 3,10, 7, 6,11, 8, 2, 9, 5,
  5, 1,10, 5,11, 3, 0, 4, 1, 4, 8, 9,
  4, 3, 2, 5, 9, 8, 4, 7, 6,10,10, 0,
  5, 1, 6, 0,11, 8, 1, 7, 2, 9, 3, 6
};


main()
{
int j,hwch,hhch,hwb,hhb;
int xpos,ypos,width,height;
long tempvar;

   appl_init();
   HIDE_MOUSE;
   
   for( j=0; j<10; j++ )
      work_in[j]=1;
   work_in[10]=2;
   
   handle = graf_handle( &hwch, &hhch, &hwb, &hhb );
   v_opnvwk( work_in, &handle, work_out );
   v_clrwk( handle );
   wind_get( 0, WF_WORKXYWH, &xpos, &ypos, &width, &height );
   wind_handle = wind_create( 0, xpos, ypos, width, height );
   wind_open( wind_handle, xpos, ypos, width, height );
   v_clrwk( handle );
   vql_attributes( wind_handle,attrib );  /* save polyline info */
   
   cur_screen = 0;
   screen[0] = (char *) Physbase();  /* find out where the screen is */
   tempvar = Malloc(0x8200L);
   screen[1] = (char *)((tempvar+512) & 0xFFFFFE00);
   
   if( check_screen() )
   {  do
      {  restart = 1;
         vsf_perimeter( wind_handle, 0 );  /* perimeter invisible after the alert box*/
         vswr_mode( wind_handle, 1 );  /* write mode replace */
         clear_em();  /* clear out the info from past games */
         opening_screen();
         bigscreen(2);  /* draw the lines */
         smallscreen();
         printscore(2);
         SHOW_MOUSE;
         graf_mouse( 0, 0x0L);  /* make the mouse an arrow */
   
         play_game();  /* main game routine */
         switch( winner )
         {  case 0: break; /* no winner */
            case 1:
               form_alert(1,"[1][Player 1 Wins!][OK]");
               break;
            case 2:
               form_alert(1,"[1][Player 2 Wins!][OK]");
               break;
         }
      } while( restart == 1 );
   }
   
   Setscreen( screen[0],screen[0],-1);  /* go back to the normal screen */
   Mfree(tempvar);  /* free up the memory we requested */
   if( rez == 0 )
      Setpalette(old_colors);  /* return to the old color palette */
   vsl_color( wind_handle, attrib[1] );  /* return old polyline color */
   wind_close( wind_handle );
   wind_delete( wind_handle );
   v_clsvwk( handle );
   appl_exit();
   
}  /* end of main() */


opening_screen()
{
int j,k,l,szx,szy,height;
int atarray[10];

   bigscreen(2);
   szx = szy = (rez/2 + 1) * 8;
   pxy[0]=szx*25; pxy[1]=szy*3;
   pxy[2]=szx*39; pxy[3]=szy*3;
   pxy[4]=szx*39; pxy[5]=szy*21;
   pxy[6]=szx*25; pxy[7]=szy*21;
   pxy[8]=pxy[0]; pxy[9]=pxy[1];
   vsl_color( wind_handle, 2 );  /* black for polyline */
   v_pline( wind_handle, 5, pxy );
   vqt_attributes(wind_handle, atarray );
   height = atarray[7];
   vst_color( wind_handle, 2 );
   vst_effects( wind_handle, 16 );  /* outline */
   vst_height( wind_handle, height*4, &dummy, &dummy, &dummy, &dummy );
   if( rez == 2)  /* monochrome */
   {  v_gtext( wind_handle, szx*27+szx/2, szy*7, "K A R M A" );
      vst_effects( wind_handle, 0 );
      vst_height( wind_handle, height/2, &dummy, &dummy, &dummy, &dummy );
      v_gtext( wind_handle, szx*27+szx/2, szy*9, "  Copyright ½ 1987");
      v_gtext( wind_handle, szx*27, szy*10, " COMPUTE!'s Atari ST");
      v_gtext( wind_handle, szx*27, szy*11, "  Disk and Magazine");
      v_gtext( wind_handle, szx*27, szy*12, " All Rights Reserved");
      vst_height( wind_handle, height, &dummy, &dummy, &dummy, &dummy );
      vst_effects( wind_handle, 0 );  /* back to normal */
      v_gtext( wind_handle, szx*28+4, szy*15, "1 Capture All");
      v_gtext( wind_handle, szx*28+4, szy*16, "2 Corners");
      v_gtext( wind_handle, szx*28+4, szy*17, "3 Two Pies");
      v_gtext( wind_handle, szx*28+4, szy*18, "4 2500 Points");
   }
   else  /* color screen */
   {  v_gtext( wind_handle, szx*27+szx/2, szy*7, "KARMA" );
      pxy[0]-=6;pxy[6]-=6;pxy[8]-=6;
      pxy[2]+=6;pxy[4]+=6;
      pxy[1]=pxy[3]=pxy[9]=szy*8;
      pxy[5]=pxy[7]=szy*13;
      vsf_color( wind_handle, 0 );
      v_fillarea( wind_handle, 5, pxy );  /* clear out some room */
      v_pline( wind_handle, 5, pxy );  /* and draw a line */
      vst_effects( wind_handle, 0 );
      vst_point( wind_handle, 6, &dummy, &dummy, &dummy, &dummy );
      v_gtext( wind_handle, szx*25, szy*9, " Copyright ½ 1987");
      v_gtext( wind_handle, szx*25, szy*10, "COMPUTE!'s Atari ST");
      v_gtext( wind_handle, szx*25, szy*11, " Disk and Magazine");
      v_gtext( wind_handle, szx*25, szy*12, "All Rights Reserved");
      vst_height( wind_handle, height, &dummy, &dummy, &dummy, &dummy );
      vst_effects( wind_handle, 0 );  /* back to normal */
      v_gtext( wind_handle, szx*26-4, szy*15, "1 Capture All");
      v_gtext( wind_handle, szx*26-4, szy*16, "2 Corners");
      v_gtext( wind_handle, szx*26-4, szy*17, "3 Two Pies");
      v_gtext( wind_handle, szx*26-4, szy*18, "4 2500 Points");
   }
   game = 0;
   while( game<49 || game>52 )
      game = (Bconin(2) & 0xFF);
   game -=48 ;  /* convert ASCII to int */

}  /* end of opening_screen() */

check_screen()
{
int j;
int k = 1;

   rez = Getrez();
   if( rez==0 )  /* low res screen */
   {  box_hi = box_wide = 12;
      bh_2 = bw_2 = 8;
      x_offset = 16;
      y_offset = 12;
      xo_2 = 200;
      yo_2 = 68;
      for( j=0; j<16; j++ )
         old_colors[j] = Setcolor( j, -1);
      Setpalette(new_colors);
   }
   else if( rez==2 ) /* hi res screen */
   {  box_hi = box_wide = 24;
      bh_2 = bw_2 = 16;
      x_offset = 32;
      y_offset = 24;
      xo_2 = 400;
      yo_2 = 136;
   }
   else
   {  k = 0;  /* don't allow medium res */
      form_alert( 1, "[3][   Please switch to   |low or high resolution][OK]");
   }
   return(k);
}  /* end check_screen() */

clear_em()
{
int j;

   winner = score[1] = score[2] = 0;  /* both players start at zero */
   for( j=0; j<53; j++)
   {  karma[j].owner = 0;
      karma[j].renters = 0;
      karma[j].update = 0;
   }
   for( j=0; j<20; j++)
   {  karma[start[j]].owner = ((j&1)+1);  /* player 1 or 2 */
      karma[start[j]].renters = 1;
   }
}  /* end clear_em() */


bigscreen(all)  /* all = 1 for color cycling, = 2 for whole screen */
int       all;
{
int j,k,c,f,l,lrc[3];

   HIDE_MOUSE;
   v_clrwk( handle );  /* clear the screen */
   sound_fx();
   if( rez == 2 )  /* hi-res only */
   {  vsf_interior( wind_handle, 2 );  /* use a pattern */
      vsf_color( wind_handle, 2 );  /* and black */
   }
   else
      vsf_interior( wind_handle, 1 );  /* use colors in low res */
   
   for( j=0; j<53; j++ )
   {  c = karma[j].num_corners;
      for( k=0; k<(c*2); k+=2 )
      {  pxy[k] = ((karma[j].corners[k])*box_wide) + x_offset;
         pxy[k+1] = ((karma[j].corners[k+1])*box_hi) + y_offset;
      }
      f = 14;  /* the full pattern */
      l = 2;
      lrc[2] = 11;
      lrc[1] = 14;
      switch( karma[j].num_neighbors - karma[j].renters )
      {  case 1: f = 8; l = 0; lrc[2] = 7; lrc[1] = 12; break;
         case 2: f = 5; l = 2; lrc[2] = 5; lrc[1] = 15; break;
         case 3: f = 3; l = 2; lrc[2] = 8; lrc[1] = 13; break;
         case 4: f = 1; l = 2; lrc[2] = 9; lrc[1] = 9; break;
      }
      if( rez == 2 )
      {  vsf_style( wind_handle, f );  /* dots (hi-res only) */
         vsl_color( wind_handle, l );
      }
      else
      {  if( karma[j].update == 0 )
            lrc[1] = lrc[2];
         vsf_color( wind_handle, lrc[all]);
         vsl_color( wind_handle, 10);
      }
      v_fillarea( wind_handle, c, pxy );
      v_pline( wind_handle, c, pxy );
   }
   SHOW_MOUSE;

}  /* end of bigscreen() */


smallscreen()
{
int j,k,c,f,perim;

   for( j=0; j<53; j++ )
   {  c = karma[j].num_corners;
      for( k=0; k<(c*2); k+=2 )
      {  pxy[k] = ((karma[j].corners[k])*bw_2) + xo_2;
         pxy[k+1] = ((karma[j].corners[k+1])*bh_2) + yo_2;
      }
      
      if( rez == 2)  /* monochrome */
      {  switch( karma[j].owner )  /* who owns it? */
         {  case 0: vsf_color( wind_handle, 2 );  /* black */
                    vsf_interior( wind_handle, 2 ); /* pattern */
                    vsf_style( wind_handle, 4 );  /* shade of gray */
                    perim = 2;  /* black edge */
                    break;
            case 1: vsf_color( wind_handle, 0 );  /* white */
                    vsf_interior( wind_handle, 1 ); /* fill solid */
                    perim = 2;  /* black edge */
                    break;
            case 2: vsf_color( wind_handle, 2 );  /* black */
                    vsf_interior( wind_handle, 1 ); /* fill solid */
                    perim = 0;  /* white edge */
                    break;
         }
      }
      else  /* must be low-resolution */
      {  perim = 10;  /* light blue edges */
         vsf_interior( wind_handle, 1 );  /* fill solid */
         switch( karma[j].owner )  /* who owns it? */
         {  case 0: vsf_color( wind_handle, 4 );  /* gray */
                    break;
            case 1: vsf_color( wind_handle, 3 ); /* red */
                    break;
            case 2: vsf_color( wind_handle, 6 ); /* blue */
                    break;
         }
      }
      
      v_fillarea( wind_handle, c, pxy );
      vsl_color( wind_handle,perim );  /* the edge color */
      v_pline( wind_handle, c, pxy );  /* draw some edges */
   }

}  /* end of smallscreen() */


play_game()
{
int screen_x,screen_y,box_x,box_y;
int which,ask,old_one;
int player = 1;

int what;  /* what happened */
int mflags = 35;  /* binary 100011: timer, button, or keyboard event */
int mbclick = 1;  /* wait for one click */
int mbmask = 1;  /* left button */
int mbstate = 1;  /* wait for down */
int dum;  /* dummy variable */
int low_time = 1200;  /* low byte of timer 1.2 seconds */
int high_time = 0;
int msx, msy, button, kstate, key;
char dumc[16];
int edge_color = 0;
int new_edge;
int exit_play = 0;

   do
   {  what =
      evnt_multi( mflags, mbclick, mbmask, mbstate,
                  dum,dum,dum,dum,dum,  /* no mouse event 1 */
                  dum,dum,dum,dum,dum,  /* no mouse event 2 */
                  dumc,                 /* no message event */
                  low_time, high_time,  /* timer event = 1.2 seconds */
                  &msx,&msy,&button,&kstate,&key,&dum);
      if( what == 32 )  /* timer event */
      {  ++edge_color;
         if( edge_color > 5 )
            edge_color = 0;
         new_edge = cycle[edge_color];
         expl_colors[9] = new_colors[9] = new_edge;
         Setpalette( new_colors );
      }
      if( what == 1 )  /* key press */
      {  key &= 0x00FF;
         vsf_perimeter( wind_handle, 1 );  /* perimeter visible */
         if( key == 'q' || key == 'Q' )
         {  exit_play = form_alert( 1,"[1][Quit|Are you sure?][Yes|No]" );
            exit_play &= 1;
            if( exit_play )
               restart = 0;
         }
         if( key == 'r' || key == 'R' )
         {  exit_play = form_alert( 1,"[1][Restart Game?][Yes|No]" );
            exit_play &= 1;
            if( exit_play )
               restart = 1;
         }
         vsf_perimeter( wind_handle, 0 );  /* perimeter invisible after the alert box*/
         vswr_mode( wind_handle, 1 );  /* write mode replace */
      }
      if( what == 2 )  /* button click */
      {  screen_x = msx - x_offset;
         screen_y = msy - y_offset;
         box_x = screen_x/box_hi;
         box_y = screen_y/box_wide;
         if( box_x>=0 && box_x<=13 && box_y>=0 && box_y<=13 )
         {  which = translate[box_y][box_x];
            if( which > 99)
            {  ask = which - 100;
               which = fix_it( ask, screen_x, screen_y );
            }
            HIDE_MOUSE;
            if( which != -1)
            {  if( karma[which].owner == player )
               {  ++karma[which].renters;
                  explode(player);
                  printscore(player);
                  if( game == 4 )
                     check_winner();
                  if( winner )
                     exit_play = 1;
                  player ^= 3;  /* switch players 1 and 2 */
               }
            }
            
            SHOW_MOUSE;
         }  /* end if */
      }  /* end if (left button not down) */
   } while( exit_play != 1);  /* end of do */
}  /* end of play_game() */


explode(player)
int     player;
{
int j,k,wha,z,p1,p2;
int list[53];
int index = 0;
int quit = 1;

   while(quit == 1)
   {  quit = 0;
      index = 0;
      p1 = p2 = 0;
      for( j=0; j<53; j++ )
      {  if( karma[j].num_neighbors <= karma[j].renters )
         {  list[index] = j;
            ++index;
            quit = 1;  /* don't quit */
         }
         if( karma[j].owner == 1 ) ++p1;
         if( karma[j].owner == 2 ) ++p2;
      }
      if( quit )
      {  for( z=0; z<index; z++)
         {  j = list[z];
            karma[j].update = 1;
            for( k=0; k<karma[j].num_neighbors; k++)
            {  wha = karma[j].neighbors[k];
               ++karma[wha].renters;
               karma[wha].update = 1;
               karma[wha].owner = player;
            }
            karma[j].renters -= karma[j].num_neighbors;
         }
      }
      cur_screen ^= 1L;
      Setscreen( screen[cur_screen],-1L,-1 );  /* the invisible alt screen */
      HIDE_MOUSE;
      bigscreen(2-quit);
      smallscreen();
      SHOW_MOUSE;
      Setscreen( -1L,screen[cur_screen],-1 );  /* make alt screen visible */
      if( quit == 1)
         blend();  /* cycle colors */
      else
         Setpalette( new_colors );
      check_winner();  /* see if someone won */
      if( winner !=0 || p1 == 0 || p2 == 0 )
      {  quit = 0; /* someone won or there are no squares left */
         if( winner == 0 )
            winner = player;  /*if no winner, the loser lost all the pieces*/
      }
   }  /* end while() */
}  /* end explode() */


blend()
{
int j,k;

   if( rez == 0 )
   {   for( j=0; j<6; j++ )
      {  for( k=0; k<4; k++ )
            expl_colors[11+k] = smooth[j][k];
         Setpalette( expl_colors );
         evnt_timer( 200,0 );  /* wait 1/5 second */
      }
   }
   for( j=0; j<53; j++ )
      karma[j].update = 0;
}  /* end of blend() */


printscore(player)
int        player;
{
int j,k,l;
int x=200, y=12;
int spx = 8, spy = 8;
int temp1[3],temp2[3];
char string1[40], string2[40];

   if( rez == 2 )
   {  x = 460; y *= 2; spx *= 2; spy *= 2;
   }
   for( j=0; j<3; j++ )
   {  temp1[j] = 0;
      temp2[j] = 0;
   }
   for( j=0; j<53; j++ )
   {  k = karma[j].owner;
      l = karma[j].num_neighbors;
      temp1[k] += l;
      temp2[k] += 1;
   }
   score[1] += temp1[1];
   score[2] += temp1[2];
   
   for( j=1; j<3; j++ )
   {  y += spy;
      sprintf( string1,"Player %d: %4d", j, score[j] );
      sprintf( string2,"          %4d", temp2[j] );
      vst_color( wind_handle, 3*j );
      v_gtext( wind_handle, x, y, string1 );
      y += spy;
      v_gtext( wind_handle, x, y, string2 );
      y += spy;
   }
   
   vst_color( wind_handle, 2);
   if( player == 2 && rez == 2)  /* monochrome only */
      vst_effects( wind_handle, 16 );  /* outlined check mark for player 1 */
   v_gtext( wind_handle, x-spx, (player^3)*3*spy-spy/2, "" );
   vst_effects( wind_handle, 0 );

}  /* end printscore() */


sound_fx()
{
int j;

   if( sfx_counter > 59 )
      sfx_counter = 0;
   j = zounds[sfx_counter++];
   Dosound( sfx[j] );
}  /* end sound_fx() */


check_winner()
{
int j,k,l,m,w;
int pies[3];

switch( game )
   { case 1: break;  /* this one is handled by explode() */
     case 2:
        w = karma[0].owner;
        k = 1;
        for( j=1; j<4; j++ )
           if( karma[j].owner == w )
              ++k;
        if( k == 4 )
           winner = w;  /* if nobody owns the corners, winner = 0 */
        break;
     case 3:
        pies[1] = pies[2] = 0;  /* clear the array */
        for( j=4; j<29; j+=8 )
        {  w = karma[j].owner;
           m = 0;
           for( k=1; k<8; k++ )
           {  l = j+k;
              if( karma[l].owner == w )
                 ++m;
           }
           if( m == 7 )  /* all seven pies matched the first one */
             ++pies[w];
        }
        for( j=1; j<3; j++ )
           if( pies[j] >= 2 )
              winner = j;
        break;
     case 4:
        if( score[1]>2499 || score[2]>2499 )
           if( score[1] > score[2] )
              winner = 1;
           else
              winner = 2;  /* player 2 wins ties */
        break;
   }
}  /* end of check_winner() */



