void HandleTimer(PtrEP para);
void QuitAlert(PtrAlertpara ap);
void SetBFlags(OBJECT *t, BITSET b, int _gem, int magic, int gback, 
               int mback, BOOLEAN incl);
void SetBState(OBJECT *t, BITSET b, int _gem, int magic, int gback, 
               int mback, BOOLEAN incl);
void ButtonHandler(PtrDialpara dp);
void StringHandler(PtrDialpara dp);
void FrameHandler(PtrDialpara dp);
void BoxHandler(PtrDialpara dp);
void DialHandle(PtrDialpara dp);
void WinHandler(PtrWinPara w);
void OpenWin(char *wname, char *winfo, BOOLEAN mn);
void DemoAlert (PtrAlertpara ap);
void HandleMenu (PtrMenupara mp);
void FillDrop(void);
void AddList(OBJECT *t, int list, int sel);
void main(void);
