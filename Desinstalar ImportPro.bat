@echo off
chcp 65001 >nul
title Desinstalar Carvest
echo.
echo  Este programa vai apagar o Carvest deste computador:
echo   - a pasta do programa (%LOCALAPPDATA%\ImportaConsole), incluindo a chave do Firecrawl,
echo     a sessao da conta, os favoritos, os ajustes e os registos;
echo   - os atalhos no ambiente de trabalho e no menu Iniciar.
echo.
echo  Antes de continuar, abra o Carvest e use "A minha conta" ^> "Terminar sessao".
echo.
set /p OK= Escreva SIM e carregue Enter para apagar:
if /I not "%OK%"=="SIM" (
  echo  Cancelado. Nada foi apagado.
  pause
  exit /b
)

echo.
echo  A fechar o Carvest...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*ImportaConsole*servidor.py*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"
timeout /t 2 /nobreak >nul

echo  A apagar a pasta do programa...
if exist "%LOCALAPPDATA%\ImportaConsole" rmdir /s /q "%LOCALAPPDATA%\ImportaConsole"

echo  A apagar os atalhos...
powershell -NoProfile -ExecutionPolicy Bypass -Command "foreach ($p in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) { foreach ($n in @('Carvest.lnk','ImportPro.lnk','Importa Console.lnk','Import Invest.lnk')) { $f = Join-Path $p $n; if (Test-Path $f) { Remove-Item $f -Force } } }"

echo.
if exist "%LOCALAPPDATA%\ImportaConsole" (
  echo  Nao consegui apagar tudo. Feche o Carvest, espere 3 minutos e corra este ficheiro outra vez.
) else (
  echo  Feito. O Carvest foi apagado deste computador.
)
echo.
echo  Falta fazer a mao (ver as instrucoes que o Claude lhe deu):
echo   - apagar os ficheiros "Carvest ... .xlsx", "ImportPro ... .xlsx" e "Instalar ImportPro.bat" das Transferencias;
echo   - limpar os dados do navegador e terminar as sessoes nos sites;
echo   - desinstalar o Python, so se foi instalado por causa do Carvest.
echo.
pause
