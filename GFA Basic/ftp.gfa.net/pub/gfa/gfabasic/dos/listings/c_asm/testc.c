
/*
    Dieses C-File wird zum GFA-BASIC-Programm TESTC.GFW hinzugelinkt.
*/

long far pascal TestC(int x,int y,int w,int h,int wid)
{
    /* Dieses Beispiel errechnet x*w + y*h - wid */
    return (x*w + y*h - wid);
}

// Eine durch $XREF von GFA-BASIC aufgerufene C-Routine ist VOID FAR 
// PASCAL
//
// Compilierung von TESTC.C in TESTC.OBJ
// cl /Ox /AL /c testc.c
