(******************************************************************************
 * MODULE:        StatLine
 * DESCRIPTION:   This is a custom control for a status bar.
 * LANGUAGE:      Oberon-2
 * COMPILER:      Robinson Associates Oberon-2 V1.14
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 94/11/30  PDI     Version 1.0
 * 96/08/22  SK1     Stateline get system colors
 * 96/08/23  SK2     change text height
 * 96/08/24  SK3     modify height of status bar
 * 96/08/25  SK4     Setposition of statusbar 0 => up , 1 => down  
 * 96/08/25  SK5     modification of frame
 * 96/08/25  SK6     calculate height of status bar
 * 97/03/11  PDI     minor changes for windows callback functions
 * 97/03/16  PDI     changed background color for status bar
 *                   Scrollbar color instead of menu color
 ******************************************************************************)
MODULE StatLine;

IMPORT SYSTEM, W := Windows;

CONST ClassName = "CStatusLine";
      SECURITY = 12;

TYPE SB_TEXT = POINTER TO RECORD
       text: ARRAY 256 OF CHAR;
       nTextHeight: INTEGER ;             (* SK2 *)
       nSbHeight :  INTEGER ;             (* SK3 *)
       sbPosition : INTEGER ;             (* SK4 *)
       hFont:       W.HFONT;              (* font for StatusLine      *)
     END;
                                 
VAR hPenDkGray:  W.HPEN;
    hInstance:   W.HINSTANCE;          (* handle of this module    *)
    hFont:       W.HFONT;

    
PROCEDURE RGB(r,g,b: INTEGER): W.COLORREF;
BEGIN
  RETURN (b * 256 + g) * 256 + r
END RGB;


(******************************************************************************
 *
 * Custrom Control StatusLine
 *
 ******************************************************************************
 *
 * Description:
 * StatusLine is a window which displays status information. The status line 
 * is at the bottom or at the top  of the parent window placed.
 *
 * Functions:
 * Create(hWndParednt, hInstance)
 * SetText(hWnd, text)
 * SetFont(hWnd, nTextHeight)
 * SetPosition(hWnd,sbPosition)
 * GetHeight(hWnd):INTEGER
 *
 * Messages:
 * WM_SETTEXT(0, @text) .. sets the text in the status line
 * WM_SIZE(0, 0) ......... moves the status line to the bottom of the parent window.
 *
 *
 ******************************************************************************)

(******************************************************************************)
(* event handling procedure for status bar                                    *)
(******************************************************************************)

PROCEDURE OnCreate(hWnd: W.HWND; wParam: W.WPARAM; lParam: W.LPARAM): W.LRESULT;
VAR
  hdc: W.HDC;
  r:   LONGINT;
  s:   SB_TEXT;
BEGIN

  (* -- Instanzdaten anlegen -- *)
  NEW(s);
  COPY("", s.text);
  s.nTextHeight := 12 ;                      (*SK2*)
  s.nSbHeight := s.nTextHeight + SECURITY  ;   (*SK3*)
  s.sbPosition := 1 ;                        (*SK4*)
  r := W.SetWindowLong(hWnd, 0, SYSTEM.ADR(s^));

  (* -- set window attributes -- *)
  hdc := W.GetDC(hWnd);
  r := W.SetBkMode(hdc, W.TRANSPARENT);
  r := W.ReleaseDC(hWnd, hdc);
  r := W.SendMessage(hWnd, W.WM_SETFONT, SYSTEM.VAL(W.WPARAM, hFont), W.true);
  r := W.SendMessage(hWnd, W.WM_SETTEXT, 0, SYSTEM.ADR(""));

  RETURN 0;
END OnCreate;

PROCEDURE OnSetFont(hWnd: W.HWND; wParam: W.WPARAM; lParam: W.LPARAM): W.LRESULT;
VAR
  hdc: W.HDC;
  hFontOld: W.HFONT;
  r:   LONGINT;
  s:   SB_TEXT;
  tm:  W.TEXTMETRIC;
BEGIN
  (* -- Instanzdaten holen --*)
  s := SYSTEM.VAL(SB_TEXT, W.GetWindowLong(hWnd, 0));
  IF s = NIL THEN RETURN 0 END;
  (* -- set window attributes -- *)
  s.hFont := SYSTEM.VAL(W.HFONT, wParam);
  hdc := W.GetDC(hWnd);
  hFontOld := W.SelectObject(hdc, s.hFont);
  r := W.GetTextMetrics(hdc, SYSTEM.ADR(tm));
  s.nSbHeight := tm.tmHeight + SECURITY;
  r := W.SelectObject(hdc, SYSTEM.VAL(W.HFONT, hFontOld));
  r := W.ReleaseDC(hWnd, hdc);
  r := W.SendMessage(hWnd, W.WM_SIZE, 0, 0);
  RETURN 0;
END OnSetFont;

PROCEDURE OnPaint(hWnd: W.HWND): W.LRESULT;
VAR
  crf:      W.COLORREF; (*SK1*)
  hbr:      W.HBRUSH;
  hbrOld:   W.HBRUSH;   (*SK1*)
  hdc:      W.HDC;
  hFontOld: W.HFONT;
  hPen:     W.HPEN;
  ps:       W.PAINTSTRUCT;
  r:        LONGINT;
  rb :      W.BOOL;     (*SK1*)
  rect:     W.RECT;
  s:        SB_TEXT;
BEGIN
  hdc := W.BeginPaint(hWnd, SYSTEM.ADR(ps));
  (* -- draw a frame -- *)
  W.GetClientRect(hWnd, SYSTEM.ADR(rect));
  hPen := W.SelectObject(hdc, hPenDkGray);
  r := W.MoveTo(hdc, rect.left, rect.top);
  r := W.LineTo(hdc, rect.right, rect.top);
  r := W.MoveTo(hdc, rect.left, rect.bottom);               (*SK5*)
  r := W.LineTo(hdc, rect.right, rect.bottom);              (*SK5*)
  INC(rect.top, 1);                                        
  DEC(rect.bottom, 1);                                      (*SK5*)
  r := W.SelectObject(hdc, W.GetStockObject(W.WHITE_PEN));
  r := W.MoveTo(hdc, rect.left, rect.top);
  r := W.LineTo(hdc, rect.right, rect.top);
(*  r := W.MoveTo(hdc, rect.left, rect.bottom);             (* removed by PDI *)
    r := W.LineTo(hdc, rect.right, rect.bottom); *)
  INC(rect.top, 1);
  DEC(rect.bottom, 1);                                       (*SK5*)
  INC(rect.left, 4); INC(rect.top, 3); DEC(rect.right, 4); DEC(rect.bottom, 1); (* PDI *)
  r := W.SelectObject(hdc, hPenDkGray);
  r := W.MoveTo(hdc, rect.right, rect.bottom);               (*SK5*)
  r := W.LineTo(hdc, rect.left, rect.bottom);                (*Sk5*)
  r := W.LineTo(hdc, rect.left, rect.top);
  r := W.LineTo(hdc, rect.right, rect.top);
  r := W.SelectObject(hdc, W.GetStockObject(W.WHITE_PEN));
  r := W.LineTo(hdc, rect.right, rect.bottom);
  r := W.LineTo(hdc, rect.left, rect.bottom);
  r := W.SelectObject(hdc, hPen);
  INC(rect.left, 1); INC(rect.top, 1); DEC(rect.right, 1); DEC(rect.bottom, 1);
 
  (* System color from Menu bar *)
  crf := W.GetSysColor(W.COLOR_SCROLLBAR);     (*SK1*) (*PDI*)
  hbr := W.CreateSolidBrush(crf);              (*SK1*)
  hbrOld := W.SelectObject(hdc, hbr) ;         (*SK1*)
  r := W.FillRect(hdc, SYSTEM.ADR(rect), hbr); (*SK1*)
  
  (* -- display text -- *)
  s := SYSTEM.VAL(SB_TEXT, W.GetWindowLong(hWnd, 0));
  IF s # NIL THEN
    INC(rect.left, 5); INC(rect.top, 1); DEC(rect.right, 5); DEC(rect.bottom, 1);
    hFontOld := W.SelectObject(hdc, s.hFont);
    r := W.DrawText(hdc, SYSTEM.ADR(s.text[0]), W.lstrlen(SYSTEM.ADR(s.text[0])), SYSTEM.ADR(rect), W.DT_SINGLELINE + W.DT_LEFT + W.DT_VCENTER);
    r := W.SelectObject(hdc, SYSTEM.VAL(W.HFONT, hFontOld));
  END;
  W.EndPaint(hWnd, SYSTEM.ADR(ps));
  
  r := W.SelectObject(hdc,hbrOld);    (*SK1*)
  rb := W.DeleteObject(hbr);          (*SK1*)
                                            
  RETURN 0;
END OnPaint;

PROCEDURE OnSize(hWnd: W.HWND; wParam: W.WPARAM; lParam: W.LPARAM): W.LRESULT;
VAR
  hWndParent: W.HWND;
  rb:         W.BOOL;
  rect:       W.RECT;
  s:          SB_TEXT;
BEGIN
  (* -- Instanzdaten holen --*)
  s := SYSTEM.VAL(SB_TEXT, W.GetWindowLong(hWnd, 0));
  IF s = NIL THEN RETURN 0 END;

  hWndParent := W.GetParent(hWnd);
  W.GetClientRect(hWndParent, SYSTEM.ADR(rect));
  
  (*SK4*)
  IF s.sbPosition = 1 THEN  
    IF rect.bottom - rect.top > s.nSbHeight THEN
      rect.top := rect.bottom - s.nSbHeight;
    END;
    rb := W.MoveWindow(hWnd, rect.left, rect.top, rect.right - rect.left, s.nSbHeight, W.true);
  ELSE
    IF rect.bottom - rect.top > s.nSbHeight THEN
      rect.top := rect.top;
    END;
    rb := W.MoveWindow(hWnd, rect.left, rect.top, rect.right - rect.left, s.nSbHeight, W.true); 
  END;
  (*SK4*)
  W.InvalidateRect(hWnd, W.NULL, W.true);
  RETURN 0;
END OnSize;

PROCEDURE OnSetText(hWnd: W.HWND; wParam: W.WPARAM; lParam: W.LPARAM): W.LRESULT;
VAR
  len: LONGINT;
  r:   LONGINT;
  s:   SB_TEXT;
BEGIN
  s := SYSTEM.VAL(SB_TEXT, W.GetWindowLong(hWnd, 0));
  IF s = NIL THEN RETURN 0 END;
  len := W.lstrlen(lParam);
  SYSTEM.MOVE(lParam, SYSTEM.ADR(s.text[0]), len + 1);
  W.InvalidateRect(hWnd, W.NULL, W.true);
  RETURN 0;
END OnSetText;

PROCEDURE OnDestroy(hWnd: W.HWND): W.LRESULT;
VAR
  s: SB_TEXT;
BEGIN
  s := SYSTEM.VAL(SB_TEXT, W.GetWindowLong(hWnd, 0));
  IF s # NIL THEN DISPOSE(s) END;
  RETURN 0;
END OnDestroy;

(******************************************************************************
 * StatusLineProc is the window function for the status bar. It handles all
 * messages sent to a status bar.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hWnd           window handle
 * msg            message sent to the window
 * wParam         first parameter of the message
 * lParam         second parameter
 ******************************************************************************)
PROCEDURE [WINDOWS] StatusLineProc*(hWnd: W.HWND; msg: W.WORD; wParam: W.WORD; lParam: LONGINT): LONGINT;
BEGIN
  IF    msg = W.WM_CREATE  THEN RETURN OnCreate(hWnd, wParam, lParam);
  ELSIF msg = W.WM_PAINT   THEN RETURN OnPaint(hWnd);
  ELSIF msg = W.WM_SIZE    THEN RETURN OnSize(hWnd, wParam, lParam);
  ELSIF msg = W.WM_SETTEXT THEN RETURN OnSetText(hWnd, wParam, lParam);
  ELSIF msg = W.WM_SETFONT THEN RETURN OnSetFont(hWnd, wParam, lParam);
  ELSIF msg = W.WM_DESTROY THEN RETURN OnDestroy(hWnd);
  ELSE                          RETURN W.DefWindowProc(hWnd, msg, wParam, lParam)
  END;
END StatusLineProc;



(******************************************************************************
 *
 * FUNCTION:
 * LibMain is the initialization function of this dynamic link library. It is
 * automatically called by Windows when this DLL is loaded.
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle for this DLL
 * wDataSeg       data segment for this DLL
 * cbHeapSize     heap size 
 * lpszCmdLine    command line (pointer to a null terminated string)
 ******************************************************************************)
PROCEDURE [WINDOWS] LibMain* (hInstCurr:   W.HANDLE; 
                              wDataSeg:    INTEGER; 
                              cbHeapSize:  INTEGER; 
                              lpszCmdLine: LONGINT): INTEGER;
  VAR wc: W.WNDCLASS;

BEGIN

  (* -- save global data -- *)
  hInstance := hInstCurr;
  
  (* -- prepare window class structure -- *)
  wc.style         := W.CS_GLOBALCLASS + W.CS_CLASSDC;
  wc.lpfnWndProc   := StatusLineProc;
  wc.cbClsExtra    := 0;                     
  wc.cbWndExtra    := 4;                     
  wc.hInstance     := hInstCurr;
  wc.hIcon         := W.NULL;
  wc.hCursor       := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.COLOR_BTNFACE + 1;
  wc.lpszMenuName  := W.NULL;
  wc.lpszClassName := SYSTEM.ADR(ClassName);

  (* -- register StatusLine class -- *)
  IF W.RegisterClass(SYSTEM.ADR(wc)) = 0 THEN
    W.MessageBeep(0);
    HALT(0);
    RETURN 0;
  END;  

  (* -- create font for StatusLine -- *)
  hFont := W.CreateFont(12 * (-1), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, SYSTEM.ADR("MS Sans Serif"));
  
  (* -- create pen -- *)
  hPenDkGray := W.CreatePen(W.PS_SOLID, 1, RGB(128, 128, 128));

  RETURN 1;

END LibMain;


(******************************************************************************
 *
 * FUNCTION:
 * WEP is the exit function of this DLL which is automatically called by 
 * Windows when this DLL is unloaded.
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * nExitType      type of exit (e.g.: quit Windows, unload DLL, ...)
 ******************************************************************************)
PROCEDURE [WINDOWS] WEP* (nExitType: INTEGER): INTEGER;
BEGIN

  (* -- unregister window class -- *)
  IF W.UnregisterClass(SYSTEM.ADR(ClassName), hInstance) = 0 THEN
    HALT(0);
  END;
  
  (* -- delete font -- *)
  IF W.DeleteObject(hFont) = 0 THEN
    HALT(0);
  END;
  IF W.DeleteObject(hPenDkGray) = 0 THEN
    HALT(0);
  END;
  
  RETURN 1;

END WEP;


(******************************************************************************
 *
 * FUNCTION:
 * It creates a status bar as child window of the window hWndParent.
 *
 * PRECONDITIONS:
 * The parent window for the status bar must exist.
 *
 * POSTCONDITIONS:
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hWndParent     window handle of parent window
 * hIntance       instance handle of the module which wants to create a status bar.
 ******************************************************************************)
PROCEDURE [WINDOWS] Create*(hWndParent: W.HWND; 
                                      hInstance:  W.HINSTANCE): W.HWND;
  VAR hWndBar: W.HWND;
    
BEGIN

  (* -- create window -- *)
  hWndBar := W.CreateWindow(
             SYSTEM.ADR(ClassName), W.NULL, 
             W.WS_CHILD + W.WS_VISIBLE, 0, 0, 0, 0,
             hWndParent, W.NULL, 
             hInstance, W.NULL);
  RETURN hWndBar;
  
END Create;



(******************************************************************************
 * With SetText you can set which text should be displayed in the status bar.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hWnd           window handle of a status bar.
 * text           text
 ******************************************************************************)
PROCEDURE [WINDOWS] SetText*(hWnd: W.HWND; text: ARRAY OF CHAR);
  VAR r: LONGINT;
BEGIN
  r := W.SendMessage(hWnd, W.WM_SETTEXT, 0, SYSTEM.ADR(text));
END SetText;


(*SK2*)
(******************************************************************************
 * SetFont change only the height of the current text 
 ****************************************************************************** 
 * PARAMETER       DESCRIPTION
 * --------------- ------------------------------------------------------------
 * Height          new Height of the text
 ******************************************************************************)
  

PROCEDURE [WINDOWS] SetFont*(hWnd: W.HWND ; height : INTEGER);       (*SK2*)
VAR r , lParam : LONGINT ;
    wParam :W.WORD;
BEGIN
  (* -- create font for StatusLine -- *)
  hFont := W.CreateFont(height * (-1), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, SYSTEM.ADR("MS Sans Serif"));
   
  (* new Init for font and for status bar *)
  (*r := OnCreate(hWnd, wParam, lParam); (* by pdi *)
  r := OnSize(hWnd,wParam,lParam); *)
  r := W.SendMessage(hWnd, W.WM_SETFONT, SYSTEM.VAL(W.WPARAM, hFont), W.true);
  
  IF height = 12 THEN
    r := W.SendMessage(hWnd, W.WM_SETTEXT, 0, SYSTEM.ADR("Texthöhe 12"));
  ELSE
    r := W.SendMessage(hWnd, W.WM_SETTEXT, 0, SYSTEM.ADR("Texthöhe 20")); 
  END;
    
END SetFont;

(*SK4*)
(******************************************************************************
 * SetPositon change position of the status bar 0 => up , 1 => down 
 ****************************************************************************** 
 * PARAMETER       DESCRIPTION
 * --------------- ------------------------------------------------------------
 * sbPosition      new position of the status bar
 ******************************************************************************)
  

PROCEDURE [WINDOWS] SetPosition*(hWnd: W.HWND ; position : INTEGER);       (*SK4*)
VAR r: LONGINT;
    s: SB_TEXT;
BEGIN
  s := SYSTEM.VAL(SB_TEXT, W.GetWindowLong(hWnd, 0));
  IF s = NIL THEN RETURN END;
  s.sbPosition := position ;
  (* new Init for font and for status bar *)
  (*r := OnCreate(hWnd, wParam, lParam); (* by pdi *)
  r := OnSize(hWnd,wParam,lParam); *)
  r := W.SendMessage(hWnd, W.WM_SIZE, 0, 0);
  
  IF s.sbPosition = 0 THEN
    r := W.SendMessage(hWnd, W.WM_SETTEXT, 0, SYSTEM.ADR("Statusbar up"));
  ELSE
    r := W.SendMessage(hWnd, W.WM_SETTEXT, 0, SYSTEM.ADR("Statusbar down")); 
  END;
    
END SetPosition;

(*SK6*)
(******************************************************************************
 * GetHeight return the height of the status bar 
 ****************************************************************************** 
 * PARAMETER       DESCRIPTION
 * --------------- ------------------------------------------------------------
 * hWnd            window handle
 ******************************************************************************)
  
PROCEDURE [WINDOWS] GetHeight*(hWnd: W.HWND):INTEGER;       (*SK6*)
VAR s: SB_TEXT;
BEGIN
  s := SYSTEM.VAL(SB_TEXT, W.GetWindowLong(hWnd, 0));
  IF s = NIL THEN 
    RETURN 0;
  ELSE
  RETURN s.nSbHeight;
  END;
END GetHeight;
 

BEGIN
  (* Init *)
END StatLine.
