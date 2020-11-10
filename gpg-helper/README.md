# GPG Helper: A GPG Signing Key Bot

A bash script automating GPG signing keys setup for Git commits based on [the GitHub docs](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/about-commit-signature-verification).

The script walks users through steps to generate new GPG signing keys, linking the new keys to their GitHub accounts, and updating local Git configs.

## Dependencies

- **[Git](https://git-scm.com/downloads)**
- **[GnuPG](https://www.gnupg.org/download/) command line tools**: CLI for GPG
- **[Node.js](https://nodejs.org/en/download/) (optional)**: for formatting

## Usage

1. Clone the repository.

```
git clone https://github.com/axw250/tools.git
```

2. Navigate to the GPG-Helper.

```
cd tools/gpg-helper
```

3. (Mac/Linux) You _might_ need to set executable permissions.

```
chmod +x gpg-helper.sh
```

4. Execute the script from the command line.

```
./gpg-helper.sh
```

### Windows Instructions

If you try to run from the Windows Command Prompt, you will be prompted to "open the program" in a bash application.

```
> C:\Users\...\tools\gpg-helper\gpg-helper.sh
```

It is recommended that you use [Git Bash](https://gitforwindows.org/). Alternatively, try [Ubuntu on WSL](https://ubuntu.com/wsl).

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
