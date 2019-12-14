# Cloudflare dns record updater

This script was created to update an A record via ClodFlare API

## Usage:

1. Clone this repo
2. Provide the necessary  information to access your account on file "cloudflare_config"
3. Give execute permissions to file "update_cloudflare_record" with the comand "chmod +x <filename>" 

## Adding to crontab

If you what this action to be preformed automatecly when your Ip changes add the follwing line to your crontab:

`*/30 * * * *    <path_to_your_script>update_cloudflare_record.sh >/dev/null 2>&1`

In this case, the script will check every 30 minutes if there are IP changes.

_Feel free to contibute to this project by submiting a PR_

### TODO
Exetend this project to all CloudFlare records