
#ifndef __CFGEDIT_HH
#define __CFGEDIT_HH


#include "sgdesk.hh"
#include "cfg_type.h"


class CfgEdit : public SGDesk
{
protected:
	
	int cur_drive;
	Boolean changed;
	int done;
	Configuration *cfg;
	static int drive_items[16];

	Boolean ObjectClick( int obj );
	Boolean SelectParam( int obj );
	Boolean SelectDrive( int obj );

	void UpdateDriveBox();
	void UpdateParams();
	void DrawParams();
	
	void LogDrive( int drive );

public:
	CfgEdit();
	virtual ~CfgEdit();
	
	Boolean DoIt();
	
	void QuerySave();
	void Save();
	void Load();
};


inline CfgEdit::~CfgEdit()
{
	delete cfg;
}

#endif

