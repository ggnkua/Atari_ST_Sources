#include	<netdb.h>

#define	GemFtp_OpenSession		0x6000
#define	GemFtp_Get					0x6001
#define	GemFtp_Get_Prepare		0x6002
#define	GemFtp_Get_Start			0x6003
#define	GemFtp_Put					0x6004
#define	GemFtp_Put_Start			0x6005
#define	GemFtp_Mv					0x6006
#define	GemFtp_Mv_Old				0x6007
#define	GemFtp_Mv_New				0x6008
#define	GemFtp_Rm					0x6009
#define	GemFtp_Mkdir				0x600a
#define	GemFtp_Rmdir				0x600b
#define	GemFtp_Cd					0x600c
#define	GemFtp_Cdup					0x600d
#define	GemFtp_Cwd					0x600e
#define	GemFtp_Pwd					0x600f
#define	GemFtp_List					0x6010
#define	GemFtp_Abor					0x6011
#define	GemFtp_Path_Popup			0x6012
#define	GemFtp_Shutdown			0x6013
#define	GemFtp_Close_Transfer	0x6015
#define	GemFtp_Cmd					0x6016
#define	GemFtp_CmdFailed			0x6017
#define	GemFtp_LinkCd				0x6018
#define	GemFtp_LinkGet				0x6019
#define	GemFtp_Link					0x601a
#define	GemFtp_CdRoot				0x601b
#define	GemFtp_CwdFailed			0x601c
#define	GemFtp_LinkFailed			0x601d
#define	GemFtp_Chmod				0x601e

#ifdef	V110
#define	IConnect_Failed			0x60a0
#define	IConnect_Lost				0x60a1
#endif

#define	Fsel_GemFtp_Get			0x0001
#define	Fsel_GemFtp_Put			0x0002
#define	Fsel_File_Rename			0x0003

#define	InputText_GemFtp_Get		0x0001
#define	InputText_GemFtp_Mv_Old	0x0002
#define	InputText_GemFtp_Mv_New	0x0003
#define	InputText_GemFtp_Rm		0x0004
#define	InputText_GemFtp_Rmdir	0x0005
#define	InputText_GemFtp_Mkdir	0x0006
#define	InputText_GemFtp_Cd		0x0007
#define	InputText_GemFtp_Chmod_File	0x0008
#define	InputText_GemFtp_Chmod_Mode	0x0009

/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef struct _GemFtp_
{
/*	struct _GemFtp_	*next;	*/

	WORD			Global[15];
	WORD			VdiHandle;
	DIALOG		*FtpDialog;
	LIST_BOX		*FtpListBox;
	STR_ITEM		*FtpList;
	SESSION		Session;
	BYTE			*Url;
	WORD			nFtpWin;
} GemFtp;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
WORD	newGemFtp( BYTE *Url, WORD Global[15] );
WORD	existThreadInfoGemFtp( void );
void	delThreadInfoGemFtp( WORD AppId, WORD Global[15] );
WORD	GetThreadAppId( WORD n, WORD Global[15] );
#ifdef	GEMScript
BYTE	*GetThreadUrl( WORD n, WORD Global[15] );
void	SetThreadMainWindow( WORD AppId, WORD WinId );
WORD	GetThreadMainWindow( WORD AppId );
#endif
