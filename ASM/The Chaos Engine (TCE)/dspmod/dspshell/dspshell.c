/* DSP-Shell, Coderight by bITmASTER */

#include <stdio.h>
#include <tos.h>
#include <ext.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>

/* Prototypen */

void go( int bug );
void load_dspbug( void );
void debug( void );
void write_host( long d );
long read_host( void );
int host_status( void );
void set_files( void );
void read_inf( void );
void write_inf( void );
int file_select( char *fname );
void error( char *txt);

extern int dsp_to_obj( char *in, char *out );

/* Globales */
char editor[128];
char assembler[128];
char dspfile[128];
char dspobj[128];
char cpufile[128];
int cpu = 0;			/* wenn 1, DSP-Start mit CPU-File */
char ass_cmd[128];
char ass_lst[128];
char ass_out[128];
char buffer[512*3];
char path[128];

int ap_id;
int work_in[12], work_out[57];
int phys_handle, vdi_handle, wind_handle;
int gr_hwchar, gr_hhchar, gr_hwbox, gr_hhbox;

int main(void)
{
	char cls[] = { 0x1b, 0x45, 0 };
	char ed_cmd[] = "\0"; 
	int handle, screen;
	int c = 0;
	int ret_code;
	int i;
	
/*  init AES */

	ap_id = appl_init();
	if ( ap_id < 0 ) {
		error( "kein ap_id" );
		return(1);
	}
	
/* 	init VDI */	
	
	phys_handle = graf_handle( &gr_hwchar, &gr_hhchar, &gr_hwbox, &gr_hhbox );
	for ( i = 0; i < 10; work_in[i++] = 1 );
	work_in[10] = 2;							/* Rasterkoordinaten */
	vdi_handle = phys_handle;
	v_opnvwk( work_in, &vdi_handle, work_out );

	path[0] = Dgetdrv() +'A' ;			/* Lw */
	path[1] = ':';
	Dgetpath( path + 2, 0 );
				
	read_inf();
	set_files();
	graf_mouse( M_OFF, 0 );
	
/*	devconnect( 1, 8, 0, 1, 1 );*/		/* kein Handshake */
/*	dsptristate( 1, 0 );*/

	while ( 1 ) {
		
		if ( c != 'a' ) {
			printf(cls);
			printf("DSP-ASS Shell, coded by bITmASTER of TCE\n\n");
			printf("1: Assembler:  %s\n", assembler );
			printf("2: Editor:     %s\n", editor );			
			printf("3: DSP-File:   %s\n", dspfile );
			printf("   Output:     %s\n", ass_out );
			printf("   List:       %s\n", ass_lst );
			printf("4: (C)PU-File: ");
			if ( cpu ) {
				printf("%s\n", cpufile );	

				printf("   DSP-Object: %s\n", dspobj );
			}
			printf("\n");
			printf("(E)ditor\n");
			printf("(A)ssembler\n");
			printf("(O)bject-File\n");
			printf("(G)o\n");
			printf("(D)ebugger\n");
			printf("(Q)uit\n");
		}
		c = getch();
		switch ( c ) {
			case '1': file_select( assembler );	break;
			case '2': file_select( editor );	break;
			case '3': file_select( dspfile );	set_files(); break;
			case '4': if ( cpu )
						file_select( cpufile );
					  break;		
			case 'c' : {
				cpu = ! cpu;
				break;
			}
			case 'q': {
				write_inf();
				graf_mouse( M_ON, 0 );
				v_clsvwk( vdi_handle );
				appl_exit();
				return( 0 );
			}
			case 'e': {
				graf_mouse( M_ON, 0 );
				ret_code = (int) Pexec( 0, editor, ed_cmd, "\0" );
				graf_mouse( M_OFF, 0 );
				if ( ret_code <0  )
					error("kann Editor nicht finden");
				break;
			}
			case 'a': {
				screen = (int) Fdup( 1 );
				handle = (int) Fcreate( ass_lst, 0 );
				Fforce( 1, handle );
				ret_code = (int) Pexec( 0, assembler, ass_cmd, "\0" );
				Fclose( handle );
				Fforce( 1, screen );
				printf("Return-Code: %d\n", ret_code );
				if ( ret_code < 0  )
					error("kann Assembler nicht finden");
				else {				
					switch( ret_code ) {
						case 0: printf("OK   \r");break;
						case 1: printf("Error\r");break;
					}
				}
				break;
			}
			case 'o' : {
				ret_code = dsp_to_obj( ass_out, dspobj );
				switch( ret_code ) {
					case 1: error("kein *.DSP-File da "); break;
					case 2: error("kann *.O nicht ”ffnen "); break;
				}				
				break;
			}
			case 'g' : go( 0 ); break;
			case 'd' : go( 1 ); break;
		}
	}
}


void go( int bug )
{
	char mem;
	long adr, dat;
	int i;
	FILE *fp;

	if ( bug || ( ! cpu ) ) {	
		fp = fopen( "LOADER.DSP", "r" );
		if ( fp == NULL ) {
			error( "kann LOADER.DSP nicht finden" );
			return;
		}
		i = 0;
		while ( fscanf( fp, "%c %lX %lX\n", &mem, &adr, &dat ) != EOF ) {
			buffer[i++] = (char) ( dat >> 16 );
			buffer[i++] = (char) ( dat >>  8 );
			buffer[i++] = (char) dat;		
		}
		fclose( fp );
		Dsp_ExecBoot( buffer, i / 3, 1 );
		
		write_host( bug );
		if ( bug )
			load_dspbug();				/* Debugger laden */
	
		fp = fopen( ass_out, "r" );
		if ( fp == NULL ) {
			error( "kann das Assembler-Outfile nicht finden (*.DSP) " );
			return;
		}
		while ( fscanf( fp, "%c %lX %lX\n", &mem, &adr, &dat ) != EOF ) {
			adr |= (long) mem << 16;
			write_host( adr );
			write_host( dat );
		}
		write_host( 0xff0000L );		/* fertig */
		fclose( fp );
		if ( bug )
			debug();
	}
	else {
		i = (int) Pexec( 0, cpufile, "\0", "\0" );
		if ( i < 0  )
			error("CPU-File kann nicht gestartet werden");
	}
}

void load_dspbug( void )
{
	long *dspbug;
	DTA file_info;
	int handle;
	long len;
	char fname[] = "DSPBUG.COD";
		
	if ( Fsfirst( fname, 0 ) != 0 ) {
		error( "kann DSPBUG.COD nicht finden" );
		return;
	}
	file_info = *Fgetdta();
	len = file_info.d_length;
	write_host( len / 4L );
	dspbug = Malloc( len );
	if ( dspbug == NULL ) {
		error("nicht gengend Speicher");
		return;
	}
	handle = (int)Fopen( fname, FO_READ );
	Fread( handle, len, dspbug );
	Fclose( handle );
	while ( len > 0L ) {
		write_host( *dspbug++ );
		len -= 4L;
	}
	Mfree( dspbug );
}

void debug( void )
{
	int status;
	int c;
	
	while( 1 ) {
		status = host_status();
		if ( status & 1 )
			printf( "%c", (int)read_host() & 0xff );
		if ( kbhit() ) {
			c = getch();
			if ( c == 0x1b )
				return;
			write_host( c );
		}
	}
}

void write_host( long d )
{
	char *host_status = (char *)0xffffa202L;
	char *host_tx	  = (char *)0xffffa205L;
    long old_super_stack;

    old_super_stack = Super( 0L );

	while ( ! ( *host_status & 0x02 ) );
	*host_tx++ = (char) ( d >> 16 );
	*host_tx++ = (char) ( d >> 8 );
	*host_tx   = (char) d;
    Super((void *) old_super_stack );
}

long read_host( void )
{
	char *host_status = (char *)0xffffa202L;
	char *host_tx	  = (char *)0xffffa205L;
    long old_super_stack;
	long d;
	
    old_super_stack = Super( 0L );

	while ( ! ( *host_status & 0x01 ) );	/* auf Daten warten */
	d  = (long) *host_tx++ << 16;
	d |= (long) *host_tx++ <<  8;
	d |= (long) *host_tx;
    Super((void *) old_super_stack );
    return( d );
}

int host_status( void )
{
	char *host_status = (char *)0xffffa202L;
    long old_super_stack;
	int s;
	
    old_super_stack = Super( 0L );
	s = *host_status & 0x03;
    Super((void *) old_super_stack );
    return( s );
}

void read_inf( void )						/* DSPSHELL.INF lesen */
{
	int handle;
	char *ptr;

	Dsetpath( path );	
	handle = (int) Fopen( "DSPSHELL.INF", FO_READ );
	if ( handle < 0 ) {						/* kein INF gefunden */
		strcpy( editor, path );				/* Editor */
		strcat( editor, "\\EVEREST.PRG" );
		strcpy( assembler, path );			/* Assembler */
		strcat( assembler, "\\A56.TTP" );
		strcpy( dspfile, path );
		strcat( dspfile, "\\DEFAULT.A56" );
		strcpy( cpufile, path );
		strcat( cpufile, "\\XXXXXXXX.PRG" );
	}
	else {
		Fread( handle, 256L, buffer );		/* INF lesen */
		Fclose( handle );
		ptr = buffer;
		strcpy( editor, ptr );
		while( *ptr++ );
		strcpy( assembler, ptr );
		while( *ptr++ );
		strcpy( dspfile, ptr );
		while( *ptr++ );
		strcpy( cpufile, ptr );		
		while( *ptr++ );
		cpu = (int)*ptr;
	}

}

void write_inf( void )						/* DSPSHELL.INF schreiben */
{
	int handle;
	char *ptr;

	Dsetpath( path );	
	handle = (int) Fcreate( "DSPSHELL.INF", 0 );
	if ( handle < 0 ) {
		error( "kann INF-Datei nicht er”ffnen" );
		return;
	}
	ptr = buffer;
	strcpy( ptr, editor );
	while( *ptr++ );
	strcpy( ptr, assembler );
	while( *ptr++ );
	strcpy( ptr, dspfile );
	while( *ptr++ );
	strcpy( ptr, cpufile );
	while( *ptr++ );
	*ptr++ = (char) cpu;
	Fwrite( handle, ptr - buffer , buffer );
	Fclose( handle );
}

void set_files( void )
{
	char *ptr;
	
	*ass_cmd = 0;
	*ass_lst = 0;
	*ass_out = 0;

	strcpy( ass_out, dspfile );
	ptr = strrchr( ass_out, '.' );	
	*++ptr = '\0';						/* Fileextension abtrennen */

	strcpy( dspobj, cpufile );			/* Objectfile */
	*strrchr( dspobj, '\\' ) = 0; 
	strcat( dspobj, strrchr( ass_out, '\\' ) );
	strcat( dspobj, "O" );
		
	strcpy( ass_lst, ass_out );
	strcat( ass_out, "DSP" );
	strcat( ass_lst, "LST" );

	strcpy( ass_cmd, " -o " );
	strcat( ass_cmd, ass_out );
	strcat( ass_cmd, " " );
	strcat( ass_cmd, dspfile );
	*ass_cmd = (char) strlen( ass_cmd );	/* kein C-String !! */
}

int file_select( char *fname )
{
	int button;
	char work_path[128];
	char work_name[16];
	char *ptr;
	
	strcpy( work_path, fname );
	ptr = strrchr( work_path, '\\' );
	strcpy( work_name, ++ptr );			/* Filename */
	strcpy( ptr, "*.*\0" );				/* Pfad abtrennen */
	graf_mouse( M_ON, 0 );	
	fsel_input(work_path, work_name, &button);
	graf_mouse( M_OFF, 0 );
	if ( button ) {
		ptr = strrchr( work_path, '\\' );
		*++ptr = '\0';
		strcpy( fname, work_path );
		strcat( fname, work_name );		
		return( 1 );
	}
	return( 0 );		
}

void error( char *txt)
{
	printf("%s", txt );
	getch();
}
