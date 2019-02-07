
#include "kamikaze.h"

/* This file determines which moves are legal */

char must_take;

/* Find all moves that could be made ignoring for the moment that if you
   can take a piece you must.  While we're at it see if it's possible to
   take a piece. */
find_probable_moves()
{
register Piece_move *pm;
register Move *m;
register Piece *p;
register WORD i, j;

must_take = 0;
m = probable_moves;
probable_count = 0;
p = pieces[move_color]+16;
i = 16;
while (--i >= 0)
    {
    --p;
    if (p->flags & PDEAD)
        {
        continue;
        }
    pm = p->lmoves;
    j = p->lmove_count;
    while (--j >= 0)
        {
        m->dx = pm->dx;
        m->dy = pm->dy;
        if (probable_move(p, m, 0))
            {
            m->child = m->next = NULL;
            if (m->flags & MTAKING)
                must_take = 1;
            m += 1;
            probable_count += 1;
            }
        pm += 1;
        }
    }
}

/* Get rid of the moves that don't involve taking a piece if taking a
   piece is possible. */
find_legal_moves()
{
register Move *next, **legal;
register int i;

find_probable_moves();
sorted_count = 0;
i = probable_count;
next = probable_moves;
legal = sorted_moves;
if (must_take)
    {
    while (--i >= 0)
        {
        if (next->flags & MTAKING)
            {
            *legal++ = next;
            sorted_count++;
            }
        next++;
        }
    }
else
    {
    while (--i >= 0)
        {
        *legal++ = next++;
        sorted_count++;
        }
    }
}




char *cnames[2] = {"White Won!", "Black Won!"};

extern Piece *in_check();

/* Check for mate, stalemate, and no pieces left. */
check_for_mate()
{
Piece *x;
int i;

find_legal_moves();
if (sorted_count == 0)
    {
    if (living[move_color] == 0)
        {
        
        short_message(cnames[move_color], move_color+2);
        }
    else if ((x = in_check(move_color)) != NULL)    /* checkmate! */
        {
        flash_color(0x740);
        short_message("Checkmate!", 1-move_color+2);
        message2(cnames[1-move_color], 2 + 1-move_color);
        for (i=2; i<7; i++)
            smessage("", 0, i);
        wait_a_jiffy(20);
        flash_pieces(pieces[move_color]+KING_IX, x);
        }
    else                    /* stalemate */
        {
        flash_color(0x770);
        short_message("Stalemate!", 5);
        wait_a_jiffy(20);
        flash_pieces(white_pieces+KING_IX, black_pieces+KING_IX);
        }
    small_font();
    smessage("CLICK MOUSE OR", 15, 15);
    smessage("PRESS ANY KEY", 15, 16);
    smessage("TO CONTINUE.", 15, 17);
    normal_font();
    wait_ednkey();
    return(1);
    }
else
    return(0);
}


/* Inform user of the possible taking moves he has */
flash_taking_moves()
{
int i;
register Move **ms, *m;

i = sorted_count;
ms = sorted_moves;
while (--i >= 0)
    {
    m = *ms++;
    if (m->flags & MTAKING)
        {
        fpieces( m->piece,  m->took_piece, 2);
        }
    }
}



