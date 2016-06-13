/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

	extern declarations

******************************************************************************/

	/* char */
extern char deskacc,wait_for,mutebyte,midi_sync,play_pause;
extern char Freezex,Freezey,throwaway,clockdivider,midithru,thruchan,thruport;
extern char savectl_d,savedat_d,record_on,sysexflag,runningstat;
extern char timer_a,timer_d,no_dissolve,play_safe,lazy_mouse,plexer_on;

	/* --> char */
extern char *Mstate,*tranbuf,*tranhead,*trantail,*loopcnt;
extern char *seqdata,*nonrdata,*pitchdata,*rhythmdata,*masterdata,*notestat;
extern char maj_scale[],min_scale[],def_velmap[],clockdivs[],songname[];
extern char nchords[],nntrsts[],_nchords[],_nntrsts[],nchords1[],nntrsts1[];
extern char *wind_seq,*wind_type;

	/* --> --> char */
extern char *seq1data[],*nonr1data[],*pitch1data[],*rhyth1data[],*segptr[];
extern char *chromas[],*chromaf[],*windptr[],*vchar[],*int1char[],*int2char[];
extern char *vchar[],*int1char[],*int2char[],*p_opers[],*r_opers[],*editptr[];
extern char *orderchar[],*selectp[],*selectr[],*syncchar[],*yesnochar[];
extern char *plusminus[],*stepchar[],*timechar[],*chromachar[],*dialptr[];
extern char *dialname2[],*dialname3[];
extern char tempodivs[][8];
extern char nnotes[][NCHD],nt_or_rst[][NCHD];
extern char _nnotes[][NCHD],_nt_or_rst[][NCHD];

	/* --> --> --> char */
extern char notes[][NCHD][16];
extern char _notes[][NCHD][16];

	/* int */
extern int Downx,Downy,Upx,Upy,midiplex;
extern int menu_lo_x,menu_hi_x,menu_hi_y,bytesperline;
extern int acc_lo_x,acc_hi_x,acc_lo_y,acc_hi_y,edprchan;
extern int ap_id,gl_hand,windhndl,dummy,rez,debugflag,xor_lock;
extern int editwind,editmode,dialwind,play_mode;
extern int DMAadr,edpplex,edrtplex,edrwith,edpwith;
extern int fillmode,fillwind,fillparnum,fill_y,fill_y2;
extern int maincrc,mainchksum;

	/* --> int */
extern int *Mousex,*Mousey,*wind_y,*val_y,*tag_y,*keyb_head,*keyb_tail;
extern int messbuf[],wind1_y[],wind2_y[],val1_y[],val2_y[],tag1_y[],tag2_y[];
extern int contrl[],intin[],ptsin[],intout[],ptsout[];
extern int typetags[],nparams[],r_hlim[],p_hlim[],wind_start[];
extern int vdx[],xorc_col[],xorc_row[],xorp_col[],xorp_row[],ldsvobj[];
extern int px[],rx[],pready[],rready[],keycmds[],playkeycmds[];
extern int editparnum[],editval[],oldval[],exactdur[],legato[],_legato[];
extern int pxor_p[],pxor_r[],pxor_pp[],pxor_rr[],pxor_ppp[],pxor_rrr[];

	/* --> --> int */
extern int *oper_hlim[];

	/* long */
extern long savemvec,scrsave,scrbase,Abase,save_tran,save_spur;
extern long dial_addr,fontptr,mshrinkamt,sw_ptr,save_butv,save_motv;
extern long masterclock,softclock,stop_time,nextclock,timestamp;
extern long MPtrBbuf,MPtrCbuf,MPtrDbuf;
extern long MPtrBlim,MPtrClim,MPtrDlim;
extern long MPtrBhead,MPtrBtail,MPtrChead,MPtrCtail,MPtrDhead,MPtrDtail;

	/* --> long */
extern long segleng[],windleng[],dialleng[],nextevent[];
extern long p_func[],r_func[];
extern char *recstart,*rectail,*recend;

	/* --> --> long */
extern long *playstart[],*playhead[],*playtail[],*playend[];
extern long duration[][NCHD];
extern long _duration[][NCHD];

	/* --> struct */
extern OBJECT *menuaddr,*infoaddr,*fmtaddr,*drivaddr,*ldsvaddr,*grpaddr;
extern OBJECT *veloaddr,*copyaddr,*scaladdr,*edpaddr,*edraddr,*tempaddr;
extern OBJECT *trakaddr,*filladdr,*syncaddr,*thruaddr,*sharaddr;
extern PARAM pparams[],rparams[],vparams[],editparam[],fillparam;

	/* --> --> struct */
extern PARAM *params[];

/************************************* EOF ***********************************/
