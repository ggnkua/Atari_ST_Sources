{ KEYTAB 06 (1998-04-16) by Thomas_Much@ka2.maus.de }
{ PurePascal include file                           }

type

	PKEYT = ^TKEYT;
	TKEYT = record
		Magic             : TCookieID;
		Size              : longint;
		GetExportCount    : function: integer;
		pasGetExportName  : function(d1,d2: pointer; d3,d4,d5: longint; enr: integer): PChar;
		GetExportFilter   : function(d1,d2: pointer; d3,d4,d5: longint; eid: integer): integer;
		ExportChar        : function(d1,d2: pointer; d3,d4,d5: longint; enr: integer; echr: char): char;
		GetImportCount    : function: integer;
		pasGetImportName  : function(d1,d2: pointer; d3,d4,d5: longint; inr: integer): PChar;
		GetImportFilter   : function(d1,d2: pointer; d3,d4,d5: longint; iid: integer): integer;
		ImportChar        : function(d1,d2: pointer; d3,d4,d5: longint; inr: integer; ichr: char): char;
		ExportString      : procedure(d1,d2: pointer; d3,d4,d5: longint; enr: integer; elen: longint; echrs: PChar);
		ImportString      : procedure(d1,d2: pointer; d3,d4,d5: longint; inr: integer; ilen: longint; ichrs: PChar);
		GetExportName     : function(d1,d2: pointer; d3,d4,d5: longint; enr: integer): longint;
		GetImportName     : function(d1,d2: pointer; d3,d4,d5: longint; inr: integer): longint;
		GetExportShortName: function(d1,d2: pointer; d3,d4,d5: longint; enr: integer): longint;
		GetImportShortName: function(d1,d2: pointer; d3,d4,d5: longint; inr: integer): longint;
	end;
