@echo off
	:user_settings
	:: ScriptPNG will run automatically if autorun=1
	set "autorun=0"
	:: If it runs automatically, specify default option
	set "default_option=1"
:scriptpng
:: Global engine: 04.11.2013
setlocal enabledelayedexpansion
color 0f
set "name=ScriptPNG"
set "version=08.04.2014"
set "lib=%~dp0lib\"
path %lib%;%path%
if "%~1" equ "thread" call:thread_run "%~2" %3 %4 & exit /b
set "script_name=%~0"
set "define_source_path=%~dp0"
set "temporary_folder=%temp%\ScriptPNG\%random%\"
set "temporary_parent_folder=%temp%\ScriptPNG\"
:script_check
if exist %temporary_parent_folder% goto:debug_session
if not exist %lib% goto:debug_lib_folder
:counters
set "current_png_number=0"
set "current_png_size=0"
set "total_png_number=0"
set "total_png_size=0"
set "change_png=0"
set "wait_in_ms=500"
:params
set "png="
set "log_file=%temporary_folder%log_file.csv"
set "counters_png=%temporary_folder%countpng"
set "separe_bar=__________________________________________________________________________"
:thread_configuration
set "number_of_png_thread=4"
if %number_of_png_thread% equ 1 (set "multi_thread=0") else set "multi_thread=1"
if "%~1" neq "" (
set "params=%*"
) else (
title Usage - %name% - %version%
echo.
echo.
echo  Usage   : To use %name%, just drag-and-drop your files
echo.
echo            on the %name% file
echo.
echo.
echo            -------------------
echo  Formats : PNG,GIF,JPG,PCX,TGA
echo            -------------------
echo.
echo.
echo  Extra   : c = keep colortype
echo            f = filtering and zopfli
echo            s = clean deflate stream
echo            t = ks-flate trials
echo            x = high optimization
echo            z = zopfli compression
echo.
echo.
pause >nul
goto:eof
)
:check_folder
for %%a in (%*) do (
call:define_source "%%~a"
if defined is_a_png (
if not defined is_a_folder (
set /a "total_png_number+=1"
) else (
for /f "delims=" %%i in ('dir /b /s /a-d-h "%%~a\*.png" 2^>nul ^| find /c /v "" ') do set /a "total_png_number+=%%i"
)
)
)
if "%total_png_number%" equ "0" set "multi_thread=0"
set "params1="
for %%a in (%*) do (
set "err="
1>nul 2>nul dir "%%~a" || (
goto:eof
)
if not defined err (
call:define_source "%%~a"
if not defined is_a_png set "err=2"
if not defined err (
if defined is_a_png if not defined png call:user_interface "%%~a"
set "params1=!params1! %%a"
)
)
)
if not defined params1 goto:file_converter
:temporary_path
if not exist "%temporary_folder%" 1>nul 2>&1 md "%temporary_folder%"
if "%png%" equ "0" set "multi_thread=0"
if %multi_thread% neq 0 1>nul 2>&1 >"%log_file%" echo.
if not defined png set "png=0"
:first_echo
cls
echo.
echo.
echo  %name% - %version%
echo.
echo.
call:set_title
set start=%time%
for %%a in (%params1%) do (
call:define_source "%%~a"
if defined is_a_png if "%png%" neq "0" call:png_in_folder "%%~a"
)
:thread_check_wait
set "thread="
for /l %%z in (1,1,%number_of_png_thread%) do if exist "%temporary_folder%threadpng%%z.lock" (set "thread=1") else call:echo_in_log & call:set_title
if defined thread >nul 2>&1 ping -n 1 -w %wait_in_ms% 127.255.255.255 & goto:thread_check_wait
call:end
pause>nul & exit /b
:thread_creation
if %2 equ 1 call:thread_run "%~3" %1 1 & call:echo_in_log & exit /b
for /l %%z in (1,1,%2) do (
if not exist "%temporary_folder%thread%1%%z.lock" (
call:echo_in_log
>"%temporary_folder%thread%1%%z.lock" echo : %~3
start "" /b /low cmd.exe /c ""%script_name%" thread "%~3" %1 %%z "
exit /b
)
)
1>nul 2>&1 ping -n 1 -w %wait_in_ms% 127.255.255.255
goto:thread_creation
:echo_in_log
if %multi_thread% equ 0 exit /b
if exist "%temporary_folder%echo_in_log.lock" exit /b 
>"%temporary_folder%echo_in_log.lock" echo.echo_in_log %echo_file_log%
if not defined echo_file_log set "echo_file_log=1"
for /f "usebackq skip=%echo_file_log% tokens=1-5 delims=;" %%b in ("%log_file%") do (
echo  "%%~b"
echo  In  : %%c Bytes
if %%d geq %%c (
echo  Out : %%d Bytes
)
if %%d lss %%c (
echo  Out : %%d Bytes - %%e Bytes saved
)
echo  %separe_bar%
echo.
set /a "echo_file_log+=1"
)
1>nul 2>&1 del /f /q "%temporary_folder%echo_in_log.lock"
exit /b
:thread_run
if /i "%2" equ "png" call:png_run %1 %3 & call:count_more "%counters_png%"
if exist "%temporary_folder%thread%2%3.lock" >nul 2>&1 del /f /q "%temporary_folder%thread%2%3.lock"
exit /b
:count_more
if %multi_thread% equ 0 exit /b
call:loop_wait "%~1.lock"
>"%~1.lock" echo.%~1
>>"%counters_png%" echo.1
1>nul 2>&1 del /f /q "%~1.lock"
exit /b
:loop_wait
if exist "%~1" (1>nul 2>&1 ping -n 1 -w %wait_in_ms% 127.255.255.255 & goto:loop_wait)
exit /b 0
:define_source
set "is_a_png="
set "is_a_folder="
1>nul 2>nul dir /ad "%~1" && set "is_a_folder=1"
if not defined is_a_folder (
if /i "%~x1" equ ".png" set "is_a_png=1"
) else (
1>nul 2>nul dir /b /s /a-d-h "%~1\*.png" && set "is_a_png=1"
)
exit /b
:set_title
if "%png%" equ "0" (title %~1%name% %version% & exit /b)
if %multi_thread% neq 0 (
set "current_png_number=0"
for %%b in ("%counters_png%") do set /a "current_png_number=%%~zb/3" 2>nul
)
title %~1 [%current_png_number%/%total_png_number%] - %name% - %version%
exit /b
:user_interface
if %autorun% equ 1 (
if "%default_option%" neq "1" if "%default_option%" neq "2" if "%default_option%" neq "3" if "%default_option%" neq "4" if "%default_option%" neq "5" if "%default_option%" neq "6" if "%default_option%" neq "7" if "%default_option%" neq "8" if "%default_option%" neq "9" if "%default_option%" neq "c" if "%default_option%" neq "f" if "%default_option%" neq "s" if "%default_option%" neq "t" if "%default_option%" neq "x" if "%default_option%" neq "z" set "png=1" & exit /b
set "png=%default_option%
exit /b
)
title %name% - %version%
cls
echo.
echo.
echo  %name% - %version%
echo.
echo.
echo.
echo  [1] Fastest               [2] Fast                 [3] Normal
echo.
echo.
echo  [4] Intense               [5] High (Moderate)      [6] High (Intense)
echo.
echo.
echo. [7] High (Max)            [8] Lossy to PNG8+A      [9] Lossy for PNG24+A
echo.
echo.
echo.
set png=
set /p png=# Enter an option: 
echo.
if "%png%" equ "" goto:user_interface
if "%png%" neq "1" if "%png%" neq "2" if "%png%" neq "3" if "%png%" neq "4" if "%png%" neq "5" if "%png%" neq "6" if "%png%" neq "7" if "%png%" neq "8" if "%png%" neq "9" if "%png%" neq "c" if "%png%" neq "f" if "%png%" neq "s" if "%png%" neq "t" if "%png%" neq "x" if "%png%" neq "z" goto:user_interface
exit /b
:png_in_folder
if defined is_a_folder (
for /f "delims=" %%i in ('dir /b /s /a-d-h "%~1\*.png" ') do (
call:thread_creation png %number_of_png_thread% "%%~fi"
set /a "current_png_number+=1" & call:set_title
)
) else (
call:thread_creation png %number_of_png_thread% "%~1"
set /a "current_png_number+=1" & call:set_title
)
exit /b
:png_run
call:copy_temporary "%~1"
if %png% equ 1 call:fastest "%temporary_folder%%~nx1" >nul
if %png% equ 2 call:fast "%temporary_folder%%~nx1" >nul
if %png% equ 3 call:normal "%temporary_folder%%~nx1" >nul
if %png% equ 4 call:intense "%temporary_folder%%~nx1" >nul
if %png% equ 5 call:high_moderate "%temporary_folder%%~nx1" >nul
if %png% equ 6 call:high_intense "%temporary_folder%%~nx1" >nul
if %png% equ 7 call:high_max "%temporary_folder%%~nx1" >nul
if %png% equ 8 call:lossy_png8 "%temporary_folder%%~nx1" >nul
if %png% equ 9 call:lossy_png24 "%temporary_folder%%~nx1" >nul
if %png% equ c call:keep_colortype "%temporary_folder%%~nx1" >nul
if %png% equ f call:do_filtering_zopfli "%temporary_folder%%~nx1" >nul
if %png% equ t call:ks_flate_trials "%temporary_folder%%~nx1" >nul
if %png% equ x call:high_optimization "%temporary_folder%%~nx1" >nul
if %png% equ z call:zopfli_compression "%temporary_folder%%~nx1" >nul
if %png% equ s goto:clean_deflate_stream
	:clean_deflate_stream
	if %png% equ s (
	:: Delete all unnecessary chunks, compact iDAT
	truepng -nz -md remove all -quiet -y "%temporary_folder%%~nx1" >nul
	set "stream=1"
	)
	:: Optimize deflate stream
	if %stream% equ 1 (
	deflopt -k -b -s "%temporary_folder%%~nx1" >nul
	1>nul 2>nul defluff < "%temporary_folder%%~nx1" > "%temporary_folder%%~nx1.tmp"
	call:check_move "%temporary_folder%%~nx1" "%temporary_folder%%~nx1.tmp"
	deflopt -k -b -s "%temporary_folder%%~nx1" >nul
	)
call:check_compare "%~f1" "%temporary_folder%%~nx1" >nul
call:save_log "%~f1" !file_size_origine!
exit /b
:copy_temporary
if %multi_thread% equ 0 (
echo  "%~nx1"
echo  In:  %~z1 Bytes
)
set "file_size_origine=%~z1"
1>nul 2>&1 copy /b /y "%~f1" "%temporary_folder%%~nx1"
exit /b
:save_log
set /a "change=%2-%~z1"
if %multi_thread% neq 0 (
if exist "%temporary_folder%echo_in_log.lock" (1>nul 2>&1 ping -n 1 -w %wait_in_ms% 127.255.255.255 & goto:save_log)
1>nul 2>&1 >"%temporary_folder%echo_in_log.lock" echo.save_log %~1
1>nul 2>&1 >>"%log_file%" echo.%~nx1;%2;%~z1;%change%
1>nul 2>&1 del /f /q "%temporary_folder%echo_in_log.lock"
)
exit /b
:end
set finish=%time%
title Finished - %name% - %version%
if "%png%" equ "0" 1>nul ping -n 1 -w %wait_in_ms% 127.255.255.255 2>nul
if %multi_thread% neq 0 for /f "usebackq tokens=1-5 delims=;" %%a in ("%log_file%") do (
if /i "%%~xa" equ ".png" set /a "total_png_size+=%%b" & set /a "current_png_size+=%%c"
)
set /a "change_png=%total_png_size%-%current_png_size%" 2>nul
set /a "change_png_kb=%change_png%/1024" 2>nul
echo.
echo  Total: %change_png_kb% KB [%change_png% Bytes] saved.
echo.
echo.
echo  Started  at : %start%
echo  Finished at : %finish%
echo.
1>nul 2>&1 rd /s /q "%temporary_parent_folder%"
exit /b
:debug_lib_folder
title Error - %name% - %version%
cls
echo.
echo.
echo  %name% can not find lib folder.
echo.
echo.
pause >nul
goto:eof
:debug_session
for /f "tokens=* delims=" %%a in ('tasklist /v /fi "imagename eq cmd.exe" ^| find /c "%name%" ') do (
if %%a equ 1 exit
)
1>nul 2>&1 rd /s /q "%temporary_parent_folder%"
1>nul ping -n 1 -w %wait_in_ms% 127.255.255.255 2>nul
goto:user_settings
exit

:: File converter ::

:file_converter
echo.
echo.
echo  %name% - %version%
echo.
:converter_run
echo.
echo  In : "%~n1%~x1"
echo  Out: "%~n1.png"
if %~x1 equ .bmp (
pngout -s2 -q -y -force "%~f1" >nul
echo  %separe_bar%
goto:converter_next
)
if %~x1 equ .gif (
pngout -s2 -q -y -force "%~f1" >nul
truepng -f0,5 -i0 -g0 -a1 -zc9 -zm9 -zs1 -quiet -force -y "%~n1.png"
echo  %separe_bar%
goto:converter_next
)
if %~x1 equ .jpg (
pngout -s3 -q -y -force "%~f1" >nul
echo  %separe_bar%
goto:converter_next
)
if %~x1 equ .jpeg (
pngout -s3 -q -y -force "%~f1" >nul
echo  %separe_bar%
goto:converter_next
)
if %~x1 equ .pcx (
pngout -q -y -force "%~f1" >nul
echo  %separe_bar%
goto:converter_next
)
if %~x1 equ .tga (
pngout -s2 -q -y -force "%~f1" >nul
echo  %separe_bar%
goto:converter_next
)
:debug_unsupported
title Error - %name% - %version%
cls
echo.
echo.
echo  %name% does not support this format.
echo.
echo.
pause >nul
goto:eof
:converter_next
shift
if .%1==. goto converter_end
goto:converter_run
:converter_end
echo.
echo.
echo. Job List Finished.
echo.
echo.
title Finished - %name% - %version%
pause >nul
goto:eof

:: Comparators ::

:check_compare
if %~z1 leq %~z2 (1>nul 2>&1 del /f /q %2) else (1>nul 2>&1 move /y %2 %1 || exit /b 1)
exit /b
:check_move
1>nul 2>&1 move /y %2 %1
exit /b

:: Optimization routines ::

	:fastest
	:: Reductions are lossless transformations for Web:
	:: - Converts all non-displayed pixels to 0,0,0
	:: - Deletes gAMA chunk, or Interlacing
	:: - ColorType selection
	:: - BitDepth tests (if PNG is paletted, 1,2,4 and 8 bits / pixels tested)
	:: - Colors ordering in palette
	:: - Tests 0 (None) or 5 (alternative mixed) for filtering (fast test)
	:: - Deletes all non-displayed data (keep only necessary chunks)
	:: - Compression with zlib, only strategy 1 (for filtered files)
	truepng -f0,5 -i0 -g0 -a0 -md remove all -zc9 -zm9 -zs1 -quiet -force -y "%~f1"
		:: No Deflate structure optimization
		set "stream=0"
		exit /b
	
	:fast
	:: See "fastest", but with lower compression level that compresses faster
	:: The stream will be compressed further by Deflate method from 7-Zip
	truepng -f0,5 -i0 -g0 -a0 -md remove all -zc6 -zm9 -zs1 -quiet -force -y "%~f1"
		:: Deflate code from 7-zip with normal compression setting
		advdef -z -2 -q "%~f1"
	:: See "fastest"
	set "stream=0"
	exit /b
	
	:normal
	:: See "fast"
	truepng -f0,5 -i0 -g0 -a0 -md remove all -zc6 -zm9 -zs1 -quiet -force -y "%~f1"
		:: Deflate code from 7-zip with highest compression setting
		advdef -z -3 -q "%~f1"
	:: See "fastest"
	set "stream=0"
	exit /b
	
	:intense
	:: Same Reductions as "normal", with also:
	:: - Some tests on RGB data modification:
	:: 	+ Pixels extension to Up, Right, Down, Left
	:: 	+ Pixels modification to 0,0,0 or 255,255,255
	:: 	+ The test is also done without modifying pixels
	:: - For Paletted, if a color is fully transparent, it can be modified
	:: to another color (255,255,255) to optimize the sorting
	truepng -f0,5 -i0 -g0 -a1 -md remove all -zc6 -zm9 -zs1 -quiet -force -y "%~f1"
		:: See "normal"
		advdef -z -3 -q "%~f1"
	:: Deflate Structure Optimization is done
	:: See clean_deflate_stream instruction
	set "stream=1"
	exit /b
	
	:high_moderate
	:: See "intense", but:
	:: - There is no filtering, PNG is always "reduced" with no filtering
	:: and a very fast compression (strategy 2). The reason is that the
	:: another tool will search the optimal filtering in the next step 
	truepng -f0 -i0 -g0 -a1 -md remove all -zc6 -zm9 -zs2 -quiet -force -y "%~f1"
		:: Filtering using a genetic algorithm that can usually find the best
		:: scanline filter for each scanline in the image. Here, the test is
		:: done with a most fastest way: singles filters are excluded, same
		:: for heuristic
		pngwolfz --in="%~f1" --out="%~f1" --exclude-singles --exclude-heuristic --zlib-level=8 --max-stagnate-time=0 --max-evaluations=1 --even-if-bigger
	:: See "normal"
	advdef -z -3 -q "%~f1"
		:: See "intense"
		set "stream=1"
		exit /b
	
	:high_intense
	:: See "moderate"
	truepng -f0 -i0 -g0 -a1 -md remove all -zc6 -zm9 -zs2 -quiet -force -y "%~f1"
	:: ColorType detection. With this, ScriptPNG knows which is the ColorType
	:: of the file. If it's ColorType 3 (Paletted), it will try another
	:: strategy to compress the file further
		for /f "tokens=1 delims=/c " %%i in ('pngout -l "%~f1"') do set "colortype=%%i"
	:: See "high_moderate"
	pngwolfz --in="%~f1" --out="%~f1" --exclude-singles --exclude-heuristic --zlib-level=8 --max-stagnate-time=0 --max-evaluations=1 --even-if-bigger
		:: See "normal"
		advdef -z -3 -q "%~f1"
		:: Only if ColorType is 3 (Paletted), ScriptPNG does this alternative.
		:: PNGOUT does NOT rewrite all colors in palette, it moves transparent
		:: colors at the beginning, and does small changes in ordering.
		:: That's why it does not use "-c3" option: "-c3" rewrites palette
		:: entirely with a similar way as "popularity (most used colors)".
		:: It also uses KS-Flate, that is often a better Deflate compressor
		if %colortype% equ 3 (
		pngout -q "%~f1"
		)
	:: See "intense"
	set "stream=1"
	exit /b
	
	:high_max
	:: All reductions tested before, but small changes:
	:: - Test 0 (None) or 5 (alternative mixed) for filtering (fast test)
	:: - Memory level is 3-9 that can hurt compression a bit
	truepng -f0,5 -i0 -g0 -a1 -md remove all -zc6 -zm3-9 -zs2 -force -y "%~f1"
		:: See "high_intense"
		for /f "tokens=1 delims=/c " %%i in ('pngout -l "%~f1"') do set "colortype=%%i"
	:: See "high_intense"
	pngwolfz --in="%~f1" --out="%~f1" --exclude-singles --exclude-heuristic --zlib-level=8 --max-stagnate-time=0 --max-evaluations=1 --even-if-bigger
		:: Zopfli compression algorithm with 15 iterations. The file
		:: is enought compressed to be more fairly compared with PNGOUT job
		advdef -z -4 -i 15 -q "%~f1"
	:: See "high_intense"
	if %colortype% equ 3 (
	pngout -q "%~f1"
	)
		:: See "intense"
		set "stream=1"
		exit /b
	
	:high_optimization
	:: All reductions tested before, but:
	:: - All strategy methods are tested
	truepng -f0,5 -i0 -g0 -a1 -md remove all -zc9 -zm3-9 -zs0-3 -force -y "%~f1"
		:: See "high_intense"
		for /f "tokens=1 delims=/c " %%i in ('pngout -l "%~f1"') do set "colortype=%%i"
	:: BitDepth Detection: ScriptPNG collects BitDepth value to use it after
	:: The bitdepth is collected only if PNG is Paletted (ColorType 3)
	if %colortype% equ 3 (
	for /f "tokens=3 delims=/d " %%i in ('pngout -l "%~f1"') do set "bitdepth=%%i"
	)
		:: See "high_intense" but with a better zlib compression level
		pngwolfz --in="%~f1" --out="%~f1" --exclude-singles --exclude-heuristic --zlib-level=9 --max-stagnate-time=0 --max-evaluations=1 --even-if-bigger
		
	:: ScriptPNG does a first try by asking PNGOUT to compress
	:: the file as a pure compressor, without modifying any settings

	:: The file is also re-encoded to RGB+alpha to prevent any
	:: colors influence during palette regeneration. This allow
	:: PNGOUT to find a best optimal palette with "-c3" option

	:: PNGOUT rewrites the palette entirely with "-c3" option, using
	:: a loop that consist to find the optimal compression block
	:: (also, each trial change the palette ordering)

	:: Finally, ScriptPNG compares the file
		
	if %colortype% equ 3 (
	start /b /low pngout -f6 -kp -ks -q -y -force "%~f1"
	pngout -c6 -s4 -q -y -force "%~f1" "%temporary_folder%%~n1-pal.png"
	for %%i in (1,2,3,4) do pngout -c3 -d%bitdepth% -n%%i -q -y "%temporary_folder%%~n1-pal.png"
	call:check_compare "%~f1" "%temporary_folder%%~n1-pal.png"
	)
	
	:: Zopfli Compression algorithm with 30 iterations
	:: of the best result
	advdef -z -4 -i 30 -q "%~f1"
		:: See "intense"
		set "stream=1"
		exit /b
		
	:: To optimize the file further, you can also add some features to this script.
	:: - For palette ordering, PNGOUT rewrites palette with different ways
	:: according to options. Samples:
	
	:: "pngout -ks myfile.png"
	::  + When there transparent colors, TruePNG should use its algorithm to
	::  + sort colors. Most of the time, colors are sorted in a way that
	::  + use 256 tRNS values.
	::  + PNGOUT "-ks" option should only rewrite tRNS value at the top of palette,
	::  + without affecting another colors ordering. This generate another result
	::  + that is not tested by ScriptPNG.
	
	:: "pngout -s3 myfile.png"
	:: Some samples, specially TrueColor (ColorType 2) with artifacts, could
	:: be better stored with Huffman Only, because compressed code is just
	:: bigger. ScriptPNG does not do this: JPG format should be better.
	
	:: Extended search:
	:: You should get smaller files if you change some settings, but not always.
	::  + "--max-evaluations=1", a higher value can help to find a better filtering
	::  + "advdef -z -4 -i 30", a higher value should compress more
	
	:lossy_png8
	:: Lossy Conversion to Paletted mode (ColorType 3)
	1>nul 2>&1 pngquant --speed 1 "%~f1"
		:: Reductions, but no ColorType detection:
		:: - Because PNG is always paletted (even if sometimes it can be better
		:: stored with another ColorType)
		:: - "-nc" options also disabling some palette re-ordering
		truepng -f0,5 -i0 -g0 -a1 -nc -md remove all -zc6 -zm9 -zs2 -quiet -force -y "%temporary_folder%%~n1-fs8.png"
	:: See "normal"
	advdef -z -3 -q "%temporary_folder%%~n1-fs8.png"
		call:check_compare "%~f1" "%temporary_folder%%~n1-fs8.png"
		:: See "fastest"
		set "stream=0"
		exit /b
	
	:lossy_png24
	:: Detect Paletted PNG to prevent any damage
	for /f "tokens=1 delims=/c " %%i in ('pngout -l "%~f1"') do set "colortype=%%i"
		:: If detected ColorType is 3 (Paletted), then exit
		if %colortype% equ 3 (
		set "stream=0"
		exit /b
		)
	:: A LOSSY operation, that consists to modify RGB data to be better
	:: stored with average filter. This option will convert all
	:: non-displayed RGB data to 0,0,0, does not do ColorType
	:: detection, and is done with the lowest compression settings
	:: to be more fastest
	truepng -f3 -i0 -g0 -a0 -nc -md remove all -l3 -zc1 -zm1 -zs3 -quiet -force -y "%~f1"
		:: See "normal"
		advdef -z -3 -q "%~f1"
	:: See "fastest"
	set "stream=0"
	exit /b
	
	:keep_colortype
	:: See "moderate", but without any ColorType detection
	truepng -f0,5 -i0 -g0 -a0 -nc -md remove all -zc6 -zm9 -zs2 -quiet -force -y "%~f1"
	:: See "normal"
		advdef -z -3 -q "%~f1"
	:: See "fastest"
	set "stream=0"
	exit /b
	
	:do_filtering_zopfli
	:: See "high_moderate", but searching is more accurate here:
	:: - All filtering methods are tested with 5 seconds by trial 
	pngwolfz --in="%~f1" --out="%~f1" --zlib-level=9 --max-stagnate-time=5 --even-if-bigger >nul
		:: Zopfli Compression algorithm with 30 iterations
		advdef -z -4 -i 30 -q "%~f1"
	:: See "intense"
	set "stream=1"
	exit /b
	
	:ks_flate_trials
	:: KS-Flate trials that consists to use random initial parameters
	:: to find the best optimal output with this compression algorithm
	start /wait /min /low %lib%trials.cmd "%~f1"
		:: No need, because it's already done in the previous script
		set "stream=0"
		exit /b
	
	:zopfli_compression
	:: Pure stream decompression without modifying any characteristics
	advdef -z -0 -f -q "%~f1"
		:: Zopfli Compression algorithm with 30 iterations
		advdef -z -4 -i 30 -q "%~f1"
	:: See "intense"
	set "stream=1"
	exit /b