#!/bin/bash

print_version() {
	echo "Version: 0.0.4"
}

print_keys() {
	# Print current keys
	echo ${cyan_text}
	echo "${standout_text}GPG SIGNING KEYS LIST${rm_standout_text}"
	gpg --list-secret-keys --keyid-format LONG
	echo ${reset_text}
}

refresh_keys() {
    # TODO: Refresh expired key (e.g. gpg --edit-key <key_id>)
    echo "Which key would you like to refresh?"
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
	KEY="$1"
	SET_GLOBAL="$2"
	echo "${standout_text}TELLING GIT ABOUT KEY${rm_standout_text}"
	if [ "$SET_GLOBAL" = "SET_GLOBAL" ]; then
		git config --global user.signingkey $KEY
	else
		echo "Enter the path to the repo: "
		read REPO_PATH
		CURRENT_PATH="$PWD"
		cd $REPO && git config user.signingkey $KEY
		cd $CURRENT_PATH
	fi
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
		case $key_option in
			"Set the key to sign globally")
				set_key $NEW_KEY "SET_GLOBAL"
				break
				;;
			"Set the key to sign for a single repo")
				set_key $NEW_KEY "SET_LOCAL"
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
	echo "📋 Paste the key id:"
	echo -n "> "
	read KEY_ID
}

update_git_configs() {
	while true
    do
	    PS3="What would you like to do? "
    	config_actions=("Set a Key Up for Signing with Git" "Set Git to Sign By Default" "Nothing")
		select config_action in "${config_actions[@]}"
		do
			case $config_action in
				"Set a Key Up for Signing with Git")
					prompt_for_key
					echo "Selcted Key: $KEY_ID"
					PS3="What would you like to do with this key? "
					key_actions=("Set the Key for Global Signing" "Set the Key for a Single Repo" "Select a Different Key" "Nothing")
					select key_action in "${key_actions[@]}"
					do
						case $key_action in
							"Set the Key for Global Signing")
								set_key $KEY_ID "SET_GLOBAL"
								break 2
								;;
							"Set the Key for a Single Repo")
								set_key $NEW_KEY "SET_LOCAL"
								break 2
								;;
							"Select a Different Key")
								prompt_for_key
								echo "Selcted Key: $KEY_ID"
								;;
							"Nothing")
								break 2
								;;
							*)
								echo "Invalid Option"
								;;
						esac
					done
					;;
				"Set Git to Sign By Default")
					while true; do
						echo "Sign by default? (Y/N): "
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
				"Nothing")
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
	echo "Deleted key(s): ${red_text}$OLD_KEYS${reset_text}"
	echo "New key: ${green_text}$NEW_KEY${reset_text}"
	echo "Sign commits by default: ${blue_text}${SIGN_BY_DEFAULT}${reset_text}"
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
actions=("List Keys" "Refresh keys" "Delete Keys" "Generate New Key" "Add Key to GitHub" "Update Git Configs" "Quit")

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
