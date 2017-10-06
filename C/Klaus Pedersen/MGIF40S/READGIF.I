/* Prototypes for functions defined in C:\TMP\MGIF.LC\READGIF.C */
int ReadGIF(char *fname,
            uchar_t *codedgif,
            uchar_t *raster,
            screen_t *scrninf,
            image_t *id,
            uchar_t (*colormap)[3],
            int opt);
void rasinv(uchar_t *codedgif);
int rasunpack(uchar_t *codedgif,
              uchar_t *raster,
              int opt);
int _ReadRaster(FILE *infile,
                uchar_t *codedgif,
                screen_t *scrninf,
                uchar_t *raster,
                int opt);
int _ReadCode(uchar_t *codedgif);
int _AddPixel(uchar_t indx,
              uchar_t *raster,
              int opt);
void _InstCMap(int ncolors,
               uchar_t *cm,
               uchar_t (*map)[3],
               int opt);
int _ScanSD(FILE *infile,
            screen_t *sd,
            int opt);
void _SkipEB(FILE *infile,
             int opt);
int _ScanID(FILE *infile,
            image_t *id,
            int opt);
void _ScanCM(FILE *infile,
             int colors,
             char *cm,
             int opt);
int _ScanMAGIC(FILE *infile,
               char *parse,
               int opt);
int _GetKey(void);
