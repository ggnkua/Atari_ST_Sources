/*****************************************************************************
 *
 * Module : ACCOUNT.C
 * Author : Dieter Geiž
 *
 * Creation date    : 20.10.96
 * Last modification: 21.12.02
 *
 *
 * Description: This module implements the account object window.
 *
 * History:
 * 21.12.02: start_process mit neuem šbergabeparameter
 * 02.04.97: Calling AccSortObjects after loading linked account
 * 04.03.97: Detail table can also be used as foreign table in FillParentBuffer
 * 02.03.97: Foreign tables can be used
 * 01.03.97: Duplicate option and add option added
 * 28.02.97: Calculations added
 * 26.02.97: Additional parameter "filename" for open_work_ex used
 * 24.02.97: Using real table name for error messages
 * 23.02.97: SubAccount possibilities added
 * 09.01.97: lSumModY added
 * 02.01.97: Account name is being shown in process window
 * 01.01.97: Objects can grow and shrink
 * 20.10.96: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "accobj.h"
#include "accprev.h"
#include "desktop.h"
#include "dialog.h"
#include "printer.h"
#include "process.h"
#include "resource.h"
#include "sql.h"

#include "export.h"
#include "account.h"

/****** DEFINES **************************************************************/

#define P_PROC_INF(window)	((PROC_INF *)window->special)
#define P_WORK(pProcInf)	((WORK *)pProcInf->memory)

#define CALC_OK			0		/* calc checking was ok */
#define CALC_EDIT		1		/* user wants to edit calc */
#define CALC_CANCEL		2		/* user doesn't want to edit calc */

#define MAX_ERRCHARS		37		/* max chars in error (40 - strlen (">>>")) */

#define OBJ_SHOW_DUPLICATES	0x80000000L	/* show duplicates on new page */

/****** TYPES ****************************************************************/

typedef struct
{
  ACCOUNT  *pAccount;			/* the account definition */
  CHAR     *pBuffer;			/* buffer used */
  SHORT    sTable;			/* actual table number */
  SHORT    sPrnHandle;			/* vdi handle of printer */
  BOOL     bPrnAvailable;		/* printer available? */
  DEVINFO  devinfo;			/* device info */
  LONG     lPixelsPerMeter;		/* pixels per meter */
  LONG     lCount;			/* count of records */
  LONG     lCopies;			/* number of copies of whole report */
  LONG     lPageNr;			/* page number for report */
  SHORT    sColNr;			/* column number */
  SHORT    sMaxColNr;			/* max column number */
  BOOL     bNewPage;			/* next object is to be printed to a new page */
  BOOL     bSkipPageHeader;		/* skip page header on first page */
  BOOL     bSkipPageFooter;		/* skip page footer on last page */
  BOOL     bInAccHeader;		/* printing account header */
  BOOL     bInAccFooter;		/* printing account footer */
  BOOL     bInPageHeader;		/* printing page header */
  BOOL     bInPageFooter;		/* printing page footer */
  LONG     lPhysPageWidth;		/* physical page width in 1/1000 cm */
  LONG     lPhysPageHeight;		/* physical page height in 1/1000 cm */
  LONG     lRealPageWidth;		/* printable page width in 1/1000 cm */
  LONG     lRealPageHeight;		/* printable page height in 1/1000 cm */
  LONG     lXOffset;			/* x offset of printable margin */
  LONG     lYOffset;			/* y offset of printable margin */
  LONG     lBottom;			/* bottom margin not counting footer */
  LONG     xAdd;			/* x offset to add for next object in 1/1000 cm */
  LONG     yAdd;			/* y offset to add for next object in 1/1000 cm */
  LONG     xSub;			/* x offset to subtract for next object in 1/1000 cm */
  LONG     ySub;			/* y offset to subtract for next object in 1/1000 cm */
  LONG     lModY;			/* additional y value to add or subtract if object height is variable */
  LONG     lRefY;			/* reference y value for objects to add in y direction */
  LONG     lSumModY;			/* sum of lModY */
  LONG     lMaxObjHeight;		/* max height of all objects in a region */
  FULLNAME szFileName;			/* name of object file */
  HFILE    hFile;			/* object file */
  LONG     alPageTable [MAX_PAGES];	/* table of page addresses inside the object file */
} WORK;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL BOOL WorkAccount        (PROC_INF *pProcInf);
LOCAL BOOL StopAccount        (PROC_INF *pProcInf);

LOCAL BOOL WriteAccountHeader (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount);
LOCAL BOOL WriteAccountFooter (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount);

LOCAL BOOL WritePageHeader    (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount);
LOCAL BOOL WritePageFooter    (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount);

LOCAL BOOL WriteRegion        (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount, ACC_REGION *pRegion, LONG xAdd, LONG yAdd);
LOCAL BOOL WriteObject        (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount, ACC_OBJECT *pObject, LONG xAdd, LONG yAdd, ACC_REGION *pRegion);

LOCAL BOOL HandleSubAccount   (PROC_INF *pProcInf, ACC_OBJECT *pObject, LONG xAdd, LONG yAdd, LRECT *pRect, SHORT sMasterTable, CHAR *pMasterBuffer);

LOCAL BOOL TableNameFromQuery (DB *db, ACCOUNT *pAccount, CHAR *pTableName);
LOCAL CHAR *StringFromColumn  (DB *db, SHORT sTable, CHAR *pBuffer, CHAR *pColumnBuffer, CHAR *pColumn, CHAR *pFormat, SHORT *psHorzAlignment, SHORT *psVertAlignment);
LOCAL VOID *GetSysRec         (DB *db, SHORT sTable, LONG lSize, CHAR *pName);

LOCAL WORD CompilerError      (INT iError, BYTE *pCalcText, WORD wLine, WORD wCol);

LOCAL VOID ZeroValues         (DB *db, SHORT sTable, CHAR *pBuffer);
LOCAL VOID AddValues          (DB *db, SHORT sTable, CHAR *pBuffer, CHAR *pSumBuffer);

LOCAL BOOL FillParentBuffer   (DB *db, SHORT sParentTable, CHAR *pParentBuffer, SHORT sTable, CHAR *pBuffer);

/*****************************************************************************/

GLOBAL BOOL AccountInit (VOID)
{
  return (TRUE);
} /* AccountInit */

/*****************************************************************************/

GLOBAL BOOL AccountTerm (VOID)
{
  return (TRUE);
} /* AccountTerm */

/*****************************************************************************/

GLOBAL VOID AccountExec (ACCOUNT *pAccount, DB *db, SHORT table, SHORT inx, SHORT dir, SHORT device, BOOL minimize, LONG copies)
{
  ACCOUNT    *pAcc;
  SYSQUERY   *pSysQuery;
  SHORT      sNumKeys, sPageFormat;
  LONG       lBytes;
  TABLE_INFO TableInfo;
  SQL_RESULT SqlResult;
  PROC_INF   ProcInf, *pProcInf;
  WINDOWP    window;
  WORK       *pWork;
  FULLNAME   szFileName;
  HFILE      hFile;
  WORD       wDevice;

  pSysQuery    = NULL;
  SqlResult.db = NULL;

  if (table == FAILURE)
  {
    if (pAccount->bTable)
    {
      strcpy (TableInfo.name, pAccount->szTableOrQuery);
      table = db_tableinfo (db->base, FAILURE, &TableInfo);
      inx   = min (1, TableInfo.indexes - 1);			/* use first index as default (don't use recnum) */
      dir   = ASCENDING;
    } /* if */
    else
      if ((pSysQuery = GetSysRec (db, SYS_QUERY, sizeof (SYSQUERY), pAccount->szTableOrQuery)) == NULL)
        return;
      else
      {
        sql_exec (db, pSysQuery->query, "", FALSE, &SqlResult);

        if (SqlResult.db == NULL)
        {
          mem_free (pSysQuery);
          return;
        } /* if */
        else
        {
          table = SqlResult.table;
          inx   = SqlResult.inx;
          dir   = SqlResult.dir;

          mem_free (SqlResult.columns);				/* don't need no columns */
        } /* else */
      } /* else, if */
  } /* if */

  if (pSysQuery != NULL)
    mem_free (pSysQuery);

  if (device == FAILURE)
    device = DEV_SCREEN;

  sNumKeys = num_keys (db, table, inx);

  if (warn_table)
    if (sNumKeys == 0)
      if (hndl_alert (ERR_NOKEYS) == 2)
        return;

  if (! (db_acc_table (db->base, rtable (table)) & GRANT_SELECT))
  {
    dberror (db->base->basename, DB_CNOACCESS);
    return;
  } /* if */

  if ((pAcc = AccCopy (pAccount)) == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return;
  } /* if */

  AccSortObjects (pAcc);

  pAcc->arPageHeader.sNewPageProp = RNP_NONE;	/* no other values allowed */
  pAcc->arPageFooter.sNewPageProp = RNP_NONE;

  ProcInf.db           = db;
  ProcInf.table        = table;
  ProcInf.inx          = inx;
  ProcInf.dir          = dir;
  ProcInf.cols         = 0;
  ProcInf.columns      = NULL;
  ProcInf.colwidth     = NULL;
  ProcInf.cursor       = db_newcursor (db->base);
  ProcInf.format       = 0;
  ProcInf.maxrecs      = sNumKeys;
  ProcInf.events_ps    = events_ps;
  ProcInf.recs_pe      = recs_pe;
  ProcInf.impexpcfg    = NULL;
  ProcInf.page_format  = NULL;
  ProcInf.prncfg       = NULL;
  ProcInf.to_printer   = FALSE;
  ProcInf.binary       = FALSE;
  ProcInf.tmp          = FALSE;
  ProcInf.special      = device;
  ProcInf.filename [0] = EOS;
  ProcInf.file         = NULL;
  ProcInf.filelength   = 0;
  ProcInf.workfunc     = WorkAccount;
  ProcInf.stopfunc     = StopAccount;

  if (ProcInf.cursor == NULL)
  {
    hndl_alert (ERR_NOCURSOR);
    AccFree (pAcc);
    mem_free (pAcc);
    return;
  } /* if */

  if (! v_initcursor (db, table, inx, dir, ProcInf.cursor))
  {
    db_freecursor (db->base, ProcInf.cursor);
    AccFree (pAcc);
    mem_free (pAcc);
    return;
  } /* if */

  temp_name (szFileName);

  if ((hFile = file_create (szFileName)) < 0)
  {
    file_error (ERR_FILECREATE, szFileName);
    db_freecursor (db->base, ProcInf.cursor);
    AccFree (pAcc);
    mem_free (pAcc);
    return;
  } /* if */
  else
  {
    lBytes = 0L;						/* placeholder for page table pointer */
    file_write (hFile, sizeof (LONG), &lBytes);			/* if this fails, there will be a write error later */
    file_write (hFile, sizeof (LONG), &lBytes);			/* number of pages, still unknown  */
    file_write (hFile, sizeof (LONG), &pAcc->lWidth);
    file_write (hFile, sizeof (LONG), &pAcc->lMarginLeft);
    file_write (hFile, sizeof (LONG), &pAcc->lMarginRight);
    file_write (hFile, sizeof (LONG), &pAcc->lMarginTop);
    file_write (hFile, sizeof (LONG), &pAcc->lMarginBottom);

    wDevice = DeviceFromName (pAcc->szPrinter);

    if (wDevice == FAILURE)
      wDevice = PRINTER;

    file_write (hFile, sizeof (WORD), &wDevice);

    sPageFormat = AccMapPageFormat (pAcc->sPageFormat);
    file_write (hFile, sizeof (SHORT), &sPageFormat);

    pAcc->sPageOrientation--;					/* convert to GEM value */
    file_write (hFile, sizeof (SHORT), &pAcc->sPageOrientation);
    pAcc->sPageOrientation++;
  } /* else */

  v_tableinfo (db, table, &TableInfo);

  lBytes = sizeof (WORK);

  if (odd (lBytes)) lBytes++;					/* db buffers should be on even address */

  lBytes += 3 * TableInfo.size;					/* buffer, compare buffer, total sum buffer */

  window = crt_process (NULL, NULL, NIL, FREETXT (FPACCOUNT), &ProcInf, lBytes, wi_modeless);

  if (window != NULL)
  {
    pProcInf = P_PROC_INF (window);
    pWork    = P_WORK (pProcInf);

    mem_lset (pWork, 0, lBytes);

    pWork->pAccount      = pAcc;
    pWork->pBuffer       = (BYTE *)pWork + sizeof (WORK) + odd (sizeof (WORK));
    pWork->sTable        = table;
    pWork->sPrnHandle    = open_work_ex (wDevice, &pWork->devinfo, AccMapPageFormat (pAcc->sPageFormat), pAcc->sPageOrientation - 1, NULL);
    pWork->bPrnAvailable = pWork->sPrnHandle != 0;
    pWork->lCopies       = copies;
    pWork->lPageNr       = 1;
    pWork->sColNr        = 1;
    pWork->sMaxColNr     = 1;
    pWork->bNewPage      = TRUE;				/* force a page header to be written */
    pWork->hFile         = hFile;

    if (! pWork->bPrnAvailable)					/* no printer defined, use screen handle */
    {
      pWork->sPrnHandle = vdi_handle;
      pWork->devinfo    = screen_info;
    } /* if */
    else
      vst_ex_load_fonts (pWork->sPrnHandle, 0, 3072, 0);

    pWork->lPixelsPerMeter = pWork->devinfo.lPixelsPerMeter;
    pWork->lRealPageWidth  = pWork->devinfo.lRealPageWidth / 10;
    pWork->lRealPageHeight = pWork->devinfo.lRealPageHeight / 10;
    pWork->lXOffset        = pWork->devinfo.lXOffset / 10;
    pWork->lYOffset        = pWork->devinfo.lYOffset / 10;
    pWork->lPhysPageWidth  = pWork->devinfo.lPhysPageWidth / 10;
    pWork->lPhysPageHeight = pWork->devinfo.lPhysPageHeight / 10;
    pWork->xAdd            = pAcc->lMarginLeft;
    pWork->yAdd            = pAcc->lMarginTop;
    pWork->lMaxObjHeight   = pAcc->lMarginTop;
    pWork->lBottom         = pWork->lPhysPageHeight - pAcc->lMarginBottom - ((pAcc->lFlags & ACC_HAS_PAGE_HEADFOOT) && (pAcc->arPageFooter.lFlags & REGION_VISIBLE) ? pAcc->arPageFooter.lHeight : 0);

    strcpy (pWork->szFileName, szFileName);
    strcpy (pProcInf->filestr, pAcc->szName);

    start_process (window, minimize_process, TRUE);
  } /* if */

  if (SqlResult.db != NULL)
  {
    if (VTBL (SqlResult.table))
      free_vtable (SqlResult.table);

    if (VINX (SqlResult.inx))
      free_vindex (SqlResult.inx);
  } /* if */
} /* AccountExec */

/*****************************************************************************/

GLOBAL VOID AccountNameExec (CHAR *pAccountName, DB *db, SHORT table, SHORT inx, SHORT dir, SHORT device, BOOL minimize, LONG copies)
{
  BOOL       bOk;
  ACCOUNT    Account;
  SYSACCOUNT SysAccount;
  CURSOR     cursor;
  LONGSTR    s;

  strcpy (SysAccount.name, pAccountName);

  bOk = FALSE;

  if (db_search (db->base, SYS_ACCOUNT, 1, ASCENDING, &cursor, &SysAccount, 0L))
    if (db_read (db->base, SYS_ACCOUNT, &SysAccount, &cursor, 0L, FALSE))
      bOk = TRUE;

  if (! bOk)
  {
    sprintf (s, alerts [ERR_ACC_NOT_FOUND], pAccountName);
    open_alert (s);
  } /* if */

  if (bOk)
  {
    bOk = AccMemFromSys (db->base, &Account, &SysAccount);

    if (! bOk)
      dbtest (db);
    else
    {
      AccountExec (&Account, db, table, inx, dir, device, minimize, copies);
      AccFree (&Account);
    } /* else */
  } /* if */
} /* AccountNameExec */

/*****************************************************************************/

LOCAL BOOL WorkAccount (PROC_INF *pProcInf)
{
  WORK       *pWork = P_WORK (pProcInf);
  ACCOUNT    *pAcc  = pWork->pAccount;
  BOOL       bOk    = FALSE;
  TABLE_INFO TableInfo;
  CHAR       *pPrevBuffer, *pTotalBuffer;

  v_tableinfo (pProcInf->db, pProcInf->table, &TableInfo);

  pPrevBuffer  = pWork->pBuffer + TableInfo.size;		/* buffer for comparing to duplicates */
  pTotalBuffer = pPrevBuffer + TableInfo.size;			/* buffer for total sum */

  mem_lmove (pPrevBuffer, pWork->pBuffer, TableInfo.size);

  if (pProcInf->actrec == 0)					/* only once */
    ZeroValues (pProcInf->db, pProcInf->table, pTotalBuffer);

  if (v_movecursor (pProcInf->db, pProcInf->cursor, (LONG)pProcInf->dir))
    if (v_read (pProcInf->db, pProcInf->table, pWork->pBuffer, pProcInf->cursor, 0L, FALSE))
    {
      bOk           = TRUE;
      pWork->lCount = pProcInf->actrec + 1;

      if (pProcInf->use_calc)
        v_execute (pProcInf->db, pProcInf->table, pProcInf->calccode, pWork->pBuffer, pProcInf->actrec + 1, NULL);

      AddValues (pProcInf->db, pProcInf->table, pWork->pBuffer, pTotalBuffer);

      if (pProcInf->actrec == 0)			/* account header */
        bOk = WriteAccountHeader (pProcInf, pWork->sTable, pWork->pBuffer, pWork->lCount);

      if (bOk && (pAcc->arDetails.lFlags & REGION_VISIBLE))
        bOk = WriteRegion (pProcInf, pWork->sTable, pWork->pBuffer, pWork->lCount, &pAcc->arDetails, 0, 0);
    } /* if, if */

  return (bOk);
} /* WorkAccount */

/*****************************************************************************/

LOCAL BOOL StopAccount (PROC_INF *pProcInf)
{
  WORK    *pWork = P_WORK (pProcInf);
  ACCOUNT *pAcc  = pWork->pAccount;
  BOOL    bOk    = TRUE;
  LONG    lSize;

  bOk = WriteAccountFooter (pProcInf, pWork->sTable, pWork->pBuffer, pWork->lCount);

  if (bOk)
  {
    if (! pWork->bNewPage)
      bOk = WritePageFooter (pProcInf, pWork->sTable, pWork->pBuffer, pWork->lCount);

    if (pWork->sColNr != 1)
    {
      lSize = file_seek (pWork->hFile, 0L, SEEK_CUR);
      pWork->alPageTable [pWork->lPageNr++] = lSize;
    } /* if */
  } /* if */

  if (pWork->bPrnAvailable)
  {
    vst_unload_fonts (pWork->sPrnHandle, 0);
    close_work (PRINTER, pWork->sPrnHandle);
  } /* if */

  lSize = file_seek (pWork->hFile, 0L, SEEK_CUR);			/* save position of page table */

  file_write (pWork->hFile, pWork->lPageNr * sizeof (LONG), pWork->alPageTable);

  pWork->lPageNr--;							/* has already been increased by WritePageFooter */
  file_seek (pWork->hFile, 0L, SEEK_SET);
  file_write (pWork->hFile, sizeof (LONG), &lSize);
  file_write (pWork->hFile, sizeof (LONG), &pWork->lPageNr);
  file_close (pWork->hFile);

  if (bOk)
    if (pProcInf->special == DEV_SCREEN)
      bOk = AccPrevOpen (NIL, pWork->szFileName, pAcc->szName);
    else
      AccPrevPrintFile (pWork->szFileName, pAcc->szName);

  AccFree (pAcc);
  mem_free (pAcc);

  return (bOk);
} /* StopAccount */

/*****************************************************************************/

LOCAL BOOL WriteAccountHeader (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount)
{
  WORK    *pWork = P_WORK (pProcInf);
  ACCOUNT *pAcc  = pWork->pAccount;
  BOOL    bOk    = TRUE;

  if ((pAcc->lFlags & ACC_HAS_HEADFOOT) && (pAcc->arAccountHeader.lFlags & REGION_VISIBLE))
  {
    if ((pAcc->sPageHeaderProp == APHP_NOT_ON_ACC_HEADER) || (pAcc->sPageHeaderProp == APHP_ON_NEITHER))
      pWork->bSkipPageHeader = TRUE;

    if ((pAcc->sPageFooterProp == APHP_NOT_ON_ACC_HEADER) || (pAcc->sPageFooterProp == APHP_ON_NEITHER))
      pWork->bSkipPageFooter = TRUE;

    pWork->bInAccHeader = TRUE;

    bOk = WriteRegion (pProcInf, sTable, pBuffer, lCount, &pAcc->arAccountHeader, 0, 0);

    pWork->bInAccHeader    = FALSE;
    pWork->bSkipPageHeader = FALSE;
  } /* if */

  return (bOk);
} /* WriteAccountHeader */

/*****************************************************************************/

LOCAL BOOL WriteAccountFooter (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount)
{
  WORK    *pWork = P_WORK (pProcInf);
  ACCOUNT *pAcc  = pWork->pAccount;
  BOOL    bOk    = TRUE;

  if ((pAcc->lFlags & ACC_HAS_HEADFOOT) && (pAcc->arAccountFooter.lFlags & REGION_VISIBLE))
  {
    if ((pAcc->sPageHeaderProp == APHP_NOT_ON_ACC_FOOTER) || (pAcc->sPageHeaderProp == APHP_ON_NEITHER))
      pWork->bSkipPageHeader = TRUE;

    if ((pAcc->sPageFooterProp == APHP_NOT_ON_ACC_FOOTER) || (pAcc->sPageFooterProp == APHP_ON_NEITHER))
      pWork->bSkipPageFooter = TRUE;

    pWork->bInAccFooter = TRUE;

    bOk = WriteRegion (pProcInf, sTable, pBuffer, lCount, &pAcc->arAccountFooter, 0, 0);

    pWork->bInAccFooter = FALSE;
  } /* if */

  return (bOk);
} /* WriteAccountFooter */

/*****************************************************************************/

LOCAL BOOL WritePageHeader (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount)
{
  WORK    *pWork = P_WORK (pProcInf);
  ACCOUNT *pAcc  = pWork->pAccount;
  BOOL    bOk    = TRUE;

  pWork->bNewPage = FALSE;

  if (pWork->sColNr == 1)
    pWork->alPageTable [pWork->lPageNr - 1] = file_seek (pWork->hFile, 0L, SEEK_CUR);

  if ((pAcc->lFlags & ACC_HAS_PAGE_HEADFOOT) && (pAcc->arPageHeader.lFlags & REGION_VISIBLE))
    if (pWork->bSkipPageHeader)
    {
      if (! pWork->bInAccHeader && ! pWork->bInAccFooter)
        pWork->bSkipPageHeader = FALSE;
    } /* if */
    else
      if (! pWork->bInPageHeader)
      {
        pWork->bInPageHeader = TRUE;		/* because of recursion of subaccounts in a header */
        bOk                  = WriteRegion (pProcInf, sTable, pBuffer, lCount, &pAcc->arPageHeader, 0, 0);
        pWork->bInPageHeader = FALSE;
      } /* if */

  return (bOk);
} /* WritePageHeader */

/*****************************************************************************/

LOCAL BOOL WritePageFooter (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount)
{
  WORK    *pWork = P_WORK (pProcInf);
  ACCOUNT *pAcc  = pWork->pAccount;
  BOOL    bOk    = TRUE;
  LONG    lSize;

  pWork->bInPageFooter = TRUE;
  pWork->yAdd          = pWork->lPhysPageHeight - pAcc->lMarginBottom;	/* footer has always to be on bottom of page */
  pWork->ySub          = 0;
  pWork->lModY         = 0;						/* footer always starts on a fix position */

  if ((pAcc->lFlags & ACC_HAS_PAGE_HEADFOOT) && (pAcc->arPageFooter.lFlags & REGION_VISIBLE))
    if (pWork->bSkipPageFooter)
    {
      if (! pWork->bInAccHeader && ! pWork->bInAccFooter)
        pWork->bSkipPageFooter = FALSE;
    } /* if */
    else
      if (! pWork->bNewPage)						/* at least one object on page */
        bOk = WriteRegion (pProcInf, sTable, pBuffer, lCount, &pAcc->arPageFooter, 0, 0);

  pWork->sMaxColNr     = max (pWork->sMaxColNr, pWork->sColNr);
  pWork->bInPageFooter = FALSE;
  pWork->sColNr++;

  if ((pWork->sColNr <= pAcc->sNumCols) && (pWork->xAdd + 2 * pAcc->lWidth + pAcc->lColGap <= pWork->lXOffset + pWork->lRealPageWidth))
    pWork->xAdd += pAcc->lWidth + pAcc->lColGap;
  else
  {
    lSize = file_seek (pWork->hFile, 0L, SEEK_CUR);

    pWork->alPageTable [pWork->lPageNr] = lSize;
    pWork->xAdd                         = pAcc->lMarginLeft;
    pWork->sColNr                       = 1;
    pWork->lPageNr++;
  } /* else */

  pWork->yAdd          = pAcc->lMarginTop;
  pWork->lMaxObjHeight = pAcc->lMarginTop;
  pWork->bNewPage      = TRUE;						/* next object is to be printed to a new page */

  return (bOk);
} /* WritePageFooter */

/*****************************************************************************/

LOCAL BOOL WriteRegion (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount, ACC_REGION *pRegion, LONG xAdd, LONG yAdd)
{
  WORK    *pWork = P_WORK (pProcInf);
  ACCOUNT *pAcc  = pWork->pAccount;
  BOOL    bOk    = TRUE;
  BOOL    bSkipPageHeader, bSkipPageFooter;
  SHORT   i;
  LONG    lDiff;
  LRECT   lr;

  if ((pRegion->sNewPageProp == RNP_BEFORE) || (pRegion->sNewPageProp == RNP_BOTH))
  {
    bSkipPageHeader        = pWork->bSkipPageHeader;		/* do not skip on this page, rather skip on next new page */
    bSkipPageFooter        = pWork->bSkipPageFooter;
    pWork->bSkipPageHeader = FALSE;
    pWork->bSkipPageFooter = FALSE;

    bOk = WritePageFooter (pProcInf, pWork->sTable, pWork->pBuffer, pWork->lCount);

    pWork->bSkipPageHeader = bSkipPageHeader;
    pWork->bSkipPageFooter = bSkipPageFooter;
  } /* if */

  if (bOk)
    if (pRegion->lHeight > 0)
    {
      if ((pRegion->lFlags & REGION_KEEP_TOGETHER) && ! pWork->bNewPage && ! pWork->bInPageFooter)
        if (pWork->yAdd - pWork->ySub + pRegion->lHeight > pWork->lBottom)	/* region doesn't fit on this page */
          bOk = WritePageFooter (pProcInf, pWork->sTable, pWork->pBuffer, pWork->lCount);

      for (i = 0; bOk && (i < pRegion->sNumObjects); i++)
        if (pRegion->pObjects [i].lFlags & OBJ_IS_VISIBLE)
          bOk = WriteObject (pProcInf, sTable, pBuffer, lCount, &pRegion->pObjects [i], xAdd, yAdd, pRegion);
    } /* if, if */

  if (bOk)
  {
    if (pWork->lModY != 0)			/* effect of last object */
    {
      pWork->yAdd     += pWork->lModY;
      pWork->lSumModY += pWork->lModY;
      pWork->lModY     = 0;
    } /* if */

    if (pWork->lSumModY != 0)
    {
      if ((pWork->lSumModY > 0) && ! (pRegion->lFlags & REGION_CAN_GROW) ||
          (pWork->lSumModY < 0) && ! (pRegion->lFlags & REGION_CAN_SHRINK))
        pWork->yAdd -= pWork->lSumModY;		/* reset to old value */

      pWork->lSumModY = 0;
    } /* if */

    lDiff = pRegion->lHeight + pWork->yAdd - pWork->ySub - pWork->lMaxObjHeight;

    if (lDiff > pWork->lBottom - pWork->lMaxObjHeight)	/* don't write over bottom */
      lDiff = pWork->lBottom - pWork->lMaxObjHeight;

    if ((lDiff > 0) && (pRegion->sBkColor != WHITE))
    {
      lr.x = pWork->xAdd + xAdd;
      lr.y = pWork->lMaxObjHeight;
      lr.w = pAcc->lWidth;
      lr.h = lDiff;

      AccPrevWriteBackground (pWork->hFile, &lr, pRegion->sBkColor);
    } /* if */
  } /* if */

  pWork->yAdd          += pRegion->lHeight;
  pWork->lMaxObjHeight  = pWork->yAdd - pWork->ySub;

  if (bOk)
    if ((pRegion->sNewPageProp == RNP_AFTER) || (pRegion->sNewPageProp == RNP_BOTH))
    {
      bOk = WritePageFooter (pProcInf, pWork->sTable, pWork->pBuffer, pWork->lCount);

      if (pWork->bInAccHeader)				/* footer has already been skipped in WritePageFooter */
        pWork->bSkipPageFooter = FALSE;
    } /* if, if */

  return (bOk);
} /* WriteRegion */

/*****************************************************************************/

LOCAL BOOL WriteObject (PROC_INF *pProcInf, SHORT sTable, CHAR *pBuffer, LONG lCount, ACC_OBJECT *pObject, LONG xAdd, LONG yAdd, ACC_REGION *pRegion)
{
  WORK       *pWork = P_WORK (pProcInf);
  ACCOUNT    *pAcc  = pWork->pAccount;
  BOOL       bOk    = TRUE;
  BOOL       bChecked, bHideDuplicates;
  LONG       lHeight, lDiff;
  CHAR       *pText, *pNewText, *p, *pPrevBuffer, *pTotalBuffer, *pParentBuffer;
  SHORT      sHorzAlignment, sVertAlignment, sColumn, sSum, sParentTable;
  LONGSTR    szError, szColumn;
  LRECT      lRect, lr;
  INT        i, iError;
  TABLE_INFO TableInfo, ParentTableInfo;
  FIELD_INFO FieldInfo;
  SYSCALC    *pSysCalc;
  WORD       x, y, wResult;
  VALUEDESC  ValueDesc;
  KEY        key;

  sTable        = sParentTable = rtable (sTable);		/* need physical table only */
  pParentBuffer = NULL;

  v_tableinfo (pProcInf->db, sTable, &TableInfo);

  pPrevBuffer     = pBuffer + TableInfo.size;			/* buffer for comparing to duplicates */
  pTotalBuffer    = pPrevBuffer + TableInfo.size;		/* buffer for total sum */
  bHideDuplicates = FALSE;

  if (lCount > 1)
    if (AccObjHasProperty (pObject->sClass, ACC_PROP_HIDE_DUPLICATES))
      if (pObject->lFlags & OBJ_HIDE_DUPLICATES)
      {
        strcpy (FieldInfo.name, pObject->pColumn);

        sColumn = db_fieldinfo (db->base, sTable, FAILURE, &FieldInfo);

        if (sColumn != FAILURE)
          bHideDuplicates = db_cmpfield (pProcInf->db->base, sTable, sColumn, pBuffer, pPrevBuffer) == 0;
      } /* if, if, if */

  if (pWork->bNewPage)
  {
    bOk = WritePageHeader (pProcInf, pWork->sTable, pWork->pBuffer, pWork->lCount);

    for (i = 0; (i < pRegion->sNumObjects); i++)
      if (pRegion->pObjects [i].lFlags & OBJ_IS_VISIBLE)
        pRegion->pObjects [i].lFlags |= OBJ_SHOW_DUPLICATES;
  } /* if */

  if (bOk)
  {
    pText    = NULL;
    bChecked = TRUE;

    if (AccObjHasProperty (pObject->sClass, ACC_PROP_HORZ_ALIGNMENT))
      sHorzAlignment = pObject->sHorzAlignment;

    if (AccObjHasProperty (pObject->sClass, ACC_PROP_VERT_ALIGNMENT))
      sVertAlignment = pObject->sVertAlignment;

    if (AccObjHasProperty (pObject->sClass, ACC_PROP_TEXT))
      pText = pObject->pText;

    if (pObject->sClass == OBJ_TEXT)
      if (pText != NULL)
      {
        if (((p = strchr (pText, '{')) != NULL) && (strncmpi (p, "{Count}", 7) == 0))
        {
          pNewText = pText;
          i        = 0;

          while (pNewText != p)
            szColumn [i++] = *pNewText++;

          szColumn [i] = EOS;

          sprintf (szColumn + strlen (szColumn), "%ld", lCount);
          strcat (szColumn, p + 7);
          pText = szColumn;
        } /* if */

        if (((p = strchr (pText, '{')) != NULL) && (strncmpi (p, "{Page}", 6) == 0))
        {
          pNewText = pText;
          i        = 0;

          while (pNewText != p)
            szColumn [i++] = *pNewText++;

          szColumn [i] = EOS;

          sprintf (szColumn + strlen (szColumn), "%ld", (pWork->lPageNr - 1) * pWork->sMaxColNr + pWork->sColNr);
          strcat (szColumn, p + 6);
          pText = szColumn;
        } /* if */

        if (pText [0] == '=')
        {
          if (pText [1] == '@')
          {
            pSysCalc = mem_alloc (sizeof (SYSCALC));

            strcpy (pSysCalc->tablename, TableInfo.name);
            strcpy (pSysCalc->name, &pText [2]);
            db_buildkey (pProcInf->db->base, SYS_CALC, 1, pSysCalc, key);
            mem_free (pSysCalc);

            pSysCalc = GetSysRec (pProcInf->db, SYS_CALC, sizeof (SYSCALC), key);

            if (pSysCalc == NULL)
              bOk = FALSE;
          } /* if */
          else
          {
            pSysCalc = mem_alloc (sizeof (SYSCALC));
  
            if (strnicmp (&pText [1], "Var ", 4) == 0)
              sprintf (pSysCalc->text, "%s", &pText [1]);	/* more than a simple expression */
            else
              sprintf (pSysCalc->text, "Var _RetVal; _RetVal=%s; _RetVal=Return (_RetVal);", &pText [1]);
          } /* else */

          if (bOk)
          {
            iError  = db_compile (pProcInf->db->base, sTable, pSysCalc, &y, &x, pProcInf->db->format);
            wResult = CompilerError (iError, pSysCalc->text, y, x);

            if (wResult != CALC_OK)
              bOk = FALSE;
            else
              v_execute (pProcInf->db, sTable, &pSysCalc->code, pBuffer, lCount, &ValueDesc);

            mem_free (pSysCalc);

            if (bOk)
            {
              pText = szColumn;

              if (HASWILD (ValueDesc.type))
                strcpy (szColumn, ValueDesc.val.stringVal);
              else
                bin2str (ValueDesc.type, &ValueDesc.val, szColumn);

              if (pProcInf->db->format != NULL)
                str2format (ValueDesc.type, szColumn, pProcInf->db->format [ValueDesc.type]);
            } /* if */
          } /* if */
        } /* if */
      } /* if, if */

    if ((pText == NULL) || (*pText == EOS) || AccObjHasProperty (pObject->sClass, ACC_PROP_VALUE))
      if (AccObjHasProperty (pObject->sClass, ACC_PROP_COLUMN))
      {
        strcpy (ParentTableInfo.name, pObject->pTable);
        sParentTable = v_tableinfo (pProcInf->db, FAILURE, &ParentTableInfo);

        sSum = AccObjHasProperty (pObject->sClass, ACC_PROP_SUM) ? pObject->sSum : SUM_NONE;

        if (sTable != sParentTable)					/* use parent table */
        {
          pParentBuffer = mem_alloc (ParentTableInfo.size);

          if (pParentBuffer == NULL)
          {
            hndl_alert (ERR_NOMEMORY);
            bOk = FALSE;
          } /* if */
          else
          {
            bOk = FillParentBuffer (pProcInf->db, sParentTable, pParentBuffer, sTable, pBuffer);

            if (bOk)
              pNewText = StringFromColumn (pProcInf->db, sParentTable, pParentBuffer, szColumn, pObject->pColumn, pObject->pFormat, &sHorzAlignment, &sVertAlignment);
          } /* else */
        } /* if */
        else
          pNewText = StringFromColumn (pProcInf->db, sTable, (sSum == SUM_NONE) ? pBuffer : pTotalBuffer, szColumn, pObject->pColumn, pObject->pFormat, &sHorzAlignment, &sVertAlignment);

        if (bOk)
          if (pNewText == NULL)						/* column not found */
          {
            v_tableinfo (pProcInf->db, sTable, &TableInfo);
            sprintf (szError, alerts [ERR_ACC_COLUMN_NOT_FOUND], pObject->pColumn, TableInfo.name);

            open_alert (szError);
            bOk = FALSE;
          } /* if, if */

        if (bOk)
        {
          if (AccObjHasProperty (pObject->sClass, ACC_PROP_VALUE))	/* check box or radio button */
          {
            if ((pObject->pValue == NULL) || (*pObject->pValue == EOS))
              bChecked = *pNewText != EOS;
            else
              bChecked = strcmp (pNewText, pObject->pValue) == 0;

            if (*pNewText == EOS)					/* in case there's no specific text for button, use column name */
              pNewText = pObject->pColumn;
          } /* if */

          if ((pText == NULL) || (*pText == EOS))
            pText = pNewText;
        } /* if */
      } /* if, if */

    if (sHorzAlignment == ALI_HSTANDARD)
      sHorzAlignment = ALI_HLEFT;

    if (sVertAlignment == ALI_VSTANDARD)
      sVertAlignment = ALI_VTOP;

    lHeight = AccObjCalcUnitHeight (pObject, pWork->sPrnHandle, pText, pWork->lPixelsPerMeter);

    if (pWork->lModY != 0)
      if (pObject->rcPos.y >= pWork->lRefY)
      {
        pWork->yAdd     += pWork->lModY;
        pWork->lSumModY += pWork->lModY;
        pWork->lModY     = 0;
      } /* if, if */

    if (bOk && ! pWork->bInPageFooter)
      if (pObject->rcPos.y + pWork->yAdd - pWork->ySub + lHeight > pWork->lBottom)	/* object doesn't fit on this page */
      {
        lDiff = pObject->rcPos.y + pWork->yAdd - pWork->ySub - pWork->lMaxObjHeight;

        if (lDiff > pWork->lBottom - pWork->lMaxObjHeight)
          lDiff = pWork->lBottom - pWork->lMaxObjHeight;

        if (lDiff > 0)
        {
          if (pRegion->sBkColor != WHITE)
          {
            lr.x = pWork->xAdd + xAdd;
            lr.y = pWork->lMaxObjHeight;
            lr.w = pAcc->lWidth;
            lr.h = lDiff;

            AccPrevWriteBackground (pWork->hFile, &lr, pRegion->sBkColor);
          } /* if */

          pWork->lMaxObjHeight += lDiff;
        } /* if */

        bOk = WritePageFooter (pProcInf, pWork->sTable, pWork->pBuffer, pWork->lCount);

        if (bOk)
          bOk = WritePageHeader (pProcInf, pWork->sTable, pWork->pBuffer, pWork->lCount);

        pWork->ySub = pObject->rcPos.y;					/* this object should be the first on the page */

        for (i = 0; (i < pRegion->sNumObjects); i++)
          if (pRegion->pObjects [i].lFlags & OBJ_IS_VISIBLE)
            pRegion->pObjects [i].lFlags |= OBJ_SHOW_DUPLICATES;	/* show duplicates on new page */
      } /* if, if */

    lDiff = lHeight - pObject->rcPos.h;

    if (lDiff != 0)							/* object size changed */
      if ((lDiff > pWork->lModY) || (pWork->lModY == 0))
      {
        pWork->lModY = lDiff;
        pWork->lRefY = pObject->rcPos.y + pObject->rcPos.h;
      } /* if, if */

    lRect    = pObject->rcPos;
    lRect.x += pWork->xAdd - pWork->xSub + xAdd;
    lRect.y += pWork->yAdd - pWork->ySub + yAdd;
    lRect.h  = lHeight;

    if (pObject->sClass != OBJ_SUBACCOUNT)				/* sub account has it's own background color */
      if (lRect.y + lHeight > pWork->lMaxObjHeight)
      {
        if (pRegion->sBkColor != WHITE)
        {
          lr.x = pWork->xAdd + xAdd;
          lr.y = pWork->lMaxObjHeight;
          lr.w = pAcc->lWidth;
          lr.h = lRect.y + lHeight - pWork->lMaxObjHeight;

          AccPrevWriteBackground (pWork->hFile, &lr, pRegion->sBkColor);
        } /* if, if */

        pWork->lMaxObjHeight = lRect.y + lHeight;
      } /* if, if */

    if (bOk)
      if (AccObjHasProperty (pObject->sClass, ACC_PROP_BK_MODE))
        if (pObject->sBkMode != MODE_TRANSPARENT)
          bOk = AccPrevWriteBackground (pWork->hFile, &lRect, pObject->sBkColor);

    if (pObject->lFlags & OBJ_SHOW_DUPLICATES)				/* occurs if object is to be printed on a new page */
      bHideDuplicates = FALSE;

    if (bOk && ! bHideDuplicates)
      switch (pObject->sClass)
      {
        case OBJ_TEXT        : /* fall through */
        case OBJ_COLUMN      : if (lHeight != 0)
                                 bOk = AccPrevWriteRectangle (pWork->hFile, &lRect, pObject->sEffect, pObject->sBorderMode, pObject->sBorderColor, pObject->lBorderWidth, pObject->sBorderStyle);
                               if (pText != NULL)
                                 bOk = bOk && AccPrevWriteText (pWork->hFile, &lRect, (pObject->sBorderMode == MODE_OPAQUE) ? pObject->lBorderWidth : 0L, &pObject->Font, sHorzAlignment, sVertAlignment, pObject->sRotation, pText);
                               break;
        case OBJ_LINE        : bOk = AccPrevWriteLine (pWork->hFile, &lRect, pObject->sEffect, pObject->sBorderMode, pObject->sBorderColor, pObject->lBorderWidth, pObject->sBorderStyle);
                               break;
        case OBJ_BOX         : bOk = AccPrevWriteRectangle (pWork->hFile, &lRect, pObject->sEffect, pObject->sBorderMode, pObject->sBorderColor, pObject->lBorderWidth, pObject->sBorderStyle);
                               break;
        case OBJ_GROUPBOX    : bOk = AccPrevWriteGroupBox (pWork->hFile, &lRect, pObject->sEffect, pObject->sBorderMode, pObject->sBorderColor, pObject->lBorderWidth, pObject->sBorderStyle, &pObject->Font, pObject->sHorzAlignment, pText);
                               break;
        case OBJ_CHECKBOX    : /* fall through */
        case OBJ_RADIOBUTTON : bOk = AccPrevWriteCheckRadio (pWork->hFile, &lRect, pObject->sEffect, &pObject->Font, pText, bChecked, pObject->sClass == OBJ_RADIOBUTTON);
                               break;
        case OBJ_GRAPHIC     : bOk = AccPrevWriteRectangle (pWork->hFile, &lRect, pObject->sEffect, pObject->sBorderMode, pObject->sBorderColor, pObject->lBorderWidth, pObject->sBorderStyle);
                               bOk = bOk && AccPrevWriteGraphic (pWork->hFile, &lRect, (pObject->sBorderMode == MODE_OPAQUE) ? pObject->lBorderWidth : 0L, pObject->pFileName);
                               break;
        case OBJ_SUBACCOUNT  : bOk = HandleSubAccount (pProcInf, pObject, xAdd, yAdd, &lRect, sTable, pBuffer);
                               break;
      } /* switch, if */

    pObject->lFlags &= ~ OBJ_SHOW_DUPLICATES;
  } /* if */

  if (pParentBuffer != NULL)
    mem_free (pParentBuffer);

  return (bOk);
} /* WriteObject */

/*****************************************************************************/

LOCAL BOOL HandleSubAccount (PROC_INF *pProcInf, ACC_OBJECT *pObject, LONG xAdd, LONG yAdd, LRECT *pRect, SHORT sMasterTable, CHAR *pMasterBuffer)
{
  WORK       *pWork = P_WORK (pProcInf);
  BOOL       bOk    = TRUE;
  ACCOUNT    Account;
  SYSACCOUNT SysAccount;
  CURSOR     cursor;
  LONGSTR    s, szSQL;
  FIELDNAME  szTableName;
  SHORT      sTable;
  CHAR       *p, *pBuffer, *pPrevBuffer, *pTotalBuffer;
  CHAR       *pLinkMasterFields, *pLinkChildFields;
  CHAR       *pLinkMasterField [MAX_INXCOLS], *pLinkChildField [MAX_INXCOLS];
  INT        i, iLinkMasterField, iLinkChildField;
  BOOL       bWarnTable;
  SQL_RESULT SqlResult;
  TABLE_INFO TableInfo;
  LONG       lCount;

  if ((pObject->pAccountName != NULL) && (pObject->pAccountName [0] != EOS))
  {
    strcpy (SysAccount.name, pObject->pAccountName);

    bOk = FALSE;

    if (db_search (pProcInf->db->base, SYS_ACCOUNT, 1, ASCENDING, &cursor, &SysAccount, 0L))
      if (db_read (pProcInf->db->base, SYS_ACCOUNT, &SysAccount, &cursor, 0L, FALSE))
        bOk = TRUE;

    if (! bOk)
    {
      sprintf (s, alerts [ERR_ACC_NOT_FOUND], pObject->pAccountName);
      open_alert (s);
    } /* if */

    if (bOk)
    {
      bOk = AccMemFromSys (pProcInf->db->base, &Account, &SysAccount);
      AccSortObjects (&Account);
    } /* if */

    if (bOk)
      bOk = TableNameFromQuery (pProcInf->db, &Account, szTableName);

    if (bOk)
    {
      pLinkMasterFields = (pObject->pLinkMasterFields == NULL) ? NULL : strdup (pObject->pLinkMasterFields);
      pLinkChildFields  = (pObject->pLinkChildFields == NULL) ? NULL : strdup (pObject->pLinkChildFields);

      if (pLinkMasterFields != NULL)
        for (iLinkMasterField = 0, p = strtok (pLinkMasterFields, ",;"); p != NULL; p = strtok (NULL, ",;"))
          pLinkMasterField [iLinkMasterField++] = p;

      if (pLinkChildFields != NULL)
        for (iLinkChildField = 0, p = strtok (pLinkChildFields, ",;"); p != NULL; p = strtok (NULL, ",;"))
          pLinkChildField [iLinkChildField++] = p;

      iLinkMasterField = min (iLinkMasterField, iLinkChildField);

      sprintf (szSQL, "SELECT * FROM %s", szTableName);

      for (i = 0; bOk && (i < iLinkMasterField); i++)
      {
        if (i == 0)
          strcat (szSQL, " WHERE ");
        else
          strcat (szSQL, " AND ");

        strcat (szSQL, pLinkChildField [i]);
        strcat (szSQL, " = ");

        p = StringFromColumn (pProcInf->db, sMasterTable, pMasterBuffer, s, pLinkMasterField [i], NULL, NULL, NULL);

        if (p == NULL)
        {
          bOk = FALSE;
          sprintf (s, alerts [ERR_ACC_COLUMN_NOT_FOUND], pLinkMasterField [i], szTableName);
          open_alert (s);
        } /* if */
        else
        {
          strcat (szSQL, "'");
          strcat (szSQL, p);
          strcat (szSQL, "'");
        } /* else */
      } /* for */

      if ((pObject->pLinkCondition != NULL) && (*pObject->pLinkCondition != EOS))
      {
        if (iLinkMasterField == 0)
          strcat (szSQL, " WHERE ");
        else
          strcat (szSQL, " AND ");

        strcat (szSQL, pObject->pLinkCondition);
      } /* if */

      if ((pObject->pLinkOrder != NULL) && (*pObject->pLinkOrder != EOS))
      {
        strcat (szSQL, " ORDER BY ");
        strcat (szSQL, pObject->pLinkOrder);
      } /* if */

      if (bOk)
      {
        busy_mouse ();

        bWarnTable        = warn_table;
        warn_table        = FALSE;
        pProcInf->pausing = TRUE;

        sql_exec (pProcInf->db, szSQL, "", FALSE, &SqlResult);
        bOk = SqlResult.db != NULL;

        pProcInf->pausing = FALSE;
        warn_table        = bWarnTable;

        set_timer ();

        if (bOk)
        {
          v_tableinfo (db, SqlResult.table, &TableInfo);

          sTable  = SqlResult.table;			/* set new values */
          pBuffer = mem_alloc (3 * TableInfo.size);	/* buffer, compare buffer, total sum buffer */
          lCount  = 0;

          if (pBuffer == NULL)
          {
            hndl_alert (ERR_NOMEMORY);
            bOk = FALSE;
          } /* if */
          else
          {
            pPrevBuffer  = pBuffer + TableInfo.size;			/* buffer for comparing to duplicates */
            pTotalBuffer = pPrevBuffer + TableInfo.size;		/* buffer for total sum */
            pWork->yAdd  = pRect->y + pWork->ySub;			/* ySub is being added in case subaccount is first item on new page */

            ZeroValues (pProcInf->db, sTable, pTotalBuffer);

            if (v_initcursor (pProcInf->db, SqlResult.table, SqlResult.inx, SqlResult.dir, &cursor))
              while (bOk && v_movecursor (pProcInf->db, &cursor, SqlResult.dir))
              {
                mem_lmove (pPrevBuffer, pBuffer, TableInfo.size);

                if (v_read (pProcInf->db, SqlResult.table, pBuffer, &cursor, 0L, FALSE))
                {
                  lCount++;

                  if (pProcInf->use_calc)
                    v_execute (pProcInf->db, SqlResult.table, &db->t_info [tableinx (pProcInf->db, rtable (SqlResult.table))].calccode, pBuffer, lCount, NULL);

                  AddValues (pProcInf->db, sTable, pBuffer, pTotalBuffer);

                  if (Account.arDetails.lFlags & REGION_VISIBLE)
                    bOk = WriteRegion (pProcInf, sTable, pBuffer, lCount, &Account.arDetails, xAdd + pObject->rcPos.x, yAdd);
                } /* if */
              } /* while, if */

            pWork->ySub += pObject->rcPos.y + pObject->rcPos.h;

            mem_free (pBuffer);
          } /* else */

          mem_free (SqlResult.columns);

          if (VTBL (SqlResult.table))
            free_vtable (SqlResult.table);

          if (VINX (SqlResult.inx))
            free_vindex (SqlResult.inx);
        } /* if */

        arrow_mouse ();
      } /* if */

      if (pLinkMasterFields != NULL)
        free (pLinkMasterFields);

      if (pLinkChildFields != NULL)
        free (pLinkChildFields);

      AccFree (&Account);
    } /* if */

    set_meminfo ();
  } /* if */

  return (bOk);
} /* HandleSubAccount */

/*****************************************************************************/

LOCAL BOOL TableNameFromQuery (DB *db, ACCOUNT *pAccount, CHAR *pTableName)
{
  BOOL     bOk;
  CHAR     *p;
  SYSQUERY SysQuery;
  CURSOR   cursor;

  bOk         = TRUE;
  *pTableName = EOS;

  if (pAccount->bTable)
    strcpy (pTableName, pAccount->szTableOrQuery);
  else
  {
    *pTableName = EOS;

    strcpy (SysQuery.name, pAccount->szTableOrQuery);
    bOk = db_search (db->base, SYS_QUERY, 1, ASCENDING, &cursor, &SysQuery, 0L);

    if (bOk)
      bOk = db_read (db->base, SYS_QUERY, &SysQuery, &cursor, 0L, FALSE);

    if (bOk)
    {
      p = strstr (SysQuery.query, "FROM");		/* look for table name behind id FROM */

      if (p != NULL)
      {
        for (p += 4; isspace (*p); p++);
        strncpy (pTableName, p, MAX_TABLENAME);
        pTableName [MAX_TABLENAME] = EOS;
        for (p = pTableName; isalnum (ch_ascii (*p)) || (*p == '_'); p++);
        *p = EOS;
      } /* if */
    } /* if */
  } /* else */

  return (bOk);
} /* TableNameFromQuery */

/*****************************************************************************/

LOCAL CHAR *StringFromColumn (DB *db, SHORT sTable, CHAR *pBuffer, CHAR *pColumnBuffer, CHAR *pColumn, CHAR *pFormat, SHORT *psHorzAlignment, SHORT *psVertAlignment)
{
  CHAR       *pString, *pField;
  SHORT      sColumn, sType, sFormat;
  FIELD_INFO FieldInfo;
  FORMAT     Format;

  strcpy (FieldInfo.name, pColumn);

  sColumn = db_fieldinfo (db->base, sTable, FAILURE, &FieldInfo);

  if (sColumn == FAILURE)
    pString = NULL;
  else
  {
    sType   = FieldInfo.type;
    sFormat = FieldInfo.format;
    pField  = pBuffer + FieldInfo.addr;

    if (psHorzAlignment != NULL)
      if (*psHorzAlignment == ALI_HSTANDARD)
        switch (sType)
        {
          case TYPE_WORD      : /* fall through */
          case TYPE_LONG      : /* fall through */
          case TYPE_FLOAT     : /* fall through */
          case TYPE_CFLOAT    : /* fall through */
          case TYPE_DBADDRESS : *psHorzAlignment = ALI_HRIGHT; break;
          default             : *psHorzAlignment = ALI_HLEFT;  break;
        } /* switch, if, if */

    if (psVertAlignment)
      if (*psVertAlignment == ALI_VSTANDARD)
        *psVertAlignment = ALI_VTOP;

    if ((sType == TYPE_CHAR) && (strlen (pField) > LONGSTRLEN))
      pString = pField;
    else
    {
      pString = pColumnBuffer;
      bin2str (sType, pField, pString);

      if ((pFormat != NULL) && (*pFormat != EOS))
      {
        build_format (sType, pFormat, Format);
        str2format (sType, pString, Format);
      } /* if */
      else
      {
        if (db->format != NULL)
          str2format (sType, pString, db->format [sFormat]);

        if ((sType == TYPE_WORD) || (sType == TYPE_LONG) || (sType == TYPE_FLOAT))	/* I don't need blanks to format numbers */
        {
          RemLeadSP (pString);
          RemTrailSP (pString);
        } /* if */
      } /* else */
    } /* else */
  } /* else */

  return (pString);
} /* StringFromColumn */

/*****************************************************************************/

LOCAL VOID *GetSysRec (DB *db, SHORT sTable, LONG lSize, CHAR *pName)
{
  BOOL   bOk;
  CHAR   *p;
  CURSOR cursor;
  STRING sz;

  bOk = TRUE;
  p   = mem_alloc (lSize);

  if (p == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    strcpy (sz, pName);
    db_convstr (db->base, sz);

    bOk = db_keysearch (db->base, sTable, 1, ASCENDING, &cursor, sz, 0L);

    if (! bOk)
    {
      sprintf (sz, alerts [ERR_REC_NOT_FOUND], pName);
      open_alert (sz);
      mem_free (p);
      p = NULL;
    } /* if */
    else
    {
      bOk = db_read (db->base, sTable, p, &cursor, 0L, FALSE);

      if (! bOk)
      {
        dbtest (db);
        mem_free (p);
        p = NULL;
      } /* if */
    } /* else */
  } /* else */

  return (p);
} /* GetSysRec */

/*****************************************************************************/

LOCAL WORD CompilerError (INT iError, BYTE *pCalcText, WORD wLine, WORD wCol)
{
  WORD    result, i, inx;
  LONGSTR s;
  STRING  text;
  BYTE    *p;

  if (iError == SUCCESS) return (CALC_OK);

  for (i = inx = 0; i < wLine; i++)
    while (pCalcText [inx++] != LF);

  inx += wCol;

  strncpy (text, &pCalcText [inx], MAX_ERRCHARS);
  text [MAX_ERRCHARS] = EOS;

  if ((p = strchr (text, CR)) != NULL) *p = EOS;
  if ((p = strchr (text, LF)) != NULL) *p = EOS;
  if ((p = strchr (text, SEP_OPEN)) != NULL) *p = EOS;

  sprintf (s, alerts [iError], text, wLine + 1, wCol + 1);

  result = open_alert (s);

  return (result);
} /* CompilerError */

/*****************************************************************************/

LOCAL VOID ZeroValues (DB *db, SHORT sTable, CHAR *pBuffer)
{
  TABLE_INFO TableInfo;
  FIELD_INFO FieldInfo;
  WORD       i;

  v_tableinfo (db, sTable, &TableInfo);

  mem_lset (pBuffer, 0, TableInfo.size);

  for (i = 1; i < TableInfo.cols; i++)
  {
    db_fieldinfo (db->base, rtable (sTable), i, &FieldInfo);

    switch (FieldInfo.type)			/* all fields which cannot be added */
    {
      case TYPE_CHAR      :
      case TYPE_DATE      :
      case TYPE_TIME      :
      case TYPE_TIMESTAMP :
      case TYPE_VARBYTE   :
      case TYPE_VARWORD   :
      case TYPE_VARLONG   :
      case TYPE_PICTURE   :
      case TYPE_EXTERN    :
      case TYPE_DBADDRESS : set_null (FieldInfo.type, pBuffer + FieldInfo.addr); break;
    } /* switch */
  } /* for */
} /* ZeroValues */

/*****************************************************************************/

LOCAL VOID AddValues (DB *db, SHORT sTable, CHAR *pBuffer, CHAR *pSumBuffer)
{
  TABLE_INFO TableInfo;
  FIELD_INFO FieldInfo;
  CALC_TYPE  res, sum;
  DOUBLE     dbl_res, dbl_sum;
  WORD       i, table;
  BOOLEAN    calc;

  table = rtable (sTable);

  v_tableinfo (db, sTable, &TableInfo);

  for (i = 1; i < TableInfo.cols; i++)
  {
    db_fieldinfo (db->base, table, i, &FieldInfo);

    switch (FieldInfo.type)
    {
      case TYPE_WORD   :
      case TYPE_LONG   :
      case TYPE_FLOAT  :
      case TYPE_CFLOAT : calc = TRUE;  break;
      default          : calc = FALSE; break;
    } /* switch */

    if (calc && ! is_null (FieldInfo.type, pBuffer + FieldInfo.addr))
    {
      db_getfield (db->base, table, i, pBuffer, &sum);
      db_getfield (db->base, table, i, pSumBuffer, &res);

      switch (FieldInfo.type)
      {
        case TYPE_WORD   : res.c_word += sum.c_word;
                           break;
        case TYPE_LONG   : res.c_long += sum.c_long;
                           break;
        case TYPE_CFLOAT : str2bin (TYPE_FLOAT, sum.c_cfloat, &dbl_sum);
                           str2bin (TYPE_FLOAT, res.c_cfloat, &dbl_res);
                           dbl_res += dbl_sum;
                           bin2str (TYPE_FLOAT, &dbl_res, res.c_cfloat);
                           res.c_cfloat [FieldInfo.size] = EOS;
                           break;
        case TYPE_FLOAT  : res.c_float += sum.c_float;
                           break;
      } /* switch */

      db_setfield (db->base, table, i, pSumBuffer, &res);
    } /* if */
  } /* for */
} /* AddValues */

/*****************************************************************************/

LOCAL BOOL FillParentBuffer (DB *db, SHORT sParentTable, CHAR *pParentBuffer, SHORT sTable, CHAR *pBuffer)
{
  BOOL       bOk, bFound;
  SYSREL     *pSysRel;
  SHORT      sRecs, i, sParentIndex, sIndex;
  TABLE_INFO TableInfo;
  KEY        key;
  CURSOR     cursor;

  bOk    = TRUE;
  bFound = FALSE;

  db_tableinfo (db->base, SYS_REL, &TableInfo);
  db_fillnull (db->base, sParentTable, pParentBuffer);

  sRecs = (WORD)TableInfo.recs;

  for (i = 0, pSysRel = db->base->sysrel; (i < sRecs) && ! bFound; i++, pSysRel++)	/* look for parent table */
    if ((sParentTable == pSysRel->reftable) && (sTable == pSysRel->reltable))
    {
      sParentIndex = pSysRel->refindex;
      sIndex       = pSysRel->relindex;
      bFound       = TRUE;
    } /* if, for */

  for (i = 0, pSysRel = db->base->sysrel; (i < sRecs) && ! bFound; i++, pSysRel++)	/* look for detail table */
    if ((sParentTable == pSysRel->reltable) && (sTable == pSysRel->reftable))
    {
      sParentIndex = pSysRel->relindex;
      sIndex       = pSysRel->refindex;
      bFound       = TRUE;
    } /* if, for */

  if (bFound)
  {
    db_buildkey (db->base, sTable, sIndex, pBuffer, key);

    if (db_keysearch (db->base, sParentTable, sParentIndex, ASCENDING, &cursor, key, 0L))
      bOk = db_read (db->base, sParentTable, pParentBuffer, &cursor, 0L, FALSE);
  } /* if */

  return (bOk);
} /* FillParentBuffer */

/*****************************************************************************/

