#define CUR_WIDTH 16
#define CUR_HEIGHT 16

#define CUR_X_BIAS 7
#define CUR_Y_BIAS 7

struct cursor 
    {
    WORD type;
    WORD *image;
    WORD width,height;
    WORD xhot, yhot;
    };

extern struct cursor *cursor;

extern struct cursor cross_cursor, box_cursor, hook_cursor;
extern struct cursor camera_cursor, reels_cursor, replay_cursor;
extern struct cursor rotate_cursor, reel_cursor, grab_cursor;
extern struct cursor dump_cursor, point_cursor, poly_cursor;
extern struct cursor out_cursor;
extern struct cursor size_cursor, kill_cursor, color_cursor, select_cursor;
extern struct cursor scoop_cursor;
extern struct cursor straw_cursor;
extern struct cursor in_cursor,  bye_cursor;
extern struct cursor center_cursor;
extern struct cursor spike_cursor;
extern struct cursor loop_cursor;
extern struct cursor frame_cursor;
extern struct cursor strip_cursor;
extern struct cursor clone_cursor, fill_cursor, doodle_cursor;
extern struct cursor spray_cursor, disk_cursor, lreplay_cursor;
extern struct cursor breplay_cursor, raster_cursor;
extern struct cursor circle_squared_cursor,  square_circled_cursor;
extern struct cursor edit_cursor;
extern struct cursor seq_cursor,  story_cursor;
extern struct cursor segment_cursor, splice_cursor;

