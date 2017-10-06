			for(t = 0; (t < tl) && (lb[t] != ' '); t++) 
				if ((lb[t] >= 'a') && (lb[t] <= 'z'))	/* Capitalise the command */
					lb[t] -= 'a' - 'A';

			for(t++; t < tl; t++)
			{
				if (lb[t] < ' ')			/* Strip out unwanted carriage returns, etc */
					lb[t] = '\0';
			}

			if (!strncmp(lb, "RUN ", 4))
			{			/* Run command launches a program */
				for(p = lb + 4; (*p != ' ') && (*p != '\0'); p++)
					;
				if (*p)
				{
					*p = '\0';
					p++;
				}
				sprintf(parms + 1, "%s", p);
				parms[0] = (char)strlen(parms + 1);
				
				shell_write(0, 0, 0, lb + 4, parms);
			}
			else
			if (!strncmp(lb, "CLIPBOARD ", 10)) {		/* Set the location of the default clipboard */
				sprintf(scrap_path, "%s", lb + 10);
			}
			else
			if (!strncmp(lb, "ACCPATH ", 8)) {		/* Set the location of the default clipboard */
				sprintf(acc_path, "%s", lb + 8);
			}
			else
			if (!strncmp(lb, "DC_TIME ", 8)) {		/* Set the default double click timing */
				sscanf(lb + 8, "%i", &double_click_time);
			}
			
#if GENERATE_DIAGS
			else
			if (!strncmp(lb, "DEBUG ", 6)) {			/* Redirect console output */
				if (!strncmp(lb + 6, "OFF", 3) || !strncmp(lb + 6, "off", 3))
					debugging = 0;
				else
					sprintf(debug_path, "%s", lb + 6);
			}
#endif
			else
			if (!strncmp(lb, "DIRECT ", 7)) {		/* Enable/disable direct call */
				if (!strncmp(lb + 7, "ON", 2) || !strncmp(lb + 7, "on", 2))
				{
					direct_call = 1;
					if ((lb[9] >= '1') && (lb[9] <= '9'))	/* Extra direct options (for testing) */
						direct_call = lb[9] - '0';
				} else
					direct_call = 0;
			}
			else
			if (!strncmp(lb, "FONT_ID ", 8)) {		/* Set the AES font id */
				sscanf(lb + 8, "%i", &font_id);
			}
			else
			if (!strncmp(lb, "STANDARD_POINT ", 15)) {	/* Set the standard AES font size */
				sscanf(lb + 15, "%i", &standard_font_point);
			}
			else
			if (!strncmp(lb, "MEDIUM_POINT ", 13)) {		/* Set the medium AES font size */
				sscanf(lb + 13, "%i", &medium_font_point);
			}
			else
			if (!strncmp(lb, "SMALL_POINT ", 12)) {		/* Set the small AES font size */
				sscanf(lb + 12, "%i", &small_font_point);
			}
