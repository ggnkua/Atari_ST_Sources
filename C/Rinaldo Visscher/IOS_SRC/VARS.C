/*********************************************************************

					IOS - global variables
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991
	
	All global variables used by IOS are here.
***********************************************************************/

#include		<stdio.h>
#include		<ext.h>

#include		"portab.h"

#include		"defs.h"
#include		"lang.h"


BOOLEAN			registered,
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
				doonly_tear = FALSE,
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
				
				CRspec = FALSE,
				
				defPKT = FTS_TYPE,
				
				Copy_area[N_AREAS],
				
				Read_only[N_AREAS],
				
				FDcompare[N_FDBASE],

#if defined AREAFIX
				dorescan = FALSE,
				areafix_on,
				doquery = FALSE,
				dototallist = FALSE,
#endif
				Fsystem,
				Tsystem;

WORD			Areamsgs[N_AREAS],
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
				F_LSTBBS = -1,		/* used for updating the lastread.bbs file	*/
									/*  initially closed						*/

				g_curarea,			/* area we're processing					*/
				
				g_users=0,			/* number of qbbs lastreas.bbs records		*/
				*g_newnum,			/* new numbers of messages, malloced		*/
				
				g_lsttype = 2,		/* type of the lastread.ced file, 2 for LED	*/
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
				ncopyareas = 0,
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
				
				nfdbase = 0,
				
				def_days = 21,
				maildays,
				pvtboxdays,
				trashdays,
				dupedays,
				
				mailmin,
				pvtboxmin,
				trashmin,
				dupemin,
				
				loglevel,
				
				minmsgs,
				_screen = -1,
				defcrunch = AFTERSCAN,
				
				lastareawritten[N_MAXAREA],
				areafixmsgs = 0,
				
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

UWORD			maxmsgs = 0xfffeU,

				TOSversion,
				IOSKEY_zone,
				
				*Tozone[N_AREAS],
				*Tonet[N_AREAS],
				*Tonode[N_AREAS],
				*Topoint[N_AREAS],
				
				maxPRD = 0,
				
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
				
				bosszone[N_ALIAS],
				bossnet[N_ALIAS],
				bossnode[N_ALIAS],
				bosspoint[N_ALIAS],
				
				Zdomain[N_DOMAINS],
				Ndomain = 0,
				
				Zpoint[N_DOMAINS],
				Npoint = 0,
				
				Fzone, Fnet, Fnode, Fpoint, Ffake,
				Tzone, Tnet, Tnode, Tpoint, Tfake,
				fzone, fnet, fnode, fpoint,
				tzone, tnet, tnode, tpoint,
				
				c_zone, c_net, c_node, c_point, c_fakenet;
				
				PKTzone[N_MAXPKT],
				PKTnet[N_MAXPKT],
				PKTnode[N_MAXPKT],
				PKTpoint[N_MAXPKT],
				Files_to_open;			/* Files can be opened by MT */

LONG			mindiskspace,
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
				
				DupeLog = 0L;

ULONG			MAXMSGLENGTH = 0x8000L,
				Ttest;

BYTE			IOSmail[40],
				InMail[40],
				OutMail[40],
				ScanMail[40],
				Consultant[40],
				LOG_line = 0,
				TEAR_buffer[512],
				
				MTask = NOTASK,

				Todomain[N_AREAS] [30],
				
				oldmsg[80],			/* names of the log_line and header files 	*/
				newmsg[80],
				oldhdr[80],
				newhdr[80],

				pkttype = STONEAGE,
				org_domain[8],
				dest_domain[8],
				
				tm_now[40],
				
				*mailarea = "",
				*trasharea = "",
				*privatebox = "",
				*dupearea = "",
				*mailtemp = "",
				*pkt_temp = "",
				*outbound = "",
				*inbound = "",
				*Inboundpaths[4],
				*Arch = "",
				*Archcmdi = "",
				*Archcmdo = "",
				*Qbbslr = "",
				*Envpath = "",
				envp[254],
				*configlabel,
				*logfile = "",
				*TRACKmsg= "",
								
#if defined EXTERNDEBUG
				*logtypes = "$%+-#?!*=~>",
				*disptypes = "$%+-#?!*=~>",
#else
				*logtypes = "$%+-#?!*=~",
				*disptypes = "$%+-#?!*=~",
#endif
				
				*Lzh = "",
				*Zip = "",
				*Arc = "",
				*Arj = "",
				
				*LzheC = "",
				*ZipeC = "",
				*ArceC = "",
				*ArjeC = "",
				
				*LzheA = "",
				*ZipeA = "",
				*ArceA = "",
				*ArjeA = "",
				*FDbase= "",
				
				*ToBase[N_FDBASE],
				
				SysOp[78],

				*ROnode[N_AREAS],
				*NODElist[N_NODELIST],
				
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
				
				*Mainorg = "",
				
				*Killfrom[N_KILL],
				we_have_inbound = PROTINBOUND,
				
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

FILE			*LOG,
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

Aliases			alias[N_ALIAS];
Key				pwd[N_POINTS];
Dom_			Appl[N_DOMAINS];
CAPTUREBUF		capbuf[N_POINTS];

MSGHEADER		hdr,
				mhdr;

READDRESS		readdress[N_POINTS];

struct tm			*tijd;
struct ffblk		blok;
struct stat			stbuf;
struct _pkthdr		phdr;
struct _phdr2		phdr2;
struct _pktmsg		pmsg;
struct _RouteDef	*RouteDef;
struct _ndi			*nodeidx;

CONST BYTE		*isuf[] = {"SU", "MO", "TU", "WE", "TH", "FR", "SA", NULL},
				*ArcMail[] = {"ARCmail", "LZHmail", "ZIPmail", "UNKNOWN", "ARJmail"};
				
CONST BYTE		*Mtasker[] = {"MultiGEM", "Mint", NULL};

