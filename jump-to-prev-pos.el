;;; jump-to-prev-pos.el --- Simply jump to the previous cursor position -*- lexical-binding: t; -*-
;;
;; Author: Philippe IVALDI <emacs@MY-NAME.me>
;; Maintainer: Philippe IVALDI <emacs@MY-NAME.me>
;; Created: January 15, 2025
;; Modified: January 15, 2025
;; Version: 0.0.1
;; Keywords: emacs lisp
;; Homepage: https://github.com/pivaldi/jump-to-prev-pos.el
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; - Renaming function to satisfy Emacs packages naming best practice ;
;; - Make the variables `jump-to-prev-pos-stack-depth' customizable (default 32) ;
;; - Register new cursor position only when the distance between current position
;;   and previous one is greater or equal to `jump-to-prev-pos-min-lines-number'
;;   (customizable with default 5).
;;
;;; Code:

(defvar jump-to-prev-pos-prev-pos-stack nil
  "Stack of previous positions.")
(make-variable-buffer-local 'jump-to-prev-pos-prev-pos-stack)

(defvar jump-to-prev-pos-next-pos-stack nil
  "Stack of next positions.")
(make-variable-buffer-local 'jump-to-prev-pos-next-pos-stack)

(defgroup jump-to-prev-pos nil
  "Extensions to move the cursor to prev/next position."
  :group 'emacs)

(defcustom jump-to-prev-pos-stack-depth 32
  "Stack depth for jump-to-prev-pos."
  :type 'integer
  :group 'jump-to-prev-pos)

(defcustom jump-to-prev-pos-min-lines-number 5
  "The minimum number of visible lines between point and previous
point needed to add point in the stack."
  :type 'integer
  :group 'jump-to-prev-pos)

;;;###autoload
(defun jump-to-prev-pos-remember-position ()
  (let ((currentp (point))
        (previousp (car jump-to-prev-pos-prev-pos-stack)))
    (unless (or
             (and previousp
                  (< (count-lines previousp currentp) jump-to-prev-pos-min-lines-number))
             (equal this-command 'jump-to-prev-pos-prev-pos)
             (equal this-command 'jump-to-prev-pos-next-pos))
      (setq jump-to-prev-pos-next-pos-stack nil)
      (setq jump-to-prev-pos-prev-pos-stack (cons currentp jump-to-prev-pos-prev-pos-stack))
      (when (> (length jump-to-prev-pos-prev-pos-stack) jump-to-prev-pos-stack-depth)
        (nbutlast jump-to-prev-pos-prev-pos-stack)))))
;; (add-hook 'pre-command-hook #'jump-to-prev-pos-remember-position)

;;;###autoload
(defun jump-to-prev-pos-prev-pos ()
  "Jump to previous position."
  (interactive)
  (when jump-to-prev-pos-prev-pos-stack
    (goto-char (car jump-to-prev-pos-prev-pos-stack))
    (setq jump-to-prev-pos-prev-pos-stack (cdr jump-to-prev-pos-prev-pos-stack))
    (setq jump-to-prev-pos-next-pos-stack (cons (point) jump-to-prev-pos-next-pos-stack))))

;;;###autoload
(defun jump-to-prev-pos-next-pos ()
  "Jump to next position."
  (interactive)
  (when jump-to-prev-pos-next-pos-stack
    (goto-char (car jump-to-prev-pos-next-pos-stack))
    (setq jump-to-prev-pos-next-pos-stack (cdr jump-to-prev-pos-next-pos-stack))
    (setq jump-to-prev-pos-prev-pos-stack (cons (point) jump-to-prev-pos-prev-pos-stack))))

(provide 'jump-to-prev-pos)
;;; jump-to-prev-pos.el ends here
