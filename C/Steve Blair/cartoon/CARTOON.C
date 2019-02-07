/* The Cartoonist                      */
/* by Steve Blair                      */
/*                                     */ 
/* (c) 1987 by Antic Publishing, Inc.  */
/*                                     */
/* Developed for Alcyon C              */

#include  "stdio.h"
#include  "gemdefs.h"
#include  "osbind.h"
#include  "sprite.h"
#include  "obdefs.h"

#define   SCREEN_REZ 0

extern    int  init();
extern    long do_raster();
extern         scr_copy();
extern         clear_screen();
extern         set_source();
extern         xor_image();
extern         kill_sprite();
extern    long get_free();
extern    int  load_sprite();
extern    int  save_sprite();
extern    long timer();

struct
    {
          long addr;
          int  word_length;
          int  byte_length;
          int  width;
          int  height;
          int  new_x;
          int  new_y;
          int  x;
          int  y;
          char new;
          char enable;
          char plane;
          char frame;
          char next_frame;
          char advance_frame;
          char last_frame;
          char filler;
     } raster[16];

int  contrl[12],
     intin[128],
     intout[128],
     ptsin[128],
     ptsout[128];

int  handle,
     work_in[12],
     work_out[57],
     pxy[16],
     read_handle,
     write_handle,
     pal[16],
     old_pal[16];

int  x, y,
     dum,
     button,
     rez,
     error,
     clear,
     nums = 0,
     form_exit;

char rez0_message[] = "[1][ | Please switch |  to low rez | ][OK]",
     no_resource[] =  "[1][ | I can't find | SPRITE.RSC | ][Ok]",
     image_def[] = "[2][ That sprite has | been defined.   | Ok to replace? ][Yes|No]",
     frame_def[] = "[2][ That frame has | been defined.  | Ok to replace? ][Yes|No]",
     no_space[] = "[1][ There is not | enough free space | on this drive ][Ok]",
     confirm[] = "[2][ | Ok to delete | current sprite? ][Yes|No]",
     no_mem[] = "[1][ There is not enough | memory for an image | of that size ][Ok]",
     reboot[] = "[1][ There is not enough | memory to run this | application ][Ok]";

char *point_to_mess[2],
     pic_path[40] = "A:*.PI1",
     ani_path[40] = "A:*.ANI",
     rsc[20] = "A:SPRITE.RSC",
     kill_path[40] = "A:*.*",
     pic_filename[40],
     ani_filename[40],
     kill_filename[40],
     screen[32768],
     *old_screen,
     *temp_screen,
     hold_num[4],
     free_buff[10];

long cur_screen,
     time;

int  x_pos, y_pos,
     dx[16], dy[16],
     h, w, length,
     height, image = 0,
     all = 0,
     move_all = 0,
     free = 0;

long menu,
     dum_buff[4];

OBJECT *set_sp,
       *set_pr,
       *dis,
       *set_fr,
       *hi;

char *str_sp,
     *strs_sp[1],
     *str_pr,
     *strs_pr[2],
     *str_dis,
     *strs_dis[16],
     **tedptr,
     *dummy,
     *str_fr,
     *strs_fr[1];

int  formx,
     formy,
     formw,
     formh;



initialize()
{
     point_to_mess[0] = rez0_message;

     appl_init();
     handle = graf_handle(&dum, &dum, &dum, &dum);
     for(x = 0; x < 10; work_in[x++] = 1);
     work_in[10] = 2;

     v_opnvwk(work_in, &handle, work_out);

     for(x = 0; x < 16; x++)
     {
          old_pal[x] = Setcolor(x, -1);
          pal[x] = old_pal[x];
     }
     rez = Getrez();

     if(rez != SCREEN_REZ)
     {
          form_alert(1, point_to_mess[SCREEN_REZ]);
          error = 1;
          return;
     }

     rsc[0] = Dgetdrv() + 'A';
     dum = rsrc_load(rsc);
     if(dum == 0)
     {
          error = 1;
          form_alert(1, no_resource);
          return;
     }

     rsrc_gaddr(0, MENU, &menu);

     rsrc_gaddr(0, SETPRI, &set_pr);
     rsrc_gaddr(0, NEWSP, &set_sp);
     rsrc_gaddr(0, DIS, &dis);
     rsrc_gaddr(0, NEWFRAME, &set_fr);
     rsrc_gaddr(0, HELLO, &hi);

     tedptr = set_sp[NEWSPRIT].ob_spec;
     strs_sp[0] = *tedptr;

     tedptr = set_pr[PRIORITY].ob_spec;
     strs_pr[1] = *tedptr;

     tedptr = set_pr[SETSPRIT].ob_spec;
     strs_pr[0] = *tedptr;

     tedptr = set_fr[FRAME].ob_spec;
     strs_fr[0] = *tedptr;
}




main()
{
     initialize();
     if(!error)
     {
          start();
          Setscreen(old_screen, old_screen, -1);
          Setpallete(old_pal);
     }
     v_clsvwk(handle);
     appl_exit();
}




start()
{
     int  ev_mwhich,
          buttn,
          pipe[16],
          find_sprite();

     int  wi_handle,
          xdesk, ydesk,
          wdesk, hdesk;

     old_screen = Physbase();
     temp_screen = (0xffff00 & screen) + 0x100;

     Setpallete(screen);

     graf_mouse(256, 0x0L);
     clear_screen(old_screen);
     dum = init(raster);
     if(dum == -1)
     {
          Setpallete(old_pal);
          graf_mouse(257, 0x0L);
          form_alert(1, reboot);
          return;
     }
     time = timer();
     cur_screen = do_raster(1);
     time = timer() - time;

     wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
     wi_handle = wind_create(0, xdesk, ydesk, wdesk, hdesk);
     wind_open(wi_handle, xdesk, ydesk, wdesk, hdesk);

     cur_screen = do_raster(1);
     graf_mouse(257, 0x0L);
     
     top_bar();
     Setpallete(old_pal);

     do
     {
          graf_mouse(0, 0x0L);

          do
          {
               ev_mwhich = evnt_multi(  48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, pipe, 20, 0, &dum, &dum, &dum,
                                        &dum, &dum, &dum );
               graf_mkstate(&x, &y, &buttn, &dum);
          }    while(pipe[0] == 0 && buttn == 0);

          if(pipe[0] == 10)
          {
               menu_tnormal(menu, pipe[3], 1);
               switch (pipe[4])
               {
                    case ABOUT:
                         hello();
                         break;

                    case LOADPIC:
                         load_pic();
                         break;

                    case SAVEPIC:
                         save_pic();
                         break;

                    case LOADSPRI:
                         load_data();
                         break;

                    case SAVESPRI:
                         save_data();
                         break;

                    case DELETE:
                         delete();
                         break;

                    case QUIT:
                         return;

                    case DEFINESP:
                         get_sprite();
                         break;

                    case SETSP:
                         set_sprite();
                         break;

                    case DEFFRAME:
                         get_frame();
                         break;

                    case SHOWNUMS:
                         flip_nums();
                         break;

                    case SETPRIOR:
                         set_priority();
                         break;

                    case DISPLAY:
                         display();
                         break;

                    case ALL:
                         do_all();
                         break;

                    case RESTORE:
                         change_screen();
                         break;

                    case DELSPRI:
                         delete_sprite();
                         break;

                    case SELECT:
                         select();
                         break;

                    case FREE:
                         flip_free();
                         break;
               }
               top_bar();
               pipe[0] = 0;
          }
          if(pipe[0] == 20)
          {
               cur_screen = do_raster(1);
               top_bar();
               pipe[0] = 0;
          }
          if(buttn != 0)
          {
               if(move_all == 0)
                    drag_sprite(find_sprite(x, y), x, y);
               else
                    drag_all(find_sprite(x, y), x, y);

               if(nums == 0)
                    top_bar();
          }
          if(nums == 1)
          {
               show_nums();
               top_bar();
          }
     }    while(1);
}




load_pic()
{
     pic_path[0] = (Dgetdrv() + 'A');
     fsel_input(pic_path, pic_filename, &dum);
     graf_mouse(256, 0x0L);
     if(dum)
     {
          Dsetdrv(pic_path[0] - 'A');

          read_handle = Fopen(pic_filename, 0);
          if(read_handle > -1)
          {
               Fread(read_handle, (long)2, &dum);
               Fread(read_handle, (long)32, pal);
               Setpallete(pal);
               Fread(read_handle, (long)32000, old_screen);
          }
          Fclose(read_handle);
          menu_text(menu, RESTORE, "  Clear Screen");
          clear = 1;
     }
     graf_mouse(257, 0x0L);
}




save_pic()
{
     long disk_space();

     pic_path[0] = (Dgetdrv() + 'A');
     fsel_input(pic_path, pic_filename, &dum);

     graf_mouse(256, 0x0L);
     cur_screen = do_raster(1);

     if(dum)
     {
          Dsetdrv(pic_path[0] - 'A');
          if(disk_space(dum_buff) < (long)(33000) )
          {
               form_alert(1, no_space);
               write_handle = -1;
          }
          else
               write_handle = Fcreate(pic_filename, 0);
          if(write_handle > -1)
          {
               Fwrite(write_handle, (long)2, &dum);
               Fwrite(write_handle, (long)32, pal);
               Fwrite(write_handle, (long)32000, cur_screen);
          }
          Fclose(write_handle);
     }
     graf_mouse(257, 0x0L);
}




load_data()
{
     ani_path[0] = (Dgetdrv() + 'A');
     fsel_input(ani_path, ani_filename, &dum);
     graf_mouse(256, 0x0L);
     if(dum)
     {
          Dsetdrv(ani_path[0] - 'A');

          read_handle = Fopen(ani_filename, 0);
          Fclose(read_handle);
          if(read_handle > -1)
          {
               if(load_sprite(ani_filename, pal))
                    form_alert(1, no_mem);
               all = 1;
               do_all();
          }
     }
     graf_mouse(257, 0x0L);
}




save_data()
{
     long disk_space(),
          space = 32;

     for(dum = 0; dum < 16; dum++)
          if(raster[dum].addr)
          {
               space += raster[dum].byte_length * (raster[dum].height + 1) * (raster[dum].last_frame + 1);
               space += 100 * (raster[dum].last_frame + 1) + 28;
          }

     ani_path[0] = (Dgetdrv() + 'A');
     fsel_input(ani_path, ani_filename, &dum);

     graf_mouse(256, 0x0L);
     cur_screen = do_raster(1);

     if(dum)
     {
          Dsetdrv(ani_path[0] - 'A');
          if(disk_space(dum_buff) < space)
               form_alert(1, no_space);
          else
               if(save_sprite(ani_filename, pal))
               {
                    form_alert(1, no_space);
                    Fdelete(ani_filename);
               }
     }
     graf_mouse(257, 0x0L);
}




delete()
{
     kill_path[0] = Dgetdrv() + 'A';
     do
     {
          fsel_input(kill_path, kill_filename, &dum);
          if(dum)
               Fdelete(kill_filename);
     }    while(dum);
     cur_screen = do_raster(1);
}




get_sprite()
{
     int x_off, y_off,
         x_tem, y_tem,
         kill = 0;

     menu_bar(menu, 0);
     graf_mouse(256, 0x0L);
     vswr_mode(handle, 3);
     vsf_color(handle, 15);
     cur_screen = do_raster(1);
     graf_mouse(257, 0x0L);

     graf_mouse(0, 0x0L);
     if(raster[image].addr != 0)
     {
          dum = form_alert(1, image_def);
          kill = 1;
          if(dum == 2)
               return;
     }
     graf_mouse(3, 0x0L);

     do
          graf_mkstate(&dum, &dum, &button, &dum);
     while(button != 0);

     while(button == 0)
          graf_mkstate(&x_pos, &y_pos, &button, &dum);

     graf_mouse(256, 0x0L);

     pxy[0] = pxy[6] = pxy[8] = x_pos;
     pxy[2] = pxy[4] = x_pos;
     pxy[1] = pxy[3] = pxy[9] = y_pos;
     pxy[5] = pxy[7] = y_pos;

     v_pline(handle, 5, pxy);

     while(button != 0)
     {
          graf_mkstate(&x, &y, &button, &dum);

          if(x_tem != x || y_tem != y)
          {
               v_pline(handle, 5, pxy);

               x_tem = x;
               y_tem = y;

               pxy[0] = pxy[6] = pxy[8] = x_pos;
               pxy[1] = pxy[3] = pxy[9] = y_pos;
               pxy[2] = pxy[4] = x;
               pxy[5] = pxy[7] = y;
               v_pline(handle, 5, pxy);
          }
     }
     v_pline(handle, 5, pxy);

     x_off = y_off = 0;
     if(x > x_pos)
          x_off = x - x_pos;
     if(y > y_pos)
          y_off = y - y_pos;

     w = abs(x - x_pos);
     h = abs(y - y_pos);

     if(w < 16)
          w = 16;
     if(h < 5)
          h = 5;

     pxy[0] = x - x_off;
     pxy[1] = y - y_off;
     pxy[2] = x + w - x_off;
     pxy[3] = y + h - y_off;
     v_bar(handle, pxy);

     x_pos = y_pos = 0;

     do
     {
          graf_mkstate(&x, &y, &button, &dum);

          if(button > 1)
          {
               cur_screen = do_raster(1);
               graf_mouse(257, 0x0L);
               return;
          }
          x -= x_off;
          y -= y_off;

          if(x < 0)
               x = 0;
          if(y < 0)
               y = 0;

          if(x + w > 319)
               x = 319 - w;
          if(y + h > 199)
               y = 199 - h;

          if(x_pos != x || y_pos != y)
          {
               v_bar(handle, pxy);

               pxy[0] = x;
               pxy[1] = y;
               pxy[2] = x + w;
               pxy[3] = y + h;
               v_bar(handle, pxy);

               x_pos = x;
               y_pos = y;
          }
     }    while(button == 0);
     v_bar(handle, pxy);

     if(kill)
     {
          dum = raster[image].enable;

          kill_sprite(image, 0);
          cur_screen = do_raster(1);

          raster[image].enable = dum;
     }
     raster[image].new_x = x_pos;
     raster[image].new_y = y_pos;

     raster[image].width = w;
     raster[image].height = h;

     raster[image].new = (short)(1);
     raster[image].frame = (short)(0);

     raster[image].plane = (short)(1);

     raster[image].x = x_pos + 8;
     raster[image].y = y_pos + 5;

     set_source(cur_screen);
     cur_screen = do_raster(1);
     set_source(old_screen);

     if(cur_screen == -1L)
     {
          form_alert(1, no_mem);
          cur_screen = do_raster(1);
     }
     graf_mouse(257, 0x0L);
}




set_sprite()
{
     int get_num();

     Setpallete(old_pal);
     graf_mouse(0, 0x0L);

     set_sp[OKSETSP].ob_state = NORMAL;
     set_sp[CANSETSP].ob_state = NORMAL;

     form_center(set_sp, &formx, &formy, &formw, &formh);

     form_dial(1, 160, 100, 0, 0, formx, formy, formw, formh);

     objc_draw(set_sp, 0, CANSETSP, formx, formy, formw, formh);
     dum = form_do(set_sp, NEWSPRIT);

     form_dial(2, 160, 100, 0, 0, formx, formy, formw, formh);

     if(dum == OKSETSP)
          image = get_num(strs_sp[0], 0);

     graf_mouse(256, 0x0L);
     Setpallete(pal);
     cur_screen = do_raster(1);
     graf_mouse(257, 0x0L);
}




get_frame()
{
     int  get_num(),
          frame,
          kill = 0;

     Setpallete(old_pal);
     graf_mouse(0, 0x0L);

     set_fr[FROK].ob_state = NORMAL;
     set_fr[FRCAN].ob_state = NORMAL;

     form_center(set_fr, &formx, &formy, &formw, &formh);

     form_dial(1, 160, 100, 0, 0, formx, formy, formw, formh);

     objc_draw(set_fr, 0, FRCAN, formx, formy, formw, formh);
     form_exit = form_do(set_fr, FRAME);

     form_dial(2, 160, 100, 0, 0, formx, formy, formw, formh);

     frame = get_num(strs_fr[0], 1);
     if((short)raster[image].last_frame >= (short)frame && form_exit != FRCAN)
     {
          dum = form_alert(1, frame_def);
          kill = 1;
          if(dum == 2)
               form_exit = FRCAN;
     }

     menu_bar(menu, 0);
     graf_mouse(256, 0x0L);
     Setpallete(pal);
     cur_screen = do_raster(1);
     graf_mouse(257, 0x0L);

     if(form_exit == FRCAN)
          return;

     if(raster[image].addr == 0x0L)
     {
          get_sprite();
          return;
     }
     w = raster[image].width;
     h = raster[image].height;

     graf_mouse(256, 0x0L);

     do
          vq_mouse(handle, &button, &x, &y);
     while(button != 0);

     vswr_mode(handle, 3);
     vsf_color(handle, 15);

     if(x + w > 319)
          x = 319 - w;
     if(y + h > 199)
          y = 199 - h;

     x_pos = x;
     y_pos = y;

     pxy[0] = pxy[6] = pxy[8] = x;
     pxy[1] = pxy[3] = pxy[9] = y;
     pxy[2] = pxy[4] = x + w;
     pxy[5] = pxy[7] = y + h;
     v_pline(handle, 5, pxy);
     xor_image(image, x, y);

     do
     {
          graf_mkstate(&x, &y, &button, &dum);
          if(button > 1)
          {
               cur_screen = do_raster(1);
               graf_mouse(257, 0x0L);
               return;
          }
          if(x + w > 319)
               x = 319 - w;
          if(y + h > 199)
               y = 199 - h;

          if(x_pos != x || y_pos != y)
          {
               xor_image(image, x_pos, y_pos);
               v_pline(handle, 5, pxy);

               pxy[0] = pxy[6] = pxy[8] = x;
               pxy[1] = pxy[3] = pxy[9] = y;
               pxy[2] = pxy[4] = x + w;
               pxy[5] = pxy[7] = y + h;
               v_pline(handle, 5, pxy);
               xor_image(image, x, y);

               x_pos = x;
               y_pos = y;
          }
     }    while(button == 0);

     xor_image(image, x, y);
     v_pline(handle, 5, pxy);

     if(kill)
          kill_sprite(image, frame);

     dum = raster[image].frame;

     raster[image].new_x = x;
     raster[image].new_y = y;
     raster[image].width = w;
     raster[image].height = h;
     raster[image].frame = (short)frame;
     if(raster[image].last_frame < (short)frame)
          raster[image].last_frame = (short)frame;

     set_source(cur_screen);
     cur_screen = do_raster(1);
     set_source(old_screen);

     if(cur_screen == -1L)
     {
          form_alert(1, no_mem);
          cur_screen = do_raster(1);
          raster[image].frame = (short)dum;
     }
     graf_mouse(257, 0x0L);
}




hello()
{
     Setpallete(old_pal);
     graf_mouse(0, 0x0L);

     hi[HELLOK].ob_state = NORMAL;

     form_center(hi, &formx, &formy, &formw, &formh);
     form_dial(1, 160, 100, 0, 0, formx, formy, formw, formh);
     objc_draw(hi, 0, 4, formx, formy, formw, formh);
     form_do(hi, -1);
     form_dial(2, 160, 100, 0, 0, formx, formy, formw, formh);

     graf_mouse(256, 0x0L);
     Setpallete(pal);
     cur_screen = do_raster(1);
     graf_mouse(257, 0x0L);
}




set_priority()
{
     int get_num();

     Setpallete(old_pal);
     graf_mouse(0, 0x0L);

     set_pr[OKSETPR].ob_state = NORMAL;
     set_pr[CANSETPR].ob_state = NORMAL;

     form_center(set_pr, &formx, &formy, &formw, &formh);

     form_dial(1, 160, 100, 0, 0, formx, formy, formw, formh);

     objc_draw(set_pr, 0, CANSETPR, formx, formy, formw, formh);
     dum = form_do(set_pr, SETSPRIT);

     form_dial(2, 160, 100, 0, 0, formx, formy, formw, formh);

     if(dum == OKSETPR)
          raster[get_num(strs_pr[0], 0)].plane = (short)(get_num(strs_pr[1], 0));

     graf_mouse(256, 0x0L);
     Setpallete(pal);
     cur_screen = do_raster(1);
     graf_mouse(257, 0x0L);
}




display()
{
     Setpallete(old_pal);
     graf_mouse(0, 0x0L);

     dis[OKDIS].ob_state = NORMAL;
     dis[CANDIS].ob_state = NORMAL;

     for(dum = 0; dum < 16; dum++)
          dis[dum + ONE].ob_state = NORMAL;

     for(dum = 0; dum < 16; dum++)
          dis[dum + ONE].ob_state = DISABLED * (raster[dum].addr == 0x0L) + SELECTED * (raster[dum].enable == (short)(1));

     form_center(dis, &formx, &formy, &formw, &formh);

     form_dial(1, 160, 100, 0, 0, formx, formy, formw, formh);

     objc_draw(dis, 0, CANDIS, formx, formy, formw, formh);
     dum = form_do(dis, -1);

     form_dial(2, 160, 100, 0, 0, formx, formy, formw, formh);

     if(dum == OKDIS)
          for(dum = 0; dum < 16; dum++)
               raster[dum].enable = (short)(dis[dum + ONE].ob_state == SELECTED);

     graf_mouse(256, 0x0L);
     Setpallete(pal);

     time = timer();
     cur_screen = do_raster(1);
     time = timer() - time;

     graf_mouse(257, 0x0L);

     for(dum = 0; dum < 16; dum++)
          if(raster[dum].enable == (short)(1))
          {
               all = 1;
               menu_text(menu, ALL, "  Remove All");
               return;
          }
}




do_all()
{
     int flag = 0;

     if(all == 0)
     {
          for(dum = 0; dum < 16; dum++)
               if(raster[dum].addr != 0x0L)
               {
                    flag = 1;
                    raster[dum].enable = (short)(1);
               }
          if(flag)
          {
               all = 1;
               menu_text(menu, ALL, "  Remove All");
          }
          else
               return;
     }
     else
     {
          all = 0;
          menu_text(menu, ALL, "  Display All");
          for(dum = 0; dum < 16; dum++)
               raster[dum].enable = (short)(0);
     }
     graf_mouse(256, 0x0L);
     time = timer();
     cur_screen = do_raster(1);
     time = timer() - time;
     graf_mouse(257, 0x0L);
}



int get_num(string, low)
char *string;
int low;
{
     dum = 10 * (string[0] - '0') + (string[1] - '0');

     if(dum < low)
          dum = low;

     if(dum > 16)
          dum = 16;
     return dum;
}



int find_sprite(xx, yy)
int xx, yy;
{
     int loop,
         temx, temy;

     for(dum = 0; dum < 16; dum++)
          for(loop = 0; loop < 16; loop++)
               if( (raster[loop].enable == (short)(1)) && raster[loop].plane == (short)(dum) )
               {
                    temx = raster[loop].x;
                    temy = raster[loop].y;

                    if(temx <= xx && xx <= (temx + raster[loop].width) && temy <= yy && yy <= (temy + raster[loop].height))
                         return loop;
               }
     return -1;
}




drag_sprite(spr, xx, yy)
int spr, xx, yy;
{
     if(spr == -1)
          return;

     graf_mouse(256, 0x0L);

     dx[0] = xx - raster[spr].x;
     dy[0] = yy - raster[spr].y;

     button = 1;

     while(button != 0)
     {
          graf_mkstate(&x_pos, &y_pos, &button, &dum);
          if(x_pos < dx[0])
               x_pos = dx[0];
          if(y_pos < dy[0])
               y_pos = dy[0];

          if((button & 0x0001) == 1)
          {
               raster[spr].x = x_pos - dx[0];
               raster[spr].y = y_pos - dy[0];
          }
          if(button > 1)
               raster[spr].advance_frame = 1;

          time = timer();
          cur_screen = do_raster(1);
          time = timer() - time;

          if(button == 2)
               break;
      }
      graf_mouse(257, 0x0L);
}




show_nums()
{
     char tex[5],
          *p;

     graf_mouse(256, 0x0L);
     vswr_mode(handle, 1);
     vst_color(handle, 1);

     cur_screen = do_raster(1);

     for(dum = 0; dum < 16; dum++)
          if(raster[dum].enable == (short)(1) )
          {
               p = tex;

               itoa(dum, p);
               p += 2;

               *(p++) = '.';
               itoa(raster[dum].next_frame, p);
               p += 2;

               *p = 0;
               v_gtext(handle, raster[dum].x, raster[dum].y, tex);
          }
     graf_mouse(257, 0x0L);
}




itoa(num, t)
int num;
char *t;
{
     *(++t) = num % 10 + '0';
     num /= 10;
     *(--t) = num + '0';
}




change_screen()
{
     graf_mouse(256, 0x0L);
     if(clear == 1)
     {
          scr_copy(old_screen, temp_screen);
          clear_screen(old_screen);
          cur_screen = do_raster(1);
          clear = 0;
          menu_text(menu, RESTORE, "  Restore Screen");
     }
     else
     {
          scr_copy(temp_screen, old_screen);
          cur_screen = do_raster(1);
          clear = 1;
          menu_text(menu, RESTORE, "  Clear Screen");
     }
     graf_mouse(257, 0x0L);
}




flip_nums()
{
     if(nums == 1)
     {
          nums = 0;
          menu_text(menu, SHOWNUMS, "  Show Numbers");
          cur_screen = do_raster(1);
     }
     else
     {
          nums = 1;
          menu_text(menu, SHOWNUMS, "  Hide Numbers");
     }
}




long disk_space(buff)
long *buff;
{
     Dfree(buff, 0);
     return (buff[0]*buff[2]*buff[3]);
}




top_bar()
{
     long free_mem;

     if(!free)
          free_mem = get_free();
     else
          free_mem = (long)(200.0 / time);

     for(dum = 0; dum < 9; dum++)
          free_buff[dum] = ' ';

     free_buff[9] = 0;

     for(dum = 8; dum >= 0; dum--)
     {
          free_buff[dum] = (char)(free_mem % 10) + '0';
          free_mem /= 10;
          if(free_mem == 0)
               dum = -1;
     }
     menu_bar(menu, 1);
     v_gtext(handle, 240, 7, free_buff);
}




delete_sprite()
{
     dum = form_alert(1, confirm);
     if(dum == 1 && raster[image].addr)
     {
          kill_sprite(image, 0);

          graf_mouse(256, 0x0L);

          time = timer();
          cur_screen = do_raster(1);
          time = timer() - time;

          graf_mouse(257, 0x0L);

          for(dum = 0; dum < 16; dum++)
               if(raster[dum].enable)
                    return;

          if(all)
               do_all();
     }
}




select()
{
     if(move_all == 0)
     {
          move_all = 1;
          menu_text(menu, SELECT, "  Select One");
     }
     else
     {
          move_all = 0;
          menu_text(menu, SELECT, "  Select All");
     }
}




drag_all(spr, xx, yy)
int spr, xx, yy;
{
     if(spr == -1)
          return;

     graf_mouse(256, 0x0L);

     for(dum = 0; dum < 16; dum++)
     {
          dx[dum] = xx - raster[dum].x;
          dy[dum] = yy - raster[dum].y;
     }
     button = 1;

     while(button != 0)
     {
          graf_mkstate(&x_pos, &y_pos, &button, &dum);

          if((button & 0x0001) == 1)
          {
               for(dum = 0; dum < 16; dum++)
                    if(raster[dum].enable)
                    {
                         if(x_pos - dx[dum] >= 0)
                              raster[dum].x = x_pos - dx[dum];

                         if(y_pos - dy[dum] >= 0)
                              raster[dum].y = y_pos - dy[dum];
                    }
          }
          if(button > 1)
               for(dum = 0; dum < 16; dum++)
                    if(raster[dum].enable)
                         raster[dum].advance_frame = 1;

          time = timer();
          cur_screen = do_raster(1);
          time = timer() - time;

          if(button == 2)
               break;
      }
      graf_mouse(257, 0x0L);
}




flip_free()
{
     if(!free)
     {
          free = 1;
          menu_text(menu, FREE, "  Display Free   ");
     }
     else
     {
          free = 0;
          menu_text(menu, FREE, "  Display Speed  ");
     }
}

