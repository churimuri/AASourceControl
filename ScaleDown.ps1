workflow ScaleDown
{
Function SetAzureVMSize{
     [CmdletBinding()]
     param(
         [parameter(Mandatory=$true)]
          [string]$ServiceName,
          [parameter(Mandatory=$false)]
          [ValidateNotNullOrEmpty()]
          [string]$Name,
          [parameter(Mandatory=$true)]
          [string]$VMSize
     )
     PROCESS{
             Get-AzureVM –ServiceName $ServiceName -Name $Name | 
             Set-AzureVMSize $VMSize | 
             Update-AzureVM
     }
}    

Function SetAzureRMVMSize{
     [CmdletBinding()]
     param(
         [parameter(Mandatory=$true)]
          [string]$ResourceGroupName,
          [parameter(Mandatory=$false)]
          [ValidateNotNullOrEmpty()]
          [string]$Name,
          [parameter(Mandatory=$true)]
          [string]$VMSize
     )
     PROCESS{
            # Shut down VM 
            # VM must be shut down before size change to switch between A/D/DS/Dv2/G/GS/N 
            # Stop-AzureRmVm -name $Name -ResourceGroupName $ResourceGroupName -StayProvisioned -Force 
            # Resize VM
            $vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $Name
            $vm.HardwareProfile.vmSize = $VMSize
            Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $VM
            # Start VM 
            Start-AzureRmVm -name $Name -ResourceGroupName $ResourceGroupName     }
}
    
$AutomationCredentialAssetName = "automation@joseconstantinooutlook.onmicrosoft.com"

# Get the credential asset with access to my Azure subscription
$Cred = Get-AutomationPSCredential -Name $AutomationCredentialAssetName

# Authenticate to Azure Service Management and Azure Resource Manager
"Authenticating...."
Add-AzureAccount -Credential $Cred 
Add-AzureRmAccount -Credential $Cred 
"`n--------------`n" 

# Get and scale down Azure classic VMs
"My classic VMs:"
$VMs = Get-AzureVM
foreach ($VM in $VMs)
{
    $VM.Name
    SetAzureVMSize –ServiceName $VM.ServiceName -Name $VM.Name –VMSize "Small"
    "`n--------------`n" 
}
"`n--------------`n"

# Get and scale down Azure v2 VMs
"My v2 VMs"
$VMsv2 = Get-AzureRmVM
foreach ($VMv2  in $VMsv2 )
{
    $VMv2.Name
    SetAzureRMVMSize –ResourceGroupName $VMv2.ResourceGroupName -Name $VMv2.Name –VMSize "Standard_A1"
    "`n--------------`n" 
}

}