(******************************************************************************)
(* MODULE:      NclProc                                         ME - 29.06.96 *)
(* DESCRIPTION: Decoding procedures for nonclient messages                    *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 29.05.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE NclProc;

IMPORT W := Windows, Strings, Utils, SYSTEM, htConst;


CONST
  STR_LEN = 128;

(*==============< Decoding procedures for nonclient messages >================*)
(* This Application provides for nonclient message group:                     *)
(*                WM_NCACTIVATE                                               *)
(*                WM_NCCREATE                                                 *)
(*                WM_NCCALCSIZE                                               *)
(*                WM_NCDESTROY   (using default)                              *)
(*                WM_NCHITTEST                                                *)
(*                WM_NCLBUTTONDOWN                                            *)
(*                WM_NCLBUTTONUP                                              *)
(*                WM_NCLBUTTONDBLCLK                                          *)
(*                WM_NCMBUTTONDOWN                                            *)
(*                WM_NCMBUTTONUP                                              *)
(*                WM_NCMBUTTONDBLCLK                                          *)
(*                WM_NCMOUSEMOVE                                              *)
(*                WM_NCPAINT     (using default)                              *)
(*                WM_NCRBUTTONDOWN                                            *)
(*                WM_NCRBUTTONUP                                              *)
(*                WM_NCRBUTTONDBLCLK                                          *)
(*============================================================================*)


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCACTIVATE                             *)
(*                                                                            *)
(* COMMENTS: The WM_NCACTIVATE message is sent to a window when its nonclient *)
(*           area needs to be changed to indicate an active or inactive state.*)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fActive = wParam: the active/inactive flag                  *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCACTIVATE*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);

BEGIN
  Strings.Append(str," fActive:");
  IF (SYSTEM.VAL(W.BOOL,wParam) # W.false) THEN
    Strings.Append(str,"TRUE(=active)")
  ELSE
    Strings.Append(str,"FALSE(=inactive)")
  END
END Proc_WM_NCACTIVATE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCCREATE                               *)
(*                                                                            *)
(* COMMENTS: The WM_NCCREATE message is sent prior to the WM_CREATE message   *)
(*           when a window is first created.                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam                                                                     *)
(* lParam         lpcs = (CREATESTRUCT FAR* ) structure address               *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCCREATE*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," lpcs:"); numStr := ""; Strings.HexStr(lParam, numStr);
  Strings.Append(str,numStr);
END Proc_WM_NCCREATE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCCALCSIZE                             *)
(*                                                                            *)
(* COMMENTS: The WM_NCCALCSIZE message is sent when the size and position of  *)
(*           a window's client area needs to be calculated. By processing     *)
(*           this message, an application can control the contents of the     *)
(*           window's client area when the size or position of the            *)
(*           window changes.                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fCalcValidRects = (BOOL) wParam: valid-area flag            *)
(* lParam         lpncsp = (NCCALCSIZE_PARAMS FAR* ) lParam: address of data  *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCCALCSIZE*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," fCalcValidRects:");
  IF (SYSTEM.VAL(W.BOOL,wParam) # W.false) THEN
    Strings.Append(str,"TRUE")
  ELSE
    Strings.Append(str,"FALSE")
  END;
  
  Strings.Append(str," lpncsp:"); numStr := "";
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr)
END Proc_WM_NCCALCSIZE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCHITTEST                              *)
(*                                                                            *)
(* COMMENTS: The WM_NCHITTEST message is sent to the window that contains the *)
(*           cursor or to the window that used the SetCapture function to     *)
(*           capture the mouse input. It is sent every time the mouse         *)
(*           is moved.                                                        *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         not used                                                    *)
(* lParam         xPos=Value of the low-order word of lParam                  *)
(*                yPos=Value of the high-order word of lParam                 *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCHITTEST*(wParam : W.WPARAM; 
                             lParam : W.LPARAM;
                             VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," Cursor xPos:"); numStr := "";
  Strings.Str(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);
  Strings.Append(str," yPos:"); numStr := ""; 
  Strings.Str(Utils.HiWord(lParam),numStr); Strings.Append(str,numStr); 
END Proc_WM_NCHITTEST;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for a set of similar mouse messages           *)
(*                                                                            *)
(* COMMENTS:                                                                  *)
(*============================================================================*)
PROCEDURE Proc_NcMouseGeneric(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
TYPE 
  pointDesc = RECORD
                x : INTEGER;
                y : INTEGER;
              END;

VAR
  pt : pointDesc;
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," HitTestCode:");
  IF((wParam >= 0) & (wParam < LEN(htConst.htTab))) THEN
    IF (htConst.htTab[wParam] # "") THEN
      Strings.Append(str,htConst.htTab[wParam])
    ELSE
      Strings.Append(str, "unknown "); numStr := "";
      Strings.HexStr(wParam,numStr); Strings.Append(str,numStr) 
    END
  END;
  
  W.GetCursorPos(SYSTEM.ADR(pt));
  Strings.Append(str," Cursor xPos:"); numStr := "";
  Strings.Str(pt.x,numStr); Strings.Append(str,numStr);
  Strings.Append(str," yPos:"); numStr := "";
  Strings.Str(pt.y,numStr); Strings.Append(str,numStr);
END Proc_NcMouseGeneric;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCLBUTTONDOWN                          *)
(*                                                                            *)
(* COMMENTS: The WM_NCLBUTTONDOWN message is sent to a window when the user   *)
(*           presses the left mouse button while the cursor is within a       *)
(*           nonclient area of the window.                                    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wHitTestCode = wParam: hit-test code                        *)
(* lParam         xPos = LOWORD(lParam): horizontal cursor position           *)
(*                yPos = HIWORD(lParam): vertical cursor position             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCLBUTTONDOWN*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);

BEGIN
  Proc_NcMouseGeneric(wParam,lParam,str);
END Proc_WM_NCLBUTTONDOWN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCLBUTTONUP                            *)
(*                                                                            *)
(* COMMENTS: The WM_NCLBUTTONDOWN message is sent to a window when the user   *)
(*           releases the left mouse button while the cursor is within a      *)
(*           nonclient area of the window.                                    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wHitTestCode = wParam: hit-test code                        *)
(* lParam         xPos = LOWORD(lParam): horizontal cursor position           *)
(*                yPos = HIWORD(lParam): vertical cursor position             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCLBUTTONUP*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);

BEGIN
  Proc_NcMouseGeneric(wParam,lParam,str);
END Proc_WM_NCLBUTTONUP;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCLBUTTONDBLCLK                        *)
(*                                                                            *)
(* COMMENTS: The WM_NCLBUTTONDBLCLK message is sent when the user             *)
(*           double-clicks the left mouse button while the cursor is within a *)
(*           nonclient area of the window.                                    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wHitTestCode = wParam: hit-test code                        *)
(* lParam         xPos = LOWORD(lParam): horizontal cursor position           *)
(*                yPos = HIWORD(lParam): vertical cursor position             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCLBUTTONDBLCLK*(wParam : W.WPARAM; 
                                   lParam : W.LPARAM;
                                   VAR str : ARRAY OF CHAR);

BEGIN
  Proc_NcMouseGeneric(wParam,lParam,str);
END Proc_WM_NCLBUTTONDBLCLK;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCMBUTTONDOWN                          *)
(*                                                                            *)
(* COMMENTS: The WM_NCMBUTTONDOWN message is sent to a window when the user   *)
(*           presses the middle mouse button while the cursor is within a     *)
(*           nonclient area of the window.                                    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wHitTestCode = wParam: hit-test code                        *)
(* lParam         xPos = LOWORD(lParam): horizontal cursor position           *)
(*                yPos = HIWORD(lParam): vertical cursor position             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCMBUTTONDOWN*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);

BEGIN
  Proc_NcMouseGeneric(wParam,lParam,str);
END Proc_WM_NCMBUTTONDOWN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCMBUTTONUP                            *)
(*                                                                            *)
(* COMMENTS: The WM_NCMBUTTONDOWN message is sent to a window when the user   *)
(*           releases the middle mouse button while the cursor is within a    *)
(*           nonclient area of the window.                                    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wHitTestCode = wParam: hit-test code                        *)
(* lParam         xPos = LOWORD(lParam): horizontal cursor position           *)
(*                yPos = HIWORD(lParam): vertical cursor position             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCMBUTTONUP*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);

BEGIN
  Proc_NcMouseGeneric(wParam,lParam,str);
END Proc_WM_NCMBUTTONUP;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCMBUTTONDBLCLK                        *)
(*                                                                            *)
(* COMMENTS: The WM_NCMBUTTONDBLCLK message is sent when the user             *)
(*           double-clicks the middle mouse button while the cursor is within *)
(*           a nonclient area of the window.                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wHitTestCode = wParam: hit-test code                        *)
(* lParam         xPos = LOWORD(lParam): horizontal cursor position           *)
(*                yPos = HIWORD(lParam): vertical cursor position             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCMBUTTONDBLCLK*(wParam : W.WPARAM; 
                                   lParam : W.LPARAM;
                                   VAR str : ARRAY OF CHAR);

BEGIN
  Proc_NcMouseGeneric(wParam,lParam,str);
END Proc_WM_NCMBUTTONDBLCLK;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCMOUSEMOVE                            *)
(*                                                                            *)
(* COMMENTS: The WM_NCMOUSEMOVE message is sent to a window when the cursor   *)
(*           is moved within a nonclient area of the window.                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wHitTestCode = wParam: hit-test code                        *)
(* lParam         xPos = LOWORD(lParam): horizontal cursor position           *)
(*                yPos = HIWORD(lParam): vertical cursor position             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCMOUSEMOVE*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);

BEGIN
  Proc_NcMouseGeneric(wParam,lParam,str);
END Proc_WM_NCMOUSEMOVE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCRBUTTONDOWN                          *)
(*                                                                            *)
(* COMMENTS: The WM_NCRBUTTONDOWN message is sent to a window when the user   *)
(*           presses the right mouse button while the cursor is within a      *)
(*           nonclient area of the window.                                    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wHitTestCode = wParam: hit-test code                        *)
(* lParam         xPos = LOWORD(lParam): horizontal cursor position           *)
(*                yPos = HIWORD(lParam): vertical cursor position             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCRBUTTONDOWN*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);

BEGIN
  Proc_NcMouseGeneric(wParam,lParam,str);
END Proc_WM_NCRBUTTONDOWN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCRBUTTONUP                            *)
(*                                                                            *)
(* COMMENTS: The WM_NCRBUTTONDOWN message is sent to a window when the user   *)
(*           releases the right mouse button while the cursor is within a     *)
(*           nonclient area of the window.                                    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wHitTestCode = wParam: hit-test code                        *)
(* lParam         xPos = LOWORD(lParam): horizontal cursor position           *)
(*                yPos = HIWORD(lParam): vertical cursor position             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCRBUTTONUP*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);

BEGIN
  Proc_NcMouseGeneric(wParam,lParam,str);
END Proc_WM_NCRBUTTONUP;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_NCRBUTTONDBLCLK                        *)
(*                                                                            *)
(* COMMENTS: The WM_NCRBUTTONDBLCLK message is sent when the user             *)
(*           double-clicks the right mouse button while the cursor is within  *)
(*           a nonclient area of the window.                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wHitTestCode = wParam: hit-test code                        *)
(* lParam         xPos = LOWORD(lParam): horizontal cursor position           *)
(*                yPos = HIWORD(lParam): vertical cursor position             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_NCRBUTTONDBLCLK*(wParam : W.WPARAM; 
                                   lParam : W.LPARAM;
                                   VAR str : ARRAY OF CHAR);

BEGIN
  Proc_NcMouseGeneric(wParam,lParam,str);
END Proc_WM_NCRBUTTONDBLCLK;


BEGIN
END NclProc.
