/*------------------------------------------------------------------*/
/* TEAROFF.C                                                        */
/*                                                                  */
/* Routinen zur Verwaltung von Tear-Off-MenÅs                       */
/* (c)1995 by MAXON-Computer                                        */
/* Autor: Uwe Hax                                                   */
/*------------------------------------------------------------------*/

#include <portab.h>
#include <aes.h>
#include <linea.h>
#include <stdlib.h>
#include <vdi.h>
#include <string.h>

#include "prototyp.h"
#include "typedef.h"

#include "tearoff.h"
#include "tearoff.rsh"

#define NUM_OBS   29

/*------------------------------------------------------------------*/
/* globale Variablen                                                */
/*------------------------------------------------------------------*/

WORD (*_m_oldvec) (VOID);

OBJECT *menu;
WORD tear_menu = NIL;
WORD tear_title = NIL;
WORD tear_msg = FALSE;
WORD vdi_handle;
WORD aes_version;

TEAROFF tearoff[MAX_TEAROFF] = { 0 };



/*------------------------------------------------------------------*/
/* Haupt-Routine des Demo-Programms                                 */
/*------------------------------------------------------------------*/

VOID main (VOID)
{
  WORD dummy, i;
  WORD work_in[10], work_out[57];
  WORD events, mx, my, mbutton, clicks;
  WORD msg_buff[8];
  WORD end = FALSE;

  /*
   * Initialisierung
   */
             
  if (appl_init() < 0)
    exit(1);

  aes_version = _GemParBlk.global[0];
  
  linea_init();
  
  vdi_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);
  
  for (i = 0; i < 10; i++)
    work_in[i] = 1;
  work_in[10] = 2;
  v_opnvwk(work_in, &vdi_handle, work_out);

  vex_butv(vdi_handle, _m_newvec, &_m_oldvec);
 
  for (i = 0; i < NUM_OBS; i++)
    rsrc_obfix(rs_object, i);

  menu = rs_trindex[MENU];
  
  menu_bar(menu, TRUE);

  graf_mouse(ARROW, 0L);
  
  /*
   * Haupt-Event-Schleife
   */
   
  do
  {
    events = evnt_multi(MU_MESAG | MU_BUTTON | MU_TIMER, 1, LEFT_BUTTON, 1,
                                        0,0,0,0,0, 0,0,0,0,0, msg_buff, 100,0,
                                        &mx, &my, &mbutton, &dummy, &dummy, &clicks);

    wind_update(BEG_UPDATE);
   
    /*
     * RegelmÑûig abfragen, ob ein MenÅ abgerissen wurde.
     */
      
    if (events & MU_TIMER)
      if (tear_menu != NIL)
        tear_off();

    /*
     * Messages auswerten
     */
     
    if (events & MU_MESAG)
      if (msg_buff[0] == MN_SELECTED)
        end = do_menu(msg_buff);
      else
        end = do_window(msg_buff);

    /*
     * Mausklicks auswerten.
     */
         
    if (events & MU_BUTTON)
      end = do_tearoff(mx, my);
    
    wind_update(END_UPDATE);
  }
  while (!end);

  /*
   * Alle Tear-Off-MenÅs schlieûen.
   */
   
  for (i = 0; i < MAX_TEAROFF; i++)
    if (tearoff[i].whandle > 0)
      close_window(tearoff[i].whandle);
  
  /*
   * Und den ganzen Rest abmelden.
   */
   
  menu_bar(menu, FALSE);
  appl_exit();

  vex_butv(vdi_handle, _m_oldvec, &_m_oldvec);
  v_clsvwk(vdi_handle);
  
  exit(0);
} /* main */


/*------------------------------------------------------------------*/
/* Feststellen, ob sich der Mauszeiger in einem MenÅ befindet.      */
/*------------------------------------------------------------------*/

VOID mouse_in_menu (VOID)
{
  WORD title, parent, menubox, item;
  WORD xbox, ybox;
  GRECT box, itembox;
  WORD first;
  
  /*
   * Indizes und Koordinaten ermitteln.
   */
   
  title = menu[ROOT].ob_head;
  title = parent = menu[title].ob_head;
  first = title = menu[title].ob_head;

  xbox = menu[ROOT].ob_x;
  ybox = menu[ROOT].ob_y;
  menubox = menu[ROOT].ob_tail;

  xbox += menu[menubox].ob_x;
  ybox += menu[menubox].ob_y;
  menubox = menu[menubox].ob_head;

  /*
   * Schleife Åber alle MenÅtitel, ob ein Titel selektiert, d.h.
   * das MenÅ ausgeklappt ist.
   */
   
  while (title != parent)
  {
    if (menu[title].ob_state & SELECTED)
    {
      /*
       * Koordinaten des ausgeklappten MenÅs berechnen.
       */
       
      box.g_x = xbox + menu[menubox].ob_x;
      box.g_y = ybox + menu[menubox].ob_y;
      box.g_w = menu[menubox].ob_width;

      if (title == first)
        box.g_h = menu[menu[menubox].ob_head].ob_height;
      else
        box.g_h = menu[menubox].ob_height;

      if (rc_inside(&box, Vdiesc->cur_x, Vdiesc->cur_y))
      {
        tear_menu = menubox;
        tear_title = title;

        /*
         * Feststellen, ob der angeklickte MenÅ-Eintrag disabled ist.
         * Wenn nein, muû die erzeugte MN_SELECTED-Meldung spÑter 
         * abgefangen werden.
         */
                
        item = menu[menubox].ob_head;
        do
        {
          itembox.g_x = box.g_x + menu[item].ob_x;
          itembox.g_y = box.g_y + menu[item].ob_y;
          itembox.g_w = menu[item].ob_width;
          itembox.g_h = menu[item].ob_height;

          if (rc_inside(&itembox, Vdiesc->cur_x, Vdiesc->cur_y))
            if (!(menu[item].ob_state & DISABLED))
            {
              tear_msg = TRUE;
              break;
            } /* if */
          item = menu[item].ob_next;
        }
        while (item != menubox);
        return;
      } /* if */
    } /* if */
    
    title = menu[title].ob_next;
    menubox = menu[menubox].ob_next;
  } /* while */
} /* mouse_in_menu */



/*------------------------------------------------------------------*/
/* Mausklick in ein Tear-Off-MenÅ bearbeiten.                       */
/*------------------------------------------------------------------*/

WORD do_tearoff (WORD mx, WORD my)
{
  WORD whandle;
  WORD i, object;
  WORD end = FALSE;
  WORD dummy;
  GRECT clip;
  OBJECT *tree;
  BYTE *string;

  /*
   * Fenster an Mausposition ermitteln.
   */
     
  whandle = wind_find(mx, my);
  if (whandle != DESKTOP)
  {
    /*
     * Tear-Off-MenÅ an Mausposition ermitteln.
     */
     
    for (i = 0; i < MAX_TEAROFF; i++)
      if (tearoff[i].whandle == whandle)
      {
        /*
         * Objekt an Mausposition ermitteln.
         */
         
        tree = tearoff[i].tree;
        object = objc_find(tree, ROOT, MAX_DEPTH, mx, my);
        if (object != NIL)
          if (!(tree[object].ob_state & DISABLED))
          { 
            /*
             * AngewÑhltes Objekt selektieren.
             */
             
            objc_offset(tree, object, &clip.g_x, &clip.g_y);
            clip.g_w = tree[object].ob_width;
            clip.g_h = tree[object].ob_height;
          
            tree[object].ob_state = SELECTED;
           
            redraw_window(whandle, &clip);
            if (tree[object].ob_type == G_STRING)
            {
              /*
               * Dem MenÅ-Eintrag zuordnete Funktion ausfÅhren.
               */
               
              string = tree[object].ob_spec.free_string;
              if (!strncmp(string, "  Ende", 6))
                end = TRUE;
              else if (!strncmp(string, "  Programminfo...", 17)) 
                do_about();
              else
                form_alert(1, NOT_IMPLEMENTED);
            } /* if */
            
            /*
             * Nach Loslassen des Mausbuttons den Eintrag wieder
             * deselektieren.
             */
             
            evnt_timer(100, 0);
            evnt_button(1, LEFT_BUTTON, 0, &dummy, &dummy, &dummy, &dummy);
          
            tree[object].ob_state = NORMAL;
            redraw_window(whandle, &clip);
          } /* if */
       
        break;
      } /* if */
  } /* if */
  
  return (end);
} /* do_tearoff */



/*------------------------------------------------------------------*/
/* MN_SELECTED-Meldung bearbeiten.                                  */
/*------------------------------------------------------------------*/

WORD do_menu (WORD *msg_buff)
{
  WORD end = FALSE;
    
  if (tear_msg)
  {
    /*
     * Falls ein MenÅ abgerissen wurde, nur den MenÅ-Titel
     * wieder deselektieren.
     */
     
    if (menu[msg_buff[3]].ob_state & SELECTED)
      menu_tnormal(menu, msg_buff[3], TRUE);
    tear_msg = FALSE;
  }
  else
  {
    /*
     * Meldung auswerten.
     */
     
    switch (msg_buff[4])
    {
      case ABOUT:
        do_about();
        break;
        
      case QUIT:
        end = TRUE;
        break;
        
      default:
        form_alert(1, NOT_IMPLEMENTED);
        break;
     } /* switch */
     
     menu_tnormal(menu, msg_buff[3], TRUE);
  } /* else */

  return (end);
} /* do_menu */



/*------------------------------------------------------------------*/
/* MenÅ in Tear-Off-MenÅ umwandeln.                                 */
/*------------------------------------------------------------------*/

VOID tear_off (VOID)
{
  GRECT size, desk;
  WORD mx, my, mstate, mbutton, dummy;
  WORD pxyarray[4], deskarray[4];
  WORD diffx, diffy;
  WORD events, msg_buff[8];
  WORD count, next, i, whandle, found;
  OBJECT *tree;
  BYTE title[20];
  WORD first, condition, clicks;
      
  /*
   * Sicherheitsabfrage
   */
   
  if ((tear_menu == NIL) || (tear_title == NIL))
    return;
   
  /*
   * Falls der MenÅtitel invertiert ist, wiederherstellen.
   */
   
  if (menu[tear_title].ob_state & SELECTED)
    menu_tnormal(menu, tear_title, TRUE);
  
  /*
   * Index des ersten MenÅtitels ermitteln.
   */  
   
  first = menu[ROOT].ob_head;
  first = menu[first].ob_head;
  first = menu[first].ob_head;
  
  /*
   * Grîûe des zu zeichnenden Rechtecks ermitteln.
   */
   
  objc_offset(menu, tear_menu, &size.g_x, &size.g_y);
  size.g_w = menu[tear_menu].ob_width;
  if (first == tear_title)
    size.g_h = menu[menu[tear_menu].ob_head].ob_height;
  else
    size.g_h = menu[tear_menu].ob_height;
  
  /*
   * Rechteck zeichnen und verschieben.
   * graf_dragbox() ist nicht einsetzbar, da diese Funktion nur
   * mit der linken Maustaste arbeitet.
   */
   
  wind_get(DESKTOP, WF_WORKXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h);
  
  wind_update(BEG_MCTRL);  
  
  graf_mkstate(&mx, &my, &mstate, &dummy);
  pxyarray[0] = size.g_x;
  pxyarray[1] = size.g_y;
  pxyarray[2] = size.g_x + size.g_w - 1;
  pxyarray[3] = size.g_y + size.g_h - 1;
  
  diffx = mx - size.g_x;
  diffy = my - size.g_y;

  /*
   * Je nach AES-Version andere Bedienung.
   */
   
  if (aes_version < 0x410)
  {  
    condition = mstate & RIGHT_BUTTON;
    clicks = 1;
  }
  else
  {
    condition = !mstate;
    clicks = 256 | 1;
  } /* else */
  
  if (condition)
  {
    /*
     * ersten Rahmen zeichnen
     */
     
    deskarray[0] = desk.g_x;
    deskarray[1] = desk.g_y;
    deskarray[2] = desk.g_x + desk.g_w - 1;
    deskarray[3] = desk.g_y + desk.g_h - 1;
    
    vs_clip(vdi_handle, TRUE, deskarray);
    
    vswr_mode(vdi_handle, MD_XOR);
    vsf_interior(vdi_handle, FIS_HOLLOW);
    vsf_style(vdi_handle, 0);
    vsf_color(vdi_handle, BLACK);
    vsf_perimeter(vdi_handle, TRUE);
  
    v_hide_c(vdi_handle);
    v_bar(vdi_handle, pxyarray);
    v_show_c(vdi_handle, TRUE);
    
    do
    {
      events = evnt_multi(MU_M1 | MU_BUTTON, clicks, LEFT_BUTTON | RIGHT_BUTTON, 
                                          0, 1, mx, my, 1, 1, 0,0,0,0,0, msg_buff, 0,0,
                          &mx, &my, &mbutton, &dummy, &dummy, &dummy);

      /*
       * Sonderbehandlung ab AES 4.1:
       * Loslassen der Maustaste ignorieren (wird hier noch aus
       * der MenÅbehandlung gemeldet)
       */
       
      if (events & MU_BUTTON)
        if ((aes_version >= 0x410) && (mbutton == 0))
          events &= ~MU_BUTTON;
          
      /*
       * Bei Mausbewegung neuen Rahmen zeichnen.
       */
       
      if (events & MU_M1)
      {
        v_hide_c(vdi_handle);
        v_bar(vdi_handle, pxyarray);
        v_show_c(vdi_handle, TRUE);
        
        pxyarray[0] = mx - diffx;
        pxyarray[1] = my - diffy;
        pxyarray[2] = pxyarray[0] + size.g_w;
        pxyarray[3] = pxyarray[1] + size.g_h;
        
        v_hide_c(vdi_handle);
        v_bar(vdi_handle, pxyarray);
        v_show_c(vdi_handle, TRUE);
      } /* if */
    }
    while (!(events & MU_BUTTON));
  
    /*
     * letzten Rahmen lîschen
     */
     
    v_hide_c(vdi_handle);
    v_bar(vdi_handle, pxyarray);
    v_show_c(vdi_handle, TRUE);
  } /* if */
  
  wind_update(END_MCTRL); 
  
  /*
   * Neuen Objektbaum erstellen.
   * 1. Anzahl der Objekte ermitteln.
   */

  count = objc_childs(menu, tear_menu) + 1;
  tree = malloc((LONG)count * sizeof(OBJECT));
  if (tree == NULL)
  {
    form_alert(1, NO_MEMORY);
    return;
  } /* if */
  
  /*
   * Objekte kopieren
   */
   
  tree[ROOT] = menu[tear_menu];
  tree[ROOT].ob_next = NIL;
  tree[ROOT].ob_head = 1;
  tree[ROOT].ob_x = 0;
  tree[ROOT].ob_y = 0;
  
  next = menu[tear_menu].ob_head;
  i = 1;
  do
  {
    /* 
     * Objekt kopieren
     */
     
    tree[i] = menu[next];
    
    /*
     * Verkettung anpassen
     * Kind-Objekte werden hier nicht mit Åbernommen, da in MenÅzeilen
     * normalerweise keine verschachtelten Objekte vorhanden sind.
     */
     
    tree[i].ob_head = NIL;
    tree[i].ob_tail = NIL;
    tree[i].ob_next = i + 1;
    
    i++;
    next = menu[next].ob_next;
  }
  while ((next != tear_menu) && (first != tear_title));
  
  i--;
  tree[i].ob_next = ROOT;
  tree[ROOT].ob_tail = i;
  
  /*
   * Sonderbehandlung fÅr Desk-MenÅ
   */
   
  if (first == tear_title)
    tree[ROOT].ob_height = tree[tree[ROOT].ob_head].ob_height;
  
  /*
   * Fenstergrîûe berechnen und Fenster erzeugen.
   */
   
  wind_calc(WC_BORDER, NAME | MOVER | CLOSER, pxyarray[0], pxyarray[1],
              size.g_w, size.g_h, &size.g_x, &size.g_y, &size.g_w, &size.g_h);
  if (size.g_y < desk.g_y)
    size.g_y = desk.g_y;

  whandle = wind_create(CLOSER | NAME | MOVER, size.g_x, size.g_y, 
                                                size.g_w, size.g_h);
  if (whandle <= 0)
  {
    free(tree);
    form_alert(1, NO_WINDOW);
    tear_menu = NIL;
    tear_title = NIL;
    return;
  } /* if */
  
  /*
   * Fenstertitel festlegen.
   */
   
  title[0] = EOS;
  if (menu[tear_title].ob_spec.free_string[0] != ' ')
    strcpy(title, " ");
  strcat(title, menu[tear_title].ob_spec.free_string);
  if (title[strlen(title) - 1] != ' ')
    strcat(title, " ");
    
  tear_menu = NIL;
  tear_title = NIL;

  /*
   * Verwaltungsinformationen anlegen.
   */
   
  found = FALSE;
  for (i = 0; i < MAX_TEAROFF; i++)
    if (tearoff[i].whandle <= 0)
    {
      tearoff[i].whandle = whandle;
      tearoff[i].tree = tree;
      strcpy(tearoff[i].title, title);

      wind_set(whandle, WF_NAME, tearoff[i].title);
      wind_set(whandle, WF_BEVENT, 1, 0, 0, 0);
      
      found = TRUE;
      break;
    } /* if */
    
  if (!found)
  {
    form_alert(1, NO_WINDOW);
    wind_delete(whandle);
    free(tree);
    return;
  } /* if */
   
  /*
   * Fenster îffnen.
   */
    
  wind_open(whandle, size.g_x, size.g_y, size.g_w, size.g_h);
  wind_get(whandle, WF_WORKXYWH, &tree[ROOT].ob_x, &tree[ROOT].ob_y,
                        &dummy, &dummy);
} /* tear_off */


/*------------------------------------------------------------------*/
/* Feststellen, wieviele Kinder ein Objekt besitzt.                 */
/*------------------------------------------------------------------*/

WORD objc_childs (OBJECT *tree, WORD object)
{
  WORD next = object;
  WORD count = 0;
  
  next = tree[object].ob_head;
  if (next == NIL)
    return (0);
    
  do
  {
    count++;
    if (tree[next].ob_head != NIL)
      count += objc_childs(tree, next);
    next = tree[next].ob_next;
  }
  while (next != object);
  
  return (count);
} /* objc_childs */



/*------------------------------------------------------------------*/
/* About-Dialog darstellen.                                         */
/*------------------------------------------------------------------*/

VOID do_about (VOID)
{
  OBJECT *dialog;
  WORD x,y,w,h;

  dialog = rs_trindex[DIALOG];  
  form_center(dialog, &x, &y, &w, &h);
  form_dial(FMD_START, x,y,w,h,x,y,w,h);
  objc_draw(dialog, ROOT, MAX_DEPTH, x,y,w,h);
  form_do(dialog, 0);
  form_dial(FMD_FINISH, x,y,w,h,x,y,w,h);
  dialog[OK].ob_state = NORMAL;
} /* do_about */
