/* Prototypes for functions defined in C:\TMP\MGIF.LC\PROCESS.C */
int larger(uchar_t *pras,
           int w,
           int h,
           int opt,
           uchar_t *ptrans);
int zoom(uchar_t *pras,
         int w,
         int h,
         int xstart,
         int ystart,
         uchar_t *ptrans);
int smaller(uchar_t *pras,
            int w,
            int h,
            int opt,
            uchar_t *ptrans);
int cut(uchar_t *pras,
        int w,
        int h,
        int x1,
        int y1,
        int x2,
        int y2,
        uchar_t *ptrans);
int rotate(uchar_t *pras,
           int w,
           int h,
           int angle,
           uchar_t *ptrans);
int mirror(uchar_t *pras,
           int w,
           int h,
           int opt,
           uchar_t *ptrans);
int convolve(uchar_t *pras,
             register int w,
             int h,
             int opt,
             int *kernel,
             uchar_t *ptrans);
int blur(uchar_t *pras,
         register int w,
         int h,
         uchar_t *ptrans);
int median(uchar_t *pras,
           int w,
           int h,
           uchar_t *ptrans);
int piksrt(int num,
           uint_t *arr);
uint_t findmedian(int num,
                  uint_t *arr);
int logscale(uchar_t *pras,
             int w,
             int h,
             uchar_t *ptrans);
int Log2x10(uint_t x);
int contrast(uchar_t *pras,
             int w,
             int h,
             long thresh,
             long *hist,
             uchar_t *ptrans);
int brighten(uchar_t *pras,
             int w,
             int h,
             register int brite,
             uchar_t *ptrans);
int invert(uchar_t *pras,
           int w,
           int h,
           int thresh,
           uchar_t *ptrans);
int threshold(uchar_t *pras,
              int w,
              int h,
              int thresh,
              uchar_t *ptrans);
int histeq(uchar_t *pras,
           int w,
           int h,
           long *hist,
           uchar_t *ptrans);
int redistribute(uchar_t *pras,
                 int w,
                 int h,
                 register long *s_kapprx);
int copyrast(uchar_t *ps,
             int w,
             int h,
             uchar_t *pd);
