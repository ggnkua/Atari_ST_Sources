/* Prototypes for functions defined in C:\TMP\MGIF.LC\FLICKER.C */
int *flicker(unsigned char *pimg,
             int width,
             int hight,
             int beta,
             int maxrandom,
             int opt);
void _Conv2Gray(unsigned char *pic);
void _SimpConv2Gray(unsigned char *pic);
int _GenConvPix(unsigned char *pic,
                int x,
                int opt);
int _Laplace(unsigned char *Pic);
void _ClearErr(void);
int _Rand(int mx);
int _Delay(int ms);
int _GetHist(unsigned char *pras,
             int w,
             int h,
             long *hist);
int _DoHist(int *scrn,
            long *hst,
            int opt);
