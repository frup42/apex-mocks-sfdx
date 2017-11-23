# apex-mocks-sfdx

This is a little project built on top of [Apex Mocks](https://github.com/financialforcedev/fflib-apex-mocks/).
It shows:
* A way of deploying Apex Mocks as part of an SFDX project.
* A few examples of using Apex Mocks in unit tests.

## Simple Deploy
[![Deploy](https://deploy-to-sfdx.com/dist/assets/images/DeployToSFDX.svg)](https://deploy-to-sfdx.com) 

## Manual deployment
This app is built and deployed via SFDX.

1. If you don't have a Dev Hub, sign up for a trial here:
	* Complete the form on the [sign up page](https://developer.salesforce.com/promotions/orgs/dx-signup)
	* Note. The org will expire in 30 days
1. If you don't have the SFDX CLI:
	* Download it [here](https://developer.salesforce.com/tools/sfdxcli)
	* Or install via brew
		```shell
		brew cask install caskroom/cask/sfdx
		```
1. Authenticate with your dev hub
	```shell
	sfdx force:auth:web:login -d
	```
	* Log into your dev hub when prompted, then close the browser.
1. Create a scratch org:
	```shell
	sfdx force:org:create -f config/project-scratch-def.json -s
	```
1. Push source to scratch org:
	```shell
	sfdx force:source:push
	```
1. Launch the scratch org in a browser:
	```shell
	sfdx force:org:open
	```
