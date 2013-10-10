/******************************************************************************

                                     GenEdit
                                       by
                                   Tom Bajoras
 
                        Copyright 1990/1991 Tom Bajoras

   global variable externs

******************************************************************************/

/* char .....................................................................*/

extern char Deskacc;
extern char midithru,thruchan,midiovfl,midiplexer,windprt1col;
extern char windsavc,windsavd,windlodc,windlodd,windlink,edmouseinvrt;
extern char midi_tport,midi_rport,thru_tport,thru_rport;
extern char mrpt_delay,mrpt_rate,tone_disabled,chase_disabled,quit_prot;
extern char midipchan,midipdelay,midi_pport;

/* --> char .................................................................*/

extern char *Mstate;
extern char *macrobuf,*macrclip,*heapptr;
extern char *recv_start,*recv_end,*recv_head,*recv_tail;
extern char *tran_head,*tran_tail;
extern char *thru_head,*thru_tail;
extern char cnxfile[],macrfile[],temfile[],macroscan[];
extern char mlt_path[],midi_path[],cnx_path[],mac_path[];
extern char tem_path[],ldat_path[],rdat_path[],change_flag[],orig_path[];
extern char clpname[],windpatsend[],windpatchan[],defdataname[];

/* -->--> char ..............................................................*/

extern char *hextext[],*macroasci[],*chanchar[];
extern char windfile[2][13];
extern char cnxname[NCNX][NCHPERCNX],cnxlclpname[NCNX][NCHPERCNX];
extern char windcnxname[2][NCHPERCNX];
extern char *cnxsegname[];
extern char patchselect[2][MAXNPATS];

/* int ......................................................................*/

extern int ap_id,gl_hand,dummy,rez,charh,charw,windhndl,no_alerts;
extern int an_rte,an_rts,nmenutitl,nmacrclip,midi_speed,midi_filter;
extern int mainclpmem,cnxeclpmem,cdrmem,seqmem,gl_font;
extern int menu_hi_y,menu_lo_x,menu_hi_x,tempmem,cnxmem,cnxlclpmem,editmem;
extern int acc_lo_x,acc_hi_x,acc_lo_y,acc_hi_y,windname_y;
extern int mlt_drive,midi_drive,cnx_drive,mac_drive;
extern int tem_drive,ldat_drive,rdat_drive,orig_drive,nmemblks;
extern int gr_color,gr_fcolor,ncnxlclip,window_y,window_w,window_h;
extern int vscroll_y,vscroll_w,vscroll_h,hscroll_y,hscroll_w,hscroll_h;
extern int up_y,up_h,down_y,down_h,left_w,right_w,area_y,area_w,area_h;
extern int pnumber_y,pnumber_w,pnumber_h,cprnwsrow;
extern int mainclip_x,mainclip_y,mainclip_w,mainclip_h;
extern int clpnameleng,midi_opsys;
extern int studio_x1,studio_x2,studio_x3,studio_x4,studio_x5;
extern int studio_y1,studio_y2,studio_y3,studioHome;

/* --> int ..................................................................*/

extern int *Mousex,*Mousey;
extern int *keyb_head,*keyb_tail;
extern int contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];
extern int speedtable[];
extern int hotspotx[],hotspoty[],hotspotw[],hotspoth[],windcnxmem[];
extern int note_icon[],cross_icon[],windname_x[],windatamem[],temmem[];
extern int bow_icon[],window_x[],vscroll_x[],hscroll_x[],midi_icon[];
extern int npatches[],homepatch[],nameleng[],homechar[],namemem[];
extern int vslide_x[],vslide_y[],vslide_w[],vslide_h[],hslide_x[];
extern int hslide_y[],hslide_w[],hslide_h[],left_x[],right_x[],area_x[];
extern int pnumber_x[],nameoffset[];
extern int ndatabyte[];

/* long .....................................................................*/

extern long scrsave,cnxscrsave,fontptr;
extern long mshrinkamt,sw_ptr,scrbase,Abase,heapleng;
extern long heap_start,heap_nbytes;
extern long save_mvec,save_midi;
extern long MP_bhead,MP_btail;
extern long MP_chead,MP_ctail;
extern long MP_dhead,MP_dtail;

/* --> long .................................................................*/

extern long cnxoffset[],cnxlclpoff[],cnxvars[],editleng[];

/* other ....................................................................*/

extern PNUMFMT cnxpnumfmt;
extern TEMHEADER temheader;
extern FILEHEADER cnxheader,dataheader,sqcheader,stu_header;
extern unsigned int runningstat;

/* --> other ................................................................*/

extern OBJECT *menuaddr,*infoaddr,*fmtaddr ,*midiaddr,*moniaddr,*pathaddr;
extern OBJECT *macraddr,*cnxladdr,*veryaddr,*fnamaddr,*segaddr, *windaddr;
extern OBJECT *quitaddr,*multaddr,*ebdtaddr,*nongaddr,*toptaddr,*butnaddr;
extern OBJECT *cnxeaddr,*pnamaddr,*tem1addr,*rectaddr,*lineaddr,*knfdaddr;
extern OBJECT *valaddr ,*numbaddr,*grphaddr,*joyaddr ,*textaddr,*editaddr;
extern OBJECT *popaddr ,*woptaddr,*prefaddr,*getnaddr,*stuaddr;
extern HEAP heap[];
extern PNUMFMT windpnumfmt[];
extern MEMSTRUCT mem[];
extern DEV_STRUCT wind_device[];
extern DEV_STRUCT *studioDev;
extern CONFIG_LINK *studioLink;

/* EOF */
