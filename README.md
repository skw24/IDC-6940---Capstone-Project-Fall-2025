# IDC-6940---Capstone-Project-Fall-2025
 
Authors:
- Renan Monteiro Barbosa
- Kristina Kusem
- Shree Krishna Basnet
- Steve Wong

Group Project:

Predicting stroke risk from common health indicators: a binary logistic regression analysis

Will be usind the Kaggle's [Stroke Prediction Dataset](https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset)

## Getting Started

Its preferable that you Fork the repo. Likewise you can clone this repository directly or clone your fork into your local machine.

Example:

```bash
# or anywhere you prefer
cd ~
git clone https://github.com/renanmb/IDC-6940---Capstone-Project-Fall-2025
```

### Install dependencies

TODO - Explore either making a script or show how to setup renv

Make sure you have R and quarto installed on your machine.


Install dependencies directly in R

Step 1 - Install the package remotes so you an install the custom package getsysreqs

```R
install.packages("remotes")
remotes::install_github("mdneuzerling/getsysreqs")
```

Step 2 - Running this command in R will get your all the System Dependencies for the packages in the renv.lock

This example is using the ubuntu 22.04

```R
library(getsysreqs)
get_sysreqs(
  "renv.lock",
  distribution = "ubuntu",
  release = "22.04"
)
```

Step 3 - Install base system dependencies for R packages according to the output of the previous command.

Example:

```bash
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev
```


```bash
mkdir -p $R_LIBS_USER
Rscript -e "install.packages('remotes', repos='https://cloud.r-project.org')"
Rscript -e ".libPaths(c(Sys.getenv('R_LIBS_USER'), .libPaths())); remotes::install_github('mdneuzerling/getsysreqs')"
Rscript -e ".libPaths(c(Sys.getenv('R_LIBS_USER'), .libPaths())); library(getsysreqs); packageVersion('getsysreqs')"
```

```bash
Rscript -e ".libPaths(c(Sys.getenv('R_LIBS_USER'), .libPaths())); \
    sysreqs <- getsysreqs::get_sysreqs('website/renv.lock', distribution='ubuntu', release='22.04'); \
    cat(sysreqs)"
sysreqs=$(Rscript -e ".libPaths(c(Sys.getenv('R_LIBS_USER'), .libPaths())); cat(getsysreqs::get_sysreqs('website/renv.lock', distribution='ubuntu', release='22.04'))")
if [ ! -z "$sysreqs" ]; then
    echo "Installing system requirements: $sysreqs"
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends $sysreqs
else
    echo "No system requirements found."
fi
```

### Usage

You can always refer to [Quarto Website docs](https://quarto.org/docs/websites/)

In the terminal in VScode you run both commands to render then preview the website.

```bash
# render the website in the current directory
quarto render 
```

```bash
# preview the website in the current directory
quarto preview
```

