DEFINITION MODULE BIOS;

(*
 * BIOS-Definition nach TDI V3.00
 *
 * Die Dokumentation stammt von Paul Curtis (TDI).
 *)


FROM SYSTEM IMPORT ADDRESS;


TYPE Device = (PRT,   (* printer, parallel port *)
               AUX,   (* aux device, the serial port *)
               CON,   (* console, the screen *)
               HSS,   (* high speed serial, MIDI port: Atari extension *)
               KDB,   (* intelligent keyboard: Atari extension *)
               RAW);  (* raw console device: Atari extension *)

TYPE RW = (Read,                 (* normal read *)
           Write,                (* normal write *)
           ReadNoMediaChange,    (* read, do not alter media-change *)
           WriteNoMediaChange);  (* write, do not alter media-change *)

TYPE MCState = (NoChange,        (* definately no change *)
                MayHaveChanged,  (* media might have changed *)
                Changed);        (* definately has changed *)

TYPE BPBPtr = POINTER TO BPB ;
     BPB = RECORD (* BIOS Paramter Block *)
             recsiz : CARDINAL ; (* physical sector size in bytes *)
             clsiz  : CARDINAL ; (* cluster size in sectors *)
             clsizb : CARDINAL ; (* cluster size in bytes *)
             rdlen  : CARDINAL ; (* root directory length in sectors *)
             fsiz   : CARDINAL ; (* FAT size in sectors *)
             fatrec : CARDINAL ; (* sector # of 1st data sector of 2nd FAT *)
             datrec : CARDINAL ; (* sector # of 1st data sector *)
             numcl  : CARDINAL ; (* number of data clusters on disk *)
             bflags : CARDINAL ; (* misc flags *)
           END ;

TYPE
  DriveSet = SET OF [0..31];

TYPE
  KBShiftBits = (RightShift, LeftShift, ControlKey, AlternateKey,
                 CapsLock, RightMouseButton, LeftMMouseButton);
  KBShifts = SET OF KBShiftBits;


PROCEDURE BConStat(dev: Device): BOOLEAN;
  (* return input status of device.

     dev: the device to return status of.
     returns: TRUE => characters waiting to be read. *)


PROCEDURE BCosStat(dev: Device): BOOLEAN;
  (* return output status of device.

     dev: the device to return status of.
     returns: TRUE => no characters waiting to be written. *)


PROCEDURE BConIn(dev: Device): LONGCARD;
  (* read character from device. (waits for character)

     dev: the device to read from.
     returns: character. For CON, IBM-PC compatible scan code in
       hi word, character in low word. *)


PROCEDURE BConOut(dev: Device; c: CHAR);
  (* write character to device. (waits for device ready)

     dev: the device to write to.
     c: the character to write. *)


PROCEDURE RWAbs(rw: RW; buf: ADDRESS; count, recno, dev: CARDINAL): LONGINT;
  (* read/write absolute sectors.

     rw: the type of read/write operation.
     buf: the buffer to write from/read to.
     count: number of sectors to transfer.
     recno: logical sector number to start transfer at,
     dev: device, 0 => A:, 1 => B:, > 2 for hard disk, network, etc.

     returns: 0 => OK, otherwise error code. *)


PROCEDURE SetException(vecnum: CARDINAL; vec: ADDRESS);
  (* set exception vector.

     vecnum: vector to set.
     vec: the code to execute on exception.

     returns: old vector.

     notes: $00-$FF: reserved for 68000
            $100-$107: reserved for GEMDOS.
                       $100 = system timer interrupt,
                       $101 = critical error handler.
                       $102 = Process terminate hook. *)


PROCEDURE GetException(vecnum: CARDINAL): ADDRESS;
  (* get exception vector.

     vecnum: as for SetException.
     returns: current exception handler address. *)


PROCEDURE TimerCalibration(): LONGCARD;
  (* get timer calibration value.

     returns: timer calibration value to nearest millisecond. *)


PROCEDURE GetBPB(dev: CARDINAL): BPBPtr ;
  (* get bios parameter block for device.

     dev: device to get BPB for; 0 => A:, 1 => B: etc.

     returns: 0 => BPB can't be determined, otherwise address of
                parameter block. *)


PROCEDURE MediaChange(dev: CARDINAL): MCState;
  (* returns media change state for a device.

     dev: the device to return change state of, 0 => A:, etc.

     returns: the media change state. *)


PROCEDURE DriveMap(): DriveSet;
  (* return drives on line.

     returns: 1 in bit position means drive on line, otherwise
                no drive connected. *)


PROCEDURE SetKBShift(keys: KBShifts);
  (* set keyboard shift key state.

     keys: the new keyboard shift key state. *)


PROCEDURE GetKBShift(): KBShifts;
  (* return keyboard shift key state.

     returns: the current keyboard shift key state. *)


END BIOS.
