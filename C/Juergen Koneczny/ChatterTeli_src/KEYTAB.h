/* KEYTAB 06 (1998-04-16) by Thomas_Much@ka2.maus.de */
/* PureC include file                                */

#ifndef KEYTAB_H
#define KEYTAB_H

#define	KEYTAB_ID_ANSI	1

typedef struct
{
  long   magic;
  long   size;
  int    cdecl (*GetExportCount)     (void);
  long   resvd0;
  int    cdecl (*GetExportFilter)    (int eid);
  char   cdecl (*ExportChar)         (int enr, char echr);
  int    cdecl (*GetImportCount)     (void);
  long   resvd1;
  int    cdecl (*GetImportFilter)    (int iid);
  char   cdecl (*ImportChar)         (int inr, char ichr);
  void   cdecl (*ExportString)       (int enr, long elen, char *echrs);
  void   cdecl (*ImportString)       (int inr, long ilen, char *ichrs);
  char * cdecl (*GetExportName)      (int enr);
  char * cdecl (*GetImportName)      (int inr);
  char * cdecl (*GetExportShortName) (int enr);
  char * cdecl (*GetImportShortName) (int inr);
} KEYT;

#endif
