#include "unzip.h"

#include <Traps.h>
#include <Values.h>

extern char UnzipVersion[], ZipinfoVersion[];

void MacFSTest (int);
void ResolveMacVol (short, short *, long *, StringPtr);

#define aboutAlert      128

#define selectDialog    129
#define okItem          1
#define cancelItem      2
#define editItem        3
#define staticItem      4

#define unzipMenuBar    128

#define appleMenu       128
#define aboutItem       1

#define fileMenu        129
#define extractItem     1
#define infoItem        2
#define listItem        3
#define testItem        4
#define commentItem     6
#define freshenItem     8
#define updateItem      9
#define quitItem        11

#define editMenu        130
#define cutItem         1
#define copyItem        2
#define pasteItem       3

#define modifierMenu    131
#define selectItem      1
#define screenItem      3
#define pauseItem       4
#define scrollItem      5
#define convertItem     7
#define junkItem        8
#define lowercaseItem   9
#define neverItem       10
#define promptItem      11
#define quietItem       12
#define verboseItem     13

short modifiers, modifierMask;

#define convertFlag     0x0001
#define junkFlag        0x0002
#define lowercaseFlag   0x0004
#define neverFlag       0x0008
#define promptFlag      0x0010
#define quietFlag       0x0020
#define screenFlag      0x0040
#define scrollFlag      0x0200
#define verboseFlag     0x0080
#define allFlags        0x03FF

#define pauseFlag       0x0100
#define scrollFlag      0x0200

#define extractMask     0x003F
#define infoMask        0x0000
#define listMask        0x0020
#define testMask        0x0020
#define commentMask     0x0000
#define freshenMask     0x003F
#define updateMask      0x003F

EventRecord myevent;
MenuHandle appleHandle, modifierHandle;
Handle menubar, itemHandle;
short itemType;
Rect itemRect;

char command, fileList[256];

Boolean stop;

SysEnvRec sysRec;

char *macgetenv(s) char *s; {
    if (s == NULL) return(fileList);
    return(NULL);
}

Boolean TrapAvailable(machineType, trapNumber, trapType)
short machineType;
short trapNumber;
TrapType trapType;
{
    if (machineType < 0)
        return (false);

    if ((trapType == ToolTrap) &&
        (machineType > envMachUnknown) &&
        (machineType < envMacII)) {
        if ((trapNumber &= 0x03FF) > 0x01FF)
            trapNumber = _Unimplemented;
    }
    return (NGetTrapAddress(trapNumber, trapType) !=
        GetTrapAddress(_Unimplemented));
}

void domenu(menucommand) long menucommand;
{
    short check, themenu, theitem;
    DialogPtr thedialog;
    Str255 name;

    themenu = HiWord(menucommand);
    theitem = LoWord(menucommand);

    switch (themenu) {

    case appleMenu:
        if (theitem == aboutItem) {
            ParamText(UnzipVersion, ZipinfoVersion, nil, nil);
            Alert(aboutAlert, nil);
        } else {
            GetItem(appleHandle, theitem, name);
            theitem = OpenDeskAcc(name);
        }
        break;

    case fileMenu:
        switch (theitem) {
        case extractItem:
            if (modifiers & screenFlag)
                command = 'c';
            else
                command = 'x';
            modifierMask = extractMask;
            break;
        case infoItem:
            command = 'Z';
            modifierMask = infoMask;
            break;
        case listItem:
            if (modifiers & verboseFlag)
                command = 'v';
            else
                command = 'l';
            modifierMask = listMask;
            break;
        case testItem:
            command = 't';
            modifierMask = testMask;
            break;
        case commentItem:
            command = 'z';
            modifierMask = commentMask;
            break;
        case freshenItem:
            command = 'f';
            modifierMask = freshenMask;
            break;
        case updateItem:
            command = 'u';
            modifierMask = updateMask;
            break;
        case quitItem:
            stop = true;
            break;
        default:
            break;
        }
        break;

    case editMenu:
        break;

    case modifierMenu:
        switch (theitem) {
        case selectItem:
            thedialog = GetNewDialog(selectDialog, nil, (WindowPtr)(-1));
            SetPort(thedialog);
            do
                ModalDialog(nil, &check);
            while ((check != okItem) && (check != cancelItem));
            if (check == okItem) {
                GetDItem(thedialog, editItem, &itemType, &itemHandle, &itemRect);
                GetIText(itemHandle, &fileList);
                p2cstr(fileList);
            }
            DisposDialog(thedialog);
            check = -1;
            break;
        case screenItem:
            check = (modifiers ^= screenFlag) & screenFlag;
            break;
        case pauseItem:
            check = (modifiers ^= pauseFlag) & pauseFlag;
            screenControl("p", check);
            break;
        case scrollItem:
            check = (modifiers ^= scrollFlag) & scrollFlag;
            screenControl("s", check);
            break;
        case convertItem:
            check = (modifiers ^= convertFlag) & convertFlag;
            break;
        case junkItem:
            check = (modifiers ^= junkFlag) & junkFlag;
            break;
        case lowercaseItem:
            check = (modifiers ^= lowercaseFlag) & lowercaseFlag;
            break;
        case neverItem:
            if (check = (modifiers ^= neverFlag) & neverFlag) {
                if (modifiers & promptFlag) {
                    CheckItem(modifierHandle, promptItem, false);
                    modifiers &= (allFlags ^ promptFlag);
                }
            } else {
                CheckItem(modifierHandle, promptItem, true);
                modifiers |= promptFlag;
            }
            break;
        case promptItem:
            if (check = (modifiers ^= promptFlag) & promptFlag)
                if (modifiers & neverFlag) {
                    CheckItem(modifierHandle, neverItem, false);
                    modifiers &= (allFlags ^ neverFlag);
                }
            break;
        case quietItem:
            check = (modifiers ^= quietFlag) & quietFlag;
            break;
        case verboseItem:
            check = (modifiers ^= verboseFlag) & verboseFlag;
            break;
        default:
            break;
        }
        if (check == 0)
            CheckItem(modifierHandle, theitem, false);
        else if (check > 0)
            CheckItem(modifierHandle, theitem, true);
        break;

    default:
        break;

    }

    HiliteMenu(0);
    return;
}

void dokey(myevent) EventRecord *myevent;
{
    char code;

    code = (char)(myevent->message & charCodeMask);

    if (myevent->modifiers & cmdKey) {
        if (myevent->what != autoKey) {
            domenu(MenuKey(code));
        }
    }

    return;
}

void domousedown(myevent) EventRecord *myevent;
{
    WindowPtr whichwindow;
    long code;

    code = FindWindow(myevent->where, &whichwindow);

    switch (code) {

    case inSysWindow:
        SystemClick(myevent, whichwindow);
        break;

    case inMenuBar:
        domenu(MenuSelect(myevent->where));
        break;

    }

    return;
}

int main(argc, argv) int argc; char *argv[];
{
    Boolean haveEvent, useWNE;
    short markChar;
    FILE *fp;

    FlushEvents(everyEvent, 0);
    InitGraf(&qd.thePort);
    InitFonts();
    InitWindows();
    InitMenus();
    TEInit();
    InitDialogs(nil);
    InitCursor();

    c2pstr(UnzipVersion);
    c2pstr(ZipinfoVersion);

    SysEnvirons(1, &sysRec);
    useWNE = TrapAvailable(sysRec.machineType, _WaitNextEvent, ToolTrap);

    SetMenuBar(menubar = GetNewMBar(unzipMenuBar));
    DisposeHandle(menubar);
    AddResMenu(appleHandle = GetMHandle(appleMenu), 'DRVR');
    modifierHandle = GetMHandle(modifierMenu);
    DrawMenuBar();

    screenOpen("Unzip");

    modifiers = 0;

    GetItemMark(modifierHandle, pauseItem, &markChar);
    if (markChar) modifiers ^= pauseFlag;
    screenControl("p", markChar);
    GetItemMark(modifierHandle, scrollItem, &markChar);
    if (markChar) modifiers ^= scrollFlag;
    screenControl("s", markChar);

    GetItemMark(modifierHandle, screenItem, &markChar);
    if (markChar) modifiers ^= screenFlag;
    GetItemMark(modifierHandle, convertItem, &markChar);
    if (markChar) modifiers ^= convertFlag;
    GetItemMark(modifierHandle, junkItem, &markChar);
    if (markChar) modifiers ^= junkFlag;
    GetItemMark(modifierHandle, lowercaseItem, &markChar);
    if (markChar) modifiers ^= lowercaseFlag;
    GetItemMark(modifierHandle, neverItem, &markChar);
    if (markChar) modifiers ^= neverFlag;
    GetItemMark(modifierHandle, promptItem, &markChar);
    if (markChar) modifiers ^= promptFlag;
    GetItemMark(modifierHandle, quietItem, &markChar);
    if (markChar) modifiers ^= quietFlag;
    GetItemMark(modifierHandle, verboseItem, &markChar);
    if (markChar) modifiers ^= verboseFlag;

    if ((modifiers & (neverFlag | promptFlag)) == (neverFlag | promptFlag)) {
        CheckItem(modifierHandle, promptItem, false);
        modifiers &= (allFlags ^ promptFlag);
    }

    command = ' ';

    stop = false;
    while (!stop) {
        SetCursor(&qd.arrow);

        if (useWNE) {
            haveEvent = WaitNextEvent(everyEvent, &myevent, MAXLONG, NULL);
        } else {
            SystemTask();
            haveEvent = GetNextEvent(everyEvent, &myevent);
        }

        if (haveEvent) {
            switch (myevent.what) {

            case activateEvt:
                break;

            case keyDown:
            case autoKey:
                dokey(&myevent);
                break;

            case mouseDown:
                domousedown(&myevent);
                break;

            case updateEvt:
                screenUpdate(myevent.message);
                break;

            case mouseUp:
            case keyUp:
                break;

            default:
                break;

            }
        }

        if (command != ' ') {
            char *s, **v, modifierString[16];
            SFReply fileRep;
            Point p;
            int m, n;

            SetPt(&p, 40, 40);

            SFGetFile(p, "\pSpecify ZIP file:", 0L, -1, nil, 0L, &fileRep);
            if (fileRep.good) {
                MacFSTest(fileRep.vRefNum);
                ResolveMacVol(fileRep.vRefNum, &gnVRefNum, &glDirID, NULL);

                p2cstr(fileRep.fName);

                modifierMask &= modifiers;

                s = modifierString;

                if ((command != 'Z') || modifierMask) {
                    *s++ = '-';
                    *s++ = command;

                    if (modifierMask & convertFlag) *s++ = 'a';
                    if (!HFSFlag || (modifierMask & junkFlag)) *s++ = 'j';
                    if (!modifierMask & lowercaseFlag) *s++ = 'U';
                    if (modifierMask & neverFlag) *s++ = 'n';
                    if (!modifierMask & promptFlag) *s++ = 'o';
                    if (modifierMask & quietFlag) *s++ = 'q';
                    if (modifierMask & verboseFlag) *s++ = 'v';
                }

                *s = '\0';

                v = (char **)malloc(sizeof(char *));
                *v = "unzip";
                argc = 1;

                envargs(&argc, &v, NULL, NULL);

                argv = (char **)malloc((argc + 3) * sizeof(char *));

                argv[m = 0] = (command == 'Z') ? "zipinfo" : "unzip";
                if (*modifierString) argv[++m] = modifierString;
                argv[++m] = (char *)fileRep.fName;
                for (n = 1; n < argc; n++) argv[n + m] = v[n];
                argv[argc += m] = NULL;

                free(v);

                for (n = 0; argv[n] != NULL; n++) printf("%s ", argv[n]);
                printf("...\n\n");

                unzip(argc, argv);

                printf("\nDone\n");
            }

            fileList[0] = '\0';
            command = ' ';
        }
    }

    screenClose();

    ExitToShell();
}
