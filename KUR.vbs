Dim masa, html, ico, kisayol
masa = "C:\Users\omery\OneDrive\Desktop\"
html = masa & "OMER-YILMAZ.html"
ico  = masa & "OMER-YILMAZ.ico"

Set sh = CreateObject("WScript.Shell")
Set k = sh.CreateShortcut(masa & "OMER YILMAZ.lnk")
k.TargetPath   = html
k.IconLocation = ico & ",0"
k.Description  = "Omer Yilmaz Komut Merkezi v100"
k.WindowStyle  = 3
k.Save

MsgBox "Tamam! OMER YILMAZ masaustune eklendi.", 64, "Kurulum"
