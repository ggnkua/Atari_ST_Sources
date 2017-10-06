/*
   Modul: M_MESSAG (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPMESSAG_
#define _MPMESSAG_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

#define  WinUpdate      1000
#define  WinObject      1001
#define  ActionDone     1002
#define  WinClicked     1003
#define  WinOpened      1004
#define  WinShaded      1005
#define  WinRes6        1006 /* Reserviert */
#define  WinRes7        1007 /* Reserviert */
#define  WinKeyboard    1008 
#define  WinOwnRedraw   1009
#define  WinRedraw      1010
#define  WinTopped      1011
#define  WinClosed      1012
#define  WinFulled      1013
#define  WinUppage      1014
#define  WinDownpage    1015
#define  WinUpline      1016
#define  WinDownline    1017
#define  WinLeftpage    1018
#define  WinRightpage   1019
#define  WinLeftline    1020
#define  WinRightline   1021
#define  WinHSlided     1022
#define  WinVSlided     1023
#define  WinSized       1024
#define  WinMoved       1025
#define  WinNewtop      1026
#define  WinUntopped    1027
#define  WinOnTop       1028
#define  WinBottomed    1029
#define  WinDragdrop    1030
#define  WinIconify     1031
#define  WinUniconify   1032
#define  WinAlliconify  1033
#define  WinRedrawed    1034
#define  ObjcClicked    1050
#define  ObjcDblClicked 1051
#define  OutsideClick   1052
#define  ObjcGotCursor  1053
#define  ObjcLostCursor 1054
#define  ObjcEditkey    1055
#define  ObjcEdited     1056
#define  ObjcSlided     1057
#define  ObjcPgLeft     1058
#define  ObjcPgRight    1059
#define  ObjcArLeft     1060
#define  ObjcArRight    1061
#define  ObjcMousemove  1062
#define  ObjcTimer      1063
#define  ObjcLbSelect   1064
#define  ObjcDblSelect  1065
#define  ObjcDroped     1066
#define  DialOpen       1067
#define  ListClicked    1068
#define  ListDblClicked 1069
#define  AlertClicked   1080
#define  AlertTimer     1081

#define  WinChangefont 30961
#define  WINMNSELECTED 30962
#endif
