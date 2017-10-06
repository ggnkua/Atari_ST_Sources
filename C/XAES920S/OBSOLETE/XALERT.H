/* HR: rejected alert parser */

	for(ty = 0; ty < 5; ty++)
		alert_text[ty][0] = '\0';

	if (alert[0] != '[')
		return 0;
	t = alert + 1;
	for(f = 1; (t[f] != ']') && (t[f] != '\0'); f++)	/* Search for closing bracket on first field */
		;
	if (t[f] != ']')
		return 0;

/* HR: Ok, I know nobody is perfect, but only a few are this stupid. 
			Corrupting a user's alert string.
*/
	t[f] = '\0';

	icon = atoi(t);				/* Calculate the icon */
	
	t += f + 1;
	if (t[0] != '[')
		return 0;
	
	t++;
	for(f = 0; (t[f] != ']') && (t[f] != '\0'); f++)
	{		/* Strip out the text lines */
		if (t[f] == '|')
		{
			t[f] = '\0';
			vqt_extent(V_handle, t, pnt);
			w = pnt[2] - pnt[0];
			th = pnt[7] - pnt[1];
			h += th;
			if (w > max_w)
				max_w = w;
			sprintf(alert_text[n_lines], "%s", t);
			n_lines++;
			t += f + 1;
			f = 0;
		}
	}
	if (t[f] != ']')
		return 0;
	t[f] = '\0';
	vqt_extent(V_handle, t, pnt);
	w = pnt[2] - pnt[0];
	th = pnt[7] - pnt[1];
	h += th;
	if (w > max_w)
		max_w = w;
	sprintf(alert_text[n_lines], "%s", t);
	n_lines++;

	t += f + 1;
	if (t[0] != '[')
		return 0;
	t++;

	for(f = 0; (t[f] != ']') && (t[f] != '\0'); f++)
	{		/* Strip out the text lines */
		if (t[f] == '|')
		{
			t[f] = '\0';
			vqt_extent(V_handle, t, pnt);
			button_w[n_buttons] = pnt[2] - pnt[0] + 3 * display.c_max_w;
			m_butt_w += button_w[n_buttons];
			sprintf(button_text[n_buttons], "%s", t);
			n_buttons++;
			t += f + 1;
			f = 0;
		}
	}
	if (t[f] != ']')
		return 0;
	t[f] = '\0';
	vqt_extent(V_handle, t, pnt);
	button_w[n_buttons] = pnt[2] - pnt[0] + 3 * display.c_max_w;
	m_butt_w += button_w[n_buttons];
	sprintf(button_text[n_buttons], "%s", t);
	n_buttons++;
	
	if (m_butt_w > max_w)
		max_w = m_butt_w;
	
