#include		<stdio.h>
#include		<time.h>
#include		<ctype.h>
#include		<process.h>
#include		<ext.h>
#include 	<tos.h>
#include		<string.h>
#include		<stdlib.h>
/*#include		<errno.h>*/
#include 	<mintbind.h>
#include 	<atarierr.h>

#include		"portab.h"
#include		"defs.h"
#include		"ioslib.h"
#include		"modules.h"
#include		"routing.h"

#include		"inmail.h"
#include		"strutil.h"
#include		"crc.h"
#include		"lang.h"

#include		"vars.h"

/*
**	Scanning the inbound for files. If found jump to arcmail() to
**	find out if this is arcmail. I arcmail returns ARCMAIL otherwise
**	return EMPTY inbound.
*/

BYTE unpack_pkt(VOID)
{
	BYTE			buffer[128];
#if defined LATTICE
	DMABUFFER		blk;
#else
	struct ffblk	blk;
#endif
	
	sprintf(buffer, "%s*.*", inbound);
	
	if (!findfirst(buffer, &blk, 0))
	{
		bundlesize = blk.ff_fsize;
		if (arc_mail(blk.ff_name)) return(ARCMAIL);
		
		while (!findnext(&blk))
		{
			bundlesize = blk.ff_fsize;
			if (arc_mail(blk.ff_name)) return (ARCMAIL);
		}
	}
	
	return(EMPTY);
}

/*
**	Searching for arcmail extensions. If found jump to unpack() and
**	extract the packet. If no arcmail return EMPTY otherwise return
**	RCMAIL.
*/

BYTE arc_mail(BYTE *name)
{
	BYTE	buffer[128],
			*p;
	WORD	i;
	
	if ((p = strchr(name, '.')) != NULL)
	{
		p++;
		
		for (i=0; isuf[i] != NULL; i++)
			if (!strnicmp(p, isuf[i], 2))
			{
				if (!isdigit(p[strlen(p)-1])) continue;
				
				sprintf(buffer, "%s%s", inbound, name);
				
				if (unpack(buffer)) return (ARCMAIL);
				else return (EMPTY);
			}
	}
	
	return (EMPTY);
}

VOID isPKT (BYTE *name) {
	BYTE buffer[128];
	FILE *fp;
	
	sprintf(buffer, "%s%s",pkt_temp, name);
	
	if ((fp = fopen(buffer, "r+b")) != NULL) {
		fread (&phdr, sizeof (struct _pkthdr), 1, fp);
		giveTIMEslice();
		fclose (fp);
		if (intel (phdr.ph_ver) != 2) {
			unlink (buffer);
			log_line (6, Logmessage[M__NO_MESSAGE_PACKET],buffer);
			return;
		}
	} else unlink (buffer);
	
	if(strstr(name, ".BKT") == NULL)
		log_line(3, Logmessage[M__IS_MESSAGE_PACKET], buffer);
}
	
/*
**	Upack mail packets. Return EMPTY if error.
*/

BYTE unpack(BYTE *name)
{
	BYTE	arccmd[128],
			arcprogram[128],
			buffer[128];
	WORD	j, type;

	LONG	sema_access;
	
	struct ffblk blk;
	
	type = ARCtype(name);
	
	log_line(3,Logmessage[M__RECEIVED], ArcMail[type], strupr(name));
	log_line(3,Logmessage[M__SIZE_OF], bundlesize);
	
	switch (type)
	{
		case isUNKNOWN:
			
			take_default:
			
			if (strlen(Archcmdi))
				sprintf(arccmd, "%s %s %s*.*", Archcmdi, name, pkt_temp);
			else
				sprintf(arccmd, "x %s %s*.*", name, pkt_temp);
			
			strcpy(arcprogram, Arch);
			
			break;
			
		case isARCmail:
		
			if (strlen(Arc))
			{
				if (strlen(ArceC))
					sprintf(arccmd, "%s %s %s*.*", ArceC, name, pkt_temp);
				else
					sprintf(arccmd, "x %s %s*.*", name, pkt_temp);
				
				strcpy(arcprogram, Arc);
			}
			else goto take_default;
			
			break;
			
		case isLZHmail:
		
			if (strlen(Lzh))
			{
				if (strlen(LzheC))
					sprintf(arccmd, "%s %s %s *.*", LzheC, name, pkt_temp);
				else
					sprintf(arccmd, "x %s %s*.*", name, pkt_temp);
				
				strcpy(arcprogram, Lzh);
			}
			else goto take_default;
			
			break;
			
		case isZIPmail:
		
			if (strlen(Zip))
			{
				if (strlen(ZipeC))
					sprintf(arccmd, "%s %s %s *.*", ZipeC, name, pkt_temp);
				else
					sprintf(arccmd, "-x %s %s *.*", name, pkt_temp);
				
				strcpy(arcprogram, Zip);
			}
			else goto take_default;
			
			break;
			
		case isARJmail:
		
			if (strlen(Arj))
			{
				if (strlen(ArjeC))
					sprintf(arccmd, "%s %s %s *.*", ArjeC, name, pkt_temp);
				else
					sprintf(arccmd, "x %s %s *.*", name, pkt_temp);
				
				strcpy(arcprogram, Arj);
			}
			else goto take_default;
			
			break;
			
		default:
		
			log_line(6,Logmessage[M__TAKE_DEFAULT]);
			goto take_default;
	}
	
	log_line(5,Logmessage[M__EXECUTE_PRG], arcprogram);
	
	printf ("\033E");
	
	if (MTask == MULTITOS) {
		while (1) {
			sema_access = Psemaphore (0, 0x494f535550L, 0L);
			if (sema_access == EACCDN)
				delay (1000);			
			else
				break;
		}
	}
	
	if (exec(arcprogram, arccmd, envp, &j) == -1)
	{
		log_line(6,Logmessage[M__CANT_EXEC_PRG], arcprogram);

		if (MTask == MULTITOS) {
			sema_access = Psemaphore (1, 0x494f535550L, 0L);
		}

		return(EMPTY);
	}

	if (MTask == MULTITOS) {
		sema_access = Psemaphore (1, 0x494f535550L, 0L);
	}

	printf("\033E");
	hprintf (S_ALL, "");
	
#if defined EXTERNDEBUG
	if (debugflag) {
		log_line(6, "#Memory after archiver %ld", coreleft());
	}
#endif
	
	if (!j)
	{
		if (keepmsg) rename_arcmail(name);
		else {
		
		/*
		**	If archiver returns 0, and the packet is still
		**	unpacked, don't delete the packet.
		*/
		
			sprintf (arcprogram, "%s*.PKT",pkt_temp);
			if (!findfirst(arcprogram, &blk, 0))
				unlink(name);
			else {
				
				/*
				**	Unpacket but not an PKT file. Delete them.
				*/
				
				sprintf(buffer, "%s*.*", pkt_temp);
				if (!findfirst(buffer, &blk, 0)) {
					isPKT (blk.ff_name);
					while (!findnext (&blk)) {
						isPKT (blk.ff_name);
					}
					return (EMPTY);
				} else {
				
					log_line(6, Logmessage[M__NOT_UNPACKED]);
					return (EMPTY);
				}
			}
		}
		return (ARCMAIL);
	}
	else
	{
		log_line(5,Logmessage[M__RETURNS_ERRORCODE], j, ", RENAME");
		rename_arcmail(name);
		
		/*
		**	If the archiver returns an errorcode, but there are packets
		**	in the inbound, return there is nothing happened.
		*/
		
		sprintf(arccmd, "%s*.PKT", pkt_temp);
		if (!findfirst(arccmd, &blok, 0)) return(ARCMAIL);
		
		return (EMPTY);
	}
}

BYTE rename_arcmail(BYTE *name)
{
	BYTE	newname[129],
			*p;
	
	strcpy(newname, name);
	
	if ((p = strrchr(newname, '.')) != NULL)
	{
		strcpy(++p, "000");
		
		while (rename(name, newname))
		{
			*p += 1;
			
			if (*p == 'z')
			{
				p++;
				
				if (!*p)
				{
					log_line(4,Logmessage[M__CANT_RENAME],name);
					return(FALSE);
				}
			}
		}
	}
	return(TRUE);
}
