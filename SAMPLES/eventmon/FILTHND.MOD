(******************************************************************************)
(* MODULE:      FiltHnd                                        ME - 25.05.96  *)
(* DESCRIPTION: Handles several kinds of filters                              *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 25.05.96  ME      Initial Version                                          *)
(******************************************************************************)
(* Filter Type ID's:                                                          *)
(* WH_JOURNALRECORD   0                                                       *)
(* WH_JOURNALPLAYBACK 1                                                       *)
(* WH_KEYBOARD        2                                                       *)
(* WH_GETMESSAGE      3                                                       *)
(* WH_CALLWNDPROC     4                                                       *)
(* WH_CBT             5                                                       *)
(* WH_SYSMSGFILTER    6                                                       *)
(* WH_MOUSE           7                                                       *)
(* WH_HARDWARE        8                                                       *)
(* WH_DEBUG           9                                                       *)
(* WH_SHELL          10                                                       *)
(******************************************************************************)
MODULE FiltHnd;  

IMPORT
   W := Windows, Utils, SYSTEM, Strings;

CONST
  MAX_FILTERS = 11;                        (* amount of filter types          *)

TYPE 
  FilterElemT = RECORD                     (* Description of one filter       *)
                     lpfProc : W.FARPROC;  (* pointer to hook function        *)
                     hHook   : W.HHOOK;    (* handle returned by SetWindowsh. *)
                     bActive : BOOLEAN;    (* indicates current state         *)
                   END;
VAR
  i : INTEGER;
  flt : ARRAY MAX_FILTERS OF FilterElemT;  (* set of filters                  *)

  
(*============================================================================*)
(* PURPOSE:  Inserts specified filter in windows hook chain,                  *)
(*           returns TRUE on success.                                         *)
(* COMMENTS:                                                                  *)
(*============================================================================*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* type           type of filter (WH_...)                                     *)
(*============================================================================*)
PROCEDURE InsertFilter*(type : INTEGER) : BOOLEAN; 

BEGIN 
  IF ((type >= 0) & (type < MAX_FILTERS) & ~flt[type].bActive) THEN
    flt[type].hHook := W.SetWindowsHook(type, flt[type].lpfProc);
    flt[type].bActive := flt[type].hHook # W.NULL;
    IF (type = W.WH_CALLWNDPROC) OR (type = W.WH_GETMESSAGE) THEN        
      flt[type].bActive := TRUE            (* this filter returns always NULL *)           
    END;
    RETURN flt[type].bActive;
  ELSE
    RETURN FALSE
  END
END InsertFilter; 


(*============================================================================*)
(* PURPOSE:  Removes specified filter from windows hook chain,                *)
(*           returns TRUE on success.                                         *)
(* COMMENTS:                                                                  *)
(*============================================================================*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* type           type of filter (WH_...)                                     *)
(*============================================================================*)
PROCEDURE RemoveFilter*(type : INTEGER) : BOOLEAN; 
  VAR r : W.BOOL;
    
BEGIN
  IF ((type >= 0) & (type < MAX_FILTERS) & flt[type].bActive) THEN 
    r := W.UnhookWindowsHook(type,flt[type].lpfProc);
    flt[type].bActive := ~(r # 0); 
    RETURN ~flt[type].bActive;
  ELSE
    RETURN FALSE
  END
END RemoveFilter;


(*============================================================================*)
(* PURPOSE:  Returns handle of identified filter                              *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*============================================================================*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* type           type of filter (WH_...)                                     *)
(*============================================================================*)
PROCEDURE GetHandle*(type : INTEGER) : W.HHOOK; 
BEGIN
  IF ((type >= 0) & (type < MAX_FILTERS) & flt[type].bActive) THEN 
    RETURN flt[type].hHook
  ELSE                                 
    RETURN W.NULL;
  END
END GetHandle;


(*============================================================================*)
(* PURPOSE:  Register the procedure instance of identified filter,            *)
(*                                                                            *)
(* COMMENTS: Each filter must be registered before use.                       *)
(*============================================================================*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* type           type of filter (WH_...)                                     *)
(* filterProc     procedure instance                                          *)
(*============================================================================*)
PROCEDURE RegisterFilter*(type : INTEGER; filterProc : W.FARPROC) : BOOLEAN; 
BEGIN 
  IF ((type >= 0) & (type < MAX_FILTERS)) THEN
    flt[type].lpfProc := filterProc; 
    RETURN TRUE    
  ELSE;
    RETURN FALSE
  END 
END RegisterFilter;


(*============================================================================*)
(* PURPOSE:  Returns activation state of identified filter                    *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*============================================================================*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* type           type of filter (WH_...)                                     *)
(*============================================================================*)
PROCEDURE GetState*(type : INTEGER) : BOOLEAN; 
BEGIN
  ASSERT((type >= 0) & (type < MAX_FILTERS));
  RETURN flt[type].bActive;
END GetState;


BEGIN
  FOR i := 0 TO MAX_FILTERS-1 DO
    flt[i].lpfProc := W.NULL;
    flt[i].hHook   := W.NULL; 
    flt[i].bActive := FALSE;  
  END;
END FiltHnd.
