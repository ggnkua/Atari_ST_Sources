/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *	    _    _
 *       | |  | |	OUTLAW. 
 *      -| |  | |- 
 *  _    | |- | |
 *-| |   | |  | |- 	
 * |.|  -| ||/  |
 * | |-  |  ___/ 
 *-|.|   | | |
 * |  \_|| |
 *  \____  |
 *   |   | |- 
 *       | |
 *      -| |
 *       |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#include <ISR.H>

/*-------------------------------------------- InstallVector -----
|  Function InstallVector
|
|  Purpose: Install interupt vector
|
|  Parameters: num vector # to install, pointer to vector function to save. 
|
|  Returns:
*-------------------------------------------------------------------*/

Vector InstallVector(int num, Vector vector)
{
	Vector orig;
	Vector *vectp = (Vector *)((long)num << 2);

	orig = *vectp;
	*vectp = vector;

	return orig;
}

/*-------------------------------------------- InstallMfp -----
|  Function InstallMfp
|
|  Purpose: 
|
|  Parameters: 
|
|  Returns:
*-------------------------------------------------------------------*/

void InstallMfp(void)
{
	*MFP_PDR = 0x73;
	*MFP_AER = 0x04;
	*MFP_DIR = 0x00;
	*MFP_IERA = 0x1E;
	*MFP_IERB = 0x64;
	*MFP_IPRA = 0x00;
	*MFP_IPRB = 0x00;
	*MFP_ISRA = 0x00;
	*MFP_ISRB = 0x00;
	*MFP_IMRA = 0x1E;
	*MFP_IMRB = 0x64;
	*MFP_VCR = 0x48;
	*MFP_TAC = 0x00;
	*MFP_TBC = 0x00;
	*MFP_TAD = 0x00;
	*MFP_TBD = 0x21;
	*MFP_TCD = 0x91;
	*MFP_TDD = 0x01;
	*MFP_SYC = 0x00;
	*MFP_UCR = 0x88;
	*MFP_RES = 0x01;
	*MFP_TRS = 0x81;
	*MFP_UAD = 0x00;
}
