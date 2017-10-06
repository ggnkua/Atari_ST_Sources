/*
 *  Turing -- A simple two-dimensional turing machine.
 *
 *  Written by Steven T. McClure @ University of New Hampshire, 1989
 *
 *  This program can be distributed freely in any non-commercial
 *  environment, and can be used in no way for a profit by anyone
 *  (except me, of course :) ), and can be modified in any way that
 *  you like.  I take no responsibility for the readablness of this
 *  code (or this comment, for that matter :) ), the correctness of
 *  this code, or any damages occuring from the use of this code.
 *  Have fun with it, I know I did.
 */
/*
 *  This program uses the screen as a 'tape' for a two-dimensional
 *  turing machine.  Instructions for use are in 'turing.inf'.
 */
/*  Ported ( a very simple port ) to the Atari ST ( MWC ) by Mark Boyd.
 *  On the Atari ST this program supports 16 colors in 320X200 (low)
 *  4 colors in 640X200 (medium), and 2 colors in 640X400 mode (high).
 */

#include <stdio.h>
#include <linea.h>
#include <osbind.h>

#define         UP              0       /* Physical directions to move */
#define         RGT             2
#define         DOWN            4
#define         LFT             6

#define         LEFT            10      /* Turn and move directions */
#define         RIGHT           20
#define         FORWARD         30
#define         STAY            40
#define         BACKUP          50

struct  tape    {
        int     t_lin;
        int     t_col;
        int     t_dir;
        int     t_state;
        int     t_color;
} tp;

struct  state   {
        int     s_got;
        int     s_paint;
        int     s_dirgo;
        int     s_sgo;

        struct  state   *s_prev;
        struct  state   *s_next;
};

struct  list    {
        int     l_state;

        struct  state   *l_first;
        struct  state   *l_last;
        struct  list    *l_prev;
        struct  list    *l_next;
};

struct  list    *firstlist;
struct  list    *lastlist;
struct  tape    t;

main(argc, argv)
int     argc;
char    *argv[];
{
        char    c;
        int     rez;

        if (argc < 2) {
                printf("Usage: turing [ file ] ...\n");
                exit(0);
        }
        read_tuples(argv[1]); /* getdata from a file */
        Cconws("\033E\033f"); /* Home and clear screen, turn off cursor */
        rez = Getrez();       /* get screen resolution */
        linea0();             /* initialize linea stuff */
        putpixel(tp.t_col, tp.t_lin, tp.t_color);  /* write starting pixel */
        do {
                do_turing(rez);
                c = Crawcin();
        } while (c != 'q' && c != 'Q'); /* quit when a 'q' is entered*/
        Cconws("\033Y9 \033e");      /* turn cursor back on at bottom right*/
}

do_turing(rez)
int rez;
{
        struct  list    *l;
        struct  state   *s;
        int     color, width = 319, height = 199;

        if(rez > 0) width  = 639;  /* set window size to work in */
        if(rez > 1) height = 399;

        while (!Cconis()) {
                color = getpixel(tp.t_col, tp.t_lin);
                for (l = firstlist; l; l = l->l_next)
                        if (l->l_state == tp.t_state)
                                break;
                if (!l)
                        break;
                for (s = l->l_first; s; s = s->s_next)
                        if (color == s->s_got)
                                break;
                if (!s)
                        break;
                putpixel(tp.t_col, tp.t_lin, s->s_paint);
                if (s->s_dirgo == RIGHT)
                        tp.t_dir = (tp.t_dir + 2 > 6 ? 0 : tp.t_dir + 2);
                else if (s->s_dirgo == LEFT)
                        tp.t_dir = (tp.t_dir - 2 < 0 ? tp.t_dir + 6 : tp.t_dir - 2);
                else if (s->s_dirgo == BACKUP)
                        tp.t_dir = (tp.t_dir - 4 < 0 ? tp.t_dir + 4 : tp.t_dir - 4);
                if (s->s_dirgo != STAY) {
                        if (tp.t_dir == UP)
                                tp.t_lin = (tp.t_lin - 1 < 0 ? 0 : tp.t_lin - 1);
                        else if (tp.t_dir == DOWN)
                                tp.t_lin = (tp.t_lin + 1 > height ? height : tp.t_lin + 1);
                        else if (tp.t_dir == LFT)
                                tp.t_col = (tp.t_col - 1 < 0 ? 0 : tp.t_col - 1);
                        else if (tp.t_dir == RGT)
                                tp.t_col = (tp.t_col + 1 > width ? width : tp.t_col + 1);
                        else
                                break;
                }
                if (s->s_dirgo == BACKUP)
                        tp.t_dir = (tp.t_dir - 4 < 0 ? tp.t_dir + 4 : tp.t_dir - 4);
                tp.t_state = s->s_sgo;
        }
        Crawcin();
}

read_tuples(str)
char    *str;
{
        struct  state   *s;
        struct  list    *l;
        FILE    *fp;
        int     cstate;
        int     godir;
        int     gotcol;
        int     paint;
        int     gostate;

        if ((fp = fopen(str, "r")) == NULL) {
                printf("Cannot open '%s' for reading.\n", str);
                exit(-1);
        }
        fscanf(fp, "%d %d %d %d %d\n", &tp.t_state, &tp.t_lin, &tp.t_col, &tp.t_dir, &tp.t_color);
        while (!feof(fp)) {
                fscanf(fp, "%d %d %d %d %d\n", &cstate, &gotcol, &paint, &godir, &gostate);
                for (l = firstlist; l; l = l->l_next)
                        if (cstate == l->l_state)
                                break;
                if (!l) {
                        l = malloc(sizeof(struct list));
                        l->l_prev = firstlist;
                        l->l_next = 0;
                        if (!firstlist)
                                firstlist = l;
                        if (lastlist)
                                lastlist->l_next = l;
                        lastlist = l;
                        l->l_first = 0;
                        l->l_last = 0;
                        l->l_state = cstate;
                }
                s = malloc(sizeof(struct state));
                s->s_prev = l->l_first;
                s->s_next = 0;
                if (!l->l_first)
                        l->l_first = s;
                if (l->l_last)
                        l->l_last->s_next = s;
                l->l_last = s;
                s->s_got = gotcol;
                s->s_paint = paint;
                s->s_dirgo = godir;
                s->s_sgo = gostate;
        }
        fclose(fp);
}
