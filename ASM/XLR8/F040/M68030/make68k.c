/*---------------------------------------------------------------
 * Motorola 68030 32 Bit emulator
 *
 * Copyright 1999-2000  XLR8 Software,  All rights reserved
 * Frans van Nispen (xlr8@tref.nl)
 *
 * This file creates a program that creates an assembly (TASM)
 * File that emulates the Motorola MC6030 cpu.
 *
 *---------------------------------------------------------------
 *
 * Thanks to ...
 *
 * Neil Bradley    Neil Bradley   (lots of optimisation help & ideas)
 * Mike Coates &   Make68000      (used as frame of the M68030)
 * Darren Olafson
 *---------------------------------------------------------------
 * History (so we know what bugs have been fixed)
 *
 * 31-03-1999 FvN - Started to upgrade the M68000 code to
 *                  M68030 code. Added code for new indexed modes
 *                  and registerscaling: ' $10([A0,D1*4.L],100),D0 '
 *                  Not Optimized!
 * 07-04-1999 FvN - Movec, MMU skipped, EXTB, BSR.S corrected
 * 08-04-1999 FvN - New IRQ handling for Atari, Memory access build in.
 * 09-04-1999 FvN - MULU.L,MULS.L,DIVU.L,DIVS.L, new modes in TST
 * 02-07-2000 FvN - Memory access divided in B/W/L,
 *                  ExceptionHandling rewritten to support long
 *                  StackFrames as needed for interupt-handling.
 * 07-07-2000 FvN - Memory Read/Write rewritten for use with
 *                  Hardware Emulation. MOVEC implemented.
 *
 *---------------------------------------------------------------
 * Things to do:  BFCHG, BFCLR, BFEXTS, BFEXTU, BFFFO, BFINS,
 *                BFSET, BFTST, BKPT, CAS, CAS2, CHK2, CMP2,
 *                cpbcc, cpDBcc, cpGEN, cpRESTORE, cpSAVE, cpScc,
 *                cpTRAPcc, Move from CCR,
 *                MOVES, PACK, PFLUSH, PFLUSHA, PLOAD,
 *                PMOVE, PTEST, RTD, TRAPcc, UNPK
 *
 * Change some Privileges, rewrite Interupt & Exeption Core's
 *
 *---------------------------------------------------------------
 * Known Problems / Bugs
 *
 * Some Rotate instructions, flags not totally correct.
 * Low 64Kb does not generate a BusError in UserMode (for Speed)
 *
 *---------------------------------------------------------------
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

/* New Disassembler */

char 		*codebuf;
int 		DisOp;

#define MEMORY_H        /* so memory.h will not be included... */

#define VERSION         "0.4"

#define TRUE -1
#define FALSE 0

#define EAX 0
#define EBX 1
#define ECX 2
#define EDX 3
#define ESI 4
#define PC  ESI
#define EDI 5
#define EBP 6


/* Register Location Offsets */

#define ICOUNT                  "M68030_ICount"
#define REG_DAT                 "R_D0"
#define REG_DAT_EBX             "[R_D0+ebx*4]"
#define REG_ADD                 "R_A0"
#define REG_A7                  "R_A7"
#define REG_USP                 "R_USP"
#define REG_ISP                 "R_ISP"
#define REG_SRH                 "R_SR_H"
#define REG_CCR                 "R_CCR"
#define REG_X                   "R_XC"
#define REG_PC                  "R_PC"
#define REG_IRQ                 "R_IRQ"
#define REG_SR                  "R_SR"

/* Global Variables */

FILE *fp = NULL;

int  FlagProcess    = 0;
int  CheckInterrupt = 0;
int  Opcount        = 0;
int  TimingCycles   = 0;
int  AddEACycles    = 0;

/* Registers normally saved around C routines anyway */
/* GCC (dos) seems to preserve EBX,EDI,ESI and EBP   */

static char SavedRegs[] = "-B--SDB";


/* Jump Table */

int OpcodeArray[65536];

/* Lookup Arrays */

static char* regnameslong[] =
{ "EAX","EBX","ECX","EDX","ESI","EDI","EBP" };

static char* regnamesword[] =
{ "AX","BX","CX","DX" };

static char* regnamesshort[] =
{ "AL","BL","CL","DL" };

/*********************************/
/* Conversion / Utility Routines */
/*********************************/

/* Convert EA to Address Mode Number
 *
 * 0   Dn
 * 1   An
 * 2   (An)
 * 3   (An)+
 * 4   -(An)
 * 5   x(An)
 * 6   x(An,xr.s)
 * 7   x.w
 * 8   x.l
 * 9   x(PC)
 * 10  x(PC,xr.s)
 * 11  #x,SR,CCR		Read = Immediate, Write = SR or CCR
 *                      in order to read SR to AX, use READCCR
 * 12-15  INVALID
 *
 * 19  (A7)+
 * 20  -(A7)
 *
 */

int EAtoAMN(int EA, int Way)
{
    int Work;

    if (Way)
    {
       Work = (EA & 0x7);
       if (Work == 7) Work += ((EA & 0x38) >> 3);

       if (((Work == 3) || (Work == 4)) && (((EA & 0x38) >> 3) == 7))
       {
          Work += 16;
       }
    }else
    {
       Work = (EA & 0x38) >> 3;

       if (Work == 7) Work += (EA & 7);

       if (((Work == 3) || (Work == 4)) && ((EA & 7) == 7))
       {
          Work += 16;
       }
    }

    return Work;
}

/*
 * Generate Main or Sub label
 */

char *GenerateLabel(int ID,int Type)
{
	static int LabID,LabNum;

	static char disasm[80];
	char   *dis = disasm;

    if (Type == 0)
    {
		CheckInterrupt=0;			/* No need to check for Interrupts */
		TimingCycles=0;				/* No timing info for this command */
        AddEACycles=1;              /* default to add in EA timing */
		Opcount++;					/* for screen display */

		DisOp = ID;

                sprintf(codebuf, "OP_%4.4x", ID);

        LabID  = ID;
        LabNum = 0;
    }
    else
    {
    	LabNum++;
        sprintf(codebuf, "OP_%4.4x_%1x", LabID, LabNum);
    }

    return codebuf;
}

/*
 * Generate Alignment Line
 */

void Align(void)
{
        fprintf(fp, "\tALIGN 4\n");
}

/*
 * Copy X into Carry
 *
 * There are several ways this could be done, this allows
 * us to easily change the way we are doing it!
 */

void CopyX(void)
{
	/* Copy bit 0 from X flag store into Carry */

    fprintf(fp, "\tbt    d [%s],0\n",REG_X);
}


/*
 * Immediate 3 bit data
 *
 * 0=8, anything else is itself
 *
 * Again, several ways to achieve this
 *
 * ECX contains data as 3 lowest bits
 *
 */

void Immediate8(void)
{
	/* This takes 3 cycles, 5 bytes, no memory reads */

    fprintf(fp, "\tdec   ecx          ; Move range down\n");
    fprintf(fp, "\tand   ecx,7        ; Mask out lower bits\n");
    fprintf(fp, "\tinc   ecx          ; correct range\n");

}

/*
 * Complete Opcode handling
 *
 * Any tidying up, end code
 *
 */

void Completed(void)
{

	/* Flag Processing to be finished off ? */

	if (FlagProcess > 0)
    {      fprintf(fp, "\tpop   EDX\n"); // Flags

        if (FlagProcess == 2)
           fprintf(fp, "\tmov   d [%s],edx\n",REG_X);  // Carry to X

        FlagProcess = 0;
    }

     fprintf(fp, "\txor   ecx,ecx\t\t; Avoid Stall (P2)\n");

	/* Use assembler timing routines */
/*
	if (TimingCycles != 0)
	{
           if (TimingCycles > 127)
              fprintf(fp, "\tsub   d [%s],%d\n",ICOUNT,TimingCycles);
           else
        {
           if (TimingCycles != -1)
              fprintf(fp, "\tsub   d [%s],%d\n",ICOUNT,TimingCycles);
        }
	}

	else
	{
              fprintf(fp, "\tor    d [%s],0\n",ICOUNT);
	}
*/

        fprintf(fp, "\tdec   d [%s]\n",ICOUNT);
        fprintf(fp, "\tjs    MainExit\n");

     fprintf(fp, "\tmov   cx,[esi+ebp]\n");
     fprintf(fp, "\tadd   esi,2\n");
     fprintf(fp, "\tcmp   esi,d BRK\n");
     fprintf(fp, "\tje    DebugExit\n");
     fprintf(fp, "\tjmp   [OPCODETABLE+ecx*4]\n\n");
}

/*
 * Flag Routines
 *
 * Size     = B,W or L
 * Sreg     = Register to Test
 * TestReg  = Need to test register (false if flags already set up)
 * SetX     = if C needs to be copied across to X register
 * Delayed  = Delays final processing to end of routine (Completed())
 *
 */

void SetFlags(char Size,int Sreg,int Testreg,int SetX,int Delayed)
{
	char* Regname="";

    switch(Size)
	{
        case 66:
        	Regname = regnamesshort[Sreg];
            break;

        case 87:
        	Regname = regnamesword[Sreg];
            break;

        case 76:
        	Regname = regnameslong[Sreg];
            break;
    }

    /* Test does not update register    */
	/* so cannot generate partial stall */

    if (Testreg) fprintf(fp, "\ttest  %s,%s\n",Regname,Regname);
        fprintf(fp, "\tpushfd\n");

    if (Delayed)
    {
   		/* Rest of code done by Completed routine */

		if (SetX) FlagProcess = 2;
    	else FlagProcess = 1;
    }
    else
   	{
                fprintf(fp, "\tpop   EDX\n");

            if (SetX) fprintf(fp, "\tmov   d [%s],edx\n",REG_X);
   	}
}

/************************************/
/* Pre-increment and Post-Decrement */
/************************************/

void IncrementEDI(int Size,int Rreg)
{
    switch(Size)
	{
        case 66:

        	/* Always does Byte Increment - A7 uses special routine */

            fprintf(fp, "\tinc   d [%s+%s*4]\n",REG_ADD,regnameslong[Rreg]);
            break;

        case 87:

            fprintf(fp, "\tadd   d [%s+%s*4],2\n",REG_ADD,regnameslong[Rreg]);
            break;

        case 76:

            fprintf(fp, "\tadd   d [%s+%s*4],4\n",REG_ADD,regnameslong[Rreg]);
            break;
    }
}

void DecrementEDI(int Size,int Rreg)
{
    switch(Size)
	{
        case 66:

        	/* Always does Byte Decrement - A7 uses special routine */

            fprintf(fp, "\tdec   EDI\n");
            break;

        case 87:

            fprintf(fp, "\tsub   EDI,2\n");
            break;

        case 76:
            fprintf(fp, "\tsub   EDI,4\n");
            break;
    }
}

/*
 * Generate an exception
 *
 * if Number = -1 then assume value in AL already
 *                code must continue running afterwards
 *
 */

void Exception(int Number, int BaseCode)
{
    if (Number > -1)
    {
            fprintf(fp, "\tsub   esi,2\n");
        fprintf(fp, "\tmov   al,%d\n",Number);
    }

    fprintf(fp, "\tcall  Exception\n\n");

    if (Number > -1)
       Completed();
}


/********************/
/* Address Routines */
/********************/

/*
 * Decode Intel flags into AX as SR register
 *
 * Wreg = spare register to use (must not be EAX or EDX)
 */

void ReadCCR(char Size, int Wreg)
{
    fprintf(fp, "\tmov   eax,edx\n");
    fprintf(fp, "\tmov   ah,b [%s]\n",REG_X);

    /* Partial stall so .. switch to new bit of processing */

    fprintf(fp, "\tmov   %s,edx\n",regnameslong[Wreg]);
    fprintf(fp, "\tand   %s,1\n",regnameslong[Wreg]);

    /* Finish what we started */

    fprintf(fp, "\tshr   eax,4\n");
    fprintf(fp, "\tand   eax,01Ch \t\t; X, N & Z\n\n");

    /* and complete second task */

    fprintf(fp, "\tor    eax,%s \t\t\t\t; C\n\n",regnameslong[Wreg]);

    /* and Finally */

    fprintf(fp, "\tmov   %s,edx\n",regnameslong[Wreg]);
    fprintf(fp, "\tshr   %s,10\n",regnameslong[Wreg]);
    fprintf(fp, "\tand   %s,2\n",regnameslong[Wreg]);
    fprintf(fp, "\tor    eax,%s\t\t\t\t; O\n\n",regnameslong[Wreg]);

    if (Size == 'W')
            fprintf(fp, "\tmov   ah,b [%s] \t; T, S & I\n\n",REG_SRH);
}

/*
 * Convert SR into Intel flags
 *
 * Also handles change of mode from Supervisor to User
 *
 * n.b. This is also called by EffectiveAddressWrite
 */

void WriteCCR(char Size)
{
	if (Size == 'W')
    {
    	/* Did we change from Supervisor to User mode ? */

		char *Label = GenerateLabel(0,1);

        fprintf(fp, "\ttest  ah,20h \t\t\t; User Mode ?\n");
        fprintf(fp, "\tjne   short %s\n\n",Label);

        /* Mode Switch - Update A7 */

                fprintf(fp, "\tmov   edx,d [%s]\n",REG_A7);
        fprintf(fp, "\tmov   d [%s],edx\n",REG_ISP);
        fprintf(fp, "\tmov   edx,d [%s]\n",REG_USP);
        fprintf(fp, "\tmov   d [%s],edx\n",REG_A7);

        fprintf(fp, "%s:\t",Label);
                fprintf(fp, "\tmov   b [%s],ah \t;T, S & I\n",REG_SRH);

        /* Mask may now allow Interrupt */

  		CheckInterrupt += 1;
    }

    /* Flags */

    fprintf(fp, "\tand   eax,1Fh\n");
    fprintf(fp, "\tmov   edx,d [IntelFlag+eax*4]\n");
    fprintf(fp, "\tmov   b [%s],dh\n",REG_X);
    fprintf(fp, "\tand   edx,0EFFh\n");
}


/*
 * Flags = "ABCDSDB" - set to '-' if not required to preserve
 *         (order EAX,EBX,ECX,EDX,ESI,EDI,EBP)
 *
 * AReg   = Register containing Address
 *
 * Mask   0 : No Masking
 *        1 : Mask top byte, but preserve register
 *        2 : Mask top byte, preserve masked register
 */

void Memory_Read(char Size,int AReg,char *Flags,int Mask)
{
    switch(Size)
    {
    	case 66 :
            fprintf(fp, "\tReadTestB\n");
            break;

        case 87 :
             fprintf(fp, "\tReadTestW\n");
            break;

        case 76 :
            fprintf(fp, "\tReadTestL\n");
            break;
    }



}

/*
 * Flags = "ABCDSDB" - set to '-' if not required to preserve
 *         (order EAX,EBX,ECX,EDX,ESI,EDI,EBP)
 *
 * AReg   = Register containing Address 
 * DReg   = Register containing Data
 *
 * Mask   = As for Read Command
 */

void Memory_Write(char Size,int AReg,int DReg,char *Flags,int Mask)
{
// DReg wordt niet meer gebruikt, alleen nog EAX!
// AReg wordt niet meer gebruikt, alleen nog EDI!

    switch(Size)
    {
         case 66 :
            fprintf(fp, "\tWriteTestB\n");
            break;

        case 87 :
            fprintf(fp, "\tWriteTestW\n");
            break;

        case 76 :
            fprintf(fp, "\tWriteTestL\n");
            break;
    }
}


/*
 * Fetch data from Code area
 *
 * Dreg   = Destination Register
 * Extend = Sign Extend word to Long
 *
 */

void Memory_Fetch(char Size,int Dreg,int Extend)
{

    if ((Extend == TRUE) & (Size == 'W'))
            fprintf(fp, "\tmovsx %s,w [esi+ebp]\n",regnameslong[Dreg]);
    else
            fprintf(fp, "\tmov   %s,d [esi+ebp]\n",regnameslong[Dreg]);

    if (Size == 'L')
        fprintf(fp, "\trol   %s,16\n",regnameslong[Dreg]);
}


void ExtensionDecode(int SaveEDX)
{
	char *Label = GenerateLabel(0,1);

    if (SaveEDX) fprintf(fp, "\tpush  edx\n");

    Memory_Fetch('W',EAX,FALSE);
    fprintf(fp, "\tadd   esi,2\n");
    fprintf(fp, "\tpush  ecx\n");
    fprintf(fp, "\tshr   ah,1                ; Check for extended\n");
    fprintf(fp, "\tjs    short %s2\n",Label);

    fprintf(fp, "\tmov   edx,eax\n");
    fprintf(fp, "\tshr   eax,9\n");
    fprintf(fp, "\tand   eax,3Ch\n");
    fprintf(fp, "\tmov   eax,d [%s+eax]\n",REG_DAT);
    fprintf(fp, "\ttest  dh,4H\n");
    fprintf(fp, "\tjnz   short %s\n",Label);
    fprintf(fp, "\tcwde\n");
    fprintf(fp, "%s:\t",Label);

    fprintf(fp, "\tmov   cl,dh             ; Get SCALE\n");
    fprintf(fp, "\tmovsx edx,dl\n");
    fprintf(fp, "\tand   cl,3\n");
    fprintf(fp, "\tadd   edi,edx\n");
    fprintf(fp, "\tshl   eax,cl            ; Scale Xn*...\n");
    fprintf(fp, "\tadd   edi,eax\n");
    fprintf(fp, "\tjmp   short %s3\n",Label);
    fprintf(fp, "%s2:\n",Label);

    fprintf(fp, ";******************************************** MC 68030 *\n");

    fprintf(fp, "\tmovsx edx,w [esi+ebp]   ; Get Displacement\n");
    fprintf(fp, "\tmov   ecx,esi           ; Save ESI\n");
    fprintf(fp, "\tadd   esi,2\n");
    fprintf(fp, "\ttest  al,10h            ; Long?\n");
    fprintf(fp, "\tjns   short %s4\n",Label);
    fprintf(fp, "\tmov   edx,d [esi+ebp-2]\n");
    fprintf(fp, "\trol   edx,16\n");
    fprintf(fp, "\tadd   esi,2\n");
    fprintf(fp, "%s4:                         ; EDX=bd or 0\n",Label);
    fprintf(fp, "\ttest  al,20h            ; BaseDisplacement?\n");
    fprintf(fp, "\tjns   short %s5\n",Label);
    fprintf(fp, "\txor   edx,edx           ; Clear Displacement\n");
    fprintf(fp, "\tmov   esi,ecx           ; Restore PC,4\n");
    fprintf(fp, "%s5:                         ; EDX=bd+An",Label);
    fprintf(fp, "\ttest  al,80h            ; An?\n");
    fprintf(fp, "\tjs    short %s6\n",Label);
    fprintf(fp, "\txor   edi,edi           ; clear EA\n");
    fprintf(fp, "%s6:                         ; EDX=bd+An",Label);
    fprintf(fp, "\tadd   edi,edx\n");
    fprintf(fp, "\txor   edx,edx           ; clear Xn\n");
    fprintf(fp, "\ttest  al,40h            ; Xn als index\n");
    fprintf(fp, "\tjs    short %s7\n",Label);

    fprintf(fp, "\tpush  eax\n");
    fprintf(fp, "\tmov   ecx,eax\n");
    fprintf(fp, "\tshr   eax,9\n");
    fprintf(fp, "\tand   eax,3Ch\n");
    fprintf(fp, "\tmov   eax,d [%s+eax]\n",REG_DAT);
    fprintf(fp, "\ttest  ch,4H\n");
    fprintf(fp, "\tjnz   short %s8\n",Label);
    fprintf(fp, "\tcwde\n");
    fprintf(fp, "%s8:\n",Label);
    fprintf(fp, "\tmov   cl,ch             ; Get SCALE\n");
    fprintf(fp, "\tmov   edx,eax\n");
    fprintf(fp, "\tand   cl,3\n");
    fprintf(fp, "\tpop   eax\n");
    fprintf(fp, "\tshl   edx,cl            ; Scale Xn*...\n");
    fprintf(fp, "%s7:                         ; EDX=Xn*SCALE",Label);
    fprintf(fp, "\ttest  al,4              ; Post or Pre-index\n");
    fprintf(fp, "\tjs    short %s9         ; Post!\n",Label);
    fprintf(fp, "\tadd   edi,edx           ; EDI=bs+An+Xn\n");
    fprintf(fp, "\txor   edx,edx           ; Clear Xn for Postindex\n");
    fprintf(fp, "%s9:",Label);
    Memory_Fetch('L',EDI,FALSE);
    fprintf(fp, "\tadd   edi,edx           ; EA+Xn*SCALE\n");
    fprintf(fp, "\ttest  al,2              ; OD?\n");
    fprintf(fp, "\tjns   short %s3\n",Label);
    fprintf(fp, "\tmovsx edx,w [esi+ebp]\n");
    fprintf(fp, "\tadd   esi,2\n");
    fprintf(fp, "\ttest  al,1              ; long?\n");
    fprintf(fp, "\tjns   short %sa\n",Label);
    fprintf(fp, "\tmov   edx,d [esi+ebp-2]\n");
    fprintf(fp, "\trol   edx,16\n");
    fprintf(fp, "\tadd   esi,2\n");
    fprintf(fp, "%sa:\n",Label);
    fprintf(fp, "\tadd   edi,edx\n");

    fprintf(fp, "%s3:\n",Label);
    fprintf(fp, "\tpop   ecx\n");
    if (SaveEDX) fprintf(fp, "\tpop   edx\n");
}

/* Calculate Effective Address - Return address in EDI
 *
 * mode = Effective Address from Instruction
 * Size = Byte,Word or Long
 * Rreg = Register with Register Number in
 *
 * Only for modes 2 - 10 (5-10 clobber EAX)
 */

void EffectiveAddressCalculate(int mode,char Size,int Rreg,int SaveEDX)
{
    switch(mode)
	{

      case 2:
        fprintf(fp, "\tmov   EDI,d [%s+%s*4]\n",REG_ADD,regnameslong[Rreg]);
        break;

      case 3:
        fprintf(fp, "\tmov   EDI,d [%s+%s*4]\n",REG_ADD,regnameslong[Rreg]);
        IncrementEDI(Size,Rreg);
        break;

      case 4:
        fprintf(fp, "\tmov   EDI,d [%s+%s*4]\n",REG_ADD,regnameslong[Rreg]);
        DecrementEDI(Size,Rreg);
        fprintf(fp, "\tmov   d [%s+%s*4],EDI\n",REG_ADD,regnameslong[Rreg]);
        break;

      case 5:
        Memory_Fetch('W',EAX,TRUE);
        fprintf(fp, "\tmov   EDI,d [%s+%s*4]\n",REG_ADD,regnameslong[Rreg]);
        fprintf(fp, "\tadd   esi,2\n");
        fprintf(fp, "\tadd   edi,eax\n");
        break;

      case 6:

      	/* Get Address register Value */
        fprintf(fp, "\tmov   EDI,d [%s+%s*4]\n",REG_ADD,regnameslong[Rreg]);

        /* Add Extension Details */
      	ExtensionDecode(SaveEDX);
        break;

      case 7:

      	/* Get Word */

        Memory_Fetch('W',EDI,TRUE);
        fprintf(fp, "\tadd   esi,2\n");
        break;

      case 8:

      	/* Get Long */

        Memory_Fetch('L',EDI,FALSE);
        fprintf(fp, "\tadd   esi,4\n");
        break;

      case 9:

        Memory_Fetch('W',EAX,TRUE);
        fprintf(fp, "\tmov   EDI,ESI           ; Get PC\n");
        fprintf(fp, "\tadd   esi,2\n");
        fprintf(fp, "\tadd   edi,eax         ; Add Offset to PC\n");
        break;

      case 10:

       	/* Get PC */

        fprintf(fp, "\tmov   edi,esi           ; Get PC\n");

        /* Add Extension Details */
      	ExtensionDecode(SaveEDX);

        break;

      case 19:

      	/* (A7)+ */

        fprintf(fp, "\tmov   edi,d [%s]    ; Get A7\n",REG_A7);
        fprintf(fp, "\tadd   d [%s],2\n",REG_A7);
        break;

      case 20:

      	/* -(A7) */

        fprintf(fp, "\tmov   edi,d [%s]    ; Get A7\n",REG_A7);
        fprintf(fp, "\tsub   edi,2\n");
        fprintf(fp, "\tmov   d [%s],edi\n",REG_A7);
        break;

    }
}

/* Read from Effective Address
 *
 * mode = Effective Address from Instruction
 * Size = Byte,Word or Long
 * Rreg = Register with Register Number in
 * Flag = Registers to preserve (EDX is handled by SaveEDX)
 *
 * Return
 * Dreg = Register to return result in (EAX is usually most efficient)
 * (modes 5 to 10) EDI  = Address of data read (masked with FFFFFF)
 */

void EffectiveAddressRead(int mode,char Size,int Rreg,int Dreg,const char *flags,int SaveEDX)
{
    char* Regname="";
    int   MaskMode;
	char Flags[8];


	strcpy(Flags,flags);

    /* Which Masking to Use */

    if (Flags[5] != '-')
    	MaskMode = 2;
    else
    	MaskMode = 1;

    if (SaveEDX)
    	Flags[3] = 'D';
    else
    	Flags[3] = '-';

    switch(Size)
	{
        case 66:
        	Regname = regnamesshort[Dreg];
            break;

        case 87:
        	Regname = regnamesword[Dreg];
            break;

        case 76:
        	Regname = regnameslong[Dreg];
            break;
    }

    switch(mode & 15)
	{

      case 0:           // Dn

        fprintf(fp, "\tmov   %s,d [%s+%s*4]\n",regnameslong[Dreg],REG_DAT,regnameslong[Rreg]);
        break;

      case 1:           // An

        fprintf(fp, "\tmov   %s,d [%s+%s*4]\n",regnameslong[Dreg],REG_ADD,regnameslong[Rreg]);
        break;

      case 2:           // (An)

        EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);
        Memory_Read(Size,EDI,Flags,MaskMode);

        if (Dreg != EAX)
        {
                fprintf(fp, "\tmov   %s,EAX\n",regnameslong[Dreg]);
        }
        break;

      case 3:           // (An)+

        EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);

       	Memory_Read(Size,EDI,Flags,MaskMode);

        if (Dreg != EAX)
        {
                fprintf(fp, "\tmov   %s,EAX\n",regnameslong[Dreg]);
        }
        break;

      case 4:           // -(An)

        EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);

       	Memory_Read(Size,EDI,Flags,MaskMode);

        if (Dreg != EAX)
        {
                fprintf(fp, "\tmov   %s,EAX\n",regnameslong[Dreg]);
        }
        break;


      case 5:           // (d16,An)

        EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);

       	Memory_Read(Size,EDI,Flags,MaskMode);

        if (Dreg != EAX)
        {
                fprintf(fp, "\tmov   %s,EAX\n",regnameslong[Dreg]);
        }
        break;

      case 6:           // (d8,An,Xn)

        EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);

       	Memory_Read(Size,EDI,Flags,MaskMode);

        if (Dreg != EAX)
        {
                fprintf(fp, "\tmov   %s,EAX\n",regnameslong[Dreg]);
        }
        break;

      case 7:
		EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);

       	Memory_Read(Size,EDI,Flags,MaskMode);

        if (Dreg != EAX)
        {
                fprintf(fp, "\tmov   %s,EAX\n",regnameslong[Dreg]);
        }
        break;

      case 8:
		EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);

       	Memory_Read(Size,EDI,Flags,MaskMode);

        if (Dreg != EAX)
        {
                fprintf(fp, "\tmov   %s,EAX\n",regnameslong[Dreg]);
        }
        break;

      case 9:
		EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);

       	Memory_Read(Size,EDI,Flags,MaskMode);

        if (Dreg != EAX)
        {
                fprintf(fp, "\tmov   %s,EAX\n",regnameslong[Dreg]);
        }
        break;

      case 10:
		EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);

       	Memory_Read(Size,EDI,Flags,MaskMode);

        if (Dreg != EAX)
        {
                fprintf(fp, "\tmov   %s,EAX\n",regnameslong[Dreg]);
        }
        break;

      case 11:

      	/* Immediate - for SR or CCR see ReadCCR() */

      	if(Size == 'L')
        {
			Memory_Fetch('L',Dreg,FALSE);
            fprintf(fp, "\tadd   esi,4\n");
        }
        else
        {
			Memory_Fetch('W',Dreg,FALSE);
            fprintf(fp, "\tadd   esi,2\n");
        };
        break;
    }
}

/*
 * EA   = Effective Address from Instruction
 * Size = Byte,Word or Long
 * Rreg = Register with Register Number in
 *
 * Writes from EAX
 */

void EffectiveAddressWrite(int mode,char Size,int Rreg,int CalcAddress,const char *flags,int SaveEDX)
{
    int   MaskMode;
    char* Regname="";
    char* Regwide="";
	char Flags[8];


	strcpy(Flags,flags);

    /* Which Masking to Use ? */

    if (CalcAddress)
    {
        if (Flags[5] != '-')
    	    MaskMode = 2;
        else
    	    MaskMode = 1;
    }
    else
    	MaskMode = 0;

    if (SaveEDX)
    	Flags[3] = 'D';
    else
    	Flags[3] = '-';

    switch(Size)
	{
        case 66:
                Regname = regnamesshort[0];
                Regwide = "b";
            break;

        case 87:
        	Regname = regnamesword[0];
                Regwide = "w";
            break;

        case 76:
        	Regname = regnameslong[0];
                Regwide = "d";
            break;
    }

    switch(mode & 15)
	{

      case 0:
           fprintf(fp, "\tmov   %s [%s+%s*4],%s\n",Regwide,REG_DAT,regnameslong[Rreg],Regname);
        break;

      case 1:
      	if (Size == 66)
        {
          /* Not Allowed */

		  fprintf(fp, "DUFF CODE!\n");
        }
        else
        {
          if (Size == 87)
          {
                  fprintf(fp, "\tcwde\n");
      	  }

          fprintf(fp, "\t\tmov   d [%s+%s*4],%s\n",REG_ADD,regnameslong[Rreg],regnameslong[0]);
        }
    	break;

      case 2:
      	if (CalcAddress) EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);
		Memory_Write(Size,EDI,EAX,Flags,MaskMode);
		break;

      case 3:
      	if (CalcAddress) EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);
		Memory_Write(Size,EDI,EAX,Flags,MaskMode);
        break;

      case 4:
      	if (CalcAddress) EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);
		Memory_Write(Size,EDI,EAX,Flags,MaskMode);
        break;

      case 5:
      	if (CalcAddress)
        {
                fprintf(fp, "\tpush  EAX\n");
			EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);
                fprintf(fp, "\tpop   EAX\n");
        }
  		Memory_Write(Size,EDI,EAX,Flags,MaskMode);
        break;

      case 6:
      	if (CalcAddress)
        {
                fprintf(fp, "\tpush  EAX\n");
			EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);
                fprintf(fp, "\tpop   EAX\n");
        }
		Memory_Write(Size,EDI,EAX,Flags,MaskMode);
        break;

      case 7:
      	if (CalcAddress)
        {
                fprintf(fp, "\tpush  EAX\n");
			EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);
                fprintf(fp, "\tpop   EAX\n");
        }
 		Memory_Write(Size,EDI,EAX,Flags,MaskMode);
        break;

      case 8:
      	if (CalcAddress)
        {
                fprintf(fp, "\tpush  EAX\n");
			EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);
                fprintf(fp, "\tpop   EAX\n");
        }
		Memory_Write(Size,EDI,EAX,Flags,MaskMode);
        break;

      case 9:
      	if (CalcAddress)
        {
                fprintf(fp, "\tpush  EAX\n");
			EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);
                fprintf(fp, "\tpop   EAX\n");
        }
 		Memory_Write(Size,EDI,EAX,Flags,MaskMode);
        break;

      case 10:
      	if (CalcAddress)
        {
                fprintf(fp, "\tpush  EAX\n");
                EffectiveAddressCalculate(mode,Size,Rreg,SaveEDX);
                fprintf(fp, "\tpop   EAX\n");
        }
 		Memory_Write(Size,EDI,EAX,Flags,MaskMode);
        break;

      case 11:

      	/* SR, CCR - Chain to correct routine */

        WriteCCR(Size);
    }
}

/* Condition Decode Routines */

/*
 * mode = condition to check for
 *
 * Returns LABEL that is jumped to if condition is Condition
 *
 * Some conditions clobber AH
 */

char *ConditionDecode(int mode, int Condition)
{
    char *Label = GenerateLabel(0,1);

    switch(mode)
	{

      case 0:   /* A - Always */
           if (Condition)
           {
               fprintf(fp, "\tjmp   short %s\n",Label);
           }
           break;

      case 1:   /* F - Never */
           if (!Condition)
           {
               fprintf(fp, "\tjmp   short %s\n",Label);
           }
           break;

      case 2:   /* Hi */
           fprintf(fp, "\tmov   ah,dl\n");
           fprintf(fp, "\tsahf\n");

           if (Condition)
           {
                   fprintf(fp, "\tja    short %s\n",Label);
           }
           else
           {
                   fprintf(fp, "\tjbe   short %s\n",Label);
           }
           break;

      case 3:   /* Ls */
           fprintf(fp, "\tmov   ah,dl\n");
           fprintf(fp, "\tsahf\n");

           if (Condition)
           {
               fprintf(fp, "\tjbe   short %s\n",Label);
           }
           else
           {
               fprintf(fp, "\tja    short %s\n",Label);
           }
           break;

      case 4:   /* CC */
                   fprintf(fp, "\ttest  dl,1H\t\t;check carry\n");

           if (Condition)
           {
                           fprintf(fp, "\tjz    short %s\n",Label);
           }
           else
           {
                           fprintf(fp, "\tjnz   short %s\n",Label);
           }
           break;

      case 5:   /* CS */
                   fprintf(fp,  "\ttest  dl,1H\t\t;check carry\n");
           if (Condition)
           {
                           fprintf(fp, "\tjnz   short %s\n",Label);
           }
           else
           {
                           fprintf(fp, "\tjz    short %s\n",Label);
           }
           break;

      case 6:   /* NE */
                   fprintf(fp, "\ttest  dl,40H\t\t;Check zero\n");
           if (Condition)
           {
                           fprintf(fp, "\tjz    short %s\n",Label);
           }
           else
           {
                           fprintf(fp, "\tjnz   short %s\n",Label);
           }
           break;

      case 7:   /* EQ */
                   fprintf(fp, "\ttest  dl,40H\t\t;Check zero\n");
           if (Condition)
           {
                           fprintf(fp, "\tjnz   short %s\n",Label);
           }
           else
           {
                           fprintf(fp, "\tjz    short %s\n",Label);
           }
           break;

      case 8:   /* VC */
//                 fprintf(fp, "\ttest  dx,800H\t\t;Check Overflow\n");
                   fprintf(fp, "\ttest  dh,8H\t\t;Check Overflow\n");
           if (Condition)
           {
                           fprintf(fp, "\tjz    short %s\n", Label);
           }
           else
           {
                           fprintf(fp, "\tjnz   short %s\n", Label);
           }
           break;

      case 9:   /* VS */
//                 fprintf(fp, "\ttest  dx,800H\t\t;Check Overflow\n");
                   fprintf(fp, "\ttest  dh,8H\t\t;Check Overflow\n");
           if (Condition)
           {
                           fprintf(fp, "\tjnz   short %s\n", Label);
           }
           else
           {
                           fprintf(fp, "\tjz    short %s\n", Label);
           }
           break;

      case 10:   /* PL */
                   fprintf(fp,"\ttest  dl,80H\t\t;Check Sign\n");
           if (Condition)
           {
                           fprintf(fp, "\tjz    short %s\n", Label);
           }
           else
           {
                           fprintf(fp, "\tjnz   short %s\n", Label);
           }
           break;

      case 11:   /* MI */
                   fprintf(fp,"\ttest  dl,80H\t\t;Check Sign\n");
           if (Condition)
           {
                           fprintf(fp, "\tjnz   short %s\n", Label);
           }
           else
           {
                           fprintf(fp, "\tjz    short %s\n", Label);
           }
           break;

      case 12:   /* GE */
           fprintf(fp, "\tor    edx,200h\n");
           fprintf(fp, "\tpush  edx\n");
           fprintf(fp, "\tpopf\n");
           if (Condition)
           {
               fprintf(fp, "\tjge   short %s\n",Label);
           }
           else
           {
               fprintf(fp, "\tjl    short %s\n",Label);
           }
           break;

      case 13:   /* LT */
           fprintf(fp, "\tor    edx,200h\n");
           fprintf(fp, "\tpush  edx\n");
           fprintf(fp, "\tpopf\n");
           if (Condition)
           {
               fprintf(fp, "\tjl    short %s\n",Label);
           }
           else
           {
               fprintf(fp, "\tjge   short %s\n",Label);
           }
           break;

      case 14:   /* GT */
           fprintf(fp, "\tor    edx,200h\n");
           fprintf(fp, "\tpush  edx\n");
           fprintf(fp, "\tpopf\n");
           if (Condition)
           {
               fprintf(fp, "\tjg    short %s\n",Label);
           }
           else
           {
               fprintf(fp, "\tjle   short %s\n",Label);
           }
           break;

      case 15:   /* LE */
           fprintf(fp, "\tor    edx,200h\n");
           fprintf(fp, "\tpush  edx\n");
           fprintf(fp, "\tpopf\n");
           if (Condition)
           {
               fprintf(fp, "\tjle   short %s\n",Label);
           }
           else
           {
               fprintf(fp, "\tjg    short %s\n",Label);
           }
           break;
    }

    return Label;
}

/*
 * mode = condition to check for
 * SetWhat = text for assembler command (usually AL or address descriptor)
 *
 * Some conditions clobber AH
 */

void ConditionCheck(int mode, char *SetWhat)
{
    switch(mode)
	{

      case 0:   /* A - Always */
               fprintf(fp, "\tmov   %s,0ffh\n",SetWhat);
           break;

      case 1:   /* F - Never */
           if (SetWhat == "AL")
              {
              fprintf(fp, "\txor   eax,eax\n");
              }
           else
              {
              fprintf(fp, "\tmov   %s,0h\n",SetWhat);
              }
           break;

      case 2:   /* Hi */
           fprintf(fp, "\tmov   ah,dl\n");
           fprintf(fp, "\tsahf\n");
           fprintf(fp, "\tseta  %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 3:   /* Ls */
           fprintf(fp, "\tmov   ah,dl\n");
           fprintf(fp, "\tsahf\n");
           fprintf(fp, "\tsetbe %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 4:   /* CC */
           fprintf(fp, "\ttest  dl,1\t\t;Check Carry\n");
           fprintf(fp, "\tsetz  %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 5:   /* CS */
           fprintf(fp, "\ttest  dl,1\t\t;Check Carry\n");
           fprintf(fp, "\tsetnz %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 6:   /* NE */
                   fprintf(fp, "\ttest  dl,40H\t\t;Check Zero\n");
                   fprintf(fp, "\tsetz  %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 7:   /* EQ */
                   fprintf(fp, "\ttest  dl,40H\t\t;Check Zero\n");
                   fprintf(fp, "\tsetnz %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 8:   /* VC */
//                 fprintf(fp, "\ttest  dx,800H\t\t;Check Overflow\n");
                   fprintf(fp, "\ttest  dh,8H\t\t;Check Overflow\n");
                   fprintf(fp, "\tsetz  %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 9:   /* VS */
//                 fprintf(fp, "\ttest  dx,800H\t\t;Check Overflow\n");
                   fprintf(fp, "\ttest  dh,8H\t\t;Check Overflow\n");
                   fprintf(fp, "\tsetnz %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 10:   /* PL */
                   fprintf(fp, "\ttest  dl,80H\t\t;Check Sign\n");
                   fprintf(fp, "\tsetz  %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 11:   /* MI */
                   fprintf(fp, "\ttest  dl,80H\t\t;Check Sign\n");
                   fprintf(fp, "\tsetnz %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 12:   /* GE */
           fprintf(fp, "\tor    edx,200h\n");
           fprintf(fp, "\tpush  edx\n");
           fprintf(fp, "\tpopf\n");
               fprintf(fp, "\tsetge %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 13:   /* LT */
           fprintf(fp, "\tor    edx,200h\n");
           fprintf(fp, "\tpush  edx\n");
           fprintf(fp, "\tpopf\n");
               fprintf(fp, "\tsetl  %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 14:   /* GT */
           fprintf(fp, "\tor    edx,200h\n");
           fprintf(fp, "\tpush  edx\n");
           fprintf(fp, "\tpopf\n");
               fprintf(fp, "\tsetg  %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;

      case 15:   /* LE */
           fprintf(fp, "\tor    edx,200h\n");
           fprintf(fp, "\tpush  edx\n");
           fprintf(fp, "\tpopf\n");
               fprintf(fp, "\tsetle %s\n",SetWhat);
           fprintf(fp, "\tneg   b %s\n",SetWhat);
           break;
    }
}


/**********************************************************************/
/* Instructions - Each routine generates a range of instruction codes */
/**********************************************************************/

/*
 * Immediate Commands
 *
 * ORI	00xx
 * ANDI	02xx
 * SUBI	04xx
 * ADDI	06xx
 * EORI	0axx
 * CMPI	0cxx
 *
 */

void dump_imm( int type, int leng, int mode, int sreg )
{
	int Opcode,BaseCode ;
	char Size=' ' ;
	char * RegnameEBX="" ;
	char * Regname="" ;
	char * OpcodeName[16] = {"or ", "and", "sub", "add",0,"xor","cmp",0 } ;
	int allow[] = {1,0,1,1, 1,1,1,1, 1,0,0,0, 0,0,0,0, 0,0,0,1, 1 } ;

	Opcode = (type << 9) | ( leng << 6 ) | ( mode << 3 ) | sreg;

	BaseCode = Opcode & 0xfff8;

	if ( mode == 7 ) BaseCode |= sreg ;

	if ( (leng == 0) && (sreg == 7) && (mode > 2) && (mode < 5) )
	{
		BaseCode |= sreg ;
	}

    if (type != 4) 	/* Not Valid (for this routine) */
    {
        int Dest = EAtoAMN(Opcode, FALSE);
        int SetX;

        /* ADDI & SUBI also set X flag */

        SetX = ((type == 2) || (type == 3));

        switch (leng)
        {
            case 0:
                Size = 'B';
                Regname = regnamesshort[0];
                RegnameEBX = regnamesshort[EBX];
                break;
            case 1:
                Size = 'W';
                Regname = regnamesword[0];
                RegnameEBX = regnamesword[EBX];
                break;
            case 2:
                Size = 'L';
                Regname = regnameslong[0];
                RegnameEBX = regnameslong[EBX];
                break;
        }

        if (allow[Dest])
		{
			if (OpcodeArray[BaseCode] == -2 )
            {
				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                if  (mode < 2)
                {
                	if (Size != 'L' )
                        TimingCycles += 8;
                    else
                    {
                        TimingCycles += 14;
                        if ((type != 1) && (type!=6))
                            TimingCycles += 2 ;
                    }
                }
                else
                {
                    if (type != 6)
                    {
                        if (Size != 'L')
                            TimingCycles += 12 ;
                        else
                            TimingCycles += 20 ;
                    }
                    else
                    {
                        if (Size != 'L')
                            TimingCycles += 8 ;
                        else
                            TimingCycles += 12 ;
                    }
                }

                        fprintf(fp, "\tand   ecx,7\n");

                /* Immediate Mode Data */
                EffectiveAddressRead(11,Size,EBX,EBX,"--C-S-B",FALSE);

                /* Source Data */
				EffectiveAddressRead(Dest,Size,ECX,EAX,"-BC-SDB",FALSE);

                /* The actual work */
                        fprintf(fp, "\t%s   %s,%s\n", OpcodeName[type], Regname, RegnameEBX );

				SetFlags(Size,EAX,FALSE,SetX,TRUE);

		        if ( type != 6 ) /* CMP no update */
			        EffectiveAddressWrite(Dest,Size,ECX,EAX,"---DS-B",FALSE);

			    Completed();
 		    }
		}
        else
        {
        	/* Logicals are allowed to alter SR/CCR */

            if ((!SetX) && (Dest == 11) && (Size != 'L'))
            {
            	Align();

                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                TimingCycles += 20 ;

                if (Size=='W')
                {
	                /* If SR then must be in Supervisor Mode */

					char *Label = GenerateLabel(0,1);

                                fprintf(fp, "\ttest  b [%s],20h \t\t\t; Supervisor Mode ?\n",REG_SRH);
                                fprintf(fp, "\tjne   %s\n",Label);

                    /* User Mode - Exception */

                    Exception(8,BaseCode);

                    fprintf(fp, "%s:\t",Label);
                }

                /* Immediate Mode Data */
                EffectiveAddressRead(11,Size,EBX,EBX,"---DS-B",TRUE);

            	ReadCCR(Size,ECX);

                        fprintf(fp, "\t%s   %s,%s\n", OpcodeName[type], Regname, RegnameEBX );

                WriteCCR(Size);

                Completed();
            }
            else
            {

    	        /* Illegal Opcode */

                OpcodeArray[BaseCode] = -1;
                BaseCode = -1;
            }
        }
	}
    else
    {
    	BaseCode = -2;
    }

    OpcodeArray[Opcode] = BaseCode;
}

void immediate(void)
{
	int type, size, mode, sreg ;

	for ( type = 0 ; type < 0x7; type++ )
		for ( size = 0 ; size < 3 ; size++ )
			for ( mode = 0 ; mode < 8 ; mode++ )
				for ( sreg = 0 ; sreg < 8 ; sreg++ )
					dump_imm( type, size, mode, sreg ) ;
}


/*
 * Bitwise Codes
 *
 */

void dump_bit_dynamic( int sreg, int type, int mode, int dreg )
{
	int  Opcode, BaseCode ;
	char Size ;
	char *EAXReg,*ECXReg, *Label ;
	char allow[] = "0-2345678-------" ;
    int Dest ;

    /* BTST allows x(PC) and x(PC,xr.s) - others do not */

    if (type == 0)
    {
        allow[9] = '9';
    	allow[10] = 'a';
    }

	Opcode = 0x0100 | (sreg << 9) | (type<<6) | (mode<<3) | dreg ;
	BaseCode = Opcode & 0x01f8 ;
	if ( mode == 7 ) BaseCode |= dreg ;

    Dest = EAtoAMN(Opcode, FALSE);

	if ( allow[Dest&0xf] != '-' )
	{
		if ( mode == 0 ) /* long*/
		{
        	/* Modify register memory directly */

			Size = 'L' ;
            EAXReg = REG_DAT_EBX;
			ECXReg = regnameslong[ECX];
		}
		else
		{
			Size = 'B' ;
			EAXReg = regnamesshort[EAX];
			ECXReg = regnamesshort[ECX];
		}

		if ( OpcodeArray[BaseCode] == -2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            if (mode<2)
            {
            	switch (type)
                {
                    case 0:
                        TimingCycles += 6 ;
                        break;
                    case 1:
                    case 3:
                        TimingCycles += 8 ;
                        break;
                    case 2:
                        TimingCycles += 10;
                        break;
                }
            }
            else
            {
            	if (type==0)
                    TimingCycles += 4;
                else
                    TimingCycles += 8;
            }

            /* Only need this sorted out if a register is involved */

            if (Dest < 7)
            {
                                fprintf(fp, "\tmov   ebx,ecx\n");
                                fprintf(fp, "\tand   ebx,7\n");
            }

            /* Get bit number and create mask in ECX */

                        fprintf(fp, "\tshr   ecx,9\n");
                        fprintf(fp, "\tand   ecx,7\n");
                        fprintf(fp, "\tmov   ecx,d [%s+ECX*4]\n",REG_DAT);

			if ( Size == 'L' )
                                fprintf(fp, "\tand   ecx,31\n");
			else
                                fprintf(fp, "\tand   ecx,7\n");

                        fprintf(fp,"\tmov   eax,1\n");
                        fprintf(fp,"\tshl   eax,cl\n");
            fprintf(fp,"\tmov   ecx,eax\n");

            if (mode != 0)
				EffectiveAddressRead(Dest,Size,EBX,EAX,"-BCDSDB",TRUE);


			/* All commands copy existing bit to Zero Flag */

    		Label = GenerateLabel(0,1);

                        fprintf(fp,"\tand   dl,0BFH\t;Clear Zero Flag\n");
                        fprintf(fp,"\ttest  %s,%s\n",EAXReg,ECXReg);
            fprintf(fp,"\tjnz   short %s\n",Label);
            fprintf(fp,"\tor    edx,40h\n");
            fprintf(fp,"%s:\t",Label);

            /* Some then modify the data */

			switch ( type )
			{
				case 0: /* btst*/
					break;

				case 1: /* bchg*/
                                        fprintf(fp,"\txor   %s,%s\n",EAXReg,ECXReg);
					break;

				case 2: /* bclr*/
                                        fprintf(fp,"\tnot   ecx\n");
                                        fprintf(fp,"\tand   %s,%s\n",EAXReg,ECXReg);
					break;

				case 3: /* bset*/
                                        fprintf(fp,"\tor    %s,%s\n",EAXReg,ECXReg);
					break;
			}

            if ((mode !=0) && (type != 0))
				EffectiveAddressWrite(Dest,Size,EBX,FALSE,"---DS-B",TRUE);

			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}
}

void bitdynamic(void) /* dynamic non-immediate bit operations*/
{
	int type, sreg, mode, dreg ;

	for ( sreg = 0 ; sreg < 8 ; sreg++ )
		for ( type = 0 ; type < 4 ; type++ )
			for ( mode = 0 ; mode < 8 ;mode++ )
				for ( dreg = 0 ; dreg < 8 ;dreg++ )
					dump_bit_dynamic( sreg, type, mode, dreg ) ;
}

void dump_bit_static(int type, int mode, int dreg )
{
	int  Opcode, BaseCode ;
	char Size ;
	char *EAXReg,*ECXReg, *Label ;
	char allow[] = "0-2345678-------" ;
    int Dest ;

    /* BTST allows x(PC) and x(PC,xr.s) - others do not */

    if (type == 0)
    {
        allow[9] = '9';
    	allow[10] = 'a';
    }

	Opcode = 0x0800 | (type<<6) | (mode<<3) | dreg ;
	BaseCode = Opcode & 0x08f8 ;
	if ( mode == 7 ) BaseCode |= dreg ;

    Dest = EAtoAMN(Opcode, FALSE);

	if ( allow[Dest&0xf] != '-' )
	{
		if ( mode == 0 ) /* long*/
		{
        	/* Modify register memory directly */

			Size = 'L' ;
            EAXReg = REG_DAT_EBX;
			ECXReg = regnameslong[ECX];
		}
		else
		{
			Size = 'B' ;
			EAXReg = regnamesshort[EAX];
			ECXReg = regnamesshort[ECX];
		}

		if ( OpcodeArray[BaseCode] == -2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            if (mode<2)
            {
                switch ( type )
                {
                    case 0:
                        TimingCycles += 10 ;
                        break ;
                    case 1:
                    case 3:
                        TimingCycles += 12 ;
                        break ;
                    case 2:
                        TimingCycles += 14 ;
                        break ;
                }
            }
            else
            {
                if ( type != 0 )
                    TimingCycles += 12 ;
                else
                    TimingCycles += 8 ;
            }

            /* Only need this sorted out if a register is involved */

            if (Dest < 7)
            {
                                fprintf(fp, "\tmov   ebx,ecx\n");
                                fprintf(fp, "\tand   ebx,7\n");
            }

            /* Get bit number and create mask in ECX */

			Memory_Fetch('W',ECX,FALSE);
                    fprintf(fp, "\tadd   esi,2\n");

			if ( Size == 'L' )
                                fprintf(fp, "\tand   ecx,31\n");
                        else
                                fprintf(fp, "\tand   ecx,7\n");

                        fprintf(fp,"\tmov   eax,1\n");
                        fprintf(fp,"\tshl   eax,cl\n");
            fprintf(fp,"\tmov   ecx,eax\n");

            if (mode != 0)
				EffectiveAddressRead(Dest,Size,EBX,EAX,"-BCDSDB",TRUE);

			/* All commands copy existing bit to Zero Flag */

    		Label = GenerateLabel(0,1);

                        fprintf(fp,"\tand   dl,0BFH\t;Clear Zero Flag\n");
                        fprintf(fp,"\ttest  %s,%s\n",EAXReg,ECXReg);
            fprintf(fp,"\tjnz   short %s\n",Label);
            fprintf(fp,"\tor    edx,40h\n");
            fprintf(fp,"%s:\t",Label);

            /* Some then modify the data */

			switch ( type )
			{
				case 0: /* btst*/
					break;

				case 1: /* bchg*/
                                        fprintf(fp,"\txor   %s,%s\n",EAXReg,ECXReg);
					break;

				case 2: /* bclr*/
                                        fprintf(fp,"\tnot   ecx\n");
                                        fprintf(fp,"\tand   %s,%s\n",EAXReg,ECXReg);
					break;

				case 3: /* bset*/
                                        fprintf(fp,"\tor    %s,%s\n",EAXReg,ECXReg);
					break;
			}

            if ((mode !=0) && (type != 0))
				EffectiveAddressWrite(Dest,Size,EBX,FALSE,"---DS-B",TRUE);

			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}
}

void bitstatic(void) /* static non-immediate bit operations*/
{
	int type, mode, dreg ;

	for ( type = 0 ; type < 4 ; type++ )
		for ( mode = 0 ; mode < 8 ;mode++ )
			for ( dreg = 0 ; dreg < 8 ;dreg++ )
				dump_bit_static( type, mode, dreg ) ;
}

/*
 * Move Peripheral
 *
 */

void movep(void)
{
	int sreg,dir,leng,dreg ;
	int	Opcode, BaseCode ;

	for ( sreg = 0 ; sreg < 8 ; sreg++ )
    {
		for ( dir = 0 ; dir < 2 ; dir++ )
        {
			for ( leng = 0 ; leng < 2 ; leng++ )
            {
				for ( dreg = 0 ; dreg < 8 ; dreg++ )
				{
					Opcode = 0x0108 | (sreg<<9) | (dir<<7) | (leng<<6) | dreg;
					BaseCode = Opcode & 0x01c8 ;
					if (OpcodeArray[BaseCode] == -2)
					{
						Align();
                                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                        if (leng == 0 ) /* word */
                            TimingCycles += 16 ;
                        else
                            TimingCycles += 24 ;

                        /* Save Flags Register (so we only do it once) */

                        fprintf(fp, "\tpush  edx\n");

                                                fprintf(fp, "\tmov   ebx,ecx\n");
                                                fprintf(fp, "\tand   ebx,7\n");

                        /* Get Address to Read/Write in EDI */

						EffectiveAddressCalculate(5,'L',EBX,FALSE);

                                                fprintf(fp, "\tshr   ecx,9\n");
                                                fprintf(fp, "\tand   ecx,7\n");


						if ( dir == 0 ) /* from memory to register*/
						{
                        	Memory_Read('B',EDI,"-BC-SDB",2);		/* mask first call */
                                                        fprintf(fp,"\tmov   bh,al\n");
                                                        fprintf(fp,"\tadd   edi,2\n");
                        	Memory_Read('B',EDI,"-BC-SDB",0);		/* not needed then */
                                                        fprintf(fp,"\tmov   bl,al\n");

							if ( leng == 0 ) /* word d(Ax) into Dx.W*/
							{
                                                                fprintf(fp,"\tmov   w [%s+ecx*4],bx\n",REG_DAT);
							}
							else /* long d(Ax) into Dx.L*/
							{
                                                                fprintf(fp,"\tadd   edi,2\n");
                                                                fprintf(fp,"\tshl   ebx,16\n");
	                        	Memory_Read('B',EDI,"-BC-SDB",0);
                                                                fprintf(fp,"\tmov   bh,al\n");
                                                                fprintf(fp,"\tadd   edi,2\n");
	                        	Memory_Read('B',EDI,"-BC-S-B",0);
                                                                fprintf(fp,"\tmov   bl,al\n");
                                                                fprintf(fp,"\tmov   d [%s+ecx*4],ebx\n",REG_DAT);
							}
						}
                        else /* Register to Memory*/
                        {
                                                        fprintf(fp,"\tmov   eax,d [%s+ecx*4]\n",REG_DAT);

                            /* Move bytes into Line */

                            if ( leng == 1)
                                fprintf(fp,"\trol   eax,8\n");
                            else
                                fprintf(fp,"\trol   eax,24\n");

							Memory_Write('B',EDI,EAX,"A---SDB",2);	/* Mask First */
                                                        fprintf(fp,"\tadd   edi,2\n");
                                                        fprintf(fp,"\trol   eax,8\n");

                            if ( leng == 1 ) /* long*/
                            {
								Memory_Write('B',EDI,EAX,"A---SDB",0);
                                                            fprintf(fp,"\tadd   edi,2\n");
                                                            fprintf(fp,"\trol   eax,8\n");
                                                                Memory_Write('B',EDI,EAX,"A---SDB",0);                                                            fprintf(fp,"\tadd   edi,2\n");
                                                            fprintf(fp,"\trol   eax,8\n");
                            }
							Memory_Write('B',EDI,EAX,"A---S-B",0);
                        }

                        fprintf(fp, "\tpop   edx\n");
						Completed();
					}

					OpcodeArray[Opcode] = BaseCode ;
				}
            }
        }
    }
}

/*
 * Move Instructions
 *
 * Used to generate MOVE.B, MOVE.W and MOVE.L
 *
 */

void movereg(void)
{
    int   Opcode ;
    int       leng,dreg,sreg ;
    char  Size ;

    for ( leng = 1 ; leng < 4; leng++ )
    for ( dreg = 0 ; dreg < 8; dreg++ )
    for ( sreg = 0 ; sreg < 8; sreg++ )
    {
        Opcode = (leng<<12) | (dreg<<9) | sreg;

        if (OpcodeArray[Opcode] == -2)
        {
           Align();
           fprintf(fp, "%s:\t",GenerateLabel(Opcode,0));

           TimingCycles += 4 ;

           /* Always read 32 bits - no prefix, no partial stalls */

           fprintf(fp, "\tmov   eax,d [%d+%s]\n",4+sreg*4,ICOUNT);

           switch( leng )
           {
           case 1:
             if (sreg != dreg)
                fprintf(fp, "\tmov   b [%d+%s],al\n",4+dreg*4,ICOUNT);
                fprintf(fp, "\ttest  al,al\n");
                break;
           case 2:
             if (sreg != dreg)
                fprintf(fp, "\tmov   d [%d+%s],eax\n",4+dreg*4,ICOUNT);
                fprintf(fp, "\ttest  eax,eax\n");
                break;
           case 3:
             if (sreg != dreg)
                fprintf(fp, "\tmov   w [%d+%s],ax\n",4+dreg*4,ICOUNT);
                fprintf(fp, "\ttest  ax,ax\n");
                break;
           }

           fprintf(fp, "\tpushf\n");
           fprintf(fp, "\tpop   edx\n");
           Completed();

           OpcodeArray[Opcode] = Opcode;
           }
    }
}

void movecodes(int allowfrom[],int allowto[],int Start,char Size)	/* MJC */
{
    int Opcode;
    int Src,Dest;
    int SaveEDX;
    int BaseCode;

    for(Opcode=Start;Opcode<Start+0x1000;Opcode++)
    {
    	/* Mask our Registers */

        BaseCode = Opcode & (Start + 0x1f8);

        /* Unless Mode = 7 */

        if ((BaseCode & 0x38)  == 0x38)  BaseCode |= (Opcode & 7);
        if ((BaseCode & 0x1c0) == 0x1c0) BaseCode |= (Opcode & 0xE00);

        /* If mode = 3 or 4 and Size = byte and register = A7 */
        /* then make it a separate code                       */

        if (Size == 'B')
        {  if (((Opcode & 0x3F) == 0x1F) || ((Opcode & 0x3F) == 0x27)){
              BaseCode |= 0x07;}

           if (((Opcode & 0xFC0) == 0xEC0) || ((Opcode & 0xFC0) == 0xF00)){
              BaseCode |= 0x0E00;}
        }

        if (OpcodeArray[BaseCode] == -2)
        {
           Src  = EAtoAMN(Opcode, FALSE);
           Dest = EAtoAMN(Opcode >> 6, TRUE);

           if ((allowfrom[(Src & 15)]) && (allowto[(Dest & 15)])){
              /* If we are not going to calculate the flags */
              /* we need to preserve the existing ones      */

              SaveEDX = (Dest == 1);

              Align();
              fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

              TimingCycles += 4 ;

              if (Src < 7){
                 if (Dest < 7){
                    fprintf(fp, "\tmov   ebx,ecx\n");
                    fprintf(fp, "\tand   ebx,7\n");
                    EffectiveAddressRead(Src,Size,EBX,EAX,"--CDS-B",SaveEDX);}

                 else{
                    fprintf(fp, "\tand   ecx,7\n");
                    EffectiveAddressRead(Src,Size,ECX,EAX,"---DS-B",SaveEDX);
                 }
               }
               else
               {
                 if (Dest < 7)
                    EffectiveAddressRead(Src,Size,EBX,EAX,"--CDS-B",SaveEDX);
                 else
                    EffectiveAddressRead(Src,Size,EBX,EAX,"---DS-B",SaveEDX);
               }

               /* No flags if Destination Ax */

               if (!SaveEDX){
                  SetFlags(Size,EAX,TRUE,FALSE,TRUE);}

               if (Dest < 7){
                  fprintf(fp, "\tshr   ecx,9\n");
                  fprintf(fp, "\tand   ecx,7\n");}

               EffectiveAddressWrite(Dest,Size,ECX,TRUE,"---DS-B",SaveEDX);

               Completed();
            }
            else
            {
            	BaseCode = -1;	/* Invalid Code */
            }
        }
        else
        {
            BaseCode = OpcodeArray[BaseCode];
        }

        if (OpcodeArray[Opcode] < 0)
       		OpcodeArray[Opcode] = BaseCode;
    }
}

void moveinstructions(void)
{
	int allowfrom[] = {1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0};
	int allowto[]   = {1,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0};

	/* Register transfers first */

/*  movereg();*/

    /* For Byte */

    movecodes(allowfrom,allowto,0x1000,'B');

    /* For Word & Long */

    allowto[1] = 1;
    movecodes(allowfrom,allowto,0x2000,'L');
    movecodes(allowfrom,allowto,0x3000,'W');
}

/*
 *
 * Opcodes 5###
 *
 * ADDQ,SUBQ,Scc and DBcc
 *
 */

void opcode5(void)
{
	/* ADDQ,SUBQ,Scc and DBcc */

	int allowtoScc[]   = {1,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0};
	int allowtoADDQ[]  = {1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0};
	int Opcode,BaseCode;
    int Counter;
    char Label[32];
    char Label2[32];
    char Size=' ';
    char* Regname="";
    char* RegnameECX="";

    for (Opcode = 0x5000;Opcode < 0x6000;Opcode++)
    {
        if ((Opcode & 0xc0) == 0xc0)
        {
            /* Scc or DBcc */

            BaseCode = Opcode & 0x5FF8;
            if ((BaseCode & 0x38) == 0x38) BaseCode |= (Opcode & 7);

        	/* If mode = 3 or 4 and register = A7 */
	        /* then make it a separate code                       */

       		if (((Opcode & 0x3F) == 0x1F) || ((Opcode & 0x3F) == 0x27))
           	{
           		BaseCode |= 0x07;
           	}

            if (OpcodeArray[BaseCode] == -2)
            {
                OpcodeArray[BaseCode] = BaseCode;

                if ((BaseCode & 0x38) == 0x8)
                {
                      /* DBcc */

                      Align();
                      fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                    TimingCycles += 10 ;

                    strcpy(Label,GenerateLabel(BaseCode,1)) ;
                    strcpy(Label2,ConditionDecode((Opcode >> 8) & 0x0F,TRUE));

                    /* False - Decrement Counter - Loop if not -1 */

                    fprintf(fp, "\tand   ecx,7\n");
                    fprintf(fp, "\tmov   ax,w [%s+ecx*4]\n",REG_DAT);
                    fprintf(fp, "\tdec   ax\n");
                    fprintf(fp, "\tmov   w [%s+ecx*4],ax\n",REG_DAT);
                    fprintf(fp, "\tinc   ax\t\t; Is it -1\n");
                    fprintf(fp, "\tjz    short %s\n",Label);
                    Memory_Fetch('W',EAX,TRUE);
                    fprintf(fp, "\tadd   esi,eax\n");
                    fprintf(fp, "\tand   esi,0ffffffh\n");
                    Completed();

                    /* True - Exit Loop */
                    fprintf(fp, "%s:\t",Label);
//                  fprintf(fp, "\tsub   d [%s],2\n",ICOUNT);

                    fprintf(fp, "%s:\t",Label2);
                    fprintf(fp, "\tadd   esi,2\n");
                    TimingCycles += 2 ;

			        Completed();
                }
                else
                {
                	/* Scc */

                	int  Dest = EAtoAMN(Opcode, FALSE);
                    char TrueLabel[16];

	                if (allowtoScc[(Dest & 15)])
    	            {
                           Align();
                           fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));
                        if ( Dest > 1 )
                           TimingCycles += 8 ;
                        else
                           TimingCycles += 4 ;

                        if (Dest < 7)
                        {
                           fprintf(fp, "\tand   ecx,7\n");
                        }

                        if (Dest > 1)
                        {
                           EffectiveAddressCalculate(Dest,'B',ECX,TRUE);
                           fprintf(fp,"\tand   edi,0FFFFFFh\n");
                        }

                        ConditionCheck((Opcode >> 8) & 0x0F,"AL");

                        EffectiveAddressWrite(Dest,'B',ECX,FALSE,"---DS-B",TRUE);

                        /* take advantage of AL being 0 for false, 0xff for true */
                        /* need to add 2 cycles if register and condition is true */

/*                        if ( Dest == 0 )
                        {
                           fprintf(fp, "\tand   eax,2\n");
                           fprintf(fp, "\tadd   eax,%d\n",TimingCycles);
                           fprintf(fp, "\tsub   d [%s],eax\n",ICOUNT);

                           TimingCycles = -1;
                        }
*/
						Completed();
                    }
                    else
                    {
                        OpcodeArray[BaseCode] = -1;
                        BaseCode = -1;
                    }
                }
            }
            else
            {
                BaseCode = OpcodeArray[BaseCode];
            }

           	OpcodeArray[Opcode] = BaseCode;
        }
        else
        {
            /* ADDQ or SUBQ */

            BaseCode = Opcode & 0x51F8;
            if ((BaseCode & 0x38) == 0x38) BaseCode |= (Opcode & 7);

            /* Special for Address Register Direct - Force LONG */

            if ((Opcode & 0x38) == 0x8) BaseCode = ((BaseCode & 0xFF3F) | 0x80);


        	/* If mode = 3 or 4 and Size = byte and register = A7 */
	        /* then make it a separate code                       */

        	if ((Opcode & 0xC0) == 0)
	        {
        		if (((Opcode & 0x3F) == 0x1F) || ((Opcode & 0x3F) == 0x27))
            	{
            		BaseCode |= 0x07;
            	}
        	}

            if (OpcodeArray[BaseCode] == -2)
            {
                char *Operation;
                char *Regwide = "";

                int Dest = EAtoAMN(Opcode, FALSE);
                int SaveEDX = (Dest == 1);

                if (allowtoADDQ[(Dest & 15)])
                {
                    switch (BaseCode & 0xC0)
                    {
                        case 0:
                            Size = 'B';
                            Regwide = "b";
                            Regname = regnamesshort[0];
                            RegnameECX = regnamesshort[ECX];
                            break;

                        case 0x40:
                            Size = 'W';
                            Regwide = "w";
                            Regname = regnamesword[0];
                            RegnameECX = regnamesword[ECX];
                            break;

                        case 0x80:
                            Size = 'L';
                            Regwide = "d";
                            Regname = regnameslong[0];
                            RegnameECX = regnameslong[ECX];
                            break;
                    }

                    OpcodeArray[BaseCode] = BaseCode;

                    Align();
                            fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                    if ( Dest == 0 ) /* write to Dx */
                    {
                        if ( Size != 'L' )
                           TimingCycles += 4 ;
                        else
                           TimingCycles += 8 ;
                    }

                    if ( Dest == 1 )
                    {
                        if ((Size == 'L') || (Opcode & 0x100)) /* if long or SUBQ */
                           TimingCycles += 8 ;
                        else
                           TimingCycles += 4 ;
                    }

                    if ( Dest > 1 ) /* write to mem */
                    {
                        if ( Size != 'L' )
                           TimingCycles += 8 ;
                        else
                           TimingCycles += 12 ;
                    }

                    if (Dest < 7)
                    {
                            fprintf(fp, "\tmov   ebx,ecx\n");
                            fprintf(fp, "\tand   ebx,7\n");
                    }

                    if (Dest > 1)
                    {
				        EffectiveAddressRead(Dest,Size,EBX,EAX,"-BCDSDB",SaveEDX);
                    }

                    /* Sub Immediate from Opcode */

                    fprintf(fp, "\tshr   ecx,9\n");

                    Immediate8();

                    if (Opcode & 0x100)
                    {
                        /* SUBQ */
                        Operation = "sub";
                    }
                    else
                    {
                        /* ADDQ */
                        Operation = "add";
                    }

                    /* For Data or Address register, operate directly */
                    /* on the memory location. Don't load into EAX    */

                    if (Dest < 2)
                    {
                        if (Dest == 0)
                        {
                            fprintf(fp, "\t%s   %s [%s+ebx*4],%s\n",Operation,Regwide,REG_DAT,RegnameECX);
                        }
                        else
                        {
                            fprintf(fp, "\t%s   %s [%s+ebx*4],%s\n",Operation,Regwide,REG_ADD,RegnameECX);
                        }
                    }
                    else
                    {
                        fprintf(fp, "\t%s   %s,%s\n",Operation,Regname,RegnameECX);
                    }

                    /* No Flags for Address Direct */

                    if (!SaveEDX)
                    {
                    	/* Directly after ADD or SUB, so test not needed */

			            SetFlags(Size,EAX,FALSE,TRUE,TRUE);
                    }

                    if (Dest > 1)
                    {
				        EffectiveAddressWrite(Dest,Size,EBX,FALSE,"---DS-B",FALSE);
                    }

                    Completed();
                }
                else
                {
                    OpcodeArray[BaseCode] = -1;
                    BaseCode = -1;
                }
            }
            else
            {
                BaseCode = OpcodeArray[BaseCode];
            }

            OpcodeArray[Opcode] = BaseCode;
        }
    }
}

/*
 * Branch Instructions
 *
 * BSR, Bcc
 *
 */

void branchinstructions(void)
{
	int Opcode,BaseCode;
    int Counter;
    char *Label;

    for (Opcode = 0x60;Opcode < 0x70;Opcode++)
    {
		BaseCode = Opcode * 0x100;
        OpcodeArray[BaseCode] = BaseCode;

        /* Displacement = 0 -> 16 Bit displacement */

		Align();
                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

        TimingCycles += 10 ;

        if (Opcode > 0x60)
        {
            if (Opcode != 0x61)
            {
			    Label = ConditionDecode(Opcode & 0x0F,TRUE);

                /* Code for Failed branch */

//                fprintf(fp, "\tsub   d [%s],2\n",ICOUNT);
                            fprintf(fp, "\tadd   esi,2\n");
                Completed();

                /* Successful Branch */

                fprintf(fp, "%s:\t",Label);
            }
            else
            {
        	    /* BSR - Special Case */

                TimingCycles += 8 ;

                fprintf(fp, "\tmov   edi,d [%s]           ; Get A7\n",REG_A7);
                fprintf(fp, "\tmov   eax,esi            ; Get PC\n");
                fprintf(fp, "\tsub   edi,4         ; Decrement A7\n");
                fprintf(fp, "\tadd   eax,2         ; Skip Displacement\n");
                fprintf(fp, "\tmov   d [%s],edi\n",REG_A7);
				Memory_Write('L',EDI,EAX,"---DS-B",1);
            }
        }

        /* Common Ending */

		Memory_Fetch('W',EAX,TRUE);
        fprintf(fp, "\tadd   esi,eax\n");
        fprintf(fp, "\tand   esi,0ffffffh\n");
        Completed();


        /* 8 Bit Displacement included */

		Align();
                fprintf(fp, "%s:\t",GenerateLabel(BaseCode+1,0));

        TimingCycles += 10 ;

        if (Opcode > 0x60)
        {
            if (Opcode != 0x61)
            {
			    Label = ConditionDecode(Opcode & 0x0F,TRUE);

                /* Code for Failed branch */

//                fprintf(fp, "\tadd   d [%s],2\n",ICOUNT);
		        Completed();

                /* Successful Branch */

                fprintf(fp, "%s:\t",Label);
            }
            else
            {
        	    /* BSR - Special Case */

                TimingCycles += 8 ;

                fprintf(fp, "\tmov   edi,d [%s]      ; Get A7\n",REG_A7);
                fprintf(fp, "\tmov   eax,esi            ; Get PC\n");
                fprintf(fp, "\tsub   edi,4         ; Decrement\n");
                fprintf(fp, "\tmov   d [%s],edi\n",REG_A7);
				Memory_Write('L',EDI,ESI,"--CDS-B",1);
            }
        }

        /* Common Ending */

        fprintf(fp, "\tmovsx eax,cl               ; Sign Extend displacement\n");
        fprintf(fp, "\tadd   esi,eax\n");
        fprintf(fp, "\tand   esi,0ffffffh\n");
        Completed();

        /* Fill up Opcode Array */

        for (Counter=1;Counter<0xff;Counter++)
            OpcodeArray[BaseCode+Counter] = BaseCode+1;


        /* 68020 instruction - 32 bit displacement */

		Align();
                fprintf(fp, "%s:\t",GenerateLabel(BaseCode+0xff,0));

        TimingCycles += 10 ;

        if (Opcode > 0x60)
        {
            if (Opcode != 0x61)
            {
			    Label = ConditionDecode(Opcode & 0x0F,TRUE);

                /* Code for Failed branch */

//                fprintf(fp, "\tadd   d [%s],2\n",ICOUNT);
                            fprintf(fp, "\tadd   esi,4\n");
		        Completed();

                /* Successful Branch */

                fprintf(fp, "%s:\t",Label);
            }
            else
            {
        	    /* BSR - Special Case */

                TimingCycles += 8 ;

                fprintf(fp, "\tmov   edi,d [%s]      ; Get A7\n",REG_A7);
                fprintf(fp, "\tmov   eax,esi            ; Get PC\n");
                fprintf(fp, "\tsub   edi,4         ; Decrement A7\n");
                fprintf(fp, "\tadd   eax,2         ; Skip Displacement\n");
                fprintf(fp, "\tmov   d [%s],edi\n",REG_A7);
				Memory_Write('L',EDI,EAX,"---DS-B",1);
            }
        }

        /* Common Ending */

		Memory_Fetch('L',EAX,FALSE);
        fprintf(fp, "\tadd   esi,eax\n");
        fprintf(fp, "\tand   esi,0ffffffh\n");
        Completed();

        OpcodeArray[BaseCode+0xff] = BaseCode+0xff;
    }
}

/*
 * Move Quick Commands
 *
 * Fairly simple, as only allowed to Data Registers
 *
 */

void moveq(void)
{
	int Count;

	/* The Code */

	Align();
        fprintf(fp, "%s:\t",GenerateLabel(0x7000,0));

    TimingCycles += 4 ;

    fprintf(fp, "\tmovsx eax,cl\n");
    fprintf(fp, "\tshr   ecx,9\n");
    fprintf(fp, "\tand   ecx,7\n");
    SetFlags('L',EAX,TRUE,FALSE,FALSE);
    EffectiveAddressWrite(0,'L',ECX,TRUE,"---DS-B",FALSE);
    Completed();

    /* Set OpcodeArray (Not strictly correct, since some are illegal!) */

    for (Count=0x7000;Count<0x8000;Count++)
    {
        OpcodeArray[Count] = 0x7000;
    }
}

/*
 * Extended version of Add & Sub commands
 *
 */

void addx_subx(void)
{
	int	Opcode, BaseCode ;
	int	regx,type,leng,rm,regy,mode ;
	char  Size=' ' ;
	char * Regname="" ;
	char * RegnameEBX="" ;
        char * Regwide ="";
        char * Operand="";
	char * Label;

	for ( type = 0 ; type < 2 ; type ++ ) /* 0=subx, 1=addx */
	for ( regx = 0 ; regx < 8 ; regx++ )
	for ( leng = 0 ; leng < 3 ; leng++ )
	for ( rm = 0 ; rm < 2 ; rm++ )
	for ( regy = 0 ; regy < 8 ; regy++ )
	{
		Opcode = 0x9100 | (type<<14) | (regx<<9) | (leng<<6) | (rm<<3) | regy ;

		BaseCode = Opcode & 0xd1c8 ;

		if ( rm == 0 )
			mode = 0 ;
		else
			mode = 4 ;

      	switch (leng)
	    {
            case 0:
               	Size = 'B';
                Regwide = "b";
                Regname = regnamesshort[0];
                RegnameEBX = regnamesshort[EBX];
                break;
            case 1:
                Size = 'W';
                Regwide = "w";
                Regname = regnamesword[0];
                RegnameEBX = regnamesword[EBX];
                break;
            case 2:
                Size = 'L';
                Regwide = "d";
                Regname = regnameslong[0];
                RegnameEBX = regnameslong[EBX];
                break;
      	}

		if ( OpcodeArray[BaseCode] == -2 )
		{
		    if (type == 0)
				Operand = "sbb";
		    else
				Operand = "adc";

			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            /* don't add in EA timing for ADDX,SUBX */

            AddEACycles = 0 ;

            if ( rm == 0 ) /* reg to reg */
            {
                if ( Size != 'L' )
                    TimingCycles += 4 ;
                else
                    TimingCycles += 8 ;
            }
            else
            {
                if ( Size != 'L' )
                    TimingCycles += 18 ;
                else
                    TimingCycles += 30 ;
            }

                        fprintf(fp, "\tmov   ebx,ecx\n");
                        fprintf(fp, "\tand   ebx,7\n");
                        fprintf(fp, "\tshr   ecx,9\n");
                        fprintf(fp, "\tand   ecx,7\n");

		    /* Get Source */

			EffectiveAddressRead(mode,Size,EBX,EBX,"--CDS-B",FALSE);

		    /* Get Destination (if needed) */

			if (mode == 4)
				EffectiveAddressRead(mode,Size,ECX,EAX,"-BCDSDB",FALSE);

		    /* Copy the X flag into the Carry Flag */

			CopyX();

		    /* Do the sums */

		    if (mode == 0)
                                fprintf(fp, "\t%s   %s [%s+ecx*4],%s\n",Operand,Regwide,REG_DAT,RegnameEBX);
			else
                                fprintf(fp, "\t%s   %s,%s\n",Operand,Regname,RegnameEBX);

    		/* Preserve old Z flag */

                    fprintf(fp, "\tmov   ebx,edx\n");

		    /* Set the Flags */

		    SetFlags(Size,EAX,FALSE,TRUE,FALSE);

		    /* Handle the Z flag */

			Label = GenerateLabel(0,1);

                        fprintf(fp, "\tjnz   short %s\n\n",Label);

                    fprintf(fp, "\tand   dl,0BFh       ; Remove Z\n");
                    fprintf(fp, "\tand   bl,40h        ; Mask out Old Z\n");
                    fprintf(fp, "\tor    dl,bl         ; Copy across\n\n");
                    fprintf(fp, "%s:\t",Label);

		    /* Update the Data (if needed) */

		    if (mode == 4)
                       EffectiveAddressWrite(mode,Size,ECX,FALSE,"---DS-B",TRUE);

		    Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}
}

/*
 * Logicals / Simple Maths (+ and -)
 *
 * OR,AND,CMP,EOR,ADD and SUB
 *
 */

void dumpx( int start, int reg, int type, char * Op, int dir, int leng, int mode, int sreg )
{
	int Opcode,BaseCode ;
	char Size=' ' ;
	char * RegnameECX="" ;
	char * Regname="" ;
    char *Operation="";
    char *Regwide="";
    int Dest ;
    int SaveEDX ;
    int SaveDir;
	char * allow="" ;
	char * allowtypes[] = { "0-23456789ab----", "--2345678-------",
					        "0123456789ab----", "0-2345678-------" };

        switch (leng)
        {
                case 0: Regwide="b";
                        break;

                case 1: Regwide="w";
                        break;

                case 2: Regwide="d";
                        break;
        }

    SaveDir = dir;

	switch (type)
	{
		case 0: /* or and*/
			if ( dir == 0 )
				allow = allowtypes[0];
			else
				allow = allowtypes[1];
			break ;

		case 1: /* cmp*/
			allow = allowtypes[2] ;
			break ;

		case 2: /* eor*/
			allow = allowtypes[3] ;
			break ;

		case 3: /* adda suba cmpa*/
			allow = allowtypes[2] ;
			break ;

		case 4: /* sub add*/
			if ( dir == 0 )
				allow = allowtypes[0] ;
			else
				allow = allowtypes[1] ;
			break ;
	}

	if ( (type == 4) && (dir == 0) && (leng > 0) )
	{
		allow = allowtypes[2] ; /* word and long ok*/
	}

	Opcode = start | (reg << 9 ) | (dir<<8) | (leng<<6) | (mode<<3) | sreg;

	BaseCode = Opcode & 0xf1f8;

	if ( mode == 7 ) BaseCode |= sreg ;

	if ( (mode == 3 || mode == 4) && ( leng == 0 ) && (sreg == 7 ) )
		BaseCode |= sreg ;

    Dest = EAtoAMN(Opcode, FALSE);
    SaveEDX = (Dest == 1) || (type == 3);

	if ( allow[Dest&0xf] != '-' )
	{
		if ( OpcodeArray[BaseCode] == -2 )
		{
            switch (leng)
      		{
                  case 0:
                        Size = 'B';
                        Regname = regnamesshort[0];
                        RegnameECX = regnamesshort[ECX];
                        break;
                  case 1:
                        Size = 'W';
                        Regname = regnamesword[0];
                        RegnameECX = regnamesword[ECX];
                        break;
                  case 2:
                        Size = 'L';
                        Regname = regnameslong[0];
                        RegnameECX = regnameslong[ECX];
                        break;

                  case 3: /* cmpa adda suba */
				        if ( dir == 0 )
						{
	                        Size = 'W';
      	                    Regname = regnamesword[0];
            	            RegnameECX = regnamesword[ECX];
						}
						else
						{
	                        Size = 'L';
      	                    Regname = regnameslong[0];
            	            RegnameECX = regnameslong[ECX];
						}
						dir = 0 ;
						break ;
            }

		    Align();
                    fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            if (dir==0)
            {
                if ( Size != 'L' )
                    TimingCycles += 4;
                else
                    TimingCycles += 6;
            }
            else
            {
                if ( Size != 'L' )
                    TimingCycles += 8;
                else
                    TimingCycles += 12;
            }

            if ((mode == 0) && (dir==0) && (Size == 'L'))
               TimingCycles += 2 ;

            if ((mode == 1) && (dir==0) && (Size != 'L'))
               TimingCycles += 4 ;

		    if (Dest < 7) 	/* Others do not need reg.no. */
		    {
                            fprintf(fp, "\tmov   ebx,ecx\n");
                            fprintf(fp, "\tand   ebx,7\n");
		    }

                    fprintf(fp, "\tshr   ecx,9\n");
                    fprintf(fp, "\tand   ecx,7\n");

		    EffectiveAddressRead(Dest,Size,EBX,EAX,"-BCDSDB",SaveEDX);

		    if ( dir == 0 )
		    {
				if ( type != 3 )
                {
                                fprintf(fp, "\t%s   %s [%s+ECX*4],%s\n",Op ,Regwide,REG_DAT ,Regname ) ;

				    if ( type == 4 )
			    	    SetFlags(Size,EAX,FALSE,TRUE,FALSE);
				    else
			    	    SetFlags(Size,EAX,FALSE,FALSE,FALSE);
                }
				else
				{
					if ( Size == 'W' )
                                        fprintf(fp, "\tcwde\n");

                                        fprintf(fp, "\t%s   %s [%s+ECX*4],EAX\n",Op ,Regwide,REG_ADD);

                    if (Op == "cmp")
                    {
                    	SetFlags('L',EAX,FALSE,FALSE,FALSE);
                    }
				}
		    }
		    else
		    {
                            fprintf(fp, "\t%s   %s,%s [%s+ECX*4]\n", Op, Regname ,Regwide, REG_DAT ) ;

                if ( type == 4)
			    	SetFlags(Size,EAX,FALSE,TRUE,TRUE);
                else
			    	SetFlags(Size,EAX,FALSE,FALSE,TRUE);

			    EffectiveAddressWrite(Dest,Size,EBX,FALSE,"---DS-B",FALSE);
		    }
		    Completed();
	 	}

		OpcodeArray[Opcode] = BaseCode;
	}

    dir = SaveDir;
}

void typelogicalmath(void)
{
	int type, dir, leng, mode, sreg ,reg ;

	for ( reg = 0 ; reg < 8 ; reg++ )
	{
	    /* or */
	    for ( dir = 0 ; dir < 2 ; dir++ )
	        for ( leng = 0 ; leng < 3; leng++ )
	            for ( mode = 0 ; mode < 8 ; mode++ )
	                for ( sreg = 0 ; sreg < 8 ; sreg++ )
				    	dumpx( 0x8000, reg, 0, "or ", dir, leng, mode, sreg ) ;

		/* sub */
	    for ( dir = 0 ; dir < 2 ; dir++ )
	        for ( leng = 0 ; leng < 3; leng++ )
	            for ( mode = 0 ; mode < 8 ; mode++ )
	                for ( sreg = 0 ; sreg < 8 ; sreg++ )
				    	dumpx( 0x9000, reg, 4, "sub", dir, leng, mode, sreg ) ;

        /* suba */

	  	for ( dir = 0 ; dir < 2 ; dir++ )
	    	for ( mode = 0 ; mode < 8 ; mode++ )
	        	for ( sreg = 0 ; sreg < 8 ; sreg++ )
			    	dumpx( 0x9000, reg, 3, "sub", dir, 3, mode, sreg ) ;


	    /* cmp */
        for ( leng = 0 ; leng < 3; leng++ )
	        for ( mode = 0 ; mode < 8 ; mode++ )
	            for ( sreg = 0 ; sreg < 8 ; sreg++ )
			    	dumpx( 0xb000, reg, 1, "cmp", 0, leng, mode, sreg ) ;

        /* cmpa */

	  	for ( dir = 0 ; dir < 2 ; dir++ )
	        for ( mode = 0 ; mode < 8 ; mode++ )
	            for ( sreg = 0 ; sreg < 8 ; sreg++ )
			    	dumpx( 0xb000, reg, 3, "cmp", dir, 3, mode, sreg ) ;

        /* adda */

	  	for ( dir = 0 ; dir < 2 ; dir++ )
	        for ( mode = 0 ; mode < 8 ; mode++ )
	            for ( sreg = 0 ; sreg < 8 ; sreg++ )
			    	dumpx( 0xd000, reg, 3, "add", dir, 3, mode, sreg ) ;


	    /* eor */
        for ( leng = 0 ; leng < 3; leng++ )
	        for ( mode = 0 ; mode < 8 ; mode++ )
	            for ( sreg = 0 ; sreg < 8 ; sreg++ )
			    	dumpx( 0xb100, reg, 2, "xor", 1, leng, mode, sreg ) ;

	    /* and */
	    for ( dir = 0 ; dir < 2 ; dir++ )
	        for ( leng = 0 ; leng < 3; leng++ )
	            for ( mode = 0 ; mode < 8 ; mode++ )
	                for ( sreg = 0 ; sreg < 8 ; sreg++ )
				    	dumpx( 0xc000, reg, 0, "and", dir, leng, mode, sreg ) ;

	    /* add  */
	    for ( dir = 0 ; dir < 2 ; dir++ )
	        for ( leng = 0 ; leng < 3; leng++ )
	            for ( mode = 0 ; mode < 8 ; mode++ )
	                for ( sreg = 0 ; sreg < 8 ; sreg++ )
				    	dumpx( 0xd000, reg, 4, "add", dir, leng, mode, sreg ) ;
	}
}

/*
 * Single commands missed out by routines above
 *
 */

void mul(void)
{
	int dreg, type, mode, sreg ;
	int Opcode, BaseCode ;
	int Dest ;
	char allow[] = "0-23456789ab-----" ;

	for ( dreg = 0 ; dreg < 8 ; dreg++ )
	for ( type = 0 ; type < 2 ; type++ )
	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0xc0c0 | (dreg<<9) | (type<<8) | (mode<<3) | sreg ;
		BaseCode = Opcode & 0xc1f8 ;
		if ( mode == 7 )
		{
			BaseCode |= sreg ;
		}

	    Dest = EAtoAMN(Opcode, FALSE);
		if ( allow[Dest&0x0f] != '-' )
		{
			if ( OpcodeArray[ BaseCode ] == -2 )
			{
				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                TimingCycles += 70 ;

				if ( mode < 7 )
				{
                                        fprintf(fp, "\tmov   ebx,ecx\n");
                                        fprintf(fp, "\tand   ebx,7\n");
				}

                                fprintf(fp, "\tshr   ecx,9\n");
                                fprintf(fp, "\tand   ecx,7\n");

				EffectiveAddressRead(Dest,'W',EBX,EAX,"ABCDSDB",FALSE);

				if ( type == 0 )
                                        fprintf(fp, "\tmul   w [%s+ECX*4]\n",REG_DAT);
				else
                                        fprintf(fp, "\timul  w [%s+ECX*4]\n",REG_DAT);

                                fprintf(fp, "\tshl   edx,16\n");
                                fprintf(fp, "\tmov   dx,ax\n");
                                fprintf(fp, "\tmov   d [%s+ECX*4],edx\n",REG_DAT);
				SetFlags('L',EDX,TRUE,FALSE,FALSE);
				Completed();
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

/*
 * not
 * clr
 * neg
 * negx
 *
 */

void not(void)
{
	int	type,leng, mode, sreg ;
	int	Opcode, BaseCode ;
	int	Dest ;
	char Size=' ' ;
	char * Regname="" ;
	char * RegnameECX ;

	char allow[] = "0-2345678-------" ;

	for ( type = 0 ; type < 4 ; type++ )
	for ( leng = 0 ; leng < 3 ; leng++ )
	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0x4000 | (type<<9) | (leng<<6) | (mode<<3) | sreg ;
		BaseCode = Opcode & 0x46f8 ;
		if ( mode == 7 )
		{
			BaseCode |= sreg ;
		}

        Dest = EAtoAMN(Opcode, FALSE);

	    if ( allow[Dest&0x0f] != '-' )
	    {
            switch (leng)
    	    {
        	    case 0:
               	    Size = 'B';
                    Regname = regnamesshort[0];
                    RegnameECX = regnamesshort[ECX];
                    break;
                case 1:
                    Size = 'W';
                    Regname = regnamesword[0];
                    RegnameECX = regnamesword[ECX];
                    break;
                case 2:
                    Size = 'L';
                    Regname = regnameslong[0];
                    RegnameECX = regnameslong[ECX];
                    break;
            }

		    if ( OpcodeArray[ BaseCode ] == -2 )
		    {
			    Align();
                            fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                if (Size != 'L')
                    TimingCycles += 4;
                else
                    TimingCycles += 6;

                if (Dest < 7)
                                        fprintf(fp, "\tand   ecx,7\n");

                /* CLR does not need to read source */

                if (type != 1)
                {
				    EffectiveAddressRead(Dest,Size,ECX,EAX,"ABCDSDB",FALSE);
                }

			    switch ( type )
			    {
				    case 0: /* negx */
                                            fprintf(fp, "\tneg   %s\n",Regname ) ;
						CopyX();
                                            fprintf(fp, "\tsbb   %s,0\n", Regname ) ;
					    SetFlags(Size,EAX,FALSE,TRUE,TRUE);
					    break;

				    case 1: /* clr */
                                            fprintf(fp, "\txor   eax,eax\n") ;
				    	EffectiveAddressWrite(Dest,Size,ECX,TRUE,"----S-B",FALSE);
                                            fprintf(fp, "\tmov   edx,40H\n");
					    break;

				    case 2: /* neg */
                                            fprintf(fp, "\tneg   %s\n",Regname ) ;
					    SetFlags(Size,EAX,FALSE,TRUE,TRUE);
					    break;

				    case 3: /* not */
                                            fprintf(fp, "\txor   %s,-1\n",Regname ) ;
					    SetFlags(Size,EAX,FALSE,FALSE,TRUE);
					    break;
			    }

                /* Update (unless CLR command) */

                if (type != 1)
				    EffectiveAddressWrite(Dest,Size,ECX,FALSE,"---DS-B",FALSE);
			    Completed();
		    }

			OpcodeArray[Opcode] = BaseCode ;
        }
	}
}

/*
 * Move to/from USP
 *
 */

void moveusp(void)
{
	int Opcode, BaseCode ;
	int dir, sreg ;
	char * Label;

	for ( dir = 0 ; dir < 2 ; dir++)
	for ( sreg = 0 ; sreg < 8 ; sreg++)
	{
		Opcode = 0x4e60 | ( dir << 3 ) | sreg ;
		BaseCode = Opcode & 0x4e68 ;

		if ( OpcodeArray[BaseCode] == -2 )
		{
			Align();
			Label = GenerateLabel(BaseCode,0);
                        fprintf(fp, "%s:", Label );

            TimingCycles += 4;

                        fprintf(fp, "\ttest  b [%s],20h \t\t\t; Supervisor Mode ?\n",REG_SRH);
                        fprintf(fp, "\tjz    short OP_%4.4x_Trap\n",BaseCode);

                        fprintf(fp, "\tand   ecx,7\n");

			if ( dir == 0 ) /* reg 2 USP */
			{
                                fprintf(fp, "\tmov   eax,d [%s+ECX*4]\n",REG_ADD);
                                fprintf(fp, "\tmov   d [%s],eax\n",REG_USP);
			}
			else
			{
                                fprintf(fp, "\tmov   eax,d [%s]\n",REG_USP);
                                fprintf(fp, "\tmov   d [%s+ECX*4],eax\n",REG_ADD);
			}
		  	Completed();

			fprintf(fp, "OP_%4.4x_Trap:\n",BaseCode);
			Exception(8,BaseCode);
		}
		OpcodeArray[Opcode] = BaseCode ;
	}
}


/*
 * Check
 *
 */

void chk(void)
{
	int	dreg,mode,sreg ;
	int	Opcode, BaseCode ;
	int	Dest ;
	char  Size ;
	char * Label ;

	char  *allow = "0-23456789ab----" ;

	for ( dreg = 0 ; dreg < 8; dreg++ )
	for ( mode = 0 ; mode < 8; mode++ )
	for ( sreg = 0 ; sreg < 8; sreg++ )
	{
		Opcode = 0x4180 | (dreg<<9) | (mode<<3) | sreg ;
		BaseCode = Opcode & 0x41f8 ;

		if ( mode == 7 )
		{
			BaseCode |= sreg ;
		}

		Dest = EAtoAMN(Opcode, FALSE);

		if ( (OpcodeArray[BaseCode] == -2 ) && ( allow[Dest&0xf] != '-' ))
		{
			Align();
			Label = GenerateLabel(BaseCode,0);
                        fprintf(fp, "%s:\t", Label );

            TimingCycles += 10;

                        fprintf(fp, "\tmov   ebx,ecx\n");
                        fprintf(fp, "\tshr   ebx,9\n");
                        fprintf(fp, "\tand   ebx,7\n");

                        fprintf(fp, "\tmov   ebx,d [%s+EBX*4]\n",REG_DAT);
                        fprintf(fp, "\ttest  ebx,8000h\n"); /* is word bx < 0 */
                        fprintf(fp, "\tjnz   OP_%4.4x_Trap_minus\n",BaseCode);

			if (Dest < 7)
                                fprintf(fp, "\tand   ecx,7\n");

			EffectiveAddressRead(Dest,'W',ECX,EAX,"----S-B",FALSE);

                        fprintf(fp, "\tcmp   bx,ax\n");
                        fprintf(fp, "\tjg    OP_%4.4x_Trap_over\n",BaseCode);
			Completed();

            /* N is set if data less than zero */

			Align();
			fprintf(fp, "OP_%4.4x_Trap_minus:\n",BaseCode);
                        fprintf(fp, "\tor    dl,80h\n");             /* N flag = 80H */
			Exception(6,BaseCode);

            /* N is cleared if greated than compared number */

            Align();
			fprintf(fp, "OP_%4.4x_Trap_over:\n",BaseCode);
                        fprintf(fp, "\tand   dl,7Fh\n");             /* N flag = 80H */
			Exception(6,0x10000+BaseCode);

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

/*
 * Load Effective Address
 */

void LoadEffectiveAddress(void)
{
	int	Opcode, BaseCode ;
	int	sreg,mode,dreg ;
	int	Dest ;
	char allow[] = "--2--56789a-----" ;

	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( dreg = 0 ; dreg < 8 ; dreg++ )
	{
		Opcode = 0x41c0 | (sreg<<9) | (mode<<3) | dreg ;

		BaseCode = Opcode & 0x41f8 ;

		if ( mode == 7 )
			BaseCode = BaseCode | dreg ;

		Dest = EAtoAMN(BaseCode, FALSE);

		if ( allow[Dest&0x0f] != '-' )
		{
			if ( OpcodeArray[BaseCode] == -2 )
			{
				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                switch ( mode )
                {
                    case 2:
                        TimingCycles += 4;
                        break;
                    case 5:
                    case 7:
                    case 9:
                        TimingCycles += 8;
                        break;
                    case 6:
                    case 8:
                    case 10:
                        TimingCycles += 12;
                        break;
                }

				if ( mode < 7 )
				{
                                        fprintf(fp, "\tmov   ebx,ecx\n");
                                        fprintf(fp, "\tand   ebx,7\n");
				}

                                fprintf(fp, "\tshr   ecx,9\n");
                                fprintf(fp, "\tand   ecx,7\n");

				EffectiveAddressCalculate(Dest,'L',EBX,TRUE);
                                fprintf(fp, "\tmov   d [%s+ECX*4],edi\n",REG_ADD);
				Completed();
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

/*
 * Negate BCD
 *
 */

void nbcd(void)
{
	int	Opcode, BaseCode ;
	int	sreg,mode,Dest ;
	char allow[] = "0-23456789ab----" ;

	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
		{
		Opcode = 0x4800 | (mode<<3) | sreg ;
		BaseCode = Opcode & 0x4838 ;

		if ( mode == 7 )
			BaseCode |= sreg ;

		Dest = EAtoAMN(BaseCode, FALSE);

		if ( allow[Dest&0xf] != '-' )
		{
			if ( OpcodeArray[BaseCode] == -2 )
			{
				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                if (mode < 2)
                    TimingCycles += 6;
                else
                    TimingCycles += 8;

                                fprintf(fp, "\tand   ecx,7\n");

  				EffectiveAddressRead(Dest,'B',ECX,EBX,"--C-S-B",FALSE);

                                fprintf(fp, "\txor   eax,eax\n");
	   	        CopyX();

                                fprintf(fp, "\tsbb   al,bl\n");
                                fprintf(fp, "\tdas\n");

				SetFlags('B',EAX,FALSE,TRUE,TRUE);

	  			EffectiveAddressWrite(Dest,'B',ECX,EAX,"----S-B",FALSE);
				Completed();
			}
			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

void tas(void)
{
	int	Opcode, BaseCode ;
	int	sreg,mode,Dest ;
	char allow[] = "0-2345678-------" ;

	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0x4ac0 | (mode<<3) | sreg ;
		BaseCode = Opcode & 0x4af8 ;

		if ( mode == 7 )
			BaseCode |= sreg ;

		Dest = EAtoAMN(BaseCode, FALSE);

		if ( allow[Dest&0xf] != '-' )
		{
			if ( OpcodeArray[BaseCode] == -2 )
			{
				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                if (mode < 2)
                    TimingCycles += 4;
                else
                    TimingCycles += 14;

                                fprintf(fp, "\tand   ecx,7\n");

  				EffectiveAddressRead(Dest,'B',ECX,EAX,"--C-S-B",FALSE);

				SetFlags('B',EAX,TRUE,TRUE,TRUE);
                                fprintf(fp, "\tor    al,128\n");

	  			EffectiveAddressWrite(Dest,'B',ECX,EAX,"----S-B",FALSE);
				Completed();
			}
			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}


/*
 * BFEXTU (dummy)
 */

void bfextu(void)
{
	int	Opcode, BaseCode ;
	int	sreg,mode,Dest ;
        char allow[] = "0-2--56789a-----" ;

	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
                Opcode = 0xE9C0 | (mode<<3) | sreg ;
                BaseCode = Opcode & 0xE9F8 ;

		if ( mode == 7 )
			BaseCode |= sreg ;

		Dest = EAtoAMN(BaseCode, FALSE);

		if ( allow[Dest&0xf] != '-' )
		{
			if ( OpcodeArray[BaseCode] == -2 )
			{
				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));
                                fprintf(fp, "\tmov   bx,w [esi+ebp]\n");
                                fprintf(fp, "\tadd   esi,2\n");
  				EffectiveAddressRead(Dest,'B',ECX,EAX,"--C-S-B",FALSE);
				Completed();
			}
			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

/*
 * push Effective Address
 */

void PushEffectiveAddress(void)
{
	int	Opcode, BaseCode ;
	int	sreg,mode,dreg ;
	int	Dest ;
	char allow[] = "--2--56789a-----" ;

	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( dreg = 0 ; dreg < 8 ; dreg++ )
	{
		Opcode = 0x4840 | (mode<<3) | dreg ;

		BaseCode = Opcode & 0x4878 ;

		if ( mode == 7 )
			BaseCode = BaseCode | dreg ;

		Dest = EAtoAMN(BaseCode, FALSE);

		if ( allow[Dest&0x0f] != '-' )
		{
			if ( OpcodeArray[BaseCode] == -2 )
			{
				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                switch ( mode )
                {
                    case 2:
                        TimingCycles += 12;
                        break;
                    case 5:
                    case 7:
                    case 9:
                        TimingCycles += 16;
                        break;
                    case 6:
                    case 8:
                    case 10:
                        TimingCycles += 20;
                        break;
                }

				if ( mode < 7 )
				{
                                        fprintf(fp, "\tand   ecx,7\n");
				}

				EffectiveAddressCalculate(Dest,'L',ECX,TRUE);

                                fprintf(fp, "\tmov   eax,edi\n");
                                fprintf(fp, "\tmov   edi,d [%s]\t ; Push onto Stack\n",REG_A7);
                                fprintf(fp, "\tsub   edi,4\n");
                                fprintf(fp, "\tmov   d [%s],edi\n",REG_A7);
                                Memory_Write('L',EDI,EAX,"---DS-B",2);
				Completed();
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

/*
 * Test
 *
 */

void tst(void)
{
	int	leng, mode, sreg ;
	int	Opcode, BaseCode ;
	int	Dest ;
	char Size=' ' ;
	char * Regname ;
	char * RegnameECX ;

        char allow[] = "0123456789ab----" ;

	for ( leng = 0 ; leng < 3 ; leng++ )
	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0x4a00 | (leng<<6) | (mode<<3) | sreg ;
		BaseCode = Opcode & 0x4af8 ;
		if ( mode == 7 )
		{
			BaseCode |= sreg ;
		}

		Dest = EAtoAMN(BaseCode, FALSE);

                if ( (allow[Dest&0x0f] != '-') )
                {
            switch (leng)
    	    {
        	    case 0:
               	    Size = 'B';
                    Regname = regnamesshort[0];
                    RegnameECX = regnamesshort[ECX];
                    break;
                case 1:
                    Size = 'W';
                    Regname = regnamesword[0];
                    RegnameECX = regnamesword[ECX];
                    break;
                case 2:
                    Size = 'L';
                    Regname = regnameslong[0];
                    RegnameECX = regnameslong[ECX];
                    break;
            }


                    if ( OpcodeArray[ BaseCode ] == -2 )
		    {
			   	Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                TimingCycles += 4;

                if (Dest < 7)
                                    fprintf(fp, "\tand   ecx,7\n");

			   	EffectiveAddressRead(Dest,Size,ECX,EAX,"----S-B",FALSE);

                /* Should X be changed - C Does Not */

				SetFlags(Size,EAX,TRUE,FALSE,FALSE);
	    		Completed();
    		}

			OpcodeArray[Opcode] = BaseCode ;
            }
	}
}

/*
 * Move registers too / from memory
 *
 */

void movem_reg_ea(void)
{
	int	leng,mode,sreg ;
	int	Opcode, BaseCode ;
	int	Dest ;
	char  Size ;
	char * Label ;

	char *allow = "--2-45678-------" ;

	for ( leng = 0 ; leng < 2; leng++ )
	for ( mode = 0 ; mode < 8; mode++ )
	for ( sreg = 0 ; sreg < 8; sreg++ )
	{
		Opcode = 0x4880 | ( leng<<6) | (mode<<3) | sreg ;
		BaseCode = Opcode & 0x4cf8 ;

		if ( mode == 7 )
		{
			BaseCode |= sreg ;
		}

		Dest = EAtoAMN(Opcode, FALSE);

		Size = "WL"[leng] ;

		if ( allow[Dest&0xf] != '-' )
		{
			if ( OpcodeArray[BaseCode] == - 2)
			{
				Align();
				Label = GenerateLabel(BaseCode,0);

                switch (mode)
                {
                    case 2:
                    case 4:
                        TimingCycles += 8 ;
                        break;
                    case 5:
                    case 7:
                        TimingCycles += 12 ;
                        break;
                    case 6:
                    case 8:
                        TimingCycles += 14 ;
                        break;
                }

                                fprintf(fp, "%s:\t",Label ) ;

                                fprintf(fp, "\tpush edx\n");

				Memory_Fetch('W',EDX,FALSE);
                                fprintf(fp, "\tadd   esi,2\n");

				if ( mode < 7 )
				{
                                        fprintf(fp, "\tand   ecx,7\n");
				}

				if ( mode == 4 )
                {
                                        fprintf(fp, "\tpush  ecx\n");
                                        fprintf(fp, "\tmov   edi,d [%s+ECX*4]\n",REG_ADD);
                }
				else
					EffectiveAddressCalculate(Dest,'L',ECX,TRUE);

                                fprintf(fp, "\tmov   ebx,1\n");

				/* predecrement uses d0-d7..a0-a7  a7 first*/
				/* other modes use   a7-a0..d7-d0  d0 first*/

				if ( Dest != 4 )
                                        fprintf(fp, "\tmov   ecx,4h\n");
				else
                                        fprintf(fp, "\tmov   ecx,40h\n");

				fprintf(fp, "OP_%4.4x_Again:\n",BaseCode);
                                fprintf(fp, "\ttest  edx,ebx\n");
                                fprintf(fp, "\tje    OP_%4.4x_Skip\n",BaseCode);

                                fprintf(fp, "\tmov   eax,d [%s+ecx]\n",ICOUNT);        /* load eax with current reg data */

				if ( Dest == 4 )
				{
					if ( Size == 'W' )						/* adjust pointer before write */
                                                fprintf(fp, "\tsub   edi,2\n");
					else
                                                fprintf(fp, "\tsub   edi,4\n");
				}

				Memory_Write(Size,EDI,EAX,"-BCDSDB",1);

				if ( Dest != 4 )
				{
					if ( Size == 'W' )					/* adjust pointer after write */
                                                fprintf(fp, "\tadd   edi,2\n");
					else
                                                fprintf(fp, "\tadd   edi,4\n");
				}

                /* Update Cycle Count */

//                                if ( Size == 'W' )
//                                       fprintf(fp, "\tsub   d [%s],4\n",ICOUNT);
//                                else
//                                        fprintf(fp, "\tsub   d [%s],8\n",ICOUNT);
//
				fprintf(fp, "OP_%4.4x_Skip:\n",BaseCode);

				if ( Dest != 4 )
                                        fprintf(fp, "\tadd   ecx,4h\n");
				else
                                        fprintf(fp, "\tsub   ecx,4h\n");

                                fprintf(fp, "\tshl   ebx,1\n");
                                fprintf(fp, "\tor    bx,bx\n");                      /* check low 16 bits */
                                fprintf(fp, "\tjnz   OP_%4.4x_Again\n",BaseCode);

				if ( Dest == 4 )
				{
                                        fprintf(fp, "\tpop   ecx\n");
                                        fprintf(fp, "\tmov   d [%s+ECX*4],edi\n",REG_ADD);
				}

                                fprintf(fp, "\tpop   edx\n");
				Completed();
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

void movem_ea_reg(void)
{
	int	leng,mode,sreg ;
	int	Opcode, BaseCode ;
	int	Dest ;
	char  Size ;
	char * Label ;

	char  *allow = "--23-56789a-----" ;

	for ( leng = 0 ; leng < 2; leng++ )
	for ( mode = 0 ; mode < 8; mode++ )
	for ( sreg = 0 ; sreg < 8; sreg++ )
	{
		Opcode = 0x4c80 | ( leng<<6) | (mode<<3) | sreg ;
		BaseCode = Opcode & 0x4cf8 ;

		if ( mode == 7 )
		{
			BaseCode |= sreg ;
		}

		Dest = EAtoAMN(Opcode, FALSE);

		Size = "WL"[leng] ;

		if (  allow[Dest&0xf] != '-' )
		{
			if ( OpcodeArray[BaseCode] == - 2 )
			{
				Align();
				Label = GenerateLabel(BaseCode,0);

                                fprintf(fp, "%s:\t",Label ) ;

                switch (mode)
                {
                    case 2:
                    case 4:
                        TimingCycles += 8 ;
                        break;
                    case 5:
                    case 7:
                        TimingCycles += 12 ;
                        break;
                    case 6:
                    case 8:
                        TimingCycles += 14 ;
                        break;
                }

                                fprintf(fp, "\tpush  edx\n");                                /* save edx because sr is unaffected */

				Memory_Fetch('W',EDX,FALSE);
                                fprintf(fp, "\tadd   esi,2\n");

				if ( mode < 7 )
				{
                                        fprintf(fp, "\tand   ecx,7\n");
				}

				if ( mode == 3 )
                                        fprintf(fp, "\tpush   ecx\n");                       /* if (An)+ then it needed later */

				EffectiveAddressCalculate(Dest,'L',ECX,TRUE);

                                fprintf(fp, "\tmov   ebx,1\n");                              /* setup register list mask */

				/* predecrement uses d0-d7..a0-a7  a7 first*/
				/* other modes use   a7-a0..d7-d0  d0 first*/

                                fprintf(fp, "\tmov   ecx,4h\n");                             /* always start with D0 */

				fprintf(fp, "OP_%4.4x_Again:\n",BaseCode);
                                fprintf(fp, "\ttest  edx,ebx\n");                    /* is bit set for this register? */
                                fprintf(fp, "\tje    OP_%4.4x_Skip\n",BaseCode);

				Memory_Read(Size,EDI,"-BCDSDB",1);

				if ( Size == 'W' )
                                        fprintf(fp, "\tcwde\n");                             /* word size must be sign extended */

                                fprintf(fp, "\tmov   d [%s+ecx],eax\n",ICOUNT);                /* load current reg with eax */

				if ( Size == 'W' )						/* adjust pointer after write */
                                        fprintf(fp, "\tadd   edi,2\n");
				else
                                        fprintf(fp, "\tadd   edi,4\n");

                /* Update Cycle Count */

//                                if ( Size == 'W' )
//                                        fprintf(fp, "\tsub   d [%s],4\n",ICOUNT);
//                                else
//                                        fprintf(fp, "\tsub   d [%s],8\n",ICOUNT);

				fprintf(fp, "OP_%4.4x_Skip:\n",BaseCode);
                                fprintf(fp, "\tadd   ecx,4\n");                 /* adjust pointer to next reg */
                                fprintf(fp, "\tshl   ebx,1\n");
                                fprintf(fp, "\tor    bx,bx\n");                              /* check low 16 bits */
                                fprintf(fp, "\tjnz   OP_%4.4x_Again\n",BaseCode);

				if ( mode == 3 )
				{
                                        fprintf(fp, "\tpop   ecx\n");
                                        fprintf(fp, "\tmov   d [%s+ECX*4],edi\n",REG_ADD);     /* reset Ax if mode = (Ax)+ */
				}

                                fprintf(fp, "\tpop   edx\n");                                /* restore flags */
				Completed();
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

/*
 * Link / Unlink
 *
 * Local stack space
 *
 */

void link(void)
{
	int	sreg ;
	int	Opcode, BaseCode ;

	for ( sreg = 0 ; sreg < 8; sreg++ )
	{
		Opcode = 0x4e50 | sreg ;
		BaseCode = 0x4e50 ;

		if ( OpcodeArray[BaseCode] == - 2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            TimingCycles += 16;

                        fprintf(fp, "\tsub   d [%s],4\n",REG_A7);

                        fprintf(fp, "\tand   ecx,7\n");
                        fprintf(fp, "\tmov   eax,d [%s+ECX*4]\n",REG_ADD);
                        fprintf(fp, "\tmov   edi,d [%s]\n",REG_A7);
                        fprintf(fp, "\tmov   d [%s+ECX*4],edi\n",REG_ADD);

			Memory_Write('L',EDI,EAX,"---DS-B",1);

			Memory_Fetch('W',EAX,TRUE);
                        fprintf(fp, "\tadd   esi,2\n");
                        fprintf(fp, "\tadd   d [%s],eax\n",REG_A7);

			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}
}

void unlinkasm(void)
{
	int	sreg ;
	int	Opcode, BaseCode ;

	for ( sreg = 0 ; sreg < 8; sreg++ )
		{
		Opcode = 0x4e58 | sreg ;
		BaseCode = 0x4e58 ;

		if ( OpcodeArray[BaseCode] == - 2 )
			{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            TimingCycles += 12;

                        fprintf(fp, "\tmov   ebx,ecx\n");
                        fprintf(fp, "\tand   ebx,7\n");
                        fprintf(fp, "\tmov   edi,d [%s+EBX*4]\n",REG_ADD);

			Memory_Read('L',EDI,"-B-DSDB",1);

                        fprintf(fp, "\tmov   d [%s+EBX*4],eax\n",REG_ADD);
            fprintf(fp, "\tadd   edi,4\n");
                        fprintf(fp, "\tmov   d [%s],EDI\n",REG_A7);
			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}
}

void trap(void)
{
	int Count;
   	int BaseCode = 0x4E40;

	if ( OpcodeArray[BaseCode] == -2 )
	{

        fprintf(fp, "\t\tEXTRN GemDos,Bios,Xbios,VDI_AES\n");
        fprintf(fp, "\t\tPUBLIC trapcont,trapend\n");

		Align();
                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

        fprintf(fp, "\tmov   eax,ecx\n");
        fprintf(fp, "\tand   eax,15\n");
        fprintf(fp, "\tcmp   eax,1\t\t;GemDos\n");
        fprintf(fp, "\tjz    trap1\n");
        fprintf(fp, "\tcmp   eax,13\t\t;Bios\n");
        fprintf(fp, "\tjz    trap13\n");
        fprintf(fp, "\tcmp   eax,14\t\t;XBios\n");
        fprintf(fp, "\tjz    trap14\n");
        fprintf(fp, "\tcmp   eax,2\t\t;VDI/AES\n");
        fprintf(fp, "\tjz    trap2\n");
 fprintf(fp, "trapcont:\n");
        fprintf(fp, "\tor    eax,32\n");
        Exception(-1,BaseCode);
 fprintf(fp, "trapend:\n");
        Completed();
 fprintf(fp, "trap1:\t\tlea\tebx,GemDos\n");
        fprintf(fp, "\tjmp   ebx\n");
 fprintf(fp, "trap13:\t\tlea\tebx,Bios\n");
        fprintf(fp, "\tjmp   ebx\n");
 fprintf(fp, "trap14:\t\tlea\tebx,Xbios\n");
        fprintf(fp, "\tjmp   ebx\n");
 fprintf(fp, "trap2:\t\tlea\tebx,VDI_AES\n");
        fprintf(fp, "\tjmp   ebx\n");



	}

    for (Count=0;Count<=15;Count++)
	    OpcodeArray[BaseCode+Count] = BaseCode;
}

void reset(void)
{
	int Count;
   	int BaseCode = 0x4E70;
	char * Label;

	if ( OpcodeArray[BaseCode] == -2 )
	{
		Align();
		Label = GenerateLabel(BaseCode,0);

        TimingCycles += 132;

                fprintf(fp, "%s:\t", Label );
                fprintf(fp, "\ttest  b [%s],20h \t\t\t; Supervisor Mode ?\n",REG_SRH);
                fprintf(fp, "\tjnz   OP_%4.4x_NOP\n",BaseCode);
		Exception(8,BaseCode);

		fprintf(fp, "OP_%4.4x_NOP:\n",BaseCode);
	  	Completed();
	}
	OpcodeArray[BaseCode] = BaseCode ;
}

void nop(void)
{
	int	BaseCode = 0x4e71 ;

	if ( OpcodeArray[BaseCode] == -2 )
	{
		Align();
                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

        TimingCycles += 4;

		Completed();
		OpcodeArray[BaseCode] = BaseCode ;
	}
}

void stop(void)
{
	char *Label;
	char TrueLabel[16];
	int	 BaseCode = 0x4e72 ;

	if ( OpcodeArray[BaseCode] == -2 )
	{
		Align();
                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

        TimingCycles += 4;

	    /* Must be in Supervisor Mode */

	    sprintf(TrueLabel,GenerateLabel(0,1));

                fprintf(fp, "\ttest  b [%s],20h \t\t\t; Supervisor Mode ?\n",REG_SRH);
                fprintf(fp, "\tje    %s\n\n",TrueLabel);

        /* Next WORD is new SR */

		Memory_Fetch('W',EAX,FALSE);
        fprintf(fp, "\tadd   esi,2\n");

        WriteCCR('W');

        /* See if Valid interrupt waiting */

		CheckInterrupt = 0;

    fprintf(fp, "\tmov   al,b [%s]\n",REG_IRQ);
    fprintf(fp, "\tmov   ebx,d [%s]\t\t; int mask\n",REG_SRH);
    fprintf(fp, "\tand   ebx,07H\n");
    fprintf(fp, "\ttest  b [IRQmask],al\t\t; MASK IRQ\n");
    fprintf(fp, "\tjne   procint\t\t; Quick Leave\n\n");

        /* No int waiting - clear count, set stop */

        fprintf(fp, "\txor   ecx,ecx\n");
        fprintf(fp, "\tmov   d [%s],ecx\n",ICOUNT);
        fprintf(fp, "\tor    b [%s],80h\n",REG_IRQ);
		Completed();

        /* User Mode - Exception */

        Align();
        fprintf(fp, "%s:\t",TrueLabel);
        Exception(8,BaseCode);

		OpcodeArray[BaseCode] = BaseCode ;
	}
}

void ReturnFromException(void)
{
	char TrueLabel[16];

    int BaseCode = 0x4e73;

  	Align();
        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

    TimingCycles += 20;

    /* Check in Supervisor Mode */

    sprintf(TrueLabel,GenerateLabel(0,1));
    fprintf(fp, "\ttest  b [%s],20h \t\t\t; Supervisor Mode ?\n",REG_SRH);
        fprintf(fp, "\tje    %s\n\n",TrueLabel);

    /* Get SR - Save in EBX */

    fprintf(fp, "\tmov   edi,d [%s]\n",REG_A7);
    fprintf(fp, "\tadd   d [%s],8\n",REG_A7);

    Memory_Read('W',EDI,"-----DB",2);
    fprintf(fp, "\tadd   edi,2\n");
    fprintf(fp, "\tmov   esi,eax\n");
    fprintf(fp, "\tand   esi,0ffffffh\n");

    /* Get PC */

    Memory_Read('L',EDI,"----S-B",0);
    fprintf(fp, "\tand   eax,0ffffffh\n");
    fprintf(fp, "\txchg  esi,eax\n");

    /* Update CCR (and A7) */

	WriteCCR('W');

    Completed();

        fprintf(fp, "%s:\t",TrueLabel);
    Exception(8,0x10000+BaseCode);

    OpcodeArray[BaseCode] = BaseCode;
}

void trapv(void)
{
	int Count;
   	int BaseCode = 0x4E76;
	char * Label;

	if ( OpcodeArray[BaseCode] == -2 )
	{
		Align();
		Label = GenerateLabel(BaseCode,0);
                fprintf(fp, "%s:", Label );

        TimingCycles += 4;

        fprintf(fp, "\ttest  edx,0800h\n");
        fprintf(fp, "\tjz    OP_%4.4x_Clear\n",BaseCode);
		Exception(7,BaseCode);

		fprintf(fp, "OP_%4.4x_Clear:\n",BaseCode);
	  	Completed();
	}
	OpcodeArray[BaseCode] = BaseCode ;

}
        
void illegal_opcode(void)
{
	Align();
	fprintf(fp, "ILLEGAL:\n");
//        fprintf(fp, "\tmov   d [%s],-256\n",ICOUNT);
        fprintf(fp, "\tjmp   MainExit\n");

    Exception(4,0xFFFE);
}

/*
 * Return from subroutine
 * restoring flags as well
 *
 */

void ReturnandRestore(void)
{
	char TrueLabel[16];

    int BaseCode = 0x4e77;

  	Align();
        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

    TimingCycles += 20;

    /* Get SR into ESI */

    fprintf(fp, "\tmov   edi,d [%s]\n",REG_A7);
    fprintf(fp, "\tadd   d [%s],6\n",REG_A7);

    Memory_Read('W',EDI,"-----DB",2);
    fprintf(fp, "\tadd   edi,2\n");
    fprintf(fp, "\tmov   esi,eax\n");
        fprintf(fp, "\tand   esi,0ffffffh\n");

    /* Get PC */

    Memory_Read('L',EDI,"----SDB",0);
    fprintf(fp, "\txchg   esi,eax\n");
        fprintf(fp, "\tand   esi,0ffffffh\n");

    /* Update flags */

	WriteCCR('B');

    Completed();

    OpcodeArray[BaseCode] = BaseCode;
}

/*
 * Return from Subroutine
 *
 */

void rts(void)
{
	int	BaseCode = 0x4e75 ;

	if ( OpcodeArray[BaseCode] == -2 )
	{
		Align();
                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

        TimingCycles += 16;

		/* Previous PC (Indy & Temple of Doom need this) */

        fprintf(fp, "\tsub   esi,2\n");
            fprintf(fp, "\tmov   d [R_PPC],esi\n");

		OpcodeArray[BaseCode] = BaseCode ;

                fprintf(fp, "\tmov   edi,d [%s]\n",REG_A7);
                fprintf(fp, "\tadd   d [%s],4\n",REG_A7);
                Memory_Read('L',EDI,"---D--B",1);
                fprintf(fp, "\tmov   esi,eax\n");
        fprintf(fp, "\tand   esi,0ffffffh\n");
		Completed();
	}
}

void jmp_jsr(void)
{
	int	Opcode, BaseCode ;
	int	dreg,mode,type ;
	int	Dest ;
	char allow[] = "--2--56789a-----" ;

	for ( type = 0 ; type < 2 ; type++ )
	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( dreg = 0 ; dreg < 8 ; dreg++ )
	{
		Opcode = 0x4e80 | (type<<6) | (mode<<3) | dreg ;
		BaseCode = Opcode & 0x4ef8 ;
		if ( mode == 7 )
			BaseCode = BaseCode | dreg ;

		Dest = EAtoAMN(BaseCode, FALSE);
		if ( allow[Dest&0x0f] != '-' )
		{
			if ( OpcodeArray[BaseCode] == -2 )
			{
				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                switch ( mode )
                {
                    case 2:
                        TimingCycles += 8;
                        break;
                    case 5:
                    case 7:
                    case 9:
                        TimingCycles += 10;
                        break;
                    case 8:
                        TimingCycles += 12;
                        break;
                    case 6:
                    case 10:
                        TimingCycles += 14;
                        break;
                }

                if ( type == 0 ) /* jsr takes 8 more than jmp */
                    TimingCycles += 8;

				if ( mode < 7 )
				{
                                        fprintf(fp, "\tand   ecx,7\n");
				}
				EffectiveAddressCalculate(Dest,'L',ECX,TRUE);

				if ( type == 0 ) /* jsr needs to push PC onto stack */
				{
                                   fprintf(fp, "\tmov   eax,esi\t\t; Old PC\n");
                                   fprintf(fp, "\tmov   ebx,edi\n");
                                   fprintf(fp, "\tmov   edi,d [%s]\t ; Push onto Stack\n",REG_A7);
                                   fprintf(fp, "\tsub   edi,4\n");
                                   fprintf(fp, "\tmov   esi,ebx\t\t; New PC\n");
                                   fprintf(fp, "\tand   esi,0ffffffh\n");
                                   fprintf(fp, "\tmov   d [%s],edi\n",REG_A7);
                                   Memory_Write('L',EDI,EAX,"---DS-B",1);
				}
                else
                {
                                        fprintf(fp, "\tmov   esi,edi\n");
                                        fprintf(fp, "\tand   esi,0ffffffh\n");
                }

				Completed();
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

void cmpm(void)
{
	int	Opcode, BaseCode ;
	int	regx,leng,regy ;
	char Size=' ' ;
	char * Regname="" ;
	char * RegnameEBX="" ;

	for ( regx = 0 ; regx < 8 ; regx++ )
	for ( leng = 0 ; leng < 3 ; leng++ )
	for ( regy = 0 ; regy < 8 ; regy++ )
	{
		Opcode = 0xb108 | (regx<<9) | (leng<<6) | regy ;
		BaseCode = Opcode & 0xb1c8 ;
      	switch (leng)
    	{
            case 0:
               	Size = 'B';
                Regname = regnamesshort[EAX];
                RegnameEBX = regnamesshort[EBX];
                break;
            case 1:
                Size = 'W';
                Regname = regnamesword[EAX];
                RegnameEBX = regnamesword[EBX];
                break;
            case 2:
                Size = 'L';
                Regname = regnameslong[EAX];
                RegnameEBX = regnameslong[EBX];
                break;
        }

		if ( OpcodeArray[BaseCode] == -2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            AddEACycles = 0 ;

            if ( Size != 'L' )
                TimingCycles += 12 ;
            else
                TimingCycles += 20 ;

                        fprintf(fp, "\tmov   ebx,ecx\n");
                        fprintf(fp, "\tand   ebx,7\n");
                        fprintf(fp, "\tshr   ecx,9\n");
                        fprintf(fp, "\tand   ecx,7\n");

			EffectiveAddressRead(3,Size,EBX,EBX,"--C-S-B",FALSE);
			EffectiveAddressRead(3,Size,ECX,EAX,"-B--S-B",FALSE);

                        fprintf(fp, "\tcmp   %s,%s\n",Regname,RegnameEBX);
			SetFlags(Size,EAX,FALSE,FALSE,FALSE);
			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}
}

void exg(void)
{
	int	Opcode, BaseCode ;
	int	regx,type,regy ;
	int	opmask[3] = { 0x08, 0x09, 0x11 } ;

	for ( regx = 0 ; regx < 8 ; regx++ )
	for ( type = 0 ; type < 3 ; type++ )
	for ( regy = 0 ; regy < 8 ; regy++ )
	{
	    Opcode = 0xc100 | (regx<<9) | (opmask[type]<<3) | regy ;
	    BaseCode = Opcode & 0xc1c8 ;

	    if ( OpcodeArray[BaseCode] == -2 )
	    {
		    Align();
                    fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            TimingCycles += 6 ;

                    fprintf(fp, "\tmov   ebx,ecx\n");
                    fprintf(fp, "\tand   ebx,7\n");
                    fprintf(fp, "\tshr   ecx,9\n");
                    fprintf(fp, "\tand   ecx,7\n");

		    if ( type == 0 )
		    {
                            fprintf(fp, "\tmov   eax,d [%s+ECX*4]\n",REG_DAT);
                            fprintf(fp, "\tmov   edi,d [%s+EBX*4]\n",REG_DAT);
                            fprintf(fp, "\tmov   d [%s+ECX*4],edi\n",REG_DAT);
                            fprintf(fp, "\tmov   d [%s+EBX*4],eax\n",REG_DAT);
		    }
		    if ( type == 1 )
		    {
                            fprintf(fp, "\tmov   eax,d [%s+ECX*4]\n",REG_ADD);
                            fprintf(fp, "\tmov   edi,d [%s+EBX*4]\n",REG_ADD);
                            fprintf(fp, "\tmov   d [%s+ECX*4],edi\n",REG_ADD);
                            fprintf(fp, "\tmov   d [%s+EBX*4],eax\n",REG_ADD);
		    }
		    if ( type == 2 )
		    {
                            fprintf(fp, "\tmov   eax,d [%s+ECX*4]\n",REG_DAT);
                            fprintf(fp, "\tmov   edi,d [%s+EBX*4]\n",REG_ADD);
                            fprintf(fp, "\tmov   d [%s+ECX*4],edi\n",REG_DAT);
                            fprintf(fp, "\tmov   d [%s+EBX*4],eax\n",REG_ADD);
		    }

		    Completed();
	    }

	    OpcodeArray[Opcode] = BaseCode ;
	}
}

void ext(void)
{
	int	Opcode, BaseCode ;
	int	type,regy ;

	for ( type = 2 ; type < 4 ; type++ )
	for ( regy = 0 ; regy < 8 ; regy++ )
	{
		Opcode = 0x4800 | (type<<6) | regy ;
		BaseCode = Opcode & 0x48c0 ;

		if ( OpcodeArray[BaseCode] == -2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            TimingCycles += 4 ;

                        fprintf(fp, "\tand   ecx,7\n");

                        if ( type == 2 ) /* b to word */
			{
                                fprintf(fp, "\tmovsx eax,b [%s+ECX*4]\n",REG_DAT);
                                fprintf(fp, "\tmov   w [%s+ECX*4],ax\n",REG_DAT);
				SetFlags('W',EAX,TRUE,FALSE,FALSE);
			}
			if ( type == 3 ) /* word to long */
			{
                                fprintf(fp, "\tmovsx eax,w [%s+ECX*4]\n",REG_DAT);
                                fprintf(fp, "\tmov   d [%s+ECX*4],eax\n",REG_DAT);
				SetFlags('L',EAX,TRUE,FALSE,FALSE);
			}
			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}

	for ( regy = 0 ; regy < 8 ; regy++ )
	{
                Opcode = 0x49c0 | regy ;
                BaseCode = Opcode & 0x49c0 ;

		if ( OpcodeArray[BaseCode] == -2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            TimingCycles += 4 ;

                        fprintf(fp, "\tand   ecx,7\n");

                        /* b to long */
                        fprintf(fp, "\tmovsx eax,b [%s+ECX*4]\n",REG_DAT);
                        fprintf(fp, "\tmov   d [%s+ECX*4],eax\n",REG_DAT);
                        SetFlags('L',EAX,TRUE,FALSE,FALSE);
			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}

}

void swap(void)
{
	int	Opcode, BaseCode ;
	int	sreg ;

	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0x4840 | sreg ;
		BaseCode = Opcode & 0x4840;

		if ( OpcodeArray[BaseCode] == -2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            TimingCycles += 4 ;

                        fprintf(fp, "\tand   ecx,7\n");
                        fprintf(fp, "\tror   d [%s+ECX*4],16\n",REG_DAT);
                        fprintf(fp, "\tor    d [%s+ECX*4],0\n",REG_DAT);
			SetFlags('L',EAX,FALSE,FALSE,FALSE);
			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}
}

/*
 * Line A and Line F commands
 *
 */

void LineA(void)
{
	int Count;

	/* Line A */

	Align();
        fprintf(fp, "%s:\t",GenerateLabel(0xA000,0));
	Exception(0x0A,0xA000);

    for (Count=0xA000;Count<0xB000;Count++)
    {
        OpcodeArray[Count] = 0xA000;
    }
}

//****************************************************************
// MOVEC
//
void movec(void)
{
	Align();
        fprintf(fp, "%s:\t",GenerateLabel(0x4E7A,0));
        fprintf(fp, "\txor   eax,eax\n");
        fprintf(fp, "\tmov   AX,w [esi+ebp]\n");
        fprintf(fp, "\tadd   esi,2\n");
        fprintf(fp, "\tmov   ecx,eax\n");
        fprintf(fp, "\tshr   ecx,12\n");

        fprintf(fp, "\tmov   ebx,eax\n");
        fprintf(fp, "\tshr   ebx,8\n");
        fprintf(fp, "\tor    eax,ebx\n");
        fprintf(fp, "\tand   eax,0fh\n");
        fprintf(fp, "\tmov   edx,d [R_Control+eax*4]\n");
        fprintf(fp, "\tmov   d [R_D0+ECX*4],edx\n");

        TimingCycles += 8;
        Completed();

	Align();
        fprintf(fp, "%s:\t",GenerateLabel(0x4E7B,0));
        fprintf(fp, "\txor   eax,eax\n");
        fprintf(fp, "\tmov   AX,w [esi+ebp]\n");
        fprintf(fp, "\tadd   esi,2\n");
        fprintf(fp, "\tmov   ecx,eax\n");
        fprintf(fp, "\tshr   ecx,12\n");
        fprintf(fp, "\tmov   edx,d [R_D0+ECX*4]\n");
        fprintf(fp, "\tmov   ebx,eax\n");
        fprintf(fp, "\tshr   ebx,8\n");
        fprintf(fp, "\tor    eax,ebx\n");
        fprintf(fp, "\tand   eax,0fh\n");
        fprintf(fp, "\tmov   d [R_Control+eax*4],edx\n");
        TimingCycles += 8;
        Completed();

        OpcodeArray[0x4E7A] = 0x4E7A;
        OpcodeArray[0x4E7B] = 0x4E7B;
}



void LineF(void)
{
	int Count;

    /* Line F */
	Align();
        fprintf(fp, "%s:\t",GenerateLabel(0xF039,0));
        fprintf(fp, "\tadd   esi,6\n");
    TimingCycles += 12;
        Completed();
        OpcodeArray[0xF039] = 0xF039;


	Align();
        fprintf(fp, "%s:\t",GenerateLabel(0xF100,0));
        Exception(0x0B,0xF100);

    for (Count=0xF100;Count<0x10000;Count++)
    {
        OpcodeArray[Count] = 0xF100;
    }
}

/*
 * Moves To/From CCR and SR
 *
 * (Move from CCR is 68010 command)
 *
 */

void movesr(void)
{
	int Opcode, BaseCode ;
	int type, mode, sreg ;
	int Dest ;
	char allow[] = "0-2345678-------" ;
    char Size;
	char *Label;

	for ( type = 0 ; type < 4 ; type++ )
	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0x40c0 | (type << 9) | ( mode << 3 ) | sreg ;

        /* To has extra modes */

		if ( type > 1 )
		{
			allow[0x9] = '9';
			allow[0xa] = 'a';
			allow[0xb] = 'b' ;
		}

        if ((type == 0) | (type == 3))
        	Size = 'W'; /* SR */
        else
        	Size = 'B'; /* CCR */

		BaseCode = Opcode & 0x46f8 ;

		if ( mode == 7 )
			BaseCode |= sreg ;

		Dest = EAtoAMN(BaseCode, FALSE);

		if ( allow[Dest&0xf] != '-' )
		{
			if ( OpcodeArray[BaseCode] == -2 )
			{
                char TrueLabel[16];

				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                if ( type > 1 ) /* move to */
                    TimingCycles += 12 ;
                else
                {
                    if ( mode < 2 )
                        TimingCycles += 6 ;
                    else
                        TimingCycles += 8 ;
                }

                /* If Move to SR then must be in Supervisor Mode */

                if (type == 3)
                {
					sprintf(TrueLabel,GenerateLabel(0,1));

                                fprintf(fp, "\ttest  b [%s],20h \t\t\t; Supervisor Mode ?\n",REG_SRH);
                                fprintf(fp, "\tje    %s\n\n",TrueLabel);
                }

				if ( mode < 7 )
				{
                                        fprintf(fp, "\tand   ecx,7\n");
				}


				/* Always read/write word 2 bytes */
				if (type < 2)
				{
					ReadCCR(Size,EBX);
					EffectiveAddressWrite(Dest & 15,'W',ECX,TRUE,"---DS-B",TRUE);
				}
				else
				{
					EffectiveAddressRead(Dest & 15,'W',ECX,EAX,"----S-B",FALSE);
					WriteCCR(Size);
				}
				Completed();

                /* Exception if not Supervisor Mode */

                if (type == 3)
                {
                    /* Was in User Mode - Exception */

                    fprintf(fp, "%s:\t",TrueLabel);
                    Exception(8,BaseCode);
                }
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

/*
 * Decimal mode Add / Subtracts
 *
 */

void abcd_sbcd(void)
{
	int	Opcode, BaseCode ;
	int	regx,type,rm,regy,mode ;
	char * Regname ;
	char * RegnameECX ;
	char *Label;

	for ( type = 0 ; type < 2 ; type ++ ) /* 0=sbcd, 1=abcd */
	for ( regx = 0 ; regx < 8 ; regx++ )
	for ( rm = 0 ; rm < 2 ; rm++ )
	for ( regy = 0 ; regy < 8 ; regy++ )
	{
		Opcode = 0x8100 | (type<<14) | (regx<<9) | (rm<<3) | regy ;
		BaseCode = Opcode & 0xc108 ;

		if ( rm == 0 )
			mode = 0 ;
		else
			mode = 4 ;

		if ( OpcodeArray[BaseCode] == -2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            AddEACycles = 0 ;

            if ( rm == 0 )
                TimingCycles += 6 ;
            else
                TimingCycles += 18 ;

                        fprintf(fp, "\tmov   ebx,ecx\n");
                        fprintf(fp, "\tand   ebx,7\n");
                        fprintf(fp, "\tshr   ecx,9\n");
                        fprintf(fp, "\tand   ecx,7\n");

  			EffectiveAddressRead(mode,'B',EBX,EBX,"--C-S-B",FALSE);
  			EffectiveAddressRead(mode,'B',ECX,EAX,"-BC-S-B",FALSE);

            CopyX();

			if ( type == 0 )
			{
                                fprintf(fp, "\tsbb   al,bl\n");
                                fprintf(fp, "\tdas\n");
			}
			else
			{
                                fprintf(fp, "\tadc   al,bl\n");
                                fprintf(fp, "\tdaa\n");
			}

            /* Should only clear Zero flag if not zero */

			Label = GenerateLabel(0,1);

                        fprintf(fp, "\tmov   ebx,edx\n");
            fprintf(fp, "\tsetc  dl\n");

                        fprintf(fp, "\tjnz   short %s\n\n",Label);

            /* Keep original Zero flag */
                    fprintf(fp, "\tand   bl,40h        ; Mask out Old Z\n");
                    fprintf(fp, "\tor    dl,bl         ; Copy across\n\n");

                    fprintf(fp, "%s:\t",Label);
                        fprintf(fp, "\tmov   d [%s],edx\n",REG_X);

  			EffectiveAddressWrite(mode,'B',ECX,EAX,"---DS-B",TRUE);
			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}
}

/*
 * Rotate Left / Right
 *
 */

void rol_ror(void)
{
	int Opcode, BaseCode ;
	int dreg, dr, leng, mode, ir, sreg ;
	int Dest ;
	char Size=' ';
	char * Label ;
	char * Regname="" ;
	char * RegnameECX ;

	for ( dreg = 0 ; dreg < 8 ; dreg++ )
	for ( dr = 0 ; dr < 2 ; dr++ )
	for ( leng = 0 ; leng < 3 ; leng++ )
	for ( ir = 0 ; ir < 2 ; ir++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0xe018 | (dreg<<9) | (dr<<8) | (leng<<6) | (ir<<5) | sreg ;
		BaseCode = Opcode & 0xe1f8 ;

      	switch (leng)
    	{
           	case 0:
           		Size = 'B';
           		Regname = regnamesshort[0];
           		RegnameECX = regnamesshort[ECX];
           		break;
           	case 1:
           		Size = 'W';
           		Regname = regnamesword[0];
           		RegnameECX = regnamesword[ECX];
           		break;
           	case 2:
           		Size = 'L';
           		Regname = regnameslong[0];
           		RegnameECX = regnameslong[ECX];
           		break;
   		}

		if ( OpcodeArray[ BaseCode ] == -2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            if ( Size != 'L' )
                TimingCycles += 6 ;
            else
                TimingCycles += 8 ;

                        fprintf(fp, "\tmov   ebx,ecx\n");
                        fprintf(fp, "\tand   ebx,7\n");
                        fprintf(fp, "\tshr   ecx,9\n");

			if ( ir == 0 )
			{
                Immediate8();
			}
			else
			{
                                fprintf(fp, "\tand   ecx,7\n");
				EffectiveAddressRead(0,'L',ECX,ECX,"-B--S-B",FALSE);
                                fprintf(fp, "\tand   ecx,63\n");
			}

//            fprintf(fp, "\tshl   ecx,1\n"); /* and 2 cycles per shift */
//            fprintf(fp, "\tsub   d [%s],ecx\n",ICOUNT);
//            fprintf(fp, "\tshr   ecx,1\n"); /* and 2 cycles per shift */

			EffectiveAddressRead(0,Size,EBX,EAX,"-BC-S-B",FALSE);

			if ( dr == 0 )
                                fprintf(fp, "\tror   %s,cl\n",Regname);
			else
                                fprintf(fp, "\trol   %s,cl\n",Regname);

                        fprintf(fp, "\tsetc  ch\n");
			SetFlags(Size,EAX,TRUE,FALSE,FALSE);
                        fprintf(fp, "\tand   dl,254\n");
                        fprintf(fp, "\tor    dl,ch\n");

			EffectiveAddressWrite(0,Size,EBX,EAX,"--C-S-B",TRUE);

			/* if shift count is zero clear carry */

			Label = GenerateLabel(0,1);
                        fprintf(fp, "\tor    cl,cl\n");
                        fprintf(fp, "\tjz    %s\n",Label);
			Completed();

			Align();
                        fprintf(fp, "%s:\t",Label);
                        fprintf(fp, "\tand   dl,254\t\t;clear C flag\n");
			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}
}

void rol_ror_ea(void)
{
	int Opcode, BaseCode ;
	int dr, mode, sreg ;
	int Dest ;
	char * Label ;
	char * Regname ;
	char * RegnameECX ;
	char allow[] = "--2345678-------" ;

	for ( dr = 0 ; dr < 2 ; dr++ )
	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0xe6c0 | (dr<<8) | (mode<<3) | sreg ;
		BaseCode = Opcode & 0xfff8 ;

		if ( mode == 7 )
			BaseCode |= sreg ;

		Dest = EAtoAMN(BaseCode, FALSE);

		if ( allow[Dest&0xf] != '-' )
		{
			if ( OpcodeArray[ BaseCode ] == -2 )
			{
				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                TimingCycles += 8 ;

                                fprintf(fp, "\tand   ecx,7\n");
				EffectiveAddressRead(Dest&0xf,'W',ECX,EAX,"--C-S-B",FALSE);

				if ( dr == 0 )
                                        fprintf(fp, "\tror   ax,1\n");
				else
                                        fprintf(fp, "\trol   ax,1\n");

                                fprintf(fp, "\tsetc  bl\n");
				SetFlags('W',EAX,TRUE,FALSE,FALSE);
                                fprintf(fp, "\tand   dl,254\n");
                                fprintf(fp, "\tor    dl,bl\n");

				EffectiveAddressWrite(Dest&0xf,'W',ECX,EAX,"---DS-B",TRUE);

				Completed();
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

/*
 * Logical Shift Left / Right
 *
 */

void lsl_lsr(void)
{
	int Opcode, BaseCode ;
	int dreg, dr, leng, mode, ir, sreg ;
	int Dest ;
	char Size=' ';
	char * Regname="" ;
	char * RegnameECX="" ;
	char * Label ;

	for ( dreg = 0 ; dreg < 8 ; dreg++ )
	for ( dr = 0 ; dr < 2 ; dr++ )
	for ( leng = 0 ; leng < 3 ; leng++ )
	for ( ir = 0 ; ir < 2 ; ir++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0xe008 | (dreg<<9) | (dr<<8) | (leng<<6) | (ir<<5) | sreg ;
		BaseCode = Opcode & 0xe1f8 ;

      	switch (leng)
		{
           	case 0:
           		Size = 'B';
          		Regname = regnamesshort[0];
          		RegnameECX = regnamesshort[ECX];
           		break;
           	case 1:
           		Size = 'W';
           		Regname = regnamesword[0];
           		RegnameECX = regnamesword[ECX];
           		break;
           	case 2:
           		Size = 'L';
           		Regname = regnameslong[0];
           		RegnameECX = regnameslong[ECX];
          		break;
        }

		if ( OpcodeArray[ BaseCode ] == -2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            if ( Size != 'L' )
                TimingCycles += 6 ;
            else
                TimingCycles += 8 ;

                        fprintf(fp, "\tmov   ebx,ecx\n");
                        fprintf(fp, "\tand   ebx,7\n");
                        fprintf(fp, "\tshr   ecx,9\n");

			if ( ir == 0 )
			{
            	Immediate8();
			}
			else
			{
                                fprintf(fp, "\tand   ecx,7\n");
				EffectiveAddressRead(0,'L',ECX,ECX,"-B--S-B",FALSE);
                                fprintf(fp, "\tand   ecx,63\n");
			}

//            fprintf(fp, "\tshl   ecx,1\n"); /* and 2 cycles per shift */
//            fprintf(fp, "\tsub   d [%s],ecx\n",ICOUNT);
//            fprintf(fp, "\tshr   ecx,1\n"); /* and 2 cycles per shift */

			EffectiveAddressRead(0,Size,EBX,EAX,"-BC-S-B",FALSE);

			if ( dr == 0 )
                                fprintf(fp, "\tshr   %s,cl\n",Regname);
			else
                                fprintf(fp, "\tshl   %s,cl\n",Regname);

			SetFlags(Size,EAX,FALSE,FALSE,FALSE);

            /* Clear Overflow flag */

            fprintf(fp, "\txor   dh,dh\n");

			EffectiveAddressWrite(0,Size,EBX,EAX,"--CDS-B",TRUE);

			/* if shift count is zero clear carry */

			Label = GenerateLabel(0,1);
                        fprintf(fp, "\tor    cl,cl\n");
                        fprintf(fp, "\tjz    %s\n",Label);

                        fprintf(fp, "\tmov   d [%s],edx\n",REG_X);
			Completed();

			Align();
                        fprintf(fp, "%s:\t",Label);
                        fprintf(fp, "\tand   dl,254\t\t;clear C flag\n");
			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}
}

void lsl_lsr_ea(void)
{
	int Opcode, BaseCode ;
	int dr, mode, sreg ;
	int Dest ;
	char * Label ;
	char * Regname ;
	char * RegnameECX ;
	char allow[] = "--2345678-------" ;

	for ( dr = 0 ; dr < 2 ; dr++ )
	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0xe2c0 | (dr<<8) | (mode<<3) | sreg ;
		BaseCode = Opcode & 0xfff8 ;

		if ( mode == 7 )
			BaseCode |= sreg ;

		Dest = EAtoAMN(BaseCode, FALSE);

		if ( allow[Dest&0xf] != '-' )
		{
			if ( OpcodeArray[ BaseCode ] == -2 )
			{

				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                TimingCycles += 8 ;

                                fprintf(fp, "\tand   ecx,7\n");
				EffectiveAddressRead(Dest&0xf,'W',ECX,EAX,"--C-S-B",FALSE);

				if ( dr == 0 )
                                        fprintf(fp, "\tshr   ax,1\n");
				else
                                        fprintf(fp, "\tshl   ax,1\n");

				SetFlags('W',EAX,FALSE,TRUE,TRUE);

				EffectiveAddressWrite(Dest&0xf,'W',ECX,EAX,"----S-B",FALSE);
				Completed();
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

/*
 * Rotate Left / Right though Extend
 *
 */

void roxl_roxr(void)
{
	int Opcode, BaseCode ;
	int dreg, dr, leng, mode, ir, sreg ;
	int Dest ;
	char Size=' ' ;
	char * Regname="" ;
	char * RegnameECX="" ;
	char * Label ;

	for ( dreg = 0 ; dreg < 8 ; dreg++ )
	for ( dr = 0 ; dr < 2 ; dr++ )
	for ( leng = 0 ; leng < 3 ; leng++ )
	for ( ir = 0 ; ir < 2 ; ir++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0xe010 | (dreg<<9) | (dr<<8) | (leng<<6) | (ir<<5) | sreg ;
		BaseCode = Opcode & 0xe1f8 ;

      	switch (leng)
		{
           	case 0:
           		Size = 'B';
           		Regname = regnamesshort[0];
           		RegnameECX = regnamesshort[ECX];
           		break;
          	case 1:
           		Size = 'W';
           		Regname = regnamesword[0];
           		RegnameECX = regnamesword[ECX];
           		break;
           	case 2:
           		Size = 'L';
           		Regname = regnameslong[0];
           		RegnameECX = regnameslong[ECX];
          		break;
        }

		if ( OpcodeArray[ BaseCode ] == -2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

            if ( Size != 'L' )
                TimingCycles += 6 ;
            else
                TimingCycles += 8 ;

                        fprintf(fp, "\tmov   ebx,ecx\n");
                        fprintf(fp, "\tand   ebx,7\n");
                        fprintf(fp, "\tshr   ecx,9\n");

			if ( ir == 0 )
			{
            	Immediate8();
			}
			else
			{
                                fprintf(fp, "\tand   ecx,7\n");
				EffectiveAddressRead(0,'L',ECX,ECX,"-B--S-B",FALSE);
                                fprintf(fp, "\tand   ecx,63\n");
			}

//            fprintf(fp, "\tshl   ecx,1\n"); /* and 2 cycles per shift */
//            fprintf(fp, "\tsub   d [%s],ecx\n",ICOUNT);
//            fprintf(fp, "\tshr   ecx,1\n"); /* and 2 cycles per shift */

			EffectiveAddressRead(0,Size,EBX,EAX,"-BC-S-B",FALSE);

			/* move X into C so RCR & RCL can be used */
			/* RCR & RCL only set the carry flag      */

            CopyX();

			if ( dr == 0 )
                                fprintf(fp, "\trcr   %s,cl\n",Regname);
			else
                                fprintf(fp, "\trcl   %s,cl\n",Regname);

                        fprintf(fp, "\tsetc  ch\n");
			SetFlags(Size,EAX,TRUE,FALSE,FALSE);
                        fprintf(fp, "\tand   dl,254\n");
                        fprintf(fp, "\tor    dl,ch\n");

			EffectiveAddressWrite(0,Size,EBX,EAX,"--CDS-B",TRUE);

			/* if shift count is zero clear carry */

			Label = GenerateLabel(0,1);
                        fprintf(fp, "\tor    cl,cl\n");
                        fprintf(fp, "\tjz    %s\n",Label);
                        fprintf(fp, "\tmov   d [%s],edx\n",REG_X);
			Completed();

			Align();
                        fprintf(fp, "%s:\t",Label);

			/* copy X onto C when shift is zero */

                        fprintf(fp, "\tand   dl,254\t\t;clear C flag\n");
                        fprintf(fp, "\tmov   ecx,d [%s]\n",REG_X);
                        fprintf(fp, "\tand   ecx,1\n");
                        fprintf(fp, "\tor    edx,ecx\n");
			Completed();
		}

		OpcodeArray[Opcode] = BaseCode ;
	}
}

void roxl_roxr_ea(void)
{
	int Opcode, BaseCode ;
	int dr, mode, sreg ;
	int Dest ;
	char * Label ;
	char * Regname ;
	char * RegnameECX ;
	char allow[] = "--2345678-------" ;

	for ( dr = 0 ; dr < 2 ; dr++ )
	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0xe4c0 | (dr<<8) | (mode<<3) | sreg ;
		BaseCode = Opcode & 0xfff8 ;

		if ( mode == 7 )
			BaseCode |= sreg ;

		Dest = EAtoAMN(BaseCode, FALSE);

		if ( allow[Dest&0xf] != '-' )
		{
			if ( OpcodeArray[ BaseCode ] == -2 )
			{
				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                TimingCycles += 8 ;

                                fprintf(fp, "\tand   ecx,7\n");
				EffectiveAddressRead(Dest&0xf,'W',ECX,EAX,"--C-S-B",FALSE);

				/* move X into C so RCR & RCL can be used */
				/* RCR & RCL only set the carry flag      */

	            CopyX();

				if ( dr == 0 )
                                        fprintf(fp, "\trcr   ax,1\n");
				else
                                        fprintf(fp, "\trcl   ax,1\n");

                                fprintf(fp, "\tsetc  bl\n");
				SetFlags('W',EAX,TRUE,FALSE,FALSE);
/*                              fprintf(fp, "\tand   dl,254\n"); - Intel Clears on Test */
                                fprintf(fp, "\tor    dl,bl\n");

				EffectiveAddressWrite(Dest&0xf,'W',ECX,EAX,"---DS-B",TRUE);

                                fprintf(fp, "\tmov   d [%s],edx\n",REG_X);
				Completed();
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

/*
 * Arithmetic Shift Left / Right
 *
 */

void asl_asr(void)
{
	int Opcode, BaseCode ;
	int dreg, dr, leng, mode, ir, sreg ;
	int Dest ;
	char Size=' ';
    char * Sizename="" ;
	char * Regname="" ;
	char * RegnameECX="" ;
	char * RegnameEDX="" ;
	char * Label ;

    /* Normal routines for codes */

	for ( dreg = 0 ; dreg < 8 ; dreg++ )
	for ( dr = 0 ; dr < 2 ; dr++ )
	for ( leng = 0 ; leng < 3 ; leng++ )
	for ( ir = 0 ; ir < 2 ; ir++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0xe000 | (dreg<<9) | (dr<<8) | (leng<<6) | (ir<<5) | sreg ;
		BaseCode = Opcode & 0xe1f8 ;

      	switch (leng)
		{
          	case 0:
           		Size = 'B';
          		Regname = regnamesshort[0];
           		RegnameECX = regnamesshort[ECX];
           		RegnameEDX = regnamesshort[EDX];
           		break;
          	case 1:
           		Size = 'W';
           		Regname = regnamesword[0];
           		RegnameECX = regnamesword[ECX];
           		RegnameEDX = regnamesword[EDX];
           		break;
           	case 2:
           		Size = 'L';
           		Regname = regnameslong[0];
           		RegnameECX = regnameslong[ECX];
           		RegnameEDX = regnameslong[EDX];
          		break;
        }

		if ( OpcodeArray[ BaseCode ] == -2 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

			Label = GenerateLabel(0,1);

            if ( Size != 'L' )
                TimingCycles += 6 ;
            else
                TimingCycles += 8 ;

                        fprintf(fp, "\tmov   ebx,ecx\n");
                        fprintf(fp, "\tand   ebx,7\n");
                        fprintf(fp, "\tshr   ecx,9\n");

			EffectiveAddressRead(0,Size,EBX,EAX,"-BC-S-B",FALSE);

			if ( ir == 0 )
			{
            	Immediate8();
			}
			else
			{
                                fprintf(fp, "\tand   ecx,7\n");
				EffectiveAddressRead(0,'L',ECX,ECX,"-B--S-B",FALSE);
                                fprintf(fp, "\tand   ecx,63\n");
                fprintf(fp, "\tjz    short %s\n",Label);
			}

//            fprintf(fp, "\tshl   ecx,1\n"); /* and 2 cycles per shift */
//            fprintf(fp, "\tsub   d [%s],ecx\n",ICOUNT);
//            fprintf(fp, "\tshr   ecx,1\n"); /* and 2 cycles per shift */

			if ( dr == 0 )
            {
	            /* ASR */

                                fprintf(fp, "\tsar   %s,cl\n",Regname);

                /* Mode 0 write does not affect Flags */
				EffectiveAddressWrite(0,Size,EBX,EAX,"---DS-B",TRUE);

                /* Update Flags */
                fprintf(fp, "\tlahf\n");
                fprintf(fp, "\txor   edx,edx\n");
                fprintf(fp, "\tmov   dl,ah\n");
                                fprintf(fp, "\tmov   d [%s],edx\n",REG_X);
            }
            else
            {
            	/* ASL */

                /* Check to see if Overflow should be set */

                fprintf(fp,"\tmov   edi,eax\t\t; Save It\n");

                fprintf(fp,"\txor   edx,edx\n");
                                fprintf(fp,"\tstc\n");
                fprintf(fp,"\trcr   %s,1\t\t; d=1xxxx\n",RegnameEDX);
                fprintf(fp,"\tsar   %s,cl\t\t; d=1CCxx\n",RegnameEDX);
                fprintf(fp,"\tand   eax,edx\n");
                fprintf(fp,"\tjz    short %s_V\t\t; No Overflow\n",Label);
                fprintf(fp,"\tcmp   eax,edx\n");
                fprintf(fp,"\tje    short %s_V\t\t; No Overflow\n",Label);

                /* Set Overflow */
                fprintf(fp,"\tmov   edx,0800h\n");
                fprintf(fp,"\tjmp   short %s_OV\n",Label);

                fprintf(fp,"%s_V:\n",Label);
                fprintf(fp,"\txor   edx,edx\n");

                fprintf(fp,"%s_OV:\n",Label);
                fprintf(fp,"\tmov   eax,edi\t\t; Restore It\n");

                                fprintf(fp, "\tsal   %s,cl\n",Regname);
                EffectiveAddressWrite(0,Size,EBX,EAX,"---DS-B",TRUE);
                fprintf(fp, "\tlahf\n");
                fprintf(fp, "\tmov   dl,ah\n");
                                fprintf(fp, "\tmov   d [%s],edx\n",REG_X);
            }
			Completed();

            if ( ir != 0 )
            {
				Align();
                                fprintf(fp, "%s:\t",Label);


	            if (dr == 0)
	            {
    	        	/* ASR - Test clears V and C */
                    SetFlags(Size,EAX,TRUE,FALSE,FALSE);
	            }
    	        else
        	    {
                	/* ASL - Keep existing Carry flag, Clear V */
                        fprintf(fp, "\tmov   ebx,edx\n");
                    fprintf(fp, "\tand   ebx,1\n");
                    SetFlags(Size,EAX,TRUE,FALSE,FALSE);
                    fprintf(fp, "\tor    edx,ebx\n");
            	}

				Completed();
            }
		}

		OpcodeArray[Opcode] = BaseCode ;
	}

    /* End with special routines for ASL.x #1,Dx  */
    /* To do correct V setting, ASL needs quite a */
    /* bit of additional code. A Shift of one has */
    /* correct flags on Intel, and is very common */
    /* in 68030 programs.                         */

	for ( leng = 0 ; leng < 3 ; leng++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
    {
		Opcode = 0xe300 | (leng<<6) | sreg ;
		BaseCode = Opcode & 0xe3c8 ;

      	switch (leng)
		{
          	case 0:
                Sizename = "b";
           		break;
          	case 1:
                Sizename = "w";
           		break;
           	case 2:
                Sizename = "d";
          		break;
        }

		if ( sreg == 0 )
		{
			Align();
                        fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

			Label = GenerateLabel(0,1);

            if ( Size != 'L' )
                TimingCycles += 6 ;
            else
                TimingCycles += 8 ;

                        fprintf(fp, "\tand   ecx,7\n");
                        fprintf(fp, "\tsal   %s [%s+ecx*4],1\n",Sizename,REG_DAT);
            SetFlags('L',EAX,FALSE,TRUE,FALSE);
            Completed();

        }

		OpcodeArray[Opcode] = BaseCode ;
    }
}

void asl_asr_ea(void)
{
	int Opcode, BaseCode ;
	int dr, mode, sreg ;
	int Dest ;
	char * Label ;
	char * Regname ;
	char * RegnameECX ;
	char allow[] = "--2345678-------" ;

	for ( dr = 0 ; dr < 2 ; dr++ )
	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0xe0c0 | (dr<<8) | (mode<<3) | sreg ;
		BaseCode = Opcode & 0xfff8 ;

		if ( mode == 7 )
			BaseCode |= sreg ;

		Dest = EAtoAMN(BaseCode, FALSE);

		if ( allow[Dest&0xf] != '-' )
		{
			if ( OpcodeArray[ BaseCode ] == -2 )
			{

				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                TimingCycles += 8 ;

                                fprintf(fp, "\tand   ecx,7\n");
				EffectiveAddressRead(Dest&0xf,'W',ECX,EAX,"--C-S-B",FALSE);

				if ( dr == 0 )
                                        fprintf(fp, "\tsar   ax,1\n");
				else
                                        fprintf(fp, "\tsal   ax,1\n");

				SetFlags('W',EAX,FALSE,TRUE,TRUE);

				EffectiveAddressWrite(Dest&0xf,'W',ECX,EAX,"----S-B",FALSE);
				Completed();
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}
}

/*
 * Divide Commands, and MULU.l/MULS.L
 */

void divides(void)
{
	int dreg, type, mode, sreg ;
	int Opcode, BaseCode ;
	int Dest ;
	char allow[] = "0-23456789ab-----" ;
	char * Label ;
	char TrapLabel[16];
	int Cycles;

	int divide_cycles[12] =
	{
      38,0,42,42,44,46,50,46,50,46,48,42
    };

	for ( dreg = 0 ; dreg < 8 ; dreg++ )
	for ( type = 0 ; type < 2 ; type++ )
	for ( mode = 0 ; mode < 8 ; mode++ )
	for ( sreg = 0 ; sreg < 8 ; sreg++ )
	{
		Opcode = 0x80c0 | (dreg<<9) | (type<<8) | (mode<<3) | sreg ;
		BaseCode = Opcode & 0x81f8 ;
		if ( mode == 7 )
		{
			BaseCode |= sreg ;
		}

	    Dest = EAtoAMN(Opcode, FALSE);
		if ( allow[Dest&0x0f] != '-' )
		{
			if ( OpcodeArray[ BaseCode ] == -2 )
			{
				Align();
                                fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

                /* Cycle Timing (if succeeds OK) */

                Cycles = divide_cycles[Dest & 0x0f] + 95 + (type * 17);

//                        if (Cycles > 127)
//                                    fprintf(fp, "\tsub   d [%s],%d\n",ICOUNT,Cycles);
//                        else
//                                    fprintf(fp, "\tsub   d [%s],%d\n",ICOUNT,Cycles);

				if ( mode < 7 )
				{
                                        fprintf(fp, "\tmov   ebx,ecx\n");
                                        fprintf(fp, "\tand   ebx,7\n");
				}

                                fprintf(fp, "\tshr   ecx,9\n");
                                fprintf(fp, "\tand   ecx,7\n");

                                sprintf(TrapLabel, "%s", GenerateLabel(0,1) ) ;

				if ( type == 1 ) /* signed */
					{
					EffectiveAddressRead(Dest,'W',EBX,EAX,"A-CDSDB",FALSE); /* source */
                                        fprintf(fp, "\tor    ax,ax\n");
                                        fprintf(fp, "\tje    %s\t\t;do div by zero trap\n", TrapLabel);
                                        fprintf(fp, "\tcwde\n");
                                        fprintf(fp, "\tmov   ebx,eax\n");
					}
				else
					{
					EffectiveAddressRead(Dest,'W',EBX,EBX,"A-CDSDB",FALSE); /* source */
                                        fprintf(fp, "\tor    bx,bx\n");
                                        fprintf(fp, "\tje    %s\t\t;do div by zero trap\n", TrapLabel);
					}

				EffectiveAddressRead(0,'L',ECX,EAX,"ABCDSDB",FALSE); /* dest */

				if ( type == 1 )
                                        fprintf(fp, "\tcdq\n");
				else
					{
/*                                      fprintf(fp, "\tand   eax,0FFFFH\n");*/
                                        fprintf(fp, "\tmovzx ebx,bx\n");
                                        fprintf(fp, "\txor   edx,edx\n");
					}

				if ( type == 1 )
                                        fprintf(fp, "\tidiv  ebx\n");
				else
                                        fprintf(fp, "\tdiv   ebx\n");

                                fprintf(fp, "\txor   ebx,ebx\n");
                                fprintf(fp, "\ttest  eax, 0FFFF0000H\n");
                                fprintf(fp, "\tsetnz bl\n");
                                fprintf(fp, "\tshl   ebx,11\n"); /* set bit 11 */

                                fprintf(fp, "\tshl   edx,16\n");
                                fprintf(fp, "\tmov   dx,ax\n");
                                fprintf(fp, "\tmov   d [%s+ECX*4],edx\n",REG_DAT);
				SetFlags('W',EDX,TRUE,FALSE,FALSE);

				/* overflow = 0800H */
                                fprintf(fp, "\tor    edx,ebx\t\t;V flag\n");
				Completed();

				Align();
                                fprintf(fp, "%s:\t;Do divide by zero trap\n", TrapLabel);

                /* Correct cycle counter for error */

//                                fprintf(fp, "\tadd   d [%s],%d\n",ICOUNT,95 + (type * 17));

				Exception(5,BaseCode);
			}

			OpcodeArray[Opcode] = BaseCode ;
		}
	}

 for ( mode = 0 ; mode < 8 ; mode++ )
 for ( sreg = 0 ; sreg < 8 ; sreg++ ){
     Opcode = 0x4c40 | (mode<<3) | sreg ;
     BaseCode = Opcode & 0x4cf8 ;
     if ( mode == 7 ){
        BaseCode |= sreg ;}

        Dest = EAtoAMN(Opcode, FALSE);
        if ( allow[Dest&0x0f] != '-' )
        {
           if ( (OpcodeArray[ BaseCode ] == -2) )
           {
              Align();
              fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

              /* Cycle Timing (if succeeds OK) */

              Cycles = divide_cycles[Dest & 0x0f] + 95 + (type * 17);
//              fprintf(fp, "\tsub   d [%s],%d\n",ICOUNT,Cycles);

              if ( mode < 7 )
              {
                 fprintf(fp, "\tand   ecx,7\n");
              }
              sprintf(TrapLabel, "%s", GenerateLabel(0,1) ) ;

              fprintf(fp, "\tmov   bx,w [esi+ebp]\n");
              fprintf(fp, "\tadd   esi,2\n");
              EffectiveAddressRead(Dest,'L',ECX,ECX,"A-CDSDB",FALSE); /* source */
              fprintf(fp, "\tcmp   ecx,0\n");
              fprintf(fp, "\tjz    %s\t\t;do div by zero trap\n", TrapLabel);

              fprintf(fp, "\tmov   d [@@dummy],ecx\n");
              fprintf(fp, "\tmov   cl,bh\t;Dq\n");
              fprintf(fp, "\tshr   cl,4\n");
              fprintf(fp, "\tand   ecx,7\n");
              fprintf(fp, "\tmov   eax,d [R_D0+ecx*4]\n");
              fprintf(fp, "\tpush  ecx\n");
              fprintf(fp, "\tmov   cl,bl\n");
              fprintf(fp, "\tand   ecx,7\n");
              fprintf(fp, "\tmov   edx,d [R_D0+ecx*4]\n");
              fprintf(fp, "\tpush  ecx\n");
              fprintf(fp, "\ttest  bh,4\n");
              fprintf(fp, "\tjnz   short @@1\n");
              fprintf(fp, "\txor   edx,edx\t;32bit\n");
              fprintf(fp, "@@1:\n");
              fprintf(fp, "\tmov   ecx,d [@@dummy]\n");
              fprintf(fp, "\ttest  bh,8\n");
              fprintf(fp, "\tjz    short @@unsigned\n");
              fprintf(fp, "\tdiv   ecx\n");
              fprintf(fp, "\tjmp   short @@2\n");
              fprintf(fp, "@@unsigned:\n");
              fprintf(fp, "\tidiv  ecx\n");
              fprintf(fp, "@@2:\n");
              fprintf(fp, "\tpop   ecx\t;Dr\n");
              fprintf(fp, "\tpop   ebx\t;Dq\n");
              fprintf(fp, "\tcmp   ebx,ecx\n");
              fprintf(fp, "\tjz    short @@3\n");
              fprintf(fp, "\tmov   d [R_D0+ecx*4],edx\n");
              fprintf(fp, "@@3:\n");
              fprintf(fp, "\tmov   d [R_D0+ebx*4],eax\n");
              fprintf(fp, "\t \n");
              fprintf(fp, "\t \n");
              SetFlags('L',EDX,TRUE,FALSE,FALSE);
              /* overflow = 0800H */
              fprintf(fp, "\tor    edx,ebx\t\t;V flag\n");
              Completed();
              fprintf(fp, "@@dummy:\tdd\t0\n");
              Align();
              fprintf(fp, "%s:\t;Do divide by zero trap\n", TrapLabel);
              /* Correct cycle counter for error */

//              fprintf(fp, "\tadd   d [%s],%d\n",ICOUNT,95 + (type * 17));

              Exception(5,BaseCode);
              }
           OpcodeArray[Opcode] = BaseCode ;

           }
     }
//*******************************
// Multiply 32/64 bit


 for ( mode = 0 ; mode < 8 ; mode++ )
 for ( sreg = 0 ; sreg < 8 ; sreg++ ){
     Opcode = 0x4c00 | (mode<<3) | sreg ;
     BaseCode = Opcode & 0x4cf8 ;
     if ( mode == 7 ){
        BaseCode |= sreg ;}

        Dest = EAtoAMN(Opcode, FALSE);
        if ( allow[Dest&0x0f] != '-' )
        {
           if ( (OpcodeArray[ BaseCode ] == -2) )
           {
              Align();
              fprintf(fp, "%s:\t",GenerateLabel(BaseCode,0));

              /* Cycle Timing (if succeeds OK) */

              Cycles = divide_cycles[Dest & 0x0f] + 95 + (type * 17);
//              fprintf(fp, "\tsub   d [%s],%d\n",ICOUNT,Cycles);

              if ( mode < 7 )
              {
                 fprintf(fp, "\tand   ecx,7\n");
              }
              sprintf(TrapLabel, "%s", GenerateLabel(0,1) ) ;

              fprintf(fp, "\tmov   bx,w [esi+ebp]\n");
              fprintf(fp, "\tadd   esi,2\n");
              EffectiveAddressRead(Dest,'L',ECX,ECX,"A-CDSDB",FALSE); /* source */

              fprintf(fp, "\tmov   d [@@dummy],ecx\n");
              fprintf(fp, "\tmov   cl,bh\t;Dq\n");
              fprintf(fp, "\tshr   cl,4\n");
              fprintf(fp, "\tand   ecx,7\n");
              fprintf(fp, "\tmov   eax,d [R_D0+ecx*4]\n");
              fprintf(fp, "\tpush  ecx\n");
              fprintf(fp, "\tmov   cl,bl\n");
              fprintf(fp, "\tand   ecx,7\n");
              fprintf(fp, "\tpush  ecx\n");
              fprintf(fp, "\tmov   ecx,d [@@dummy]\n");
              fprintf(fp, "\ttest  bh,8\n");
              fprintf(fp, "\tjz    short @@unsigned\n");
              fprintf(fp, "\tmul   ecx\n");
              fprintf(fp, "\tjmp   short @@2\n");
              fprintf(fp, "@@unsigned:\n");
              fprintf(fp, "\timul  ecx\n");
              fprintf(fp, "@@2:\n");
              fprintf(fp, "\tpop   ecx\t;Dr\n");
              fprintf(fp, "\tpop   ebx\t;Dq\n");
              fprintf(fp, "\ttest  bh,4\n");
              fprintf(fp, "\tjz    short @@3\n");
              fprintf(fp, "\tmov   d [R_D0+ecx*4],edx\n");
              fprintf(fp, "@@3:\n");
              fprintf(fp, "\tmov   d [R_D0+ebx*4],eax\n");
              fprintf(fp, "\t \n");


              SetFlags('L',EDX,TRUE,FALSE,FALSE);
              Completed();
              fprintf(fp, "@@dummy:\tdd\t0\n");
              }
           OpcodeArray[Opcode] = BaseCode ;

           }
     }
}

/*
 * Generate Jump Table
 *
 */

void JumpTable(void)
{
	int Opcode,l,op;
	FILE *jt ;

        jt = fopen( "comptab.asm", "w" ) ;

    l = 0 ;
    for(Opcode=0x0;Opcode<0x10000;)
    {
		fprintf(jt, "DD ");

		op = OpcodeArray[Opcode];
    	if(op > -1 )
       	{
			fprintf(jt, "OP_%4.4x\n",op);
	    }
        else
        {
	    	fprintf(jt, "ILLEGAL\n");
	    }

		l = 1 ;
		while ( op == OpcodeArray[Opcode+l] && ((Opcode+l) & 0xfff) != 0 )
		{
			l++ ;
		}

		Opcode += l ;
		fprintf(jt, "DW %d\n", l ) ;
    }
	fclose(jt);
}

void CodeSegmentBegin(void)
{

/* Messages */

        fprintf(fp, "; Make68030 - V%s - Copyright 1999, Frans van Nispen (xlr8@tref.nl)\n\n", VERSION);
/* Needed code to make it work! */

    fprintf(fp, "\t\t.586p\n");
    fprintf(fp, "\t\t.Model Flat\n");
    fprintf(fp, "\t\t.Code\n");
    fprintf(fp, "\t\tlocals @@\n");
    fprintf(fp, "b\tequ\tbyte ptr\n");
    fprintf(fp, "w\tequ\tword ptr\n");
    fprintf(fp, "d\tequ\tdword ptr\n\n");
    fprintf(fp, "\t\tPUBLIC R_D0,R_A0,R_PC,R_USP,R_SR_H,R_A7\n");
    fprintf(fp, "\t\tPUBLIC R_VBR,R_SFC,R_DFC,R_CAAR,R_CACR,R_MSP\n");
    fprintf(fp, "\t\tPUBLIC R_CRP,R_SRP,R_TC,R_TT0,R_TT1,R_MMUSR\n");
    fprintf(fp, "\t\tPUBLIC R_ISP, R_CCR, R_SR, R_XC,R_IRQ\n");
    fprintf(fp, "\t\tPUBLIC M68030_Reset,M68030_Run,%s\n",ICOUNT);
    fprintf(fp, "\t\tEXTRN BRK,HTabRB,HTabRW,HTabRL,HTabWB,HTabWW,HTabWL\n");

    fprintf(fp, "ReadTestB\t MACRO\n");
        fprintf(fp, "\tlocal x,y\n");
        fprintf(fp, "\tand   edi,0ffffffh\n");
        fprintf(fp, "\tcmp   edi,0ff0000h\n");
        fprintf(fp, "\tjnae  short y\n");
        fprintf(fp, "\tmov   eax,edi\n");
        fprintf(fp, "\tand   eax,000fe00h\n");
        fprintf(fp, "\tshr   eax,7\n");
        fprintf(fp, "\tcall  d [HTabRB+eax]\n");
        fprintf(fp, "\tjmp   short x\n");
        fprintf(fp, "y:\t\n");
        fprintf(fp, "\txor   EDI,1\n");
        fprintf(fp, "\tmov   al,b [ebp+EDI]\n");
        fprintf(fp, "\txor   EDI,1\n");
        fprintf(fp, "x:\t\n");
    fprintf(fp, "\tENDM\n");
    fprintf(fp, "WriteTestB\tMACRO\n");
        fprintf(fp, "\tlocal x,y\n");
        fprintf(fp, "\tand   edi,0ffffffh\n");
        fprintf(fp, "\tcmp   edi,0ff0000h\n");
        fprintf(fp, "\tjnae  short y\n");
        fprintf(fp, "\tpush  ebx\n");
        fprintf(fp, "\tmov   ebx,edi\n");
        fprintf(fp, "\tand   ebx,000fe00h\n");
        fprintf(fp, "\tshr   ebx,7\n");
        fprintf(fp, "\tcall  d [HTabWB+ebx]\n");
        fprintf(fp, "\tpop   ebx\n");
        fprintf(fp, "\tjmp   short x\n");
        fprintf(fp, "y:\t\n");
            fprintf(fp, "\txor   EDI,1\n");
            fprintf(fp, "\tmov   b [ebp+EDI],al\n");
            fprintf(fp, "\txor   EDI,1\n");
        fprintf(fp, "x:\t\n");
    fprintf(fp, "\tENDM\n");
    fprintf(fp, "ReadTestW\t MACRO\n");
        fprintf(fp, "\tlocal x,y\n");
        fprintf(fp, "\tand   edi,0ffffffh\n");
        fprintf(fp, "\tcmp   edi,0ff0000h\n");
        fprintf(fp, "\tjnae  short y\n");
        fprintf(fp, "\tmov   eax,edi\n");
        fprintf(fp, "\tand   eax,000fe00h\n");
        fprintf(fp, "\tshr   eax,7\n");
        fprintf(fp, "\tcall  d [HTabRW+eax]\n");
        fprintf(fp, "\tjmp   short x\n");
        fprintf(fp, "y:\t\n");
        fprintf(fp, "\tmov   ax,w [ebp+EDI]\n");
        fprintf(fp, "x:\t\n");
    fprintf(fp, "\tENDM\n");
    fprintf(fp, "WriteTestW\tMACRO\n");
        fprintf(fp, "\tlocal x,y\n");
        fprintf(fp, "\tand   edi,0ffffffh\n");
        fprintf(fp, "\tcmp   edi,0ff0000h\n");
        fprintf(fp, "\tjnae  short y\n");
        fprintf(fp, "\tpush  ebx\n");
        fprintf(fp, "\tmov   ebx,edi\n");
        fprintf(fp, "\tand   ebx,000fe00h\n");
        fprintf(fp, "\tshr   ebx,7\n");
        fprintf(fp, "\tcall  d [HTabWW+ebx]\n");
        fprintf(fp, "\tpop   ebx\n");
        fprintf(fp, "\tjmp   short x\n");
        fprintf(fp, "y:\t\n");
            fprintf(fp, "\tmov   w [ebp+EDI],ax\n");
        fprintf(fp, "x:\t\n");
    fprintf(fp, "\tENDM\n");
    fprintf(fp, "ReadTestL\t MACRO\n");
        fprintf(fp, "\tlocal x,y\n");
        fprintf(fp, "\tand   edi,0ffffffh\n");
        fprintf(fp, "\tcmp   edi,0ff0000h\n");
        fprintf(fp, "\tjnae  short y\n");
        fprintf(fp, "\tmov   eax,edi\n");
        fprintf(fp, "\tand   eax,000fe00h\n");
        fprintf(fp, "\tshr   eax,7\n");
        fprintf(fp, "\tcall  d [HTabRL+eax]\n");
        fprintf(fp, "\tjmp   short x\n");
        fprintf(fp, "y:\t\n");
           fprintf(fp, "\tmov   eax,d [ebp+EDI]\n");
           fprintf(fp, "\trol   eax,16\n");
        fprintf(fp, "x:\t\n");
    fprintf(fp, "\tENDM\n");
    fprintf(fp, "WriteTestL\tMACRO\n");
        fprintf(fp, "\tlocal x,y\n");
        fprintf(fp, "\tand   edi,0ffffffh\n");
        fprintf(fp, "\tcmp   edi,0ff0000h\n");
        fprintf(fp, "\tjnae  short y\n");
        fprintf(fp, "\tpush  ebx\n");
        fprintf(fp, "\tmov   ebx,edi\n");
        fprintf(fp, "\tand   ebx,000fe00h\n");
        fprintf(fp, "\tshr   ebx,7\n");
        fprintf(fp, "\tcall  d [HTabWL+ebx]\n");
        fprintf(fp, "\tpop   ebx\n");
        fprintf(fp, "\tjmp   short x\n");
        fprintf(fp, "y:\t\n");
            fprintf(fp, "\trol   eax,16\n");
            fprintf(fp, "\tmov   d [ebp+EDI],eax\n");
        fprintf(fp, "x:\t\n");
    fprintf(fp, "\tENDM\n");
    fprintf(fp, " \n");

/* Reset routine */


    Align();
    fprintf(fp, "\tinclude except.asm\n");

}

void CodeSegmentEnd(void)
{
        fprintf(fp, "\t\t.DATA\n\n");
    Align();

    fprintf(fp, "M68030_ICount\t DD 0\n\n");

    /* Memory structure for 68030 registers  */

    fprintf(fp, "\n\n; Register Structure\n\n");

    fprintf(fp, "_regs:\n");
    fprintf(fp, "R_D0\t DD 0\t\t; Data Registers\n");
    fprintf(fp, "R_D1\t DD 0\n");
    fprintf(fp, "R_D2\t DD 0\n");
    fprintf(fp, "R_D3\t DD 0\n");
    fprintf(fp, "R_D4\t DD 0\n");
    fprintf(fp, "R_D5\t DD 0\n");
    fprintf(fp, "R_D6\t DD 0\n");
    fprintf(fp, "R_D7\t DD 0\n\n");

    fprintf(fp, "R_A0\t DD 0\t\t; Address Registers\n");
    fprintf(fp, "R_A1\t DD 0\n");
    fprintf(fp, "R_A2\t DD 0\n");
    fprintf(fp, "R_A3\t DD 0\n");
    fprintf(fp, "R_A4\t DD 0\n");
    fprintf(fp, "R_A5\t DD 0\n");
    fprintf(fp, "R_A6\t DD 0\n");
    fprintf(fp, "R_A7\t DD 0\n\n");


    fprintf(fp, "R_Control: ; DO NOT CHANGE NEXT ORDER!!\n");
    fprintf(fp, "R_SFC\t DD 0\t\t; Alternate Function Code\n");
    fprintf(fp, "R_DFC\t DD 0\t\t; Alternate Function Code\n");
    fprintf(fp, "R_CACR\t DD 0\t\t; Cash Control Register\n");
    fprintf(fp, "R_TC\t DD 0\n");
    fprintf(fp, "R_TT0\tDD 0 ; ITT0\n");
    fprintf(fp, "R_TT1\tDD 0 ; ITT1\n");
    fprintf(fp, "\tDD 0 ; DTT0\n");
    fprintf(fp, "\tDD 0 ; DTT1\n");
    fprintf(fp, "R_USP\t DD 0\t\t; Stack Registers\n");
    fprintf(fp, "R_VBR\t DD 0\t\t; Vector Base Register\n");
    fprintf(fp, "R_CAAR\t DD 0\t\t; Cash Adres Register\n");
    fprintf(fp, "R_MSP\t DD 0\n\n");
    fprintf(fp, "R_ISP\t DD 0\n\n");
    fprintf(fp, "R_MMUSR\t DD 0\n");
    fprintf(fp, "\tDD 0 ; URP\n");
    fprintf(fp, "R_SRP\t DD 0,0\n");
    fprintf(fp, "R_CRP\t DD 0,0\t\t; MMU Registers\n");

    fprintf(fp, "R_SR_H\t DD 0\t\t; Status Register High TuSuuIII\n");
    fprintf(fp, "R_CCR\t DD 0\t\t; CCR Register in Intel Format\n");
    fprintf(fp, "R_XC\t DD 0\t\t; Extended Carry uuuuuuuX\n");

    fprintf(fp, "R_PC\t DD 0\t\t; Program Counter\n");
    fprintf(fp, "R_IRQ\t DD 0\t\t; IRQ Request Level\n\n");
    fprintf(fp, "R_SR\t DD 0\t\t; Motorola Format SR\n\n");
    fprintf(fp, "R_PPC\t DD 0\t\t; Previous Program Counter\n");



    /* Safe Memory Locations */

	fprintf(fp, "Safe_EBX\t DD 0\n");
	fprintf(fp, "Safe_ECX\t DD 0\n");
	fprintf(fp, "Safe_EDI\t DD 0\n\n");

    fprintf(fp, "\tALIGN 4\n");

    fprintf(fp, "IntelFlag:\n");
    fprintf(fp, "\tDD 0000h,0001h,0800h,0801h,0040h,0041h,0840h,0841h\n");
    fprintf(fp, "\tDD 0080h,0081h,0880h,0881h,00C0h,00C1h,08C0h,08C1h\n");
    fprintf(fp, "\tDD 0100h,0101h,0900h,0901h,0140h,0141h,0940h,0941h\n");
    fprintf(fp, "\tDD 0180h,0181h,0980h,0981h,01C0h,01C1h,09C0h,09C1h\n");

    /* Interrupt Masks */

    fprintf(fp, "\n\nIRQmask:\t\t\t\t; Interrupt Masks\n");
    fprintf(fp, "\tDB 7,7,7,3,3,1,1,0\t;mask for ATARI\n");

    /* Exception Timing Table */

    fprintf(fp, "exception_cycles:\n");
    fprintf(fp, "\tDB 0, 0, 0, 0, 38, 42, 44, 38, 38, 0, 38, 38, 0, 0, 0, 0\n");
    fprintf(fp, "\tDB 0, 0, 0, 0, 0, 0, 0, 0, 46, 46, 46, 46, 46, 46, 46, 46\n");
    fprintf(fp, "\tDB 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38\n\n");

	fprintf(fp, "; RLE Compressed Jump Table\n\n");
        fprintf(fp, "COMPTABLE:\n\n");
        fprintf(fp, "include comptab.asm\n\n");
	fprintf(fp, "\t\tDD   0,0\n\n");


//     fprintf(fp, "\t\t.BSS\n\n");

        fprintf(fp, "OPCODETABLE\tDD    65536 DUP (?)\n\n");
        fprintf(fp, "\t\tEND\n");
}

void EmitCode(void)
{
	CodeSegmentBegin();

    /* Instructions */

	moveinstructions();					/* 1000 to 3FFF MOVE.X */
  	immediate();						/* 0### XXX.I */
  	tst();
	bitdynamic();                       /* 0### dynamic bit operations */
	movep();                            /* 0### Move Peripheral */
	bitstatic();						/* 08## static bit operations */
	LoadEffectiveAddress();				/* 4### */
  	PushEffectiveAddress();				/* ???? */
	movesr();							/* 4#C# */
  	opcode5();                          /* 5000 to 5FFF ADDQ,SUBQ,Scc and DBcc */
  	branchinstructions();				/* 6000 to 6FFF Bcc,BSR */
  	moveq();							/* 7000 to 7FFF MOVEQ */
	abcd_sbcd();						/* 8### Decimal Add/Sub */
	typelogicalmath();                  /* Various ranges */
	addx_subx();
        divides();
	swap();
	not(); 								/* also neg negx clr */
	moveusp();
	chk();
	exg();
	cmpm();
	mul();
	ReturnandRestore();
	rts();
	jmp_jsr();
    nbcd();
    tas();
   	trap();
	trapv();
	reset();
	nop();
	stop();
	ext();
  	ReturnFromException();
	movem_reg_ea();
	movem_ea_reg();
    link();
    unlinkasm();
	asl_asr();							/* E### Shift Commands */
	asl_asr_ea();
	roxl_roxr();
	roxl_roxr_ea();
	lsl_lsr();
	lsl_lsr_ea();
	rol_ror();
	rol_ror_ea();
	LineA();							/* A000 to AFFF Line A */
    LineF();							/* F000 to FFFF Line F */
  	illegal_opcode();
        movec();
        bfextu();

	CodeSegmentEnd();
}

void main(int argc, char **argv)
{
	int dwLoop = 0;
        int counter=0;

        printf("Make68K - V%s - Copyright 1999, Frans van Nispen (xlr8@tref.nl)\n\n", VERSION);


    for(dwLoop=0;dwLoop<65536;)	OpcodeArray[dwLoop++] = -2;

 	codebuf=malloc(64);
	if (!codebuf)
 	{
  		printf ("Memory allocation error\n");
  		exit(3);
 	}

	if (argc < 1)
	{
		printf("Usage: %s outfile \n", argv[0]);
		exit(1);
	}

	for (dwLoop = 1; dwLoop < argc; dwLoop++)
		if (argv[dwLoop][0] != '-')
		{
			fp = fopen(argv[dwLoop], "w");
			break;
		}

	if (NULL == fp)
	{
		fprintf(stderr, "Can't open %s for writing\n", argv[1]);
	}

	EmitCode();

	fclose(fp);

	printf("\n%d Unique Opcodes\n",Opcount);

    /* output Jump table to separate file */

    JumpTable();

    exit(0);
}
