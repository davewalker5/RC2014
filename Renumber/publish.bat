@ECHO OFF

REM publish.bat win-x64

dotnet publish Renumber\Renumber.csproj -c Release -r %1 --self-contained -o Published\%1

IF [%1] NEQ [win-x64] GOTO END
robocopy /MIR Published\%1 C:\MyApps\RC2014\Renumber

:END
ECHO ON