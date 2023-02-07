Start-Transcript -Path C:\ASRKDB\transcript.txt
# БАЗА НН .73 без остановки реплики , т.к нет прав для стоппинга процесса. 06.2021
# Скрипт создания и архивирования резервных копий базы данных
# 01/2023
###############################################################
# Задаём алиас утилите создания резевной копии
Set-Alias -Name gbak -Value "C:\Program Files (x86)\Red Soft Corporation\Red Database\bin\gbak.exe"

# настр почтового уведомления
$Mail1 = "N@fc.ru"
$Mail2 = "ev@fc.ru"
$Mail3 = "ov@fc.ru"
$BodyMail = "BackUp сервера 73 АСРК-РФ. "

$FBUser = "xxxxxxx"                 # логин пользователя
$FBPassword = "xxxxxxo"            # Пароль пользователя
$ArchiveDir = "\\10.52.216.54\asrk\backup_week_ASRK"  # Путь к папке куда будме Ложить бэкапы с 73

$FBDataDir  = "C:\ASRKDB"       # Путь к Данным исходной базы
$FBDumpDir  = "C:\BACKUPNN"          # Путь к дампу

$ExpiredDayInterval = 7           # Время хранения архивов (в днях)

###################################################################################################
$username = "xxxx"
$password = ConvertTo-SecureString "xxxxxx" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $password)
New-PSDrive -Name "L" -PSProvider FileSystem -Root "$ArchiveDir" -Credential $cred
####################################################################################################

# Получаем текущую дату
$CurrentDate = Get-Date 
# Приводим её к формату год-месяц-день Типа \\10.52.216.54\asrk\backup_week\2023-01-17
$BackupDir = "{0:yyyy-MM-dd}" -f $CurrentDate
# созд диска L как директория 
New-Item -Path L:\ -Name $BackupDir -ItemType "directory" -Force
# cоздать заново директорию на С:\BACKUPNN куда пойдет бэкап базы .fbk
mkdir -p $FBDumpDir -Force

# Создаём саму копию
#ASRKDB_NEW2019
gbak -B -G -V -user $FBUser -pas $FBPassword $FBDataDir\ASRKDB_NEW2019.fdb $FBDumpDir\ASRKDB_NEW2019.fbk -Y $FBDumpDir\dump.log

# узнаем размер бэкапа 
$result = gci -Path $FBDumpDir -Recurse -Force | Measure-Object -Property Length -Sum
# Данные в Гигабайтах для почты
$result = [string]$result.Sum / 1GB
$result = [math]::Round($result, 1)

#перемещаем наш дамп, ибо архивация слишком долго длится в сет папку на 54 L:\...2023-01-17
Move-Item -Path $FBDumpDir -Destination L:\$BackupDir -Force
#

# Теперь удаляем старые архивы
gci L:\ | ForEach {
    $dirdate = [datetime]$_.Name
	if ($dirdate -lt (Get-Date).AddDays(-$ExpiredDayInterval)) {
	   rd $_.FullName -Recurse
	}
}
#удалем связь диска и папки
Remove-PSDrive -Name "L"
# Текущее время указываем как окончание события
$BackupEnd = Get-Date
$BodyMailEnd = $BodyMail + "Событие завершено `n " + $BackupEND
$BodyMailSZ1 = " `n Размер Гб "
$BodyMailSZ2 = $result

# если в домене, то  10.77.5.240 241 это SRV77-040.RFS.LOCAL
Send-MailMessage -From $Mail1 -To $Mail2 -Cc $Mail3 -SmtpServer 10.177.5.195 -Subject "BackUp сервера 73 АСРК-РФ" -Body "$BodyMailEnd $BodyMailSZ1 $BodyMailSZ2" -Encoding 'UTF8'

net use /d $ArchiveDir  # удалить подключение.
Stop-Transcript