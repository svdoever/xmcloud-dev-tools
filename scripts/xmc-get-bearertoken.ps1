# Get the bearer-token used for the XM Cloud API calls.
# Example of XM Cloud API where bearer token can be used: https://xmclouddeploy-api.sitecorecloud.io/swagger/index.html
# On the swagger page, click Authorize and enter the bearer token in the value field.
#
# Author: Serge van den Oever [Macaw]
# Version: 1.0
$VerbosePreference = 'SilentlyContinue' # change to Continue to see verbose output
$DebugPreference = 'SilentlyContinue' # change to Continue to see debug output
$ErrorActionPreference = 'Stop'

Push-Location -Path $PSScriptRoot\..
if (-not (Test-Path -Path .\tools\xmc-config.json)) {
    Write-Error "File .\tools\xmc-config.json does not exist"
}
$xmcloudConfig = Get-Content -Raw -Path .\tools\xmc-config.json | ConvertFrom-Json

$clientId = $xmcloudConfig.XMCloud_AutomationClient_ClientId
$clientSecret = $xmcloudConfig.XMCloud_AutomationClient_ClientSecret
if (-not ($clientId -and $clientSecret)) {
    Write-Verbose "XM Cloud organization client id and client secret not found in file .\tools\xmc-config.json."
}
curl --request POST --url "https://auth.sitecorecloud.io/oauth/token" --header "content-type: application/x-www-form-urlencoded" --data audience=https://api.sitecorecloud.io --data grant_type=client_credentials --data client_id=$clientId --data client_secret=$clientSecret