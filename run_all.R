# Reproduces all tables and figures in Pietryka (2016), Political Psychology.
# Run from the top level of the replication folder. Results are written to output/.

scripts <- list.files("code", pattern = "\\.R$", full.names = TRUE)

for (s in scripts) {
  message("Running ", s)
  source(s, echo = TRUE, max.deparse.length = Inf)
}

writeLines(capture.output(sessionInfo()), "output/sessionInfo.txt")
