@echo off
setlocal

::
::
::

	if "%1"=="download" (
		goto :downloadFunction
	)
	
	if "%1"=="unpack" (
		goto :unpackFunction
	)

::
::
::

	set "url_def=http://vanuatu.com.br/getlast/?"
	set "bse_dir=%~dp0base\essentials"
	set "lck_fil=.\lck\"
	set "err_fil=.\error\"

::
::
::

	if not exist "%lck_fil%"     mkdir "%lck_fil%"
	if not exist "%bse_dir%\%3"  mkdir "%bse_dir%"
	if     exist "%err_fil%"     rmdir "%err_fil%" /s /q

::
:: downloading files
::

	:downloadSection
	
		set inCount=

		set prog=7za32
		set file=7za.exe
		set fold=%bse_dir%\7zip\x86
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
		set unzip=no
		call:startDownload

		set prog=npm
		set file=npm.zip
		set fold=%bse_dir%\node
		set unzip=yes
		call:startDownload

		set prog=repo
		set file=repo.zip
		set fold=%~dp0
		set unzip=yes
		call:startDownload

		set prog=cli
		set file=cli.zip
		set fold=%~dp0
		set unzip=yes
		call:startDownload

		set prog=srvc
		set file=srvc.zip
		set fold=%~dp0
		set unzip=yes
		call:startDownload
	
		call:WaitParalel

::
::
::

	ren repo-master repo
	ren srvc-master srvc
	ren cli-master  cli

::
::
::

	rmdir "%lck_fil%" /s /q
	del install.cmd
	
::
:: Functions
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
		echo %url_def%%prog%
		set inCount=%inCount% dwn-%prog%
		start "" cmd /c 9>"%lck_fil%dwn-%prog%" "install.cmd" download
	goto:eof

	:startUnpack
		set inCount=%inCount% upk-%prog%
		start "" cmd /c 9>"%lck_fil%upk-%prog%" "install.cmd" unpack
	goto:eof
	
	:downloadFunction
		mode con: cols=80 lines=12
		title AMBIENT DOWNLOADING

		echo Wait, downloading %file%
		echo from url: %url_def%%prog%
		echo to folder: %fold%
		echo.
		echo DONT CLOSE THIS WINDOW
		echo DONT CLOSE THIS WINDOW
		echo DONT CLOSE THIS WINDOW

		if not exist "%fold%" mkdir "%fold%"
		if exist "%fold%\%file%" (
			echo existe manolo
			goto:eof
		)

		powershell -Command "Invoke-WebRequest %url_def%%prog% -OutFile '%fold%\%file%'"

		if %errorlevel% neq 0 (
			title AMBIENT DOWNLOADING - ERROR
			echo Para maiores detalhes acesse "%err_fil%"
			if not exist "%err_fil%" mkdir "%err_fil%"
			echo "Download error">>%err_fil%\%file%.log
			pause
		) else (
			if %unzip%==yes (
				goto :startUnpack
			)
		)
	goto:eof
	
	:unpackFunction
		mode con: cols=80 lines=12
		title AMBIENT UNPACKING
		echo Unpacking: "%fold%\%file%"
		
		set inCount=%inCount% %prog%
		%zip% x "%fold%\%file%" "-o%fold%" -y
		del "%fold%\%file%"
	goto:eof
