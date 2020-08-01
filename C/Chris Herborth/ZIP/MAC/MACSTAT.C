#ifdef THINK_C
#define MACOS
#include    <pascal.h>
#endif
#ifdef MPW
#define MACOS
#include    <Files.h>
#include    <Errors.h>
#define FSFCBLen    (*(short *)0x3F6)
#endif

#ifdef MACOS
#include    <string.h>
#include    "macstat.h"
int macstat(char *path, struct stat *buf, short nVRefNum, long lDirID );

#define unixTime(t) ((t) = ((t) < (time_t)0x7c25b080) ? 0 : (t) - (time_t)0x7c25b080)

/* assume that the path will contain a Mac-type pathname, i.e. ':'s, etc. */
int macstat(char *path, struct stat *buf, short nVRefNum, long lDirID )
{
    char    temp[256];
    short   nVRefNumT;
    long    lDirIDT;
    short   fIsHFS = false;
    OSErr   err;
    short   fUseDefault = ((nVRefNum == 0) && (lDirID == 0));

    if (buf == (struct stat *)0L || path == (char *)0L) {
        SysBeep(1);
        return -1;
    }

    if (path[0] == '\0' || strlen(path)>255) {
        return -1;
    }

    if ( fUseDefault )
    {
        if (GetVol((StringPtr)&temp[0], &nVRefNumT) != noErr) {
            SysBeep(1);
            return -1;
        }
    }

    /* get info about the specified volume */
    if (FSFCBLen > 0)   /* HFS Disk? */
    {
        HParamBlockRec    hpbr;

        if ( fUseDefault )
        {
            WDPBRec wdpb;

            wdpb.ioCompletion = 0;
            wdpb.ioNamePtr = (StringPtr)temp;
            err = PBHGetVol(&wdpb, 0);
            nVRefNumT = wdpb.ioWDVRefNum;
            lDirIDT = wdpb.ioWDDirID;
        }
        else
        {
            nVRefNumT = nVRefNum;
            lDirIDT = lDirID;
            err = noErr;
        }
        if (err == noErr)
        {
            hpbr.volumeParam.ioCompletion = 0;
            hpbr.volumeParam.ioNamePtr = (StringPtr)temp;
            hpbr.volumeParam.ioVRefNum = nVRefNumT;
            hpbr.volumeParam.ioVolIndex = 0;
            err = PBHGetVInfo(&hpbr, 0);

            if (err == noErr && hpbr.volumeParam.ioVFSID == 0
                && hpbr.volumeParam.ioVSigWord == 0x4244) {
                    fIsHFS = true;
            }
        }
    }


    /* number of links, at least in System 6.0x, 0 */
    buf->st_nlink = 0;
    /* user id */
    buf->st_uid = 0;
    /* group id */
    buf->st_gid = 0;

    if (fIsHFS == true)   /* HFS? */
    {
        CInfoPBRec  cPB;
        HParamBlockRec  hPB;

        /* get information about file */
        cPB.hFileInfo.ioCompletion = (ProcPtr)0L;
        c2pstr(path);
        strncpy(temp,path, path[0]+1);
        p2cstr(path);
        cPB.hFileInfo.ioNamePtr = (StringPtr)temp;
        cPB.hFileInfo.ioVRefNum = nVRefNumT;
        cPB.hFileInfo.ioDirID = lDirIDT;
        cPB.hFileInfo.ioFDirIndex = 0;

        err = PBGetCatInfo(&cPB, false);

        if (err != noErr) {
            if ((err != fnfErr) && (err != dirNFErr)) {
                SysBeep(1);
            }
            return -1;
        }

        /* Type of file: directory or regular file + access */
        buf->st_mode = (cPB.hFileInfo.ioFlAttrib & ioDirMask) ? S_IFDIR : S_IFREG |
                       (cPB.hFileInfo.ioFlAttrib & 0x01) ? S_IREAD : (S_IREAD | S_IWRITE);

        /* last access time, modification time and creation time(?) */
        buf->st_atime = buf->st_mtime = cPB.hFileInfo.ioFlMdDat;
        buf->st_ctime = cPB.hFileInfo.ioFlCrDat;
        /* dev number */
        buf->st_dev = (long)cPB.hFileInfo.ioVRefNum;
        /* inode number */
        buf->st_ino = cPB.hFileInfo.ioDirID;
        /* size of file - use only the data fork */
        buf->st_size = cPB.hFileInfo.ioFlLgLen;

        /* size of disk block */
        hPB.volumeParam.ioCompletion = (ProcPtr)0L;
        hPB.volumeParam.ioNamePtr = (StringPtr)temp;
        hPB.volumeParam.ioVRefNum = nVRefNumT;
        hPB.volumeParam.ioVolIndex = 0;

        err = PBHGetVInfo(&hPB, false);

        if (err != noErr) {
            SysBeep(1);
            return -1;
        }

        buf->st_blksize = cPB.hFileInfo.ioFlPyLen / hPB.volumeParam.ioVAlBlkSiz;
    }
    else    /* MFS? */
    {
        ParamBlockRec   pPB;
        ParamBlockRec   hPB;

        c2pstr(path);
        strncpy(temp, path, path[0]+1);
        p2cstr(path);
        pPB.fileParam.ioCompletion = (ProcPtr)0;
        pPB.fileParam.ioNamePtr = (StringPtr)temp;
        pPB.fileParam.ioVRefNum = nVRefNumT;
        pPB.fileParam.ioFVersNum = 0;
        pPB.fileParam.ioFDirIndex = 0;

        err = PBGetFInfo(&pPB, false);

        if (err != noErr) {
            SysBeep(1);
            return -1;
        }

        /* Type of file: either directory or regular file + access */
        buf->st_mode = (pPB.fileParam.ioFlAttrib & ioDirMask) ? S_IFDIR : S_IFREG;
                       (pPB.fileParam.ioFlAttrib & 0x01) ? S_IREAD : (S_IREAD | S_IWRITE);

        /* last access time, modification time and creation time(?) */
        buf->st_atime = buf->st_mtime = pPB.fileParam.ioFlMdDat;
        buf->st_ctime = pPB.fileParam.ioFlCrDat;
        /* dev number */
        buf->st_dev = (long)pPB.fileParam.ioVRefNum;
        /* inode number */
        buf->st_ino = pPB.fileParam.ioFlNum;
        /* size of file - use only the data fork */
        buf->st_size = pPB.fileParam.ioFlLgLen;

        /* size of disk block */
        hPB.volumeParam.ioCompletion = (ProcPtr)0;
        hPB.volumeParam.ioNamePtr = (StringPtr)temp;
        hPB.volumeParam.ioVRefNum = nVRefNumT;
        hPB.volumeParam.ioVolIndex = 0;

        err = PBGetVInfo(&hPB, false);

        if (err != noErr) {
            SysBeep(1);
            return -1;
        }

        buf->st_blksize = pPB.fileParam.ioFlPyLen / hPB.volumeParam.ioVAlBlkSiz;
    }

    /* Convert from Macintosh time format to Unix time format. */

    unixTime(buf->st_atime);
    unixTime(buf->st_mtime);
    unixTime(buf->st_ctime);

    return 0;
}
#else
#error 1
#endif
