extern int open_djpeg_files ( decompress_info_ptr cinfo,
						   char *ifi, char *ofi, int argc ) ;
extern void init_decompress_info (decompress_info_ptr cinfo,
							struct decompress_methods_struct *dc_methods,
						    struct external_methods_struct *e_methods,
						    IMAGE_FORMATS format ) ;
extern int decompress_jpeg_file ( decompress_info_ptr cinfo ) ;
