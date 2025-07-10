/*              RSC_LOAD.C : Zusatzmodul zur Einbindung         */
/*              von RSC-Dateien in eigene Programme.            */
/*              Version 1.2 fÅr Turbo-C Version 2.0             */
/*              Datum: 20.04.93                                 */

#include    <tos.h>     /*  wird fÅr Getrez benîtigt    */
#include    <aes.h>
#include    <portab.h>

/* #define  DRI_RCS */  /*Wenn INTERFACE benutzt wird, auskommentieren!*/
#define HIGH        2   /*  Returnwert von Getrez fÅr hohe Aufl.*/
#define EXTERN   extern

extern int contrl[12], intin[128], intout[128], ptsin[128], ptsout[128];
extern int work_in[12], work_out[57];

/************************************************************************/

#include    "galshell.rh"    /*  .RH Datei des Recources     */
#include    "galshell.rsh"   /*  Quellfile des Recources     */

/************************************************************************/

int rsrc_load(Rscfile)
    const char    *Rscfile;   /*  Der Ordnung halber  */
{
    int     dx, dy, Obj;
    OBJECT  **GEM_rsc;
    
    GEM_rsc = (OBJECT**) &(_GemParBlk.global[5]);
    *GEM_rsc= (OBJECT*)  &rs_trindex[0];
    
    dx  = dy    = 3;

    if ( work_out[1] >= 399)   dy=4;
    
/*  Do Objects  */

    for (Obj = 0; Obj < NUM_OBS; Obj++)
        {
        rs_object[Obj].ob_x = ((rs_object[Obj].ob_x & 0x00ff) << dx) +
                               (rs_object[Obj].ob_x >> 8);

        rs_object[Obj].ob_y = ((rs_object[Obj].ob_y & 0x00ff) << dy) +
                               (rs_object[Obj].ob_y >> 8);

        rs_object[Obj].ob_width  = ((rs_object[Obj].ob_width & 0x00ff) << dx) +
                                    (rs_object[Obj].ob_width >> 8);

        rs_object[Obj].ob_height = ((rs_object[Obj].ob_height & 0x00ff) << dy)+
                                    (rs_object[Obj].ob_height >> 8);

#ifdef DRI_RCS
        switch(rs_object[Obj].ob_type)
            {
            case    G_FTEXT     :
            case    G_BOXTEXT   :
            case    G_FBOXTEXT  :
            case    G_TEXT      :
                {
                rs_object[Obj].ob_spec.index = (long) &rs_tedinfo[(int)
                                                rs_object[Obj].ob_spec.index];
                break;
                }
            case    G_BUTTON    :
            case    G_TITLE     :
            case    G_STRING    :
                {
                rs_object[Obj].ob_spec.index = (long) rs_strings[(int)
                                                rs_object[Obj].ob_spec.index];
                break;
                }

            case    G_ICON      :
                {
                rs_object[Obj].ob_spec.index = (long) 
                         (&rs_iconblk[(int) rs_object[Obj].ob_spec.index]);
                break;
                }

            case    G_IMAGE     :
                {
                rs_object[Obj].ob_spec.index = (long) 
                         (&rs_bitblk[(int)rs_object[Obj].ob_spec.index]);
                break;
                }

            }
#endif /* DRI_RCS */
        }

#ifdef DRI_RCS
/*  Do Textinfos    */
    for(Obj = 0; Obj < NUM_TI; Obj++)
        {
        rs_tedinfo[Obj].te_ptext    = rs_strings[(int) 
                                                rs_tedinfo[Obj].te_ptext];
        rs_tedinfo[Obj].te_ptmplt   = rs_strings[(int) 
                                                rs_tedinfo[Obj].te_ptmplt];
        rs_tedinfo[Obj].te_pvalid   = rs_strings[(int) 
                                                rs_tedinfo[Obj].te_pvalid];
        }

/*  Do IconBlocks   */
    for(Obj = 0; Obj < NUM_IB; Obj++)
        {
        rs_iconblk[Obj].ib_pmask    = rs_imdope[(int)
                                          rs_iconblk[Obj].ib_pmask].image;
        rs_iconblk[Obj].ib_pdata    = rs_imdope[(int)
                                          rs_iconblk[Obj].ib_pdata].image;
        rs_iconblk[Obj].ib_ptext    = rs_strings[(int) 
                                                rs_iconblk[Obj].ib_ptext];
        }

/*  Do BitImages   */
    for(Obj = 0; Obj < NUM_BB; Obj++)
        {
        rs_bitblk[Obj].bi_pdata    = rs_imdope[(int)
                                          rs_bitblk[Obj].bi_pdata].image;
        }

/*  Do FreeStrings  */
    for(Obj = 0; Obj < NUM_FRSTR; Obj++)
        {
        rs_frstr[Obj] = (long) rs_strings[(int) rs_frstr[Obj]];
        }
        
/*  Do FreeImages   */
    for(Obj = 0; Obj < NUM_FRIMG; Obj++)
        {
        rs_frimg[Obj] = (long) &rs_bitblk[(int) rs_frimg[Obj]];
        }
        
/*  Do TreeIndex    */
    for(Obj = 0; Obj < NUM_TREE; Obj++)
        {
        rs_trindex[Obj] = (long) &rs_object[(int) rs_trindex[Obj]];
        }

#endif /* DRI_RCS */        
    return(1);  /*  Kein Fehler, woher auch ;-) */
}
