# Notes on how to setup RENV



From the following discussion:

[Option to change renv folder location
#472](https://github.com/rstudio/renv/issues/472)

We could do this, but I think there's a bunch of things that would have to be done. Here are the places where we make use of the "renv" path by default:

Inside renv/R/paths.R
Lines 68 to 72
```{r}
renv_paths_settings <- function(project = NULL) { 
project <- renv_project_resolve(project) 
components <- c(project, renv_profile_prefix(), "renv/settings.dcf") 
paste(components, collapse = "/") 
} 
```


renv/R/bootstrap.R

Line 474

```{r}
paste(c(project, prefix, "renv/library"), collapse = "/") 
```

renv/renv/activate.R

Lines 607 to 608 in 15b044d

```{r}
# check for a profile file (nothing to do if it doesn't exist) 
path <- file.path(project, "renv/local/profile") 
```

renv/R/infrastructure.R

Lines 73 to 78 in 15b044d

```{r}
renv_infrastructure_write_entry_impl( 
   add    = as.character(add$data()), 
   remove = as.character(remove$data()), 
   file   = file.path(project, "renv/.gitignore"), 
   create = TRUE 
) 
```

renv/R/install.R

Lines 282 to 288 in 15b044d

```{r}
# determine root directory for staging 
root <- if (!is.na(staging)) 
    staging 
else if (!is.na(project)) 
    file.path(project, "renv/staging") 
else 
    file.path(libpath, ".renv") 
```

We'd likely want to add a configuration option autoloader.enabled and also an argument for e.g. renv::init(autoloader = FALSE).


Another example"

```{r}
remotes::install_github("rstudio/renv")

project <- tempfile()
dir.create(project)
setwd(project)

# Disable autoloader, set lockfile path
Sys.setenv(
  RENV_CONFIG_AUTOLOADER_ENABLED = "FALSE",
  RENV_PATHS_LOCKFILE = file.path(project, "scripts/libraries/")
)

renv::init(bare = TRUE, restart = FALSE)
renv::install("estimatr@0.30.4")

renv::snapshot()
```

A more complete solution:

```{r}
Sys.setenv(
  RENV_CONFIG_AUTOLOADER_ENABLED = "FALSE",
  RENV_PATHS_RENV = file.path(project, "scripts/libraries/renv"),
  RENV_PATHS_LOCKFILE = file.path(project, "scripts/libraries/renv.lock")
)

renv::init(bare = TRUE, restart = FALSE)
renv::snapshot()
```