/*
   CAVEAT:
   If the 40 folder TOS bug is present this program will activate it!

Fontlist.c

Lists the file name and font name of every Calamus or PS type 1 font
within a path. Lists them in sub directories too.
 
The OS specific uncommented source is included.


Matthew Carey 1995.

This is written for Lattice C 5 some of the names of types have to be
changed for GCC, include files need renaming and perhap dfind substituted 
with Fsfirst and Fsnext

This program is without warranty and is placed in the public domain in the 
vain hope it might be useful to somebody.

*/


#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>
#include <osbind.h>

#include "listfonr.h"
#include "listfont.h"

#define  NO_CLIP    0
#define  CLIP       1

#define MAX(x,y) (x)>(y)?(x):(y)
#define MIN(x,y) (x)<(y)?(x):(y)

#define WF_PARTS   NAME|MOVER|CLOSER


#define  NO_CLIP    0
#define  CLIP       1

#define MAX(x,y) (x)>(y)?(x):(y)
#define MIN(x,y) (x)<(y)?(x):(y)



short gdos;

short scrn_w, scrn_h, vplanes;
size_t pathTextLen,listTextLen;
short subevents = MU_MESAG | MU_TIMER | MU_KEYBD | MU_M1 | MU_M2;

unsigned long _STACK = 0x10000L;

typedef struct tag_folder
{
     struct tag_folder *sibling;
     struct tag_folder *child;
     char name[16];
} FOLDER;


short
select_file(char *file_name, char *tail, char *label);
void
get_dir(void);
int insert_sub_f(FOLDER *pf, char *name);
int init_f(FOLDER **ppf, char *name);
int build_root(FOLDER **ppfRoot, char *path, short whand, short vw);
void get_folder_name(char *path, char *name);
int build_tree(FOLDER *pfCurrent, char *path, short whand, short vw);
int walk_tree(FOLDER *pfCurrent,  char *path, FILE *fpList, short whand, short vw, short mode);
void free_tree(FOLDER *pfTarget);
int list_fonts(FILE *fpList,char *name, short whand, short vw, short mode);
void get_volume_name (char *volume, char *path);
void clip_work(short whand,
               short vw_handle);
void close_all(struct object *main_addr,
               short whand);
void close_window(short whand);
short dialogue(OBJECT *box_tree,
               int field);
short do_menu(short title,
              short item,
              short whand,
              short vw);
short do_main_menu(short item,
                   short whand,
                   short vw);
short got_key(short ch,
              short whand,
              short vw);
void hide_mouse(void);
void show_mouse(void);
void just_draw(short whand,
               short x,
               short y,
               short w,
               short h,
               short vw);
int main(void);
void get_dir(void);
short mouse_hit(short butdown,
                short x,
                short y,
                short kstate,
                short num_clicks,
                short whand,
                short vw);
short submulti( short *pWhand, short *pVw);
short multi(short events,
            short *wh,
            short milli_secs,
            short *vw);
short open_vwork(short handle);
short open_window(char *name,
                  short vertical,
                  short horizontal,
                  short vsize,
                  short hsize,
                  short dx,
                  short dy,
                  short dw,
                  short dh);
void do_redraw(short xc,
              short yc,
              short wc,
              short hc,
              short whand,
              short vw);
short setup_screen(void);
short setup_window(char *name,
                   short vp,
                   short hp,
                   short vs,
                   short hs,
                   short dx,
                   short dy,
                   short dw,
                   short dh);
short show_form(char *s);
short was_msg(short msg,
               short title,
               short x,
               short y,
               short w,
               short h,
               short  *whand,
               short *vw);
short find_parent(struct object *tree, short index);
void child_deselect(short parent,OBJECT *tree);
short tree_radio(short index, OBJECT *tree);
void tree_redraw(short index, OBJECT *tree, short whand, short vw);
short handle_main_dial(short but, short whand, short vw);
void forRun(short mode, short whand, short vw);



typedef struct tagControl
{
     char *description;
     char *tail;
     int  (*pfuncList)(char *,char *,size_t ,FILE *, short);
} CONTROL;

#define FONTTYPES 15

CONTROL controlTable[FONTTYPES] =
{
     "Postscript Type 1","*.PFB",postList,
     "Postscript Type 1 (disabled)","*.PFX",postList,
     "Ghostscript","*.GSF",ghostList,
     "Postscript ASCII","*.PFA",ghostList,
     "Calamus","*.CFN",calamusList,
     "TrueType","*.TTF",ttfList,
     "TrueType (disabled)","*.TTX",ttfList,
     "Speedo","*.SPD",speedoList,
     "Speedo (disabled)","*.SPX",speedoList,
     "GEM Gdos","*.FNT",GEMList,
     "GEM Gdos (disabled)","*.FNX",GEMList,
     "Calligrapher Vector","*.LAC",caligList,
     "Pagestream","*.DMF",dmfList,
     "Compugraphic","*.CG",cgList,
     "Postscript Type 3","*.PS",post3List
};



char datdir[160];

/*
   To descend into subdirectories I create a binary tree of the 
   directories as I find them. The root directory has only a child
   the other directories in the root directory are that childs siblings.
   Each child or sibling can itself have a child with siblings.   

   After the tree is created I can safely recursivley descend into it 
   and traverse it searching each subdirectory for Postscript and Calamus 
   fonts without risk of getting into a loop of searching the same 
   directories again and again.

   CAVEAT:
   If the 40 folder TOS bug is present this program will activate it!

*/

int insert_sub_f(FOLDER *pf, char *name)
{
     FOLDER *pfNewborn, *pfSibling;

     if (!init_f(&pfNewborn, name)) return 0;
     if(!pf->child)
     {
          pf->child=pfNewborn;
     } 
     else
     {
          pfSibling=pf->child;
          while(pfSibling->sibling)pfSibling=pfSibling->sibling;
          pfSibling->sibling=pfNewborn;
     }
     return 1;
}

int init_f(FOLDER **ppf, char *name)
{
     *ppf=(FOLDER *)malloc(sizeof(FOLDER));
     if (!*ppf) return 0;
     strncpy((*ppf)->name,name,12);
     (*ppf)->name[12]=0;
     (*ppf)->sibling = NULL;
     (*ppf)->child = NULL;
     return 1;
}

int build_root(FOLDER **ppfRoot, char *path, short whand, short vw)
{
     char name[16];

     get_folder_name(path,name);
     if (!init_f(ppfRoot,name)) return 0;

     return build_tree(*ppfRoot, path, whand, vw);
}

void get_volume_name (char *volume, char *path)
{
     char root_path[7];
     struct FILEINFO info;

     strncpy (root_path,path,3);
     root_path[3]=0;
     strcat (root_path,"*.*");
     volume[0]=0;
     if (!dfind(&info,root_path,8))
     {
          do
          {
               if (info.attr & 8) strcpy(volume,info.name);
          }while(!dnext(&info) && !volume[0]);
     }
}


void get_folder_name(char *path, char *name)
{
     char *pchLastSlash;
     pchLastSlash = strrchr(path,'\\');
     if (pchLastSlash) 
     {    
          *pchLastSlash = 0;
          pchLastSlash = strrchr(path,'\\');
          if (pchLastSlash) 
          {       
               strcpy (name, pchLastSlash+1);
               pchLastSlash[1] = 0;
          }
          else 
          {
               strncpy(name,path,13);
               path[0]=0;
          }
     }
     else
     {
          strncpy(name,path,13);
          path[0]=0;
     }

}

int build_tree(FOLDER *pfCurrent, char *path, short whand, short vw)
{
     struct FILEINFO info;
     FOLDER *pfChild;
     size_t len;
     char *pch;

     len = strlen(path);
     
     strcat(path,pfCurrent->name);
     strcat(path,"\\*.*");

/*
     printf("buildtree %s\n",path);
*/
     if (submulti( &whand, &vw)) return 0;

     if (!dfind (&info,path, FA_SUBDIR))
     {    
          do
          {
               if(info.name[0]!='.' && info.attr==FA_SUBDIR)
               {
                    if(!insert_sub_f(pfCurrent,info.name))
                         return 0;
               }
          } while (!dnext(&info));

          pch = strrchr(path,'\\');
          if (pch) 
               pch[1] = 0;
          else path[0] = 0;
          
          pfChild=pfCurrent->child;
          while (pfChild)
          {
               if (!build_tree(pfChild, path, whand, vw)) return 0;
               pfChild=pfChild->sibling;
          }
     }
     path[len]=0; 
     return 1;
}
     

int walk_tree(FOLDER *pfCurrent,  char *path, FILE *fpList, short whand,
                short vw, short mode)
{
     FOLDER *pfChild;
     size_t len;


     len = strlen(path);
     strcat(path,pfCurrent->name);
     strcat(path,"\\");

/*
     printf("Walktree %s\n",path);
*/
     pfChild = pfCurrent->child;
     while (pfChild) 
     {
          if (walk_tree(pfChild, path, fpList, whand, vw, mode)) return 1;
          pfChild=pfChild->sibling;
     }
     if (submulti( &whand, &vw)) return 1;

     if (list_fonts(fpList,path, whand, vw, mode)) return 1;
     path[len]=0;
}

void free_tree(FOLDER *pfTarget)
{
     if (pfTarget->child) free_tree(pfTarget->child);
     pfTarget->child=NULL;
     if (pfTarget->sibling) free_tree(pfTarget->sibling);
     pfTarget->sibling=NULL;
     free(pfTarget);
}




int list_fonts(FILE *fpList,char *name, short whand, short vw, short mode)
{
     struct FILEINFO info; 
     char pth[250], fontname[250];
     size_t len;
     int c;

     len =strlen(name);

     strcpy(pth,name);

     for (c=0;c<FONTTYPES;c++)
     {
          if (submulti( &whand, &vw)) return 1;          
          strcat(name,controlTable[c].tail);

/*     printf(" List fonts %s\n",name); */

          if (!dfind(&info,name,0)) 
          {
               if (!mode)fprintf (fpList,"Folder %s - %s Fonts\n", name, controlTable[c].description);
               do
               {
     
                    strcpy(fontname,pth);
                    strcat(fontname,info.name);

                    if ((*controlTable[c].pfuncList)(fontname, info.name, info.size, fpList, mode)) return 1;

                    if (submulti( &whand, &vw)) return 1;

               } while (!dnext(&info));
          }
          name[len]=0;

     }
     return 0;
}



short
select_file(char *file_name, char *tail, char *label)
{
   short button;
   char  newfile[128];
   char *last_slash /*, *p */;


   last_slash=file_name;  /* extract file name */
   last_slash=strrchr(file_name,'\\');


   if (last_slash) 
   {
         strcpy(newfile,last_slash+1);
                     /* extract directory */
         strcpy(datdir,file_name);
         last_slash=strrchr(datdir,'\\');
         if (last_slash) *(last_slash + 1) = 0;
 
   }
   else strcpy(newfile,file_name);
                     /* glue on correct tail */
/*
   for (p=newfile; *p && *p != '.' && *p != ' '; p++);
   *p= '.'; 
   *(p+1) = '\0';
*/

   strcat(datdir,"*.");
   strcat(datdir,tail);
 
   if ( (fsel_exinput(datdir,newfile,&button,label)==0) || 
      (button == 0) )   /* CANCEL button*/
          return 0;

    datdir[128]=0;
    newfile[15]=0;
    last_slash=strrchr(datdir,'\\');
    if (last_slash) *(last_slash + 1) = 0;

    sprintf(file_name,"%s%s",datdir,newfile);
    return 1;
}

void
get_dir(void)
{
   char curdir[100];
   short drv;

   curdir[0] ='\0';
   drv = Dgetdrv();
   Dgetpath(curdir,(short)(drv+1));
   sprintf(datdir, "%c:%s\\",drv+'A',curdir);
}

unsigned char *memsearch(unsigned char *targ,
                unsigned char *model,
                size_t len,
                unsigned char *end)
{
     unsigned char *ptr;

     end=end-len;

     for (ptr=targ;ptr<end;ptr++)
       if (!memcmp(ptr,model,len)) return ptr; 
     return NULL;
}

unsigned long intel_long(unsigned char array[4])
{
     long ret;

     ret = array[3];
     ret = ret << 8;
     ret |= array[2];
     ret = ret << 8;
     ret |= array[1];
     ret = ret << 8;
     ret |= array[0];
     return ret;
}

void clip_work(short whand, short vw_handle)
{
      short temp[4];
      short x, y, w, h;
      
      wind_get(whand,WF_WORKXYWH,&x,&y,&w,&h);
      temp[0] = x;
      temp[1] = y;
      temp[2] = x + w - 1;
      temp[3] = y + h - 1;
      vs_clip( vw_handle, CLIP, temp );
}

void close_all(struct object *main_addr,short whand)
{
      close_window( whand);
      menu_bar( MAINMENU, 0);
}     

void close_window(short whand)
{
     short x, y, w, h;
     
     if(whand!=-1)
     {
          wind_get(whand,WF_WORKXYWH,&x,&y,&w,&h);
          wind_close(whand);
          graf_shrinkbox(x+w/2,y+h/2,2,2,x,y,w,h);
          wind_delete(whand);
     }
}     



char *wind_name      = " List Font ";


short interval        = 30000;
short events = MU_MESAG | MU_BUTTON | MU_KEYBD | MU_M1 | MU_M2;


/*
short dialogue(OBJECT *box_tree, int field)
{
         short x, y, w, h, littlex, littley, littlew, littleh;
         short ret;

         if (field < 0) field = 0;
         form_center(box_tree,&x,&y,&w,&h);
         littlew = littleh = 50;
         littlex = x + w / 2 - littlew;
         littley = y + h / 2 - littleh;
         form_dial(FMD_START,littlex,littley,littlew,littleh,x,y,w,h);
         form_dial(FMD_GROW,littlex,littley,littlew,littleh,x,y,w,h);
         objc_draw(box_tree,0,1,x,y,w,h);
         ret=(int)form_do(box_tree,field);
         form_dial(FMD_SHRINK,littlex,littley,littlew,littleh,x,y,w,h);
         form_dial(FMD_FINISH,littlex,littley,littlew,littleh,x,y,w,h);
         return (ret);
}

*/

short do_menu(short title, short item, short whand, short vw)
{
     short ret=0;

     menu_tnormal(MAINMENU,title,1);
     menu_tnormal(MAINMENU,item,1);
     ret  = do_main_menu(item,whand,vw);
     return (ret);
}


short do_main_menu(short item, short whand, short vw)
{
     char str[256];
     short ret=0;


       switch(item)
       {
           case MNQUIT:
               ret = handle_main_dial(CANCELBUT,whand,vw);
               break;

          case MNTARG:
               handle_main_dial(TARGETBUT,whand,vw);
               break;

          case MNREPLACE:
               handle_main_dial(REPLACEBUT,whand,vw);
               break;

          case MNAPPEND:
               handle_main_dial(APPENDBUT,whand,vw);
               break;

          case MNDBASE:
               handle_main_dial(DBASEBUT,whand,vw);
               break;

          case MNLIST:
                handle_main_dial(LISTINGBUT,whand,vw);
               break;

          case MNOK:
                handle_main_dial(OKBUT,whand,vw);
               break;

           case MNABOUT:
               form_alert(1,"[0][ Listfont by Matthew Carey| |"
                            " comments and suggestions to: |"
                              " mcareyb@cix.compulink.co.uk][Ok]");
               break;
            default:
                sprintf(str,"[1][%s %d][ OK ]","Unknown menu member!",item);
                form_alert(1,str);
                break;
       }
       return ret;
}

/*
**
** Here is where we handle keystrokes
**
*/

#define UP__ARROW 0x4800
#define DN__ARROW 0x5000
#define LF__ARROW 0x4b00
#define RT__ARROW 0x4d00
#define C_RETURN  '\r'
#define ESCAPE    0x1b
#define CTRL_A    0x01
#define CTRL_C    0x03
#define CTRL_D    0x04
#define CTRL_M    0x0D
#define CTRL_Q      0x11
#define CTRL_L      0x0C
#define CTRL_R      0x12
#define CTRL_T      0x14

#define HELPKEY   0x6200

short got_key(short ch, short whand, short vw)
{
     short c, ret=0;

     c=ch & 0xFF;
     switch(c)
     {
          case CTRL_Q:
               ret = handle_main_dial(CANCELBUT,whand,vw);
               break;

          case CTRL_T:
               handle_main_dial(TARGETBUT,whand,vw);
               break;

          case CTRL_L:
               handle_main_dial(LISTINGBUT,whand,vw);
               break;

          case CTRL_R:
               handle_main_dial(REPLACEBUT,whand,vw);
               break;

          case CTRL_A:
               handle_main_dial(APPENDBUT,whand,vw);
               break;

          case CTRL_D:
               handle_main_dial(DBASEBUT,whand,vw);
               break;

          case C_RETURN:
               handle_main_dial(OKBUT,whand,vw);
               break;

          default:     
               switch( ch )
               {
                    case HELPKEY:
                         form_alert(1,"[1][No help yet?]"
                              "[Sorry]"); 

                    default:
                         break;
               }
          break;
      }
      return (ret);
}

/*
** These routines keep us from having to worry about how many
** times we hid the mouse, and how many times we tried to show it
*/


static int mouse_gone;       /* is the mouse visible? */

void hide_mouse(void)
{
     if(! mouse_gone)
     {
          graf_mouse(M_OFF, 0x0L);
          mouse_gone = ! mouse_gone;
     }
}


void show_mouse(void)
{
     if( mouse_gone)
     {
          graf_mouse(M_ON, 0x0L);
          mouse_gone = ! mouse_gone;
     }
}


/*
** Clear the display by drawing a white bar whose width is the screen
** width and whose lenth is the screen length
*/

 

void
just_draw(short whand, short x, short y, short w, short h, short vw)
{

        hide_mouse();
        clip_work(whand,vw);
        objc_draw(MAINDIAL,0,MAX_DEPTH,x,y,w,h);
        show_mouse();
}



/*
** This is where we begin 
** We set up the screen so that we can write things on it.
** We save the old colour map so that we reset it before we exit.
** We set up the windows with sliders, a title etc.
** We change the mouse from an arrow to pointing finger (for fun).
** We call multi() to handle all of the mouse and keyboard input.
** Then we restore the the color map and exit.
*/



#define HIDE_CURSOR 0
#define SHOW_CURSOR 1

int main(void)
{
     short wh, vw_hand, fx, fy, fw, fh;

     rsrc_init();

     get_dir();
     vw_hand = setup_screen();

     graf_mouse(ARROW, 0x0L);

     wh = -1;
     wind_get(0, WF_WORKXYWH, &fx, &fy, &fw, &fh );
     wh = setup_window(wind_name,0,0,1000,1000,fx,fy,fw,fh);


     multi(events,&wh, 0 ,&vw_hand);

     close_all(MAINMENU,wh);

     v_clsvwk(vw_hand);
     appl_exit();
     return 0;
}




#define ANY_SHIFT  3
#define XOR_MODE   3
#define RPLC_MODE  1

#define MIN_WIDE   25
#define MIN_HIGH   25

short mouse_hit(short butdown, short x, short y, short kstate,
                    short num_clicks, short whand, short vw)
{
     short  xwork, ywork, wwork, hwork,top,dummy,but;

          
     if(butdown == 0)
          return(1);

     wind_get(whand, WF_TOP, &top,&dummy,&dummy,&dummy);
     if (top != whand) return(0);
     wind_get(whand, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);

     if ((x<xwork || x>xwork+wwork) && (y<ywork || y>ywork+hwork))
          return (0);


     but=objc_find(MAINDIAL, ROOT, MAX_DEPTH,x,y);

     return (handle_main_dial(but, whand, vw));
}

short handle_main_dial(short but, short whand, short vw)
{
     static short depth=0;

     short  error, mode, xwork, ywork, wwork, hwork, ret = 0;
     char pathname[160],pth[160], mapname[160], *ptr, str[150], volume[16];
     FILE *mapfp;
     FOLDER *pfRoot;

     wind_get(whand, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);

     depth++;
     strncpy(pathname,((TEDINFO *)MAINDIAL[PATHTEXT].ob_spec)->te_ptext,pathTextLen);
     pathname[pathTextLen]=0;
     strncpy(mapname,((TEDINFO *)MAINDIAL[LISTTEXT].ob_spec)->te_ptext,listTextLen);
     mapname[listTextLen]=0;


     if (MAINDIAL[but].ob_flags & SELECTABLE 
          && (MAINDIAL[but].ob_state & DISABLED)==0)
     {
          if (MAINDIAL[but].ob_flags & EXIT)
          {
               MAINDIAL[but].ob_state |= SELECTED;
               do_redraw(xwork,ywork ,wwork,hwork ,whand,vw);
               
               
               switch (but)
               {
     

                case TARGETBUT:
                         strcat(pathname,"PathOnly");
                         select_file(pathname, "*","Select Path");
                         ptr = strrchr(pathname,'\\');
                         if (ptr) 
                              ptr[1] = 0;
                         strncpy(((TEDINFO *)MAINDIAL[PATHTEXT].ob_spec)->te_ptext,pathname,pathTextLen);
                         ((TEDINFO *)MAINDIAL[PATHTEXT].ob_spec)->te_ptext[pathTextLen]=0;
                         break;

                 case LISTINGBUT:
                         select_file(mapname, "LST","Select Output file");
                         if (mapname[0])
                         {
                              if (mapname[strlen(mapname)-1]=='\\') strcat(mapname,"FONTLIST.MAP");
                         }
                         else                         
                         {
                              strcpy(mapname,datdir);
                              strcat(mapname,"FONTMAP.LST");
                         }
                         strncpy(((TEDINFO *)MAINDIAL[LISTTEXT].ob_spec)->te_ptext,mapname,listTextLen);
                         ((TEDINFO *)MAINDIAL[LISTTEXT].ob_spec)->te_ptext[listTextLen]=0;
                         break;

                    case OKBUT:
                         mode=(MAINDIAL[DBASEBUT].ob_state & SELECTED)!=0;
                         mapfp=fopen (mapname,
                              MAINDIAL[APPENDBUT].ob_state & SELECTED ? "aa":"wa" );
                         forRun(0,whand,vw); 
                         if (!mapfp)
                         {
                              ptr=strrchr(mapname,'\\');
                              if (ptr) ptr++;
                              else ptr=mapname;

                              sprintf(str,"[1][Couldn't open |%s][Ok]",ptr);
                              form_alert(1,str);
                              forRun(1,whand, vw);
                              break;
                         }

                         strcpy(pth,pathname);
                         get_volume_name (volume,pathname);
                         if (!mode) fprintf(mapfp,"\nFont report on %s Volume: %s\n\n",
                              pathname, volume[0]?volume:"<No Volume name>");
                         ptr = strrchr(pth,'\\');
                         error=0;
                         if (ptr) ptr[1]=0;
                              else pth[0]=0;
                         if (build_root(&pfRoot,pth,whand,vw)
                         {
                              walk_tree(pfRoot,pth,mapfp,whand,vw, mode)                         
                         }
                         if (pfRoot) free_tree(pfRoot);
                         fflush(mapfp);
                         fclose(mapfp);
                         forRun(1,whand,vw);
                         break;

                     case CANCELBUT:
                         if (depth < 2)
                         {
                              if (form_alert(1,"[1][| Quit LISTFONT now? ][Quit|Cancel]")==1)
                                   ret=-1;
                         }
                         else
                         {
                             if (form_alert(1,"[1][| Abort listing now? ][Abort|Cancel]")==1)
                                   ret=-1;
                         }
                         break;
                     default:
                         break;
               }
               
               MAINDIAL[but].ob_state &= ~SELECTED;
               do_redraw(xwork,ywork ,wwork,hwork ,whand,vw);
          }
          else
          {
               if (MAINDIAL[but].ob_flags & RBUTTON && depth < 2)
               {
                    tree_redraw(tree_radio(but,MAINDIAL),MAINDIAL,whand,vw);
                    menu_icheck(MAINMENU,MNREPLACE,0);
                    menu_icheck(MAINMENU,MNAPPEND,0);
                    menu_icheck(MAINMENU,MNDBASE,0);
                    switch(but)
                    {
                         case REPLACEBUT:
                              menu_icheck(MAINMENU,MNREPLACE,1);
                              break;
                         case APPENDBUT:
                              menu_icheck(MAINMENU,MNAPPEND,1);
                              break;                         
                         case DBASEBUT:
                              menu_icheck(MAINMENU,MNDBASE,1);
                              break;
                    }
               }
          }
     }
     depth--;
     return (ret);
}


void forRun(short mode, short whand, short vw)
{
     short xwork, ywork, wwork, hwork;


     menu_ienable(MAINMENU,MNTARG,mode);
     menu_ienable(MAINMENU,MNLIST,mode);
     menu_ienable(MAINMENU,MNREPLACE,mode);
     menu_ienable(MAINMENU,MNAPPEND,mode);
     menu_ienable(MAINMENU,MNDBASE,mode);
     menu_ienable(MAINMENU,MNOK,mode);
     if (!mode)
     {
          MAINDIAL[TARGETBUT].ob_state |= DISABLED;
          MAINDIAL[LISTINGBUT].ob_state |= DISABLED;
          MAINDIAL[OKBUT].ob_state |= DISABLED;
          MAINDIAL[REPLACEBUT].ob_state |= DISABLED;
          MAINDIAL[APPENDBUT].ob_state |= DISABLED;
          MAINDIAL[DBASEBUT].ob_state |= DISABLED;
          MAINDIAL[CANCELBUT].ob_spec=ABORTBUTSTR;
          MAINMENU[MNQUIT].ob_spec=ABORTMNSTR;
          
     }
     else
     {
          MAINDIAL[TARGETBUT].ob_state &= ~DISABLED;
          MAINDIAL[LISTINGBUT].ob_state &= ~DISABLED;
          MAINDIAL[OKBUT].ob_state &= ~DISABLED;
          MAINDIAL[REPLACEBUT].ob_state &= ~DISABLED;
          MAINDIAL[APPENDBUT].ob_state &= ~DISABLED;
          MAINDIAL[DBASEBUT].ob_state &= ~DISABLED;
          MAINDIAL[CANCELBUT].ob_spec=QUITBUTSTR;
          MAINMENU[MNQUIT].ob_spec=QUITMNSTR;
     }


     wind_get(whand, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);

     do_redraw(xwork,ywork ,wwork,hwork ,whand,vw);

}

/*
** This is where all input is handled 
** We loop calling evnt_multi(), until we get a message saying
** that the user has clicked on the CLOSE patch in the upper left
** corner of the window.
*/



short multi(short events, short *wh,
            short milli_secs, short *vw)
{

      short event, timer_low, timer_high, mu_timer, m[8];
      short bbutton, kstate, nclick, mx, my, keycode, btn, r; 

      btn = 1;
      for( ;; )
      {        
              timer_high = 0;
              if( milli_secs)
              {
                  timer_low = milli_secs;
                  mu_timer = MU_TIMER;
              }
              else
              {
                  timer_low = 0;
                  mu_timer = 0;
              }
              event = evnt_multi( events|mu_timer,
                      2,             /* how many clicks possible */
                      3,             /* any buttons can click */
                      btn,           /* if button down wait for up */
                      0,0,0,0,0,       /* mouse rectangle 1 */
                      0,0,0,0,0,       /* mouse rectangle 2 */
                      m,             /* ipc & timer messages */
                      timer_low,     /* low word of timer */
                      timer_high,    /* high word of timer */
                      &mx, &my,      /* mouse coordinates */
                      &bbutton,      /* mouse button states */
                      &kstate,       /* shift key state */
                      &keycode,      /* the key that was hit */
                      &nclick   /* number of mouse clicks hit */
                      );

              show_mouse();
              if( event & MU_MESAG )
              {
                      if(r=was_msg(m[0],m[3],m[4],m[5],m[6],m[7],wh,vw))
                                return(r);
              }
              else if( event & MU_KEYBD )
              {
                      if(r=got_key(keycode,*wh,*vw))
                                return(r);
              }
              else if( event & MU_BUTTON )
              {
                      btn=mouse_hit(btn,mx,my,kstate,nclick,*wh,*vw);
                      if (btn==-1) return -1;
              }
              else if( event & MU_TIMER )
              {
                    return 0;
              }
              else
              {
                      show_form("What?");
              }
      }
}

          


#define V_SCREEN    1
#define V_PLOTTER   11
#define V_PRINTER   21
#define V_METAFILE  31
#define V_CAMERA    41
#define V_GRAFTAB   51


short open_vwork(short handle)
{
       short res;
       register int i;
       static short in[11], out[57];

 
       gdos = vq_gdos();
       res = Getrez();

       in[0] = gdos?res+2:1;      
       for ( i = 1; i < 10; i++)
              in[i] = 1;
       in[0] = V_SCREEN;
       in[10] = 2;
       /*
       ** handle comes in a graf_handle and goes out a vw_handle
       */
       v_opnvwk(in,&handle,out);
       scrn_h = out[1]+1;
       scrn_w = out[0]+1;

       vq_extnd(handle,1,out);
       vplanes= out[4];

       return (handle);
}






short open_window(char *name, short vertical, short horizontal,
                    short vsize, short hsize,
                    short dx, short dy, short dw, short dh)
{
     short wi_handle, fx, fy,fw,fh;
     char pathname[160], mapname[160];

     strcpy(mapname,datdir);
     strcpy(pathname,datdir);
     strcat(mapname,"FONTMAP.LST");

     pathTextLen= strlen(((TEDINFO *)MAINDIAL[PATHTEXT].ob_spec)->te_ptext);
     listTextLen= strlen(((TEDINFO *)MAINDIAL[LISTTEXT].ob_spec)->te_ptext);

     strncpy(((TEDINFO *)MAINDIAL[PATHTEXT].ob_spec)->te_ptext,pathname,pathTextLen);
     ((TEDINFO *)MAINDIAL[PATHTEXT].ob_spec)->te_ptext[pathTextLen]=0;
     strncpy(((TEDINFO *)MAINDIAL[LISTTEXT].ob_spec)->te_ptext,mapname,listTextLen);
     ((TEDINFO *)MAINDIAL[LISTTEXT].ob_spec)->te_ptext[listTextLen]=0;


     form_center(MAINDIAL,&fx,&fy,&fw,&fh);
     fx=MAINDIAL[0].ob_x;
     fy=MAINDIAL[0].ob_y;
     fw=MAINDIAL[0].ob_width;
     fh=MAINDIAL[0].ob_height;

     wind_calc(WC_BORDER,WF_PARTS,fx, fy, fw, fh, &fx, &fy, &fw, &fh);

     wi_handle = wind_create(WF_PARTS,fx,fy,fw,fh);
     wind_set(wi_handle, WF_NAME, ADDR(name),0,0);
     graf_growbox( fx + fy/2,fy + fh/2, 2, 2, fx, fy, fw, fh );
     wind_open(wi_handle,fx,fy,fw,fh);
     return( wi_handle );
}

/*
** This routine worries a lot about how to clean up the screen after
** a window has re-sized , moved, or dissappeared. Since there can be
** many overlapping windows, the task is not trivial
*/





void do_redraw(short xc,short yc,short wc,short hc,short whand,short vw)
{
      short clip[4];
      GRECT t1, t2;

      hide_mouse();
      wind_update(1);
      t2.g_x = xc;
      t2.g_y = yc;
      t2.g_w = wc;
      t2.g_h = hc;
      wind_get(whand,WF_FIRSTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
      while (t1.g_w && t1.g_h )
      {
              if (rc_intersect(&t2,&t1))
              {
                      clip[0] = t1.g_x;
                      clip[1] = t1.g_y;
                      clip[2] = t1.g_x + t1.g_w - 1;
                      clip[3] = t1.g_y + t1.g_h - 1;
                      vs_clip(vw,1,clip);
                      just_draw(whand,t1.g_x ,t1.g_y ,t1.g_w ,t1.g_h, vw);
               }
              wind_get(whand,WF_NEXTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
      }
      wind_update(0);
      show_mouse();
} 


/*
** To set up the screen, we must inform GEM that we are using its
** libraries.  Then we must open the "virtual workstation" which
** tell GEM that we are using the screen, and what types of lines
** and colours we want.  To open the virtual workstation, we need to
** get a "handle" from graf_handle() which points to the screen.
*/




#define NO_VWS       -1

short gl_hchar, gl_wchar, gl_wbox, gl_hbox;      /* size of character */
short gl_apid, menu_id;                                   /* accesory handle */

short setup_screen(void)
{
      
      short gr_handle;
      
      gl_apid=appl_init();
      gr_handle = graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
      return ( open_vwork(gr_handle) );
}


/*
** menus can be handled by declaring the menu structure as
** a series of object structures within the program
** or imported from a resource file made using a resource
** editor
*/




short setup_window(char *name,short vp,short hp,short vs,short hs,
                    short dx, short dy,short dw,short dh)
{
/*
     {
          rsrc_load( resource );
          rsrc_gaddr( R_TREE, MAINMENU, &main_addr);
     }
*/
     if (MAINMENU)
     {
          menu_bar( MAINMENU, 1);
     }

     return ( open_window( name, vp, hp, vs, hs, dx, dy, dw, dh) );
}

/*
** use form alert
*/

short show_form(char *s)
{
     char str2[128];
     sprintf(str2,"[1][%s][ OK | CANCEL ]",s);
     return ( form_alert(2,str2) -1);
}

/*
** Here we handle messages received by event_mult().
** if we were asked to close the main window we return a non 
** zero, which will eventually cause us to exit.
*/




#define MIN_WIDTH     10
#define MIN_HEIGHT    10
#define NO_WINDOW     -1
#define NO_VWS        -1
#define BYE_BYE       -1
#define OBLIVION      -2

short was_msg(short msg, short title, short x, short y, short w, short h,
               short  *whand, short *vw)
{
       short exit_flag, xc,yc,wc,hc,xo,yo,wo,ho;
   /* 0 = continue  BYE_BYE = exit */
       exit_flag = 0;
/*       wind_update(1); */
       switch( msg)
       {
             case WM_CLOSED:
                exit_flag=handle_main_dial(CANCELBUT,*whand,*vw);
                break;
             case MN_SELECTED:
                 exit_flag=do_menu(title,x,*whand,*vw);
                 break;
             case WM_REDRAW:
                 do_redraw(x,y,w,h,title,*vw);
                 break;
             case AC_CLOSE:
             case AC_OPEN:
                    break;
                  /* fall through top of window */
             case WM_NEWTOP: 
             case WM_TOPPED: 
                  wind_set(title,WF_TOP,0,0,0,0);
                  wind_get(title,WF_WORKXYWH,&x,&y,&w,&h);
                  do_redraw(x,y,w,h,title,*vw);
                  break;
             case WM_MOVED:
                  hide_mouse();
                  wind_get(0,WF_WORKXYWH, &xc, &yc, &wc, &hc);
                  wind_get(title,WF_CURRXYWH, &xo, &yo, &wo, &ho);
                  wind_calc(WC_WORK,WF_PARTS, xo, yo, wo, ho, &xo, &yo, &wo, &ho);
                  wind_set(title,WF_CURRXYWH, x, y, w, h);
                  wind_calc(WC_WORK,WF_PARTS, x, y, w, h, &x, &y, &w, &h);
                  wind_set(title,WF_WORKXYWH, x, y, w, h);
                  MAINDIAL[0].ob_x=x;
                  MAINDIAL[0].ob_y=y;

                 clip_work(title,*vw);
                 if (  (xo > xc) && (yo > yc) &&
                         ((xo + wo + 1) < (xc + wc) || (x + w) > (xo + wo)) &&
                         ((yo + ho + 1) < (yc + hc) || (y + h) > (yo + ho)) )
                  {

                  }
                  else
                  {
                        do_redraw(x,y,w,h,title,*vw);
                  }


                  show_mouse();

                  break;

                  break;
             case WM_SIZED: 
             case WM_ARROWED:
             case WM_VSLID: 
             case WM_HSLID: 
             case WM_FULLED:
                  break;
       }
/*       wind_update(0); */
       return( exit_flag );
}
                  

/*
   Useful routine that returns the index of the parent (if there is one)
   of any resource file object or -1
*/

short find_parent(struct object *tree, short index)
{
     if (tree[index].ob_next==-1) return -1;

     while (tree[tree[index].ob_next].ob_tail != index)
          index=tree[index].ob_next;
     return (tree[index].ob_next);
}

/*
**  Given an index of an object on the desktop
**  marks selected the object and the marks all
**  the siblings not selected and forces a redraw
**  of the immediate parent object and its offspring
*/



void child_deselect(short parent,OBJECT *tree)
{
     short sibling;
     sibling=tree[parent].ob_head;
     while (sibling != parent)
     {
          tree[sibling].ob_state &= ~SELECTED;
          sibling=tree[sibling].ob_next;
     }
}




short tree_radio(short index, OBJECT *tree)
{
     short parent;

     parent = find_parent(tree,index);
     if (parent<0) return 0;

     child_deselect(parent,tree);
     tree[index].ob_state |= SELECTED;
     return (parent);
}

void tree_redraw(short index, OBJECT *tree, short whand, short vw)
{
     short x,y,w,h;
     GRECT rect;

     objc_xywh(tree,index,&rect);
     x=rect.g_x;
     y=rect.g_y;
     w=rect.g_w;
     h=rect.g_h;
     do_redraw(x,y,w,h,whand,vw);

}

void
print_to_list(FILE *fp, char *fullname, char *node, char *font_name, short mode)
{
     char type[4], path[255], *ptr;

     if (!mode)
     {
          fprintf (fp,"  %-16s  %s \n", node, font_name);
          return;
     }
     else
     strcpy (path,fullname);
     ptr=strrchr(path,'\\');
     ptr[1]=0;
     ptr=strrchr(node,'.');
     strcpy (type,&ptr[1]);
     fprintf (fp,"\"%s\",\"%s\",\"%s\",\"%s\"\n", path, type, node, font_name);
     return;
}

short submulti( short *pWhand, short *pVw)
{
     short timer, parm1, parm2, parm3, parm4;

     wind_get(*pWhand, WF_TOP, &parm1, &parm2, &parm3, &parm4);

     if (*pWhand==parm1)timer = 20;
     else timer = 200;

     return multi(events,pWhand, timer, pVw);
}

