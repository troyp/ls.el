;;;  -*- lexical-binding: t -*-

(require 'ert)
(require 'fn)

(cl-macrolet ((should-equal
               (expr keyword result)
               (if (eq keyword :result)
                   `(should (equal ,expr ,result))
                 (error "expected :result"))))

  (ert-deftest test-ls-range ()
    "Test `ls-range'."

    (should-equal (ls-range to 5)
                  :result
                  '(0 1 2 3 4 5))

    (should-equal (ls-range below 5)
                  :result
                  '(0 1 2 3 4))

    (should-equal (ls-range from 1 to 10 by 2)
                  :result
                  '(1 3 5 7 9))

    (should-equal (ls-range from 1 to 8 by 1.5)
                  :result
                  '(1 2.5 4.0 5.5 7.0))

    (should-equal (ls-range from 3 downto -3)
                  :result
                  '(3 2 1 0 -1 -2 -3))

    (should-equal (ls-range from 1 to 10 when (oddp i))
                  :result
                  '(1 3 5 7 9))

    (should-equal (ls-range from 1 until (> (* i i) 50))
                  :result
                  '(1 2 3 4 5 6 7))

    (should-equal (ls-range in '(a b c d e) by 'cddr)
                  :result
                  '(a c e))

    (should-equal (ls-range on '(a b c d))
                  :result
                  '((a b c d) (b c d) (c d) (d)))

    (should-equal (ls-range on (ls-range to 3))
                  :result
                  '((0 1 2 3) (1 2 3) (2 3) (3)))

    (should-equal (-map 'string (ls-range from ?A to ?K))
                  :result
                  '("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K"))
    )

  (ert-deftest test-ls-cons-if-t ()
    "Test `ls-cons-if-t'."

    (should-equal (ls-cons-if-t 'a '(b c))
                  :result
                  '(a b c))

    (should-equal (ls-cons-if-t nil '(b c))
                  :result
                  '(b c))

    (should-equal (ls-cons-if-t 2 3)
                  :result
                  '(2 . 3))

    (should-equal (ls-cons-if-t nil 3)
                  :result
                  3)
    )

  (ert-deftest test-ls-zero-when ()
    "Test `ls-zero-when'."
    (should-equal (ls-zero-when (fn (zerop (mod <> 3)))
                                (ls-range from 1 to 10))
                  :result
                  '(nil nil 3 nil nil 6 nil nil 9 nil))
    )

  (ert-deftest test-ls-zero-unless ()
    "Test `ls-zero-unless'."
    (should-equal (ls-zero-unless (fn (zerop (mod <> 3)))
                                  (ls-range from 1 to 10))
                  :result
                  '(1 2 nil 4 5 nil 7 8 nil 10))
    )

  (ert-deftest test-ls-*-before ()
    "Test `ls-*-before'."

    (let ((list '(1 2 3 4 5 6 7 8 9 10)))
      (should-equal (-concat (ls-take-before '7 list)
                             (ls-drop-before '7 list))
                    :result
                    list))

    (let ((list '((1 2) "foo" ?a (3 . 4))))
      (should-equal (-concat (ls-take-before ?a list)
                             (ls-drop-before ?a list))
                    :result
                    list))
    )

  (ert-deftest test-ls-partition-by-indices ()
    "Test `ls-partition-by-indices'."
    (should-equal
     (ls-partition-by-indices nil '(0 1 2))
     :result
     '((0 1 2)))
    (should-equal
     (ls-partition-by-indices '(1) '(0 1 2))
     :result
     '((0) (1 2)))
    ;; out-of-order indices
    (should-equal
     (ls-partition-by-indices '(5 8 3) (ls-seq 0 9))
     :result
     '((0 1 2) (3 4) (5 6 7) (8 9))
     )
    ;; zero index is ignored
    (should-equal
     (ls-partition-by-indices '(0) '(0 1 2))
     :result
     '((0 1 2)))
    ;; indices out of range are ignored
    (should-equal
     (ls-partition-by-indices '(1 100 200) '(0 1 2))
     :result
     '((0) (1 2)))
    ;; indices out of range are ignored
    (should-equal
     (ls-partition-by-indices '(1 -1) '(0 1 2))
     :result
     '((0) (1 2))
     )
    )
  (ert-deftest test-ls-partition-by-indices/repeated-application ()
    "Test repeated applications of `ls-partition-by-indices'.
May result from binding (let ((parts '(nil)) ...) rather than
(let ((parts (list nil)) ...))."
    (should-equal
     (ls-partition-by-indices '(1 2 3) '(0 1 2))
     :result
     '((0) (1) (2)))
    (should-equal
     (ls-partition-by-indices '(1 2 3) '(0 1 2))
     :result
     '((0) (1) (2)))
    )

(ert-deftest test-ls-reverse-sublist ()
  "Test `ls-reverse-sublist'."
  (should-equal
   (ls-reverse-sublist 3 8 (ls-seq 0 9))
   :result
   '(0 1 2 7 6 5 4 3 8 9)
   )
   ;;
  (should-equal
   (ls-reverse-sublist 0 10 (ls-seq 0 9))
   :result
   '(9 8 7 6 5 4 3 2 1 0)
   )
  )

  )

(defun ls---test-all ()
  (interactive)
  (ert-run-tests-batch "^test-ls" ))
