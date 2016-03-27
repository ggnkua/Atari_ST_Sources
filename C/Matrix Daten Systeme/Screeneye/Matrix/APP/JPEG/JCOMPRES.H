extern void init_compress_info ( compress_info_ptr cinfo,
						  struct compress_methods_struct *c_methods,
						  struct external_methods_struct *e_methods,
						  IMAGE_FORMATS format ) ;
extern int open_cjpeg_files ( compress_info_ptr cinfo,
					   char *fil0, char *fil1, int argc ) ;
extern int compress_jpeg_file ( compress_info_ptr cinfo ) ;
