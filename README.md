# Credit Default Risk App

A Shiny app for predicting loan default risk, built on the [Home Credit Default Risk](https://www.kaggle.com/c/home-credit-default-risk) dataset.

View app at https://arielrp.shinyapps.io/project/

---

## Repository structure

```
credit_risk_app/
├── index.html                      # Project landing page (GitHub Pages)
├── ui.R                            # App layout, styling, and input widgets
├── server.R                        # Model training, reactive logic, and plot outputs
├── loan_agg.csv.zip                # Preprocessed dataset (291,643 loans, 13 features)
├── credit_risk_presentation.html   # Rendered slide deck
├── credit_risk_presentation.Rmd    # Slide deck source with embedded R code
└── README.md
```

---

## Data

`loan_agg.csv` contains one row per loan with engineered features derived from two raw Home Credit files:

- `application_train.csv`: Static loan and applicant characteristics
- `installments_payments.csv`: Payment-level history

The aggregation was performed in Python. Raw files are available at [kaggle.com/c/home-credit-default-risk](https://www.kaggle.com/c/home-credit-default-risk).

---

## Requirements

- R 4.0 or higher
- The following packages:

```r
install.packages(c("shiny", "ggplot2", "bslib"))
```
---

## Built with

- [R](https://www.r-project.org/) / [Shiny](https://shiny.posit.co/)
- [ggplot2](https://ggplot2.tidyverse.org/)
- [bslib](https://rstudio.github.io/bslib/)
- [Home Credit Default Risk dataset](https://www.kaggle.com/c/home-credit-default-risk) via Kaggle
