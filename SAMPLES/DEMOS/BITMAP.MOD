(******************************************************************************
 * MODULE:        Bitmap
 * DESCRIPTION:   Shows the use of memory device contexts and bitmaps
 * LANGUAGE:      Oberon-2
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 96/04/26  PDI     Version 1
 * 97/03/11  PDI     minor changes for callback functions
 ******************************************************************************)
MODULE Bitmap;

  IMPORT W := Windows, SYSTEM;

  CONST 
    ClassName  = "CBitmapTest";
    WindowName = "Bitmap Demo";
    WINDOW_HEIGHT = 640;
    WINDOW_WIDTH  = 480;

  VAR
    hdcmem:  W.HDC;      (* memory device context for Bitmap    *)
    hbmp:    W.HBITMAP;  (* bitmap created by this program      *)
    hbmpOld: W.HBITMAP;  (* bitmap of the memory device context *)
    

(******************************************************************************
 * DisplayError opens a message box and displays an error message in it.
 * It waits until the user has clicked on the Ok-button.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * msg            error message which should be displayed in the message box
 ******************************************************************************)
PROCEDURE DisplayError(msg: ARRAY OF CHAR);
  VAR r: INTEGER;
BEGIN
  r := W.MessageBox(W.NULL, SYSTEM.ADR(msg), SYSTEM.ADR("ERROR"), W.MB_OK);
END DisplayError;


(******************************************************************************
 *
 * FUNCTION:
 * WndProc is the so called "callback function" for the window displayed by
 * this application. WndProc is called by Windows every time Windows sends
 * a message to the window. 
 * WndProc creates a bitmap in WM_CREATE which has exactly the same size as 
 * the window and displays the bitmap in the window in WM_PAINT.
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hWnd           window handle
 * message        message for the window
 * wParam         first parameter for the message
 * lParam         second parameter for the message
 ******************************************************************************)
PROCEDURE [WINDOWS] WndProc*(hWnd:    W.HWND; 
                             message: W.WORD; 
                             wParam:  W.WPARAM; 
                             lParam:  W.LPARAM): LONGINT;

  VAR
    cr:  W.RECT;
    hdc: W.HDC;
    ps:  W.PAINTSTRUCT;
    r:   INTEGER;
    
BEGIN

 IF message = W.WM_CREATE THEN
    W.GetClientRect(hWnd, SYSTEM.ADR(cr));
    hdc := W.GetDC(hWnd);
    hdcmem  := W.CreateCompatibleDC(hdc);
    hbmp    := W.CreateCompatibleBitmap(hdc, cr.right, cr.bottom);
    hbmpOld := W.SelectObject(hdcmem, hbmp);
    r := W.FillRect(hdcmem, SYSTEM.ADR(cr), W.GetStockObject(W.GRAY_BRUSH));
    r := W.LineTo(hdcmem, cr.right, cr.bottom);
    r := W.ReleaseDC(hWnd, hdc);
    RETURN 0;

  ELSIF message = W.WM_DESTROY THEN
    r := W.SelectObject(hdcmem, hbmpOld);
    r := W.DeleteObject(hbmp);
    r := W.DeleteDC(hdcmem);
    W.PostQuitMessage(0);
    RETURN 0;

  ELSIF message = W.WM_PAINT THEN
    W.GetClientRect(hWnd, SYSTEM.ADR(cr));
    hdc := W.BeginPaint(hWnd, SYSTEM.ADR(ps));
    r := W.BitBlt(hdc, 0, 0, cr.right, cr.bottom, hdcmem, 0, 0, W.SRCCOPY);
    W.EndPaint(hWnd, SYSTEM.ADR(ps));
    RETURN 0;
    
  ELSIF message = W.WM_ERASEBKGND THEN
    RETURN 0;

  ELSE
    RETURN W.DefWindowProc(hWnd, message, wParam, lParam)

  END;
  RETURN 0;

END WndProc;



(******************************************************************************
 *
 * FUNCTION:
 * InitApplication registers all window classes.
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle of the current instance
 ******************************************************************************)
PROCEDURE InitApplication(hInstCurr: W.HINSTANCE): BOOLEAN;
  VAR wc: W.WNDCLASS;
BEGIN

  (* -- register application specific classes -- *)
  wc.style         := W.NULL;
  wc.lpfnWndProc   := WndProc;
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 0;
  wc.hInstance     := hInstCurr;
  wc.hIcon         := W.NULL;
  wc.hCursor       := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.GetStockObject(W.WHITE_BRUSH);
  wc.lpszMenuName  := W.NULL;
  wc.lpszClassName := SYSTEM.ADR(ClassName);
  RETURN W.RegisterClass(SYSTEM.ADR(wc)) # 0;
  
END InitApplication;



(******************************************************************************
 *
 * FUNCTION:
 * InitInstance performs the initialisation for the current instance of this
 * program. It creates the main window.
 *
 * PRECONDITIONS:
 * The window class used by this program should be registered. (InitApplication)
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle of the current instance
 * nCmdShow       ??
 ******************************************************************************)
PROCEDURE InitInstance(hInstCurr: W.HINSTANCE; nCmdShow: INTEGER): BOOLEAN;

  VAR
    hWnd:  W.HWND;
    r:     LONGINT;

BEGIN

  (* -- create main window -- *)
  hWnd := W.CreateWindow(
          SYSTEM.ADR(ClassName), SYSTEM.ADR(WindowName), 
          W.WS_DLGFRAME + W.WS_SYSMENU + W.WS_MINIMIZEBOX,
          W.CW_USEDEFAULT, W.CW_USEDEFAULT, 
          WINDOW_HEIGHT, WINDOW_WIDTH, 
          W.NULL, W.NULL, 
          hInstCurr, W.NULL);
  IF hWnd = 0 THEN RETURN FALSE END;
  r := W.ShowWindow(hWnd, nCmdShow);
  RETURN TRUE;

END InitInstance;



(******************************************************************************
 *
 * FUNCTION:
 * WinMain is the "main program". It is automartically called by Windows when
 * the user starts this application. It displays a simple window with the 
 * standard features of windows like moving, sizing and system menu.
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle for the current instance of this application
 * hInstPrev      instance handle for the previously loaded instance
 * lpCmdLine      command line (far pointer to a null terminated string)
 * nCmdShow       This parameter says how the main window should be displayed.
 ******************************************************************************)
PROCEDURE [WINDOWS] WinMain*(hInstCurr: W.HINSTANCE; 
                             hInstPrev: W.HINSTANCE;
                             lpCmdLine: W.LPSTR;
                             nCmdShow:  INTEGER):          INTEGER;
  VAR
    msg: W.MSG;
    r:   LONGINT;
    
BEGIN

  (* -- initialize first instance -- *)
  IF (hInstPrev = W.NULL) & ~InitApplication(hInstCurr) THEN
    DisplayError("Global Initialization didn't work!");
    RETURN W.false;
  END;

  (* -- initialize current instance -- *)
  IF ~InitInstance(hInstCurr, nCmdShow) THEN
    DisplayError("Local Initialization didn't work!");
    RETURN W.false;
  END; 
  
  (* -- standard message loop -- *)
  WHILE W.GetMessage(SYSTEM.ADR(msg), W.NULL, W.NULL, W.NULL) # 0 DO
    r := W.TranslateMessage(SYSTEM.ADR(msg)); 
    r := W.DispatchMessage(SYSTEM.ADR(msg));
  END;
  
  RETURN msg.wParam
  
END WinMain;


END Bitmap.
