#################################################################
PS v 3.0
#################################################################
# Процент занятости на 54м сервере.
# Задаём алиас утилите создания резевной копии
# место с процентами .54
$DiskNet = "10.x.x.54\asrk"               # Путь к папке с архивами

####################################################################################################
$username = "xxx"
$password = ConvertTo-SecureString "xxxxx" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $password)
New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\$DiskNet" -Credential $cred
####################################################################################################
# df.txt образутся средствами юникс df -h
# получаем содержимое айла df
$PercentBusyDisk = Get-ChildItem -Path "P:\df.txt" | cat

echo $PercentBusyDisk

if ($PercentBusyDisk -ge 91)   # больше или =
{
   echo "Места на xxxxxx осталось < 91% !! "
   Send-MailMessage .....   
   net use /d "\\$DiskNet"  # удалить подключение.
	 exit 0                            # net use /d "\\$DiskNet"
}  
else
{
   echo "место на xxxxxx есть!!"
   net use /d "\\$DiskNet"  # удалить подключение.
   exit 0
}

