/*
 * avi.c
 *
 */

#include "avi.h" 


LONG Is_AVI_File();
ULONG AVI_Read_File();
void AVI_Print_ID();
AVI_FRAME *AVI_Add_Frame();
void AVI_Free_Frame_List();
ULONG RIFF_Read_AVIH();
ULONG RIFF_Read_STRH();
ULONG RIFF_Read_VIDS();
ULONG AVI_Get_Color();
void AVI_Get_RGBColor();

/* CODEC ROUTINES */
ULONG AVI_Decode_RLE8();
ULONG AVI_Decode_CRAM();
ULONG AVI_Decode_CRAM16();
ULONG AVI_Decode_RGB();

extern ULONG QT_Decode_CVID();
extern void QT_Gen_YUV_Tabs();

void CMAP_Cache_Clear();
void CMAP_Cache_Init();

XA_ACTION *ACT_Get_Action();
XA_CHDR *ACT_Get_CMAP();
XA_CHDR *CMAP_Create_332();
XA_CHDR *CMAP_Create_422();
XA_CHDR *CMAP_Create_Gray();
void ACT_Add_CHDR_To_Action();
void ACT_Setup_Mapped();
void ACT_Get_CCMAP();
XA_CHDR *CMAP_Create_CHDR_From_True();
ULONG CMAP_Find_Closest();
UBYTE *UTIL_RGB_To_FS_Map();
UBYTE *UTIL_RGB_To_Map();

ULONG UTIL_Get_MSB_Long();
ULONG UTIL_Get_LSB_Long();
ULONG UTIL_Get_LSB_Short();

extern ULONG cmap_color_func;
ULONG avi_cmap_cnt;
ULONG avi_cf2_rmap[256],avi_cf2_gmap[256],avi_cf2_bmap[256];

#define AVI_MAX_COLORS  256
ColorReg avi_cmap[AVI_MAX_COLORS];
XA_CHDR *avi_chdr;

AVI_HDR avi_hdr;
AVI_STREAM_HDR strh_hdr;
VIDS_HDR vids_hdr;

ULONG avi_frame_cnt;
ULONG avi_imagex,avi_imagey,avi_imagec;
ULONG avi_depth,avi_compression;
ULONG avi_time;
UBYTE *avi_pic;
ULONG avi_pic_size;
ULONG avi_max_fsize;

AVI_FRAME *avi_frame_start,*avi_frame_cur;


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

AVI_FRAME *AVI_Add_Frame(time,act)
ULONG time;
XA_ACTION *act;
{
  AVI_FRAME *fframe;
 
  fframe = (AVI_FRAME *) malloc(sizeof(AVI_FRAME));
  if (fframe == 0) TheEnd1("AVI_Add_Frame: malloc err");
 
  fframe->time = time;
  fframe->act = act;
  fframe->next = 0;
 
  if (avi_frame_start == 0) avi_frame_start = fframe;
  else avi_frame_cur->next = fframe;
 
  avi_frame_cur = fframe;
  avi_frame_cnt++;
  return(fframe);
}

void AVI_Free_Frame_List(fframes)
AVI_FRAME *fframes;
{
  AVI_FRAME *ftmp;
  while(fframes != 0)
  {
    ftmp = fframes;
    fframes = fframes->next;
    FREE(ftmp,0x2000);
  }
}

/*
 *
 */
LONG Is_AVI_File(filename)
char *filename;
{
  FILE *fin;
  ULONG data;

  if ( (fin=fopen(filename,XA_OPEN_MODE)) == 0) return(XA_NOFILE);
  data = UTIL_Get_MSB_Long(fin);  /* read past size */
  fclose(fin);
  if ( data == RIFF_RIFF ) return(TRUE);
  return(FALSE);
}

ULONG AVI_Read_File(fname,anim_hdr)
char *fname;
XA_ANIM_HDR *anim_hdr;
{
  FILE *fin;
  LONG i,ret;
  XA_ACTION *act;
 
  if ( (fin=fopen(fname,XA_OPEN_MODE)) == 0)
  {
    fprintf(stderr,"can't open AVI File %s for reading\n",fname);
    return(FALSE);
  }
 
  avi_pic = 0;
  avi_pic_size = 0;
  avi_chdr = 0;
  avi_frame_cnt = 0;
  avi_frame_start = 0;
  avi_frame_cur = 0;
  avi_time = 17; /* default */
  avi_max_fsize = 0;
  avi_imagex = avi_imagey = avi_imagec = 0;
  avi_compression = 0;

  while( !feof(fin) )
  {
    ULONG d,ck_id,ck_size;

    ck_id = UTIL_Get_MSB_Long(fin);
    ck_size = UTIL_Get_LSB_Long(fin);
DEBUG_LEVEL2 
{
  fprintf(stderr,"AVI cid ");
  AVI_Print_ID(stderr,ck_id);
  fprintf(stderr,"  cksize %08lx\n",ck_size);
}
    switch(ck_id)
    {
	case RIFF_RIFF:
		d = UTIL_Get_MSB_Long(fin);
		DEBUG_LEVEL2 
		{
			fprintf(stderr,"  RIFF form type ");
			AVI_Print_ID(stderr,d);
			fprintf(stderr,"\n");
		}
                break;
	case RIFF_LIST:
		d = UTIL_Get_MSB_Long(fin);
		DEBUG_LEVEL2 
		{
			fprintf(stderr,"  List type ");
			AVI_Print_ID(stderr,d);
			fprintf(stderr,"\n");
		}
		break;
 
	case RIFF_avih:
		DEBUG_LEVEL2 fprintf(stderr,"  AVI_HDR:\n");
                if (RIFF_Read_AVIH(fin,ck_size,&avi_hdr)==FALSE) return(FALSE);
                break;
 
	case RIFF_strh:
		DEBUG_LEVEL2 fprintf(stderr,"  STRH HDR:\n");
                if (RIFF_Read_STRH(fin,ck_size,&strh_hdr)==FALSE) return(FALSE);
                break;
 
	case RIFF_strf:
		DEBUG_LEVEL2 fprintf(stderr,"  STRF HDR:\n");
                switch(strh_hdr.fcc_type)
                {
                 case RIFF_vids:
                        if (RIFF_Read_VIDS(fin,ck_size,&vids_hdr)==FALSE)
				return(FALSE);
                        break;
                 case RIFF_auds:
                        if (ck_size & 0x01) ck_size++;
                        for(i=0; i<ck_size; i++) d = getc(fin);
                        break;
                 default:
                        fprintf(stderr,"unknown fcc_type at strf");
			return(FALSE);
                        break;
                }
                break;
 
        case RIFF_00iv:
        case RIFF_00vc:
        case RIFF_00db:
        case RIFF_00dc:
        case RIFF_00dx:
        case RIFF_00xx:
	  {
	    ACT_DLTA_HDR *dlta_hdr;
	    ULONG d;
	    if (ck_size & 0x01) ck_size++;
	    if (ck_size == 0) break;
	    act = ACT_Get_Action(anim_hdr,ACT_DELTA);

	    if (xa_file_flag==TRUE)
	    {
	      dlta_hdr = (ACT_DLTA_HDR *) malloc(sizeof(ACT_DLTA_HDR));
	      if (dlta_hdr == 0) TheEnd1("AVI 00dc: malloc failed");
	      act->data = (UBYTE *)dlta_hdr;
	      dlta_hdr->flags = ACT_SNGL_BUF;
	      dlta_hdr->fpos  = ftell(fin);
	      dlta_hdr->fsize = ck_size;
	      fseek(fin,ck_size,1); /* move past this chunk */
	      if (ck_size > avi_max_fsize) avi_max_fsize = ck_size;
	    }
	    else
	    {
	      d = ck_size + (sizeof(ACT_DLTA_HDR));
	      dlta_hdr = (ACT_DLTA_HDR *) malloc( d );
	      if (dlta_hdr == 0) TheEnd1("AVI 00dc: malloc failed");
	      act->data = (UBYTE *)dlta_hdr;
	      dlta_hdr->flags = ACT_SNGL_BUF | DLTA_DATA;
	      dlta_hdr->fpos = 0; dlta_hdr->fsize = ck_size;
	      ret = fread( dlta_hdr->data, ck_size, 1, fin);
	      if (ret != 1) 
		{fprintf(stderr,"AVI 00dc: read failed\n"); return(FALSE);}
	    }

	    AVI_Add_Frame( avi_time ,act);
	    dlta_hdr->xpos = dlta_hdr->ypos = 0;
	    dlta_hdr->xsize = avi_imagex;
	    dlta_hdr->ysize = avi_imagey;
	    dlta_hdr->special = 0;
	    dlta_hdr->extra = 0;
	    switch(avi_compression)
	    {
	      case RIFF_RLE8:
		if (avi_depth == 8) dlta_hdr->delta = AVI_Decode_RLE8;
		else goto AVI_UNSUPPORTED;
		break;
	      case RIFF_MSVC:
	      case RIFF_CRAM:
		if (avi_depth == 8) dlta_hdr->delta = AVI_Decode_CRAM;
		else if (avi_depth ==16) dlta_hdr->delta = AVI_Decode_CRAM16;
		else goto AVI_UNSUPPORTED;
		break;
	      case RIFF_RGB:
		if (avi_depth == 8) dlta_hdr->delta = AVI_Decode_RGB;
		else goto AVI_UNSUPPORTED;
		break;
	      case RIFF_CVID:
		if (avi_depth == 24) dlta_hdr->delta = QT_Decode_CVID;
		else goto AVI_UNSUPPORTED;
		break;
	      default:
		AVI_UNSUPPORTED:
		fprintf(stderr,"AVI: unsupported comp ");
		AVI_Print_ID(stderr,avi_compression);
		fprintf(stderr," with depth %ld\n",avi_depth);
		act->type = ACT_NOP;
		return(FALSE);
		break;
	    }
	    if ( (xa_buffer_flag == TRUE) && (act->type != ACT_NOP) )
	    {
	      ULONG xpos,ypos,xsize,ysize,dlta_flag;

	      if ( (cmap_true_map_flag==FALSE) || (avi_depth <= 8) )
	      {
		ULONG map_flag = 
			(x11_display_type & XA_X11_TRUE)?(TRUE):(FALSE);
	        dlta_flag = dlta_hdr->delta(avi_pic,dlta_hdr->data,
			dlta_hdr->fsize,0,avi_chdr->map,map_flag,
			avi_imagex,avi_imagey,8,&xpos,&ypos,&xsize,&ysize,0,0);
		if (!(dlta_flag & ACT_DLTA_MAPD)) map_flag = FALSE;
		xsize -= xpos; ysize -= ypos;
	        FREE(dlta_hdr,0x3000); act->data = 0;
	        if (dlta_flag & ACT_DLTA_NOP) act->type = ACT_NOP;
	        else ACT_Setup_Mapped(act,avi_pic,avi_chdr,xpos,ypos,xsize,
		    ysize,avi_imagex,avi_imagey,FALSE,0, FALSE,TRUE,map_flag);
	        ACT_Add_CHDR_To_Action(act,avi_chdr);
	      } 
	      else /* decode as RGB triplets and then convert to mapped image */
	      {
		UBYTE *tpic;
		dlta_flag = dlta_hdr->delta(avi_pic,dlta_hdr->data,
			dlta_hdr->fsize,0,0,FALSE,
			avi_imagex,avi_imagey,8,&xpos,&ypos,&xsize,&ysize,1,0);
		xpos = ypos = 0; xsize = avi_imagex; ysize = avi_imagey;
		FREE(dlta_hdr,0x9999); act->data = 0; dlta_hdr = 0;
		if (dlta_flag & ACT_DLTA_NOP) act->type = ACT_NOP;
		else
		{
		  if (    (cmap_true_to_all == TRUE)
		      || ((cmap_true_to_1st == TRUE) && (avi_chdr == 0) )
		     )  avi_chdr = CMAP_Create_CHDR_From_True(avi_pic,8,8,8,
				avi_imagex,avi_imagey,avi_cmap,&avi_imagec);
		  else if ( (cmap_true_to_332 == TRUE) && (avi_chdr == 0) )
			avi_chdr = CMAP_Create_332(avi_cmap,&avi_imagec);
		  else if ( (cmap_true_to_gray == TRUE) && (avi_chdr == 0) )
			avi_chdr = CMAP_Create_Gray(avi_cmap,&avi_imagec);
		 
		  if (cmap_dither_type == CMAP_DITHER_FLOYD)
			tpic = UTIL_RGB_To_FS_Map(0,avi_pic,avi_chdr,
						avi_imagex,avi_imagey,FALSE);
		  else tpic = UTIL_RGB_To_Map(0,avi_pic,avi_chdr,
						avi_imagex,avi_imagey,FALSE);
		  ACT_Setup_Mapped(act,tpic,avi_chdr,xpos,ypos,xsize,ysize,
			avi_imagex,avi_imagey,FALSE,0,TRUE,TRUE,FALSE);
		  ACT_Add_CHDR_To_Action(act,avi_chdr);
		} /* end of not NOP */
	      } /* end of true_map */
	    } /* end of buffer */
	    else /* not buffered */ACT_Add_CHDR_To_Action(act,avi_chdr);
      {
        /* Also make sure not TRUE, is 332 and special case file_flag */
        if ( (cmap_color_func != 0) && (avi_cmap_cnt == 0)
            && (avi_depth > 8) && (!(x11_display_type & XA_X11_TRUE)) )
        {
            ULONG xpos,ypos,xsize,ysize,dlta_flag,psize;
            UBYTE *cbuf,*data;

          psize = avi_imagex * avi_imagey;
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
          dlta_flag = dlta_hdr->delta(cbuf,data,dlta_hdr->fsize,0,
                0,FALSE,avi_imagex,avi_imagey,8,&xpos,&ypos,&xsize,&ysize,1,0);
          if (xa_file_flag == TRUE) { free(data); data = 0; }
 
	switch(cmap_color_func)
        {
	  case 4:
	  {
            avi_chdr = CMAP_Create_CHDR_From_True(cbuf,8,8,8,
                              avi_imagex,avi_imagey,avi_cmap,&avi_imagec);
/*POD NOTE: work on this */
	    DEBUG_LEVEL1 fprintf(stderr,"CF4: csize = %ld\n",avi_chdr->csize);
	    if (avi_chdr->csize > 128) avi_cmap_cnt = 1;
            if (cbuf) free(cbuf); cbuf = 0;

	  }
	  break;
       } /* end switch */
     } /* first time through */
        ACT_Add_CHDR_To_Action(act,avi_chdr);
      } /* not bufferd */

	  }
	  break;
 
        case RIFF_idx1:
        case RIFF_vedt:
        case RIFF_strd:
        case RIFF_strl:
        case RIFF_hdrl:
        case RIFF_vids:
        case RIFF_JUNK:
        case RIFF_01wb:
	case RIFF_DISP:
	case RIFF_ISBJ:
	case RIFF_00AM:
                if (ck_size & 0x01) ck_size++;
                for(i=0; i<ck_size; i++) d = getc(fin);
                break;
 
        default:
		if ( !feof(fin) )
		{
			AVI_Print_ID(stderr,ck_id);
                	fprintf(stderr,"  chunk unknown\n");
                	fseek(fin,0,2); /* goto end of file */
		}
 
      } /* end of ck_id switch */
    } /* while not exitflag */

  if (avi_pic != 0) { FREE(avi_pic,0x3000); avi_pic=0; }
  fclose(fin);

  if (xa_verbose) 
  {
    fprintf(stderr,"AVI %ldx%ldx%ld frames %ld codec ",
			avi_imagex,avi_imagey,avi_imagec,avi_frame_cnt);
    AVI_Print_ID(stderr,avi_compression);
    fprintf(stderr," depth=%ld\n",avi_depth);
  }
  if (avi_frame_cnt == 0)
  { 
    fprintf(stderr,"AVI: No supported video frames exist in this file.\n");
    return(FALSE);
  }

  anim_hdr->frame_lst = (XA_FRAME *)
				malloc( sizeof(XA_FRAME) * (avi_frame_cnt+1));
  if (anim_hdr->frame_lst == NULL) TheEnd1("AVI_Read_File: frame malloc err");

  avi_frame_cur = avi_frame_start;
  i = 0;
  while(avi_frame_cur != 0)
  {
    if (i > avi_frame_cnt)
    {
      fprintf(stderr,"AVI_Read_Anim: frame inconsistency %ld %ld\n",
                i,avi_frame_cnt);
      break;
    }
    anim_hdr->frame_lst[i].time = avi_frame_cur->time;
    anim_hdr->frame_lst[i].act = avi_frame_cur->act;
    avi_frame_cur = avi_frame_cur->next;
    i++;
  }
  anim_hdr->imagex = avi_imagex;
  anim_hdr->imagey = avi_imagey;
  anim_hdr->imagec = avi_imagec;
  anim_hdr->imaged = 8; /* nop */
  anim_hdr->frame_lst[i].time = 0;
  anim_hdr->frame_lst[i].act  = 0;
  anim_hdr->loop_frame = 0;
  if (xa_buffer_flag == FALSE) anim_hdr->anim_flags |= ANIM_SNG_BUF;
  if (xa_file_flag == TRUE) anim_hdr->anim_flags |= ANIM_USE_FILE;
  anim_hdr->max_fsize = avi_max_fsize;
  anim_hdr->fname = anim_hdr->name;
  if (i > 0) anim_hdr->last_frame = i - 1;
  else i = 0;
  AVI_Free_Frame_List(avi_frame_start);
  return(TRUE);
} /* end of read file */

ULONG RIFF_Read_AVIH(fin,size,avi_hdr)
FILE *fin;
ULONG size;
AVI_HDR *avi_hdr;
{
  if (size != 0x38)
  {
    fprintf(stderr,"avih: size not 56 size=%ld\n",size);
    return(FALSE);
  }
 
  avi_hdr->us_frame     = UTIL_Get_LSB_Long(fin);
  avi_hdr->max_bps      = UTIL_Get_LSB_Long(fin);
  avi_hdr->pad_gran     = UTIL_Get_LSB_Long(fin);
  avi_hdr->flags        = UTIL_Get_LSB_Long(fin);
  avi_hdr->tot_frames   = UTIL_Get_LSB_Long(fin);
  avi_hdr->init_frames  = UTIL_Get_LSB_Long(fin);
  avi_hdr->streams      = UTIL_Get_LSB_Long(fin);
  avi_hdr->sug_bsize    = UTIL_Get_LSB_Long(fin);
  avi_hdr->width        = UTIL_Get_LSB_Long(fin);
  avi_hdr->height       = UTIL_Get_LSB_Long(fin);
  avi_hdr->scale        = UTIL_Get_LSB_Long(fin);
  avi_hdr->rate         = UTIL_Get_LSB_Long(fin);
  avi_hdr->start        = UTIL_Get_LSB_Long(fin);
  avi_hdr->length       = UTIL_Get_LSB_Long(fin);

  avi_time = XA_GET_TIME( (avi_hdr->us_frame/1000) );
  return(TRUE);
}

ULONG RIFF_Read_STRH(fin,size,strh_hdr)
FILE *fin;
ULONG size;
AVI_STREAM_HDR *strh_hdr;
{
  ULONG d,tsize;
 
  if (size < 0x24) 
	{fprintf(stderr,"strh: size < 36 size = %ld\n",size); return(FALSE);}
 
  strh_hdr->fcc_type    = UTIL_Get_MSB_Long(fin);
  strh_hdr->fcc_handler = UTIL_Get_MSB_Long(fin);
  strh_hdr->flags       = UTIL_Get_LSB_Long(fin);
  strh_hdr->priority    = UTIL_Get_LSB_Long(fin);
  strh_hdr->init_frames = UTIL_Get_LSB_Long(fin);
  strh_hdr->scale       = UTIL_Get_LSB_Long(fin);
  strh_hdr->rate        = UTIL_Get_LSB_Long(fin);
  strh_hdr->start       = UTIL_Get_LSB_Long(fin);
  strh_hdr->length      = UTIL_Get_LSB_Long(fin);
  strh_hdr->sug_bsize   = UTIL_Get_LSB_Long(fin);
  strh_hdr->quality     = UTIL_Get_LSB_Long(fin);
  strh_hdr->samp_size   = UTIL_Get_LSB_Long(fin);
 
  tsize = 48; if (size & 0x01) size++;
  while(tsize < size) { d = getc(fin); tsize++; }
 
DEBUG_LEVEL1 fprintf(stderr,"AVI TEST handler = %08lx",strh_hdr->fcc_handler);
  return(TRUE);
}

ULONG RIFF_Read_VIDS(fin,size,vids_hdr)
FILE *fin;
ULONG size;
VIDS_HDR *vids_hdr;
{
  ULONG d,i,tsize;
 
  vids_hdr->size        = UTIL_Get_LSB_Long(fin);
  vids_hdr->width       = UTIL_Get_LSB_Long(fin);
  vids_hdr->height      = UTIL_Get_LSB_Long(fin);
  vids_hdr->planes      = UTIL_Get_LSB_Short(fin);
  vids_hdr->bit_cnt     = UTIL_Get_LSB_Short(fin);
  vids_hdr->compression = UTIL_Get_MSB_Long(fin);
  vids_hdr->image_size  = UTIL_Get_LSB_Long(fin);
  vids_hdr->xpels_meter = UTIL_Get_LSB_Long(fin);
  vids_hdr->ypels_meter = UTIL_Get_LSB_Long(fin);
  vids_hdr->num_colors  = UTIL_Get_LSB_Long(fin);
  vids_hdr->imp_colors  = UTIL_Get_LSB_Long(fin);


  avi_compression = vids_hdr->compression;
DEBUG_LEVEL1 fprintf(stderr,"VIDS compression = %08lx\n",avi_compression);
  avi_depth = vids_hdr->bit_cnt;
  avi_imagex = vids_hdr->width;
  avi_imagey = vids_hdr->height;
  avi_imagec = vids_hdr->num_colors;
  if ( (avi_imagec==0) && (avi_depth <= 8) ) avi_imagec = (1 << avi_depth);
  vids_hdr->num_colors = avi_imagec; /* re-update struct */

  switch(avi_compression)
  {
    case RIFF_rgb:  avi_compression = RIFF_RGB;  break;
    case RIFF_rle8: avi_compression = RIFF_RLE8; break;
    case RIFF_rle4: avi_compression = RIFF_RLE4; break;
    case RIFF_none: avi_compression = RIFF_NONE; break;
    case RIFF_pack: avi_compression = RIFF_PACK; break;
    case RIFF_tran: avi_compression = RIFF_TRAN; break;
    case RIFF_ccc : avi_compression = RIFF_CCC;  break;
    case RIFF_jpeg: avi_compression = RIFF_JPEG; break;
    case RIFF_rt21: avi_compression = RIFF_RT21;  break;
    case RIFF_CVID:
	QT_Gen_YUV_Tabs(); /* gen YUV tables and fall through */
    case RIFF_MSVC:
    case RIFF_CRAM: /* need to be multiple of 4 */
	avi_imagex = 4 * ((avi_imagex + 3)/4);
	avi_imagey = 4 * ((avi_imagey + 3)/4);
	break;
  }

  if (avi_depth <= 8)
  {
    for(i=0; i < avi_imagec; i++)
    {
      avi_cmap[i].blue  =  ( getc(fin) ) & 0xff;
      avi_cmap[i].green =  ( getc(fin) ) & 0xff;
      avi_cmap[i].red   =  ( getc(fin) ) & 0xff;
      d = getc(fin); /* pad */
    }
    avi_chdr = ACT_Get_CMAP(avi_cmap,avi_imagec,0,avi_imagec,0,8,8,8);
  }
  else if (   (cmap_true_map_flag == FALSE) /* depth 16 and not true_map */
           || (xa_buffer_flag == FALSE) )
  {
     if (cmap_true_to_332 == TRUE)
             avi_chdr = CMAP_Create_332(avi_cmap,&avi_imagec);
     else    avi_chdr = CMAP_Create_Gray(avi_cmap,&avi_imagec);
  }
  if ( (avi_pic==0) && (xa_buffer_flag == TRUE))
  {
    avi_pic_size = avi_imagex * avi_imagey;
    if ( (cmap_true_map_flag == TRUE) && (avi_depth == 16) )
		avi_pic = (UBYTE *) malloc( 3 * avi_pic_size );
    else avi_pic = (UBYTE *) malloc( XA_PIC_SIZE(avi_pic_size) );
    if (avi_pic == 0) TheEnd1("AVI_Buffer_Action: malloc failed");
  }

  /* Read rest of header */
  tsize = vids_hdr->num_colors * 4 + 40; if (size & 0x01) size++;
  while(tsize < size) { d = getc(fin); tsize++; }
  return(TRUE);
}

/*
 * Routine to Decode an AVI CRAM chunk
 */

#define AVI_CRAM_C1(ip,clr,rdec) { \
 *ip++ = clr; *ip++ = clr; *ip++ = clr; *ip = clr; ip -= rdec; \
 *ip++ = clr; *ip++ = clr; *ip++ = clr; *ip = clr; ip -= rdec; \
 *ip++ = clr; *ip++ = clr; *ip++ = clr; *ip = clr; ip -= rdec; \
 *ip++ = clr; *ip++ = clr; *ip++ = clr; *ip = clr; }

#define AVI_CRAM_C2(ip,flag,cA,cB,rdec) { \
  *ip++ =(flag&0x01)?(cB):(cA); *ip++ =(flag&0x02)?(cB):(cA); \
  *ip++ =(flag&0x04)?(cB):(cA); *ip   =(flag&0x08)?(cB):(cA); ip-=rdec; \
  *ip++ =(flag&0x10)?(cB):(cA); *ip++ =(flag&0x20)?(cB):(cA); \
  *ip++ =(flag&0x40)?(cB):(cA); *ip   =(flag&0x80)?(cB):(cA); }

#define AVI_CRAM_C4(ip,flag,cA0,cA1,cB0,cB1,rdec) { \
  *ip++ =(flag&0x01)?(cB0):(cA0); *ip++ =(flag&0x02)?(cB0):(cA0); \
  *ip++ =(flag&0x04)?(cB1):(cA1); *ip   =(flag&0x08)?(cB1):(cA1); ip-=rdec; \
  *ip++ =(flag&0x10)?(cB0):(cA0); *ip++ =(flag&0x20)?(cB0):(cA0); \
  *ip++ =(flag&0x40)?(cB1):(cA1); *ip   =(flag&0x80)?(cB1):(cA1); }

#define AVI_MIN_MAX_CHECK(x,y,min_x,max_x,min_y,max_y) { \
    if (x < min_x) min_x = x; if (y > max_y) max_y = y; \
    if (x > max_x) max_x = x; if (y < min_y) min_y = y; } 

#define AVI_BLOCK_INC(x,y,imagex) { x += 4; if (x>=imagex) { x=0; y -= 4; } }

#define AVI_GET_16(data,dptr) { data = *dptr++; data |= (*dptr++) << 8; }

#define AVI_CRAM_rgbC1(ip,r,g,b) { \
 *ip++=r; *ip++=g; *ip++=b; *ip++=r; *ip++=g; *ip++=b; \
 *ip++=r; *ip++=g; *ip++=b; *ip++=r; *ip++=g; *ip  =b; }

#define AVI_CRAM_rgbC2(ip,flag,rA,gA,bA,rB,gB,bB) { \
  if (flag&0x01) {*ip++=rB; *ip++=gB; *ip++=bB;} \
  else		 {*ip++=rA; *ip++=gA; *ip++=bA;} \
  if (flag&0x02) {*ip++=rB; *ip++=gB; *ip++=bB;} \
  else		 {*ip++=rA; *ip++=gA; *ip++=bA;} \
  if (flag&0x04) {*ip++=rB; *ip++=gB; *ip++=bB;} \
  else		 {*ip++=rA; *ip++=gA; *ip++=bA;} \
  if (flag&0x08) {*ip++=rB; *ip++=gB; *ip  =bB;} \
  else		 {*ip++=rA; *ip++=gA; *ip  =bA;}  }

#define AVI_CRAM_rgbC4(ip,flag,rA,gA,bA,rB,gB,bB) { \
  if (flag&0x01) {*ip++=rB; *ip++=gB; *ip++=bB;} \
  else		 {*ip++=rA; *ip++=gA; *ip++=bA;} \
  if (flag&0x02) {*ip++=rB; *ip++=gB; *ip  =bB;} \
  else		 {*ip++=rA; *ip++=gA; *ip  =bA;} }

#define AVI_Get_RGBColor(r,g,b,color) \
{ register ULONG _r,_g,_b; \
  _r = (color >> 10) & 0x1f; r = (_r << 3) | (_r >> 2); \
  _g = (color >>  5) & 0x1f; g = (_g << 3) | (_g >> 2); \
  _b =  color & 0x1f;        b = (_b << 3) | (_b >> 2); \
  if (xa_gamma_flag==TRUE) { r = xa_gamma_adj[r]>>8;    \
     g = xa_gamma_adj[g]>>8; b = xa_gamma_adj[b]>>8; } }


ULONG
AVI_Decode_CRAM(image,delta,dsize,chdr,map,map_flag,imagex,imagey,imaged,
						xs,ys,xe,ye,special,extra)
UBYTE *image;		/* Image Buffer. */
UBYTE *delta;		/* delta data. */
ULONG dsize;		/* delta size */
XA_CHDR *chdr;		/* color map info */
ULONG *map;		/* used if it's going to be remapped. */
ULONG map_flag;		/* whether or not to use remap_map info. */
ULONG imagex,imagey;	/* Size of image buffer. */
ULONG imaged;		/* Depth of Image. (IFF specific) */
ULONG *xs,*ys;		/* pos of changed area. */
ULONG *xe,*ye;		/* size of changed area. */
ULONG special;		/* Special Info. */
ULONG extra;		/* extra info needed to decode delta */
{
  ULONG row_dec,exitflag,changed,block_cnt;
  ULONG code0,code1;
  LONG x,y,min_x,max_x,min_y,max_y;
  UBYTE *dptr;

  changed = 0;
  max_x = max_y = 0;	min_x = imagex;	min_y = imagey;
  dptr = delta;
  row_dec = imagex + 3;
  x = 0;
  y = imagey - 1;
  exitflag = 0;
  block_cnt = ((imagex * imagey) >> 4) + 1;

  if (map_flag == TRUE)
  {
    if (x11_bytes_pixel == 4)
    {
      while(!exitflag)
      {
	code0 =  *dptr++;	code1 =  *dptr++;	block_cnt--;
	if ( (code1==0) && (code0==0) && !block_cnt ) exitflag = 1;
	else
	{
	  if (y < 0) {exitflag = 1; continue; }
	  if ((code1 >= 0x84) && (code1 <= 0x87)) /* skip */
	  { ULONG skip = ((code1 - 0x84) << 8) + code0;
	    block_cnt -= (skip-1); while(skip--) AVI_BLOCK_INC(x,y,imagex);
	  }
	  else /* single block encoded */
	  {
	    if (code1 >= 0x90) /* 8 color quad encoding */
	    { ULONG cA0,cA1,cB0,cB1;
	      ULONG *i_ptr = (ULONG *)(image + ((y * imagex + x) << 2) );
	      cB0 = (ULONG)map[*dptr++];  cA0 = (ULONG)map[*dptr++];
	      cB1 = (ULONG)map[*dptr++];  cA1 = (ULONG)map[*dptr++];
	      AVI_CRAM_C4(i_ptr,code0,cA0,cA1,cB0,cB1,row_dec); i_ptr -=row_dec;
	      cB0 = (ULONG)map[*dptr++];  cA0 = (ULONG)map[*dptr++];
	      cB1 = (ULONG)map[*dptr++];  cA1 = (ULONG)map[*dptr++];
	      AVI_CRAM_C4(i_ptr,code1,cA0,cA1,cB0,cB1,row_dec);
	    } else if (code1 < 0x80) /* 2 color encoding */
	    { register ULONG clr_A,clr_B;
	      ULONG *i_ptr = (ULONG *)(image + ((y * imagex + x) << 2) );
	      clr_B = (ULONG)map[*dptr++];   clr_A = (ULONG)map[*dptr++];
	      AVI_CRAM_C2(i_ptr,code0,clr_A,clr_B,row_dec); i_ptr -= row_dec;
	      AVI_CRAM_C2(i_ptr,code1,clr_A,clr_B,row_dec);
	    }
	    else /* 1 color encoding */
	    { ULONG clr = (ULONG)map[code0]; 
	      ULONG *i_ptr = (ULONG *)(image + ((y * imagex + x) << 2) );
	      AVI_CRAM_C1(i_ptr,clr,row_dec);
	    }
	    AVI_MIN_MAX_CHECK(x,y,min_x,max_x,min_y,max_y);
	    changed = 1; AVI_BLOCK_INC(x,y,imagex);
	  } /* end of single block */
	} /* end of not term code */
      } /* end of not while exit */
    } /* end of 4 bytes pixel */
    else if (x11_bytes_pixel == 2)
    {
      while(!exitflag)
      {
	code0 =  *dptr++;	code1 =  *dptr++;	block_cnt--;
	if ( (code1==0) && (code0==0) && !block_cnt ) exitflag = 1;
	else
	{
	  if (y < 0) {exitflag = 1; continue; }
	  if ((code1 >= 0x84) && (code1 <= 0x87)) /* skip */
	  { ULONG skip = ((code1 - 0x84) << 8) + code0;
	    block_cnt -= (skip-1); while(skip--) AVI_BLOCK_INC(x,y,imagex);
	  } else /* single block encoded */
	  {
	    if (code1 >= 0x90) /* 8 color quad encoding */
	    {
	      USHORT cA0,cA1,cB0,cB1;
	      USHORT *i_ptr = (USHORT *)(image + ((y * imagex + x) << 1) );
	      cB0 = map[*dptr++];  cA0 = map[*dptr++];
	      cB1 = map[*dptr++];  cA1 = map[*dptr++];
	      AVI_CRAM_C4(i_ptr,code0,cA0,cA1,cB0,cB1,row_dec); i_ptr -=row_dec;
	      cB0 = map[*dptr++];  cA0 = map[*dptr++];
	      cB1 = map[*dptr++];  cA1 = map[*dptr++];
	      AVI_CRAM_C4(i_ptr,code1,cA0,cA1,cB0,cB1,row_dec);
	    } /* end of 8 color quad encoding */
	    else if (code1 < 0x80) /* 2 color encoding */
	    { USHORT clr_A,clr_B;
	      USHORT *i_ptr = (USHORT *)(image + ((y * imagex + x) << 1) );
	      clr_B = (USHORT)map[*dptr++];   clr_A = (USHORT)map[*dptr++];
	      AVI_CRAM_C2(i_ptr,code0,clr_A,clr_B,row_dec); i_ptr -= row_dec;
	      AVI_CRAM_C2(i_ptr,code1,clr_A,clr_B,row_dec);
	    } /* end of 2 color */
	    else /* 1 color encoding */
	    { USHORT clr = (USHORT)map[code0];
	      USHORT *i_ptr = (USHORT *)(image + ((y * imagex + x) << 1) );
	      AVI_CRAM_C1(i_ptr,clr,row_dec);
	    }
	    AVI_MIN_MAX_CHECK(x,y,min_x,max_x,min_y,max_y);
	    changed = 1; AVI_BLOCK_INC(x,y,imagex);
	  } /* end of single block */
	} /* end of not term code */
      } /* end of not while exit */
    } /* end of 2 bytes pixel */
    else /* (x11_bytes_pixel == 1) */
    {
      while(!exitflag)
      {
	code0 =  *dptr++;	code1 =  *dptr++;	block_cnt--;
	if ( (code1==0) && (code0==0) && !block_cnt ) exitflag = 1;
	else
	{
	  if (y < 0) {exitflag = 1; continue; }
	  if ((code1 >= 0x84) && (code1 <= 0x87)) /* skip */
	  { ULONG skip = ((code1 - 0x84) << 8) + code0;
	    block_cnt -= (skip-1); while(skip--) AVI_BLOCK_INC(x,y,imagex);
	  } else /* single block encoded */
	  { 
	    if (code1 >= 0x90) /* 8 color quad encoding */
	    { UBYTE cA0,cA1,cB0,cB1;
	      UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      cB0 = (UBYTE)map[*dptr++];  cA0 = (UBYTE)map[*dptr++];
	      cB1 = (UBYTE)map[*dptr++];  cA1 = (UBYTE)map[*dptr++];
	      AVI_CRAM_C4(i_ptr,code0,cA0,cA1,cB0,cB1,row_dec); i_ptr -=row_dec;
	      cB0 = (UBYTE)map[*dptr++];  cA0 = (UBYTE)map[*dptr++];
	      cB1 = (UBYTE)map[*dptr++];  cA1 = (UBYTE)map[*dptr++];
	      AVI_CRAM_C4(i_ptr,code1,cA0,cA1,cB0,cB1,row_dec);
	    } 
	    else if (code1 < 0x80) /* 2 color encoding */
	    { UBYTE clr_A,clr_B;
	      UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      clr_B = (UBYTE)map[*dptr++];   clr_A = (UBYTE)map[*dptr++];
	      AVI_CRAM_C2(i_ptr,code0,clr_A,clr_B,row_dec); i_ptr -= row_dec;
	      AVI_CRAM_C2(i_ptr,code1,clr_A,clr_B,row_dec);
	    }
	    else /* 1 color encoding */
	    { UBYTE clr = (UBYTE)map[code0];
	      UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      AVI_CRAM_C1(i_ptr,clr,row_dec);
	    }
	    AVI_MIN_MAX_CHECK(x,y,min_x,max_x,min_y,max_y);
	    changed = 1; AVI_BLOCK_INC(x,y,imagex);
	  } /* end of single block */
	} /* end of not term code */
      } /* end of not while exit */
    } /* end of 1 bytes pixel */
  } /* end of map is TRUE */
  else
  {
      while(!exitflag)
      {
	code0 =  *dptr++;	code1 =  *dptr++;	block_cnt--;
	if ( (code1==0) && (code0==0) && !block_cnt ) exitflag = 1;
	else if (y < 0) {exitflag = 1; continue; }
	else
	{
	  if ((code1 >= 0x84) && (code1 <= 0x87)) /* skip */
	  { ULONG skip = ((code1 - 0x84) << 8) + code0;
	    block_cnt -= (skip-1); while(skip--) AVI_BLOCK_INC(x,y,imagex);
	  } else /* single block encoded */
	  {
	    if (code1 >= 0x90) /* 8 color quad encoding */
	    {
	      UBYTE cA0,cA1,cB0,cB1;
	      UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      cB0 = (UBYTE)*dptr++;  cA0 = (UBYTE)*dptr++;
	      cB1 = (UBYTE)*dptr++;  cA1 = (UBYTE)*dptr++;
	      AVI_CRAM_C4(i_ptr,code0,cA0,cA1,cB0,cB1,row_dec); i_ptr -=row_dec;
	      cB0 = (UBYTE)*dptr++;  cA0 = (UBYTE)*dptr++;
	      cB1 = (UBYTE)*dptr++;  cA1 = (UBYTE)*dptr++;
	      AVI_CRAM_C4(i_ptr,code1,cA0,cA1,cB0,cB1,row_dec);
	    } 
	    else if (code1 < 0x80) /* 2 color encoding */
	    { UBYTE clr_A,clr_B;
	      UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      clr_B = (UBYTE)*dptr++;   clr_A = (UBYTE)*dptr++;
	      AVI_CRAM_C2(i_ptr,code0,clr_A,clr_B,row_dec); i_ptr -= row_dec;
	      AVI_CRAM_C2(i_ptr,code1,clr_A,clr_B,row_dec);
	    } /* end of 2 color */
	    else /* 1 color encoding */
	    {
	      UBYTE clr = (UBYTE)code0;
	      UBYTE *i_ptr = (UBYTE *)(image + y * imagex + x);
	      AVI_CRAM_C1(i_ptr,clr,row_dec);
	    }
	    AVI_MIN_MAX_CHECK(x,y,min_x,max_x,min_y,max_y);
	    changed = 1; AVI_BLOCK_INC(x,y,imagex);
	  } /* end of single block */
	} /* end of not term code */
      } /* end of not while exit */
  }
  if (xa_optimize_flag == TRUE)
  {
    if (changed) { *xs=min_x; *ys=min_y - 3; *xe=max_x + 4; *ye=max_y + 1; }
    else  { *xs = *ys = *xe = *ye = 0; return(ACT_DLTA_NOP); }
  }
  else { *xs = *ys = 0; *xe = imagex; *ye = imagey; }
  if (map_flag) return(ACT_DLTA_MAPD);
  else return(ACT_DLTA_NORM);
}


/*
 * Routine to Decode an AVI RGB chunk
 * (i.e. just copy it into the image buffer)
 * courtesy of Julian Bradfield.
 */

ULONG
AVI_Decode_RGB(image,delta,dsize,chdr,map,map_flag,imagex,imagey,imaged,
						xs,ys,xe,ye,special,extra)
UBYTE *image;		/* Image Buffer. */
UBYTE *delta;		/* delta data. */
ULONG dsize;		/* delta size */
XA_CHDR *chdr;		/* color map info */
ULONG *map;		/* used if it's going to be remapped. */
ULONG map_flag;		/* whether or not to use remap_map info. */
ULONG imagex,imagey;	/* Size of image buffer. */
ULONG imaged;		/* Depth of Image. (IFF specific) */
ULONG *xs,*ys;		/* pos of changed area. */
ULONG *xe,*ye;		/* size of changed area. */
ULONG special;		/* Special Info. */
ULONG extra;		/* extra info needed to decode delta */
{ ULONG oddflag;
  UBYTE *dptr = delta;
  
  oddflag = imagex & 0x01;
  if (map_flag == TRUE)
  {
    if (x11_bytes_pixel == 4)
    { LONG x,y = imagey - 1;
      while ( y >= 0 )
      { ULONG *i_ptr = (ULONG *)(image + ((y * imagex)<<2) ); y--; 
        x = imagex; while(x--) *i_ptr++ = (ULONG)map[*dptr++];
	if (oddflag) dptr++;
      }
    }
    else if (x11_bytes_pixel == 2)
    { LONG x,y = imagey - 1;
      while ( y >= 0 )
      { USHORT *i_ptr = (USHORT *)(image + ((y * imagex)<<1) ); y--; 
        x = imagex; while(x--) *i_ptr++ = (USHORT)map[*dptr++];
	if (oddflag) dptr++;
      }
    }
    else /* (x11_bytes_pixel == 1) */
    { LONG x,y = imagey - 1;
      while ( y >= 0 )
      { UBYTE *i_ptr = (UBYTE *)(image + y * imagex); y--; 
        x = imagex; while(x--) *i_ptr++ = (UBYTE)map[*dptr++];
	if (oddflag) dptr++;
      }
    }
  } /* end of map is TRUE */
  else
  { LONG x,y = imagey - 1;
    while ( y >= 0 )
    { UBYTE *i_ptr = (UBYTE *)(image + y * imagex); y--; 
      x = imagex; while(x--) *i_ptr++ = (UBYTE)*dptr++;
	if (oddflag) dptr++;
    }
  }
 *xs = *ys = 0; *xe = imagex; *ye = imagey;
  if (map_flag) return(ACT_DLTA_MAPD);
  else return(ACT_DLTA_NORM);
}

void AVI_Print_ID(fout,id)
FILE *fout;
LONG id;
{
 fprintf(fout,"%c",     ((id >> 24) & 0xff)   );
 fprintf(fout,"%c",     ((id >> 16) & 0xff)   );
 fprintf(fout,"%c",     ((id >>  8) & 0xff)   );
 fprintf(fout,"%c(%lx)", (id        & 0xff),id);
}


ULONG AVI_Get_Color(color,map_flag,map,chdr)
ULONG color,map_flag,*map;
XA_CHDR *chdr;
{
  register ULONG clr,ra,ga,ba,tr,tg,tb;
 
  ra = (color >> 10) & 0x1f;
  ga = (color >>  5) & 0x1f;
  ba =  color & 0x1f;
  tr = (ra << 3) | (ra >> 2);
  tg = (ga << 3) | (ga >> 2);
  tb = (ba << 3) | (ba >> 2);
  if (xa_gamma_flag==TRUE) { tr = xa_gamma_adj[tr]>>8;  
     tg = xa_gamma_adj[tg]>>8; tb = xa_gamma_adj[tb]>>8; }

 
  if (x11_display_type & XA_X11_TRUE) clr = X11_Get_True_Color(ra,ga,ba,5);
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
	   CMAP_Find_Closest(chdr->cmap,chdr->csize,ra,ga,ba,5,5,5,TRUE);
        cmap_cache[cache_i] = (USHORT)clr;
      }
      else clr = (ULONG)cmap_cache[cache_i];
    }
    else
    {
      if (cmap_true_to_332 == TRUE) 
	  clr=CMAP_GET_332(ra,ga,ba,CMAP_SCALE5);
      else   clr = CMAP_GET_GRAY(ra,ga,ba,CMAP_SCALE10);
      if (map_flag) clr = map[clr];
    }
  }
  return(clr);
}


ULONG
AVI_Decode_RLE8(image,delta,dsize,chdr,map,map_flag,imagex,imagey,imaged,
                                                xs,ys,xe,ye,special,extra)
UBYTE *image;           /* Image Buffer. */
UBYTE *delta;           /* delta data. */
LONG dsize;             /* delta size */
XA_CHDR *chdr;          /* color map info */
ULONG *map;             /* used if it's going to be remapped. */
ULONG map_flag;         /* whether or not to use remap_map info. */
ULONG imagex,imagey;    /* Size of image buffer. */
ULONG imaged;           /* Depth of Image. (IFF specific) */
ULONG *xs,*ys;          /* pos of changed area. */
ULONG *xe,*ye;          /* size of changed area. */
ULONG special;          /* Special Info. */
ULONG extra;            /* extra info needed to decode delta */
{
  ULONG opcode,mod;
  LONG x,y,min_x,max_x,min_y,max_y;
  UBYTE *dptr;

  max_x = max_y = 0; min_x = imagex; min_y = imagey;
  x = 0;  y = imagey - 1;
  dptr = delta;

  while( (y >= 0) && (dsize > 0) )
  {
    mod = *dptr++;
    opcode = *dptr++;  dsize-=2;

    if (mod == 0x00)				/* END-OF-LINE */
    {
      if (opcode==0x00)
      {
        while(x > imagex) { x -=imagex; y--; }
        x = 0; y--;
      }
      else if (opcode==0x01)			/* END Of Image */
      {
        y = -1;
      }
      else if (opcode==0x02)			/* SKIP */
      {
        ULONG yskip,xskip;
        xskip = *dptr++; 
        yskip = *dptr++;  dsize-=2;
        x += xskip;
        y -= yskip;
      }
      else					/* ABSOLUTE MODE */
      {
        int cnt = opcode;
        
	dsize-=cnt;
        while(x >= imagex) { x -= imagex; y--; }
	if (y > max_y) max_y = y; if (x < min_x) x = min_x;
        if (map_flag==TRUE)
	{
	  if (x11_bytes_pixel==1)
          { UBYTE *iptr = (UBYTE *)(image + (y * imagex + x) );
            while(cnt--) 
	    { if (x >= imagex) { max_x = imagex; min_x = 0;
		 x -= imagex; y--; iptr = (UBYTE *)(image+y*imagex+x); }
              *iptr++ = (UBYTE)map[*dptr++];  x++;
	    }
	  }
	  else if (x11_bytes_pixel==2)
          { USHORT *iptr = (USHORT *)(image + ((y * imagex + x)<<1) );
            while(cnt--) 
	    { if (x >= imagex)  { max_x = imagex; min_x = 0;
		x -= imagex; y--; iptr = (USHORT *)(image+y*imagex+x); }
              *iptr++ = (USHORT)map[*dptr++];  x++;
	    }
	  }
	  else /* if (x11_bytes_pixel==4) */
          { ULONG *iptr = (ULONG *)(image + ((y * imagex + x)<<2) );
            while(cnt--) 
	    { if (x >= imagex)  { max_x = imagex; min_x = 0;
		x -= imagex; y--; iptr = (ULONG *)(image+y*imagex+x); }
              *iptr++ = (ULONG)map[*dptr++];  x++;
	    }
	  }
        }
        else
        { UBYTE *iptr = (UBYTE *)(image + (y * imagex + x) );
          while(cnt--) 
	  { if (x >= imagex)  { max_x = imagex; min_x = 0;
		x -=imagex; y--; iptr = (UBYTE *)(image+y*imagex+x); }
	    *iptr++ = (UBYTE)(*dptr++); x++;
	  }
        }
        if (opcode & 0x01) { dptr++; dsize--; }
        if (y < min_y) min_y = y; if (x > max_x) x = max_x;
      }
    }
    else					/* ENCODED MODE */
    {
      int color,cnt;
      while(x >= imagex) { x -=imagex; y--; }
      if (y > max_y) max_y = y; if (x < min_x) x = min_x;
      cnt = mod;
      color = (map_flag==TRUE)?(map[opcode]):(opcode);
      if ( (map_flag==FALSE) || (x11_bytes_pixel==1) )
      { UBYTE *iptr = (UBYTE *)(image + (y * imagex + x) );
	UBYTE clr = (UBYTE)color;
	while(cnt--) 
	{ if (x >= imagex) { max_x = imagex; min_x = 0;
		x -=imagex; y--; iptr = (UBYTE *)(image+y*imagex+x); }
	  *iptr++ = clr; x++;
	}
      }
      else if (x11_bytes_pixel==2)
      { USHORT *iptr = (USHORT *)(image + ((y * imagex + x)<<1) );
	USHORT clr = (USHORT)color;
	while(cnt--) 
	{ if (x >= imagex)  { max_x = imagex; min_x = 0;
		x -=imagex; y--; iptr = (USHORT *)(image+y*imagex+x); }
	  *iptr++ = clr; x++;
	}
      }
      else /* if (x11_bytes_pixel==4) */
      { ULONG *iptr = (ULONG *)(image + ((y * imagex + x)<<2) );
	ULONG clr = (ULONG)color;
	while(cnt--) 
	{ if (x >= imagex)  { max_x = imagex; min_x = 0;
		x -=imagex; y--; iptr = (ULONG *)(image+y*imagex+x); }
	  *iptr++ = clr; x++;
	}
      }
      if (y < min_y) min_y = y; if (x > max_x) x = max_x;
    }
  } /* end of while */

  if (xa_optimize_flag == TRUE)
  {
    max_x++; if (max_x>imagex) max_x=imagex;
    max_y++; if (max_y>imagey) max_y=imagey;
    if ((min_x >= max_x) || (min_y >= max_y)) /* no change */
		{ *xs = *ys = *xe = *ye = 0; return(ACT_DLTA_NOP); }
    else	{ *xs=min_x; *ys=min_y; *xe=max_x; *ye=max_y; }
  }
  else { *xs = *ys = 0; *xe = imagex; *ye = imagey; }
  if (map_flag) return(ACT_DLTA_MAPD);
  else return(ACT_DLTA_NORM);
}

ULONG
AVI_Decode_CRAM16(image,delta,dsize,tchdr,map,map_flag,imagex,imagey,imaged,
						xs,ys,xe,ye,special,extra)
UBYTE *image;		/* Image Buffer. */
UBYTE *delta;		/* delta data. */
ULONG dsize;		/* delta size */
XA_CHDR *tchdr;		/* color map info */
ULONG *map;		/* used if it's going to be remapped. */
ULONG map_flag;		/* whether or not to use remap_map info. */
ULONG imagex,imagey;	/* Size of image buffer. */
ULONG imaged;		/* Depth of Image. (IFF specific) */
ULONG *xs,*ys;		/* pos of changed area. */
ULONG *xe,*ye;		/* size of changed area. */
ULONG special;		/* Special Info. */
ULONG extra;		/* extra info needed to decode delta */
{
  ULONG row_dec,exitflag,changed,block_cnt;
  ULONG code0,code1;
  LONG x,y,min_x,max_x,min_y,max_y;
  UBYTE *dptr;
  XA_CHDR *chdr;

  if (tchdr) {chdr=(tchdr->new_chdr)?(tchdr->new_chdr):(tchdr);} else chdr=0;
  changed = 0;
  max_x = max_y = 0;	min_x = imagex;	min_y = imagey;
  dptr = delta;
  if (special) row_dec = (3*(imagex+4))-1; else row_dec = imagex + 3; 
  x = 0;
  y = imagey - 1;
  exitflag = 0;
  block_cnt = ((imagex * imagey) >> 4) + 1;

  if (special == 1)
  {
    while(!exitflag)
    {
      code0 =  *dptr++;	code1 =  *dptr++;	block_cnt--;
      if ( (code1==0) && (code0==0) && !block_cnt) { exitflag = 1; continue; }
      if (y < 0) {exitflag = 1; continue; }
      if ((code1 >= 0x84) && (code1 <= 0x87)) /* skip */
      { ULONG skip = ((code1 - 0x84) << 8) + code0;
	block_cnt -= (skip-1); while(skip--) AVI_BLOCK_INC(x,y,imagex);
      }
      else /* not skip */
      { UBYTE *i_ptr = (UBYTE *)(image + 3 * (y * imagex + x) );
	if (code1 < 0x80) /* 2 or 8 color encoding */
	{ ULONG cA,cB; UBYTE rA0,gA0,bA0,rB0,gB0,bB0;
	  AVI_GET_16(cB,dptr); AVI_Get_RGBColor(rB0,gB0,bB0,cB);
	  AVI_GET_16(cA,dptr); AVI_Get_RGBColor(rA0,gA0,bA0,cA); 
	  if (cB & 0x8000)   /* Eight Color Encoding */
	  { UBYTE rA1,gA1,bA1,rB1,gB1,bB1;
	    register flag = code0;
	    AVI_GET_16(cB,dptr); AVI_Get_RGBColor(rB1,gB1,bB1,cB);
	    AVI_GET_16(cA,dptr); AVI_Get_RGBColor(rA1,gA1,bA1,cA); 
	    AVI_CRAM_rgbC4(i_ptr,flag,rA0,gA0,bA0,rB0,gB0,bB0); 
	    i_ptr++; flag >>= 2;
	    AVI_CRAM_rgbC4(i_ptr,flag,rA1,gA1,bA1,rB1,gB1,bB1); 
	    i_ptr -= row_dec; flag >>= 2;
	    AVI_CRAM_rgbC4(i_ptr,flag,rA0,gA0,bA0,rB0,gB0,bB0); 
	    i_ptr++; flag >>= 2;
	    AVI_CRAM_rgbC4(i_ptr,flag,rA1,gA1,bA1,rB1,gB1,bB1); 
	    i_ptr -= row_dec; flag = code1;
	    AVI_GET_16(cB,dptr); AVI_Get_RGBColor(rB0,gB0,bB0,cB);
	    AVI_GET_16(cA,dptr); AVI_Get_RGBColor(rA0,gA0,bA0,cA); 
	    AVI_GET_16(cB,dptr); AVI_Get_RGBColor(rB1,gB1,bB1,cB);
	    AVI_GET_16(cA,dptr); AVI_Get_RGBColor(rA1,gA1,bA1,cA); 
	    AVI_CRAM_rgbC4(i_ptr,flag,rA0,gA0,bA0,rB0,gB0,bB0); 
	    i_ptr++; flag >>= 2;
	    AVI_CRAM_rgbC4(i_ptr,flag,rA1,gA1,bA1,rB1,gB1,bB1); 
	    i_ptr -= row_dec; flag >>= 2;
	    AVI_CRAM_rgbC4(i_ptr,flag,rA0,gA0,bA0,rB0,gB0,bB0); 
	    i_ptr++; flag >>= 2;
	    AVI_CRAM_rgbC4(i_ptr,flag,rA1,gA1,bA1,rB1,gB1,bB1); 
	  } else /* Two Color Encoding */
	  { register ULONG flag = code0;
	    AVI_CRAM_rgbC2(i_ptr,flag,rA0,gA0,bA0,rB0,gB0,bB0); 
	    i_ptr -= row_dec; flag >>= 4;
	    AVI_CRAM_rgbC2(i_ptr,flag,rA0,gA0,bA0,rB0,gB0,bB0); 
	    i_ptr -= row_dec; flag = code1;
	    AVI_CRAM_rgbC2(i_ptr,flag,rA0,gA0,bA0,rB0,gB0,bB0); 
	    i_ptr -= row_dec; flag >>= 4;
	    AVI_CRAM_rgbC2(i_ptr,flag,rA0,gA0,bA0,rB0,gB0,bB0); 
	  }
	} /* end of 2 or 8 */
	else /* 1 color encoding (80-83) && (>=88)*/
	{ ULONG cA = (code1<<8) | code0;
	  UBYTE r,g,b;
	  AVI_Get_RGBColor(r,g,b,cA);
	  AVI_CRAM_rgbC1(i_ptr,r,g,b);  i_ptr -= row_dec;
	  AVI_CRAM_rgbC1(i_ptr,r,g,b);  i_ptr -= row_dec;
	  AVI_CRAM_rgbC1(i_ptr,r,g,b);  i_ptr -= row_dec;
	  AVI_CRAM_rgbC1(i_ptr,r,g,b);
	}
	changed = 1; AVI_MIN_MAX_CHECK(x,y,min_x,max_x,min_y,max_y);
	AVI_BLOCK_INC(x,y,imagex);
      } /* end of not skip */
    } /* end of not while exit */
  } /* end of special */
  else
  {
    if ( (x11_bytes_pixel == 1) || (map_flag == FALSE) )
    {
      while(!exitflag)
      {
	code0 =  *dptr++;	code1 =  *dptr++;	block_cnt--;
	if ( (code1==0) && (code0==0) && !block_cnt) { exitflag = 1; continue; }
	if (y < 0) {exitflag = 1; continue; }
	if ((code1 >= 0x84) && (code1 <= 0x87)) /* skip */
	{ ULONG skip = ((code1 - 0x84) << 8) + code0;
	  block_cnt -= (skip-1); while(skip--) AVI_BLOCK_INC(x,y,imagex);
	}
	else /* not skip */
	{ UBYTE *i_ptr = (UBYTE *)(image + (y * imagex + x) );
	  if (code1 < 0x80) /* 2 or 8 color encoding */
	  { ULONG cA,cB; UBYTE cA0,cB0;
	    AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	    cB0 = (UBYTE)AVI_Get_Color(cB,map_flag,map,chdr);
	    cA0 = (UBYTE)AVI_Get_Color(cA,map_flag,map,chdr);
	    if (cB & 0x8000)   /* Eight Color Encoding */
	    { UBYTE cA1,cB1;
	      AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	      cB1 = (UBYTE)AVI_Get_Color(cB,map_flag,map,chdr);
	      cA1 = (UBYTE)AVI_Get_Color(cA,map_flag,map,chdr);
	      AVI_CRAM_C4(i_ptr,code0,cA0,cA1,cB0,cB1,row_dec); i_ptr -=row_dec;
	      AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	      cB0 = (UBYTE)AVI_Get_Color(cB,map_flag,map,chdr);
	      cA0 = (UBYTE)AVI_Get_Color(cA,map_flag,map,chdr);
	      AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	      cB1 = (UBYTE)AVI_Get_Color(cB,map_flag,map,chdr);
	      cA1 = (UBYTE)AVI_Get_Color(cA,map_flag,map,chdr);
	      AVI_CRAM_C4(i_ptr,code1,cA0,cA1,cB0,cB1,row_dec);
	    } else /* Two Color Encoding */
	    { 
	      AVI_CRAM_C2(i_ptr,code0,cA0,cB0,row_dec); i_ptr -= row_dec;
	      AVI_CRAM_C2(i_ptr,code1,cA0,cB0,row_dec);
	    }
	  } /* end of 2 or 8 */
	  else /* 1 color encoding (80-83) && (>=88)*/
	  { ULONG cA = (code1<<8) | code0;
	    UBYTE clr = (UBYTE)AVI_Get_Color(cA,map_flag,map,chdr);
	    AVI_CRAM_C1(i_ptr,clr,row_dec);
	  }
	  changed = 1; AVI_MIN_MAX_CHECK(x,y,min_x,max_x,min_y,max_y);
	  AVI_BLOCK_INC(x,y,imagex);
	} /* end of not skip */
      } /* end of not while exit */
    } /* end of 1 bytes pixel */
    else if (x11_bytes_pixel == 2)
    {
      while(!exitflag)
      {
	code0 =  *dptr++;	code1 =  *dptr++;	block_cnt--;
	if ( (code1==0) && (code0==0) && !block_cnt) { exitflag = 1; continue; }
	if (y < 0) {exitflag = 1; continue; }
	if ((code1 >= 0x84) && (code1 <= 0x87)) /* skip */
	{ ULONG skip = ((code1 - 0x84) << 8) + code0;
	  block_cnt -= (skip-1); while(skip--) AVI_BLOCK_INC(x,y,imagex);
	}
	else /* not skip */
	{ USHORT *i_ptr = (USHORT *)(image + ((y * imagex + x) << 1) );
	  if (code1 < 0x80) /* 2 or 8 color encoding */
	  { ULONG cA,cB; USHORT cA0,cB0;
	    AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	    cB0 = (USHORT)AVI_Get_Color(cB,map_flag,map,chdr);
	    cA0 = (USHORT)AVI_Get_Color(cA,map_flag,map,chdr);
	    if (cB & 0x8000)   /* Eight Color Encoding */
	    { USHORT cA1,cB1;
	      AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	      cB1 = (USHORT)AVI_Get_Color(cB,map_flag,map,chdr);
	      cA1 = (USHORT)AVI_Get_Color(cA,map_flag,map,chdr);
	      AVI_CRAM_C4(i_ptr,code0,cA0,cA1,cB0,cB1,row_dec); i_ptr -=row_dec;
	      AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	      cB0 = (USHORT)AVI_Get_Color(cB,map_flag,map,chdr);
	      cA0 = (USHORT)AVI_Get_Color(cA,map_flag,map,chdr);
	      AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	      cB1 = (USHORT)AVI_Get_Color(cB,map_flag,map,chdr);
	      cA1 = (USHORT)AVI_Get_Color(cA,map_flag,map,chdr);
	      AVI_CRAM_C4(i_ptr,code1,cA0,cA1,cB0,cB1,row_dec);
	    } else /* Two Color Encoding */
	    { 
	      AVI_CRAM_C2(i_ptr,code0,cA0,cB0,row_dec); i_ptr -= row_dec;
	      AVI_CRAM_C2(i_ptr,code1,cA0,cB0,row_dec);
	    }
	  } /* end of 2 or 8 */
	  else /* 1 color encoding (80-83) && (>=88)*/
	  { ULONG cA = (code1<<8) | code0;
	    USHORT clr = (USHORT)AVI_Get_Color(cA,map_flag,map,chdr);
	    AVI_CRAM_C1(i_ptr,clr,row_dec);
	  }
	  changed = 1; AVI_MIN_MAX_CHECK(x,y,min_x,max_x,min_y,max_y);
	  AVI_BLOCK_INC(x,y,imagex);
	} /* end of not skip */
      } /* end of not while exit */
    } /* end of 2 bytes pixel */
    else if (x11_bytes_pixel == 4)
    {
      while(!exitflag)
      {
	code0 =  *dptr++;	code1 =  *dptr++;	block_cnt--;
	if ( (code1==0) && (code0==0) && !block_cnt) { exitflag = 1; continue; }
	if (y < 0) {exitflag = 1; continue; }
	if ((code1 >= 0x84) && (code1 <= 0x87)) /* skip */
	{ ULONG skip = ((code1 - 0x84) << 8) + code0;
	  block_cnt -= (skip-1); while(skip--) AVI_BLOCK_INC(x,y,imagex);
	}
	else /* not skip */
	{ ULONG *i_ptr = (ULONG *)(image + ((y * imagex + x) << 2) );
	  if (code1 < 0x80) /* 2 or 8 color encoding */
	  { ULONG cA,cB,cA0,cB0;
	    AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	    cB0 = AVI_Get_Color(cB,map_flag,map,chdr);
	    cA0 = AVI_Get_Color(cA,map_flag,map,chdr);
	    if (cB & 0x8000)   /* Eight Color Encoding */
	    { ULONG cA1,cB1;
	      AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	      cB1 = AVI_Get_Color(cB,map_flag,map,chdr);
	      cA1 = AVI_Get_Color(cA,map_flag,map,chdr);
	      AVI_CRAM_C4(i_ptr,code0,cA0,cA1,cB0,cB1,row_dec); i_ptr -=row_dec;
	      AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	      cB0 = AVI_Get_Color(cB,map_flag,map,chdr);
	      cA0 = AVI_Get_Color(cA,map_flag,map,chdr);
	      AVI_GET_16(cB,dptr); AVI_GET_16(cA,dptr);
	      cB1 = AVI_Get_Color(cB,map_flag,map,chdr);
	      cA1 = AVI_Get_Color(cA,map_flag,map,chdr);
	      AVI_CRAM_C4(i_ptr,code1,cA0,cA1,cB0,cB1,row_dec);
	    } else /* Two Color Encoding */
	    {
	      AVI_CRAM_C2(i_ptr,code0,cA0,cB0,row_dec); i_ptr -= row_dec;
	      AVI_CRAM_C2(i_ptr,code1,cA0,cB0,row_dec);
	    }
	  } /* end of 2 or 8 */
	  else /* 1 color encoding (80-83) && (>=88)*/
	  { ULONG cA = (code1<<8) | code0;
	    ULONG clr = AVI_Get_Color(cA,map_flag,map,chdr);
	    AVI_CRAM_C1(i_ptr,clr,row_dec);
	  }
	  changed = 1; AVI_MIN_MAX_CHECK(x,y,min_x,max_x,min_y,max_y);
	  AVI_BLOCK_INC(x,y,imagex);
	} /* end of not skip */
      } /* end of not while exit */
    } /* end of 4 bytes pixel */
  } /* end of not special */
  if (xa_optimize_flag == TRUE)
  {
    if (changed) { *xs=min_x; *ys=min_y - 3; *xe=max_x + 4; *ye=max_y + 1; }
    else  { *xs = *ys = *xe = *ye = 0; return(ACT_DLTA_NOP); }
  }
  else { *xs = *ys = 0; *xe = imagex; *ye = imagey; }
  if (map_flag) return(ACT_DLTA_MAPD);
  else return(ACT_DLTA_NORM);
}