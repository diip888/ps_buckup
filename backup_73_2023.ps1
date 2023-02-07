Start-Transcript -Path C:\ASRKDB\transcript.txt
# ���� �� .73 ��� ��������� ������� , �.� ��� ���� ��� ��������� ��������. 06.2021
# ������ �������� � ������������� ��������� ����� ���� ������
# 01/2023
###############################################################
# ����� ����� ������� �������� �������� �����
Set-Alias -Name gbak -Value "C:\Program Files (x86)\Red Soft Corporation\Red Database\bin\gbak.exe"

# ����� ��������� �����������
$Mail1 = "N@fc.ru"
$Mail2 = "ev@fc.ru"
$Mail3 = "ov@fc.ru"
$BodyMail = "BackUp ������� 73 ����-��. "

$FBUser = "xxxxxxx"                 # ����� ������������
$FBPassword = "xxxxxxo"            # ������ ������������
$ArchiveDir = "\\10.52.216.54\asrk\backup_week_ASRK"  # ���� � ����� ���� ����� ������ ������ � 73

$FBDataDir  = "C:\ASRKDB"       # ���� � ������ �������� ����
$FBDumpDir  = "C:\BACKUPNN"          # ���� � �����

$ExpiredDayInterval = 7           # ����� �������� ������� (� ����)

###################################################################################################
$username = "xxxx"
$password = ConvertTo-SecureString "xxxxxx" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $password)
New-PSDrive -Name "L" -PSProvider FileSystem -Root "$ArchiveDir" -Credential $cred
####################################################################################################

# �������� ������� ����
$CurrentDate = Get-Date 
# �������� � � ������� ���-�����-���� ���� \\10.52.216.54\asrk\backup_week\2023-01-17
$BackupDir = "{0:yyyy-MM-dd}" -f $CurrentDate
# ���� ����� L ��� ���������� 
New-Item -Path L:\ -Name $BackupDir -ItemType "directory" -Force
# c������ ������ ���������� �� �:\BACKUPNN ���� ������ ����� ���� .fbk
mkdir -p $FBDumpDir -Force

# ������ ���� �����
#ASRKDB_NEW2019
gbak -B -G -V -user $FBUser -pas $FBPassword $FBDataDir\ASRKDB_NEW2019.fdb $FBDumpDir\ASRKDB_NEW2019.fbk -Y $FBDumpDir\dump.log

# ������ ������ ������ 
$result = gci -Path $FBDumpDir -Recurse -Force | Measure-Object -Property Length -Sum
# ������ � ���������� ��� �����
$result = [string]$result.Sum / 1GB
$result = [math]::Round($result, 1)

#���������� ��� ����, ��� ��������� ������� ����� ������ � ��� ����� �� 54 L:\...2023-01-17
Move-Item -Path $FBDumpDir -Destination L:\$BackupDir -Force
#

# ������ ������� ������ ������
gci L:\ | ForEach {
    $dirdate = [datetime]$_.Name
	if ($dirdate -lt (Get-Date).AddDays(-$ExpiredDayInterval)) {
	   rd $_.FullName -Recurse
	}
}
#������ ����� ����� � �����
Remove-PSDrive -Name "L"
# ������� ����� ��������� ��� ��������� �������
$BackupEnd = Get-Date
$BodyMailEnd = $BodyMail + "������� ��������� `n " + $BackupEND
$BodyMailSZ1 = " `n ������ �� "
$BodyMailSZ2 = $result

# ���� � ������, ��  10.77.5.240 241 ��� SRV77-040.RFS.LOCAL
Send-MailMessage -From $Mail1 -To $Mail2 -Cc $Mail3 -SmtpServer 10.177.5.195 -Subject "BackUp ������� 73 ����-��" -Body "$BodyMailEnd $BodyMailSZ1 $BodyMailSZ2" -Encoding 'UTF8'

net use /d $ArchiveDir  # ������� �����������.
Stop-Transcript