#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>

#define TRUE 1
#define FALSE 0

#define ALTERNATE 0x0008	/*	graf_mkstate()	*/
#define USER_OK 1			/*	fsel_input()	*/

#define CNCLBTN 5		/*	Set-up box object	*/
#define OKBTN 7

#define PARALLEL 0		/*	Printer port		*/
#define SERIAL 1

#define NAMESTRG 1		/*	Working box object	*/
#define BTN1 2
#define BTN2 3
#define BTN3 4
#define BTN4 5
#define BTN5 6
#define BTN6 7
#define BTN7 8
#define BTN8 9
#define SAVEBTN 10
#define LOADBTN 11
#define DONEBTN 12

int	contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];
int work_in[11], work_out[57];

extern int gl_apid;

TEDINFO rs_tedinfo[] = {
  {"________", "________", "X",
    3,   6,   0, 4480,   0, 255,   9,   9},
  {"_________________________________", "_________________________________", "X",
    3,   6,   0, 4480,   0, 255,  34,  34}
};

OBJECT setupbox[] = {
  {  -1,   1,   7,0x0014,0x0000,0x0010, 0x00021100L,   0,   0,  37,   10 },
  {   2,  -1,  -1,0x001C,0x0000,0x0000, "Button name:",   2,   1,  12,   1},
  {   3,  -1,  -1,0x001E,0x0008,0x0000, &rs_tedinfo[0],  15,   1,   8,   1},
  {   4,  -1,  -1,0x001C,0x0000,0x0000, "Codes:",   2,   3,   6,   1},
  {   5,  -1,  -1,0x001D,0x0008,0x0000, &rs_tedinfo[1],   2,   4,  33,   1},
  {   6,  -1,  -1,0x001C,0x0000,0x0000, 0L,   2,   6,   33,   1},
  {   7,  -1,  -1,0x001A,0x0005,0x0000, "Cancel",   8,   8,   8,   1},
  {   0,  -1,  -1,0x001A,0x0027,0x0000, "OK",  21,   8,   8,   1}
};

OBJECT workbox[] = {
  {  -1,   1,  12,0x0014,0x0000,0x0010, 0x00021100L,   0,   0,  30,  14},
  {   2,  -1,  -1,0x001C,0x0000,0x0000, 0L,   2,   1,  26,   1},
  {   3,  -1,  -1,0x001A,0x0041,0x0000, 0L,   3,   3,  10,   1},
  {   4,  -1,  -1,0x001A,0x0041,0x0000, 0L,   3,   5,  10,   1},
  {   5,  -1,  -1,0x001A,0x0041,0x0000, 0L,   3,   7,  10,   1},
  {   6,  -1,  -1,0x001A,0x0041,0x0000, 0L,   3,   9,  10,   1},
  {   7,  -1,  -1,0x001A,0x0041,0x0000, 0L,  17,   3,  10,   1},
  {   8,  -1,  -1,0x001A,0x0041,0x0000, 0L,  17,   5,  10,   1},
  {   9,  -1,  -1,0x001A,0x0041,0x0000, 0L,  17,   7,  10,   1},
  {  10,  -1,  -1,0x001A,0x0041,0x0000, 0L,  17,   9,  10,   1},
  {  11,  -1,  -1,0x001A,0x0041,0x0000, 0L,   3,  12,   6,   1},
  {  12,  -1,  -1,0x001A,0x0041,0x0000, 0L,  10,  12,   6,   1},
  {   0,  -1,  -1,0x001A,0x0027,0x0000, 0L,  19,  12,   8,   1}
};

int magic = 0xDEAD;
int menu_id, dummy, msgbuff[8];
int work_x, work_y, work_w, work_h;
int setup_x, setup_y, setup_w, setup_h;
char msg[80], default_path[64];

char *button_string[] = { "", "TWinpEAKS  \275 Martyn Dryden", 
"BUTTON 1", "BUTTON 2", "BUTTON 3", "BUTTON 4", 
"BUTTON 5", "BUTTON 6", "BUTTON 7", "BUTTON 8", 
"Save", "Load", "Done!"
};

char *code_help = "ESC ^[   Return ^M   Tab ^I etc";

char *codes_string[] = { "", "", 
"@                                ", 
"@                                ", 
"@                                ", 
"@                                ", 
"@                                ", 
"@                                ", 
"@                                ", 
"@                                ", 
"", 
"", 
""
};

main()
{
	appl_init();
	menu_id = menu_register( gl_apid,"  TWinpEAKS" );
	initialise();
	multi();
}

multi()
{
	int event, button;

	while (TRUE) {
		event = evnt_multi( MU_MESAG,
			0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			msgbuff, 0, 0,
			&dummy, &dummy, &dummy, &dummy, &dummy, &dummy );

		if (event & MU_MESAG) {
			switch (msgbuff[0]) {

				case AC_OPEN:
					if (msgbuff[4] == menu_id) {
						button = do_work();
					}
	    			break;

				default:
					break;

			} /* end of switch( msgbuff ) */
		} /* end of if MESAG	*/
	} /* end of while (TRUE) */
}

initialise()
{
	register int i;
	int err, fd;

	for(i=0; i<8; i++)
		rsrc_obfix(setupbox, i);
	setupbox[5].ob_spec = code_help;

	for(i=0; i<13; i++)
		rsrc_obfix(workbox, i);
	for(i=1; i<13; i++)
		workbox[i].ob_spec = button_string[i];

/*	Set dialog dimensions	*/
	form_center( workbox, &work_x, &work_y, &work_w, &work_h );
	form_center( setupbox, &setup_x, &setup_y, &setup_w, &setup_h );

	default_path[0]=Dgetdrv()+'A';
	default_path[1]=':';
	Dgetpath(&default_path[2],0);

/*	Load default tweaks file if any	*/
	err = Fsfirst( "DEFAULT.TWK", 0x003F );
	if( !err ) {
		fd = Fopen( "DEFAULT.TWK", 0);
		if ( fd >= 0 ) {
			Fread( fd, 2L, &magic );
			if( magic != 0xDEAD ) {
				magic = 0xDEAD;
			} else {
				Fread( fd, 26L, button_string[ NAMESTRG] );
				for( i = BTN1; i <= BTN8 ; i++ ) {
					Fread( fd, 8L, button_string[i] );
					Fread( fd, 33L, codes_string[i] );
				}
			}
			Fclose( fd );
		}
	}
}

do_work()
{
	int i, itemhit, edit_result, keys;

	for(i=0; i<13; i++)
		workbox[i].ob_state = NORMAL;

	wind_update( BEG_UPDATE );
	form_dial( FMD_START, 0, 0, 0, 0, work_x, work_y, work_w, work_h );
	objc_draw( workbox, 0, 10, work_x, work_y, work_w, work_h );

	itemhit = FALSE;
	while( itemhit != DONEBTN ) {

		itemhit = form_do( workbox, 0 );

		switch( itemhit ) {
			case LOADBTN:
			case SAVEBTN:
					form_dial( FMD_FINISH, 0, 0, 0, 0, work_x, work_y, work_w, work_h );
					wind_update( END_UPDATE );
					fix_damage();
					handle_file( itemhit );
					wind_update( BEG_UPDATE );
					fix_damage();
					form_dial( FMD_START, 0, 0, 0, 0, work_x, work_y, work_w, work_h );
					objc_draw( workbox, 0, 10, work_x, work_y, work_w, work_h );
				break;

			case BTN1:
			case BTN2:
			case BTN3:
			case BTN4:
			case BTN5:
			case BTN6:
			case BTN7:
			case BTN8:
				graf_mkstate( &dummy, &dummy, &dummy, &keys );
				if( keys & ALTERNATE ) {
					form_dial( FMD_FINISH, 0, 0, 0, 0, work_x, work_y, work_w, work_h );
fix_damage();
					wind_update( END_UPDATE );
					edit_result = edit_button( itemhit );
					wind_update( BEG_UPDATE );
					form_dial( FMD_START, 0, 0, 0, 0, work_x, work_y, work_w, work_h );
					objc_draw( workbox, 0, 10, work_x, work_y, work_w, work_h );
				}
				else do_button( itemhit );
				break;

			default:
				break;
		}
		workbox[itemhit].ob_state = NORMAL;
		objc_draw( workbox, itemhit, 1, work_x, work_y, work_w, work_h );
	}
	form_dial( FMD_FINISH, 0, 0, 0, 0, work_x, work_y, work_w, work_h );
	wind_update( END_UPDATE );
	return( itemhit );
}

hide_mouse()
{
	graf_mouse(M_OFF,0x0L);
}

show_mouse()
{
	graf_mouse(M_ON,0x0L);
}

edit_button( which )
int which;
{
	int i, itemhit;

	for(i=0; i<7; i++)
		setupbox[i].ob_state = NORMAL;

	strcpy( rs_tedinfo[0].te_ptext, button_string[which] );
	strcpy( rs_tedinfo[1].te_ptext, codes_string[which] );

	wind_update( BEG_UPDATE );
	form_dial( FMD_START, 0, 0, 0, 0, setup_x, setup_y, setup_w, setup_h );
	objc_draw( setupbox, 0, 10, setup_x, setup_y, setup_w, setup_h );

	itemhit = form_do( setupbox, 2 );

	setupbox[itemhit].ob_state = NORMAL;
	objc_draw( setupbox, itemhit, 1, setup_x, setup_y, setup_w, setup_h );
	form_dial( FMD_FINISH, 0, 0, 0, 0, setup_x, setup_y, setup_w, setup_h );
	wind_update( END_UPDATE );
	fix_damage();

	if( itemhit == OKBTN ) {
		strcpy( button_string[which], rs_tedinfo[0].te_ptext );
		strcpy( codes_string[which], rs_tedinfo[1].te_ptext );
	}
	return( itemhit );
}

do_button( which )
int which;
{
	int i, butn_x, butn_y, butn_w, butn_h, config, device, code, waits;

	butn_x = workbox[0].ob_x + workbox[which].ob_x;
	butn_y = workbox[0].ob_y + workbox[which].ob_y;
	butn_w = workbox[which].ob_width;
	butn_h = workbox[which].ob_height;

	config = Setprt( -1 );
	if( config & 16 ) device = SERIAL;
	else device = PARALLEL;

	if( ( codes_string[which][0] == '@' ) || !(strlen(codes_string[which]) ) )
		form_alert( 1, "[1][  No codes defined  |  for this button.  |  Hold Alternate  |  and click button |  to define codes.  ][ Righty-ho ]" );
	else {

		for( i=0 ; i<strlen(codes_string[which]) ; i++ ) {
			workbox[which].ob_state = SELECTED;
			objc_draw( workbox, which, 1, work_x, work_y, work_w, work_h );

			code = codes_string[which][i] & 0x00FF;
			waits = 0;
			while( ( !Bcostat( device ) ) && ( waits < 1000 ) ) waits++;
			if( waits < 1000 ) Bconout( device, code );
			else {
				form_alert( 1, "[1][  |  Printer not responding  |  ][  OK  ]" );
				i = strlen( codes_string[which] );
			}
			workbox[which].ob_state = NORMAL;
			objc_draw( workbox, which, 1, work_x, work_y, work_w, work_h );
		}
	}
}

/*	Allow AES to pre-empt us and send out redraw messages	*/
fix_damage()
{
	int event, message[8];

	hide_mouse();
	do {
		event = evnt_multi(  MU_TIMER,   
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			message,			/* message buffer 	*/
			10, 0,				/* Wait 10ms		*/
			&dummy,	&dummy,	&dummy,	&dummy,	&dummy,	&dummy );
	} while( !(event & MU_TIMER) );
	show_mouse();
}

handle_file( action )
int action;
{ /* HERE */
	int i, fd, button, ok;
	char path[64], fname[16], fspec[80];
	char *ptr;

	strcpy( path, default_path );
	strcat( path, "\\*.TWK" );
	strcpy( fname, "");

	wind_update( BEG_UPDATE );
	fsel_input( path, fname, &button);
	fix_damage();
	wind_update( END_UPDATE );

	strcpy( fspec, path );
	trunname( fspec );

	if ( button == USER_OK ) {
		strcpy( default_path, fspec );
		default_path[ strlen(default_path) - 1 ] = '\0';
		strcat( fspec, fname );

/*	Cursor = busy bee	*/
		hide_mouse();
		graf_mouse( 2, &dummy );
		show_mouse();

		if( action == LOADBTN ) {
/*	Try to open the read file	*/
			fd = Fopen( fspec, 0);
			if ( fd < 0 ) {
				graf_mouse( 0, &dummy );
	wind_update( BEG_UPDATE );
				form_alert( 1, "[1][  |  Can't open the file   |  ][  Oh  ]" );
	wind_update( END_UPDATE );
			} else {
				Fread( fd, 2L, &magic );
				if( magic != 0xDEAD ) {
	wind_update( BEG_UPDATE );
					form_alert( 1, "[1][  |  Doesn't seem to  |  be a TWin pEAKS  |  file  |  ][  H'mmm ]" ); 
	wind_update( END_UPDATE );
					magic = 0xDEAD;
				} else {
					Fread( fd, 26L, button_string[ NAMESTRG] );
					for( i = BTN1; i <= BTN8 ; i++ ) {
						Fread( fd, 8L, button_string[i] );
						Fread( fd, 33L, codes_string[i] );
					}
				}
				Fclose( fd );
			}
		} else {	/*	It's a write file job	*/

/*	Chop off extn if any	*/
			for( i=strlen(fspec)-1 ; i>0 ; i-- ) {
				if( fspec[i] == '.' ) {
					fspec[i] = '\0';
					break;
				}
			}
/*	Add the right extn	*/
			strcat( fspec, ".TWK" );

/*	Does the file already exist?	*/
			ok = Fsfirst( fspec, 0x003F );
	wind_update( BEG_UPDATE );
			if( !ok ) button = form_alert( 1, "[1][  |  File exists!  |  OK to replace?  |  ][ Cancel |  OK  ]" );
	wind_update( END_UPDATE );
			if( button == 2 ) ok = TRUE;
			if( ok ) {

/*	Try to open the write file	*/
				fd = Fcreate( fspec, 0 );
				if (fd < 0) {
					graf_mouse( 0, &dummy );
	wind_update( BEG_UPDATE );
					form_alert( 1, "[1][  | Can't create the file  |  ][  Oh  ]" );
	wind_update( END_UPDATE );
				} else {
					Fwrite( fd, 2L, &magic );
					Fwrite( fd, 26L, button_string[ NAMESTRG] );
					for( i = BTN1; i <= BTN8 ; i++ ) {
						Fwrite( fd, 8L, button_string[i] );
						Fwrite( fd, 33L, codes_string[i] );
					}
					Fclose( fd );
					graf_mouse( 0, &dummy );
				}
			}
			else {
				wind_update( BEG_UPDATE );
				form_alert( 1, "[1][  |  The file was  |  not written  |  ][  OK  ]" );
				wind_update( END_UPDATE );
			}
		}

/*	Cursor = arrow	*/
		graf_mouse( 0, &dummy );
	}
}

trunname(string)
char *string;
{
	register int i;

	for( i=strlen(string) ; i >=0 ; --i )
		if( string[i] == 92 ) break;
	string[i+1]=0;
}
