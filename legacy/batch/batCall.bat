@echo on

::Will call multiple scripts, generated with ChatGPT
::Edit the placeholders "script*.bat"

::SYNTAX
::echo Running script1.bat
::call allPwdChange.bat


echo Running allPwdChange.bat
call allPwdChange.bat

echo Running secApply.bat
call secApply.bat

echo Running script3.bat
call script3.bat

echo All scripts have been executed.
