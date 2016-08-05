ls.el -- List functions and macros for Emacs Lisp.
-----

Provides a set of utilities for list processing in Emacs Lisp. Sister library
to [__fn.el__](https://github.com/troyp/fn.el).

__ls.el__ builds on the facilities provided by
[`dash`](https://github.com/magnars/dash.el) and
[`cl`](https://www.gnu.org/software/emacs/manual/html_node/cl/) and focuses on
concision, readability and consistent naming conventions.

------------------------------------------------------------

## Installation

Place `fn.el` in any directory on your `load-path` and:

    (require 'fn)

------------------------------------------------------------

## API

### List creation: ranges, list comprehensions, etc.
* [ls-range](#ls-range-rest-clauses) `(&rest clauses)`

### List modification.
* [ls-cons-if-t](#ls-cons-if-t-car-cdr) `(car cdr)`

### Sublists.
* [ls-take-before-elt](#ls-take-before-elt-target-list) `(target-list)`
* [ls-take-to-elt](#ls-take-to-elt-target-list) `(target list)`
* [ls-drop-before-elt](#ls-drop-before-elt-target-list) `(target list)`
* [ls-drop-to-elt](#ls-drop-to-elt-target-list) `(target list)`

### Predicates.
* [ls-proper?](#ls-proper?-list) `(list)`
* [ls-improper?](#ls-improper?-list) `(list)`
* [ls-proper-list?](#ls-proper-list?-object) `(object)`
* [ls-improper-list?](#ls-improper-list?-object) `(object)`
* [ls-take-until](#ls-take-until-pred-list)
* [ls-drop-until](#ls-drop-until-pred-list)

------------------------------------------------------------

### List creation: ranges, list comprehensions, etc.

#### ls-range `(&rest clauses)`
Return a range of numbers (or other values) as a list.

The CLAUSES follow `cl-loop` syntax and an anaphoric loop variable `i` is exposed.
This is equivalent to:

    (cl-loop for i CLAUSES... collect i)

For more information on clauses, see
[Loop Facility](https://www.gnu.org/software/emacs/manual/html_node/cl/Loop-Facility.html)

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
    ;; ("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K")

------------------------------------------------------------

### List modification.

#### ls-cons-if-t `(car cdr)`
Create a new cons if CAR is non-nil, else return CDR.

    (ls-cons-if-t 'a '(b c))
    ;; (a b c)
    (ls-cons-if-t nil '(b c))
    ;; (b c)
    (ls-cons-if-t 2 3)
    ;; (2 . 3)
    (ls-cons-if-t nil 3)
    ;; 3

------------------------------------------------------------

### Sublists.

#### ls-take-before-elt `(target list)`
Return the sublist ending immediately before TARGET of LIST.

#### ls-take-to-elt `(target list)`
Return the sublist ending with TARGET of LIST.

#### ls-drop-before-elt `(target list)`
Return the sublist beginning with TARGET of LIST (alias for `memql`).

#### ls-drop-to-elt `(target list)`
Return the sublist starting immediately after TARGET of LIST.

### ls-take-until `(pred list)`
Return the prefix starting with the first argument for which PRED fails.

### ls-drop-until `(pred list)`
Return the suffix starting with the first argument for which PRED fails.

Note that `ls-take-until` and `ls-drop-until` partition a list into two parts
(the prefix before PRED first holds, and the rest).

------------------------------------------------------------

### Predicates.

#### ls-proper? `(list)`
Return `t` if LIST is proper (ie. not dotted).

A proper list is one where each element is the `car` of a cons cell. `nil` is
trivially a proper list.

If the argument is not a list, an error is thrown.

#### ls-improper? `(list)`
Return `t` if LIST is an improper (ie. dotted) list.

An improper list is one where the last element is the `cdr` of a cons cell (with
the second-last element being the `car`). It is represented by dotted notation.

If the argument is not a list, an error is thrown.

#### ls-improper-list? `(object)`
Return `t` if OBJECT is a proper list.

#### fn-proper-list? `(object)`
Return `t` if OBJECT is an improper list.

------------------------------------------------------------

## TODO

* `ls-range`:
    * Allow final `collect` clause (over-riding default of `collect _`). This
    permits `map` functionality, completing list comprehension syntax.
    * Allow initial `for` clause permitting __(a)__ custom iteration variable
    names; and __(b)__ destructuring.
* `ls-take`, `ls-drop` -- DWIM macros allowing clauses to specify various
criteria for choosing a prefix/suffix.
