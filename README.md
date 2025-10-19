# June's Doom Emacs Config

Yes, that.

## Prerequisites

At least, some of them:

```
brew install shellcheck direnv cmake

brew tap d12frosted/emacs-plus

# Edit to remove the with-native-comp build flag
brew edit emacs-plus@30

brew install emacs-plus@30 --with-c9rgreen-sonoma-icon
```

Set up elixir-ls:
- Get from [https://github.com/elixir-lsp/elixir-ls]
- Symlink the executable to `~/bin/elixir-ls`
