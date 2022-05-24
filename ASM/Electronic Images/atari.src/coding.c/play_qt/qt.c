
/*
 * xanim_qt.c
 *
 * Copyright (C) 1993,1994 by Mark Podlipec.
 * All rights reserved.
 *
 * This software may be freely copied, modified and redistributed
 * without fee provided that this copyright notice is preserved
 * intact on all copies and modified copies.
 *
 * There is no warranty or other guarantee of fitness of this software.
 * It is provided solely "as is". The author(s) disclaim(s) all
 * responsibility and liability with respect to this software's usage
 * or its effect upon hardware or computer systems.
 *
 */
#include "xanim_qt.h"

ULONG UTIL_Get_MSB_Long(FILE *);
ULONG QT_Decode_RLE();
ULONG QT_Decode_RLE16();
ULONG QT_Decode_RLE24();
ULONG QT_Decode_RLE33();
ULONG QT_Decode_RAW();
ULONG QT_Decode_RPZA();
ULONG QT_Decode_SMC();
ULONG QT_Decode_CVID();
ULONG QT_Read_Codec_HDR();
ULONG QT_Read_File();
void QT_Gen_YUV_Tabs();
void QT_CVID_C1();
void QT_CVID_C4();
char *XA_rindex();

extern ULONG cmap_color_func;
ULONG qt_cmap_cnt;
void CMAP_Cache_Clear();
void CMAP_Cache_Init();

#define SMC_MAX_CNT 256
static ULONG smc_8cnt,smc_Acnt,smc_Ccnt;
static ULONG smc_8[ (2 * SMC_MAX_CNT) ];
static ULONG smc_A[ (4 * SMC_MAX_CNT) ];
static ULONG smc_C[ (8 * SMC_MAX_CNT) ];
LONG xa_debug;

QT_CODEC_HDR *qt_codecs;
ULONG qt_codec_num;
ULONG qt_stsc_invalid;

XA_ACTION *ACT_Get_Action();
XA_CHDR *ACT_Get_CMAP();
XA_CHDR *CMAP_Create_332();
XA_CHDR *CMAP_Create_422();
XA_CHDR *CMAP_Create_Gray();
void ACT_Add_CHDR_To_Action();
void ACT_Setup_Mapped();
XA_CHDR *CMAP_Create_CHDR_From_True();
UBYTE *UTIL_RGB_To_FS_Map();
UBYTE *UTIL_RGB_To_Map();
ULONG CMAP_Find_Closest();
 
ULONG UTIL_Get_MSB_Long();
LONG UTIL_Get_MSB_Short();
ULONG UTIL_Get_MSB_UShort();

FILE *QT_Open_File();
void  QT_Parse_Chunks();
ULONG QT_Parse_Bin();
void  QT_Read_Data();

void yuv_to_rgb();
void QT_Print_ID();
void QT_Read_MVHD();
void QT_Read_TKHD();
void QT_Read_ELST();
void QT_Read_MDHD();
void QT_Read_HDLR();
void QT_Read_STSD();
void QT_Read_Name();
void QT_Read_RAW();
void QT_Read_STTS();
void QT_Read_STSS();
void QT_Read_STCO();
void QT_Read_STSZ();
void QT_Read_STSC();
void QT_Codec_List();
ULONG QT_Get_Color();
void QT_Get_RGBColor();
void QT_Get_AV_Colors();
void QT_Get_AV_RGBColors();
ULONG QT_Get_Color24();


QT_RAW_HDR qt_raw_hdr;
QT_MVHDR qt_mvhdr;
QT_TKHDR qt_tkhdr;
QT_MDHDR qt_mdhdr;
QT_HDLR_HDR qt_hdlr_hdr;
QT_RPZA_HDR rpza_hdr;
QT_RLE_HDR rle_hdr;

char qt_rfilename[256];
char qt_dfilename[256];
ULONG qt_video_flag;
ULONG qt_data_flag;
ULONG qt_v_flag,qt_s_flag;


#define QT_MAX_COLORS  256
ColorReg qt_cmap[QT_MAX_COLORS];
XA_CHDR *qt_chdr;
USHORT qt_gamma_adj[32];

ULONG qt_frame_cnt;
ULONG qt_imagex,qt_imagey,qt_imagec;
ULONG qt_max_imagex,qt_max_imagey;
ULONG qt_compression,qt_depth;
ULONG qt_max_fsize;
ULONG qt_time,qt_timescale;

#define QT_CODEC_UNK   0x000
#define QT_CODEC_RLE   0x001
#define QT_CODEC_RLE16 0x002
#define QT_CODEC_RLE24 0x003
#define QT_CODEC_RLE33 0x004
#define QT_CODEC_RAW   0x008
#define QT_CODEC_SMC   0x010
#define QT_CODEC_RPZA  0x020
#define QT_CODEC_CVID  0x030

/* YUV cache tables for CVID */
static LONG *QT_UB_tab=0;
static LONG *QT_VR_tab=0;
static LONG *QT_UG_tab=0;
static LONG *QT_VG_tab=0;

/* Default Color Map for Quicktime RLE codec.
 * This is an educated guess after looking at two quicktime animations
 * (Gaspra and MacMolecule) and may not be totally correct.
 */
 
UBYTE qt_def_rle_cmap[768] = {
    0xff,0xff,0xff,   0xff,0xff,0xcc,   0xff,0xff,0x99,   0xff,0xff,0x66,   
    0xff,0xff,0x33,   0xff,0xff,0x0,   0xff,0xcc,0xff,   0xff,0xcc,0xcc,   
    0xff,0xcc,0x99,   0xff,0xcc,0x66,   0xff,0xcc,0x33,   0xff,0xcc,0x0,   
    0xff,0x99,0xff,   0xff,0x99,0xcc,   0xff,0x99,0x99,   0xff,0x99,0x66,   
    0xff,0x99,0x33,   0xff,0x99,0x0,   0xff,0x66,0xff,   0xff,0x66,0xcc,   
    0xff,0x66,0x99,   0xff,0x66,0x66,   0xff,0x66,0x33,   0xff,0x66,0x0,   
    0xff,0x33,0xff,   0xff,0x33,0xcc,   0xff,0x33,0x99,   0xff,0x33,0x66,   
    0xff,0x33,0x33,   0xff,0x33,0x0,   0xff,0x0,0xff,   0xff,0x0,0xcc,   
    0xff,0x0,0x99,   0xff,0x0,0x66,   0xff,0x0,0x33,   0xff,0x0,0x0,   
    0xcc,0xff,0xff,   0xcc,0xff,0xcc,   0xcc,0xff,0x99,   0xcc,0xff,0x66,   
    0xcc,0xff,0x33,   0xcc,0xff,0x0,   0xcc,0xcc,0xff,   0xcc,0xcc,0xcc,   
    0xcc,0xcc,0x99,   0xcc,0xcc,0x66,   0xcc,0xcc,0x33,   0xcc,0xcc,0x0,   
    0xcc,0x99,0xff,   0xcc,0x99,0xcc,   0xcc,0x99,0x99,   0xcc,0x99,0x66,   
    0xcc,0x99,0x33,   0xcc,0x99,0x0,   0xcc,0x66,0xff,   0xcc,0x66,0xcc,   
    0xcc,0x66,0x99,   0xcc,0x66,0x66,   0xcc,0x66,0x33,   0xcc,0x66,0x0,   
    0xcc,0x33,0xff,   0xcc,0x33,0xcc,   0xcc,0x33,0x99,   0xcc,0x33,0x66,   
    0xcc,0x33,0x33,   0xcc,0x33,0x0,   0xcc,0x0,0xff,   0xcc,0x0,0xcc,   
    0xcc,0x0,0x99,   0xcc,0x0,0x66,   0xcc,0x0,0x33,   0xcc,0x0,0x0,   
    0x99,0xff,0xff,   0x99,0xff,0xcc,   0x99,0xff,0x99,   0x99,0xff,0x66,   
    0x99,0xff,0x33,   0x99,0xff,0x0,   0x99,0xcc,0xff,   0x99,0xcc,0xcc,   
    0x99,0xcc,0x99,   0x99,0xcc,0x66,   0x99,0xcc,0x33,   0x99,0xcc,0x0,   
    0x99,0x99,0xff,   0x99,0x99,0xcc,   0x99,0x99,0x99,   0x99,0x99,0x66,   
    0x99,0x99,0x33,   0x99,0x99,0x0,   0x99,0x66,0xff,   0x99,0x66,0xcc,   
    0x99,0x66,0x99,   0x99,0x66,0x66,   0x99,0x66,0x33,   0x99,0x66,0x0,   
    0x99,0x33,0xff,   0x99,0x33,0xcc,   0x99,0x33,0x99,   0x99,0x33,0x66,   
    0x99,0x33,0x33,   0x99,0x33,0x0,   0x99,0x0,0xff,   0x99,0x0,0xcc,   
    0x99,0x0,0x99,   0x99,0x0,0x66,   0x99,0x0,0x33,   0x99,0x0,0x0,   
    0x66,0xff,0xff,   0x66,0xff,0xcc,   0x66,0xff,0x99,   0x66,0xff,0x66,   
    0x66,0xff,0x33,   0x66,0xff,0x0,   0x66,0xcc,0xff,   0x66,0xcc,0xcc,   
    0x66,0xcc,0x99,   0x66,0xcc,0x66,   0x66,0xcc,0x33,   0x66,0xcc,0x0,   
    0x66,0x99,0xff,   0x66,0x99,0xcc,   0x66,0x99,0x99,   0x66,0x99,0x66,   
    0x66,0x99,0x33,   0x66,0x99,0x0,   0x66,0x66,0xff,   0x66,0x66,0xcc,   
    0x66,0x66,0x99,   0x66,0x66,0x66,   0x66,0x66,0x33,   0x66,0x66,0x0,   
    0x66,0x33,0xff,   0x66,0x33,0xcc,   0x66,0x33,0x99,   0x66,0x33,0x66,   
    0x66,0x33,0x33,   0x66,0x33,0x0,   0x66,0x0,0xff,   0x66,0x0,0xcc,   
    0x66,0x0,0x99,   0x66,0x0,0x66,   0x66,0x0,0x33,   0x66,0x0,0x0,   
    0x33,0xff,0xff,   0x33,0xff,0xcc,   0x33,0xff,0x99,   0x33,0xff,0x66,   
    0x33,0xff,0x33,   0x33,0xff,0x0,   0x33,0xcc,0xff,   0x33,0xcc,0xcc,   
    0x33,0xcc,0x99,   0x33,0xcc,0x66,   0x33,0xcc,0x33,   0x33,0xcc,0x0,   
    0x33,0x99,0xff,   0x33,0x99,0xcc,   0x33,0x99,0x99,   0x33,0x99,0x66,   
    0x33,0x99,0x33,   0x33,0x99,0x0,   0x33,0x66,0xff,   0x33,0x66,0xcc,   
    0x33,0x66,0x99,   0x33,0x66,0x66,   0x33,0x66,0x33,   0x33,0x66,0x0,   
    0x33,0x33,0xff,   0x33,0x33,0xcc,   0x33,0x33,0x99,   0x33,0x33,0x66,   
    0x33,0x33,0x33,   0x33,0x33,0x0,   0x33,0x0,0xff,   0x33,0x0,0xcc,   
    0x33,0x0,0x99,   0x33,0x0,0x66,   0x33,0x0,0x33,   0x33,0x0,0x0,   
    0x0,0xff,0xff,   0x0,0xff,0xcc,   0x0,0xff,0x99,   0x0,0xff,0x66,   
    0x0,0xff,0x33,   0x0,0xff,0x0,   0x0,0xcc,0xff,   0x0,0xcc,0xcc,   
    0x0,0xcc,0x99,   0x0,0xcc,0x66,   0x0,0xcc,0x33,   0x0,0xcc,0x0,   
    0x0,0x99,0xff,   0x0,0x99,0xcc,   0x0,0x99,0x99,   0x0,0x99,0x66,   
    0x0,0x99,0x33,   0x0,0x99,0x0,   0x0,0x66,0xff,   0x0,0x66,0xcc,   
    0x0,0x66,0x99,   0x0,0x66,0x66,   0x0,0x66,0x33,   0x0,0x66,0x0,   
    0x0,0x33,0xff,   0x0,0x33,0xcc,   0x0,0x33,0x99,   0x0,0x33,0x66,   
    0x0,0x33,0x33,   0x0,0x33,0x0,   0x0,0x0,0xff,   0x0,0x0,0xcc,   
    0x0,0x0,0x99,   0x0,0x0,0x66,   0x0,0x0,0x33,   0xee, 0x0, 0x0,
    0xdd, 0x0, 0x0,0xbb, 0x0, 0x0,0xaa, 0x0, 0x0,0x88, 0x0, 0x0,
    0x77, 0x0, 0x0,0x55, 0x0, 0x0,0x44, 0x0, 0x0,0x22, 0x0, 0x0,
    0x11, 0x0, 0x0,0x0, 0xee, 0x0,0x0, 0xdd, 0x0,0x0, 0xbb, 0x0,
    0x0, 0xaa, 0x0,0x0, 0x88, 0x0,0x0, 0x77, 0x0,0x0, 0x55, 0x0,
    0x0, 0x44, 0x0,0x0, 0x22, 0x0,0x0, 0x11, 0x0,0x0, 0x0, 0xee,
    0x0, 0x0, 0xdd,0x0, 0x0, 0xbb,0x0, 0x0, 0xaa,0x0, 0x0, 0x88,
    0x0, 0x0, 0x77,0x0, 0x0, 0x55,0x0, 0x0, 0x44,0x0, 0x0, 0x22,
    0x0, 0x0, 0x11,0xee, 0xee, 0xee,0xdd, 0xdd, 0xdd,0xbb, 0xbb, 0xbb,
    0xaa, 0xaa, 0xaa,0x88, 0x88, 0x88,0x77, 0x77, 0x77,0x55, 0x55, 0x55,
    0x44, 0x44, 0x44,0x22, 0x22, 0x22,0x11, 0x11, 0x11,0x0, 0x0, 0x0  };
    


QT_FRAME *qt_frame_start,*qt_frame_cur;


/* Routine to read a big endian long word.
 */
ULONG UTIL_Get_MSB_Long(fp)
FILE *fp;
{
 ULONG ret;

 ret  = fgetc(fp) << 24;
 ret |= fgetc(fp) << 16;
 ret |= fgetc(fp) << 8;
 ret |=  fgetc(fp);
 return ret;
}

 
QT_FRAME *QT_Add_Frame(time,act)
ULONG time;
XA_ACTION *act;
{
  QT_FRAME *fframe;
 
  fframe = (QT_FRAME *) malloc(sizeof(QT_FRAME));
  if (fframe == 0) TheEnd1("QT_Add_Frame: malloc err");
 
  fframe->time = time;
  fframe->act = act;
  fframe->next = 0;
 
  if (qt_frame_start == 0) qt_frame_start = fframe;
  else qt_frame_cur->next = fframe;
 
  qt_frame_cur = fframe;
  qt_frame_cnt++;
  return(fframe);
}
 
void QT_Free_Frame_List(fframes)
QT_FRAME *fframes;
{
  QT_FRAME *ftmp;
  while(fframes != 0)
  {
    ftmp = fframes;
    fframes = fframes->next;
    FREE(ftmp,0x2000);
  }
}


LONG Is_QT_File(filename)
char *filename;
{
  FILE *fin;
  ULONG ret;

  if ( (fin=QT_Open_File(filename,qt_rfilename,qt_dfilename)) == 0)
				return(XA_NOFILE);
  ret = QT_Parse_Bin(fin);
  fclose(fin);
  if ( ret != 0 ) return(TRUE);
  return(FALSE);
}

/* FOR PARSING Quicktime Files */
ULONG *qt_samp_sizes;
ULONG qt_sample_num;
 
QT_S2CHUNK_HDR *qt_s2chunks;
ULONG qt_s2chunk_num;

QT_T2SAMP_HDR *qt_t2samps;
ULONG qt_t2samp_num;
 
ULONG qt_chunkoff_num;
ULONG *qt_chunkoffs;
UBYTE *qt_pic;
ULONG qt_pic_size;

ULONG qt_codec_lstnum;
ULONG qt_chunkoff_lstnum;
ULONG qt_sample_lstnum;
ULONG qt_s2chunk_lstnum;

/* main() */
ULONG QT_Read_File(fname,anim_hdr)
char *fname;
XA_ANIM_HDR *anim_hdr;
{
  FILE *fin;
  LONG i;

  qt_cmap_cnt = 0;
  qt_codec_lstnum = qt_chunkoff_lstnum = qt_sample_lstnum = 0;
  qt_codecs = 0;
  qt_codec_num = 0;
  qt_stsc_invalid = FALSE;
  qt_data_flag = FALSE;
  qt_video_flag = 0;
  qt_v_flag = qt_s_flag = 0;
  qt_compression = QT_CODEC_UNK;
  qt_depth = 0;
  qt_pic = 0;
  qt_pic_size = 0;

  qt_chdr = 0;
  qt_frame_cnt = 0;
  qt_frame_start = 0;
  qt_frame_cur = 0;
  qt_time = XA_GET_TIME( 67 ); /* default 15 frames per second */
  qt_timescale = 1000;
  qt_chunkoff_num = 0;
  qt_chunkoffs = 0;
  qt_s2chunk_num = qt_s2chunk_lstnum = 0;
  qt_s2chunks = 0;
  qt_t2samp_num = 0;
  qt_t2samps = 0;
  qt_samp_sizes = 0;
  qt_sample_num = 0;
  qt_imagex = qt_imagey = qt_imagec = 0;
  qt_max_fsize = 0;
  qt_max_imagex = qt_max_imagey = 0;

  for(i=0;i<32;i++) qt_gamma_adj[i] = xa_gamma_adj[ ((i<<3)|(i>>2)) ];

  if ( (fin=QT_Open_File(fname,qt_rfilename,qt_dfilename)) == 0)
  {
    fprintf(stderr,"QT_Read: can't open %s\n",qt_rfilename);
    return(FALSE);
  }

  if ( QT_Parse_Bin(fin) == 0 )
  {
    fprintf(stderr,"Not quicktime file\n");
    return(FALSE);
  }

  QT_Parse_Chunks(fin);

  if (qt_data_flag == FALSE) 
  { /* mdat was not in .rscr file need to open .data file */
    fclose(fin); /* close .rscr file */
    if (qt_dfilename[0] == 0)
    {
       fprintf(stderr,"QT_Data: No data in %s file. Can't find .data file.\n",
		qt_rfilename);
       return(FALSE);
    }
    if ( (fin=fopen(qt_dfilename,XA_OPEN_MODE)) == 0) 
    {
      fprintf(stderr,"QT_Data: can't open %s file.\n",qt_dfilename);
      return(FALSE);
    }
  } else strcpy(qt_dfilename,qt_rfilename); /* r file is d file */
  QT_Read_Data(fin,anim_hdr);
  fclose(fin);

  if (xa_verbose) fprintf(stderr,"    Frames %ld\n", qt_frame_cnt);

  anim_hdr->frame_lst = (XA_FRAME *)
                                malloc( sizeof(XA_FRAME) * (qt_frame_cnt+1));
  if (anim_hdr->frame_lst == NULL) TheEnd1("QT_Read_File: frame malloc err");
 
  qt_frame_cur = qt_frame_start;
  i = 0;
  while(qt_frame_cur != 0)
  {
    if (i >= qt_frame_cnt)
    {
      fprintf(stderr,"QT_Read_Anim: frame inconsistency %ld %ld\n",
                i,qt_frame_cnt);
      break;
    }
    anim_hdr->frame_lst[i].time = qt_frame_cur->time;
    anim_hdr->frame_lst[i].act = qt_frame_cur->act;
    qt_frame_cur = qt_frame_cur->next;
    i++;
  }
  anim_hdr->imagex = qt_max_imagex;
  anim_hdr->imagey = qt_max_imagey;
  anim_hdr->imagec = qt_imagec;
  anim_hdr->imaged = 8; /* nop */
  anim_hdr->frame_lst[i].time = 0;
  anim_hdr->frame_lst[i].act  = 0;
  anim_hdr->loop_frame = 0;
  if (xa_buffer_flag == FALSE) anim_hdr->anim_flags |= ANIM_SNG_BUF;
  anim_hdr->max_fsize = qt_max_fsize;
  if (xa_file_flag == TRUE) 
  {
    ULONG len;
    anim_hdr->anim_flags |= ANIM_USE_FILE;
    len = strlen(qt_dfilename) + 1;
    anim_hdr->fname = (char *)malloc(len);
    if (anim_hdr->fname==0) TheEnd1("QT: malloc fname err");
    strcpy(anim_hdr->fname,qt_dfilename);
  }
  if (i > 0) anim_hdr->last_frame = i - 1;
  else i = 0;
  QT_Free_Frame_List(qt_frame_start);
  if (qt_samp_sizes) free(qt_samp_sizes);
  if (qt_codecs) free(qt_codecs);
  if (qt_t2samps) free(qt_t2samps);
  if (qt_s2chunks) free(qt_s2chunks);
  if (qt_chunkoffs) free(qt_chunkoffs);
  return(TRUE);
}

FILE *QT_Open_File(fname,r_file,d_file)
char *fname,*r_file,*d_file;
{
  FILE *fin;

  /* check to see if fname exists? */
  if ( (fin=fopen(fname,XA_OPEN_MODE)) != 0)  /* filename is as give */
  { /*three choices - with or without .rsrc ending, or using .resource subdir*/
    LONG len;
    FILE *ftst;
    /* path/fname exits. */

    /* check for  path/.resource/fname */
    {
      char *lastdirsep;
      strcpy(r_file,fname);			/* copy path/fname to r */
      lastdirsep = XA_rindex(r_file, '/');	/* find sep if any */
      if (lastdirsep != 0)
      {
        strcpy(d_file,lastdirsep);		/* save fname to d*/
	lastdirsep++; *lastdirsep = 0;		/* cut of fname off r*/
        strcat(lastdirsep, ".resource/"); 	/* add .resource to r*/
        strcat(r_file, d_file); 		/* add fname to r */
      }
      else /* no path */
      {
	strcpy(r_file,".resource/");
	strcat(r_file,fname);
      }
      if ( (ftst=fopen(r_file,"r")) != 0)
      {
	/* path/fname and path/.resource/fname exist - wrap it up */
	strcpy(d_file,fname);			/* setup .data name */
	fclose(fin);				/* close .data fork */
        return(ftst);		/* return .rsrc fork (in .resource) */
      }
    }
     
    /* Now check for .rsrc or .data endings */
    strcpy(r_file,fname);
    strcpy(d_file,fname);
    len = strlen(r_file) - 5;
    if (len > 0)
    { char *tmp;
      tmp = XA_rindex(d_file, '.');	/* get last "." */
      if (strcmp(tmp,".rsrc")==0)  /* fname has .rsrc ending */
      {
        strcpy(tmp,".data"); /* overwrite .rsrc with .data in d*/
	return(fin);
      }
      else if (strcmp(tmp,".data")==0)  /* fname has .data ending */
      {
        strcpy(tmp,".rsrc"); /* overwrite .rsrc with .data in d*/
        if ( (ftst=fopen(d_file,"r")) != 0) /* see if .rsrc exists */
	{
	  char t_file[256];  /* swap r and d files */
	  strcpy(t_file,r_file); strcpy(r_file,d_file); strcpy(d_file,t_file);
	  fclose(fin);		/* close .data file */
	  return(ftst);		/* return .rsrc file */
	}
	/* hopefully .data is flattened. find out later */
	else { *d_file = 0; return(fin); }
      }
      else { *d_file = 0; return(fin); }
    }
    else { *d_file = 0; return(fin); }
  }

  /* does fname.rsrc exist? */
  strcpy(r_file,fname);
  strcat(r_file,".rsrc");
  if ( (fin=fopen(r_file,XA_OPEN_MODE)) != 0)  /* fname.rsrc */
  { FILE *ftst;
    /* if so, check .data existence */
    strcpy(d_file,fname);
    strcat(d_file,".data");
    if ( (ftst=fopen(d_file,XA_OPEN_MODE)) != 0)	fclose(ftst);
    else *d_file = 0;
    return(fin);
  } else *d_file = 0;
  return(0);
}

void QT_Parse_Chunks(fin)
FILE *fin;
{
  LONG file_len;
  ULONG id,len;

  file_len = 1;
  while(file_len > 0)
  {
    len = UTIL_Get_MSB_Long(fin);
    id  = UTIL_Get_MSB_Long(fin);

    if ( (len == 0) && (id == QT_mdat) )
	TheEnd1("QT: mdat len is 0. You also need a .rsrc file.\n");
    if (len < 8) { file_len = 0; continue; } /* just bad - finish this */
    if (file_len == 1)
    {
      if (id == QT_moov) file_len = len;
      else file_len = len + 1;
    }
    DEBUG_LEVEL2 fprintf(stderr,"%c%c%c%c %04lx len = %lx file_len =  %lx\n",
	(id >> 24),((id>>16)&0xff),((id>>8)&0xff),(id&0xff),id,len,file_len);

    switch(id)
    {
    /*--------------ATOMS------------------*/
      case QT_trak:
	qt_v_flag = qt_s_flag = 0;
	qt_codec_lstnum = qt_codec_num;
	qt_chunkoff_lstnum = qt_chunkoff_num;
	qt_sample_lstnum = qt_sample_num;
	qt_s2chunk_lstnum = qt_s2chunk_num;
      case QT_moov:
      case QT_mdia:
      case QT_minf:
      case QT_stbl:
      case QT_edts:
	file_len -= 8;
	break;
    /*---------------STUFF------------------*/
      case QT_mvhd:
	QT_Read_MVHD(fin,&qt_mvhdr);
	file_len -= len;
	break;
      case QT_tkhd:
	QT_Read_TKHD(fin,&qt_tkhdr);
	file_len -= len;
	break;
      case QT_elst:
	QT_Read_ELST(fin);
	file_len -= len;
	break;
      case QT_mdhd:
	QT_Read_MDHD(fin,&qt_mdhdr);
	file_len -= len;
	break;
      case QT_hdlr:
	QT_Read_HDLR(fin,len,&qt_hdlr_hdr);
	file_len -= len;
	break;
    /*--------------DATA CHUNKS-------------*/
      case QT_mdat:  /* data is included in .rsrc - assumed flatness */
	fseek(fin,(len-8),1); /* skip over it for now */
	qt_data_flag = TRUE;
	break;
      case QT_stsd:
	qt_video_flag = 0;
	QT_Read_STSD(fin);
	if (qt_v_flag != 1) file_len -= 16; /* sound/txt */
	else file_len -= len; /* video */
	break;
      case QT_stts:
	QT_Read_STTS(fin);
	file_len -= len;
	break;
      case QT_stss:
	QT_Read_STSS(fin);
	file_len -= len;
	break;
      case QT_stco:
	QT_Read_STCO(fin);
	file_len -= len;
	break;
      case QT_stsz:
	QT_Read_STSZ(fin,len);
	file_len -= len;
	break;
      case QT_stsc:
	QT_Read_STSC(fin,len);
	file_len -= len;
	break;
    /*-----------Sound Codec Headers--------------*/
      case QT_podsnd:
        fseek(fin,(len-8),1);  /* move to start of chunk data */
        file_len -= len;
        break;
    /*-----------Video/Sound Codec Headers--------------*/
      case QT_raw:
	if (qt_v_flag==1)
	{
	  fprintf(stderr,"QT: Warning %08lx\n",id);
          fseek(fin,(len-8),1);  /* skip over */
	}
	else QT_Read_RAW(fin,&qt_raw_hdr);
	file_len -= len;
	break;
    /*-----------Video Codec Headers--------------*/
      case QT_smc:
      case QT_rpza:
      case QT_rle:
      case QT_cvid:
	fprintf(stderr,"QT: Warning %08lx\n",id);
        fseek(fin,(len-8),1);  /* skip over */
	file_len -= len;
	break;
    /*-----------TYPE OF TRAK---------------*/
      case QT_vmhd:
        fseek(fin,(len-8),1);
	file_len -= len; qt_v_flag = 1;
	break;
      case QT_smhd:
        fseek(fin,(len-8),1);
	file_len -= len; qt_s_flag = 1;
	break;
    /*--------------IGNORED FOR NOW---------*/
      case QT_gmhd:
      case QT_text:
      case QT_twos:
      case QT_skip:
      case QT_stgs:
      case QT_udta:
      case QT_dinf:
        fseek(fin,(len-8),1);  /* skip over */
	file_len -= len;
	break;
    /*--------------UNKNOWN-----------------*/
      default:
	if ( !feof(fin) && (len <= file_len) )
	{
	  LONG i;
	  QT_Print_ID(stderr,id,1);
	  fprintf(stderr," len = %lx\n",len);
	  i = (LONG)(len) - 8;
	  while(i > 0) { i--; getc(fin); if (feof(fin)) i = 0; }
	}
	file_len -= len;
	break;
    } /* end of switch */
    if ( feof(fin) ) file_len = 0;
  } /* end of while */
}

void QT_Print_ID(fout,id,flag)
FILE *fout;
LONG id,flag;
{
 fprintf(fout,"%c",     ((id >> 24) & 0xff));
 fprintf(fout,"%c",     ((id >> 16) & 0xff));
 fprintf(fout,"%c",     ((id >>  8) & 0xff));
 fprintf(fout,"%c",      (id        & 0xff));
 if (flag) fprintf(fout,"(%lx)",id);
}


void QT_Read_MVHD(fin,qt_mvhdr)
FILE *fin;
QT_MVHDR *qt_mvhdr;
{
  ULONG i,j;

  qt_mvhdr->version =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->creation =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->modtime =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->timescale =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->duration =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->rate =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->volume =	UTIL_Get_MSB_UShort(fin);
  qt_mvhdr->r1  =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->r2  =	UTIL_Get_MSB_Long(fin);
  for(i=0;i<3;i++) for(j=0;j<3;j++) 
	qt_mvhdr->matrix[i][j]=UTIL_Get_MSB_Long(fin);
  qt_mvhdr->r3  =	UTIL_Get_MSB_UShort(fin);
  qt_mvhdr->r4  =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->pv_time =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->post_time =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->sel_time =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->sel_durat =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->cur_time =	UTIL_Get_MSB_Long(fin);
  qt_mvhdr->nxt_tk_id =	UTIL_Get_MSB_Long(fin);
  
  DEBUG_LEVEL2
  {
    fprintf(stderr,"     ver = %lx  timescale = %lx  duration = %lx\n",
	qt_mvhdr->version,qt_mvhdr->timescale, qt_mvhdr->duration);
    fprintf(stderr,"     rate = %lx volumne = %lx  nxt_tk = %lx\n",
	qt_mvhdr->rate,qt_mvhdr->volume,qt_mvhdr->nxt_tk_id);
  }
}

void QT_Read_TKHD(fin,qt_tkhdr)
FILE *fin;
QT_TKHDR *qt_tkhdr;
{
  ULONG i,j;

  qt_tkhdr->version =	UTIL_Get_MSB_Long(fin);
  qt_tkhdr->creation =	UTIL_Get_MSB_Long(fin);
  qt_tkhdr->modtime =	UTIL_Get_MSB_Long(fin);
  qt_tkhdr->trackid =	UTIL_Get_MSB_Long(fin);
  qt_tkhdr->timescale =	UTIL_Get_MSB_Long(fin);
  qt_tkhdr->duration =	UTIL_Get_MSB_Long(fin);
  qt_tkhdr->time_off =	UTIL_Get_MSB_Long(fin);
  qt_tkhdr->priority  =	UTIL_Get_MSB_Long(fin);
  qt_tkhdr->layer  =	UTIL_Get_MSB_UShort(fin);
  qt_tkhdr->alt_group = UTIL_Get_MSB_UShort(fin);
  qt_tkhdr->volume  =	UTIL_Get_MSB_UShort(fin);
  for(i=0;i<3;i++) for(j=0;j<3;j++) 
			qt_tkhdr->matrix[i][j]=UTIL_Get_MSB_Long(fin);
  qt_tkhdr->tk_width =	UTIL_Get_MSB_Long(fin);
  qt_tkhdr->tk_height =	UTIL_Get_MSB_Long(fin);
  qt_tkhdr->pad  =	UTIL_Get_MSB_UShort(fin);

  DEBUG_LEVEL2
  {
    fprintf(stderr,"     ver = %lx  tk_id = %lx  timescale = %lx\n",
	qt_tkhdr->version,qt_tkhdr->trackid,qt_tkhdr->timescale);
    fprintf(stderr,"     dur= %lx timoff= %lx tk_width= %lx  tk_height= %lx\n",
	qt_tkhdr->duration,qt_tkhdr->time_off,qt_tkhdr->tk_width,qt_tkhdr->tk_height);
  }
}


void QT_Read_ELST(fin)
FILE *fin;
{
 ULONG num,version;

 version = UTIL_Get_MSB_Long(fin);
 num = UTIL_Get_MSB_Long(fin);
 DEBUG_LEVEL2 fprintf(stderr,"    ELST ver %lx num %lx\n",version,num);
 while(num--)
 {
   ULONG duration,time,rate,pad;
   duration = UTIL_Get_MSB_Long(fin); 
   time = UTIL_Get_MSB_Long(fin); 
   rate = UTIL_Get_MSB_UShort(fin); 
   pad  = UTIL_Get_MSB_UShort(fin); 
   DEBUG_LEVEL2 fprintf(stderr,"    -) dur %lx tim %lx rate %lx\n",
		duration,time,rate);
 }
}

void QT_Read_MDHD(fin,qt_mdhdr)
FILE *fin;
QT_MDHDR *qt_mdhdr;
{
  qt_mdhdr->version =	UTIL_Get_MSB_Long(fin);
  qt_mdhdr->creation =	UTIL_Get_MSB_Long(fin);
  qt_mdhdr->modtime =	UTIL_Get_MSB_Long(fin);
  qt_mdhdr->timescale =	UTIL_Get_MSB_Long(fin);
  qt_mdhdr->duration =	UTIL_Get_MSB_Long(fin);
  qt_mdhdr->language =	UTIL_Get_MSB_UShort(fin);
  qt_mdhdr->quality =	UTIL_Get_MSB_UShort(fin);

  qt_timescale = qt_mdhdr->timescale;
  DEBUG_LEVEL2
  {
    fprintf(stderr,"     ver = %lx  timescale = %lx  duration = %lx\n",
	qt_mdhdr->version,qt_mdhdr->timescale,qt_mdhdr->duration);
    fprintf(stderr,"     lang= %lx quality= %lx\n", 
	qt_mdhdr->language,qt_mdhdr->quality);
  }
}


void QT_Read_HDLR(fin,len,qt_hdlr_hdr)
FILE *fin;
LONG len;
QT_HDLR_HDR *qt_hdlr_hdr;
{
  qt_hdlr_hdr->version =	UTIL_Get_MSB_Long(fin);
  qt_hdlr_hdr->type =	UTIL_Get_MSB_Long(fin);
  qt_hdlr_hdr->subtype =	UTIL_Get_MSB_Long(fin);
  qt_hdlr_hdr->vendor =	UTIL_Get_MSB_Long(fin);
  qt_hdlr_hdr->flags =	UTIL_Get_MSB_Long(fin);
  qt_hdlr_hdr->mask =	UTIL_Get_MSB_Long(fin);

  DEBUG_LEVEL2
  {
    fprintf(stderr,"     ver = %lx  ",qt_hdlr_hdr->version);
    QT_Print_ID(stderr,qt_hdlr_hdr->type,1);
    QT_Print_ID(stderr,qt_hdlr_hdr->subtype,1);
    QT_Print_ID(stderr,qt_hdlr_hdr->vendor,0);
    fprintf(stderr,"\n     flags= %lx mask= %lx\n",
	qt_hdlr_hdr->flags,qt_hdlr_hdr->mask);
  }
  /* Read Handler Name if Present */
  if (len > 32)
  {
    len -= 32;
    QT_Read_Name(fin,len);
  }
}

void QT_Read_STSD(fin)
FILE *fin;
{
  ULONG i,version,num,cur,sup;
  
  version = UTIL_Get_MSB_Long(fin);
  num = UTIL_Get_MSB_Long(fin);

  if (qt_v_flag != 1) return;
  DEBUG_LEVEL2 fprintf(stderr,"     ver = %lx  num = %lx\n", version,num);
  if (qt_codecs == 0)
  {
    qt_codec_num = num;
    qt_codecs = (QT_CODEC_HDR *)malloc(qt_codec_num * sizeof(QT_CODEC_HDR));
    if (qt_codecs==0) TheEnd1("QT STSD: malloc err");
    cur = 0;
  }
  else
  { QT_CODEC_HDR *tcodecs;
    tcodecs = (QT_CODEC_HDR *)malloc((qt_codec_num+num) * sizeof(QT_CODEC_HDR));
    if (tcodecs==0) TheEnd1("QT STSD: malloc err");
    for(i=0;i<qt_codec_num;i++) tcodecs[i] = qt_codecs[i];
    cur = qt_codec_num;
    qt_codec_num += num;
    free(qt_codecs);
    qt_codecs = tcodecs;
  }
  sup = 0;
  for(i=0; i < num; i++)
  {
    sup |= QT_Read_Codec_HDR( &qt_codecs[cur], fin ); 
    cur++;
  }

  if (sup == 0) TheEnd1("    QT codecs not supported - exiting.");

  qt_video_flag = 1; 

  if ( (qt_pic==0) && (xa_buffer_flag == TRUE))
  {
    qt_pic_size = qt_max_imagex * qt_max_imagey;
    if ( (cmap_true_map_flag == TRUE) && (qt_depth > 8) )
		qt_pic = (UBYTE *) malloc(3 * qt_pic_size);
    else	qt_pic = (UBYTE *) malloc( XA_PIC_SIZE(qt_pic_size) );
    if (qt_pic == 0) TheEnd1("QT_Buffer_Action: malloc failed");
  }
}


ULONG QT_Read_Codec_HDR(c_hdr,fin)
QT_CODEC_HDR *c_hdr;
FILE *fin;
{
  ULONG id;
  LONG len,i;
  ULONG unk_0,unk_1,unk_2,unk_3,unk_4,unk_5,unk_6,unk_7,flag;
  ULONG vendor,temp_qual,spat_qual,h_res,v_res;
  
  c_hdr->compression = 0;  /* used as support flag later */
  len		= UTIL_Get_MSB_Long(fin);
  id 		= UTIL_Get_MSB_Long(fin);

  unk_0		= UTIL_Get_MSB_Long(fin);
  unk_1		= UTIL_Get_MSB_Long(fin);
  unk_2		= UTIL_Get_MSB_UShort(fin);
  unk_3		= UTIL_Get_MSB_UShort(fin);
  vendor	= UTIL_Get_MSB_Long(fin);
  temp_qual	= UTIL_Get_MSB_Long(fin);
  spat_qual	= UTIL_Get_MSB_Long(fin);
  qt_imagex	= UTIL_Get_MSB_UShort(fin);
  qt_imagey	= UTIL_Get_MSB_UShort(fin);
  h_res		= UTIL_Get_MSB_UShort(fin);
  unk_4		= UTIL_Get_MSB_UShort(fin);
  v_res		= UTIL_Get_MSB_UShort(fin);
  unk_5		= UTIL_Get_MSB_UShort(fin);
  unk_6		= UTIL_Get_MSB_Long(fin);
  unk_7		= UTIL_Get_MSB_UShort(fin);
  QT_Read_Name(fin,32);
  qt_depth	= UTIL_Get_MSB_UShort(fin);
  flag		= UTIL_Get_MSB_UShort(fin);
  len -= 0x56;

  if (qt_depth == 8) /* generate colormap */
  {
    qt_imagec = 256;
    for(i=0;i<256;i++)
    {
      ULONG j = 3 * i;
      qt_cmap[i].red   = 0x101 * qt_def_rle_cmap[j];
      qt_cmap[i].green = 0x101 * qt_def_rle_cmap[j + 1];
      qt_cmap[i].blue  = 0x101 * qt_def_rle_cmap[j + 2];
    }
    if (!(flag & 0x08)) /* colormap isn't default */
    {
      ULONG start,end,p,r,g,b;
      start = UTIL_Get_MSB_Long(fin); /* is this start or something else? */
      end   = UTIL_Get_MSB_Long(fin); /* is this end or total number? */
      len -= 8;
      for(i = start; i <= end; i++)
      {
        p = UTIL_Get_MSB_UShort(fin); 
        r = UTIL_Get_MSB_UShort(fin); 
        g = UTIL_Get_MSB_UShort(fin); 
        b = UTIL_Get_MSB_UShort(fin);  len -= 8;
        if (p<qt_imagec)
        {
	  qt_cmap[p].red   = r;
	  qt_cmap[p].green = g;
	  qt_cmap[p].blue  = b;
        }
        if (len <= 0) break;
      }
    } 
  }

  while(len > 0) {fgetc(fin); len--; }

  if (xa_verbose) fprintf(stderr,"    Size %ldx%ld  Codec ",
						qt_imagex,qt_imagey);
  switch(id)
  {
    case QT_rle:
	if (xa_verbose) fprintf(stderr,"RLE depth %ld\n",qt_depth);
	if (qt_depth == 8)
	{
	  qt_compression = QT_CODEC_RLE;
	  qt_imagex = 4 * ((qt_imagex + 3)/4);
	}
	else if (qt_depth == 16) qt_compression = QT_CODEC_RLE16;
	else if (qt_depth == 24) qt_compression = QT_CODEC_RLE24;
	else if ( (qt_depth == 33) || (qt_depth == 1) )
	{
	  qt_compression = QT_CODEC_RLE33;
	  qt_imagex = 16 * ((qt_imagex + 15)/16);
	  qt_depth = 1;
	}
	else { fprintf(stderr,"      unsupported\n"); return(0); }
	break;
    case QT_smc:
	if (xa_verbose) fprintf(stderr,"SMC depth %ld\n",qt_depth);
	if (qt_depth == 8)
	{
	  qt_compression = QT_CODEC_SMC;
	  qt_imagex = 4 * ((qt_imagex + 3)/4);
	  qt_imagey = 4 * ((qt_imagey + 3)/4);
	}
	else { fprintf(stderr,"      unsupported\n"); return(0); }
	break;
    case QT_raw:
	if (xa_verbose) fprintf(stderr,"RAW depth %ld\n",qt_depth);
	if (qt_depth == 8) qt_compression = QT_CODEC_RAW;
	else { fprintf(stderr,"      unsupported\n"); return(0); }
	break;
    case QT_rpza:
	if (xa_verbose) fprintf(stderr,"RPZA depth %ld\n",qt_depth);
	if (qt_depth == 16)
	{
	  qt_compression = QT_CODEC_RPZA;
	  qt_imagex = 4 * ((qt_imagex + 3)/4);
	  qt_imagey = 4 * ((qt_imagey + 3)/4);
	}
	else { fprintf(stderr,"      unsupported\n"); return(0); }
	break;
    case QT_cvid:
	if (xa_verbose) fprintf(stderr,"CVID depth %ld\n",qt_depth);
	if ((qt_depth == 24) || (qt_depth == 32) )
	{
	  QT_Gen_YUV_Tabs();
	  qt_compression = QT_CODEC_CVID;
	  qt_imagex = 4 * ((qt_imagex + 3)/4);
	  qt_imagey = 4 * ((qt_imagey + 3)/4);
	}
	else { fprintf(stderr,"      unsupported\n"); return(0); }
	break;
    default:
       fprintf(stderr,"%08lx unknown\n",id);
       return(0);
       break;
  }
 
  if (qt_depth == 1)
  {
    qt_imagec = 2;
    qt_cmap[0].red = qt_cmap[0].green = qt_cmap[0].blue = 0; 
    qt_cmap[1].red = qt_cmap[1].green = qt_cmap[1].blue = 0xff; 
    qt_chdr = ACT_Get_CMAP(qt_cmap,qt_imagec,0,qt_imagec,0,8,8,8);
  }

  if (qt_depth == 8)
    qt_chdr = ACT_Get_CMAP(qt_cmap,qt_imagec,0,qt_imagec,0,16,16,16);

  if (qt_depth >= 16)
  {
    if (   (cmap_true_map_flag == FALSE) /* depth 16 and not true_map */
           || (xa_buffer_flag == FALSE) )
    {
      if (cmap_true_to_332 == TRUE)
		qt_chdr = CMAP_Create_332(qt_cmap,&qt_imagec);
      else	qt_chdr = CMAP_Create_Gray(qt_cmap,&qt_imagec);
    }
    else { qt_imagec = 0; qt_chdr = 0; }
  }
  c_hdr->width	= qt_imagex;
  c_hdr->height	= qt_imagey;
  c_hdr->depth	= qt_depth;
  c_hdr->compression = qt_compression;
  c_hdr->chdr	= qt_chdr;
  if (qt_imagex > qt_max_imagex) qt_max_imagex = qt_imagex;
  if (qt_imagey > qt_max_imagey) qt_max_imagey = qt_imagey;
  return(1);
}

void QT_Read_RAW(fin,qt_raw_hdr)
FILE *fin;
QT_RAW_HDR *qt_raw_hdr;
{
  qt_raw_hdr->dref_id	= UTIL_Get_MSB_Long(fin);
  qt_raw_hdr->version	= UTIL_Get_MSB_Long(fin);
  qt_raw_hdr->codec_rev	= UTIL_Get_MSB_Long(fin);
  qt_raw_hdr->vendor	= UTIL_Get_MSB_Long(fin);
  qt_raw_hdr->chan_num	= UTIL_Get_MSB_UShort(fin);
  qt_raw_hdr->bits_samp	= UTIL_Get_MSB_UShort(fin);
  qt_raw_hdr->comp_id	= UTIL_Get_MSB_UShort(fin);
  qt_raw_hdr->pack_size	= UTIL_Get_MSB_UShort(fin);
  qt_raw_hdr->samp_rate	= UTIL_Get_MSB_UShort(fin);
  qt_raw_hdr->pad	= UTIL_Get_MSB_UShort(fin);

  DEBUG_LEVEL2
  {
    fprintf(stderr,"       ver= %lx  codec_rev = %lx  chan_num = %lx  bits = %lx samp_rate= %lx\n", qt_raw_hdr->version, qt_raw_hdr->codec_rev,
	qt_raw_hdr->chan_num, qt_raw_hdr->bits_samp, qt_raw_hdr->samp_rate);
  }
}

void QT_Read_Name(fin,r_len)
FILE *fin;
LONG r_len;
{
  ULONG len,d,i;

  len = fgetc(fin); r_len--;
  if (r_len == 0) r_len = len;
  if (len > r_len) fprintf(stderr,"QT_Name: len(%ld) > r_len(%ld)\n",len,r_len);
  DEBUG_LEVEL2 fprintf(stderr,"      (%ld/%ld) ",len,r_len);
  for(i=0;i<r_len;i++)
  {
    d = fgetc(fin);
    if (i < len) DEBUG_LEVEL2 fputc(d,stderr);
  }
  DEBUG_LEVEL2 fputc('\n',stderr);
}

/* Time To Sample */
void QT_Read_STTS(fin)
FILE *fin;
{
  ULONG version,num,i,samp_cnt,duration,cur; 
  version	= UTIL_Get_MSB_Long(fin);
  num		= UTIL_Get_MSB_Long(fin);
  DEBUG_LEVEL2 fprintf(stderr,"    ver=%lx num of entries = %lx\n",version,num);
  if (qt_video_flag)
  {
    if (qt_t2samps==0)
    {
      qt_t2samp_num = num;
      qt_t2samps = (QT_T2SAMP_HDR *)malloc(num * sizeof(QT_T2SAMP_HDR));
      if (qt_t2samps==0) TheEnd1("QT_Read_STTS: malloc err");
      cur = 0;
    }
    else
    { QT_T2SAMP_HDR *t_t2samp;
      t_t2samp = (QT_T2SAMP_HDR *)
			malloc((qt_t2samp_num + num) * sizeof(QT_T2SAMP_HDR));
      if (t_t2samp==0) TheEnd1("QT_Read_STTS: malloc err");
      for(i=0;i<qt_t2samp_num;i++) t_t2samp[i] = qt_t2samps[i];
      cur = qt_t2samp_num;
      qt_t2samp_num += num;
      free(qt_t2samps);
      qt_t2samps = t_t2samp;
    }
    if (qt_timescale == 0) qt_timescale = 1000;
  }
  for(i=0;i<num;i++)
  {
    samp_cnt	= UTIL_Get_MSB_Long(fin);
    duration	= UTIL_Get_MSB_Long(fin);
    if (qt_video_flag)
    { /* NOTE: convert to 1000ms per second */
      qt_t2samps[cur].cnt = samp_cnt;
      qt_t2samps[cur].time = (1000 * duration) / qt_timescale; 
      cur++;
    }
    DEBUG_LEVEL2 fprintf(stderr,"      %ld) samp_cnt=%lx duration = %lx\n",
						i,samp_cnt,duration);
  }
}


/* Sync Sample */
void QT_Read_STSS(fin)
FILE *fin;
{
  ULONG version,num,i,j;
  version	= UTIL_Get_MSB_Long(fin);
  num		= UTIL_Get_MSB_Long(fin);
  DEBUG_LEVEL2 
  {
    fprintf(stderr,"    ver=%lx num of entries = %lx\n",version,num);
    j = 0;
    fprintf(stderr,"      ");
  }
  for(i=0;i<num;i++)
  {
    ULONG samp_num;
    samp_num	= UTIL_Get_MSB_Long(fin);
    DEBUG_LEVEL2
    {
      fprintf(stderr,"%lx ",samp_num); j++;
      if (j >= 8) {fprintf(stderr,"\n      "); j=0; }
    }
  }
  DEBUG_LEVEL2 fprintf(stderr,"\n");
}


/* Sample to Chunk */
void QT_Read_STSC(fin,len)
FILE *fin;
LONG len;
{
  ULONG version,num,i,cur;
  version	= UTIL_Get_MSB_Long(fin);
  num		= UTIL_Get_MSB_Long(fin);
  DEBUG_LEVEL2 fprintf(stderr,"    ver=%lx num of entries = %lx\n",version,num);

  if (qt_video_flag == 1) /* if video info */
  {
    if (qt_s2chunks == 0)
    {
      qt_s2chunk_num = num;
      qt_s2chunks = (QT_S2CHUNK_HDR *)malloc((num+1) * sizeof(QT_S2CHUNK_HDR));
      cur = 0;
    }
    else
    { QT_S2CHUNK_HDR *ts2c;
      ts2c = (QT_S2CHUNK_HDR *)
		malloc( (qt_s2chunk_num+num+1) * sizeof(QT_S2CHUNK_HDR));
      for(i=0;i<qt_s2chunk_num;i++) ts2c[i] = qt_s2chunks[i];
      cur = qt_s2chunk_num;
      qt_s2chunk_num += num;
      free(qt_s2chunks);
      qt_s2chunks = ts2c;
    }
  }
  for(i=0;i<num;i++)
  {
    ULONG first_chk,samp_per,chunk_tag;
    first_chk	= UTIL_Get_MSB_Long(fin);
    samp_per	= UTIL_Get_MSB_Long(fin);
    chunk_tag	= UTIL_Get_MSB_Long(fin);
    DEBUG_LEVEL2 
     fprintf(stderr,"      %ld) first_chunk=%lx samp_per_chk=%lx chk_tag=%lx\n",
					i,first_chk,samp_per,chunk_tag);
    if (qt_video_flag == 1) /* if video info */
    {
        /* start at 0 not 1  and account for previous chunks */
      qt_s2chunks[cur].first = first_chk - 1 + qt_chunkoff_lstnum;
      if (chunk_tag > (qt_codec_num-qt_codec_lstnum)) 
	{ qt_stsc_invalid = TRUE; samp_per = chunk_tag = 1; }
      qt_s2chunks[cur].num   = samp_per;
      qt_s2chunks[cur].tag   = chunk_tag - 1 + qt_codec_lstnum;
      cur++;
    }
  }
  if (qt_video_flag == 1) /* if video info */
  {
    qt_s2chunks[cur].first = 0;
    qt_s2chunks[cur].num   = 0;
    qt_s2chunks[cur].tag   = 0;
  }
  len -= 16 + (num * 12);
  while (len > 0) { fgetc(fin); len--; }
}


/* Sample Size */
void QT_Read_STSZ(fin,len)
FILE *fin;
LONG len;
{
  ULONG version,samp_size,num,i;
  version	= UTIL_Get_MSB_Long(fin);
  samp_size	= UTIL_Get_MSB_Long(fin);
  num		= UTIL_Get_MSB_Long(fin);
  len = (len - 20) / 4;   /* number of stored samples */

  DEBUG_LEVEL2 fprintf(stderr,"    ver=%lx samp_size=%lx entries= %lx stored entries=%lx\n",
				version,samp_size,num,len);

  if (qt_video_flag == 1) /* if video info */
  { ULONG cur;

    if (qt_samp_sizes == 0)
    {
      qt_sample_num = num;
      qt_samp_sizes = (ULONG *)malloc(num * sizeof(ULONG));
      if (qt_samp_sizes == 0) {fprintf(stderr,"malloc err 0\n"); exit(0);}
      cur = 0;
    }
    else /*TRAK*/
    {
      ULONG *tsamps;
      tsamps = (ULONG *)malloc((qt_sample_num + num) * sizeof(ULONG));
      if (tsamps == 0) {fprintf(stderr,"malloc err 0\n"); exit(0);}
      for(i=0; i<qt_sample_num; i++) tsamps[i] = qt_samp_sizes[i];
      cur = qt_sample_num;
      qt_sample_num += num;
      free(qt_samp_sizes);
      qt_samp_sizes = tsamps;
    }
    for(i=0;i<num;i++) 
    {
      if (i < len) qt_samp_sizes[cur] = UTIL_Get_MSB_Long(fin);
      else if (i==0) qt_samp_sizes[cur] = samp_size;
           else qt_samp_sizes[cur] = qt_samp_sizes[cur-1];
      cur++;
    }
  }
  else while(len > 0) { UTIL_Get_MSB_Long(fin); len--; }
}

/* Chunk Offset */
void QT_Read_STCO(fin)
FILE *fin;
{
  ULONG version,num,i;
  version	= UTIL_Get_MSB_Long(fin);
  num		= UTIL_Get_MSB_Long(fin);
  DEBUG_LEVEL2 fprintf(stderr,"    ver=%lx entries= %lx\n",version,num);

  if (qt_video_flag == 1) /* if video info */
  { ULONG cur;
    if (qt_chunkoffs == 0)
    {
      qt_chunkoff_num = num;
      qt_chunkoffs = (ULONG *)malloc(num * sizeof(ULONG) );
      cur = 0;
    }
    else
    {
      ULONG *tchunks;
      tchunks = (ULONG *)malloc((qt_chunkoff_num + num) * sizeof(ULONG));
      if (tchunks == 0) {fprintf(stderr,"malloc err 0\n"); exit(0);}
      for(i=0; i<qt_chunkoff_num; i++) tchunks[i] = qt_chunkoffs[i];
      cur = qt_chunkoff_num;
      qt_chunkoff_num += num;
      free(qt_chunkoffs);
      qt_chunkoffs = tchunks;
    }
    for(i=0;i<num;i++) {qt_chunkoffs[cur] = UTIL_Get_MSB_Long(fin); cur++; }
  }
  else for(i=0;i<num;i++) UTIL_Get_MSB_Long(fin);
}



void QT_Read_Data(fin,anim_hdr)
FILE *fin;
XA_ANIM_HDR *anim_hdr;
{
  ULONG d,ret,base_offset,i;
  ULONG cur_samp,cur_s2chunk,nxt_s2chunk;
  ULONG cur_t2samp,nxt_t2samp;
  ULONG tag;
  ULONG olast;
  XA_ACTION *act;

  if (qt_samp_sizes == 0) {fprintf(stderr,"no samples\n"); return; } 
  base_offset = 0;

  nxt_t2samp = cur_t2samp = 0;
  if (qt_t2samps)
  {
    qt_time = XA_GET_TIME( qt_t2samps[cur_t2samp].time );
    nxt_t2samp += qt_t2samps[cur_t2samp].cnt;
  } else qt_time = XA_GET_TIME( 67 );

  olast=0;
  cur_samp = 0;
  cur_s2chunk = 0;
  nxt_s2chunk = qt_s2chunks[cur_s2chunk + 1].first;
  tag =  qt_s2chunks[cur_s2chunk].tag;
  qt_imagex = qt_codecs[tag].width;
  qt_imagey = qt_codecs[tag].height;
  qt_depth  = qt_codecs[tag].depth;
  qt_compression  = qt_codecs[tag].compression;
  qt_chdr   = qt_codecs[tag].chdr;
  /* KLUDGE FOR Lem_Separation */
/*
  if (qt_sample_num == qt_chunkoff_num) nxt_s2chunk = qt_chunkoff_num + 1;
*/
  /* Loop through chunk offsets */
  for(i=0; i < qt_chunkoff_num; i++)
  {
    ULONG size,off,num_samps;
    ACT_DLTA_HDR *dlta_hdr;

    off =  base_offset + qt_chunkoffs[i];
    	/* survive RPZA despite corruption(offsets commonly corrupted).*/
    if (qt_compression == QT_CODEC_RPZA)
    { ULONG check;
      fseek(fin,off,0); check = UTIL_Get_MSB_Long(fin) & 0x00ffffff;
      if (check != qt_samp_sizes[cur_samp])
      {
        fseek(fin,olast,0); check = UTIL_Get_MSB_Long(fin) & 0x00ffffff;
        if (check == qt_samp_sizes[cur_samp]) off = olast;
      }
    }
    olast = off;
    fseek(fin,off,0);  /* move to start of chunk data */

    if ( (cur_samp >= nxt_t2samp) && (nxt_t2samp < qt_t2samp_num) )
    {
      cur_t2samp++;
      qt_time = XA_GET_TIME( qt_t2samps[cur_t2samp].time );
      nxt_t2samp += qt_t2samps[cur_t2samp].cnt;
    }

    if ( (i == nxt_s2chunk) && ((cur_s2chunk+1) < qt_s2chunk_num) )
    {
      cur_s2chunk++;
      nxt_s2chunk = qt_s2chunks[cur_s2chunk + 1].first;
    }
    num_samps = qt_s2chunks[cur_s2chunk].num;

    /* Check tags and possibly move to new codec */
    if (qt_s2chunks[cur_s2chunk].tag >= qt_codec_num) 
    {
      fprintf(stderr,"QT Data: Warning stsc chunk invalid %ld tag %ld\n",
		cur_s2chunk,qt_s2chunks[cur_s2chunk].tag);
    } 
    else if (qt_s2chunks[cur_s2chunk].tag != tag)
    {
      tag =  qt_s2chunks[cur_s2chunk].tag;
      qt_imagex = qt_codecs[tag].width;
      qt_imagey = qt_codecs[tag].height;
      qt_depth  = qt_codecs[tag].depth;
      qt_compression  = qt_codecs[tag].compression;
      qt_chdr   = qt_codecs[tag].chdr;
    }

    /* Read number of samples in each chunk */
    while(num_samps--)
    {
      size = qt_samp_sizes[cur_samp];
      olast += size;

      /* QT_Codec_List(fin,size);  for decoding only */
      DEBUG_LEVEL2 fprintf(stderr,"CODEC %lx) size = %lx offset = %lx\n",
		i,size,off);
/*
fprintf(stderr,"CODEC %lx %ld) size = %lx offset = %lx samp %ld\n",
		i,cur_samp,size,off,num_samps);
*/

      act = ACT_Get_Action(anim_hdr,ACT_DELTA);
      if (xa_file_flag == TRUE)
      {
	dlta_hdr = (ACT_DLTA_HDR *) malloc(sizeof(ACT_DLTA_HDR));
	if (dlta_hdr == 0) TheEnd1("QT rle: malloc failed");
	act->data = (UBYTE *)dlta_hdr;
	dlta_hdr->flags = ACT_SNGL_BUF;
	dlta_hdr->fsize = size;
	dlta_hdr->fpos  = ftell(fin);
	fseek(fin,size,1); /* move past this chunk */
	if (size > qt_max_fsize) qt_max_fsize = size;
      }
      else
      {
	d = size + (sizeof(ACT_DLTA_HDR));
	dlta_hdr = (ACT_DLTA_HDR *) malloc( d );
	if (dlta_hdr == 0) TheEnd1("QT rle: malloc failed");
	act->data = (UBYTE *)dlta_hdr;
	dlta_hdr->flags = ACT_SNGL_BUF | DLTA_DATA;
	dlta_hdr->fpos = 0; dlta_hdr->fsize = size;
	ret = fread( dlta_hdr->data, size, 1, fin);
	if (ret != 1) TheEnd1("QT codec: read failed");
      }

      QT_Add_Frame( qt_time ,act);
      dlta_hdr->xpos = dlta_hdr->ypos = 0;
      dlta_hdr->xsize = qt_imagex;
      dlta_hdr->ysize = qt_imagey;
      dlta_hdr->special = 0;
      dlta_hdr->extra = 0;
      switch(qt_compression)
      {
        case QT_CODEC_RLE:   dlta_hdr->delta = QT_Decode_RLE; break;
        case QT_CODEC_RLE16: dlta_hdr->delta = QT_Decode_RLE16; break;
        case QT_CODEC_RLE24: dlta_hdr->delta = QT_Decode_RLE24; break;
        case QT_CODEC_RLE33: dlta_hdr->delta = QT_Decode_RLE33; break;
        case QT_CODEC_RAW:   dlta_hdr->delta = QT_Decode_RAW; break;
        case QT_CODEC_RPZA:  dlta_hdr->delta = QT_Decode_RPZA; break;
        case QT_CODEC_CVID:  dlta_hdr->delta = QT_Decode_CVID; break;
        case QT_CODEC_SMC:   dlta_hdr->delta = QT_Decode_SMC; break;
        default:
          fprintf(stderr,"QT: unsupported comp ");
          QT_Print_ID(stderr,qt_compression,1); 
	  fprintf(stderr,"depth=%ld\n",qt_depth);
          act->type = ACT_NOP;
          break;
      } /* end of compression types */

      if ( (xa_buffer_flag == TRUE) && (act->type != ACT_NOP) )
      {
	ULONG xpos,ypos,xsize,ysize,dlta_flag;
        if ( (cmap_true_map_flag==FALSE) || (qt_depth <= 8) )
	{
	  ULONG map_flag = (x11_display_type & XA_X11_TRUE)?(TRUE):(FALSE);
	  dlta_flag = dlta_hdr->delta(qt_pic,dlta_hdr->data,dlta_hdr->fsize,
		0,qt_chdr->map,map_flag, qt_imagex,qt_imagey,8,
		&xpos,&ypos,&xsize,&ysize,0,0);
	  if (!(dlta_flag & ACT_DLTA_MAPD)) map_flag = FALSE;
	  xsize -= xpos; ysize -= ypos;
	  FREE(dlta_hdr,0x9999); act->data = 0; dlta_hdr = 0;
	  if (dlta_flag & ACT_DLTA_NOP) act->type = ACT_NOP;
	  else ACT_Setup_Mapped(act,qt_pic,qt_chdr,xpos,ypos,xsize,ysize,
		qt_imagex,qt_imagey,FALSE,0, FALSE,TRUE,map_flag);
          ACT_Add_CHDR_To_Action(act,qt_chdr);
	}
	else /* decode as RGB triplets and then convert to mapped image */
	{
          UBYTE *tpic;
	  dlta_flag = dlta_hdr->delta(qt_pic,dlta_hdr->data,dlta_hdr->fsize,
		0,0,FALSE,qt_imagex,qt_imagey,8,&xpos,&ypos,&xsize,&ysize,1,0);
/*POD NOTE: need to add subimage support to RGB conversion utils */
	  FREE(dlta_hdr,0x9999); act->data = 0; dlta_hdr = 0;
	  if (dlta_flag & ACT_DLTA_NOP) act->type = ACT_NOP;
	  else
	  {
	    xpos = ypos = 0; xsize = qt_imagex; ysize = qt_imagey;
	    /* xsize -= xpos; ysize -= ypos; */
	    if (    (cmap_true_to_all == TRUE)
	        || ((cmap_true_to_1st == TRUE) && (qt_chdr == 0) )
	       )	qt_chdr = CMAP_Create_CHDR_From_True(qt_pic,8,8,8,
				qt_imagex,qt_imagey,qt_cmap,&qt_imagec);
	    else if ( (cmap_true_to_332 == TRUE) && (qt_chdr == 0) )
			qt_chdr = CMAP_Create_332(qt_cmap,&qt_imagec);
	    else if ( (cmap_true_to_gray == TRUE) && (qt_chdr == 0) )
			qt_chdr = CMAP_Create_Gray(qt_cmap,&qt_imagec);

	    if (cmap_dither_type == CMAP_DITHER_FLOYD)
		tpic = UTIL_RGB_To_FS_Map(0,qt_pic,qt_chdr,
					qt_imagex,qt_imagey,FALSE);
	    else
		tpic = UTIL_RGB_To_Map(0,qt_pic,qt_chdr,
					qt_imagex,qt_imagey,FALSE);
	    ACT_Setup_Mapped(act,tpic,qt_chdr,xpos,ypos,xsize,ysize,
		qt_imagex,qt_imagey,FALSE,0,TRUE,TRUE,FALSE);
            ACT_Add_CHDR_To_Action(act,qt_chdr);
	  } /* end of not NOP */
	} /* end of true_map */
      } /* end of buffer */
      else  /* not buffered */
      {
        /* Also make sure not TRUE, is 332 and special case file_flag */
        if ( (cmap_color_func != 0) && (qt_cmap_cnt == 0)
            && (qt_depth > 8) && (!(x11_display_type & XA_X11_TRUE)) )
        { 
	  ULONG xpos,ypos,xsize,ysize,dlta_flag,psize;
	  UBYTE *cbuf,*data;

	  psize = qt_imagex * qt_imagey;
	  cbuf = (UBYTE *) malloc(3 * psize);
          if (cbuf == 0) TheEnd1("colorfunc1 malloc err0\n");
	  memset((char *)(cbuf),0x00,(3 * psize) );

	  if (xa_file_flag == TRUE)
	  { ULONG pos;
	    data = (UBYTE *)malloc(dlta_hdr->fsize);
	    if (data==0) TheEnd1("colorfunc1 malloc err1\n");
	    pos = ftell(fin); 
	    fseek(fin,dlta_hdr->fpos,0); /* save file pos */
	    fread(data,dlta_hdr->fsize,1,fin); /* read data*/
	    fseek(fin,pos,0); /* restore file pos */
	  } else data = dlta_hdr->data;
          dlta_flag = dlta_hdr->delta(cbuf,data,dlta_hdr->fsize,
                0,0,FALSE,qt_imagex,qt_imagey,8,&xpos,&ypos,&xsize,&ysize,1,0);
	  if (xa_file_flag == TRUE) { free(data); data = 0; }

	 switch(cmap_color_func)
	 {
	  case 4:
	  {
            qt_chdr = CMAP_Create_CHDR_From_True(cbuf,8,8,8,
                              qt_imagex,qt_imagey,qt_cmap,&qt_imagec);
            DEBUG_LEVEL1 fprintf(stderr,"CF4: csize = %ld\n",qt_chdr->csize);
            if (qt_chdr->csize > 128) qt_cmap_cnt = 1;
            if (cbuf) free(cbuf); cbuf = 0;
	  }
	  break;
         } /* end of switch */
        } /* first time through */
        ACT_Add_CHDR_To_Action(act,qt_chdr);
      }
      cur_samp++;
      if (cur_samp >= qt_sample_num) break;
    } /* end of sample number */
    if (cur_samp >= qt_sample_num) break;
  } /* end of chunk_offset loop */
}


ULONG
QT_Decode_RLE(image,delta,dsize,tchdr,map,map_flag,imagex,imagey,imaged,
					xs,ys,xe,ye,special,extra)
UBYTE *image;           /* Image Buffer. */
UBYTE *delta;           /* delta data. */
ULONG dsize;            /* delta size */
XA_CHDR *tchdr;		/* color map info */
ULONG *map;             /* used if it's going to be remapped. */
ULONG map_flag;         /* whether or not to use remap_map info. */
ULONG imagex,imagey;    /* Size of image buffer. */
ULONG imaged;           /* Depth of Image. (IFF specific) */
ULONG *xs,*ys;          /* pos of changed area. */
ULONG *xe,*ye;          /* size of changed area. */
ULONG special;          /* Special Info. */
ULONG extra;		/* extra info needed to decode delta */
{
  LONG y,lines,d; /* LONG min_x,max_x,min_y,max_y;  */
  UBYTE *dptr;

  dptr = delta;
  dptr += 4;    /* skip codec size */
  d = (*dptr++) << 8;  d |= *dptr++;   /* read code either 0008 or 0000 */
  if (d == 0x0000) /* NOP frame? */
  { /* There is one more byte 0x00 that I don't read in this case */
    *xs = *ys = *xe = *ye = 0;
    return(ACT_DLTA_NOP);
  }
  y = (*dptr++) << 8; y |= *dptr++;		/* start line */
  dptr += 2;					/* unknown */
  lines = (*dptr++) << 8; lines |= *dptr++;	/* number of lines */
  dptr += 2;					/* unknown */
  while(lines--)
  {
    ULONG xskip,cnt;
    xskip = *dptr++;				/* skip x pixels */
    cnt = *dptr++;				/* RLE code */
    if ( (x11_bytes_pixel==1) || (map_flag==FALSE) )
    { UBYTE *iptr = (UBYTE *)(image + (y * imagex) + (4 * (xskip-1)) );
      while(cnt != 0xff)
      {
        if (cnt == 0x00) { xskip = *dptr++; iptr += 4 * (xskip-1); }
        else if (cnt < 0x80)			/* run of data */
        {
          cnt *= 4; if (map_flag==FALSE) while(cnt--) *iptr++ = (UBYTE)*dptr++;
          else while(cnt--) *iptr++ = (UBYTE)map[*dptr++];
        } else					/* repeat data */
        { UBYTE d1,d2,d3,d4;	cnt = 0x100 - cnt;
          if (map_flag==TRUE) { d1=(UBYTE)map[*dptr++]; d2=(UBYTE)map[*dptr++];
			      d3=(UBYTE)map[*dptr++]; d4=(UBYTE)map[*dptr++]; }
	  else	{ d1 = (UBYTE)*dptr++; d2 = (UBYTE)*dptr++;
		  d3 = (UBYTE)*dptr++; d4 = (UBYTE)*dptr++; }
          while(cnt--) { *iptr++ =d1; *iptr++ =d2; *iptr++ =d3; *iptr++ =d4; }
        } /* end of  >= 0x80 */
        cnt = *dptr++;
      } /* end while cnt */
    } else if (x11_bytes_pixel==2)
    { USHORT *iptr = (USHORT *)(image + 2 *((y * imagex) + (4 * (xskip-1))) );
      while(cnt != 0xff)
      {
        if (cnt == 0x00) { xskip = *dptr++; iptr += 4 * (xskip-1); }
        else if (cnt < 0x80)			/* run of data */
        {
          cnt *= 4; while(cnt--) *iptr++ = (USHORT)map[*dptr++];
        } else					/* repeat data */
        { USHORT d1,d2,d3,d4;	cnt = 0x100 - cnt;
	  { d1 = (USHORT)map[*dptr++]; d2 = (USHORT)map[*dptr++];
	    d3 = (USHORT)map[*dptr++]; d4 = (USHORT)map[*dptr++]; }
          while(cnt--) { *iptr++ =d1; *iptr++ =d2; *iptr++ =d3; *iptr++ =d4; }
        } /* end of  >= 0x80 */
        cnt = *dptr++;
      } /* end while cnt */
    } else /* bytes == 4 */
    { ULONG *iptr = (ULONG *)(image + 4 * ((y * imagex) + (4 * (xskip-1))) );
      while(cnt != 0xff)
      {
        if (cnt == 0x00) { xskip = *dptr++; iptr += 4 * (xskip-1); }
        else if (cnt < 0x80)			/* run of data */
        {
          cnt *= 4; while(cnt--) *iptr++ = (ULONG)map[*dptr++];
        } else					/* repeat data */
        { ULONG d1,d2,d3,d4; cnt = 0x100 - cnt;
	  { d1 = (ULONG)map[*dptr++]; d2 = (ULONG)map[*dptr++]; 
	    d3 = (ULONG)map[*dptr++]; d4 = (ULONG)map[*dptr++]; }
          while(cnt--) { *iptr++ =d1; *iptr++ =d2; *iptr++ =d3; *iptr++ =d4; }
        } /* end of  >= 0x80 */
        cnt = *dptr++;
      } /* end while cnt */
    }
    y++;
  } /* end of lines */
 /* one more zero byte */
 *xs = *ys = 0; *xe = imagex; *ye = imagey;
 if (map_flag==TRUE) return(ACT_DLTA_MAPD);
 else return(ACT_DLTA_NORM);
}

ULONG QT_Parse_Bin(fin)
FILE *fin;
{
  ULONG pos,len,csize,cid,total;
 
  fseek(fin,0,2);
  total = ftell(fin);
 
/* Read over Header */
  fseek(fin,0,0);
  pos = len = UTIL_Get_MSB_Long(fin);
  cid = UTIL_Get_MSB_Long(fin);
  if (cid == QT_mdat)
  {
    fseek(fin,0,0);
    if (len == 0)
    {
      fprintf(stderr,"QT: This is only .data fork. Need .rsrc fork\n");
      return(0);
    }
    else return(1);
  }
 
DEBUG_LEVEL1 fprintf(stderr,"QT_Parse_Bin: %lx\n",pos);
 
  while( pos < total )
  {
    fseek(fin,pos,0);
 
    len = UTIL_Get_MSB_Long(fin);
    pos += 4;        /* binary size is 4 bytes */
    csize = UTIL_Get_MSB_Long(fin);
    cid   = UTIL_Get_MSB_Long(fin);
    if (cid == QT_moov)
    {
      fseek(fin,pos,0);
      return(1);
    }
    if (len == 0) return(0);
    pos += len;
  }
  return(0);
}

#define QT_BLOCK_INC(x,y,imagex) { x += 4; if (x>=imagex) { x=0; y += 4; }}

#define QT_MIN_MAX_CHECK(x,y,min_x,min_y,max_x,max_y) {	\
  if (x > max_x) max_x=x; if (y > max_y) max_y=y;	\
  if (x < min_x) min_x=x; if (y < min_y) min_y=y;  }

#define QT_RPZA_C1(ip,c,CAST,rinc) { \
 *ip++=(CAST)c; *ip++ =(CAST)c; *ip++ =(CAST)c; *ip = (CAST)c; ip +=rinc; \
 *ip++=(CAST)c; *ip++ =(CAST)c; *ip++ =(CAST)c; *ip = (CAST)c; ip +=rinc; \
 *ip++=(CAST)c; *ip++ =(CAST)c; *ip++ =(CAST)c; *ip = (CAST)c; ip +=rinc; \
 *ip++=(CAST)c; *ip++ =(CAST)c; *ip++ =(CAST)c; *ip = (CAST)c; }

#define QT_RPZA_C4(ip,c,mask,CAST); { \
 *ip++ =(CAST)(c[((mask>>6)&0x03)]); *ip++ =(CAST)(c[((mask>>4)&0x03)]); \
 *ip++ =(CAST)(c[((mask>>2)&0x03)]); *ip   =(CAST)(c[ (mask & 0x03)]); }

#define QT_RPZA_C16(ip,c,CAST,rinc) { \
 *ip++=(CAST)(*c++); *ip++=(CAST)(*c++); \
 *ip++=(CAST)(*c++); *ip  =(CAST)(*c++); ip +=rinc; \
 *ip++=(CAST)(*c++); *ip++=(CAST)(*c++); \
 *ip++=(CAST)(*c++); *ip  =(CAST)(*c++); ip +=rinc; \
 *ip++=(CAST)(*c++); *ip++=(CAST)(*c++); \
 *ip++=(CAST)(*c++); *ip  =(CAST)(*c++); ip +=rinc; \
 *ip++=(CAST)(*c++); *ip++=(CAST)(*c++); \
 *ip++=(CAST)(*c++); *ip  =(CAST)(*c  ); }

#define QT_RPZA_rgbC1(ip,r,g,b) { \
 *ip++=r; *ip++=g; *ip++=b; *ip++=r; *ip++=g; *ip++=b; \
 *ip++=r; *ip++=g; *ip++=b; *ip++=r; *ip++=g; *ip  =b; }

#define QT_RPZA_rgbC4(ip,r,g,b,mask); { ULONG _idx; \
 _idx = (mask>>6)&0x03; *ip++ = r[_idx]; *ip++ = g[_idx]; *ip++ = b[_idx]; \
 _idx = (mask>>4)&0x03; *ip++ = r[_idx]; *ip++ = g[_idx]; *ip++ = b[_idx]; \
 _idx = (mask>>2)&0x03; *ip++ = r[_idx]; *ip++ = g[_idx]; *ip++ = b[_idx]; \
 _idx =  mask    &0x03; *ip++ = r[_idx]; *ip++ = g[_idx]; *ip   = b[_idx]; }

#define QT_RPZA_rgbC16(ip,r,g,b) { \
 *ip++= *r++; *ip++= *g++; *ip++= *b++; *ip++= *r++; *ip++= *g++; *ip++= *b++; \
 *ip++= *r++; *ip++= *g++; *ip++= *b++; *ip++= *r++; *ip++= *g++; *ip = *b++; }

ULONG
QT_Decode_RPZA(image,delta,dsize,tchdr,map,map_flag,imagex,imagey,imaged,
					xs,ys,xe,ye,special,extra)
UBYTE *image;           /* Image Buffer. */
UBYTE *delta;           /* delta data. */
ULONG dsize;            /* delta size */
XA_CHDR *tchdr;		/* color map info */
ULONG *map;             /* used if it's going to be remapped. */
ULONG map_flag;         /* whether or not to use remap_map info. */
ULONG imagex,imagey;    /* Size of image buffer. */
ULONG imaged;           /* Depth of Image. (IFF specific) */
ULONG *xs,*ys;          /* pos of changed area. */
ULONG *xe,*ye;          /* size of changed area. */
ULONG special;          /* Special Info. */
ULONG extra;		/* extra info needed to decode delta */
{
  LONG x,y,len,row_inc, min_x,max_x,min_y,max_y;
  UBYTE *dptr;
  ULONG code,changed;
  XA_CHDR *chdr;

  if (tchdr) {chdr=(tchdr->new_chdr)?(tchdr->new_chdr):(tchdr);} else chdr=0;
  *xs = *ys = 0; *xe = imagex; *ye = imagey;
  max_x = max_y = 0; min_x = imagex; min_y = imagey; changed = 0;
  dptr = delta;
  x = y = 0;
  if (special) row_inc = (3 * imagex) - 11 ;
  else row_inc = imagex - 3;

  dptr++;			/* for 0xe1 */
  len =(*dptr++)<<16; len |= (*dptr++)<< 8; len |= (*dptr++); /* Read Len */
  if (len != dsize) /* CHECK FOR CORRUPTION - FAIRLY COMMON */
  {
    if (xa_verbose==TRUE) 
	fprintf(stderr,"QT corruption-skipping this frame %lx %lx\n",dsize,len);
    return(ACT_DLTA_NOP);
  }
  len -= 4;				/* read 4 already */
  while(len > 0)
  {
    code = *dptr++; len--;

    if ( (code >= 0xa0) && (code <= 0xbf) )			/* SINGLE */
    {
      ULONG color,skip;
      changed = 1;
      color = (*dptr++) << 8; color |= *dptr++; len -= 2;
      skip = (code-0x9f);
      if (special)
      { UBYTE r,g,b;
        QT_Get_RGBColor(&r,&g,&b,color); 
        while(skip--)
        { UBYTE *i_ptr = (UBYTE *)(image + 3 * (y * imagex + x) );
	  QT_RPZA_rgbC1(i_ptr,r,g,b); i_ptr += row_inc;
	  QT_RPZA_rgbC1(i_ptr,r,g,b); i_ptr += row_inc;
	  QT_RPZA_rgbC1(i_ptr,r,g,b); i_ptr += row_inc;
	  QT_RPZA_rgbC1(i_ptr,r,g,b); 
	  QT_MIN_MAX_CHECK(x,y,min_x,min_y,max_x,max_y);
	  QT_BLOCK_INC(x,y,imagex);
	}
      }
      else /* not special */
      {
        color = QT_Get_Color(color,map_flag,map,chdr); 
        while(skip--)
        {
          if ( (x11_bytes_pixel==1) || (map_flag == FALSE) )
          { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	    QT_RPZA_C1(i_ptr,color,UBYTE,row_inc);
	  }
          else if (x11_bytes_pixel==4)
          { ULONG *i_ptr = (ULONG *)(image + 4 * (y * imagex + x) );
	    QT_RPZA_C1(i_ptr,color,ULONG,row_inc);
	  }
          else /* if (x11_bytes_pixel==2) */
          { USHORT *i_ptr = (USHORT *)(image + 2 * (y * imagex + x) );
	    QT_RPZA_C1(i_ptr,color,USHORT,row_inc);
	  }
	  QT_MIN_MAX_CHECK(x,y,min_x,min_y,max_x,max_y);
	  QT_BLOCK_INC(x,y,imagex);
        } /* end of skip-- */
      } /* end not special */
    }
    else if ( (code >= 0x80) && (code <= 0x9f) )		/* SKIP */
    {
      ULONG skip = (code-0x7f);
      while(skip--) QT_BLOCK_INC(x,y,imagex);
    }
    else if ( (code < 0x80) 				/* FOUR/SIXTEEN */ 
	     || ((code >= 0xc0) && (code <= 0xdf)) )
    { ULONG cA,cB;
      changed = 1;
      /* Get 1st two colors */
      if (code >= 0xc0) { cA = (*dptr++) << 8; cA |= *dptr++; len -= 2; }
      else {cA = (code << 8) | *dptr++; len -= 1;}
      cB = (*dptr++) << 8; cB |= *dptr++; len -= 2;

      /****** SIXTEEN COLOR *******/
      if ( (code < 0x80) && ((cB & 0x8000)==0) ) /* 16 color */
      {
        ULONG i,d,*clr,c[16];
        UBYTE r[16],g[16],b[16];
	if (special)
	{
          QT_Get_RGBColor(&r[0],&g[0],&b[0],cA);
          QT_Get_RGBColor(&r[1],&g[1],&b[1],cB);
          for(i=2; i<16; i++)
          {
            d = (*dptr++) << 8; d |= *dptr++; len -= 2;
            QT_Get_RGBColor(&r[i],&g[i],&b[i],d);
          }
	}
	else
	{
	  clr = c;
          *clr++ = QT_Get_Color(cA,map_flag,map,chdr);
          *clr++ = QT_Get_Color(cB,map_flag,map,chdr);
          for(i=2; i<16; i++)
          {
            d = (*dptr++) << 8; d |= *dptr++; len -= 2;
            *clr++ = QT_Get_Color(d,map_flag,map,chdr);
          }
	}
	clr = c;
	if (special)
	{ UBYTE *i_ptr = (UBYTE *)(image + 3 * (y * imagex + x) );
	  UBYTE *tr,*tg,*tb; tr=r; tg=g; tb=b;
	  QT_RPZA_rgbC16(i_ptr,tr,tg,tb); *i_ptr += row_inc;
	  QT_RPZA_rgbC16(i_ptr,tr,tg,tb); *i_ptr += row_inc;
	  QT_RPZA_rgbC16(i_ptr,tr,tg,tb); *i_ptr += row_inc;
	  QT_RPZA_rgbC16(i_ptr,tr,tg,tb);
	}
	else if ( (x11_bytes_pixel==1) || (map_flag==FALSE) )
        { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	  QT_RPZA_C16(i_ptr,clr,UBYTE,row_inc);
	}
	else if (x11_bytes_pixel==4)
	{ ULONG *i_ptr = (ULONG *)(image + 4 * (y * imagex + x) );
	  QT_RPZA_C16(i_ptr,clr,ULONG,row_inc);
	}
	else /* if (x11_bytes_pixel==2) */
	{ USHORT *i_ptr = (USHORT *)(image + 2 * (y * imagex + x) );
	  QT_RPZA_C16(i_ptr,clr,USHORT,row_inc);
	}
	QT_MIN_MAX_CHECK(x,y,min_x,min_y,max_x,max_y);
	QT_BLOCK_INC(x,y,imagex);
      } /*** END of SIXTEEN COLOR */
      else					/****** FOUR COLOR *******/
      {
        ULONG m_cnt,msk0,msk1,msk2,msk3,c[4];
	UBYTE r[4],g[4],b[4];

        if (code < 0x80) m_cnt = 1; 
	else m_cnt = code - 0xbf; 

	if (special) QT_Get_AV_RGBColors(c,r,g,b,cA,cB);
	else QT_Get_AV_Colors(c,cA,cB,map_flag,map,chdr);

        while(m_cnt--)
        {
	  msk0 = *dptr++; msk1 = *dptr++;
	  msk2 = *dptr++; msk3 = *dptr++; len -= 4;
	  if (special)
	  { UBYTE *i_ptr = (UBYTE *)(image + 3 * (y * imagex + x) );
	    QT_RPZA_rgbC4(i_ptr,r,g,b,msk0); *i_ptr += row_inc;
	    QT_RPZA_rgbC4(i_ptr,r,g,b,msk1); *i_ptr += row_inc;
	    QT_RPZA_rgbC4(i_ptr,r,g,b,msk2); *i_ptr += row_inc;
	    QT_RPZA_rgbC4(i_ptr,r,g,b,msk3);
	  }
	  else if ( (x11_bytes_pixel==1) || (map_flag==FALSE) )
          { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	    QT_RPZA_C4(i_ptr,c,msk0,UBYTE); i_ptr += row_inc;
	    QT_RPZA_C4(i_ptr,c,msk1,UBYTE); i_ptr += row_inc;
	    QT_RPZA_C4(i_ptr,c,msk2,UBYTE); i_ptr += row_inc;
	    QT_RPZA_C4(i_ptr,c,msk3,UBYTE);
	  }
	  else if (x11_bytes_pixel==4)
	  { ULONG *i_ptr = (ULONG *)(image + 4 * (y * imagex + x) );
	    QT_RPZA_C4(i_ptr,c,msk0,ULONG); i_ptr += row_inc;
	    QT_RPZA_C4(i_ptr,c,msk1,ULONG); i_ptr += row_inc;
	    QT_RPZA_C4(i_ptr,c,msk2,ULONG); i_ptr += row_inc;
	    QT_RPZA_C4(i_ptr,c,msk3,ULONG);
	  }
	  else /* if (x11_bytes_pixel==2) */
	  { USHORT *i_ptr = (USHORT *)(image + 2 * (y * imagex + x) );
	    QT_RPZA_C4(i_ptr,c,msk0,USHORT); i_ptr += row_inc;
	    QT_RPZA_C4(i_ptr,c,msk1,USHORT); i_ptr += row_inc;
	    QT_RPZA_C4(i_ptr,c,msk2,USHORT); i_ptr += row_inc;
	    QT_RPZA_C4(i_ptr,c,msk3,USHORT);
	  }
	  QT_MIN_MAX_CHECK(x,y,min_x,min_y,max_x,max_y);
	  QT_BLOCK_INC(x,y,imagex);
        }  
      } /*** END of FOUR COLOR *******/
    } /*** END of 4/16 COLOR BLOCKS ****/
    else /* UNKNOWN */
    {
      fprintf(stderr,"QT RPZA: Unknown %lx\n",code);
      return(ACT_DLTA_NOP);
    }
  }
  if (xa_optimize_flag == TRUE)
  {
    if (changed) { *xs=min_x; *ys=min_y; *xe=max_x + 4; *ye=max_y + 4; }
    else  { *xs = *ys = *xe = *ye = 0; return(ACT_DLTA_NOP); }
  }
  else { *xs = *ys = 0; *xe = imagex; *ye = imagey; }
  if (map_flag) return(ACT_DLTA_MAPD);
  else return(ACT_DLTA_NORM);
}

void QT_Get_RGBColor(r,g,b,color)
UBYTE *r,*g,*b;
ULONG color;
{ ULONG ra,ga,ba;
  ra = (color >> 10) & 0x1f;	ra = (ra << 3) | (ra >> 2);
  ga = (color >>  5) & 0x1f;	ga = (ga << 3) | (ga >> 2);
  ba =  color & 0x1f;		ba = (ba << 3) | (ba >> 2);
  *r = ra; *g = ga; *b = ba;
}

ULONG QT_Get_Color(color,map_flag,map,chdr)
ULONG color,map_flag,*map;
XA_CHDR *chdr;
{
  register ULONG clr,ra,ga,ba,ra5,ga5,ba5;

  ra5 = (color >> 10) & 0x1f;
  ga5 = (color >>  5) & 0x1f;
  ba5 =  color & 0x1f;
  ra = qt_gamma_adj[ra5]; ga = qt_gamma_adj[ga5]; ba = qt_gamma_adj[ba5];

  if (x11_display_type & XA_X11_TRUE) clr = X11_Get_True_Color(ra,ga,ba,16);
  else 
  { 
    if ((cmap_color_func == 4) && (chdr))
    { register ULONG cache_i = color & 0x7fff;
      if (cmap_cache == 0) CMAP_Cache_Init();
      if (chdr != cmap_cache_chdr)
      {
        CMAP_Cache_Clear();
        cmap_cache_chdr = chdr;
      }
      if (cmap_cache[cache_i] == 0xffff)
      {
        clr = chdr->coff +
           CMAP_Find_Closest(chdr->cmap,chdr->csize,ra,ga,ba,16,16,16,TRUE);
        cmap_cache[cache_i] = (USHORT)clr;
      }
      else clr = (ULONG)cmap_cache[cache_i];
    }
    else
    {
      if (cmap_true_to_332 == TRUE) clr = CMAP_GET_332(ra5,ga5,ba5,CMAP_SCALE5);
      else			  clr = CMAP_GET_GRAY(ra5,ga5,ba5,CMAP_SCALE10);
      if (map_flag) clr = map[clr];
    }
  }
  return(clr);
}

ULONG QT_Get_Color24(r,g,b,map_flag,map,chdr)
register ULONG r,g,b;
ULONG map_flag,*map;
XA_CHDR *chdr;
{
  ULONG clr,ra,ga,ba;

  ra = xa_gamma_adj[r]; ga = xa_gamma_adj[g]; ba = xa_gamma_adj[b];

  if (x11_display_type & XA_X11_TRUE) clr = X11_Get_True_Color(ra,ga,ba,16);
  else 
  { 
    if ((cmap_color_func == 4) && (chdr))
    { register ULONG cache_i;
      if (cmap_cache == 0) CMAP_Cache_Init();
      if (chdr != cmap_cache_chdr)
      {
        CMAP_Cache_Clear();
        cmap_cache_chdr = chdr;
      }
      cache_i  = ((r>>3)<<10) | ((g>>3)<<5) | (b>>3);
      if (cmap_cache[cache_i] == 0xffff)
      {
        clr = chdr->coff +
           CMAP_Find_Closest(chdr->cmap,chdr->csize,ra,ga,ba,16,16,16,TRUE);
        cmap_cache[cache_i] = (USHORT)clr;
      }
      else clr = (ULONG)cmap_cache[cache_i];
    }
    else 
    { if (cmap_true_to_332 == TRUE) clr = CMAP_GET_332(r,g,b,CMAP_SCALE8);
      else			  clr = CMAP_GET_GRAY(r,g,b,CMAP_SCALE13);
      if (map_flag) clr = map[clr];
    }
  }
  return(clr);
}

void QT_Get_AV_RGBColors(c,r,g,b,cA,cB)
ULONG *c;
UBYTE *r,*g,*b;
ULONG cA,cB;
{ ULONG rA,gA,bA,rB,gB,bB,ra,ga,ba;
/**color 3 ***/
  rA = (cA >> 10) & 0x1f;	r[3] = (rA << 3) | (rA >> 2);
  gA = (cA >>  5) & 0x1f;	g[3] = (gA << 3) | (gA >> 2);
  bA =  cA & 0x1f;		b[3] = (bA << 3) | (bA >> 2);
/**color 0 ***/
  rB = (cB >> 10) & 0x1f;	r[0] = (rB << 3) | (rB >> 2);
  gB = (cB >>  5) & 0x1f;	g[0] = (gB << 3) | (gB >> 2);
  bB =  cB & 0x1f;		b[0] = (bB << 3) | (bB >> 2);
/**color 2 ***/
  ra = (21*rA + 11*rB) >> 5;	r[2] = (ra << 3) | (ra >> 2);
  ga = (21*gA + 11*gB) >> 5;	g[2] = (ga << 3) | (ga >> 2);
  ba = (21*bA + 11*bB) >> 5;	b[2] = (ba << 3) | (ba >> 2);
/**color 1 ***/
  ra = (11*rA + 21*rB) >> 5;	r[1] = (ra << 3) | (ra >> 2);
  ga = (11*gA + 21*gB) >> 5;	g[1] = (ga << 3) | (ga >> 2);
  ba = (11*bA + 21*bB) >> 5;	b[1] = (ba << 3) | (ba >> 2);
}

void QT_Get_AV_Colors(c,cA,cB,map_flag,map,chdr)
ULONG *c;
ULONG cA,cB,map_flag,*map;
XA_CHDR *chdr;
{
  ULONG clr,rA,gA,bA,rB,gB,bB,r0,g0,b0,r1,g1,b1;
  ULONG rA5,gA5,bA5,rB5,gB5,bB5;
  ULONG r05,g05,b05,r15,g15,b15;

/*color 3*/
  rA5 = (cA >> 10) & 0x1f;
  gA5 = (cA >>  5) & 0x1f;
  bA5 =  cA & 0x1f;
/*color 0*/
  rB5 = (cB >> 10) & 0x1f;
  gB5 = (cB >>  5) & 0x1f;
  bB5 =  cB & 0x1f;
/*color 2*/
  r05 = (21*rA5 + 11*rB5) >> 5;
  g05 = (21*gA5 + 11*gB5) >> 5;
  b05 = (21*bA5 + 11*bB5) >> 5;
/*color 1*/
  r15 = (11*rA5 + 21*rB5) >> 5;
  g15 = (11*gA5 + 21*gB5) >> 5;
  b15 = (11*bA5 + 21*bB5) >> 5;
/*adj and scale to 16 bits */
  rA=qt_gamma_adj[rA5]; gA=qt_gamma_adj[gA5]; bA=qt_gamma_adj[bA5];
  rB=qt_gamma_adj[rB5]; gB=qt_gamma_adj[gB5]; bB=qt_gamma_adj[bB5];
  r0=qt_gamma_adj[r05]; g0=qt_gamma_adj[g05]; b0=qt_gamma_adj[b05];
  r1=qt_gamma_adj[r15]; g1=qt_gamma_adj[g15]; b1=qt_gamma_adj[b15];

  /*** 1st Color **/
  if (x11_display_type & XA_X11_TRUE) clr = X11_Get_True_Color(rA,gA,bA,16);
  else 
  { 
    if ((cmap_color_func == 4) && (chdr))
    { register ULONG cache_i = cA & 0x7fff;
      if (cmap_cache == 0) CMAP_Cache_Init();
      if (chdr != cmap_cache_chdr)
      {
        CMAP_Cache_Clear();
        cmap_cache_chdr = chdr;
      }
      if (cmap_cache[cache_i] == 0xffff)
      {
        clr = chdr->coff +
           CMAP_Find_Closest(chdr->cmap,chdr->csize,rA,gA,bA,16,16,16,TRUE);
        cmap_cache[cache_i] = (USHORT)clr;
      }
      else clr = (ULONG)cmap_cache[cache_i];
    }
    else
    { if (cmap_true_to_332 == TRUE) clr = CMAP_GET_332(rA5,gA5,bA5,CMAP_SCALE5);
      else	clr = CMAP_GET_GRAY(rA5,gA5,bA5,CMAP_SCALE10);
      if (map_flag) clr = map[clr];
    }
  }
  c[3] = clr;

  /*** 2nd Color **/
  if (x11_display_type & XA_X11_TRUE) clr = X11_Get_True_Color(rB,gB,bB,16);
  else 
  { 
    if ((cmap_color_func == 4) && (chdr))
    { register ULONG cache_i = cB & 0x7fff;
      if (cmap_cache[cache_i] == 0xffff)
      {
        clr = chdr->coff +
           CMAP_Find_Closest(chdr->cmap,chdr->csize,rB,gB,bB,16,16,16,TRUE);
        cmap_cache[cache_i] = (USHORT)clr;
      }
      else clr = (ULONG)cmap_cache[cache_i];
    }
    else
    { if (cmap_true_to_332 == TRUE) clr = CMAP_GET_332(rB5,gB5,bB5,CMAP_SCALE5);
      else	clr = CMAP_GET_GRAY(rB5,gB5,bB5,CMAP_SCALE10);
      if (map_flag) clr = map[clr];
    }
  }
  c[0] = clr;

  /*** 1st Av ****/
  if (x11_display_type & XA_X11_TRUE) clr = X11_Get_True_Color(r0,g0,b0,16);
  else 
  { 
    if ((cmap_color_func == 4) && (chdr))
    { register ULONG cache_i;
      cache_i = (ULONG)(r05 << 10) | (g05 << 5) | b05;
      if (cmap_cache[cache_i] == 0xffff)
      {
        clr = chdr->coff +
           CMAP_Find_Closest(chdr->cmap,chdr->csize,r0,g0,b0,16,16,16,TRUE);
        cmap_cache[cache_i] = (USHORT)clr;
      }
      else clr = (ULONG)cmap_cache[cache_i];
    }
    else
    { if (cmap_true_to_332 == TRUE) clr = CMAP_GET_332(r05,g05,b05,CMAP_SCALE5);
      else	clr = CMAP_GET_GRAY(r05,g05,b05,CMAP_SCALE10);
      if (map_flag) clr = map[clr];
    }
  }
  c[2] = clr;

  /*** 2nd Av ****/
  if (x11_display_type & XA_X11_TRUE) clr = X11_Get_True_Color(r1,g1,b1,16);
  else 
  { 
    if ((cmap_color_func == 4) && (chdr))
    { register ULONG cache_i;
      cache_i = (ULONG)(r15 << 10) | (g15 << 5) | b15;
      if (cmap_cache[cache_i] == 0xffff)
      {
        clr = chdr->coff +
           CMAP_Find_Closest(chdr->cmap,chdr->csize,r1,g1,b1,16,16,16,TRUE);
        cmap_cache[cache_i] = (USHORT)clr;
      }
      else clr = (ULONG)cmap_cache[cache_i];
    }
    else
    { if (cmap_true_to_332 == TRUE) clr = CMAP_GET_332(r15,g15,b15,CMAP_SCALE5);
      else	clr = CMAP_GET_GRAY(r15,g15,b15,CMAP_SCALE10);
      if (map_flag) clr = map[clr];
    }
  }
  c[1] = clr;
}


ULONG
QT_Decode_RLE16(image,delta,dsize,tchdr,map,map_flag,imagex,imagey,imaged,
					xs,ys,xe,ye,special,extra)
UBYTE *image;           /* Image Buffer. */
UBYTE *delta;           /* delta data. */
ULONG dsize;            /* delta size */
XA_CHDR *tchdr;		/* color map info */
ULONG *map;             /* used if it's going to be remapped. */
ULONG map_flag;         /* whether or not to use remap_map info. */
ULONG imagex,imagey;    /* Size of image buffer. */
ULONG imaged;           /* Depth of Image. (IFF specific) */
ULONG *xs,*ys;          /* pos of changed area. */
ULONG *xe,*ye;          /* size of changed area. */
ULONG special;          /* Special Info. */
ULONG extra;		/* extra info needed to decode delta */
{
  LONG y,d,lines; /* LONG min_x,max_x,min_y,max_y; */
  ULONG special_flag;
  UBYTE r,g,b,*dptr;
  XA_CHDR *chdr;

  if (tchdr) {chdr=(tchdr->new_chdr)?(tchdr->new_chdr):(tchdr);} else chdr=0;

  special_flag = special & 0x0001;

  dptr = delta;
  dptr += 4;    /* skip codec size */
  d = (*dptr++) << 8;  d |= *dptr++;   /* read code either 0008 or 0000 */
  if (d == 0x0000) /* NOP */
  { /* There is one more byte 0x00 that I don't read in this case */
    *xs = *ys = *xe = *ye = 0;
    return(ACT_DLTA_NOP);
  }
  y = (*dptr++) << 8; y |= *dptr++;		/* start line */
  dptr += 2;					/* unknown */
  lines = (*dptr++) << 8; lines |= *dptr++;	/* number of lines */
  dptr += 2;					/* unknown */
  while(lines--)				/* loop thru lines */
  {
    ULONG d,xskip,cnt;
    xskip = *dptr++;				/* skip x pixels */
    cnt = *dptr++;				/* RLE code */

    if (special_flag)
    { UBYTE *iptr = (UBYTE *)(image + 3*((y * imagex) + (xskip-1)) );
      while(cnt != 0xff)				/* while not EOL */
      {
        if (cnt == 0x00) { xskip = *dptr++; iptr += 3*(xskip-1); }
        else if (cnt < 0x80)				/* run of data */
          while(cnt--) { d = (*dptr++ << 8); d |= *dptr++;
			 QT_Get_RGBColor(&r,&g,&b,d);
			*iptr++ = r; *iptr++ = g; *iptr++ = b; }
        else						/* repeat data */
        { cnt = 0x100 - cnt; d = (*dptr++ << 8); d |= *dptr++;
          QT_Get_RGBColor(&r,&g,&b,d);
          while(cnt--) { *iptr++ = r; *iptr++ = g; *iptr++ = b; }
        }
        cnt = *dptr++;				/* get new RLE code */
      } /* end of line */
    }
    else if ( (x11_bytes_pixel==1) || (map_flag==FALSE) )
    { UBYTE *iptr = (UBYTE *)(image + (y * imagex) + (xskip-1) );
      while(cnt != 0xff)				/* while not EOL */
      {
        if (cnt == 0x00) { xskip = *dptr++; iptr += (xskip-1); }
        else if (cnt < 0x80)				/* run of data */
          while(cnt--) { d = (*dptr++ << 8); d |= *dptr++;
		*iptr++ = (UBYTE)QT_Get_Color(d,map_flag,map,chdr); }
        else						/* repeat data */
        { cnt = 0x100 - cnt; d = (*dptr++ << 8); d |= *dptr++;
          d = QT_Get_Color(d,map_flag,map,chdr);
          while(cnt--) { *iptr++ = (UBYTE)d; }
        }
        cnt = *dptr++;				/* get new RLE code */
      } /* end of line */
    }
    else if (x11_bytes_pixel==4)
    { ULONG *iptr = (ULONG *)(image + 4*((y * imagex)+(xskip-1)) );
      while(cnt != 0xff)				/* while not EOL */
      {
        if (cnt == 0x00) { xskip = *dptr++; iptr += (xskip-1); }
        else if (cnt < 0x80)				/* run of data */
          while(cnt--) { d = (*dptr++ << 8); d |= *dptr++;
		*iptr++ = (ULONG)QT_Get_Color(d,map_flag,map,chdr); }
        else						/* repeat data */
        { cnt = 0x100 - cnt; d = (*dptr++ << 8); d |= *dptr++;
          d = QT_Get_Color(d,map_flag,map,chdr);
          while(cnt--) { *iptr++ = (ULONG)d; }
        }
        cnt = *dptr++;				/* get new RLE code */
      } /* end of line */
    }
    else /* if (x11_bytes_pixel==2) */
    { USHORT *iptr = (USHORT *)(image + 2*((y * imagex)+(xskip-1)) );
      while(cnt != 0xff)				/* while not EOL */
      {
        if (cnt == 0x00) { xskip = *dptr++; iptr += (xskip-1); }
        else if (cnt < 0x80)				/* run of data */
          while(cnt--) { d = (*dptr++ << 8); d |= *dptr++;
		*iptr++ = (USHORT)QT_Get_Color(d,map_flag,map,chdr); }
        else						/* repeat data */
        { cnt = 0x100 - cnt; d = (*dptr++ << 8); d |= *dptr++;
          d = QT_Get_Color(d,map_flag,map,chdr);
          while(cnt--) { *iptr++ = (USHORT)d; }
        }
        cnt = *dptr++;				/* get new RLE code */
      } /* end of line */
    }
    y++;
  } /* end of lines */
 /* one more zero byte */
 *xs = *ys = 0; *xe = imagex; *ye = imagey;
 if (map_flag==TRUE) return(ACT_DLTA_MAPD);
 else return(ACT_DLTA_NORM);
}


ULONG
QT_Decode_RLE33(image,delta,dsize,tchdr,map,map_flag,imagex,imagey,imaged,
					xs,ys,xe,ye,special,extra)
UBYTE *image;           /* Image Buffer. */
UBYTE *delta;           /* delta data. */
ULONG dsize;            /* delta size */
XA_CHDR *tchdr;		/* color map info */
ULONG *map;             /* used if it's going to be remapped. */
ULONG map_flag;         /* whether or not to use remap_map info. */
ULONG imagex,imagey;    /* Size of image buffer. */
ULONG imaged;           /* Depth of Image. (IFF specific) */
ULONG *xs,*ys;          /* pos of changed area. */
ULONG *xe,*ye;          /* size of changed area. */
ULONG special;          /* Special Info. */
ULONG extra;		/* extra info needed to decode delta */
{
  LONG x,y,d,lines; /* LONG min_x,max_x,min_y,max_y; */
  UBYTE *dptr;

  dptr = delta;
  dptr += 4;    /* skip codec size */
  d = (*dptr++) << 8;  d |= *dptr++;   /* read code either 0008 or 0000 */
  if (d == 0x0000) /* NOP */
  { /* There is one more byte 0x00 that I don't read in this case */
    *xs = *ys = *xe = *ye = 0;
    return(ACT_DLTA_NOP);
  }
  y = (*dptr++) << 8; y |= *dptr++;		/* start line */
  dptr += 2;					/* unknown */
  lines = (*dptr++) << 8; lines |= *dptr++;	/* number of lines */
  dptr += 2;					/* unknown */
  x = 0; y--; lines++;
  while(lines)				/* loop thru lines */
  {
    ULONG d,xskip,cnt;
    xskip = *dptr++;				/* skip x pixels */
    cnt = *dptr++;				/* RLE code */
    
    if ((xskip == 0x80) && (cnt == 0x00))  /* end of codec */
	{lines = 0; y++; x = 0; }
    else if ((xskip == 0x80) && (cnt == 0xff)) /* skip line */
	{lines--; y++; x = 0; }
    else
    {
      if (xskip & 0x80) {lines--; y++; x = xskip & 0x7f;}
      else x += xskip;

      if (cnt < 0x80)				/* run of data */
      { 
        UBYTE *bptr; USHORT *sptr; ULONG *lptr;
	if ((x11_bytes_pixel==1) || (map_flag==FALSE) )
		bptr = (UBYTE *)(image + (y * imagex) + (x << 4) );
	else if (x11_bytes_pixel==2)
		sptr = (USHORT *)(image + 2*(y * imagex) + (x << 5) );
        else lptr = (ULONG *)(image + 4*(y * imagex) + (x << 6) );
        x += cnt;
        while(cnt--) 
        { ULONG i,mask;
          d = (*dptr++ << 8); d |= *dptr++;
          mask = 0x8000;
          for(i=0;i<16;i++)
          {
            if (map_flag==FALSE) 
		{ if (d & mask) *bptr++ = 0;  else *bptr++ = 1; }
            else if (x11_bytes_pixel==1) {if (d & mask) *bptr++=(UBYTE)map[0];
					else *bptr++=(UBYTE)map[1];}
            else if (x11_bytes_pixel==2) {if (d & mask) *sptr++ =(USHORT)map[0];
					else *sptr++ =(USHORT)map[1]; }
            else { if (d & mask) *lptr++ = (ULONG)map[0]; 
					else *lptr++ = (ULONG)map[1]; }
            mask >>= 1;
          }
        }
      } /* end run */ 
      else				/* repeat data */
      { 
        UBYTE *bptr; USHORT *sptr; ULONG *lptr;
	if ((x11_bytes_pixel==1) || (map_flag==FALSE) )
		bptr = (UBYTE *)(image + (y * imagex) + (x << 4) );
	else if (x11_bytes_pixel==2)
		sptr = (USHORT *)(image + 2*(y * imagex) + (x << 5) );
        else lptr = (ULONG *)(image + 4*(y * imagex) + (x << 6) );
        cnt = 0x100 - cnt;
        x += cnt;
        d = (*dptr++ << 8); d |= *dptr++;
        while(cnt--) 
        { ULONG i,mask;
          mask = 0x8000;
          for(i=0;i<16;i++)
          {
            if (map_flag==FALSE) 
		{ if (d & mask) *bptr++ = 0;  else *bptr++ = 1; }
            else if (x11_bytes_pixel==1) {if (d & mask) *bptr++=(UBYTE)map[0];
					else *bptr++=(UBYTE)map[1];}
            else if (x11_bytes_pixel==2) {if (d & mask) *sptr++ =(USHORT)map[0];
					else *sptr++ =(USHORT)map[1]; }
            else { if (d & mask) *lptr++ = (ULONG)map[0]; 
					else *lptr++ = (ULONG)map[1]; }
            mask >>= 1;
          }
        }
      } /* end repeat */
    } /* end of code */
  } /* end of lines */
 *xs = *ys = 0; *xe = imagex; *ye = imagey;
 if (map_flag==TRUE) return(ACT_DLTA_MAPD);
 else return(ACT_DLTA_NORM);
}

ULONG
QT_Decode_RAW(image,delta,dsize,tchdr,map,map_flag,imagex,imagey,imaged,
					xs,ys,xe,ye,special,extra)
UBYTE *image;           /* Image Buffer. */
UBYTE *delta;           /* delta data. */
ULONG dsize;            /* delta size */
XA_CHDR *tchdr;		/* color map info */
ULONG *map;             /* used if it's going to be remapped. */
ULONG map_flag;         /* whether or not to use remap_map info. */
ULONG imagex,imagey;    /* Size of image buffer. */
ULONG imaged;           /* Depth of Image. (IFF specific) */
ULONG *xs,*ys;          /* pos of changed area. */
ULONG *xe,*ye;          /* size of changed area. */
ULONG special;          /* Special Info. */
ULONG extra;		/* extra info needed to decode delta */
{
  UBYTE *dptr = delta;
  LONG i = imagex * imagey;
  
  if (map_flag==FALSE) { UBYTE *iptr = (UBYTE *)image; 
				while(i--) *iptr++ = (UBYTE)*dptr++; }
  else if (x11_bytes_pixel==1) { UBYTE *iptr = (UBYTE *)image; 
				while(i--) *iptr++ = (UBYTE)map[*dptr++]; }
  else if (x11_bytes_pixel==2) { USHORT *iptr = (USHORT *)image; 
				while(i--) *iptr++ = (USHORT)map[*dptr++]; }
  else { ULONG *iptr = (ULONG *)image; 
				while(i--) *iptr++ = (ULONG)map[*dptr++]; }

  *xs = *ys = 0; *xe = imagex; *ye = imagey;
  if (map_flag==TRUE) return(ACT_DLTA_MAPD);
  else return(ACT_DLTA_NORM);
}

#define QT_SMC_O2I(i,o,rinc) { \
*i++ = *o++; *i++ = *o++; *i++ = *o++; *i++ = *o++; i += rinc; o += rinc; \
*i++ = *o++; *i++ = *o++; *i++ = *o++; *i++ = *o++; i += rinc; o += rinc; \
*i++ = *o++; *i++ = *o++; *i++ = *o++; *i++ = *o++; i += rinc; o += rinc; \
*i++ = *o++; *i++ = *o++; *i++ = *o++; *i++ = *o++;  } 

#define QT_SMC_C1(i,c,rinc) { \
*i++ = c; *i++ = c; *i++ = c; *i++ = c;  i += rinc; \
*i++ = c; *i++ = c; *i++ = c; *i++ = c;  i += rinc; \
*i++ = c; *i++ = c; *i++ = c; *i++ = c;  i += rinc; \
*i++ = c; *i++ = c; *i++ = c; *i++ = c;  i += rinc; }

#define QT_SMC_C2(i,c0,c1,msk,rinc) { \
*i++ =(msk&0x80)?c1:c0; *i++ =(msk&0x40)?c1:c0; \
*i++ =(msk&0x20)?c1:c0; *i++ =(msk&0x10)?c1:c0; i += rinc; \
*i++ =(msk&0x08)?c1:c0; *i++ =(msk&0x04)?c1:c0; \
*i++ =(msk&0x02)?c1:c0; *i++ =(msk&0x01)?c1:c0; }

#define QT_SMC_C4(i,CST,c,mska,mskb,rinc) { \
*i++ = (CST)(c[(mska>>6) & 0x03]); *i++ = (CST)(c[(mska>>4) & 0x03]); \
*i++ = (CST)(c[(mska>>2) & 0x03]); *i++ = (CST)(c[mska & 0x03]); i+=rinc; \
*i++ = (CST)(c[(mskb>>6) & 0x03]); *i++ = (CST)(c[(mskb>>4) & 0x03]); \
*i++ = (CST)(c[(mskb>>2) & 0x03]); *i++ = (CST)(c[mskb & 0x03]); }

#define QT_SMC_C8(i,CST,c,msk,rinc) { \
*i++ = (CST)(c[(msk>>21) & 0x07]); *i++ = (CST)(c[(msk>>18) & 0x07]); \
*i++ = (CST)(c[(msk>>15) & 0x07]); *i++ = (CST)(c[(msk>>12) & 0x07]); i+=rinc; \
*i++ = (CST)(c[(msk>> 9) & 0x07]); *i++ = (CST)(c[(msk>> 6) & 0x07]); \
*i++ = (CST)(c[(msk>> 3) & 0x07]); *i++ = (CST)(c[msk & 0x07]); }

#define QT_SMC_C16m(i,dp,CST,map,rinc) { \
*i++ =(CST)map[*dp++]; *i++ =(CST)map[*dp++]; \
*i++ =(CST)map[*dp++]; *i++ =(CST)map[*dp++]; i += rinc; \
*i++ =(CST)map[*dp++]; *i++ =(CST)map[*dp++]; \
*i++ =(CST)map[*dp++]; *i++ =(CST)map[*dp++]; }

#define QT_SMC_C16(i,dp,CST) { \
*i++ =(CST)(*dp++); *i++ =(CST)(*dp++); \
*i++ =(CST)(*dp++); *i++ =(CST)(*dp++); }

ULONG
QT_Decode_SMC(image,delta,dsize,tchdr,map,map_flag,imagex,imagey,imaged,
					xs,ys,xe,ye,special,extra)
UBYTE *image;           /* Image Buffer. */
UBYTE *delta;           /* delta data. */
ULONG dsize;            /* delta size */
XA_CHDR *tchdr;		/* color map info */
ULONG *map;             /* used if it's going to be remapped. */
ULONG map_flag;         /* whether or not to use remap_map info. */
ULONG imagex,imagey;    /* Size of image buffer. */
ULONG imaged;           /* Depth of Image. (IFF specific) */
ULONG *xs,*ys;          /* pos of changed area. */
ULONG *xe,*ye;          /* size of changed area. */
ULONG special;          /* Special Info. */
ULONG extra;		/* extra info needed to decode delta */
{
  LONG x,y,len,row_inc; /* LONG min_x,max_x,min_y,max_y; */
  UBYTE *dptr;
  ULONG i,cnt,hicode,code;
  ULONG *c;

  smc_8cnt = smc_Acnt = smc_Ccnt = 0;

  *xs = *ys = 0; *xe = imagex; *ye = imagey;
  dptr = delta;
  x = y = 0;
  row_inc = imagex - 4;

  dptr++;				/* skip over 0xe1 */
  len =(*dptr++)<<16; len |= (*dptr++)<< 8; len |= (*dptr++); /* Read Len */
  len -= 4;				/* read 4 already */
  while(len > 0)
  {
    code = *dptr++; len--; hicode = code & 0xf0;
    switch(hicode)
    {
      case 0x00: /* SKIPs */
      case 0x10:
	if (hicode == 0x10) {cnt = 1 + *dptr++; len -= 1;}
	else cnt = 1 + (code & 0x0f);
        while(cnt--) {x += 4; if (x >= imagex) { x = 0; y += 4; } }
	break;
      case 0x20: /* Repeat Last Block */
      case 0x30:
	{ LONG tx,ty;
	  if (hicode == 0x30) {cnt = 1 + *dptr++; len--;}
	  else cnt = 1 + (code & 0x0f);
	  if (x==0) {ty = y-4; tx = imagex-4;} else {ty=y; tx = x-4;}

	  while(cnt--)
	  { 
	    if ( (x11_bytes_pixel==1) || (map_flag==FALSE) )
	    { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      UBYTE *o_ptr = (UBYTE *)(image + ty * imagex + tx);
	      QT_SMC_O2I(i_ptr,o_ptr,row_inc);
	    } else if (x11_bytes_pixel==2)
	    { USHORT *i_ptr = (USHORT *)(image + 2*(y * imagex + x) );
	      USHORT *o_ptr = (USHORT *)(image + 2*(ty * imagex + tx) );
	      QT_SMC_O2I(i_ptr,o_ptr,row_inc);
	    } else /* if (x11_bytes_pixel==4) */
	    { ULONG *i_ptr = (ULONG *)(image + 4*(y * imagex + x) );
	      ULONG *o_ptr = (ULONG *)(image + 4*(ty * imagex + tx) );
	      QT_SMC_O2I(i_ptr,o_ptr,row_inc);
	    }
	    x += 4; if (x >= imagex) { x = 0; y += 4; }
	  }
	}
	break;
      case 0x40: /* */
      case 0x50:
	{ ULONG cnt,cnt1;
	  ULONG m_cnt,m_cnt1;
	  LONG m_tx,m_ty;
          LONG tx,ty;
	  if (hicode == 0x50) 
	  {  
	     m_cnt1 = 1 + *dptr++; len--; 
	     m_cnt = 2;
	  }
          else 
	  {
	    m_cnt1 = (1 + (code & 0x0f));
	    m_cnt = 2;
	  }
          m_tx = x-(LONG)(4 * m_cnt); m_ty = y; 
	  if (m_tx < 0) {m_tx += imagex; m_ty -= 4;}
	  cnt1 = m_cnt1;
	  while(cnt1--)
	  {
	    cnt = m_cnt; tx = m_tx; ty = m_ty;
	    while(cnt--)
	    { 
	      if ( (x11_bytes_pixel==1) || (map_flag==FALSE) )
	      { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
		UBYTE *o_ptr = (UBYTE *)(image + ty * imagex + tx);
		QT_SMC_O2I(i_ptr,o_ptr,row_inc);
	      } else if (x11_bytes_pixel==2)
	      { USHORT *i_ptr = (USHORT *)(image + 2*(y * imagex + x));
		USHORT *o_ptr = (USHORT *)(image + 2*(ty * imagex + tx));
		QT_SMC_O2I(i_ptr,o_ptr,row_inc);
	      } else 
	      { ULONG *i_ptr = (ULONG *)(image + 4*(y * imagex + x));
		ULONG *o_ptr = (ULONG *)(image + 4*(ty * imagex + tx));
		QT_SMC_O2I(i_ptr,o_ptr,row_inc);
	      }
	      x += 4; if (x >= imagex) { x = 0; y += 4; }
	      tx += 4; if (tx >= imagex) { tx = 0; ty += 4; }
	    } /* end of cnt */
	  } /* end of cnt1 */
	}
	break;

      case 0x60: /* Repeat Data */
      case 0x70:
	{ ULONG ct,cnt;
	  if (hicode == 0x70) {cnt = 1 + *dptr++; len--;}
	  else cnt = 1 + (code & 0x0f);
	  ct = (map_flag)?(map[*dptr++]):(ULONG)(*dptr++); len--;
	  while(cnt--)
	  {
	    if ( (x11_bytes_pixel==1) || (map_flag==FALSE) )
	    { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      UBYTE d = (UBYTE)(ct);
	      QT_SMC_C1(i_ptr,d,row_inc);
	    } else if (x11_bytes_pixel==2)
	    { USHORT *i_ptr = (USHORT *)(image + 2*(y * imagex + x));
	      USHORT d = (UBYTE)(ct);
	      QT_SMC_C1(i_ptr,d,row_inc);
	    } else
	    { ULONG *i_ptr = (ULONG *)(image + 4*(y * imagex + x));
	      QT_SMC_C1(i_ptr,ct,row_inc);
	    }
	    x += 4; if (x >= imagex) { x = 0; y += 4; }
	  }
	}
	break;

      case 0x80: /* 2 colors plus 16 mbits per */
      case 0x90:
        { ULONG cnt = 1 + (code & 0x0f);
	  if (hicode == 0x80)
	  {
            c = (ULONG *)&smc_8[ (smc_8cnt * 2) ];  len -= 2;
	    smc_8cnt++; if (smc_8cnt >= SMC_MAX_CNT) smc_8cnt -= SMC_MAX_CNT;
	    for(i=0;i<2;i++) {c[i]=(map_flag)?map[*dptr++]:(ULONG)(*dptr++);}
	  }
          else { c = (ULONG *)&smc_8[ ((ULONG)(*dptr++) << 1) ]; len--; }
	  while(cnt--)
	  { ULONG msk1,msk0;
	    msk0 = *dptr++; msk1 = *dptr++;  len-= 2;
	    if ( (x11_bytes_pixel==1) || (map_flag==FALSE) )
	    { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      UBYTE c0=(UBYTE)c[0];	UBYTE c1=(UBYTE)c[1];
	      QT_SMC_C2(i_ptr,c0,c1,msk0,row_inc); i_ptr += row_inc;
	      QT_SMC_C2(i_ptr,c0,c1,msk1,row_inc);
	    } else if (x11_bytes_pixel==2)
	    { USHORT *i_ptr = (USHORT *)(image + 2*(y * imagex + x));
	      USHORT c0=(USHORT)c[0];	USHORT c1=(USHORT)c[1];
	      QT_SMC_C2(i_ptr,c0,c1,msk0,row_inc); i_ptr += row_inc;
	      QT_SMC_C2(i_ptr,c0,c1,msk1,row_inc);
	    } else
	    { ULONG *i_ptr = (ULONG *)(image + 4*(y * imagex + x));
	      ULONG c0=(ULONG)c[0];	ULONG c1=(ULONG)c[1];
	      QT_SMC_C2(i_ptr,c0,c1,msk0,row_inc); i_ptr += row_inc;
	      QT_SMC_C2(i_ptr,c0,c1,msk1,row_inc);
	    }
	    x += 4; if (x >= imagex) { x = 0; y += 4; }
          } 
        } 
	break;

      case 0xA0: /* 4 color + 32 mbits */
      case 0xB0:
        { ULONG cnt = 1 + (code & 0xf);
          if (hicode == 0xA0)
          {
            c = (ULONG *)&smc_A[ (smc_Acnt << 2) ]; len -= 4;
            smc_Acnt++; if (smc_Acnt >= SMC_MAX_CNT) smc_Acnt -= SMC_MAX_CNT;
            for(i=0;i<4;i++) {c[i]=(map_flag)?map[*dptr++]:(ULONG)(*dptr++);}
          }
          else { c = (ULONG *)&smc_A[ ((ULONG)(*dptr++) << 2) ]; len--; }
	  while(cnt--)
	  { UBYTE msk0,msk1,msk2,msk3; 
	    msk0 = *dptr++;	msk1 = *dptr++; 
	    msk2 = *dptr++;	msk3 = *dptr++;		len -= 4;
	    if ( (x11_bytes_pixel==1) || (map_flag==FALSE) )
	    { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      QT_SMC_C4(i_ptr,UBYTE,c,msk0,msk1,row_inc); i_ptr += row_inc;
	      QT_SMC_C4(i_ptr,UBYTE,c,msk2,msk3,row_inc);
	    } else if (x11_bytes_pixel==2)
	    { USHORT *i_ptr = (USHORT *)(image + 2*(y * imagex + x));
	      QT_SMC_C4(i_ptr,USHORT,c,msk0,msk1,row_inc); i_ptr += row_inc;
	      QT_SMC_C4(i_ptr,USHORT,c,msk2,msk3,row_inc);
	    } else
	    { ULONG *i_ptr = (ULONG *)(image + 4*(y * imagex + x));
	      QT_SMC_C4(i_ptr,ULONG,c,msk0,msk1,row_inc); i_ptr += row_inc;
	      QT_SMC_C4(i_ptr,ULONG,c,msk2,msk3,row_inc);
	    }
	    x += 4; if (x >= imagex) { x = 0; y += 4; }
          } 
        } 
	break;

      case 0xC0: /* 8 colors + 48 mbits */
      case 0xD0:
        { ULONG cnt = 1 + (code & 0xf);
          if (hicode == 0xC0)
          {
            c = (ULONG *)&smc_C[ (smc_Ccnt << 3) ];   len -= 8;
            smc_Ccnt++; if (smc_Ccnt >= SMC_MAX_CNT) smc_Ccnt -= SMC_MAX_CNT;
            for(i=0;i<8;i++) {c[i]=(map_flag)?map[*dptr++]:(ULONG)(*dptr++);}
          }
          else { c = (ULONG *)&smc_C[ ((ULONG)(*dptr++) << 3) ]; len--; }

	  while(cnt--)
	  { ULONG t,mbits0,mbits1;
	    t = (*dptr++) << 8; t |= *dptr++;
	    mbits0  = (t & 0xfff0) << 8;  mbits1  = (t & 0x000f) << 8;
	    t = (*dptr++) << 8; t |= *dptr++;
	    mbits0 |= (t & 0xfff0) >> 4;  mbits1 |= (t & 0x000f) << 4;
	    t = (*dptr++) << 8; t |= *dptr++;
	    mbits1 |= (t & 0xfff0) << 8;  mbits1 |= (t & 0x000f);
	    len -= 6;
	    if ( (x11_bytes_pixel==1) || (map_flag==FALSE) )
	    { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      QT_SMC_C8(i_ptr,UBYTE,c,mbits0,row_inc); i_ptr += row_inc;
	      QT_SMC_C8(i_ptr,UBYTE,c,mbits1,row_inc);
	    } else if (x11_bytes_pixel==2)
	    { USHORT *i_ptr = (USHORT *)(image + 2*(y * imagex + x));
	      QT_SMC_C8(i_ptr,USHORT,c,mbits0,row_inc); i_ptr += row_inc;
	      QT_SMC_C8(i_ptr,USHORT,c,mbits1,row_inc);
	    } else
	    { ULONG *i_ptr = (ULONG *)(image + 4*(y * imagex + x));
	      QT_SMC_C8(i_ptr,ULONG,c,mbits0,row_inc); i_ptr += row_inc;
	      QT_SMC_C8(i_ptr,ULONG,c,mbits1,row_inc);
	    }
	    x += 4; if (x >= imagex) { x = 0; y += 4; }
          } 
        } 
	break;

      case 0xE0: /* 16 colors */
        { ULONG cnt = 1 + (code & 0x0f);
	  while(cnt--)
	  { 
	    if (map_flag==FALSE)
	    { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      QT_SMC_C16(i_ptr,dptr,UBYTE); i_ptr += row_inc;
	      QT_SMC_C16(i_ptr,dptr,UBYTE); i_ptr += row_inc;
	      QT_SMC_C16(i_ptr,dptr,UBYTE); i_ptr += row_inc;
	      QT_SMC_C16(i_ptr,dptr,UBYTE);
	    } else if (x11_bytes_pixel==1)
	    { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      QT_SMC_C16m(i_ptr,dptr,UBYTE,map,row_inc); i_ptr += row_inc;
	      QT_SMC_C16m(i_ptr,dptr,UBYTE,map,row_inc);
	    } else if (x11_bytes_pixel==2)
	    { USHORT *i_ptr = (USHORT *)(image + 2*(y * imagex + x));
	      QT_SMC_C16m(i_ptr,dptr,USHORT,map,row_inc); i_ptr += row_inc;
	      QT_SMC_C16m(i_ptr,dptr,USHORT,map,row_inc);
	    } else
	    { ULONG *i_ptr = (ULONG *)(image + 4*(y * imagex + x));
	      QT_SMC_C16m(i_ptr,dptr,ULONG,map,row_inc); i_ptr += row_inc;
	      QT_SMC_C16m(i_ptr,dptr,ULONG,map,row_inc);
	    }
	    len -= 16; x += 4; if (x >= imagex) { x = 0; y += 4; }
	  }
	}
	break;

      case 0xF0: /* ??? */
	fprintf(stderr,"SMC opcode %lx is unknown\n",code);
	TheEnd();
	break;
    }
  }
  if (map_flag) return(ACT_DLTA_MAPD);
  else return(ACT_DLTA_NORM);
}

ULONG
QT_Decode_RLE24(image,delta,dsize,tchdr,map,map_flag,imagex,imagey,imaged,
					xs,ys,xe,ye,special,extra)
UBYTE *image;           /* Image Buffer. */
UBYTE *delta;           /* delta data. */
ULONG dsize;            /* delta size */
XA_CHDR *tchdr;		/* color map info */
ULONG *map;             /* used if it's going to be remapped. */
ULONG map_flag;         /* whether or not to use remap_map info. */
ULONG imagex,imagey;    /* Size of image buffer. */
ULONG imaged;           /* Depth of Image. (IFF specific) */
ULONG *xs,*ys;          /* pos of changed area. */
ULONG *xe,*ye;          /* size of changed area. */
ULONG special;          /* Special Info. */
ULONG extra;		/* extra info needed to decode delta */
{
  LONG y,d,lines; /* ULONG min_x,max_x,min_y,max_y; */
  ULONG special_flag,r,g,b;
  UBYTE *dptr;
  XA_CHDR *chdr;

  if (tchdr) {chdr=(tchdr->new_chdr)?(tchdr->new_chdr):(tchdr);} else chdr=0;

  special_flag = special & 0x0001;

  dptr = delta;
  dptr += 4;    /* skip codec size */
  d = (*dptr++) << 8;  d |= *dptr++;   /* read code either 0008 or 0000 */
  if (d == 0x0000) /* NOP */
  { /* There is one more byte 0x00 that I don't read in this case */
    *xs = *ys = *xe = *ye = 0;
    return(ACT_DLTA_NOP);
  }
  y = (*dptr++) << 8; y |= *dptr++;		/* start line */
  dptr += 2;					/* unknown */
  lines = (*dptr++) << 8; lines |= *dptr++;	/* number of lines */
  dptr += 2;					/* unknown */
  while(lines--)				/* loop thru lines */
  {
    ULONG d,xskip,cnt;
    xskip = *dptr++;				/* skip x pixels */
    cnt = *dptr++;				/* RLE code */

    if (special_flag)
    { UBYTE *iptr = (UBYTE *)(image + 3*((y * imagex) + (xskip-1)) );
      while(cnt != 0xff)				/* while not EOL */
      {
        if (cnt == 0x00) { xskip = *dptr++; iptr += 3*(xskip-1); }
        else if (cnt < 0x80)				/* run of data */
          while(cnt--) { r = *dptr++; g = *dptr++; b = *dptr++;
			*iptr++ = (UBYTE)r; *iptr++ = (UBYTE)g; 
					    *iptr++ = (UBYTE)b; }
        else						/* repeat data */
        { cnt = 0x100 - cnt; r = *dptr++; g = *dptr++; b = *dptr++;
          while(cnt--) { *iptr++ = (UBYTE)r; *iptr++ = (UBYTE)g; 
					     *iptr++ = (UBYTE)b; }
        }
        cnt = *dptr++;				/* get new RLE code */
      } /* end of line */
    }
    else if ( (x11_bytes_pixel==1) || (map_flag==FALSE) )
    { UBYTE *iptr = (UBYTE *)(image + (y * imagex) + (xskip-1) );
      while(cnt != 0xff)				/* while not EOL */
      {
        if (cnt == 0x00) { xskip = *dptr++; iptr += (xskip-1); }
        else if (cnt < 0x80)				/* run of data */
          while(cnt--) { r = *dptr++; g = *dptr++; b = *dptr++;
		*iptr++ = (UBYTE)QT_Get_Color24(r,g,b,map_flag,map,chdr); }
        else						/* repeat data */
        { cnt = 0x100 - cnt; r = *dptr++; g = *dptr++; b = *dptr++;
          d = QT_Get_Color24(r,g,b,map_flag,map,chdr);
          while(cnt--) { *iptr++ = (UBYTE)d; }
        }
        cnt = *dptr++;				/* get new RLE code */
      } /* end of line */
    }
    else if (x11_bytes_pixel==4)
    { ULONG *iptr = (ULONG *)(image + 4*((y * imagex)+(xskip-1)) );
      while(cnt != 0xff)				/* while not EOL */
      {
        if (cnt == 0x00) { xskip = *dptr++; iptr += (xskip-1); }
        else if (cnt < 0x80)				/* run of data */
          while(cnt--) { r = *dptr++; g = *dptr++; b = *dptr++;
		*iptr++ = (ULONG)QT_Get_Color24(r,g,b,map_flag,map,chdr); }
        else						/* repeat data */
        { cnt = 0x100 - cnt; r = *dptr++; g = *dptr++; b = *dptr++;
          d = QT_Get_Color24(r,g,b,map_flag,map,chdr);
          while(cnt--) { *iptr++ = (ULONG)d; }
        }
        cnt = *dptr++;				/* get new RLE code */
      } /* end of line */
    }
    else /* if (x11_bytes_pixel==2) */
    { USHORT *iptr = (USHORT *)(image + 2*((y * imagex)+(xskip-1)) );
      while(cnt != 0xff)				/* while not EOL */
      {
        if (cnt == 0x00) { xskip = *dptr++; iptr += (xskip-1); }
        else if (cnt < 0x80)				/* run of data */
          while(cnt--) { r = *dptr++; g = *dptr++; b = *dptr++;
		*iptr++ = (USHORT)QT_Get_Color24(r,g,b,map_flag,map,chdr); }
        else						/* repeat data */
        { cnt = 0x100 - cnt; r = *dptr++; g = *dptr++; b = *dptr++;
          d = QT_Get_Color24(r,g,b,map_flag,map,chdr);
          while(cnt--) { *iptr++ = (USHORT)d; }
        }
        cnt = *dptr++;				/* get new RLE code */
      } /* end of line */
    }
    y++;
  } /* end of lines */
 /* one more zero byte */
 *xs = *ys = 0; *xe = imagex; *ye = imagey;
 if (map_flag==TRUE) return(ACT_DLTA_MAPD);
 else return(ACT_DLTA_NORM);
}

typedef struct
{
  UBYTE r,g,b,pad;
  ULONG clr;
  ULONG g0,g1,g2,g3,v0,v1;
} CVID_Color;

#define QT_CVID_MAX_STRIPS 16
CVID_Color *qt_cvid_maps0[QT_CVID_MAX_STRIPS];
CVID_Color *qt_cvid_maps1[QT_CVID_MAX_STRIPS];
int qt_cvid_vmap0[QT_CVID_MAX_STRIPS];
int qt_cvid_vmap1[QT_CVID_MAX_STRIPS];
int qt_cvid_map_num = 0;



/* POD Move this internal Later */
CVID_Color *qt_cvid_cmap0,*qt_cvid_cmap1;

ULONG
QT_Decode_CVID(image,delta,dsize,tchdr,map,map_flag,imagex,imagey,imaged,
					xs,ys,xe,ye,special,extra)
UBYTE *image;           /* Image Buffer. */
UBYTE *delta;           /* delta data. */
ULONG dsize;            /* delta size */
XA_CHDR *tchdr;		/* color map info */
ULONG *map;             /* used if it's going to be remapped. */
ULONG map_flag;         /* whether or not to use remap_map info. */
ULONG imagex,imagey;    /* Size of image buffer. */
ULONG imaged;           /* Depth of Image. (IFF specific) */
ULONG *xs,*ys;          /* pos of changed area. */
ULONG *xe,*ye;          /* size of changed area. */
ULONG special;          /* Special Info. */
ULONG extra;		/* extra info needed to decode delta */
{
  LONG len,x,y,row_inc;
  UBYTE *dptr;
  ULONG kk,strips,cnum,xsz,ysz;
  ULONG y_top;
  XA_CHDR *chdr;

  *xs = *ys = 0; *xe = imagex; *ye = imagey;
  dptr = delta;
  x = y = 0;
  y_top = 0;
  row_inc = imagex - 4; if (special) row_inc *= 3;
  if (tchdr) {chdr=(tchdr->new_chdr)?(tchdr->new_chdr):(tchdr);} else chdr=0;

  dptr++;	/* skip flag */
  len =(*dptr++)<<16; len |= (*dptr++)<< 8; len |= (*dptr++); /* Read Len */
  if (len != dsize) /* CHECK FOR CORRUPTION - FAIRLY COMMON */
  {
    if (len & 0x01) len++; /* AVIs tend to have a size mismatch */
    if (len != dsize)
    {
     if (xa_verbose==TRUE) 
	 fprintf(stderr,"QT CVID corruption-skipping this frame %lx %lx\n",
								dsize,len);
     return(ACT_DLTA_NOP);
    }
  }
  xsz    = (*dptr++) << 8;  xsz    |= *dptr++;  /* xsize */
  ysz    = (*dptr++) << 8;  ysz    |= *dptr++;  /* ysize */
  strips = (*dptr++) << 8;  strips |= *dptr++;

  if (strips > qt_cvid_map_num)
  { int i;
    if (strips >= QT_CVID_MAX_STRIPS) 
		TheEnd1("CVID: strip ovrflow - contact Author");
    for(i=qt_cvid_map_num; i<strips; i++)
    {
      CVID_Color *cvmap;
      cvmap = (CVID_Color *)malloc( 1040 * sizeof(CVID_Color) );
      if (cvmap==0) TheEnd1("CVID: cvmap0 alloc err");
      qt_cvid_maps0[i] = cvmap;
      cvmap = (CVID_Color *)malloc( 1040 * sizeof(CVID_Color) );
      if (cvmap==0) TheEnd1("CVID: cvmap1 alloc err");
      qt_cvid_maps1[i] = cvmap;
      qt_cvid_vmap0[i] = qt_cvid_vmap1[i] = FALSE;
    }
  }
  qt_cvid_map_num = strips;

  DEBUG_LEVEL1 fprintf(stderr,"CVID <%lx %lx> strips %lx\n",xsz,ysz,strips);

  for(kk=0;kk<strips;kk++)
  {
    ULONG i,top_cid,cid,x0,y0,x1,y1; 
    LONG top_size, csize;

/* POD QUESTION: TREAT 20 and 22 separately or together???? */

    qt_cvid_cmap0 = qt_cvid_maps0[kk];
    qt_cvid_cmap1 = qt_cvid_maps1[kk];
    if (qt_cvid_vmap0[kk]==FALSE) 
    { ULONG idx;
      CVID_Color *src,*dst;
      idx = (kk==0)?(strips-1):(kk-1);
      src = qt_cvid_maps0[idx]; dst = qt_cvid_maps0[kk];
      qt_cvid_vmap0[kk] = TRUE;
      for(i=0;i<1024;i++) dst[i]=src[i];
    }
    if (qt_cvid_vmap1[kk]==FALSE) 
    { ULONG idx;
      CVID_Color *src,*dst;
      idx = (kk==0)?(strips-1):(kk-1);
      src = qt_cvid_maps1[idx]; dst = qt_cvid_maps1[kk];
      qt_cvid_vmap1[kk] = TRUE;
      for(i=0;i<1024;i++) dst[i]=src[i];
    }

    top_cid  = (*dptr++) << 8;   top_cid  |= *dptr++;
    top_size = (*dptr++) << 8;   top_size |= *dptr++;
    y0       = (*dptr++) << 8;   y0       |= *dptr++;
    x0       = (*dptr++) << 8;   x0       |= *dptr++;
    y1       = (*dptr++) << 8;   y1       |= *dptr++;
    x1       = (*dptr++) << 8;   x1       |= *dptr++;

    y_top += y1;
    top_size -= 12;
    x = 0;
    if (x1 != imagex) 
	fprintf(stderr,"CVID Warning x1(%lx) != imagex(%lx)\n",x1,imagex);
    DEBUG_LEVEL1
    {
      fprintf(stderr,"   %ld) %04lx %04lx <%lx,%lx> <%lx,%lx> yt %lx\n",
	    kk,top_cid,top_size,x0,y0,x1,y1,y_top);
    }
    while(top_size > 0)
    {
      cid   = (*dptr++) << 8;  cid   |= *dptr++;
      csize = (*dptr++) << 8;  csize |= *dptr++;
      /* DEBUG_LEVEL1 fprintf(stderr,"        %04lx %04lx\n",cid,csize); */
      top_size -= csize;
      csize -= 4;
      switch(cid)
      {
	case 0x2000: 
	case 0x2200: 
	  { ULONG i;
	    CVID_Color *cvid_map;

	    if (cid == 0x2200)
	    {
  	      cvid_map = qt_cvid_cmap1;
	      for(i=0;i<qt_cvid_map_num;i++) qt_cvid_vmap1[i] = FALSE;
	      qt_cvid_vmap1[kk] = TRUE;
	    }
	    else if (cid == 0x2000) 
	    { 
  	      cvid_map = qt_cvid_cmap0;
	      for(i=0;i<qt_cvid_map_num;i++) qt_cvid_vmap0[i] = FALSE;
	      qt_cvid_vmap0[kk] = TRUE;
	    }

	    cnum = csize / 6;  
	    for(i=0; i<cnum; i++) 
	    { ULONG Y0,Y1,Y2,Y3,U,V;
	      ULONG r0,r1,r2,r3,g0,g1,g2,g3,b0,b1,b2,b3;
	      Y0 = (ULONG)*dptr++; Y1 = (ULONG)*dptr++;  /* luma */
	      Y2 = (ULONG)*dptr++; Y3 = (ULONG)*dptr++;
	      U = (ULONG)(*dptr++); /* chroma */
	      V = (ULONG)(*dptr++);

	      yuv_to_rgb(Y0,U,V,&r0,&g0,&b0);
	      yuv_to_rgb(Y1,U,V,&r1,&g1,&b1);
	      yuv_to_rgb(Y2,U,V,&r2,&g2,&b2);
	      yuv_to_rgb(Y3,U,V,&r3,&g3,&b3);

	      if (special)
	      { register ULONG off;
	        cvid_map[  i].r=r0; cvid_map[  i].g=g0; cvid_map[  i].b=b0; 
	        off = i+256;
	        cvid_map[off].r=r1; cvid_map[off].g=g1; cvid_map[off].b=b1;
	        off += 256;
	        cvid_map[off].r=r2; cvid_map[off].g=g2; cvid_map[off].b=b2;
	        off += 256;
	        cvid_map[off].r=r3; cvid_map[off].g=g3; cvid_map[off].b=b3;
	      }
	      else
	      {
	        cvid_map[i].clr = QT_Get_Color24(r0,g0,b0,map_flag,map,chdr);
	        cvid_map[i+256].clr =QT_Get_Color24(r1,g1,b1,map_flag,map,chdr);
	        cvid_map[i+512].clr =QT_Get_Color24(r2,g2,b2,map_flag,map,chdr);
	        cvid_map[i+768].clr =QT_Get_Color24(r3,g3,b3,map_flag,map,chdr);
	      }
	    } /* end of cnum loop */
	  } /* end of case */
	  break;
	case 0x2100: 
	case 0x2300: 
	  { ULONG k,flag,mask,ci;
	    CVID_Color *cvid_map;

	    if (cid == 0x2300) cvid_map = qt_cvid_cmap1; 
	    else cvid_map = qt_cvid_cmap0;

	    ci = 0;
	    while(csize > 0)
	    {
	      flag  = (*dptr++) << 24;  flag |= (*dptr++) << 16;
	      flag |= (*dptr++) <<  8;  flag |= *dptr++; csize -= 4;

	      mask = 0x80000000;
	      for(k=0;k<32;k++)
	      {
	        if (mask & flag)
		{ ULONG Y0,Y1,Y2,Y3,U,V;
		  ULONG r0,r1,r2,r3,g0,g1,g2,g3,b0,b1,b2,b3;
		  Y0 = (ULONG)*dptr++; Y1 = (ULONG)*dptr++; /* luma */
		  Y2 = (ULONG)*dptr++; Y3 = (ULONG)*dptr++;
		  U = (ULONG)(*dptr++);
		  V = (ULONG)(*dptr++);
		  csize -= 6;
 
		  yuv_to_rgb(Y0,U,V,&r0,&g0,&b0);
		  yuv_to_rgb(Y1,U,V,&r1,&g1,&b1);
		  yuv_to_rgb(Y2,U,V,&r2,&g2,&b2);
		  yuv_to_rgb(Y3,U,V,&r3,&g3,&b3);

		  if (special)
		  { register ULONG off;
		    cvid_map[ ci].r=r0; cvid_map[ ci].g=g0; cvid_map[ ci].b=b0; 
		    off = ci + 256;
		    cvid_map[off].r=r1; cvid_map[off].g=g1; cvid_map[off].b=b1;
		    off += 256;
		    cvid_map[off].r=r2; cvid_map[off].g=g2; cvid_map[off].b=b2;
		    off += 256;
		    cvid_map[off].r=r3; cvid_map[off].g=g3; cvid_map[off].b=b3;
		  }
		  else
		  {
		    cvid_map[ci].clr = 
				QT_Get_Color24(r0,g0,b0,map_flag,map,chdr);
		    cvid_map[ci+256].clr =
				QT_Get_Color24(r1,g1,b1,map_flag,map,chdr);
		    cvid_map[ci+512].clr =
				QT_Get_Color24(r2,g2,b2,map_flag,map,chdr);
		    cvid_map[ci+768].clr =
				QT_Get_Color24(r3,g3,b3,map_flag,map,chdr);
		  }
		} /* end of if update */
	        ci++; mask >>= 1;
	      } /* loop thru flag */
	    } /* while csize > 0 */
	    if (csize != 0) fprintf(stderr,"CVID_21 err sz %04lx\n",csize);
	  } /* end of case */
	  break;
	case 0x3000: 
	{ ULONG flag;

	  while( (csize > 0) && (y < y_top) )
	  { ULONG mask;
	    LONG j;
	    flag  = (*dptr++) << 24;  flag |= (*dptr++) << 16;
	    flag |= (*dptr++) <<  8;  flag |= *dptr++; csize -= 4;

	    mask = 0x80000000; j = 32;
	    for(j=0; j<32; j++)
	    { 
	      if (y >= y_top) break;
	      if (mask & flag) /* update blocks 4 bytes map 0*/
	      { ULONG d0,d1,d2,d3;
	        d0 = *dptr++; d1 = *dptr++; 
		d2 = *dptr++; d3 = *dptr++; csize -= 4;
		QT_CVID_C4(image,x,y,imagex,special,map_flag,
						d0,d1,d2,d3,qt_cvid_cmap0);
	      }
	      else /* 1 byte map 1 */
	      { ULONG d;
		d = *dptr++; csize--;
		QT_CVID_C1(image,x,y,imagex,special,map_flag,d,qt_cvid_cmap1);
	      }
              x += 4; if (x >= imagex) {x = 0; y += 4;}
	      mask >>= 1;
            } /* end of loop through flags */
	    if (csize < 4) { dptr += csize;  csize = 0; } /* POD still ness?? */
	  } /* end of csize loop */
	  if (csize) dptr += csize;
	} /* end of case 3000 */
	break;
	case 0x3200: /* Every Byte is <C1> */ 
	{
	  while( (csize > 0) && (y < y_top) )
	  { ULONG d;
	    d = *dptr++; csize--;
	    QT_CVID_C1(image,x,y,imagex,special,map_flag,d,qt_cvid_cmap1);
            x += 4; if (x >= imagex) {x = 0; y += 4;}
	  }
	  if (csize) dptr += csize;
	} /* end of case 3200 */
	break;
	case 0x3100: 
	case 0x3300: 
	{ ULONG flag;
	  ULONG flag0,flag1,flag2;
 	  flag1 = flag2 = 0;
	  flag0 = 1; /* dtest */

	  while( (csize > 0) && (y < y_top) )
	  { ULONG mcode;
	    LONG j;
	    flag  = (*dptr++) << 24;  flag |= (*dptr++) << 16;
	    flag |= (*dptr++) <<  8;  flag |= *dptr++; csize -= 4;

	    { 
 	      ULONG btotal;
 	      btotal=0;
 	      for(j=30; j>=0; j-=2)
 	      {
		if (y >= y_top) break;
		mcode = (flag >> j) & 0x03;
		switch(mcode)
		{ 
		  case 0x0: 
		  { 
		    flag0 = 1;
		    if (flag1)  /* <C1><SKIP> */
		    { ULONG d = *dptr++; csize--;
		      QT_CVID_C1(image,x,y,imagex,special,map_flag,
							d,qt_cvid_cmap1);
		    } /* else  <SKIP><SKIP> */
		    x += 4; if (x >= imagex) {x = 0; y += 4;}
		    flag1 = 0;
		  }
		  break;
		  case 0x1: 
		  { 
		    flag1 = 1;
		    if ( (flag2) || (flag0) ) /*<SKIP>*/ {flag2=flag0=0;}
		    else /* <C1> */
		    { ULONG d = *dptr++; csize--;
		      QT_CVID_C1(image,x,y,imagex,special,map_flag,
							d,qt_cvid_cmap1);
		    }
		  }
		  break;
		  case 0x2: 
		  { 
		    flag2 = 1;
		    if (flag1) /* <C4><SKIP> */
		    { ULONG d0,d1,d2,d3;
		      flag1 = 0;
		      d0 = *dptr++; d1 = *dptr++;
		      d2 = *dptr++; d3 = *dptr++; csize -= 4;
		      QT_CVID_C4(image,x,y,imagex,special,map_flag,
						d0,d1,d2,d3,qt_cvid_cmap0);
		      x += 4; if (x >= imagex) {x = 0; y += 4;}
		    }
		    else  /* <C1> */
		    { ULONG d = *dptr++; csize--;
		      QT_CVID_C1(image,x,y,imagex,special,map_flag,
							d,qt_cvid_cmap1);
		    } 
		  }
		  break;
		  case 0x3:  /* <C4> */
		  { register ULONG d0,d1,d2,d3;
		    d0 = *dptr++; d1 = *dptr++;
		    d2 = *dptr++; d3 = *dptr++; csize -= 4;
		    QT_CVID_C4(image,x,y,imagex,special,map_flag,
						d0,d1,d2,d3,qt_cvid_cmap0);
		  }
		  break;
		} /* end of switch mcode */
		x += 4; if (x >= imagex) {x = 0; y += 4;}
	      } /* end of j loop */
	    } /* end of stuff */
	  } /* end of csize loop */
	  if (csize) dptr += csize; /* better way of doing this */
	} /* end of case 3000 */
	break;

	default:
	  fprintf(stderr,"CVID unknown cid %08lx\n",cid);
	  TheEnd();
	  break;
      } /* end of switch */
    } /* end of top_size */
  } /* end of strips */
  if (map_flag) return(ACT_DLTA_MAPD);
  else return(ACT_DLTA_NORM);
}

#define QT_CVID_C1_BLK(ip,CAST,d,cv_map,rinc) { register CAST d0,d1; \
 *ip++ = d0 = (CAST)(cv_map[d].clr); *ip++ = d0; d += 256;	\
 *ip++ = d1 = (CAST)(cv_map[d].clr); *ip   = d1; d += 256;	\
  ip += rinc; \
 *ip++ = d0; *ip++ = d0; *ip++ = d1; *ip = d1; ip += rinc;	\
 *ip++ = d0 = (CAST)(cv_map[ d ].clr); *ip++ = d0; d += 256;	\
 *ip++ = d1 = (CAST)(cv_map[ d ].clr); *ip   = d1;		\
  ip += rinc; *ip++ = d0; *ip++ = d0; *ip++ = d1; *ip = d1; }

#define QT_CVID_C4_BLK(ip,CAST,d0,d1,cv_map,rinc) { \
 *ip++ = (CAST)(cv_map[d0].clr); d0 += 256;  \
 *ip++ = (CAST)(cv_map[d0].clr); d0 += 256;  \
 *ip++ = (CAST)(cv_map[d1].clr); d1 += 256;  \
 *ip   = (CAST)(cv_map[d1].clr); d1 += 256; ip += rinc; \
 *ip++ = (CAST)(cv_map[d0].clr); d0 += 256;  \
 *ip++ = (CAST)(cv_map[d0].clr); 		  \
 *ip++ = (CAST)(cv_map[d1].clr); d1 += 256;  \
 *ip   = (CAST)(cv_map[d1].clr); }

void QT_CVID_C1(image,x,y,imagex,special,map_flag,d,cvid_map)
UBYTE *image;
ULONG x,y,imagex,special,map_flag,d;
CVID_Color *cvid_map;
{ ULONG row_inc;
  row_inc = imagex - 3;
  if (special)
  { UBYTE *i_ptr = (UBYTE *)(image + 3*(y * imagex + x) );
    register UBYTE r0,r1,b0,b1,g0,g1;
    row_inc *= 3; row_inc -= 2;
    *i_ptr++ = r0 = (UBYTE)(cvid_map[ d ].r);  
    *i_ptr++ = g0 = (UBYTE)(cvid_map[ d ].g);  
    *i_ptr++ = b0 = (UBYTE)(cvid_map[ d ].b);  
    *i_ptr++ = r0; *i_ptr++ = g0; *i_ptr++ = b0;  d += 256;
    *i_ptr++ = r1 = (UBYTE)(cvid_map[ d ].r);  
    *i_ptr++ = g1 = (UBYTE)(cvid_map[ d ].g);  
    *i_ptr++ = b1 = (UBYTE)(cvid_map[ d ].b);  
    *i_ptr++ = r1; *i_ptr++ = g1; *i_ptr = b1;  d += 256;
     i_ptr += row_inc;
    *i_ptr++ = r0; *i_ptr++ = g0; *i_ptr++ = b0;
    *i_ptr++ = r0; *i_ptr++ = g0; *i_ptr++ = b0;
    *i_ptr++ = r1; *i_ptr++ = g1; *i_ptr++ = b1;
    *i_ptr++ = r1; *i_ptr++ = g1; *i_ptr   = b1;
     i_ptr += row_inc;
    *i_ptr++ = r0 = (UBYTE)(cvid_map[ d ].r);  
    *i_ptr++ = g0 = (UBYTE)(cvid_map[ d ].g);  
    *i_ptr++ = b0 = (UBYTE)(cvid_map[ d ].b);  
    *i_ptr++ = r0; *i_ptr++ = g0; *i_ptr++ = b0;  d += 256;
    *i_ptr++ = r1 = (UBYTE)(cvid_map[ d ].r);  
    *i_ptr++ = g1 = (UBYTE)(cvid_map[ d ].g);  
    *i_ptr++ = b1 = (UBYTE)(cvid_map[ d ].b);  
    *i_ptr++ = r1; *i_ptr++ = g1; *i_ptr = b1;
     i_ptr += row_inc;
    *i_ptr++ = r0; *i_ptr++ = g0; *i_ptr++ = b0;
    *i_ptr++ = r0; *i_ptr++ = g0; *i_ptr++ = b0;
    *i_ptr++ = r1; *i_ptr++ = g1; *i_ptr++ = b1;
    *i_ptr++ = r1; *i_ptr++ = g1; *i_ptr   = b1;
    return;
  }
  if ( (x11_bytes_pixel==1) || (map_flag == FALSE) )
  { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
    QT_CVID_C1_BLK(i_ptr,UBYTE,d,cvid_map,row_inc);
  }
  else if (x11_bytes_pixel==2)
  { USHORT *i_ptr = (USHORT *)(image + ((y*imagex+x)<<1) );
    QT_CVID_C1_BLK(i_ptr,USHORT,d,cvid_map,row_inc);
  }
  else /* if (x11_bytes_pixel==4) */
  { ULONG *i_ptr = (ULONG *)(image + ((y*imagex+x)<<2) );
    QT_CVID_C1_BLK(i_ptr,ULONG,d,cvid_map,row_inc);
  }
}

void QT_CVID_C4(image,x,y,imagex,special,map_flag,d0,d1,d2,d3,cvid_map)
UBYTE *image;
ULONG x,y,imagex,special,map_flag;
ULONG d0,d1,d2,d3;
CVID_Color *cvid_map;
{ ULONG row_inc;
  row_inc = imagex - 3;
  if (special)
  { UBYTE *i_ptr = (UBYTE *)(image + 3*(y * imagex + x) );
    row_inc *= 3; row_inc -= 2;
    *i_ptr++ = (UBYTE)(cvid_map[d0].r);  *i_ptr++ = (UBYTE)(cvid_map[d0].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d0].b); d0 += 256;  
    *i_ptr++ = (UBYTE)(cvid_map[d0].r);  *i_ptr++ = (UBYTE)(cvid_map[d0].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d0].b); d0 += 256;  
    *i_ptr++ = (UBYTE)(cvid_map[d1].r);  *i_ptr++ = (UBYTE)(cvid_map[d1].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d1].b); d1 += 256;  
    *i_ptr++ = (UBYTE)(cvid_map[d1].r);  *i_ptr++ = (UBYTE)(cvid_map[d1].g);  
    *i_ptr   = (UBYTE)(cvid_map[d1].b); d1 += 256;  i_ptr += row_inc;
    *i_ptr++ = (UBYTE)(cvid_map[d0].r);  *i_ptr++ = (UBYTE)(cvid_map[d0].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d0].b); d0 += 256;  
    *i_ptr++ = (UBYTE)(cvid_map[d0].r);  *i_ptr++ = (UBYTE)(cvid_map[d0].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d0].b);
    *i_ptr++ = (UBYTE)(cvid_map[d1].r);  *i_ptr++ = (UBYTE)(cvid_map[d1].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d1].b); d1 += 256;  
    *i_ptr++ = (UBYTE)(cvid_map[d1].r);  *i_ptr++ = (UBYTE)(cvid_map[d1].g);  
    *i_ptr   = (UBYTE)(cvid_map[d1].b); i_ptr += row_inc;
    *i_ptr++ = (UBYTE)(cvid_map[d2].r);  *i_ptr++ = (UBYTE)(cvid_map[d2].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d2].b); d2 += 256;  
    *i_ptr++ = (UBYTE)(cvid_map[d2].r);  *i_ptr++ = (UBYTE)(cvid_map[d2].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d2].b); d2 += 256;  
    *i_ptr++ = (UBYTE)(cvid_map[d3].r);  *i_ptr++ = (UBYTE)(cvid_map[d3].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d3].b); d3 += 256;  
    *i_ptr++ = (UBYTE)(cvid_map[d3].r);  *i_ptr++ = (UBYTE)(cvid_map[d3].g);  
    *i_ptr   = (UBYTE)(cvid_map[d3].b); d3 += 256;  i_ptr += row_inc;
    *i_ptr++ = (UBYTE)(cvid_map[d2].r);  *i_ptr++ = (UBYTE)(cvid_map[d2].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d2].b); d2 += 256;  
    *i_ptr++ = (UBYTE)(cvid_map[d2].r);  *i_ptr++ = (UBYTE)(cvid_map[d2].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d2].b);
    *i_ptr++ = (UBYTE)(cvid_map[d3].r);  *i_ptr++ = (UBYTE)(cvid_map[d3].g);  
    *i_ptr++ = (UBYTE)(cvid_map[d3].b); d3 += 256;  
    *i_ptr++ = (UBYTE)(cvid_map[d3].r);  *i_ptr++ = (UBYTE)(cvid_map[d3].g);  
    *i_ptr   = (UBYTE)(cvid_map[d3].b);
    return;
  }
  if ( (x11_bytes_pixel==1) || (map_flag == FALSE) )
  { UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
    QT_CVID_C4_BLK(i_ptr,UBYTE,d0,d1,cvid_map,row_inc);
    i_ptr += row_inc;
    QT_CVID_C4_BLK(i_ptr,UBYTE,d2,d3,cvid_map,row_inc);
  }
  else if (x11_bytes_pixel==2)
  { USHORT *i_ptr = (USHORT *)(image + ((y*imagex+x)<<1) );
    QT_CVID_C4_BLK(i_ptr,USHORT,d0,d1,cvid_map,row_inc);
    i_ptr += row_inc;
    QT_CVID_C4_BLK(i_ptr,USHORT,d2,d3,cvid_map,row_inc);
  }
  else /* if (x11_bytes_pixel==4) */
  { ULONG *i_ptr = (ULONG *)(image + ((y*imagex+x)<<2) );
    QT_CVID_C4_BLK(i_ptr,ULONG,d0,d1,cvid_map,row_inc);
    i_ptr += row_inc;
    QT_CVID_C4_BLK(i_ptr,ULONG,d2,d3,cvid_map,row_inc);
  }
}

void yuv_to_rgb(y,u,v,ir,ig,ib)
ULONG y,u,v,*ir,*ig,*ib;
{
  LONG r,g,b;
  y <<= 14;
  r = ( (LONG)(y) + QT_VR_tab[v]);
  g = ( (LONG)(y) + QT_UG_tab[u] + QT_VG_tab[v]);
  b = ( (LONG)(y) + QT_UB_tab[u]);
  if (r<0) r = 0; if (g<0) g = 0; if (b<0) b = 0;
  r >>= 14; g >>= 14; b >>= 14;
  if (r > 255) r = 255; if (g > 255) g = 255; if (b > 255) b = 255;
  *ir = (ULONG)r; *ig = (ULONG)g; *ib = (ULONG)b;
}
  

/*
 *      R = Y               + 1.40200 * V
 *      G = Y - 0.34414 * U - 0.71414 * V
 *      B = Y + 1.77200 * U
 */
void QT_Gen_YUV_Tabs()
{
  LONG i;

  if (QT_UB_tab==0)
  {
    QT_UB_tab = (LONG *)malloc( 256 * sizeof(LONG) );
    QT_VR_tab = (LONG *)malloc( 256 * sizeof(LONG) );
    QT_UG_tab = (LONG *)malloc( 256 * sizeof(LONG) );
    QT_VG_tab = (LONG *)malloc( 256 * sizeof(LONG) );
    if (  (QT_UB_tab==0) || (QT_VR_tab==0)
	||(QT_UG_tab==0)||(QT_VG_tab==0) ) TheEnd1("CVID: yuv tab malloc err");
  }

  for(i=0;i<256;i++)
  {
    float x = (float)(i);
    if (i & 0x80) x -= 256.0;
    x *= 16384.0; /* 1<<14) */
    QT_UB_tab[i] = (LONG)( 1.77200 * x);
    QT_VR_tab[i] = (LONG)( 1.40200 * x);
    QT_UG_tab[i] = (LONG)(-0.34414 * x);
    QT_VG_tab[i] = (LONG)(-0.71414 * x);
  }
}

char *XA_rindex(s,c)
char *s,c;
{
  int len = strlen(s);
  char *p = s + len;
  while(len >= 0)
  {
    if (*p == c) return(p);
    else {p--; len--;}
  }
  return( (char *)(0) );
}
