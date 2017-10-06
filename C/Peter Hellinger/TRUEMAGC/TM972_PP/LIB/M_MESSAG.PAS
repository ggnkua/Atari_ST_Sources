UNIT M_Messages;

INTERFACE

CONST WinUpdate =     1000;
      WinObject =     1001;
      ActionDone =    1002;
      WinClicked =    1003;
      WinOpend =      1004;
      WinShaded =     1005;
      WinRes6 =       1006; (* Reserviert *)
      WinRes7 =       1007; (* Reserviert *)
      WinKeyboard =   1008;
      WinOwnRedraw =  1009;
      WinRedraw =     1010;
      WinTopped =     1011;
      WinClosed =     1012;
      WinFulled =     1013;
      WinUppage =     1014;
      WinDownpage =   1015;
      WinUpline =     1016;
      WinDownline =   1017;
      WinLeftpage =   1018;
      WinRightpage =  1019;
      WinLeftline =   1020;
      WinRightline =  1021;
      WinHSlided =    1022;
      WinVSlided =    1023;
      WinSized =      1024;
      WinMoved =      1025;
      WinNewtop =     1026;
      WinUntopped =   1027;
      WinOnTop =      1028;
      WinBottomed =   1029;
      WinDragdrop =   1030;
      WinIconify =    1031;
      WinUniconify =  1032;
      WinAlliconify = 1033;
      WinRedrawed =   1034;
      WinChangefont = $78F1;
      WINMNSELECTED = $78F2;
      TOPTOOL =       $78F3;
      UpdateInfo =    $78F4;

CONST ObjcClicked =    1050;
      ObjcDblClicked = 1051;
      OutsideClick =   1052;
      ObjcGotCursor =  1053;
      ObjcLostCursor = 1054;
      ObjcEditkey =    1055;
      ObjcEdited =     1056;
      ObjcSlided =     1057;
      ObjcPgLeft =     1058;
      ObjcPgRight =    1059;
      ObjcArLeft =     1060;
      ObjcArRight =    1061;
      ObjcMousemove =  1062;
      ObjcTimer =      1063;
      ObjcSelect =     1064;
      ObjcDblSelect =  1065;
      ObjcDroped =     1066;
      DialOpen =       1067;
      ListClicked =    1068;
      ListDblClicked = 1069;

CONST AlertClicked =   1080;
      AlertTimer =     1081;

IMPLEMENTATION

END (*M_Messages*).