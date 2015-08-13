/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 


#include <midi/midiscrn.hh>



MIDIScrn::MIDIScrn( ushort type, ushort channel )
{
	scrn_type=type;
	scrn_channel=channel;
}


void MIDIScrn::Set( char *long_text, char *short_text )
{
	Clear();

	switch( scrn_type )
	{
	case DISP_TYPE_D50:
		d50( scrn_channel, long_text );
		break;
	case DISP_TYPE_MT32:
		mt32( scrn_channel, short_text );
		break;
	case DISP_TYPE_D10:
		d10( scrn_channel, long_text );
		break;
	case DISP_TYPE_JX8P:
		jx8p( scrn_channel, short_text );
		break;
	case DISP_TYPE_DX7:
		dx7( scrn_channel, short_text );
		break;
	case DISP_TYPE_JUNO1:
		juno1( scrn_channel, short_text );
		break;
	case DISP_TYPE_U20:
		u20( scrn_channel, long_text );
		break;
	case DISP_TYPE_JD800:
		jd800( scrn_channel, long_text );
		break;
	case DISP_TYPE_NONE:
	default:
		break;
	}

}



void MIDIScrn::d50( ushort chan, char *s )
{

	if( chan>15 )
		return;


	Add( M_EXCL );
	Add( 0x41 );
	Add( chan );
	Add( 0x14 );
	Add( 0x12 );
	
	AddChk( 0x00 );
	AddChk( 0x03 );
	AddChk( 0x00 );
	
	ushort len=strlen(s);
	
	for( register ushort i=0; i<18; i++ )
	{
		if( i>=len ) 
		{
			AddChk( 0x00 );
			continue;
		}

		register char c=s[i];
		
		if( isupper(c) ) 
		{
			c-='A'-1;
			AddChk( c );
			continue;
		}
		if( islower(c) ) 
		{
			c-='a'-1;
			c+=26;
			AddChk( c );
			continue;
		}
		if( c=='0' ) 
		{
			AddChk( 62 );
			continue;
		}
		if( isdigit(c) )
		{
			c-='0';
			c+=52;
			AddChk( c );
			continue;
		}
		if( c=='-' )
		{
			AddChk( 63 );
			continue;
		}
		AddChk( 0 );
		continue;
	}

	CalcSum();
	Eox();

}

void MIDIScrn::mt32( ushort chan, char *s )
{
	
	if(  chan>32 ) return;



	Add( M_EXCL );
	Add( 0x41 );
	Add( chan );
	Add( 0x16 );
	Add( 0x12 );
	
	AddChk( 0x20 );
	AddChk( 0x00 );
	AddChk( 0x00 );
	
	ushort l=strlen( s );
	
	for( ushort i=0; i<32; i++ ) 
	{
		if( i<l ) 
			AddChk( s[i] );
		else
			AddChk( ' ' );
	}

	CalcSum();
	Eox();

}

void MIDIScrn::d10( ushort chan, char *s )
{
	mt32( chan, s );
}

void MIDIScrn::jx8p( ushort chan, char *s )
{

	if( chan>15 ) return;


	Add( M_EXCL );
	Add( 0x41 );
	Add( 0x36 );
	Add( chan );
	Add( 0x21 );
	Add( 0x20 );
	Add( 0x01 );
	
	ushort l=strlen(s);

	for( ushort i=0; i<10; i++ )
	{
		Add( i );
		if( i>=l )
			Add( ' ' );
		else
			Add( s[i] );
	}
	
	Eox();
	

}

void MIDIScrn::dx7( ushort chan, char *s )
{
	if(  chan>15 ) return;
	
	ushort len=strlen( s );
	uchar c;

	for( ushort i=0; i<10; i++ )
	{
		if( i<len )
			c=s[i];
		else
			c=' ';
		
		Clear();
		Add( M_EXCL );
		Add( 0x43 );
		Add( 0x10+chan );
		Add( 0x01 );
		Add( 0x11+i );
		Add( c );
		Eox();
		

	}

}

void MIDIScrn::u20( ushort chan, char *s )
{

	if( chan>32 ) return;
	
	ushort l=strlen(s);

	Add( M_EXCL );
	Add( 0x41 );
	Add( chan );
	Add( 0x2b );    // u-20, u-220
	Add( 0x12 );    // data set

	AddChk( 0x00 );
	AddChk( 0x01 );
	AddChk( 0x01 );
	
	ushort ch;
	
	for( ushort i=0; i<12; i++ ) 
	{
		if( i>=l )
			ch=' ';
		else
			ch=s[i];
			
		AddChk( ch&0x0f );
		AddChk( (ch>>4)&0x0f );
	}

	CalcSum();
	Eox();


}

void MIDIScrn::juno1( ushort chan, char *s )
{

}

void MIDIScrn::jd800( ushort chan, char *s )
{
	if( chan>32 ) return;


	Add( M_EXCL );
	Add( 0x41 );
	Add( chan );
	Add( 0x3d );
	Add( 0x12 );
	AddChk( 0x07 );
	AddChk( 0x00 );
	AddChk( 0x00 );
	
	while( *s )
	{
		AddChk( (*s++)&0x7f );
	}
	CalcSum();
	Eox();
}

