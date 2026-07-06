/**
 * Copyright (c) 1985 by Steve Wilhite, Worthington, Ohio
 *
 * Permission is granted to use or distribute this software without any
 * restrictions as long as this entire copyright notice is included intact.
 * You may include it in any software product that you sell for profit.
 *
 * This software is distributed as is, and is not guaranteed to work on any
 * given hardware/software configuration.  Furthermore, no liability is
 * granted with this software.
 *
 * ABSTRACT:
 *
 *	The function, Transfer_File, implements error-free file transfer using
 *	CompuServe's "B" protocol.
 *
 *	It has been assumed that the start-of-packet sequence, DLE "B", has
 *	been detected and the next byte not received yet is the packet
 *	sequence number (an ASCII digit).
 *
 * ENVIRONMENT: Lattice "C", machine independent.
 *
 * AUTHOR: Steve Wilhite, CREATION DATE: 21-Jul-85
 *
 * REVISION HISTORY:
 *
 **/

#include "\lc\stdio.h"
#include "\lc\fcntl.h"

/* External Functions */

extern Delay();			/* Sleep for "n" milliseconds */
extern Start_Timer();		/* Enable the timer for the specified number
    				   seconds */
extern int Timer_Expired();	/* Returns "true" if the timer has expired,
    				   "false" otherwise */
extern int Wants_To_Abort();	/* Returns "true" if the user wants to abort
    				   the file transfer, "false" otherwise */
extern int Read_Modem();	/* Read a character from the comm port.
    				   Returns -1 if no character available */
extern int Write_Modem();	/* Send a character to the comm port. Returns
    				   "true" is successful, "false" otherwise */

extern int open(), creat();	/* standard I/O functions */
extern int read(), write();
extern int close();

#define ETX	0x03
#define ENQ	0x05
#define DLE	0x10
#define XON	0x11
#define XOFF	0x13
#define NAK	0x15

#define True		1
#define False		0
#define Success		-1
#define Failure		0
#define Packet_Size	512
#define Max_Errors	10
#define Max_Time	10
#define WACK		';'		/* wait acknowledge */

/* Sender actions */

#define S_Send_Packet	0
#define S_Get_DLE	1
#define S_Get_Num	2
#define S_Get_Seq	3
#define S_Get_Data	4
#define S_Get_Checksum	5
#define S_Timed_Out	6
#define S_Send_NAK	7

/* Receiver actions */

#define R_Get_DLE	0
#define R_Get_B		1
#define R_Get_Seq	2
#define R_Get_Data	3
#define R_Get_Checksum	4
#define R_Send_NAK	5
#define R_Send_ACK	6

static int
    Ch,
    Checksum,
    Seq_Num,
    R_Size,				/* Size of receiver buffer */
    XOFF_Flag,
    Seen_ETX;

static char
    S_Buffer[Packet_Size],		/* Sender buffer */
    R_Buffer[Packet_Size];		/* Receiver buffer */

static Put_Msg(Text)
    char *Text;
{
    while (*Text != 0) Put_Char(*Text++);
    Put_Char('\015');
    Put_Char('\012');
}

static Send_Byte(Ch)
    int Ch;
{
    int TCh;

    /* Listen for XOFF from the network */

    do
	{
	while ((TCh = Read_Modem()) >= 0)
	    if (TCh == XON) XOFF_Flag = False;
	    else if (TCh == XOFF) XOFF_Flag = True;
	}
    while (XOFF_Flag);

    while (!Write_Modem(Ch));
}

static Send_Masked_Byte(Ch)
    int Ch;
{
    /* Mask any protocol or flow characters */

    if (Ch == ETX || Ch == ENQ || Ch == DLE || Ch == NAK || Ch == XON || Ch == XOFF)
	{
	Send_Byte(DLE);
	Send_Byte(Ch + '@');
	}
    else Send_Byte(Ch);
}

static Send_ACK()
{
    Send_Byte(DLE);
    Send_Byte(Seq_Num + '0');
}

static Read_Byte()
{
    if ((Ch = Read_Modem()) < 0)
	{
	Start_Timer(Max_Time);

	do
	    {
	    if (Timer_Expired()) return Failure;
	    }
	while ((Ch = Read_Modem()) < 0);
	}

    return Success;
}

static Read_Masked_Byte()
{
    Seen_ETX = False;
    if (Read_Byte() == Failure) return Failure;

    if (Ch == DLE)
	{
	if (Read_Byte() == Failure) return Failure;
	Ch &= 0x1F;
	}
    else if (Ch == ETX) Seen_ETX = True;

    return Success;
}


static Do_Checksum(Ch)
    int Ch;
{
    Checksum <<= 1;
    if (Checksum > 255) Checksum = (Checksum & 0xFF) + 1;
    Checksum += Ch;
    if (Checksum > 255) Checksum = (Checksum & 0xFF) + 1;
}

static int Read_Packet(Action)
/**
 * Function:
 *	Receive a packet from the host.
 *
 * Inputs:
 *	Action -- the starting action
 *
 * Outputs:
 *	R_Buffer -- contains the packet just received
 *	R_Size -- length of the packet
 *
 * Returns:
 *	success/failure
 **/
    int Action;
{
    int Errors;
    int Next_Seq;

    Errors = 0;

    while (Errors < Max_Errors)
	switch (Action)
	    {
	    case R_Get_DLE:
		if (Read_Byte() == Failure) Action = R_Send_NAK;
		else if (Ch == DLE) Action = R_Get_B;
		else if (Ch == ENQ) Action = R_Send_ACK;
		break;

	    case R_Get_B:
		if (Read_Byte() == Failure) Action = R_Send_NAK;
		else if (Ch == 'B') Action = R_Get_Seq;
		else Action = R_Get_DLE;
		break;

	    case R_Get_Seq:
		if (Read_Byte() == Failure) Action = R_Send_NAK;
		else
		    {
		    Checksum = 0;
		    Next_Seq = Ch - '0';
		    Do_Checksum(Ch);
		    R_Size = 0;
		    Action = R_Get_Data;
		    }

		break;

	    case R_Get_Data:
		if (Read_Masked_Byte() == Failure) Action = R_Send_NAK;
		else if (Seen_ETX) Action = R_Get_Checksum;
		else if (R_Size == Packet_Size) Action = R_Send_NAK;
		else
		    {
		    R_Buffer[R_Size++] = Ch;
		    Do_Checksum(Ch);
		    }

		break;

	    case R_Get_Checksum:
		Do_Checksum(ETX);

		if (Read_Masked_Byte() == Failure) Action = R_Send_NAK;
		else if (Checksum != Ch) Action = R_Send_NAK;
		else if (Next_Seq == Seq_Num)
		    Action = R_Send_ACK;	/* Ignore duplicate packet */
		else if (Next_Seq != (Seq_Num + 1) % 10) Action = R_Send_NAK;
		else
		    {
		    Seq_Num = Next_Seq;
		    return Success;
		    }

		break;

	    case R_Send_NAK:
		Put_Char('-');
		Errors++;
		Send_Byte(NAK);
		Action = R_Get_DLE;
		break;

	    case R_Send_ACK:
		Send_ACK();
		Action = R_Get_DLE;
		break;
	    }

    return Failure;
}

static int Send_Packet(Size)
/**
 * Function:
 *	Send the specified packet to the host.
 *
 * Inputs:
 *	Size -- length of the packet
 *	S_Buffer -- the packet to send
 *
 * Outputs:
 *
 * Returns:
 *	success/failure
 **/
    int Size;				/* size of packet to send */
{
    int Action;
    int Next_Seq;
    int RCV_Num;
    int I;
    int Errors;

    Next_Seq = (Seq_Num + 1) % 10;
    Errors = 0;
    Action = S_Send_Packet;

    while (Errors < Max_Errors)
	switch (Action)
	    {
	    case S_Send_Packet:
		Checksum = 0;
		Send_Byte(DLE);
		Send_Byte('B');
		Send_Byte(Next_Seq + '0');
		Do_Checksum(Next_Seq + '0');

		for (I = 0; I < Size; I++)
		    {
		    Send_Masked_Byte(S_Buffer[I]);
		    Do_Checksum(S_Buffer[I]);
		    }

		Send_Byte(ETX);
		Do_Checksum(ETX);
		Send_Masked_Byte(Checksum);
		Action = S_Get_DLE;
		break;

	    case S_Get_DLE:
		if (Read_Byte() == Failure) Action = S_Timed_Out;
		else if (Ch == DLE) Action = S_Get_Num;
		else if (Ch == NAK)
		    {
		    Errors++;
		    Action = S_Send_Packet;
		    }

		break;

	    case S_Get_Num:
		if (Read_Byte() == Failure) Action = S_Timed_Out;
		else if (Ch >= '0' && Ch <= '9')
		    {
		    if (Ch == Seq_Num + '0')
			Action = S_Get_DLE;	/* Ignore duplicate ACK */
		    else if (Ch == Next_Seq + '0')
			{
			/* Correct sequence number */

			Seq_Num = Next_Seq;
			return Success;
			}
		    else if (Errors == 0) Action = S_Send_Packet;
		    else Action = S_Get_DLE;
		    }
		else if (Ch == WACK)
		    {
		    Delay(5000);	/* Sleep for 5 seconds */
		    Action = S_Get_DLE;
		    }
		else if (Ch == 'B') Action = S_Get_Seq;
		else Action = S_Get_DLE;
		break;

	    case S_Get_Seq:
		/**
		 * Start of a "B" protocol packet. The only packet that makes
		 * any sense here is a failure packet.
		 **/

		if (Read_Byte() == Failure) Action = S_Send_NAK;
		else
		    {
		    Checksum = 0;
		    RCV_Num = Ch - '0';
		    Do_Checksum(Ch);
		    I = 0;
		    Action = S_Get_Data;
		    }

		break;

	    case S_Get_Data:
		if (Read_Masked_Byte() == Failure) Action = S_Send_NAK;
		else if (Seen_ETX) Action = S_Get_Checksum;
		else if (I == Packet_Size) Action = S_Send_NAK;
		else
		    {
		    R_Buffer[I++] = Ch;
		    Do_Checksum(Ch);
		    }

		break;

	    case S_Get_Checksum:
		Do_Checksum(ETX);

		if (Read_Masked_Byte() == Failure) Action = S_Send_NAK;
		else if (Checksum != Ch) Action = S_Send_NAK;
		else if (RCV_Num != (Next_Seq + 1) % 10) Action = S_Send_NAK;
		else
		    {
		    /**
		     * Assume the packet is failure packet. It makes no
		     * difference since any other type of packet would be
		     * invalid anyway. Return failure to caller.
		     **/

		    Errors = Max_Errors;
		    }

		break;

	    case S_Timed_Out:
		Errors++;
		Action = S_Get_DLE;
		break;

	    case S_Send_NAK:
		Put_Char('-');
		Errors++;
		Send_Byte(NAK);
		Action = S_Get_DLE;
		break;
	    }

    return Failure;
}

static Send_Failure(Code)
/**
 * Function:
 *	Send a failure packet to the host.
 *
 * Inputs:
 *	Code -- failure code
 *
 * Outputs:
 *
 * Returns:
 **/
    char Code;
{
    S_Buffer[0] = 'F';
    S_Buffer[1] = Code;
    Send_Packet(2);
}

static int Receive_File(Name)
/**
 * Function:
 *	Download the specified file from the host.
 *
 * Inputs:
 *	Name -- ptr to the file name string
 *
 * Outputs:
 *
 * Returns:
 *	success/failure
 **/
    char *Name;
{
    int Data_File;

    if ((Data_File = creat(Name, O_RAW)) == -1)
	{
	Put_Msg("Cannot create file");
	Send_Failure('E');
	return Failure;
	}

    Send_ACK();

    for (;;)
	if (Read_Packet(R_Get_DLE) == Success)
	    switch (R_Buffer[0])
		{
		case 'N':		/* Data packet */

		    if (write(Data_File, &R_Buffer[1], R_Size - 1) != R_Size - 1)
			{
			/* Disk write error */

			Put_Msg("Disk write error");
			Send_Failure('E');
			close(Data_File);
			return Failure;
			}

		    if (Wants_To_Abort())
			{
			/* The user wants to kill the transfer */

			Send_Failure('A');
			close(Data_File);
			return Failure;
			}

		    Send_ACK();
		    Put_Char('+');
		    break;

		case 'T':		/* Transfer packet */

		    if (R_Buffer[1] == 'C') /* Close file */
			{
			Send_ACK();
			close(Data_File);
			return Success;
			}
		    else
			{
			/**
			 * Unexpected "T" packet. Something is rotten on the
			 * other end. Send a failure packet to kill the
			 * transfer cleanly.
			 **/

			Put_Msg("Unexpected packet type");
			Send_Failure('E');
			close(Data_File);
			return Failure;
			}

		case 'F':		/* Failure packet */
		    Send_ACK();
		    close(Data_File);
		    return Failure;
		}
	else
	    {
	    close(Data_File);
	    return Failure;
	    }
}

static int Send_File(Name)
/**
 * Function:
 *	Send the specified file to the host.
 *
 * Inputs:
 *	Name -- ptr to the file name string
 *
 * Outputs:
 *
 * Returns:
 *	success/failure
 **/
    char *Name;
{
    int Data_File;
    int N;

    if ((Data_File = open(Name, O_RDONLY | O_RAW)) == -1)
	{
	Put_Msg("Cannot access that file");
	Send_Failure('E');
	return Failure;
	}

    do
	{
	S_Buffer[0] = 'N';
	N = read(Data_File, &S_Buffer[1], Packet_Size - 1);

	if (N > 0)
	    {
	    if (Send_Packet(N + 1) == Failure)
		{
		close(Data_File);
		return Failure;
		}

	    if (Wants_To_Abort())
		{
		Send_Failure('A');
		close(Data_File);
		return Failure;
		}

	    Put_Char('+');
	    }
	}
    while (N > 0);

    if (N == 0)				/* end of file */
	{
	close(Data_File);
	S_Buffer[0] = 'T';
	S_Buffer[1] = 'C';
	return Send_Packet(2);
	}
    else
	{
	Put_Msg("Disk read error");
	Send_Failure('E');
	return Failure;
	}
}

int Transfer_File()
/**
 * Function:
 *	Transfer a file from/to the macro to/from the host.
 *
 * Inputs:
 *
 * Outputs:
 *
 * Returns:
 *	success/failure
 **/
{
    int I, N;
    char Name[64];

    XOFF_Flag = False;
    Seq_Num = 0;

    if (Read_Packet(R_Get_Seq) == Success)
	{
	if (R_Buffer[0] == 'T')		/* transfer packet */
	    {
	    /* Check the direction */

	    if (R_Buffer[1] != 'D' && R_Buffer[1] != 'U')
		{
		Send_Failure('N');	/* not implemented */
		return Failure;
		}

	    /* Check the file type */

	    if (R_Buffer[2] != 'A' && R_Buffer[2] != 'B')
		{
		Send_Failure('N');
		return Failure;
		}

	    /* Collect the file name */

	    if (R_Size - 3 > 63) N = 63;
	    else N = R_Size - 3;

	    for (I = 0; I < N; I++)
		Name[I] = R_Buffer[I + 3];

	    Name[I] = 0;

	    /* Do the transfer */

	    if (R_Buffer[1] == 'U') return Send_File(Name);
	    else return Receive_File(Name);
	    }
	else
	    {
	    Send_Failure('E');		/* wrong type of packet */
	    return Failure;
	    }
	}
    else return Failure;
}
