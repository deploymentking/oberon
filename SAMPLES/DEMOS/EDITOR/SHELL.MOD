(******************************************************************************
 * MODULE:      SHELL
 * DESCRIPTION: Interface for Shell-DLL (Registration and Drag & Drop)
 * LANGUAGE:    Oberon-2
 * COMPILER:    Robinson Associates Oberon-2 V1.14
 * AUTHOR(S):   Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 *              Ulrich Kreuzeder, kreuzeder@fim.uni-linz.ac.at (KRE)
 *              Bernhard Leisch, leisch@fim.uni-linz.ac.at (LEI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 95/04/05  PDI     Version 1.0
 ******************************************************************************)
DEFINITION SHELL;

  IMPORT Windows;

  CONST

    (* -- return codes from Registration functions -- *)
    ERROR_SUCCESS           = 0;
    ERROR_BADDB             = 1;
    ERROR_BADKEY            = 2;
    ERROR_CANTOPEN          = 3;
    ERROR_CANTREAD          = 4;
    ERROR_CANTWRITE         = 5;
    ERROR_OUTOFMEMORY       = 6;
    ERROR_INVALID_PARAMETER = 7;
    ERROR_ACCESS_DENIED     = 8;

    (* -- error values for ShellExecute() beyond the regular WinExec() codes -- *)
    SE_ERR_SHARE            = 26;
    SE_ERR_ASSOCINCOMPLETE  = 27;
    SE_ERR_DDETIMEOUT       = 28;
    SE_ERR_DDEFAIL          = 29;
    SE_ERR_DDEBUSY          = 30;
    SE_ERR_NOASSOC          = 31;

    REG_SZ                  = 1;           (* string type *)
    HKEY_CLASSES_ROOT       = 1;

  TYPE
    HDROP  = Windows.HANDLE;
    HKEY   = LONGINT;

    LPSTR  = LONGINT;
    LPCSTR = LONGINT;
    DWORD  = LONGINT;
    UINT   = INTEGER;


PROCEDURE [WINDOWS] RegOpenKey    (key: HKEY; lpszSubKey: LPCSTR; lphkResult: LONGINT):LONGINT;
PROCEDURE [WINDOWS] RegCreateKey  (key: HKEY; lpszSubKey: LPCSTR; lphkResult: LONGINT):LONGINT;
PROCEDURE [WINDOWS] RegCloseKey   (key: HKEY):LONGINT;
PROCEDURE [WINDOWS] RegDeleteKey  (key: HKEY; lpszSubKey: LPCSTR):LONGINT;
PROCEDURE [WINDOWS] RegSetValue   (key: HKEY; lpszSubKey: LPCSTR; fdwType: DWORD; lpszValue: LPCSTR; cb: DWORD):LONGINT;
PROCEDURE [WINDOWS] RegQueryValue (key: HKEY; lpszSubKey: LPCSTR; lpszValue: LPSTR; lpcb: LONGINT):LONGINT;
PROCEDURE [WINDOWS] RegEnumKey    (key: HKEY; iSubkey: DWORD; lpszBuffer: LPSTR; cbBuffer: DWORD):LONGINT;

PROCEDURE [WINDOWS] DragQueryFile   (hDrop: HDROP; iFile: UINT; lpszFile: LPSTR; cb: UINT): INTEGER;
PROCEDURE [WINDOWS] DragQueryPoint  (hDrop: HDROP; lppt: LONGINT): INTEGER;
PROCEDURE [WINDOWS] DragFinish      (hDrop: HDROP);
PROCEDURE [WINDOWS] DragAcceptFiles (hWnd: Windows.HWND; fAccept: Windows.BOOL);

PROCEDURE [WINDOWS] ExtractIcon (hInst: Windows.HINSTANCE; lpszExeFileName: LPCSTR; nIconIndex: UINT): Windows.HICON;

PROCEDURE [WINDOWS] ShellExecute (hWnd: Windows.HWND; lpOperation: LPCSTR; lpFile: LPCSTR; lpParameters: LPCSTR; lpDirectory: LPCSTR; iShowCmd: INTEGER): Windows.HINSTANCE;
PROCEDURE [WINDOWS] FindExecutable (lpFile: LPCSTR; lpDirectory: LPCSTR; lpResult: LPSTR): Windows.HINSTANCE;

END SHELL.
