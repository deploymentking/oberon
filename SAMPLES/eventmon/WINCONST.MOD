(******************************************************************************)
(* MODULE:      WinConst                                        ME - 29.06.96 *)
(* DESCRIPTION: Defines string table for windows constants                    *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 21.05.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE WinConst;

IMPORT W := Windows, Sys := SysProc, Inp := InProc, Ncl := NclProc, Wnd := WndProc,
       Clp := ClpProc, dde := DDEProc, Ctr := CtrProc, ht := htConst, ft := FlagTab, 
       Strings, Utils, SYSTEM;

CONST
  STR_LEN = 128;
 
TYPE 
  (* Procedure type for message decoding procedures *)
  DecoderProcT = PROCEDURE (wParam : W.WORD; 
                            lParam : W.DWORD;
                            VAR str : ARRAY OF CHAR);
                              
  (* Describes one entry of message table *) 
  msgDesc = RECORD
              id  : INTEGER;
              msg : ARRAY 32 OF CHAR;
              flg : LONGINT;
              proc : DecoderProcT;
            END;
            
  (* Windows compatible message structure *)
  msgStructP = POINTER TO RECORD
                 hwnd : W.HWND;
                 message : W.UINT;
                 wParam : W.WPARAM;
                 lParam : W.LPARAM;
                 time   : W.DWORD;
                 pt     : W.POINT;
               END;            
  
VAR 
  winVer,                                  (* version flag                    *)
  i : INTEGER;
  wMsgTab : ARRAY 311 OF msgDesc;          (* common windows messages         *)

 
(*----------------< Auxiliary procedures >------------------------------------*)
  
(*============================================================================*)
(* PURPOSE:  Covert number in word format to string                           *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* w              Word                                                        *)
(* str            String to receive output                                    *)
(*============================================================================*)
PROCEDURE HexWordToStr(w : INTEGER; VAR s : ARRAY OF CHAR);
VAR 
  res,                                     (* some strings nedded to form     *)
  formatStr : ARRAY 32 OF CHAR;            (* output                          *)
  argList   : ARRAY 1 OF INTEGER;
  r : INTEGER;                             (* dummy return value              *)
 
BEGIN
  res := "";
  formatStr := "0x%4.4X"; 
  argList[0] := w;
  r := W.wvsprintf(SYSTEM.ADR(res),
                   SYSTEM.ADR(formatStr), 
                   SYSTEM.ADR(argList));   
  Strings.Append(s,res); 
END HexWordToStr;  


(*============================================================================*)
(* PURPOSE:  Appends number "n" in hexadecimal representation to string "s"   *)
(*           eg: (0x....)                                                     *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* i              number                                                      *)
(* s              string to receive output                                    *)
(*============================================================================*)
PROCEDURE AppendHexInt(n : INTEGER; VAR s : ARRAY OF CHAR); 
BEGIN    
  Strings.Append(s," (");
  HexWordToStr(n,s); 
  Strings.Append(s,")"); 
END AppendHexInt; 


(*============================================================================*)
(* PURPOSE:  Default WM_.. decoding procedure                                 *)
(*           Will be called, if no message specific procedure is available.   *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         depends on message                                          *)
(* lParam         depends on message                                          *)
(* str            string to receive output                                    *)
(*============================================================================*)  
PROCEDURE Default(wParam : W.WORD; 
                  lParam : W.DWORD;
                  VAR str : ARRAY OF CHAR); 

BEGIN
  Strings.Append(str," Msg: wp=");   HexWordToStr(wParam,str);
  Strings.Append(str," lp-HiWord="); HexWordToStr(Utils.HiWord(lParam),str);
  Strings.Append(str," lp-LoWord="); HexWordToStr(Utils.LoWord(lParam),str); 
END Default;  

  
(*============================================================================*)
(* PURPOSE:  Search in message table and sets index "i" to fitting position   *)
(*           using "binary rearch".                                           *)
(* COMMENTS: TRUE is returned, if message was found                           *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* t              table to search for                                         *)
(* x              message to find                                             *)
(* i              table index of message                                      *)
(*============================================================================*) 
PROCEDURE FindBin(VAR t- : ARRAY OF msgDesc; x : INTEGER; VAR i : INTEGER) : BOOLEAN;
VAR 
  j, m : INTEGER;

BEGIN
 ASSERT(LEN(t) < MAX(INTEGER)-1);
  
 i := -1; j := SHORT(LEN(t));
 WHILE (j # i + 1) DO 
   m := (i + j) DIV 2;
   IF t[m].id <= x THEN i := m ELSE j := m END;
 END;
 RETURN ((0 <= i) & (i < LEN(t)) & (t[i].id = x)); 
END FindBin;


(*============================================================================*)
(* PURPOSE:  Lookup string in message table according to index                *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* t              table                                                       *)
(* index          index of message table                                      *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE LookUpText(VAR t- : ARRAY OF msgDesc; 
                     index : INTEGER; 
                     VAR str : ARRAY OF CHAR); 
   
BEGIN
  ASSERT ((index >= 0) & (index < LEN(wMsgTab)));
  Strings.Append(str,t[index].msg);
END LookUpText;  


(*============================================================================*)
(* PURPOSE:  Lookup message string fitting to its identifier "uMsg"           *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* uMsg           identifier of windows message                               *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE GetMsgText(uMsg : INTEGER; VAR str : ARRAY OF CHAR);
VAR  
  i : INTEGER;
  msgStr : ARRAY STR_LEN OF CHAR;

BEGIN
  i := 0; msgStr := ""; 
  
  IF FindBin(wMsgTab,uMsg,i) THEN
    LookUpText(wMsgTab,i,msgStr);
  ELSIF uMsg >= W.WM_USER THEN
    msgStr := "WM_USER"
  ELSE
    msgStr := "WM_"
  END;
  AppendHexInt(uMsg, msgStr); 
  
  Strings.Append(str,msgStr); 
END GetMsgText;  


(*============================================================================*)
(* PURPOSE:  Compare the two flags, return true, if one flag can be assumed   *)       
(*           to be a subset of the other one.                                 *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* userFlag       message selection flag from user                            *)
(* tableFlag      message enabling flag of message table                      *)
(*============================================================================*)
PROCEDURE CompareFlags(userFlag, tableFlag : LONGINT) : BOOLEAN;
VAR
  r : LONGINT;

BEGIN
  IF userFlag = ft.MSG_TYPE_ALL THEN 
    RETURN TRUE
  ELSE
    r := Utils.BitAndL(userFlag, tableFlag);
    IF ((tableFlag # 0) & ((r = userFlag) OR (r = tableFlag))) THEN
      RETURN TRUE
    ELSE
      RETURN FALSE
    END
  END
END CompareFlags;


(*----------------< Exported procedures >-------------------------------------*)

(*============================================================================*)
(* PURPOSE:  Lookup message string fitting to its identifier "uMsg"           *)
(*           in accordance to current group selection.                        *)
(*                                                                            *)
(* COMMENTS: Returns true, if request is valid                                *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* uMsg           identifier of windows message                               *)
(* msgFlag        Flag with message group selection                           *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE RequestMsg*(uMsg : INTEGER; 
                      msgFlag : LONGINT; 
                      VAR str : ARRAY OF CHAR) : BOOLEAN;

VAR  
  i : INTEGER;

BEGIN
  i := 0; 
  
  IF FindBin(wMsgTab,uMsg,i) & CompareFlags(msgFlag, wMsgTab[i].flg) THEN 
    LookUpText(wMsgTab,i,str); AppendHexInt(i,str);
    RETURN TRUE
  ELSIF ((uMsg >= W.WM_USER) & (uMsg <= 32767)) & 
    CompareFlags(msgFlag, ft.MSG_TYPE_WMUSER) THEN
    Strings.Append(str,"WM_USER"); AppendHexInt(uMsg,str);
    RETURN TRUE
  ELSIF (msgFlag = ft.MSG_TYPE_ALL) THEN
    Strings.Append(str,"WM_"); AppendHexInt(uMsg,str);
    RETURN TRUE 
  ELSE  
    RETURN FALSE
  END
END RequestMsg;


(*============================================================================*)
(* PURPOSE:  Generic message decoding procedure                               *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* uMsg           windows message                                             *)
(* wParam         depends on message                                          *)
(* lParam         depends on message                                          *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE ExpandMsg*(uMsg : INTEGER; 
                     wParam : W.WPARAM; 
                     lParam : W.LPARAM; 
                     VAR s : ARRAY OF CHAR);
VAR 
  i : INTEGER;
  p : DecoderProcT;

BEGIN
  i := 0;
  IF FindBin(wMsgTab, uMsg, i) THEN
    p := wMsgTab[i].proc
  ELSE
    p := Default 
  END; 
  p(wParam, lParam, s); 
END ExpandMsg;


(*==============< Decoding procedures for mouse messages >====================*)
(* This Application provides for mouse message group:                         *)
(*                WM_HSCROLL                                                  *)
(*                WM_SETCURSOR                                                *)
(*                WM_LBUTTONDOWN            (Proc_MouseGeneric)               *)
(*                WM_LBUTTONUP              (Proc_MouseGeneric)               *)
(*                WM_LBUTTONDBLCLK          (Proc_MouseGeneric)               *)
(*                WM_MBUTTONDOWN            (Proc_MouseGeneric)               *)
(*                WM_MBUTTONUP              (Proc_MouseGeneric)               *)
(*                WM_MBUTTONDBLCLK          (Proc_MouseGeneric)               *)
(*                WM_MOUSEACTIVATE                                            *)
(*                WM_MOUSEMOVE              (Proc_MouseGeneric)               *)
(*                WM_PARENTNOTIFY                                             *)
(*                WM_RBUTTONDOWN            (Proc_MouseGeneric)               *)
(*                WM_RBUTTONUP              (Proc_MouseGeneric)               *)
(*                WM_RBUTTONDBLCLK          (Proc_MouseGeneric)               *)
(*                WM_VSCROLL                                                  *)
(*============================================================================*)


(*============================================================================*)
(* PURPOSE:  Decoding procedure for a set of similar mouse messages           *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwKeys: key flags                                           *)
(* lParam         xPos: Value of the low-order word of lParam                 *)
(*                yPos: Value of the high-order word of lParam                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_MouseGeneric(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);

TYPE 
  pointDesc = RECORD
                x : INTEGER;
                y : INTEGER;
              END;

VAR
  numStr : ARRAY STR_LEN OF CHAR;
  pt : pointDesc;

BEGIN
  numStr := "";
 
  (*-- Get mouse button key-flags --*) 
  Strings.Append(str, " fwKeys:");
  Strings.HexStr(wParam, numStr); Strings.Append(str, numStr); numStr := "";
  
  (*-- Get mouse position --*)
  W.GetCursorPos(SYSTEM.ADR(pt));
  Strings.Append(str, " Cursor xPos:");
  Strings.Str(pt.x, numStr); Strings.Append(str, numStr); numStr := "";
  Strings.Append(str, " yPos:"); 
  Strings.Str(pt.y, numStr); Strings.Append(str, numStr);   
END Proc_MouseGeneric;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_HSCROLL                                *)
(*                                                                            *)
(* COMMENTS: The WM_HSCROLL message is sent to a window when the user clicks  *)
(*           the window's horizontal scroll bar.                              *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wScrollCode: scroll bar code indicating scrolling request.  *)
(* lParam         nPos = LOWORD(lParam): current position of scroll box       *)
(*                hwndCtl = (HWND) HIWORD(lParam): handle of the control      *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_HSCROLL(wParam : W.WPARAM; 
                          lParam : W.LPARAM;
                          VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  numStr := "";
  
  (*-- Get scroll bar code and position in scroll box --*)
  Strings.Append(str," wScrollCode:");
  ASSERT((wParam >= 0) & (wParam < LEN(ht.sbHscrTab)));
  IF (ht.sbHscrTab[wParam] # "") THEN
    Strings.Append(str, ht.sbHscrTab[wParam]);
  ELSE
    Strings.HexStr(wParam, numStr); Strings.Append(str, numStr); numStr := ""; 
  END;
  IF (wParam = W.SB_THUMBPOSITION) OR (wParam = W.SB_THUMBTRACK) THEN
    Strings.Append(str," nPos:");   
    Strings.Str(Utils.LoWord(lParam), numStr); Strings.Append(str, numStr); numStr := "";
  END;

  (*-- Get handle of control --*)
  Strings.Append(str," hWndScrollBar:"); 
  Strings.HexStr(Utils.HiWord(lParam), numStr); Strings.Append(str, numStr);
END Proc_WM_HSCROLL;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SETCURSOR                              *)
(*                                                                            *)
(* COMMENTS: The WM_SETCURSOR message is sent to a window if mouse input      *)
(*           is not captured and the mouse causes cursor movement within      *)
(*           the window.                                                      *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         Specifies a handle to the window that contains the cursor   *)
(* lParam         nHittest: Value of the low-order word of lParam             *)
(*                wMouseMsg: Value of the high-order word of lParam           *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SETCURSOR(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR 
  msgStr, hexStr : ARRAY STR_LEN OF CHAR;

BEGIN
  hexStr := ""; msgStr := "";

  (*-- Build Hittest information --*)
  Strings.Append(str," hHittest:");  
  ASSERT((Utils.LoWord(lParam) >= 0) & (Utils.LoWord(lParam) < LEN(ht.htTab)));
  IF (ht.htTab[Utils.LoWord(lParam)] # "") THEN
    Strings.Append(str, ht.htTab[Utils.LoWord(lParam)]);
  ELSE
    Strings.HexStr(Utils.LoWord(lParam), hexStr);
    Strings.Append(str, hexStr);
  END;

  (*-- Build information about mouse message --*)
  Strings.Append(str, " wMouseMsg:");
  GetMsgText(Utils.HiWord(lParam), msgStr);  
  
  Strings.Append(str,msgStr); 
END Proc_WM_SETCURSOR;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_LBUTTONDOWN                            *)
(*                                                                            *)
(* COMMENTS: The WM_LBUTTONDOWN message is sent when the user presses the     *)
(*           left mouse button.                                               *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwKeys: key flags                                           *)
(* lParam         xPos: Value of the low-order word of lParam                 *)
(*                yPos: Value of the high-order word of lParam                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_LBUTTONDOWN(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);

BEGIN
  Proc_MouseGeneric(wParam,lParam,str);
END Proc_WM_LBUTTONDOWN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_LBUTTONUP                              *)
(*                                                                            *)
(* COMMENTS: The WM_LBUTTONUP message is sent when the user releases the      *)
(*           left mouse button.                                               *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwKeys: key flags                                           *)
(* lParam         xPos: Value of the low-order word of lParam                 *)
(*                yPos: Value of the high-order word of lParam                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_LBUTTONUP(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);

BEGIN
  Proc_MouseGeneric(wParam,lParam,str);
END Proc_WM_LBUTTONUP;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_LBUTTONDBLCLK                          *)
(*                                                                            *)
(* COMMENTS: The WM_LBUTTONDBLCLK message is sent when the user double-clicks *)
(*           the left mouse button.                                           *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwKeys: key flags                                           *)
(* lParam         xPos: Value of the low-order word of lParam                 *)
(*                yPos: Value of the high-order word of lParam                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_LBUTTONDBLCLK(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);

BEGIN
  Proc_MouseGeneric(wParam,lParam,str);
END Proc_WM_LBUTTONDBLCLK;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_MBUTTONDOWN                            *)
(*                                                                            *)
(* COMMENTS: The WM_MBUTTONDOWN message is sent when the user presses the     *)
(*           middle mouse button.                                             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwKeys: key flags                                           *)
(* lParam         xPos: Value of the low-order word of lParam                 *)
(*                yPos: Value of the high-order word of lParam                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_MBUTTONDOWN(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);

BEGIN
  Proc_MouseGeneric(wParam,lParam,str);
END Proc_WM_MBUTTONDOWN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_MBUTTONUP                              *)
(*                                                                            *)
(* COMMENTS: The WM_MBUTTONUP message is sent when the user releases the      *)
(*           middle mouse button.                                             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwKeys: key flags                                           *)
(* lParam         xPos: Value of the low-order word of lParam                 *)
(*                yPos: Value of the high-order word of lParam                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_MBUTTONUP(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);

BEGIN
  Proc_MouseGeneric(wParam,lParam,str);
END Proc_WM_MBUTTONUP;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_MBUTTONDBLCLK                          *)
(*                                                                            *)
(* COMMENTS: The WM_MBUTTONDBLCLK message is sent when the user double-clicks *)
(*           the middle mouse button.                                         *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwKeys: key flags                                           *)
(* lParam         xPos: Value of the low-order word of lParam                 *)
(*                yPos: Value of the high-order word of lParam                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_MBUTTONDBLCLK(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);

BEGIN
  Proc_MouseGeneric(wParam,lParam,str);
END Proc_WM_MBUTTONDBLCLK;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_MOUSEACTIVATE                          *)
(*                                                                            *)
(* COMMENTS: The WM_MOUSEACTIVATE message is sent when the cursor is in an    *)
(*           inactive window and the user presses a mouse button.             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hwndTopLevel: handle of top-level parent                    *)
(* lParam         wHitTestCode = LOWORD(lParam): Specifies the hit-test code  *)
(*                wMouseMsg = HIWORD(lParam): mouse-message identifier        *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_MOUSEACTIVATE(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
VAR 
  i : INTEGER;
  msgStr, hexStr : ARRAY STR_LEN OF CHAR;

BEGIN
  msgStr := ""; hexStr := "";

  (*-- Fetch top level window --*)
  Strings.Append(str, " hWndTopLevel:");
  Strings.HexStr(wParam, hexStr); Strings.Append(str, hexStr); hexStr := "";
  
  (*-- Build hittest code ------*)
  Strings.Append(str, " Hittest:");  
  ASSERT((Utils.LoWord(lParam) >= 0) & (Utils.LoWord(lParam) < LEN(ht.htTab)));
  IF (ht.htTab[Utils.LoWord(lParam)] # "") THEN
    Strings.Append(str, ht.htTab[Utils.LoWord(lParam)]);
  ELSE
    Strings.HexStr(Utils.LoWord(lParam), hexStr); Strings.Append(str, hexStr); 
  END;

  (*-- Build information about mouse message --*)
  Strings.Append(str, " wMouseMsg:");
  GetMsgText(Utils.HiWord(lParam), msgStr);
   
  Strings.Append(str,msgStr); 
END Proc_WM_MOUSEACTIVATE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_MOUSEMOVE                              *)
(*                                                                            *)
(* COMMENTS: The WM_MOUSEMOVE message is sent to a window when the mouse      *)
(*           cursor moves. If the mouse is not captured, the message goes to  *)
(*           the window beneath the cursor. Otherwise, the message goes to    *)
(*           the window that has captured the mouse.                          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwKeys: key flags                                           *)
(* lParam         xPos: Value of the low-order word of lParam                 *)
(*                yPos: Value of the high-order word of lParam                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_MOUSEMOVE(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);


BEGIN
  Proc_MouseGeneric(wParam,lParam,str);
END Proc_WM_MOUSEMOVE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_PARENTNOTIFY                           *)
(*                                                                            *)
(* COMMENTS: The WM_PARENTNOTIFY message is sent to the parent of a child     *)
(*           window when the child window is created or destroyed or when the *)
(*           user clicks a mouse button while the cursor is over the child    *)
(*           window. When the child window is being created, the system sends *)
(*           WM_PARENTNOTIFY just before the CreateWindow or CreateWindowEx   *)
(*           function that creates the window returns. When the child window  *)
(*           is being destroyed, the system sends the message before any      *)
(*           processing to destroy the window takes place.                    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwEvent: The event for which the parent is being notified.  *)
(* lParam         wValue1 = LOWORD(lParam): child handle/cursor x-coordinate  *)
(*                wValue2 = HIWORD(lParam); child ID/cursor y-coordinate      *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_PARENTNOTIFY(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
VAR 
  msgStr, numStr : ARRAY STR_LEN OF CHAR;

BEGIN
   msgStr := ""; numStr := "";

  (*-- Build event information --*)
  Strings.Append(str, " Event:");
  GetMsgText(wParam, msgStr); Strings.Append(str, msgStr); 
 
  (*-- Build information about child window --*)
  IF ((wParam = W.WM_CREATE) OR (wParam = W.WM_DESTROY)) THEN
    Strings.Append(str, " Child Wnd:");
    Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str, numStr); numStr := "";
    Strings.Append(str, " Child ID:");
    Strings.HexStr(Utils.HiWord(lParam), numStr); Strings.Append(str, numStr);
  ELSE
    Strings.Append(str, " Cursor xPos:");
    Strings.Str(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr); numStr := ""; 
    Strings.Append(str, " yPos:");
    Strings.Str(Utils.HiWord(lParam), numStr); Strings.Append(str, numStr);
  END;
END Proc_WM_PARENTNOTIFY;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_RBUTTONDOWN                            *)
(*                                                                            *)
(* COMMENTS: The WM_RBUTTONDOWN message is sent when the user presses the     *)
(*           right mouse button.                                              *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwKeys: key flags                                           *)
(* lParam         xPos: Value of the low-order word of lParam                 *)
(*                yPos: Value of the high-order word of lParam                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_RBUTTONDOWN(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);

BEGIN
  Proc_MouseGeneric(wParam,lParam,str);
END Proc_WM_RBUTTONDOWN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_RBUTTONUP                              *)
(*                                                                            *)
(* COMMENTS: The WM_RBUTTONUP message is sent when the user releases the      *)
(*           right mouse button.                                              *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwKeys: key flags                                           *)
(* lParam         xPos: Value of the low-order word of lParam                 *)
(*                yPos: Value of the high-order word of lParam                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_RBUTTONUP(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);

BEGIN
  Proc_MouseGeneric(wParam,lParam,str);
END Proc_WM_RBUTTONUP;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_RBUTTONDBLCLK                          *)
(*                                                                            *)
(* COMMENTS: The WM_RBUTTONDBLCLK message is sent when the user double-clicks *)
(*           the right mouse button.                                          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwKeys: key flags                                           *)
(* lParam         xPos: Value of the low-order word of lParam                 *)
(*                yPos: Value of the high-order word of lParam                *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_RBUTTONDBLCLK(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);

BEGIN
  Proc_MouseGeneric(wParam,lParam,str);
END Proc_WM_RBUTTONDBLCLK;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_VSCROLL                                *)
(*                                                                            *)
(* COMMENTS: The WM_VSCROLL message is sent to a window when the user clicks  *)
(*           the window's vertical scroll bar.                                *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wScrollCode: scroll bar code indicating scrolling request.  *)
(* lParam         nPos = LOWORD(lParam): current position of scroll box       *)
(*                hwndCtl = (HWND) HIWORD(lParam): handle of the control      *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_VSCROLL(wParam : W.WPARAM; 
                          lParam : W.LPARAM;
                          VAR str : ARRAY OF CHAR);
VAR 
  t : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," wScrollCode:");

  ASSERT((wParam >= 0) & (wParam < LEN(ht.sbVscrTab)));
  IF (ht.sbVscrTab[wParam] # "") THEN
    Strings.Append(str,ht.sbVscrTab[wParam]);
  ELSE
    t := ""; Strings.HexStr(wParam,t); Strings.Append(str,t); 
  END;

  IF (wParam = W.SB_THUMBPOSITION) OR (wParam = W.SB_THUMBTRACK) THEN
    Strings.Append(str," nPos:"); t := "";  
    Strings.Str(Utils.LoWord(lParam),t); Strings.Append(str,t); 
  END;

  Strings.Append(str," hWndScrollBar:"); t := "";
  Strings.HexStr(Utils.HiWord(lParam),t); Strings.Append(str,t);
END Proc_WM_VSCROLL;



(*==============< Decoding procedures for init messages >=====================*)
(* This Application provides for init message group:                          *)
(*                WM_INITDIALOG                                               *)
(*                WM_INITMENU                                                 *)
(*                WM_INITMENUPOPUP                                            *)
(*============================================================================*)

(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_INITDIALOG                             *)
(*                                                                            *)
(* COMMENTS: The WM_INITDIALOG message is sent to a dialog box procedure      *)
(*           immediately before the dialog box is displayed.                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hwndFocus = (HWND) wParam: handle of control for focus      *)
(* lParam         dwData = lParam: application-specific data                  *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_INITDIALOG(wParam : W.WPARAM; 
                             lParam : W.LPARAM;
                             VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," hWndFocus:"); numStr := "";
  HexWordToStr(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," dwData:"); numStr := "";
  Strings.HexStr(lParam, numStr); Strings.Append(str,numStr);
END Proc_WM_INITDIALOG;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_INITMENU                               *)
(*                                                                            *)
(* COMMENTS: The WM_INITMENU message is sent when a menu is about to become   *)
(*           active. It occurs when the user clicks an item on the menu bar   *)
(*           or presses a menu key. This allows an application to modify the  *)
(*           menu before it is displayed.                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hmenuInit = (HMENU) wParam: handle of menu to initialize    *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_INITMENU(wParam : W.WPARAM; 
                             lParam : W.LPARAM;
                             VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," hWndMenuInit:"); numStr := "";
  HexWordToStr(wParam,numStr); Strings.Append(str,numStr)
END Proc_WM_INITMENU;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_INITMENUPOPUP                          *)
(*                                                                            *)
(* COMMENTS: The WM_INITMENUPOPUP message is sent when a pop-up menu is about *)
(*           to become active. This allows an application to modify the       *)
(*           pop-up menu before it is displayed, without changing the         *)
(*           entire menu.                                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hmenuPopup = (HMENU) wParam: handle of pop-up menu          *)
(* lParam         nIndex = (int) LOWORD(lParam): index of pop-up menu         *)
(*                fSystemMenu = (BOOL) HIWORD(lParam): System-menu flag       *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_INITMENUPOPUP(wParam : W.WPARAM; 
                             lParam : W.LPARAM;
                             VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," hmenuPopup:"); numStr := "";
  HexWordToStr(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," nIndex:"); numStr := "";
  Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
                                 
  Strings.Append(str," fSystemMenu:");
  IF (SYSTEM.VAL(W.BOOL,Utils.HiWord(lParam)) # W.false) THEN
    Strings.Append(str,"TRUE")
  ELSE
    Strings.Append(str,"FALSE")
  END
END Proc_WM_INITMENUPOPUP;


(*==============< Begin of module-body >======================================*)

BEGIN
  winVer := ft.WIN_3_XX;
  
  (*-- Init string tables --*)
  FOR i := 0 TO LEN(wMsgTab)-1 DO
    wMsgTab[i].id  := 0;
    wMsgTab[i].msg := "";
    wMsgTab[i].flg := 0;
    wMsgTab[i].proc := Default;
  END;

 (*----------< Init common windows messages >-----------------------------------------------*) 
 (* 0x0000 *) wMsgTab[0].id     := W.WM_NULL;                  wMsgTab[0].msg   := "WM_NULL";
                                                               wMsgTab[0].flg   :=  ft.MSG_TYPE_SYS;
 (* 0x0001 *) wMsgTab[1].id     := W.WM_CREATE;                wMsgTab[1].msg   := "WM_CREATE";
              wMsgTab[1].proc   := Wnd.Proc_WM_CREATE;         wMsgTab[1].flg   :=  ft.MSG_TYPE_WND;
 (* 0x0002 *) wMsgTab[2].id     := W.WM_DESTROY;               wMsgTab[2].msg   := "WM_DESTROY";
                                                               wMsgTab[2].flg   :=  ft.MSG_TYPE_WND;
 (* 0x0003 *) wMsgTab[3].id     := W.WM_MOVE;                  wMsgTab[3].msg   := "WM_MOVE";
              wMsgTab[3].proc   := Wnd.Proc_WM_MOVE;           wMsgTab[3].flg   :=  ft.MSG_TYPE_WND;
 (* 0x0005 *) wMsgTab[4].id     := W.WM_SIZE;                  wMsgTab[4].msg   := "WM_SIZE";
              wMsgTab[4].proc   := Wnd.Proc_WM_SIZE;           wMsgTab[4].flg   :=  ft.MSG_TYPE_WND;
 (* 0x0006 *) wMsgTab[5].id     := W.WM_ACTIVATE;              wMsgTab[5].msg   := "WM_ACTIVATE";
              wMsgTab[5].proc   := Wnd.Proc_WM_ACTIVATE;       wMsgTab[5].flg   :=  ft.MSG_TYPE_WND;
 (* 0x0007 *) wMsgTab[6].id     := W.WM_SETFOCUS;              wMsgTab[6].msg   := "WM_SETFOCUS";
              wMsgTab[6].proc   := Wnd.Proc_WM_SETFOCUS;       wMsgTab[6].flg   :=  ft.MSG_TYPE_WND;
 (* 0x0008 *) wMsgTab[7].id     := W.WM_KILLFOCUS;             wMsgTab[7].msg   := "WM_KILLFOCUS";
              wMsgTab[7].proc   := Wnd.Proc_WM_KILLFOCUS;      wMsgTab[7].flg   :=  ft.MSG_TYPE_WND; 
 (* 0x000A *) wMsgTab[8].id     := W.WM_ENABLE;                wMsgTab[8].msg   := "WM_ENABLE";
              wMsgTab[8].proc   := Wnd.Proc_WM_ENABLE;         wMsgTab[8].flg   :=  ft.MSG_TYPE_WND;
 (* 0x000B *) wMsgTab[9].id     := W.WM_SETREDRAW;             wMsgTab[9].msg   := "WM_SETREDRAW";
              wMsgTab[9].proc   := Wnd.Proc_WM_SETREDRAW;      wMsgTab[9].flg   :=  ft.MSG_TYPE_WND;
 (* 0x000C *) wMsgTab[10].id    := W.WM_SETTEXT;               wMsgTab[10].msg  := "WM_SETTEXT"; 
              wMsgTab[10].proc  := Wnd.Proc_WM_SETTEXT;        wMsgTab[10].flg  :=  ft.MSG_TYPE_WND;
 (* 0x000D *) wMsgTab[11].id    := W.WM_GETTEXT;               wMsgTab[11].msg  := "WM_GETTEXT";
              wMsgTab[11].proc  := Wnd.Proc_WM_GETTEXT;        wMsgTab[11].flg  :=  ft.MSG_TYPE_WND; 
 (* 0x000E *) wMsgTab[12].id    := W.WM_GETTEXTLENGTH;         wMsgTab[12].msg  := "WM_GETTEXTLENGTH";
                                                               wMsgTab[12].flg  :=  ft.MSG_TYPE_WND; 
 (* 0x000F *) wMsgTab[13].id    := W.WM_PAINT;                 wMsgTab[13].msg  := "WM_PAINT";
                                                               wMsgTab[13].flg  :=  ft.MSG_TYPE_WND; 
 (* 0x0010 *) wMsgTab[14].id    := W.WM_CLOSE;                 wMsgTab[14].msg  := "WM_CLOSE";
                                                               wMsgTab[14].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0011 *) wMsgTab[15].id    := W.WM_QUERYENDSESSION;       wMsgTab[15].msg  := "WM_QUERYENDSESSION";
                                                               wMsgTab[15].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0012 *) wMsgTab[16].id    := W.WM_QUIT;                  wMsgTab[16].msg  := "WM_QUIT";
              wMsgTab[16].proc  := Wnd.Proc_WM_QUIT;           wMsgTab[16].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0013 *) wMsgTab[17].id    := W.WM_QUERYOPEN;             wMsgTab[17].msg  := "WM_QUERYOPEN";
                                                               wMsgTab[17].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0014 *) wMsgTab[18].id    := W.WM_ERASEBKGND;            wMsgTab[18].msg  := "WM_ERASEBKGND";
              wMsgTab[18].proc  := Wnd.Proc_WM_ERASEBKGND;     wMsgTab[18].flg  :=  ft.MSG_TYPE_WND; 
 (* 0x0015 *) wMsgTab[19].id    := W.WM_SYSCOLORCHANGE;        wMsgTab[19].msg  := "WM_SYSCOLORCHANGE";
                                                               wMsgTab[19].flg  :=  ft.MSG_TYPE_SYS; 
 (* 0x0016 *) wMsgTab[20].id    := W.WM_ENDSESSION;            wMsgTab[20].msg  := "WM_ENDSESSION";
              wMsgTab[20].proc  := Wnd.Proc_WM_ENDSESSION;     wMsgTab[20].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0018 *) wMsgTab[21].id    := W.WM_SHOWWINDOW;            wMsgTab[21].msg  := "WM_SHOWWINDOW";
              wMsgTab[21].proc  := Wnd.Proc_WM_SHOWWINDOW;     wMsgTab[21].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0019 *) wMsgTab[22].id    := W.WM_CTLCOLOR;              wMsgTab[22].msg  := "WM_CTLCOLOR";  
              wMsgTab[22].proc  := Wnd.Proc_WM_CTLCOLOR;       wMsgTab[22].flg  :=  ft.MSG_TYPE_WND;
 (* 0x001A *) wMsgTab[23].id    := W.WM_WININICHANGE;          wMsgTab[23].msg  := "WM_WININICHANGE";
              IF winVer >= ft.WIN_95 THEN wMsgTab[23].msg := "WM_SETTINGCHANGE" END;
              wMsgTab[23].proc  := Sys.Proc_WM_WININICHANGE;   wMsgTab[23].flg  :=  ft.MSG_TYPE_SYS; 
 (* 0x001B *) wMsgTab[24].id    := W.WM_DEVMODECHANGE;         wMsgTab[24].msg  := "WM_DEVMODECHANGE";
              wMsgTab[24].proc  := Sys.Proc_WM_DEVMODECHANGE;  wMsgTab[24].flg  :=  ft.MSG_TYPE_SYS;
 (* 0x001C *) wMsgTab[25].id    := W.WM_ACTIVATEAPP;           wMsgTab[25].msg  := "WM_ACTIVATEAPP";
              wMsgTab[25].proc  := Wnd.Proc_WM_ACTIVATEAPP;    wMsgTab[25].flg  :=  ft.MSG_TYPE_WND;
 (* 0x001D *) wMsgTab[26].id    := W.WM_FONTCHANGE;            wMsgTab[26].msg  := "WM_FONTCHANGE";
                                                               wMsgTab[26].flg  :=  ft.MSG_TYPE_SYS;
 (* 0x001E *) wMsgTab[27].id    := W.WM_TIMECHANGE;            wMsgTab[27].msg  := "WM_TIMECHANGE";
                                                               wMsgTab[27].flg  :=  ft.MSG_TYPE_SYS;
 (* 0x001F *) wMsgTab[28].id    := W.WM_CANCELMODE;            wMsgTab[28].msg  := "WM_CANCELMODE";
                                                               wMsgTab[28].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0020 *) wMsgTab[29].id    := W.WM_SETCURSOR;             wMsgTab[29].msg  := "WM_SETCURSOR"; 
              wMsgTab[29].proc  := Proc_WM_SETCURSOR;          wMsgTab[29].flg  :=  ft.MSG_TYPE_MOUSE;
 (* 0x0021 *) wMsgTab[30].id    := W.WM_MOUSEACTIVATE;         wMsgTab[30].msg  := "WM_MOUSEACTIVATE";
              wMsgTab[30].proc  := Proc_WM_MOUSEACTIVATE;      wMsgTab[30].flg  :=  ft.MSG_TYPE_MOUSE;
 (* 0x0022 *) wMsgTab[31].id    := W.WM_CHILDACTIVATE;         wMsgTab[31].msg  := "WM_CHILDACTIVATE";
                                                               wMsgTab[31].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0023 *) wMsgTab[32].id    := W.WM_QUEUESYNC;             wMsgTab[32].msg  := "WM_QUEUESYNC";
                                                               wMsgTab[32].flg  :=  ft.MSG_TYPE_SYS;
 (* 0x0024 *) wMsgTab[33].id    := W.WM_GETMINMAXINFO;         wMsgTab[33].msg  := "WM_GETMINMAXINFO"; 
              wMsgTab[33].proc  := Wnd.Proc_WM_GETMINMAXINFO;  wMsgTab[33].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0026 *) wMsgTab[34].id    := 38;                         wMsgTab[34].msg  := "WM_PAINTICON"; 
                                                               wMsgTab[34].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0027 *) wMsgTab[35].id    := W.WM_ICONERASEBKGND;        wMsgTab[35].msg  := "WM_ICONERASEBKGND";   
              wMsgTab[35].proc  := Wnd.Proc_WM_ICONERASEBKGND; wMsgTab[35].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0028 *) wMsgTab[36].id    := W.WM_NEXTDLGCTL;            wMsgTab[36].msg  := "WM_NEXTDLGCTL"; 
                                                               wMsgTab[36].flg := ft.MSG_TYPE_OTHER;
 (* 0x002A *) wMsgTab[37].id    := W.WM_SPOOLERSTATUS;         wMsgTab[37].msg  := "WM_SPOOLERSTATUS";   
              wMsgTab[37].proc  := Sys.Proc_WM_SPOOLERSTATUS;  wMsgTab[37].flg  :=  ft.MSG_TYPE_SYS;
 (* 0x002B *) wMsgTab[38].id    := W.WM_DRAWITEM;              wMsgTab[38].msg  := "WM_DRAWITEM";   
                                                               wMsgTab[38].flg := ft.MSG_TYPE_OTHER;
 (* 0x002C *) wMsgTab[39].id    := W.WM_MEASUREITEM;           wMsgTab[39].msg  := "WM_MEASUREITEM";
                                                               wMsgTab[39].flg := ft.MSG_TYPE_OTHER;
 (* 0x002D *) wMsgTab[40].id    := W.WM_DELETEITEM;            wMsgTab[40].msg  := "WM_DELETEITEM"; 
                                                               wMsgTab[40].flg := ft.MSG_TYPE_OTHER;
 (* 0x002E *) wMsgTab[41].id    := W.WM_VKEYTOITEM;            wMsgTab[41].msg  := "WM_VKEYTOITEM"; 
              wMsgTab[41].proc  := Inp.Proc_WM_VKEYTOITEM;     wMsgTab[41].flg  :=  ft.MSG_TYPE_INPUT;
 (* 0x002F *) wMsgTab[42].id    := W.WM_CHARTOITEM;            wMsgTab[42].msg  := "WM_CHARTOITEM"; 
              wMsgTab[42].proc  := Inp.Proc_WM_CHARTOITEM;     wMsgTab[42].flg  :=  ft.MSG_TYPE_INPUT;
 (* 0x0030 *) wMsgTab[43].id    := W.WM_SETFONT;               wMsgTab[43].msg  := "WM_SETFONT"; 
              wMsgTab[43].proc  := Wnd.Proc_WM_SETFONT;        wMsgTab[43].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0031 *) wMsgTab[44].id    := W.WM_GETFONT;               wMsgTab[44].msg  := "WM_GETFONT"; 
                                                               wMsgTab[44].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0032 *) wMsgTab[45].id    := 50;                         wMsgTab[45].msg  := "WM_SETHOTKEY";
                                                               wMsgTab[45].flg := ft.MSG_TYPE_OTHER;
 (* 0x0033 *) wMsgTab[46].id    := 51;                         wMsgTab[46].msg  := "WM_GETHOTKEY";
                                                               wMsgTab[46].flg := ft.MSG_TYPE_OTHER;
 (* 0x0037 *) wMsgTab[47].id    := W.WM_QUERYDRAGICON;         wMsgTab[47].msg  := "WM_QUERYDRAGICON"; 
                                                               wMsgTab[47].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0039 *) wMsgTab[48].id    := W.WM_COMPAREITEM;           wMsgTab[48].msg  := "WM_COMPAREITEM"; 
                                                               wMsgTab[48].flg := ft.MSG_TYPE_OTHER;
 (* 0x0041 *) wMsgTab[49].id    := W.WM_COMPACTING;            wMsgTab[49].msg  := "WM_COMPACTING"; 
              wMsgTab[49].proc  := Sys.Proc_WM_COMPACTING;     wMsgTab[49].flg  :=  ft.MSG_TYPE_SYS;
 (* 0x0044 *) wMsgTab[50].id    := W.WM_COMMNOTIFY;            wMsgTab[50].msg  := "WM_WM_COMMNOTIFY"; (* not longer supported *)
                                                               wMsgTab[50].flg := ft.MSG_TYPE_OTHER;
 (* 0x0046 *) wMsgTab[51].id    := W.WM_WINDOWPOSCHANGING;     wMsgTab[51].msg  := "WM_WINDOWPOSCHANGING"; 
              wMsgTab[51].proc  := Wnd.Proc_WM_WINDOWPOSCHANGED; wMsgTab[51].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0047 *) wMsgTab[52].id    := W.WM_WINDOWPOSCHANGED;      wMsgTab[52].msg  := "WM_WINDOWPOSCHANGED"; 
              wMsgTab[52].proc  := Wnd.Proc_WM_WINDOWPOSCHANGED; wMsgTab[52].flg  :=  ft.MSG_TYPE_WND;
 (* 0x0048 *) wMsgTab[53].id    := W.WM_POWER;                 wMsgTab[53].msg  := "WM_POWER"; 
              wMsgTab[53].proc  := Sys.Proc_WM_POWER;          wMsgTab[53].flg  :=  ft.MSG_TYPE_SYS;
 (* 0x004A *) wMsgTab[54].id    := 74;                         wMsgTab[54].msg  := "WM_COPYDATA";
                                                               wMsgTab[54].flg := ft.MSG_TYPE_OTHER;
 (* 0x004B *) wMsgTab[55].id    := 75;                         wMsgTab[55].msg  := "WM_CANCELJOURNAL";
              (*-- Some new stuff, WINVER >= 0x0400 --*)       wMsgTab[55].flg := ft.MSG_TYPE_OTHER;
 (* 0x004E *) wMsgTab[56].id    := 78;                         wMsgTab[56].msg  := "WM_NOTIFY"; 
                                                               wMsgTab[56].flg := ft.MSG_TYPE_OTHER;
 (* 0x0050 *) wMsgTab[57].id    := 80;                         wMsgTab[57].msg  := "WM_INPUTLANGCHANGEREQUEST"; 
                                                               wMsgTab[57].flg := ft.MSG_TYPE_OTHER;
 (* 0x0051 *) wMsgTab[58].id    := 81;                         wMsgTab[58].msg  := "WM_INPUTLANGCHANGE"; 
                                                               wMsgTab[58].flg := ft.MSG_TYPE_OTHER;
 (* 0x0052 *) wMsgTab[59].id    := 82;                         wMsgTab[59].msg  := "WM_TCARD"; 
                                                               wMsgTab[59].flg := ft.MSG_TYPE_OTHER;
 (* 0x0053 *) wMsgTab[60].id    := 83;                         wMsgTab[60].msg  := "WM_HELP"; 
                                                               wMsgTab[60].flg := ft.MSG_TYPE_OTHER;
 (* 0x0054 *) wMsgTab[61].id    := 84;                         wMsgTab[61].msg  := "WM_USERCHANGED"; 
                                                               wMsgTab[61].flg := ft.MSG_TYPE_OTHER;
 (* 0x0055 *) wMsgTab[62].id    := 85;                         wMsgTab[62].msg  := "WM_NOTIFYFORMAT"; 
                                                               wMsgTab[62].flg := ft.MSG_TYPE_OTHER;
 (* 0x007B *) wMsgTab[63].id    := 123;                        wMsgTab[63].msg  := "WM_CONTEXTMENU"; 
                                                               wMsgTab[63].flg := ft.MSG_TYPE_OTHER;
 (* 0x007C *) wMsgTab[64].id    := 124;                        wMsgTab[64].msg  := "WM_STYLECHANGING"; 
                                                               wMsgTab[64].flg := ft.MSG_TYPE_OTHER;
 (* 0x007D *) wMsgTab[65].id    := 125;                        wMsgTab[65].msg  := "WM_STYLECHANGED"; 
                                                               wMsgTab[65].flg := ft.MSG_TYPE_OTHER;
 (* 0x007E *) wMsgTab[66].id    := 126;                        wMsgTab[66].msg  := "WM_DISPLAYCHANGE"; 
                                                               wMsgTab[66].flg := ft.MSG_TYPE_OTHER;
 (* 0x007F *) wMsgTab[67].id    := 127;                        wMsgTab[67].msg  := "WM_GETICON"; 
                                                               wMsgTab[67].flg := ft.MSG_TYPE_OTHER;
 (* 0x0080 *) wMsgTab[68].id    := 128;                        wMsgTab[68].msg  := "WM_SETICON"; 
              (*-- End of new stuff ------------------*)       wMsgTab[68].flg := ft.MSG_TYPE_OTHER;
 (* 0x0081 *) wMsgTab[69].id    := W.WM_NCCREATE;              wMsgTab[69].msg  := "WM_NCCREATE"; 
              wMsgTab[69].proc  := Ncl.Proc_WM_NCCREATE;       wMsgTab[69].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x0082 *) wMsgTab[70].id    := W.WM_NCDESTROY;             wMsgTab[70].msg  := "WM_NCDESTROY"; 
                                                               wMsgTab[70].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x0083 *) wMsgTab[71].id    := W.WM_NCCALCSIZE;            wMsgTab[71].msg  := "WM_NCCALCSIZE"; 
              wMsgTab[71].proc  := Ncl.Proc_WM_NCCALCSIZE;     wMsgTab[71].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x0084 *) wMsgTab[72].id    := W.WM_NCHITTEST;             wMsgTab[72].msg  := "WM_NCHITTEST";
              wMsgTab[72].proc  := Ncl.Proc_WM_NCHITTEST;      wMsgTab[72].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x0085 *) wMsgTab[73].id    := W.WM_NCPAINT;               wMsgTab[73].msg  := "WM_NCPAINT"; 
                                                               wMsgTab[73].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x0086 *) wMsgTab[74].id    := W.WM_NCACTIVATE;            wMsgTab[74].msg  := "WM_NCACTIVATE"; 
              wMsgTab[74].proc  := Ncl.Proc_WM_NCACTIVATE;     wMsgTab[74].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x0087 *) wMsgTab[75].id    := W.WM_GETDLGCODE;            wMsgTab[75].msg  := "WM_GETDLGCODE"; 
                                                               wMsgTab[75].flg  :=  ft.MSG_TYPE_WND;
 (* 0x00A0 *) wMsgTab[76].id    := W.WM_NCMOUSEMOVE;           wMsgTab[76].msg  := "WM_NCMOUSEMOVE";
              wMsgTab[76].proc  := Ncl.Proc_WM_NCMOUSEMOVE;    wMsgTab[76].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x00A1 *) wMsgTab[77].id    := W.WM_NCLBUTTONDOWN;         wMsgTab[77].msg  := "WM_NCLBUTTONDOWN"; 
              wMsgTab[77].proc  := Ncl.Proc_WM_NCLBUTTONDOWN;  wMsgTab[77].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x00A2 *) wMsgTab[78].id    := W.WM_NCLBUTTONUP;           wMsgTab[78].msg  := "WM_NCLBUTTONUP"; 
              wMsgTab[78].proc  := Ncl.Proc_WM_NCLBUTTONUP;    wMsgTab[78].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x00A3 *) wMsgTab[79].id    := W.WM_NCLBUTTONDBLCLK;       wMsgTab[79].msg  := "WM_NCLBUTTONDBLCLK"; 
              wMsgTab[79].proc  := Ncl.Proc_WM_NCLBUTTONDBLCLK;wMsgTab[79].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x00A4 *) wMsgTab[80].id    := W.WM_NCRBUTTONDOWN;         wMsgTab[80].msg  := "WM_NCRBUTTONDOWN"; 
              wMsgTab[80].proc  := Ncl.Proc_WM_NCRBUTTONDOWN;  wMsgTab[80].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x00A5 *) wMsgTab[81].id    := W.WM_NCRBUTTONUP;           wMsgTab[81].msg  := "WM_NCRBUTTONUP"; 
              wMsgTab[81].proc  := Ncl.Proc_WM_NCRBUTTONUP;    wMsgTab[81].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x00A6 *) wMsgTab[82].id    := W.WM_NCRBUTTONDBLCLK;       wMsgTab[82].msg  := "WM_NCRBUTTONDBLCLK"; 
              wMsgTab[82].proc  := Ncl.Proc_WM_NCRBUTTONDBLCLK;wMsgTab[82].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x00A7 *) wMsgTab[83].id    := W.WM_NCMBUTTONDOWN;         wMsgTab[83].msg  := "WM_NCMBUTTONDOWN"; 
              wMsgTab[83].proc  := Ncl.Proc_WM_NCMBUTTONDOWN;  wMsgTab[83].flg  :=  ft.MSG_TYPE_NCL;
 (* 0x00A8 *) wMsgTab[84].id    := W.WM_NCMBUTTONUP;           wMsgTab[84].msg  := "WM_NCMBUTTONUP";
              wMsgTab[84].proc  := Ncl.Proc_WM_NCMBUTTONUP;    wMsgTab[84].flg  :=  ft.MSG_TYPE_NCL; 
 (* 0x00A9 *) wMsgTab[85].id    := W.WM_NCMBUTTONDBLCLK;       wMsgTab[85].msg  := "WM_NCMBUTTONDBLCLK"; 
              wMsgTab[85].proc  := Ncl.Proc_WM_NCMBUTTONDBLCLK;wMsgTab[85].flg  :=  ft.MSG_TYPE_NCL;
 
 (*----------< Edit control messages >------------------------------------------------------*)
 (* 0x00B0 *) wMsgTab[86].id    := 176;                        wMsgTab[86].msg  := "EM_GETSEL"; 
                                                               wMsgTab[86].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00B1 *) wMsgTab[87].id    := 177;                        wMsgTab[87].msg  := "EM_SETSEL"; 
                                                               wMsgTab[87].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00B2 *) wMsgTab[88].id    := 178;                        wMsgTab[88].msg  := "EM_GETRECT"; 
                                                               wMsgTab[88].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00B3 *) wMsgTab[89].id    := 179;                        wMsgTab[89].msg  := "EM_SETRECT"; 
                                                               wMsgTab[89].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00B4 *) wMsgTab[90].id    := 180;                        wMsgTab[90].msg  := "EM_SETRECTNP"; 
                                                               wMsgTab[90].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00B5 *) wMsgTab[91].id    := 181;                        wMsgTab[91].msg  := "EM_SCROLL";
                                                               wMsgTab[91].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00B6 *) wMsgTab[92].id    := 182;                        wMsgTab[92].msg  := "EM_LINESCROLL"; 
                                                               wMsgTab[92].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00B7 *) wMsgTab[93].id    := 183;                        wMsgTab[93].msg  := "EM_SCROLLCARET";
                                                               wMsgTab[93].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00B8 *) wMsgTab[94].id    := 184;                        wMsgTab[94].msg  := "EM_GETMODIFY"; 
                                                               wMsgTab[94].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00B9 *) wMsgTab[95].id    := 185;                        wMsgTab[95].msg  := "EM_SETMODIFY"; 
                                                               wMsgTab[95].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00BA *) wMsgTab[96].id    := 186;                        wMsgTab[96].msg  := "EM_GETLINECOUNT"; 
                                                               wMsgTab[96].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00BB *) wMsgTab[97].id    := 187;                        wMsgTab[97].msg  := "EM_LINEINDEX"; 
                                                               wMsgTab[97].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00BC *) wMsgTab[98].id    := 188;                        wMsgTab[98].msg  := "EM_SETHANDLE"; 
                                                               wMsgTab[98].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00BD *) wMsgTab[99].id    := 189;                        wMsgTab[99].msg  := "EM_GETHANDLE"; 
                                                               wMsgTab[99].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00BE *) wMsgTab[100].id   := 190;                        wMsgTab[100].msg := "EM_GETTHUMB";
                                                               wMsgTab[100].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00C1 *) wMsgTab[101].id   := 193;                        wMsgTab[101].msg := "EM_LINELENGTH"; 
                                                               wMsgTab[101].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00C2 *) wMsgTab[102].id   := 194;                        wMsgTab[102].msg := "EM_REPLACESEL"; 
                                                               wMsgTab[102].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00C4 *) wMsgTab[103].id   := 196;                        wMsgTab[103].msg := "EM_GETLINE"; 
                                                               wMsgTab[103].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00C5 *) wMsgTab[104].id   := 197;                        wMsgTab[104].msg := "EM_LIMITTEXT"; 
                                                               wMsgTab[104].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00C6 *) wMsgTab[105].id   := 198;                        wMsgTab[105].msg := "EM_CANUNDO"; 
                                                               wMsgTab[105].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00C7 *) wMsgTab[106].id   := 199;                        wMsgTab[106].msg := "EM_UNDO"; 
                                                               wMsgTab[106].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00C8 *) wMsgTab[107].id   := 200;                        wMsgTab[107].msg := "EM_FMTLINES"; 
                                                               wMsgTab[107].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00C9 *) wMsgTab[108].id   := 201;                        wMsgTab[108].msg := "EM_LINEFROMCHAR"; 
                                                               wMsgTab[108].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00CB *) wMsgTab[109].id   := 203;                        wMsgTab[109].msg := "EM_SETTABSTOPS"; 
                                                               wMsgTab[109].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00CC *) wMsgTab[110].id   := 204;                        wMsgTab[110].msg := "EM_SETPASSWORDCHAR"; 
                                                               wMsgTab[110].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00CD *) wMsgTab[111].id   := 205;                        wMsgTab[111].msg := "EM_EMPTYUNDOBUFFER"; 
                                                               wMsgTab[111].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00CE *) wMsgTab[112].id   := 206;                        wMsgTab[112].msg := "EM_GETFIRSTVISIBLELINE"; 
                                                               wMsgTab[112].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00CF *) wMsgTab[113].id   := 207;                        wMsgTab[113].msg := "EM_SETREADONLY"; 
                                                               wMsgTab[113].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00D0 *) wMsgTab[114].id   := 208;                        wMsgTab[114].msg := "EM_SETWORDBREAKPROC"; 
                                                               wMsgTab[114].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00D1 *) wMsgTab[115].id   := 209;                        wMsgTab[115].msg := "EM_GETWORDBREAKPROC"; 
                                                               wMsgTab[115].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00D2 *) wMsgTab[116].id   := 210;                        wMsgTab[116].msg := "EM_GETPASSWORDCHAR"; 
              (*-- Some new stuff, WINVER >= 0x0400 --*)       wMsgTab[116].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00D3 *) wMsgTab[117].id   := 211;                        wMsgTab[117].msg := "EM_SETMARGINS"; 
                                                               wMsgTab[117].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00D4 *) wMsgTab[118].id   := 212;                        wMsgTab[118].msg := "EM_GETMARGINS"; 
              IF winVer >= ft.WIN_95 THEN wMsgTab[104].msg  := "EM_SETLIMITTEXT" END; (* win40 Name change *)
                                                               wMsgTab[118].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00D5 *) wMsgTab[119].id   := 213;                        wMsgTab[119].msg := "EM_GETLIMITTEXT"; 
                                                               wMsgTab[119].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00D6 *) wMsgTab[120].id   := 214;                        wMsgTab[120].msg := "EM_POSFROMCHAR"; 
                                                               wMsgTab[120].flg  :=  ft.MSG_TYPE_EM;
 (* 0x00D7 *) wMsgTab[121].id   := 215;                        wMsgTab[121].msg := "EM_CHARFROMPOS"; 
              (*-- End of new stuff ------------------*)       wMsgTab[121].flg  :=  ft.MSG_TYPE_EM;

 (*----------< Scroll bar control messages >-----------------------------------------------*)
 (* 0x00E0 *) wMsgTab[122].id   := 224;                        wMsgTab[122].msg := "SBM_SETPOS"; 
                                                               wMsgTab[122].flg := ft.MSG_TYPE_OTHER;
 (* 0x00E1 *) wMsgTab[123].id   := 225;                        wMsgTab[123].msg := "SBM_GETPOS";
                                                               wMsgTab[123].flg := ft.MSG_TYPE_OTHER;
 (* 0x00E2 *) wMsgTab[124].id   := 226;                        wMsgTab[124].msg := "SBM_SETRANGE";
                                                               wMsgTab[124].flg := ft.MSG_TYPE_OTHER;
 (* 0x00E3 *) wMsgTab[125].id   := 227;                        wMsgTab[125].msg := "SBM_GETRANGE";
                                                               wMsgTab[125].flg := ft.MSG_TYPE_OTHER;
 (* 0x00E4 *) wMsgTab[126].id   := 228;                        wMsgTab[126].msg := "SBM_ENABLE_ARROWS";
                                                               wMsgTab[126].flg := ft.MSG_TYPE_OTHER;
 (* 0x00E6 *) wMsgTab[127].id   := 230;                        wMsgTab[127].msg := "SBM_SETRANGEREDRAW";
              (*-- Some new stuff, WINVER >= 0x0400 --*)       wMsgTab[127].flg := ft.MSG_TYPE_OTHER;
 (* 0x00E9 *) wMsgTab[128].id   := 233;                        wMsgTab[128].msg := "SBM_SETSCROLLINFO";
                                                               wMsgTab[128].flg := ft.MSG_TYPE_OTHER;
 (* 0x00EA *) wMsgTab[129].id   := 234;                        wMsgTab[129].msg := "SBM_GETSCROLLINFO";
                                                               wMsgTab[129].flg := ft.MSG_TYPE_OTHER;
 (*----------< Buttom control messages >----------------------------------------------------*)
 (* 0x00F0 *) wMsgTab[130].id   := 240;                        wMsgTab[130].msg := "BM_GETCHECK"; 
                                                               wMsgTab[130].flg :=  ft.MSG_TYPE_BM;
 (* 0x00F1 *) wMsgTab[131].id   := 241;                        wMsgTab[131].msg := "BM_SETCHECK"; 
              wMsgTab[131].proc := Ctr.Proc_BM_SETCHECK;       wMsgTab[131].flg :=  ft.MSG_TYPE_BM;
 (* 0x00F2 *) wMsgTab[132].id   := 242;                        wMsgTab[132].msg := "BM_GETSTATE"; 
                                                               wMsgTab[132].flg :=  ft.MSG_TYPE_BM;
 (* 0x00F3 *) wMsgTab[133].id   := 243;                        wMsgTab[133].msg := "BM_SETSTATE"; 
              wMsgTab[133].proc := Ctr.Proc_BM_SETSTATE;       wMsgTab[133].flg :=  ft.MSG_TYPE_BM;
 (* 0x00F4 *) wMsgTab[134].id   := 244;                        wMsgTab[134].msg := "BM_SETSTYLE"; 
              wMsgTab[134].proc := Ctr.Proc_BM_SETSTYLE;       wMsgTab[134].flg :=  ft.MSG_TYPE_BM;
              (*-- Some new stuff, WINVER >= 0x0400 --*)
 (* 0x00F5 *) wMsgTab[135].id   := 245;                        wMsgTab[135].msg := "BM_CLICK"; 
                                                               wMsgTab[135].flg :=  ft.MSG_TYPE_BM;
 (* 0x00F6 *) wMsgTab[136].id   := 246;                        wMsgTab[136].msg := "BM_GETIMAGE"; 
                                                               wMsgTab[136].flg :=  ft.MSG_TYPE_BM;
 (* 0x00F7 *) wMsgTab[137].id   := 247;                        wMsgTab[137].msg := "BM_SETIMAGE"; 
                                                               wMsgTab[137].flg :=  ft.MSG_TYPE_BM;
 (*----------< Continuing common windows messages >----------------------------------------*)
 (* 0x0100 *) wMsgTab[138].id   := W.WM_KEYDOWN;               wMsgTab[138].msg := "WM_KEYDOWN"; (* equal to WM_KEYFIRST *)
              wMsgTab[138].proc := Inp.Proc_WM_KEYDOWN;        wMsgTab[138].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0101 *) wMsgTab[139].id   := W.WM_KEYUP;                 wMsgTab[139].msg := "WM_KEYUP"; 
              wMsgTab[139].proc := Inp.Proc_WM_KEYUP;          wMsgTab[139].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0102 *) wMsgTab[140].id   := W.WM_CHAR;                  wMsgTab[140].msg := "WM_CHAR"; 
              wMsgTab[140].proc := Inp.Proc_WM_CHAR;           wMsgTab[140].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0103 *) wMsgTab[141].id   := W.WM_DEADCHAR;              wMsgTab[141].msg := "WM_DEADCHAR"; 
              wMsgTab[141].proc := Inp.Proc_WM_DEADCHAR;       wMsgTab[141].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0104 *) wMsgTab[142].id   := W.WM_SYSKEYDOWN;            wMsgTab[142].msg := "WM_SYSKEYDOWN"; 
              wMsgTab[142].proc := Inp.Proc_WM_SYSKEYDOWN;     wMsgTab[142].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0105 *) wMsgTab[143].id   := W.WM_SYSKEYUP;              wMsgTab[143].msg := "WM_SYSKEYUP"; 
              wMsgTab[143].proc := Inp.Proc_WM_SYSKEYUP;       wMsgTab[143].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0106 *) wMsgTab[144].id   := W.WM_SYSCHAR;               wMsgTab[144].msg := "WM_SYSCHAR"; 
              wMsgTab[144].proc := Inp.Proc_WM_SYSCHAR;        wMsgTab[144].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0107 *) wMsgTab[145].id   := W.WM_SYSDEADCHAR;           wMsgTab[145].msg := "WM_SYSDEADCHAR"; 
              wMsgTab[145].proc := Inp.Proc_WM_SYSDEADCHAR;    wMsgTab[145].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0108 *) wMsgTab[146].id   := W.WM_KEYLAST;               wMsgTab[146].msg := "WM_KEYLAST";
              (*-- Some new stuff, WINVER >= 0x0400 --*)       wMsgTab[146].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x010D *) wMsgTab[147].id   := 269;                        wMsgTab[147].msg := "WM_IME_STARTCOMPOSITION"; 
                                                               wMsgTab[147].flg := ft.MSG_TYPE_OTHER;
 (* 0x010E *) wMsgTab[148].id   := 270;                        wMsgTab[148].msg := "WM_IME_ENDCOMPOSITION"; 
                                                               wMsgTab[148].flg := ft.MSG_TYPE_OTHER;
 (* 0x010F *) wMsgTab[149].id   := 271;                        wMsgTab[149].msg := "WM_IME_COMPOSITION"; (* equal to WM_IME_KEYLAST *)
              (*-- End of new stuff ------------------*)       wMsgTab[149].flg := ft.MSG_TYPE_OTHER;
 (* 0x0110 *) wMsgTab[150].id   := W.WM_INITDIALOG;            wMsgTab[150].msg := "WM_INITDIALOG"; 
              wMsgTab[150].proc := Proc_WM_INITDIALOG;         wMsgTab[150].flg :=  ft.MSG_TYPE_INIT;
 (* 0x0111 *) wMsgTab[151].id   := W.WM_COMMAND;               wMsgTab[151].msg := "WM_COMMAND"; 
              wMsgTab[151].proc := Inp.Proc_WM_COMMAND;        wMsgTab[151].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0112 *) wMsgTab[152].id   := W.WM_SYSCOMMAND;            wMsgTab[152].msg := "WM_SYSCOMMAND"; 
              wMsgTab[152].proc := Sys.Proc_WM_SYSCOMMAND;     wMsgTab[152].flg :=  ft.MSG_TYPE_SYS;
 (* 0x0113 *) wMsgTab[153].id   := W.WM_TIMER;                 wMsgTab[153].msg := "WM_TIMER"; 
              wMsgTab[153].proc := Inp.Proc_WM_TIMER;          wMsgTab[153].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0114 *) wMsgTab[154].id   := W.WM_HSCROLL;               wMsgTab[154].msg := "WM_HSCROLL";
              wMsgTab[154].proc := Proc_WM_HSCROLL;            wMsgTab[154].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0115 *) wMsgTab[155].id   := W.WM_VSCROLL;               wMsgTab[155].msg := "WM_VSCROLL";
              wMsgTab[155].proc := Proc_WM_VSCROLL;            wMsgTab[155].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0116 *) wMsgTab[156].id   := W.WM_INITMENU;              wMsgTab[156].msg := "WM_INITMENU"; 
              wMsgTab[156].proc := Proc_WM_INITMENU;           wMsgTab[156].flg :=  ft.MSG_TYPE_INIT;
 (* 0x0117 *) wMsgTab[157].id   := W.WM_INITMENUPOPUP;         wMsgTab[157].msg := "WM_INITMENUPOPUP"; 
              wMsgTab[157].proc := Proc_WM_INITMENUPOPUP;      wMsgTab[157].flg :=  ft.MSG_TYPE_INIT;
 (* 0x011F *) wMsgTab[158].id   := W.WM_MENUSELECT;            wMsgTab[158].msg := "WM_MENUSELECT"; 
              wMsgTab[158].proc := Inp.Proc_WM_MENUSELECT;     wMsgTab[158].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0120 *) wMsgTab[159].id   := W.WM_MENUCHAR;              wMsgTab[159].msg := "WM_MENUCHAR"; 
              wMsgTab[159].proc := Inp.Proc_WM_MENUCHAR;       wMsgTab[159].flg :=  ft.MSG_TYPE_INPUT;
 (* 0x0121 *) wMsgTab[160].id   := W.WM_ENTERIDLE;             wMsgTab[160].msg := "WM_ENTERIDLE"; 
              wMsgTab[160].proc := Sys.Proc_WM_ENTERIDLE;      wMsgTab[160].flg :=  ft.MSG_TYPE_SYS;
 (* 0x0132 *) wMsgTab[161].id   := 306;                        wMsgTab[161].msg := "WM_CTLCOLORMSGBOX"; 
                                                               wMsgTab[161].flg := ft.MSG_TYPE_OTHER;
 (* 0x0133 *) wMsgTab[162].id   := 307;                        wMsgTab[162].msg := "WM_CTLCOLOREDIT";
                                                               wMsgTab[162].flg := ft.MSG_TYPE_OTHER;
 (* 0x0134 *) wMsgTab[163].id   := 308;                        wMsgTab[163].msg := "WM_CTLCOLORLISTBOX";
                                                               wMsgTab[163].flg := ft.MSG_TYPE_OTHER;
 (* 0x0135 *) wMsgTab[164].id   := 309;                        wMsgTab[164].msg := "WM_CTLCOLORBTN";
                                                               wMsgTab[164].flg := ft.MSG_TYPE_OTHER;
 (* 0x0136 *) wMsgTab[165].id   := 310;                        wMsgTab[165].msg := "WM_CTLCOLORDLG";
                                                               wMsgTab[165].flg := ft.MSG_TYPE_OTHER;
 (* 0x0137 *) wMsgTab[166].id   := 311;                        wMsgTab[166].msg := "WM_CTLCOLORSCROLLBAR";
                                                               wMsgTab[166].flg := ft.MSG_TYPE_OTHER;
 (* 0x0138 *) wMsgTab[167].id   := 312;                        wMsgTab[167].msg := "WM_CTLCOLORSTATIC";
                                                               wMsgTab[167].flg := ft.MSG_TYPE_OTHER;
 (*----------< Combo box messages >---------------------------------------------------------*)
 (* 0x0140 *) wMsgTab[168].id   := 320;                        wMsgTab[168].msg := "CB_GETEDITSEL"; 
                                                               wMsgTab[168].flg :=  ft.MSG_TYPE_CB;  
 (* 0x0141 *) wMsgTab[169].id   := 321;                        wMsgTab[169].msg := "CB_LIMITTEXT";
              wMsgTab[169].proc := Ctr.Proc_CB_LIMITTEXT;      wMsgTab[169].flg :=  ft.MSG_TYPE_CB;
 (* 0x0142 *) wMsgTab[170].id   := 322;                        wMsgTab[170].msg := "CB_SETEDITSEL"; 
              wMsgTab[170].proc := Ctr.Proc_CB_SETEDITSEL;     wMsgTab[170].flg :=  ft.MSG_TYPE_CB;
 (* 0x0143 *) wMsgTab[171].id   := 323;                        wMsgTab[171].msg := "CB_ADDSTRING"; 
              wMsgTab[171].proc := Ctr.Proc_CB_ADDSTRING;      wMsgTab[171].flg :=  ft.MSG_TYPE_CB;
 (* 0x0144 *) wMsgTab[172].id   := 324;                        wMsgTab[172].msg := "CB_DELETESTRING"; 
              wMsgTab[172].proc := Ctr.Proc_CB_DELETESTRING;   wMsgTab[172].flg :=  ft.MSG_TYPE_CB;
 (* 0x0145 *) wMsgTab[173].id   := 325;                        wMsgTab[173].msg := "CB_DIR"; 
              wMsgTab[173].proc := Ctr.Proc_CB_DIR;            wMsgTab[173].flg :=  ft.MSG_TYPE_CB;
 (* 0x0146 *) wMsgTab[174].id   := 326;                        wMsgTab[174].msg := "CB_GETCOUNT"; 
                                                               wMsgTab[174].flg :=  ft.MSG_TYPE_CB;
 (* 0x0147 *) wMsgTab[175].id   := 327;                        wMsgTab[175].msg := "CB_GETCURSEL"; 
                                                               wMsgTab[175].flg :=  ft.MSG_TYPE_CB;
 (* 0x0148 *) wMsgTab[176].id   := 328;                        wMsgTab[176].msg := "CB_GETLBTEXT"; 
              wMsgTab[176].proc := Ctr.Proc_CB_GETLBTEXT;      wMsgTab[176].flg :=  ft.MSG_TYPE_CB;
 (* 0x0149 *) wMsgTab[177].id   := 329;                        wMsgTab[177].msg := "CB_GETLBTEXTLEN"; 
              wMsgTab[177].proc := Ctr.Proc_CB_GETLBTEXTLEN;   wMsgTab[177].flg :=  ft.MSG_TYPE_CB;
 (* 0x014A *) wMsgTab[178].id   := 330;                        wMsgTab[178].msg := "CB_INSERTSTRING"; 
              wMsgTab[178].proc := Ctr.Proc_CB_INSERTSTRING;   wMsgTab[178].flg :=  ft.MSG_TYPE_CB;
 (* 0x014B *) wMsgTab[179].id   := 331;                        wMsgTab[179].msg := "CB_RESETCONTENT";
                                                               wMsgTab[179].flg :=  ft.MSG_TYPE_CB;
 (* 0x014C *) wMsgTab[180].id   := 332;                        wMsgTab[180].msg := "CB_FINDSTRING"; 
              wMsgTab[180].proc := Ctr.Proc_CB_FINDSTRING;     wMsgTab[180].flg :=  ft.MSG_TYPE_CB;
 (* 0x014D *) wMsgTab[181].id   := 333;                        wMsgTab[181].msg := "CB_SELECTSTRING"; 
              wMsgTab[181].proc := Ctr.Proc_CB_SELECTSTRING;   wMsgTab[181].flg :=  ft.MSG_TYPE_CB;
 (* 0x014E *) wMsgTab[182].id   := 334;                        wMsgTab[182].msg := "CB_SETCURSEL"; 
              wMsgTab[182].proc := Ctr.Proc_CB_SETCURSEL;      wMsgTab[182].flg :=  ft.MSG_TYPE_CB;
 (* 0x014F *) wMsgTab[183].id   := 335;                        wMsgTab[183].msg := "CB_SHOWDROPDOWN"; 
              wMsgTab[183].proc := Ctr.Proc_CB_SHOWDROPDOWN;   wMsgTab[183].flg :=  ft.MSG_TYPE_CB;
 (* 0x0150 *) wMsgTab[184].id   := 336;                        wMsgTab[184].msg := "CB_GETITEMDATA"; 
              wMsgTab[184].proc := Ctr.Proc_CB_GETITEMDATA;    wMsgTab[184].flg :=  ft.MSG_TYPE_CB;
 (* 0x0151 *) wMsgTab[185].id   := 337;                        wMsgTab[185].msg := "CB_SETITEMDATA"; 
              wMsgTab[185].proc := Ctr.Proc_CB_SETITEMDATA;    wMsgTab[185].flg :=  ft.MSG_TYPE_CB;
 (* 0x0152 *) wMsgTab[186].id   := 338;                        wMsgTab[186].msg := "CB_GETDROPPEDCONTROLRECT"; 
              wMsgTab[186].proc := Ctr.Proc_CB_GETDROPPEDCONTROLRECT; wMsgTab[186].flg :=  ft.MSG_TYPE_CB;
 (* 0x0153 *) wMsgTab[187].id   := 339;                        wMsgTab[187].msg := "CB_SETITEMHEIGHT"; 
              wMsgTab[187].proc := Ctr.Proc_CB_SETITEMHEIGHT;  wMsgTab[187].flg :=  ft.MSG_TYPE_CB;
 (* 0x0154 *) wMsgTab[188].id   := 340;                        wMsgTab[188].msg := "CB_GETITEMHEIGHT"; 
              wMsgTab[188].proc := Ctr.Proc_CB_GETITEMHEIGHT;  wMsgTab[188].flg :=  ft.MSG_TYPE_CB;
 (* 0x0155 *) wMsgTab[189].id   := 341;                        wMsgTab[189].msg := "CB_SETEXTENDEDUI";
              wMsgTab[189].proc := Ctr.Proc_CB_SETEXTENDEDUI;  wMsgTab[189].flg :=  ft.MSG_TYPE_CB;
 (* 0x0156 *) wMsgTab[190].id   := 342;                        wMsgTab[190].msg := "CB_GETEXTENDEDUI"; 
                                                               wMsgTab[190].flg :=  ft.MSG_TYPE_CB;
 (* 0x0157 *) wMsgTab[191].id   := 343;                        wMsgTab[191].msg := "CB_GETDROPPEDSTATE"; 
                                                               wMsgTab[191].flg :=  ft.MSG_TYPE_CB;
 (* 0x0158 *) wMsgTab[192].id   := 344;                        wMsgTab[192].msg := "CB_FINDSTRINGEXACT"; 
              wMsgTab[192].proc := Ctr.Proc_CB_FINDSTRINGEXACT;wMsgTab[192].flg :=  ft.MSG_TYPE_CB;
 (* 0x0159 *) wMsgTab[193].id   := 345;                        wMsgTab[193].msg := "CB_SETLOCALE";
                                                               wMsgTab[193].flg :=  ft.MSG_TYPE_CB;
 (* 0x015A *) wMsgTab[194].id   := 346;                        wMsgTab[194].msg := "CB_GETLOCALE";
                                                               wMsgTab[194].flg :=  ft.MSG_TYPE_CB;
 (*----------< Static control messages >----------------------------------------------------*)
 (* 0x0170 *) wMsgTab[195].id   := 368;                        wMsgTab[195].msg := "STM_SETICON"; 
                                                               wMsgTab[195].flg :=  ft.MSG_TYPE_STM;
 (* 0x0171 *) wMsgTab[196].id   := 369;                        wMsgTab[196].msg := "STM_GETICON"; 
                                                               wMsgTab[196].flg :=  ft.MSG_TYPE_STM;
 (* 0x0172 *) wMsgTab[197].id   := 370;                        wMsgTab[197].msg := "STM_SETIMAGE"; 
                                                               wMsgTab[197].flg :=  ft.MSG_TYPE_STM;
 (* 0x0173 *) wMsgTab[198].id   := 371;                        wMsgTab[198].msg := "STM_GETIMAGE"; 
                                                               wMsgTab[198].flg :=  ft.MSG_TYPE_STM;
 (* 0x0174 *) wMsgTab[199].id   := 372;                        wMsgTab[199].msg := "STM_MSGMAX"; 
                                                               wMsgTab[199].flg :=  ft.MSG_TYPE_STM;
 (*----------< Listbox control messages >---------------------------------------------------*)
 (* 0x0180 *) wMsgTab[200].id   := 384;                        wMsgTab[200].msg := "LB_ADDSTRING"; 
              wMsgTab[200].proc := Ctr.Proc_LB_ADDSTRING;      wMsgTab[200].flg :=  ft.MSG_TYPE_LB;
 (* 0x0181 *) wMsgTab[201].id   := 385;                        wMsgTab[201].msg := "LB_INSERTSTRING"; 
              wMsgTab[201].proc := Ctr.Proc_LB_INSERTSTRING;   wMsgTab[201].flg :=  ft.MSG_TYPE_LB;
 (* 0x0182 *) wMsgTab[202].id   := 386;                        wMsgTab[202].msg := "LB_DELETESTRING"; 
              wMsgTab[202].proc := Ctr.Proc_LB_DELETESTRING;   wMsgTab[202].flg :=  ft.MSG_TYPE_LB;
 (* 0x0183 *) wMsgTab[203].id   := 387;                        wMsgTab[203].msg := "LB_SELITEMRANGEEX";
                                                               wMsgTab[203].flg :=  ft.MSG_TYPE_LB;
 (* 0x0184 *) wMsgTab[204].id   := 388;                        wMsgTab[204].msg := "LB_RESETCONTENT"; 
                                                               wMsgTab[204].flg :=  ft.MSG_TYPE_LB;
 (* 0x0185 *) wMsgTab[205].id   := 389;                        wMsgTab[205].msg := "LB_SETSEL"; 
              wMsgTab[205].proc := Ctr.Proc_LB_SETSEL;         wMsgTab[205].flg :=  ft.MSG_TYPE_LB;
 (* 0x0186 *) wMsgTab[206].id   := 390;                        wMsgTab[206].msg := "LB_SETCURSEL"; 
              wMsgTab[206].proc := Ctr.Proc_LB_SETCURSEL;      wMsgTab[206].flg :=  ft.MSG_TYPE_LB;
 (* 0x0187 *) wMsgTab[207].id   := 391;                        wMsgTab[207].msg := "LB_GETSEL"; 
              wMsgTab[207].proc := Ctr.Proc_LB_GETSEL;         wMsgTab[207].flg :=  ft.MSG_TYPE_LB;
 (* 0x0188 *) wMsgTab[208].id   := 392;                        wMsgTab[208].msg := "LB_GETCURSEL"; 
                                                               wMsgTab[208].flg :=  ft.MSG_TYPE_LB;
 (* 0x0189 *) wMsgTab[209].id   := 393;                        wMsgTab[209].msg := "LB_GETTEXT"; 
              wMsgTab[209].proc := Ctr.Proc_LB_GETTEXT;        wMsgTab[209].flg :=  ft.MSG_TYPE_LB;
 (* 0x018A *) wMsgTab[210].id   := 394;                        wMsgTab[210].msg := "LB_GETTEXTLEN"; 
              wMsgTab[210].proc := Ctr.Proc_LB_GETTEXTLEN;     wMsgTab[210].flg :=  ft.MSG_TYPE_LB;
 (* 0x018B *) wMsgTab[211].id   := 395;                        wMsgTab[211].msg := "LB_GETCOUNT"; 
                                                               wMsgTab[211].flg :=  ft.MSG_TYPE_LB;
 (* 0x018C *) wMsgTab[212].id   := 396;                        wMsgTab[212].msg := "LB_SELECTSTRING";
              wMsgTab[212].proc := Ctr.Proc_LB_SELECTSTRING;   wMsgTab[212].flg :=  ft.MSG_TYPE_LB;
 (* 0x018D *) wMsgTab[213].id   := 397;                        wMsgTab[213].msg := "LB_DIR"; 
              wMsgTab[213].proc := Ctr.Proc_LB_DIR;            wMsgTab[213].flg :=  ft.MSG_TYPE_LB;
 (* 0x018E *) wMsgTab[214].id   := 398;                        wMsgTab[214].msg := "LB_GETTOPINDEX"; 
                                                               wMsgTab[214].flg :=  ft.MSG_TYPE_LB;
 (* 0x018F *) wMsgTab[215].id   := 399;                        wMsgTab[215].msg := "LB_FINDSTRING"; 
              wMsgTab[215].proc := Ctr.Proc_LB_FINDSTRING;     wMsgTab[215].flg :=  ft.MSG_TYPE_LB;
 (* 0x0190 *) wMsgTab[216].id   := 400;                        wMsgTab[216].msg := "LB_GETSELCOUNT"; 
                                                               wMsgTab[216].flg :=  ft.MSG_TYPE_LB;
 (* 0x0191 *) wMsgTab[217].id   := 401;                        wMsgTab[217].msg := "LB_GETSELITEMS"; 
              wMsgTab[217].proc := Ctr.Proc_LB_GETSELITEMS;    wMsgTab[217].flg :=  ft.MSG_TYPE_LB;
 (* 0x0192 *) wMsgTab[218].id   := 402;                        wMsgTab[218].msg := "LB_SETTABSTOPS"; 
              wMsgTab[218].proc := Ctr.Proc_LB_SETTABSTOPS;    wMsgTab[218].flg :=  ft.MSG_TYPE_LB;
 (* 0x0193 *) wMsgTab[219].id   := 403;                        wMsgTab[219].msg := "LB_GETHORIZONTALEXTENT"; 
                                                               wMsgTab[219].flg :=  ft.MSG_TYPE_LB;
 (* 0x0194 *) wMsgTab[220].id   := 404;                        wMsgTab[220].msg := "LB_SETHORIZONTALEXTENT"; 
              wMsgTab[220].proc := Ctr.Proc_LB_SETHORIZONTALEXTENT; wMsgTab[220].flg :=  ft.MSG_TYPE_LB;
 (* 0x0195 *) wMsgTab[221].id   := 405;                        wMsgTab[221].msg := "LB_SETCOLUMNWIDTH"; 
              wMsgTab[221].proc := Ctr.Proc_LB_SETCOLUMNWIDTH; wMsgTab[221].flg :=  ft.MSG_TYPE_LB;
 (* 0x0196 *) wMsgTab[222].id   := 406;                        wMsgTab[222].msg := "LB_ADDFILE";
                                                               wMsgTab[222].flg :=  ft.MSG_TYPE_LB;
 (* 0x0197 *) wMsgTab[223].id   := 407;                        wMsgTab[223].msg := "LB_SETTOPINDEX"; 
              wMsgTab[223].proc := Ctr.Proc_LB_SETTOPINDEX;    wMsgTab[223].flg :=  ft.MSG_TYPE_LB;
 (* 0x0198 *) wMsgTab[224].id   := 408;                        wMsgTab[224].msg := "LB_GETITEMRECT"; 
              wMsgTab[224].proc := Ctr.Proc_LB_GETITEMRECT;    wMsgTab[224].flg :=  ft.MSG_TYPE_LB;
 (* 0x0199 *) wMsgTab[225].id   := 409;                        wMsgTab[225].msg := "LB_GETITEMDATA"; 
              wMsgTab[225].proc := Ctr.Proc_LB_GETITEMDATA;    wMsgTab[225].flg :=  ft.MSG_TYPE_LB;
 (* 0x019A *) wMsgTab[226].id   := 410;                        wMsgTab[226].msg := "LB_SETITEMDATA"; 
              wMsgTab[226].proc := Ctr.Proc_LB_SETITEMDATA;    wMsgTab[226].flg :=  ft.MSG_TYPE_LB;
 (* 0x019B *) wMsgTab[227].id   := 411;                        wMsgTab[227].msg := "LB_SELITEMRANGE";
              wMsgTab[227].proc := Ctr.Proc_LB_SELITEMRANGE;   wMsgTab[227].flg :=  ft.MSG_TYPE_LB;
 (* 0x019C *) wMsgTab[228].id   := 412;                        wMsgTab[228].msg := "LB_SETANCHORINDEX"; 
                                                               wMsgTab[228].flg :=  ft.MSG_TYPE_LB;
 (* 0x019D *) wMsgTab[229].id   := 413;                        wMsgTab[229].msg := "LB_GETANCHORINDEX"; 
                                                               wMsgTab[229].flg :=  ft.MSG_TYPE_LB;
 (* 0x019E *) wMsgTab[230].id   := 414;                        wMsgTab[230].msg := "LB_SETCARETINDEX"; 
              wMsgTab[230].proc := Ctr.Proc_LB_SETCARETINDEX;  wMsgTab[230].flg :=  ft.MSG_TYPE_LB;
 (* 0x019F *) wMsgTab[231].id   := 415;                        wMsgTab[231].msg := "LB_GETCARETINDEX"; 
                                                               wMsgTab[231].flg :=  ft.MSG_TYPE_LB;
 (* 0x01A0 *) wMsgTab[232].id   := 416;                        wMsgTab[232].msg := "LB_SETITEMHEIGHT";
              wMsgTab[232].proc := Ctr.Proc_LB_SETITEMHEIGHT;  wMsgTab[232].flg :=  ft.MSG_TYPE_LB;
 (* 0x01A1 *) wMsgTab[233].id   := 417;                        wMsgTab[233].msg := "LB_GETITEMHEIGHT"; 
              wMsgTab[233].proc := Ctr.Proc_LB_GETITEMHEIGHT;  wMsgTab[233].flg :=  ft.MSG_TYPE_LB;
 (* 0x01A2 *) wMsgTab[234].id   := 418;                        wMsgTab[234].msg := "LB_FINDSTRINGEXACT"; 
              wMsgTab[234].proc := Ctr.Proc_LB_FINDSTRINGEXACT;wMsgTab[234].flg :=  ft.MSG_TYPE_LB;
 (* 0x01A5 *) wMsgTab[235].id   := 421;                        wMsgTab[235].msg := "LB_SETLOCALE";
                                                               wMsgTab[235].flg :=  ft.MSG_TYPE_LB;
 (* 0x01A6 *) wMsgTab[236].id   := 422;                        wMsgTab[236].msg := "LB_GETLOCALE";
                                                               wMsgTab[236].flg :=  ft.MSG_TYPE_LB;
 (* 0x01A7 *) wMsgTab[237].id   := 423;                        wMsgTab[237].msg := "LB_SETCOUNT"; 
              (*--- WINVER >= 0x0400 ---*)                     wMsgTab[237].flg :=  ft.MSG_TYPE_LB;
 (* 0x01A8 *) wMsgTab[238].id   := 424;                        wMsgTab[238].msg := "LB_INITSTORAGE"; 
              IF winVer < ft.WIN_95 THEN wMsgTab[238].msg := "LB_MSGMAX" END; wMsgTab[238].flg :=  ft.MSG_TYPE_LB;
 (* 0x01A9 *) wMsgTab[239].id   := 425;                        wMsgTab[239].msg := "LB_ITEMFROMPOINT"; 
                                                               wMsgTab[239].flg :=  ft.MSG_TYPE_LB;
 (* 0x01B0 *) wMsgTab[240].id   := 432;                        wMsgTab[240].msg := "LB_MSGMAX"; 
                                                               wMsgTab[240].flg :=  ft.MSG_TYPE_LB;
 (*----------< Continue windows common messages >-------------------------------------------*)
 (* 0x0200 *) wMsgTab[241].id   := W.WM_MOUSEMOVE;             wMsgTab[241].msg := "WM_MOUSEMOVE"; (* equal to WM_MOUSEFIRST *)
              wMsgTab[241].proc := Proc_WM_MOUSEMOVE;          wMsgTab[241].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0201 *) wMsgTab[242].id   := W.WM_LBUTTONDOWN;           wMsgTab[242].msg := "WM_LBUTTONDOWN";
              wMsgTab[242].proc := Proc_WM_LBUTTONDOWN;        wMsgTab[242].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0202 *) wMsgTab[243].id   := W.WM_LBUTTONUP;             wMsgTab[243].msg := "WM_LBUTTONUP";
              wMsgTab[243].proc := Proc_WM_LBUTTONUP;          wMsgTab[243].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0203 *) wMsgTab[244].id   := W.WM_LBUTTONDBLCLK;         wMsgTab[244].msg := "WM_LBUTTONDBLCLK";
              wMsgTab[244].proc := Proc_WM_LBUTTONDBLCLK;      wMsgTab[244].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0204 *) wMsgTab[245].id   := W.WM_RBUTTONDOWN;           wMsgTab[245].msg := "WM_RBUTTONDOWN"; 
              wMsgTab[245].proc := Proc_WM_RBUTTONDOWN;        wMsgTab[245].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0205 *) wMsgTab[246].id   := W.WM_RBUTTONUP;             wMsgTab[246].msg := "WM_RBUTTONUP"; 
              wMsgTab[246].proc := Proc_WM_RBUTTONUP;          wMsgTab[246].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0206 *) wMsgTab[247].id   := W.WM_RBUTTONDBLCLK;         wMsgTab[247].msg := "WM_RBUTTONDBLCLK"; 
              wMsgTab[247].proc := Proc_WM_RBUTTONDBLCLK;      wMsgTab[247].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0207 *) wMsgTab[248].id   := W.WM_MBUTTONDOWN;           wMsgTab[248].msg := "WM_MBUTTONDOWN";
              wMsgTab[248].proc := Proc_WM_MBUTTONDOWN;        wMsgTab[248].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0208 *) wMsgTab[249].id   := W.WM_MBUTTONUP;             wMsgTab[249].msg := "WM_MBUTTONUP";
              wMsgTab[249].proc := Proc_WM_MBUTTONUP;          wMsgTab[249].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0209 *) wMsgTab[250].id   := W.WM_MBUTTONDBLCLK;         wMsgTab[250].msg := "WM_MBUTTONDBLCLK"; (* equal to WM_MOUSELAST *)
              wMsgTab[250].proc := Proc_WM_MBUTTONDBLCLK;      wMsgTab[250].flg :=  ft.MSG_TYPE_MOUSE;
 (* 0x0210 *) wMsgTab[251].id   := W.WM_PARENTNOTIFY;          wMsgTab[251].msg := "WM_PARENTNOTIFY";
              wMsgTab[251].proc := Proc_WM_PARENTNOTIFY;       wMsgTab[251].flg :=  ft.MSG_TYPE_MOUSE+ft.MSG_TYPE_INPUT;
 (* 0x0211 *) wMsgTab[252].id   := 529;                        wMsgTab[252].msg := "WM_ENTERMENULOOP"; 
                                                               wMsgTab[252].flg := ft.MSG_TYPE_OTHER;
 (* 0x0212 *) wMsgTab[253].id   := 530;                        wMsgTab[253].msg := "WM_EXITMENULOOP";
              (*-- Some new stuff, WINVER >= 0x0400 --*)       wMsgTab[253].flg := ft.MSG_TYPE_OTHER;
 (* 0x0213 *) wMsgTab[254].id   := 531;                        wMsgTab[254].msg := "WM_NEXTMENU";
                                                               wMsgTab[254].flg := ft.MSG_TYPE_OTHER;
 (* 0x0214 *) wMsgTab[255].id   := 532;                        wMsgTab[255].msg := "WM_SIZING";
                                                               wMsgTab[255].flg := ft.MSG_TYPE_OTHER;
 (* 0x0215 *) wMsgTab[256].id   := 533;                        wMsgTab[256].msg := "WM_CAPTURECHANGED";
                                                               wMsgTab[256].flg := ft.MSG_TYPE_OTHER;
 (* 0x0216 *) wMsgTab[257].id   := 534;                        wMsgTab[257].msg := "WM_MOVING";
                                                               wMsgTab[257].flg := ft.MSG_TYPE_OTHER;
 (* 0x0218 *) wMsgTab[258].id   := 536;                        wMsgTab[258].msg := "WM_POWERBROADCAST";
                                                               wMsgTab[258].flg := ft.MSG_TYPE_OTHER;
 (* 0x0219 *) wMsgTab[259].id   := 537;                        wMsgTab[259].msg := "WM_DEVICECHANGE";
              (*-- End of new stuff ------------------*)       wMsgTab[259].flg := ft.MSG_TYPE_OTHER;
 (* 0x0220 *) wMsgTab[260].id   := W.WM_MDICREATE;             wMsgTab[260].msg := "WM_MDICREATE"; 
                                                               wMsgTab[260].flg := ft.MSG_TYPE_OTHER;
 (* 0x0221 *) wMsgTab[261].id   := W.WM_MDIDESTROY;            wMsgTab[261].msg := "WM_MDIDESTROY";
                                                               wMsgTab[261].flg := ft.MSG_TYPE_OTHER;
 (* 0x0222 *) wMsgTab[262].id   := W.WM_MDIACTIVATE;           wMsgTab[262].msg := "WM_MDIACTIVATE";
                                                               wMsgTab[262].flg := ft.MSG_TYPE_OTHER;
 (* 0x0223 *) wMsgTab[263].id   := W.WM_MDIRESTORE;            wMsgTab[263].msg := "WM_MDIRESTORE";
                                                               wMsgTab[263].flg := ft.MSG_TYPE_OTHER;
 (* 0x0224 *) wMsgTab[264].id   := W.WM_MDINEXT;               wMsgTab[264].msg := "WM_MDINEXT";
                                                               wMsgTab[264].flg := ft.MSG_TYPE_OTHER;
 (* 0x0225 *) wMsgTab[265].id   := W.WM_MDIMAXIMIZE;           wMsgTab[265].msg := "WM_MDIMAXIMIZE";
                                                               wMsgTab[265].flg := ft.MSG_TYPE_OTHER;
 (* 0x0226 *) wMsgTab[266].id   := W.WM_MDITILE;               wMsgTab[266].msg := "WM_MDITILE";
                                                               wMsgTab[266].flg := ft.MSG_TYPE_OTHER;
 (* 0x0227 *) wMsgTab[267].id   := W.WM_MDICASCADE;            wMsgTab[267].msg := "WM_MDICASCADE";
                                                               wMsgTab[267].flg := ft.MSG_TYPE_OTHER;
 (* 0x0228 *) wMsgTab[268].id   := W.WM_MDIICONARRANGE;        wMsgTab[268].msg := "WM_MDIICONARRANGE";
                                                               wMsgTab[268].flg := ft.MSG_TYPE_OTHER;
 (* 0x0229 *) wMsgTab[269].id   := W.WM_MDIGETACTIVE;          wMsgTab[269].msg := "WM_MDIGETACTIVE";
                                                               wMsgTab[269].flg := ft.MSG_TYPE_OTHER;
 (* 0x0230 *) wMsgTab[270].id   := W.WM_MDISETMENU;            wMsgTab[270].msg := "WM_MDISETNEMU";
                                                               wMsgTab[270].flg := ft.MSG_TYPE_OTHER;
 (* 0x0231 *) wMsgTab[271].id   := 561;                        wMsgTab[271].msg := "WM_ENTERSIZEMOVE";
                                                               wMsgTab[271].flg := ft.MSG_TYPE_OTHER;
 (* 0x0232 *) wMsgTab[272].id   := 562;                        wMsgTab[272].msg := "WM_EXITSIZEMOVE";
                                                               wMsgTab[272].flg := ft.MSG_TYPE_OTHER;
 (* 0x0233 *) wMsgTab[273].id   := W.WM_DROPFILES;             wMsgTab[273].msg := "WM_DROPFILES";
                                                               wMsgTab[273].flg := ft.MSG_TYPE_OTHER;
 (* 0x0234 *) wMsgTab[274].id   := 564;                        wMsgTab[274].msg := "WM_MDIREFRESHMENU";
                                                               wMsgTab[274].flg := ft.MSG_TYPE_OTHER;
 (* 0x0300 *) wMsgTab[275].id   := W.WM_CUT;                   wMsgTab[275].msg := "WM_CUT";
                                                               wMsgTab[275].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x0301 *) wMsgTab[276].id   := W.WM_COPY;                  wMsgTab[276].msg := "WM_COPY";
                                                               wMsgTab[276].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x0302 *) wMsgTab[277].id   := W.WM_PASTE;                 wMsgTab[277].msg := "WM_PASTE";
                                                               wMsgTab[277].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x0303 *) wMsgTab[278].id   := W.WM_CLEAR;                 wMsgTab[278].msg := "WM_CLEAR";
                                                               wMsgTab[278].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x0304 *) wMsgTab[279].id   := W.WM_UNDO;                  wMsgTab[279].msg := "WM_UNDO";
                                                               wMsgTab[279].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x0305 *) wMsgTab[280].id   := W.WM_RENDERFORMAT;          wMsgTab[280].msg := "WM_RENDERFORMAT";
              wMsgTab[280].proc := Clp.Proc_WM_RENDERFORMAT;   wMsgTab[280].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x0306 *) wMsgTab[281].id   := W.WM_RENDERALLFORMATS;      wMsgTab[281].msg := "WM_RENDERALLFORMATS";
                                                               wMsgTab[281].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x0307 *) wMsgTab[282].id   := W.WM_DESTROYCLIPBOARD;      wMsgTab[282].msg := "WM_DESTROYCLIPBOARD";
                                                               wMsgTab[282].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x0308 *) wMsgTab[283].id   := W.WM_DRAWCLIPBOARD;         wMsgTab[283].msg := "WM_DRAWCLIPBOARD";
                                                               wMsgTab[283].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x0309 *) wMsgTab[284].id   := W.WM_PAINTCLIPBOARD;        wMsgTab[284].msg := "WM_PAINTCLIPBOARD";
                                                               wMsgTab[284].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x030A *) wMsgTab[285].id   := W.WM_VSCROLLCLIPBOARD;      wMsgTab[285].msg := "WM_VSCROLLCLIPBOARD";
              wMsgTab[285].proc := Clp.Proc_WM_VSCROLLCLIPBOARD;wMsgTab[285].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x030B *) wMsgTab[286].id   := W.WM_SIZECLIPBOARD;         wMsgTab[286].msg := "WM_SIZECLIPBOARD";
              wMsgTab[286].proc := Clp.Proc_WM_SIZECLIPBOARD;  wMsgTab[286].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x030C *) wMsgTab[287].id   := W.WM_ASKCBFORMATNAME;       wMsgTab[287].msg := "WM_ASKCBFORMATNAME";
              wMsgTab[287].proc := Clp.Proc_WM_ASKCBFORMATNAME;wMsgTab[287].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x030D *) wMsgTab[288].id   := W.WM_CHANGECBCHAIN;         wMsgTab[288].msg := "WM_CHANGECBCHAIN";
              wMsgTab[288].proc := Clp.Proc_WM_CHANGECBCHAIN;  wMsgTab[288].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x030E *) wMsgTab[289].id   := W.WM_HSCROLLCLIPBOARD;      wMsgTab[289].msg := "WM_HSCROLLCLIPBOARD";
              wMsgTab[289].proc := Clp.Proc_WM_HSCROLLCLIPBOARD;wMsgTab[289].flg := ft.MSG_TYPE_CLPBRD;
 (* 0x030F *) wMsgTab[290].id   := W.WM_QUERYNEWPALETTE;       wMsgTab[290].msg := "WM_QUERYNEWPALETTE";
                                                               wMsgTab[290].flg :=  ft.MSG_TYPE_WND;
 (* 0x0310 *) wMsgTab[291].id   := W.WM_PALETTEISCHANGING;     wMsgTab[291].msg := "WM_PALETTEISCHANGING";
              wMsgTab[291].proc := Sys.Proc_WM_PALETTEISCHANGING; wMsgTab[291].flg:=  ft.MSG_TYPE_SYS;
 (* 0x0311 *) wMsgTab[292].id   := W.WM_PALETTECHANGED;        wMsgTab[292].msg := "WM_PALETTECHANGED";
              wMsgTab[292].proc := Sys.Proc_WM_PALETTECHANGED; wMsgTab[292].flg :=  ft.MSG_TYPE_SYS;
 (* 0x0312 *) wMsgTab[293].id   := 786;                        wMsgTab[293].msg := "WM_HOTKEY";
              (*-- Some new stuff, WINVER >= 0x0400 --*)       wMsgTab[293].flg := ft.MSG_TYPE_OTHER;
 (* 0x0317 *) wMsgTab[294].id   := 791;                        wMsgTab[294].msg := "WM_PRINT";
                                                               wMsgTab[294].flg := ft.MSG_TYPE_OTHER;
 (* 0x0318 *) wMsgTab[295].id   := 792;                        wMsgTab[295].msg := "WM_PRINTCLIENT";
                                                               wMsgTab[295].flg := ft.MSG_TYPE_OTHER;
 (* 0x0358 *) wMsgTab[296].id   := 856;                        wMsgTab[296].msg := "WM_HANDHELDFIRST";
                                                               wMsgTab[296].flg := ft.MSG_TYPE_OTHER;
 (* 0x035F *) wMsgTab[297].id   := 863;                        wMsgTab[297].msg := "WM_HANDHELDLAST";
                                                               wMsgTab[297].flg := ft.MSG_TYPE_OTHER;
 (* 0x0360 *) wMsgTab[298].id   := 864;                        wMsgTab[298].msg := "WM_AFXFIRST";
                                                               wMsgTab[298].flg := ft.MSG_TYPE_OTHER;
 (* 0x037F *) wMsgTab[299].id   := 895;                        wMsgTab[299].msg := "WM_AFXLAST";
              (*-- End of new stuff ------------------*)       wMsgTab[299].flg := ft.MSG_TYPE_OTHER;
 (* 0x0380 *) wMsgTab[300].id   := W.WM_PENWINFIRST;           wMsgTab[300].msg := "WM_PENWINFIRST";
                                                               wMsgTab[300].flg := ft.MSG_TYPE_OTHER;
 (* 0x038F *) wMsgTab[301].id   := W.WM_PENWINLAST;            wMsgTab[301].msg := "WM_PENWINLAST";
                                                               wMsgTab[301].flg := ft.MSG_TYPE_OTHER; 
 (* 0x03E0 *) wMsgTab[302].id   := 992;                        wMsgTab[302].msg := "WM_DDE_INITIATE";
              wMsgTab[302].proc := dde.Proc_WM_DDE_INITIATE;   wMsgTab[302].flg := ft.MSG_TYPE_DDE; 
 (* 0x03E1 *) wMsgTab[303].id   := 993;                        wMsgTab[303].msg := "WM_DDE_TERMINATE";
              wMsgTab[303].proc := dde.Proc_WM_DDE_TERMINATE;  wMsgTab[303].flg := ft.MSG_TYPE_DDE; 
 (* 0x03E2 *) wMsgTab[304].id   := 994;                        wMsgTab[304].msg := "WM_DDE_ADVISE";
              wMsgTab[304].proc := dde.Proc_WM_DDE_ADVISE;     wMsgTab[304].flg := ft.MSG_TYPE_DDE;
 (* 0x03E3 *) wMsgTab[305].id   := 995;                        wMsgTab[305].msg := "WM_DDE_UNADVISE";
              wMsgTab[305].proc := dde.Proc_WM_DDE_UNADVISE;   wMsgTab[305].flg := ft.MSG_TYPE_DDE; 
 (* 0x03E4 *) wMsgTab[306].id   := 996;                        wMsgTab[306].msg := "WM_DDE_ACK";
              wMsgTab[306].proc := dde.Proc_WM_DDE_ACK;        wMsgTab[306].flg := ft.MSG_TYPE_DDE;
 (* 0x03E5 *) wMsgTab[307].id   := 997;                        wMsgTab[307].msg := "WM_DDE_DATA";
              wMsgTab[307].proc := dde.Proc_WM_DDE_DATA;       wMsgTab[307].flg := ft.MSG_TYPE_DDE; 
 (* 0x03E6 *) wMsgTab[308].id   := 998;                        wMsgTab[308].msg := "WM_DDE_REQUEST";
              wMsgTab[308].proc := dde.Proc_WM_DDE_REQUEST;    wMsgTab[308].flg := ft.MSG_TYPE_DDE;
 (* 0x03E7 *) wMsgTab[309].id   := 999;                        wMsgTab[309].msg := "WM_DDE_POKE";
              wMsgTab[309].proc := dde.Proc_WM_DDE_POKE;       wMsgTab[309].flg := ft.MSG_TYPE_DDE; 
 (* 0x03E8 *) wMsgTab[310].id   :=1000;                        wMsgTab[310].msg := "WM_DDE_EXECUTE";
              wMsgTab[310].proc := dde.Proc_WM_DDE_EXECUTE;    wMsgTab[310].flg := ft.MSG_TYPE_DDE; 

              (*--  NOTE: All Message Numbers below 0x0400 are RESERVED --*)
 (*--------------------------------------------------------------------------------------------*) 

END WinConst.
