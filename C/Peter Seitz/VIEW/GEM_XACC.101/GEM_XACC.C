#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <aes.h>
#include "xacc.h"

#define WAIT_TIMER	10000
#define  XNAME       "Test-xAcc\0XDSC\0"\
                     "1xAcc-TEST-Accessory\0\0"




int				 appl_id, menu_id,
				 msg[8], ToAccApp = 0;
long             tmp_count = 0;
static char		*XAccName = XNAME;


/* ----- Cookie Jar -------------------------------------------------------- */

typedef struct
{
	long	id,
			*ptr;
} COOKJAR;




void XAccSend(int sendto, int msg0, int msg3, char *msg4, int msg6, int msg7)
{
  int     msg[8];
  
  msg[0] = msg0;
  msg[1] = appl_id;
  msg[2] = 0;
  msg[3] = msg3;
  *(char**)&msg[4] = msg4;
  msg[6] = msg6;
  msg[7] = msg7;
  appl_write(sendto, 16, msg);
}



void XAccSendId(int sendto)
{
  XAccSend(sendto, ACC_ID, 0x0103, XAccName, menu_id, -1);
}



void XAccSendAck(int sendto, int answer)
{
  XAccSend(sendto, ACC_ACK, answer, NULL, -1, -1);
}



void XAccSendAccClose(void)
{
  if (!_app && !(_GemParBlk.global[0] >= 0x0400 && _GemParBlk.global[1] == -1))
    XAccSendId(ToAccApp);
}



void XAccSendStartup(void)
{
  int     next, type, id;
  char    name[10], *buf;
  
  if (_GemParBlk.global[0] >= 0x0400 && get_cookie('MiNT') != NULL) {
    buf = Mxalloc(sizeof(XNAME), 0x0022);
    if (buf != NULL)
      memcpy(buf, XAccName, sizeof(XNAME));
    XAccName = buf;
    next = 0;
    while (appl_search(next, name, &type, &id)) {
      if (type & 0x06)
        XAccSendId(id);
      next = 1;
    }
  } else {
    if (!_app)
      XAccSendAccClose();
  }
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
	int     ret, ex, fh;
	
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
	fh = (int)Fopen(path, FO_READ);
	if (fh < 0)
		return;
	
	*length = Fseek(0L, fh, SEEK_END);
	Fseek(0L, fh, SEEK_SET);
	*input = malloc(*length + 10L);
	if (*input == NULL) {
		Fclose(fh);
		return;
	}
	
	memset(*input, '\0', *length + 10L);
	Fread(fh, *length, *input);
	Fclose(fh);
}




XAccWait(int *msg, int wait)
{
	int		event, dummy;
  
	msg[0] = 0;
	event = evnt_multi(MU_MESAG|MU_TIMER, 0, 0, 0,
						0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
						msg, wait, 0, &dummy, &dummy,
						&dummy, &dummy, &dummy, &dummy);
	if (event & MU_MESAG) {
		if (msg[0] == 0x0500 && msg[3] == 1)
			return(1);
		if (msg[0] == AC_OPEN)
			return(0);
		if (msg[0] == AC_CLOSE)
			return(0);
		if (msg[0] == ACC_TEXT)
			return(0);
		if (msg[0] == ACC_IMG)
			return(0);
		if (msg[0] == ACC_META)
			return(0);
	}
	if (!(event & MU_MESAG))
		tmp_count++;
	
	return(0);
}

void main(void)
{
	char   *input, *mem;
	char    file[30];
	int     fd;
	long    length;
	
	tmp_count = 0;
	appl_id = appl_init();
	menu_register(appl_id, "  Send xAcc!");
	XAccSendStartup();
	msg[0] = 0;
	while(1)
	{
		if (msg[0] == 0)
			evnt_mesag(msg);
		switch(msg[0])
		{
			case AC_OPEN:
				msg[0] = 0;
				switch(form_alert(0, "[0][ | Send xACC! | ][ Text | IMG | Meta ]"))
				{
					case 1:
						getfile(&input, &length);
						if (input == NULL)
						{
							msg[0] = 0;
							break;
						}
						input[length] = '\0';
						/* L„nge ist bei Textfile eigentlich unn”tig! */
						XAccSend(ToAccApp, ACC_TEXT, 1, input, (int)(length>>16), (int)(length & 0xFFFFL));
						XAccWait(msg, WAIT_TIMER);
						free(input);
						msg[0] = 0;
						break;
					case 2:
						getfile(&input, &length);
						if (input == NULL)
						{
							msg[0] = 0;
							break;
						}
						mem = input;
						while(length > 4096)
						{
							XAccSend(ToAccApp, ACC_IMG, 0, input, 0, 4096);
							if (XAccWait(msg, WAIT_TIMER) <= 0)
								goto skip2;
							input += 4096;
							length -= 4096;
						}
						XAccSend(ToAccApp, ACC_IMG, 1, input, 0, (int)length);
						XAccWait(msg, WAIT_TIMER);
skip2:
						free(mem);
						msg[0] = 0;
						break;
					case 3:
						getfile(&input, &length);
						if (input == NULL)
						{
							msg[0] = 0;
							break;
						}
						mem = input;
						while(length > 4096)
						{
							XAccSend(ToAccApp, ACC_META, 0, input, 0, 4096);
							if (XAccWait(msg, WAIT_TIMER) <= 0)
								goto skip3;
							input += 4096;
							length -= 4096;
						}
						XAccSend(ToAccApp, ACC_META, 1, input, 0, (int)length);
						XAccWait(msg, WAIT_TIMER);
skip3:
						free(mem);
						msg[0] = 0;
						break;
				}
				msg[0] = 0;
				break;
			
			case AC_CLOSE:
				XAccSendAccClose();
				msg[0] = 0;
				break;
			
		    case ACC_ID:
				if (msg[1] != 0)
					ToAccApp = msg[1];
				break;
			
		    case ACC_ACC:
				if (msg[7] != 0)
					ToAccApp = msg[7];
				if (!_app && !(_GemParBlk.global[0] >= 0x0400 && _GemParBlk.global[1] == -1))
					XAccSendId(msg[7]);
				msg[0] = 0;
				break;
			
			case ACC_TEXT:
				sprintf(file, "C:\\CLIPBRD\\TMP%05lx.TXT", tmp_count);
				if (msg[3] == 1)
					tmp_count++;
				goto save;
			
			case ACC_IMG:
				sprintf(file, "C:\\CLIPBRD\\TMP%05lx.IMG", tmp_count);
				if (msg[3] == 1)
					tmp_count++;
				goto save;
			
			case ACC_META:
				sprintf(file, "C:\\CLIPBRD\\TMP%05lx.GEM", tmp_count);
				if (msg[3] == 1)
					tmp_count++;
save:
				fd = (int)Fopen(file, FO_WRITE);
				if (fd < 0)
					fd = (int)Fcreate(file, 0x00);
				if (fd > 0)
				{
					Fseek(0, fd, SEEK_END);
					Fwrite(fd, *(long*)&msg[6],*(char**)&msg[4]);
					Fclose(fd);
					XAccSendAck(msg[1], 1);
				}
				else
				{
					XAccSendAck(msg[1], 0);
					tmp_count++;
				}
				msg[0] = 0;
				break;
			
			default:
				msg[0] = 0;
		}
	}
}
