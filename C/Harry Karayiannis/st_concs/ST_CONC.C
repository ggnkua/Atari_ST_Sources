/*
 *                        ST - CONCENTRATION
 *                        ------------------
 *
 *  A Public Domain game, written in May 1990 with Mark Williams C ver 3.0.9
 *  
 *  PAUL MAKRIDAKIS  :  Idea and construction of the color images
 *  HARRY KARAYIANNIS:  Programming and construction of the monochrome images
 *
 *  You may redistribute the source code, as long as all of the files
 *  (CONCENTR.H, CONCENTR.C, CONCENTR.RSC, CONCEMTR.RSD, CONCENTR.PRG,
 *   CONCENTR.DOC, and finally READ.ME) are also included in your re-
 *  distribution package
 *
 *  COMMENTS: The program was written with MWC but it should run without pro-
 *  --------  blem, in any other C-compiler on the ST(with minor or no changes)
 *            It has been tested with SOZOBON-C + GEMFAST 1.3 and LASER-C 2.0
 *
 *  BUGS(?):  (when compiled with SOZOBON-C & GEMFAST, the program interferes
 *  -------    with the german backround-image program: "DESKTOP"; as a result
 *             CONCENTRATION gives a bus-error on exit when DESKTOP is active.
 *             I have discovered (thanks to Alex Volanis) that the problem
 *             resides in the call of the gem function rsrc_free(). Since the
 *             game runs ok when compiled with the other compilers, I suspect
 *             that there is a problem with rsrc_free() inside GEMFAST
 *
 *  NOTE:   Please do not send me bug-reports because I will not answer you
 *  -----   back. That's why I give you the source-code...if you find a bug
 *          you can fix it yourself....you can even add more features to the
 *          game if you want to.
 *
 *
 *                    That's all folks.......have fun!!!!!!!
 *
 *
 *
 *                                                  HARRY KARAYIANNIS
 *
 *                                                  Email(BITNET):
 *                                                      harryk@bucsf.bu.edu
 *                                                  OR  CSCRZCC@BUACCA.BU.EDU
 */


#include <stdio.h>
#include <string.h>

/*
 * if you don't have the file "gemfast.h"
 * you should use the files (included in
 * C-compiler) "gemdefs.h" and "obdefs.h"
 */
#include <gemfast.h>

#include <osbind.h>
#include "st_conc.h"

#define FALSE   0
#define TRUE    !FALSE
#define MAXPLAYERS 4

/* This macro  fixes the case where a dialog-box has outside-border.
 * In such cases, the clipping rectangle -used by GEM- should cover
 * the border of the dialog-box too. (Works for SHADOWED forms too)
 */
#define fix_border(x,y,w,h,border_size)\
    x -= border_size;\
    y -= border_size;\
    w += (border_size*2);\
    h += (border_size*2);


typedef int BOOLEAN;

/* GEM-related variables & arrays */
int aes_handle;
int vdi_handle;
int work_in[] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2};
int work_out[57];
int contrl[12], intin[128], intout[128], ptsin[128], ptsout[128];


/*
 *  This structure is not necessary (it just shows another way to declare
 *  an array of pointers to integers). But I think it improves the general
 *  readability of the programme
 */
typedef struct data{
    int *data;
}PIC_DATA;

/* The board of pictures and its backup */
PIC_DATA   board[100], backboard[100];


/* This structure is used for the players & the top scorers */
typedef struct players{
    char  name[11];
    int   score;
}PLAYERS;

/* Array of players initialized with default values */
PLAYERS player[MAXPLAYERS] = { "Player #1", 0,
                               "Player #2", 0,
                               "Player #3", 0,
                               "Player #4", 0
                             };

/* table of high-scores initialized with default values */
PLAYERS hitable[12] = { "Atari ST ", 10,
                        "Atari ST ", 10,
                        "Atari ST ", 10,
                        "Atari ST ", 10,
                        "Atari ST ", 10,
                        "Atari ST ", 10,
                        "Atari ST ", 10,
                        "Atari ST ", 10,
                        "Atari ST ", 10,
                        "Atari ST ", 10,
                        "Atari ST ", 10,
                        "Atari ST ", 10
                      };
    
int     rez;                      /* ST's resolution */
int     bx, by, bw, bh;           /* coordinates for the board's dialog-box */
OBJECT  *treeboard;               /* tree for the board's dialog-box */

main()
{
  int   dummy;
  int   dimensions=100, players=2;
  char  rsc_name[12];             /* name of the resource file */

  /* for a description of these functions see their declaration */
  void  init(), suffle(), play();
  void  arrcpy(), initial_display();
  void  read_hiscores(), write_hiscores();


  /* initialize AES */
  if ( (aes_handle=appl_init()) == -1 )
  {
    form_alert(1,"[3][Application cannot be initialized][Desktop]");
    exit(0);
  }

  /* get resolution */
  rez = Getrez();

  /* decide which rsc file to use */
  if (rez == 0){
    form_alert(1,"[3][Use Medium Rez][Desktop]");
    appl_exit();
  }
  else if (rez == 1)
    strcpy(rsc_name, "ST_CONCC.RSC");
  else
    strcpy(rsc_name, "ST_CONC.RSC");

  /* load the resource file */
  if ( !rsrc_load(rsc_name) )
  {
    form_alert(1,"[3][Resource File not found!][Desktop]");
    appl_exit();
  }


  /* initialize VDI */
  vdi_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);
  v_opnvwk(work_in, &vdi_handle, work_out);
  vswr_mode(vdi_handle, 1);       /* replace mode */
  vsf_color(vdi_handle, 0);       /* Color = 0 (white) */
  vsf_interior(vdi_handle, 1);    /* Fill  = 1 (solid) */

  read_hiscores(hitable);
  graf_mouse(ARROW, 0L);
  init(board, dimensions);
  arrcpy(backboard, board, dimensions);
  suffle(board, dimensions);

  /* display board's dialog-box & start playing */
  rsrc_gaddr(0, FRMBOARD, &treeboard);
  form_center(treeboard, &bx, &by, &bw, &bh);
  form_dial(FMD_START, 0,0,0,0, bx,by,bw,bh);
  initial_display(treeboard, bx,by,bw,bh);
  play(treeboard, board, dimensions, players);
  form_dial(FMD_FINISH, 0,0,0,0, bx,by,bw,bh);
  rsrc_free();

  /* close VDI & AES */
  v_clsvwk(vdi_handle);
  appl_exit();

  write_hiscores(hitable);
  return(0);
}
/* ----------------------------------------------------------------------- */
/* copy pics from the resource file to my array */

void init(board, dimensions)
    PIC_DATA board[];
    int   dimensions;
{
  OBJECT   *tree;
  register int i;

  rsrc_gaddr(0, FRMBOARD, &tree);
  for (i=PIC1; i<(PIC1+dimensions); i++)
    board[i-PIC1].data = ((BITBLK *)tree[i].ob_spec)->bi_pdata;
}
/* ----------------------------------------------------------------------- */
/* suffle pics in my array */

void suffle(board, dimensions)
    PIC_DATA board[];
    int   dimensions;
{
  int     i1, i2;
  int     *temp;
  register int i;

  for (i=0; i<100; i++)
  {
    /* we pick 2 random cards & we swap their pictures */
    i1 = Random() % dimensions;
    i2 = Random() % dimensions;
    temp = board[i1].data;
    board[i1].data = board[i2].data;
    board[i2].data = temp;
  }
}
/* ----------------------------------------------------------------------- */
/*  Copy pics from my array to dialog-box and display the dialog-box */

void initial_display(tree, x, y, w, h)
    OBJECT  *tree;
    int     x,y,w,h;
{
  register int i;

  for (i=PIC1; i<=PIC100; i++)
    ((BITBLK *)tree[i].ob_spec)->bi_pdata = 
                           ((BITBLK *)treeboard[PICBLANK].ob_spec)->bi_pdata;
  objc_draw(tree, 0, MAX_DEPTH, x,y,w,h);
}
/* ----------------------------------------------------------------------- */
/* dipslay in the dialog-box as much pics as 'dimensions' indicate.
 * the rest of the pics become HIDDEN objects
 */

void display(treeboard, dimensions)
    OBJECT  *treeboard;
    int     dimensions;
{
  register int  i;
  extern int  bx, by, bw, bh;

  for (i=PIC1; i<(PIC1+dimensions); i++)
  {
    treeboard[i].ob_flags |= TOUCHEXIT;
    if (treeboard[i].ob_flags & HIDETREE)
      treeboard[i].ob_flags &= ~HIDETREE;   /* unhide pic */
    ((BITBLK *)treeboard[i].ob_spec)->bi_pdata = 
                           ((BITBLK *)treeboard[PICBLANK].ob_spec)->bi_pdata;
  }

  for (i=PIC1+dimensions; i<=PIC100; i++)
    treeboard[i].ob_flags |= HIDETREE;

  /* draw only pictures' parent-object (object 2) */
  objc_draw(treeboard, 2, MAX_DEPTH, bx,by,bw,bh);
}
/* ----------------------------------------------------------------------- */
/* the heart of the game */

void play(tree, board, dimensions, players)
    OBJECT   *tree;
    PIC_DATA board[];
    int dimensions, players;
{
  int     exit_button;
  int     count = 0;            /* counter to indicate the end of the game */
  int     cur_player = 0;       /* who is the current player: 0=1st, 1=2nd..*/
  BOOLEAN same_pics();          /* compares 2 pictures */

  extern  int   bx, by, bw, bh;
  extern PLAYERS player[], hitable[];

  int     upd_hiscores();
  char    *itos99();
  void    init(), suffle(), display();
  void    blank_pic(), ena_options(), dis_options();
  void    show_topscorer(), show_hiscores(), show_about();
  void    get_names(), reset_scores();
  void    arrcpy(), show_winner(), write_hiscores();


  /* the main loop */
  do{
  int prev_button;
  register int i;

    /* show players' names in the proper box */
    strcpy(
      ((TEDINFO *)tree[CURPLAYE].ob_spec)->te_ptext,
      player[cur_player].name
    );
    objc_draw(tree, CURPLAYE, MAX_DEPTH, bx,by,bw,bh);

    /* interact with user */
    exit_button = form_do(tree, 0);     /* no editable fields */
    exit_button &= 0x7FFF;              /* "defuse" double-clicks */

    /* handle case when user clicked on a picture */
    if (exit_button >= PIC1  &&  exit_button <= PIC100) /* pic selected */
    {

      /* draw the 1st selected pic in the dialog-box */
      prev_button = exit_button;
      ((BITBLK *)tree[prev_button].ob_spec)->bi_pdata =
                                                board[prev_button-PIC1].data;
      objc_draw(tree, prev_button, MAX_DEPTH, bx,by,bw,bh);

      /* disable "un-needed" options */
      dis_options(tree, dimensions, players);


      /* get & draw the 2nd selected picture */
      do{
        exit_button=form_do(tree, 0);   /* no editable fields */
        exit_button &= 0x7FFF;          /* "defuse" double-clicks */
      }while(
            exit_button==prev_button || (exit_button<PIC1 || exit_button>PIC100)
            );

      ((BITBLK *)tree[exit_button].ob_spec)->bi_pdata =
                                                board[exit_button-PIC1].data;
      objc_draw(tree, exit_button, MAX_DEPTH, bx,by,bw,bh);


      /* compare the pics and act appropriely */
      if( same_pics(tree, prev_button, exit_button) )
      {
        Bconout(2,7); /* bell */
        /* reset TOUCHEXIT flag */
        tree[exit_button].ob_flags &= ~TOUCHEXIT; /* NOT TOUCHEXIT */
        tree[prev_button].ob_flags &= ~TOUCHEXIT; /* NOT TOUCHEXIT */
        /* update current player's score */
        player[cur_player].score += 1; /* we increase score by one */
        /* update counter */
        count++;
      }

      else    /* make pics look "empty" again */
      {register long i;

        /* update pictures' data-field to be blank */
        ((BITBLK *)tree[prev_button].ob_spec)->bi_pdata =
                                ((BITBLK *)tree[PICBLANK].ob_spec)->bi_pdata;
        ((BITBLK *)tree[exit_button].ob_spec)->bi_pdata =
                                ((BITBLK *)tree[PICBLANK].ob_spec)->bi_pdata;
        /* just a delay */
        for (i=0; i<=50000L; i++);

        /*
         * when AES redraws an image, it performs an OR-operation
         * between the image and the existed pixels on the screen
         * As a result, if the screen is currently showing an image
         * and we want to OR it with a blank image (all zeros), AES
         * does not update the screen (0 OR x = x). Thus, I have to
         * use a VDI function to make the screen look blank.
         * ...see declaration of the function blank_pic()...
         */
        blank_pic(tree, prev_button);
        blank_pic(tree, exit_button);
        /* next player plays */
        cur_player++;
        if (cur_player == players)  /* wrap around */
          cur_player = 0;
      }

      /* enable "un-needed" options */
      ena_options(tree, dimensions, players);

    }

    else    /* user didn't click on a picture */
    {
      switch (exit_button)
      {int temp_x, temp_y, temp_w, temp_h;

        case ABOUT:
          show_about(&temp_x, &temp_y, &temp_w, &temp_h);
          objc_draw(tree, 0, MAX_DEPTH, temp_x,temp_y,temp_w,temp_h);
          objc_change(tree, exit_button, 0, bx,by,bw,bh, NORMAL, 1);
          break;

        case BOARD70:
        case BOARD80:
        case BOARD90:
        case BOARD100:
          /* the following line accepts the user's request for */
          /* possible values for dimensions are: 70,80,90,100) */
          /* NOTE:this line heavily depends on the order of the*/
          /*      objects BOARD70 to BOARD100 in the rsrc file */
          /*       - You can reduce this dependancy by using a */
          /*         simple SWITCH-statement                   */
          dimensions = 70 + (exit_button-BOARD70)*10;

          /* reset everything to their initial state */
          count = 0;
          cur_player = 0;
          reset_scores(player);
          arrcpy(board, backboard, dimensions);
          suffle(board, dimensions);
          display(tree, dimensions);
          break;

        case PLAYERS1:
        case PLAYERS2:
        case PLAYERS3:
        case PLAYERS4:
          /* as with the board-size you can just use a SWITCH-statement */
          /* in order to reduce the dependency between 'players' value  */
          /* and the order of the objects  PLAYERS1 to PLAYERS4  in the */
          /* resource file */
          players = exit_button-PLAYERS1 + 1;

          /* reset everything to their initial state */
          count = 0;
          cur_player = 0;
          reset_scores(player);
          /* read the new names for the players */
          get_names(players, player, &temp_x, &temp_y, &temp_w, &temp_h);
          objc_draw(tree, 0, MAX_DEPTH, temp_x, temp_y, temp_w, temp_h);
          arrcpy(board, backboard, dimensions);
          suffle(board, dimensions);
          display(tree, dimensions);
          break;

        case HISCORES:
          /* dispaly high-scores in a dialog-box */
          show_hiscores(&temp_x, &temp_y, &temp_w, &temp_h);
          objc_draw(tree, 0, MAX_DEPTH, temp_x,temp_y,temp_w,temp_h);
          objc_change(tree, exit_button, 0, bx,by,bw,bh, NORMAL, 1);
          break;

        case SAVEHISC:
          /* save most recent high-scores */
          write_hiscores(hitable);
          objc_change(tree, exit_button, 0, bx,by,bw,bh, NORMAL, 1);
          break;

        case NEWGAME:
          objc_change(tree, exit_button, 0, bx,by,bw,bh, NORMAL, 1);
          /* reset everything to initial state ...*/
          count = 0;
          cur_player = 0;
          reset_scores(player);
          arrcpy(board, backboard, dimensions);
          suffle(board, dimensions);
          display(tree, dimensions);
          break;

        case QUITGAME:
          break;

      } /* switch */

    } /* else */


    /* diaplay current player's score in NORMAL  */
    /* and show the rest of 'em in DISABLED mode */
    for (i=SCORES1; i<=SCORES4; i++)
    {
      strcpy(
        ((TEDINFO *)tree[i].ob_spec)->te_ptext,
        (char *)itos99( player[i-SCORES1].score )
      );
      objc_change(tree, i, 0, bx,by,bw,bh, DISABLED, 0);
      objc_draw(tree, i, MAX_DEPTH, bx,by,bw,bh);
    }
    objc_change(tree, SCORES1+cur_player, 0, bx,by,bw,bh, NORMAL, 1);


    /* check for end-of-game, winner, and any new high-scorer */
    if (count == (dimensions/2)  &&  players>1) /* end-of-game reached */
    {int  temp_x, temp_y, temp_w, temp_h, i;

      /* find and display winner's name */
      show_winner(player, &temp_x, &temp_y, &temp_w, &temp_h);
      objc_draw(tree, 0, MAX_DEPTH, temp_x,temp_y,temp_w,temp_h);

      /* check for a possible new high-scorer */
      /* if there is, update score-table  and */
      /* display the guy's name               */
      if ( (i=upd_hiscores(players, dimensions, player, hitable)) != -1 )
      {
        show_topscorer(player[i].name, &temp_x, &temp_y, &temp_w, &temp_h);
        objc_draw(tree, 0, MAX_DEPTH, temp_x,temp_y,temp_w,temp_h);
      }

      /* reset counter */
      count = 0;
    }

  }while (exit_button != QUITGAME);
}
/* ----------------------------------------------------------------------- */
/*
 * fill with white the interior of a specified picture
 * (the perimeter remains black)
 */
void blank_pic(tree, button)
    OBJECT  *tree;
    int     button;
{
  int xyarray[4];
  extern int vdi_handle;

  /* mouse off */
  graf_mouse(M_OFF, 0L);

  /* calc picture's absolute coordinates */
  objc_offset(tree, button, &xyarray[0], &xyarray[1]);

  /* exclude the perimeter */
  xyarray[0] += 1;
  xyarray[1] += 1;
  xyarray[2] = xyarray[0] + tree[button].ob_width  - 3;
  xyarray[3] = xyarray[1] + tree[button].ob_height - 3;
  
  /* fill with white */
  vr_recfl(vdi_handle, xyarray);

  /* mouse on */
  graf_mouse(M_ON, 0L);
}
/* ----------------------------------------------------------------------- */
/* disable right-hand-side buttons(on the main dialog-box) */

void dis_options(tree, dimensions, players)
    OBJECT  *tree;
    int     dimensions, players;
{
  register int i;
  extern int bx, by, bw, bh;

  objc_change(tree, ABOUT, 0, bx,by,bw,bh, DISABLED, 1);
  for (i=BOARD70; i<=BOARD100; i++)
    objc_change(tree, i, 0, bx,by,bw,bh, DISABLED, 1);
  for (i=PLAYERS1; i<=PLAYERS4; i++)
    objc_change(tree, i, 0, bx,by,bw,bh, DISABLED, 1);
  for (i=HISCORES; i<=QUITGAME; i++)
    objc_change(tree, i, 0, bx,by,bw,bh, DISABLED, 1);

  objc_change(tree, BOARD70+(dimensions-70)/10, 0, bx,by,bw,bh, SELECTED, 1);
  objc_change(tree, PLAYERS1 + players-1, 0, bx,by,bw,bh, SELECTED, 1);
}
/* ----------------------------------------------------------------------- */
/* enable right-hand-side buttons(on the main dialog-box) */

void ena_options(tree, dimensions, players)
    OBJECT  *tree;
    int     dimensions, players;
{
  register int i;
  extern int bx, by, bw, bh;

  objc_change(tree, ABOUT, 0, bx,by,bw,bh, NORMAL, 1);
  for (i=BOARD70; i<=BOARD100; i++)
    objc_change(tree, i, 0, bx,by,bw,bh, NORMAL, 1);
  for (i=PLAYERS1; i<=PLAYERS4; i++)
    objc_change(tree, i, 0, bx,by,bw,bh, NORMAL, 1);
  for (i=HISCORES; i<=QUITGAME; i++)
    objc_change(tree, i, 0, bx,by,bw,bh, NORMAL, 1);

  objc_change(tree, BOARD70+(dimensions-70)/10, 0, bx,by,bw,bh, SELECTED, 1);
  objc_change(tree, PLAYERS1 + players-1, 0, bx,by,bw,bh, SELECTED, 1);
}
/* ----------------------------------------------------------------------- */
/* compare two pictures. if they are the same return TRUE else FALSE */

BOOLEAN same_pics(tree, pic1, pic2)
    OBJECT  *tree;
    int     pic1, pic2;
{
  int pic_size;
  register int i;
  extern int rez;

  /* Color pics are smaller than Mono ones */
  /* calc their size, depending on resolution */
  if (rez == 1)
    pic_size = 36;
  else
    pic_size = 56;

  /* compare the 2 pictures */
  for (i=0; i<pic_size; i++)
  {
    if ( ((BITBLK *)tree[pic1].ob_spec)->bi_pdata[i]
         !=
         ((BITBLK *)tree[pic2].ob_spec)->bi_pdata[i]
    )
      return(FALSE);
  }

  return(TRUE);
}
/* ----------------------------------------------------------------------- */
void reset_scores(player)
    PLAYERS player[];
{
  register int i;

  for (i=0; i<MAXPLAYERS; i++)
    player[i].score = 0;
}
/* ----------------------------------------------------------------------- */
/* copy the 'dimensions' first elements of array 'source' into array 'dest'*/

void arrcpy(dest, source, dimensions)
    PIC_DATA  dest[], source[];
    int       dimensions;
{
  register int i;

  for (i=0; i<dimensions; i++)
    dest[i] = source[i];
}
/* ----------------------------------------------------------------------- */
/* get players' names (via a dialog-box) */

void get_names(players, player, tx,ty,tw,th)
    int     players;
    PLAYERS player[];
    int     *tx, *ty, *tw, *th;
{
  OBJECT  *tree;
  int     exit_button;
  int     x, y, w, h;
  register int i;

  rsrc_gaddr(0, FRMNAMES, &tree);
  form_center(tree, &x, &y, &w, &h);
  form_dial(FMD_START, 0,0,0,0, x,y,w,h);

  /* make EDITABLE only the objects we need (depending on # of players) */
  for (i=NAME1; i<NAME1+players; i++)
  {
    strcpy( ((TEDINFO *)tree[i].ob_spec)->te_ptext, player[i-NAME1].name );
    objc_change(tree, i, 0, x,y,w,h, NORMAL, 0);
    tree[i].ob_flags |= EDITABLE;
  }

  /* make the rest NOT EDITABLE and DISABLED */
  for (i=NAME1+players; i<=NAME4; i++)
  {
    ((TEDINFO *)tree[i].ob_spec)->te_ptext[0] = '\0';
    objc_change(tree, i, 0, x,y,w,h, DISABLED, 0);
    tree[i].ob_flags &= ~EDITABLE;
  }
  objc_draw(tree, 0, MAX_DEPTH, x,y,w,h);

  /* wait for players to type their names */
  exit_button = form_do(tree, NAME1);
  objc_change(tree, exit_button, 0, x,y,w,h, NORMAL, 0);
  form_dial(FMD_FINISH, 0,0,0,0, x,y,w,h);

  /* put their names in my array 'players[]' */
  /* empty fields are substituted with the string "Player #x" */
  for (i=NAME1; i<NAME1+players; i++)
    if ( ((TEDINFO *)tree[i].ob_spec)->te_ptext[0] == '\0' )
      sprintf(player[i-NAME1].name, "Player #%d", i-NAME1+1);
    else
      strcpy(player[i-NAME1].name, ((TEDINFO *)tree[i].ob_spec)->te_ptext);

  *tx = x-1;
  *ty = y-1;
  *tw = w+3;
  *th = h+3;
}
/* ----------------------------------------------------------------------- */
void show_about(tx, ty, tw, th)
    int *tx, *ty, *tw, *th;
{
  OBJECT  *tree;
  int     exit_button, x,y,w,h;

  rsrc_gaddr(0, FRMABOUT, &tree);
  form_center(tree, &x, &y, &w, &h);
  fix_border(x,y,w,h,2);
  form_dial(FMD_START, 0,0,0,0, x,y,w,h);
  objc_draw(tree, 0, MAX_DEPTH, x,y,w,h);
  exit_button = form_do(tree, 0);
  objc_change(tree, exit_button, 0, x,y,w,h, NORMAL, 0);
  form_dial(FMD_FINISH, 0,0,0,0, x,y,w,h);

  *tx = x-1;
  *ty = y-1;
  *tw = w+3;
  *th = h+3;
}
/* ----------------------------------------------------------------------- */
char itoa9(digit)    /* integer to ascii (works for digits 0..9) */
    int digit;
{
	return ('0'+digit);
}
/* ----------------------------------------------------------------------- */
char *itos99(number)    /* integer to string (works for integers 0..99)    */
                        /* returns: string of length 5, with leading zeros */
    int number;
{
  char  itoa9();
  static char string[5];

  if (number < 10)
  {register int i;
    for (i=0; i<3; i++)
      string[i] = '0';
    string[i] = itoa9(number);
  }

  else
  {int t1, t2;

    t1 = number / 10;
    t2 = number % 10;
    string[0] = '0';
    string[1] = '0';
    string[2] = itoa9(t1);
    string[3] = itoa9(t2);
  }

  string[4] = '\0';

  return(string);
}
/* ----------------------------------------------------------------------- */
/* find the winner and display its name in a dialog-box */

void show_winner(player, tx, ty, tw, th)
    PLAYERS player[];	
    int     *tx, *ty, *tw, *th;
{
  OBJECT  *tree;
  int     max=0, winner=0;
  int     x,y,w,h;
  BOOLEAN draw=FALSE;
  register long i;


  /* find the winner's index */
  for (i=0; i<MAXPLAYERS; i++)
  {
    if (player[i].score > max)
    {
      max = player[i].score;
      winner = (int)i;
    }
  }

  /* check for draw */
  for (i=0; i<MAXPLAYERS && !draw; i++)
    if (player[i].score == player[winner].score)
      if (i != winner)
        draw = TRUE;

  if (draw)   /* no winner: do nothing */
    return;

  /* display the dialog-box */
  rsrc_gaddr(0, FRMWINER, &tree);
  form_center(tree, &x, &y, &w, &h);
  fix_border(x,y,w,h,2);
  form_dial(FMD_START, 0,0,0,0, x,y,w,h);
  strcpy( ((TEDINFO *)tree[WINNER].ob_spec)->te_ptext, player[winner].name );
  objc_draw(tree, 0, MAX_DEPTH, x,y,w,h);
  for (i=0; i<200000L; i++);
  form_dial(FMD_FINISH, 0,0,0,0, x,y,w,h);

  *tx = x-1;
  *ty = y-1;
  *tw = w+3;
  *th = h+3;
}
/* ----------------------------------------------------------------------- */
/* diasplay high-scores-table in a dialog box */

void show_hiscores(tx, ty, tw, th)
    int *tx, *ty, *tw, *th;
{
  OBJECT  *tree;
  int     exit_button, x,y,w,h;
  void    put_scores_in_dbox();
  extern PLAYERS hitable[];

  rsrc_gaddr(0, FRMSCORE, &tree);
  form_center(tree, &x, &y, &w, &h);
  form_dial(FMD_START, 0,0,0,0, x,y,w,h);
  put_scores_in_dbox(tree, hitable);
  objc_draw(tree, 0, MAX_DEPTH, x,y,w,h);
  exit_button = form_do(tree, 0);
  objc_change(tree, exit_button, 0, x,y,w,h, NORMAL, 0);
  form_dial(FMD_FINISH, 0,0,0,0, x,y,w,h);

  *tx = x-1;
  *ty = y-1;
  *tw = w+3;
  *th = h+3;
}
/* ----------------------------------------------------------------------- */
/* put high-scores in the high-score-table dialog-box */

void put_scores_in_dbox(tree, hitable)
    OBJECT  *tree;
    PLAYERS hitable[];
{
  register int i;


  /* 2 PLAYERS */
  for (i=TOPNAM1; i<=TOPNAM4; i++)
    sprintf( (char *)tree[i].ob_spec, "%s", hitable[i-TOPNAM1].name );

  /* 3 PLAYERS */
  for (i=TOPNAM5; i<=TOPNAM8; i++)
    sprintf( (char *)tree[i].ob_spec, "%s", hitable[i-TOPNAM5+4].name );

  /* 4 PLAYERS */
  for (i=TOPNAM9; i<=TOPNAM12; i++)
    sprintf( (char *)tree[i].ob_spec, "%s", hitable[i-TOPNAM9+8].name );

  for (i=POINTS1; i<=POINTS12; i++)
    sprintf( (char *)tree[i].ob_spec, "%d", hitable[i-POINTS1].score );

}
/* ----------------------------------------------------------------------- */
/* update the high-score-table */

int upd_hiscores(players, dimensions, player, hitable)
    int       players, dimensions;
    PLAYERS   player[], hitable[];
{
  register int i;
  int   new_hiscorer = -1;
  int   start_index, offset, hi_index;



  if (players == 1)   /* no high-score when single-player */
    return(-1);

  switch (dimensions)
  {
    case 100:
      offset = 0;
      break;

    case  90:
      offset = 1;
      break;

    case  80:
      offset = 2;
      break;

    case  70:
      offset = 3;
      break;
  }

  switch(players)
  {
    case 2:
      start_index = 0;
      break;

    case 3:
      start_index = 4;
      break;

    case 4:
      start_index = 8;
      break;
  }

  hi_index = start_index + offset;

  for (i=0; i<players; i++)
  {
    if (player[i].score > hitable[hi_index].score)
    {
      strcpy(hitable[hi_index].name, player[i].name);
      hitable[hi_index].score = player[i].score;
      new_hiscorer = i;
    }
  }

  return(new_hiscorer);
}
/* ----------------------------------------------------------------------- */
/* display top-scorer's name in a dialog-box */

void show_topscorer(name, tx, ty, tw, th)
    char  *name;
    int   *tx, *ty, *tw, *th;
{
  OBJECT  *tree;
  int     x,y,w,h;
  register long i;

  rsrc_gaddr(0, FRMTOPER, &tree);
  form_center(tree, &x, &y, &w, &h);
  form_dial(FMD_START, 0,0,0,0, x,y,w,h);
  strcpy( ((TEDINFO *)tree[TOPSCORE].ob_spec)->te_ptext, name );
  objc_draw(tree, 0, MAX_DEPTH, x,y,w,h);
  for (i=0; i<200000L; i++);
  form_dial(FMD_FINISH, 0,0,0,0, x,y,w,h);

  *tx = x-1;
  *ty = y-1;
  *tw = w+3;
  *th = h+3;
}
/* ----------------------------------------------------------------------- */
/* read high-scores from disk, and put them in hitable[] */

void read_hiscores(hitable)
    PLAYERS hitable[];
{
  FILE   *fp;
  static char score_file[] = "ST_CONC.DAT";

  /* if the file doesn't exist, use the default names & scores */
  if ( !(fp=fopen(score_file, "rb")) )
  {char str[128];
    sprintf(str,
            "[3][%s doesn't exist.|I'll use the default values][OK]",
            score_file
    );
    form_alert(1,str);
  }

  else  /* read from disk to hitable[] */
  {unsigned size, n;

    n = (unsigned)12;
    size = (unsigned)sizeof(PLAYERS);
    fread(hitable, size, n, fp);
    fclose(fp);
  }
}
/* ----------------------------------------------------------------------- */
/* write high-scores from hitable[] to disk */

void write_hiscores(hitable)
    PLAYERS hitable[];
{
  FILE   *fp;
  static char score_file[] = "ST_CONC.DAT";
  long   disk_free();

  /* if the file doesn't exist, try to create a new one */
  if ( !(fp=fopen(score_file, "wb")) )
  {
    form_alert(1,"[3][Cannot create file|Is disk protected?|Save Aborted][OK]");
    return;
  }

  else  /* write from hitable[] to disk */
  {unsigned size, n;

    n = (unsigned)12;
    size = (unsigned)sizeof(PLAYERS);
    if ( disk_free() < (long)(n * size) + 2040 )
    {
      form_alert(1,"[3][You disk doesn't have| enough free-space!][I see]");
      fclose(fp);
      return;
    }
    fwrite(hitable, size, n, fp);
    fclose(fp);
  }
}
/* ----------------------------------------------------------------------- */
long disk_free()
{
  typedef struct disk_info{
    unsigned long d_freeAUs;  /* free Allocation Units */
    unsigned long d_manyAUs;  /* how many AUs on disk */
    unsigned long d_secsize;  /* sector size */
    unsigned long d_secperAU; /* sectors per AU */
  }DISK;

  int   drive;
  long  free_bytes;
  long  free_sectors;
  DISK  disk;


  drive = Dgetdrv();
  Dfree(&disk, drive+1);
  free_sectors = disk.d_freeAUs*disk.d_secperAU;
  free_bytes   =   free_sectors*disk.d_secsize;

  return(free_bytes);
}
/* -------------------------------------------------------------------- */
