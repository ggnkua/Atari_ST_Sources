/*************************************/
/* Header de d‚compression Pack Bits */
/*************************************/

/****************************************/
/* Routine de d‚compression format MFDB */
/****************************************/
void packbits_dcmps(void *in, void *out, int nbpixel,
                    int nbline, int nbplan) ;

/***********************************************/
/* Routine de d‚compression en suite d'indices */
/***********************************************/
void packbits_idcmps(void *in, void *out, int nbpixel,
                     int nbline, int nbplan) ;
