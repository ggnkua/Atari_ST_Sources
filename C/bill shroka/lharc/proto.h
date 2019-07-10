#ifdef __STDC__
# define	P(s) s
#else
# define P(s) ()
#endif


/* lharc.c */
int print_tiny_usage_and_exit P((void ));
int message P((char *title , char *msg ));
int warning P((char *msg ));
int error P((char *msg ));
int write_error P((void ));
int read_error P((void ));
int sort_files P((void ));
int make_tmp_name P((char *original , char *name ));
int make_backup_name P((char *name , char *orginal ));
FILE *xfopen P((char *name , char *mode ));
int print_size P((long packed_size , long original_size ));
#ifdef atarist
int print_stamp P((time_t t ));
#else
int print_stamp P((long t ));
#endif
int print_bar P((void ));
int cmd_view P((void ));
int cmd_extract P((void ));
int write_tail P((FILE *nafp ));
FILE *append_it P((char *name , FILE *oafp , FILE *nafp ));
int remove_it P((char *name ));
int cmd_append P((void ));

/* lhio.c */
int init_crc P((void ));
int copy_file P((FILE *ifp , FILE *ofp , long size ));
int decode_stored_crc P((FILE *ifp , FILE *ofp , long original_size , char *name ));
int decode_stored_nocrc P((FILE *ifp , FILE *ofp , long original_size , char *name ));
int encode_stored_crc P((FILE *ifp , FILE *ofp , int size , long *original_size_var , long *write_size_var ));

/* lzhuf.c */
void Error P((char *message ));
int encode_lzhuf P((FILE *infp , FILE *outfp , long size , long *original_size_var , long *packed_size_var , char *name ));
int decode_lzhuf P((FILE *infp , FILE *outfp , long original_size , char *name ));
int decode_larc P((FILE *infp , FILE *outfp , long original_size , char *name ));
