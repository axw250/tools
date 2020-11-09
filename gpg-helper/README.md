# GPG Helper: A GPG Signing Key Bot

Bash script automating GPG signing keys setup for Git commits based on [the GitHub docs](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/about-commit-signature-verification).

The script walks users through steps to generate new GPG signing keys, linking the new keys to their GitHub accounts, and updating local Git configs.

## Usage

You _might_ need to set executable permissions.

```
chmod +x gpg-helper.sh
```

Execute the script from the command line.

```
./gpg-helper.sh
```

## Features

| Feature                 | Progress |
| ----------------------- | -------- |
| List current key(s)     | Done     |
| Refresh expired key(s)  | To-do    |
| Delete local key(s)     | Done     |
| Generate new key        | Done     |
| Capture new key         | Done     |
| Add key(s) to GitHub    | Done     |
| Add key to Git (global) | Done     |
| Add key to Git (local)  | To-do    |
