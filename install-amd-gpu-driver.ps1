 $KeyPrefix = "latest/AMD_GPU_WINDOWS10"
Expand-Archive .\AMD_GPU_WINDOWS10_DRIVER-23.10.02.02-230926a-397144C-Retail_End_User.zip -DestinationPath "AMD\$KeyPrefix" -Verbose

Get-ChildItem AMD\latest\"AMD_GPU_WINDOWS10"
pnputil /add-driver AMD\latest\"AMD_GPU_WINDOWS10"\*.inf /install /subdirs 

