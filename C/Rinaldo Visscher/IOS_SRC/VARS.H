#if !defined (__VARS_H__)
#define __VARS_H__

EXTERN BOOLEAN		registered,
					debugflag,
					dooutdeb,
					SENDfido_bits,
					StatusScreen,
					
					Dareas[N_AREAS],
					
					dokillsent,
					dorealname,
					dokillall,
					dopvtmail,
					doknown,
					doareafix,
					doniceout,
					doreport,
					dodiskcheck,
					dopathcheck,
					donozone,
					doadd_AKA,
					dolog,
					doquit,
					dosecure,
					doifna,
					doled,
					dopkt,
					domsg,
					dostripzone,
					doimport,
					doscanmail,
					dochanged,
					dopack,
					keepmsg,
					toprivate,
					domulti_reg,
					dowait,
					docrunch,
					dolabel,
					donopack,
					doredirect,
					doQbbslr,
					dosaveprivate,
					dosavelocal,
					doextra,
					donewbink,
					dothebox,
					dopointcpy,
					doonly_tear,
					doadd_domain,
					dofastimport,
					dosentpkt,
					donopointadd,
					donopointpath,
					docheckname,
					dostripPID,
					doNOdupecheck,
					doDEFgroup,
					dostripINTL,
					doAUTOaddareas,
					doDENIED,
					doNODELIST,

					AreaAdded,
										
					HaveDUPES,
					
					MSGheader4d,
					
					CRspec,

					defPKT,
					
					Copy_area[N_AREAS],
					
					Read_only[N_AREAS],
					
					FDcompare[N_FDBASE],

#if defined AREAFIX
					dorescan ,
					areafix_on,
					doquery ,
					dototallist ,
#endif
										
					Fsystem,
					Tsystem;
				
EXTERN WORD			Areamsgs[N_AREAS],
					Areaday[N_AREAS],
					Areamin[N_AREAS],
					
					Tosysop[N_AREAS],
					Ncreated[N_AREAS],
					Lledmsgs[N_AREAS],
					Lledmask[N_AREAS],

					HDR,				/* File pointers for log_line and header 	*/
					MSG,				/* files								  	*/
					newHDR,
					newMSG,
					F_LSTBBS,		/* used for updating the lastread.bbs file	*/
										/*  initially closed						*/

					g_curarea,			/* area we're processing					*/
					
					g_users,			/* number of qbbs lastreas.bbs records		*/
					*g_newnum,			/* new numbers of messages, malloced		*/
					
					g_lsttype,			/* type of the lastread.ced file, 2 for LED	*/
					g_minhdrs,			/*  1 for the old way...					*/
					g_nrhdrs,
					g_safety,

					g_totdel,				/* total deleted messages					*/
					g_totleft,				/* total remaining messages					*/
					g_amhdr,				/* Amount hdr	*/

					ToCopy,
					
					nalias,
					nkey,
					domain,
					nbosses,
					msgareas,
					ncopyareas,
					nled,
					nkill,
					ncapbuf,
					nRouteDef,
					MaxRouteDef,
					nimported,
					nechos,
					nnetmails,
					nnet_priv,
					nprivate,
					ntrashed,
					nseenby,
					npath,
					nreaddress,
					nnodelist,
					
					nfdbase,
					
					def_days,
					maildays,
					pvtboxdays,
					trashdays,
					dupedays,

					mailmin,
					pvtboxmin,
					trashmin,
					dupemin,
					
					minmsgs,
					_screen,
					defcrunch,
					
					lastareawritten[N_MAXAREA],
					areafixmsgs,
					loglevel,
					
					PKTchannel[N_MAXPKT],

					v_handle,
					vdi_handle,
					gl_wchar,
					gl_hchar,
					gl_hbox,
					gl_wbox,
					work_in[12],
					work_out[57],
					
					__MiNT;

EXTERN UWORD		maxmsgs,

					TOSversion,
					IOSKEY_zone,
					
					*Tozone[N_AREAS],
					*Tonet[N_AREAS],
					*Tonode[N_AREAS],
					*Topoint[N_AREAS],

					maxPRD,
					
					Tz[N_SEENS],
					Tnt[N_SEENS],
					Tne[N_SEENS],
					Tp[N_SEENS],
					
					SeenZ[N_SEENS],
					SeenN[N_SEENS],
					SeenO[N_SEENS],
					
					Pathzone[N_SEENS],
					Pathnet[N_SEENS],
					Pathnode[N_SEENS],

					Zdomain[N_DOMAINS],
					Ndomain,

					Zpoint[N_DOMAINS],
					Npoint,
					
					bosszone[N_ALIAS],
					bossnet[N_ALIAS],
					bossnode[N_ALIAS],
					bosspoint[N_ALIAS],
					
					Fzone, Fnet, Fnode, Fpoint, Ffake,
					Tzone, Tnet, Tnode, Tpoint, Tfake,
					fzone, fnet, fnode, fpoint,
					tzone, tnet, tnode, tpoint,
					
					c_zone, c_net, c_node, c_point, c_fakenet,
					
					PKTzone[N_MAXPKT],
					PKTnet[N_MAXPKT],
					PKTnode[N_MAXPKT],
					PKTpoint[N_MAXPKT],

					Files_to_open;			/* Files can be opened by MT */

EXTERN LONG			mindiskspace,
					minpktsize,
					secs,
					bundlesize,
					pktsize,

					g_hdr_fsize,		/* file length of current headerfile		*/
					g_bod_fsize,		/* file length of current bodyfile			*/
					
					g_curtime,			/* current time								*/
					
					g_offset,			/* offset in new file						*/
					
					g_dfree[MAXDRIVES],	/* to hold free space on the drives			*/
					AreaSize[N_AREAS],	/* size of area after last scan         	*/
					
					switch_it,
					*scr1,
					*scr2,
					*oldestscr,
					
					DupeLog;

EXTERN ULONG		MAXMSGLENGTH,
					Ttest;

EXTERN BYTE			IOSmail[40],
					InMail[40],
					OutMail[40],
					ScanMail[40],
					Consultant[40],
					LOG_line,
					TEAR_buffer[512],

					Todomain[N_AREAS] [30],
					
					MTask,
										
					oldmsg[80],			/* names of the log_line and header files 	*/
					newmsg[80],
					oldhdr[80],
					newhdr[80],

					pkttype,
					org_domain[8],
					dest_domain[8],
					
					tm_now[40],
					
					*mailarea,
					*trasharea,
					*privatebox,
					*dupearea,
					
					*mailtemp,
					*pkt_temp,
					*outbound,
					*inbound,
					*Inboundpaths[4],
					*Arch,
					*Archcmdi,
					*Archcmdo,
					*Qbbslr,
					*Envpath,
					envp[254],
					*configlabel,
					*logfile,
					*TRACKmsg,
					
#if defined DEBUG
					*logtypes,
					*disptypes,
#else
					*logtypes,
					*disptypes,
#endif
					
					*Lzh,
					*Zip,
					*Arc,
					*Arj,
					
					*LzheC,
					*ZipeC,
					*ArceC,
					*ArjeC,
					
					*LzheA,
					*ZipeA,
					*ArceA,
					*ArjeA,
					*FDbase,
					
					*NODElist[N_NODELIST],

					*ToBase[N_FDBASE],
					
					SysOp[78],

					*ROnode[N_AREAS],
					
					*Areaname[N_AREAS],
					*Lareaname[N_AREAS],
					*Areapath[N_AREAS],
					*Areaorg[N_AREAS],
					*Copyarea[N_AREAS],
					*Destarea[N_AREAS],
					*Copylegal[N_AREAS],
					*Ausername[N_AREAS],
					*Randorgfile[N_AREAS],
					Areakeep[N_AREAS],
					Areagroup[N_AREAS],
					
					mailkeep,
					trashkeep,
					pvtkeep,
					dupekeep,
					
					*Mainorg,
					
					*Killfrom[N_KILL],
					we_have_inbound,
					
					*Areafix,
					*Areafixcmd,
					
					mtime[20],
					mfrom[36],
					mto[36],
					mtopic[72],
					
					*toarea,
					
					*messagebuffer,
					*messagebody,
					*Logmessage[LAST_MESSAGE],
					Dateformat[80],
					*PRDcode[256],
					
					Defaultgroup,
					
					LMSGfile[N_MAXAREA], LHDRfile[N_MAXAREA];

EXTERN FILE			*LOG,
					*FDUMMY,
					*OUT,
					*PACKET,
					*MSGHDR, *MSGMSG,
					*MMSG, *MHDR,
					*FMSG, *FHDR,
					*PKTfile[N_MAXPKT],
					*LMSG[N_MAXAREA],
					*LHDR[N_MAXAREA],
					*SIZE,					/* sizes of the areas						*/
					*LEDNEW,				/* to update led.new, area sizes part of it	*/
					*LRD;					/* last read messages per area				*/

EXTERN Aliases		alias[N_ALIAS];
EXTERN Key			pwd[N_POINTS];
EXTERN Dom_			Appl[N_DOMAINS];
EXTERN CAPTUREBUF	capbuf[N_POINTS];

EXTERN MSGHEADER	hdr,
					mhdr;

EXTERN READDRESS	readdress[N_POINTS];

EXTERN struct tm		*tijd;
#if defined LATTICE
EXTERN DMABUFFER		blok;
#else
EXTERN struct ffblk		blok;
#endif
EXTERN struct stat		stbuf;
EXTERN struct _pkthdr	phdr;
EXTERN struct _phdr2	phdr2;
EXTERN struct _pktmsg	pmsg;
EXTERN struct _RouteDef	*RouteDef;
EXTERN struct _ndi		*nodeidx;

EXTERN CONST BYTE	*isuf[],
					*ArcMail[],
					*Mtasker[];
#endif