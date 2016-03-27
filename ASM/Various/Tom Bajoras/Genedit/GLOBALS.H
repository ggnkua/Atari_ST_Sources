/******************************************************************************

                                    GenEdit
                                       by
                                  Tom Bajoras
 
                         Copyright 1990/1991 Tom Bajoras

   global variable declarations

******************************************************************************/

   /* GEM */
int contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];

	/* miscellaneous */
int ap_id;							/* application i.d. */
int gl_hand;						/* vdi handle */
int gl_font;						/* current vdi font: 0= normal, 1= mini */
int dummy;							/* throw-away word */
int rez;             			/* screen resolution:  0,1,2 */
int charh;							/* height of system font (8*rez) */
int charw;							/* width of system font (8) */
int windhndl;						/* window handle */
int an_rte= 0x4e73;				/* rte instruction */
int an_rts= 0x4e75;				/* rts instruction */
char *Mstate;						/* pointer to mouse buttons byte */
int *Mousex,*Mousey;				/* pointers to mouse position words */
int nmenutitl;						/* how many menu titles */
int *keyb_head,*keyb_tail;		/* --> keyboard I/O queue head and tail */
char change_flag[6];				/* whether buffers have been changed:
											ldat, rdat, cnx, macro, tem, studio setup */
long scrbase;						/* pointer to start of screen memory */
long Abase;							/* --> line A variables */
long fontptr;						/* --> system font */
long scrsave;						/* saved screen + general purpose */
	/* change this to tempbuf throughout !!! */
long cnxscrsave;					/* saved screen during cnx "window" */
int gr_color;						/* color for gr_text: WH_ON_BL, etc. */
int gr_fcolor;						/* color for gr_fill: 0-3 */
int cprnwsrow;						/* printer pagination in Cprnws() */
int no_alerts;						/* suppress alert boxes */

	/* custom mouse vector */
int menu_hi_y,menu_lo_x,menu_hi_x;			/* menu position and size */
int acc_lo_x,acc_hi_x,acc_lo_y,acc_hi_y;	/* acc part of menu bar */
char Deskacc;										/* desk accessory selected? */
long save_mvec;									/* system mouse vector */

	/* HybriSwitch */
long mshrinkamt;			/* amount m-shrunk in init */
long sw_ptr;				/* pointer to HybriSwitch structure */

	/* memory management */
long heap_start;		/* start of heap */
long heap_nbytes;		/* length of heap (bytes), div by 4 */
int nmemblks;			/* how many blocks heap is divided into */
MEMSTRUCT mem[NMEMBLKS];
HEAP heap[NHEAPBLKS];
int tempmem;				/* handle:	temporary buffer */
int cnxmem;					/* handle:	CNX buffer */
int temmem[NTEMSEGS];	/* handles:	template segments */
int cnxlclpmem;			/* handle:	CNXL clipboard */
int cnxeclpmem;			/* handle:	CNXE clipboard */
int windcnxmem[2];		/* handles:	main screen window cnx's */
int windatamem[2];		/* handles:	window data buffers */
int namemem[2];       	/* handles:	patch name buffers */
int editmem;				/* handle:	edit buffer */
int mainclpmem;			/* handle:	main screen clipboard */
int cdrmem;					/* handle:	code resource */
int seqmem;					/* handle:	internal sequencer */

	/* pointers to object trees in resource file */
OBJECT *menuaddr,*infoaddr,*fmtaddr ,*midiaddr,*moniaddr,*pathaddr,*multaddr;
OBJECT *macraddr,*cnxladdr,*veryaddr,*fnamaddr,*quitaddr,*segaddr, *windaddr;
OBJECT *ebdtaddr,*nongaddr,*cnxeaddr,*pnamaddr,*tem1addr,*butnaddr,*joyaddr;
OBJECT *lineaddr,*rectaddr,*knfdaddr,*toptaddr,*valaddr ,*numbaddr,*grphaddr;
OBJECT *textaddr,*editaddr,*popaddr ,*woptaddr,*prefaddr,*getnaddr,*stuaddr;

	/* drives and paths for disk functions */
int mlt_drive,midi_drive,cnx_drive,mac_drive;
int tem_drive,ldat_drive,rdat_drive;
int orig_drive= -1;	/* start without original drive/path saved */
char mlt_path[41],midi_path[41],cnx_path[41],mac_path[41];
char tem_path[41],ldat_path[41],rdat_path[41],orig_path[41];

	/* screen layout:  y-coords are for color, doubled at run-time for mono */
int hotspotx[NHOTSPOTS]= { 306, 33,400,302 };	/* draggable things */
int hotspoty[NHOTSPOTS]= {  17, 18, 18, 37 };
int hotspotw[NHOTSPOTS]= {  30,231,231, 38 };
int hotspoth[NHOTSPOTS]= {  17, 13, 13, 21 };
int mainclip_x= 302;
int mainclip_y= 60;
int mainclip_w= 38;
int mainclip_h= 14;
int windname_x[2]= { 12, 58 };	/* column of first character */
int windname_y=21;					/* top of character */
int window_x[2]= { 14,60 } ;		/* column coord of start of name */
int window_y=32;						/* top of first patch name */
int window_w=18;						/* width (columns) of window work area */
int window_h=19;						/* height (rows)) of window work area */
int pnumber_x[2]= { 33,400 } ;	/* patch number display columns */
int pnumber_y=31;
int pnumber_w=70;
int pnumber_h=153;
int vscroll_x[2]= { 9,376 };	/* position & size of vertical scroll bars */
int vscroll_y=31;
int vscroll_h=153;
int vscroll_w= 22;
int hscroll_x[2]= { 128,495 };	/* position & size of horiz scroll bars */
int hscroll_y=185;
int hscroll_h=11;
int hscroll_w= 111;
int up_y=19;							/* window up/down arrows */
int up_h=11;
int down_y=185;
int down_h=11;
int left_x[2]= { 104,471 };		/* window left/right arrows */
int right_x[2]= { 240,607 };
int left_w= 22;
int right_w= 22;
int area_x[2]= { 105,472 };		/* window work areas */
int area_y=31;
int area_w=159;
int area_h=153;
int studio_x1= 266;				/* studio description */
int studio_x2= 282;
int studio_x3= 355;
int studio_x4= 371;
int studio_x5= 277;
int studio_y1= 88;			/* these get doubled in monochrome */
int studio_y2= 96;
int studio_y3= 196;

	/* window variables */
char windfile[2][13];				/* data file names */
DEV_STRUCT wind_device[2];			/* device info for each window */
int npatches[2];  				   /* # patches per bank (>=0) */
PNUMFMT windpnumfmt[2];				/* patch numbering system for each window */
int homepatch[2];    				/* patch number at top of window */
int nameleng[2];     				/* characters per patch name */
int nameoffset[2];					/* where's the name in the edit buffer */
long editleng[2];     				/* bytes per patch in edit buffer */
int homechar[2];						/* character # at left of window */
char patchselect[2][MAXNPATS];	/* 1= patch selected, 0= patch not selected */
int vslide_x[2];      				/* position and size of vertical sliders */
int vslide_y[2];
int vslide_w[2];
int vslide_h[2];
int hslide_x[2];      				/* position and size of horizontal sliders */
int hslide_y[2];
int hslide_w[2];
int hslide_h[2];

/* window options */
char windsavc=1;
char windsavd=1;
char windlodc=1;
char windlodd=1;
char windlink=0;
char windpatsend[2],windpatchan[2];

	/* studio description */
DEV_STRUCT *studioDev;
CONFIG_LINK *studioLink;
int studioHome=0;

	/* user preferences */
char mrpt_delay= 0x17;
char mrpt_rate= 0x0D;
char defdataname[9]= { 'F','R','O','M','M','I','D','I',0 };
char tone_disabled=0;
char chase_disabled=0;
char quit_prot=0;
char edmouseinvrt=0;
char windprt1col=0;

	/* main screen clipboard */
char clpname[256];
int clpnameleng;

	/* MIDI */
char midithru,thruchan;
char midiovfl;
char *recv_start,*recv_end,*recv_head,*recv_tail;
char *tran_head,*tran_tail;
char *thru_head,*thru_tail;
int midi_speed,midi_filter=3;
unsigned int runningstat;			/* track running status in get_midi() */
long save_midi;						/* system midi vector */
int speedtable[6]= { 0, 50, 100, 500, 1000, 2000 };
int midi_opsys;						/* 0 normal, 1 SoftLink, 2 MROS, etc. */
long MP_bhead,MP_btail;				/* MidiPlexer buffers */
long MP_chead,MP_ctail;
long MP_dhead,MP_dtail;
char midiplexer;						/* 1= midiplexer, 0= no midiplexer */
char midi_tport,midi_rport,thru_tport,thru_rport;
int ndatabyte[21]=	{2,2,2,2,1,1,2,
							 0,1,2,1,0,0,0,
							 0,0,0,0,0,0,0 };
char midipchan=0;						/* midi patch bay automation */
char midipdelay=0;
char midi_pport=0;

	/* file headers */
FILEHEADER cnxheader= { CNXMAGIC, MACHINE, CNXVERSION };
FILEHEADER dataheader= { DATAMAGIC, MACHINE, DATAVERSION };
FILEHEADER sqcheader= { SQCMAGIC, MACHINE, SQCVERSION };
FILEHEADER stu_header= { STUMAGIC, MACHINE, STUVERSION };

	/* macro stuff */
char *macroasci[NMACROS]= {
	"A","B","C","D","E","F","G","H","I","J","K","L","M",
	"N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
	"1","2","3","4","5","6","7","8","9","0" };
char macroscan[NMACROS]= {
	SCAN_A,SCAN_B,SCAN_C,SCAN_D,SCAN_E,SCAN_F,SCAN_G,SCAN_H,SCAN_I,
	SCAN_J,SCAN_K,SCAN_L,SCAN_M,SCAN_N,SCAN_O,SCAN_P,SCAN_Q,SCAN_R,
	SCAN_S,SCAN_T,SCAN_U,SCAN_V,SCAN_W,SCAN_X,SCAN_Y,SCAN_Z,
	SCAN_1,SCAN_2,SCAN_3,SCAN_4,SCAN_5,SCAN_6,SCAN_7,SCAN_8,SCAN_9,SCAN_0
};
char *macrobuf;					/* --> macro bank */
char *macrclip;					/* --> macro clip board */
int nmacrclip;						/* # bytes on macro clip board */
char macrfile[13];				/* current macro file name */

	/* template stuff */
char temfile[13];						/* current template file name */
TEMHEADER temheader;					/* TEM file header */

	/* configuration stuff */
char cnxfile[13];						/* current config file name */
long cnxoffset[NCNX+1];				/* index to start of each CNX */
long cnxlclpoff[NCNX+1];			/* index to start of each CNX in clipboard */
char cnxname[NCNX][NCHPERCNX];	/* CNX names */
char cnxlclpname[NCNX][NCHPERCNX];	/* CNX names in clipboard */
char windcnxname[2][NCHPERCNX];	/* CNX name in each window */
int ncnxlclip;							/* clipboard stack index */
char *cnxsegname[NSEGTYPES]= {
	"Transmit  ", "Receive   ",
	"MakeEdit  ", "UnMakeEdit",
	"Send Edit ", "Initialize",
	"Get Patch ", "Put Patch ",
	"Validate  ", "Common    "
};
long cnxvars[NVARS];				/* cnx variables */
PNUMFMT cnxpnumfmt;

	/* note-icon mouse */
int note_icon[5+16+16]= {
	7,7,1,0,1,
	0x0040, 0x0060, 0x0070, 0x0058,					/* mask */
	0x004C, 0x0044, 0x0044, 0x0044,
	0x0044, 0x0040, 0x0040, 0x03C0,
	0x07C0, 0x07C0, 0x07C0, 0x0380,
	0x0040, 0x0060, 0x0070, 0x0058,					/* data */
	0x004C, 0x0044, 0x0044, 0x0044,
	0x0044, 0x0040, 0x0040, 0x03C0,
	0x07C0, 0x07C0, 0x07C0, 0x0380
};
	/* midi-icon mouse */
int midi_icon[5+16+16]= {
	7,7,1,0,1,
   0x0000, 0x0660, 0x0E70, 0x1FF8,   				/* mask */
   0x3FFC, 0x3FFC, 0x7FFE, 0x4FF2,
   0x4FF2, 0x7FFE, 0x33CC, 0x33CC,
   0x1E78, 0x0E70, 0x03C0, 0x0000,
   0x07E0, 0x1998, 0x318C, 0x6006,					/* data */
   0x4002, 0xC003, 0x8001, 0xB00D,
   0xB00D, 0x8001, 0xCC33, 0x4C32,
   0x6186, 0x318C, 0x1C38, 0x07E0
};

	/* ascii encoded hex bytes */
char *hextext[256]= {
"00","01","02","03","04","05","06","07","08","09","0A","0B","0C","0D","0E","0F",
"10","11","12","13","14","15","16","17","18","19","1A","1B","1C","1D","1E","1F",
"20","21","22","23","24","25","26","27","28","29","2A","2B","2C","2D","2E","2F",
"30","31","32","33","34","35","36","37","38","39","3A","3B","3C","3D","3E","3F",
"40","41","42","43","44","45","46","47","48","49","4A","4B","4C","4D","4E","4F",
"50","51","52","53","54","55","56","57","58","59","5A","5B","5C","5D","5E","5F",
"60","61","62","63","64","65","66","67","68","69","6A","6B","6C","6D","6E","6F",
"70","71","72","73","74","75","76","77","78","79","7A","7B","7C","7D","7E","7F",
"80","81","82","83","84","85","86","87","88","89","8A","8B","8C","8D","8E","8F",
"90","91","92","93","94","95","96","97","98","99","9A","9B","9C","9D","9E","9F",
"A0","A1","A2","A3","A4","A5","A6","A7","A8","A9","AA","AB","AC","AD","AE","AF",
"B0","B1","B2","B3","B4","B5","B6","B7","B8","B9","BA","BB","BC","BD","BE","BF",
"C0","C1","C2","C3","C4","C5","C6","C7","C8","C9","CA","CB","CC","CD","CE","CF",
"D0","D1","D2","D3","D4","D5","D6","D7","D8","D9","DA","DB","DC","DD","DE","DF",
"E0","E1","E2","E3","E4","E5","E6","E7","E8","E9","EA","EB","EC","ED","EE","EF",
"F0","F1","F2","F3","F4","F5","F6","F7","F8","F9","FA","FB","FC","FD","FE","FF"
};

	/* ascii encoded midi channels */
char *chanchar[17]= { "--","01","02","03","04","05","06","07","08",
							 "09","10","11","12","13","14","15","16" };

/* EOF */
