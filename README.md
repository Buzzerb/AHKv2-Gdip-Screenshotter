# AHKv2-Gdip
This repository contains the GDI+ library (Gdip_All.ahk) backwards compatiable with both AHK v1.1 and up to [AHK v2-alpha77](https://autohotkey.com/v2/).  

AHK v2 may still undergo further changes to the syntax (such as removal of Command syntax), in which case this library will no longer be backward compatible.  

Support for AHK v1.0 has been dropped (find the original `Gdip_All.ahk` library if you need that).  

See the [commit history](https://github.com/mmikeww/AHKv2-Gdip/commits/master) to see the changes made. There is probably lots of room for improvement still.  

It has not been tested thorougly on AHK v2, but all of the tutorial files in the `/Examples/` subfolder work successfully. 

# Usage
All of the Gdip_*() functions use the same syntax as before, so no changes should be required.  

The one exception is for `Gdip_BitmapFromBRA()`. It requires you to read the .bra file witih `FileObj.RawRead()` instead of the `FileRead`command. See the Tutorial.11 file in the Examples folder

# History
- @tic created the original [Gdip.ahk](https://github.com/tariqporter/Gdip/) library
- @Rseding91 updated it to make it compatible with unicode and x64 AHK versions and renamed the file `Gdip_All.ahk`
- this repository updates @Rseding91's `Gdip_All.ahk` to make it compatible with AHK v2

