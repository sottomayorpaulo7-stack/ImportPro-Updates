@echo off
chcp 65001 >nul
title Desinstalar Carvest
echo.
echo  Este programa vai apagar o Carvest deste computador:
echo   - a pasta do programa (%LOCALAPPDATA%\ImportaConsole), incluindo a chave do Firecrawl,
echo     a sessao da conta, os favoritos, as pesquisas, os ajustes e os registos;
echo   - os atalhos no ambiente de trabalho e no menu Iniciar;
echo   - das Transferencias e do Ambiente de trabalho: o instalador e os Excel do Carvest;
echo   - os atalhos do Carvest nos ficheiros recentes do Windows e na Reciclagem;
echo   - os enderecos do Carvest escritos no Explorador e na janela Executar.
echo  No fim abre as paginas do navegador para apagar os dados do Carvest
echo  e pergunta se quer desinstalar o Python.
echo.
echo  Antes de continuar: copie para uma pen os favoritos e as pesquisas, se os quiser
echo  levar, e no Carvest use "A minha conta" ^> "Terminar sessao".
echo.
set /p OK= Escreva SIM e carregue Enter para apagar:
if /I not "%OK%"=="SIM" (
  echo  Cancelado. Nada foi apagado.
  pause
  exit /b
)

echo.
echo  [1/7] A fechar o Carvest...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*ImportaConsole*servidor.py*' -or $_.CommandLine -like '*127.0.0.1:8766*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"
timeout /t 2 /nobreak >nul

echo  [2/7] A apagar a pasta do programa...
if exist "%LOCALAPPDATA%\ImportaConsole" rmdir /s /q "%LOCALAPPDATA%\ImportaConsole"

echo  [3/7] A apagar os atalhos...
powershell -NoProfile -ExecutionPolicy Bypass -Command "foreach ($p in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) { foreach ($n in @('Carvest.lnk','ImportPro.lnk','Importa Console.lnk','Import Invest.lnk')) { $f = Join-Path $p $n; if (Test-Path $f) { Remove-Item $f -Force } } }"

echo  [4/7] A apagar o instalador e os Excel do Carvest (Transferencias e Ambiente de trabalho)...
rem apaga sem passar pela Reciclagem; este desinstalador apaga-se a si proprio no fim
powershell -NoProfile -ExecutionPolicy Bypass -Command "$eu = '%~f0'; $pastas = @((Join-Path $env:USERPROFILE 'Downloads'), [Environment]::GetFolderPath('Desktop')); foreach ($d in $pastas) { if (-not (Test-Path $d)) { continue }; Get-ChildItem -LiteralPath $d -File -ErrorAction SilentlyContinue | Where-Object { ($_.Name -like 'Instalar ImportPro*.bat' -or $_.Name -like 'Instalar Carvest*.bat' -or $_.Name -like 'Desinstalar ImportPro*.bat' -or $_.Name -like 'Desinstalar Carvest*.bat' -or $_.Name -like 'Carvest*.xlsx' -or $_.Name -like 'ImportPro*.xlsx' -or $_.Name -like 'Importa*.xlsx') -and $_.FullName -ne $eu } | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue } }"

echo  [5/7] A apagar o Carvest dos ficheiros recentes do Windows...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$r = Join-Path $env:APPDATA 'Microsoft\Windows\Recent'; if (Test-Path $r) { Get-ChildItem -LiteralPath $r -Filter *.lnk -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'Carvest|ImportPro|ImportaConsole|Importa Console' } | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue } }"

echo  [6/7] A apagar os ficheiros do Carvest que estejam na Reciclagem...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$sh = New-Object -ComObject Shell.Application; $rb = $sh.Namespace(10); if ($rb) { foreach ($it in @($rb.Items())) { if ($it.Name -match 'Carvest|ImportPro|ImportaConsole|Importa Console') { Remove-Item -LiteralPath $it.Path -Recurse -Force -ErrorAction SilentlyContinue } } }"
echo  A apagar os enderecos do Carvest escritos no Explorador e na janela Executar...
powershell -NoProfile -ExecutionPolicy Bypass -Command "foreach ($k in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths','HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU')) { if (Test-Path $k) { $p = Get-ItemProperty -Path $k; foreach ($n in $p.PSObject.Properties.Name) { if ($n -notlike 'PS*' -and $n -ne 'MRUList' -and [string]$p.$n -match 'ImportaConsole|Carvest|ImportPro') { Remove-ItemProperty -Path $k -Name $n -ErrorAction SilentlyContinue } } } }"

echo  [7/7] Dados do Carvest no navegador
echo.
echo  O Carvest abre numa janela do Edge ou do Chrome, que guarda os ajustes do separador
echo  Custos e o historico do endereco 127.0.0.1. Isso so se apaga dentro do navegador.
echo  Vou abrir as paginas certas. Em cada uma:
echo   - Dados dos sites: procure 127.0.0.1 e carregue no caixote do lixo;
echo   - Historico (Ctrl+H): procure 127.0.0.1 e github e apague essas entradas.
echo.
pause
set "EDGE="
for %%E in ("%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" "%LOCALAPPDATA%\Microsoft\Edge\Application\msedge.exe") do if exist %%E set "EDGE=%%~E"
set "CHROME="
for %%C in ("%ProgramFiles%\Google\Chrome\Application\chrome.exe" "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe") do if exist %%C set "CHROME=%%~C"
if defined EDGE start "" "%EDGE%" "edge://settings/content/all" "edge://history/all"
if defined CHROME start "" "%CHROME%" "chrome://settings/content/all" "chrome://history"

echo.
set /p PY= Quer desinstalar tambem o Python? So diga SIM se foi instalado por causa do Carvest:
if /I "%PY%"=="SIM" (
  echo  A desinstalar o Python...
  winget uninstall -e --id Python.Python.3.12 --silent --accept-source-agreements >nul 2>nul
  winget uninstall -e --id Python.Launcher --silent --accept-source-agreements >nul 2>nul
  echo  Se o Python ainda aparecer em Definicoes ^> Aplicacoes, desinstale-o ai.
)

echo.
if exist "%LOCALAPPDATA%\ImportaConsole" (
  echo  Nao consegui apagar tudo. Feche o Carvest, espere 3 minutos e corra este ficheiro outra vez.
) else (
  echo  Feito. O Carvest foi apagado deste computador.
)
echo.
echo  Falta so, se quiser: gerar uma chave nova no site do Firecrawl e apagar a antiga,
echo  porque esta esteve guardada neste computador.
echo.
echo  Este ficheiro vai apagar-se a si proprio quando carregar numa tecla.
pause
(goto) 2>nul & del /f /q "%~f0"
