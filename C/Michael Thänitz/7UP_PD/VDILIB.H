/*
 * VDI-Lib  V0.09
 *
 * started    : 20.02.92 (wb)
 * last change: 28.07.92 (wb)
 *
 * Versionen
 *---------------------------------------
 * 0.04  vom 23.02.92
 * 0.05  vom 27.02.92
 *       -  Handle wird nun bei v_opnvwk() Åbergeben
 * 0.06  vom 01.03.92
 *       -  vergessenes Postincrement in vs_color()
 *          hinzugefÅgt
 *       -  vst_point() liefer jetzt einen RÅckgabewert
 *       -  vergessenes Postincr. bei v_gtext() und
 *          v_ftext() hinzugefÅgt
 *       -  Lib um die Funktionen v_cellarray(), vq_cellarray(),
 *          vsc_expose() vervollstÑndigt
 * 0.07  vom 02.03.92
 *       -  Polaroid-Funktionen ergÑnzt
 * 0.08  vom 27.7.92
 *       - Stackoffsetfehler in v_bez() und v_bez_fill() beseitigt
 * 0.09  vom 28.7.92
 *       - BestÅckungsfehler bei v_bez_qual in intin[0] behoben
 *       - Falsches n_ptsin in v_bez() und v_bez_fill() behoben
 */

/****** VDIparams *******************************************************/

/* Die VDI-Arrays */
typedef struct
{
    int    contrl[15];
    int    intin[1024];
    int    ptsin[128];
    int    intout[45];
    int    ptsout[128];
} VDIPARBLK;

extern  VDIPARBLK _VDIParBlk;

/* Der VDI-Parameterblock */
typedef struct
{
   int   *contrl;
   int   *intin;
   int   *ptsin;
   int   *intout;
   int   *ptsout;
} VDIPB;

/********* zusÑtzliche Funktionen ***************************************/

/*
 * VDI-Handler
 */
void vdi( VDIPB *vdipb );

/************************************************************************/
