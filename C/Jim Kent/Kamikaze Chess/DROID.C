
#include "kamikaze.h"

/* This file is where the ST figures out how to move.  It's a simple
   Minimax algorithm.  It makes each possible move on the board in
   memory and sees where it stands, adding up the values of all it's
   remaining pieces and subtracting the values of all it's opponent's
   pieces.   Then it selects the 'best' moves and pursues them deeper,
   guessing what the opponents response will be by figuring it will
   also choose the 'best' move.   Of course it can
   be pretty easily fooled by a clever 'sacrifice' when there are
   many options open.  However in the situation where most moves are
   forced (as is common in delian more so than plain chess)
   it can look ahead many moves indeed.  As it goes further and further
   ahead it will look at less and less of the 'best' moves until
   eventually it stops.*/
   

extern WORD break_game;

WORD max_level;
Move root_move;
int nomem;
Move *freem;
long freem_avail = 10000L;

/* Make up a free list for possible moves.  Currently only should need 
   about 1000 really */
init_freem()
{
long freems;
register Move *ifr;
void *dummy;

if ((dummy = askmem(200*sizeof(Move))) == NULL)
    return(0);
freems = 10000L;
while (freems > 400)
    {
    if ((ifr = laskmem(freems*sizeof(Move)))!=NULL)
        break;
    freems -= 100;
    }
freem_avail = freems;
if (!ifr)
    return(0);
while (--freems >= 0)
    {
    ifr->next = freem;
    freem = ifr;
    ifr++;
    }
freemem(dummy);
return(1);
}

/* Free up a tree of possible moves */
free_mtree(m)
register Move *m;
{
if (m->child)
    free_mtree(m->child);
if (m->next)
    free_mtree(m->next);
m->next = freem;
freem = m;
}

int etc;

/* Clone the 'legal moves' list into freem memory where it won't get
   recursively over-written */
Move *
instantiate_array(ml, count)
register Move **ml;
register int count;
{
register Move *next;
register Move *nlist;

nlist = NULL;
while (--count >= 0)
    {
    if ((next = freem) == NULL)
        {
        nomem = 1;
        break;
        }
    freem = freem->next;
    copy_structure(*ml++, next, sizeof(*next));
    next->next = nlist;
    nlist = next;
    if ((etc&0x3f) == 0)
        {
        /*char buf[16];

        sprintf(buf, "..%d.%d..", max_level, etc);
        message2(buf, 6);*/
        }
    etc++;
    }
return(nlist);
}

/* Figure out our best move */
Move *
best_move(m)
register Move *m;
{
register Move *best;
int bestval;

best = m;
bestval = m->value;
while (m = m->next)
    {
    if (m->value > bestval)
        {
        bestval = m->value;
        best = m;
        }
    }
return(best);
}

Move *rb[256];
WORD rb_count;

/* Randomly pick one of the moves our algorithm says is best */
Move *
rbest_move(m)
register Move *m;
{
register int bval;

m = best_move(m);
bval = m->value;
rb_count = 1;
rb[0] = m;
while (m = m->next)
    {
    if (m->value == bval)
        {
        rb[rb_count] = m;
         rb_count++;
        if (rb_count == Array_els(rb))
            break;
        }
    }
return(rb[FastRand()%rb_count]);
}

WORD stop_level;


/* Assign a number to a board position.  The higher the number the better
   the position is. */
static
eval_board( m)
struct move *m;
{
register Piece *p, *kp;
register int acc;
register int dx, dy, v;

/* add up white pices */
acc = 0;
p = white_pieces;
dx = 16;
while (--dx >= 0)
    {
    if (p->flags & PDEAD)
        acc -= (p->value)+5;
    p++;
    }
/* and black pieces */
p = black_pieces;
dx = 16;
while (--dx >= 0)
    {
    if (p->flags & PDEAD)
        acc += (p->value)+5;
    p++;
    }
acc <<= 4;
if (move_color)
    acc = -acc;
return(acc);
}

/* Evaluate all possible legal moves */
eval_legal_moves()
{
register Move **l, *m;
register int i;
register int base, val;

l = sorted_moves;
i = sorted_count;
while (--i >= 0)
    {
    m = *l++;
    board_move(m);
    m->value = eval_board(m);
    unboard_move(m);
    }
}

/* Do a little shell sort on our moves, arranging them from best to worst */
sort_array(array, count)
Move **array;
WORD count;
{
register Move **pt1, **pt2;
register Move *swap;
register short swaps;
register int space, ct;

if (count < 2)  /*very short arrays are already sorted*/
    return;

space = count/2;
--count; /* since look at two elements at once...*/
for (;;)
    {
    swaps = 1;
    while (swaps)
        {
        pt1 = array;
        pt2 = array + space;
        ct = count - space + 1;
        swaps = 0;
        while (--ct >= 0)
            {
            if ((*pt1)->value < (*pt2)->value)
                {
                swaps = 1;
                swap = *pt1;
                *pt1 = *pt2;
                *pt2 = swap;
                }
            pt1++;
            pt2++;
            }
        }
    if ( (space = space/2) == 0)
        break;
    }
}



/* Make up a binary tree recursively of all the likely looking moves.
   When have  looked at all the possible moves and still have the
   memory and time call ourselves to determine the best moves the
   opposition can make in response to these moves. (This is your
   basic MiniMax game theory algorithm.  Thanks to Morgenstern and
   Von Neumann. */
make_etree(level, root, color, euse)
int level;
Move *root;
int color;
long euse;
{
register Move *m;
register int i;
int ecount;
int temp;

if (level > max_level)
    max_level = level;
find_legal_moves();
if (sorted_count <= 0)
    return;
eval_legal_moves();
ecount = sorted_count;
sort_array(sorted_moves, sorted_count);
if (ecount  > euse)    /* let euse limit the # to instantiate */
    {
    ecount =  euse;
    }
root->child = m = instantiate_array(sorted_moves,  ecount);
euse -= ecount;
euse /= ecount;
if (euse <= 4 && (level&1) == 1)
    return;
if (level < stop_level && euse > 0)
    {
    while (m != NULL)
        {
        board_move(m);
        make_etree(level+1, m,1-color, euse);
        unboard_move(m);
        if (m->child)
            m->value = -best_move(m->child)->value;
        m = m->next;
        }
    }
}



/* Reduce tendency to jiggle king.  Helps end game especially. */
dampen_king()
{
register Move *m;

m = root_move.child;
while (m != NULL)
    {
    if (m->piece->id == KING_IX)
        m->value -= 1;
    m = m->next;
    }
}


/* The confuser moves a piece.  Analagous routine to human_move_piece in
   kamikaze.c */
droid_move_piece(color, depth)
int color;
long depth;
{
int i;
Move *m;
Piece *p;
int omust;
char buf[16];

check_input();
if (key_hit)
    {
    switch (key_in&0xff)
        {
        case 'x':
        case 'q':
        case 'X':
        case 'Q':
            break_game = 1;
            break;
        case ' ':
            smessage("Paused...", 6,1);
            smessage("Any key", 6, 2);
            smessage("to start", 6, 3);
            wait_click();
            break;
        default:
            break;
        }
    }
omust = must_take;
nomem = 0;
etc = 0;
max_level = 0;
if (sorted_count > 1)
    {
    stop_level = 40;
    make_etree(0, &root_move, color, depth);
    dampen_king();
    m = rbest_move(root_move.child);
    }
else
    {
    m = *sorted_moves;
    root_move.child = NULL;
    }
if (nomem)    /* Should never happen */
    {
    message2("Ran Out", color+2);
    wait_a_jiffy(30);
    }
p = m->piece;
must_take = omust;
fpieces(p, NULL, 2);
i = move_piece(p, p->column + m->dx, p->row + m->dy);
fpieces(p, NULL, 2);
if (sorted_count > 1)
    free_mtree(root_move.child);
return(i);
}

