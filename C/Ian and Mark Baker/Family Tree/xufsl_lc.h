#define EOS '\0'
#define UFSL_COOKIE     'UFSL'

xUFSL_struct* ufsl_cookie( void ) ;
void ufsl_font_select( long handle,
				xUFSL_struct* ufsl,
				long flags, char* u_title, char* u_info,
				XUFSL_LIST* list_ptr, long list_entries, long starting_entry,
				long sys_small, long sysibm,
				short* font, short* point,
				FW_INFO* width, short* attr, short* color, short* skew,
				long maxfonts ) ;
