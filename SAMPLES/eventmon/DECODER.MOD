(******************************************************************************)
(* MODULE:      Decoder                                         ME - 05.06.96 *)
(* DESCRIPTION: Decode Messages to Output string                              *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 05.05.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE Decoder;

IMPORT W := Windows, WinConst, Strings, Utils, SYSTEM;
 
CONST
  TEXT_ONLY    = 0;                        (* output states                   *)
  TEXT_AND_HEX = 1;
  HEX_ONLY     = 2;

VAR                                        (* holds current output mode       *)
  mode : INTEGER;
  
(*============================================================================*)
(* PURPOSE:  Toggle to text mode                                              *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*)
PROCEDURE SetTextMode*(); 
BEGIN
  mode := TEXT_ONLY
END SetTextMode;


(*============================================================================*)
(* PURPOSE:  Toggle to text and hex mode                                      *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*)
PROCEDURE SetTextAndHexMode*(); 
BEGIN
  mode := TEXT_AND_HEX;
END SetTextAndHexMode;


(*============================================================================*)
(* PURPOSE:  Toggle hex mode                                                  *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(*                                                                            *)
(*============================================================================*)
PROCEDURE SetHexMode*(); 
BEGIN
  mode := HEX_ONLY;
END SetHexMode;


(*============================================================================*)
(* PURPOSE:  Covert number to hex string                                      *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* w              word                                                        *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE NumToHexStr(w : INTEGER; VAR s : ARRAY OF CHAR);
VAR 
  res,                                     (* some strings nedded to form     *)
  formatStr : ARRAY 32 OF CHAR;            (* hex string                      *)
  argList   : ARRAY 1 OF INTEGER;
  r : INTEGER;
 
BEGIN
  res := "";
  formatStr := "0x%8.8X"; 
  argList[0] := w;
  r := W.wvsprintf(SYSTEM.ADR(res),
                   SYSTEM.ADR(formatStr), 
                   SYSTEM.ADR(argList));   
  Strings.Append(s,res); 
END NumToHexStr;  


(*============================================================================*)
(* PURPOSE:  Prepare common output string (adddress of window handle )        *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWnd           handle to window                                            *)
(* str            string to receive output                                    *) 
(*============================================================================*) 
PROCEDURE PrepareHeader(hWnd : W.HWND; VAR s : ARRAY OF CHAR);
VAR 
  adr : ARRAY 16 OF CHAR;                  (* some strings nedded to form     *)
 
BEGIN
  adr := ""; 
  IF W.IsWindow(hWnd) = W.false THEN 
    adr := "invalid handle"
  ELSE
    NumToHexStr(hWnd,adr);
  END;
  Strings.Append(s,adr); 
END PrepareHeader;

(*============================================================================*)
(* PURPOSE:  Decode wParam of CallWndProc-filter and adds result to "str".    *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         current task flag                                           *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE CallWndProc_wPText(wParam : W.WORD; VAR str : ARRAY OF CHAR); 
VAR 
  intStr  : ARRAY 12 OF CHAR;
   
BEGIN
  Strings.Append(str," fTask:");  
  Strings.Str(wParam,intStr); Strings.Append(str,intStr)       
END CallWndProc_wPText;  


(*============================================================================*)
(* PURPOSE:  Decode lParam of CallWndProc-filter and adds result to "str".    *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* lParam         address of structure with message data                      *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE CallWndProc_lPText(lParam : W.DWORD; VAR str : ARRAY OF CHAR); 

TYPE msgStructP = POINTER TO RECORD
                    lParam : W.LPARAM; 
                    wParam : W.WPARAM;
                    uMsg   : W.UINT;
                    hWnd   : W.HWND;
                  END;
  
VAR 
  p : msgStructP;
  adr : ARRAY 32 OF CHAR;              (* address information             *)
      
BEGIN 
  p := SYSTEM.VAL(msgStructP,lParam);  ASSERT(p # NIL);
  Strings.Append(str," to Wnd:"); 
  adr := ""; 
  IF W.IsWindow(p.hWnd) = W.false THEN 
    adr := "invalid"
  ELSE
    NumToHexStr(p.hWnd,adr);
  END;
  Strings.Append(str,adr);
  WinConst.ExpandMsg(p.uMsg,p.wParam,p.lParam,str);
END CallWndProc_lPText;  


(*============================================================================*)
(* PURPOSE:  Decode lParam of GetMsgProc-filter and adds result to "str".     *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* lParam         address of structure with message data                      *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE GetMsgProc_lPText(lParam : W.DWORD; VAR str : ARRAY OF CHAR);
TYPE 
  msgStructP = POINTER TO RECORD
                 hwnd : W.HWND;
                 message : W.UINT;
                 wParam : W.WPARAM;
                 lParam : W.LPARAM;
                 time   : W.DWORD;
                 pt     : W.POINT;
               END;
               
VAR 
  p : msgStructP;                          (* pointer to msg-structure        *)
  adr : ARRAY 32 OF CHAR;                  (* address information             *)
      
BEGIN 
  p := SYSTEM.VAL(msgStructP,lParam);  ASSERT(p # NIL);
  Strings.Append(str," in Wnd:");          (* build window information        *)
  adr := "";   
  IF W.IsWindow(p.hwnd) = W.false THEN 
    adr := "invalid"
  ELSE
    NumToHexStr(p.hwnd,adr);
  END;
  Strings.Append(str,adr);
  WinConst.ExpandMsg(p.message,p.wParam,p.lParam,str);
END GetMsgProc_lPText;  


(*============================================================================*)
(* PURPOSE:  Convert wParam to hex digits and adds result to "str".           *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         depends on message                                          *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE GetwPHex(wParam : W.WORD; VAR str : ARRAY OF CHAR); 
VAR 
  hexStr  : ARRAY 12 OF CHAR;
   
BEGIN 
  Strings.Append(str," wP:"); Strings.HexStr(wParam,hexStr); Strings.Append(str,hexStr)
END GetwPHex;


(*============================================================================*)
(* PURPOSE:  Convert lParam to hex digits and adds result to "str".           *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* lParam         depends on message                                          *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE GetlPHex(lParam : W.DWORD; VAR str : ARRAY OF CHAR); 
VAR 
  hexStr  : ARRAY 12 OF CHAR;
   
BEGIN 
  Strings.Append(str," lP:"); Strings.HexStr(lParam,hexStr); Strings.Append(str,hexStr)
END GetlPHex;


(*============================================================================*)
(* PURPOSE:  Compares handle "target" with window handle of msg-structure     *)
(*           fitting to CallWndProc - callback function                       *)
(*                                                                            *)
(* COMMENTS: Returns TRUE, if current window is target to spy on.             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* target         window to spy on                                            *)
(* thisWnd        current window                                              *)
(*============================================================================*)
PROCEDURE IsTarget(target, thisWnd : W.HWND) : BOOLEAN;

VAR 
  hParent, hCurr : W.HWND;
  s, n : ARRAY 64 OF CHAR;
  r : INTEGER;

BEGIN
  s := "";  n := "";
  IF (W.IsWindow(thisWnd) # W.NULL) THEN
     hParent := W.GetParent(thisWnd);
     IF hParent = W.NULL THEN              (* curr. handle is already parent   *)
       RETURN thisWnd = target;
     ELSE                                  (* child window hit, so evaluate    *) 
       WHILE hParent # W.NULL DO           (* parent handle                    *)
         hCurr := hParent;
         hParent := W.GetParent(hCurr);
       END; 
       RETURN (W.IsWindow(hCurr) # W.NULL) & (hCurr = target); 
     END
  ELSE
    RETURN FALSE                           (* invalid window handle           *)
  END
END IsTarget;   


(*============================================================================*)
(* PURPOSE:  Prepare output string for WH_CALLWNDPROC filter                  *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWnd           handle of target window                                     *)
(* wParam         current task-flag                                           *)
(* lParam         address of structure with message data                      *)
(* msgFlag        indicates message group selection                           *)
(* str            string to receive output                                    *) 
(*============================================================================*)
PROCEDURE CallWndProc*(hWnd : W.HWND;
                       wParam : W.WORD; 
                       lParam : W.DWORD;
                       msgFlag : LONGINT;
                       VAR str : ARRAY OF CHAR
                      ) : BOOLEAN;

TYPE 
  msgStructP = POINTER TO RECORD            (* message structure              *)
                            lParam : W.LPARAM; 
                            wParam : W.WPARAM;
                            uMsg   : W.UINT;
                            hWnd   : W.HWND;
                          END;

VAR
  p : msgStructP;                           (* pointer to msg structure       *)
  r : INTEGER;                              (* dummy return value             *)
  msg : ARRAY 64 OF CHAR;
  
BEGIN
  p := SYSTEM.VAL(msgStructP,lParam);  ASSERT(p # NIL); msg := "";
  
  IF IsTarget(hWnd, p.hWnd) &               (* target window hit / message    *)
    WinConst.RequestMsg(p.uMsg,msgFlag,msg) THEN  (* request successfull      *) 
    PrepareHeader(hWnd,str);
    Strings.Append(str," SendMsg: "); Strings.Append(str,msg);
    IF mode = TEXT_ONLY THEN 
      CallWndProc_wPText(wParam,str); CallWndProc_lPText(lParam,str); 
    ELSIF mode = TEXT_AND_HEX THEN 
      GetwPHex(wParam,str); GetlPHex(lParam,str); 
      CallWndProc_wPText(wParam,str); CallWndProc_lPText(lParam,str); 
    ELSIF mode = HEX_ONLY THEN 
      GetwPHex(wParam,str); 
      GetlPHex(lParam,str); 
    ELSE
      Strings.Append(str,"Decoder.CallWndProc: ERROR: Invalid display mode !");
    END;
    RETURN TRUE

  ELSE                                      (* skip event                     *)
    RETURN FALSE
  END
END CallWndProc;


(*============================================================================*)
(* PURPOSE:  Prepare output string for WH_GETMESSAGE filter                   *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* hWnd           handle of target window                                     *)
(* wParam         should specify a NULL value.                                *)
(* lParam         address of structure with message data                      *)
(* msgFlag        indicates message group selection                           *)
(* str            string to receive output                                    *) 
(*============================================================================*)
PROCEDURE GetMsgProc*(hWnd : W.HWND;
                      wParam : W.WORD; 
                      lParam : W.DWORD;
                      msgFlag : LONGINT;
                      VAR str : ARRAY OF CHAR
                     ) : BOOLEAN;

TYPE 
  msgStructP = POINTER TO RECORD            (* message structure              *)
                 hwnd : W.HWND;
                 message : W.UINT;
                 wParam : W.WPARAM;
                 lParam : W.LPARAM;
                 time   : W.DWORD;
                 pt     : W.POINT;
               END;
VAR 
  p : msgStructP;                           (* pointer to message structure   *)
  r : INTEGER;                              (* dummy return value             *)
  msg : ARRAY 64 OF CHAR;

BEGIN
  p := SYSTEM.VAL(msgStructP,lParam);  ASSERT(p # NIL); msg := "";

  IF IsTarget(hWnd, p.hwnd) & (p.wParam # -1) &
    WinConst.RequestMsg(p.message,msgFlag,msg) THEN (* target window hit     *)
    PrepareHeader(hWnd,str);
    Strings.Append(str," GetMsg:    "); Strings.Append(str,msg);
    IF mode = TEXT_ONLY THEN 
      GetMsgProc_lPText(lParam,str); 
    ELSIF mode = TEXT_AND_HEX THEN 
      GetwPHex(p.wParam,str); GetlPHex(p.lParam,str); 
      GetMsgProc_lPText(lParam,str); 
    ELSIF mode = HEX_ONLY THEN 
      GetwPHex(p.wParam,str); 
      GetlPHex(p.lParam,str); 
    ELSE
      Strings.Append(str,"Decoder.GetMsgProc: ERROR: Invalid display mode !");
    END; 
    RETURN TRUE

  ELSE                                      (* skip event                     *)
    RETURN FALSE
  END
END GetMsgProc;


BEGIN
  
  mode := TEXT_ONLY;
END Decoder.
