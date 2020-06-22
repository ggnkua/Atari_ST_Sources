#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <aes.h>
#include <view.h>

#define WAIT_TIMER	10000




int				 appl_id, menu_id, wi_id = 0,
				 msg[8], ToAccApp = 0;
long             tmp_count = 0;


/* ----- Cookie Jar -------------------------------------------------------- */

typedef struct
{
	long	id,
			*ptr;
} COOKJAR;




void MessageSend(int sendto, int msg0, char *msg3, int msg5, int msg6, int msg7)
{
  int     msg[8];
  
  msg[0] = msg0;
  msg[1] = appl_id;
  msg[2] = 0;
  *(char**)&msg[3] = msg3; /* ACHTUNG: Unter 'MiNT' GLOBAL reservieren! */
  msg[5] = msg5;
  msg[6] = msg6;
  msg[7] = msg7;
  appl_write(sendto, 16, msg);
}



long *get_cookie(long cookie)
{
	long	sav;
	COOKJAR	*cookiejar;
	int	    i = 0;

	sav = Super((void *)1L);
	if(sav == 0L)
		sav = Super(0L);
	cookiejar = *((COOKJAR **)0x05a0L);
	if(sav != -1L)
		Super((void *)sav);
	if(cookiejar)
	{
		while(cookiejar[i].id)
		{
			if(cookiejar[i].id == cookie)
				return(cookiejar[i].ptr);
			i++;
		}
	}
	return(0L);
}



void getfile(char **input, long *length)
{
	char	path[220];
	char	file[20], *s;
	int     ret, ex;
	
	*input = NULL;
	*length = 0;
	path[0] = '\0';
	file[0] = '\0';
	ret = fsel_input(path, file, &ex);
	if (ret == 0 || ex == 0)
		return;
	
	s = strrchr(path, '\\');
	if (s == NULL)
		return;
	
	strcpy(s+1, file);
	
	*length = strlen(path) + 1;
	*input = malloc(*length + 10L);
	if (*input == NULL) {
		return;
	}
	strcpy(*input, path);
}




MessageWait(int *msg, int wait)
{
	int		event, dummy;
  
	msg[0] = 0;
	event = evnt_multi(MU_MESAG|MU_TIMER, 0, 0, 0,
						0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						msg, wait, 0, &dummy, &dummy,
						&dummy, &dummy, &dummy, &dummy);
	if (event & MU_MESAG) {
		if ((msg[0] & 0xFF00) == VIEW_FILE)
			return(1);
		if (msg[0] == AC_OPEN)
			return(0);
		if (msg[0] == AC_CLOSE)
			return(0);
	}
	if (!(event & MU_MESAG))
		tmp_count++;
	
	return(0);
}

void main(void)
{
	char   *input;
	long    length;
	
	tmp_count = 0;
	appl_id = appl_init();
	menu_register(appl_id, "  Send View!");
	input = (char*)get_cookie('View');
	if (input != NULL)
		ToAccApp = appl_find(input);
	msg[0] = 0;
	while(1)
	{
		if (msg[0] == 0)
			evnt_mesag(msg);
		switch(msg[0])
		{
			case AC_OPEN:
				if (wi_id == 0) {
					/* Neuladen! */
					getfile(&input, &length);
					if (input == NULL)
					{
						msg[0] = 0;
						break;
					}
					input[length] = '\0';
					/* Neues File anzeigen lassen */
					MessageSend(ToAccApp, VIEW_FILE, input, 0, 0, 0);
					wi_id = 0;
					if (MessageWait(msg, WAIT_TIMER) == 0) {
						free(input);
						break;
					}
					free(input);
					if (msg[0] == VIEW_OPEN)
						wi_id = msg[7];
				} else {
					/* Ersetzen oder L”schen! */
					if (form_alert(0, "[0][ | Send View! | ][ Replace | Delete ]") == 1) {
						/* Ersetzen! */
						getfile(&input, &length);
						if (input == NULL)
						{
							msg[0] = 0;
							break;
						}
						input[length] = '\0';
						/* Altes File durch neues File ersetzen */
						MessageSend(ToAccApp, VIEW_FILE, input, 0, 0, wi_id);
						wi_id = 0;
						if (MessageWait(msg, WAIT_TIMER) == 0) {
							free(input);
							break;
						}
						free(input);
					
						if (msg[0] == VIEW_CLOSED || msg[0] == VIEW_OPEN) {
							if (msg[0] == VIEW_CLOSED)
								if (MessageWait(msg, WAIT_TIMER) == 0)
									break;
							if (msg[0] == VIEW_OPEN)
								wi_id = msg[7];
						}
					} else {
						/* Fenster schliežen */
						MessageSend(ToAccApp, VIEW_FILE, NULL, 0, 0, wi_id);
						wi_id = 0;
						if (MessageWait(msg, WAIT_TIMER) == 0)
							break;
						wi_id = 0;
					}
				}
				msg[0] = 0;
				break;

			case AC_CLOSE:
				wi_id = 0;
				msg[0] = 0;
				break;
			
			case VIEW_OPEN:
				wi_id = msg[7];
				msg[0] = 0;
				break;
			
			case VIEW_CLOSED:
				wi_id = 0;
				msg[0] = 0;
				break;
			
			default:
				msg[0] = 0;
		}
	}
}
