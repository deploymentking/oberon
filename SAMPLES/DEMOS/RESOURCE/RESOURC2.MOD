(******************************************************************************
 * MODULE:        Resourc2
 * DESCRIPTION:   This program shows the use of some windows Resoures.
 * LANGUAGE:      Oberon-2
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 94/11/22  PDI     Version 1.0
 * 97/03/11  PDI     Minor changes for windows callback functions
 ******************************************************************************)
MODULE Resourc2;


  IMPORT Error, W := Windows, SYSTEM;


  CONST 
    ClassName   = "CResourceTest";
    WindowTitle = "Resource Demo 2 (Bitmap, Menu, ...)";

    IDM_FILE_NEW    = 20001;
    IDM_FILE_OPEN   = 20002;
    IDM_FILE_SAVE   = 20003;
    IDM_FILE_SAVEAS = 20004;
    IDM_FILE_EXIT   = 20005;
    
    IDM_RESOURCES_DIALOG = 20101;
    IDM_RESOURCES_BITMAP = 20102;
    IDM_RESOURCES_PRINT  = 20103;
    
    IDM_HELP_ABOUT = 20201;
    
    IDA_MAINMENU = 101;


  VAR
    hInstance: W.HINSTANCE;
    hBmpFIM:   W.HBITMAP;
    row:       BOOLEAN;

    
(******************************************************************************
 *
 * FUNCTION:
 * About is the callback function for my About Dialogbox. It handles messages
 * sent to my dialog box. 
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hDlg           window handle
 * message        message for the window
 * wParam         first parameter for the message
 * lParam         second parameter for the message
 ******************************************************************************)
PROCEDURE [WINDOWS] About*(hDlg:    W.HWND;
                           message: W.WORD;
                           wParam:  W.WORD;
                           lParam:  LONGINT): W.BOOL;
BEGIN
  IF message = W.WM_INITDIALOG THEN
    RETURN W.true
  ELSIF message = W.WM_COMMAND THEN
    IF (wParam = W.IDOK) OR (wParam = W.IDCANCEL) THEN
      W.EndDialog(hDlg, W.true)
    END;
    RETURN W.true
  END;
  RETURN W.false
END About;



(******************************************************************************
 *
 * FUNCTION:
 * DisplayBitmap displays the bitmap of the handle hBmpFIM in the window
 * hWnd. Depending on the status of the global variable row the function 
 * displays the once in the middle of the window or several times.
 *
 * PRECONDITIONS:
 * The handle hBmpFIM should point to a valid bitmap. The global variable
 * should be set to TRUE or FALSE.
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hWnd           window handle
 * hdc            device context of the window determined by hWnd
 ******************************************************************************)
PROCEDURE DisplayBitmap(hWnd: W.HWND; hdc: W.HDC);

  VAR
    bitmap:     W.BITMAP;
    hBitmapOld: W.HBITMAP;
    hdcMem:     W.HDC;
    r:          INTEGER;
    window:     W.RECT;
    x, y:       INTEGER;

BEGIN
  IF row THEN
    hdcMem := W.CreateCompatibleDC(hdc);
    IF hdcMem # 0 THEN
      hBitmapOld := W.SelectObject(hdcMem, hBmpFIM);
      IF hBitmapOld # 0 THEN
        W.GetClientRect(hWnd, SYSTEM.ADR(window));
        r := W.GetObject(hBmpFIM, SIZE(W.BITMAP), SYSTEM.ADR(bitmap));
        x := 0;
        WHILE (x < window.right) DO
          y := 0;
          WHILE (y < window.bottom) DO
            r := W.BitBlt(hdc, x, y, bitmap.bmWidth, bitmap.bmHeight, hdcMem, 0, 0, W.SRCCOPY);
            INC(y, bitmap.bmHeight);
          END;
          INC(x, bitmap.bmWidth);
        END;
        r := W.SelectObject(hdcMem, hBitmapOld);
      END;
      r := W.DeleteDC(hdcMem);
    END;
  ELSE
    hdcMem := W.CreateCompatibleDC(hdc);
    IF hdcMem # 0 THEN
      hBitmapOld := W.SelectObject(hdcMem, hBmpFIM);
      IF hBitmapOld # 0 THEN
        W.GetClientRect(hWnd, SYSTEM.ADR(window));
        r := W.GetObject(hBmpFIM, SIZE(W.BITMAP), SYSTEM.ADR(bitmap));
        x := (window.right - bitmap.bmWidth) DIV 2;
        y := (window.bottom - bitmap.bmHeight) DIV 2;
        r := W.BitBlt(hdc, x, y, bitmap.bmWidth, bitmap.bmHeight, hdcMem, 0, 0, W.SRCCOPY);
        r := W.SelectObject(hdcMem, hBitmapOld);
      END;
      r := W.DeleteDC(hdcMem);
    END;
  END;
END DisplayBitmap;



PROCEDURE SetMenuState(hWnd: W.HWND);

  VAR 
    hMenu: W.HMENU;
    r:     LONGINT;

BEGIN
  hMenu := W.GetMenu(hWnd);
  hMenu := W.GetSubMenu(hMenu, 1);
  IF row THEN
    r := W.CheckMenuItem(hMenu, IDM_RESOURCES_BITMAP, W.MF_CHECKED);
  ELSE
    r := W.CheckMenuItem(hMenu, IDM_RESOURCES_BITMAP, W.MF_UNCHECKED);
  END;
END SetMenuState;



(******************************************************************************
 *
 * FUNCTION:
 * WndProc is the so called "callback function" for the window displayed by
 * this application. WndProc is called by Windows every time Windows wants 
 * to send a message to the window. 
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
                             wParam:  W.WORD; 
                             lParam:  LONGINT): LONGINT;
  VAR
    hdc:        W.HDC;
    ps:         W.PAINTSTRUCT;
    r:          INTEGER;
    
BEGIN

  IF message = W.WM_CREATE THEN
    SetMenuState(hWnd);
    RETURN 0;

  ELSIF message = W.WM_DESTROY THEN
    W.PostQuitMessage(0);
    RETURN 0;

  ELSIF message = W.WM_PAINT THEN
    hdc := W.BeginPaint(hWnd, SYSTEM.ADR(ps));
    DisplayBitmap(hWnd, hdc);
    W.EndPaint(hWnd, SYSTEM.ADR(ps));
    RETURN 0;

  ELSIF message = W.WM_SIZE THEN
    IF ~row THEN
      W.InvalidateRect(hWnd, W.NULL, W.true);
    END;

  ELSIF message = W.WM_COMMAND THEN
    IF wParam = IDM_FILE_EXIT THEN
      r := W.DestroyWindow(hWnd);
    ELSIF (wParam = IDM_RESOURCES_DIALOG) OR (wParam = IDM_HELP_ABOUT) THEN
      r := W.DialogBox(hInstance, SYSTEM.ADR("About"), hWnd,  About);
    ELSIF wParam = IDM_RESOURCES_BITMAP THEN
      row := ~row;
      W.InvalidateRect(hWnd, W.NULL, W.true);
      SetMenuState(hWnd);
    ELSE
      RETURN W.DefWindowProc(hWnd, message, wParam, lParam)
    END;

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
  wc.hIcon         := W.LoadIcon(hInstCurr, SYSTEM.ADR("FIM_ICON"));
  wc.hCursor       := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.GetStockObject(W.WHITE_BRUSH);
  wc.lpszMenuName  := SYSTEM.ADR("Main");
  wc.lpszClassName := SYSTEM.ADR(ClassName);
  IF W.RegisterClass(SYSTEM.ADR(wc)) = 0 THEN
    Error.DspMsg("Couldn't register window class!");
    RETURN FALSE
  END;
  RETURN TRUE
    
END InitApplication;



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
                             nCmdShow:  INTEGER): INTEGER;
  VAR
    ha:   W.HACCEL;
    hWnd: W.HWND;
    msg:  W.MSG;
    r:    LONGINT;
    
BEGIN

  hInstance := hInstCurr;
  row       := FALSE;

  (* -- initialize first instance -- *)
  IF (hInstPrev = W.NULL) & ~InitApplication(hInstCurr) THEN
    RETURN W.false;
  END;

  (* -- initialize the current instance -- *)
  
  (* -- load bitmap -- *)
  hBmpFIM := W.LoadBitmap(hInstCurr, SYSTEM.ADR("FIM_BITMAP"));
  IF hBmpFIM = W.NULL THEN
    Error.DspMsg("Could not load FIM bitmap.");
    RETURN W.false;
  END;
  
  (* -- load accelerators -- *)
  ha := W.LoadAccelerators(hInstCurr, IDA_MAINMENU);

  (* -- create main window -- *)
  hWnd := W.CreateWindow(
          SYSTEM.ADR(ClassName), SYSTEM.ADR(WindowTitle),
          W.WS_OVERLAPPEDWINDOW, 
          W.CW_USEDEFAULT, W.CW_USEDEFAULT, 
          W.CW_USEDEFAULT, W.CW_USEDEFAULT, 
          W.NULL, W.NULL, 
          hInstCurr, W.NULL);
  IF hWnd = 0 THEN 
    Error.DspMsg("Couldn't create main window!");
    RETURN W.false;
  END;
  r := W.ShowWindow(hWnd, nCmdShow);
  
  (* -- standard message loop -- *)
  WHILE W.GetMessage(SYSTEM.ADR(msg), W.NULL, W.NULL, W.NULL) # 0 DO
    IF W.TranslateAccelerator(hWnd, ha, SYSTEM.ADR(msg)) = 0 THEN
      r := W.TranslateMessage(SYSTEM.ADR(msg)); 
      r := W.DispatchMessage(SYSTEM.ADR(msg));
    END;
  END;
  RETURN msg.wParam
  
END WinMain;


END Resourc2.
