# Credit Default Risk App

A Shiny app for predicting loan default risk, built on the [Home Credit Default Risk](https://www.kaggle.com/c/home-credit-default-risk) dataset and available online via [Shinyapps.io](https://arielrp.shinyapps.io/project/).

---

## Repository structure

```
credit_risk_app/
├── index.html                      # Project landing page (GitHub Pages)
├── ui.R                            # App layout, styling, and input widgets
├── server.R                        # Model training, reactive logic, and plot outputs
├── loan_agg.csv.zip                # Preprocessed dataset (291,643 loans, 13 features)
├── credit_risk_presentation.html   # Rendered slide deck (GitHub Pages)
├── credit_risk_presentation.Rmd    # Slide deck source with embedded R code
└── README.md
```

---

## Data

`loan_agg.csv.zip` contains a CSV file with one row per loan with engineered features derived from two raw Home Credit files:

- `application_train.csv`: Static loan and applicant characteristics
- `installments_payments.csv`: Payment-level history

The aggregation was performed in Python. Raw files are available at [kaggle.com/c/home-credit-default-risk](https://www.kaggle.com/c/home-credit-default-risk).

---
## Notes
### Presentation Tooling 

Originally, the project rubric specified Slidify or RStudio Presenter for the presentation. **Both tools are no longer actively maintained and have known compatibility issues with current versions of R**. As noted by other students in the [JHU course forum](https://www.coursera.org/learn/data-products/discussions/forums/6a3-LF8IEea5lw7yUOQN9w/threads/03qjLBPqEfCAEAr_9gQbYQ), the course no longer teaches either tool. 

As an alternative, this presentation was built using R Markdown ioslides, which is the currently supported equivalent. It renders the same HTML format and is hosted on GitHub Pages per the deployment requirements.

### GitHub Pages

The rubric also requires deployment from a `gh-pages` branch with a `.nojekyll` file, which reflects an earlier GitHub Pages workflow. Both requirements have been followed here, though GitHub now supports deploying directly from `main`.

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
