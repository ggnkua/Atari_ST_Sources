#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif


/* decoders.c */
void init_tables _P((void));
void decodeDCTDCSizeLum _P((unsigned int *value));
void decodeDCTDCSizeChrom _P((unsigned int *value));
void decodeDCTCoeffFirst _P((unsigned int *run, int *level));
void decodeDCTCoeffNext _P((unsigned int *run, int *level));

/* gdith.c */
void InitColorDisplay _P((void));
void CloseColorDisplay _P((void));
void ExecuteDisplay _P((VidStream *vid_stream));

/* main.c */
long get_more_data _P((unsigned long *buf_start, long max_length, long *length_ptr, unsigned long **buf_ptr));
void main _P((int argc, char **argv));
void DoDitherImage _P((unsigned char *l, unsigned char *Cr, unsigned char *Cb, unsigned char *disp, long h, long w));

/* motionve.c */
void ComputeForwVector _P((int *recon_right_for_ptr, int *recon_down_for_ptr));
void ComputeBackVector _P((int *recon_right_back_ptr, int *recon_down_back_ptr));

/* parseblo.c */
void ParseReconBlock _P((int n));
void ParseAwayBlock _P((int n));

/* util.c */
void correct_underflow _P((void));
long next_bits _P((long num, unsigned long mask));
char *get_ext_data _P((void));
long next_start_code _P((void));
char *get_extra_bit_info _P((void));

/* video.c */
VidStream *NewVidStream _P((long bufLength));
void DestroyVidStream _P((VidStream *astream));
PictImage *NewPictImage _P((unsigned long width, unsigned long height));
void DestroyPictImage _P((PictImage *apictimage));
VidStream *mpegVidRsrc _P((TimeStamp time_stamp, VidStream *vid_stream));
long ParseSeqHead _P((VidStream *vid_stream));
long ParseGOP _P((VidStream *vid_stream));
long ParsePicture _P((VidStream *vid_stream, TimeStamp time_stamp));
long ParseSlice _P((VidStream *vid_stream));
long ParseMacroBlock _P((VidStream *vid_stream));
void ReconIMBlock2 _P((VidStream *vid_stream, long bnum));
void ReconIMBlock _P((VidStream *vid_stream, long bnum));
void ReconPMBlock _P((VidStream *vid_stream, long bnum, long recon_right_for, long recon_down_for, long zflag));
void ReconBMBlock _P((VidStream *vid_stream, long bnum, long recon_right_back, long recon_down_back, long zflag));
void ReconBiMBlock _P((VidStream *vid_stream, long bnum, long recon_right_for, long recon_down_for, long recon_right_back, long recon_down_back, long zflag));
void ProcessSkippedPFrameMBlocks _P((VidStream *vid_stream));
void ProcessSkippedBFrameMBlocks _P((VidStream *vid_stream));
void ReconSkippedBlock _P((unsigned char *source, unsigned char *dest, long row, long col, long row_size, long right, long down, long right_half, long down_half, long width));
void DoPictureDisplay _P((VidStream *vid_stream));

#undef _P
