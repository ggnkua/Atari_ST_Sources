/* Beispielroutine zum Window-Redraw unter Verwendung von   */
/* rc_intersect und rc_grect_to_array                       */
/* Eingabeparameter:                                        */
/* handle: Window-Handle des zu zeichnenden Fensters        */
/* rec: Pointer auf neu zu zeichnenden Bildschirmausschnitt */

void wm_redraw(handle,rec)
int handle;
GRECT *rec;
{
  GRECT box;
  int pxyarray[4];

  wind_get(handle,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
  while (box.g_w||box.g_h)
    {
    if (rc_intersect(rec,&box))   /* öberlappung ermitteln */
      {
      rc_grect_to_array(&box,pxyarray);   /* ergibt Clipping-Koordinaten */
      vs_clip(g_handle,1,pxyarray);
      draw();   /* Routine zum Neuzeichnen aufrufen */
      }
    wind_get(handle,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
    }
}


/* Reaktion auf Grîûenfeld, Demonstration fÅr rc_equal */

void wm_fulled(handle)
int handle;
{
  GRECT prev;   /* vorherige Fenstergrîûe */
  GRECT curr;   /* aktuelle Fenstergrîûe */
  GRECT full;   /* maximale Fenstergrîûe */

  wind_get(handle,WF_CURRXYWH,&curr.g_x,&curr.g_y,&curr.g_w,&curr.g_h);
  wind_get(handle,WF_PREVXYWH,&prev.g_x,&prev.g_y,&prev.g_w,&prev.g_h);
  wind_get(handle,WF_FULLXYWH,&full.g_x,&full.g_y,&full.g_w,&full.g_h);
  if (rc_equal(&curr,&full))  /* ist Fenster bereits bildschirmgroû? */
    wind_set(handle,WF_CURRXYWH,prev.g_x,prev.g_y,prev.g_w,prev.g_h);
  else
    wind_set(handle,WF_CURRXYWH,full.g_x,full.g_y,full.g_w,full.g_h);
}
