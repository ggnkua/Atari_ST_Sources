/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include <mintbind.h>
#include <stdlib.h>
#include <string.h>
#include <basepage.h>
#include "ctype.h"			/* We use the version without macros!! */

#include "xa_types.h"
#include "xa_globl.h"

#include "xa_shel.h"

void accstart(void);
void reopen_moose(void);

static
char ARGV[] = "ARGV=";
static
short argvl = 5;

char *appex[16] = {".prg", ".app", ".gtp", ".ovl", ".sys", nil},
     *tosex[8] = {".tos", ".ttp", nil},
     *accex[8] = {".acc", nil}
     ;

bool is_ext(char *s, char **app)
{
	while (*app)
	{
		if (stricmp(s, *app) eq 0)
			return true;
		app++;
	}
	return false;
}

/* HR: 210201 Parse comand tail, while removing separators. */
long parse_tail(char *to, char *ti)
{
	char sep, *t = ti;

	while (*t)
	{
		if (*t eq '\'' or *t eq '\"')	/* arg between quote or apostrophe? */
		{
			if (t eq ti)		/* if first arg advance start */
				ti++;
			sep = *t++, *t=0;
		}
		else
			sep = ' ';
	
		while(*t and *t ne sep)
			*to++ = *t++;		/* transfer (in place) between seperator */

		*to++ = 0;				/* terminate 1 arg */
		if (*t)
		{
			t++;					/* skip seperator */
			if (*t and sep ne ' ' and *t eq ' ')
				t++;
		}
	}
	*to++ = 0;			/* double 0 terminate */
	return to - ti;		/* return space needed (end - start) */
}

static
void make_argv(char *p_tail, long tailsize, char *save_cmd, char *argvtail)
{
	DIAGS(("make_argv: %lx, %ld, %lx, %lx\n", p_tail, tailsize, save_cmd, argvtail));
	{
	short i = strlen(save_cmd);
	long l;
	char *argtail;

	l = count_env(C.strings, nil);
	DIAG((D.shel,-1,"count_env: %ld\n", l));
	argtail = xmalloc(l + 1 + tailsize + 1 + i + 1 + argvl + 1, 2012);
	if (argtail)
	{
		short j; char *last;
		j = copy_env(argtail, C.strings, nil, &last);
		DIAG((D.shel,-1,"copy_env: %d, last-start: %ld\n", j, last - C.strings[0]));
		strcpy(last, ARGV);
		strcpy(last + argvl + 1, save_cmd);
		parse_tail(last + argvl + 1 + i + 1, p_tail + 1);
		C.strings[j++] = last;
		C.strings[j] = nil;
		free(C.env);
		C.env = argtail;
		argvtail[0] = 0x7f;
		DIAGS(("ARGV constructed\n"));
		IFDIAG (display_env(C.strings, 0);)
	}
	else
		DIAGS(("ARGV: out of memory\n"));
	}
}

/* HR new_client --> new;  use NewClient() */
/* HR only called now for real_mode < 4 */
global
short launch(LOCK lock, short mode, short wisgr, short wiscr, char *parm, char *p_tail, XA_CLIENT *caller)
{
	char *tail,*run_name;
	short x_mode;
	XSHELW x_shell;
	short real_mode;
	short child = 0, t, drive = -1;
	char *run_path = nil, *save_tail = nil, *save_cmd = nil, *cmd = nil, *ext = nil;
	long longtail = 0, tailsize = 0;
	char argvtail[4];
	XA_CLIENT *new;
	long fl;

	if (!parm)
		return 0;

	real_mode = mode & 0xff;
	child = 0;

	x_shell = *(XSHELW *)parm;
	x_mode = mode & 0xff00;

	argvtail[0] = 0, argvtail[1] =  0;

	if (x_mode)				/* HR 010701: Do some checks before allocating anything. */
	{
		if (!x_shell.newcmd)
			return 0;
#if GENERATE_DIAGS
		{
			char ppp[128];
			*ppp = 0;
			if (x_mode & SW_PSETLIMIT)		/* Limit child's memory? */
				strcat(ppp,"SW_PSETLIMIT,");
			if (x_mode & SW_UID)				/* XaAES extension - set user id */
				strcat(ppp, "SW_UID,");
			if (x_mode & SW_GID)				/* XaAES extension - set group id */
				strcat(ppp, "SW_GID,");
			if ((x_mode & SW_PRENICE))		/* Was the child spawned as 'nice'? */
				strcat(ppp, "SW_PRENICE,");
			if ((x_mode & SW_ENVIRON))		/* Was the child spawned as 'nice'? */
				strcat(ppp, "SW_ENVIRON");
			DIAG((D.shel,-1,"Extended shell_write bits: %s\n",ppp));
		}
#endif
	}

	if (p_tail[0] == 0x7f or (unsigned char)p_tail[0] == 0xff)				/* HR: 210201 */
	{
		/* In this case the string CAN ONLY BE null terminated. */
		longtail = strlen(p_tail + 1);
		DIAG((D.shel,-1,"ARGV!  longtail = %ld\n", longtail));
		if (longtail < 126)
		{
			p_tail[0] = longtail;
			longtail = 0;
		}
	}

	if (longtail)
	{
		tailsize = longtail;
		tail = xmalloc(tailsize + 2,1012);
		if (!tail)
			return 0;
		strcpy(tail + 1, p_tail + 1);
		*tail = 0x7f;
		DIAG((D.shel,-1,"long tailsize: %ld\n", tailsize));
	othw
		tailsize = p_tail[0];
		tail = xmalloc(tailsize + 2,12);
		if (!tail)
			return 0;
		strncpy(tail, p_tail, tailsize + 1);
		tail[tailsize + 1] = '\0';
		DIAG((D.shel,-1,"short tailsize: %ld\n", tailsize));
	}

	if (!x_mode)
	{
		cmd = xmalloc(strlen(parm) + 2,13);
		if (!cmd)
			return 0;
		strcpy(cmd, parm);
	} else
	{
		cmd = xmalloc(strlen(x_shell.newcmd) + 2,14);
		if (!cmd)
			return free(tail), 0;
		strcpy(cmd,x_shell.newcmd);
	}

	DIAG((D.shel,-1,"Launch(0x%x): wisgr:%d, wiscr:%d\r\n cmd='%s'\r\n tail=%d'%s'\n",
							mode,
							wisgr, wiscr,
							cmd ? cmd : "~",
							*tail,
							tail+1));
#if GENERATE_DIAGS
	if (wiscr == 1)
	{
		DIAGS(("wiscr == 1\n"));
		display_env(C.strings, 0);
	}
#endif

	if (cmd)
	{
		save_cmd = xmalloc(strlen(cmd) + 2,15);		/* Preserve the details */

		if (!save_cmd)
			return free(cmd), 0;

		strcpy(save_cmd,cmd);

/* HR: This was a very bad bug, it took me a day to find it, although it was
		right before my eyes all the time.
		Dont mix pascal string processing with C string processing! :-)
*/
		save_tail = xmalloc(tailsize + 2,16);	/* was: strlen(tail+1) */
		strncpy(save_tail, tail, tailsize + 1);
		save_tail[tailsize + 1] = '\0';

	/* HR: t is 1 too high!!!!    added '-1'*/
		t = strlen(cmd)-1;
		while (t >= 0 and cmd[t] != bslash)  	/* Seperate path & name*/
			t--;

		if (cmd[t] == bslash)
		{
			cmd[t] = '\0';
			run_path = cmd;
			run_name = cmd + t + 1;
			if (isalpha(run_path[0]) and run_path[1] == ':')			/* HR */
			{
				drive = toupper(run_path[0]) - 'A';
DIAG((D.shel,-1,"Dsetdrv %d\n", drive));
				Dsetdrv(drive);
				run_path += 2;
			}
DIAG((D.shel,-1,"Dsetpath '%s'\n",run_path));
			if (*run_path)
				Dsetpath(run_path);	/* Ensure that client is run from its correct directory */
			else					/* - This allows it to find its resources,etc */
				Dsetpath(sbslash);		/* HR: a "\0" path is not accepted. Unix? */
		othw
			DIAG((D.shel,-1,"cmd: '%s'\n", cmd));
			drive = toupper(caller->home_path[0]) - 'A';
			Dsetdrv(drive);					/* HR: no drive, no path, use the caller's */
			Dsetpath(caller->home_path + 2);
			run_name = cmd;
			run_path = nil;
		}

		ext = run_name + strlen(run_name) - 4; /* Hmmmmm, OK, tos ttp and acc are really specific and always 3 */

		if (real_mode == 0)
		{
			if (is_ext(ext, tosex))
			{
				real_mode = 1, wisgr = 0;
DIAG((D.shel,-1," -= 1,0 =-\n"));
			}
			else
			if (is_ext(ext, accex))
			{
				real_mode = 3;
DIAG((D.shel,-1," -= 3,%d =-\n", wisgr));
			}
			else
			{
				real_mode = 1, wisgr = 1;
DIAG((D.shel,-1," -= 1,1 =-\n"));
			}
		}
	}

	fl = Fopen(run_name, 0);
DIAG((D.shel,-1,"Fopen run_name '%s' to %ld, real_mode %d\n", run_name, fl, real_mode));
	if (fl > 0)
	{
		Fclose(fl);
DIAG((D.shel,-1,"OK Fclose %ld\n", fl));

		switch(real_mode)
		{
		case 1:
			if (wisgr == 0)						/* TOS Launch?  */
			{
				char *tosrun = get_env(lock, "TOSRUN=");
				if (tosrun == nil)
				{
					char new_cmd[300];
					long fd;				/* HR: check tosrun's pipe */
	
					if (run_path)			/* HR: dont know if this ever happens, but it must be here for completeness */
						sdisplay(new_cmd,"%s" sbslash "%s %s", run_path, run_name, tail + 1);
					else
						sdisplay(new_cmd,"%s %s", run_name, tail + 1);
	
					fd = Fopen("U:" sbslash "pipe" sbslash "tosrun", 2);	/* HR */
					if (fd > 0)
					{
						t = strlen(new_cmd) + 1;
		
						Fwrite(fd, t, new_cmd);
	
						Fclose(fd);
					}
					else
					{
						DIAGS(("Raw run.\n"));
						goto raw_run;
					}
					DIAGS(("Tosrun pipe not opened!!  nn: '%s', nt: %d'%s'\n", run_name, tail[0], tail+1));
					child = 0;
				othw
					char *new_tail = xmalloc(tailsize + 1 + strlen(run_name) + 1, 17),
					     *new_run;
					long new_tailsize;

					strcpy(new_tail + 1, run_name);
					strcat(new_tail + 1, " ");
					DIAGS(("TOSRUN: '%s'\n", tosrun));
					wisgr = 1;
					new_run = xmalloc(strlen(tosrun) + 1, 18);
					strcpy(new_run, tosrun);
					run_name = new_run;
					free(cmd);
					cmd = new_run;
					new_tailsize = strlen(new_tail + 1);
					strncpy(new_tail + new_tailsize + 1, tail + 1, tailsize);
					new_tailsize += tailsize;
					free(tail);
					tail = new_tail;
					tail[new_tailsize + 1] = 0;
					tailsize = new_tailsize;
					if (tailsize > 126)
					{
						longtail = tailsize;
						tail[0] = 0x7f;
						DIAGS(("long tosrun nn: '%s', tailsize: %ld\n", run_name, tailsize));
					othw
						longtail = 0;
						tail[0] = tailsize;
						DIAGS(("tosrun nn: '%s', nt: %ld'%s'\n", run_name, tailsize, tail+1));
					}
				}
			}

			if (tailsize and (wiscr eq 1 or longtail))			/* HR 060201: implement ARGV */
				make_argv(tail, tailsize, run_name, argvtail);

			if (wisgr != 0)
			{
#if FIX_PC
				void  Pvfork1(void) 0x3F3C;
				void  Pvfork2(void) 0x0113;
				void  Pvfork3(void) 0x4E41;
				short Pvfork4(void) 0x544F;			/* inline Pvfork */
#endif

raw_run:

#if MOUSE_KLUDGE
				if (C.MOUSE_dev)
					Fclose(C.MOUSE_dev);		/* Kludge to get round a bug in MiNT (or moose?) */
#endif
				Sema_Up(CLIENTS_SEMA);	/* HR */
#if GENERATE_DIAGS
			if (*argvtail < 127)
				DIAG((D.shel,-1,"Pexec(200) '%s', tail: %ld(%lx) %ld(%d) '%s'\n", run_name, tail, tail, tailsize, *tail, tail + 1));
			else
				DIAG((D.shel,-1,"Pexec(200) with argvtail=0x7f; '%s', %ld\n", run_name, tailsize));
#endif
			DIAGS(("Normal Pexec\n"));
			IFDIAG (display_env(C.strings, 0);)

#if FIX_PC
				Pvfork1();
				Pvfork2();
				Pvfork3();
				child = Pvfork4();
#else
				child = Pvfork();	/* Fork off a new process */
#endif
				if (!child)
				{						/* In child here */
			      /*  debug_file is not a handle of the child ? */
					IFDIAG (if (D.debug_file > 0)
						        Fforce(1, D.debug_file);)			/* Redirect console output */
					if (x_mode)
					{
						if (x_mode & SW_PSETLIMIT)		/* Limit child's memory? */
							Psetlimit(2, x_shell.psetlimit);

						if (x_mode & SW_UID)				/* XaAES extension - set user id */
							Psetuid(x_shell.uid);
	
						if (x_mode & SW_GID)				/* XaAES extension - set group id */
							Psetgid(x_shell.gid);

						if ((x_mode & SW_PRENICE) and x_shell.prenice)		/* Was the child spawned as 'nice'? */
							Pnice(x_shell.prenice);
					}

					/* It took me a few hours to realize that the envp must be derefernced,
						to get to the original type of string (which I call a 'superstring' */

/* HR */			Pterm(Pexec(200, run_name, *argvtail ? argvtail : tail,
							   (x_mode & SW_ENVIRON)
							                 ? x_shell.env
							                 : *C.strings));	/* Run the new client */

					/* If we Pterm, we've failed to execute */
					/* HR: this approach passes the Pexec reply to the SIGCHILD code in signal.c */
				}

				new = NewClient(child);

				if (new)
				{
					if (   ((x_mode & SW_PRENICE) == 0)
						or ((x_mode & SW_PRENICE) != 0 and x_shell.prenice == 0)
						)
						Prenice(child, -4);

					new->pid = child;
		DIAG((D.appl,-1,"Alloc client; APP %d\n",child));
					new->type = XA_CT_APP;
					new->cmd_name = save_cmd;
					new->heap_name = true;		/* HR */
					new->cmd_tail = save_tail;
					new->heap_tail = true;		/* HR */
					new->parent = Pgetpid();
		/* HR: As we now unambiguously know the path from which the client is loaded,
		       why not fill it out here? :-) */
					* new->home_path = Dgetdrv() + 'A';
					*(new->home_path+1) = ':';
					if (run_path)
						strcpy(new->home_path+2, run_path);
					else
						strcpy(new->home_path+2, caller->home_path+2);	/* HR */
				}

				Sema_Dn(CLIENTS_SEMA);	/* HR */
/*
 * MASSIVE KLUDGE
 * - for some reason, you MUST re-open the moose after a Pvfork()
 */
#if MOUSE_KLUDGE
				if (C.MOUSE_dev)
					reopen_moose();
#endif
			}

			break;
		case 3:
#if MOUSE_KLUDGE
			if (C.MOUSE_dev)
				Fclose(C.MOUSE_dev);		/* Kludge to get round a bug in MiNT (or moose?) */
#endif
			{
				long p_rtn; long shrink;
				IFDIAG (short shrinked;)
				BASEPAGE* b;
				char full_cmd[300];

				if (run_path)			/* HR */		
					sdisplay(full_cmd,"%s" sbslash "%s", run_path, run_name);
				else
					sdisplay(full_cmd,"%s", run_name);

				p_rtn = Pexec(3, full_cmd, *argvtail ? argvtail : tail, nil);

				if (p_rtn < 0)
				{
					DIAG((D.shel,-1,"acc launch failed:error=%ld\n", p_rtn));
					break;
				}

				b = (BASEPAGE *)p_rtn;
				shrink = 256 + b->p_tlen + b->p_dlen + b->p_blen;
				IFDIAG (shrinked = )
					Mshrink(b, shrink);

DIAGS(("Shrinked accessory@%lx to %ld: %d\n",b, shrink, shrinked));
				b->p_dbase = b->p_tbase;
				b->p_tbase = (char *)accstart;		/* This code basically puts the basepage address in a0. */

				Sema_Up(CLIENTS_SEMA);	/* HR */

DIAG((D.shel,-1,"Pexec(106) '%s'\n",run_name));
				child = Pexec(106, run_name, b, *C.strings);		/* HR 104 --> 106 */

				DIAG((D.shel,-1,"child=%d\n", child));

				Prenice(child, -4);

				new = NewClient(child);
				new->pid = child;

				DIAG((D.appl,-1,"Alloc client; ACC %d\n",child));

				new->type = XA_CT_ACC;
				new->cmd_name = save_cmd;		/* HR */
				new->heap_name = true;			/* HR */
				new->parent = Pgetpid();
				Sema_Dn(CLIENTS_SEMA);			/* HR */
			}

#if MOUSE_KLUDGE
		if (C.MOUSE_dev)									/* Kludge - for some reason, you MUST re-open the moose after a Pvfork() */
			reopen_moose();
#endif
			break;

		}
	}

	Dsetdrv(C.home_drv);
	Dsetpath(C.home);
	
	free(cmd);
	free(tail);

	DIAG((D.shel,-1,"Launch for '%s'(%d): returns child %d\n",caller->name, caller->pid, child));
	DIAG((D.shel,-1,"Remove ARGV\n"));
	put_env(lock, 1, 0, ARGV);				/* Remove ARGV */
	return child;			/* HR */
}

AES_function XA_shell_write	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_CLIENT *child;
	short wisgr = pb->intin[1],
	      wiscr = pb->intin[2];

	CONTROL(3,1,2)

DIAG((D.shel,-1,"shell_write 0x%x for %s\n", pb->intin[0], client->name));
	if ((pb->intin[0]&0xff) < 4)
	{
		short child_id;

		if unlocked(envstr)
			Sema_Up(ENV_SEMA);

		child_id = launch(	lock|envstr,
							pb->intin[0],
							wisgr,
							wiscr,
					(char *)pb->addrin[0],
					(char *)pb->addrin[1],
					        client);

		pb->intout[0] = child_id;
	
		if (child_id)		/* HR */
		{
			child = Pid2Client(child_id);
			if (child)
			{
				child->parent = client->pid;		/* OK */
			
				if ((pb->intin[0] == 1) and (wisgr == 1))
				{
					client->waiting_for = XAWAIT_CHILD;
					if unlocked(envstr)
						Sema_Dn(ENV_SEMA);
					return XAC_BLOCK;
				}
			}
		}
		if unlocked(envstr)
			Sema_Dn(ENV_SEMA);
	} else
	{
		char *cmd = pb->addrin[0];
DIAG((D.shel,-1," -- 0x%x, wisgr %d, wiscr %d\n",
							pb->intin[0],pb->intin[1],pb->intin[2]));
		pb->intout[0] = 0;

		switch (pb->intin[0])
		{
		case 4:		/* Shutdown system */
			if (wisgr == 2)
			{
				DIAGS(("shutown by shell_write(4, ...)\n"));
				C.shutdown = true;
			}
			break;
			
		case 5:		/* Res change */
			break;
				
		case 6:		/* undefined */
			break;
			
		case 7:		/* broadcast message */
			{
				XA_CLIENT *cl;
				short *msg = (short *)cmd;

				if unlocked(clients)
					Sema_Up(CLIENTS_SEMA);		/* HR */
	
				cl = S.client_list;
				while (cl)
				{
					if (is_client(cl) and cl->pid != client->pid)
						send_app_message(clients, nil, cl->pid, msg[0], msg[1], msg[3], msg[4], msg[5], msg[6], msg[7]);
					cl = cl->next;				/* HR 250601: changed very wrong 'client->next' into 'cl->next' */
				}

				if unlocked(clients)
					Sema_Dn(CLIENTS_SEMA);		/* HR */
	
			}
			break;
			
		case 8:		/* Manipulate AES environment */
			pb->intout[0] = put_env(lock, wisgr, wiscr, cmd);
		break;
		case 9:		/* currently: tell AES app understands AP_TERM */
/*			client->apterm = (wisgr&1) != 0;
*/			break;
		case 10:	/* Send a msg to the AES  */
		default:
			break;
		}
	}
	return XAC_DONE;
}


/* I think that the description if shell_read in the compendium is 
     rubbish. At least on Atari GEM the processes own command must be
     given, NOT that of the parent.
*/
AES_function XA_shell_read	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	char *name = (char *)pb->addrin[0];
	char *tail = (char *)pb->addrin[1];
	short f;

	CONTROL(0,1,2)

	strcpy(name, client->cmd_name ? client->cmd_name : sbslash);
	
	for(f = 0; f < client->cmd_tail[0] + 1; f++)
		tail[f] = client->cmd_tail[f];
	tail[f] = 0;
	
	pb->intout[0] = 1;

DIAG((D.shel, -1, "shel_read: n='%s', t=%d'%s'\n",pb->addrin[0], *(char *)pb->addrin[1], (char *)pb->addrin[1]+1));
	return XAC_DONE;
}

extern Path Xpath;
extern short Xdrive;

global
char *shell_find(LOCK lock, XA_CLIENT *client, char *fn)
{
	char *kp;
	static
	Path path;
	char cwd[256];
	long handle;
	short f = 0, l, n, drive;

	kp = get_env(lock, "PATH=");

	DIAG((D.shel,client->pid,"shell_find for %s '%s', PATH= '%s'\n", client->name, fn ? fn : "~", kp ? kp : "~"));

	if ( ! (isalpha(*fn) and *(fn+1) == ':'))
	{
	/* Check the clients home path */
		sdisplay(path, "%s" sbslash "%s", client->home_path, fn);
		handle = Fopen(path, 0);
DIAG((D.shel,client->pid,"[1]  --   try: '%s' :: %ld\n",path,handle));
		if (handle > 0)
		{
			Fclose(handle);
			return path;
		}

		if (kp)						/* HR: the PATH env could be simply absent */
		{
		/* Check our PATH environment variable */
		/*	l = strlen(cwd);	 */		/* HR: cwd uninitialized; after sdisplay? or is it kp? or is it sizeof? */
			l = strlen(kp);
			sdisplay(cwd, "%s", kp);
			while(f < l)				/* We understand ';' and ',' as path seperators */
			{
				n = f;
				while(    cwd[n]
				      and cwd[n] != ';'
				      and cwd[n] != ','
				     )
				{
					if (cwd[n] == slash)
						cwd[n] = bslash;
					n++;
				}
				if (cwd[n-1] == bslash)
					cwd[n-1] = 0;
				cwd[n] = '\0';
				sdisplay(path, "%s" sbslash "%s", cwd + f, fn);
				handle = Fopen(path, 0);
DIAG((D.shel,client->pid,"[2]  --   try: '%s' :: %ld\n",path,handle));
				if (handle > 0)
				{
					Fclose(handle);
					return path;
				}
				f = n + 1;
			}
		}
	}

#if 0		/* needed for experimentation. not anymore. */
/* Try clients current path: */
	sdisplay(path, "%c:%s" sbslash "%s",
				client->Xdrive + 'a', client->Xpath, fn);
	handle = Fopen(path, 0);
DIAG((D.shel,client->pid,"[3]  --   try: '%s' :: %ld\n",path,handle));
	if (handle > 0)
	{
		Fclose(handle);
		return path;
	}
#endif

/* Last ditch - try the file spec on its own */
	handle = Fopen(fn, 0);
DIAG((D.shel,client->pid,"[4]  --    try: '%s' :: %ld\n",fn,handle));
	if (handle > 0)
	{
		Fclose(handle);
		return fn;
	}

DIAG((D.shel,client->pid," - nil\n"));
	return nil;
}

AES_function XA_shell_find	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	char *fn = pb->addrin[0],
	     *path;

	CONTROL(0,1,1)

	path = shell_find(lock, client, pb->addrin[0]);
	if (path)
	{
		strcpy(fn, path);
		pb->intout[0] = 1;
	}
	else
		pb->intout[0] = 0;		/* Didn't find the file :( */
	return XAC_DONE;
}

global
char *get_env(LOCK lock, const char *name)		/* This version finds XX & XX= */
{
	short i = 0;

	if unlocked(envstr)
		Sema_Up(ENV_SEMA);

	while (C.strings[i])
	{
		char *f = C.strings[i];
		const char *n = name;
		do {
			if (*f != *n)
				if (*f == '=' and *n == 0)
				{
					if unlocked(envstr)
						Sema_Dn(ENV_SEMA);
					return f;			/* HR: if used XX return pointer to '=' */
				}
				else
					break;
			if (*f == '=' and *n == '=')
			{
				if unlocked(envstr)			/* HR: 131200 */
					Sema_Dn(ENV_SEMA);
				return f+1;				/*    if used XX= return pointer after '=' */
			}
			if (*f == '=')
				break;
			f++, n++;
		} od

		i++;
	}

	if unlocked(envstr)
		Sema_Dn(ENV_SEMA);

	return nil;
}

/* HR: The importance of usefull functions */
global
short copy_env(char *to, char *s[], char *without, char **last)		/* HR */
{
	short i = 0, j = 0, l = 0;

	if (without)
		while (without[l] != '=') l++;

	while (s[i])
	{
		if (strncmp(s[i],ARGV,4) == 0)
		{
			DIAGS(("copy_env ARGV: skipped remainder of environment\n"));
			break;
		}
		if (l == 0 or (l != 0 and strncmp(s[i], without, l) != 0) )
		{
			strcpy(to, s[i]);
			s[j++] = to;
			to += strlen(to) + 1;
		}
		i++;
	}
	C.strings[j] = nil;
	*to = 0;		/* the last extra \0 */
	if (last)
		*last = to;
	return j;
}

global
long count_env(char *s[], char *without)	/* HR */
{
	long ct = 0;
	short i = 0, l = 0;

	if (without)
		while (without[l] != '=') l++;
	while (s[i])
	{
		if (strncmp(s[i],ARGV,4) == 0)
		{
			DIAGS(("count_env ARGV: skipped remainder of environment\n"));
			break;
		}
		if (l == 0 or (l != 0 and strncmp(s[i], without, l) != 0) )
			ct += strlen(s[i]) + 1;
		i++;
	}
	return ct + 1;
}

global
long put_env(LOCK lock, short wisgr, short wiscr, char *cmd)	/* HR */
{
	long ret = 0;
	if unlocked(envstr)
		Sema_Up(ENV_SEMA);

	if (wisgr == 0)
	{
		long ct = count_env(C.strings, nil);
DIAG((D.shel,-1," -- count = %d\n", ct));
		ret = ct;
	}
	else if (wisgr == 1)
	{
		if (cmd)
		{
			long ct;
			char *newenv;

DIAG((D.shel,-1," -- change; '%s'\n", cmd ? cmd : "~~"));

			ct = count_env(C.strings, cmd);		/* count without */
/* ct is including the extra \0 at the end! */
			if (*(cmd + strlen(cmd) - 1) == '=')	/* ends with '=': remove */
			{
				newenv = xmalloc(ct, 19);
				if (newenv)
					copy_env(newenv, C.strings, cmd, nil);		 /* copy without */
			} else
			{
				short l = strlen(cmd) + 1;
				newenv = xmalloc(ct + l, 20);
				if (newenv)
				{
					char *last;
					short j = copy_env(newenv, C.strings, cmd, &last);	/* copy without */
					C.strings[j] = last;
					strcpy(C.strings[j], cmd);			/* add new */
					*(C.strings[j] + l) = 0;
					C.strings[j + 1] = nil;
				}
			}
			if (newenv)
			{
				free(C.env);
				C.env = newenv;
			}
			DIAGS(("putenv\n"));
			IFDIAG (display_env(C.strings, 0);)
		}
	}
	else if (wisgr == 2)
	{
		long ct = count_env(C.strings, nil);
DIAG((D.shel,-1," -- copy\n"));
		memcpy(cmd, C.strings[0], wiscr > ct ? ct : wiscr);
		ret = ct > wiscr ? ct - wiscr : 0;
DIAG((D.shel,-1," -- & left %ld\n", ret));
	}

	if unlocked(envstr)
		Sema_Dn(ENV_SEMA);

	return ret;
}


/* HR: because everybody can mess around with the AES's environment
       (shell_write(8, ...) changing the pointer array strings,
       it is necessary to make a permanent copy of the variable.
*/
AES_function XA_shell_envrn	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	char **p = pb->addrin[0], *pf;
	char *name = (char *)pb->addrin[1];

	CONTROL(0,1,2)

	if (p and name)
	{
		*p = nil;					/* HR 130201 */
		pf = get_env(lock, name);
DIAGS(("shell_env for %s(%d): '%s' :: '%s'\n",client->name, client->pid, name, pf? pf: "~~~"));	
		if (pf)
		{
			*p = XA_alloc(&client->base, strlen(pf) + 1, 0, 0);
			if (*p)
				strcpy(*p, pf);
		}
	}

	pb->intout[0] = 1;
	
	return XAC_DONE;
}
