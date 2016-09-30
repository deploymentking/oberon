(******************************************************************************)
(* MODULE:      FlagTab                                         ME - 29.06.96 *)
(* DESCRIPTION: Defines Flags for message groups                              *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 29.05.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE FlagTab;

CONST 
  WIN_3_XX* = 768;             (* 0x0300 *)           (* windows version flag *)
  WIN_95*   = 1024;            (* 0x0400 *)
                                                      (* message group flags  *)
  MSG_TYPE_MOUSE*  =     1;    (* 0x0001 *)
  MSG_TYPE_WND*    =     2;    (* 0x0002 *)
  MSG_TYPE_INPUT*  =     4;    (* 0x0004 *)
  MSG_TYPE_SYS*    =     8;    (* 0x0008 *)
  MSG_TYPE_INIT*   =    16;    (* 0x0010 *)
  MSG_TYPE_CLPBRD* =    32;    (* 0x0020 *)
  MSG_TYPE_DDE*    =    64;    (* 0x0040 *)
  MSG_TYPE_NCL*    =   128;    (* 0x0080 *)
  MSG_TYPE_BM*     =   256;    (* 0x0100 *)
  MSG_TYPE_CB*     =   512;    (* 0x0200 *)
  MSG_TYPE_LB*     =  1024;    (* 0x0400 *)
  MSG_TYPE_EM*     =  2048;    (* 0x0800 *)
  MSG_TYPE_STM*    =  4096;    (* 0x1000 *)
  MSG_TYPE_OTHER*  = 16384;    (* 0x4000 *)
  MSG_TYPE_WMUSER* = 32768;    (* 0x8000 *)
  MSG_TYPE_ALL*    = 65535;    (* 0xFFFF *)

BEGIN
END FlagTab.
