# Login into XM Cloud using the organization client id and client secret as configured
# in 'tools\xmc-config.json'. This login makes sure that the XM Cloud login 
# information as stored in '.sitecore\user.json' under the key 'endpoints.xmCloud' is
# updated with the organization client id and client secret, because these settings are 
# used by the 'dotnet sitecore cloud *' commands. There is also an environment specific
# section created in '.sitecore\user.json' under the key 'endpoints.<ENVIRONMENT>',
# because in the other sitecore CLI commands (not under 'dotnet sitecore xmcloud', e.g. 
# 'dotnet sitecore serialization') we can specify a '--environment-name' to select the
# configuration section needed to connect to the correct environment.
# This script utilizes the combined information of `.sitecore\user.json` configuration
# which is created during a `dotnet sitecore cloud login` (contains the required 
# authority URL and audience URL) and the configuration file `tools\xmc-config.json`
# which contains the organization client id and client secret for non-interactive 
# organization level admin access.
#
# Author: Serge van den Oever [Macaw]
# Version: 1.0
param (
    [Parameter(Mandatory=$true)][string]$environment
)

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

# Login into XM Cloud using the organization client id and client secret as configured
# Note that login has no --json flag available, check error code results
dotnet sitecore cloud login --client-id $clientId --client-secret $clientSecret --client-credentials
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to login to XM Cloud using client id and client secret."
}

if (-not (Test-Path -Path .\.sitecore\user.json)) {
    Write-Error "File .sitecore\user.json does not exist. Should have beed created by 'dotnet sitecore cloud login' command."
}

$user = Get-Content -Raw -Path .\.sitecore\user.json | ConvertFrom-Json

if (-not $user.endpoints.xmCloud) {
    Write-Error "XM Cloud login information not found in file .sitecore\user.json. Should have beed created by 'dotnet sitecore cloud login' command."
}

Write-Host "Login for environment: $environment"
if (-not ($xmcloudConfig.XMCloud_Environments -and $xmcloudConfig.XMCloud_Environments.$environment)) {
    Write-Error "Environment '$environment' not found in file .\tools\xmc-config.json. See .\tools\xmc-config.md for an example of the required format."
}

$environmentInfo = $xmcloudConfig.XMCloud_Environments.$environment
if (-not ($environmentInfo.id -and $environmentInfo.cm)) {
    Write-Error "Environment '$environment' missing field 'id' or 'cm' in file .\tools\xmc-config.json. See .\tools\xmc-config.md for an example of the required format."
}

# Use the authority, audience urls from the user.json file to do a login in the context of the cm server
$authorityUrl = $user.endpoints.xmCloud.authority
$audienceUrl = $user.endpoints.xmCloud.audience
$cmUrl = $environmentInfo.cm

try {
    Invoke-WebRequest "$cmUrl/sitecore" -Method Head | Out-Null
} catch {
    Write-Error "The XM Cloud CM URL $cmUrl does not responded with a 200 status code. Check your configuration for environment '$environment' in '.\tools\xmc-config'."
}

# Do a login. Login information is saved, make sure it is not saved in the "default" environment-name, use the $environment as environment-name  
# Note that login has no --json flag available, check error code results
dotnet sitecore login --environment-name $environment --authority $authorityUrl --cm $cmUrl --audience $audienceUrl --client-credentials true --client-id $clientId --client-secret $clientSecret --allow-write true
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to login to XM Cloud using client id and client secret."
}
Write-Host "See the file .sitecore\user.json for the login information."
Pop-Location