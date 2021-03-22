DEFINITION MODULE InOutBase;

FROM SYSTEM IMPORT WORD, LONGWORD;

VAR consIn, consOut: BOOLEAN;
    level, inLev, outLev: CARDINAL;
    termCh: CHAR;
    eop, done: BOOLEAN;

VAR     InitDriver: PROC; (* Wird aufgerufen, sobald InOut o. Text init. ist *)
                          (* Ggf. muû doppelter Aufruf berÅcksichtigt werden!*)

TYPE    OpenProc  = PROCEDURE ( CARDINAL, CARDINAL );
        ClsProc   = PROCEDURE;
        ReadProc  = PROCEDURE ( VAR CHAR );
        WriteProc = PROCEDURE ( CHAR );
        LWProc    = PROCEDURE;
        KeyPrProc = PROCEDURE (): BOOLEAN;
        GoXYProc  = PROCEDURE ( CARDINAL, CARDINAL );
        CReadProc = PROCEDURE ( VAR CHAR, VAR BOOLEAN );
        RStrProc  = PROCEDURE ( VAR ARRAY OF CHAR );
        WStrProc  = PROCEDURE ( REF ARRAY OF CHAR );
        GetInProc = PROCEDURE ( VAR ARRAY OF CHAR );
        GetOutProc= PROCEDURE ( VAR ARRAY OF CHAR, VAR BOOLEAN );
        OpErrProc = PROCEDURE ( VAR ARRAY OF CHAR, VAR BOOLEAN );
        IOErrProc = PROCEDURE ( VAR ARRAY OF CHAR, BOOLEAN );

VAR     (* Unit - Treiberfunktionen fÅr Modul 'InOut' *)
        OpenWdw: OpenProc;
        CloseWdw: ClsProc;
        KeyPressed: KeyPrProc;
        CondRead: CReadProc;
        Read: ReadProc;
        ReadString: RStrProc;
        Write: WriteProc;
        WriteString: WStrProc;
        WriteLn: LWProc;
        WritePg: LWProc;
        FlushKbd: LWProc;
        GotoXY: GoXYProc;
        GetInput: GetInProc;
        GetOutput: GetOutProc;
        OpenError: OpErrProc;
        IOError: IOErrProc;

TYPE    pRead       = PROCEDURE (VAR CHAR);
        pKeyPressed = PROCEDURE (): BOOLEAN;
        pCondRead   = PROCEDURE (VAR CHAR, VAR BOOLEAN);
        pReadString = PROCEDURE (VAR ARRAY OF CHAR);
        pRdWLR      = PROCEDURE ;
        pReadCard   = PROCEDURE (VAR CARDINAL);
        pReadInt    = PROCEDURE (VAR INTEGER);
        pReadLCard  = PROCEDURE (VAR LONGCARD);
        pReadLInt   = PROCEDURE (VAR LONGINT);
        pReadNum    = PROCEDURE (VAR WORD, CARDINAL);
        pReadLNum   = PROCEDURE (VAR LONGWORD, CARDINAL);
        pReadReal   = PROCEDURE (VAR LONGREAL);
        pWrite      = PROCEDURE (CHAR);
        pWriteLn    = PROCEDURE ;
        pWritePg    = PROCEDURE ;
        pGotoXY     = PROCEDURE (CARDINAL, CARDINAL);
        pWriteString= PROCEDURE (REF ARRAY OF CHAR);
        pCloseInput = PROCEDURE ;
        pCloseOutput= PROCEDURE ;

VAR     fRead: pRead;
        fKeyPressed: pKeyPressed;
        fCondRead: pCondRead;
        fReadString: pReadString;
        fRdWLR: pRdWLR;
        fReadCard: pReadCard;
        fReadInt: pReadInt;
        fReadLCard: pReadLCard;
        fReadLInt: pReadLInt;
        fReadNum: pReadNum;
        fReadLNum: pReadLNum;
        fReadReal: pReadReal;
        fWrite: pWrite;
        fWriteLn: pWriteLn;
        fWritePg: pWritePg;
        fGotoXY: pGotoXY;
        fWriteString: pWriteString;
        fCloseInput: pCloseInput;
        fCloseOutput: pCloseOutput;

END InOutBase.
