;;; eask-api.el --- Core Eask APIs  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Shen, Jen-Chieh

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Maintainer: Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/emacs-eask/eask-api
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1"))
;; Keywords: lisp eask api

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This is the core APIs of the Eask CLI, a tool for building and testing
;; Emacs Lisp packages
;;

;;; Code:

(require 'cl-lib)
(require 'subr-x)

(defgroup eask-api nil
  "Eask API."
  :prefix "eask-api-"
  :group 'tool
  :link '(url-link :tag "Repository" "https://github.com/emacs-eask/eask-api"))

(defcustom eask-api-strict-p t
  "Set to nil if you want to load Eask API whenever it's possible."
  :type 'boolean
  :group 'eask-api)

(defcustom eask-api-executable nil
  "Executable to eask-cli."
  :type 'string
  :group 'eask-api)

;;
;;; Externals

(declare-function project-root "project" (project))

;;
;;; Executable

(defun eask-api-executable ()
  "Return Eask CLI path."
  (or eask-api-executable (executable-find "eask")))

(defun eask-api-executable-p ()
  "Return t if Eask CLI is executed from executable and not shell script."
  (not
   (string= "bin"
            (file-name-nondirectory
             (directory-file-name (file-name-directory (eask-api-executable)))))))

(defun eask-api-lisp-root ()
  "Return Eask CLI lisp path."
  (file-name-as-directory
   (expand-file-name "lisp"
                     (if (eask-api-executable-p)
                         (eask-api-executable)
                       (expand-file-name "../../" (eask-api-executable))))))

;;
;;; Entry

(defun eask-api-check-filename (name)
  "Return non-nil if NAME is a valid Eask-file."
  (when-let* ((name (file-name-nondirectory (directory-file-name name)))
              (prefix (cond ((string-prefix-p "Easkfile" name) "Easkfile")
                            ((string-prefix-p "Eask" name)     "Eask"))))
    (let ((suffix (car (split-string name prefix t))))
      (or (null suffix)
          (string-match-p "^[.][.0-9]*$" suffix)))))

;;;###autoload
(defun eask-api-setup ()
  "Set up for `eask-api'.

It will return a list of available Eask-files to load."
  (when-let* ((files (eask--find-files default-directory))
              (files (if eask-api-strict-p
                         (cl-remove-if-not (lambda (file)
                                             (string-prefix-p "Easkfile" file))
                                           files)
                       files)))
    (require 'eask-api-core)
    files))

(provide 'eask-api)
;;; eask-api.el ends here
