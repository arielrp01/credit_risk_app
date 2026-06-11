# Credit Default Risk App

An interactive Shiny app for predicting loan default risk, built on the [Home Credit Default Risk](https://www.kaggle.com/c/home-credit-default-risk) dataset.

View app at https://arielrp.shinyapps.io/project/.

---

## Repository structure

```
credit_risk_app/
├── ui.R            # App layout, styling, and input widgets
├── server.R        # Model training, reactive logic, and plot outputs
├── loan_agg.csv    # Preprocessed dataset (291,643 loans, 13 features)
└── README.md
```

---

## Requirements

- R 4.0 or higher
- The following packages:

```r
install.packages(c("shiny", "ggplot2", "bslib"))
```

---

## Data

`loan_agg.csv` contains one row per loan with engineered features derived from two raw Home Credit files:

- `application_train.csv` — static loan and applicant characteristics
- `installments_payments.csv` — payment-level history

The aggregation was performed in Python. Raw files are available at [kaggle.com/c/home-credit-default-risk](https://www.kaggle.com/c/home-credit-default-risk).

---

## Background

This app was developed as an extension of a machine learning project completed for UC Berkeley COMPSCI X433.6. The original project compared a logistic regression baseline against an LSTM-based sequence model for credit default prediction. This app brings the logistic regression component to life as an interactive tool.

---

## Built with

- [R](https://www.r-project.org/) / [Shiny](https://shiny.posit.co/)
- [ggplot2](https://ggplot2.tidyverse.org/)
- [bslib](https://rstudio.github.io/bslib/)
- [Home Credit Default Risk dataset](https://www.kaggle.com/c/home-credit-default-risk) via Kaggle
