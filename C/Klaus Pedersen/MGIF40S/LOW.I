/* Prototypes for functions defined in C:\TMP\MGIF.LC\LOW.C */
int do_hist(uchar_t *pras,
            int w,
            int h,
            long *hist);
int draw_hist(long *hist);
int drhhist(long *hst,
            int hstsiz,
            long hmax,
            int xmn,
            int ymn,
            int xmx,
            int ymx,
            int bordr,
            int vspace,
            int barsize);
int drvhist(long *hst,
            int hstsiz,
            long hmax,
            int xmn,
            int ymn,
            int xmx,
            int ymx,
            int bordr,
            int hspace,
            int barsize);
int grid(int x,
         int y,
         int w,
         int h,
         int sp);
int do_line(int x1,
            int y1,
            int x2,
            int y2);
void xor_line(int x1,
              int y1,
              int x2,
              int y2);
void xor_dash(int x1,
              int y1,
              int x2,
              int y2);
int cursor(int visible);
int clr_cmd(void);
int mv_cursor(int col,
              int row);
int clr_screen(void);
long do_time(int opt);
int check_key(void);
int get_key(void);
int get_string(int n,
               char *buf);
long get_rkey(void);
int get_xypos(int opt,
              int type,
              int xorg,
              int yorg,
              int width,
              int height,
              int rwidth,
              int rheight,
              int xstart,
              int ystart,
              int *x,
              int *y);
int wait_key(void);
int wait_ms(int ms);
