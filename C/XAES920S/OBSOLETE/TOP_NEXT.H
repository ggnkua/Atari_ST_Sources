/* HR: top the first window that isnt already on top */
void top_next_window(LOCK lock)
{
	XA_WINDOW *w;

	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);

	DIAG((D.wind, w->pid, "top_next_window\n"));
	if (window_list)		/* HR: needed when closing down */
	{	
		w = window_list->next;
		while(w)
		{
			if (w != root_window && w->is_open)
			{
				top_window(lock|winlist, w, menu_owner());		/* HR */
				break;
			}
			w = w->next;
		}
	}
	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);
}
