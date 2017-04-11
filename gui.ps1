Set-ExecutionPolicy -ExecutionPolicy Unrestricted

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


#region byrjun
$ctrlsmainform = @()
$netform = @()
$tabpages = @()
$ctrlstabpage1 = @()
$ctrlstabpage2 = @()


#Mainform - þetta er aðalformið sem opnast
$mainform = New-Object System.Windows.Forms.Form
$mainform.StartPosition = "CenterScreen"
$mainform.ClientSize = New-Object System.Drawing.Size(1366,768)

#netform - Þetta er formið sem opnast þegar þú ert promptaður um að breyta netkorti
$netform = New-Object System.Windows.Forms.Form
$netform.StartPosition = "CenterScreen"
$netform.ClientSize = New-Object System.Drawing.Size(800,800)
$netform.add_Closed({$mainform.Show()})

#Comboboxið fyrir netform heldur yfir öll local og virtual netkort
$combo = New-Object System.Windows.Forms.ComboBox
$combo.Size = New-Object System.Drawing.Size(150,25)
$net = Get-NetIPAddress

foreach($n in $net){
    if($n.InterfaceAlias -like "*Loopback Pseudo-Interface*") {
    $net.Dispose($n)
    }
    else{
        $combo.Items.Add($n.InterfaceAlias)
    }
}
$combo.Sorted = $true
$combo.SelectedIndex = 0
$netform.Controls.Add($combo) 




#Tabcontrol - Unitið sem meðhondlar stjórnunina á tabs, læt það vera jafnstórt og mainformið
$tabcontrol = New-Object System.Windows.Forms.TabControl
$tabcontrol.Location.X = -1
$tabcontrol.Location.Y = -0
$tabcontrol.Margin.All = 3
$tabcontrol.ClientSize = $mainform.ClientSize
$tabcontrol.Visible = $true
$ctrlsmainform += $tabcontrol

#endregion




#þegar ein hurð lokast opnast önnur...
$tab1tbnnetkort = buttonmaker -text "Opna Netkort" -location (9,50)
$tab1tbnnetkort.Size =  New-Object System.Drawing.Size(120,25)
$tab1tbnnetkort.Add_Click({$mainform.Hide()
$netform.ShowDialog()
})
$ctrlstabpage1 += $tab1tbnnetkort



#Labelar í tab1
$tab1lblnetkort = Labelmaker -text "Breyta Netkortum" -location (9,27)
$ctrlstabpage1 += $tab1lblnetkort

#tabpage1 - Fyrsti tabinn í forminu
$tabpage1 = New-Object System.Windows.Forms.TabPage
$tabpage1.Text = "Uppsetning"
foreach($item in $ctrlstabpage1){
$tabpage1.Controls.Add($item)
}
$tabpages += $tabpage1

#tabpage2 - Seinni tabinn í ævintýrinu
$tabpage2 = New-Object System.Windows.Forms.TabPage
$tabpage2.Text = "TBA"
foreach($item in $ctrlstabpage2){
$tabpage2.Controls.Add($item)
}
$tabpages += $tabpage2

foreach($tab in $tabpages)
{
$tabcontrol.Controls.Add($tab)
}



#Byrjum þetta
$mainform.controls.Add($tabcontrol)
$mainform.ShowDialog()