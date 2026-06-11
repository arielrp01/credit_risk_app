library(shiny)
library(bslib)

# -- Custom CSS --
app_css <- "
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=IBM+Plex+Mono:wght@400;600&display=swap');

:root {
  --bg:        #f8f9fb;
  --surface:   #ffffff;
  --border:    #e2e6ea;
  --accent:    #2563eb;
  --accent2:   #0ea5e9;
  --text:      #1a202c;
  --muted:     #64748b;
  --low:       #16a34a;
  --med:       #d97706;
  --high:      #dc2626;
  --sidebar:   #1e293b;
  --sidebar-text: #cbd5e1;
  --sidebar-muted: #64748b;
}

body, .shiny-app, html {
  background: var(--bg) !important;
  color: var(--text);
  font-family: 'Inter', sans-serif;
  font-size: 14px;
}

/* -- Sidebar -- */
.sidebar-panel {
  background: var(--sidebar) !important;
  border-right: none;
  padding: 24px 18px;
  height: 100vh;
  overflow-y: auto;
}

.sidebar-title {
  font-family: 'Inter', sans-serif;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.10em;
  text-transform: uppercase;
  color: var(--sidebar-muted);
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}

.input-group-label {
  font-family: 'Inter', sans-serif;
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 0.09em;
  text-transform: uppercase;
  color: var(--sidebar-muted);
  margin-top: 20px;
  margin-bottom: 8px;
}

/* -- Shiny widget overrides (sidebar) -- */
.sidebar-panel .form-control,
.sidebar-panel .selectize-input {
  background: rgba(255,255,255,0.07) !important;
  border: 1px solid rgba(255,255,255,0.12) !important;
  color: var(--sidebar-text) !important;
  border-radius: 5px !important;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
}
.sidebar-panel .selectize-dropdown {
  background: #2d3748 !important;
  border: 1px solid rgba(255,255,255,0.12) !important;
  color: var(--sidebar-text) !important;
}
.sidebar-panel .selectize-dropdown-content .option:hover,
.sidebar-panel .selectize-dropdown-content .option.active {
  background: rgba(255,255,255,0.1) !important;
}

.sidebar-panel .irs--shiny .irs-bar { background: var(--accent) !important; }
.sidebar-panel .irs--shiny .irs-handle { background: var(--accent) !important; border-color: var(--accent) !important; }
.sidebar-panel .irs--shiny .irs-from,
.sidebar-panel .irs--shiny .irs-to,
.sidebar-panel .irs--shiny .irs-single { background: var(--accent) !important; font-size: 10px !important; }
.sidebar-panel .irs--shiny .irs-line { background: rgba(255,255,255,0.15) !important; }
.sidebar-panel .irs--shiny .irs-grid-text { color: var(--sidebar-muted) !important; font-size: 9px !important; }
.sidebar-panel .irs--shiny .irs-min,
.sidebar-panel .irs--shiny .irs-max { color: var(--sidebar-muted) !important; font-size: 9px !important; }

.sidebar-panel .shiny-input-container label {
  color: var(--sidebar-text) !important;
  font-size: 12px;
  font-weight: 400;
}

.sidebar-panel input[type='number'] {
  color: var(--sidebar-text) !important;
}

/* checkbox */
input[type='checkbox'] { accent-color: var(--accent); }

/* -- Action button -- */
#assess_btn {
  width: 100%;
  margin-top: 24px;
  background: var(--accent) !important;
  border: none !important;
  color: #ffffff !important;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 0.03em;
  padding: 11px 0;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.15s;
  box-shadow: 0 1px 3px rgba(37,99,235,0.3);
}
#assess_btn:hover { background: #1d4ed8 !important; }

/* -- Main panel -- */
.main-panel {
  background: var(--bg);
  padding: 28px 32px;
  min-height: 100vh;
}

/* -- App header -- */
.app-header {
  margin-bottom: 24px;
  padding-bottom: 18px;
  border-bottom: 1px solid var(--border);
}
.app-title {
  font-family: 'Inter', sans-serif;
  font-size: 20px;
  font-weight: 600;
  color: var(--text);
  letter-spacing: -0.02em;
  margin: 0 0 4px 0;
}
.app-subtitle {
  font-size: 12px;
  color: var(--muted);
  margin: 0;
}

/* -- Cards -- */
.card {
  background: var(--surface) !important;
  border: 1px solid var(--border) !important;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 18px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}
.card-title {
  font-family: 'Inter', sans-serif;
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 0.10em;
  text-transform: uppercase;
  color: var(--muted);
  margin-bottom: 14px;
}

/* -- Probability display -- */
.prob-container {
  text-align: center;
  padding: 10px 0 6px;
}
.prob-number {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 64px;
  font-weight: 600;
  line-height: 1;
  letter-spacing: -0.04em;
}
.prob-label {
  font-size: 11px;
  color: var(--muted);
  margin-top: 6px;
  font-family: 'Inter', sans-serif;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

/* -- Risk badge -- */
.risk-badge {
  display: inline-block;
  padding: 4px 14px;
  border-radius: 20px;
  font-family: 'Inter', sans-serif;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  margin-top: 12px;
}
.risk-low  { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
.risk-med  { background: #fef3c7; color: #b45309; border: 1px solid #fde68a; }
.risk-high { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }

/* -- Metric tiles -- */
.metrics-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
  margin-bottom: 0;
}
.metric-tile {
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 14px 10px;
  text-align: center;
}
.metric-value {
  font-family: 'IBM Plex Mono', monospace;
  font-size: 22px;
  font-weight: 600;
  color: var(--accent);
  line-height: 1;
}
.metric-label {
  font-family: 'Inter', sans-serif;
  font-size: 9px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--muted);
  margin-top: 5px;
}

/* -- Plot backgrounds -- */
.shiny-plot-output { background: transparent !important; }

/* -- Confusion matrix table -- */
.cm-table {
  width: 100%;
  border-collapse: collapse;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  margin-top: 14px;
}
.cm-table td, .cm-table th {
  padding: 12px 14px;
  border: 1px solid var(--border);
  text-align: center;
}
.cm-table th {
  color: var(--muted);
  font-size: 10px;
  letter-spacing: 0.07em;
  text-transform: uppercase;
  background: var(--bg);
  font-weight: 600;
}
.cm-tn { color: var(--low);    font-size: 20px; font-weight: 700; font-family: 'IBM Plex Mono', monospace; }
.cm-fp { color: var(--med);    font-size: 20px; font-weight: 700; font-family: 'IBM Plex Mono', monospace; }
.cm-fn { color: var(--high);   font-size: 20px; font-weight: 700; font-family: 'IBM Plex Mono', monospace; }
.cm-tp { color: var(--accent); font-size: 20px; font-weight: 700; font-family: 'IBM Plex Mono', monospace; }
.cm-sublabel { display: block; font-size: 9px; color: var(--muted); margin-top: 4px; font-weight: 400; }

/* -- Tabs -- */
.nav-tabs { border-bottom: 1px solid var(--border) !important; margin-bottom: 20px; }
.nav-tabs .nav-link {
  color: var(--muted) !important;
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  font-weight: 500;
  letter-spacing: 0.02em;
  border: none !important;
  padding: 8px 18px;
}
.nav-tabs .nav-link.active {
  color: var(--accent) !important;
  border-bottom: 2px solid var(--accent) !important;
  background: transparent !important;
  font-weight: 600;
}
.nav-tabs .nav-link:hover { color: var(--text) !important; }

/* -- Awaiting input state -- */
.awaiting {
  color: var(--muted);
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  text-align: center;
  padding: 30px 0;
}

/* -- Coeff chart note -- */
.coeff-note {
  font-size: 11px;
  color: var(--muted);
  margin-top: 8px;
  font-style: italic;
}

/* -- About the Model card (sidebar) -- */
.about-card {
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.10);
  border-radius: 6px;
  padding: 14px;
  margin-top: 24px;
}
.about-card-title {
  font-family: 'Inter', sans-serif;
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 0.09em;
  text-transform: uppercase;
  color: var(--sidebar-muted);
  margin-bottom: 8px;
}
.about-card p {
  font-size: 11px;
  color: var(--sidebar-text);
  line-height: 1.6;
  margin: 0 0 6px 0;
}
.about-card p:last-child { margin-bottom: 0; }

/* -- How to Use tab -- */
.how-section { margin-bottom: 24px; }
.how-section-title {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: var(--text);
  margin: 0 0 8px 0;
  padding-bottom: 6px;
  border-bottom: 1px solid var(--border);
}
.how-section p {
  font-size: 13px;
  color: var(--text);
  line-height: 1.7;
  margin: 0 0 8px 0;
}
.scenario-card {
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 14px 16px;
  margin-bottom: 12px;
}
.scenario-title {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  font-weight: 600;
  margin-bottom: 8px;
}
.scenario-low  { border-left: 3px solid #16a34a; }
.scenario-med  { border-left: 3px solid #d97706; }
.scenario-high { border-left: 3px solid #dc2626; }
.scenario-card table { width: 100%; font-size: 12px; border-collapse: collapse; }
.scenario-card td { padding: 3px 8px 3px 0; color: var(--text); }
.scenario-card td:first-child { color: var(--muted); width: 55%; }
.glossary-table { width: 100%; font-size: 12px; border-collapse: collapse; }
.glossary-table td {
  padding: 8px 12px;
  border-bottom: 1px solid var(--border);
  vertical-align: top;
  line-height: 1.6;
}
.glossary-table td:first-child { font-weight: 600; color: var(--accent); white-space: nowrap; width: 22%; }
.glossary-table tr:last-child td { border-bottom: none; }
.limitations-list { font-size: 13px; color: var(--text); line-height: 1.8; padding-left: 18px; margin: 0; }

/* -- Footer -- */
.app-footer {
  margin-top: 40px;
  padding: 16px 0 24px;
  border-top: 1px solid var(--border);
  text-align: center;
  font-size: 11px;
  color: var(--muted);
}
"

# -- UI --
ui <- fluidPage(
  tags$head(
    tags$style(HTML(app_css)),
    tags$title("Credit Default Risk App")
  ),

  sidebarLayout(

    # -- SIDEBAR --
    sidebarPanel(width = 3,
      class = "sidebar-panel",

      div(class = "sidebar-title", "Loan Inputs"),

      # -- Static loan features --
      div(class = "input-group-label", "Loan Characteristics"),

      numericInput("amt_credit", "Loan Amount ($)",
                   value = 300000, min = 10000, max = 2000000, step = 5000),

      numericInput("amt_income", "Annual Income ($)",
                   value = 150000, min = 10000, max = 2000000, step = 5000),

      # -- Payment behavior --
      div(class = "input-group-label", "Payment Behavior"),

      sliderInput("frac_late", "Fraction of Late Payments",
                  min = 0, max = 1, value = 0.1, step = 0.01),

      sliderInput("mean_days_late", "Mean Days Late",
                  min = -30, max = 90, value = 0, step = 1),

      sliderInput("max_days_late", "Worst Single Late Payment (days)",
                  min = -30, max = 365, value = 5, step = 1),

      sliderInput("mean_pay_ratio", "Avg Pay Ratio (payment / scheduled)",
                  min = 0, max = 3, value = 1.0, step = 0.01),

      sliderInput("frac_underpay", "Fraction of Underpayments",
                  min = 0, max = 1, value = 0.05, step = 0.01),

      sliderInput("frac_on_time", "Fraction Paid On Time",
                  min = 0, max = 1, value = 0.90, step = 0.01),

      numericInput("n_payments", "Number of Payments on Record",
                   value = 24, min = 1, max = 200, step = 1),

      # -- Threshold --
      div(class = "input-group-label", "Decision Threshold"),

      sliderInput("threshold", NULL,
                  min = 0.05, max = 0.50, value = 0.10, step = 0.01),

      actionButton("assess_btn", "Assess Risk", icon = icon("shield-halved")),

      # -- About the Model --
      div(class = "about-card",
        div(class = "about-card-title", "About the Model"),
        p("Logistic regression trained on 291,643 real loan records from the Home Credit Default Risk dataset."),
        p("Class balance: 91.8% repaid | 8.2% defaulted"),
        p("Test set AUC: ~0.605")
      )
    ),

    # -- MAIN PANEL --
    mainPanel(width = 9,
      class = "main-panel",

      # Header
      div(class = "app-header",
        h1(class = "app-title", "Credit Default Risk App"),
        p(class = "app-subtitle",
          "Home Credit Default Risk | Logistic Regression Baseline")
      ),

      tabsetPanel(id = "main_tabs",

        # -- TAB 0: How to Use --
        tabPanel("How to Use",
          br(),

          # What this app does
          div(class = "card",
            div(class = "how-section",
              p(class = "how-section-title", "What this app does"),
              p("This app estimates the probability that a loan applicant will default and fail to repay their loan. It is built on 291,643 real loan records from Home Credit, a consumer finance company, and uses a logistic regression model trained on applicants' payment behavior and loan characteristics."),
              p("Enter an applicant's details in the sidebar and click Assess Risk to receive a default probability, a risk verdict, and a breakdown of which factors most influenced the prediction.")
            ),

            # How to use
            div(class = "how-section",
              p(class = "how-section-title", "Step-by-step"),
              tags$ol(style = "font-size:13px; line-height:2; padding-left:18px; margin:0;",
                tags$li("Set the applicant's ", tags$strong("Loan Amount"), " and ", tags$strong("Annual Income"), " in the sidebar."),
                tags$li("Adjust the ", tags$strong("Payment Behavior"), " sliders to reflect the applicant's history."),
                tags$li("Set the ", tags$strong("Decision Threshold"), " the probability cutoff above which an applicant is flagged as High Risk. The default is 10%."),
                tags$li("Click ", tags$strong("Assess Risk"), " to generate a prediction."),
                tags$li("Drag the threshold slider to see how the risk verdict and model metrics change in real time.")
              )
            ),

            # Three scenarios
            div(class = "how-section",
              p(class = "how-section-title", "Try these scenarios"),
              p("Use the inputs below to recreate three representative profiles. Leave all other inputs at their default values."),

              div(class = "scenario-card scenario-low",
                div(class = "scenario-title", style = "color:#15803d;", " Low Risk - Reliable borrower"),
                tags$table(
                  tags$tr(tags$td("Fraction of Late Payments"), tags$td(tags$strong("0"))),
                  tags$tr(tags$td("Mean Days Late"),             tags$td(tags$strong("-20"))),
                  tags$tr(tags$td("Fraction Paid On Time"),      tags$td(tags$strong("1.0")))
                ),
                tags$p(style = "font-size:11px; color:#64748b; margin:8px 0 0;",
                  "Expected: ~5-7% probability | Low Risk badge")
              ),

              div(class = "scenario-card scenario-med",
                div(class = "scenario-title", style = "color:#b45309;", " Borderline - Typical applicant"),
                tags$table(
                  tags$tr(tags$td("Fraction of Late Payments"), tags$td(tags$strong("0.1"))),
                  tags$tr(tags$td("Mean Days Late"),             tags$td(tags$strong("0"))),
                  tags$tr(tags$td("Fraction Paid On Time"),      tags$td(tags$strong("0.9")))
                ),
                tags$p(style = "font-size:11px; color:#64748b; margin:8px 0 0;",
                  "Expected: ~6-8% probability | Borderline badge")
              ),

              div(class = "scenario-card scenario-high",
                div(class = "scenario-title", style = "color:#b91c1c;", " High Risk - Poor payment history"),
                tags$table(
                  tags$tr(tags$td("Fraction of Late Payments"), tags$td(tags$strong("0.8"))),
                  tags$tr(tags$td("Mean Days Late"),             tags$td(tags$strong("60"))),
                  tags$tr(tags$td("Fraction Paid On Time"),      tags$td(tags$strong("0.1")))
                ),
                tags$p(style = "font-size:11px; color:#64748b; margin:8px 0 0;",
                  "Expected: ~18-22% probability | High Risk badge")
              )
            ),

            # Output glossary
            div(class = "how-section",
              p(class = "how-section-title", "Understanding the outputs"),
              tags$table(class = "glossary-table",
                tags$tr(
                  tags$td("Default Probability"),
                  tags$td("The model's estimated chance (0-100%) that this applicant will fail to repay. This is a risk score, not a guarantee.")
                ),
                tags$tr(
                  tags$td("Risk Badge"),
                  tags$td("Green = probability is well below the threshold. Amber = close to the threshold. Red = exceeds the threshold.")
                ),
                tags$tr(
                  tags$td("Decision Threshold"),
                  tags$td("The cutoff probability above which an applicant is flagged as High Risk. Lowering it catches more defaulters but also flags more creditworthy borrowers as risky.")
                ),
                tags$tr(
                  tags$td("Confusion Matrix"),
                  tags$td("Shows model performance on the held-out test set. True Negatives and True Positives are correct predictions. False Positives are good borrowers wrongly flagged; False Negatives are missed defaulters.")
                ),
                tags$tr(
                  tags$td("Recall"),
                  tags$td("The share of actual defaulters the model correctly identifies. At the default threshold of 10%, recall is ~28%. Lowering the threshold increases recall.")
                ),
                tags$tr(
                  tags$td("AUC"),
                  tags$td("Area Under the ROC Curve. Measures how well the model ranks defaulters above non-defaulters, independent of threshold. This model achieves ~0.605 (random = 0.5, perfect = 1.0).")
                ),
                tags$tr(
                  tags$td("Feature Contributions"),
                  tags$td("Standardized log-odds coefficients. Red bars increase default risk; green bars reduce it. Log Instalment and Fraction On Time are the strongest signals in this model.")
                )
              )
            ),

            # Limitations
            div(class = "how-section",
              p(class = "how-section-title", "Limitations"),
              tags$ul(class = "limitations-list",
                tags$li("AUC of ~0.605 is modest. Production credit models using the full feature set reach ~0.78-0.80."),
                tags$li("No fairness audit has been performed. Real lending decisions require group-level disparity analysis under fair lending law."),
                tags$li("The model is static and does not update as new data arrives."),
                tags$li(tags$strong("This app is for educational purposes only and should not be used to make actual credit decisions."))
              )
            )
          ) # end card
        ), # end How to Use tab

        # -- TAB 1: Risk Assessment --
        tabPanel("Risk Assessment",

          fluidRow(

            # Left col - probability + badge
            column(4,
              div(class = "card",
                div(class = "card-title", "Default Probability"),
                div(class = "prob-container",
                  uiOutput("prob_display")
                )
              ),

              div(class = "card",
                div(class = "card-title", "Threshold Sensitivity"),
                plotOutput("threshold_plot", height = "130px")
              )
            ),

            # Right col - metrics + confusion matrix
            column(8,
              div(class = "card",
                div(class = "card-title", "Model Performance at Current Threshold"),
                uiOutput("metrics_tiles"),
                br(),
                uiOutput("confusion_matrix")
              )
            )
          ),

          fluidRow(
            column(12,
              div(class = "card",
                div(class = "card-title", "Feature Contributions (Log-Odds)"),
                plotOutput("coeff_plot", height = "220px"),
                p(class = "coeff-note",
                  "Bars show standardized log-odds coefficients. A positive (red) coefficient means the feature is associated with higher default risk; a negative (green) coefficient means it is associated with lower risk.")
              )
            )
          )
        ),

        # -- TAB 2: ROC & Precision-Recall --
        tabPanel("ROC & Precision-Recall",
          fluidRow(
            column(6,
              div(class = "card",
                div(class = "card-title", "ROC Curve - Test Set"),
                plotOutput("roc_plot", height = "300px")
              )
            ),
            column(6,
              div(class = "card",
                div(class = "card-title", "Precision-Recall Curve - Test Set"),
                plotOutput("pr_plot", height = "300px")
              )
            )
          ),
          fluidRow(
            column(12,
              div(class = "card",
                div(class = "card-title", "Threshold Sweep - Recall vs Precision vs F1"),
                plotOutput("threshold_sweep_plot", height = "250px")
              )
            )
          )
        ),

        # -- TAB 3: Data Explorer --
        tabPanel("Data Explorer",
          fluidRow(
            column(6,
              div(class = "card",
                div(class = "card-title", "Default Rate by Days Late Bucket"),
                plotOutput("days_late_plot", height = "260px")
              )
            ),
            column(6,
              div(class = "card",
                div(class = "card-title", "Predicted Probability Distribution"),
                plotOutput("prob_dist_plot", height = "260px")
              )
            )
          ),
          fluidRow(
            column(12,
              div(class = "card",
                div(class = "card-title", "Feature Distributions by Default Status"),
                selectInput("explorer_feature", NULL,
                  choices = c(
                    "Fraction Late"      = "frac_late",
                    "Mean Days Late"     = "mean_days_late",
                    "Mean Pay Ratio"     = "mean_pay_ratio",
                    "Fraction On Time"   = "frac_on_time",
                    "Loan Amount"        = "AMT_CREDIT",
                    "Annual Income"      = "AMT_INCOME_TOTAL"
                  ),
                  width = "240px"
                ),
                plotOutput("feature_dist_plot", height = "220px")
              )
            )
          )
        )
      ), # end tabsetPanel

      # -- Footer --
      div(class = "app-footer",
        "Built with R Shiny | ",
        tags$a(href = "https://github.com/arielrp01/credit_risk_app",
               target = "_blank",
               style = "color: #64748b;",
               "View on GitHub")
      )

    )   # end mainPanel
  )     # end sidebarLayout
)
