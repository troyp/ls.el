;;; ls.el --- List functions and utilities for Emacs   -*- lexical-binding: t -*-

;; Copyright (C) 2016 Troy Pracy

;; Author: Troy Pracy
;; Keywords: list functional
;; Version: 0.0.5
;; Package-Requires: ((emacs "24") (dash "2.12.1") (dash-functional "1.2.0"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'cl-macs)
(require 'dash-functional)



;; ,---------------,
;; | List Creation |
;; '---------------'

(defalias 'ls-seq 'number-sequence)



(defmacro ls-range (&rest clauses)
  "Return a range of numbers (or other values) as a list.

The CLAUSES follow `cl-loop' syntax and an anaphoric loop variable i is exposed.
This is equivalent to:

  (cl-loop for i CLAUSES... collect i)

For more information on clauses, see Info Node `(cl)Loop Facility'

Examples:

  (ls-range to 5)
  ;; (0 1 2 3 4 5)

  (ls-range below 5)
  ;; (0 1 2 3 4)

  (ls-range from 1 to 10 by 2)
  ;; (1 3 5 7 9)

  (ls-range from 1 to 8 by 1.5)
  ;; (1 2.5 4.0 5.5 7.0)

  (ls-range from 3 downto -3)
  ;; (3 2 1 0 -1 -2 -3)

  (ls-range from 1 to 10 when (oddp i))
  ;; (1 3 5 7 9)

  (ls-range from 1 until (> (* i i) 50))
  ;; (1 2 3 4 5 6 7)

  (ls-range in '(a b c d e) by 'cddr)
  ;; (a c e)

  (ls-range on '(a b c d))
  ;; ((a b c d) (b c d) (c d) (d))

  (ls-range on (ls-range to 3))
  ;; ((0 1 2 3) (1 2 3) (2 3) (3))

  (-map 'string (ls-range from ?A to ?K))
  ;; (\"A\" \"B\" \"C\" \"D\" \"E\" \"F\" \"G\" \"H\" \"I\" \"J\" \"K\")

\(fn CLAUSE...)"
  (declare (indent 0)
           (debug body))
  `(cl-loop for i ,@clauses collect i))



;; ,-------------,
;; | List Access |
;; '-------------'

(defun ls-uncons (list)
  "Decompose LIST into `car' and `cdr'.

If LIST is nil, return nil."
  (list (car list) (cdr list)))

(defun ls-last (list)
  "Return the last element of LIST."
  (car (last list)))



;; ,-------------------,
;; | List Modification |
;; '-------------------'

(defun ls-cons-if-t (car cdr)
  "Create a new cons if CAR is non-nil, else return CDR.

Examples:

  (ls-cons-if-t 'a '(b c))
  ;; (a b c)
  (ls-cons-if-t nil '(b c))
  ;; (b c)
  (ls-cons-if-t 2 3)
  ;; (2 . 3)
  (ls-cons-if-t nil 3)
  ;; 3"
  (if car (cons car cdr) cdr))

(defun ls-zero-when (pred list)
  "Replace items where PRED yields t by zero in LIST.

Example:

  (ls-zero-when (fn (zerop (mod <> 3))) (ls-range from 1 to 10))
  ;; (nil nil 3 nil nil 6 nil nil 9 nil)"
  (--map (when (funcall pred it) it) list))

(defun ls-zero-unless (pred list)
  "Replace items where PRED yields nil by zero in LIST.

Example:

  (ls-zero-unless (fn (zerop (mod <> 3))) (ls-range from 1 to 10))
  ;; (1 2 nil 4 5 nil 7 8 nil 10)"
  (--map (unless (funcall pred it) it) list))

(defun ls-reverse-sublist (start end list)
  "Return a copy of LIST with sublist [START, end) reversed."
  (let* ((parts (cond
                 ((= start 0) (list nil (-take end list) (-drop end list)))
                 (t (ls-partition-by-indices (list start end) list))))
         (prefix  (car parts))
         (sublist (cadr parts))
         (suffix  (caddr parts)))
    (-concat prefix (reverse sublist) suffix)))



;; ,----------,
;; | Sublists |
;; '----------'

(defun ls-take-before (target list)
  "Return the prefix ending immediately before TARGET of LIST."
  (--take-while (not (eql it target)) list))

(defun ls-take-to (target list)
  "Return the prefix ending with TARGET of LIST."
  (let ((found nil))
    (-take-while
     (lambda (x)
       (cond (found            nil)
             ((eql target x)   (progn (setq found t) t))
             (t                t)))
     list)))

(defalias 'ls-drop-before 'memql
  "Return the suffix beginning with TARGET of LIST.")

(defun ls-drop-to (target list)
  "Return the suffix starting immediately after TARGET of LIST."
  (cdr (memql target list)))

(defalias 'ls-take-to-elt 'ls-take-to)
(defalias 'ls-drop-to-elt 'ls-drop-to)
(defalias 'ls-take-before-elt 'ls-take-before)
(defalias 'ls-drop-before-elt 'ls-drop-before)

(defun ls-take-until (pred list)
  "Return a prefix of items failing PRED from LIST.

  Note that `ls-take-until' and `ls-drop-until' partition a list into two parts
  (the prefix before PRED first holds, and the rest)."
  (-take-while (-not pred) list))

(defun ls-drop-until (pred list)
  "Return a suffix of items failing PRED from LIST.

Note that `ls-take-until' and `ls-drop-until' partition a list into two parts.
\(the prefix before PRED first holds, and the rest)."
  (-drop-while (-not pred) list))

(defun ls-partition-by-indices (indices list)
  "Return a list of sublists partitioning LIST at INDICES.

INDICES may be in any order and should be in the range 0 < i < N.
Out-of-range indices are ignored.

Example:
  (ls-partition-by-indices '(1 3) (ls-seq 0 9))
  ;; ((0) (1 2) (3 4 5 6 7 8 9)) "
  (let ((indices (-filter (lambda (x)
                            (and (> x 0)
                                 (< x (length list))))
                          indices))
        (parts (list nil) )
        (rest  list))
    (dotimes (i (length list))
      ;; (cl-prettyprint (list i parts rest))
      (when (member i indices)
        (push nil parts))
      ;; (cl-prettyprint (list i parts rest))
      (push (car rest) (car parts))
      ;; (cl-prettyprint (list i parts rest))
      (setf rest (cdr rest)))
    ;; (insert "\n\n")
    (reverse (mapcar #'reverse parts))))



;; ,------------,
;; | Predicates |
;; '------------'

(defun ls-proper? (list)
  "Return t if LIST is proper (ie. not dotted).

A proper list is one where each target is the `car' of a cons cell.  nil is
trivially a proper list.

If the argument is not a list, an error is thrown."
  (pcase (cdr list)
    (`nil          t)
    ((pred nlistp) nil)
    ((pred consp)  (ls-proper? (cdr list)))))

(defun ls-improper? (list)
  "Return t if LIST is an improper (ie. dotted) list.

An improper list is one where the last target is the `cdr' of a cons cell (with
the second-last target being the `car').  It is represented by dotted notation.

If the argument is not a list, an error is thrown."
  (not (ls-proper? list)))

(defun ls-proper-list? (object)
  "Return t if OBJECT is a proper list.

See `ls-proper?'."
  (and (listp      object)
       (ls-proper? object)))

(defun ls-improper-list? (object)
  "Return t if OBJECT is an improper list.

See `ls-improper?'."
  (and (listp      object)
       (ls-improper? object)))

(defun ls-sublist? (sub list)
  "Return t if SUB is a contiguous sublist of LIST."
  (let ((n (length sub)))
    (cl-labels
        ((---sublist-n?
          (sub list)
          (let ((suffix (memq (car sub) list)))
            (cond ((equal sub
                          (-take n suffix))   t)
                  ((null list)                nil)
                  (:otherwise  (---sublist-n? sub (cdr suffix)))))))
      (---sublist-n? sub list))))



(provide 'ls)

;;; ls.el ends here
