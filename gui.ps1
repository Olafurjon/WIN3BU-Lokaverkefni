$form = New-Object System.Windows.Forms.Form
$form.StartPosition = "CenterScreen"
$form.ClientSize = New-Object System.Drawing.Size(1366,768)



$tabcontrol = New-Object System.Windows.Forms.TabControl
$tabcontrol.Location.X = -1
$tabcontrol.Location.Y = -0
$tabcontrol.Margin.All = 3
$tabcontrol.ClientSize = $form.ClientSize
$tabcontrol.Visible = $true

$tabpage1 = New-Object System.Windows.Forms.TabPage
$tabpage1.Text
$tabcontrol.Controls.Add($tabpage1)

$form.controls.Add($tabcontrol)
$form.ShowDialog()