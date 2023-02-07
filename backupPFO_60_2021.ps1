Start-Transcript -Path C:\transcript.txt
# ���� ���
# ������ �������� � ������������� ��������� ����� ���� ������
#
###############################################################
# ����� ����� ������� �������� �������� �����
Set-Alias -Name gbak -Value "C:\Program Files (x86)\Red Soft Corporation\Red Database\bin\gbak.exe"
Set-Alias -Name rar -Value "C:\Program Files (x86)\WinRAR\WinRAR.exe"
$Mail1 = "N@fc.ru"
$Mail2 = "ev@fc.ru"
$Mail3 = "ov@fc.ru"
$BodyMail = "BackUp ������� 60 ����-���. \\10xxxxx "

$FBUser = "xxxxx"                 # ����� ������������
$FBPassword = "xxxxxo"            # ������ ������������
## ���� � ����� � ��������  
$ArchiveDir = "\\10xxxx\60"

$FBDataDir  = "C:\ASRKPFO\DB"       # ���� � ������ �������� ����
$FBDumpDir  = "C:\BACKUP"          # ���� � �����

$ExpiredDayInterval = 15           # ����� �������� ������� (� ����)

####################################################################################################
# �������� ������� ����
$CurrentDate = Get-Date 
# �������� � � ������� ���-�����-����
$BackupDir = "{0:yyyy-MM-dd}" -f $CurrentDate
# ������ �������� ������ ���� � ����� �������� ������
$BackupDir = $ArchiveDir + '\' + $BackupDir
# c������ ������ ���������� �� �: ���� ������ ����� ���� .fbk
mkdir $FBDumpDir
# ������� ����� � ������ ������, �� ������ ���� ��� �������� ������������ �� ������� ������
if (Test-Path $BackupDir) {
    Remove-Item $BackupDir -recurse -force
}
# ������� ���������� �����
Remove-Item $FBDumpDir\*
# ������ ���� ����� gbak
gbak -b -g -V -user $FBUser -pas $FBPassword $FBDataDir\DBRCPFO_NEW2019.fdb $FBDumpDir\DBRCPFO_NEW2019.fbk -Y $FBDumpDir\dump.log
# ������ ����� ��� �������
mkdir $BackupDir
#���������� ��� ����, ��� ��������� ������� ����� ������
Move-Item -Path $FBDumpDir -Destination $BackupDir -Force
# ������ ������� ������ ������
gci $ArchiveDir | ForEach {
    $dirdate = [datetime]$_.Name
	if ($dirdate -lt (Get-Date).AddDays(-$ExpiredDayInterval)) {
	   rd $_.FullName -Recurse
	}
}
# ������� ����� ��������� ��� ��������� �������
$BackupEnd = Get-Date
$BodyMailEnd = $BodyMail + '������� ��������� ' + $BackupEND
# ���� � ������, ��  10xxxxxxx ��� SRV77xxxxxxxxx
Send-MailMessage -From $Mail1 -To $Mail2,$Mail3 -SmtpServer 10xxxxxx -Subject "BackUp ������� 60 ����-��" -Body $BodyMailEnd -Encoding 'UTF8'
Stop-Transcript