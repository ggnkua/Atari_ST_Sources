 ; ****************************************************************************
 ; **  Program Name   :  SPEECH.ASM                                          **
 ; **  Written By     :  David Thomson,(C) 1986 All Rights Reserved          **
 ; **  Version        :  1.0                                                 **
 ; **  Date Started   :  19/07/87       Date Completed :    /  /             **
 ; ****************************************************************************
 ; **  Program Information                                                   **
 ; **    Program Name :  SPEECH.ASM                                          **
 ; **    Language     :  68000 Assembly Language                             **
 ; **      Compiler   :  Not Applicable                                      **
 ; **      Assembler  :  METACOMCO Macro Assembler                           **
 ; **      Interpreter:  Not Applicable                                      **
 ; **      Other      :  GST-LINK                                            **
 ; **    Function     :  Provide A Lattice C Command To "Speak" Using The    **
 ; **                    Fast Basic Speech Module It Assumes That The        **
 ; **                    Module Has Been Loaded, And Is Set Up As TRAP #8    **
 ; **    Input Data   :  Speech String And Control Information               **
 ; **    Output Data  :  Speech To Display Speaker                           **
 ; ****************************************************************************
 ; **  External Dependancies                                                 **
 ; **    Programs     :  ATARI ST Operating System, Fast Basic Speech Module **
 ; **    Data Files   :  None                                                **
 ; ****************************************************************************

 ; Set Up Metacomco Library Macros

 ; *****************************************************************
 ; ** LIBFNV  name,args    Set up entry Point for 'void' function **
 ; *****************************************************************

 libfnv:      macro
              ifne       NARG-2
              fail
              endc
              xdef       \1
 \1:          init       \2
              endm

 ; *****************************************************************
 ; * INIT     argcount        Set up initial call                  *
 ; *****************************************************************

 init:        macro
              link       a6,#1024                ; 1Kb Of Stack Space
              movem.l    d4-d7/a2-a5,-(a6)       ; Save Registers
              endm

              libfnv     speak,2
              move.l     40(a6),d0               ; Control Info (1)
              move.l     44(a6),a0               ; String Pointer
              trap       #8                      ; Call Speach Routine
              move.l     #0,d0                   ; To Zero, In Case
              movem.l    (a6)+,d4-d7/a2-a5       ; Save Registers
              unlk       a6                      ; Release Stack Space
              rts                                ; Return To Caller

              end
