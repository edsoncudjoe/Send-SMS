
function Send-SMS {
	<#
	.SYNOPSIS
		The Send-SMS command will send an SMS message to a given number using the AQL API.
		Further info can be found at https://aql.com

	.DESCRIPTION
		The Send-SMS command will receive mobile number and message as arguments.
		It will then send the message to the given user numbers.
        The AQL API requires an access token which can be obtained from their support.
        The API token can be saved as a Windows environment variable. 
		Create an environment variable called AQL and set its value to the token.
		
		To create an environment variable via PowerShell:
			[Environment]::SetEnvironmentVariable("AQL", "<Enter token value here>", "User")

		You will need to restart Powershell afterwards for it to take effect.

		Author: EdsonCudjoe

		MIT License

		Copyright (c) [2018] [Edson Cudjoe]

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
		
	.EXAMPLE
		Send-SMS -Number '44703123456' -Message 'Hello World'

		DESCRIPTION
		-----------
        This command will send the message 'abcabc' to the number '44703123456'
                
	.PARAMETER Number
		Specifies the mobile number which the SMS message will be sent to. Must include the international code.
        The UK is 44. So a typical UK number of 07987123456 will be 447987123456.
        Can receive multiple phone numbers separated by commas. 
	.PARAMETER Message
		Specifies the message to be sent to the users. This is a string of any length.
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=0, 
		HelpMessage="Enter one or more mobile numbers separated by commas.")]
        [String[]]$Number,
        [Parameter(Mandatory=$true, Position=1)]
		[String]$Message
	)

	process {
		Add-Type -Assembly System.Collections
		$url = 'https://api.aql.com/v2/sms/send'
		$token = Get-ChildItem env:AQL 
		$contentType = 'application/json'
		$headers = @{ 'X-AUTH-TOKEN' = $token.value }
		$mobNumbers = @()

		write-verbose "Sending SMS messages"

		foreach ($N in $Number) {
			Write-Verbose "Processing $N"
			$mobNumber += $N
			$payload = @{
				'destinations' = $mobNumber.Split(" ")
				'message' = "Hi {0}!,`r`n{1}`r`n" -f $name, $Message
			}
			$json = $payload | ConvertTo-Json
			Invoke-RestMethod -Uri $url -Method Post -Headers $headers -ContentType $contentType -Body $json
		}
	}
}
