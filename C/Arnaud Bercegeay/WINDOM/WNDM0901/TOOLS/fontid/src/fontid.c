/*
 *	G‚nŠre un fichier de fonte pour WinDom
 */

#include <stdio.h>
#include <string.h>
#include <vdi.h>

/* WinDom	*/

int vqt_xname( int handle, int id, int index, char *name, int *flags);

/* Usage : fontid <path> */

int main( int argc, char **argv) {
	int work_in[11], work_out[57], vdihandle;
	FILE *fp;
	char name[44], path[255];
	int i, max, id, flags;
	
	if( vq_gdos()) {
		v_opnvwk( work_in, &vdihandle, work_out);

		if( argc > 1) {
			strcpy( path, argv[1]);
			strcat( path, "\\");
		} else
			*path = '\0';
	
		strcat( path, "fontid");
		fp = fopen( path, "w");
		if( fp) {
			fprintf( fp, "# @(#)WinDom/fontid\n"
						 "# Copyright Dominique B‚r‚ziat 2000\n"
						 "# Describe the font features when there is no font driver.\n\n");
			max = vst_load_fonts( vdihandle, 0) + work_out[10];
			fprintf( fp, "%d \"%s\" %d 0x%X\n", 0, "system font", 1, 0);		
			for( i = 1; i<=max; i++) {
				id = vqt_name( vdihandle, i, name);
				vst_font( vdihandle, id);      
				vqt_xname( vdihandle, id, i, path, &flags);
				fprintf( fp, "%d \"%s\" %d 0x%X\n", i, name, id, flags);
			}
			vst_unload_fonts( vdihandle, 0);
			fprintf( fp, "\n");
			fclose( fp);
			v_clsvwk( vdihandle);
			fprintf( stdout, "Found %d fonts. FONTID file correctly Generated.\n", max);
		}
	} else
		fprintf( stderr, "Error, no font manager.\n");
	return 0;
}

