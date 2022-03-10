/*********************************************************************

					IOS - tosser
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991
	
	Seek in the inboundfolders for arcmail and-or for files with the
	extension PKT. If found, read those files, and decompress it to
	readable textfile for the messageeditor. Tos all new messages to
	connected people on an partical area. Create packets if on.
	
*********************************************************************/


/*#define TEST_CRUNCH 1*/

#include		<stdio.h>
#include		<time.h>
#include		<ctype.h>
#if !defined LATTICE
#include		<ext.h>
#include 		<tos.h>
#include		<process.h>
#include		<vdi.h>
#else
#include		<sys/stat.h>
#include		<dos.h>
#endif
#include		<string.h>
#include		<stdlib.h>
/* #include		<errno.h> */
#include 	<mintbind.h>
#include		<atarierr.h>

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

#include		"compiler.h"

CONST BYTE		*thisprogram = "INMAIL.TTP";
BYTE			first_pass=0;

#define PRGNAMELEN 10



MLOCAL BOOLEAN get_secure(WORD area, UWORD zone, UWORD net, UWORD node, UWORD point)
{
	WORD	i;
	
	for (i=0; Tozone[area][i] != (UWORD)-1; i++)
		if (Tozone[area][i] == zone && Tonet[area][i] == net &&
			Tonode[area][i] == node && Topoint[area][i] == point)
		   	return(TRUE);
	
	return(FALSE);
}

/*
**	Scanning the inbound for files. If found jump to arcmail() to
**	find out if this is arcmail. I arcmail returns ARCMAIL otherwise
**	return EMPTY inbound.
*/

/*

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
	
	if (exec(arcprogram, arccmd, envp, &j) == -1)
	{
		log_line(6,Logmessage[M__CANT_EXEC_PRG], arcprogram);
		return(EMPTY);
	}
	
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
*/
/*
**	Checking diskspace.
*/

BYTE check_diskspace(LONG space)
{

#if defined LATTICE
	struct DISKINFO dinf;
#else
	DISKINFO	dinf;
#endif
	LONG		free;

#if defined LATTICE
	if(getdfs(0,&dinf))
#else	
	if (Dfree(&dinf, 0))
#endif
	{
		log_line(6,Logmessage[M__CANT_ASK_DISKFREE]);
		return(FALSE);
	}
	
	free = (dinf.b_free * dinf.b_clsiz * dinf.b_secsiz) - 1024L;
	free -= space;
	
	if (free <= mindiskspace)
	{
		log_line(6,Logmessage[M__DISKSPACE_EXEEDED]);
		return(FALSE);
	}
	
	return(TRUE);
}

/*
**	Scanning inbound on *.PKT If found import PKT.
*/

VOID import_pkt(BYTE *path)
{
	BYTE	buffer[128];
	LONG	sema_access;
	
	sprintf(buffer, "%s*.PKT", path);

	if (MTask == MULTITOS) {
		while (1) {
			sema_access = Psemaphore (0, 0x494f535550L, 0L);
			if (sema_access == EACCDN)
				delay (1000);			
			else
				break;
		}
	}
	
	if (!findfirst(buffer, &blok, 0))
	{
		if (dodiskcheck && !check_diskspace(blok.ff_fsize)) return;
		
		pktsize = blok.ff_fsize;
		if (pktsize < sizeof (struct _pkthdr)) {
		
			rename_pkt (strcat (path, blok.ff_name));
		} else {
			have_pkt(blok.ff_name, path);
		}
		
		while (!findnext(&blok))
		{
			if (dodiskcheck && !check_diskspace(blok.ff_fsize)) return;
			pktsize = blok.ff_fsize;
		
			if (pktsize < sizeof (struct _pkthdr)) {
			
				rename_pkt(blok.ff_name);
				continue;
			}
			
			have_pkt(blok.ff_name, path);
		}
	}

	if (dofastimport) close_PKTS();
	first_pass = 0;
	
	/*
	**	The pkt temp. dir must be empty. If someone sends mail
	**	that isn't an PKT, it could be an person who wants to
	**	destroy the system. So delete everything in the temp dir.
	**	This only if the path is the same as pkt temp. dir.
	*/
	
	if (!stricmp(path,pkt_temp)) {
		sprintf(buffer, "%s*.*",path);

		if (!findfirst(buffer, &blok, 0)) {
			isPKT (blok.ff_name);
			while(!findnext(&blok)) {
				isPKT (blok.ff_name);
			}
		}
	}
	sema_access = Psemaphore (1, 0x494f535550L, 0L);
}

VOID have_pkt(BYTE *pktname, BYTE *path)
{
	BYTE	buffer[128],
			program[128],
			*p, *q,
			temp[10];
	WORD	i;
	
	
	sprintf(buffer, "%s%s", path, pktname);
	
	if ((PACKET = fopen(buffer, "rb")) == NULL)
	{
		log_line(6,Logmessage[M__CANT_OPEN], buffer);
		return;
	}
	
	hdrread(&phdr, sizeof(struct _pkthdr), PACKET);
	
	/*
	**	Init some vars first.
	*/
	
	Fpoint = Tpoint = Ffake = Tfake =
	fzone = fnet = fnode = fpoint =
	tzone = tnet = tnode = tpoint = 0;
	
	org_domain[0] = EOS;
	dest_domain [0] = EOS;
	
	if (strlen(thisprogram) != PRGNAMELEN) FOREVER
	
	if ((i = intel(phdr.ph_ver)) != 2)
	{
		log_line(4,Logmessage[M__PACKET_TYPE_ERROR], pktname, i);
		rename_pkt(buffer);
		return;
	}
	
	if ((i= intel(phdr.ph_rate)) == TYPE2_2) {
		memcpy(&phdr2, &phdr, sizeof(struct _phdr2));
		memset(&phdr, 0, sizeof(struct _pkthdr));
		
		pkttype = TYPE2_2;

		log_line(6, Logmessage[M__PACKETTYPE], "2.2");

		Fpoint = intel(phdr2.ph_opoint);
		Tpoint = intel(phdr2.ph_dpoint);
		Fzone  = intel(phdr2.ph_ozone);
		Tzone  = intel(phdr2.ph_dzone);
		Fnet   = intel(phdr2.ph_onet);
		Tnet   = intel(phdr2.ph_dnet);
		Fnode  = intel(phdr2.ph_onode);
		Tnode  = intel(phdr2.ph_dnode);
		
		phdr.ph_rev   = phdr2.ph_spec_data[1];
		phdr.ph_revMin= phdr2.ph_spec_data[2];
		phdr.ph_prod  = phdr2.ph_prod;
		
		strncpy(phdr.ph_pwd, phdr2.ph_pwd, 8);

	}
	
	if (phdr.ph_prod <= maxPRD && maxPRD && phdr.ph_prod != IOSPRDCODE) {
		strcpy(program, PRDcode[phdr.ph_prod]);
		if (pkttype != TYPE2_2) {
			sprintf(&program[strlen(program)], " %d.%02d",
				(WORD) phdr.ph_rev, (WORD) phdr.ph_revMin);
		}
	}
	else {
		if (phdr.ph_prod == IOSPRDCODE)
		{
			if (phdr.ph_rev || phdr.ph_revMin) 
			{
				if (!phdr.ph_revMin && pkttype == TYPE_2_2)
					sprintf(program, "IOSmail %d.%02d",
						(WORD)phdr.ph_rev, (WORD)phdr.ph_revMin);

				else
					sprintf(program, "IOSmail %d.%02d", 
						(WORD)phdr.ph_rev, (WORD)phdr.ph_revMin);
			}
			else
				strcpy(program, "IOSmail");
		}
		else
			sprintf(program, "program 0x%x", (WORD)phdr.ph_prod);
	}
	
	if (intel(phdr.ph_capable) == phdr.ph_CWcopy &&
		phdr.ph_capable && intel(phdr.ph_capable) & TYPE2PLUS)
	{
		pkttype = TYPE2PLUS;
		log_line(6, Logmessage[M__PACKETTYPE], "2+");
		Fzone = intel(phdr.ph_ozone);
		Fnet = intel(phdr.ph_onet);
		Fnode = intel(phdr.ph_onode);
		Fpoint = intel(phdr.ph_opoint);
		Tzone = intel(phdr.ph_dzone);
		Tnet = intel(phdr.ph_dnet);
		Tnode = intel(phdr.ph_dnode);
		Tpoint = intel(phdr.ph_dpoint);
		
		if (Fpoint && Fnet == (UWORD)(-1))
			Fnet = intel(phdr.ph_auxnet);
	}
	else if (pkttype == STONEAGE)
	{
		log_line(6, Logmessage[M__PACKETTYPE], "2.0");
		Fzone = intel(phdr.ph_qozone);
		Fnet = intel(phdr.ph_onet);
		Fnode = intel(phdr.ph_onode);
		Fpoint = intel(phdr.ph_opoint);
		Tzone = intel(phdr.ph_qdzone);
		Tnet = intel(phdr.ph_dnet);
		Tnode = intel(phdr.ph_dnode);
		Tpoint = intel(phdr.ph_dpoint);
		
		if (!Fzone) Fzone = intel(phdr.ph_ozone);
		if (!Tzone) Tzone = intel(phdr.ph_dzone);
		
		if (!Fzone)
			for (i=0; i < nkey; i++)
			{
				if (pwd[i].net == Fnet && pwd[i].node == Fnode)
				{
					Fzone = pwd[i].zone;
					break;
				}
				
				if (i >= nkey) Fzone = alias[0].zone;
			}
		
		if (!Tzone)
		{
			for (i=0; i < nalias; i++)
			{
				if (!strnicmp (dest_domain, alias[i].Domain, 8))
				{
					Tzone = alias[i].zone;
					break;
				}
				
				if (alias[i].pointnet == Tnet)
				{
					Tzone = alias[i].zone;
					Tnet = alias[i].net;
					Tpoint = Tnode;
					Tnode = alias[i].node;
				}
			}
			
			if (i >= nalias) Tzone = alias[0].zone;
		}
	}
	
	if (pkttype == STONEAGE) {
		if (!Tpoint)
			for (i=0; i < nalias; i++)
				if (Tnet == alias[i].pointnet)
				{
					Tzone = alias[i].zone;
					Tfake = Tnet;
					Tnet  = alias[i].net;
					Tpoint= Tnode;
					Tnode = alias[i].node;
					
					break;
				}
		
		if (!Fpoint)
			for (i=0; i < nalias; i++)
				if (Fnet == alias[i].pointnet)
				{
					Fzone = alias[i].zone;
					Fpoint= Fnode;
					Fnode = alias[i].node;
					Ffake = Fnet;
					Fnet  = alias[i].net;
					
					break;
				}
	}
	
	/*
	**	Double check the numbers now. If system is unknown then mail
	**	can only imported in the netmail.
	*/
	
#if defined EXTERNDEBUG
	if (debugflag)
	{
		log_line(6,">Packetheader contains :");
		log_line(6,">Org %u:%u/%u.%u -> %u:%u/%u.%u", Fzone, Fnet, Fnode, Fpoint, Tzone, Tnet, Tnode, Tpoint);
		log_line(6,">Tfake = %u, Ffake = %u", Tfake, Tfake);
	}
#endif
	
	Fsystem = Tsystem = OUR_SYSTEM;
	
	if (pkttype != TYPE_2_2) {
		for (i=0;i < nkey; i++) {
			if (pwd[i].zone == Fzone && pwd[i].net == Fnet &&
				pwd[i].node == Fnode && pwd[i].point == Fpoint) {
				
				strcpy (org_domain, pwd[i].Domain);
				strcpy (dest_domain, org_domain);
				break;
			}
		}
	}
	
	if (!check_nodes(Fzone, Fnet, Fnode, Fpoint))
	{
		log_line(4,Logmessage[M__IMP_UNKNOWN], Fzone, Fnet, Fnode, Fpoint);
		Fsystem = UNKNOWN_SYSTEM;
	}
	else
		log_line(4,Logmessage[M__IMPORT_MESSAGES], Fzone, Fnet, Fnode, Fpoint);
	
	log_line(4,Logmessage[M__ASSEMBLED_ON],
		pktname, intel(phdr.ph_dy), intel(phdr.ph_mo)+1, intel(phdr.ph_yr),
		intel(phdr.ph_hr), intel(phdr.ph_mn), program);
	log_line(2,Logmessage[M__PACKET_SIZE], pktsize);
	
	if (!check_nodes(Tzone, Tnet, Tnode, Tpoint))
	{
		log_line(6,Logmessage[M__DESTANATION_ERROR], Tzone, Tnet, Tnode, Tpoint);
		
		Tsystem = UNKNOWN_SYSTEM;
		
		if (dosecure >= 3)
		{
			rename_pkt(buffer);
			return;
		}
	}
	
	/*
	**	Check for password in pktheader, but first search for
	**	origin address.
	*/
	
	if (Fsystem == OUR_SYSTEM)
	{
		for (i=0; i < nkey; i++)
		{
			if (Fzone == pwd[i].zone &&
				Fnet == pwd[i].net &&
				Fnode == pwd[i].node &&
				Fpoint == pwd[i].point) {
				
				break;
			}
		}
		
		if (i >= nkey) i = 0;
	}
	
	p = skip_blanks(phdr.ph_pwd);
	
	if (dosecure >= 2 && !strlen(p) && Fsystem == OUR_SYSTEM &&
		strlen(pwd[i].pwd))
	{
		log_line(6,Logmessage[M__PASSWORD_ERROR], "", pwd[i].pwd);
		rename_pkt(buffer);
		
		return;
	}
	
	/*
	**	Get password from header without spaces
	*/
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	if (dosecure >= 2 && Fsystem == OUR_SYSTEM)
	{
		if (stricmp (pwd[i].pwd, temp)) {
			log_line(6,Logmessage[M__PASSWORD_ERROR], temp, pwd[i].pwd);
			rename_pkt (buffer);
			return;
		}
		if (strnicmp (pwd[i].Domain, org_domain, 8)) {
			log_line (6, "-Domain is incorrect.");
			rename_pkt (buffer);
			return;
		}
	}
	
	/*
	**	Check deny flags
	*/
	
	if (DenyOk (Fzone, Fnet, Fnode, Fpoint) == FALSE && Fsystem == OUR_SYSTEM) {
		log_line (6, "*Packet denied.");
		rename_pkt (buffer);
		return;
	}

	/*
	**	Initialize files. Set them all to NULL. if opened then those
	**	files area not NULL.
	*/
	
	if (!first_pass)
		init_PKTS();
	else if (dofastimport == FALSE)
		init_PKTS();
	
	first_pass = 1;
	
	while (import_messages(buffer));
	
	if (PACKET) fclose(PACKET);
	
	/*
	**	If there was netmail, close the file.
	*/
	
#if !defined TEST_CRUNCH	
	unlink(buffer);
#endif
	
	if (dofastimport == FALSE)
		close_PKTS();	
}

/*
**	Rename *.PKT > *.BKT
*/

VOID rename_pkt(BYTE *oldname)
{
	BYTE	newname[128],
			*p;
	
	if (PACKET) fclose(PACKET);
	
	strcpy(newname, oldname);
	
	if ((p = strrchr(newname, '.')) == NULL )
	{
		log_line(6,Logmessage[M__CANT_RENAME], oldname);
		terminate(10);
	}
	
	strcpy (++p, "BAD");
/*	*++p = 'B';*/
	
	if (rename(oldname, newname))
	{
		log_line(6,Logmessage[M__CANT_RENAME], oldname);
		terminate(10);
	}
	
	log_line(6,Logmessage[M__BAD_PACKET_RENAME], oldname);
}

/*
**	Check if the node is an known node.
*/

BYTE check_nodes(UWORD zone, UWORD net, UWORD node, UWORD point)
{
	WORD	i;
	
	for (i=0; i < nalias; i++)
		if (zone == alias[i].zone &&
			net == alias[i].net &&
			node == alias[i].node &&
			!strnicmp (dest_domain, alias[i].Domain, 8)) return(TRUE);
	
	for (i=0; i < nkey; i++)
		if (zone == pwd[i].zone &&
			net == pwd[i].net &&
			node == pwd[i].node &&
			point == pwd[i].point &&
			!strnicmp (org_domain, pwd[i].Domain, 8)) return(TRUE);
	
	return(FALSE);
}

/*
**	import message
*/

BYTE import_messages(BYTE *pktname)
{
	WORD	i;
	
	hdrread(&pmsg, sizeof(struct _pktmsg), PACKET);
	if (feof(PACKET)) return(FALSE);
	
	if ((i = intel(pmsg.pm_ver)) != 2)
	{
		log_line(5,Logmessage[M__ILLEGAL_MESSAGE_TYPE]);
		
		if (!find_message())
		{
			rename_pkt(pktname);
			return(FALSE);
		}
	}
	
	fnet = intel(pmsg.pm_onet);
	fnode = intel(pmsg.pm_onode);
	
	tnet = intel(pmsg.pm_dnet);
	tnode = intel(pmsg.pm_dnode);
	
	/*
	**	Store the zonenumber what is found in header.
	*/
	
	if (!fzone) fzone = Fzone;
	if (!tzone) tzone = Tzone;
	
	fpoint = tpoint = 0;
	
	/*
	**	Get 3d numbers.
	*/
	
	for (i=0; i < nalias; i++)
		if (fnet == alias[i].pointnet)
		{
			fzone  = alias[i].zone;
			fpoint = fnode;
			fnet   = alias[i].net;
			fnode  = alias[i].node;
			
			break;
		}
	
	if (i >= nalias && !fpoint) fpoint = Fpoint;
	
	for (i=0; i < nalias; i++)
		if (tnet == alias[i].pointnet)
		{
			tzone	= alias[i].zone;
			tpoint	= tnode;
			tnet	= alias[i].net;
			tnode	= alias[i].node;
			
			break;
		}
	
	if (i >= nalias && !tpoint) tpoint = Tpoint;
	
#if defined EXTERNDEBUG
	if (debugflag)
	{
		log_line(6,">Message header contains :");
		log_line(6,">Org %u:%u/%u.%u -> %u:%u/%u.%u", fzone, fnet, fnode, fpoint, tzone, tnet, tnode, tpoint);
		log_line(6,">Strict : %u/%u -> %u/%u", intel(pmsg.pm_onet), intel(pmsg.pm_onode), intel(pmsg.pm_dnet), intel(pmsg.pm_dnode));
	}
#endif
	
	/*
	**	Get the from, to, topic and time field.
	*/
	
	if (!get_fields())
	{
		if (feof(PACKET)) return(FALSE);
		return(TRUE);
	}
	
	/*
	**	Now read the entire message.
	*/

#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Alloc messagebuffer");
			log_line(6,">Memory %ld", coreleft());
		}
#endif

	messagebuffer = (BYTE *) myalloc(MAXMSGLENGTH);
	
	read_message();
	
	messagebody = messagebuffer;
	
	/*
	**	Now handle the message body, and copy them.
	*/
	
	handle_message(pktname);

#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Free messagebuffer");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
	
	free(messagebody);
	
	if (!PACKET || feof(PACKET)) return(FALSE);
	
	if (dodiskcheck && !check_diskspace(0)) return(FALSE);
	
	return(TRUE);
}

BYTE find_field_end(VOID)
{
	WORD	i, j = 0;
	
	while ((i = getc(PACKET)) != 0)
	{
		j++;
		giveTIMEslice();
		
		if (feof(PACKET))
		{
			log_line(6,Logmessage[M__UNEXPECTED_END_PKT]);
			return(FALSE);
		}
		
		if (j > 100)
		{
			log_line(6,Logmessage[M__ERROR_MESSAGE]);
			
			while ((i = getc(PACKET)) != 2)
				giveTIMEslice();
				if (feof(PACKET))
				{
					log_line(6,Logmessage[M__DAMAGED_PACKET]);
					return(FALSE);
				}
			
			j = getc(PACKET);
			
			if (j)
			{
				log_line(6,Logmessage[M__DAMAGED_PACKET]);
				return(FALSE);
			}
			
			fseek(PACKET, ftell(PACKET)-2, SEEK_SET);
			return(FALSE);
		}
		
		if (i == 2)
		{
			i = getc(PACKET);
			
			if (!i)
			{
				fseek(PACKET, ftell(PACKET)-2, SEEK_SET);
				log_line(6,Logmessage[M__UNEXPECTED_END_MSG]);
				return(FALSE);
			}
		}
	}
	
	return(TRUE);
}

/*
**	Get the from, to, topic and time fields from the packet
**	into global chars.
*/

BYTE get_fields(VOID)
{
	WORD	i, j = 0;
	BYTE	temp[80],
			*q = temp;
	
	while ((i = getc(PACKET)) != 0)
	{
		*q++ = i;
		j++;
		giveTIMEslice();
		
		if (j > 19)
		{
			if (!find_field_end()) return(FALSE);
			break;
		}
	}
	
	*q = EOS;
	
	/*
	**	If no time field, create one.
	*/
	
	if (!strlen(temp))
	{
		time(&secs);
		tijd = localtime(&secs);
		strftime(mtime, 20, "%d %b %y %H:%M:%S", tijd);
	}
	else strcpy(mtime,temp);
	
	q = temp;
	j = 0;
	
	while ((i = getc(PACKET)) != 0)
	{
		*q++ = i;
		j++;
		
		if (j > 31)
		{
			if (!find_field_end()) return(FALSE);
			break;
		}
	}
	
	*q = EOS;
	
	/*
	**	If no to field, copy 'All' to it.
	*/
	
	if (!strlen(temp)) strcpy(mto, "All");
	else strcpy(mto, temp);
	
	q = temp;
	j = 0;
	
	while ((i = getc(PACKET)) != 0)
	{
		*q++ = i;
		j++;
		
		if (j > 31)
		{
			if (!find_field_end()) return(FALSE);
			break;
		}
	}
	
	*q = EOS;
	
	/*
	**	If no from field copy unknown
	*/
	
	if (!strlen(temp)) strcpy(mfrom, "Unknown");
	else strcpy(mfrom, temp);
	
	/*
	**	Now for the topic.
	*/
	
	q = temp;
	j = 0;
	
	while ((i = getc(PACKET)) != 0)
	{
		*q++ = i;
		j++;
		
		if (j > 71)
		{
			if (!find_field_end()) return(FALSE);
			break;
		}
	}
	
	*q = EOS;
	
	if (strlen(temp)) strcpy(mtopic, temp);
	else *temp = EOS;
	
	return(TRUE);
}

/*
**	Read the message byte for byte.
*/

VOID read_message(VOID)
{
	WORD	i, j, c = 0;
	BYTE	*q = messagebuffer;
	
#if defined DEBUG
	printf("*Reading message.\n");
#endif
	
	while ((i = getc(PACKET)) != 0 && c < MAXMSGLENGTH)
	{
		/*
		**	Not 0 terminated and end of file reached. Returning with
		**	we have already.
		*/

		giveTIMEslice();
		
		if (feof(PACKET))
		{
			log_line(6,Logmessage[M__UNEXPECTED_END_PKT]);
			return;
		}
		
		/*
		**	This tokens are not needed in a message.
		*/
		
		if (i == 0x8d || i == 0x8f || i == 0x7f) continue;
		
		/*
		**	If we have found 0x02 then this can be the start of the
		**	next message header. Maybe they have only 0x02 and the
		**	next byte is an normal token, not 0, then continue reading.
		*/
		
		if (i == 2)
		{
			j = getc(PACKET);
			
			/*
			**	It is indeed the start of an next message.
			*/
			
			if (!j)
			{
				log_line(6,Logmessage[M__UNEXPECTED_END_MSG]);
				fseek(PACKET, ftell(PACKET)-2, SEEK_SET);
				*q = EOS;
				return;
			}
			
			/*
			**	Carriage return ? will be linefeed.
			*/
			
			if (i != '\n')
			{
				if (i == '\r') i = '\n';
				*q++ = i;
			} 
			
			if (j != '\n')
			{
				if (j == '\r') j = '\n';
				*q++ = j;
			}
			
			c += 2;
		}
		
		if (i != '\n')
		{
			if (i == '\r') i = '\n';
			*q++ = i;
		}
		
		c++;
	}
	
	if (c >= MAXMSGLENGTH - 200)
	{
		log_line(6,Logmessage[M__MSG_TO_LONG]);
		q = &messagebuffer[MAXMSGLENGTH - 250];
		q = skip_to_blank(q);
	}
	
	/*
	**	And terminate the message.
	*/
	
	*q = EOS;
	
#if defined DEBUG
	printf("*Got message.\n");
#endif
}

/*
**	Finding the next message header is a tough thing. Trying to find
**	the pkt header type 2.
*/

BYTE find_message(VOID)
{
	WORD	i, j;
	LONG	z = 1;
	
	fseek(PACKET, (ftell(PACKET) - sizeof(struct _pktmsg))+1, SEEK_SET);
	i = getc(PACKET);
	
	while (!feof(PACKET))
	{
		giveTIMEslice();
		if (feof(PACKET))
		{
			log_line(5,Logmessage[M__END_OF_PACKET], z);
			return(FALSE);
		}
		
		/*
		**	If we found it read the PKT header and return 1.
		*/
				
		if (i == 2)
		{
			j = getc(PACKET);
			
			if (!j)
			{
				log_line(4,Logmessage[M__MSG_FOUND], z);
				
				fseek(PACKET, (ftell(PACKET) - 2L), SEEK_SET);
				hdrread(&pmsg, sizeof(struct _pktmsg), PACKET);
				
				return(TRUE);
			}
			
			ungetc(j, PACKET);
		}
		
		/*
		**	And get 1 bytes again.
		*/
		
		i = getc(PACKET);
		z++;
	}
	
	log_line(6,Logmessage[M__NO_MSG_ANYMORE], z);
	
	return(FALSE);
}

/*
**	Handle the message and save it.
*/

VOID handle_message(BYTE *pktname)
{
	WORD	i, j,
			toarea = -1,
			oldarea;
	UWORD	fmpt, topt,						/* FMPT, TOPT		*/
			izone, inet, inode,				/* INTL line?		*/
			mzone, mnet, mnode, mpoint;		/* MSGID			*/
	BYTE	*newmsg,
			*p, *q,
			*expmsg,
			temp[100],
			oldname[100],
			buffer[250],
			bounced_message = FALSE,		/* Message bounced?	*/
			Unknown_area = FALSE,
			*area;							/* Areaname			*/
	MSGHEADER	fhdr;						/* Message header	*/
	
	memset(&fhdr, 0, sizeof(MSGHEADER));
	
	for (i=0; i < nalias; i++)
		if (fnet == alias[i].pointnet && fzone == alias[i].zone)
		{
			fnet = alias[i].net;
			fnode =alias[i].node;
			fpoint = fnode;
			break;
		}
	
	for (i=0; i < nalias; i++)
		if (tnet == alias[i].pointnet && tzone == alias[i].zone)
		{
			tnet = alias[i].net;
			tnode= alias[i].node;
			tpoint = tnode;
			break;
		}
	
	fhdr.Ozone = fzone;
	fhdr.Onet = fnet;
	fhdr.Onode = fnode;
	fhdr.Opoint = fpoint;
	
	fhdr.Dzone = tzone;
	fhdr.Dnet = tnet;
	fhdr.Dnode = tnode;
	fhdr.Dpoint = tpoint;
	
	strcpy(fhdr.from, mfrom);
	strcpy(fhdr.to, mto);
	strcpy(fhdr.topic, mtopic);
	strcpy(fhdr.time, mtime);
	
	fhdr.create = time(NULL);
	fhdr.flags = intel(pmsg.pm_attr);
	
	fhdr.flags &= ~ ALLBITS;
	
	/*
	**	Calculate reply chain CRCs
	*/

#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6, ">Get reply chain");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
	
	reply_chain(messagebody, &fhdr, UPCOST);
	
	
	/*
	**	Get destination area
	*/
	
	area = get_area(messagebody);

#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6, ">Have area %s", (area != NULL) ? area : "MAIL");
		}
#endif
	
	if (area != NULL)
		for (i=0; i < msgareas; i++)
			if (!stricmp(area, Areaname[i]))
			{
				if (!stricmp(area, "MAIL"))
				{
					area = NULL;
					break;
				}
				
				toarea = i;
				hprintf(S_AREA, "%s", area);
				hprintf (S_COMMENT, "Importing echomail.");
				break;
			}
	
	hprintf(S_DEST, "%u:%u/%u.%u", fhdr.Dzone, fhdr.Dnet,
		fhdr.Dnode, fhdr.Dpoint);
	hprintf(S_FROM, "%u:%u/%u.%u", fhdr.Ozone, fhdr.Onet,
		fhdr.Onode, fhdr.Opoint);

	/*
	**	Save it for later. If arealine found and the area is not
	**	found in the AREAS.BBS save this message to trasharea.
	*/
	
	if (area != NULL && i >= msgareas) {
		Unknown_area = TRUE;
		toarea = -2;
	}
	
	/*
	**	If we want the realname and in the message is ^aREALNAME:
	**	copy it
	*/
	
	strcpy(oldname, fhdr.from);
	
	if (dorealname & REALIN && (p = strline(messagebody, "\01REALNAME:")) != NULL)
	{
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6, ">Have REALNAME kludge");
		}
#endif
		p = skip_to_token(p, ':');
		p = skip_blanks(p);
		
		for (q = temp; *p && *p != '\n'; *q++ = *p++);
		*q = EOS;
		
		strcpy(fhdr.from, temp);
	}

	giveTIMEslice();
	
	/*
	**	This is netmail. Get INTL, TOPT and FMPT.
	**	-----------------------------------------
	*/
	
	if (area == NULL)
	{
		/*
		**	Get From point.
		*/
		
		hprintf (S_COMMENT, "Importing NETMAIL");
		
		fmpt = get_point(messagebody, "\01FMPT");
		
		if (fmpt == (UWORD)-1) fmpt = get_point(messagebody, "FMPT");
		if (fmpt != (UWORD)-1) fhdr.Opoint = fmpt;
		
		/*
		**	and To point.
		*/
		
		topt = get_point(messagebody, "\01TOPT");
		
		if (topt == (UWORD)-1) topt = get_point(messagebody, "TOPT");
		if (topt != (UWORD)-1) fhdr.Dpoint = topt;
		
		if (get_interzone(messagebody, &mzone, &mnet, &mnode, &izone, &inet, &inode))
		{
			for (i=0; i < nalias; i++)
				if (inet == alias[i].pointnet &&
					inode == alias[i].point &&
					izone == alias[i].zone) break;
			
			if (i >= nalias)
			{
				fhdr.Dzone = izone;
				fhdr.Dnet = inet;
				fhdr.Dnode = inode;
			}
			else
			{
				fhdr.Dzone = alias[i].zone;
				fhdr.Dnet = alias[i].net;
				fhdr.Dnode = alias[i].node;
				fhdr.Dpoint = alias[i].point;
			}
			
			for (i=0; i < nalias; i++) {
				if (mnet == alias[i].pointnet &&
					mzone== alias[i].zone) break;
			}
			
			if (i >= nalias) {
				fhdr.Ozone = mzone;
				fhdr.Onet = mnet;
				fhdr.Onode = mnode;
			} else {
				fhdr.Ozone = alias[i].zone;
				fhdr.Onet  = alias[i].net;
				fhdr.Onode = alias[i].node;
				fhdr.Opoint= mnet;
			}
		}
		
		if (domsg)
		{
			i = get_reply(messagebody, &mzone, &mnet, &mnode, &mpoint);
			
			if (i && mzone != fhdr.Ozone && mnet != fhdr.Onet &&
				mnode != fhdr.Onode && mpoint != fhdr.Opoint)
			{
				fhdr.Dzone = mzone;
				fhdr.Dnet = mnet;
				fhdr.Dnode = mnode;
				fhdr.Dpoint = mpoint;
			}
			
			i = get_msgid(messagebody, &mzone, &mnet, &mnode, &mpoint);
			
			if (i && mzone != fhdr.Dzone && mnet != fhdr.Dnet &&
				mnode != fhdr.Dnode && mpoint != fhdr.Dpoint)
			{
				fhdr.Ozone = mzone;
				fhdr.Onet = mnet;
				fhdr.Onode = mnode;
				fhdr.Opoint = mpoint;
			}
		}
		
		hprintf(S_DEST, "%u:%u/%u.%u", fhdr.Dzone, fhdr.Dnet,
			fhdr.Dnode, fhdr.Dpoint);
		hprintf(S_FROM, "%u:%u/%u.%u", fhdr.Ozone, fhdr.Onet,
			fhdr.Onode, fhdr.Opoint);
		
		messagebuffer = strip_cr(messagebuffer);
		
		/*
		**	Check on right route if point is 0 and name is
		**	not sysop name.
		*/
		
		if (docheckname) {
		/*
			if (stricmp(fhdr.to, SysOp) && stricmp(fhdr.to, "sysop") &&
				!fhdr.Dpoint)
		*/
			for (i=0; i < nkey; i++)
			{
				if (!stricmp(fhdr.to, pwd[i].Uname) &&
					pwd[i].zone == fhdr.Dzone && 
					!strnicmp (pwd[i].Domain, dest_domain, 8))
				{
					fhdr.Dzone = pwd[i].zone;
					fhdr.Dnet = pwd[i].net;
					fhdr.Dnode = pwd[i].node;
					fhdr.Dpoint = pwd[i].point;
					break;
				}
			}
		}
		
		/*
		**	Readdress mail.
		*/
		
		DO_readdress (&fhdr, messagebuffer);
		
		/*
		**	And print the numbers.
		*/
		
		if (!doniceout && !doquit)
		{
			gprintf("%-20.20s %-20.20s MAIL %u:%u/%u.%u > %u:%u/%u.%u\n",
				fhdr.from, fhdr.to,
				fhdr.Ozone, fhdr.Onet, fhdr.Onode, fhdr.Opoint,
				fhdr.Dzone, fhdr.Dnet, fhdr.Dnode, fhdr.Dpoint);

		}
		else
		{
			log_line(3,Logmessage[M__NETMAIL_MSG],
				mfrom, mto, fhdr.Ozone, fhdr.Onet, fhdr.Onode, fhdr.Opoint,
				fhdr.Dzone, fhdr.Dnet, fhdr.Dnode, fhdr.Dpoint);
		}
/*		
		if (doquit)
			hprintf(S_COMMENT, "%-20s %-20s", mfrom, mto);
*/		
		/*
		**	Hier stond het killsend gedoe. Verplaatst naar beneden na
		**	het schrijven van de pkt.
		*/
				
		if (!strlen(messagebuffer))
		{
			/*
			**	Deze berichten, die leeg zijn, bevatten meestal
			**	een fileattach van een DOS util zoals TIC.
			**	In de toekomst kan hier een soort filemanager staan.
			*/
			
			log_line(4,Logmessage[M__EMPTY_MSG]);
			strcpy(messagebuffer, "---\n");
		}
		
		strcat(messagebuffer, "\n");
		
		if (doknown && dopkt)
			pack_netmail(&fhdr, messagebuffer);

		/*
		**	KILLSEND messages which are not for us or our points
		**	and not adressed to us of our points.
		**	If dokillall is true, kill all mail not from/to us.
		**	Also points.
		**
		**	ATTENTIE, onderstaande code is verplaatst.
		*/
		
		if ((dokillsent || dokillall) &&
			ouralias(fhdr.Dzone, fhdr.Dnet, fhdr.Dnode, (dokillall) ? fhdr.Dpoint : 0) &&
			ouralias(fhdr.Ozone, fhdr.Onet, fhdr.Onode, (dokillall) ? fhdr.Opoint : 0))
		{
		 	if (dopkt)
		 		fhdr.flags |= DELETED;
		 	else
		 		fhdr.flags |= KILLSEND;
		}
		
		savemsg(TONETMAIL, &fhdr, 0, messagebuffer, 0, 0, 0, 0);
		nnetmails++;
		nimported++;
		
		hprintf(S_IMP, "%d", nimported);
		hprintf(S_NETMAIL, "%d", nnetmails);
		
		if (!stricmp(fhdr.to, SysOp) || !stricmp(fhdr.to, "sysop"))
		{
			nnet_priv++;
			nprivate++;
			
			hprintf(S_SYSOP, "%d", nprivate);
			
			if (dopvtmail)
				savemsg(TOPRIVATE, &fhdr, -1, messagebuffer, 0, 0, 0, 0);
		}

#if defined AREAFIX
		if (areafix_on && (!strnicmp (fhdr.to, "areafix", 7) || 
			!strnicmp (fhdr.to, "IOSmail", 7))) {
			consult_areafix(&fhdr, messagebuffer);
		} else 
#endif
			if (doareafix && !strnicmp(hdr.to, "areafix", 7)) areafixmsgs ++;
		
		return;
	}

	/*
	**	We are importing from inbound ?
	**	If we are using several inbounds then...
	*/
	
	if (we_have_inbound == KNOWNINBOUND) toarea = -2;
	
	if (we_have_inbound == NORMALINBOUND)
	{
		rename_pkt(pktname);
		PACKET = NULL;
		return;
	}
	
	/*
	**	If it's possible that zone addressing is mixed,we searching
	**	than for the correct zone.
	*/
	
	if (domulti_reg)
	{
		
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Mixed multizone check:");
			log_line(6,">Was : %u:%u/%u.%u ->%u:%u/%u.%u", fhdr.Ozone, fhdr.Onet, fhdr.Onode, fhdr.Opoint, fhdr.Dzone, fhdr.Dnet, fhdr.Dnode, fhdr.Dpoint);
		}
#endif
		if (other_zone((UWORD *) &fhdr.Dzone, (UWORD *) &fhdr.Dnet,
			(UWORD *) &fhdr.Dnode, (UWORD *) &fhdr.Ozone,
			(UWORD *) &fhdr.Onet, (UWORD *) &fhdr.Onode) == 1)
			log_line(4,Logmessage[M__ORG_ADDRESS_UNKNOWN]);
		
#if defined EXTERNDEBUG
		if (debugflag) log_line(6,">Is : %u:%u/%u.%u ->%u:%u/%u.%u", fhdr.Ozone, fhdr.Onet, fhdr.Onode, fhdr.Opoint, fhdr.Dzone, fhdr.Dnet, fhdr.Dnode, fhdr.Dpoint);
#endif
	}
	
	/*
	**	Starting here to import in the normal echomail area's
	**	-----------------------------------------------------
	**
	**	If the sender using our alias, this could be an 4 dim. address
	**	with an FMPT line in the message. Only is the destination is
	**	0, thus no point.
	*/
	
	if (!ouralias(fhdr.Ozone, fhdr.Onet, fhdr.Onode, fhdr.Opoint))
	{
		/*
		**	If we are an point, and no pointnumber at our system
		**	get TOPT.
		*/
		
		if (!fhdr.Dpoint)
		{
			topt = get_point(messagebody, "\01TOPT");
			
			if (topt == (UWORD)-1) topt = get_point(messagebody, "TOPT");
			if (topt != (UWORD)-1) fhdr.Dpoint = tpoint = topt;
		}
		
		/*
		**	Origin have point number 0 and the nodenumber is our
		**	alias.
		*/
		
		fmpt = get_point(messagebody, "\01FMPT");
		
		if (fmpt == (UWORD)-1)
			if ((fmpt = get_point(messagebody, "FMPT")) == (UWORD)-1)
			{
				/*
				**	We don't find any FMPT line. He is using our node
				**	number. Maybe an INTL line ?
				*/
				
				if (get_interzone(messagebody, &mzone, &mnet, &mnode,
					&izone, &inet, &inode))
				{
					fhdr.Dzone = izone;
					fhdr.Dnet = inet;
					fhdr.Dnode = inode;
					
					fhdr.Ozone = mzone;
					fhdr.Onet = mnet;
					fhdr.Onode = mnode;
				}
			}
			else fhdr.Opoint = fpoint = fmpt;
		else fhdr.Opoint = fpoint = fmpt;
		
		/*
		**	It's impossible that this message is from point to point.
		**	Check our aliases if this message is from an point.
		*/
		
		if (fhdr.Opoint && fhdr.Dpoint)
		{
			for (i=0; i < nalias; i++)
				if (alias[i].zone == fhdr.Dzone &&
					alias[i].net == fhdr.Dnet &&
					alias[i].node == fhdr.Dnode &&
					alias[i].point == fhdr.Dpoint)
				{
					/*
					**	The destination is a point, not a node.
					*/
				
					fhdr.Opoint = 0;
					break;
				}
			
			/*
			**	The destination is an node, not a point.
			*/
			
			if (i >= nalias) fhdr.Dpoint = 0;
		}
		hprintf(S_DEST, "%u:%u/%u.%u", fhdr.Dzone, fhdr.Dnet,
			fhdr.Dnode, fhdr.Dpoint);
		hprintf(S_FROM, "%u:%u/%u.%u", fhdr.Ozone, fhdr.Onet,
			fhdr.Onode, fhdr.Opoint);
	}
	else
		if (get_interzone(messagebody, &mzone, &mnet, &mnode, &izone, &inet, &inode))
			for (i=0; i < nalias; i++)
				if ((izone == alias[i].zone && inet == alias[i].net && inode == alias[i].node) ||
					(inet == alias[i].pointnet && inode == alias[i].point))
				{
					fmpt = get_point(messagebody, "\01FMPT");
					topt = get_point(messagebody, "\01TOPT");
					
					if (inet != alias[i].pointnet)
					{
						fhdr.Dzone = izone;
						fhdr.Dnet = inet;
						fhdr.Dnode = inode;
						
						if (topt != (UWORD)-1) fhdr.Dpoint = topt;
					}
					else
					{
						fhdr.Dzone = alias[i].zone;
						fhdr.Dnet = alias[i].net;
						fhdr.Dnode = alias[i].node;
						fhdr.Dpoint = inode;
					}
					
					for (j=0; j < nkey; j++)
						if (pwd[j].zone == mzone && pwd[j].net == mnet && pwd[j].node == mnode)
						{
							fhdr.Ozone = mzone;
							fhdr.Onet = mnet;
							fhdr.Onode = mnode;
							
							if (fmpt != (UWORD)-1 &&
								fmpt == pwd[j].point) fhdr.Opoint = fmpt;
							
							break;
						}
				}
					
	/*
	**	Security.
	**
	**	If system where message(s) come from are echomail
	**	message(s), then the message(s) are in the trasharea.
	*/
	
	if (dosecure && area != NULL && Fsystem == UNKNOWN_SYSTEM)
		toarea = -2;
	
	/*
	**	If messages in an area where the sender is not connected to
	**	then his message(s) are in the trasharea.
	*/
	
	if (dosecure && area != NULL && toarea != -1 && toarea != -2 &&
		!get_secure(toarea, fhdr.Ozone, fhdr.Onet, fhdr.Onode, fhdr.Opoint))
	{
		log_line(4,Logmessage[M__NOT_CONNECTED],
			fhdr.Ozone, fhdr.Onet, fhdr.Onode, fhdr.Opoint, area);
		
		toarea = -2;
	}
	
	/*
	**	Get the ^aMSGID an ^aREPLY if wanted.
	*/
	
	if (domsg)
	{
		i = get_reply(messagebody, &mzone, &mnet, &mnode, &mpoint);
		
		if (i)
		{
			fhdr.Dzone = mzone;
			fhdr.Dnet = mnet;
			fhdr.Dnode = mnode;
			fhdr.Dpoint = mpoint;
		}
		
		i = get_msgid(messagebody, &mzone, &mnet, &mnode, &mpoint);
		
		if (i)
		{
			fhdr.Ozone = mzone;
			fhdr.Onet = mnet;
			fhdr.Onode = mnode;
			fhdr.Opoint = mpoint;
		}
		hprintf(S_DEST, "%u:%u/%u.%u", fhdr.Dzone, fhdr.Dnet,
			fhdr.Dnode, fhdr.Dpoint);
		hprintf(S_FROM, "%u:%u\%u.%u", fhdr.Ozone, fhdr.Onet,
			fhdr.Onode, fhdr.Opoint);
	}

	/*
	**	Duplicate msg test
	*/
	
	if (doNOdupecheck == FALSE) {
		if (get_dupes(messagebody, toarea) == TRUE) {
			log_line(4,Logmessage[M__DUP_MSG],fhdr.from, 
				(toarea >= 0) ? Areaname[toarea] : "TRASH");
			dupesave(&fhdr, messagebody);
			HaveDUPES = TRUE;
			hprintf(S_COMMENT, "Duplicate message.");
			return;
		}
	}
	
	if (!doniceout && !doquit) {
		gprintf("%-20.20s %-20.20s %20.20s\n", mfrom, mto, area);
	} else if (StatusScreen)
		log_line(4,"*%-15.15s > %-15.15s %-15.15s", mfrom, mto, area);
/*	
	if (doquit)
		hprintf (S_COMMENT, "%-20s %-20s", mfrom, mto);
*/	
	/*
	**	Not allowed to send echomail? Trash his mail.
	*/
	
	for (i=0; i < nkill; i++)
		if (!stricmp(fhdr.from, Killfrom[i]))
		{
			if (!doniceout && !doquit) {
				gprintf("Kill");
			} else
				log_line(2,Logmessage[M__TRASH_MSG]);
			
			toarea = -1;
			break;
		
		}
		
	/*
	**	Normal mail. Import it in the echomail areas and export it
	**	if we have nodes and points under us.
	*/
	
	if (toarea != -1 && toarea != -2)
	{
	
		/*
		**	If auto added, start here again.
		*/
		
		AUTO_area:
		
		/*
		**	Get the pathlines.
		*/
		
		expmsg = skip_to_token(messagebody, '\n');
		
		npath = 0;
		get_path(messagebody, toarea);

		/*
		**	If message from our points, check the path on illegal
		**	PATH number.
		*/
		
		if (npath <= 1) redo_PATH();
		
		/*
		**	Check ^aPATH. If message is bounced, don't send
		**	the message to an other node.
		*/
		
		if (dopathcheck && !checkPATH) bounced_message = TRUE;
		
		nseenby = 0;
		
		get_seen(messagebody, toarea);
		get_org_and_tearline(messagebody);
		
		if (strlen (org_domain))
			i = ourseen (toarea, 1, &fhdr, org_domain);
		else
			i = ourseen(toarea, 1, &fhdr, NULL);

#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Alloc newmsg");
			log_line(6,">Memory %ld", coreleft());
		}
#endif

		newmsg = (BYTE *) myalloc(MAXMSGLENGTH);

		if (dostripINTL) {		
			expmsg = strip_line(expmsg, "\01FMPT");
			expmsg = strip_line(expmsg, "\01TOPT");
			expmsg = strip_line(expmsg, "\01INTL");
		}
		
		strcpy(newmsg, expmsg);
		
		newmsg = strip_line(newmsg, "\01EID:");
		
		/*
		** If the origin line doesn't contain an linefeed,
		** add an linefeed. Needed for RA echo.
		**	Eruit gehaald omdat berichten onder een SEEN-BY niet
		**	meer te zien waren.
		*/

/*		
		p = strstr(newmsg,"SEEN-BY");
		if (p) {
			p--;
			if (*p == '\n' || *p == '\r')
				*p = EOS;
			if (*p == '\01') *p = EOS;
		}
*/
		
		if (newmsg[ strlen(newmsg) - 1 ] != '\n') strcat(newmsg,"\n");
		
		Addline(newmsg, (doifna) ? "\01SEEN-BY" : "SEEN-BY:", i-1, tzone);
		
		if (strlen (org_domain))
			i = ourpath (toarea, org_domain);
		else
			i = ourpath(toarea, NULL);
		
		Addline(newmsg, "\01PATH:", i-1, tzone);
		
		Areamsgs[toarea]++;
		
		if (!stricmp(fhdr.to, SysOp))
		{
			Tosysop[toarea]++;
			
			if (toprivate || dopvtmail)
			{
				nprivate++;
				hprintf (S_SYSOP, "%d", nprivate);
				
				if (get_msgid(messagebody, &mzone, &mnet, &mnode, &mpoint))
				{
					fhdr.Ozone = mzone;
					fhdr.Onet = mnet;
					fhdr.Onode = mnode;
					fhdr.Opoint = mpoint;
				}
				
				savemsg(TOPRIVATE, &fhdr, toarea, newmsg, fzone, fnet, fnode, fpoint);
			}
		}
		
		/*
		**	Move this area ?
		*/
		
		oldarea = toarea;
		
		if (dofastimport == FALSE)		
			toarea = move_area(toarea, &fhdr);

		/*
		**	Save message to local areas.
		** 	If copyarea the copy this area.
		*/
		
		ToCopy = 0;
		
		if (!Dareas[toarea]) {
			savemsg (TOLOCAL, &fhdr, toarea, newmsg, fzone, fnet, fnode, fpoint);
			while ((i = copy_area(toarea, &fhdr)) != FAILURE) {
				savemsg (TOLOCAL, &fhdr, i, newmsg, fzone,fnet, fnode, fpoint);
			}
		}
		
		toarea = oldarea;

		/*
		** Increment of number of imported messages.
		*/
		
		nimported++;
		
		hprintf(S_IMP, "%d", nimported);
		
		/*
		** Message belongs also to database ?
		*/
		
		if (nfdbase) {
			for (i=0; i < nfdbase; i++) {
				if (FDcompare[i] == FD_FROM) {
					if (!stricmp(fhdr.from,ToBase[i])) {
						
						write_to_database:
						
						log_line(2,Logmessage[M__MSG_TO_DATABASE]);
						ToDataBase(&fhdr, newmsg, toarea);
								
						continue;
					}
				}
				if (FDcompare[i] == FD_TO) {
					if (!stricmp(fhdr.to,ToBase[i])) {
						goto write_to_database;
					}
				}
			}
		}
		
		/*
		**	If doing fastimport, return.
		*/
		
		if (dofastimport == TRUE) {
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Free newmsg");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
			free(newmsg);
			free(area);
			return;
		}
		
		/*
		**	If message is bounced back, don't export the message.
		*/
		
		if (bounced_message) {
			free (newmsg);
			free (area);
#if defined EXTERNDEBUG
			if (debugflag) {
				log_line(6, ">Free newmsg.");
				log_line(6 ,">Memory %ld", coreleft());
			}
#endif
			return;
		}
		
		/*
		** Read only area ?
		*/
		
		if (Read_only[toarea] == READ_ONLY) {
			free (newmsg);
			free (area);
#if defined EXTERNDEBUG
			if (debugflag) {
				log_line(6, ">Free newmsg.");
				log_line(6 ,">Memory %ld", coreleft());
			}
#endif
		
			return;
		}
		
		if (Read_only[toarea] == REMOTE_ONLY) {
			if (Not_allowed(messagebody, toarea) == FALSE) {
				free (newmsg);
				free (area);
	#if defined EXTERNDEBUG
				if (debugflag) {
					log_line(6, ">Free newmsg.");
					log_line(6 ,">Memory %ld", coreleft());
				}
	#endif
				
				return;
			}
		}
		
		/*
		**	Copy the oldname into the header again.
		*/
		
		strcpy(fhdr.from, oldname);
		
		/*
		**	Strip some lines.
		*/
		
		if (dostripINTL) {
			messagebuffer = strip_line(messagebuffer, "\01FMPT");
			messagebuffer = strip_line(messagebuffer, "\01TOPT");
			messagebuffer = strip_line(messagebuffer, "\01INTL");
		}
		
		/*
		**	If we have nodes and points under us then export it to
		**	them to.
		*/
		
#if defined DEBUG
		printf("*Pack for others.\n");
#endif		

		packmail(toarea, nseenby, expmsg, &fhdr);
		
		ToCopy = 0;
		
		if(dopointcpy == TRUE) {
			while(( i = copy_area(toarea,&fhdr)) != FAILURE) {
				log_line(3,Logmessage[M__COPY_TO],Areaname[i]);
			
				packmail(i, nseenby, expmsg, &fhdr);
			}
		}
		
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Free newmsg");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
		free(newmsg);
		free(area);
		
		return;
	}
	
	/*
	**	If area was unknown.
	*/
	
	if (Unknown_area == TRUE && doAUTOaddareas) {
		toarea = ADDarea(area);
		if (toarea > 0)
			goto AUTO_area;
	}
	
	if (!doniceout && !doquit) {
		gprintf("Trashed.");
	}
	
	nimported++;
	ntrashed ++;
	
	hprintf(S_IMP, "%d", nimported);
	hprintf(S_TRASH,"%d",ntrashed);
	hprintf(S_COMMENT, "Importing trashed.");
	
	savemsg(TOTRASH, &fhdr, 0, messagebody, 0, 0, 0, 0);
	free (area);
}

/*
**	The messageheader doesn't contain an zonenumber. There are
**	utils that's mixing zonenumbers when using multizone in the
**	same packet. The Packet header contains an other zonenumber
**	then the message must be stored. It's not realy right
**	solution to search for the net and nodenumber. I can take
**	for example the INTL line, but than we have problems with
**	D'Bridge. This routine is only used with normal echomail and
**	not for netmail.
*/

WORD other_zone(UWORD *tozone, UWORD *tonet, UWORD *tonode,
				UWORD *fromzone, UWORD *fromnet, UWORD *fromnode)
{
	WORD	i, j, retcode = 0;
	
	for (i=0; i < nalias; i++)
	{
		if (*tonode == alias[i].node && *tonet == alias[i].net)
		{
			/*
			**	This is our nodenumber.
			*/
			
			*tozone = alias[i].zone;
			
			if (Tzone != *tozone)
			{
				Tzone = tzone = *tozone;
				Tnet = tnet;
				Tnode = tnode;
				Tpoint = tpoint;
			}
			
#if defined EXTERNDEBUG
			if (debugflag) log_line(6,">Found Dzone %u at node %u/%u", Tzone, Tnet, Tnode);
#endif			
			retcode++;
			
			break;
		}
	}
	
	for (i=0; i < nkey; i++)
	{
		if (*fromnet == pwd[i].net && *fromnode == pwd[i].node)
		{
			*fromzone = pwd[i].zone;
			retcode++;
			
			if (Fzone != *fromzone)
			{
				Fzone = fzone = *fromzone;
				Fnode = fnode;
				Fnet = fnet;
				Fpoint = fpoint;
			}
			
			/*
				Added for D'Bridge.
				D'Bridge seems to send his own zonenumber correctly,
				but doesn't set the destanation correct and shows an
				main zone, in example 2 instead of 66.
				66:666/229 to
				2:280/301.1
			*/
			
			if (tzone != fzone) {
				for (j = 0; j < nalias ; j++) {
					if (fzone == alias[j].zone) {
						Tzone = tzone = alias[j].zone;
						Tnet  = tnet  = alias[j].net;
						Tnode = tnode = alias[j].node;
						Tpoint= tpoint= alias[j].point;
						break;
					}
				}
			}
			
#if defined EXTERNDEBUG
			if (debugflag) log_line(6,">Found Ozone %u at node %u/%u", Fzone, Fnet, Fnode);
#endif			
			break;
		}
	}
	
	return(retcode);
}

/*
**	Get our alias.
*/

BYTE ouralias(UWORD zone, UWORD net, UWORD node, UWORD point)
{
	WORD	i;
	
	/*
	**	Check aliases.
	*/
	
	for (i=0; i < nalias; i++)
		if (alias[i].zone == zone &&
			alias[i].net == net &&
			alias[i].node == node && !point &&
			!strnicmp (dest_domain, alias[i].Domain, 8)) return(FALSE);
	
	return(TRUE);
}

BYTE *strip_cr(BYTE *l)
{
	while (*l)
	{
		if (*l == '\n' || *l == '\r') l++;
		if (*l != '\n' && *l != '\r' || !*l) break;
	}
	
	return(l);
}

/*
**	Add seen-by. Add our nodenumber first.
*/

WORD ourseen(WORD area, UWORD point, MSGHEADER *hdr, BYTE *Odomain)
{
	WORD	i, j, z, x,
			used_aka;
	UWORD	fake,
			use_zone;
	
	/*
	**	We are working in zone ??
	*/
	
	use_zone = Tozone[area][0];
	
	for (i=0; i < nalias; i++) {
		
		if (use_zone == alias[i].zone) 
		{
			
			if (Odomain != NULL) {
				if (strlen (Odomain)) {
					if (strncmp (Odomain, alias[i].Domain, 8)) {
						continue;
					}
				}
			}			
			
#if defined EXTERNDEBUG
			if (debugflag)
			{
				log_line(6,">Add OURSEENS, have zone %u, point = %u", alias[i].zone, point);
				log_line(6,">Org %u:%u/%u.%u -> %u:%u/%u.%u", hdr->Ozone, hdr->Onet, hdr->Onode, hdr->Opoint, hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Dpoint);
			}
#else
			hdr->Ozone += 0;
#endif
			
			if (alias[i].net == Tnet && alias[i].node == Tnode &&
				alias[i].zone == Tzone && alias[i].point== Tpoint)
			{
				fake = alias[i].pointnet;
				
#if defined EXTERNDEBUG
				if (debugflag) log_line(6,">OURSEEN using Dest. %u:%u/%u.%u (%u)", alias[i].zone, alias[i].net, alias[i].node, alias[i].point, alias[i].pointnet);
#endif	
				break;
			}
			
			if (alias[i].net == Fnet && alias[i].node == Fnode &&
				alias[i].zone == Fzone && alias[i].point== Fpoint)
			{
				fake = alias[i].pointnet;
				
#if defined EXTERNDEBUG
				if (debugflag) log_line(6,">OURSEEN using Org. %u:%u/%u.%u (%u)", alias[i].zone, alias[i].net, alias[i].node, alias[i].point, alias[i].pointnet);
#endif	
				break;
			}
		}
	}
	
	
	if (i >= nalias)
	{
		for (i = 0; i < nalias; i++) {
			if (Tozone[area][0] == alias[i].zone) {
				fake = alias[i].pointnet;
				break;
			}
		}
		
		if (i >= nalias) 
			i = 0;
	
#if defined EXTERNDEBUG
		if (debugflag) log_line(6,">OURSEEN using Unkn. %u:%u/%u.%u (%u)", alias[i].zone, alias[i].net, alias[i].node, alias[i].point, alias[i].pointnet);
#endif	
	}
	
#if defined DEBUG
	printf("*Adding our SEEN-BY\n");
#endif
	
	/*
	**	Add our nodenumber. If we are point take our fakenet number.
	*/
	
	used_aka = i;
	
	SeenZ[nseenby] = alias[i].zone;
	
	if (alias[i].point)
	{
		if (donopointadd == FALSE) {
			SeenN[nseenby] = alias[i].pointnet;
			SeenO[nseenby] = alias[i].point;
		} else {
			j = nseenby;
			goto NOincrement;
		}
	}
	else
		if (!doadd_AKA)
		{
			SeenN[nseenby] = alias[i].net;
			SeenO[nseenby] = alias[i].node;
		}
	
	j = nseenby + 1;
	
	NOincrement:
	
	if (doadd_AKA)
	{
		if (!alias[i].point) j--;
		
		for (i=0; i < nalias; i++) {
			if (use_zone == alias[i].zone && !alias[i].point)
			{
				if (Odomain != NULL) {
					if (strlen (Odomain)) {
						if (strncmp (Odomain, alias[i].Domain, 8)) {
							continue;
						}
					}
				}
				
				SeenZ[j] = alias[i].zone;
				SeenN[j] = alias[i].net;
				SeenO[j++] = alias[i].node;
				
#if defined EXTERNDEBUG
				if (debugflag) log_line(6,">Added AKA %u:%u/%u in SEEN's", alias[i].zone, alias[i].net, alias[i].node);
#endif
			}
		}
	}
	
	/*
	**	Add seen-by. Take adresses from the AREAS.BBS.
	**	If message to point take fake and pointadresses to, else
	**	only nodenumbers.
	*/
	
	for (i=0; Tozone[area][i] != (UWORD)-1; i++)
	{
		SeenZ[j] = Tozone[area][i];
		
		if (point && Topoint[area][i])
		{
			if (Tozone[area][i] == alias[used_aka].zone ||
				Tonet[area][i] == alias[used_aka].net ||
				Tonode[area][i] == alias[used_aka].node)
			{
				if (donopointadd == FALSE) {
					SeenN[j] = fake;
					SeenO[j++]= Topoint[area][i];
				}
			}
			else
			{
				SeenN[j] = Tonet[area][i];
				SeenO[j++] = Tonode[area][i];
			}
			
			continue;
		}
		
		if (!point && !Topoint[area][i])
		{
			SeenN[j] = Tonet[area][i];
			SeenO[j++] = Tonode[area][i];
			continue;
		}
		
		if (!point && Topoint[area][i]) continue;
		
		SeenN[j] = Tonet[area][i];
		SeenO[j++] = Tonode[area][i];
		
		if (j >= N_SEENS - 2)
		{
			memcpy(&Tz, &SeenZ, sizeof(WORD) * (N_SEENS-2));
			memcpy(&Tnt, &SeenN, sizeof(WORD) * (N_SEENS-2));
			memcpy(&Tne, &SeenO, sizeof(WORD) * (N_SEENS-2));
			memset(&Tp, 0, sizeof(WORD) * (N_SEENS-1));
			
			Tz[N_SEENS-2] = (UWORD)-1;
			Tne[N_SEENS-2] = (UWORD)-1;
			Tnt[N_SEENS-2] = (UWORD)-1;
			
			sort_connected(N_SEENS-2, 0);
			
			for(x = 1; x<j; x++)
				if (Tz[x-1] == Tz[x] &&
					Tnt[x-1] == Tnt[x] &&
					Tne[x-1] == Tne[x])
				{
					for (z = x; z < (j-1); z++)
					{
						Tz[z] = Tz[z+1];
						Tnt[z] = Tnt[z+1];
						Tne[z] = Tne[z+1];
					}
					
					if(--j <= 1) break;
					x = 1;
				}
			
			if (j >= N_SEENS -1)
			{
				log_line(6,"?More than %d nodes in SEEN-BY's, contact author.", N_SEENS-1);
				j--;
				break;
			}
			
			memcpy(&SeenZ, &Tz, sizeof(WORD) * (N_SEENS-1));
			memcpy(&SeenN, &Tnt, sizeof(WORD) * (N_SEENS-1));
			memcpy(&SeenO, &Tne, sizeof(WORD) * (N_SEENS-1));
		}
	}

	SeenZ[j] = -1;
	SeenN[j] = -1;
	SeenO[j] = -1;
	
	j++;
	
	/*
	**	Copy.
	*/
	
#if defined DEBUG
	printf("*Copying SEENs\n");
#endif
	
	memcpy(&Tz, &SeenZ, sizeof(WORD) * j);
	memcpy(&Tnt, &SeenN, sizeof(WORD) * j);
	memcpy(&Tne, &SeenO, sizeof(WORD) * j);
	memset(&Tp, 0, sizeof(WORD) * (j+1));
	
	/*
	**	Sort the line.
	*/
	
#if defined DEBUG
	printf("*Sorting SEENs\n");
#endif
	
	sort_connected(j, 0);
	
#if defined DEBUG
	printf("*Wipe dups out.\n");
#endif
	
	/*
	**	Duplicates? Wipe them out.
	*/
	
	for (i = 1; Tz[i] != (UWORD)-1; i++)
		if (Tz[i] == Tz[i-1] &&
			Tnt[i] == Tnt[i-1] &&
			Tne[i] == Tne[i-1])
		{
			for (z = i; z < (j-1); z++)
			{
				Tz[z] = Tz[z+1];
				Tnt[z] = Tnt[z+1];
				Tne[z] = Tne[z+1];
			}
			
			i = 1;
			--j;
		}
	
#if defined DEBUG
	printf("*Have SEENs\n");
#endif
	
	return(j);
}

/*
**	Add our number in the PATH
*/

WORD ourpath(WORD area, BYTE *Odomain)
{
	WORD	i, z;
	UWORD	zone,
			net,
			node;
	
	if (npath == N_SEENS-1)
	{
		log_line(5,"?Can't add PATH:, more than %d nodes.", N_SEENS);
		return(npath-1);
	}
	
	/*
	**	We are working in zone?? If we are point take our
	**	fakenet number.
	*/
	
	for (i=0; i < nalias; i++) {

		if (Tozone[area][0] == alias[i].zone)
		{

			if (Odomain != NULL) {
				if (strlen (Odomain)) {
					if (strncmp (Odomain, alias[i].Domain, 8)) {
						continue;
					}
				}
			}
			
			zone = alias[i].zone;
			
#if defined EXTERNDEBUG
			if (debugflag) log_line(6,">OURPATH have areazone %u", zone);
#endif
			if ((alias[i].net == Fnet && alias[i].node == Fnode &&
				alias[i].zone == Fzone && alias[i].point== Fpoint) ||
				(alias[i].net == Tnet && alias[i].node == Tnode &&
				alias[i].zone == Tzone && alias[i].point== Tpoint))
			{
			
				/*
				**	Point? Take fakenumber.
				*/
				
				if (alias[i].point)
				{
					if (donopointpath == FALSE)
					{
						net = alias[i].pointnet;
						node = alias[i].point;
					}
					else
					{
						net = alias[i].net;
						node= alias[i].node;
					}
					break;
				}
				
				net  = alias[i].net;
				node = alias[i].node;
				break;
			}
		}
	}

	if (i >= nalias)
	{
		zone = alias[0].zone;
		
		if (alias[0].point)
		{
			if (donopointpath == FALSE)
			{
				net = alias[0].pointnet;
				node = alias[0].point;
			}
			else
			{
				net = alias[0].net;
				node= alias[0].node;
			}
		}
		else
		{
			net = alias[0].net;
			node = alias[0].node;
		}
	}
	
#if defined EXTERNDEBUG
	if (debugflag) log_line(6,">OURPATH now having %u:%u/%u", zone, net, node);
#endif
	
#if defined DEBUG
	printf("*Adding our PATH:\n");
#endif
	
	Pathzone[npath] = zone;
	Pathnet[npath] = net;
	Pathnode[npath++] = node;
	
	Pathzone[npath] = -1;
	Pathnet[npath] = -1;
	Pathnode[npath++] = -1;
	
	memcpy(&Tz, &Pathzone, sizeof(WORD) * npath);
	memcpy(&Tnt, &Pathnet, sizeof(WORD) * npath);
	memcpy(&Tne, &Pathnode, sizeof(WORD) * npath);
	memset(&Tp, 0, sizeof(WORD) * npath);
	
	for (i = 1; Tz[i] != (UWORD)-1; i++)
		if (Tz[i] == Tz [i-1] &&
			Tnt[i] == Tnt[i-1] &&
			Tne[i] == Tne[i-1])
		{
			for (z = i; z <= npath; z++)
			{
				Tz[z] = Tz[z+1];
				Tnt[z] = Tnt[z+1];
				Tne[z] = Tne[z+1];
			}
			
			if (--npath <= 1) break;
			i = 1;
		}
	
	return(++npath);
}

BYTE Openarea(WORD file, BYTE *Hfile, BYTE *Mfile, MSGHEADER *Hdr)
{
#if defined DEBUG
	printf("*Opening other area\n");
#endif
	
	if ((LMSG[file] = fopen(Mfile, "r+b")) == NULL)
		if ((LMSG[file] = fopen(Mfile, "wb")) == NULL)
		{
			log_line(5,Logmessage[M__CANT_OPEN_AREA], Mfile);
			return(FALSE);
		}
		else
			Hdr->Mstart = 0L;
	else
	{
		fseek(LMSG[file], 0L, SEEK_END);
		Hdr->Mstart = ftell(LMSG[file]);
	}

	giveTIMEslice();
	
	if ((LHDR[file] = fopen(Hfile, "r+b")) == NULL)
		if ((LHDR[file] = fopen(Hfile, "wb")) == NULL)
		{
			log_line(5,Logmessage[M__CANT_OPEN_HEADER], Hfile);
			fclose(LMSG[file]);
			LMSGfile[file] = FILEclosed;
			
			return(FALSE);
		}				
	else
		fseek(LHDR[file], 0L, SEEK_END);
	
	return(TRUE);
}

/*
**	Open an new packet. If packet doens't exist write an PKT header.
**	If not new, seek end.
*/

BYTE Openpkt(WORD file, BYTE *node32, MSGHEADER *Hdr)
{
	BYTE			pktname[128],
					buffer[128];
#if defined LATTICE
	DMABUFFER		blk;
#else
	struct ffblk	blk;
#endif
	
	node32[11] = EOS;
	
	sprintf(pktname, "%s%sC", mailtemp, node32);
	
	if (Hdr->flags & CRASH)
	{
		sprintf(buffer, "%s%sH", mailtemp, node32);
		
		if (findfirst(buffer, &blk, 0))
		{
			sprintf(buffer, "%s%sN", mailtemp, node32);
			
			if (!findfirst(buffer, &blk, 0)) rename(buffer, pktname);
		}
		else rename(buffer, pktname);
	
		giveTIMEslice();
		
		if ((PKTfile[file] = fopen(pktname, "r+b")) == NULL)
		{
			giveTIMEslice();
			if ((PKTfile[file] = fopen(pktname, "wb")) == NULL)
			{
				log_line(6,Logmessage[M__CANT_OPEN_PACKET]);
				return(FALSE);
			}			
			hdrwrite(&phdr, sizeof(struct _pkthdr), PKTfile[file]);
/*
			Fwrite(fileno(PKTfile[file]), sizeof(struct _pkthdr), &phdr);
*/
		}
		else get_last_byte(PKTfile[file], pktname);
		
		return(TRUE);
	}
	
	sprintf (pktname, "%s%sH", mailtemp, node32);
	
	if (Hdr->flags & MSGHOLD) {
		sprintf(buffer, "%s%sN", mailtemp, node32);
		
		if (findfirst(buffer, &blk, 0))
		{
			sprintf(buffer, "%s%sC", mailtemp, node32);
			
			if (!findfirst(buffer, &blk, 0)) 
				strcpy (pktname, buffer);
		}
		else rename(buffer, pktname);
	
		giveTIMEslice();
		
		if ((PKTfile[file] = fopen(pktname, "r+b")) == NULL)
		{
			giveTIMEslice();
			if ((PKTfile[file] = fopen(pktname, "wb")) == NULL)
			{
				log_line(6,Logmessage[M__CANT_OPEN_PACKET]);
				return(FALSE);
			}			
			hdrwrite(&phdr, sizeof(struct _pkthdr), PKTfile[file]);
/*
			Fwrite(fileno(PKTfile[file]), sizeof(struct _pkthdr), &phdr);
*/
		}
		else get_last_byte(PKTfile[file], pktname);
		
		return(TRUE);
	}

	sprintf(pktname, "%s%sC", mailtemp, node32);
		
	if ((PKTfile[file] = fopen(pktname, "r+b")) == NULL)
	{
		sprintf(pktname, "%s%sH", mailtemp, node32);
		giveTIMEslice();
		
		if ((PKTfile[file] = fopen(pktname, "r+b")) == NULL )
		{
			sprintf(pktname, "%s%sN", mailtemp, node32);
			giveTIMEslice();
			
			if ((PKTfile[file] = fopen(pktname, "r+b")) == NULL)
			{
				giveTIMEslice();
				if ((PKTfile[file] = fopen(pktname, "wb")) == NULL)
				{
					log_line(6,Logmessage[M__CANT_CREATE_PACKET]);
					return(FALSE);
				}
				else
				{
					/*
					**	New file. Write header at once.
					*/
					
					hdrwrite(&phdr, sizeof(struct _pkthdr), PKTfile[file]);
/*
					Fwrite(fileno(PKTfile[file]), sizeof(struct _pkthdr), &phdr);
*/					
				}
			}
			else get_last_byte(PKTfile[file], pktname);
		}
		else get_last_byte(PKTfile[file], pktname);
	}
	else get_last_byte(PKTfile[file], pktname);
	
	
	return(TRUE);
}

VOID get_last_byte(FILE *stream, BYTE *filename)
{
	WORD			i;
#if defined LATTICE
	DMABUFFER		blk;
#else
	struct ffblk	blk;
#endif
	
	if (!findfirst(filename, &blk, 0))
	{
		giveTIMEslice();

		fseek(stream, blk.ff_fsize - 3, SEEK_SET);
		i = getc(stream);
		if (!i) return;
		i = getc(stream);
		if (!i) return;
		i = getc(stream);
		if (!i) return;
		putc(0, stream);
		giveTIMEslice();
		
		return;
	}
	
	if (stream)
	{
		fseek(stream, 0L, SEEK_END);
		return;
	}
	
	log_line(6,Logmessage[M__UNKNOWN_ERROR_PKT]);
}

/*
**	Add an line at the end of the message.
*/

VOID Addline(BYTE *msg, BYTE *what, WORD numbers, UWORD ourzone)
{
	WORD	i;
	UWORD	zone,
			net,
			node,
			lzone,
			lnet,
			lnode;
	BYTE	line[100];
	BYTE	*p;
	
	/*
	**	If not one of ourzones then add zonenumber.
	*/
	
#if defined DEBUG
	printf("*Adding line %s\n", what);
#endif
	
	if (ourzone != Tz[0] && !donozone)
		sprintf(line, "%s %u:%u/%u", what, Tz[0], Tnt[0], Tne[0]);
	else
		sprintf(line, "%s %u/%u", what, Tnt[0], Tne[0]);
	
	lzone = Tz[0];
	lnet = Tnt[0];
	lnode = Tne[0];
	
	for (i=1; i < numbers && Tz[i] != (UWORD)-1; i++)
	{
		/*
		**	Don't make it to long daddy.
		*/
		
		if (strlen(line) >= 65)
		{
			p = &msg[strlen(msg)-1];
			
			if (*p != '\n') strcpy(++p, "\n");
			
			strcat(msg, line);
			sprintf(line, what);
			
			lnet = -1;
			lnode = -1;
			
			if (fzone != ourzone) lzone = -1;
		}
		
		zone = Tz[i];
		net = Tnt[i];
		node = Tne[i];
		
		/*
		**	Find out if this is the same as before.
		*/
		
		if (zone == lzone && net == lnet && node == lnode) continue;
		
		/*
		**	If we are polling an other zone than add zone.
		*/
		
		if (zone != lzone && !donozone)
		{
			sprintf(&line[strlen(line)], " %u:%u/%u", zone, net, node);
			
			lzone = zone;
			lnet = net;
			lnode= node;
			
			continue;
		}
				
		if (lnet == net && lzone == zone)
		{
			sprintf(&line[strlen(line)], " %u", node);
			continue;
		}
		
		lzone = zone;
		lnet = net;
		lnode = node;
		
		sprintf(&line[strlen(line)], " %u/%u", net, node);
	}
	
	if (strlen(line) > strlen(what))
	{
		p = &msg[strlen(msg)-1];
		
		if (*p != '\n') strcat(msg, "\n");
		strcat(msg, line);
	}
	
#if defined DEBUG
	printf("*Line added.\n");
#endif
}

/*
**	Strip a line.
*/

BYTE *strip_line(BYTE *msg, BYTE *line)
{
	BYTE	*p, *q;
	
	if ((p = strline(msg, line)) == NULL) return(msg);
	
	/*
	**	Find the end of the line.
	*/
	
	q = p;
	while (*p != '\n') p++;
	strcpy(q, ++p);
	
	return(msg);
}

WORD move_area(WORD org_area, MSGHEADER *hdr) {
	WORD i, j;
	
	for(i=0; i < ncopyareas ; i++) {
		if(match(Areaname[org_area], Copyarea[i]) &&
		Copy_area[i] == MOVEAREA) {
			for(j=0; j < msgareas ; j++) {
				if(stricmp(Areaname[j], Destarea[i])) {
					if (newmatch(hdr->from, Copylegal[i])) {
						log_line(3,Logmessage[M__MOVE_AREA],
						Areaname[org_area],Areaname[j]);
						
						return (j);
					}
				}
			}
		}
	}
	return(org_area);
}

WORD copy_area(WORD org_area, MSGHEADER *hdr) {
	WORD i, j;
	
	if (ToCopy >= ncopyareas) return (FAILURE);
	
	for(i=ToCopy; i < ncopyareas ; i++) {
		if(match(Areaname[org_area], Copyarea[i]) &&
		Copy_area[i] == COPYAREA) {
			for(j = 0; j < msgareas ; j++) {
				if (!stricmp(Areaname[j], Destarea[i])) {
					if(newmatch(hdr->from, Copylegal[i])) {
						log_line(3,Logmessage[M__COPY_TO_AREA],
						Areaname[org_area],Areaname[j]);
						ToCopy = i+1;
						return (j);
					}
				}
			}
		}
	}
	return (FAILURE);
}

VOID packmail(UWORD toarea, UWORD nseenby, BYTE *expmsg, MSGHEADER *fhdr) {

	WORD j, l, i;
	
	BYTE *newmsg;

#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Alloc newmsg in packmail");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
	
	newmsg = (BYTE *) myalloc(MAXMSGLENGTH);
	
	for (j=0; Tozone[toarea][j] != (UWORD)-1; j++)
	{
		if (Tozone[toarea][j] == fzone &&
			Tonet[toarea][j] == fnet &&
			Tonode[toarea][j] == fnode &&
			Topoint[toarea][j] == fpoint) continue;
		
		/*
		**	Don't export if the node mentioned in the AREAS.BBS
		**	is 1 of our aliases.
		*/
		
		if (!ouralias(Tozone[toarea][j], Tonet[toarea][j],
						Tonode[toarea][j], Topoint[toarea][j]))
			continue;
		
		/*
		**	Check SEEN-BY
		*/
					
		for (l=0; l < nseenby; l++)
		{
			if (SeenN[l] == Tonet[toarea][j] && 
				SeenO[l] == Tonode[toarea][j] &&
				SeenZ[l] == Tozone[toarea][j] &&
				!Topoint[toarea][j]) break;
			
			i = nalias;
			
			if (Topoint[toarea][j])
				for (i=0; i < nalias; i++)
					if (SeenN[l] == alias[i].pointnet &&
						SeenZ[l] == Tozone[toarea][j] &&
						SeenO[l] == Topoint[toarea][j]) break;
			
			if (i < nalias) break;
		}
		
		if (l < nseenby) continue;
		
		nechos++;
		Ncreated[toarea]++;
		
		hprintf (S_EXP, "%d", nechos);
		
		fhdr->Dzone = Tozone[toarea][j];
		fhdr->Dnet = Tonet[toarea][j];
		fhdr->Dnode = Tonode[toarea][j];
		fhdr->Dpoint = Topoint[toarea][j];
					
		fhdr->Ozone = Tzone;
		fhdr->Onet = Tnet;
		fhdr->Onode = Tnode;
		fhdr->Opoint = Tpoint;
		
		if (fhdr->Ozone != fhdr->Dzone)
			for (l=0; l < nalias; l++)
				if (alias[l].zone == fhdr->Dzone)
				{
					fhdr->Ozone = alias[l].zone;
					fhdr->Onet = alias[l].net;
					fhdr->Onode = alias[l].node;
					fhdr->Opoint = alias[l].point;
					break;
				}
		
		/*
		**	Message not sent. On holiday?
		*/
		
		if (!capture_msg(fhdr)) continue;

		hprintf(S_DEST, "%u:%u/%u.%u", fhdr->Dzone, fhdr->Dnet,
			fhdr->Dnode, fhdr->Dpoint);
		hprintf(S_FROM, "%u:%u/%u.%u", fhdr->Ozone, fhdr->Onet,
			fhdr->Onode, fhdr->Opoint);
		
		sprintf(newmsg, "AREA:%s\n", Areaname[toarea]);
		
		add_point(newmsg, fhdr);
		
		strcpy(&newmsg[strlen(newmsg)], expmsg);
		
		if (strlen (dest_domain))
			i = ourseen(toarea, Topoint[toarea][j], fhdr, dest_domain);
		else
			i = ourseen(toarea, Topoint[toarea][j], fhdr, NULL);

		Addline(newmsg, (doifna) ? "\01SEEN-BY" : "SEEN-BY:", i-1, Tozone[toarea][j]);
		
		if (strlen (dest_domain))
			i = ourpath(toarea, dest_domain);
		else
			i = ourpath(toarea, NULL);
		
		Addline(newmsg, "\01PATH:", i-1, Tozone[toarea][j]);
		
		if (!dopkt)
		{
			fhdr->flags |= (KILLSEND|MSGLOCAL);
			fhdr->flags &= ~SENT;
			fhdr->mailer[7] = 0;
		}
		
		savemsg((dopkt) ? TOPACKET : TONETMAIL, fhdr, toarea,
			newmsg, Tozone[toarea][j], Tonet[toarea][j],
			Tonode[toarea][j], Topoint[toarea][j]);
			
			
	}
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Free newmsg");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
	free(newmsg);
}
