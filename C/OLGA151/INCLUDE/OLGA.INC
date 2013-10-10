{* OLGA Rev 1.5 (98-06-08)                       *
 * Thomas_Much@ka2.maus.de                       *
 * http://www.uni-karlsruhe.de/~Thomas.Much/OLGA *}

const

	OLE_INIT                 = $4950;
	OLE_EXIT                 = $4951;
	OLE_NEW                  = $4952;

	OLGA_INIT                = $1236;
	OLGA_UPDATE              = $1238;
	OLGA_ACK                 = $1239;
	OLGA_RENAME              = $123a;
	OLGA_OPENDOC             = $123b;
	OLGA_CLOSEDOC            = $123c;
	OLGA_LINK                = $123d;
	OLGA_UNLINK              = $123e;
	OLGA_UPDATED             = $123f;
	OLGA_RENAMELINK          = $1240;
	OLGA_LINKRENAMED         = $1241;
	OLGA_GETOBJECTS          = $1242;
	OLGA_OBJECTS             = $1243;
	OLGA_BREAKLINK           = $1244;
	OLGA_LINKBROKEN          = $1245;
	OLGA_START               = $1246;
	OLGA_GETINFO             = $1247;
	OLGA_INFO                = $1248;
	OLGA_IDLE                = $1249;
	OLGA_ACTIVATE            = $124a;
	OLGA_EMBED               = $124b;
	OLGA_EMBEDDED            = $124c;
	OLGA_UNEMBED             = $124d;
	OLGA_GETSETTINGS         = $124e;
	OLGA_SETTINGS            = $124f;
	OLGA_REQUESTNOTIFICATION = $1250;
	OLGA_RELEASENOTIFICATION = $1251;
	OLGA_NOTIFY              = $1252;
	OLGA_NOTIFIED            = $1253;
	OLGA_SERVERTERMINATED    = $1254;
	OLGA_CLIENTTERMINATED    = $1255;
	OLGA_INPLACEUPDATE       = $1256;
	OLGA_ID4UPDATE           = $1257;
	OLGA_GETEXTENSION        = $1258;
	OLGA_EXTENSION           = $1259;
	OLGA_GETSERVERPATH       = $125a;
	OLGA_SERVERPATH          = $125b;
	OLGA_IE_BUTTON           = $125c;
	OLGA_IE_KEY              = $125d;

	OL_SERVER                = $0001;
	OL_CLIENT                = $0002;
	OL_PEER                  = OL_SERVER or OL_CLIENT;
	OL_CONF                  = $0400;
	OL_IDLE                  = $0800;
	OL_PIPES                 = $1000;
	OL_START                 = $2000;
	OL_MANAGER               = $4000;
	OL_OEP                   = $0001;

	OLS_TYPE                 =     1;
	OLS_EXTENSION            =     2;
	OLS_NAME                 =     3;

	OL_SRV_ID4               = $0001;


type

	GRECTPtr = ^GRECT;
	GRECT    = record
		X,Y,W,H,
		X1,Y1,X2,Y2: integer
	end;

	POLGAInfHeader = ^TOLGAInfHeader;
	TOLGAInfHeader = record
		Magic  : array [0..3] of char;
		Version,
		Skip   : word
	end;

	POLGABlockHeader = ^TOLGABlockHeader;
	TOLGABlockHeader = record
		ID    : array [0..3] of char;
		Length: longint
	end;

	PRGB = ^TRGB;
	TRGB = record
		Red,
		Green,
		Blue : integer
	end;

	POLGAColorTable = ^TOLGAColorTable;
	TOLGAColorTable = record
		Count : integer;
		Colors: array [0..255] of TRGB
	end;

	POLGAObjectInfo = ^TOLGAObjectInfo;
	TOLGAObjectInfo = record
		Filename    : PChar;
		ClientGEMPB : AESPBPtr;
		ClientData,
		ServerData  : longint;
		CBLock,
		CBCount     : integer;
		CBDraw      : procedure(d1,d2: pointer; d3,d4,d5: longint; objectinfo: POLGAObjectInfo; outScreen,outHandle,outDevID: integer; Size,Clip: GRECTPtr);
		CBUnembed   : procedure(d1,d2: pointer; d3,d4,d5: longint; objectinfo: POLGAObjectInfo);
		CBXDraw     : procedure(d1,d2: pointer; d3,d4,d5: longint; objectinfo: POLGAObjectInfo; outScreen,outHandle,outDevID: integer; Size,Clip: GRECTPtr; Width_mm1000, Height_mm1000, Scale: longint);
		cbColorTable: POLGAColorTable;
		cbClientID,
		cbServerID  : integer
		{ IE }
	end;

	POLGAIEInfo = ^TOLGAIEInfo;
	TOLGAIEInfo = record
		len       : longint;
		wHandle,
		kShift    : integer;
		Size      : PGRECT;
		objectinfo: POLGAObjectInfo
	end;
