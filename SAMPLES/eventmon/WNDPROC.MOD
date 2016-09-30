(******************************************************************************)
(* MODULE:      WndProc                                         ME - 29.06.96 *)
(* DESCRIPTION: Decoding procedures for window messages                       *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 29.05.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE WndProc;

IMPORT W := Windows, Strings, Utils, SYSTEM;

CONST
  STR_LEN = 128;

(*==============< Decoding procedures for window messages >===================*)
(* This Application provides for window message group:                        *)
(*                WM_ACTIVATE                                                 *)
(*                WM_ACTIVATEAPP                                              *)
(*                WM_CANCELMODE        (using default)                        *)
(*                WM_CHILDACTIVATE     (using default)                        *)
(*                WM_CLOSE             (using default)                        *)
(*                WM_CREATE                                                   *)
(*                WM_CTLCOLOR                                                 *)
(*                WM_DESTROY           (using default)                        *)
(*                WM_ENABLE                                                   *)
(*                WM_ENDSESSION                                               *)
(*                WM_ERASEBKGND                                               *)
(*                WM_GETDLGCODE        (using default)                        *)
(*                WM_GETMINMAXINFO                                            *)
(*                WM_GETTEXT                                                  *)
(*                WM_GETTEXTLENGTH     (using default)                        *)
(*                WM_ICONERASEBKGND                                           *)
(*                WM_KILLFOCUS                                                *)
(*                WM_MOVE                                                     *)
(*                WM_PAINT             (using default)                        *)
(*                WM_PAINTICON         (using default)                        *)
(*                WM_QUERYDRAGICON     (using default)                        *)
(*                WM_QUERYENDSESSION   (using default)                        *)
(*                WM_QUERYNEWPALETTE   (using default)                        *)
(*                WM_QUERYOPEN         (using default)                        *)
(*                WM_QUIT                                                     *)
(*                WM_SETFOCUS                                                 *)
(*                WM_SETFONT                                                  *)
(*                WM_SETREDRAW                                                *)
(*                WM_SETEXT                                                   *)
(*                WM_SHOWWINDOW                                               *)
(*                WM_SIZE                                                     *)
(*                WM_WINDOWPOSCHANGED                                         *)
(*                WM_WINDOWPOSCHANGING (same as WM_WINDOWPOSCHANGED)          *)
(*============================================================================*)

(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_ACTIVATE                               *)
(*                                                                            *)
(* COMMENTS: The WM_ACTIVATE message is sent when a window is being activated *)
(*           or deactivated. This message is sent first to the window         *)
(*           procedure of the main window being deactivated and then to the   *)
(*           window procedure of the main window being activated.             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fActive = activation flag                                   *)
(* lParam         fMinimized = (BOOL) HIWORD(lParam): minimized flag          *)
(*                hwnd = (HWND) LOWORD(lParam): window handle                 *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_ACTIVATE*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," fActive:");
  IF (wParam = W.WA_INACTIVE) THEN
    Strings.Append(str,"WA_INACTIVE")
  ELSIF (wParam = W.WA_ACTIVE) THEN
    Strings.Append(str,"WA_ACTIVE")
  ELSIF (wParam = W.WA_CLICKACTIVE) THEN
    Strings.Append(str,"WA_CLICKACTIVE")
  ELSE  
    Strings.Append(str,"unknown "); numStr := "";
    Strings.HexStr(wParam,str); Strings.Append(str,numStr); 
  END;
  
  Strings.Append(str," fMinimized:");
  IF (SYSTEM.VAL(W.BOOL,Utils.HiWord(lParam)) # W.false) THEN
    Strings.Append(str,"TRUE")
  ELSE
    Strings.Append(str,"FALSE")
  END;
  
  Strings.Append(str," hWnd:"); numStr := "";
  Strings.HexStr(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);
END Proc_WM_ACTIVATE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_ACTIVATEAPP                            *)
(*                                                                            *)
(* COMMENTS: The WM_ACTIVATEAPP message is sent when a window is about to be  *)
(*           activated and that window belongs to a different task than the   *)
(*           active window. The message is sent to all top-level windows of   *)
(*           the task being activated and to all top-level windows of the     *)
(*           task being deactivated.                                          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fActive = (BOOL) wParam: the activation/deactivation flag   *)
(* lParam         htask = (HTASK) LOWORD(lParam): task handle                 *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_ACTIVATEAPP*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," fActive:");
  IF (SYSTEM.VAL(W.BOOL,wParam) # W.false) THEN
    Strings.Append(str,"TRUE(=activated)")
  ELSE
    Strings.Append(str,"FALSE(=deactivated)")
  END;
  Strings.Append(str," task handle:"); numStr := "";
  Strings.HexStr(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);
END Proc_WM_ACTIVATEAPP;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_CREATE                                 *)
(*                                                                            *)
(* COMMENTS: The WM_CREATE message is sent when an application requests that  *)
(*           a window be created by calling the CreateWindowEx or CreateWindow*)
(*           function. The window procedure for the new window receives this  *)
(*           message after the window is created but before the window becomes*)
(*           visible. The message is sent to the window before the            *)
(*           CreateWindowEx or CreateWindow function returns.                 *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam                                                                     *)
(* lParam         lpcs = (CREATESTRUCT FAR* ) structure address               *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_CREATE*(wParam : W.WPARAM; 
                          lParam : W.LPARAM;
                          VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," lpcs:"); numStr := ""; 
  Strings.HexStr(lParam, numStr); Strings.Append(str,numStr);
END Proc_WM_CREATE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_CTLCOLOR                               *)
(*                                                                            *)
(* COMMENTS: The WM_CTLCOLOR message is sent to the parent of a               *)
(*           system-defined control class or a message box when the control   *)
(*           or message box is about to be drawn.                             *)
(*           The following controls send this message:                        *)
(*                                                                            *)
(*           Combo boxes                                                      *)
(*           Edit controls                                                    *)
(*           List boxes                                                       *)
(*           Buttons                                                          *)
(*           Static controls                                                  *)
(*           Scroll bars                                                      *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hdcChild = (HDC) wParam: child-window display context       *)
(* lParam         hwndChild = (HWND) LOWORD(lParam): handle of child window   *)
(*                nCtlType = (int) HIWORD(lParam): type of control            *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_CTLCOLOR*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," hdcChild:"); numStr := "";
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr);

  Strings.Append(str," hWndChild:"); numStr := "";
  Strings.HexStr(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);

  Strings.Append(str," Control Type:");
  IF (Utils.HiWord(lParam) = W.CTLCOLOR_BTN) THEN
    Strings.Append(str,"Button")
  ELSIF (Utils.HiWord(lParam) = W.CTLCOLOR_DLG) THEN
    Strings.Append(str,"Dialog box")
  ELSIF (Utils.HiWord(lParam) = W.CTLCOLOR_EDIT) THEN
    Strings.Append(str,"Edit control")
  ELSIF (Utils.HiWord(lParam) = W.CTLCOLOR_LISTBOX) THEN
    Strings.Append(str,"List box")
  ELSIF (Utils.HiWord(lParam) = W.CTLCOLOR_MSGBOX) THEN
    Strings.Append(str,"Message box")
  ELSIF (Utils.HiWord(lParam) = W.CTLCOLOR_SCROLLBAR) THEN
    Strings.Append(str,"Scroll bar")
  ELSIF (Utils.HiWord(lParam) = W.CTLCOLOR_STATIC) THEN
    Strings.Append(str,"Static control")
  ELSE  
    Strings.Append(str,"unknown "); numStr := "";
    Strings.HexStr(Utils.HiWord(lParam),str); Strings.Append(str,numStr) 
  END 
END Proc_WM_CTLCOLOR;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_ENABLE                                 *)
(*                                                                            *)
(* COMMENTS: The WM_ENABLE message is sent when an application changes the    *)
(*           enabled state of a window. It is sent to the window whose        *)
(*           enabled state is changing. This message is sent before the       *)
(*           EnableWindow function returns but after the enabled state        *)
(*           (WS_DISABLE style bit) of the window has changed.                *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fEnabled = (BOOL) wParam: the enabled/disabled flag         *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_ENABLE*(wParam : W.WPARAM; 
                          lParam : W.LPARAM;
                          VAR str : ARRAY OF CHAR);

BEGIN
  Strings.Append(str," fEnabled:"); 
  IF (SYSTEM.VAL(W.BOOL,wParam) = W.true) THEN
    Strings.Append(str,"TRUE(=enabled)")
  ELSE
    Strings.Append(str,"FALSE(=deactivated)")
  END
END Proc_WM_ENABLE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_ENDSESSION                             *)
(*                                                                            *)
(* COMMENTS: The WM_ENDSESSION message is sent to an application that has     *)
(*           returned a nonzero value in response to a WM_QUERYENDSESSION     *)
(*           message. The WM_ENDSESSION message informs the application       *)
(*           whether the session is actually ending.                          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fEndSession = (BOOL) wParam: end-session flag               *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_ENDSESSION*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);

BEGIN
  Strings.Append(str," fEndSession:"); 
  IF (SYSTEM.VAL(W.BOOL,wParam) = W.true) THEN
    Strings.Append(str,"TRUE(=session being ended)")
  ELSE
    Strings.Append(str,"FALSE")
  END
END Proc_WM_ENDSESSION;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_ERASEBKGND                             *)
(*                                                                            *)
(* COMMENTS: The WM_ERASEBKGND message is sent when the window background     *)
(*           needs to be erased (for example, when a window is resized).      *)
(*           It is sent to prepare an invalidated region for painting.        *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hdc = (HDC) wParam: Identifies the device context.          *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_ERASEBKGND*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," hdc:"); numStr := "";
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr);
END Proc_WM_ERASEBKGND;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_GETMINMAXINFO                          *)
(*                                                                            *)
(* COMMENTS: The WM_GETMINMAXINFO message is sent to a window whenever        *)
(*           Windows needs the maximized position or dimensions of the window *)
(*           or needs the maximum or minimum tracking size of the window.     *)
(*           The maximized size of a window is the size of the window when    *)
(*           its borders are fully extended. The maximum tracking size of a   *)
(*           window is the largest window size that can be achieved by using  *)
(*           the borders to size the window. The minimum tracking size of a   *)
(*           window is the smallest window size that can be achieved by using *)
(*           the borders to size the window.                                  *)
(*           Windows fills in a MINMAXINFO data structure, specifying default *)
(*           values for the various positions and dimensions. The application *)
(*           may change these values if it processes this message.            *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam                                                                     *)
(* lParam         lpmmi = (MINMAXINFO FAR* ) lParam: address of structure     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_GETMINMAXINFO*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," lpmmi:"); numStr := ""; 
  Strings.HexStr(lParam, numStr); Strings.Append(str,numStr);
END Proc_WM_GETMINMAXINFO;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_GETTEXT                                *)
(*                                                                            *)
(* COMMENTS: An application sends a WM_GETTEXT message to copy the text that  *)
(*           corresponds to a window into a buffer provided by the caller.    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) cchTextMax: number of bytes to copy       *)
(* lParam         lParam = (LPARAM) lpszText: address of buffer for text      *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_GETTEXT*(wParam : W.WPARAM; 
                           lParam : W.LPARAM;
                           VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN 
  Strings.Append(str," cchTextMax:"); numStr := ""; Strings.Str(wParam, numStr);
  Strings.Append(str,numStr);
  Strings.Append(str," lpszText:");  numStr := ""; Strings.HexStr(wParam, numStr);
  Strings.Append(str,numStr);
END Proc_WM_GETTEXT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_ICONERASEBKGND                         *)
(*                                                                            *)
(* COMMENTS: The WM_ICONERASEBKGND message is sent to a minimized (iconic)    *)
(*           window when the background of the icon must be filled before     *)
(*           painting the icon. A window receives this message only if a      *)
(*           class icon is defined for the window; otherwise, WM_ERASEBKGND   *)
(*           is sent.                                                         *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hdc = (HDC) wParam: device-context handle of the icon       *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_ICONERASEBKGND*(wParam : W.WPARAM; 
                                  lParam : W.LPARAM;
                                  VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," hdcIcon:"); numStr := "";
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr);
END Proc_WM_ICONERASEBKGND;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_KILLFOCUS                              *)
(*                                                                            *)
(* COMMENTS: The WM_KILLFOCUS message is sent immediately before a window     *)
(*           loses the input focus.                                           *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam                                                                     *)
(* lParam         hwndGetFocus = (HWND) lParam: handle of wnd receiving focus *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_KILLFOCUS*(wParam : W.WPARAM; 
                             lParam : W.LPARAM;
                             VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," hWndGetFocus:"); numStr := "";
  Strings.HexStr(SYSTEM.VAL(W.HWND,lParam),numStr); Strings.Append(str,numStr)
END Proc_WM_KILLFOCUS;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_MOVE                                   *)
(*                                                                            *)
(* COMMENTS: The WM_MOVE message is sent after a window has been moved.       *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam                                                                     *)
(* lParam         xPos = (int) LOWORD(lParam): horizontal position            *)
(*                yPos = (int) HIWORD(lParam): vertical position              *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_MOVE*(wParam : W.WPARAM; 
                        lParam : W.LPARAM;
                        VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str, " xPos:"); numStr := "";
  Strings.Str(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
  Strings.Append(str, " yPos:");  numStr := "";
  Strings.Str(Utils.HiWord(lParam), numStr); Strings.Append(str, numStr);
END Proc_WM_MOVE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_QUIT                                   *)
(*                                                                            *)
(* COMMENTS: The WM_QUIT message indicates a request to terminate an          *)
(*           application and is generated when the application calls the      *)
(*           PostQuitMessage function.                                        *)
(*           It causes the GetMessage function to return zero.                *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wExit = wParam: exit code                                   *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_QUIT*(wParam : W.WPARAM; 
                        lParam : W.LPARAM;
                        VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," wExitCode:"); numStr := ""; 
  Strings.Str(wParam, numStr); Strings.Append(str,numStr);
END Proc_WM_QUIT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SETFOCUS                               *)
(*                                                                            *)
(* COMMENTS: The WM_SETFOCUS message is sent after a window gains the         *)
(*           input focus.                                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hwnd = (HWND) wParam: handle of window losing focus         *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SETFOCUS*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," hWndLosingFocus:"); numStr := "";
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr)
END Proc_WM_SETFOCUS;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SETFONT                                *)
(*                                                                            *)
(* COMMENTS: An application sends the  WM_SETFONT message to specify the font *)
(*           that a control is to use when drawing text.                      *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) hfont: handle of the font                 *)
(* lParam         lParam = (LPARAM) MAKELONG((WORD) fRedraw, 0): redraw flag  *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SETFONT*(wParam : W.WPARAM; 
                           lParam : W.LPARAM;
                           VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN 
  Strings.Append(str," hFont:"); numStr := ""; 
  Strings.HexStr(wParam, numStr); Strings.Append(str,numStr);
  Strings.Append(str," fRedraw:");  numStr := ""; 
  Strings.Str(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
END Proc_WM_SETFONT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SETREDRAW                              *)
(*                                                                            *)
(* COMMENTS: An application sends a WM_SETREDRAW message to a window to allow *)
(*           changes in that window to be redrawn or to prevent changes in    *)
(*           that window from being redrawn.                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) fRedraw: state of redraw flag             *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SETREDRAW*(wParam : W.WPARAM; 
                             lParam : W.LPARAM;
                             VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;
  
BEGIN 
  Strings.Append(str," fRedraw:");  numStr := ""; 
  Strings.Str(wParam, numStr); Strings.Append(str,numStr);
END Proc_WM_SETREDRAW;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SETTEXT                                *)
(*                                                                            *)
(* COMMENTS: An application sends a WM_SETTEXT message to set the text        *)
(*           of a window.                                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = 0: not used, must be zero                          *)
(* lParam         lParam = (LPARAM) (LPCSTR) pszText: address of window-text  *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SETTEXT*(wParam : W.WPARAM; 
                           lParam : W.LPARAM;
                           VAR str : ARRAY OF CHAR);
VAR 
  numStr, s : ARRAY STR_LEN OF CHAR;
  r : LONGINT;
  
BEGIN 
  Strings.Append(str," pszText:");  numStr := ""; 
  Strings.HexStr(lParam, numStr); Strings.Append(str,numStr); s :="";
  r := W.lstrcpy(SYSTEM.ADR(s),lParam);
  IF r # W.NULL THEN
    Strings.Append(str," (");
    Strings.Append(str,s);
    Strings.Append(str,")");
  END
END Proc_WM_SETTEXT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SHOWWINDOW                             *)
(*                                                                            *)
(* COMMENTS: The WM_SHOWWINDOW message is sent to a window when it is about   *)
(*           to be hidden or shown. A window is hidden or shown when the      *)
(*           ShowWindow function is called; when an overlapped window is      *)
(*           maximized or restored; or when an overlapped or pop-up window is *)
(*           minimized or displayed on the screen. When an overlapped window  *)
(*           is minimized, all pop-up windows associated with that window are *)
(*           hidden.                                                          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fShow = (BOOL) wParam: show/hide flag                       *)
(* lParam         fnStatus = LOWORD(lParam): status flag                      *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SHOWWINDOW*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," fShow:");
  IF (SYSTEM.VAL(W.BOOL,wParam) = W.true) THEN
    Strings.Append(str,"TRUE(=being shown)")
  ELSE
    Strings.Append(str,"FALSE(=being hidden)")
  END;
  
  Strings.Append(str," fnStatus:");
  IF (Utils.LoWord(lParam) = W.SW_PARENTCLOSING) THEN
    Strings.Append(str,"SW_PARENTCLOSING")
  ELSIF (Utils.LoWord(lParam) = W.SW_PARENTOPENING) THEN
    Strings.Append(str,"SW_PARENTOPENING")
  ELSE
    numStr := "";  
    Strings.HexStr(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr); 
  END
END Proc_WM_SHOWWINDOW;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SIZE                                   *)
(*                                                                            *)
(* COMMENTS: The WM_SIZE message is sent to a window after its size           *)
(*           has changed.                                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwSizeType = wParam: sizing-type flag                       *)
(* lParam         nWidth = LOWORD(lParam): width of client area               *)
(*                nHeight = HIWORD(lParam): height of client area             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SIZE*(wParam : W.WPARAM; 
                        lParam : W.LPARAM;
                        VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str," fwSizeType:");
  IF (wParam = W.SIZE_MAXIMIZED) THEN
    Strings.Append(str,"SIZE_MAXIMIZED")
  ELSIF (wParam = W.SIZE_MINIMIZED) THEN
    Strings.Append(str,"SIZE_MINIMIZED")
  ELSIF (wParam = W.SIZE_RESTORED) THEN
    Strings.Append(str,"SIZE_RESTORED")
  ELSIF (wParam = W.SIZE_MAXHIDE) THEN
    Strings.Append(str,"SIZE_MAXHIDE")
  ELSIF (wParam = W.SIZE_MAXSHOW) THEN
    Strings.Append(str,"SIZE_MAXSHOW")
  ELSE  
    Strings.Append(str," unknown "); numStr := "";  
    Strings.HexStr(wParam,numStr); Strings.Append(str,numStr)
  END;
 
  Strings.Append(str, " nWidth:"); numStr := "";
  Strings.Str(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
  Strings.Append(str, " nHeight:");  numStr := "";
  Strings.Str(Utils.HiWord(lParam), numStr); Strings.Append(str, numStr)
END Proc_WM_SIZE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_WINDOWPOSCHANGED                       *)
(*                                                                            *)
(* COMMENTS: The WM_WINDOWPOSCHANGED message is sent to a window whose size,  *)
(*           position, or z-order has changed as a result of a call to        *)
(*           SetWindowPos or another window-management function.              *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam                                                                     *)
(* lParam         pwp = (const WINDOWPOS FAR* ) lParam: structure address     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_WINDOWPOSCHANGED*(wParam : W.WPARAM; 
                                    lParam : W.LPARAM;
                                    VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," pwp:"); numStr := ""; 
  Strings.HexStr(lParam, numStr); Strings.Append(str,numStr);
END Proc_WM_WINDOWPOSCHANGED;


BEGIN
END WndProc.
