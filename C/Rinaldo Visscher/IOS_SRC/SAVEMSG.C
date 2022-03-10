/*********************************************************************

					Packet saver.
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991
	
	Moved from inmail.c to this sources at 7-8-1991
	
	Save PKT's to disk.
		
*********************************************************************/


#include		<stdio.h>
#include		<stdlib.h>
#include		<ext.h>
#include		<string.h>
#include		<errno.h>
#include		<tos.h>

#include		"portab.h"
#include		"defs.h"
#include		"ioslib.h"
#include		"modules.h"
#include		"lang.h"
#include		"vars.h"

#include		"inmail.h"


/*
**	Save the message. In this part there are many files opened.
**	Messages to local, netmail and trasarea are written down here. Also
**	writing PKT files can be found here. For each of them there are
**	seperated files open. 2 files for the netmail, 2 files for the trasharea
**	16 files for the local area and 10 files for the packets.
**	A total of 30 file channels are opened if using full power at
**	importing.
**
**	It works, it speed up the diskaccess, esspecially if many area's must
**	be imported and there are nodes and points connected to an area.
**	Thanks to Jac that's found out this logic. I've build it up to an
**	greater proportion.
*/

/*
**	WARNING ........
**	Don't make this function longer, the compiler seems to be
**	have problems to generate an good function of it.
*/

VOID savemsg(BYTE whereto, MSGHEADER *Hdr, WORD area, BYTE *msg,
				UWORD zone, UWORD net, UWORD node, UWORD point)
{
	BYTE	Mfile[128],
			Hfile[128],
			system32[128],
			*tbuffer,
			pktpwd[10],
			mtype = TYPE3d,
			htype = FTS_TYPE,
			wrtTOPT = FALSE,
			wrtFMPT = FALSE;
	WORD	i, j,
			tofile;
	UWORD	t_zone, t_net, t_node, t_point,
			f_zone, f_net, f_node, f_point,
			zo, ne, no, dzo, dne, dno, dpo;
	
	Hdr->size = ((UWORD)strlen(msg));
	
	switch (whereto)
	{			
		case TOTRASH:
		case TOPRIVATE:
		
			Hdr->mailer[7] |= SCANNED;
			Hdr->flags |= RECEIVED;
			
			switch (whereto)
			{
				case TOPRIVATE:
				
					if(!strlen(privatebox))
						log_line(6,Logmessage[M__PVTBOX_UNKNOWN]);
					
					sprintf(Hfile, "%s.HDR", privatebox);
					sprintf(Mfile, "%s.MSG", privatebox);
					
					tbuffer = (BYTE *) myalloc(MAXMSGLENGTH + 80);
					
					if (area != -1)
					{
						sprintf(tbuffer, "\03AREA [%s]\n", Areaname[area]);
						strcat(tbuffer, msg);
					}
					else
					{
						sprintf(tbuffer, "\03AREA [MAIL]\n");
						strcat(tbuffer, msg);
					}
					
					Hdr->size = ((UWORD)strlen(tbuffer));
					break;
				
				case TOTRASH:
				
					Hdr->mailer[7] = 0;
					
					sprintf(Hfile, "%s.HDR", trasharea);
					sprintf(Mfile, "%s.MSG", trasharea);
					
					tbuffer = (BYTE *) myalloc(strlen(msg)+20);
					strcpy(tbuffer, msg);
					break;
			}
			
			/*
			**	Area all open? If not, open it.
			*/
			
			if ((MSGHDR = fopen(Hfile, "r+b")) == NULL &&
				(MSGHDR = fopen(Hfile, "wb")) == NULL)
			{
				log_line(6,Logmessage[M__CANT_OPEN_HEADER], Hfile);
				return;
			}
			else fseek(MSGHDR, 0L, SEEK_END);
			
			if ((MSGMSG = fopen(Mfile, "r+b")) == NULL)
			{
				if ((MSGMSG = fopen(Mfile, "wb")) == NULL)
				{
					log_line(6,Logmessage[M__CANT_OPEN_AREA], Mfile);
					fclose(MSGHDR);
					return;
				}
				else Hdr->Mstart = 0L;
			}
			else
			{
				fseek(MSGMSG, 0L, SEEK_END);
				Hdr->Mstart = ftell(MSGMSG);
			}
/*			
			hdrwrite(Hdr, sizeof(MSGHEADER), MSGHDR);
			
			msgwrite(tbuffer, (UWORD) strlen(tbuffer), MSGMSG);
*/
			Fwrite(fileno(MSGHDR), sizeof(MSGHEADER), Hdr);
			Fwrite(fileno(MSGMSG), strlen(tbuffer), tbuffer);
					
			fclose(MSGMSG);
			fclose(MSGHDR);
			free(tbuffer);
			return;
					
		case TOLOCAL:
			
#if defined DEBUG
			printf("*Saving LOCAL\n");
#endif
			
			sprintf(Hfile, "%s.HDR", Areapath[area]);
			sprintf(Mfile, "%s.MSG", Areapath[area]);
			
			Hdr->mailer[7] |= SCANNED;
			
			/*
			**	Searching of this area is already opened.
			**	Speeded up the joyride.
			*/
			
			for (i=0; i < N_AREAFILE; i++)
				if (lastareawritten[i] == area)
				{
					tofile = i;
					break;
				}
			
			/*
			**	No, it's a brand new one. Open it.
			*/
			
			if (i >= N_AREAFILE)
			{
				for (i=0; i < N_AREAFILE; i++)
					if (LHDRfile[i] == FILEclosed &&
						LMSGfile[i] == FILEclosed)
					{
						tofile = i;
						
						if (!Openarea(i, Hfile, Mfile, Hdr))
							terminate(10);
						
						LHDRfile[i] = FILEopen;
						LMSGfile[i] = FILEopen;
						lastareawritten[i] = area;
						
						break;
					}
				
				if (i >= N_AREAFILE)
				{
					fclose(LHDR[0]);
					fclose(LMSG[0]);
					tofile = 0;
					lastareawritten[0] = area;
					
					if (!Openarea(0, Hfile, Mfile, Hdr))
						terminate(10);
				}
			}
			else Hdr->Mstart = ftell(LMSG[tofile]);
			
			fseek(LHDR[tofile], 0L, SEEK_END);
/*
			hdrwrite(Hdr, sizeof(MSGHEADER), LHDR[tofile]);
			msgwrite(msg, (UWORD) strlen(msg), LMSG[tofile]);
*/
			Fwrite(fileno(LHDR[tofile]), sizeof(MSGHEADER), Hdr);
			Fwrite(fileno(LMSG[tofile]), strlen(msg), msg);
			
			return;
			
		case TONETMAIL:
		
			sprintf(Mfile,"%s.MSG",mailarea);
			sprintf(Hfile,"%s.HDR",mailarea);
			
#if defined DEBUG
			printf("*Saving MAIL\n");
#endif		
			
			/*
			**	If the channel is already opened, we don't have to
			**	open it again. This speed up some things.
			*/
				
			if (!MMSG && !MHDR)
			{
				if ((MMSG = fopen(Mfile, "r+b")) == NULL)
					if ((MMSG = fopen(Mfile, "wb")) == NULL)
					{
						log_line(6,Logmessage[M__CANT_OPEN_AREA], Mfile);
						return;
					}
					else
						Hdr->Mstart = 0L;
				else
				{
					fseek(MMSG, 0L, SEEK_END);
					Hdr->Mstart = ftell(MMSG);
				}
				
				if ((MHDR = fopen(Hfile, "r+b")) == NULL &&
					(MHDR = fopen(Hfile,"wb")) == NULL)
					{
						log_line(6,Logmessage[M__CANT_OPEN_AREA], Mfile);
						return;
					}
				else
					fseek(MHDR, 0L, SEEK_END);
			}
			else
			{
				fseek(MMSG, 0L, SEEK_END);
				Hdr->Mstart = ftell(MMSG);
			}
/*			
			hdrwrite(Hdr, sizeof(MSGHEADER), MHDR);
			msgwrite(msg, (UWORD) strlen(msg)+1, MMSG);
*/			
			Fwrite(fileno(MHDR), sizeof(MSGHEADER), Hdr);
			Fwrite(fileno(MMSG), strlen(msg)+1, msg);
			
			fflush(MMSG);
			fflush(MHDR);
			
			return;
			
		case TOPACKET:
			
			/*
			**	Get the password of the destination.
			*/
			
			mtype = TYPE3d;
			htype = FTS_TYPE;
			
			for (i=0; i < nkey; i++)
				if (Hdr->Dzone == pwd[i].zone &&
					Hdr->Dnet == pwd[i].net &&
					Hdr->Dnode == pwd[i].node &&
					Hdr->Dpoint == pwd[i].point)
				{
					strcpy(pktpwd, pwd[i].pwd);
					mtype = pwd[i].mtype;
					htype = pwd[i].htype;
					break;
				}
			
			
			/*
			**	If doing secure, watch all passwords mentioned in the
			**	config file. If the destination is not found, break of
			**	and warn the user of an illegal user of this area.
			**	Then return to homebase.
			*/
			
			if (dosecure && i >= nkey)
			{
				if (area >= 0)
				{
					log_line(6,Logmessage[M__NODE_UNKNOWN],
						Hdr->Dzone, Hdr->Dnet, Hdr->Dnode, Hdr->Dpoint);
					log_line(2,Logmessage[M__CHECK_PWDS],
						Areaname[area]);
				}
				else
				{
					log_line(6,Logmessage[M__NODE_UNKNOWN_NETMAIL],
						Hdr->Dzone, Hdr->Dnet, Hdr->Dnode, Hdr->Dpoint);
					log_line(2,Logmessage[M__CHECK_CONFIG]);
				}
				
				return;
			}
			
			dzo = t_zone = Hdr->Dzone;
			dne = t_net = Hdr->Dnet;
			dno = t_node = Hdr->Dnode;
			dpo = t_point = Hdr->Dpoint;
			
			zo = f_zone = Hdr->Ozone;
			ne = f_net = Hdr->Onet;
			no = f_node = Hdr->Onode;
			f_point = Hdr->Opoint;
			
			/*
			**	If point then 3d. Not if point using 4d address.
			**	If netmail, don't change the messageheader.
			**	zo,ne,no,dzo etc. contains the fakenetnumer of
			**	the points.
			*/
			
			if (Hdr->Dpoint && mtype == TYPE3d)
			{
				for (i=0; i < nalias; i++)
					if (alias[i].zone == Hdr->Dzone &&
						alias[i].net == Hdr->Dnet &&
						alias[i].node == Hdr->Dnode)
					{
						dzo = Hdr->Dzone;
						
						if (area >= 0)
						{
							dne = Hdr->Dnet = alias[i].pointnet;
							dno = Hdr->Dnode = Hdr->Dpoint;
							Hdr->Dpoint = dpo = 0;
						}
						else
						{
							dne = alias[i].pointnet;
							dno = Hdr->Dpoint;
							dpo = 0;
						}
						
						break;
					}
				
				if (i >= nalias)
				{
					htype = FRONTDOOR;
					mtype = TYPE4d;
					wrtTOPT = TRUE;
				}
			}
			
			if (Hdr->Opoint && mtype == TYPE3d)
			{
				for (i=0; i < nalias; i++)
					if (alias[i].zone == Hdr->Ozone &&
						alias[i].net == Hdr->Onet &&
						alias[i].node == Hdr->Onode)
					{
						zo = Hdr->Ozone;
						
						if (area >= 0)
						{
							ne = Hdr->Onet = alias[i].pointnet;
							no = Hdr->Onode= Hdr->Opoint;
							Hdr->Opoint = 0;
						}
						else
						{
							ne = alias[i].pointnet;
							no = Hdr->Opoint;
						}
						
						break;
					}
				
				if (i >= nalias)
				{
					htype = FRONTDOOR;
					mtype = TYPE4d;
					wrtFMPT = TRUE;
				}
			}
			
			/*
			**	Create filename.
			*/
			
			xsprintf(system32, "%02z%03z%03z.%02z", dzo, dne, dno, dpo);
			
			/*
			**	If new file create packet header.
			*/
			
			switch (htype)
			{
				case FTS_TYPE:
				
					fts_TYPE:
					create_pkt_hdr(zo, ne, no, dzo, dne, dno, pktpwd);
					break;
					
				/*
				**	Create an packetheader for frontdoor.
				*/
					
				case FRONTDOOR:
				
					create_pkt_fnd(f_zone, f_net, f_node, f_point,
						t_zone, t_net, t_node, t_point, pktpwd);
					break;
				
				default:
				
					log_line(6,Logmessage[M__COMPILER_ERROR]);
					goto fts_TYPE;
			}
			
#if defined DEBUG
			printf("*Writing PKT for %d:%d/%d.%d\n", Hdr->Dzone, Hdr->Dnet, Hdr->Dnode, Hdr->Dpoint);
#endif		
			
			/*
			**	Trying to find the channel of this node or point.
			**	If not found search for an NULL filepointer.
			*/
			
			for (i=0; i < N_PKTFILE; i++)
				if (PKTzone[i] == t_zone &&
					PKTnet[i] == t_net &&
					PKTnode[i] == t_node &&
					PKTpoint[i] == t_point)
				{
					tofile = i;
					fseek(PKTfile[i], 0L, SEEK_END);
					break;
				}
			
			/*
			**	This node or point have no channel.
			**	Searching for an free NULL filepointer.
			*/
			
			if (i >= N_PKTFILE)
			{
				for (i=0; i < N_PKTFILE; i++)
					if (PKTchannel[i] == FILEclosed)
					{
						tofile = i;
						PKTchannel[i] = FILEopen;
						if (Openpkt(i, system32, Hdr)) break;
						return;
					}
				
				/*
				**	If all files are opened, try to find an channel
				**	that's not used. Logic :
				**
				**	Compare the nodes and points that's are connected
				**	to this area with the nodes and point that are
				**	using an channel. If found break of and continue;
				**	If not close this channel and open it again for
				**	the new node or point. If all using this channel
				**	close the first one.
				**
				**	I speeded the diskwriting up mother.
				*/
				
				if (i >= N_PKTFILE)
				{
					if (area >= 0)
					{
						for (j=0; j < N_PKTFILE; j++)
						{
							for (i=0; Tozone[area][i] != (UWORD)(-1); i++)
								if (Tozone[area][i] == PKTzone[j] &&
									Tonet[area][i] == PKTnet[j] &&
									Tonode[area][i] == PKTnode[j] &&
									Topoint[area][i] == PKTpoint[j])
									break;
							
							if (Tozone[area][i] == (UWORD)(-1))
							{
								putc(0, PKTfile[j]);
								putc(0, PKTfile[j]);
								fclose(PKTfile[j]);
								
								tofile = j;
								if (!Openpkt(j, system32, Hdr)) return;
								break;
							}
						}
					}
					else j = N_PKTFILE;
					
					/*
					**	Brrrr.... close the first channel. There are
					**	so many connected.
					**
					**	It slow down the process.
					*/
					
					if (j >= N_PKTFILE )
					{
						putc(0, PKTfile[0]);
						putc(0, PKTfile[0]);
						fclose(PKTfile[0]);
						
						tofile = 0;
						if (!Openpkt(0, system32, Hdr)) return;
					}
				}
			}
			
			/*
			**	This node or point is now in use of this channel.
			*/
			
			PKTzone[tofile] = t_zone;
			PKTnet[tofile] = t_net;
			PKTnode[tofile] = t_node;
			PKTpoint[tofile] = t_point;
			
			pmsg.pm_ver = intel(2);
			pmsg.pm_dnet = intel(Hdr->Dnet);
			pmsg.pm_dnode = intel(Hdr->Dnode);
			pmsg.pm_onet = intel(Hdr->Onet);
			pmsg.pm_onode = intel(Hdr->Onode);
			pmsg.pm_attr = intel((Hdr->flags &= ~(MSGLOCAL|MSGHOLD|KILLSEND|SENT|MSGFWD|ORPHAN)));
			pmsg.pm_cost = 0;
			
			/*
			**	Writing the pkt message header.
			*/
/*			
			hdrwrite(&pmsg, sizeof(struct _pktmsg), PKTfile[tofile]);
*/
			Fwrite(fileno(PKTfile[tofile]), sizeof(struct _pktmsg), &pmsg);
						
			pktwrite(Hdr->time, (UWORD) strlen(Hdr->time), PKTfile[tofile]);
			pktwrite(Hdr->to, (UWORD) strlen(Hdr->to), PKTfile[tofile]);
			pktwrite(Hdr->from, (UWORD) strlen(Hdr->from), PKTfile[tofile]);
			pktwrite(Hdr->topic, (UWORD) strlen(Hdr->topic), PKTfile[tofile]);
			
			if (wrtTOPT)
				fprintf(PKTfile[tofile], "\01TOPT %d\n", Hdr->Dpoint);
			if (wrtFMPT)
				fprintf(PKTfile[tofile], "\01FMPT %d\n", Hdr->Opoint);
			
			/*
			**	Put the message on disk.
			*/
			
			pktwrite(msg, (UWORD) strlen(msg), PKTfile[tofile]);
			
			break;
			
		case NETMAILPACKET:
			
			/*
			**	Get the pasword of the destination.
			*/
			
			mtype = TYPE3d;
			htype = FTS_TYPE;
			
			for (i=0; i < nkey; i++)
			{
				if (zone == pwd[i].zone && net == pwd[i].net &&
					node == pwd[i].node && point == pwd[i].point)
				{
					strcpy(pktpwd, pwd[i].pwd);
					
					mtype = pwd[i].mtype;
					htype = pwd[i].htype;
					
#if defined OUTDEBUG
					if (dooutdeb) log_line(6,">Have password %d:%d/%d.%d - %s", pwd[i].zone, pwd[i].net, pwd[i].node, pwd[i].point, pwd[i].pwd);
#endif
					break;
				}
			}
			
			/*
			**	If crashmail, delete password.
			*/
			
			if (Hdr->flags & CRASH)
				for (i=0; i < (WORD) strlen(pktpwd); i++)
					pktpwd[i] = EOS;
			
			if (i >= nkey)
			{
#if defined OUTDEBUG
				if (dooutdeb) log_line(6,">No password for %d:%d/%d.%d", zone, net, node, point);
#endif
				*pktpwd = EOS;
			}
			
			/*
			**	If no crashmail, take normal.
			*/
			
			if (!(Hdr->flags & CRASH))
			{
				if (point)
				{
					dzo = zone;
					
					for (i=0; i < nalias; i++)
						if (zone == alias[i].zone &&
							net == alias[i].net &&
							node == alias[i].node)
						{
							dne = alias[i].pointnet;
							dno = point;
							dpo = 0;
#if defined OUTDEBUG
							if (dooutdeb) log_line(6,">Point - dzo, dne, dno %d:%d/%d", dzo, dne, dno);
#endif
							break;
						}
				}
				else
				{
					dzo = zone;
					dne = net;
					dno = node;
					dpo = 0;
					
#if defined OUTDEBUG
					if (dooutdeb) log_line(6,">No point - dzo,dne,dno %d:%d/%d", dzo, dne, dno);
#endif
				}
				
				t_zone = zone;
				t_net = net;
				t_node = node;
				t_point = point;
				
				/*
				**	Get origin address from ourself.
				*/
				
				for (i=0; i < nalias; i++)
					if (zone == alias[i].zone &&
						node == alias[i].node &&
						net == alias[i].net)
					{
						if (!alias[i].point)
						{
							zo = alias[i].zone;
							ne = alias[i].net;
							no = alias[i].node;
						}
						else
						{
							zo = alias[i].zone;
							ne = alias[i].pointnet;
							no = alias[i].point;
						}
						
						f_zone = alias[i].zone;
						f_net = alias[i].net;
						f_node = alias[i].node;
						f_point = alias[i].point;
						
						break;
					}
				
				if (i >= nalias)
				{
					for (i=0; i < nalias; i++)
						if (zone == alias[i].zone)
						{
							if (!alias[i].point)
							{
								zo = alias[i].zone;
								ne = alias[i].net;
								no = alias[i].node;
							}
							else
							{
								zo = alias[i].zone;
								ne = alias[i].pointnet;
								no = alias[i].point;
							}
							
							f_zone = alias[i].zone;
							f_net  = alias[i].net;
							f_node = alias[i].node;
							f_point= alias[i].point;
							
							break;
						}
					
					if (i >= nalias)
						if (!alias[0].point)
						{
							zo = f_zone = alias[0].zone;
							ne = f_net = alias[0].net;
							no = f_node = alias[0].node;
							f_point = alias[0].point;
						}
						else
						{
							zo = f_zone = alias[0].zone;
							ne = alias[0].pointnet;
							no = f_point = alias[0].point;
							f_net = alias[0].net;
							f_node = alias[0].node;
						}
				}	
			}
			else
			{
			
				/*
				**	Crashmail.
				*/
				
				if (Hdr->Opoint)
				{
					for (i=0; i < nalias; i++)
						if (Hdr->Ozone == alias[i].zone &&
							Hdr->Onet == alias[i].net &&
							Hdr->Onode == alias[i].node &&
							Hdr->Opoint == alias[i].point)
						{
							zo = alias[i].zone;
							ne = alias[i].pointnet;
							no = alias[i].point;
							break;
						}
					
					if (i >= nalias)
					{
						zo = Hdr->Ozone;
						ne = Hdr->Onet;
						no = Hdr->Onode;
					}
				}
				else
				{
					zo = Hdr->Ozone;
					ne = Hdr->Onet;
					no = Hdr->Onode;
				}
				
				f_zone = Hdr->Ozone;
				f_net = Hdr->Onet;
				f_node = Hdr->Onode;
				f_point = Hdr->Opoint;
				
				if (Hdr->Dpoint)
					for (i=0; i < nalias; i++)
						if (Hdr->Dnet == alias[i].net &&
							Hdr->Dnode == alias[i].node &&
							Hdr->Dzone == alias[i].zone)
						{
							log_line(4,Logmessage[M__CANT_CRASH_POINT]);
							return;
						}
				
				dzo = t_zone = Hdr->Dzone;
				dne = t_net = Hdr->Dnet;
				dno = t_node = Hdr->Dnode;
				dpo = t_point = Hdr->Dpoint;
			}
			
#if defined EXTERNDEBUG
			if (debugflag) log_line(6,">Now have as destination PKT %d:%d/%d.%d", dzo, dne, dno, dpo);
#endif
			
			/*
			**	Create filename.
			*/
			
			xsprintf(system32, "%02z%03z%03z.%02z", dzo, dne, dno, dpo);
			
			/*
			**	If new file create packet header.
			*/
			
			switch (htype)
			{
				case FTS_TYPE:
				
					FTS_type:
					create_pkt_hdr(zo, ne, no, dzo, dne, dno, pktpwd);
					break;
					
				/*
				**	Create an packetheader for frontdoor.
				*/
				
				case FRONTDOOR:
				
					create_pkt_fnd(f_zone, f_net, f_node, f_point,
						t_zone, t_net, t_node, t_point, pktpwd);
					break;
				
				default:
				
					log_line(6,Logmessage[M__COMPILER_ERROR]);
					goto FTS_type;
			}
			
#if defined DEBUG
			printf("*Writing PKT for %d:%d/%d\n", Hdr->Dzone, Hdr->Dnet, Hdr->Dnode);
#endif		
			
			/*
			**	Trying to find the channel of this node or point.
			**	If not found search for an NULL filepointer.
			*/
			
			for (i=0; i < N_PKTFILE; i++)
				if (PKTzone[i] == t_zone && PKTnet[i] == t_net &&
					PKTnode[i] == t_node)
				{
					tofile = i;
					fseek(PKTfile[i], 0L, SEEK_END);
					break;
				}
			
			/*
			**	This node or point have no channel.
			**	Searching for an free NULL filepointer.
			*/
			
			if (i >= N_PKTFILE)
			{
				for (i=0; i < N_PKTFILE; i++)
					if (PKTchannel[i] == FILEclosed)
					{
						tofile = i;
						PKTchannel[i] = FILEopen;
						
						if (Openpkt(i, system32, Hdr)) break;
						return;
					}
				
				if (i >= N_PKTFILE )
				{
					putc(0,PKTfile[0]);
					putc(0,PKTfile[0]);
					fclose(PKTfile[0]);
					
					tofile = 0;
					if (!Openpkt(0, system32, Hdr)) return;
				}
			}
			
			/*
			**	This node or point is now in use of this channel.
			*/
			
			PKTzone[tofile] = t_zone;
			PKTnet[tofile] = t_net;
			PKTnode[tofile] = t_node;
			PKTpoint[tofile] = t_point;
			
			pmsg.pm_ver = intel(2);
			pmsg.pm_dnet = intel(Hdr->Dnet);
			pmsg.pm_dnode = intel(Hdr->Dnode);
			pmsg.pm_onet = intel(Hdr->Onet);
			pmsg.pm_onode = intel(Hdr->Onode);
			pmsg.pm_attr = intel(Hdr->flags &= ~(MSGLOCAL|MSGHOLD|KILLSEND|SENT|MSGFWD));
			pmsg.pm_cost = 0;
			
			/*
			**	Writing the pkt message header.
			*/
			
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">Writing packet");
#endif
/*
			hdrwrite(&pmsg, sizeof(struct _pktmsg), PKTfile[tofile]);
*/
			Fwrite(fileno(PKTfile[tofile]), sizeof(struct _pktmsg), &pmsg);
						
			pktwrite(Hdr->time, (UWORD) strlen(Hdr->time), PKTfile[tofile]);
			pktwrite(Hdr->to, (UWORD) strlen(Hdr->to), PKTfile[tofile]);
			pktwrite(Hdr->from, (UWORD) strlen(Hdr->from), PKTfile[tofile]);
			pktwrite(Hdr->topic, (UWORD) strlen(Hdr->topic), PKTfile[tofile]);
			
			/*
			**	INTL needed?
			*/
			
			if (Hdr->Ozone != f_zone && Hdr->Dzone != t_zone)
			{
				if (strncmp(msg,"AREA:",5))
				{
					if (!get_interzone(msg, &f_zone, &f_net, &f_node, &t_zone, &t_net, &t_node))
					{
						write_INTL:
						
#if defined OUTDEBUG
						if (dooutdeb) log_line(6,">Writing INTL");
#endif
						fprintf(PKTfile[tofile], "\01INTL %d:%d/%d %d:%d/%d\n",
							Hdr->Ozone, Hdr->Onet, Hdr->Onode,
							Hdr->Dzone, Hdr->Dnet, Hdr->Dnode);
					}
					else
					{
						if (f_zone != Hdr->Ozone &&
							t_zone != Hdr->Dzone)
						{
							msg = strip_line(msg, "\01INTL ");
							goto write_INTL;
						}
					}
				}
			}
			
			pktwrite(msg, (UWORD) strlen(msg), PKTfile[tofile]);
			
			break;
		
		default:
		
			log_line(6,Logmessage[M__COMPILER_ERROR]);
			break;
	}
}

VOID ToDataBase(MSGHEADER *Hdr, BYTE *msg, WORD area) {
	WORD i;
	BYTE 
		 Hfile[128],
		 Mfile[128];
	
	SMALLBASE sbase;
	
	for (i=0; i < nfdbase; i++) {
		if (newmatch( (FDcompare[nfdbase] == FD_FROM) ? Hdr->from : Hdr->to, ToBase[nfdbase])) {
			sprintf(Hfile,"%sDATA.HR",FDbase);
			sprintf(Mfile,"%sDATA.MG",FDbase);
			
			if ((MSGHDR = fopen(Hfile,"r+b")) == NULL ) {
				if ((MSGHDR = fopen(Hfile,"wb"))  == NULL) {
					log_line(5,Logmessage[M__CANT_OPEN_B_DBASE]);
					return;
				}
			} else fseek(MSGHDR, 0L, SEEK_END);
			
			if ((MSGMSG = fopen(Mfile, "r+b")) == NULL) {
				if ((MSGMSG = fopen(Mfile, "wb")) == NULL){
					log_line(6,Logmessage[M__CANT_OPEN_M_DBASE]);
					fclose(MSGHDR);
					return;
				}
				else sbase.Mstart = 0L;
			}
			else {
				fseek(MSGMSG, 0L, SEEK_END);
				sbase.Mstart = ftell(MSGMSG);
			}
			
			strcpy (sbase.from, Hdr->from);
			strcpy (sbase.to, Hdr->to);
			strcpy (sbase.topic, Hdr->topic);
			strcpy (sbase.time, Hdr->time);
			strncpy(sbase.area, Areaname[area],39);
			sbase.size = (UWORD) strlen(msg);
			
			hdrwrite(&sbase, sizeof(SMALLBASE), MSGHDR);
			
			msgwrite(msg, (UWORD) strlen(msg), MSGMSG);
			
			fclose(MSGMSG);
			fclose(MSGHDR);
			return;
		}
	}
}
