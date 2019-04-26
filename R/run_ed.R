run_ed <- function(ed2in) {
  outfile <- here::here("input", "ED2IN")
  if (fs::file_exists(outfile)) {
    fs::file_delete(outfile)
  }
  write_ed2in(ed2in, outfile, barebones = TRUE)
  prun_ed()
}

prun_ed <- function() {
  wd <- here::here()
  stopifnot(fs::file_exists(fs::path(wd, "docker-compose.yml")))
  processx::run("docker-compose", "up", echo = TRUE)
}
