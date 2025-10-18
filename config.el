;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Iosevka Term" :size 14 :weight 'semi-light)
     doom-variable-pitch-font (font-spec :family "Helvetica" :size 14))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

(setq catppuccin-flavor 'macchiato) ;; Options: 'frappe, 'latte, 'macchiato, or 'mocha
(setq doom-theme 'catppuccin)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; -- Window frame positioning
(setq initial-frame-alist
      '((top . 50) (left . 50)
        (width . 140) (height . 50)))


;; -- eglot
;; (after! eglot
;;   (add-to-list 'eglot-server-programs
;;                '(elixir-mode "~/bin/elixir_language_server.sh")))


;; -- tree sitter
(setq treesit-language-source-alist
      '((elixir "https://github.com/elixir-lang/tree-sitter-elixir")
        (heex "https://github.com/phoenixframework/tree-sitter-heex")))

;; -- install treesitter grammars if not present
(dolist (lang '(elixir heex))
  (unless (treesit-language-available-p lang)
    (treesit-install-language-grammar lang)))

;; -- heex treesitter
(use-package! heex-ts-mode
  :mode "\\.heex\\'")

;; -- polymode
(use-package! polymode
  :config
  (define-hostmode poly-elixir-hostmode
    :mode 'elixir-mode)

  (define-innermode poly-heex-innermode
    :mode 'heex-ts-mode
    :head-matcher "~H\"\"\""
    :tail-matcher "\"\"\""
    :head-mode 'host
    :tail-mode 'host
    :fallback-mode 'host)

  (define-polymode poly-elixir-mode
    :hostmode 'poly-elixir-hostmode
    :innermodes '(poly-heex-innermode))

  ;; Keep LSP active across mode switches
  (setq polymode-move-these-vars-from-old-buffer
        (append polymode-move-these-vars-from-old-buffer
                '(lsp--buffer-workspaces
                  lsp--buffer-deferred)))

  (add-hook 'elixir-mode-hook #'poly-elixir-mode))

;; -- lsp
(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '(heex-ts-mode . "phoenix-heex"))
  (add-to-list 'lsp-language-id-configuration '(heex-mode . "phoenix-heex"))

  ;; LSP in heex mode
  ;(add-hook 'heex-ts-mode-hook #'lsp!)

  ;; Configure next-ls (brew install elixir-tools/tap/next-ls)
  ; (lsp-register-client
  ;  (make-lsp-client
  ;   :new-connection (lsp-stdio-connection '("nextls" "--stdio"))
  ;   :activation-fn (lsp-activate-on "elixir" "phoenix-heex")
  ;   :multi-root t
  ;   :server-id 'next-ls))

  ;; Prefer next-ls for Elixir
  ; (setq lsp-elixir-server-command '("nextls" "--stdio"))

  ;; Optional: configure LSP for embedded regions
  ;(setq lsp-elixir-suggest-specs nil) ; reduce noise
  )
