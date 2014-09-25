/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include <sglib.h>

#include "setedit.hh"
#include "set_edit.h"

int SetEdit::set_file_items[10] =
    {
    	TS_SET0, TS_SET1, TS_SET2, TS_SET3, TS_SET4,
	TS_SET5, TS_SET6, TS_SET7, TS_SET8, TS_SET9
    };

int SetEdit::set_items[20] =
    { 
      TS_S1,  TS_S2,  TS_S3,  TS_S4,  TS_S5,
      TS_S6,  TS_S7,  TS_S8,  TS_S9,  TS_S10,
      TS_S11, TS_S12, TS_S13, TS_S14, TS_S15, 
      TS_S16, TS_S17, TS_S18, TS_S19, TS_S20
    };

int SetEdit::disk_items[20] =
    { 
      TS_D1,  TS_D2,  TS_D3,  TS_D4,  TS_D5,
      TS_D6,  TS_D7,  TS_D8,  TS_D9,  TS_D10,
      TS_D11, TS_D12, TS_D13, TS_D14, TS_D15, 
      TS_D16, TS_D17, TS_D18, TS_D19, TS_D20
    };

int SetEdit::drive_items[16] =
    {
      TS_DRVA,TS_DRVB,TS_DRVC,TS_DRVD,
      TS_DRVE,TS_DRVF,TS_DRVG,TS_DRVH,
      TS_DRVI,TS_DRVJ,TS_DRVK,TS_DRVL,
      TS_DRVM,TS_DRVN,TS_DRVO,TS_DRVP
    };



SetEdit::SetEdit() :
 set_scroll( this, TS_SLBOX, TS_SUP, TS_SDN, TS_STHUM, TS_SGRAY, 
 		0, 15, 15, TRUE ),
 disk_scroll( this, TS_DSBOX, TS_DUP, TS_DDN, TS_DTHUM, TS_DGRAY,
 		0, 15, 15, TRUE )
	
{
	InitDesk( SGGetTree( TR_SET ) );
	cur_drive=-1;
	cur_song=0;
	cur_file=-1;
	done=FALSE;
	top_song=0;
	changed=FALSE;
	top_file=0;
	current_set=0;
	cancelled=FALSE;


	Select( set_file_items[0] );

	set=new SetFile("SETV7.0 PERFORM " );

	dir=new DirList( 512 );

}



Boolean SetEdit::DoIt()
{
	//Draw();
	UpdateDriveBox();
	UpdateSetBox();
	UpdateDirBox();
	set_scroll.Refresh();
	disk_scroll.Refresh();
		
	int obj;
	
	Draw();
	LogDrive( Dgetdrv() );
	
	Select( drive_items[cur_drive] );
	DrawItem( drive_items[cur_drive] );
	
	CreateSetFileName();	
	
	Load();
	while( !done )
	{
		ObjectClick( obj=form_do( o.d, 0 ) );
	}
	return !cancelled;
}


Boolean SetEdit::ObjectClick( int obj )
{
	if( SelectSet( obj ) )
		return TRUE;	
	if( SelectDrive( obj ) )
		return TRUE;
	if( ScrollSet(obj) )
		return TRUE;
	if( ScrollDir(obj) )
		return TRUE;
	if( SelectSong(obj) )
		return TRUE;
	if( SelectFile(obj) )
		return TRUE;


	obj&=0x7fff;
	if( obj==TS_ERASE )
	{
		EraseAll();
		DeSelect( obj );
		DrawItem( obj );
		return TRUE;
	}
	else if( obj==TS_DEL )
	{
		Delete();
		DeSelect( obj );
		DrawItem( obj );
		return TRUE;
	}
	else if( obj==TS_SAVE )
	{
		Save();
		DeSelect( obj );
		DrawItem( obj );
		return TRUE;
	}
	else if( obj==TS_LOAD )
	{
		QuerySave();
		Load();
		DeSelect( obj );
		DrawItem( obj );
		return TRUE;
	}
	else if( obj==TS_OK )
	{
		DeSelect( obj );
		DrawItem( obj );
		done=TRUE;
		cancelled=FALSE;
		QuerySave();
		return TRUE;
	}
	else if( obj==TS_PRINT )
	{
		DeSelect( obj );
		DrawItem( obj );
		Print();
		return TRUE;
	}
	return FALSE;	
}

Boolean SetEdit::SelectSet( int obj )
{
	obj=obj&0x7fff;
	for( unsigned short i=0; i<10; i++ )
	{
		if( set_file_items[i]==obj )
		{
			QuerySave();
			current_set=i;
			CreateSetFileName();
			Load();
			return TRUE;
		}	
	}
	return FALSE;
}

Boolean SetEdit::SelectDrive( int obj )
{
	obj=obj&0x7fff;
	for( int i=0; i<16; i++ )
	{
		if( drive_items[i]==obj )
		{
			//QuerySave();
			LogDrive( i );
			//CreateSetFileName();
			//Load();
			return TRUE;
		}
	}
	return FALSE;
}


Boolean SetEdit::ScrollSet( int obj )
{
	if( set_scroll.Click( obj ) )
	{
		top_song=set_scroll.GetValue();
		UpdateSetBox();
		RedrawSetBox();
		return TRUE;
	}
	return FALSE;

}


Boolean SetEdit::ScrollDir( int obj )
{
	if( disk_scroll.Click( obj ) )
	{
		top_file=disk_scroll.GetValue();
		UpdateDirBox();
		RedrawDirBox();
		return TRUE;
	}
	return FALSE;

}


Boolean SetEdit::SelectSong( int obj )
{
	obj=obj&0x7fff;
	
	for( int i=0; i<20; i++ )
	{
		if( set_items[i]==obj )
		{
			cur_song=top_song+i;
			return TRUE;
		}
	}
	return FALSE;
}


Boolean SetEdit::SelectFile( int obj )
{
	for( int i=0; i<20; i++ )
	{
		if( disk_items[i]==obj&0x7fff )
		{
			if( top_file+i >= dir->GetNumberFiles() )
			{
				DeSelect( obj&0x7fff );
				DrawItem( obj&0x7fff );
				return TRUE;
			}
			
			if( cur_song > set->GetNumber() )
				cur_song = set->GetNumber();
			
			cur_file=top_file+i;

			set->Insert( dir->GetFileName( cur_file ), cur_song );
			changed=TRUE;
			cur_song++;
			if( cur_song > top_song+19 )
				top_song++;
			if( top_song>cur_song )
				top_song=cur_song;
				
			DeSelect( obj );
			
			UpdateSetBox();
			UpdateDirBox();
			RedrawSetBox();
			RedrawDirBox();
			return TRUE;
		}
	}
	return FALSE;
}
	
void SetEdit::EraseAll()
{
	set->EraseAll();
	cur_song=0;
	top_song=0;
	UpdateSetBox();
	RedrawSetBox();
	changed=TRUE;
}

void SetEdit::Insert()
{
	set->Insert( "", cur_song );
	UpdateSetBox();
	RedrawSetBox();
	changed=TRUE;
}

void SetEdit::Delete()
{
	set->Delete( cur_song );
	UpdateSetBox();
	RedrawSetBox();
	changed=TRUE;
}
	
void SetEdit::UpdateSetBox()
{
	if( set->GetNumber()>15 )
		set_scroll.SetMaximum( set->GetNumber()-15 );
	else
		set_scroll.SetMaximum(0);
		
	set_scroll.SetValue( top_song );
	set_scroll.Refresh();
	
	unsigned short entry;
	for( unsigned short obj=0; obj<20; obj++ )
	{
		entry=obj+top_song;
		if( entry>=set->GetNumber() )
		{
			sprintf( GetText( set_items[obj] ),
				"%3d:%12s", entry+1, "" );
		}
		else
		{
			sprintf( GetText( set_items[obj] ),
				"%3d:%12s", entry+1, set->Get( entry ) );
		}
		DeSelect( set_items[obj] );
	}
	if( cur_song-top_song >=0 && cur_song-top_song<20 )
	{
		Select( set_items[cur_song-top_song] );
	}
}


void SetEdit::UpdateDirBox()
{
	if( dir->GetNumberFiles()>15 )
		disk_scroll.SetMaximum( dir->GetNumberFiles()-15 );
	else
		disk_scroll.SetMaximum(0);


	disk_scroll.SetValue( top_file );
	disk_scroll.Refresh();

	unsigned short entry;
	for( unsigned short obj=0; obj<20; obj++ )
	{
		entry=obj+top_file;
		if( entry>=dir->GetNumberFiles() )
		{
			strcpy( GetText( disk_items[obj] ), 
				"                " ); 
		}
		else
		{
			sprintf( GetText( disk_items[obj] ),
				"%3d:%12s", entry+1, 
					dir->GetFileName( entry ) );
		}
	}
}

	
void SetEdit::UpdateDriveBox()
{
	for( unsigned int i=0; i<16; i++ )
	{
		if( ! (Drvmap() & (1<<i)) )
			Disable( drive_items[i] );
		DeSelect( drive_items[i] );
	}
}

void SetEdit::RedrawSetBox()
{
	for( register unsigned short i=0; i<20; i++ )
	{
		DrawItem( set_items[i] );
	}
	set_scroll.Draw();
}


void SetEdit::RedrawDirBox()
{
	for( register unsigned short i=0; i<20; i++ )
	{
		DrawItem( disk_items[i] );
	}
	disk_scroll.Draw();
}

void SetEdit::LogDrive( int drive )
{
	cur_drive=drive;

	dir->Search( JKForm64( "%c:\\SONGS\\*.MID", drive+'A' )  );	
	dir->Sort();
	
	//changed=FALSE;
	top_file=0;
	UpdateDirBox();
	RedrawDirBox();
}

void SetEdit::QuerySave()
{
#if 0
	changed=FALSE;
#else
	if( changed==TRUE )
	{
		if( form_alert( 1, JKForm64( 
	"[2][Your set file has changed. |Save it first?][ YES | NO ]",
		set_file_name ) 
			)==1 )
		{
			Save();
		}
		changed=FALSE;
	}
#endif
}

void SetEdit::Save()
{
	set->Save( set_file_name );
	changed=FALSE;
}

void SetEdit::Load()
{

	set->EraseAll();
	CreateSetFileName();
	set->Load( set_file_name );
	top_song=0;
	cur_song=0;
	
	UpdateSetBox();
	RedrawSetBox();
}

void SetEdit::CreateSetFileName()
{
	if( cur_drive==-1 )
		sprintf( set_file_name, "PERFORM%d.SET", current_set );
	else
		sprintf( set_file_name, "%c:PERFORM%d.SET", cur_drive+'A',
			current_set );
}

void SetEdit::PrintLine( char *s )
{
	while( *s )
		Bconout( 0, *s++ );
}

void SetEdit::Print()
{
	if( !Bcostat(0) )
		return;
	PrintLine( JKForm64( "SET FILE: %s\r\n\r\n", set_file_name ) );
	for( short i=0; i< set->GetNumber(); i++ )
	{
		PrintLine( JKForm64( "        %3d :  %s\r\n", i+1, set->Get( i ) ));
	}
	Bconout( 0, 11 );
}
