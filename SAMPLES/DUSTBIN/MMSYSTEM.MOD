DEFINITION MMSystem;

IMPORT W:=Windows;

(****************************************************************************

                    General constants and data types

****************************************************************************)

(* general constants *)
CONST
  MaxPNameLen      =  32;    (* max product name length (including NULL) *)
  MaxErrorLength   = 128;    (* max error text length (including NULL) *)

(* general data types *)
TYPE
  Version = W.WORD;             (* major (high byte), minor (low byte) *)

(****************************************************************************

                String resource number bases (internal use)

****************************************************************************)

CONST
  mmsyserr_Base          = 0;
  waverr_Base            = 32;
  midierr_Base           = 64;
  timerr_Base            = 96;
  joyerr_Base            = 160;
  mcierr_Base            = 256;

  mci_String_Offset      = 512;
  mci_VD_Offset          = 1024;
  mci_CD_Offset          = 1088;
  mci_Wave_Offset        = 1152;
  mci_Seq_Offset         = 1216;

(****************************************************************************

                        General error return values

****************************************************************************)

(* general error return values *)
CONST
  mmsyserr_NoError      = 0;                  (* no error *)
  mmsyserr_Error        = mmsyserr_Base + 1;  (* unspecified error *)
  mmsyserr_BadDeviceID  = mmsyserr_Base + 2;  (* device ID out OF range *)
  mmsyserr_NotEnabled   = mmsyserr_Base + 3;  (* driver failed enable *)
  mmsyserr_Allocated    = mmsyserr_Base + 4;  (* device already allocated *)
  mmsyserr_InvalHandle  = mmsyserr_Base + 5;  (* device handle is invalid *)
  mmsyserr_NoDriver     = mmsyserr_Base + 6;  (* no device driver present *)
  mmsyserr_NoMem        = mmsyserr_Base + 7;  (* memory allocation error *)
  mmsyserr_NotSupported = mmsyserr_Base + 8;  (* PROCEDURE [WINDOWS]  isn't supported *)
  mmsyserr_BadErrNum    = mmsyserr_Base + 9;  (* error value out OF range *)
  mmsyserr_InvalFlag    = mmsyserr_Base + 10; (* invalid flag passed *)
  mmsyserr_InvalParam   = mmsyserr_Base + 11; (* invalid parameter passed *)
  mmsyserr_LastError    = mmsyserr_Base + 11; (* last error in range *)

(****************************************************************************

                            Sound support

****************************************************************************)

(* flag values for wFlags parameter *)
CONST
  snd_Sync            = 0;  (* play synchronously (default) *)
  snd_Async           = 1;  (* play asynchronously *)
  snd_NoDefault       = 2;  (* don't use default sound *)
  snd_Memory          = 4;  (* lpszSoundName points to a memory file *)
  snd_Loop            = 8;  (* loop the sound until next sndPlaySound *)
  snd_NoStop          = 16;  (* don't stop any currently playing sound *)


PROCEDURE [WINDOWS]  sndPlaySound(lpszSoundName: W.ADR; uFlags: W.WORD): W.BOOL;

PROCEDURE [WINDOWS]  mmsystemGetVersion(): W.WORD;
PROCEDURE [WINDOWS]  OutputDebugStr(P: W.ADR);


END MMSystem.
