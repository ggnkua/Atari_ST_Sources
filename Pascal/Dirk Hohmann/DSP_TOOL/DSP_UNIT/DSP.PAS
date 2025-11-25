{ ----------------------------------------------------------
  |                     UNIT DSP                           |
  |                                                        |
  | Hilfsfunktionen zur DSP-Programmierung fr Pure Pascal |
  |                                                        |
  | Autor: Dirk Hohmann                                    |
  |        An der Etzequelle 6                             |
  |        37130 Gleichen/Etzenborn                        |
  |                                                        |
  ----------------------------------------------------------}

unit dsp;

INTERFACE

type dspword = array[0..2] of byte;

var word_size :integer;					      {L„nge eines DSP-Wortes}
	x_free,y_free :longint; 	          {freier XY-Speicher}
	
function r_frac(a:real):longint;	    { REAL -> DSP-Format }
function to_real(a:longint):real;  	  { DSP-Format -> REAL }
function e_frac(a:extended):longint;  { EXTENDED -> DSP-Format }
function to_ext(a:longint):extended;  { DSP-Format -> EXTENDED }
function s_frac(a:single):longint;    { SINGLE -> DSP-Format }
function to_single(a:longint):single; { DSP-Format -> SINGLE }
function dsp_init: boolean;		
procedure dsp_exit;
procedure l_to_dspword(a:longint;var b:dspword); { Konvertierungen }
function dspword_to_l(a:dspword):longint;

IMPLEMENTATION
uses tos;

function r_frac(a:real):longint;external; 
function to_real(a:longint):real;external; 
function e_frac(a:extended):longint;external; 
function to_ext(a:longint):extended;external;
function s_frac(a:single):longint;external; 
function to_single(a:longint):single;external;

{$L C:\DSP_TOOL\DSP_UNIT\DSP_CONV.O }

	
function dsp_init: boolean;		
begin
	dsp_init:=false;
	word_size:=dsp_getwordsize;
	if word_size<>3 then exit;
	if dsp_lock<>0 then exit;
	dsp_available(x_free,y_free);
	dsp_init:=true;
end;

procedure dsp_exit;
begin
	dsp_unlock;
end;

procedure l_to_dspword(a:longint;var b:dspword);
begin
	b[0]:=(a shr 16) and 255;
	b[1]:=(a shr 8) and 255;
	b[2]:=a and 255;
end;

function dspword_to_l(a:dspword):longint;
begin
	dspword_to_l:=(a[0] shl 16) or (a[1] shl 8) or a[2];
end;

begin
end.
