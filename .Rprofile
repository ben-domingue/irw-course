# Rendering reads this file instead of the renderer's ~/.Rprofile. It sits at the
# project root because Quarto starts R here (not in lessons/), and R uses a
# .Rprofile in its working directory in place of the user's. It keeps rendered
# pages independent of anyone's personal settings: no seeds, digits or other
# options leak in, so a page prints what a fresh R session prints and the
# downloadable code gives readers the same numbers. Seeds are set in lesson code.
# (Ben's ~/.Rprofile sets digits = 2 and set.seed(1234); fixed 09-25.)
invisible(NULL)
