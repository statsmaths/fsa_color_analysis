show_image <- function(img_paths, ncol=1)
{
  n <- length(img_paths)
  m <- ceiling(n / ncol)
  par(mfrow=c(m, ncol))

  for (j in seq_along(img_paths))
  {
    par(mar=c(0, 0, 0, 0))
    img <- jpeg::readJPEG(img_paths[j])
    plot.new()
    plot.window(
      xlim=c(0, ncol(img)),
      ylim=c(0, nrow(img)),
      asp = (ncol(img) / nrow(img))
    )
    rasterImage(img, 0, 0, ncol(img), nrow(img), interpolate = FALSE)
  }
}

show_image_array <- function(img)
{
  par(mar=c(0, 0, 0, 0))
  plot.new()
  plot.window(
    xlim=c(0, ncol(img)),
    ylim=c(0, nrow(img)),
    asp = (ncol(img) / nrow(img))
  )
  rasterImage(img, 0, 0, ncol(img), nrow(img), interpolate = FALSE)
}
