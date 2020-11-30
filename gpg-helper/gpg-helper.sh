#!/bin/bash

print_version() {
	echo "Version: 0.0.5"
}

print_keys() {
	# Print current keys
	echo ${cyan_text}
	echo "${standout_text}GPG SIGNING KEYS LIST${rm_standout_text}"
	#? should we print BOTH public and secret keys? should we give users the choice?
	gpg --list-secret-keys --keyid-format LONG
	echo ${reset_text}
}

refresh_keys() {
	print_keys

	echo
	echo "${standout_text}REFRESH KEY EXPIRY${rm_standout_text}"
	echo "Copy secret key ID(s) from the list above."
	print_example_keyid

	echo "📋 Paste all key ids you would like to refresh (separated by spaces):"
	echo -n "> "
	read KEYS_TO_REFRESH

	for key in $KEYS_TO_REFRESH; do
		echo -n "❓ Would you like to refresh ${green_text}$key${reset_text}? (y/N) "
		while true; do
			read REFRESH
			case $REFRESH in
			[yY]*)
				echo ${cyan_text}
				echo "${standout_text}GPG EDIT KEY EXPIRY DIALOG${rm_standout_text}"
				echo ${yellow_text}${bold_text}
				echo "Recipe:"
				echo "> 90 (days)"
				echo "> Yes"
				echo "> Save"
				echo ${reset_text}
				
				echo ${cyan_text}
				gpg --edit-key $key expire
				echo ${reset_text}
				# TODO: read exit code (i.e. case $1 in... esac) to handle deletion completion message (i.e. deletion successful vs aborted)
				break
				;;
			[nN]*)
				echo "Not refreshing key expiry"
				break
				;;
			*)
				echo "Invalid input"
				;;
			esac
		done
	done
}

print_example_keyid() {
    echo ${yellow_text}${bold_text}
	echo "Example:"
	echo ">  /path/to/user/.gnupg/pubring.kbx"
	echo ">  ----------------------------------"
	echo ">  sec   ed25519/${standout_text}718AB54112A480E4${rm_standout_text} 2020-11-06 [SC] [expires: 2021-02-04]"
	echo ">        F1AC32932E69628FA90CB395718AB54112A480E4"
	echo ">  uid                 [ultimate] First Last <your.email@address.com>"
	echo ">  ssb   cv25519/CB52639C9C0155FB 2020-11-06 [E] [expires: 2021-02-04]"
	echo ${reset_text}
}

delete_keys() {
	print_keys

	# Delete current key(s)
	echo
	echo "${standout_text}DELETE OLD KEYS${rm_standout_text}"
	echo "Copy secret key ID(s) from the list above."
	print_example_keyid

	echo "📋 Paste all key ids you would like to delete (separated by spaces):"
	echo -n "> "
	read OLD_KEYS

	for key in $OLD_KEYS; do
		echo -n "❓ Would you like to delete ${red_text}$key${reset_text}? (y/N) "
		while true; do
			read DELETE
			case $DELETE in
			[yY]*)
				echo ${cyan_text}
				echo "${standout_text}GPG KEY DELETION DIALOG${rm_standout_text}"
				gpg --delete-secret-keys $key
				gpg --delete-keys $key
				echo ${reset_text}
				# TODO: read exit code (i.e. case $1 in... esac) to handle deletion completion message (i.e. deletion successful vs aborted)
				break
				;;
			[nN]*)
				echo "Not deleting key"
				break
				;;
			*)
				echo "Invalid input"
				;;
			esac
		done
	done
}

generate_new_key() {
	# Generate a new key
	echo
	echo -n "❔ Would you like to generate a new key? (y/N) "
	while true; do
		read GENERATE_NEW_KEY
		case $GENERATE_NEW_KEY in
		[yY]*)
			echo ${cyan_text}
			echo "${standout_text}GENERATE A NEW KEY${rm_standout_text}"
			echo ${yellow_text}${bold_text}
			echo "Recipe:"
			echo "> (9) ECC and ECC"
			echo "> (1) Curve 25519"
			echo "> 90 (days)"
			echo "> Yes"
			echo "> Your Name"
			echo "> your.email@address.com"
			echo "> (optional)"
			echo "> (O)kay"
			echo ${reset_text}

			echo ${cyan_text}
			gpg --full-generate-key --expert
			echo ${reset_text}
			break
			;;
		[nN]*)
			echo "Not generating new key."
			break
			;;
		*)
			echo "Invalid input"
			;;
		esac
	done
}

set_key() {
	# TODO: error handling (i.e. if path does not contain a Git repo)
	# TODO: instructions for path (e.g. no path => current repo)
	KEY="$1"
	SET_GLOBAL="$2"
	if [ "$SET_GLOBAL" = "SET_GLOBAL" ]; then
		git config --global user.signingkey $KEY
	else
		echo "Enter the path to the repo: "
		read REPO_PATH
		CURRENT_PATH="$PWD"
		cd $REPO_PATH && git config user.signingkey $KEY
		cd $CURRENT_PATH
		if [ -z "$REPO_KEYS" ]; then	
			REPO_KEYS="${REPO_PATH}: ${KEY}"
		else
			printf -v spaces ' %.0s' {1..22}
			REPO_KEYS="${REPO_KEYS}"$'\n'"${spaces}${REPO_PATH}: ${KEY}"
		fi
	fi
	echo "${standout_text}TELLING GIT ABOUT KEY${rm_standout_text}"
}

add_key_to_github() {
	print_keys

	echo "${standout_text}CAPTURE NEW GPG KEY${rm_standout_text}"
	echo "Copy the new secret key's ID from the updated list above."
	print_example_keyid

	echo "📋 Paste the new key id:"
	echo -n "> "
	read NEW_KEY
	echo "new key: $NEW_KEY"


	# Add key to your GitHub account
	echo ${cyan_text}
	echo "${standout_text}ASCII ARMOURED FORMAT${rm_standout_text}"
	gpg --armor --export $NEW_KEY
	echo ${reset_text}

	echo "${standout_text}ADD KEY TO YOUR GITHUB ACCOUNT${rm_standout_text}"
	echo "🌐 Navigate to http://github.com/settings/keys"
	# echo "❌ Delete expired GPG key(s)" # OLD KEY DELETION NOT RECOMMENDED
	echo "👆 Create new GPG key"
	echo "📋 Paste above's ASCII armor key"

	echo
	PS3="What would you like to do with this key?"
	key_options=("Set the key to sign globally" "Set the key to sign for a single repo" "Nothing")
	select key_option in "${key_options[@]}"
	do
		echo
		case $key_option in
			"Set the key to sign globally")
				set_key $NEW_KEY "SET_GLOBAL"
				echo "Successfully set ${green_text}$KEY_ID${reset_text} as global signing key"
				break
				;;
			"Set the key to sign for a single repo")
				set_key $NEW_KEY "SET_LOCAL"
				echo "Successfully set ${green_text}$KEY_ID${reset_text} as local signing key"
				break
				;;
			"Nothing")
				break
				;;
		esac
	done
	echo "To set this key up for signing, select option \"(6) Update Git Configs\" in the menu"
}

prompt_for_key() {
	print_keys
	echo "Copy the secret key ID from the list above."
	print_example_keyid
	while true; do
		echo "📋 Paste the key id:"
		echo -n "> "
		read KEY_ID
		# TODO: exception for "" (i.e. if user wants to exit)
		if [[ $KEY_ID =~ ^[[:xdigit:]]+$ ]]; then
			break
		else
			echo "Invalid key \"$KEY_ID\", key should be a hexidecimal number."
		fi
	done
}

update_git_configs() {
	config_actions=("Set a Key for Global Signing (All Repos)"
				"Set a Key for Local Signing (Single Repo)"
				"Set Git to Sign By Default"
				"Go Back")
	while true
    do
		echo
		select config_action in "${config_actions[@]}"
		do
			case $config_action in
				"Set a Key for Global Signing (All Repos)")
					prompt_for_key
					echo "Selected Key: ${yellow_text}$KEY_ID${reset_text}"
					while true; do
						echo -n "Are you sure you want to use this key? (y/N) " 
						read yn
						case $yn in
							[yY]*)
								set_key $KEY_ID "SET_GLOBAL"
								echo "Successfully set ${green_text}$KEY_ID${reset_text} as global signing key"
								break 2
								;;
							[nN]*)
								echo "Set global signing key aborted."
								break 2
								;;
						esac
					done
					;;
				"Set a Key for Local Signing (Single Repo)")
					prompt_for_key
					echo "Selected Key: ${yellow_text}$KEY_ID${reset_text}"
					while true; do
						echo -n "Are you sure you want to use this key? (y/N) " 
						read yn
						case $yn in
							[yY]*)
								set_key $KEY_ID "SET_LOCAL"
								echo "Successfully set ${green_text}$KEY_ID${reset_text} as local signing key"
								break 2
								;;
							[nN]*)
								echo "Set local signing key aborted."
								break 2
								;;
						esac
					done
					;;
				"Set Git to Sign By Default")
					while true; do
						echo -n "Sign by default? (y/N) "
						read SIGN_BY_DEFAULT
						case $SIGN_BY_DEFAULT in
						[yY]*)
							echo ${green_text}
							git config --global commit.gpgsign true
							echo ${reset_text}
							echo "All commits will be signed by defult."
							echo ${yellow_text}${bold_text}
							echo "To disable, run"
							echo "$ git config --global commit.gpgsign true"
							echo ${reset_text}
							break 2
							;;
						[nN]*)
							echo "Commits will not be signed by defult."
							echo ${yellow_text}${bold_text}
							echo "Sign commits with:"
							echo ">  git commit -S -m \"Your commit message\""
							echo "Enable default commit signing with:"
							echo ">  git config --global commit.gpgsign true"
							echo ${reset_text}
							break 2
							;;
						*)
							echo "Invalid input"
							;;
						esac
					done
					;;
				"Go Back")
					break 2
					;;
				*)
					echo "Invalid Option"
					;;
			esac
		done
    done
}

print_summary() {
	# Summary
	echo
	echo "${standout_text}SUMMARY${rm_standout_text}"
	[ ! -z "$NEW_KEY" ] && echo "New key: ${green_text}$NEW_KEY${reset_text}"
	[ ! -z "$KEYS_TO_REFRESH" ] && echo "Refreshed key(s) ${yellow_text}$KEYS_TO_REFRESH${reset_text}"
	[ ! -z "$OLD_KEYS" ] && echo "Deleted key(s): ${red_text}$OLD_KEYS${reset_text}"
	GLOBAL_SIGNING_KEY=$(git config --get user.signingkey)
	[ ! -z "$GLOBAL_SIGNING_KEY" ] && echo "Global Signing Key: ${yellow_text}${GLOBAL_SIGNING_KEY}${reset_text}"
	[ ! -z "$REPO_KEYS" ] && echo "Repo-Specific Key(s): ${orange_text}${REPO_KEYS}${reset_text}"
	SIGN_BY_DEFAULT=$(git config --get commit.gpgsign)
	[ ! -z "$SIGN_BY_DEFAULT" ] && echo "Sign commits by default: ${blue_text}${SIGN_BY_DEFAULT}${reset_text}"
}

#####################################################################
# Start of main program 

# Print banner
echo "
  ________  _____________  __.__________ 
 /  _____/ /   _____/    |/ _|\______   \\
/   \  ___ \_____  \|      <   |    |  _/
\    \_\  \/        \    |  \  |    |   \\
 \______  /_______  /____|__ \ |______  /
        \/        \/        \/        \/ 
"

echo "GPG Signing Key Bot"
echo "Automates setup of GPG signing keys for Git commits based on:"
echo "https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/about-commit-signature-verification"
print_version
echo "🧠 Loading..."

# Import global styles
echo "🎨 Importing styles..."
source ./bash_styles.sh
echo "✅ Ready"

echo
echo "${standout_text}LEGEND${rm_standout_text}"
echo "GSKB main output"
echo "${yellow_text}${bold_text}Example output${reset_text}"
echo "${cyan_text}GPG output${reset_text}"

# TODO: read user input for what actions to take
#       (1) Generate new key(s)
#       (2) Refresh expired key(s)
#       (3) Delete existing key(s)
#       (4) Update Git signingkey defaults (global and repo-specific)
#       (5) Review current key(s) and configsprint_keys

PS3="What would you like to do? "
actions=("List Keys" "Refresh Keys" "Delete Keys" "Generate New Key" "Add Key to GitHub" "Update Git Configs" "Quit")

# While loop needed to force re-display of entire menu
while true
do
	echo
	select action in "${actions[@]}"
	do
		case $action in
			"List Keys")
				print_keys
				break
				;;
            "Refresh Keys")
                refresh_keys
                break
                ;;
			"Delete Keys")
				delete_keys
				break
				;;
			"Generate New Key")
				generate_new_key
				break
				;;
			"Add Key to GitHub")
				add_key_to_github
				break
				;;
			"Update Git Configs")
				update_git_configs
				break
				;;
			"Quit")
				print_summary
				exit
				;;
			*) echo "Invalid option $REPLY";;
		esac
	done
done
