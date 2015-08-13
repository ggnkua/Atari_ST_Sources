/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include <sglib.hh>

#include "cfgedit.hh"
#include "cfg_edit.h"



int CfgEdit::drive_items[16] =
    {
      TC_DRVA,TC_DRVB,TC_DRVC,TC_DRVD,
      TC_DRVE,TC_DRVF,TC_DRVG,TC_DRVH,
      TC_DRVI,TC_DRVJ,TC_DRVK,TC_DRVL,
      TC_DRVM,TC_DRVN,TC_DRVO,TC_DRVP
    };

struct XlateTable
{
	int obj_id;
	int value;
};


struct Parameter
{
	long 	file_id;
	long 	rsc_id;
	char **	text;
	int 	min;
	int 	max;
	int	popup_tree;
	int	popup_hide;
	XlateTable *xlate_table;
};

static char *chan_text[] = // offset by one
{
	"None", 
	"  1 ", "  2 ", "  3 ", "  4 ", "  5 ", "  6 ", "  7 ",
	"  8 ", "  9 ", " 10 ", " 11 ", " 12 ", " 13 ", " 14 ",
	" 15 ", " 16 ", " All"
};

static char *unit_text[] =
{
	"None", 
	"  1 ", "  2 ", "  3 ", "  4 ", "  5 ", "  6 ", "  7 ",
	"  8 ", "  9 ", " 10 ", " 11 ", " 12 ", " 13 ", " 14 ",
	" 15 ", " 16 ", " 17 ", " 18 ", " 19 ", " 20 ", " 21 ",
	" 22 ", " 23 ", " 24 ", " 25 ", " 26 ", " 27 ", " 28 ",
	" 29 ", " 30 ", " 31 ", " 32 "
};

static char *disp_text[] =
{
	"None    ", "None    ", "D-50    ", "MT-32   ", "D-10    ",
	"JX-8P   ", "DX-7    ", "JUNO-1  ", "U-20    ", "JD-800  ",
	"unknown ", "unknown ", "unknown ", "unknown ", "unknown ",
	"unknown ", "unknown ", "unknown ", "unknown ", "unknown "
};

static char *ctrl_text[] =
{
	"None    ", "None    ", "PG-1    ", "PG-125  ", "Porta   ",
	"Hold    ", "PG-All  ", "unknown ", "unknown ", "unknown ", 
	"unknown ", "unknown ", "unknown ", "unknown ", "unknown ", 
	"unknown ", "unknown "
};

static char *yesno_text[] =
{
	"No ", "No  ", "Yes ", "Yes ", "Yes "
};

static char *joy_text[] =
{
	"OFF ","OFF ", "ON  ", "DP-2" 
};

static XlateTable xt_ctrl[] = 
{
	{	TC_PG,		CTRL_TYPE_PG	},
	{	TC_PG1,		CTRL_TYPE_PG1	},
	{	TC_PG125,	CTRL_TYPE_PG125	},
	{	TC_HOLD,	CTRL_TYPE_HOLD	},
	{	TC_PORT,	CTRL_TYPE_PORT	},
	{	-1,		0		}
};


static XlateTable xt_disp[] =
{
	{	TD_D10,		DISP_TYPE_D10	},
	{ 	TD_D50,		DISP_TYPE_D50	},
	{	TD_MT32,	DISP_TYPE_MT32	},
	{	TD_U20,		DISP_TYPE_U20	},
	{	TD_JX8P,	DISP_TYPE_JX8P	},
	{	TD_JD800,	DISP_TYPE_JD800	},
	{	TD_DX7,		DISP_TYPE_DX7	},
	{	-1,		0		}
};

static XlateTable xt_joy[] =
{
	{	TJ_OFF,		0	},
	{	TJ_ON,		1	},
	{	TJ_DP2,		2	},
	{	-1,		0	}
};

static XlateTable xt_yn[] =
{
	{	TYN_YES,	1	},
	{	TYN_NO,		0	},
	{	-1,		0	}
};


static XlateTable xt_chan[] =
{
	{	TC_C1,	0	},
	{	TC_C2,	1	},
	{ 	TC_C3,	2	},
	{	TC_C4,	3	},
	{	TC_C5,	4	},
	{ 	TC_C6,	5	},
	{	TC_C7,	6	},
	{	TC_C8,	7	},
	{	TC_C9,	8	},
	{	TC_C10,	9	},
	{	TC_C11,	10	},
	{	TC_C12,	11	},
	{	TC_C13,	12	},
	{	TC_C14,	13	},
	{	TC_C15,	14	},
	{	TC_C16,	15	},
	{	TC_ALL,	16	},
	{	TC_NONE,-1	},
	{ 	-1, 0 		}
};


static XlateTable xt_unit[] =
{
	{	TU_U1,	0	},
	{	TU_U2,	1	},
	{ 	TU_U3,	2	},
	{	TU_U4,	3	},
	{	TU_U5,	4	},
	{ 	TU_U6,	5	},
	{	TU_U7,	6	},
	{	TU_U8,	7	},
	{	TU_U9,	8	},
	{	TU_U10,	9	},
	{	TU_U11,	10	},
	{	TU_U12,	11	},
	{	TU_U13,	12	},
	{	TU_U14,	13	},
	{	TU_U15,	14	},
	{	TU_U16,	15	},
	{	TU_U17,	16	},
	{	TU_U18,	17	},
	{	TU_U19,	18	},
	{	TU_U20,	19	},
	{	TU_U21,	20	},
	{	TU_U22,	21	},
	{	TU_U23,	22	},
	{	TU_U24,	23	},
	{	TU_U25,	24	},
	{	TU_U26,	25	},
	{	TU_U27,	26	},
	{	TU_U28,	27	},
	{	TU_U29,	28	},
	{	TU_U30,	29	},
	{	TU_U31,	30	},
	{	TU_U32,	31	},
	
	{	TU_NONE,-1	},
	{ 	-1, 0 		}
};


static Parameter params[] =
{
{CFG_CTRL_CHANNEL,	TX_CCHAN,	chan_text,	-1,15,	TR_CHAN1, 	TC_ALL,	xt_chan },
{CFG_CTRL_TYPE,		TX_CTYPE,	ctrl_text, 	0,5,	TR_CTRL,	-1,	xt_ctrl	},
{CFG_USE_JOYSTICK,	TX_UJOY,	joy_text,	0,2,	TR_JOY,		-1,	xt_joy	},
{CFG_DISPLAY_CHANNEL,	TX_DCHAN,	unit_text, 	-1,32,	TR_UNIT,	-1,	xt_unit	},
{CFG_DISPLAY_TYPE,	TX_DTYPE,	disp_text,	0,8,	TR_DISP,	-1,	xt_disp	},
{CFG_MIDI_THRU,		TX_THRU,	chan_text,	-1,16,	TR_CHAN,	-1,	xt_chan },
{CFG_WAIT_AFTER_EXCL,	TX_PEXC,	yesno_text,	0,1,	TR_YN,		-1,	xt_yn	},
{CFG_LOAD_SINGLE_SONGS,	TX_LDSS,	yesno_text,	0,1,	TR_YN,		-1,	xt_yn	},
{CFG_INTERNAL_CHANNEL,	TX_ICHN,	chan_text,	-1,15,	TR_CHAN1,	TC_ALL,	xt_chan	},
{CFG_PAUSE_AFTER_LOAD,	TX_PAL,		yesno_text,	0,1,	TR_YN,		-1,	xt_yn	},
	{0,0}
};

CfgEdit::CfgEdit()
{
	InitDesk( SGGetTree( TR_CFG ) );
	cur_drive=Dgetdrv();

	done=FALSE;
	changed=FALSE;
	
	cfg=new Configuration( CFG_TYPE );
	cfg->Load( CFG_FILE_NAME );
}



Boolean CfgEdit::DoIt()
{
	UpdateDriveBox();
	UpdateParams();
	
	int obj;
	
	Draw();
	LogDrive( Dgetdrv() );
	Select( drive_items[cur_drive] );
	DrawItem( drive_items[cur_drive] );
	
	Load();
	while( !done )
		PollEvent();

	return TRUE;
}


Boolean CfgEdit::ObjectClick( int obj )
{
	if( SelectDrive( obj ) )
		return TRUE;

	if( SelectParam( obj ) )
		return TRUE;

	obj&=0x7fff;
	
	if( obj==TX_SAVE )
	{
		Save();
		DeSelect( obj );
		DrawItem( obj );
		return TRUE;
	}
	else if( obj==TX_LOAD )
	{
		QuerySave();
		Load();
		DeSelect( obj );
		DrawItem( obj );
		return TRUE;
	}
	else if( obj==TX_EXIT )
	{
		DeSelect( obj );
		DrawItem( obj );
		done=TRUE;
		QuerySave();
	//		form_alert( 0, "[1][Done][OK]" );
		return TRUE;
	}
//	else
//		Desk::ObjectClick( obj );
	return FALSE;
}

Boolean CfgEdit::SelectDrive( int obj )
{
	obj=obj&0x7fff;
	for( int i=0; i<16; i++ )
	{
		if( drive_items[i]==obj )
		{
			LogDrive( i );
			return TRUE;
		}
	}
	return FALSE;
}

	
void CfgEdit::UpdateDriveBox()
{
	for( unsigned int i=0; i<16; i++ )
	{
		if( ! (Drvmap() & (1<<i)) )
			Disable( drive_items[i] );
		DeSelect( drive_items[i] );
	}
}


void CfgEdit::LogDrive( int drive )
{
	QuerySave();
	cur_drive=drive;
	Load();
	UpdateParams();
	DrawParams();
}

void CfgEdit::QuerySave()
{
	if( changed==TRUE )
	{
		if( form_alert( 1, JKForm128( 
	"[2][Your config file '%c:%s'|has changed. Save it first?][ YES | NO ]",
		cur_drive+'A', CFG_FILE_NAME ) 
			)==1 )
		{
			Save();
		}
		changed=FALSE;
	}
}

void CfgEdit::Save()
{
	cfg->Save( JKForm128( "%c:%s", cur_drive+'A', CFG_FILE_NAME ) );
	changed=FALSE;
}

void CfgEdit::Load()
{

	cfg->Load( JKForm128( "%c:%s", cur_drive+'A', CFG_FILE_NAME ) );
	
	UpdateParams();
}


void CfgEdit::UpdateParams()
{
	long val;
	for( unsigned short i=0; params[i].file_id!=0; i++ )
	{
		val=cfg->Get( params[i].file_id );
		if( val< params[i].min )
		{
			val=params[i].min;
			cfg->Set( params[i].file_id, val );
		}
		if( val> params[i].max )
		{
			val=params[i].min;
			cfg->Set( params[i].file_id, val );			
		}
		strcpy( GetText( params[i].rsc_id ), 
			params[i].text[val+1] );
	}
}

Boolean CfgEdit::SelectParam( int obj )
{
	long val;
	
	obj&=0x7fff;
	for( unsigned short i=0; params[i].file_id!=0; i++ )
	{
		if( params[i].rsc_id==obj )
		{
			val=cfg->Get( params[i].file_id );

#if 1
			//JKRect killed;
			int id = DoMenu( params[i].popup_tree, TRUE );
			
			//Draw( killed );

			if( id!=-1 )
			{
				for( int j=0; params[i].xlate_table[j].obj_id!=-1; ++j )
				{
					if( params[i].xlate_table[j].obj_id==id )
					{
						val=params[i].xlate_table[j].value;
						break;
					}
				}
			}

#else		
			if( event.buttonState &1 )
			{
				val++;
				if( val>params[i].max )
					val=params[i].min;
			}
			else if( event.buttonState &2 )
			{
				val--;
				if( val<params[i].min )
					val=params[i].max;
			}

#endif
			cfg->Set( params[i].file_id, val );
			UpdateParams();
			DrawParams();
			changed=TRUE;
			return TRUE;
		}
	}
	return FALSE;
}

void CfgEdit::DrawParams()
{
	for( unsigned short i=0; params[i].file_id!=0; i++ )
	{
		DrawItem( params[i].rsc_id );
	}
}

