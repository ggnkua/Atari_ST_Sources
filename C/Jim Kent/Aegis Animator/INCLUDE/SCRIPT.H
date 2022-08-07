
struct tween
    {
    long start_time;
    WORD tweening;
    long stop_time;
    WORD act_count;
    WORD **act_list;
    struct poly_list *poly_list;
    };
typedef struct tween Tween;
extern struct tween grc_tween;


struct s_sequence
    {
    WORD type;
    WORD xoff, yoff;
    WORD width, height;
    WORD xscale, yscale;
    WORD level_z;
    WORD speed;
    long local_time;
    long start_time;
    long stop_time;
    long forward_offset;	/*amount to add as looping around */
    long duration;
    WORD since_last_tween;
    WORD to_next_tween;
    WORD tween_count;
    WORD tween_alloc;
    struct tween **tween_list;
    struct tween **next_tween;
    struct poly_list *next_poly_list;
    struct item_list *script_rasters;
    char *name;
    struct s_sequence **child_scripts;
    WORD child_count;
    };
typedef struct s_sequence Script;
extern struct s_sequence generic_sequence;
extern struct s_sequence *cur_sequence;
extern Script *make_empty_script();
extern Script *ld_scr();
extern long script_duration();
