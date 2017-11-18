//#ifndef DEFINITIONS
//	#define DEFINITIONS
	#include "definitions.h"
//#endif

/* ******** Variable Definitions ******************* */

// Globals
extern enum bool frames_recalculated;
extern short vdi_handle;
extern short app_id;
extern short window_handle;
extern short fonts[3][2][2];
extern short event_messages[8];
extern short number_of_frames_left_to_load;
extern struct frame_item *first_frame;
extern struct clickable_area *current_highlighted_link_area;
extern struct frame_item *current_highlighted_link_frame;
extern struct to_do_item *add_to_do;
extern struct to_do_item *read_to_do;

// To be in-program settings
extern short link_colour;
extern short highlighted_link_colour;
extern short text_colour;

/* ****************** Function Defs ******************************** */

short V_Opnvwk(VDI_Workstation *);
short V_Opnwk(short, VDI_Workstation *);
//void add_item_to_to_do_list(enum possible_message_types, void *);
//void add_load_item_to_to_do_list(short, char *, struct frame_item *);
//void add_parse_item_to_to_do_list(char *, struct frame_item *);
void render_page_contents(struct paragraph_item *,short,long,short,short,short);
//long calculate_frame_height(struct frame_item *);
//void calculate_frame_locations(void);
//void blit_block(struct frame_item *,short , enum direction );
//struct word_item *list_marker(struct word_item *,struct list_stack_item *,short *,short);
struct paragraph_item *parse(char *,short *);
//enum bool process_messages(struct frame_item *);
//void redraw(short,short,short,short,short,struct frame_item *);
//void redraw_frame(short,short,short,short,short,struct frame_item *);
//void scroll_bar(struct frame_item *, short);
short special_char_map(short);
//void button_clicked(struct frame_item *,short ,short );
//void frame_clicked(struct frame_item *,struct frame_item *,short ,short );
//void check_mouse_position(struct frame_item *, short , short );
//void draw_frame_borders(struct frame_item *,short);
char * load_file(char *);
void variable(char *,char *,char *);
short convert_to_number(const char *text);
short list_indent(short);
struct paragraph_item *add_paragraph(struct paragraph_item *, struct word_item *,short *,short *,short *,short);
short map(char symbol);
struct url_link *new_url_link(char *, enum link_mode);
struct font_step *new_step(short);
struct font_step *add_step(struct font_step *);
struct font_step *destroy_step(struct font_step *);
struct list_stack_item *remove_stack_item(struct list_stack_item *);
struct list_stack_item *new_stack_list_item(void);
struct word_item *add_word(struct word_item *,short *,short *,short *,short);
struct word_item *new_word(void);
//struct frame_item *new_frame(void);
//void reset_frame(struct frame_item *);
struct paragraph_item *new_paragraph(void);
//void destroy_frame_structure(struct frame_item *);
void destroy_paragraph_structure(struct paragraph_item *);
void destroy_word_structure(struct word_item *);
void word_store(struct word_item *,short *,short *);
void destroy_clickable_area_structure(struct clickable_area *);
struct clickable_area *new_clickable_area();
void destroy_named_location_structure(struct named_location *);
struct named_location *new_named_location();
char *translate_address(char *);
long search_for_named_location(char *,struct named_location *);
void debug(char *);
void i_debug(short);