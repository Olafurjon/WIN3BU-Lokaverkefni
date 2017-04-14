

#býr til label með staðsettum texta og staðsetningu
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

#region netkortsform
$Script:netselectedindex = 0
function netformtextupdate{
    $Script:netselectedindex = $combo.SelectedIndex
    $info = $Script:selectednetkort[$combo.SelectedIndex]
    $prefix = Get-NetIPAddress | Where-Object interfaceIndex -EQ $info.InterfaceIndex | Select-Object PrefixLength

    $netformIAinfo.Text = $info.InterfaceAlias
    $netformIP4info.Text = $info.IPv4Address
    if($info.IPv6Address.Count -eq 0){
        $netformIP6info.Text =  "Not Connected"
        $netformPrefinfo.Text = $prefix[1].PrefixLength
    }
    else{
        $netformIP6info.Text = $info.IPv6Address
        $netformPrefinfo.Text = $prefix[0].PrefixLength
    }
    if($info.DNSServer[0].ServerAddresses.Count -eq 0){
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
    New-NetIPAddress -InterfaceAlias $nyjanetkort -IPAddress $ipaddress -PrefixLength $prefix -ErrorAction - #-DefaultGateway 192.168.1.1 notum ekki default gateway en hægt að kommenta þetta aftur inn ef þess þarf
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
$combo.Items.Clear()
$allnets = Get-NetIPConfiguration -Detailed
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

#Comboboxið fyrir netform heldur yfir öll local og virtual netkort
$combo = New-Object System.Windows.Forms.ComboBox
$combo.Size = New-Object System.Drawing.Size(190,25)
$combo.DropDownStyle = "DropDownList"
$allnets = Get-NetIPConfiguration -Detailed
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
Write-Host $Script:selectednetkort[$combo.SelectedIndex].InterfaceAlias
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


#region byrjun
$ctrlsmainform = @()

$tabpages = @()
$ctrlstabpage1 = @()
$ctrlstabpage2 = @()


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





#þegar ein hurð lokast opnast önnur...
$tab1tbnnetkort = buttonmaker -text "Opna Netkort" -location (9,50)
$tab1tbnnetkort.Size =  New-Object System.Drawing.Size(120,25)
$tab1tbnnetkort.Add_Click({$mainform.Hide()
$netform.ShowDialog()
})
$ctrlstabpage1 += $tab1tbnnetkort
#endregion

#tooltips
$tooltipcontrol = New-Object System.Windows.Forms.ToolTip 
$tooltipcontrol.SetToolTip($tab1tbnnetkort,"Breyttu Netkortsupplýsingum")
$tooltipcontrol.SetToolTip($tab1lbldomname,"Sláðu inn domain nafnið, .local er bætt við sjálfkrara")
$tooltipcontrol.SetToolTip($tab1btndomain,"Búa til domainið")
$tooltipcontrol.SetToolTip($tab2txtscopenafn,"Má vera hvað sem ver")
$tooltipcontrol.SetToolTip($tab2txtscopestart,"t.d. 192.168.1.50")
$tooltipcontrol.SetToolTip($tab2txtscopeend,"t.d. 192.168.1.150")
$tooltipcontrol.SetToolTip($tab2txtsubmask,"t.d 255.255.255.2")
$tooltipcontrol.SetToolTip($tab2txtdns,"Hver á að vera 'routerinn'")


#region tab1
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
    $domainlocal = $domain+$local
    $pass = $tab1safeadminpass.Text
   
    $a = New-Object -ComObject Wscript.Shell
    $svar = $a.popup("Búa til domainið $domainlocal ?",0,"Staðfesta",4)}

    if($svar -eq 6){
        $error.Clear()
        try {

            Install-WindowsFeature -Name AD-Domain-Services –IncludeManagementTools
            Install-ADDSForest –DomainName $domainlocal –InstallDNS -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "$pass" -Force) 
            }
        catch {$error, "Vandamál kom upp" }
            if (!$error) {
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Aðgerð Tókst, Vél mun endurræsa sig",0,"Okei",0x1)

            }
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

#tabpage2 - Seinni tabinn í ævintýrinu
$tabpage2 = New-Object System.Windows.Forms.TabPage
$tabpage2.Text = "Búa til DHCP Scope"
$tabpage2.add_Enter({$mainform.ClientSize = New-Object System.Drawing.Size(230,500)
$tabcontrol.ClientSize = $mainform.ClientSize
})


#label í tab 2
$texttalign = "MiddleCenter"
$tab2lblscopenafn = labelmaker -text "Nafn á DHCP Scopei" -location (9,20)
$tab2lblscopenafn.Size = New-Object System.Drawing.Size(200,20)
$tab2lblscopenafn.TextAlign = $texttalign
$ctrlstabpage2 += $tab2lblscopenafn

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

#button í tab 2
$tab2btnscope = buttonmaker -text "Staðfesta" -location (9,400)
$ctrlstabpage2 += $tab2btnscope




#region tab2


foreach($item in $ctrlstabpage2){
$tabpage2.Controls.Add($item)
}
$tabpages += $tabpage2

foreach($tab in $tabpages)
{
$tabcontrol.Controls.Add($tab)
}
#endregion tab2


#Byrjum þetta
$mainform.controls.Add($tabcontrol)
$mainform.ShowDialog()
$mainform.add_Closed({$mainform.Close()})
