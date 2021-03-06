﻿Add-Type -AssemblyName System.Windows.Forms | Out-Null
$Script:csv =  " "
$Script:path =  " "

#set þetta hér því af einhverri ástæðu festist þetta í 10% ef ég var með þetta innaní forminu
$dhcp = Get-WindowsFeature -Name DHCP | Select-Object -Property installed
if($dhcp.Installed -eq $false)
{
Install-WindowsFeature –Name DHCP –IncludeManagementTools | Out-Null
}

#býr til label með staðsettum texta og staðsetningu

#region Functions

function labelmaker{
param(
[Parameter(Mandatory)]
$text,
[Parameter(Mandatory)]
$location
)

$label = New-Object System.Windows.Forms.Label
$label.Text = $text
$label.TextAlign = "TopCenter"
$label.Location = New-Object System.Drawing.Size($location[0],$location[1])
return $label


}

function buttonmaker{
param(
[Parameter(Mandatory)]
$text,
[Parameter(Mandatory)]
$location
)

$label = New-Object System.Windows.Forms.button
$label.Text = $text
$label.TextAlign = "TopCenter"
$label.Location = New-Object System.Drawing.Size($location[0],$location[1])
return $label


}

function replaceISL {
 param( 
 [Parameter(Mandatory=$true)]
    $string
 )
 #Þessi partur skiptir út öllum stöfum, (get bætt alltaf við í framtíðinni ef vantar...
 $string = $string -replace 'á','a'
 $string = $string -replace 'Á','A'
 $string = $string -replace 'í','i'
 $string = $string -replace 'Í','I'
 $string = $string -replace 'É','E'
 $string = $string -replace 'é','e'
 $string = $string -replace 'Ý','Y'
 $string = $string -replace 'ý','y'
 $string = $string -replace 'Ú','U'
 $string = $string -replace 'ú','u'
 $string = $string -replace 'Ó','O'
 $string = $string -replace 'ó','o'
 $string = $string -replace 'ö','o'
 $string = $string -replace 'Ö','O'
 $string = $string -replace 'Ð','D'
 $string = $string -replace 'ð','d'
 $string = $string -replace 'Æ','Ae'
 $string = $string -replace 'æ','ae'
 $string = $string -replace 'Þ','Th'
 $string = $string -replace 'þ','th'
 $string = $string.ToLower() #Það var hér sem ég fattaði að ég hefði allteins geta sleppt stóru stöfunum.....
 #skiptir þessu niður þannig að ég geti unnið með þetta sem array og þægilegri máta til að breyta stórum stöfum í byrjun
 $string = $string.Split()
 $cache = ""
 for($i = 0; $i -lt $string.Count; $i++){
     $cache += $string[$i][0]
     $cache = $cache.ToUpper()
     $string[$i] = $string[$i].Remove(0,1)
     $string[$i] = $string[$i].ToString().Insert(0,$cache[$i])
     }
 foreach($str in $string) {
     $string2 += $str +" "#bæti einu ljótu whitespacei við sem ég fjarlægi í lokinn
     }
     $string2 = $string2.Substring(0,$string2.Length-1)

     return $string2
}

function Nafnareglur{
param(
[parameter(Mandatory = $true)]
$nafn
)#tekur inn fullt nafn sem parameter

if($nafn[-1] -eq " ") #þessi if setning kemur í veg fyrir að ef að CSV skráin er með auka bil eftir eftirnafninu að það verði meðtekið sem eftirnafn
    {
    while ($nafn[-1] -eq " ")
    {
        $nafn = $nafn.Substring(0,$nafn.Length -1)

    }


}
$samname = $null #núllstillir stöðvar, hef þetta uppá öryggið
$eftirnafn = $null
$info = @{} #skilast sem hastafla sem kallar þá bara í fornafn: eftirnafn: usernafn: eftir þvúi hvað við á
$fornafn = $null
$nafnsplit = $nafn.Split() #splitta array til að vinna með
for ($i = 0; $i -ne $nafnsplit.Length -1 ; $i++){$fornafn += $nafnsplit[$i] + " " } #þessi forlúppa byr til fornafnið
$fornafn = $fornafn.Substring(0,$fornafn.Length -1) #þessi skipun fjarlægir þetta auka bil sem ég bjó til með forloopunni
$eftirnafn = $nafnsplit[-1] #eftirnafnið er bara síðasta indexið í nafninu sem við splittuðum
$samname = replaceISL -string $nafn #bless íslenskir stafir
$samname = $samname.Replace(' ','.') #þar sem er bil er sett punktur
$ok = $false
$i = 1

if($samname.Length -gt 20) #ef að þetta er lengra en þessir 20 stafir þá bara týnum við aftasta út þangað til að við erum góðir
{
    while ($samname.Length -gt 20)
    {
    $samname = $samname.Substring(0,$samname.Length -1)
    }
}
if($samname[-1] -eq '.')
{
    $samname = $samname.Substring(0,$samname.Length-1)
}
if($samname.Contains("..")){$samname =  $samname.Replace("..",'.')} #ef hann heitir Jón k. Jónsson þá kemur þetta í veg fyrir að það komi sem jon.k..jonsson


if((get-aduser -Filter {samaccountname -like $samname} -Properties samaccountname) -ne $null )
{
$samname = $samname.Substring(0, $samname.Length -2)
$potential = $samname + $i.ToString()

    if((get-aduser -Filter {samaccountname -like $potential} -Properties samaccountname) -ne $null )
    {
    $i++
    $samname += $i.ToString()
    }
    else
    {
    $samname += $i.ToString()
    }



}

$samname = $samname.ToLower() #hendum í lowercase
#setjum upplýsingarnar í hastöflu
$info.Add("fornafn:", $fornafn)
$info.Add("eftirnafn:",$eftirnafn)
$info.Add("username:",$samname) 

return $info

}


function checkboxmaker{
param(
[Parameter(Mandatory)]
$text,
[Parameter(Mandatory)]
$location
)

$checkbox1 = new-object System.Windows.Forms.CheckBox
$checkbox1.Size = New-Object System.Drawing.Size (250,25)
$checkbox1.Text = $text
$checkbox1.Location = New-Object System.Drawing.Size $location
return $checkbox1
}

function tbmaker{
param(
[Parameter(Mandatory)]
$size,
[Parameter(Mandatory)]
$location
)

$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Size = New-Object System.Drawing.Size($size[0],$size[1])
$textbox.Location = New-Object System.Drawing.Size($location[0],$location[1])
return $textbox

}

function villapopup{
param(
[Parameter(Mandatory)]
$message

)
$wshell = New-Object -ComObject Wscript.Shell

$wshell.Popup($message)}

function Get-FileName($initialDirectory)
{
    ##ætlaði að búa þetta til en fann þetta hér:
    #Var frekar basic að skilja
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

function Import-csvfile
{
param(
[Parameter(Mandatory)]
$delim

)
Function Get-FileName($initialDirectory)
{
    ##ætlaði að búa þetta til en fann þetta hér:
    #Var frekar basic að skilja
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}
$csv = Get-FileName
Import-Csv $csv -Encoding Default -Delimiter $delim

}

function SpecificCount
{
param(
[parameter(mandatory)]$oudistname
)
$distnames = @()
$users = get-aduser -Filter * -properties name
foreach ($user in $users)
{
    $dname = $user.Distinguishedname
    $dname = $dname.Split(',')
    $dn = ""
    for ($i = 1; $i -lt $dname.Count; $i++)
    { 
        $dn +=$dname[$i]+','
    }
    $dn = $dn.Substring(0,$dn.Length -1)
    
}

}
#endregion functions

#region mainform og tabcontrol
$ctrlsmainform = @()
$tabpages = @()
$ctrlstabpage1 = @()
$ctrlstabpage2 = @()
$ctrlstabpage3 = @()
$ctrlstabpage4 = @()

#Mainform - þetta er aðalformið sem opnast
$mainform = New-Object System.Windows.Forms.Form
$mainform.StartPosition = "CenterScreen"
$mainform.ClientSize = New-Object System.Drawing.Size(250,500)



#Tabcontrol - Unitið sem meðhondlar stjórnunina á tabs, læt það vera jafnstórt og mainformið
$tabcontrol = New-Object System.Windows.Forms.TabControl
$tabcontrol.Location.X = -1
$tabcontrol.Location.Y = 0
$tabcontrol.Margin.All = 3
$tabcontrol.ClientSize = $mainform.ClientSize
$tabcontrol.Visible = $true
$ctrlsmainform += $tabcontrol

#endregion mainform og tabcontrol

#region tab1

#þegar ein hurð lokast opnast önnur...
$tab1tbnnetkort = buttonmaker -text "Opna Netkort" -location (9,50)
$tab1tbnnetkort.Size =  New-Object System.Drawing.Size(120,25)
$tab1tbnnetkort.Add_Click({$mainform.Hide()
$netform.ShowDialog()
})
$ctrlstabpage1 += $tab1tbnnetkort

#region netkortsform
$Script:netselectedindex = 0
function netformtextupdate{
    $Script:netselectedindex = $combo.SelectedIndex
    $info = $Script:selectednetkort[$combo.SelectedIndex]
    $prefix = Get-NetIPAddress | Where-Object interfaceIndex -EQ $info.InterfaceIndex | Select-Object PrefixLength

    $netformIAinfo.Text = $info.InterfaceAlias
    $netformIP4info.Text = ""
    $netformIP4info.Text = $info.IPv4Address
    if($info.IPv6Address.Count -eq 0){
        $netformIP6info.Text =  "Not Connected"
        $netformPrefinfo.Text = $prefix[1].PrefixLength
    }
    else{
        $netformIP6info.Text = $info.IPv6Address
        $netformPrefinfo.Text = $prefix[0].PrefixLength
    }
    if($info.DNSServer[0].ServerAddresses.Count -ne 0){
    $netformDNSinfo.Text = $info.DNSServer[1].Address
    }
    else{
    $netformDNSinfo.Text = $info.DNSServer[0].Address}
}

function breytanetkorti{
$error.clear()
$message = @()
$gamlanetkort = $netformIAinfo.Text
if($netformIA.Text.Length -eq 0){
    $nyjanetkort = $gamlanetkort
    }
else{
    $nyjanetkort = $netformIA.Text
}

if($netformIP4.Text.Length -eq 0)
{
    $ipaddress = $netformIP4info.Text
}
else{
    $ipaddress = $netformIP4.Text}

if($netformpref.Text.Length -eq 0){
    $prefix = $netformPrefinfo.Text}
else {
    $prefix = $netformpref.Text}

if($netformDNS.Text.Length -eq 0){
$dnsserver = $netformDNSinfo.Text
}
else
{$dnsserver = $netformDNS.Text}

Try{
    Rename-NetAdapter -Name $gamlanetkort -NewName $nyjanetkort #rename-ar netkoritð
    $message += "Nafn Netkorts er $nyjanetkort"
}
catch{
    $message += "Ekki var hægt að skýra Netkortið"
}
try{
    New-NetIPAddress -InterfaceAlias $nyjanetkort -IPAddress $ipaddress -PrefixLength $prefix #-DefaultGateway 192.168.1.1 notum ekki default gateway en hægt að kommenta þetta aftur inn ef þess þarf
    $message += "Upplýsingar $nyjanetkort , Ip: $ipaddress , Prefix: $prefix"
}
catch{
$message += "Breyta Ip tölu mistókst vegna $error"
}
try{
Set-DnsClientServerAddress -InterfaceAlias $nyjanetkort -ServerAddresses $dnsserver #þetta 127.0.0.1 er að setja okkur á loopback semsagt við erum okkar eigin dns þjónn
$message += "DNS server $nyjanetkort = $dnsserver"
}
catch{
$message+= "Ekki tókst að breyta DNS server"
}
finally{
write-host $message
}
$combo.Items.Clear()
$allnets = Get-NetIPConfiguration -detailed | Select-Object -Property InterfaceAlias, DNSServer
$net = @()
foreach($n in $allnets){
if($n.InterfaceAlias -like "*Loopback Pseudo-Interface*")
{

}
else{
$net += $n
}
}
$Script:selectednetkort = $net


foreach($n in $net){
    if($n.AddressFamily -like "IPv6"){
     #$combo.Items.Add($n.InterfaceAlias + " IPv6")
    }
    else{
        $combo.Items.Add($n.InterfaceAlias )
    }
}
$combo.SelectedIndex = $Script:netselectedindex
netformtextupdate
}

$ctrlnetform = @()
#netform - Þetta er formið sem opnast þegar þú ert promptaður um að breyta netkorti
$netform = New-Object System.Windows.Forms.Form
$netform.Name  ="NetkortsBreytingar"
$netform.StartPosition = "CenterScreen"
$netform.ClientSize = New-Object System.Drawing.Size(757,315)
$netform.add_Closed({$mainform.Show()
$netform.Close()

})

#Comboboxið fyrir netform 
$combo = New-Object System.Windows.Forms.ComboBox
$combo.Size = New-Object System.Drawing.Size(190,25)
$combo.DropDownStyle = "DropDownList"
$allnets = Get-NetIPConfiguration -Detailed | Select-Object -Property InterfaceAlias, DNSServer,PrefixLength,interfaceindex,ipv4address
$net = @()
foreach($n in $allnets){
if($n.InterfaceAlias -like "*Loopback Pseudo-Interface*")
{

}
else{
$net += $n
}
}
$Script:selectednetkort = $net

foreach($n in $net){
    if($n.AddressFamily -like "IPv6"){
     #$combo.Items.Add($n.InterfaceAlias + " IPv6")
    }
    else{
        $combo.Items.Add($n.InterfaceAlias )
    }
}

#Get-DnsClientServerAddress -InterfaceAlias "Ethernet"
$combo.SelectedIndex = 0
$combo.Location = New-Object System.Drawing.Point(285, 25)
$Script:selectednetkort[$combo.SelectedIndex].InterfaceAlias
$combo.add_SelectedIndexChanged({
netformtextupdate})
$ctrlnetform += $combo
#textbox fyrir netform
$netformIA = tbmaker -size (138,20) -location (89,50)
$ctrlnetform += $netformIA

$netformIP4 = tbmaker -size (138,20) -location (89,75)
$ctrlnetform += $netformIP4

$netformIP6 = tbmaker -size (138,20) -location (89,100)
$ctrlnetform += $netformIP6

$netformPref = tbmaker -size (138,20) -location (89,125)
$ctrlnetform += $netformPref

$netformDNS = tbmaker -size (138,20) -location (89,150)
$ctrlnetform += $netformDNS

#infotexti
$info = $Script:selectednetkort[$combo.SelectedIndex]
$prefix = Get-NetIPAddress | Where-Object interfaceIndex -EQ $info.InterfaceIndex | Select-Object PrefixLength

$netformIAinfo = tbmaker -size (138,20) -location (530,50)
$netformIAinfo.ReadOnly = $true
$netformIAinfo.Text = $info.InterfaceAlias
$ctrlnetform += $netformIAinfo

$netformIP4info = tbmaker -size (138,20) -location (530,75)
$netformIP4info.ReadOnly = $true
$netformIP4info.Text = $info.IPv4Address
$ctrlnetform += $netformIP4info

$netformPrefinfo = tbmaker -size (138,20) -location (530,125)
$netformPrefinfo.ReadOnly = $true
$ctrlnetform += $netformPrefinfo

$netformIP6info = tbmaker -size (138,20) -location (530,100)
$netformIP6info.ReadOnly = $true
if($info.IPv6Address.Count -eq 0){
    $netformIP6info.Text =  "Not Connected"
    $netformPrefinfo.Text = $prefix[1].PrefixLength
}
else{
    $netformIP6info.Text = $info.IPv6Address
    $netformPrefinfo.Text = $prefix[0].PrefixLength

}

$ctrlnetform += $netformIP6info


$netformDNSinfo = tbmaker -size (138,20) -location (530,150)
$netformDNSinfo.ReadOnly = $true
    if($info.DNSServer[0].ServerAddresses.Count -eq 0){
    $netformDNSinfo.Text = $info.DNSServer[1].Address
    }
    else{
    $netformDNSinfo.Text = $info.DNSServer[0].Address}
$ctrlnetform += $netformDNSinfo


#labelar fyrir netform
$netformlbl1 = labelmaker -text "Veldu Netkort" -location (306,7)
$ctrlnetform += $netformlbl1

$netformlbl2 = labelmaker -text "Breyta Upplýsingum" -location (72,7)
$netformlbl2.Size = New-Object System.Drawing.Size(115,13)
$ctrlnetform += $netformlbl2

$netformlbl3 = labelmaker -text "Interface Alias:" -location (1,50)
$ctrlnetform += $netformlbl3

$netformlbl4 = labelmaker -text "IPv4 Address:" -location (1,75)
$ctrlnetform += $netformlbl4

$netformlbl5 = labelmaker -text "IPv6 Address:" -location (1,100)
$ctrlnetform += $netformlbl5

$netformlbl5 = labelmaker -text "PrefixLength:" -location (1,125)
$ctrlnetform += $netformlbl5

$netformlbl6 = labelmaker -text "DNSserver:" -location (1,150)
$ctrlnetform += $netformlbl6

$netformlbl2 = labelmaker -text "Upplýsingar Um Netkort" -location (528,7)
$ctrlnetform += $netformlbl2

$netformlbl3 = labelmaker -text "Interface Alias:" -location (442,50)
$ctrlnetform += $netformlbl3

$netformlbl4 = labelmaker -text "IPv4 Address:" -location (442,75)
$ctrlnetform += $netformlbl4

$netformlbl5 = labelmaker -text "IPv6 Address:" -location (442,100)
$ctrlnetform += $netformlbl5

$netformlbl5 = labelmaker -text "PrefixLength:" -location (442,125)
$ctrlnetform += $netformlbl5

$netformlbl6 = labelmaker -text "DNSserver:" -location (442,150)
$ctrlnetform += $netformlbl6

$netformbtn = buttonmaker -text "Breyta" -location (85,186)
$netformbtn.Size = New-Object System.Drawing.Size (138,25)
$netformbtn.add_Click({
breytanetkorti
netformtextupdate
})
$ctrlnetform += $netformbtn



foreach($item in $ctrlnetform)
{
    $netform.Controls.Add($item) 
}


#endregion

#RichTexBox í tab1
$rtbtab1 = New-Object System.Windows.Forms.RichTextBox
$rtbtab1.ReadOnly = $true
$rtbtab1.Text = "Byrjað er á að því að setja inn domain nafnið hér að neðan og svo smellt á takkann, eftir það endurræsir vélin sig þegar hún er búinn að setja upp domainið"
$rtbtab1.Location = New-Object System.Drawing.Size(9,100)
$rtbtab1.Size = New-Object System.Drawing.Size(200,100)
$rtbtab1.BackColor = "White"
$ctrlstabpage1 += $rtbtab1

#Labelar í tab1
$tab1lblnetkort = Labelmaker -text "Breyta Netkortum" -location (9,27)
$ctrlstabpage1 += $tab1lblnetkort

$tab1lbldomname = Labelmaker -text "Nafn á Domaini" -location (2,240)
$ctrlstabpage1 += $tab1lbldomname

$tab1lblsafeadminpass = Labelmaker -text "SafeMode Admin Pass" -location (-30,300)
$tab1lblsafeadminpass.ImageKey = "*"
$tab1lblsafeadminpass.Size = New-Object System.Drawing.Size(200,20)
$ctrlstabpage1 += $tab1lblsafeadminpass

#Textbox í tab1
$tab1tbdomain = tbmaker -size (200,20) -location (9,270)
$ctrlstabpage1 += $tab1tbdomain

$tab1safeadminpass = tbmaker -size (200,20) -location (9,320)
$ctrlstabpage1 += $tab1safeadminpass

#Button i tab1
$tab1btndomain = buttonmaker -text "Staðfesta" -location (9,350)
$tab1btndomain.add_Click({

    if($tab1tbdomain.Text.Length -eq 0)
    {
        $msg = villapopup -message "Domain nafnið má ekki vera tómt"
        
        
    }
    elseif($tab1tbdomain.Text -contains ".local"){
        $msg = villapopup -message ".local viðbótin kemur sjálfkrafa"
    }
    else
    {
    
    $domain = $tab1tbdomain.Text
    $local = ".local" 

   
    $a = New-Object -ComObject Wscript.Shell
    $svar = $a.popup("Búa til domainið $domainlocal ?",0,"Staðfesta",4)}
    

    if($svar -eq 6){
        $domainlocal = $domain+$local
        $pass = $tab1safeadminpass.Text

            Install-WindowsFeature -Name AD-Domain-Services –IncludeManagementTools
            Install-ADDSForest –DomainName $domainlocal –InstallDNS -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "$pass" -Force) 

    }

})

$ctrlstabpage1 += $tab1btndomain



#tabpage1 - Fyrsti tabinn í forminu
$tabpage1 = New-Object System.Windows.Forms.TabPage
$tabpage1.add_Enter({$mainform.ClientSize = New-Object System.Drawing.Size(230,500)
$tabcontrol.ClientSize = $mainform.ClientSize})
$tabpage1.Text = "Uppsetning"

foreach($item in $ctrlstabpage1){
$tabpage1.Controls.Add($item)
}
$tabpages += $tabpage1

#endregion tabpage1

#region tab2


#tabpage2 - Seinni tabinn í ævintýrinu
$tabpage2 = New-Object System.Windows.Forms.TabPage
$tabpage2.Text = "DHCP Scope + domainvélar"
$tabpage2.add_Enter({

[System.GC]::Collect()
$mainform.ClientSize = New-Object System.Drawing.Size(800,500)
$tabcontrol.ClientSize = $mainform.ClientSize
}) 

#datagridview scopes
$datagrid = new-object System.Windows.Forms.DataGridView
$datagrid.Location = New-Object System.Drawing.Size(250,40)
$datagrid.Clientsize = New-Object System.Drawing.Size(600,100)
$datagrid.ColumnCount = 5
$datagrid.Columns[0].Name = "ScopeName"
$datagrid.Columns[1].Name = "IpStart"
$datagrid.Columns[2].Name = "State"
$datagrid.Columns[3].Name = "Free"
$datagrid.Columns[4].Name = "InUse" 
$datagrid.SelectionMode = "FullRowSelect"
function datagridinfo {
$datagrid.Rows.Clear()
$scope = Get-DhcpServerv4Scope | Select-Object -Property Name,Startrange,State,ScopeId
for ($i = -1; $i -lt $scope.Count; $i++)
{ 
    $scopeid = $scope[$i].ScopeId
    $scopestats = Get-DhcpServerv4ScopeStatistics -ScopeId $scopeid | Select-Object -Property free, inuse
    $scopestats.Free
    
    $row = @($scope[$i].Name, $scope[$i].StartRange, $scope[$i].State,$scopestats.Free,$scopestats.InUse)
    $datagrid.Rows.Add($row)

}
}
datagridinfo
$ctrlstabpage2 += $datagrid

#datagridview scopes
$datagrid2 = new-object System.Windows.Forms.DataGridView
$datagrid2.Location = New-Object System.Drawing.Size(250,200)
$datagrid2.Clientsize = New-Object System.Drawing.Size(600,130)
$datagrid2.ColumnCount = 4
$datagrid2.Columns[0].Name = "Name"
$datagrid2.Columns[1].Name = "IPv4"
$datagrid2.Columns[2].Name = "OperatingSystem"
$datagrid2.Columns[2].Width = 200
$datagrid2.Columns[3].Name = "Enabled"


$datagrid2.SelectionMode = "FullRowSelect"

function datagridinfo2 {
$datagrid2.Rows.Clear()
$adcomputers = Get-ADComputer -Filter * -properties name,ipv4Address,OperatingSystem,Enabled
foreach($computer in $adcomputers){
    $row = @($computer.Name, $computer.IPv4Address, $computer.OperatingSystem, $computer.Enabled)
    $datagrid2.Rows.Add($row)

}
}
datagridinfo2
$ctrlstabpage2 += $datagrid2


#label í tab 2
$texttalign = "MiddleCenter"
$tab2lblscopenafn = labelmaker -text "Nafn á DHCP Scopei" -location (9,20)
$tab2lblscopenafn.Size = New-Object System.Drawing.Size(200,20)
$tab2lblscopenafn.TextAlign = $texttalign
$ctrlstabpage2 += $tab2lblscopenafn

$tab2lblscopes = Labelmaker -text "Upplýsingar um DHCP scopes" -location (250,20)
$tab2lblscopes.Size = New-Object System.Drawing.Size(200,20)
$ctrlstabpage2 += $tab2lblscopes

$tab2lbladcomp = Labelmaker -text "Upplýsingar um Tölvur á domaini" -location (250,180)
$tab2lbladcomp.Size = New-Object System.Drawing.Size(200,20)
$ctrlstabpage2 += $tab2lbladcomp

$tab2lbladdcpdomain = Labelmaker -text "Bæta við tölvu á domain" -location (250,330)
$tab2lbladdcpdomain.Size = New-Object System.Drawing.Size(200,20)
$ctrlstabpage2 += $tab2lbladdcpdomain

$tab2lbladcpname = Labelmaker -text "Nafn á Tölvu til að bæta við" -location (250,350)
$tab2lbladcpname.Size = New-Object System.Drawing.Size(200,20)
$ctrlstabpage2 += $tab2lbladcpname

$tab2lblscopestart = labelmaker -text "Hvaða iptölu á scope-ið að byrja" -location (9,100)
$tab2lblscopestart.Size = New-Object System.Drawing.Size(200,20)
$tab2lblscopestart.TextAlign = $texttalign
$ctrlstabpage2 += $tab2lblscopestart

$tab2lblscopeend = labelmaker -text "Hvaða iptölu á scope-ið að enda" -location (9,180)
$tab2lblscopeend.Size = New-Object System.Drawing.Size(200,20)
$tab2lblscopeend.TextAlign = $texttalign
$ctrlstabpage2 += $tab2lblscopeend

$tab2lblsubnetmsk = labelmaker -text "Hvaða subnet mask" -location (9,260)
$tab2lblsubnetmsk.Size = New-Object System.Drawing.Size(200,20)
$tab2lblsubnetmsk.TextAlign = $texttalign
$ctrlstabpage2 += $tab2lblsubnetmsk

$tab2lbldns = labelmaker -text "DNS Server" -location (9,340)
$tab2lbldns.Size = New-Object System.Drawing.Size(200,20)
$tab2lbldns.TextAlign = $texttalign
$ctrlstabpage2 += $tab2lbldns

#textbox í tab2
$tab2txtscopenafn = tbmaker -size (200,20) -location (9,50)
$ctrlstabpage2 += $tab2txtscopenafn

$tab2txtscopestart = tbmaker -size (200,20) -location (9,130)
$ctrlstabpage2 += $tab2txtscopestart

$tab2txtscopeend = tbmaker -size (200,20) -location (9,210)
$ctrlstabpage2 += $tab2txtscopeend

$tab2txtsubmask = tbmaker -size (200,20) -location (9,290)
$ctrlstabpage2 += $tab2txtsubmask

$tab2txtdns = tbmaker -size (200,20) -location (9,370)
$ctrlstabpage2 += $tab2txtdns

$tab2txtadcpadd = tbmaker -size (200,20) -location (250,370)
$ctrlstabpage2 += $tab2txtadcpadd


#button í tab 2
$tab2btndeletescope = buttonmaker -text "Eyða scope" -location (250,150)
$tab2btndeletescope.add_Click({
    $inuse = $datagrid.SelectedCells[4].Value
    if($inuse -eq 0)
    {
    villapopup -message "Scope er í notkun og því verður ekki eytt"
    }
    else{
    $Scopeid = Get-DhcpServerv4Scope | Where-Object Name -eq $datagrid.SelectedCells[0].Value
    Remove-DhcpServerv4Scope $Scopeid.ScopeId
    }
    datagridinfo
})
$ctrlstabpage2 += $tab2btndeletescope

$tab2btnadddomain = buttonmaker -text "Bæta við tölvu á domain" -location (250,390)
$tab2btnadddomain.Size = New-Object System.Drawing.Size (200,20)
$tab2btnadddomain.add_Click({
    $cp = $tab2txtadcpadd.Text
    if($cp.Length -eq 0)
    {
        villapopup -message "Má ekki vera tómt"
    }
    else{
        $Error.Clear()
        try{
            $domain = get-addomain | Select-Object -Property DNSroot
            $dnslocal = $domain.DNSroot
        
            Add-Computer -ComputerName $cp -LocalCredential "$cp\Administrator" -DomainName $domain.DNSRoot -Credential "$dnslocal\Administrator" -Restart -Force 
            villapopup -message "Aðgerð tókst $cp er kominn á $dnslocal, $cp endurræsir sig"
            datagridinfo2
        }
        catch{
            villapopup -message $error
        }
    }
    
})
$ctrlstabpage2 += $tab2btnadddomain

$tab2btnscope = buttonmaker -text "Staðfesta" -location (9,400)
$ctrlstabpage2 += $tab2btnscope
$tab2btnscope.add_Click({
    $scopename = $tab2txtscopenafn.Text
    $ipstart = $tab2txtscopestart.Text
    $ipend = $tab2txtscopeend.Text
    $subnet = $tab2txtsubmask.Text
    $dns = $tab2txtdns.Text

    $ipstartsplit = $ipstart.split('.')
    $ipendsplit = $ipend.split('.')
    $subnetsplit = $subnet.split('.')
    $dnssplit = $dns.split('.')

    if($scopename.Length -eq 0)
    {
        villapopup -message "Nafnið má ekki vera tómt"
    }
    elseif($ipstartsplit.Count -ne 4)
    {
        villapopup -message "Byrjun á scope-i er ekki í réttu sniði"
    }
    elseif($ipendsplit.Count -ne 4)
    {
        villapopup -message "Endir á scope-i er ekki í réttu sniði"
    }
    elseif($subnetsplit.Count -ne 4)
    {
        villapopup -message "Subnet Maski ekki í réttu sniði"
    }
        elseif($dnssplit.Count -ne 4)
    {
        villapopup -message "DNS ekki í réttu sniði"
    }
    else
    {
    $error.Clear()
    try {
        $domain = Get-ADDomain | Select-Object -Property Forest
    
        Add-DhcpServerv4Scope -Name $scopename -StartRange $ipstart -EndRange $ipend -SubnetMask $subnet #setur upp dhcp scope
        Set-DhcpServerv4OptionValue -DnsServer $dns -Router $dns #oft iptala serversins
        Add-DhcpServerInDC -DnsName $domain.Forest #t.d. $($env:computername + “.” $env:userdnsdomain)
        villapopup -message "$scopename hefur verið stofnað"
        datagridinfo
    }
    catch{
    villapopup -message $error
    }

    }



})




foreach($item in $ctrlstabpage2){
$tabpage2.Controls.Add($item)
}
$tabpages += $tabpage2


#endregion tab2

#region tab3
$tabpage3 = New-Object System.Windows.Forms.TabPage
$tabpage3.Text = "Notendur og Möppur"
$tabpage3.add_Enter({
[System.GC]::Collect()
$mainform.ClientSize = New-Object System.Drawing.Size(800,500)
$tabcontrol.ClientSize = $mainform.ClientSize
})


#dynamicdropdown
$dynamicdrop = @()
$y = 60
for ($i = 1; $i -lt 20; $i++)
{ 
    $dropdown = New-Object System.Windows.Forms.ComboBox
    $dropdown.DropDownStyle = "DropDownList"
    $dropdown.Location = New-Object System.Drawing.Size (91,$y)
    $dropdown.Size = New-Object System.Drawing.Size (200,25)
    $dropdown.Visible = $false
    $dropdown.Text = "Veldu það sem á við"
    $dynamicdrop += $dropdown

     
    $y+=30
}
$ctrlstabpage3 += $dynamicdrop

#labels í tab3
$importcsvlbl = labelmaker -text "Byrjaðu hér" -location (9,5)
$importcsvlbl.TextAlign = "MiddleLeft"
$ctrlstabpage3 += $importcsvlbl

$checkboxlabel = labelmaker -text "Aukahjálp" -location (300,15)
$checkboxlabel.Visible = $false
$ctrlstabpage3 += $checkboxlabel

#dynamiclabels
$dynamiclabels = @()
$y = 60
for ($i = 1; $i -lt 20; $i++)
{ 
    $label = labelmaker -text " " -location (9,$y)
    $label.Visible = $false
    $label.TextAlign = "MiddleLeft"
    $dynamiclabels += $label
    $y += 30
    
}
$ctrlstabpage3 += $dynamiclabels 


#checkbox
$dynamiccbox = @()
$cboxsplitname = checkboxmaker -text "Skipta Nafni í fornafn og eftirnafn" -location (300,60)
$dynamiccbox += $cboxsplitname
$ctrlstabpage3 += $cboxsplitname 

$cboxchangepass = checkboxmaker -text "ChangePasswordatLogon = $true" -location (300,80)
$dynamiccbox += $cboxchangepass
$ctrlstabpage3 += $cboxchangepass 


$cboxdefaultpass = checkboxmaker -text "Setja lykilorðið pass.123" -location (300,100)
$dynamiccbox += $cboxdefaultpass
$ctrlstabpage3 += $cboxdefaultpass 

$cboxusername = checkboxmaker -text "Skapa notendanafn úr fullunafni og punkt" (300,120)
$cboxusername.add_Checkedchanged({
    if($cboxusername.Checked -eq $true)
    {
        $cboxusername2.Checked = $false 
    }
})
$dynamiccbox += $cboxusername
$ctrlstabpage3 += $cboxusername 

$cboxusername2 = checkboxmaker -text "Skapa notendanafn úr nafni og tölu" (300,140)
$cboxusername2.add_CheckedChanged({
       if($cboxusername2.Checked -eq $true)
    {
        $cboxusername.Checked = $false 
    }
         
})
$dynamiccbox += $cboxusername2
$ctrlstabpage3 += $cboxusername2 

$dropdownou = New-Object System.Windows.Forms.ComboBox
$dropdownou.Location = New-Object System.Drawing.Size (460,180)

$ctrlstabpage3 += $dropdownou
$dynamiccbox += $dropdownou

$oucheck = ""
$cbNotendurogsg = checkboxmaker -text "Búa til/setja í Notendur OU og Group" -location (300,160)
$cbNotendurogsg.Checked = $true
$oucheck = Get-ADOrganizationalUnit -Filter {name -like "Notendur"} -Properties name
$cbNotendurogsg.add_CheckedChanged({
if($cbNotendurogsg.Checked -eq $false)
{
    
    if($oucheck -eq $null)
    {
        villapopup -message "Ef þú ert með þetta óhakað fara notendur í default users"
    }
}

})
$dynamiccbox += $cbNotendurogsg
$ctrlstabpage3 += $cbNotendurogsg 


$cbNotenduricustomou = checkboxmaker -text "Búa til/setja í OU flokkað eftir:" -location (300,180)
$cbNotenduricustomou.Checked = $true
$cbNotenduricustomou.add_CheckedChanged({
    if($cbNotenduricustomou.Checked -eq $false)
    {
       $moppur.Checked = $false
       $Securitygroups.Checked = $false
       $prentarar.Checked = $false
    }
        

})
$dynamiccbox += $cbNotenduricustomou
$ctrlstabpage3 += $cbNotenduricustomou 

$moppur = checkboxmaker -text "Búa til möppur líka" -location (330,200)
$moppur.add_CheckedChanged({

    if($moppur.Checked -eq $true)
    {
        $browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $browser.Description = "Veldu hvar þú vilt búa til Möppurnar"
        $null = $browser.ShowDialog()
        $path = $browser.SelectedPath
        $path =  $path.ToString()
        $Script:path = $path
    
    }
})
$dynamiccbox += $moppur
$ctrlstabpage3 += $moppur 

$Securitygroups = checkboxmaker -text "Búa til/setja í Security groups líka" -location (330,220)
$dynamiccbox += $Securitygroups
$ctrlstabpage3 += $Securitygroups

$prentarar = checkboxmaker -text "Búa til prentara líka" -location (330,240)
$dynamiccbox += $prentarar
$ctrlstabpage3 += $prentarar  

foreach($box in $dynamiccbox)
{
    $box.visible = $false
}


#buttons í tab3

$creatusersbtn = buttonmaker -text "Keyra inn  Notendur" -location (300,300)
$creatusersbtn.size = New-Object System.Drawing.Size (200,25)
$ctrlstabpage3 += $creatusersbtn
$dynamiccbox += $creatusersbtn
$creatusersbtn.Visible = $False

$importcsvbtn = buttonmaker -text "Smelltu til að velja CSV skrá" -location (9,30)
$importcsvbtn.Size = New-Object System.Drawing.Size (200,25)
$importcsvbtn.add_Click({
    $csvpath = Get-FileName($initialDirectory)
    $csv = Import-Csv -Path $csvpath -Delimiter ',' -Encoding Default
    $Script:csv = $csv
    $csvheaders = $csv | Get-Member -MemberType NoteProperty
    if($csvheaders.count -le 1)
    {
        $csv = Import-Csv -Path $csvpath -Delimiter ';' -Encoding Default
        $Script:csv = $csv
        $csvheaders = $csv | Get-Member -MemberType NoteProperty
    }

function lineupheaders{
    foreach($label in $dynamiclabels)
    {
        $label.Text = " "
        $label.Visible = $false
    
    }
   

    $i = 0
    foreach($head in $csvheaders){
        $header = $head.Name + ":"
        $dynamiclabels[$i].Text = $header
        $dynamiclabels[$i].Visible = $true
        $i++
        $dropdownou.Items.Add($head.Name)

        
    }
}

function lineupdrowdowns{

foreach($drop in $dynamicdrop)
{

$drop.Visible = $false
$drop.Text = ""
$drop.SelectedIndex = -1
$drop.Items.Clear()
}

    $command = Get-Command -Name new-aduser | Select-Object -Property Parameters
    $commandkeys = $command.Parameters.Keys
    $parameters = @()
    $badword = @("Verbose","Credential","Debug","ErrorAction","WarningVariable","WarningAction","ErrorVariable","OutVariable","OutBuffer","PipelineVariable","Whatif","Confirm","AllowReversiblePasswordEncryption","Certificates","AuthType","TrustedForDelegation","SmartCardLogonRequired","KerberosEncryptionType","Instance","AuthenticationPolicySilo","AuthenticationPolicy","AccountNotDelegated")
    foreach ($key in $commandkeys)
    {
        if($key -notin $badword)
        {$parameters += $key}
    }
    $parameters += "Veldu það sem á við"
    $parameters += "Ekkert"
    $paramdefault = $parameters.IndexOf("Veldu það sem á við")
    $paramdeild = $parameters.IndexOf("Department")
    $paramtitle = $parameters.IndexOf("Title")
    $paramhphone = $parameters.IndexOf("HomePhone")
    $paramName = $parameters.IndexOf("Name")
    $paramfornafn = $parameters.IndexOf("GivenName")
    $paramsurname = $parameters.IndexOf("Surname")
    $paramstreetadd = $parameters.IndexOf("StreetAddress")
for ($i = 0; $i -lt $csvheaders.Count; $i++)
{

    foreach($param in $parameters)
    {
        $dynamicdrop[$i].Items.Add($param)
        
    }
    $dynamicdrop[$i].SelectedIndex = $paramdefault

   if($dynamiclabels[$i].Text -like "Deild:"){
        $dynamicdrop[$i].SelectedIndex = $paramdeild
        }
   if($dynamiclabels[$i].Text -like "Titill:"){
        $dynamicdrop[$i].SelectedIndex = $paramtitle
        }
   if($dynamiclabels[$i].Text -like "HeimaSími:"){
        $dynamicdrop[$i].SelectedIndex = $paramhphone
        }
   if($dynamiclabels[$i].Text -like "Nafn:"){
        $dynamicdrop[$i].SelectedIndex = $paramName
        }
   if($dynamiclabels[$i].Text -like "Fornafn:"){
        $dynamicdrop[$i].SelectedIndex = $paramfornafn
        }
   if($dynamiclabels[$i].Text -like "Eftirnafn:"){
        $dynamicdrop[$i].SelectedIndex = $paramsurname
        }
   if($dynamiclabels[$i].Text -like "Heimilisfang:"){
        $dynamicdrop[$i].SelectedIndex = $paramstreetadd
        }



    $dynamicdrop[$i].visible = $true
}

}

    lineupheaders
    lineupdrowdowns 

    $checkboxlabel.Visible = $True
    foreach($box in $dynamiccbox)
    {
        $box.visible = $true

    }
    $texts = @()
    foreach($text in $dynamicdrop) 
    {
        if($text.Text.Length -ne 0)
        {
            $texts += $text.Text
        }
    } 

    if($texts -contains "Surname" -or $texts -contains "GivenName")
    {
       $cboxsplitname.Checked = $false 
    }
    else {
        $cboxsplitname.Checked = $true 
    }

    if($texts -notcontains "AccountPassword")
    {
       $cboxchangepass.Checked = $true
       $cboxdefaultpass.Checked = $true
    }


     
})

$ctrlstabpage3 += $importcsvbtn

$creatusersbtn.add_Click({

write-host "skref1"
    $texts = @()
    $messages = @()
    $domain = get-addomain | Select-Object -Property name
    $domainname = $domain.Name
    foreach($text in $dynamicdrop) 
    {
        if($text.Text.Length -ne 0)
        {
            $texts += $text.Text
        }
    } 

    if($texts -contains "Veldu það sem á við")
    {
        Villapopup -message "Þú átt enn eftir að velja parameter fyrir reit"
    }
    if($dropdownou.Text.Length -eq 0)
    {
        villapopup -message "OU skipuleggjari má ekki vera tómur"
    }
    else {
    write-host "skref2"
    $path = $Script:path
    $createuserstring = "New-ADUser"
    $command = Get-Command -Name new-aduser | Select-Object -Property Parameters
    $commandkeys = $command.Parameters.Keys
    $parameters = @()
    $badword = @("Verbose","Credential","Debug","ErrorAction","WarningVariable","WarningAction","ErrorVariable","OutVariable","OutBuffer","PipelineVariable","Whatif","Confirm","AllowReversiblePasswordEncryption","Certificates","AuthType","TrustedForDelegation","SmartCardLogonRequired","KerberosEncryptionType","Instance","AuthenticationPolicySilo","AuthenticationPolicy","AccountNotDelegated")
    foreach ($key in $commandkeys)
    {
        if($key -notin $badword)
        {$parameters += $key}
    }
    $u = "$"
    $header = ""

    
    $checksg = ""
    

        if($cbNotendurogsg.Checked -eq $true)
        {
        
            if($oucheck -eq $null){

                New-ADOrganizationalUnit -Name Notendur -ProtectedFromAccidentalDeletion $false 
            }
            else
            {
                $messages += "Notendur OU var nú þegar til, bætt var bara við það"
            }

            if($Securitygroups.Checked -eq $true)
            {

                $checksg = Get-ADGroup -Filter {name -like "NotendurAllir"} -Properties name
                if($checksg -eq $null)
                {
                    New-ADGroup -Name NotendurAllir -Path "OU=Notendur,DC=$domainname,DC=local" -GroupScope Global 
                }
                else
                {
                    $messages += "NotendurAllir Security Group var nú þegar til, Notendum bætt í hann"
                }
            }

            if($moppur.checked -eq $True)
            {           
                if((test-path "$path\sameign") -eq $False)
                {
                    new-item "$path\Sameign" -ItemType Directory 
                    $rettindi = Get-Acl -Path "$path\Sameign"
                    $nyrettindi = New-Object System.Security.AccessControl.FileSystemAccessRule "$domainname\NotendurAllir",'Modify','Allow' 
                    $rettindi.AddAccessRule($nyrettindi)
                    Set-Acl -Path "$path\Sameign" $rettindi 
                    New-SmbShare -Name "Sameign" -Path "$path\Sameign" -FullAccess "$domainname\NotendurAllir", administrators -ErrorAction SilentlyContinue
                }
            }

            if($prentarar.checked -eq $True)
            {
                Add-PrinterDriver -Name "Brother Color Type3 Class Driver" -ErrorAction Ignore #setur inn driver fyrir prentarann ef allir eru að nota sama kemur það upp sem bara 1 prentari og þarf að hægri smella á hann til að fá hina upp, svo það er hægt að harðkóða aðra driveraa inn 
                Add-Printer -Name "Sameign prentari2" -Location "Sameign" -Shared -PortName LPT1: -Drivername "Brother Color Type3 Class Driver"-ErrorAction Ignore  -Published  #býr til sameigna prentarann og share-ar

            }

    write-host "skref3"
    }

   
    write-host "skref4"
    
    $userscript = $createuserstring
        $u = "$"
        $i = 1
    foreach($s in $Script:csv)
    {
    $i++
    write-host $i
        $createuserstring = $userscript

         write-host "skref4.5"
        foreach ($param in $parameters)
        {
          if($texts -contains $param)
          {
            $index = $texts.IndexOf($param)
            $header = $dynamiclabels[$index].Text
            $header = $header.Substring(0,$header.Length -1)
            $createuserstring += " -"+$param.ToString()+" '" +$($s.$header.ToString())+"' "
        
          }   
    }

       if($cbNotenduricustomou.Checked -eq $true)
        {
                $domainname = $domainname.ToString()
                $sorter = $dropdownou.Text
                $sorter = $s.$sorter
                $createuserstring += " -Path '"+ $("OU=$sorter,OU=Notendur,DC=$domainname,DC=local") + "'"
        }
 

        if($cboxsplitname.Checked -eq $true -and $cboxusername.checked -eq $True)
        {
            $name = $dynamiclabels[$texts.indexof("Name")].Text
            $name = $name.Substring(0,$name.Length -1)
            $name = $s.$name

            $split = nafnareglur $name
            $split
            $given = $split['fornafn:']
            $surname = $split['eftirnafn:']
            $samacc  = $split['username:']

            $createuserstring += " -GivenName '" + $given + "' -Surname '" + $surname+"' -DisplayName '"+ $name+ "' -SamAccountName '" + $samacc + "'"
            $createuserstring += " -UserPrincipalName '$samacc@$domainname.Local'"


        }

        if($cboxsplitname.Checked -eq $true -and $cboxusername.checked -eq $False)
        {
            $name = $dynamiclabels[$texts.indexof("Name")].Text
            $name = $name.Substring(0,$name.Length -1)
            $name = $s.$name

            $split = nafnareglur $name
            $given = $split['fornafn:']
            $surname = $split['eftirnafn:']
            $samacc  = $split['username:']

            $createuserstring += " -GivenName '" + $given + "' -Surname '" + $surname+"' -DisplayName '"+ $name+ "'"

        }

        if($cboxdefaultpass.Checked -eq $true)
        {
            $createuserstring += " -AccountPassword (ConvertTo-SecureString -AsPlainText 'pass.123' -Force) "
        }
        if($cboxusername2.Checked -eq $true)
        {
            $name = $dynamiclabels[$texts.indexof("Name")].Text
            $name = $name.Substring(0,$name.Length -1)
            $name = $s.$name
            $username = $name.split(" ")
            $username = replaceIsl $username[0]
            $username = "$username"+$i
            $createuserstring += " -SamAccountName $username "

        }
           $createuserstring += " -enabled "+$u+"true"

        write-host "skref5"

        

        if((Get-ADOrganizationalUnit -Filter { name -eq $sorter }).Name -ne $sorter)
        {
        New-ADOrganizationalUnit -Name $sorter -Path "OU=Notendur,DC=$domainname,DC=local" -ProtectedFromAccidentalDeletion $false
        New-ADGroup -Name $sorter -Path $("OU=" + $sorter + ",OU=Notendur,DC=$domainname,DC=local") -GroupScope Global
        Add-ADGroupMember -Identity NotendurAllir -Members $sorter

        #Bý til möppuna
        
        
        if((Test-path "$path\$sorter") -eq $false)
        {
        new-item "$path\$sorter" -ItemType Directory


 
        #sæki núverandi réttindi
        $rettindi = Get-Acl -Path "$path\$sorter"
 
        #bý til þau réttindi sem ég ætla að bæta við möppuna
        $nyrettindi = New-Object System.Security.AccessControl.FileSystemAccessRule $domainname\$sorter,"Modify","Allow"
        #Hver á að fá réttindin, hvaða réttindi á viðkomandi að fá, erum við að leyfa eða banna (allow eða deny)
 
        #bæti nýju réttindunum við þau sem ég sótti áðan
        $rettindi.AddAccessRule($nyrettindi)
 
        #Set réttindin aftur á möppuna
        Set-Acl -Path "$path\$sorter" $rettindi
 
        #Share-a möppunni
        New-SmbShare -Name $sorter -Path "$path\$sorter" -FullAccess "$domainname\$sorter", administrators

        }
        elseif((Test-path "$path\$sorter") -eq $true)
        {
            $messages += "Mappan fyrir $sorter var þegar til"
        }


        if((get-printer | Where-Object -Property name -eq $($sorter + "prentari")) -eq $null)
        {
        Add-Printer -Name $($sorter + " prentari") -Location $sorter -Shared -PortName LPT1: -ErrorAction SilentlyContinue -Drivername "Brother Color Type3 Class Driver" -Published 
        }
        else
        {
        $messages += "prentari fyrir $sorter var þegar til"
        }


       
        
    }
        
         if($cboxusername.Checked -eq $true)
         {
            $createuserstring += "`n Add-ADGroupMember -Identity $sorter -Members '" + $samacc +"'"
         }
         if($cboxusername2.checked -eq $true)
         {
            $createuserstring += "`n Add-ADGroupMember -Identity $sorter -Members '" + $username + "'"
         }
         if($cboxusername.Checked -eq $false -and $cboxusername2.checked -eq $false)
         {
            $samacc = $dynamiclabels[$texts.indexof("SamAccountName")].Text
            $samacc = $samacc.Substring(0,$samacc.Length -1)
            $samacc = $s.$samacc
            $createuserstring += "`n Add-ADGroupMember -Identity $sorter -Members '" + $samacc + "'"
         }
         
         write-host $createuserstring
          [Scriptblock]::Create($createuserstring).Invoke()
          }
 

     write-host "skref6.5"
    
    
    foreach ($message in $messages)
    {
     Write-Host $message   
    }
    write-host "skref7"
    }

})


foreach($item in $ctrlstabpage3){
$tabpage3.Controls.Add($item)
}
$tabpages += $tabpage3




#endregion tab3

#region tab4 
$tabpage4 = New-Object System.Windows.Forms.TabPage
$tabpage4.Text = "Notendastjórnun"
$tabpage4.add_Enter({
[System.GC]::Collect()
$mainform.ClientSize = New-Object System.Drawing.Size(800,500)
$tabcontrol.ClientSize = $mainform.ClientSize
})
$script:selecteduser = ""

#datagrid
$datagridnav = new-object System.Windows.Forms.DataGridView
$datagridnav.Location = New-Object System.Drawing.Size(10,20)
$datagridnav.Clientsize = New-Object System.Drawing.Size(340 ,200)
$datagridnav.ColumnCount = 3
$datagridnav.Columns[0].Name = "Nafn á OU"
$datagridnav.Columns[1].Name = "Undirmöppur"
$datagridnav.Columns[2].Name = "Fjöldi notenda"
$datagridnav.SelectionMode = "FullRowSelect"
$datagridnav.MultiSelect = $false
$ctrlstabpage4 += $datagridnav
function birtaou{
$datagridnav.rows.Clear()
$ous = Get-ADOrganizationalUnit -Filter * -Properties name, distinguishedname
$ous | % $_{if((Get-ADOrganizationalUnit -Filter * -SearchBase $_.distinguishedname).count -ge 0){
$count = (Get-ADOrganizationalUnit -Filter * -SearchBase $_.distinguishedname).count
if ($count.GetType() -ne [int])
{
$count = 0;
}
else
{
$count = [int]$count -1
}
$countuser = (Get-ADUser -Filter * -SearchBase $_.distinguishedname).count
if ($countuser.GetType() -ne [int])
{
$countuser = 0;
}
$row = @($_.Name, $count, $countuser)
$datagridnav.Rows.Add($row)
}}


}
birtaou
$datagridnav.add_CellMouseDoubleClick({
$selected = ""
$selected = $datagridnav.SelectedCells[0].Value
$datagridnav.rows.Clear()

Write-Host $selected
if((Get-ADOrganizationalUnit -Filter * -SearchScope Subtree  -Properties name | Where-Object -Property DistinguishedName -match $selected).count -ge 1)
{
$datagridnav.Columns[0].Name = "Nafn á OU"
$datagridnav.Columns[1].Name = "Undirmöppur"
$datagridnav.Columns[2].Name = "Fjöldi notenda"
$ous = Get-ADOrganizationalUnit -Filter * | Where-Object -Property DistinguishedName -match $selected
$ous | % {
$count = (Get-ADOrganizationalUnit -Filter * -SearchBase $_.distinguishedname).count
if ($count.GetType() -ne [int])
{
$count = 0;
}
else
{
$count = [int]$count -1
}
$countuser = (Get-ADUser -Filter * -SearchBase $_.distinguishedname).count
if ($countuser.GetType() -ne [int])
{
$countuser = 0;
}
$row = @($_.Name, $count, $countuser)
$datagridnav.Rows.Add($row)
}
}
else{
$datagridnav.Columns[0].Name = "Nafn"
$datagridnav.Columns[1].Name = "Titill"
$datagridnav.Columns[2].Name = "Notendanafn"
$users = Get-ADUser -Filter * -Properties name,title,samaccountname | Where-Object DistinguishedName -Match $selected
foreach ($u in $users)
{
    $row = @($u.Name, $u.Title, $u.SamAccountName)
    $datagridnav.Rows.Add($row)  
}

}

})


$datagridnav.add_SelectionChanged({
if($datagridnav.Columns[0].Name -eq "Nafn")
{
$script:selecteduser = $datagridnav.SelectedCells[2].Value
if ($script:selecteduser -ne $null)
{
$duplicates = @()
loaduser -name $script:selecteduser
}
Write-Host $script:selecteduser
}
})

#label
$labelsearch = labelmaker -text "Leitaðu af Notenda:" -location (0,230)
$labelsearch.Size = New-Object System.Drawing.Size(150,25)
$ctrlstabpage4 += $labelsearch

#textbox
$tbsearch = tbmaker -location (160,230) -size(140,25)
$ctrlstabpage4 += $tbsearch

$tbsearch.add_TextChanged({
if($tbsearch.Text.Length -ge 2)
{
$datagridnav.rows.Clear()
$datagridnav.Columns[0].Name = "Nafn"
$datagridnav.Columns[1].Name = "Titill"
$datagridnav.Columns[2].Name = "Notendanafn"
$users = Get-ADUser -Filter * -Properties name,title,samaccountname | Where-Object name -Match $tbsearch.Text
$complete = @()
   foreach($u in $users)
    {
    $row = @($u.Name, $u.Title, $u.SamAccountName)
    $datagridnav.Rows.Add($row)  
    }
}

})
$setusertb = @()
$setuserlb = @()
$setuser = get-command Set-ADUser 
$setuserparam = $setuser.Parameters.Keys
$parameters = @()
$badword = @("Verbose","Credential","Debug","ErrorAction","WarningVariable","WarningAction","ErrorVariable","OutVariable","OutBuffer","PipelineVariable","Whatif","Confirm","AllowReversiblePasswordEncryption","Certificates","AuthType","TrustedForDelegation","SmartCardLogonRequired","KerberosEncryptionType","Instance","AuthenticationPolicySilo","AuthenticationPolicy","AccountNotDelegated","Passthru","Remove","TrustedForDelegation","Replace","PrincipalsAllowedToDelegateToAccount","KerberosEncryptionType","Clear","Confirm","CompoundIdentitySupported","AccountExpirationDate","Add","CannotChangePassword","ChangePasswordAtLogon","PasswordNotRequired","PasswordNeverExpires","ServicePrincipalNames","LogonWorkstations","ScriptPath")
foreach ($key in $setuserparam)
{
  if($key -notin $badword)
  {$parameters += $key}
} 
$y = 10
$x = 360
for ($i = 0; $i -lt $parameters.Count; $i++)
{ 
  $tb = tbmaker -size (100,25) -location(($x + 100),$y)
  $setusertb += $tb
  $lb = labelmaker -text "" -location ($x,$y)
  $lb.TextAlign = "MiddleLeft"
  $setuserlb += $lb
  $y += 25
  if ($i -eq 17){
         $x = $x + 200
         $y = 10
     }
}
 
$i = 0
foreach($para in $parameters){
   
    $setuserlb[$i].Text = $para.ToString()
    $i++
    
}
    
function loaduser{
    param(
    [parameter(mandatory)]$name
    )
    $i = 0
    write-host $duplicates
    foreach($para in $parameters)
    {
        $result = Get-ADUser -Filter {samaccountname -like $name} -Properties * | Select-Object -Property $para
        if($result.$para.count -ne 1)
        {
            if($duplicates -contains $name)
            {
            $setusertb[$i].Text = $result[1].$para
            
            }
            else
            {
            $setusertb[$i].Text = $result[0].$para
            $duplicates += $name
            }
        }
        else
        {
            $setusertb[$i].Text = $result.$para
        }
    $i++
    }
}
 

    $ctrlstabpage4 += $setusertb
    $ctrlstabpage4 += $setuserlb
    





foreach($item in $ctrlstabpage4){
$tabpage4.Controls.Add($item)
}
$tabpages += $tabpage4

#endregion tab4

foreach($tab in $tabpages)
{
$tabcontrol.Controls.Add($tab)
}
#tooltips  
$tooltipcontrol = New-Object System.Windows.Forms.ToolTip 
$tooltipcontrol.SetToolTip($tab1tbnnetkort,"Breyttu Netkortsupplýsingum")
$tooltipcontrol.SetToolTip($tab1lbldomname,"Sláðu inn domain nafnið, .local er bætt við sjálfkrara")
$tooltipcontrol.SetToolTip($tab1btndomain,"Búa til domainið")
$tooltipcontrol.SetToolTip($tab2txtscopenafn,"Má vera hvað sem er")
$tooltipcontrol.SetToolTip($tab2txtscopestart,"t.d. 192.168.1.50")
$tooltipcontrol.SetToolTip($tab2txtscopeend,"t.d. 192.168.1.150")
$tooltipcontrol.SetToolTip($tab2txtsubmask,"t.d 255.255.255.0")
$tooltipcontrol.SetToolTip($tab2txtdns,"DNS fyrir scopeið'")
$tooltipcontrol.SetToolTip($tab2btndeletescope,"Eyðir völdu scopei")
$tooltipcontrol.SetToolTip($tab2txtadcpadd,"Sláðu inn nafn vélar")
$tooltipcontrol.SetToolTip($cboxusername,"dæmi: Jon.jonsson")
$tooltipcontrol.SetToolTip($cboxusername2,"dæmi: jon1")
$tooltipcontrol.SetToolTip($cboxchangepass,"Notandi breytir password við næsta logon")
$tooltipcontrol.SetToolTip($datagridnav,"Smellir til að velja, tvísmellir til að browse-a")


#Byrjum þetta
$mainform.controls.Add($tabcontrol)
$mainform.ShowDialog()
$mainform.add_Closed({$mainform.Close()})

