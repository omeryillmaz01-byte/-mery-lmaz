Set sh = CreateObject("WScript.Shell")
Set k = sh.CreateShortcut(sh.SpecialFolders("Desktop") & "\OMER YILMAZ.lnk")
k.TargetPath = Replace(WScript.ScriptFullName, "KUR.vbs", "OMER-YILMAZ.html")
k.IconLocation = Replace(WScript.ScriptFullName, "KUR.vbs", "OMER-YILMAZ.ico") & ",0"
k.Description = "Omer Yilmaz Komut Merkezi v100"
k.WindowStyle = 3
k.Save
MsgBox "✅ OMER YILMAZ masaüstüne eklendi!", 64, "Kurulum Tamamlandı"
