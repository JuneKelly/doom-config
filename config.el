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
(setq doom-font (font-spec :family "Iosevka Term" :size 15 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Helvetica" :size 14))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

(setq catppuccin-flavor 'mocha) ;; Options: 'frappe, 'latte, 'macchiato, or 'mocha
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

;; ----------------------- my config ------------------------------------------

;; -- shells
(setq shell-file-name (executable-find
                       "bash"))
(setq-default vterm-shell
              "/opt/homebrew/bin/fish")
(setq-default explicit-shell-file-name
              "/opt/homebrew/bin/fish")


;; -- vterm
(after! vterm
  (evil-set-initial-state 'vterm-mode 'emacs))

(use-package! vterm
  :config
  (setq vterm-max-scrollback 100000))


;; -- Window frame positioning
(setq initial-frame-alist
      '((top . 50) (left . 200)
        (width . 140) (height . 50)))


;; -- eglot
(set-eglot-client! '(elixir-mode elixir-ts-mode heex-ts-mode)
                   ;; `(,(expand-file-name "~/bin/elixir-ls")))
                   `(,(expand-file-name "~/.local/bin/expert") "--stdio")
                   )


;; -- HEEx: full elixir highlighting inside `{...}`, `<%= ... %>`, etc.
;;
;; Doom's `(elixir +tree-sitter)` already embeds heex inside `~H`/`~F` sigils,
;; but elixir expressions inside heex (`{@var}`, `<%= ... %>`) stay unfontified
;; because `heex-ts-mode` has no injection back into elixir. The blocks below
;; add that injection for both `.ex` files (via `elixir-ts-mode`) and plain
;; `.heex` files (via `heex-ts-mode`).

(defvar +elixir-heex-injection-query
  '((expression (expression_value) @cap)
    (directive (expression_value) @cap)
    (directive (partial_expression_value) @cap)
    (directive (ending_expression_value) @cap))
  "Tree-sitter query for heex nodes that contain embedded elixir code.")

(after! elixir-ts-mode
  (when (and (treesit-available-p)
             (treesit-ready-p 'heex)
             (treesit-ready-p 'elixir))
    ;; Replace elixir-ts-mode's range rules to ALSO embed elixir back inside
    ;; heex's expression nodes (in addition to the default heex-in-elixir).
    ;; `:local t' is REQUIRED here: without it, treesit-update-ranges would
    ;; clobber the primary elixir parser's ranges (see treesit.el:813-830),
    ;; breaking highlighting in the rest of the buffer.
    (setq elixir-ts--treesit-range-rules
          (treesit-range-rules
           :embed 'heex
           :host 'elixir
           '((sigil (sigil_name) @_name
                    (:match "^[HF]$" @_name)
                    (quoted_content) @heex))

           :embed 'elixir
           :host 'heex
           :local t
           +elixir-heex-injection-query))))

(defun +heex-ts-inject-elixir-h ()
  "Re-parse elixir code inside heex expression nodes for full highlighting."
  (require 'elixir-ts-mode)
  (when (and (treesit-ready-p 'elixir)
             (treesit-ready-p 'heex))
    (treesit-parser-create 'elixir)
    (setq-local treesit-range-settings
                (treesit-range-rules
                 :embed 'elixir
                 :host 'heex
                 +elixir-heex-injection-query))
    (setq-local treesit-font-lock-settings
                (append treesit-font-lock-settings
                        elixir-ts--font-lock-settings))
    (setq-local treesit-font-lock-feature-list
                '((heex-comment heex-keyword heex-doctype
                   elixir-comment elixir-doc elixir-definition)
                  (heex-component heex-tag heex-attribute heex-string
                   elixir-string elixir-keyword elixir-data-type)
                  (elixir-sigil elixir-builtin elixir-string-escape)
                  (elixir-function-call elixir-variable
                   elixir-operator elixir-number)))
    (treesit-font-lock-recompute-features)))

(add-hook 'heex-ts-mode-hook #'+heex-ts-inject-elixir-h)

(defun +heex-add-delimiter-fontlock-h ()
  "Highlight heex directive delimiters (<%, <%=, <%%, <%%=, %>) as keywords.
Stock `heex-ts-mode' leaves these tokens unfontified."
  (when (treesit-ready-p 'heex)
    (setq-local treesit-font-lock-settings
                (append treesit-font-lock-settings
                        (treesit-font-lock-rules
                         :language 'heex
                         :feature 'heex-delimiter
                         '(["<%" "<%=" "<%%" "<%%=" "%>"]
                           @font-lock-keyword-face))))
    ;; Add the new feature to level 1 (always-on under the default
    ;; `treesit-font-lock-level' of 3).
    (setq-local treesit-font-lock-feature-list
                (cons (append (car treesit-font-lock-feature-list)
                              '(heex-delimiter))
                      (cdr treesit-font-lock-feature-list)))
    (treesit-font-lock-recompute-features)))

;; Use 'append so this runs AFTER `+heex-ts-inject-elixir-h', which rewrites
;; `treesit-font-lock-feature-list' wholesale.
(add-hook 'elixir-ts-mode-hook #'+heex-add-delimiter-fontlock-h 'append)
(add-hook 'heex-ts-mode-hook   #'+heex-add-delimiter-fontlock-h 'append)


;; -- eat
(after! eat
  (evil-set-initial-state 'eat-mode 'emacs)
  (setq eat-very-visible-cursor-type '(t nil nil)))


;; -- symbols outline
(use-package! symbols-outline
  :commands (symbols-outline-show)
  :init
  (map! :leader
        :desc "Show symbols outline"
        "c S" #'symbols-outline-show)

  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (setq-local symbols-outline-fetch-fn #'symbols-outline-lsp-fetch)))
  :config
  (setq symbols-outline-window-position 'left)
  (symbols-outline-follow-mode)

  ;; Evil-style keybindings for symbols-outline
  (map! :map symbols-outline-mode-map
        :n "RET" #'symbols-outline-visit
        :n "j"   #'evil-next-line
        :n "k"   #'evil-previous-line
        :n "TAB" #'symbols-outline-toggle-node
        :n "za"  #'symbols-outline-toggle-node
        :n "zM"  #'symbols-outline-hide-all
        :n "zR"  #'symbols-outline-show-all
        :n "gr"  #'symbols-outline-refresh
        :n "q"   #'quit-window))



;; -- Scrolling behavior
;; Keep extra lines of context when recentering with zt and so on
(setq scroll-margin 3)  ; Number of lines to keep above/below cursor



;; -----------------------------------------------------------------
