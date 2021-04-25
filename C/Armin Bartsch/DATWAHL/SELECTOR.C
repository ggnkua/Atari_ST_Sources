/**************************************************************************/
/*                                                                        */
/*       File-Selector-Box als Libary fÅr den Megamax-C-Compiler          */
/*                                                                        */
/*                          Armin Bartsch                                 */
/*                          Mîwenstr.5                                    */
/*                          2893 Butjadingen 1                            */
/*                                                                        */
/*       Das Grundprogramm stammt von :                                   */
/*                                                                        */
/*                          Ulrich Mast                                   */
/*                          Wilhelm-Maybach-Str.9                         */
/*                          7303 Neuhausen / Filder                       */
/*                                                                        */
/*       Es wurde von mir entwanzt,erweitert und so abgeÑndert,           */
/*       daû man es als Libary in die SYSLIB des Megamax-C-Compilers      */
/*       einbinden kann.                                                  */
/*       Es ersetzt somit vollstÑndig die System-File-Selector-Box        */
/*       und steht fÅr alle eigenen GEM-Programme zur VerfÅgung.          */
/*                                                                        */
/*       Weitere Verbesserungen sind ausdrÅcklich erwÅnscht.              */
/*                                                                        */
/**************************************************************************/

#include "gemdefs.h"
#include "osbind.h"
#include "obdefs.h"

#define hide() graf_mouse(M_OFF,0x0L)
#define show() graf_mouse(M_ON,0x0L)
#define FEHLER 1

/**************************************************************************/

#define SELECT 0        /* TREE */
#define FSTOTAL 0       /* OBJECT in TREE #0 */
#define FSINFO 2        /* OBJECT in TREE #0 */
#define FSPATH 4        /* OBJECT in TREE #0 */
#define FSTOTBOX 6      /* OBJECT in TREE #0 */
#define FSCLOSER 7      /* OBJECT in TREE #0 */
#define FSREDRAW 8      /* OBJECT in TREE #0 */
#define FSMOVEUP 9      /* OBJECT in TREE #0 */
#define FSFBOX 10       /* OBJECT in TREE #0 */
#define FSFILE0 11      /* OBJECT in TREE #0 */
#define FSFILE1 12      /* OBJECT in TREE #0 */
#define FSFILE2 13      /* OBJECT in TREE #0 */
#define FSFILE3 14      /* OBJECT in TREE #0 */
#define FSFILE4 15      /* OBJECT in TREE #0 */
#define FSFILE5 16      /* OBJECT in TREE #0 */
#define FSFILE6 17      /* OBJECT in TREE #0 */
#define FSFILE7 18      /* OBJECT in TREE #0 */
#define FSFILE8 19      /* OBJECT in TREE #0 */
#define FSFILE9 20      /* OBJECT in TREE #0 */
#define FSROLL 21       /* OBJECT in TREE #0 */
#define FSSLIDER 22     /* OBJECT in TREE #0 */
#define FSMOVEDO 23     /* OBJECT in TREE #0 */
#define FSNAME 25       /* OBJECT in TREE #0 */
#define FSEXTBOX 26     /* OBJECT in TREE #0 */
#define FSEXTEN1 27     /* OBJECT in TREE #0 */
#define FSEXTEN2 28     /* OBJECT in TREE #0 */
#define FSEXTEN3 29     /* OBJECT in TREE #0 */
#define FSEXTEN4 30     /* OBJECT in TREE #0 */
#define FSEXTEN5 31     /* OBJECT in TREE #0 */
#define FSDSKBOX 33     /* OBJECT in TREE #0 */
#define FSAD 34         /* OBJECT in TREE #0 */
#define FSBD 35         /* OBJECT in TREE #0 */
#define FSCD 36         /* OBJECT in TREE #0 */
#define FSDD 37         /* OBJECT in TREE #0 */
#define FSED 38         /* OBJECT in TREE #0 */
#define FSFD 39         /* OBJECT in TREE #0 */
#define FSGD 40         /* OBJECT in TREE #0 */
#define FSHD 41         /* OBJECT in TREE #0 */
#define FSID 42         /* OBJECT in TREE #0 */
#define FSJD 43         /* OBJECT in TREE #0 */
#define FSKD 44         /* OBJECT in TREE #0 */
#define FSLD 45         /* OBJECT in TREE #0 */
#define FSMD 46         /* OBJECT in TREE #0 */
#define FSND 47         /* OBJECT in TREE #0 */
#define FSOD 48         /* OBJECT in TREE #0 */
#define FSABBRUC 49     /* OBJECT in TREE #0 */
#define FSOK 50         /* OBJECT in TREE #0 */

/**************************************************************************/

#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 79

char *rs_strings[] = {
"Dateiauswahl fÅr :",
"",
"",
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
"",
"",
"Pfad :",
"",
"",
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
"_________________________________________________",
"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
"Dateiname :",
"",
"",
" 12345678.123 ",
"",
"",
" 0 12345678.123  ",
"",
"",
" 0 12345678.123  ",
"",
"",
" 0 12345678.123  ",
"",
"",
" 0 12345678.123  ",
"",
"",
" 0 12345678.123  ",
"",
"",
" 0 12345678.123  ",
"",
"",
" 0 12345678.123  ",
"",
"",
" 0 12345678.123  ",
"",
"",
" 0 12345678.123  ",
"",
"",
" 0 12345678.123  ",
"",
"",
"Extender :",
"",
"",
"12345678123",
"________.___",
"ppppppppppp",
"*.PAS",
"*.BAS",
"*.MOD",
"*.ASM",
"*.*  ",
"Laufwerk :",
"",
"",
"A",
"B",
"C",
"D",
"E",
"F",
"G",
"H",
"I",
"J",
"K",
"L",
"M",
"N",
"O",
"ABBRUCH",
"OK"};

long rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

long rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
0L, 1L, 2L, 3, 6, 0, 0x1100, 0x0, -1, 19,1,
3L, 4L, 5L, 3, 6, 2, 0x11C1, 0x0, -1, 30,1,
6L, 7L, 8L, 3, 6, 0, 0x1100, 0x0, -1, 7,1,
9L, 10L, 11L, 3, 6, 0, 0x1180, 0x0, -1, 50,50,
12L, 13L, 14L, 3, 6, 0, 0x1100, 0x0, -1, 12,1,
15L, 16L, 17L, 3, 6, 2, 0x11A1, 0x0, -1, 15,1,
18L, 19L, 20L, 3, 6, 0, 0x1180, 0x0, -1, 18,1,
21L, 22L, 23L, 3, 6, 0, 0x1180, 0x0, -1, 18,1,
24L, 25L, 26L, 3, 6, 0, 0x1180, 0x0, -1, 18,1,
27L, 28L, 29L, 3, 6, 0, 0x1180, 0x0, -1, 18,1,
30L, 31L, 32L, 3, 6, 0, 0x1180, 0x0, -1, 18,1,
33L, 34L, 35L, 3, 6, 0, 0x1180, 0x0, -1, 18,1,
36L, 37L, 38L, 3, 6, 0, 0x1180, 0x0, -1, 18,1,
39L, 40L, 41L, 3, 6, 0, 0x1180, 0x0, -1, 18,1,
42L, 43L, 44L, 3, 6, 0, 0x1180, 0x0, -1, 18,1,
45L, 46L, 47L, 3, 6, 0, 0x1180, 0x0, -1, 18,1,
48L, 49L, 50L, 3, 6, 0, 0x1100, 0x0, -1, 11,1,
51L, 52L, 53L, 3, 6, 0, 0x1180, 0x0, -1, 12,13,
59L, 60L, 61L, 3, 6, 0, 0x1100, 0x0, -1, 11,1};

OBJECT rs_object[] = {
-1, 1, 50, G_BOX, NONE, OUTLINED, 0x21111L, 1,1, 51,20,
2, -1, -1, G_TEXT, NONE, NORMAL, 0x0L, 1040,2560, 18,1,
3, -1, -1, G_BOXTEXT, NONE, SHADOWED, 0x1L, 10,2, 31,1,
4, -1, -1, G_TEXT, NONE, NORMAL, 0x2L, 1,3, 6,1,
5, -1, -1, G_FBOXTEXT, EDITABLE, SHADOWED, 0x3L, 1,4, 49,1,
6, -1, -1, G_TEXT, NONE, NORMAL, 0x4L, 1,6, 11,1,
24, 7, 23, G_BOX, NONE, SHADOWED, 0x11100L, 16,6, 788,269,
8, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x5FF1100L, 256,256, 2,1,
9, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, 0x5L, 514,256, 18,257,
10, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 274,513, 258,769,
21, 11, 20, G_BOX, NONE, NORMAL, 0x11100L, 0,257, 274,12,
12, -1, -1, G_TEXT, 0x51, NORMAL, 0x6L, 1,1, 17,1,
13, -1, -1, G_TEXT, 0x51, NORMAL, 0x7L, 1,2, 17,1,
14, -1, -1, G_TEXT, 0x51, NORMAL, 0x8L, 1,3, 17,1,
15, -1, -1, G_TEXT, 0x51, NORMAL, 0x9L, 1,4, 17,1,
16, -1, -1, G_TEXT, 0x51, NORMAL, 0xAL, 1,5, 17,1,
17, -1, -1, G_TEXT, 0x51, NORMAL, 0xBL, 1,6, 17,1,
18, -1, -1, G_TEXT, 0x51, NORMAL, 0xCL, 1,7, 17,1,
19, -1, -1, G_TEXT, 0x51, NORMAL, 0xDL, 1,8, 17,1,
20, -1, -1, G_TEXT, 0x51, NORMAL, 0xEL, 1,9, 17,1,
10, -1, -1, G_TEXT, 0x51, NORMAL, 0xFL, 1,10, 17,1,
23, 22, 22, G_BOX, TOUCHEXIT, NORMAL, 0x11121L, 18,1282, 770,2569,
21, -1, -1, G_BOX, TOUCHEXIT, NORMAL, 0x11101L, 0,1, 770,3585,
6, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L, 274,3851, 258,257,
25, -1, -1, G_TEXT, NONE, NORMAL, 0x10L, 39,6, 10,1,
26, -1, -1, G_FBOXTEXT, EDITABLE, SHADOWED, 0x11L, 1,7, 12,1,
32, 27, 31, G_BOX, NONE, NORMAL, 0x11131L, 39,7, 518,2823,
28, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x36L, 0,0, 6,1,
29, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x37L, 0,2561, 6,1,
30, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x38L, 0,1283, 6,1,
31, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x39L, 0,5, 6,1,
26, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x3AL, 0,2566, 6,1,
33, -1, -1, G_TEXT, NONE, NORMAL, 0x12L, 1,9, 10,1,
49, 34, 48, G_BOX, NONE, NORMAL, 0x11131L, 1,10, 1037,9,
35, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x3EL, 0,0, 3,1,
36, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x3FL, 0,2, 3,1,
37, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x40L, 0,4, 3,1,
38, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x41L, 0,6, 3,1,
39, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x42L, 0,8, 3,1,
40, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x43L, 5,0, 3,1,
41, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x44L, 5,2, 3,1,
42, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x45L, 5,4, 3,1,
43, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x46L, 5,6, 3,1,
44, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x47L, 5,8, 3,1,
45, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x48L, 10,0, 3,1,
46, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x49L, 10,2, 3,1,
47, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x4AL, 10,4, 3,1,
48, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x4BL, 10,6, 3,1,
33, -1, -1, G_BUTTON, 0x51, SHADOWED, 0x4CL, 10,8, 3,1,
50, -1, -1, G_BUTTON, 0x5, NORMAL, 0x4DL, 39,16, 9,1,
0, -1, -1, G_BUTTON, 0x27, NORMAL, 0x4EL, 39,18, 9,1};

long rs_trindex[] = {
0L};

struct foobar {
        int     dummy;
        int     *image;
        } rs_imdope[] = {
0};

#define NUM_STRINGS 79
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 19
#define NUM_OBS 51
#define NUM_TREE 1

/**************************************************************************/

typedef struct dta_buffer
{
char   dummy[21];
char   file_attr;
int    time;
int    date;
long   size;
char   name[14];
} DTABUF;

int    wieder = 0;

long   fsel_addr;

/**************************************************************************/

init_resource()
{
register int  i;
         long *ptr;
extern   int  global[];
int    phys_handle;
int    wchar,hchar,wbox,hbox;

   phys_handle = graf_handle(&wchar,&hchar,&wbox,&hbox);
   for(i=0; i < NUM_OBS;i++)
      {
      switch(rs_object[i].ob_type)
        {
        case G_TEXT     :
        case G_FTEXT    :
        case G_FBOXTEXT :
        case G_BOXTEXT  : rs_object[i].ob_spec = (char *)&rs_tedinfo[(int)rs_object[i].ob_spec].te_ptext;
                          break;
        case G_IMAGE    : rs_object[i].ob_spec = (char *)&rs_bitblk[(int)rs_object[i].ob_spec].bi_pdata;
                          break;
        case G_BUTTON   :
        case G_STRING   :
        case G_TITLE    : rs_object[i].ob_spec = rs_strings[(int)rs_object[i].ob_spec];
                          break;
        case G_ICON     : rs_object[i].ob_spec = (char *)&rs_iconblk[(int)rs_object[i].ob_spec].ib_pmask;
                          break;
        }
      rs_object[i].ob_x = wchar * (rs_object[i].ob_x % 0x100) + (rs_object[i].ob_x / 0x100);
      rs_object[i].ob_y = hchar * (rs_object[i].ob_y % 0x100) + (rs_object[i].ob_y / 0x100);
      rs_object[i].ob_width  = wchar * (rs_object[i].ob_width  % 0x100) +(rs_object[i].ob_width  / 0x100);
      rs_object[i].ob_height = hchar * (rs_object[i].ob_height % 0x100) +(rs_object[i].ob_height / 0x100);
      }
   for(i=0; i < NUM_TI ; i++)
      {
      rs_tedinfo[i].te_ptext  = rs_strings[(int)rs_tedinfo[i].te_ptext];
      rs_tedinfo[i].te_ptmplt = rs_strings[(int)rs_tedinfo[i].te_ptmplt];
      rs_tedinfo[i].te_pvalid = rs_strings[(int)rs_tedinfo[i].te_pvalid];
      }
   for(i=0; i < NUM_IB ; i++)
      {
      rs_iconblk[i].ib_pmask = rs_imdope[(int)rs_iconblk[i].ib_pmask].image;
      rs_iconblk[i].ib_pdata = rs_imdope[(int)rs_iconblk[i].ib_pdata].image;
      rs_iconblk[i].ib_ptext = rs_strings[(int)rs_iconblk[i].ib_ptext];
      }
   for(i=0; i < NUM_BB ; i++)
      rs_bitblk[i].bi_pdata = rs_imdope[(int)rs_bitblk[i].bi_pdata].image;
   for(i=0; i < NUM_IMAGES; i++)
      rs_frimg[i] = (long)&rs_bitblk[(int)rs_frimg[i]];
   for(i=0; i < NUM_FRSTR; i++)
      rs_frstr[i] = (long)rs_strings[(int)rs_frstr[i]];
   for(i=0; i < NUM_TREE ; i++)
      rs_trindex[i ]= (long)&(rs_object[(int)rs_trindex[i]].ob_next);
   ptr  = (long *) &(global[5]);
   *ptr = (long)  (&(rs_trindex[0]));
}

/**************************************************************************/

int
dialog_wahl(adresse,min,max)
register long adresse;
register int  max;
int  min;
{
    register int i,wahl;

    for(i = min;i <= max;i++)
       if(select(adresse,i))
         wahl = i;
    return(wahl);
}

/**************************************************************************/

int
anzahl_files(exten)
register char *exten;
{
    register int zaehler;

    if(Fsfirst(exten,17) < 0)
      return(0);
    for(zaehler = 1;Fsnext() >= 0;zaehler++);
    return(zaehler);
}

/**************************************************************************/

int
select(tree,which)
register OBJECT *tree;
register int which;
{
    return(((tree+which)->ob_state&SELECTED)?1:0);
}

/**************************************************************************/

int
file_select(pfad,name,info,ext2,ext3,ext4,ext5)
char *pfad,*name,*info,*ext2,*ext3,*ext4,*ext5;
{
    int  x,y,w,h,abbruch,ab,wahl,i,k,l,disk,ab_dat,max_anz,pos;
    char *text,*string,dsk,hilf[80],zusatz[80];
    OBJECT  *tree;
    TEDINFO *ted;

    if(wieder == 0)
      {
      init_resource();
      rsrc_gaddr(0,SELECT,&fsel_addr);
      }
    tree = (OBJECT *)fsel_addr;
    ted = (TEDINFO *)((tree+FSINFO)->ob_spec);
    strcpy((ted)->te_ptext,info);
    ted = (TEDINFO *)((tree+FSNAME)->ob_spec);
    strcpy((ted)->te_ptext,name);
    ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
    strcpy((ted)->te_ptext,pfad);
    ted = (TEDINFO *)((tree+FSREDRAW)->ob_spec);
    strcpy((ted)->te_ptext," ");
    strcpy((tree+FSEXTEN1)->ob_spec,"*.*");/* Muû immer *.* sein */
    strcpy((tree+FSEXTEN2)->ob_spec,ext2);
    strcpy((tree+FSEXTEN3)->ob_spec,ext3);
    strcpy((tree+FSEXTEN4)->ob_spec,ext4);
    strcpy((tree+FSEXTEN5)->ob_spec,ext5);
    wahl = dialog_wahl(fsel_addr,FSFILE0,FSFILE9);
    if(wahl > 0)
      ((tree+wahl)->ob_state) &= NORMAL;
    k = Dsetdrv(Dgetdrv());
    for(l = 1,disk = FSAD;disk <= FSOD;l *= 2,disk++)
       {
       if(k & l)
         objc_change(fsel_addr,disk,0,x,y,w,h,SHADOWED,0);
       else
         objc_change(fsel_addr,disk,0,x,y,w,h,DISABLED,0);
       }
    dsk = *pfad;
    disk = (int)(dsk - 'A');
    if((disk < 0)||(disk > 15))
      return(FEHLER);
    objc_change(fsel_addr,disk+FSAD,0,x,y,w,h,SHADOWED+SELECTED,0);
    Dsetdrv(disk);
    ab_dat = 1;
    for(i = FSFILE0;i <= FSFILE9;i++)
       {
       ted = (TEDINFO *)((tree + i)->ob_spec);
       text = (ted)->te_ptext;
       *text = 0;
       }
    form_center(fsel_addr,&x,&y,&w,&h);
    form_dial(0,80,10,20,20,x,y,w,h);
    form_dial(1,80,10,20,20,x,y,w,h);
    objc_draw(fsel_addr,0,3,0,0,639,399);
    inhalt_anzeigen(pfad,ab_dat,&max_anz);
    while(1)
      {
      abbruch = form_do(fsel_addr,FSNAME);
      ab = abbruch & 0x7FFF;
      if((ab == FSOK)||(ab == FSABBRUC))
        {
        objc_change(fsel_addr,ab,0,x,y,w,h,0,0);
        break;
        }
      if((ab >= FSAD)&&(ab <= FSOD))
        {
        wahl = dialog_wahl(fsel_addr,FSAD,FSOD);
        disk = (wahl - FSAD);
        if((disk < 0)||(disk > 15))
          return(FEHLER);
        dsk = (char)(disk + 'A');
        ted = (TEDINFO *)((tree + FSPATH)->ob_spec);
        *(ted->te_ptext) = dsk;
        Dsetdrv(disk);
        Dgetpath(zusatz,0);
        if(*zusatz != 0)
          {
          string = ted->te_ptext;
          hilf[0] = dsk;
          hilf[1] = ':';
          hilf[2] = 0;
          strcat(hilf,zusatz);
          string += 79;
          while(*string != '\\')
            string--;
          strcat(hilf,string);
          strcpy(ted->te_ptext,hilf);
          }
        objc_draw(fsel_addr,FSPATH,0,x,y,w,h);
        ab_dat = 1;
        inhalt_anzeigen(ted->te_ptext,ab_dat,&max_anz);
        abbruch = ab;
        }
      if((ab >= FSEXTEN1)&&(ab <= FSEXTEN5))
        {
        wahl = dialog_wahl(fsel_addr,FSEXTEN1,FSEXTEN5);
        ted = (TEDINFO *)((tree + FSPATH)->ob_spec);
        i = strlen(ted->te_ptext);
        for(string=(ted->te_ptext)+i;string>=(ted->te_ptext);string--)
           if(*string == '\\')
             break;
        string++;
        strcpy(string,(tree + wahl)->ob_spec);
        objc_draw(fsel_addr,FSPATH,0,x,y,w,h);
        ab_dat = 1;
        inhalt_anzeigen(ted->te_ptext,ab_dat,&max_anz);
        abbruch = ab;
        }
      if((ab >= FSFILE0)&&(ab <= FSFILE9))
        {
        wahl = dialog_wahl(fsel_addr,FSFILE0,FSFILE9);
        ted = (TEDINFO *)((tree + wahl)->ob_spec);
        string = ted->te_ptext;
        if(*string != 0)
          {
          if(*(string + 1)== 7)
            {
            ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
            i = strlen(ted->te_ptext);
            for(string=(ted->te_ptext)+i;string>=(ted->te_ptext);string--)
               if(*string == '\\')
                 break;
            strcpy(hilf,string);
            string++;
            ted = (TEDINFO *)((tree+wahl)->ob_spec);
            text = ted->te_ptext;
            text += 3;
            for(i = 0;i < 12;i++)
               {
               if(*text == 0)
                 break;
               if(*text != ' ')
                 *string++ = *text;
               text++;
               }
            strcpy(string,hilf);
            objc_draw(fsel_addr,FSPATH,0,x,y,w,h);
            ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
            ab_dat = 1;
            inhalt_anzeigen(ted->te_ptext,ab_dat,&max_anz);
            abbruch = ab;
            }
          else
            {
            string += 3;
            ted = (TEDINFO *)((tree+FSNAME)->ob_spec);
            text = ted->te_ptext;
            for(i = 0;i < 8;i++)
               *text++ = *string++;
            string++;
            for(i = 0;i < 3;i++)
               *text++ = *string++;
            *text = 0;
            objc_draw(fsel_addr,FSNAME,0,x,y,w,h);
            }
          }
        }
      if(ab == FSREDRAW)
        {
        ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
        ab_dat = 1;
        inhalt_anzeigen(ted->te_ptext,ab_dat,&max_anz);
        abbruch = ab;
        }
      if(ab == FSMOVEUP)
        {
        if(ab_dat > 1)
          {
          ab_dat--;
          ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
          inhalt_anzeigen(ted->te_ptext,ab_dat,&max_anz);
          }
        abbruch = ab;
        }
      if(ab == FSMOVEDO)
        {
        if(ab_dat < (max_anz - 9))
          {
          ab_dat++;
          ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
          inhalt_anzeigen(ted->te_ptext,ab_dat,&max_anz);
          }
        abbruch = ab;
        }
      if(ab == FSSLIDER)
        {
        if(max_anz > 10)
          {
          pos = graf_slidebox(tree,FSROLL,FSSLIDER,1)/10*(max_anz-10);
          ab_dat = (pos)/100;
          ab_dat++;
          ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
          inhalt_anzeigen(ted->te_ptext,ab_dat,&max_anz);
          }
        abbruch = ab;
        }
      if(ab == FSROLL)
        {
        graf_mkstate(&i,&pos,&i,&i);
        objc_offset(tree,FSSLIDER,&i,&k);
        if(pos > k)
          {
          ab_dat += 10;
          if(ab_dat > (max_anz - 9))
            ab_dat = max_anz - 9;
          }
        else
          {
          ab_dat -= 10;
          if(ab_dat < 1)
            ab_dat = 1;
          }
        ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
        inhalt_anzeigen(ted->te_ptext,ab_dat,&max_anz);
        abbruch = ab;
        }
      if(ab == FSCLOSER)
        {
        ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
        i = strlen(ted->te_ptext);
        for(string=(ted->te_ptext)+i;string>=(ted->te_ptext);string--)
           if(*string == '\\')
             break;
        for(text=string-1;text>=(ted->te_ptext);text--)
           if(*text == '\\')
             break;
        if(*text == '\\')
          {
          string++;
          text++;
          strcpy(text,string);
          objc_draw(fsel_addr,FSPATH,0,x,y,w,h);
          }
        ab_dat = 1;
        inhalt_anzeigen(ted->te_ptext,ab_dat,&max_anz);
        abbruch = ab;
        }
      if(abbruch & 0x8000)
        break;
      }
    form_dial(2,80,10,20,20,x,y,w,h);
    form_dial(3,80,10,20,20,x,y,w,h);
    wieder = 1;
    if(ab == FSABBRUC)
      {
      ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
      strcpy(pfad,(ted)->te_ptext);
      return(FEHLER);
      }
    else
      {
      ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
      strcpy(pfad,(ted)->te_ptext);
      ted = (TEDINFO *)((tree+FSNAME)->ob_spec);
      strcpy(name,(ted)->te_ptext);
      text = (ted)->te_ptext;
      string = name;
      for(i = 0;i < 12;i++)
         {
         if(*text != ' ')
           *string++ = *text;
         if(i == 7)
           *string++ = '.';
         text++;
         }
      *string = 0;
      return(0);
      }
}

/**************************************************************************/

inhalt_anzeigen(pfad,abnr,anzahl)
char *pfad;
int  abnr;
int  *anzahl;
{
   int  i,fehler,k,l,rueck,wahl;
   char *string,*name,*text,hilf[65],zusatz[65];
   OBJECT  *tree;
   TEDINFO *ted;
   DTABUF  *puffer;

   tree   = (OBJECT *)fsel_addr;
   puffer = (DTABUF *)Fgetdta();
   i = strlen(pfad);
   for(string=pfad+i;string>=pfad;string--)
      if(*string == '\\')
        break;
   name = string +1;
   for(string=pfad+2,i=0;string<name;string++,i++)
      hilf[i] = *string;
   hilf[i] = 0;
   Dgetpath(zusatz,0);
   rueck = Dsetpath(hilf);
   if(rueck == -34)
     {
     Dsetpath(zusatz);
     for(i=0;i<65;i++,hilf[i]=0);
     hilf[0] = pfad[0];
     hilf[1] = pfad[1];
     strcat(hilf,zusatz);
     strcat(hilf,"\\");
     strcat(hilf,name);
     ted = (TEDINFO *)((tree+FSPATH)->ob_spec);
     strcpy((ted)->te_ptext,hilf);
     objc_draw(fsel_addr,FSPATH,0,0,0,640,400);
     i = strlen(hilf);
     for(string=hilf+i;string>=hilf;string--)
        if(*string == '\\')
          break;
     name = string +1;
     }
   wahl = dialog_wahl(fsel_addr,FSEXTEN1,FSEXTEN5);
   if(wahl > 0)
     {
     ((tree+wahl)->ob_state) &= NORMAL+SHADOWED;
     objc_draw(fsel_addr,wahl,3,0,0,640,400);
     }
   wahl = FSEXTEN1;
   i = 0;
   while(i != 1)
     {
     text = ((tree+wahl)->ob_spec);
     rueck = strcmp(text,name);
     if(rueck == 0)
       {
       ((tree+wahl)->ob_state) |= SELECTED;
       objc_draw(fsel_addr,wahl,3,0,0,640,400);
       i = 1;
       }
     wahl++;
     if(wahl > FSEXTEN5)
       i = 1;
     }
   *anzahl = anzahl_files(name);
   if(*anzahl <= 10)
     {
     ((tree+FSSLIDER)->ob_y) = 0;
     ((tree+FSSLIDER)->ob_height) = ((tree+FSROLL)->ob_height);
     abnr = 1;
     }
   else
     {
     ((tree+FSSLIDER)->ob_y) = ((tree+FSROLL)->ob_height*(abnr-1))/(*anzahl);
     ((tree+FSSLIDER)->ob_height) = ((tree+FSROLL)->ob_height*10)/(*anzahl);
     }
   ted = (TEDINFO *)((tree+FSREDRAW)->ob_spec);
   text = (ted)->te_ptext;
   strcpy(text," ");
   strcat(text,name);
   strcat(text," ");
   fehler = Fsfirst(name,17);
   for(i = 2;i < abnr;i++)
      if(fehler >= 0)
        fehler = Fsnext();
   for(i = FSFILE0;i <= FSFILE9;i++,abnr++)
      {
      if((abnr != 1)&&(*anzahl > 0))
        fehler = Fsnext();
      ted = (TEDINFO *)((tree+i)->ob_spec);
      text = (ted)->te_ptext;
      if((fehler >= 0)&&(*anzahl > 0))
        {
        (tree+i)->ob_flags |= SELECTABLE;
        (tree+i)->ob_state &= NORMAL;
        if(puffer->name[0] == 46)
          (tree+i)->ob_flags &= ~TOUCHEXIT;
        else
          (tree+i)->ob_flags |= TOUCHEXIT;
        *text++ = 32;
        *text++ = ((puffer->file_attr == 16)?7:32);
        *text++ = 32;
        for(k = 0,l = 0;(puffer->name[k] != '.')&&(l < 8);l++)
           *text++ = puffer->name[k++];
        for(;l < 8;l++)
           *text++ = 32;
        for(l = 0;l < 4;l++)
           *text++ = puffer->name[k++];
        *text = 0;
        }
      else
        {
        (tree+i)->ob_flags &= ~SELECTABLE;
        (tree+i)->ob_flags &= ~TOUCHEXIT;
        (tree+i)->ob_state = NORMAL;
        *text = 0;
        }
      }
   objc_draw(fsel_addr,FSTOTBOX,2,1,1,500,380);
}

/**************************************************************************/

