/*
 * Master TOS Header File (Pragmas/Protos for Pure C)
 * Composed by Scott Sanders
 *
 * Last Update: 9/24/94 (SDS)
 *
 * Include File Hierarchy:
 *     TOS.H
 *         |- TOSDEFS.H
 *                    |- PORTAB.H
 *     ...Application Include Files...
 */
 
#ifndef _tos_h_
#define _tos_h_

#include <TOSDEFS.H>

/********************************************************** GEMDOS ******/

LONG    gemdos( void, ... );

void    Pterm0( void );
LONG    Cconin( void );
void    Cconout( WORD c );
WORD    Cauxin( void );
void    Cauxout( WORD c );
WORD    Cprnout( WORD c );
LONG    Crawio( WORD w );
LONG    Crawcin( void );
LONG    Cnecin( void );
WORD    Cconws( const char *buf );
void    Cconrs( LINE *buf );
WORD    Cconis( void );
LONG    Dsetdrv( WORD drv );
WORD	Cconos( void );
WORD    Cprnos( void );
WORD    Cauxis( void );
WORD    Cauxos( void );
WORD    Dgetdrv( void );
void    Fsetdta( DTA *buf );
LONG    Super( void *stack );
UWORD  	Tgetdate( void );
UWORD 	Tsetdate( UWORD date );
UWORD  	Tgettime( void );
UWORD  	Tsettime( UWORD time );
DTA     *Fgetdta( void );
WORD    Sversion( void );
void    Ptermres( LONG keepcnt, WORD retcode );
WORD    Dfree( DISKINFO *buf, WORD driveno );
WORD    Dcreate( const char *path );
WORD    Ddelete( const char *path );
WORD    Dsetpath( const char *path );
LONG    Fcreate( const char *filename, WORD attr );
LONG    Fopen( const char *filename, WORD mode );
WORD    Fclose( WORD handle );
LONG    Fread( WORD handle, LONG count, void *buf );
LONG    Fwrite( WORD handle, LONG count, void *buf );
WORD    Fdelete( const char *filename );
LONG    Fseek( LONG offset, WORD handle, WORD seekmode );
WORD    Fattrib( const char *filename, WORD wflag, WORD attrib );
LONG    Fdup( WORD handle );
WORD    Fforce( WORD stch, WORD nonstdh );
WORD    Dgetpath( char *path, WORD driveno );
void    *Malloc( LONG number );
WORD    Mfree( void *block );
WORD    Mshrink( WORD zero, void *block, LONG newsiz );
LONG    Pexec( WORD mode, char *ptr1, void *ptr2, void *ptr3 );
void    Pterm( WORD retcode );
WORD    Fsfirst( const char *filename, WORD attr );
WORD    Fsnext( void );
WORD    Frename( WORD zero, const char *oldname, const char *newname );
WORD    Fdatime( DATETIME *timeptr, WORD handle, WORD wflag );

/****** TOS 030 Gemdos Extension ****************************************/

void    *Mxalloc( LONG number, WORD mode );
LONG    Maddalt( void *start, LONG size );
LONG    Flock( WORD handle, WORD mode, LONG start, LONG length );

/************************************************************ BIOS ******/

LONG    bios( void, ... );

void    Getmpb( MPB *ptr );
WORD    Bconstat( WORD dev );
LONG    Bconin( WORD dev );
void    Bconout( WORD dev, WORD c );
LONG    Rwabs( WORD rwflag, void *buf, WORD cnt, WORD recnr, WORD dev );
void    (*Setexc( WORD number, void (*exchdlr)() )) ();
LONG    Tickcal( void );
BPB     *Getbpb( WORD dev );
LONG    Bcostat( WORD dev );
LONG    Mediach( WORD dev );
LONG    Drvmap( void );
LONG    Kbshift( WORD mode );

/*********************************************************** XBIOS ******/

LONG	xbios( void, ... );

void    Initmouse( WORD type, MOUSE *par, void (*mousevec)() );
void    *Ssbrk( WORD count );
void    *Physbase( void );
void    *Logbase( void );
WORD    Getrez( void );
void    Setscreen( void *laddr, void *paddr, WORD rez );
void    Setpalette( void *pallptr );
WORD    Setcolor( WORD colornum, WORD color );
WORD    Floprd( void *buf, void *filler, WORD devno, WORD sectno,
               WORD trackno, WORD sideno, WORD count );
WORD    Flopwr( void *buf, void *filler, WORD devno, WORD sectno,
               WORD trackno, WORD sideno, WORD count );
WORD    Flopfmt( void *buf, void *filler, WORD devno, WORD spt, WORD trackno,
                WORD sideno, WORD interlv, LONG magic, WORD virgin );
void    Midiws( WORD cnt, void *ptr );
void    Mfpint( WORD erno, void (*vector)() );
IOREC   *Iorec( WORD dev );
LONG    Rsconf( WORD baud, WORD ctr, WORD ucr, WORD rsr, WORD tsr, WORD scr );
KEYTAB  *Keytbl( void *unshift, void *shift, void *capslock );
LONG    Random( void );
void    Protobt( void *buf, LONG serialno, WORD disktype, WORD execflag );
WORD    Flopver( void *buf, void *filler, WORD devno, WORD sectno,
                WORD trackno, WORD sideno, WORD count );
void    Scrdmp( void );
WORD    Cursconf( WORD func, WORD rate );
void    Settime( ULONG time );
ULONG  	Gettime( void );
void    Bioskeys( void );
void    Ikbdws( WORD count, void *ptr );
void    Jdisint( WORD number );
void    Jenabint( WORD number );
char    Giaccess( char data, WORD regno );
void    Offgibit( WORD bitno );
void    Ongibit( WORD bitno );
void    Xbtimer( WORD timer, WORD control, WORD data, void (*vector)() );
void    *Dosound( void *buf );
WORD    Setprt( WORD config );
KBDVECS *Kbdvbase( void );
WORD    Kbrate( WORD initial, WORD repeat );
void    Prtblk( PRTBLK *par );
void    Vsync( void );
LONG    Supexec( LONG (*func)() );
void    Puntaes( void );
WORD    Floprate( WORD devno, WORD newrate );
WORD    Blitmode( WORD mode );
WORD    DMAread( LONG sector, WORD count, void *buffer, WORD devno );
WORD    DMAwrite( LONG sector, WORD count, void *buffer, WORD devno );
WORD    NVMaccess( WORD opcode, WORD start, WORD count, void *buffer );
LONG    Bconmap( WORD devno );
WORD    Esetshift( WORD shftMode );
WORD    Egetshift( void );
WORD    EsetBank( WORD bankNum );
WORD    EsetColor( WORD colorNum, WORD color );
void    EsetPalette( WORD colorNum, WORD count, WORD *palettePtr );
void    EgetPalette( WORD colorNum, WORD count, WORD *palettePtr );
WORD    EsetGray( WORD swtch );
WORD    EsetSmear( WORD swtch );

/************************************************************** MiNT *****/

WORD    Syield( void );
WORD    Fpipe( WORD *usrh );
WORD    Fcntl( WORD f, LONG arg, WORD cmd );
LONG    Finstat( WORD f );
LONG    Foutstat( WORD f );
LONG    Fgetchar( WORD f, WORD mode );
LONG    Fputchar( WORD f, LONG c, WORD mode );
LONG    Pwait( void );
WORD    Pnice( WORD delta );
WORD    Pgetpid( void );
WORD    Pgetppid( void );
WORD    Pgetpgrp( void );
WORD    Psetpgrp( WORD pid, WORD newgrp );
WORD    Pgetuid( void );
WORD    Psetuid( WORD id );
WORD    Pkill( WORD pid, WORD sig );
void    *Psignal( WORD sig, void *handler );
WORD    Pvfork( void );
WORD    Pgetgid( void );
WORD    Psetgid( WORD id );
LONG    Psigblock( LONG mask );
LONG    Psigsetmask( LONG mask );
LONG    Pusrval( LONG arg );
WORD    Pdomain( WORD newdom );
void    Psigreturn( void );
WORD    Pfork( void );
LONG    Pwait3( WORD flag, LONG *rusage );
WORD    Fselect( UWORD timeout, LONG *rfds, LONG *wfds, LONG *xfds );
void    Prusage( LONG *r );
LONG    Psetlimit( WORD lim, LONG value );
LONG    Talarm( LONG secs );
void    Pause( void );
LONG    Sysconf( WORD n );
LONG    Psigpending( void );
LONG    Dpathconf( char *name, WORD n );
LONG    Pmsg( WORD mode, LONG mbox, MSG *msg );
LONG    Fmidipipe( WORD pid, WORD in, WORD out );
WORD    Prenice( WORD pid, WORD delta );
LONG    Dopendir( char *name, WORD flag );
LONG    Dreaddir( WORD buflen, LONG dir, char *buf );
LONG    Drewinddir( LONG dir );
LONG    Dclosedir( LONG dir );
LONG    Fxattr( WORD flag, char *name, XATTR *buf );
LONG    Flink( char *oldname, char *newname );
LONG    Fsymlink( char *oldname, char *newname );
LONG    Freadlink( WORD size, char *buf, char *name );
LONG    Dcntl( WORD cmd, char *name, LONG arg );
LONG    Fchown( char *name, WORD uid, WORD gid );
LONG    Fchmod( char *name, WORD mode );
LONG    Pumask( UWORD mode );
LONG    Psemaphore( WORD mode, LONG id, LONG timeout );
LONG    Dlock( WORD mode, WORD drive );
void    Psigpause( ULONG mask );
LONG    Psigaction( WORD sig, SIGACTION *act, SIGACTION *oact );
WORD    Pgeteuid( void );
WORD    Pgetegid( void );
LONG    Pwaitpid( WORD pid, WORD flag, LONG *rusage );

#define	Locksnd	locksnd
#define Unlocksnd	unlocksnd
#define Soundcmd	soundcmd
#define Setbuffer	setbuffer
#define	Setmode	setmode
#define Settracks	settracks
#define Setmontracks	setmontracks
#define Setinterrupt  setinterrupt
#define Buffoper	buffoper
#define Dsptristate	dsptristate
#define Gpio		gpio
#define Devconnect	devconnect
#define Sndstatus	sndstatus
#define Buffptr	buffptr

LONG    locksnd( void );
LONG    unlocksnd( void );
LONG    soundcmd( WORD mode, WORD data );
LONG    setbuffer( WORD reg, void *begaddr, void *endaddr );
LONG    setmode( WORD mode );
LONG    settracks( WORD playtracks, WORD rectracks );
LONG    setmontracks( WORD montrack );
LONG    setinterrupt( WORD src_inter, WORD cause );
LONG    buffoper( WORD mode );
LONG    dsptristate( WORD dspxmit, WORD dsprec );
LONG    gpio( WORD mode, WORD data );
LONG    devconnect( WORD src, WORD dst, WORD srcclk, WORD prescale,
                    WORD protocol );
LONG    sndstatus( WORD reset );
LONG    buffptr( LONG *ptr );

WORD    Dsp_LoadProg( char *file, WORD ability, char *buffer );
LONG    Dsp_LodToBinary( char *file, char *codeptr );
void    Dsp_DoBlock( char *data_in, LONG size_in, char *data_out,
                     LONG size_out );
void    Dsp_BlkHandShake( char *data_in, LONG size_in, char *data_out,
                          LONG size_out );
void    Dsp_BlkUnpacked( LONG *data_in, LONG size_in, LONG *data_out,
                         LONG size_out );
void    Dsp_InStream( char *data_in, LONG block_size, LONG num_blocks,
                      LONG *blocks_done );
void    Dsp_OutStream( char *data_out, LONG block_size, LONG num_blocks,
                       LONG *blocks_done );
void    Dsp_IOStream( char *data_in, char *data_out, LONG block_insize,
                      LONG block_outsize, LONG num_blocks,
                      LONG *blocks_done );
void    Dsp_RemoveInterrupts( WORD mask );
WORD    Dsp_GetWordSize( void );
WORD    Dsp_Lock( void );
void    Dsp_Unlock( void );
void    Dsp_Available( LONG *xavailable, LONG *yavailable );
WORD    Dsp_Reserve( LONG xreserve, LONG yreserve );
void    Dsp_ExecProg( char *codeptr, LONG codesize, WORD ability );
void    Dsp_ExecBoot( char *codeptr, LONG codesize, WORD ability );
void    Dsp_TriggerHC( WORD vector );
WORD    Dsp_RequestUniqueAbility( void );
WORD    Dsp_GetProgAbility( void );
void    Dsp_FlushSubroutines( void );
WORD    Dsp_LoadSubroutine( char *codeptr, LONG codesize, WORD ability );
WORD    Dsp_InqSubrAbility( WORD ability );
WORD    Dsp_RunSubroutine( WORD handle );
WORD    Dsp_Hf0( WORD flag );
WORD    Dsp_Hf1( WORD flag );
WORD    Dsp_Hf2( void );
WORD    Dsp_Hf3( void );
void    Dsp_BlkWords( void *data_in, LONG size_in, void *data_out,
                      LONG size_out );
void    Dsp_BlkBytes( void *data_in, LONG size_in, void *data_out,
                      LONG size_out );
char    Dsp_HStat( void );
void    Dsp_SetVectors( void (*receiver)( ), LONG (*transmitter)( ));
void    Dsp_MultBlocks( LONG numsend, LONG numreceive,
                        DSPBLOCK *sendblocks, DSPBLOCK *receiveblocks );
WORD    Vsetmode( WORD modecode );
WORD    mon_type( void );
#define VsetMode	Vsetmode
#define VgetMonitor	mon_type
LONG    VgetSize( WORD mode );
void    VsetSync( WORD flag );
void    VsetRGB( WORD index, WORD count, LONG *array );
void    VgetRGB( WORD index, WORD count, LONG *array );
void    VsetMask( WORD ormask, WORD andmask, WORD overlay );

/************************************************************* AES ******/

WORD  vq_aes( void );
void _crystal( AESPB *aespb );

WORD appl_init( void );
WORD appl_read( WORD ap_rid, WORD ap_rlength, void *ap_rpbuff );
WORD appl_write( WORD ap_wid, WORD ap_wlength, void *ap_wpbuff );
WORD appl_find( const char *ap_fpname );
WORD appl_tplay( void *ap_tpmem, WORD ap_tpnum, WORD ap_tpscale );
WORD appl_trecord( void *ap_trmem, WORD ap_trcount );
WORD appl_exit( void );
WORD appl_search( WORD ap_smode, char *ap_sname, WORD *ap_stype,
                 WORD *ap_sid );
WORD appl_getinfo( WORD ap_gtype, WORD *ap_gout1, WORD *ap_gout2,
                  WORD *ap_gout3, WORD *ap_gout4 );

WORD evnt_keybd( void );
WORD evnt_button( WORD ev_bclicks, WORD ev_bmask, WORD ev_bstate,
                 WORD *ev_bmx, WORD *ev_bmy, WORD *ev_bbutton,
                 WORD *ev_bkstate );
WORD evnt_mouse( WORD ev_moflags, WORD ev_mox, WORD ev_moy,
                WORD ev_mowidth, WORD ev_moheight, WORD *ev_momx,
                WORD *ev_momy, WORD *ev_mobutton,
                WORD *ev_mokstate );
WORD evnt_mesag( WORD *ev_mgpbuff );
WORD evnt_timer( WORD ev_tlocount, WORD ev_thicount );
WORD evnt_multi( WORD ev_mflags, WORD ev_mbclicks, WORD ev_mbmask,
                WORD ev_mbstate, WORD ev_mm1flags, WORD ev_mm1x,
                WORD ev_mm1y, WORD ev_mm1width, WORD ev_mm1height,
                WORD ev_mm2flags, WORD ev_mm2x, WORD ev_mm2y,
                WORD ev_mm2width, WORD ev_mm2height,
                WORD *ev_mmgpbuff, WORD ev_mtlocount,
                WORD ev_mthicount, WORD *ev_mmox, WORD *ev_mmoy,
                WORD *ev_mmbutton, WORD *ev_mmokstate,
                WORD *ev_mkreturn, WORD *ev_mbreturn );
WORD evnt_dclick( WORD ev_dnew, WORD ev_dgetset );

WORD EvntMulti( EVENT *evnt_struct );

WORD menu_bar( OBJECT *me_btree, WORD me_bshow );
WORD menu_icheck( OBJECT *me_ctree, WORD me_citem, WORD me_ccheck );
WORD menu_ienable( OBJECT *me_etree, WORD me_eitem,
                  WORD me_eenable );
WORD menu_tnormal( OBJECT *me_ntree, WORD me_ntitle,
                  WORD me_nnormal );
WORD menu_text( OBJECT *me_ttree, WORD me_titem,
               const char *me_ttext );
WORD menu_register( WORD me_rapid, const char *me_rpstring );
WORD menu_popup( MENU *me_menu, WORD me_xpos, WORD me_ypos,
                MENU *me_mdata );
WORD menu_attach( WORD me_flag, OBJECT *me_tree, WORD me_item,
                 MENU *me_mdata );
WORD menu_istart( WORD me_flag, OBJECT *me_tree, WORD me_imenu,
                 WORD me_item );
WORD menu_settings( WORD me_flag, MN_SET *me_values );


WORD objc_add( OBJECT *ob_atree, WORD ob_aparent, WORD ob_achild );
WORD objc_delete( OBJECT *ob_dltree, WORD ob_dlobject );
WORD objc_draw( OBJECT *ob_drtree, WORD ob_drstartob,
               WORD ob_drdepth, WORD ob_drxclip, WORD ob_dryclip,
               WORD ob_drwclip, WORD ob_drhclip );
WORD objc_find( OBJECT *ob_ftree, WORD ob_fstartob, WORD ob_fdepth,
               WORD ob_fmx, WORD ob_fmy );
WORD objc_offset( OBJECT *ob_oftree, WORD ob_ofobject,
                 WORD *ob_ofxoff, WORD *ob_ofyoff );
WORD objc_order( OBJECT *ob_ortree, WORD ob_orobject,
                WORD ob_ornewpos );
WORD objc_edit( OBJECT *ob_edtree, WORD ob_edobject,
               WORD ob_edchar, WORD *ob_edidx, WORD ob_edkind );
WORD objc_change( OBJECT *ob_ctree, WORD ob_cobject,
                 WORD ob_cresvd, WORD ob_cxclip, WORD ob_cyclip,
                 WORD ob_cwclip, WORD ob_chclip,
                 WORD ob_cnewstate, WORD ob_credraw );

WORD form_do( OBJECT *fo_dotree, WORD fo_dostartob );
WORD form_dial( WORD fo_diflag, WORD fo_dilittlx,
               WORD fo_dilittly, WORD fo_dilittlw,
               WORD fo_dilittlh, WORD fo_dibigx,
               WORD fo_dibigy, WORD fo_dibigw, WORD fo_dibigh );
WORD form_alert( WORD fo_adefbttn, const char *fo_astring );
WORD form_error( WORD fo_enum );
WORD form_center( OBJECT *fo_ctree, WORD *fo_cx, WORD *fo_cy,
                 WORD *fo_cw, WORD *fo_ch );
WORD form_keybd( OBJECT *fo_ktree, WORD fo_kobject, WORD fo_kobnext,
                WORD fo_kchar, WORD *fo_knxtobject, WORD *fo_knxtchar );
WORD form_button( OBJECT *fo_btree, WORD fo_bobject, WORD fo_bclicks,
                WORD *fo_bnxtobj );

WORD graf_rubberbox( WORD gr_rx, WORD gr_ry, WORD gr_minwidth,
                    WORD gr_minheight, WORD *gr_rlastwidth,
                    WORD *gr_rlastheight );
WORD graf_rubbox( WORD gr_rx, WORD gr_ry, WORD gr_minwidth,
                    WORD gr_minheight, WORD *gr_rlastwidth,
                    WORD *gr_rlastheight );
WORD graf_dragbox( WORD gr_dwidth, WORD gr_dheight,
                  WORD gr_dstartx, WORD gr_dstarty,
                  WORD gr_dboundx, WORD gr_dboundy,
                  WORD gr_dboundw, WORD gr_dboundh,
                  WORD *gr_dfinishx, WORD *gr_dfinishy );
WORD graf_movebox( WORD gr_mwidth, WORD gr_mheight,
                  WORD gr_msourcex, WORD gr_msourcey,
                  WORD gr_mdestx, WORD gr_mdesty );
WORD graf_mbox( WORD gr_mwidth, WORD gr_mheight,
                  WORD gr_msourcex, WORD gr_msourcey,
                  WORD gr_mdestx, WORD gr_mdesty );
WORD graf_growbox( WORD gr_gstx, WORD gr_gsty,
                  WORD gr_gstwidth, WORD gr_gstheight,
                  WORD gr_gfinx, WORD gr_gfiny,
                  WORD gr_gfinwidth, WORD gr_gfinheight );
WORD graf_shrinkbox( WORD gr_sfinx, WORD gr_sfiny,
                    WORD gr_sfinwidth, WORD gr_sfinheight,
                    WORD gr_sstx, WORD gr_ssty,
                    WORD gr_sstwidth, WORD gr_sstheight );
WORD graf_watchbox( OBJECT *gr_wptree, WORD gr_wobject,
                   WORD gr_winstate, WORD gr_woutstate );
WORD graf_slidebox( OBJECT *gr_slptree, WORD gr_slparent,
                   WORD gr_slobject, WORD gr_slvh );
WORD graf_handle( WORD *gr_hwchar, WORD *gr_hhchar,
                 WORD *gr_hwbox, WORD *gr_hhbox );
WORD graf_mouse( WORD gr_monumber, MFORM *gr_mofaddr );
WORD graf_mkstate( WORD *gr_mkmx, WORD *gr_mkmy,
                  WORD *gr_mkmstate, WORD *gr_mkkstate );

WORD scrp_read( char *sc_rpscrap );
WORD scrp_write( char *sc_wpscrap );

WORD fsel_input( char *fs_iinpath, char *fs_iinsel,
                WORD *fs_iexbutton );
WORD fsel_exinput( char *fs_einpath, char *fs_einsel,
                WORD *fs_eexbutton, char *fs_elabel );

WORD wind_create( WORD wi_crkind, WORD wi_crwx, WORD wi_crwy,
                 WORD wi_crww, WORD wi_crwh );
WORD wind_open( WORD wi_ohandle, WORD wi_owx, WORD wi_owy,
               WORD wi_oww, WORD wi_owh );
WORD wind_close( WORD wi_clhandle );
WORD wind_delete( WORD wi_dhandle );
WORD wind_get( WORD wi_ghandle, WORD wi_gfield, ... );
WORD wind_set( WORD wi_shandle, WORD wi_sfield, ... );
WORD wind_find( WORD wi_fmx, WORD wi_fmy );
WORD wind_update( WORD wi_ubegend );
WORD wind_calc( WORD wi_ctype, WORD wi_ckind, WORD wi_cinx,
               WORD wi_ciny, WORD wi_cinw, WORD wi_cinh,
               WORD *coutx, WORD *couty, WORD *coutw,
               WORD *couth );
void wind_new( void );

WORD rsrc_load( const char *re_lpfname );
WORD rsrc_free( void );
WORD rsrc_gaddr( WORD re_gtype, WORD re_gindex, void *gaddr );
WORD rsrc_saddr( WORD re_stype, WORD re_sindex, void *saddr );
WORD rsrc_obfix( OBJECT *re_otree, WORD re_oobject );
WORD rsrc_rcfix( RSHDR *rc_header );

WORD shel_read( char *sh_rpcmd, char *sh_rptail );
WORD shel_write( WORD sh_wdoex, WORD sh_wisgr, WORD sh_wiscr,
                char *sh_wpcmd, char *sh_wptail );
WORD shel_get( char *sh_gaddr, WORD sh_glen );
WORD shel_put( char *sh_paddr, WORD sh_plen );
WORD shel_find( char *sh_fpbuff );
WORD shel_envrn( char **sh_epvalue, char *sh_eparm );

/************************************************************* VDI ******/

void vdi( VDIPB *vdipb );

void v_opnwk( WORD *work_in,  WORD *handle, WORD *work_out);
void v_clswk( WORD handle );
void v_opnvwk( WORD *work_in, WORD *handle, WORD *work_out);
void v_clsvwk( WORD handle );
void v_clrwk( WORD handle );
void v_updwk( WORD handle );
WORD vst_load_fonts( WORD handle, WORD select );
void vst_unload_fonts( WORD handle, WORD select );
void vs_clip( WORD handle, WORD clip_flag, WORD *pxyarray );

void v_pline( WORD handle, WORD count, WORD *pxyarray );
void v_pmarker( WORD handle, WORD count, WORD *pxyarray );
void v_gtext( WORD handle, WORD x, WORD y, char *string );
void v_fillarea( WORD handle, WORD count, WORD *pxyarray );
void v_cellarray( WORD handle, WORD *pxyarray, WORD row_length,
                     WORD el_used, WORD num_rows, WORD wrt_mode,
                     WORD *colarray );
void v_contourfill( WORD handle, WORD x, WORD y, WORD index );
void vr_recfl( WORD handle, WORD *pxyarray );
void v_bar( WORD handle, WORD *pxyarray );
void v_arc( WORD handle, WORD x, WORD y, WORD radius,
               WORD begang, WORD endang );
void v_pieslice( WORD handle, WORD x, WORD y, WORD radius,
                    WORD begang, WORD endang );
void v_circle( WORD handle, WORD x, WORD y, WORD radius );
void v_ellarc( WORD handle, WORD x, WORD y, WORD xradius,
                  WORD yradius, WORD begang, WORD endang );
void v_ellpie( WORD handle, WORD x, WORD y, WORD xradius,
                  WORD yradius, WORD begang, WORD endang );
void v_ellipse( WORD handle, WORD x, WORD y, WORD xradius,
                   WORD yradius  );
void v_rbox  ( WORD handle, WORD *pxyarray );
void v_rfbox ( WORD handle, WORD *pxyarray );
void v_justified( WORD handle,WORD x, WORD y, char *string,
                     WORD length, WORD word_space,
                     WORD char_space );

WORD vswr_mode( WORD handle, WORD mode );
void vs_color( WORD handle, WORD index, WORD *rgb_in );
WORD vsl_type( WORD handle, WORD style );
void vsl_udsty( WORD handle, WORD pattern );
WORD vsl_width( WORD handle, WORD width );
WORD vsl_color( WORD handle, WORD color_index );
void vsl_ends( WORD handle, WORD beg_style, WORD end_style );
WORD vsm_type( WORD handle, WORD symbol );
WORD vsm_height( WORD handle, WORD height );
WORD vsm_color( WORD handle, WORD color_index );
void vst_height( WORD handle, WORD height, WORD *char_width,
                    WORD *char_height, WORD *cell_width,
                    WORD *cell_height );
WORD vst_point( WORD handle, WORD point, WORD *char_width,
                    WORD *char_height, WORD *cell_width,
                    WORD *cell_height );
WORD vst_rotation( WORD handle, WORD angle );
WORD vst_font( WORD handle, WORD font );
WORD vst_color( WORD handle, WORD color_index );
WORD vst_effects( WORD handle, WORD effect );
void vst_alignment( WORD handle, WORD hor_in, WORD vert_in,
                       WORD *hor_out, WORD *vert_out );
WORD vsf_interior( WORD handle, WORD style );
WORD vsf_style( WORD handle, WORD style_index );
WORD vsf_color( WORD handle, WORD color_index );
WORD vsf_perimeter( WORD handle, WORD per_vis );
void vsf_udpat( WORD handle, WORD *pfill_pat, WORD planes );


void vro_cpyfm( WORD handle, WORD vr_mode, WORD *pxyarray,
                   MFDB *psrcMFDB, MFDB *pdesMFDB );
void vrt_cpyfm( WORD handle, WORD vr_mode, WORD *pxyarray,
                   MFDB *psrcMFDB, MFDB *pdesMFDB,
                   WORD *color_index );
void vr_trnfm( WORD handle, MFDB *psrcMFDB, MFDB *pdesMFDB );
void v_get_pixel( WORD handle, WORD x, WORD y, WORD *pel,
                     WORD *index );

void vsin_mode( WORD handle, WORD dev_type, WORD mode );
void vrq_locator( WORD handle, WORD x, WORD y, WORD *xout,
                     WORD *yout, WORD *term );
WORD vsm_locator( WORD handle, WORD x, WORD y, WORD *xout,
                     WORD *yout, WORD *term );
void vrq_valuator( WORD handle, WORD valuator_in,
                      WORD *valuator_out, WORD *terminator );
void vsm_valuator( WORD handle, WORD val_in, WORD *val_out,
                      WORD *term, WORD *status );
void vrq_choice( WORD handle, WORD ch_in, WORD *ch_out );
WORD vsm_choice( WORD handle, WORD *choice );
void vrq_string( WORD handle, WORD max_length, WORD echo_mode,
                    WORD *echo_xy, char *string );
WORD vsm_string( WORD handle, WORD max_length, WORD echo_mode,
                    WORD *echo_xy, char *string );
void vsc_form( WORD handle, WORD *pcur_form );
void vex_timv( WORD handle, WORD (*tim_addr)(), WORD (**otim_addr)(),
                  WORD *tim_conv );
void v_show_c( WORD handle, WORD reset );
void v_hide_c( WORD handle );
void vq_mouse( WORD handle, WORD *pstatus, WORD *x, WORD *y );
void vex_butv( WORD handle, WORD (*pusrcode)(), WORD (**psavcode)() );
void vex_motv( WORD handle, WORD (*pusrcode)(), WORD (**psavcode)() );
void vex_curv( WORD handle, WORD (*pusrcode)(), WORD (**psavcode)() );
void vq_key_s( WORD handle, WORD *pstatus );

void vq_extnd( WORD handle, WORD owflag, WORD *work_out );
WORD vq_color( WORD handle, WORD color_index,
                  WORD set_flag, WORD *rgb );
void vql_attributes( WORD handle, WORD *attrib );
void vqm_attributes( WORD handle, WORD *attrib );
void vqf_attributes( WORD handle, WORD *attrib );
void vqt_attributes( WORD handle, WORD *attrib );
void vqt_extent( WORD handle, char *string, WORD *extent );
WORD vqt_width( WORD handle, WORD character,
                   WORD *cell_width, WORD *left_delta,
                   WORD *right_delta );
WORD vqt_name( WORD handle, WORD element_num, char *name );
void vq_cellarray( WORD handle, WORD *pxyarray,
                      WORD row_length, WORD num_rows,
                      WORD *el_used, WORD *rows_used,
                      WORD *status, WORD *colarray );
void vqin_mode( WORD handle, WORD dew_type, WORD *input_mode );
void vqt_fontinfo( WORD handle, WORD *minADE, WORD *maxADE,
                      WORD *distances, WORD *maxwidth,
                      WORD *effects );

void vq_chcells( WORD handle, WORD *rows, WORD *columns );
void v_exit_cur( WORD handle );
void v_enter_cur( WORD handle );
void v_curup( WORD handle );
void v_curdown( WORD handle );
void v_curright( WORD handle );
void v_curleft( WORD handle );
void v_curhome( WORD handle );
void v_eeos( WORD handle );
void v_eeol( WORD handle );
void vs_curaddress( WORD handle, WORD row, WORD column );
void v_curaddress( WORD handle, WORD row, WORD column );
void v_curtext( WORD handle, char *string );
void v_rvon( WORD handle );
void v_rvoff( WORD handle );
void vq_curaddress( WORD handle, WORD *row, WORD *column );
WORD vq_tabstatus( WORD handle );
void v_hardcopy( WORD handle );
void v_dspcur( WORD handle, WORD x, WORD y );
void v_rmcur( WORD handle );
void v_form_adv( WORD handle );
void v_output_window( WORD handle, WORD *xyarray );
void v_clear_disp_list( WORD handle );
void v_bit_image( WORD handle, const char *filename,
                     WORD aspect, WORD x_scale, WORD y_scale,
                     WORD h_align, WORD v_align, WORD *xyarray );
void vq_scan( WORD handle, WORD *g_slice, WORD *g_page,
                 WORD *a_slice, WORD *a_page, WORD *div_fac);
void v_alpha_text( WORD handle, char *string );
void vs_palette( WORD handle, WORD palette );
void sound( WORD handle, WORD frequency, WORD duration );
int  vs_mute( WORD handle, WORD action );
void vqp_films( WORD handle, char *film_names );
void vqp_state( WORD handle, WORD *port, char *film_name,
                   WORD *lightness, WORD *interlace,
                   WORD *planes, WORD *indexes );
void vsp_state( WORD handle, WORD port, WORD film_num,
                   WORD lightness, WORD interlace, WORD planes,
                   WORD *indexes );
void vsp_save( WORD handle );
void vsp_message( WORD handle );
WORD  vqp_error( WORD handle );
void v_meta_extents( WORD handle, WORD min_x, WORD min_y,
                        WORD max_x, WORD max_y );
void v_write_meta( WORD handle,
                      WORD num_intin, WORD *intin,
                      WORD num_ptsin, WORD *ptsin );
void vm_coords( WORD handle, WORD llx, WORD lly, WORD urx, WORD ury );
void vm_filename( WORD handle, const char *filename );
void vm_pagesize( WORD handle, WORD pgwidth, WORD pdheight );
void v_offset( WORD handle, WORD offset );
void v_fontinit( WORD handle, WORD fh_high, WORD fh_low );
#define	v_pgcount	v_escape2000
void v_escape2000( WORD handle, WORD times );

void vt_resolution( WORD handle, WORD xres, WORD yres,
                       WORD *xset, WORD *yset );
void vt_axis( WORD handle, WORD xres, WORD yres,
                 WORD *xset, WORD *yset );
void vt_origin( WORD handle, WORD xorigin, WORD yorigin );
void vq_tdimensions( WORD handle, WORD *xdimension, WORD *ydimension );
void vt_alignment( WORD handle, WORD dx, WORD dy );
void vsp_film( WORD handle, WORD index, WORD lightness );

WORD vq_gdos( void );
LONG vq_vgdos( void );

WORD v_bez_on( WORD handle );
void v_bez_off( WORD handle );
void v_set_app_buff( WORD handle, void *address, WORD nparagraphs );
void v_bez( WORD handle, WORD count, WORD *xyarr,
                char *bezarr, WORD *extent, WORD *totpts, WORD *totmoves );
void v_bez_fill( WORD handle, WORD count, WORD *xyarr,
                     char *bezarr, WORD *extent, WORD *totpts,
                     WORD *totmoves );
WORD v_bez_qual( WORD handle, WORD prcnt, WORD *actual );

typedef LONG  fix31;

void vqt_f_extent( WORD handle, char *string, WORD *extent );
void v_ftext( WORD handle, WORD x, WORD y, char *string );
void v_ftext_offset( WORD handle, WORD x, WORD y, char *string, WORD *offset );
void v_killoutline( WORD handle, void *component );
void v_getoutline( WORD handle, WORD ch, WORD *xyarray,
                      char *bezarray, WORD maxverts, WORD *numverts );
void vst_scratch( WORD handle, WORD mode );
void vst_error( WORD handle, WORD mode, WORD *errorvar );
void vqt_advance( WORD handle, WORD ch, WORD *advx, WORD *advy,
                     WORD *remx, WORD *remy );
void vqt_advance32( WORD handle, WORD ch, fix31 *advx, fix31 *advy );
WORD vst_arbpt( WORD handle, WORD point, WORD *chwd, WORD *chht,
                   WORD *cellwd, WORD *cellht );
fix31 vst_arbpt32( WORD handle, fix31 point, WORD *chwd, WORD *chht,
                     WORD *cellwd, WORD *cellht );
void vst_charmap( WORD handle, WORD mode );
void v_getbitmap_info( WORD handle, WORD ch, fix31 *advx, fix31 *advy,
                          fix31 *xoff, fix31 *yoff, fix31 *width,
                          fix31 *height );
void vqt_pairkern( WORD handle, WORD ch1, WORD ch2, fix31 *x, fix31 *y );
void vqt_trackkern( WORD handle, fix31 *x, fix31 *y );
void vqt_fontheader( WORD handle, char *buffer, char *pathname );
void vst_kern( WORD handle, WORD tmode, WORD pmode, WORD *tracks,
                  WORD *pairs );
fix31 vst_setsize32( WORD handle, fix31 point, WORD *chwd, WORD *chht,
                       WORD *cellwd, WORD *cellht );
void vqt_devinfo( WORD handle, WORD devnum, WORD *devexits,
                     char *devstr );
WORD v_flushcache( WORD handle );
void vqt_cachesize( WORD handle, WORD which_cache, LONG *size );
void vqt_get_table( WORD handle, WORD **map );
WORD v_loadcache( WORD handle, char *filename, WORD mode );
WORD v_savecache( WORD handle, char *filename );
WORD vst_setsize( WORD handle, WORD point, WORD *chwd, WORD *chht,
                     WORD *cellwd, WORD *cellht );
WORD vst_skew( WORD handle, WORD skew );

#endif