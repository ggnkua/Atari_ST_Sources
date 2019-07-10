#include "global.h"
#include "comm.h"
#include "olga.h"

/* lokale Variablem **********************************************************/
static int	olga_id;
static bool	olga_active, have_started = FALSE;


/*****************************************************************************/
static void send_ole_init(void)
{
	memset(msgbuff, 0, (int)sizeof(msgbuff));
	msgbuff[0] = OLE_INIT;
	msgbuff[1] = gl_apid;
	msgbuff[3] = OL_SERVER;
	msgbuff[7] = 'ED';
	send_msg(olga_id);
}

static void send_ole_exit(void)
{
	memset(msgbuff, 0, (int)sizeof(msgbuff));
	msgbuff[0] = OLE_EXIT;
	msgbuff[1] = gl_apid;
	send_msg(olga_id);
}

static void send_olga_update(char *filename)
{
	memset(msgbuff, 0, (int)sizeof(msgbuff));
	msgbuff[0] = OLGA_UPDATE;
	msgbuff[1] = gl_apid;
	strcpy(global_str1, filename);
	*(char **)(msgbuff + 3) = global_str1;
	send_msg(olga_id);
}

static void send_olga_rename(char *oldname, char *newname)
{
	memset(msgbuff, 0, (int)sizeof(msgbuff));
	msgbuff[0] = OLGA_RENAME;
	msgbuff[1] = gl_apid;
	strcpy(global_str1, oldname);
	*(char **)(msgbuff + 3) = global_str1;
	strcpy(global_str2, newname);
	*(char **)(msgbuff + 5) = global_str2;
	send_msg(olga_id);
}

void handle_olga(int *msg)
{
	switch (msg[0])
	{
		case OLGA_INIT :
			/*
			 * Wenn qed OLGA gestartet hat, ist unter N.AES OLGA die aktuelle 
			 * Applikation! 
			*/
			if (have_started && gl_naes)
			{
				long	v;
				
				appl_control(gl_apid, 12, &v);
				have_started = FALSE;
			}

			olga_active = TRUE;
			break;

		case OLE_NEW :
			olga_id = msg[1];
			send_ole_init();
			break;

		case OLGA_ACK :
			break;

		case OLE_EXIT :
			olga_active = FALSE;
			break;
	}
}

void do_olga(int flag, char *name1, char *name2)
{
	if (olga_active)
	{
		switch (flag)
		{
			case OLGA_UPDATE :
				if (name1 != NULL)
					send_olga_update(name1);
				break;

			case OLGA_RENAME :
				if (name1 != NULL && name2 != NULL)
					send_olga_rename(name1, name2);
				break;
		}
	}
}

void init_olga(void)
{
	char	*p;

	olga_id = appl_find("OLGA    ");
	if (olga_id > 0)
		send_ole_init();
	else
	{
		p = getenv("OLGAMANAGER");
		if (p != NULL)
		{
			PATH	olga_path, olga_name, old;

			strcpy(olga_name, p);
			split_filename(olga_name, olga_path, NULL);
			get_path(old, 0);
			set_path(olga_path);
			if (gl_gem >= 0x400)
				shel_write(1, 1, 1, olga_name, "");
			else if (gl_magx)
				shel_write(1, 1, 100, olga_name, "");
			have_started = TRUE;
			set_path(old);
		}
	}
}

void term_olga(void)
{
	if (olga_active)
		send_ole_exit();
}
