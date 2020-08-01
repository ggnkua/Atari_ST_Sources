/*  Button-Manager Version 1.1
    zum Erstellen und Verwalten selbstdefinierter
    Knîpfe in Resource-Dateien

    (c) 1991 by Hans-JÅrgen Richstein
        ST-Computer 2/1991

    angepaût an Mark Williams C 3.09
    durch Michael Kovar
*/

#include <vdibind.h>
#include <aesbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <stdio.h>
#include <osbind.h>
#include "button.h"

#define RASTERBREITE 16
#define RASTERHOEHE 16
#define RASTER_WORTE 16

#define COL_SET 1
#define COL_RESET 0
#define BELL 7

/* Deklarationen div. Proceduren */
void init_buttons();
void convert_tree();
int find_switch();
int draw_procedure();

extern int vdi_handle;  /* FÅr die Zeichen- und Rasteroperationen */

FDB screen_mfdb, bitmap_mfdb;

char    paten[] = "oxe";        /* drei Schalterarten */

USERBLK user_defined[] =
{
    draw_procedure, (long) (&Runder_Knopf),
    draw_procedure, (long) (&Eckiger_Knopf),
    draw_procedure, (long) (&Knick_Ecke)
};


void init_buttons(trees)
OBJECT  *trees[];
{
    register int i = 0;

    screen_mfdb.fd_addr = 0L;
    bitmap_mfdb.fd_w = RASTERBREITE;
    bitmap_mfdb.fd_h = RASTERHOEHE;
    bitmap_mfdb.fd_wdwidth = 1;
    bitmap_mfdb.fd_stand = 1;
    bitmap_mfdb.fd_nplanes = 1;

    while(trees[i])
        convert_tree(trees[i++], 0);
}

void convert_tree(tree, ob)
OBJECT  *tree;
unsigned ob;
{
    static int schalter;
    register int akt_child = tree[ob].ob_head;

    while(akt_child != ob)
    {
        if((tree[akt_child].ob_type & G_BOXCHAR) == G_BOXCHAR)
        {
            schalter=find_switch((char)(tree[akt_child].ob_spec>>24));
            if(schalter >= 0)
            {
                tree[akt_child].ob_type &= 0xff00;
                tree[akt_child].ob_type |= G_USERDEF;
                tree[akt_child].ob_spec = (long)
                        (&user_defined[schalter]);
            }
        }
        if(tree[akt_child].ob_head >= 0)
            convert_tree(tree, akt_child);

        akt_child = tree[akt_child].ob_next;
    }
}


int find_switch(pate)
int pate;
{
    register char *cur = paten;
    register int ctr = 0;


    while(*cur)
    {
        if(*cur == pate)
            return(ctr);
        cur++;
        ctr++;
    }
    return(-1);
}

int draw_procedure(pb)
PARMBLK *pb;
{
    int pxy[8], col_index[2];

    col_index[0] = COL_SET;
    col_index[1] = COL_RESET;

    pxy[0] = pb->pb_xc; pxy[1] = pb->pb_yc;
    pxy[2] = pxy[0] + pb->pb_wc - 1;
    pxy[3] = pxy[1] + pb->pb_hc - 1;

    if(pxy[2] || pxy[3])
        vs_clip(vdi_handle, 1, pxy);

    if(pb->pb_currstate & OUTLINED)
    {
        pxy[0] = pb->pb_x - 2; pxy[1] = pb->pb_y - 2;
        pxy[2] = pxy[0] + RASTERBREITE + 3;
        pxy[3] = pxy[1] + RASTERHOEHE + 3;

        vsl_color(vdi_handle, COL_SET);
        vsf_interior(vdi_handle, 1);
        vsf_perimeter(vdi_handle, 1);
        v_bar(vdi_handle, pxy);
    }

    if(pb->pb_currstate & CHECKED)
        Bconout(2, BELL);

    bitmap_mfdb.fd_addr = (long) ((pb->pb_currstate & SELECTED) ?
                ((SWITCH *) (pb->pb_parm))->on :
                ((SWITCH *) (pb->pb_parm))->off);

    pxy[0] = pxy[1] = 0;
    pxy[2] = RASTERBREITE - 1;
    pxy[3] = RASTERHOEHE - 1;

    pxy[4] = pb->pb_x; pxy[5] = pb->pb_y;
    pxy[6] = pxy[4] + RASTERBREITE - 1; /* Zielkoordinaten */
    pxy[7] = pxy[5] + RASTERHOEHE - 1;

    v_hide_c(vdi_handle); /* Maus aus */

    vrt_cpyfm(vdi_handle, MD_REPLACE, pxy, &bitmap_mfdb, &screen_mfdb,
            col_index);

    v_show_c(vdi_handle, 1);    /* Maus an */

    return(0);
}

