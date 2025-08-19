(add-to-list 'default-frame-alist '(fullscreen . maximized)) ;; Maximize window after starting Emacs
(setq inhibit-startup-message t) ;; Close Emacs launch screen
(setq inhibit-splash-screen t)   ;; Close Emacs startup help screen
(setq initial-scratch-message (concat ";; Happy hacking, " user-login-name " - Emacs \u2665 you!\n\n"))

;; (menu-bar-mode 0) ;; Emacs Text Toolbar above
(tool-bar-mode 0) ;; Close Emacs icon toolbar above
(scroll-bar-mode 0) ;; Close scrollbar

(setq ring-bell-function 'ignore) ;; Close Emacs warning sound

;; File related: Backup, Delete Recycle Bin
(setq make-backup-files nil        ;; Close the backup file
      create-lockfiles nil         ;; Close Create a backup file
      delete-by-moving-to-trash t) ;; Emacs moves to the recycling bin when deleting files

(load-theme 'modus-operandi-tinted)

(set-face-attribute 'default nil :height 140)
;; (set-face-attribute 'default nil :family "Consolas" :height 140)

(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")))

(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode)
  :bind (:map vertico-map
              ("DEL" . vertico-directory-delete-char))
  :custom
  (vertico-count 10)
  )

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Display information in Minibuffer
(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

;; modelline display time
(use-package time
  :ensure nil
  :hook (after-init . display-time-mode)
  :custom
  (display-time-24hr-format t);; 24-hour system
  (display-time-format "%m-%d %a %H:%M")
  (display-time-day-and-date t) ;; Show time, day, date
  )

;; Automatically update files after external changes
(use-package autorevert
  :ensure nil
  :hook (after-init . global-auto-revert-mode))

;; Where the cursor is located before saving each file
(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode)
  :custom
  (save-place-file "~/.emacs.d/places"))

(use-package which-key
  :ensure nil
  :if (>= emacs-major-version 30)
  :diminish
  :hook (window-setup . which-key-mode))

(use-package tab-line
  :ensure nil
  :hook (window-setup . global-tab-line-mode))

(use-package recentf
  :ensure nil
  :hook (after-init . recentf-mode)
  :custom
  (recentf-filename-handlers '(abbreviate-file-name))
  (recentf-max-saved-items 400)
  (recentf-max-menu-items 400)
  (recentf-save-file "~/.emacs.d/recentf")
  :config
  (recentf-cleanup))

(use-package project
  :ensure nil)

(use-package deadgrep
  :ensure t
  :bind
  (([remap project-find-regexp] . deadgrep)))

(use-package consult
  :ensure t
  :bind
  (([remap imenu] . consult-imenu)
   ([remap switch-to-buffer] . consult-buffer)
   ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
   ([remap switch-to-buffer-other-frame] . consult-buffer-other-frame)
   ("M-g M-g" . consult-line)
   ("M-g g" . consult-goto-line)
   ([remap bookmark-jump] . freedom/consult-bookmark)
   ([remap repeat-complex-command] . consult-complex-command)
   ([remap yank-pop] . consult-yank-pop)
   ([remap Info-search] . consult-info)
   ("C-c cf" . consult-recent-file)
   ("C-c cF" . consult-flymake)
   ("C-c cg" . consult-grep)
   ("C-c cG" . consult-line-multi)
   ("C-c ck" . consult-kmacro)
   ("C-c cl" . consult-locate)
   ("C-c co" . consult-outline)
   ("C-c cr" . consult-ripgrep)
   :map isearch-mode-map
   ("C-c h" . consult-isearch-history)
   :map minibuffer-local-map
   ("C-c h" . consult-history)
   :map org-mode-map
   ([remap imenu] . consult-outline))
  :custom
  (register-preview-delay 0.5)
  (register-preview-function #'consult-register-format)
  (xref-search-program 'ripgrep)
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  (consult-preview-key 'any) ;; Preview content, can be set to buttons
  (consult-async-refresh-delay 1.0) ;; Prevent Emacs from being stuck by using external programs, for example: consult-ripgrep
  (consult-async-min-input 2) ;; Start searching at the minimum number of characters
  (consult-narrow-key "?") ;; Optional module buttons
  :config

  ;; Support Windows system `everythine.exe` software search file to use `conslut-locate`
  (when (and (eq system-type 'windows-nt))
    (setq consult-locate-args (encode-coding-string "es.exe -i -p -r" 'gbk)))

  ;; Disable preview of certain features
  (defmacro +no-consult-preview (&rest cmds)
    `(consult-customize ,@cmds :preview-key "M-."))
  (+no-consult-preview
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file
   consult--source-recent-file consult--source-project-recent-file consult--source-bookmark)
  )

(use-package eglot
  :ensure nil
  :if (>= emacs-major-version 29)
  :hook
  (eglot-managed-mode . (lambda () (eglot-inlay-hints-mode -1)));; No prompt is displayed
  :hook
  ;; NOTE: Please add your programming language here
  ((c-mode c-ts-mode c++-mode c++-ts-mode rust-mode rust-ts-mode) . eglot-ensure)
  :bind (:map eglot-mode-map
              ("C-c la" . eglot-code-actions) ;; Automatically write/repair code.
              ("C-c lr" . eglot-rename)
              ("C-c lf" . eglot-format) ;; Format current buffer
              ("C-c lc" . eglot-reconnect)
              ("C-c ld" . eldoc)) ;; view document
  :custom
  (eglot-autoshutdown t) ;; Automatically stop after closing all projects buffer
  (eglot-report-progress nil);; Hide all eglot event buffers
  :config
  (setq eglot-stay-out-of '(company));; No other complementary backend options are changed
  )

(defun freedom/compile-commands-json ()
  "Generate compile_commands.json for all .c/.C files in the selected directory.
Includes all directories containing .h/.H files as -I include paths."
  (interactive)
  (let* ((root (read-directory-name "Select project root: "))
         (c-files (directory-files-recursively root "\\.\\(c\\|C\\)$"))
         (h-dirs (let ((hs (directory-files-recursively root "\\.\\(h\\|H\\)$"))
                       (dirs '()))
                   (dolist (h hs)
                     (let ((dir (file-relative-name (file-name-directory h) root)))
                       (unless (member dir dirs)
                         (push dir dirs))))
                   dirs))
         (json-file (expand-file-name "compile_commands.json" root))
         (command-entries '()))

    ;; Construct the compile_commands.json project for each c file
    (dolist (c-file c-files)
      (let* ((rel-file (file-relative-name c-file root))
             (obj-file (concat (file-name-sans-extension rel-file) ".o"))
             (args (append
                    '("gcc" "-o")
                    (list obj-file "-g")
                    (mapcar (lambda (dir) (concat "-I" dir)) h-dirs)
                    (list rel-file)))
             (entry `(("directory" . ,(expand-file-name root))
                      ("arguments" . ,args)
                      ("file" . ,rel-file))))
        (push entry command-entries)))

    ;; Write JSON to compile_commands.json file
    (with-temp-file json-file
      (insert (json-encode command-entries)))
    (message "compile_commands.json generated at: %s" json-file)))

(use-package org
  :ensure nil)
