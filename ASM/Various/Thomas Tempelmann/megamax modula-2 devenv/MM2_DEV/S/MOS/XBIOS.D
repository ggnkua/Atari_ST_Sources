DEFINITION MODULE XBIOS;

(*
 * XBIOS-Definition nach TDI V3.00
 *
 * Die engl. Dokumentation stammt von Paul Curtis (TDI).
 *)

FROM SYSTEM IMPORT BYTE, WORD, LONGWORD, ADDRESS;

TYPE

  (* InitMouse *)
  MouseType = (DisableMouse,
               RelativeMouse,
               AbsoluteMouse,
               UnusedMouse,
               KeycodeMouse);

  ParamBlk = RECORD
               topMode: (OriginBottom, OriginTop);
               buttons: BYTE;
               xParam: BYTE;
               yParam: BYTE;
               (* for AbsoluteMouse mode only: *)
               xMax: CARDINAL;
               yMax: CARDINAL;
               xinitial: CARDINAL;
               yInitial: CARDINAL;
             END;

  Palette = ARRAY [0..15] OF CARDINAL;


  FlowFlavor = (NONE, XONXOFF, RTSCTS, XONXOFFRTSCTS);

  SerialDevice = (RS232, Keyboard, MIDI);

  SerialSpeed = (BPS19200, BPS9600, BPS4800, BPS3600, BPS2400, BPS2000,
                 BPS1800,  BPS1200, BPS600,  BPS300,  BPS200,  BPS150,
                 BPS134,   BPS110,  BPS75,   BPS50);


  IORECPTR = POINTER TO IOREC;

  IOREC = RECORD
            ibuf: ADDRESS;       (* pointer to buffer *)
            ibufsize: CARDINAL;  (* buffer size *)
            ibufhd: CARDINAL;    (* head index *)
            ibuftl: CARDINAL;    (* tail index *)
            ibuflow: CARDINAL;   (* low water mark *)
            ibufhi: CARDINAL;    (* high water mark *)
          END;


  PrtConfig = (DaisyWheel,    (* dot/daisy *)
               Monochrome,    (* colour/mono *)
               EpsonPrinter,  (* Atari/Epson *)
               Final,         (* draft/final *)
               RS232Port,     (* parallel/RS232 *)
               SingleSheet,   (* form-feed/single sheet *)
               PC6, PC7, PC8, (* unused: *)
               PC9, PC10, PC11,
               PC12, PC13, PC14,
               PC15);

  PrtConfigSet = SET OF PrtConfig;

CONST
  NoAlter = PrtConfigSet{DaisyWheel..PC15}; (* passed to ConfigurePrinter *)


TYPE
  KeyTransPtr = POINTER TO KeyTrans;

  KeyTrans = ARRAY [0..127 (* eigentlich: 0..132! *)] OF BYTE;

  KeyTablePtr = POINTER TO KeyTable;

  KeyTable = RECORD
               unshift: KeyTransPtr;
               shift: KeyTransPtr;
               capslock: KeyTransPtr;
             END;

CONST

  (* resolutions for GetScreenResolution and SetScreen *)
  Low    = 0;
  Medium = 1;
  High   = 2;


  (* normal value given for virgin floppies *)
  VirginMedia = 0E5E5H;


TYPE

  Timer = (TimerA, TimerB, TimerC, TimerD);

  KBVectorPtr = POINTER TO KBVector;

  KBVector = RECORD
               midi: ADDRESS;      (* MIDI input *)
               kbderr: ADDRESS;    (* keyboard error *)
               midierr: ADDRESS;   (* MIDI error *)
               statvec: ADDRESS;   (* ikdb status packet *)
               mousevec: ADDRESS;  (* mouse packet *)
               clockvec: ADDRESS;  (* clock packet *)
               joyvec: ADDRESS;    (* joystick packet *)
             END;


PROCEDURE InitMouse(type: MouseType; VAR param: ParamBlk; vec: ADDRESS);
  (* initialise mouse packet handler. *)

PROCEDURE ScreenPhysicalBase(): ADDRESS;
  (* get the screen's physical base address at beginning of next vblank. *)

PROCEDURE ScreenLogicalBase(): ADDRESS;
  (* get the screen's logical (GSX) base address. *)

PROCEDURE GetResolution(): INTEGER;
  (* return the screen's current resolution
     0: low, 1: medium, 2: high *)

PROCEDURE SetScreenBase(logLoc, physLoc: ADDRESS; rez: INTEGER);
  (* set screen base address and resolutions.
     logLoc: new logical screen location.
     physLoc: new physical screen resolution.
     rez: new resolution.
     NOTE: specifying -1 for any of the above will not change the
             current value. *)

PROCEDURE SetPalette(VAR palette: Palette);
  (* set the contents of the hardware palette register. *)

PROCEDURE SetColour(colourNum, colour: CARDINAL): CARDINAL;
  (* set the colour of a palette table entry.
     coluorNum: the palette entry to set colour of.
     coluor: the new colour.
     returns: the old value of the palette entry. *)

PROCEDURE FloppyRead(buf: ADDRESS; drive: CARDINAL;
                     sector, track, side: CARDINAL;
                     count: CARDINAL): INTEGER;
  (* read floppy disk sector(s) into buffer.
     buf: the buffer origin for the data.
     drive: 0 => A:, 1 => B:
     sector: sector number to start read from, normally 1..9.
     track: the track to seek to.
     side: the side to select.
     count: the number of sectors to read.
     returns: 0 => no error, otherwise DOS error code. *)

PROCEDURE FloppyWrite(buf: ADDRESS; drive: CARDINAL;
                      sector, track, side: CARDINAL;
                      count: CARDINAL): INTEGER;
  (* write buffer to floppy disk sector(s).
     parameters as for FloppyRead, except data is written from the buffer.
     returns: 0 => no error, otherwise DOS error code. *)

PROCEDURE FloppyFormat(buf: ADDRESS; drive: CARDINAL;
                       spt, track, side: CARDINAL;
                       interleave, virgin: CARDINAL): INTEGER;
  (* format a floppy disk track.
     buf: buffer large enough to hold bit image of a track (8K for 9 spt)
     drive: the drive to format, 0 => A:, 1 => B:
     spt: the number of sectors per track, normally 9
     track: the track to format, 0 through 79.
     side: the side to format, 0 or 1.
     interleave: the interleave factor, normally 1.
     virgin: the word fill value for new sectors.
     returns: 0 => no error, otherwise DOS error code.
     note: on return buf holds zero terminated list of sectors that would
           not format. *)

PROCEDURE MIDIWS(VAR string: ARRAY OF BYTE; len: CARDINAL);
  (* write a string of characters to the MIDI port.
     str: the string to write.
     len: the number of characters to write - 1. *)

PROCEDURE MFPint(intNo: CARDINAL; vector: PROC);
  (* set MFP interrupt vector.
     intNo: the MFP interrupt vector to set.
     vector: the interrupt handler code. *)

PROCEDURE IORec(dev: SerialDevice): IORECPTR;
  (* return pointer to serial device IO record.
     NOTE: for the RS232 device, an output record immediately follows the
             input record returned by this function. It may be accessed by:
           VAR x: IORECPTR;
           x := IORECPTR(LONGCARD(IORec(RS232))+LONGCARD(TSIZE(IORec))); *)

PROCEDURE ConfigureRS232(speed: SerialSpeed;
                         flowctl: FlowFlavor;
                         ucr, rsr, tsr, scr: INTEGER);
  (* configure RS232 port.
     speed: the new RS232 speed.
     flowctl: the handshaking used.
     ucr, rsr, tsr, scr: set the appropriate 68901 registers. *)

PROCEDURE SetKeyTable(VAR unshift, shift, capslock: KeyTransPtr): KeyTablePtr;
  (* set pointers to keyboard translation tables. *)

PROCEDURE Random(): LONGCARD;
  (* return a random number. *)

PROCEDURE PrototypeBootSector(buf: ADDRESS; serialNo: LONGINT;
                              disktype: INTEGER; execFlag: INTEGER);
  (* prototype an image of a boot sector.
     buf: the buffer to put the image into. (512 bytes)
     serialNo: -1 => leave boot sector serial number unchanged.
               00000000..00FFFFFF => new serial number for disk.
               01000000..FFFFFFFE => generate random serial number.
     disktype: -1 => leave information alone.
                0 = 40 tracks, SS (180K)
                1 = 40 tracks, DS (360K)
                2 = 80 tracks, SS (360K)
                3 = 80 tracks, DS (720K)
     execFlag: 1 => bootable, 0 => non-bootable, -1 => leave alone. *)

PROCEDURE FloppyVerify(buf: ADDRESS; drive: CARDINAL;
                       sector, track, side: CARDINAL;
                       count: CARDINAL): INTEGER;
  (* verify floppy disk sectors are readable.
     parameters as for FloppyRead, except buffer must br 1024 bytes long. *)

PROCEDURE ScreenDump;
  (* dump screen to printer. *)

PROCEDURE ConfigureCursor(rate, attrib: INTEGER): INTEGER;
  (* configure cursor blink rate and attributes.
     rate: based on video scan rate; -1 => no change.
     attrib: 0 => flash, 1 => steady, -1 => no change.
     returns: hi byte = old blink rate, lo byte = old attributes. *)

PROCEDURE SetDateTime(datetime: LONGCARD);
  (* set the keyboard date and time.
     datetime: DOS format date & time; hi word = date, lo word = time. *)

PROCEDURE GetDateTime(): LONGCARD;
  (* get the date and time.
     returns: DOS format date & time. *)

PROCEDURE BiosKeys;
  (* restore keymappings to power up settings *)

PROCEDURE KeyboardWS(VAR str: ARRAY OF BYTE; len: CARDINAL);
  (* write string to intelligent keyboard.
     str: the string to write.
     len: the number of characters to write - 1. *)

PROCEDURE DisableInterrupt(intNo: CARDINAL);
  (* disable given 68901 interrupt. *)

PROCEDURE EnableInterrupt(intNo: CARDINAL);
  (* enable given 68901 interrupt. *)

PROCEDURE GIRead(regno: CARDINAL): CARDINAL;
  (* read register on the sound chip.
     regno: the register number to read.
     returns: data in the register. *)

PROCEDURE GIWrite(regno, data: CARDINAL);
  (* write register on the sound chip.
     regno: the register number to write.
     data: the data to write to the register. *)

PROCEDURE GIOffBit(bitno: CARDINAL);
  (* set a bit in the port A register to zero.
     bitno: the bit number to set to zero. *)

PROCEDURE GIOnBit(bitno: CARDINAL);
  (* set a bit in the port A register to one.
     bitno: the bit number to set to one. *)

PROCEDURE SetTimerInterrupt(timer: Timer; control, data: CARDINAL; vec: PROC);
  (* set an interrupt handler for timer.
     timer: the timer to install interrupt handler for.
     control: timer's control register setting.
     data: byte put into timer's data register.
     vec: the interrupt procedure. *)

PROCEDURE DoSound(x: ADDRESS);
  (* set sound daemon's "program counter".
     x: the new program counter; program is a sequence of bytes of the
        form:
        { <opcode> <operand1> [<operand2> <operand3> ] }
        00 - 0F   sound register <opcode> := <operand1>
        80        temporary register := <operand1>
        81        sound register <operand1> := temporary register
                  INC(temporary register,<operand2>) (*signed*)
                  IF temporary register = <operand3> THEN
                    go to next instuction
                  ELSE
                    wait for next update
                    repeat instruction
                  END
        82 - FF   IF <operand1> = 0 THEN stop sound daemon
                  ELSE set next update to <operand1> 50Hz ticks time
                  END
        e.g. data for "bell" type sound:
        00 34 01 00 02 00 03 00 04 00 05 00 06 00 07 FE 08 10 09 00
        0A 00 0B 00 0C 10 0D 09 FF 00
*)

PROCEDURE ConfigurePrinter(config: PrtConfigSet): PrtConfigSet;  (*0.10a*)
  (* configure printer.
     config: the new printer configuration.
     returns: old printer configuration.
     NOTE: ConfigurePrinter(NoAlter) does not alter the old setting. *)

PROCEDURE KeyboardVectors(): KBVectorPtr;
  (* return pointer to keyboard vector table. *)

PROCEDURE KeyboardRate(initial, repeat: INTEGER): CARDINAL;
  (* set keyboard repeat rate and delay.
     initial: -1 => no change, otherwise initial delay, 50Hz.
     repeat: -1 => no change, otherwise repeat rate, 50Hz.
     returns: hi byte = old initial delay, lo byte = old repeat rate. *)

PROCEDURE VSync;
  (* wait for next vertical blank interrupt. *)

PROCEDURE SuperExec(Code: PROC);
  (* Run code in supervisor mode with supervisor stack.
     Code: The code to run in supervisor mode, terminated with RTS.
     Note: The code is run with the supervisor stack. Do NOT attempt
           to allocate large amounts of local data as the supervisor
           stack will overflow. Note that the code in the "Code" proc
           must have stack checking turned off (with a $S- directive)
           otherwise a "stack overflow" error will be generated on entry
           to the procedure. *)

PROCEDURE PuntAES;
  (* Throws away the GEM AES, freeing up memory. A re-boot will always be
     performed after this call (unless AES is in ROM) *)

PROCEDURE BlitMode (flag: INTEGER): BITSET;
  (* Is only available on Blitter TOS (version 1.2) and higher! *)

PROCEDURE FlopRate (drive: CARDINAL; rate: INTEGER): INTEGER;
  (* Returns current seek rate of the floppy disk if -1 is passed to 'rate'.
     Otherwise the new 'rate' value is set.
     Works with ALL TOS-versions!
       drive: 0 => A:, 1 => B:, other values are not allowed!
       rate: -1 -> return current rate, 0: 6ms, 1: 12ms, 2: 2ms, 3: 3ms  *)

(*
 * Die folgenden Funktionen sind nur auf einem Atari TT verfÅgbar:
 *)

PROCEDURE Bconmap (devNo: WORD): LONGWORD;

PROCEDURE DMAread (sector: LONGCARD; count: CARDINAL; buffer: ADDRESS;
                   devNo: CARDINAL): INTEGER;
PROCEDURE DMAwrite (sector: LONGCARD; count: CARDINAL; buffer: ADDRESS;
                   devNo: CARDINAL): INTEGER;

PROCEDURE NVMaccess (op, start, count: CARDINAL; buffer: ADDRESS): INTEGER;

PROCEDURE EsetShift (shftMode: WORD): WORD;
PROCEDURE EgetShift (): WORD;
PROCEDURE EsetBank (bankNum: INTEGER): INTEGER;
PROCEDURE EsetColor (colorNum, color: INTEGER): INTEGER;
PROCEDURE EsetPalette (colorNum, count: INTEGER; palettePtr: ADDRESS);
PROCEDURE EgetPalette (colorNum, count: INTEGER; palettePtr: ADDRESS);
PROCEDURE EsetGray (switch: INTEGER): INTEGER;
PROCEDURE EsetSmear (switch: INTEGER): INTEGER;

END XBIOS.
