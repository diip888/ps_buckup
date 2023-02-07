Start-Transcript -Path C:\ASRKDB\transcript.txt
# БАЗА НН .73 без остановки реплики , т.к нет прав для стоппинга процесса. 06.2021
# Скрипт создания и архивирования резервных копий базы данных
#
###############################################################
# Задаём алиас утилите создания резевной копии
Set-Alias -Name gbak -Value "C:\Program Files (x86)\Red Soft Corporation\Red Database\bin\gbak.exe"
Set-Alias -Name rar -Value "C:\Program Files (x86)\WinRAR\WinRAR.exe"
# настр почтового уведомления
$Mail1 = "N@fc.ru"
$Mail2 = "ev@fc.ru"
$Mail3 = "ov@fc.ru"
$BodyMail = "BackUp сервера 73 АСРК-РФ. "

$FBUser = "xxxxxxx"                 # логин пользователя
$FBPassword = "xxxxxxo"            # Пароль пользователя
# Путь к папке с архивами  
$ArchiveDir = "\\10.52.216.198\Common2"

$FBDataDir  = "C:\ASRKDB"       # Путь к Данным исходной базы
$FBDumpDir  = "C:\BACKUPNN"          # Путь к дампу

$ExpiredDayInterval = 10           # Время хранения архивов (в днях)

####################################################################################################
# Получаем текущую дату
$CurrentDate = Get-Date 
# Приводим её к формату год-месяц-день
$BackupDir = "{0:yyyy-MM-dd}" -f $CurrentDate
# Теперь получаем полный путь к папке текущего архива
$BackupDir = $ArchiveDir + '\' + $BackupDir
# cоздать заново директорию на С: куда пойдет бэкап базы .fbk
mkdir $FBDumpDir
#  Удаляем папку с данным именем, на случай если она случайно образовалась на удаленн машине
if (Test-Path $BackupDir) {
      Remove-Item $BackupDir -recurse -force
 }
# Удаляем предыдущую копию если там чтото есть
Remove-Item $FBDumpDir\*
# Создаём саму копию
#ASRKDB_NEW2019
###gbak -B -G -V -user $FBUser -pas $FBPassword $FBDataDir\ASRKDB_NEW2019.fdb $FBDumpDir\ASRKDB_NEW2019.fbk -Y $FBDumpDir\dump.log
# Создаём папку для архивов
mkdir $BackupDir
# Архивируем наш дамп
#rar A -y  -ibck $BackupDir\ASRKPFO.rar \*.*
#перемещаем наш дамп, ибо архивация слишком долго длится в сет папку на 198
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

# закоментарен тк в 10.2021  закрыт релей на почту SRV77-040.RFS.LOCAL.
# если в домене, то  10.77.5.240 241 это SRV77-040.RFS.LOCAL
Send-MailMessage -From $Mail1 -To $Mail2 -Cc $Mail3 -SmtpServer 10.77.5.241 -Subject "BackUp сервера 73 АСРК-РФ`n$CurrentDate" -Body $BodyMailEnd -Encoding 'UTF8'

Stop-Transcript