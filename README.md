# homebrew-granted

Homebrew tap for [Granted](https://granted.dev/) — the easiest way to access your cloud.

## Installation

```sh
brew tap fwdcloudsec/granted
brew install granted
```

## Shell Configuration

After installing, configure your shell to use the `assume` alias:

### Bash

Add to `~/.bashrc` or `~/.bash_profile`:

```sh
alias assume="source $(brew --prefix)/bin/assume"
```

### Zsh

Add to `~/.zshrc`:

```sh
alias assume="source $(brew --prefix)/bin/assume"
```

### Fish

Add to `~/.config/fish/config.fish`:

```sh
alias assume="source $(brew --prefix)/bin/assume.fish"
```

### tcsh

Add to `~/.tcshrc`:

```sh
alias assume "source $(brew --prefix)/bin/assume.tcsh"
```

## Verify

```sh
granted --version
assumego --version
```
