## What does it do

Bulk installs PKG and DMG files to Mac from a user defined selection of applications. 

## Setup

1) Open and edit 'mac_deploy.sh', change 'basedir' (2nd line) to the root directory of where the folders for all your installers are located
2) Open the 'packages.csv' and edit to add your own applications

Example
basedir: \\\\networkshare\installers (Extra double backslash for network share as escape characters)
packages.csv: CCleaner,ccleaner,run.pkg

Full path: \\networkshare\installers\ccleaner\run.pkg

## Run

Open terminal and run: sudo mac_deploy.sh

## LICENSE

GNU GPLv3