@echo on
setlocal

set security_template=sec-analysis.inf

echo Importing security template...
secedit /import /db %temp%\temp.sdb /cfg %security_template%

if %errorlevel% equ 0 (
    echo Security template imported successfully.
) else (
    echo Failed to import security template.
    goto :end
)

echo Applying security template...
secedit /configure /db %temp%\temp.sdb /cfg %security_template%

if %errorlevel% equ 0 (
    echo Security template applied successfully.
) else (
    echo Failed to apply security template.
)

:end
endlocal
