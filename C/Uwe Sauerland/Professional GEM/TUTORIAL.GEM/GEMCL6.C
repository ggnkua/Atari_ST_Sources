>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MFDB Structure <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                        /* Memory Form Definition Block */
typedef struct fdbstr
{
        long            fd_addr;        /* Form address                 */
        int             fd_w;           /* Form width in pixels         */
        int             fd_h;           /* Form height in pixels        */
        int             fd_wdwidth;     /* Form width in memory words   */
        int             fd_stand;       /* Standard form flag           */
        int             fd_nplanes;     /* Number of color planes       */
        int             fd_r1;          /* Dummy locations:             */
        int             fd_r2;          /* Reserved for future use      */
        int             fd_r3;
} MFDB;

>>>>>>>>>>>>>>>>>>>>>>> Resource Transform Utilities <<<<<<<<<<<<<<<<<<<<<
/*------------------------------*/
/*      vdi_fix                 */
/*------------------------------*/
        VOID
vdi_fix(pfd, theaddr, wb, h)            /* This routine loads the MFDB */
        MFDB            *pfd;           /* Input values are the MFDB's */
        LONG            theaddr;        /* address, the form's address,*/
        WORD            wb, h;          /* the form's width in bytes,  */
        {                               /* and the height in pixels    */
        pfd->fww = wb >> 1;
        pfd->fwp = wb << 3;
        pfd->fh = h;
        pfd->np = 1;                    /* Monochrome assumed          */
        pfd->mp = theaddr;
        }

/*------------------------------*/
/*      vdi_trans               */
/*------------------------------*/
        WORD
vdi_trans(saddr, swb, daddr, dwb, h)    /* Transform the standard form */
        LONG            saddr;          /* pointed at by saddr and     */
        UWORD           swb;            /* store in the form at daddr  */
        LONG            daddr;          /* Byte widths and pixel height*/
        UWORD           dwb;            /* are given                   */
        UWORD           h;
        {
        MFDB            src, dst;       /* These are on-the-fly MFDBs  */

        vdi_fix(&src, saddr, swb, h);   /* Load the source MFDB        */
        src.ff = TRUE;                  /* Set it's std form flag      */

        vdi_fix(&dst, daddr, dwb, h);   /* Load the destination MFDB   */
        dst.ff = FALSE;                 /* Clear the std flag          */
        vr_trnfm(vdi_handle, &src, &dst );      /* Call the VDI        */
        }

/*------------------------------*/
/*      trans_bitblk            */
/*------------------------------*/
        VOID
trans_bitblk(obspec)                    /* Transform the image belonging */
        LONG    obspec;                 /* to the bitblk pointed to by   */
        {                               /* obspec.  This routine may also*/
        LONG    taddr;                  /* be used with free images      */
        WORD    wb, hl;

        if ( (taddr = LLGET(BI_PDATA(obspec))) == -1L)
                return;                 /* Get and validate image address */
        wb = LWGET(BI_WB(obspec));      /* Extract image dimensions       */
        hl = LWGET(BI_HL(obspec));
        vdi_trans(taddr, wb, taddr, wb, hl);    /* Perform a transform    */
        }                                       /* in place               */

/*------------------------------*/
/*      trans_obj               */
/*------------------------------*/
        VOID
trans_obj(tree, obj)                    /* Examine the input object.  If  */
        LONG    tree;                   /* it is an icon or image, trans- */
        WORD    obj;                    /* form the associated raster     */
        {                               /* forms in place.                */
        WORD    type, wb, hl;           /* This routine may be used with  */
        LONG    taddr, obspec;          /* map_tree() to transform an     */
                                        /* entire resource tree           */

        type = LLOBT(LWGET(OB_TYPE(obj)));              /* Load object type */
        if ( (obspec = LLGET(OB_SPEC(obj))) == -1L)     /* Load and check   */
                return (TRUE);                          /* ob_spec pointer  */
        switch (type) {
                case G_IMAGE:
                        trans_bitblk(obspec);           /* Transform image  */
                        return (TRUE);
                case G_ICON:                            /* Load icon size   */
                        hl = LWGET(IB_HICON(obspec));
                        wb = (LWGET(IB_WICON(obspec)) + 7) >> 3;
                                                        /* Transform data   */
                        if ( (taddr = LLGET(IB_PDATA(obspec))) != -1L)
                                vdi_trans(taddr, wb, taddr, wb, hl);
                                                        /* Transform mask   */
                        if ( (taddr = LLGET(IB_PMASK(obspec))) != -1L)
                                vdi_trans(taddr, wb, taddr, wb, hl);
                        return (TRUE);
                default:
                        return (TRUE);
                }
        }

>>>>>>>>>>>>>>>>>>>  Macro definitions for the code above <<<<<<<<<<<<<<<<<<

#define BI_PDATA(x)     (x)
#define BI_WB(x)        (x + 4)
#define BI_HL(x)        (x + 6)
#define OB_TYPE(x)      (tree + (x) * sizeof(OBJECT) + 6)
#define OB_SPEC(x)      (tree + (x) * sizeof(OBJECT) + 12)
#define IB_PMASK(x)     (x)
#define IB_PDATA(x)     (x + 4)
#define IB_WICON(x)     (x + 22)
#define IB_HICON(x)     (x + 24)

>>>>>>>>>>>>>>>>>>>>>>>>>>> VDI Copy Mode Table <<<<<<<<<<<<<<<<<<<<<<<<<<<<

Symbols: N = new destination pixel value (0 or 1)
         D = old destination pixel value (0 or 1)
         S = source pixel value (0 or 1)
         ~ = Boolean not (inversion)
         & = Boolean and
         | = Boolean or
         ^ = Boolean xor (exclusive-or)

Mode Number     Action
----------      ------
    0           N = 0           (USE V_BAR INSTEAD)
    1           N = S & D
    2           N = S & ~D
    3           N = S           (REPLACE)
    4           N = ~S & D      (ERASE)
    5           N = D           (USELESS)
    6           N = S ^ D       (XOR)
    7           N = S | D       (TRANSPARENT)
    8           N = ~ (S | D)
    9           N = ~ (S ^ D)
   10           N = ~D          (USE V_BAR INSTEAD)
   11           N = S | ~D
   12           N = ~S
   13           N = ~S | D      (REVERSE TRANSPARENT)
   14           N = ~ (S & D)
   15           N = 1           (USE V_BAR INSTEAD)

>>>>>>>>>>>>>>>>>>>>>>>>>>> END OF DOWNLOAD <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
