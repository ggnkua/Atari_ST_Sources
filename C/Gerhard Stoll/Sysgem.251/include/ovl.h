#ifndef _OVL_H
#define _OVL_H

typedef LONG RSC_H;

typedef struct
{
	WORD		Protokoll;
	
	/* ab RSM2OVL.Protokoll >= 1 */

	RSC_H    cdecl (*RscLoad)(const char* RscFile, LONG Mode);
	void     cdecl (*RscFree)(RSC_H ResourceHandle);
	OBJECT*  cdecl (*RscGetTree)(RSC_H ResourceHandle, LONG Index);
	char*    cdecl (*RscGetSring)(RSC_H ResourceHandle, LONG Index);
	BITBLK*  cdecl (*RscGetImage)(RSC_H ResourceHandle, LONG Index);
	
	void     cdecl (*ConvertTree)(OBJECT* Tree, LONG Mode);
} RSM2OVL;



typedef struct
{
	OBJECT*	DialToolbox;		/* Die Toolbox fr Dialoge									*/
	OBJECT*	MenuToolbox;		/* Die Toolbox fr Mens										*/
	OBJECT*	MenuDrop;				/* Wird im Men ein Title eingefgt, 				*/
													/* dann wird dieser Baum als Drop verwendet.*/
	OBJECT*	StdDialog;			/* Soll ein neuer Dialog angelegt werden, 	*/
													/* dann wird dieser Baum verwendet.					*/
	OBJECT*	StdMenu;				/* Soll ein neues Men angelegt werden,			*/
													/* dann wird dieser Baum verwendet.					*/
} TOOLS;

typedef WORD cdecl (*EVENTHANDLER)(EVNT* Evnt);
typedef WORD cdecl (*INITEVENTHANDLER)(EVENTHANDLER EventHandler);
typedef const char* cdecl (*GETOBNAME)(LONG Idx);

typedef struct
{
	LONG		Magic;		/* 0x4f424a43 'OBJC' */
	WORD		Protokoll;
	LONG		ID;
	WORD		Version;
	char		Name[32];
	char		Copyright[32];

	WORD		cdecl (*Init)(const char* FileName, UWORD* Global, RSM2OVL* RsmOvl, TOOLS* Tools);
	void		cdecl (*Exit)();

	WORD		cdecl (*Draw)(OBJECT* Objc, LONG* Clip, LONG Flags);

	/* ab OVL2RSM.Protokoll >= 1 */

	WORD		cdecl (*GetMinSize)(OBJECT* Objc, LONG Flags, WORD* MinW, WORD* MinH);
	void		cdecl (*GetArea)(OBJECT* Objc, LONG Flags, GRECT* Area);
	
	WORD		cdecl (*SetUp)(INITEVENTHANDLER InitEventHandler);

	/* ab OVL2RSM.Protokoll >= 2 */
	
	WORD		cdecl (*Test)(LONG Mode, LONG Resource, LONG Idx, GETOBNAME GetObName, INITEVENTHANDLER InitEventHandler);

	LONG		cdecl (*GetShortCut)(OBJECT* Objc, LONG Flags, BYTE ShortCut[10]);
	
} OVL2RSM;


#endif /* _OVL_H */
