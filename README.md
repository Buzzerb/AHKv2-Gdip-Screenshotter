# AHKv2-Screenshot-Tools
### **Scripts to make taking screenshots with AHK easy, written purely in AHKv2**

This repository contains a quickstart script to easily take and save various types of screenshot, plus scripts and libraries to make taking screenshots within your own scripts easy.
 All code draws heavily upon GDI+ code, but both a standalone library and a library to extend GDI+ are included.
 A sample script with various functions to take and save common types of screenshot using the above is also included.

Compatible with the current [AutoHotKey v2](https://autohotkey.com/v2/).
 No support for AHK v1, see Cruncher1's similar AHKv1 script below.

This repository is based on GDI+ for AHKv2 by buliasz ([AHKv2-Gdip](https://github.com/buliasz/AHKv2-Gdip)).
 It is inspired by and draws some code from Cruncher1's [Screen capture script for AHKv1](https://www.autohotkey.com/board/topic/91585-screen-capture-using-only-ahk-no-3rd-party-software-required/).

See the [commit history](https://github.com/Buzzerb/AHKv2-Gdip-Screenshotter/commits/master) for changes made.

## Quickstart
Download and run `AHKv2_Screenshotter_quickstart.ahk`.
 It will create a folder in the script's directory entitled screenshots if one does not already exist.

To take screenshots, press Ctrl + Alt and one of  
s: Whole screen capture  
a: Active window capture  
c: Active window client area capture  
r: Rendered active window capture (see comments in file for more details, not officially supported by Microsoft)  
w: Rendered active window client area capture (see comments in file for more details, not officially supported by Microsoft)  

Screenshots will be saved to the screenshot folder in the script directory


## Rendered vs Unrendered Screenshots
AHKv2-Screenshot_Tools' most significant advantage over pure GDI+ is the ability to take screenshots of hardware accelerated programs.  While a fullscreen screenshot (as you get from pressing Prnt Scrn) will capture hardware accelerated programs normally, 
(with the possible exception of fullscreen hardware accelerated programs) window only screenshots will be captured incorrectly, or as blank black or white.  The solution to this is to capture a screenshot post rendering.  Unfortunately, how to take such screenshots is not
officially documented by Microsoft.  Fortunately, it appears to work anyway for windows 8.1 and above, as documented by Chromium, Rust, and various github pages.  
Owing to the undocumented nature of this function, I would recommend using (the default) unrendered screenshots where possible, but in many cases (all modern browsers, all DirectX programs) it is the only option.

AHKv2-Screenshot_Tools also adds the capability to capture only the client area of a window, in both unrendered and rendered modes.


## Manifest
 - `AHKv2_Screenshotter.ahk`: Example functions to take and save screenshots. Requires either `AHKv2_screenshot_tools.ahk` or both of `Gdip_All.ahk` and `Gdip_Screenshot_Tools_Ext.ahk` as libraries
 - `AHKv2_Screenshotter_quickstart.ahk`: Standalone version of `AHKv2_Screenshotter.ahk` with pre-made hotkeys to quickly take and save various types of screenshot
Libraries inside folder `lib`:
 - `AHKv2_screenshot_tools.ahk`: Standalone library containing only functions relevent for taking and saving screenshots, includes siginificant code from GDI+
 - `Gdip_All.ahk`: Clone of `Gdip_All.ahk` from [(AHKv2-Gdip)](https://github.com/buliasz/AHKv2-Gdip)
 - `Gdip_Screenshot_Tools_Ext.ahk`: Extension to add AHKv2-Screenshot-Tools' extra screenshot capabilities to GDI+, requires `Gdip_All.ahk`


## Retained GDI+ Functions related to screenshots
WIP, read quickstart for best current info

## Examples
WIP, read comments of quickstart for best current info

## History
- @tic Created the original [Gdip.ahk](https://github.com/tariqporter/Gdip/) library.
- @Rseding91 Updated it to make it compatible with unicode and x64 AHK versions and renamed the file `Gdip_All.ahk`.
- @mmikeww Repository updates @Rseding91's `Gdip_All.ahk` to fix bugs and make it compatible with AHK v2.
- @buliasz Fork of mmikeww repository: updates for the current version of AHK v2 (dropping AHK v1 backward compatibility).
- @Buzzerb Fork of buliasz specifically for screenshot functions
