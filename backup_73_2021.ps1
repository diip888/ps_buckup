Start-Transcript -Path C:\ASRKDB\transcript.txt
# ���� �� .73 ��� ��������� ������� , �.� ��� ���� ��� ��������� ��������. 06.2021
# ������ �������� � ������������� ��������� ����� ���� ������
#
###############################################################
# ����� ����� ������� �������� �������� �����
Set-Alias -Name gbak -Value "C:\Program Files (x86)\Red Soft Corporation\Red Database\bin\gbak.exe"
Set-Alias -Name rar -Value "C:\Program Files (x86)\WinRAR\WinRAR.exe"
# ����� ��������� �����������
$Mail1 = "N@fc.ru"
$Mail2 = "ev@fc.ru"
$Mail3 = "ov@fc.ru"
$BodyMail = "BackUp ������� 73 ����-��. "

$FBUser = "xxxxxxx"                 # ����� ������������
$FBPassword = "xxxxxxo"            # ������ ������������
# ���� � ����� � ��������  
$ArchiveDir = "\\10.52.216.198\Common2"

$FBDataDir  = "C:\ASRKDB"       # ���� � ������ �������� ����
$FBDumpDir  = "C:\BACKUPNN"          # ���� � �����

$ExpiredDayInterval = 10           # ����� �������� ������� (� ����)

####################################################################################################
# �������� ������� ����
$CurrentDate = Get-Date 
# �������� � � ������� ���-�����-����
$BackupDir = "{0:yyyy-MM-dd}" -f $CurrentDate
# ������ �������� ������ ���� � ����� �������� ������
$BackupDir = $ArchiveDir + '\' + $BackupDir
# c������ ������ ���������� �� �: ���� ������ ����� ���� .fbk
mkdir $FBDumpDir
#  ������� ����� � ������ ������, �� ������ ���� ��� �������� ������������ �� ������� ������
if (Test-Path $BackupDir) {
      Remove-Item $BackupDir -recurse -force
 }
# ������� ���������� ����� ���� ��� ����� ����
Remove-Item $FBDumpDir\*
# ������ ���� �����
#ASRKDB_NEW2019
###gbak -B -G -V -user $FBUser -pas $FBPassword $FBDataDir\ASRKDB_NEW2019.fdb $FBDumpDir\ASRKDB_NEW2019.fbk -Y $FBDumpDir\dump.log
# ������ ����� ��� �������
mkdir $BackupDir
# ���������� ��� ����
#rar A -y  -ibck $BackupDir\ASRKPFO.rar \*.*
#���������� ��� ����, ��� ��������� ������� ����� ������ � ��� ����� �� 198
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

# ������������ �� � 10.2021  ������ ����� �� ����� SRV77-040.RFS.LOCAL.
# ���� � ������, ��  10.77.5.240 241 ��� SRV77-040.RFS.LOCAL
Send-MailMessage -From $Mail1 -To $Mail2 -Cc $Mail3 -SmtpServer 10.77.5.241 -Subject "BackUp ������� 73 ����-��`n$CurrentDate" -Body $BodyMailEnd -Encoding 'UTF8'

Stop-Transcript