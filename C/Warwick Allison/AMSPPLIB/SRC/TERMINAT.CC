//////////////////////////////////////////////////////////////////////////////
//
//  This file is part of the Atari Machine Specific Library,
//  and is Copyright 1992 by Warwick W. Allison.
//
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.
//
//////////////////////////////////////////////////////////////////////////////

#include "Termination.h"
#include <osbind.h> // for Setexc()
#include <signal.h>
#include <stdlib.h>


void SignalHandler(int SigNum)
{
	exit(SigNum);
}

// Cancel the fact that we are in supervisor mode when an exception occurs
#define UNRTE asm("unlk a6; addl #6,sp; movew 0x300,sr")

void RaiseILL() { UNRTE; SignalHandler(SIGILL); }
void RaisePRIV() { UNRTE; SignalHandler(SIGPRIV); }
void RaiseFPE() { UNRTE; SignalHandler(SIGFPE); }
void RaiseBUS() { UNRTE; SignalHandler(SIGBUS); }
void RaiseSEGV() { UNRTE; SignalHandler(SIGSEGV); }

static int Unixified=0;

typedef void (*exc)(void);

static exc OrgILL;
static exc OrgPRIV;
static exc OrgFPE;
static exc OrgBUS;
static exc OrgSEGV;

const BUS_ERR = 2;
const ADDR_ERR = 3;
const ILL_INSTR = 4;
const DIV_ZERO = 5;
// const RANGE_CHK = 6;
// const OVFLW_CHK = 7;
const PRIV_VIOL = 8;

void UnixifyAtariExceptions(int on)
{
	if (on!=Unixified) {
		if (on) {
			OrgILL=Setexc(ILL_INSTR,RaiseILL);
			OrgPRIV=Setexc(PRIV_VIOL,RaisePRIV);
			OrgFPE=Setexc(DIV_ZERO,RaiseFPE);
			OrgBUS=Setexc(BUS_ERR,RaiseBUS);
			OrgSEGV=Setexc(ADDR_ERR,RaiseSEGV);
		} else {
			Setexc(ILL_INSTR,OrgILL);
			Setexc(PRIV_VIOL,OrgPRIV);
			Setexc(DIV_ZERO,OrgFPE);
			Setexc(BUS_ERR,OrgBUS);
			Setexc(ADDR_ERR,OrgSEGV);
		}
	}
}

static bool TrapsOn=FALSE;

void TrapExceptions(bool on)
{
	if (on!=TrapsOn) {
		TrapsOn=on;
		for (int sig=1; sig < NSIG; sig++) {
			if (on) {
				signal(sig,SignalHandler);
			} else {
				signal(sig,SIG_DFL);
			}
		}

		UnixifyAtariExceptions(on);
	}
}
