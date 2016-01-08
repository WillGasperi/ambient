@echo off
setlocal

::
:: CHECK PARAMETERS
::

	if "%1"=="download" (
		goto :downloadFunction
	)
	
	if "%1"=="unpack" (
		goto :unpackFunction
	)

::
:: SET ENVIRONMENT VARS
::

	set "url_def=http://vanuatu.com.br/getlast/?"
	set "bse_dir=%~dp0base\essentials"
	set "lck_fil=.\lck\"
	set "err_fil=.\error\"

::
:: CREATE AND DELETE FOLDERS
::

	if not exist "%lck_fil%"     mkdir "%lck_fil%"
	if not exist "%bse_dir%\%3"  mkdir "%bse_dir%"
	if     exist "%err_fil%"     rmdir "%err_fil%" /s /q

::
:: DOWNLOADING FILES
::

	set inCount=

	set prog=7za32
	set file=7za.exe
	set fold=%bse_dir%\7zip\x86
	set chck=%bse_dir%\7zip\x86\7za.exe
	set unzip=no
	set zip="%fold%\%file%"
	call:startDownload

	call:WaitParalel

	set inCount=

	if not exist %zip% (
		echo 7za not found, please try execute the download again
		pause
		goto:eof
	)

	set prog=node
	set file=node.exe
	set fold=%bse_dir%\node
	set chck=%bse_dir%\node\node.exe
	set unzip=no
	call:startDownload

	set prog=npm
	set file=npm.zip
	set fold=%bse_dir%\node
	set chck=%bse_dir%\node\npm.cmd
	set unzip=yes
	call:startDownload

	if not "%1"=="ignore-vanuatu-tools" (
	
		set prog=repo
		set file=repo.zip
		set fold=%~dp0
		set chck=%~dp0\repo\repo.cmd
		set unzip=yes
		call:startDownload

		set prog=cli
		set file=cli.zip
		set fold=%~dp0
		set chck=%~dp0\cli\cli.cmd
		set unzip=yes
		call:startDownload

		set prog=srvc
		set file=srvc.zip
		set fold=%~dp0
		set chck=%~dp0\srvc\srvc.cmd
		set unzip=yes
		call:startDownload
	
	)
	
	call:WaitParalel

::
:: RENAME VANUATU TOOLS
::

	if not "%1"=="ignore-vanuatu-tools" (
		if exist repo-master ren repo-master repo
		if exist srvc-master ren srvc-master srvc
		if exist cli-master  ren cli-master  cli
	)
	
::
:: DELETE LOCK FOLDER
::

	rmdir "%lck_fil%" /s /q
	
::
:: FUNCTIONS
::

	goto:eof

	:WaitParalel
		if exist %err_fil%\*.log (
			echo Erro ao fazer download de um ou mais arquivos, verifique os log na pasta %err_fil%
			taskkill /F /FI "WindowTitle eq AMBIENT DOWNLOADING" /T >nul
			goto:eof
		)
		
		for %%N in (%inCount%) do (
			2>nul ( >>"%lck_fil%%%N" (call ) ) && (
				call set inCount=%%inCount: %%N=%%
			) || (
				@timeout /t 3 /nobreak >nul
				goto :WaitParalel
			)
		)
	goto:eof

	:startDownload
		set inCount=%inCount% dwn-%prog%
		start "" /B cmd /c 9>"%lck_fil%dwn-%prog%" "install.cmd" download
	goto:eof

	:startUnpack
		set inCount=%inCount% upk-%prog%
		start "" /B cmd /c 9>"%lck_fil%upk-%prog%" "install.cmd" unpack
	goto:eof
	
	:downloadFunction

		if not exist "%fold%" mkdir "%fold%"
		if exist "%chck%" (
			echo found file: %url_def%%prog%
			goto:eof
		) else (
			echo download started: %url_def%%prog%
		)

		REM powershell -Command "Invoke-WebRequest %url_def%%prog% -OutFile '%fold%\%file%'"
		powershell -Command (New-Object System.Net.WebClient).DownloadFile('%url_def%%prog%', '%fold%\%file%')

		echo download completed: %url_def%%prog%

		if %errorlevel% neq 0 (
			echo Para maiores detalhes acesse: "%err_fil%"
			if not exist "%err_fil%" mkdir "%err_fil%"
			echo "Download error">>%err_fil%\%file%.log
			cancel
		) else (
			if %unzip%==yes (
				goto :startUnpack
			)
		)
	goto:eof
	
	:unpackFunction
		echo unpack started: "%fold%\%file%"
		
		set inCount=%inCount% %prog%
		%zip% x "%fold%\%file%" "-o%fold%" -y>nul
		del "%fold%\%file%"
		
		echo unpack complete: "%fold%\%file%"
	goto:eof
