;;; company-stack-ide --- company backend which uses a stack-ide process.

;; Copyright (c) 2015 Tristan Webb.

;; Package-Requires: ((company "0.8.11") (stack-mode "0.1.0.0"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Usage:

;; (require 'company-stack-ide)
;; (add-to-list 'company-backends 'company-stack-ide)
;; (add-hook 'stack-mode 'company-mode)

;;; Code:

(require 'company)
(require 'stack-mode)
(require 'cl-lib)

(defun company-stack-ide/get-file ()
  (let* ((filename (buffer-file-name))
         (file (with-current-buffer (stack-mode-buffer)
                 (file-relative-name filename default-directory))))
    file))

(defun company-stack-ide/get-completions (cmd)
  (let* ((filename (company-stack-ide/get-file))
         (reply (with-current-buffer (stack-mode-buffer)
            (stack-mode-call `(:tag "RequestGetAutocompletion"
                               :contents (,filename ,cmd))))))
     (cl-loop for item in (mapcar #'identity (stack-contents reply))
       collect
       (format "%s" (stack-lookup 'idName (stack-lookup 'idProp item))))
    ))

(defun company-stack-ide/meta (candidate)
  (get-text-property 0 'meta candidate))

;;;###autoload
(defun company-stack-ide (command &optional arg &rest ignored)
	"Company backend that provides completions using the a stack ide process."
	(interactive (list 'interactive))
	(cl-case command
		(interactive (company-begin-backend 'company-stack-ide))
		(prefix  (company-grab-symbol))
		(candidates (company-stack-ide/get-completions arg))
		(meta (company-stack-ide/meta arg))))
 
(provide 'company-stack-ide)
;;; company-stack-ide ends here
