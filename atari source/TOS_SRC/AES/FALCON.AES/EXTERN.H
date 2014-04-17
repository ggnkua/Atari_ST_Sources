/*	EXTERN.H		6/12/89 - 6/13/89	Derek Mui	*/
/*	Take out some variable	6/28/89					*/

/* EXTERN	WORD	namecon; */	/* name conflict flag		*/
EXTERN	BYTE	dr[];
EXTERN	WORD	p_timedate;		/* preserve time and date	*/


EXTERN	WINDOW	*ww_win;

EXTERN WORD	d_nrows;
EXTERN WORD	d_level;
EXTERN BYTE	*d_path;

EXTERN WORD	gl_hchar;
EXTERN WORD	gl_wchar;
EXTERN WORD	gl_hbox;
EXTERN WORD	gl_wbox;

EXTERN WORD	gl_nrows;
EXTERN WORD	gl_ncols;

/* EXTERN WORD	work_in[];	*/	/* Input to GSX parameter array */
/* EXTERN WORD	work_out[];	*/	/* Output from GSX parameter array */
EXTERN WORD	pxyarray[];		/* input point array 		*/

EXTERN WORD	d_xywh[];		/* disk icon pline points	*/
EXTERN WORD	f_xywh[];		/* file icon pline points	*/

EXTERN OBJECT	*menu_addr;		/* menu address			*/
EXTERN OBJECT	*background;		/* desktop object address	*/	

EXTERN GRECT	dicon;		/* desktop icon size			*/
EXTERN GRECT	r_dicon;	/* real time desktop icon size		*/
EXTERN OBJECT	*iconaddr;	/* desktop icon dialogue address	*/
EXTERN WORD	maxicon;	/* max number of desktop icons		*/

EXTERN WORD	i_status;	/* current status TURE or FALSE		*/

/* EXTERN WORD	g_defdrv;	*/ /* save the default drive		*/

EXTERN LONG	gh_buffer;

EXTERN IDTYPE	*backid;	/* background icon type definition	*/

EXTERN APP	*appnode;
EXTERN APP	*appfree;
EXTERN APP	*applist;

EXTERN BYTE	path1[];
EXTERN BYTE	path2[];
EXTERN BYTE	*path3;
EXTERN BYTE	inf_path[];

EXTERN DTA	dtabuf;		/* dta buffer	*/

EXTERN WINDOW	*warray[];	


/*	Variables for the desktop.inf file	*/

EXTERN WORD	s_sort;		/* sort item	*/
EXTERN WORD	s_view;		/* view item	*/
EXTERN WORD	ccopy_save;	/* copy ?	*/
EXTERN WORD	cdele_save;	/* delete ?	*/
EXTERN WORD	write_save;	/* write ?	*/
EXTERN WORD	cbit_save;	/* bitblt 	*/
EXTERN WORD	pref_save;	/* screen pref	*/
EXTERN WORD	s_cache;	/* cache 	*/
EXTERN WORD	s_stofit;	/* size to fit	*/
EXTERN UWORD	windspec;	/* window pattern spec	*/

/************************************************/

EXTERN BYTE	autofile[];

EXTERN BYTE	path2[];
EXTERN BYTE	g_buffer[];

/* EXTERN BYTE	mbuffer[];	*/

EXTERN BYTE	comtail[];

EXTERN WINDOW	winpd[];		/* window process structure	*/
EXTERN WINDOW	*winhead;
EXTERN GRECT	full;			/* full window size value	*/

EXTERN GRECT	fobj;		/* file object	*/

EXTERN	WORD	deskp[];
EXTERN	WORD	winp[];

EXTERN	BYTE	wildext[];
EXTERN	BYTE	infdata[];
EXTERN	BYTE	infpath[];
EXTERN	BYTE	wilds[];
EXTERN	BYTE	icndata[];
EXTERN	BYTE	noext[];

EXTERN	BYTE 	getall[];
EXTERN	BYTE 	bckslsh[];
EXTERN	BYTE 	curall[];
EXTERN	BYTE 	baklvl[];

/*	EXTERN	BYTE	Alloc[];	*/

EXTERN	BYTE	Nextline[];
EXTERN	BYTE	Nostr[];
