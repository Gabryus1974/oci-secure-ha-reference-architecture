param (
    [ValidateSet("app1", "app2")]
    [string]$Target = "app1"
)

$PrivateKey = "$HOME\.ssh\ssh-key-2026-10-05.key"
$PublicKey  = "$HOME\.ssh\ssh-key-2026-10-05.key.pub"
$LocalPort  = 2222

$BastionId = terraform output -raw bastion_id

if ($Target -eq "app1") {
    $TargetIp = terraform output -raw app1_private_ip
}
else {
    $TargetIp = terraform output -raw app2_private_ip
}

Write-Host "Target     : $Target"
Write-Host "Target IP  : $TargetIp"
Write-Host "Bastion ID : $BastionId"
Write-Host "Local port : $LocalPort"




Write-Host ""
Write-Host "Creating Bastion port-forwarding session..."

$SessionJson = oci bastion session create-port-forwarding `
    --bastion-id $BastionId `
    --target-private-ip $TargetIp `
    --target-port 22 `
    --ssh-public-key-file $PublicKey `
    --session-ttl 1800 `
    --display-name "$Target-ssh-session" | ConvertFrom-Json

$SessionId = $SessionJson.data.id

Write-Host "Session ID : $SessionId"
Write-Host "Waiting for session to become ACTIVE..."

do {
    Start-Sleep -Seconds 3

    $Session = oci bastion session get `
        --session-id $SessionId | ConvertFrom-Json

    $State = $Session.data.'lifecycle-state'
    Write-Host "State      : $State"

} while ($State -eq "CREATING")

if ($State -ne "ACTIVE") {
    throw "Bastion session did not become ACTIVE. Final state: $State"
}

Write-Host "Session ACTIVE."

Write-Host "Waiting for Bastion SSH session propagation..."
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "Opening tunnel:"
Write-Host "localhost:$LocalPort -> $TargetIp`:22"
Write-Host ""
Write-Host "Keep this window open. Press Ctrl+C to close the tunnel."
Write-Host ""


& ssh.exe `
    -i $PrivateKey `
    -N `
    -L "${LocalPort}:${TargetIp}:22" `
    -p 22 `
    "${SessionId}@host.bastion.eu-milan-1.oci.oraclecloud.com"