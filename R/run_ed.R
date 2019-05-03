run_ed <- function(ed2in, ...) {
  outfile <- here::here("input", "ED2IN")
  if (fs::file_exists(outfile)) {
    fs::file_delete(outfile)
  }
  write_ed2in(ed2in, outfile, barebones = TRUE)
  prun_ed(...)
}

prun_ed <- function(profile = FALSE, ...) {
  wd <- here::here()
  stopifnot(fs::file_exists(fs::path(wd, "docker-compose.yml")))
  cmd <- if (profile) "ed-profile" else "ed"
  processx::run("docker-compose", c("up", cmd), ...)
}
