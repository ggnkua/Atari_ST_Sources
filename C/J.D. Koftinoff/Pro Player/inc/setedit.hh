
#ifndef __SETEDIT_HH
#define __SETEDIT_HH


#include "sgdesk.hh"
#include "dirlist.hh"
#include "setfile.hh"
#include "sgscrbar.hh"


class SetEdit : public SGDesk
{
private:
	SGScrollBar set_scroll;
	SGScrollBar disk_scroll;
	
protected:
	static int set_file_items[10];
	static int set_items[20];
	static int disk_items[20];
	static int drive_items[16];

	char set_file_name[32];
	
	int cur_drive;
	int cur_song;
	int cur_file;
	
	int top_song;
	int top_file;
	
	int current_set;
	
	int done;
	int cancelled;
	Boolean changed;

	Boolean ObjectClick( int obj );

	Boolean SelectSet( int obj );
	Boolean SelectDrive( int obj );
	Boolean ScrollSet( int obj );
	Boolean ScrollDir( int obj );
	Boolean SelectSong( int obj );
	Boolean SelectFile( int obj );
		
	void EraseAll();
	void Insert();
	void Delete();
	
	void UpdateSetBox();
	void UpdateDirBox();	
	void UpdateDriveBox();
	
	void RedrawSetBox();
	void RedrawDirBox();
	
	void LogDrive( int drive );
	void CreateSetFileName();	
	
	void Print();
	void PrintLine( char *s );
public:
	SetFile *set;
	DirList *dir;
	
	SetEdit();
	virtual ~SetEdit();
	
	Boolean DoIt();
	
	void QuerySave();
	void Save();
	void Load();
};



inline SetEdit::~SetEdit()
{
	delete set;
	delete dir;
}

#endif

