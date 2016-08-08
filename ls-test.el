;;;  -*- lexical-binding: t -*-

(require 'ert)
(require 'fn)

(cl-flet
    ((should-equal (a b)
                   (should (equal a b)))
     (should-eql (a b)
                 (should (eql a b)))
     (should= (a b)
              (should (= a b))))


  (ert-deftest test-ls-range ()
    "Test `ls-range'."

    (should-equal (ls-range to 5)
                  '(0 1 2 3 4 5))

    (should-equal (ls-range below 5)
                  '(0 1 2 3 4))

    (should-equal (ls-range from 1 to 10 by 2)
                  '(1 3 5 7 9))

    (should-equal (ls-range from 1 to 8 by 1.5)
                  '(1 2.5 4.0 5.5 7.0))

    (should-equal (ls-range from 3 downto -3)
                  '(3 2 1 0 -1 -2 -3))

    (should-equal (ls-range from 1 to 10 when (oddp i))
                  '(1 3 5 7 9))

    (should-equal (ls-range from 1 until (> (* i i) 50))
                  '(1 2 3 4 5 6 7))

    (should-equal (ls-range in '(a b c d e) by 'cddr)
                  '(a c e))

    (should-equal (ls-range on '(a b c d))
                  '((a b c d) (b c d) (c d) (d)))

    (should-equal (ls-range on (ls-range to 3))
                  '((0 1 2 3) (1 2 3) (2 3) (3)))

    (should-equal (-map 'string (ls-range from ?A to ?K))
                  '("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K"))
    )

  (ert-deftest test-ls-cons-if-t ()
    "Test `ls-cons-if-t'."

    (should-equal (ls-cons-if-t 'a '(b c))
                  '(a b c))

    (should-equal (ls-cons-if-t nil '(b c))
                  '(b c))

    (should-equal (ls-cons-if-t 2 3)
                  '(2 . 3))

    (should-equal (ls-cons-if-t nil 3)
                  3)
    )

  (ert-deftest test-ls-zero-when ()
    "Test `ls-zero-when'."
    (should-equal (ls-zero-when (fn (zerop (mod <> 3)))
                                (ls-range from 1 to 10))
                  '(nil nil 3 nil nil 6 nil nil 9 nil))
    )

  (ert-deftest test-ls-zero-unless ()
    "Test `ls-zero-unless'."
    (should-equal (ls-zero-unless (fn (zerop (mod <> 3)))
                                  (ls-range from 1 to 10))
                  '(1 2 nil 4 5 nil 7 8 nil 10))
    )

  (ert-deftest test-ls-*-before ()
    "Test `ls-*-before'."

    (let ((list '(1 2 3 4 5 6 7 8 9 10)))
      (should-equal list
                    (-concat (ls-take-before '7 list)
                             (ls-drop-before '7 list))))

    (let ((list '((1 2) "foo" ?a (3 . 4))))
      (should-equal list
                    (-concat (ls-take-before ?a list)
                             (ls-drop-before ?a list))))
    )

  )

(defun ls---test-all ()
  (interactive)
  (ert-run-tests-batch "^test-ls" ))
