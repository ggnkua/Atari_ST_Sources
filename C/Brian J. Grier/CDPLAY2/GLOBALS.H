#define nBlocks 1

#define TRUE   0
#define FALSE -1

#define DEFAULT_TIME_OUT  60

typedef struct { int x, y, w, h; } Rect;
typedef struct { int *x, *y, *w, *h; } Prect;

extern void    read_TOC(TOC_DATA_FORMAT * buffer) ;
extern void    read_sub_channel(void) ;
extern void    find_Chinon(void) ;
extern void    eject_cd(void) ;
extern void    stop_audio(void) ;
extern void    pause_audio(void) ;
extern void    resume_audio(void) ;
extern void    play_audio(int track) ;
extern void    continue_audio(void) ;
extern double  t_sec(ABS_CD_ROM_ADDR * addr) ;
extern int     toc_cmp(TOC_DATA_FORMAT * toc1, TOC_DATA_FORMAT * toc2) ;
extern void    toc_copy(TOC_DATA_FORMAT * dest, TOC_DATA_FORMAT * src) ;
extern int     next_track(int cur_trk) ;
extern int     prev_track(int cur_trk) ;

extern void    Create_Window(void) ;
extern void    Update_Window(int object) ;
extern void    Remove_Window(void) ;
extern int     Process_Message(void) ;
extern double  Get_Time_Remain(void) ;

extern int cx, cy, cw, ch ;
extern Prect cntr ;
extern Rect zero_box ;
extern Rect screen ;
extern MFORM it ;

extern char            * disp_text ;
extern char            * rept_text ;

extern OBJECT          * form_addr ;
extern OBJECT          * disp_addr ;
extern OBJECT          * rept_addr ;
extern OBJECT          * menu_addr ;

extern int               current_track ;
extern int               disp_id ;
extern int               rept_id ;
extern int               diag_id ;
extern int               panel_id ;

extern int               event ;
extern int               dummy1 ;
extern int               dummy2 ;
extern int               bstate ;
extern int               ev_mmox ;
extern int               ev_mmoy ;
extern int               ev_mmbutton ;
extern int               ev_mmokstate ;
extern int               ev_buffer[128] ;

extern double            time_remaining ;

extern SUB_CHANNEL_DATA  sub_channel ; /* buffer to hold audio status */
extern TOC_DATA_FORMAT   toc ;         /* buffer to hold data to/from cd-rom */
extern char              scrap[512] ;  /* buffer to hold junk data */

extern TOC_DATA_FORMAT   toc_tmp ;
extern int cur_index ;