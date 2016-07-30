checkHash <- function(s) {
  # This function is designed to fix the problem of wrong colour paramters from the widget jscolorInput.
  # colorRampPalette() of plotTree() uses col2rgb(), which takes strings like "#FFFFFF" but not "FFFFFF" as the input.
  # therefore a '#' must be added to the beginnging of every initial input$*_col which does not contain the hash sign.
  # However, the value picked up from the pop-up palette returns value starting from '#'.
  # This disconsistancy between return values from the input box and the pop-up palette could be a bug of jscolorInput.
  # FYI, errors of col2rgb:
  #   col2rgb("FFFFFF"): invalid color name 'FFFFFF'
  #   col2rgb("##FFFFFF"): invalid RGB specification
  if (substring(s, 1, 1) != '#') {  # for values from the input box of jscolorInput
    return(paste('#', s, sep = ''))
  } else {
    return(s)  # for values picked up from the pop-up palette
  }
}