/************************************************************************
 *                                                                      *
 *  Name: GEMWork.h  Zweck: Vereinfachung verschiedener GEM - Aufrufe   *
 *                                                                      *
 *  Autor: RSB                                                          *
 *  Datum: 23.05.90  Grund: Version fÅr TOS-Magazin                     *
 *                                                                      *
 ************************************************************************/

extern int 	VDIHandle;	
extern int 	ScreenWidth,ScreenLength,FontWidth,FontHeight,
			BoxWidth,BoxHeight,ScreenPlanes;

extern int GemInit(void);
extern void GemExit(int VDIHandle);
extern int DoDialog(OBJECT tree[],int StartObj);


