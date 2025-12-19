/*
  mandbrot.c
  To draw the mandelbrot curves
  Stephen M. Bennett
  January 1990
*/

#include "d:gem.h"
#include "d:osbind.h"
#include "d:stdio.h"

/* object tree's created by MJC Resource Compiler */

char menu_s3[] = " Desk";
char menu_s4[] = " File";
char menu_s5[] = " Draw";
char menu_s8[] = "  About Mandbrot  ";
char menu_s9[] = "  --------------------  ";
char menu_s10[] = "  acc1................  ";
char menu_s11[] = "  acc2................  ";
char menu_s12[] = "  acc3................  ";
char menu_s13[] = "  acc4................  ";
char menu_s14[] = "  acc5................  ";
char menu_s15[] = "  acc6................  ";
char menu_s17[] = "  Load  ";
char menu_s18[] = "  -----------  ";
char menu_s19[] = "  Save  ";
char menu_s20[] = "  -----------  ";
char menu_s21[] = "  Quit  ";
char menu_s23[] = "  Enter Values  ";
char menu_s24[] = "  ------------  ";
char menu_s25[] = "  Select Area  ";
OBJECT menu[] = {
 { -1,1,6, 25,0x0,0x0, 0x0L, 0,0,80,25 },
 { 6,2,2, 20,0x0,0x0, 0x1100L, 0,0,80,513 },
 { 1,3,5, 25,0x0,0x0, 0x0L, 2,0,21,769 },
 { 4,-1,-1, 32,0x0,0x0, menu_s3, 0,0,7,769 },
 { 5,-1,-1, 32,0x0,0x0, menu_s4, 7,0,7,769 },
 { 2,-1,-1, 32,0x0,0x0, menu_s5, 14,0,7,769 },
 { 0,7,22, 25,0x0,0x0, 0x0L, 0,769,80,15 },
 { 16,8,15, 20,0x0,0x0, 0xff1100L, 2,0,24,8 },
 { 9,-1,-1, 28,0x0,0x0, menu_s8, 0,0,24,1 },
 { 10,-1,-1, 28,0x0,0x8, menu_s9, 0,1,24,1 },
 { 11,-1,-1, 28,0x0,0x0, menu_s10, 0,2,24,1 },
 { 12,-1,-1, 28,0x0,0x0, menu_s11, 0,3,24,1 },
 { 13,-1,-1, 28,0x0,0x0, menu_s12, 0,4,24,1 },
 { 14,-1,-1, 28,0x0,0x0, menu_s13, 0,5,24,1 },
 { 15,-1,-1, 28,0x0,0x0, menu_s14, 0,6,24,1 },
 { 7,-1,-1, 28,0x0,0x0, menu_s15, 0,7,24,1 },
 { 22,17,21, 20,0x0,0x0, 0xff1100L, 9,0,15,5 },
 { 18,-1,-1, 28,0x0,0x0, menu_s17, 0,0,15,1 },
 { 19,-1,-1, 28,0x0,0x8, menu_s18, 0,1,15,1 },
 { 20,-1,-1, 28,0x0,0x0, menu_s19, 0,2,15,1 },
 { 21,-1,-1, 28,0x0,0x8, menu_s20, 0,3,15,1 },
 { 16,-1,-1, 28,0x0,0x0, menu_s21, 0,4,15,1 },
 { 6,23,25, 20,0x0,0x0, 0xff1100L, 16,0,16,3 },
 { 24,-1,-1, 28,0x0,0x0, menu_s23, 0,0,16,1 },
 { 25,-1,-1, 28,0x0,0x8, menu_s24, 0,1,16,1 },
 { 22,-1,-1, 28,0x20,0x0, menu_s25, 0,2,16,1 },
};

#define DESKMENU 3
#define ABOUT 8
#define FILEMENU 4
#define LOAD 17
#define SAVE 19
#define QUIT 21
#define DRAWMENU 5
#define ENTER 23
#define SELECT 25


char form_s1[] = "   Enter The Values  ";
char form_t2x[11];
char form_t2p[] = "Real Low : __________";
char form_t2v[] = "XXXXXXXXXX";
TEDINFO form_t2 = {
  form_t2x, form_t2p, form_t2v, 3, 0, 0, 0x1180, 0, 1, 11, 22 };
char form_t3x[11];
char form_t3p[] = "Real High: __________";
char form_t3v[] = "XXXXXXXXXX";
TEDINFO form_t3 = {
  form_t3x, form_t3p, form_t3v, 3, 0, 0, 0x1180, 0, 1, 11, 22 };
char form_t4x[11];
char form_t4p[] = "Imag Low : __________";
char form_t4v[] = "XXXXXXXXXX";
TEDINFO form_t4 = {
  form_t4x, form_t4p, form_t4v, 3, 0, 0, 0x1180, 0, 1, 11, 22 };
char form_t5x[11];
char form_t5p[] = "Imag High: __________";
char form_t5v[] = "XXXXXXXXXX";
TEDINFO form_t5 = {
  form_t5x, form_t5p, form_t5v, 3, 0, 0, 0x1180, 0, 1, 11, 22 };
char form_t6x[11];
char form_t6p[] = "Max Iter : __________";
char form_t6v[] = "XXXXXXXXXX";
TEDINFO form_t6 = {
  form_t6x, form_t6p, form_t6v, 3, 0, 0, 0x1180, 0, 1, 11, 22 };
char form_s7[] = "Slow";
char form_s8[] = "Fast";
char form_s9[] = "Quit";
OBJECT form[] = {
 { -1,1,9, 20,0x0,0x0, 0x21180L, 0,0,24,14 },
 { 2,-1,-1, 28,0x0,0x0, form_s1, 2,1,21,1 },
 { 3,-1,-1, 29,0x8,0x0, form_t2, 2,2,22,2 },
 { 4,-1,-1, 29,0x8,0x0, form_t3, 2,4,22,2 },
 { 5,-1,-1, 29,0x8,0x0, form_t4, 2,6,22,2 },
 { 6,-1,-1, 29,0x8,0x0, form_t5, 2,8,22,2 },
 { 7,-1,-1, 29,0x8,0x0, form_t6, 2,10,22,2 },
 { 8,-1,-1, 26,0x5,0x0, form_s7, 2,12,4,1 },
 { 9,-1,-1, 26,0x5,0x0, form_s8, 9,12,4,1 },
 { 0,-1,-1, 26,0x27,0x0, form_s9, 16,12,4,1 },
};

#define FORM_RLOW 2
#define FORM_RHIGH 3
#define FORM_ILOW 4
#define FORM_IHIGH 5
#define FORM_MAXIT 6
#define FORM_SLOWDRAW 7
#define FORM_FASTDRAW 8
#define FORM_QUIT 9


rsrc_mjload() {
  int i;
  for (i = 0; i < 26; i++)
    rsrc_obfix(menu, i);
  for (i = 0; i < 10; i++)
    rsrc_obfix(form, i);
  return 0;
}

#define TRUE       1
#define FALSE      0
#define UNDEFINED -1

#define XRES   320
#define YRES   200
#define YOFFSET 11

#define BOXCOLOUR 0

int pixels[2][XRES]; /* to remember parts of picture for
                        quick drawing */

struct mfdb screen_mfdb;         /* the screen */
struct mfdb save_screen_mfdb;    /* a copy of the screen */

short screen_box[8] = {0,0,319,199,0,0,319,199};

long buff_alloc, buff_read;

long screen_size;

char filename[13] = "MANDBROT.SMB"; /* name of file */

float rlow  = -2.25, rhigh = 0.75;    /* real low and high */
float ilow  = -1.25, ihigh =  1.25;   /* imaginary low and high */
int maxit = 49;                       /* maximum number of iterations */
                                      /* if maxit = 16*n+1 then mandelbrot
                                         middle is black */
float xstep, ystep;                   /* real step and imaginary step */

int showing = FALSE;
int ev_buff[16];                      /* for event_multi */

main()
{
 gem_on();
 if (work_out.numcolors == 16) {
   clear_screen();
   load_resources();
   init();
   desk_top(); }
 else 
   form_alert(1,"[1][Use Low Resoution!][Abort]");
 gem_off(); 
}

/* load menu and form */
load_resources()
{
 if (rsrc_mjload()) {
   form_alert(1,"[1][Unable to load resource!][Abort]");
   gem_off(); }
}

/* set mfdb parameters */
init()
{
 screen_mfdb.fd_addr = NULL;

 save_screen_mfdb.fd_w = XRES;
 save_screen_mfdb.fd_wdwidth = XRES>>4;
 save_screen_mfdb.fd_h = YRES;
 save_screen_mfdb.fd_stand = 0;
 save_screen_mfdb.fd_nplanes = 4;
 screen_size = (long)((XRES/2)*YRES);
 save_screen_mfdb.fd_addr = Malloc(screen_size);
}

/* top level loop */
desk_top()
{
 menu_bar(menu,TRUE);       /* show menu */
 /* turn select and save menu entries off until mandelbrot is showing */
 menu_enable(menu,SAVE,FALSE);
 menu_enable(menu,SELECT,FALSE);
 mouse_arrow();
 while (TRUE) {
   int dummy,event;
   event = event_multi(MU_MESAG,
                       1,1,1,
                       0,0,0,0,0,
                       0,0,0,0,0,
                       ev_buff,
                       0,0,
                       &dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
 if (event & MU_MESAG)
   read_message(); }
}

/* Read a message from ev_buff */
read_message()
{
 switch(ev_buff[0]) {
 case MN_SELECTED:
   do_menu();
   menu_bar(menu,TRUE);
   break;
 default:
   break; }
}

/* Handle menu selection */
do_menu()
{
 switch(ev_buff[3]) {
 case DESKMENU:
   do_deskmenu();
   break; 
 case FILEMENU:
   do_filemenu();
   break;
 case DRAWMENU:
   do_drawmenu();
   break;
 default:
   break;  }   
 menu_tnormal(menu,ev_buff[3],1);
}

/* Handle desk menu selection */
do_deskmenu()
{
 switch(ev_buff[4]) {
 case ABOUT:
   form_alert(1,
"[0][    Mandelbrot|Stephen M. Bennett  |   January 1990][Okay]");
   break; 
 default:
   break;  }   
}

/* Handle file menu selection */
do_filemenu()
{
 switch(ev_buff[4]) {
 case LOAD:
   load_mandelbrot();
   break;
 case SAVE:
   save_mandelbrot();
   break; 
 case QUIT:
   Mfree(save_screen_mfdb.fd_addr);
   gem_off();
   break; 
 default:
   break;  }   
}

/* Handle draw menu selection */
do_drawmenu()
{
 switch(ev_buff[4]) {
 case ENTER:
   enter_values(rlow,rhigh,ilow,ihigh,maxit);
   break;
 case SELECT:
   select_area();
   break; 
 default:
   break;  }   
}


 /* 
    Present dir loader
    Load vars
    Load and display picture
 */
load_mandelbrot()
{
 if (find_file()) {
   int fd;
   fd = Fopen(filename,0);
   if (fd < 0)
     form_alert(1,"[1][Cannot Open File][Okay]");
   else {
     float trlow, trhigh, tilow, tihigh;
     trlow = rlow;
     trhigh = rhigh;
     tilow = ilow;
     tihigh = ihigh;
     mouse_hourglass();
     Fread(fd,4L,&rlow);
     Fread(fd,4L,&rhigh);
     Fread(fd,4L,&ilow);
     Fread(fd,4L,&ihigh);
     Fread(fd,2L,&maxit);
     Fread(fd,screen_size,save_screen_mfdb.fd_addr); 
     Fclose(fd); 
     mouse_arrow();
     if (showing &&
         float_ge(rlow,trlow) && 
         float_le(rhigh,trhigh) &&
         float_ge(ilow,tilow) && 
         float_le(ihigh,tihigh)) {
       int x1, x2, y1, y2;
       x1 = convert(0,XRES-1,trlow,trhigh,rlow);
       x2 = convert(0,XRES-1,trlow,trhigh,rhigh);
       y1 = convert(YOFFSET,YRES-1,tihigh,tilow,ihigh);
       y2 = convert(YOFFSET,YRES-1,tihigh,tilow,ilow);
       draw_box(x1,y1,x2,y2); }
     restore_screen();
     showing = TRUE;
     /* turn select and save menu entries on */
     menu_enable(menu,SAVE,TRUE);
     menu_enable(menu,SELECT,TRUE); }}
}

 /* 
    Present dir loader
    Save vars and picture
 */
save_mandelbrot()
{
 if (find_file()) {
   int fd;
   fd = Fcreate(filename,0);
   if (fd < 0) fd = Fopen(filename,1);
   if (fd < 0)
     form_alert(1,"[1][Cannot Open File][Okay]");
   else {
     mouse_hourglass();
     Fwrite(fd,4L,&rlow);
     Fwrite(fd,4L,&rhigh);
     Fwrite(fd,4L,&ilow);
     Fwrite(fd,4L,&ihigh);
     Fwrite(fd,2L,&maxit);
     save_screen();
     Fwrite(fd,screen_size,save_screen_mfdb.fd_addr); 
     Fclose(fd);
     mouse_arrow(); }}
}

/*
   Put values into form.
   Allow form to be edited.
   If draw returned then set values and draw.
*/
enter_values(trlow,trhigh,tilow,tihigh,tmaxit)
float trlow, trhigh, tilow, tihigh;
int tmaxit;
{
 int r;
 put_values(trlow,trhigh,tilow,tihigh,tmaxit);
 r = edit_values();
 if (r == FORM_SLOWDRAW || r == FORM_FASTDRAW) {
   set_values();
   if (r == FORM_SLOWDRAW) 
     slowdraw_mandelbrot();
   else
     fastdraw_mandelbrot(); 
   showing = TRUE;
   /* turn select and save menu entries on */
   menu_enable(menu,SAVE,TRUE);
   menu_enable(menu,SELECT,TRUE); }
}

/*  
   Use rubber box to find values of area.
   Then allow values to be changed with enter_values
   This will draw mandelbrot if user wishes
*/
select_area()
{
 float trlow, trhigh, tilow, tihigh;
 int x,y,m = 0,k,w,h,y1;
 graf_mouse(3,0);
 while (m == 0) {
   graf_mkstate(&x,&y,&m,&k); }
 graf_rubberbox(x,y,1,1,&w,&h);
 mouse_arrow();
 save_screen();
 revert(0,XRES-1,x,rlow,rhigh,&trlow);
 revert(0,XRES-1,x+w,rlow,rhigh,&trhigh);
 revert(YOFFSET,YRES-1,y+h,ihigh,ilow,&tilow);
 tihigh = (trhigh - trlow + 1.2*tilow)/1.2;
 y1 = convert(YOFFSET,YRES-1,ihigh,ilow,tihigh);
 draw_box(x,y1,x+w,y+h);
 restore_screen();
 enter_values(trlow,trhigh,tilow,tihigh,maxit); 
}

/* put the values in the form */
put_values(trlow,trhigh,tilow,tihigh,tmaxit)
float trlow, trhigh, tilow, tihigh;
int tmaxit;
{
 char s[32];
 sprintf(s,"%f",trlow);
 s[10] = '\0';
 strcpy(((struct text_edinfo *)(form[FORM_RLOW].ob_spec))->te_ptext,s);
 sprintf(s,"%f",trhigh);
 s[10] = '\0';
 strcpy(((struct text_edinfo *)(form[FORM_RHIGH].ob_spec))->te_ptext,s);
 sprintf(s,"%f",tilow);
 s[10] = '\0';
 strcpy(((struct text_edinfo *)(form[FORM_ILOW].ob_spec))->te_ptext,s);
 sprintf(s,"%f",tihigh);
 s[10] = '\0';
 strcpy(((struct text_edinfo *)(form[FORM_IHIGH].ob_spec))->te_ptext,s);
 sprintf(s,"%d",tmaxit);
 s[10] = '\0';
 strcpy(((struct text_edinfo *)(form[FORM_MAXIT].ob_spec))->te_ptext,s);
}

/* Allow user to edit form and return the button pressed */
int edit_values()
{
 int x,y,w,h;
 int button;                        /* Button selected from the form */
 save_screen();                     /* Remember the screen */
 form_center(form,&x,&y,&w,&h);     /* Find coords of form */
 form_dial(0,x,y,w,h,x,y,w,h);      /* Reserve memory */
 objc_draw(form,0,10,x,y,w,h);      /* Draw form */
 button = form_do(form,FORM_RLOW);  /* Allow user to edit it */
 form_dial(3,x,y,w,h,x,y,w,h);      /* Release memory */
 form[FORM_SLOWDRAW].ob_state = NORMAL; /* Reset slow draw button */
 form[FORM_FASTDRAW].ob_state = NORMAL; /* Reset fast draw button */
 form[FORM_QUIT].ob_state = NORMAL; /* Reset quit button */
 restore_screen();                  /* Restore the screen */
 return(button);                    /* Return which button was pressed */
}

/* Get values out of form */
set_values()
{
 sscanf(((struct text_edinfo *)(form[FORM_RLOW].ob_spec))->te_ptext,
        "%f",&rlow);
 sscanf(((struct text_edinfo *)(form[FORM_RHIGH].ob_spec))->te_ptext,
        "%f",&rhigh);
 sscanf(((struct text_edinfo *)(form[FORM_ILOW].ob_spec))->te_ptext,
        "%f",&ilow);
 sscanf(((struct text_edinfo *)(form[FORM_IHIGH].ob_spec))->te_ptext,
        "%f",&ihigh);
 sscanf(((struct text_edinfo *)(form[FORM_MAXIT].ob_spec))->te_ptext,
        "%d",&maxit);
 xstep = (rhigh - rlow) / ((float) XRES);
 ystep = (ihigh - ilow) / ((float) (YRES-YOFFSET));
}

/* draw the mandelbrot curve fast */
fastdraw_mandelbrot()
{
 int y = 0;
 float cimag;
 int line = 0;

 clear_screen();
 mouse_off();
 cimag = ilow+y*ystep;
 draw_mandelbrot_line(y,cimag,line);         /* draw first line */
 y = y+2;
 while (y < YRES-YOFFSET) {
   line = 1-line;                            /* toggle line */
   cimag = ilow+y*ystep;
   draw_mandelbrot_line(y,cimag,line);
   cimag = ilow+(y-1)*ystep;
   guess_mandelbrot_line(y-1,cimag,1-line);  /* fill in between line */
   y = y+2; }
 if (y == YRES-YOFFSET) {                /* catch last line */
   y--;
   line = 1-line;                            /* toggle line */
   cimag = ilow+y*ystep;
   draw_mandelbrot_line(y,cimag,line); }
 mouse_on();
}

draw_mandelbrot_line(y,cimag,line)
int y,line;
float cimag;
{
 int x = 0;
 float creal;

 creal = rlow+x*xstep;
 compute_mandelbrot(x,y,cimag,creal,line);    /* draw first pixel */
 x = x+2;
 while (x < XRES) {
   creal = rlow+x*xstep;
   compute_mandelbrot(x,y,cimag,creal,line);
   if (pixels[line][x] == pixels[line][x-2]) {
     pixels[line][x-1] = pixels[line][x];
     plot(x-1,YRES-1-y,pixels[line][x-1]); }
     else {
       creal = rlow+(x-1)*xstep;
       compute_mandelbrot(x-1,y,cimag,creal,line); }
   x = x+2; }
 if (x == XRES) {                            /* catch last dot */
   x--;
   creal = rlow+x*xstep;
   compute_mandelbrot(x,y,cimag,creal,line); }
}

guess_mandelbrot_line(y,cimag,line)
int y,line;
float cimag;
{
 int x;

 for(x = 0;x < XRES;x++) {
   if (pixels[0][x] == pixels[1][x])
     plot(x,YRES-1-y,pixels[0][x]);
   else {
     float creal;
     creal = rlow+x*xstep;
     compute_mandelbrot(x,y,cimag,creal,line); }}
}

/* draw the mandelbrot curve slow */
slowdraw_mandelbrot()
{
 int x,y;
 float creal,cimag;
 int line = 0;

 clear_screen();
 mouse_off();
 for(y = 0;y < YRES-YOFFSET;y++) {
   cimag = ilow+y*ystep;
   for(x=0;x<XRES;x++) {
     creal = rlow+x*xstep;
     compute_mandelbrot(x,y,cimag,creal,line); }}
 mouse_on(); 
}

compute_mandelbrot(x,y,cimag,creal,line) 
float cimag, creal;
int x,y,line;
{
 int iterations = 0;
 float zreal = 0, zimag = 0, tmp;
 do {
   tmp = (zreal*zreal) - (zimag*zimag) + creal;
   zimag = 2*zreal*zimag+cimag;
   zreal = tmp;
   iterations++; }
 while ( ((zreal*zreal) + (zimag*zimag)) <= 4
         && iterations < maxit);
 pixels[line][x] = iterations & 15;
 plot(x,YRES-1-y,pixels[line][x]);
}

plot(x,y,c)
{
 int a[4];
 vsl_color(handle,c);
 a[0] = x; a[1] = y;
 a[2] = x; a[3] = y;
 v_pline(handle,2,a);
}

save_screen()
{
 mouse_off();
 vro_cpyfm(handle,S_ONLY,screen_box,&screen_mfdb,&save_screen_mfdb);
 mouse_on();
}

restore_screen()
{
 mouse_off();
 vro_cpyfm(handle,S_ONLY,screen_box,&save_screen_mfdb,&screen_mfdb);
 mouse_on();
}

find_file()
{
 char path[64]; 
 int b;
 strcpy(path,"A:\*.*");
 save_screen(); 
 fsel_input(path,filename,&b);
 restore_screen(); 
 if (b) {
   int i;
   for(i=strlen(path);path[i] != '\\' && i > 0;i--);
   path[i] = '\0';
   Dsetdrv(path[0]-65);
   Dsetpath(path+2); }
 return(b);
}

int convert(s1,s2,r1,r2,r)
int s1,s2;
float r1,r2,r;
{
 int i;
 /*
    returns (r-r1)*(s2-s1) 
            -------------- + s1
                (r2-r1)            
 */
 i = (r-r1)*((float)(s2-s1))/(r2-r1);
 return(i + s1);
}

revert(s1,s2,s,r1,r2,r)
int s1,s2,s;
float r1,r2,*r;
{
 float f1, f2, f3, f4, f5;
 /*
    returns (s-s1)*(r2-r1)
            -------------- + r1
                (s2-s1)            
 */
 f1 = s-s1;
 f2 = r2 - r1;
 f3 = s2-s1;
 f4 = f1 * f2;
 f5 = f4/f3;
 *r = f5 + r1;
}

draw_box(x1,y1,x2,y2)
{
 int a[10];
 vsl_color(handle,BOXCOLOUR);
 a[0] = x1; a[1] = y1;
 a[2] = x2; a[3] = y1;
 a[4] = x2; a[5] = y2;
 a[6] = x1; a[7] = y2;
 a[8] = x1; a[9] = y1;
 mouse_off();
 v_pline(handle,5,a);
 Crawcin();
 mouse_on();
}

/* needed because <=,>= does not work for floats */
int float_ge(f1,f2)
float f1,f2;
{
 return((f1 -f2) >= 0);
}

int float_le(f1,f2)
float f1,f2;
{
 return((f1 -f2) <= 0);
}

