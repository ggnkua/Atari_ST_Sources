#include <stdio.h>
#include <dsplib.h>

#define __GNU__
#define __TCC_COMPAT__

#ifndef __GNU__
 #include <aes.h>
#else
 #include <gemfast.h>
 #include <aesbind.h>
 #define obspec			ob_spec
 extern int _app;
#endif

#include "mplex.h"

#ifndef AP_TERM
#define AP_TERM		50
#endif

int		ap_id;
int		menu_id;
int		freq = 1;
int		fmt = 1;
int		src[4] = { 0, 0, 0, 0 };
int		ltatten, rtatten, ltgain, rtgain;
int		adderin = 0;
int		adcinput;
int		shake = NO_SHAKE;

char	*freq_list[] = { 
					"",
					"49170 Hz",
					"32780 Hz",
					"24585 Hz",
					"19668 Hz",
					"16370 Hz",
					"",
					"12292 Hz",
					"",
					" 9834 Hz",
					"",
					" 8195 Hz",
					"" };
					
char	*fmt_list[] = {
					" 8 Stereo",
					"16 Stereo",
					" 8 Mono  " };

#define	DbSet(o,v)	(sprintf( (o)->obspec.tedinfo->te_ptext,"%2d.%1d", \
					 (((int)(v) >> 4) * 3) >> 1,				\
					 ((((int)(v) >> 4) * 3) & 1) * 5 ) )

void	do_dialog( OBJECT *tr, int x, int y, int w, int h )
{
	int		obj;
	int		done = 0;
	int		d, m;
	
	while ( !done )
	{
		switch( ( obj = form_do( tr, -1 ) & 0x7fff ) )
		{
		case OK:
		case CANCEL:	tr[obj].ob_state ^= SELECTED;
						done = 1;				break;
		case OL_P:		if ( ltgain < 0xf0 )
							ltgain += 0x10;
						DbSet( tr + OUT_L, ltgain );
						objc_draw( tr, OUT_L, 8, x, y, w, h );
						soundcmd( LTGAIN, ltgain );
						break;
		case OL_M:		if ( ltgain > 0x00 )
							ltgain -= 0x10;
						DbSet( tr + OUT_L, ltgain );
						objc_draw( tr, OUT_L, 8, x, y, w, h );
						soundcmd( LTGAIN, ltgain );
						break;
		case OR_P:		if ( rtgain < 0xf0 )
							rtgain += 0x10;
						DbSet( tr + OUT_R, rtgain );
						objc_draw( tr, OUT_R, 8, x, y, w, h );
						soundcmd( RTGAIN, rtgain );
						break;
		case OR_M:		if ( rtgain > 0x00 )
							rtgain -= 0x10;
						DbSet( tr + OUT_R, rtgain );
						objc_draw( tr, OUT_R, 8, x, y, w, h );
						soundcmd( RTGAIN, rtgain );
						break;
		case IL_P:		if ( ltatten > 0x00 )
							ltatten -= 0x10;
						DbSet( tr + IN_L, 0xf0 - ltatten );
						objc_draw( tr, IN_L, 8, x, y, w, h );
						soundcmd( LTATTEN, ltatten );
						break;
		case IL_M:		if ( ltatten < 0xf0 )
							ltatten += 0x10;
						DbSet( tr + IN_L, 0xf0 - ltatten );
						objc_draw( tr, IN_L, 8, x, y, w, h );
						soundcmd( LTATTEN, ltatten );
						break;
		case IR_P:		if ( rtatten > 0x00 )
							rtatten -= 0x10;
						DbSet( tr + IN_R, 0xf0 - rtatten );
						objc_draw( tr, IN_R, 8, x, y, w, h );
						soundcmd( RTATTEN, rtatten );
						break;
		case IR_M:		if ( rtatten < 0xf0 )
							rtatten += 0x10;
						DbSet( tr + IN_R, 0xf0 - rtatten );
						objc_draw( tr, IN_R, 8, x, y, w, h );
						soundcmd( RTATTEN, rtatten );
						break;
		case OUT_ADC:	adderin ^= 1;
						soundcmd( ADDERIN, adderin );
						break;
		case OUT_CODEC:	adderin ^= 2;
						soundcmd( ADDERIN, adderin );
						break;
		case MICRO:		adcinput = 0;
						soundcmd( ADCINPUT, adcinput );
						break;
		case CHIP:		adcinput = 3	;
						soundcmd( ADCINPUT, adcinput );
						break;
		case SHAKE_ON:	shake ^= 1;
						goto connect;
		case FREQ_P:	if ( freq > 1 )
							while ( freq_list[--freq][0] == 0 );
						tr[FREQ].obspec.tedinfo->te_ptext = freq_list[freq];
						objc_draw( tr, FREQ, 8, x, y, w, h );
						goto connect;
		case FREQ_M:	if ( freq < 11 )
							while ( freq_list[++freq][0] == 0 );
						tr[FREQ].obspec.tedinfo->te_ptext = freq_list[freq];
						objc_draw( tr, FREQ, 8, x, y, w, h );
						goto connect;
		case FMT_P:		if ( fmt < 2 )
							fmt++;
						setsndmode( fmt );
						tr[FORMAT].obspec.tedinfo->te_ptext = fmt_list[fmt];
						objc_draw( tr, FORMAT, 8, x, y, w, h );
						break; 
		case FMT_M:		if ( fmt > 0 )
							fmt--;
						setsndmode( fmt );
						tr[FORMAT].obspec.tedinfo->te_ptext = fmt_list[fmt];
						objc_draw( tr, FORMAT, 8, x, y, w, h );
						break; 
		default:		d = obj - PATH - 1;
						if ( d < 0 || d > 15 )
							break;
						src[d >> 2] ^= (1 << (d % 4));
connect:
				devconnect( DMAPLAY, src[0], CLK25M, freq, shake );
				devconnect( DSPXMIT, src[1], CLK25M, freq, shake );
				devconnect( EXTINP, src[2], CLK25M, freq, shake );
				devconnect( ADC, src[3], CLK25M, freq, shake );
						break;
		}
		do
			graf_mkstate( &d, &d, &d, &m );
		while ( m );
		objc_draw( tr, obj, 8, x, y, w, h );
	}
}

void	do_it( void )
{
	int		buf[8];
	OBJECT	*tr;
	int		x, y, w, h;

	do	
	{
		while ( !_app )
		{
			evnt_mesag( buf );
			if ( buf[0] == AC_OPEN && buf[4] == menu_id )
				break;
			if ( buf[0] == AP_TERM )
				return;
		}
		if ( Dsp_GetWordSize() > 4 )
		{
			form_alert( 1, "[3][Sorry no DSP|availlable!][OK]" );
			return;
		}
		rsrc_gaddr( 0, DIALOG, &tr );
		if ( tr->ob_height < 200 )
		{
			form_alert( 1, "[3][Sorry, programm|does not run with|"
						   "this resolution!][OK]" );
			return;
		}
		dsptristate( ENABLE, ENABLE );
		ltatten = (int) soundcmd( LTATTEN, -1 );
		DbSet( tr + IN_L, 0xf0 - ltatten );
		rtatten = (int) soundcmd( RTATTEN, -1 );
		DbSet( tr + IN_R, 0xf0 - rtatten );
		ltgain = (int) soundcmd( LTGAIN, -1 );
		DbSet( tr + OUT_L, ltgain );
		rtgain = (int) soundcmd( RTGAIN, -1 );
		DbSet( tr + OUT_R, rtgain );
		adderin = (int) soundcmd( ADDERIN, -1 );
		if ( adderin & 1 )
			tr[OUT_ADC].ob_state |= SELECTED;
		else
			tr[OUT_ADC].ob_state &= ~SELECTED;
		if ( adderin & 2 )
			tr[OUT_CODEC].ob_state |= SELECTED;
		else
			tr[OUT_CODEC].ob_state &= ~SELECTED;
		adcinput = (int) soundcmd( ADCINPUT, -1 );
		if ( !adcinput )
		{
			tr[MICRO].ob_state |= SELECTED;
			tr[CHIP].ob_state &= ~SELECTED;
		}
		else
		{
			tr[MICRO].ob_state &= ~SELECTED;
			tr[CHIP].ob_state |= SELECTED;
			adcinput = 3;
		}
		form_center( tr, &x, &y, &w, &h );
		x -= 3;
		y -= 3;
		w += 6;
		h += 6;
		form_dial( FMD_START, x, y, w, h, x, y, w, h );
		wind_update( BEG_UPDATE );
		objc_draw( tr, 0, 8, x, y, w, h );
		do_dialog( tr, x, y, w, h );
		form_dial( FMD_FINISH, x, y, w, h, x, y, w, h );
		wind_update( END_UPDATE );
	} while ( !_app );
}

int		main( void )
{
	int		buf[8];
	
	ap_id = appl_init();

	if ( ap_id == -1 )
		return ( -1 );
		
	if ( rsrc_load( "MPLEX.RSC" ) )
	{
		if ( !_app )
			menu_id = menu_register( ap_id, "  Set Data path " );

		if ( _app || menu_id != -1 )
			do_it();
		else
		{
			form_alert( 1, "[1][Keine freien|"
						"Accessory-Eintr„ge][ OK ]" );
			do
				evnt_mesag( buf );
			while ( buf[0] != AP_TERM );
		}
	}
	else
	{
		form_alert( 1,	"[1][Resource-Datei|nicht gefunden]"
						"[ OK ]" );
		if ( !_app )
			do
				evnt_mesag( buf );
			while ( buf[0] != AP_TERM );
	}
	rsrc_free();
	appl_exit();
	return ( 0 );
}
