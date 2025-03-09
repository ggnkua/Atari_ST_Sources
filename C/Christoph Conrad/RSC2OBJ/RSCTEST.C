/***************************************************************************
 * RSCTEST.PRG - geschrieben in Turbo-C 1.0
 *               Mai 1990 Christoph Conrad
 *
 * FUNKTION: Test einer RSC-Objectdatei Einbindung
 *           durch Anzeigen aller ObjektbÑume
 *           Der labelname auf der Kommandozeile von RSC2OBJ.TTP
 *           muss 'resource' lauten (ohne AnfÅhrungsstriche) !!!
 *
 * Benîtigte Bibliotheken: Standard/Gemlib/TOS-Lib.
 */

#include <vdi.h>
#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

typedef enum {false, true} bool;

/* Die Åblichen GEM-Variablen...*/
int contrl[12], intin[128], intout[128], ptsin[128], ptsout[128];
int work_in[12], work_out[57];
int handle, phys_handle;
int gl_hchar, gl_wchar, gl_hbox, gl_wbox;
int gl_apid;

/* Beim AES/VDI anmelden */
bool open_vwork(void)
{
    register int i;

    if((gl_apid = appl_init()) != -1)
    {   for(i = 1; i < 10; work_in[i++] = 0);
        work_in[10] = 2;
        phys_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
        work_in[0] = handle = phys_handle;
        v_opnvwk(work_in, &handle, work_out);
        return(true);
    }
    else
        return(false);
}

/* Beim VDI/AES abmelden */
void close_vwork(void)
{   v_clsvwk(handle);
    appl_exit();
}

extern RESOURCE;
/* rsc zeigt auf den Anfang der Resourcedatei, also den Resourceheader */
RSHDR *rsc = (RSHDR*) &RESOURCE;

/* Ersatz der Funktion rsrc_gaddr des AES.
 * Es werden  ObjektbÑume/Freestrings/Freeimages berÅcksichtigt.
 * Die Original-AES-Funktion liefert bei anderen Typen zum Teil
 * seltsame Ergebnisse.
 * Die Positionsoffsets im Resourceheader verweisen auf (relozierte)
 * Adresstabellen mit Zeigern auf die eigentlichen Objekte.
 * rsrc_gaddr liefert bei
 *  - ObjectbÑumen (re_gtype == 0): Die Anfangsadresse des Baums
 *  - Free-Strings/Images: Zeiger auf Zeiger auf das eigentliche Object
 */
int rsrc_gaddr(int re_gtype, int re_gindex, OBJECT **re_gaddr)
{   if(re_gtype == 0 && 0 <= re_gindex && re_gindex < rsc->rsh_ntree)
    {   *re_gaddr = *((OBJECT**)
                    (rsc->rsh_trindex + (long) rsc + 4 * re_gindex));
        return true;
    }

    if(re_gtype == 15 && 0 <= re_gindex && re_gindex < rsc->rsh_nstring)
    {   *re_gaddr = (OBJECT*)   /* eigentlich OBJECT** */
                    (rsc->rsh_frstr + (long) rsc + 4 * re_gindex);
        return true;
    }

    if(re_gtype == 16 && 0 <= re_gindex && re_gindex < rsc->rsh_nimages)
    {   *re_gaddr = (OBJECT*)   /* eigentlich OBJECT** */
                    (rsc->rsh_frimg + (long) rsc + 4 * re_gindex);
        return true;
    }

    return false;
}

/* FÅr alle Objecte wird eine Transformation von Zeichen- in
 * Pixelkoordinaten vorgenommen.
 */
void rsrc_AllFix(OBJECT *firstObj, int nrObj)
{   int obj;

    for(obj = 0; obj < nrObj; ++obj)
        rsrc_obfix(firstObj, obj);
}

bool main(void)
{
    if(open_vwork() == true)
    {   OBJECT *objTree;
        int nrObj = rsc->rsh_nobs;
        int x,y,w,h;
        int nrObjTrees = rsc->rsh_ntree;
        int actObjTree;

        graf_mouse(0,0);            /* Maus als Pfeil */

        rsrc_gaddr(0,0,&objTree);   /* Adresse des ersten Objectbaums */
        rsrc_AllFix(objTree, nrObj);/* Zeichen -> Pixelkoordinaten */

        for(actObjTree = 0; actObjTree < nrObjTrees; actObjTree++)
        {
          /* Objektbaumadresse bestimmen */
             rsrc_gaddr(0, actObjTree, &objTree);
          /* Zentrieren des Objektbaums
           * MenÅleisten sind nicht zum Zentrieren gedacht, bei
           * ihnen bleibt MÅll am oberen Bildschirmrand nach
           * dem Restaurieren mit form_dial(3,..).
           */
            form_center(objTree, &x, &y, &w, &h);

          /* Bildschirmbereich reservieren */
            form_dial(0, x, y, w, h, x, y, w, h);
          /* Objektbaum zeichnen */
            objc_draw(objTree, 0, 8, x, y, w, h);
            Crawcin();
          /* Bildschirmbereich freigeben */
            form_dial(3, x, y, w, h, x, y, w, h);
        }

        close_vwork();
        return false;
    }
    else
    {   printf("Fehler bei der Programminitialisierung!");
        return true;
    }
}
