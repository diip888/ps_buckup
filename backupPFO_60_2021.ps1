Start-Transcript -Path C:\transcript.txt
# БАЗА ПФО
# Скрипт создания и архивирования резервных копий базы данных
#
###############################################################
# Задаём алиас утилите создания резевной копии
Set-Alias -Name gbak -Value "C:\Program Files (x86)\Red Soft Corporation\Red Database\bin\gbak.exe"
Set-Alias -Name rar -Value "C:\Program Files (x86)\WinRAR\WinRAR.exe"
$Mail1 = "N@fc.ru"
$Mail2 = "ev@fc.ru"
$Mail3 = "ov@fc.ru"
$BodyMail = "BackUp сервера 60 АСРК-ПФО. \\10xxxxx "

$FBUser = "xxxxx"                 # логин пользователя
$FBPassword = "xxxxxo"            # Пароль пользователя
## Путь к папке с архивами  
$ArchiveDir = "\\10xxxx\60"

$FBDataDir  = "C:\ASRKPFO\DB"       # Путь к Данным исходной базы
$FBDumpDir  = "C:\BACKUP"          # Путь к дампу

$ExpiredDayInterval = 15           # Время хранения архивов (в днях)

####################################################################################################
# Получаем текущую дату
$CurrentDate = Get-Date 
# Приводим её к формату год-месяц-день
$BackupDir = "{0:yyyy-MM-dd}" -f $CurrentDate
# Теперь получаем полный путь к папке текущего архива
$BackupDir = $ArchiveDir + '\' + $BackupDir
# cоздать заново директорию на С: куда пойдет бэкап базы .fbk
mkdir $FBDumpDir
# Удаляем папку с данным именем, на случай если она случайно образовалась на удаленн машине
if (Test-Path $BackupDir) {
    Remove-Item $BackupDir -recurse -force
}
# Удаляем предыдущую копию
Remove-Item $FBDumpDir\*
# Создаём саму копию gbak
gbak -b -g -V -user $FBUser -pas $FBPassword $FBDataDir\DBRCPFO_NEW2019.fdb $FBDumpDir\DBRCPFO_NEW2019.fbk -Y $FBDumpDir\dump.log
# Создаём папку для архивов
mkdir $BackupDir
#Перемещаем наш дамп, ибо архивация слишком долго длится
Move-Item -Path $FBDumpDir -Destination $BackupDir -Force
# Теперь удаляем старые архивы
gci $ArchiveDir | ForEach {
    $dirdate = [datetime]$_.Name
	if ($dirdate -lt (Get-Date).AddDays(-$ExpiredDayInterval)) {
	   rd $_.FullName -Recurse
	}
}
# Текущее время указываем как окончание события
$BackupEnd = Get-Date
$BodyMailEnd = $BodyMail + 'Событие завершено ' + $BackupEND
# если в домене, то  10xxxxxxx это SRV77xxxxxxxxx
Send-MailMessage -From $Mail1 -To $Mail2,$Mail3 -SmtpServer 10xxxxxx -Subject "BackUp сервера 60 АСРК-РФ" -Body $BodyMailEnd -Encoding 'UTF8'
Stop-Transcript