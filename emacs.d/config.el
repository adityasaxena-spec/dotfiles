(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                 ,@(when-let ((depth (plist-get order :depth)))
                                                     (list (format "--depth=%d" depth) "--no-single-branch"))
                                                 ,(plist-get order :repo) ,repo))))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca all-the-icons-dired (use-package all-the-icons-dired
                              :hook (dired-mode . (lambda () (all-the-icons-dired-mode t)))))

(setq backup-directory-alist '((".*" . "~/.local/share/Trash/files")))

(elpaca ewal (use-package ewal
	       :init (setq ewal-use-built-in-always-p nil
			   ewal-use-built-in-on-failure-p t
			   ewal-built-in-palette "sexy-material")))
(elpaca ewal-spacemacs-themes (use-package ewal-spacemacs-themes
				:init (progn
					(setq spacemacs-theme-org-highlight t)
					(setq spacemacs-theme-underline-parens t
  					      my:rice:font (font-spec
							    :family "JetBrainsMonoNerdFont"
							    :weight 'semi-bold
							    :size 11.0))
					(show-paren-mode +1)
					(global-hl-line-mode)
					(set-frame-font my:rice:font nil t)
					(add-to-list  'default-frame-alist
						      `(font . ,(font-xlfd-name my:rice:font))))
				:config (progn
					  (load-theme 'ewal-spacemacs-modern t)
					  (enable-theme 'ewal-spacemacs-modern))))
(elpaca ewal-evil-cursors (use-package ewal-evil-cursors
			    :after (ewal-spacemacs-themes)
			    :config (ewal-evil-cursors-get-colors
				     :apply t :spaceline t)))
(elpaca spaceline (use-package spaceline
		    :after (ewal-evil-cursors winum)
		    :init (setq powerline-default-separator nil)
		    :config (spaceline-spacemacs-theme)))

(elpaca dashboard (use-package dashboard
		    :init 
		    ;; Set the title
		    (setq dashboard-banner-logo-title "Welcome to Emacs Dashboard")
		    ;; Set the banner
		    (setq dashboard-startup-banner 'logo )
		    ;; Content is not centered by default. To center, set
		    (setq dashboard-center-content nil)
		    ;; vertically center content
		    (setq dashboard-vertically-center-content nil)
		    :config
		    (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
		    (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
		    (dashboard-setup-startup-hook)))

;; Install a package via the elpaca macro
;; See the "recipes" section of the manual for more details.

;; (elpaca example-package)

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;;When installing a package used in the init file itself,
;;e.g. a package which adds a use-package key word,
;;use the :wait recipe keyword to block until that package is installed/configured.
;;For example:
;;(use-package general :ensure (:wait t) :demand t)

;; Expands to: (elpaca evil (use-package evil :demand t))
(elpaca evil (use-package evil
               :init      ;; tweak evil's configuration before loading it
               (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
               (setq evil-want-keybinding nil)
               (setq evil-vsplit-window-right t)
               (setq evil-split-window-below t)
               (evil-mode)))
(elpaca evil-collection (use-package evil-collection
                          :after evil
                          :config
                          (setq evil-collection-mode-list '(dashboard dired ibuffer))
                          (evil-collection-init)))
(elpaca evil-tutor (use-package evil-tutor))

;;Turns off elpaca-use-package-mode current declaration
;;Note this will cause evaluate the declaration immediately. It is not deferred.
;;Useful for configuring built-in emacs features.
(use-package emacs :ensure nil :config (setq ring-bell-function #'ignore))

(elpaca hl-todo (use-package hl-todo
                  :hook ((org-mode . hl-todo-mode)
                         (prog-mode . hl-todo-mode))
                  :config
                  (setq hl-todo-highlight-punctuation ":"
                        hl-todo-keyword-faces
                        `(("TODO"       warning bold)
                          ("FIXME"      error bold)
                          ("HACK"       font-lock-constant-face bold)
                          ("REVIEW"     font-lock-keyword-face bold)
                          ("NOTE"       success bold)
                          ("DEPRECATED" font-lock-doc-face bold)))))

(elpaca neotree (use-package neotree
                  :config
                  (setq neo-smart-open t
                        neo-show-hidden-files t
                        neo-window-width 55
                        neo-window-fixed-size nil
                        inhibit-compacting-font-caches t
                        projectile-switch-project-action 'neotree-projectile-action) 
                  ;; truncate long file names in neotree
                  (add-hook 'neo-after-create-hook
                            #'(lambda (_)
                                (with-current-buffer (get-buffer neo-buffer-name)
                                  (setq truncate-lines t)
                                  (setq word-wrap nil)
                                  (make-local-variable 'auto-hscroll-mode)
                                  (setq auto-hscroll-mode nil))))))

(elpaca toc-org (use-package toc-org
                  :commands toc-org-enable
                  :init (add-hook 'org-mode-hook 'toc-org-enable)))

(add-hook 'org-mode-hook 'org-indent-mode)
(elpaca org-bullets (use-package org-bullets))
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(custom-set-faces
 '(org-level-1 ((t (:inherit outline-1 :height 1.7))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.6))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.5))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.4))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.3))))
 '(org-level-6 ((t (:inherit outline-5 :height 1.2))))
 '(org-level-7 ((t (:inherit outline-5 :height 1.1)))))

(require 'org-tempo)

(elpaca ob-mermaid (use-package ob-mermaid))
(setq ob-mermaid-cli-path "/home/aditya/.local/bin/mmdc")

(elpaca auctex (use-package auctex))
(setq org-latex-create-formula-image-program 'imagemagick)
(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))

(elpaca org-roam (use-package org-roam
                   :ensure t
                   :custom
                   (org-roam-directory "~/Notes")
                   :bind (("C-c n l" . org-roam-buffer-toggle)
                          ("C-c n f" . org-roam-node-find)
                          ("C-c n i" . org-roam-node-insert))
                   :config
                   (org-roam-setup)))

(elpaca rainbow-delimiters (use-package rainbow-delimiters
                             :hook ((emacs-lisp-mode . rainbow-delimiters-mode)
                                    (clojure-mode . rainbow-delimiters-mode))))

(elpaca rainbow-mode (use-package rainbow-mode
                       :hook org-mode prog-mode))

(delete-selection-mode 1)    ;; You can select text and delete it by typing.
(electric-indent-mode -1)    ;; Turn off the weird indenting that Emacs does by default.
(electric-pair-mode 1)       ;; Turns on automatic parens pairing
;; The following prevents <> from auto-pairing when electric-pair-mode is on.
;; Otherwise, org-tempo is broken when you try to <s TAB...
(add-hook 'org-mode-hook (lambda ()
                           (setq-local electric-pair-inhibit-predicate
                                       `(lambda (c)
                                          (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))
(global-auto-revert-mode t)  ;; Automatically show changes if the file has changed
(global-display-line-numbers-mode 1) ;; Display line numbers
(global-visual-line-mode t)  ;; Enable truncated lines
(setq display-line-numbers-type 'relative) 
(menu-bar-mode -1)           ;; Disable the menu bar 
(scroll-bar-mode -1)         ;; Disable the scroll bar
(tool-bar-mode -1)           ;; Disable the tool bar
(setq org-edit-src-content-indentation 0) ;; Set src block automatic indent to 0 instead of 2.
;; RETURN will follow links in org-mode files
(setq org-return-follows-link  t)
(setq indent-tabs-mode t
      tab-width 2)

(defun display-startup-echo-area-message ()
  (message nil))

(elpaca sudo-edit (use-package sudo-edit))

(add-to-list 'default-frame-alist '(alpha-background . 80)) ; For all new frames henceforth

(set-face-attribute 'default nil
                    :font "JetBrainsMonoNerdFont"
                    :height 110
                    :weight 'medium)
(set-face-attribute 'variable-pitch nil
                    :font "JetBrainsMonoNerdFont"
                    :height 120
                    :weight 'medium)
(set-face-attribute 'fixed-pitch nil
                    :font "JetBrainsMonoNerdFont"
                    :height 110
                    :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
                    :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
                    :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "JetBrainsMonoNerdFont"))

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

(elpaca centered-cursor-mode (use-package centered-cursor-mode
                               :demand
                               :config
                               ;; Optional, enables centered-cursor-mode in all buffers.
                               (global-centered-cursor-mode)))

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
