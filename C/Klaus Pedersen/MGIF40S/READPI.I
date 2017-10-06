/* Prototypes for functions defined in C:\TMP\MGIF.LC\READPI.C */
int ReadPI1(char *fname,
            uchar_t *raster,
            uchar_t (*colormap)[3],
            int opt);
void _PI1toIndx(int *pscrn,
                uchar_t *pras);
int ReadPI2(char *fname,
            uchar_t *raster,
            uchar_t (*colormap)[3],
            int opt);
void _PI2toIndx(int *pscrn,
                uchar_t *pras);
