#Requires AutoHotkey v2.0

;#####################################################################################
; Startup:
;#####################################################################################
; Assumes AHKv2_screenshot_tools is an available library
; However, if you are already using GDI+, you may prefer to use both Gdip_All and Gdip_Screenshot_Tools_Ext instead
; Comment in and out include statments as required


; Option 1:
#Include <AHKv2_Screenshot_Tools>

; Option 2:
; #Include <Gdip_All>
; #Include <Gdip_Screenshot_Tools_Ext>

pToken := Gdip_Startup()
OnExit(shutdown, )

folderPath := A_ScriptDir "\Screenshots\"
if (!DirExist(folderPath)) {
	DirCreate folderPath
}

;#####################################################################################
; Screenshot Functions:
;#####################################################################################

CaptureWholeScreen()
{
	pBitmap := Gdip_BitmapFromScreen()
	fileName :=  A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec ".png"
	;NOTE: other formats are supported, just replace "jpg" with "png" or another format in the fileName.
	saveFileTo := folderPath fileName
	Gdip_SaveBitmapToFile(pBitmap, saveFileTo)
	Gdip_DisposeImage(pBitmap)
	return
}

CaptureActiveWindow(clientOnly := false)
{
	activeHWND := WinExist("A")
	if clientOnly {
		pBitmap := Gdip_ClientAreaBitmapFromHWND(activeHWND)
	}
	else {
		pBitmap := Gdip_BitmapFromHWND(activeHWND)
	}
	fileName :=  A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec ".png"
	;NOTE: other formats are supported, just replace "jpg" with "png" or another format in the fileName.
	saveFileTo := folderPath fileName
	Gdip_SaveBitmapToFile(pBitmap, saveFileTo)
	Gdip_DisposeImage(pBitmap)
	return
}

CaptureRenderedActiveWindow(clientOnly := false)
; NOTE: This function uses flags in calls to windows DLLs that are either not officially documented or ENTIRELY UNDOCUMENTED
; As such, behavior may vary or change at any time 
; Rendered capture is also significantly slower, so should be avoided where possible
; That said this is in my experience the most accurate window capture method across various apps
; USE AT YOUR OWN RISK
{
	userConfirm := MsgBox("This function uses undocumented flags for the Windows function PrintWindow. Behavior may be unexpected or change at any time. USE AT YOUR OWN RISK. Press OK if you accept to continue."
							, "WARNING!", "OKCancel Icon! 256 4096")
	if (userConfirm = "OK") {
		activeHWND := WinExist("A")
		if clientOnly {
			pBitmap := Gdip_RenderedClientAreaBitmapFromHWND(activeHWND)
		}
		else {
			pBitmap := Gdip_RenderedBitmapFromHWND(activeHWND)
		}
		fileName :=  A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec ".png"
		;NOTE: other formats are supported, just replace "jpg" with "png" or another format in the fileName.
		saveFileTo := folderPath fileName
		Gdip_SaveBitmapToFile(pBitmap, saveFileTo)
		Gdip_DisposeImage(pBitmap)
	}
	return
}

;#####################################################################################
;Shutdown
shutdown(A_ExitReason, ExitCode)
{
	Gdip_Shutdown(pToken)
	ExitApp()
	Return 1
}