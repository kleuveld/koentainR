#Create restore_all.R script
lockfile_dirs <- list.dirs("/tmp/lockfiles", recursive = FALSE)

options(renv.config.ignored.packages = c("ggthemewur"))


#options(pkgType = "binary")
#options(pkgType = "source")



for (dir in lockfile_dirs) {
  lockfile_path <- file.path(dir, "renv.lock")
  if (file.exists(lockfile_path)) {
    setwd(dir)
    cat("Restoring from:", lockfile_path, "\n")
    #renv::restore(lockfile = lockfile_path, library = .libPaths()[1], confirm = FALSE)
    renv::restore(lockfile = lockfile_path, confirm = FALSE)
    renv::deactivate()
  }
}