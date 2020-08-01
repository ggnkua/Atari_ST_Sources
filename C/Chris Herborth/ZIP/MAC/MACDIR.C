#include    <Errors.h>
#include    <Files.h>
#ifndef THINK_C
#include    <Strings.h>
#endif

#ifndef FSFCBLen
#define FSFCBLen    (*(short *)0x3F6)
#endif

#include    <errno.h>
#include    <stdlib.h>
#include    <string.h>

#include    "macdir.h"

int closedir(dPtr) DIR *dPtr; {
    free(dPtr);

    return 0;
}

DIR *opendir(dirName) char *dirName; {
    int fullPath, pathLen;
    char *s, pName[256];
    HParamBlockRec hPB;
    CInfoPBRec cPB;
    DIR *dPtr;
    OSErr err;

    if (dirName == NULL || *dirName == '\0' || (pathLen = strlen(dirName)) > 255) {
        errno = EINVAL;
        return NULL;
    }

    if (FSFCBLen <= 0) {
        errno = ENOTDIR;
        return NULL;
    }

    /* Get information about volume. */

    memset(&hPB, '\0', sizeof(hPB));

    strcpy(pName, dirName);

    if (((s = strchr(pName, ':')) == NULL) || (*pName == ':')) {
        fullPath = false;
    } else {
        *(s + 1) = '\0';
        c2pstr(pName);
        hPB.volumeParam.ioVolIndex = -1;
        fullPath = true;
    }

    hPB.volumeParam.ioNamePtr = (StringPtr)pName;

    err = PBHGetVInfo(&hPB, 0);

    if ((err != noErr) || (hPB.volumeParam.ioVFSID != 0)) {
        errno = ENOENT;
        return NULL;
    }

    /* Get information about file. */

    memset(&cPB, '\0', sizeof(cPB));

    strcpy(pName, dirName);
    c2pstr(pName);

    if (fullPath)
        cPB.hFileInfo.ioVRefNum = hPB.volumeParam.ioVRefNum;

    cPB.hFileInfo.ioNamePtr = (StringPtr)pName;

    err = PBGetCatInfo(&cPB, false);

    if (err != noErr) {
        errno = (err == fnfErr) ? ENOENT : EIO;
        return NULL;
    }

    if (!(cPB.hFileInfo.ioFlAttrib & ioDirMask)) {
        errno = ENOTDIR;
        return NULL;
    }

    /* Get space for, and fill in, DIR structure. */

    if ((dPtr = (DIR *)malloc(sizeof(DIR))) == NULL) {
        return NULL;
    }

    dPtr->ioVRefNum = cPB.dirInfo.ioVRefNum;
    dPtr->ioDrDirID = cPB.dirInfo.ioDrDirID;
    dPtr->ioFDirIndex = 1;
    dPtr->flags = 0;

    return dPtr;
}

struct dirent *readdir(dPtr) DIR *dPtr; {
    struct dirent *dirPtr;
    CInfoPBRec cPB;
    char name[32];
    OSErr err;

    if (dPtr->flags) {
        return NULL;
    }

    /* Get information about file. */

    memset(&cPB, '\0', sizeof(cPB));

    cPB.hFileInfo.ioNamePtr = (StringPtr)name;
    cPB.hFileInfo.ioFDirIndex = dPtr->ioFDirIndex;
    cPB.hFileInfo.ioVRefNum = dPtr->ioVRefNum;
    cPB.hFileInfo.ioDirID = dPtr->ioDrDirID;

    err = PBGetCatInfo(&cPB, false);

    if (err != noErr) {
        dPtr->flags = 0xff;
        errno = (err == fnfErr) ? ENOENT : EIO;
        return NULL;
    }

    p2cstr((StringPtr)name);

    dirPtr = &dPtr->currEntry;

    dirPtr->d_fileno = dPtr->ioFDirIndex++;
    dirPtr->d_namlen = strlen(name);
    strcpy(dirPtr->d_name, name);
    dirPtr->d_reclen = sizeof(struct dirent) - sizeof(dirPtr->d_name) + dirPtr->d_namlen;

    return dirPtr;
}
