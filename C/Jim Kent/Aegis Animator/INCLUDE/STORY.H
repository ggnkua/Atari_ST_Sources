
#define MORPH_CYCLE 0
#define RASTER_STILL 1
/* defs for sequence->type*/

#define NO_PATH 0
#define CIRCLE_PATH 1
#define POLY_PATH 2
#define CURSOR_PATH 3

struct story
    {
    struct s_sequence *sequence;
    WORD is_active;
    WORD x_min_pos, y_min_pos;
    WORD x_max_pos, y_max_pos;
    char *name;
    };

extern struct story story_board[];

#ifdef AMIGA
#define STORY_COUNT 9
#endif AMIGA
#ifdef ATARI
#define STORY_COUNT 6
#endif ATARI
