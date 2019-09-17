 /****************************************************************************
  **  Program Name    :  SPEAKTST.C                                         **
  **  Written By      :  David Thomson,(C) 1986 All Rights Reserved         **
  **  Version         :  1.0                                                **
  **  Date Started    :  18/07/87       Date Completed :    /  /            **
  ****************************************************************************
  **  Program Information                                                   **
  **    Program Name  :  SPEAKTST.C                                         **
  **    Language      :  Lattice C                                          **
  **      Compiler    :  Metacomco Lattice C Compiler                       **
  **      Assembler   :  Not Applicable                                     **
  **      Interpreter :  Not Applicable                                     **
  **      Other       :  GST-LINK                                           **
  **    Function      :  Test The Speach Interface Library                  **
  **    Input Data    :  None                                               **
  **    Output Data   :  None                                               **
  ****************************************************************************
  **  External Dependancies                                                 **
  **    Programs      :  ATARI ST Operating System, FastBasic Speach Module **
  **    Data Files    :  None                                               **
  ****************************************************************************/

 #include <stdlib.h>
 #include <osbind.h>

 /** Free Some Memory For SPEAKER.PRG To Be Loaded ***************************/

 int _mneed=4096;                                /** 4K Is More Than Enough **/
 int _stack=3072;                                /** Most Of It's The Stack **/

 /** Main Control Function ***************************************************/

 void main()
  {
     int rc;

     if(Setexc(0x28,-1L)!=0x28FC0A1A) rc=0;      /** If It's Not Installed  **/
     else  rc=Pexec(0,"SPEAKER.PRG","","");      /** Install Speech Handler **/

     if(rc!=0)
      {
        form_alert(1,"[3][Unable To Load SPEAKER.PRG][  OK  ]");
        exit(rc);
      }

     speak(1,"Hello World");                     /** If OK, Talk            **/
     speak(1,"Press A Key To Exit");

     puts(" Press A Key To Exit.");
     while(kbhit()) getch();                     /** Wait For A Key         **/
     getch();
  }

 /** The End ! ***************************************************************/
