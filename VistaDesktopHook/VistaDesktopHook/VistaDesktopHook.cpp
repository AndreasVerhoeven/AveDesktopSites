// VistaDesktopHook.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"


#ifdef _MANAGED
#pragma managed(push, off)
#endif

// data shared between all instances of this DLL
#pragma data_seg(".AVEDESKTOPHOOK")
HWND defView = NULL;
HMODULE hMod = NULL;		// this DLL's module handle
HHOOK hook = NULL;			// the hook's handle
HWND owner = NULL;			// the owner of this hook; this is were we forward to all WM_COPYDATA messages
BOOL hasSubclassed = FALSE;	// TRUE iff we have subclassed the tray already
UINT unsubclassMsg = 0;		// messages used for notifying that we need to remove the subclass procedure.
UINT avePaintMsg = 0;
BOOL doStop=FALSE;
#pragma data_seg()
#pragma comment(linker, "/section:.AVEDESKTOPHOOK,rws")

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
    return TRUE;
}

// Subclass procedure for the tray's window.
LRESULT CALLBACK MsgProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam, UINT_PTR, DWORD_PTR)
{
	// whenever we get a WM_COPYDATA message for the tray,
	// just pass it to the owner window.
	// if the Owner signals we need to drop the data (returning 1), we drop it,
	// otherwise we pass it on to the original procedure.
	/*if(hwnd == tray && WM_COPYDATA == msg)
	{
		if(owner != NULL)
		{
			LRESULT res = SendMessage(owner, WM_COPYDATA, wParam, lParam);
			if(1 == res)
				return 0;
		}
	}*/

	if(WM_ERASEBKGND == msg)
	{
		HDC dc = (HDC)wParam;
		if(dc != NULL)
		{
			RECT clip ={0};
			GetClipBox(dc, &clip);
			//OutputDebugString(L"draw");
			//SendMessage(owner, avePaintMsg, (WPARAM)dc, 0L);
			//	return 0;
			SetProp(owner, L"l", (HANDLE)clip.left);
			SetProp(owner, L"t", (HANDLE)clip.top);
			SetProp(owner, L"r", (HANDLE)clip.right);
			SetProp(owner, L"b", (HANDLE)clip.bottom);
			//HBRUSH brush = CreateSolidBrush(RGB(255,0,0));
			//FillRect(dc, &clip, brush);
			//DeleteObject(brush);
			PrintWindow(owner, dc, PW_CLIENTONLY);
			//SendMessage(owner, WM_PRINTCLIENT, (WPARAM)dc, 0);
			return 0;
		}
	}

	return DefSubclassProc(hwnd, msg, wParam, lParam);
}

// hook callback function
LRESULT CALLBACK CallWndProc(int code, WPARAM wParam,  LPARAM lParam)
{
	// we examine all messages before they reach their destination window.
	// if the window is the tray, subclass the tray (from within the explorer process, thus!).
	// If we get a "stop subclassing" message, we unsubclass the tray again.
	// It's important this is done from this procedure, since this procedure runs
	// on the same thread as the tray window.
	CWPSTRUCT* cpw = reinterpret_cast<CWPSTRUCT*>(lParam);
	if(cpw != NULL && cpw->hwnd == defView)
	{
		if(unsubclassMsg == cpw->message)
		{
			if(hasSubclassed)
				hasSubclassed = !RemoveWindowSubclass(defView, MsgProc, 1);
		}
		else if(!hasSubclassed && !doStop)
		{
			OutputDebugString(L"set subclass");
			hasSubclassed = SetWindowSubclass(defView, MsgProc, 1, NULL);
		}
	}

	return CallNextHookEx(hook, code, wParam, lParam);
}

// method to start the hook
BOOL CALLBACK StartHook(HMODULE hMod, HWND hwnd)
{
	OutputDebugString(L"start hook");
	if(hook != NULL)
		return FALSE;

	doStop = FALSE;

	unsubclassMsg = RegisterWindowMessage(L"AveUnSubclassDefViewPlease");
	avePaintMsg   = RegisterWindowMessage(L"AvePaintMePlease");

	owner = hwnd;

	HWND progman = FindWindow(L"progman", NULL);
	if(NULL == progman)
		return FALSE;

	defView = FindWindowEx(progman, NULL, L"SHELLDLL_DefView", NULL);
	if(NULL == defView)
		return FALSE;

	DWORD threadid = GetWindowThreadProcessId(defView, 0);
	hook = SetWindowsHookEx(WH_CALLWNDPROC, CallWndProc, hMod, threadid);
	if(NULL == hook)
		return FALSE;

	OutputDebugString(L"hook successfully set");

	SendMessage(defView, WM_NULL, 0, 0);
	RECT rc = {0};
	GetClientRect(defView, &rc);
	InvalidateRect(defView, &rc, TRUE);
	UpdateWindow(defView);

	return TRUE;
}

// method to stop the hook
BOOL CALLBACK StopHook()
{
	if(NULL == hook)
		return FALSE;

	doStop = TRUE;
	SendMessage(defView, unsubclassMsg, 0, 0);

	BOOL res = UnhookWindowsHookEx(hook);
	if(res)
	{
		hook = NULL;
	}

	return res;
}

// returns TRUE iff the hook is running
BOOL CALLBACK IsHookRunning()
{
	return hook != NULL;
}


#ifdef _MANAGED
#pragma managed(pop)
#endif

