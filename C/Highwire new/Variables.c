#include "HighWire.h"

/* ******** Variable Definitions ******************* */

// To be in-program settings
short link_colour=12;
short highlighted_link_colour=10;
short text_colour=1;

// Globals
enum bool frames_recalculated=false;
short vdi_handle;
//short app_id,window_handle;

//short fonts[3][2][2]={5031,5032,5033,5034,5031,5032,5033,5034,5031,5032,5033,5034};
short fonts[3][2][2]={5954,5955,5956,5957,5003,5004,5005,5006,5596,5597,5598,5599};
//short event_messages[8];
//short number_of_frames_left_to_load=0;
//struct frame_item *first_frame;

struct clickable_area *current_highlighted_link_area;
//struct frame_item *current_highlighted_link_frame;
//struct to_do_item *add_to_do;
//struct to_do_item *read_to_do;
