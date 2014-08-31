/*
 *   Library for handling Dialogs in Windows ...
 */

#define  BEGIN            1
#define  END              2

#define  CB_TIMER         -1
#define  CB_MESSAGE       -2
#define  CB_MENU          -3
#define  CB_EVENT         -4

#define  TE_PTEXT         0
#define  TE_PTMPLT        1
#define  TE_PVALID        2

#define  CLOSER_CLICKED   0x7654


typedef  int  (* FUNC) ();


int   initialise_windows (int number_trees, int icnfy_index);
int   leave_windows (void);
int   open_rsc_window (int rsc_tree, int edit_object, char window_name[], char short_name[], int parent_tree);
int   close_rsc_window (int rsc_tree, int wind_handle);
void  set_callbacks (int rsc_tree, int click_func (int obj), int key_func (int scan));
int   operate_events (void);
void  interupt_editing (int rsc_tree, int what, int new_edit);
void  change_rsc_size (int rsc_tree, int new_width, int new_height, int parent_obj);
void  change_freestring (int rsc_tree, int object, int parent_obj, char text[], int length);
void  change_tedinfo (int rsc_tree, int object, int parent_obj, int which, char text[], int length);
void  change_flags (int rsc_tree, int object, int change_flag, int flags, int state);
int   top_rsc_window (int rsc_tree);
int   pop_up (int popup_tree, int *object, int dialog_tree, int string_obj, int length);
