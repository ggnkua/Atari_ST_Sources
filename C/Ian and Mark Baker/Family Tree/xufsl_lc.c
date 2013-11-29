/* This file must be compiled with -aw option, ie with type based stack
   alignment.
*/

#include <aes.h>
#define cdecl /* used in XUFSL.H, presumably required in PureC */
#include <XUFSL.h>
#include <cookie.h>

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "genmain.h"
#include "genutil.h"

#include "xufsl_lc.h"

static xUFSL_struct ufsl ;




xUFSL_struct*  ufsl_cookie( void )
{
	long cookie ;
	xUFSL_struct* ufsl ;
	
	if ( getcookie( UFSL_COOKIE, &cookie ) )
		ufsl = (xUFSL_struct *) cookie ;
	else ufsl = NULL ;
	
	return ufsl ;
}

/*	font_select parameters
		handle			VDI workstation handle
		flags
			UFS_SIZE_CHANGE   0x00000001  size alterable
			UFS_WIDTH_CHANGE  0x00000002  width alterable
			UFS_ATTR_CHANGE   0x00000004  attributes selectable
			UFS_SKEW_CHANGE   0x00000008  skew alterable
			UFS_COLOR_CHANGE  0x00000010  colour alterable
			UFS_SIZE_DEFAULT  0x00000020  "DEFAULT" size allowed
			UFS_ATTR_INVERS   0x00000040  special attribute "inverse" allowed
			UFS_KERNING_INFO  0x00000080  kerning informationen alterable
			UFS_GDOS_FONTS    0x00000100  GDOS-Fonts allowed
			UFS_PROP_FONTS    0x00000200  proportional fonts allowed
			UFS_BITMAP_FONTS  0x00000400  only bitmap fonts allowed
			UFS_VECTOR_FONTS  0x00000800  only vector fonts allowed
			UFS_WIND_DIALOG   0x00001000  dialog in a window
			UFS_ERROR_MSG     0x00008000  faults reported in alert box
			UFS_INDIRECT      0x80000000L use XUFSL list
		u_title			font selector window title when using XUFSL
		u_info			font selector information line when not using XUFSL list
		xufsl_list		pointer to list of font selections
						Each entry in list contains flags, title plus font attributes
						for a font selection.
		list_entries	length of list
		starting_entry	list item selected when dialogue opened
		sys_small
		sysibm
		font			6 pointers to parameters, not used when using XUFSL list
		point
		width
		attr
		color
		skew	
*/
void ufsl_font_select( long handle,
				xUFSL_struct* ufsl,
				long flags, char* u_title, char* u_info,
				XUFSL_LIST* list_ptr, long list_entries, long starting_entry,
				long sys_small, long sysibm,
				short* font, short* point,
				FW_INFO* width, short* attr, short* color, short* skew,
				long maxfonts )
{
	if ( ufsl->id == xUFS_ID )
	{
		if( list_ptr != NULL && ufsl->version >= 0x103 )
		{
			ufsl->font_selexinput( (short) handle,
									flags | UFS_INDIRECT,
									( u_title[0] == EOS ) ? NULL : u_title,
									(char *) list_ptr, /* typecast to satisfy compiler */
									(short) sys_small, (short) sysibm,
									(int *) &list_entries, (int *) &starting_entry,
									width, attr, color, skew ) ;
		}
		else
		{
			ufsl->font_selexinput( (short) handle,
									flags,
									( u_title[0] == EOS ) ? NULL : u_title,
									( u_info == NULL || u_info[0] == EOS ) ? NULL : u_info,
									(short) sys_small, (short) sysibm,
									font, point,
									width, attr, color, skew );
		}
	}
	else
	{
		ufsl->dialtyp = ( flags & UFS_WIND_DIALOG ) ? UFS_WINDOW : UFS_DIALOG ;
		ufsl->fontsel_input( (short) handle, (short) maxfonts,
							(short) ( flags & UFS_PROP_FONTS ) != 0,
							( u_info[0] == EOS ) ? NULL : u_info,
							font, point ) ;

	}
}  
