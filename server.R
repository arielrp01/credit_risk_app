library(shiny)
library(ggplot2)

# ── Palette (matches CSS variables) ─────────────────────────────────────────
COL_BG      <- "#f8f9fb"
COL_SURFACE <- "#ffffff"
COL_BORDER  <- "#e2e6ea"
COL_ACCENT  <- "#2563eb"
COL_ACCENT2 <- "#0ea5e9"
COL_TEXT    <- "#1a202c"
COL_MUTED   <- "#64748b"
COL_LOW     <- "#16a34a"
COL_MED     <- "#d97706"
COL_HIGH    <- "#dc2626"

# ── ggplot2 light theme ───────────────────────────────────────────────────────
theme_credit <- function() {
  theme_minimal(base_family = "sans") +
    theme(
      plot.background    = element_rect(fill = COL_SURFACE, color = NA),
      panel.background   = element_rect(fill = COL_SURFACE, color = NA),
      panel.grid.major   = element_line(color = COL_BORDER, linewidth = 0.4),
      panel.grid.minor   = element_blank(),
      axis.text          = element_text(color = COL_MUTED,  size = 9),
      axis.title         = element_text(color = COL_MUTED,  size = 9),
      plot.title         = element_text(color = COL_TEXT,   size = 10, face = "bold"),
      legend.background  = element_rect(fill = COL_SURFACE, color = NA),
      legend.text        = element_text(color = COL_MUTED,  size = 8),
      legend.title       = element_text(color = COL_MUTED,  size = 8),
      strip.text         = element_text(color = COL_MUTED,  size = 8)
    )
}

# ── Load real data ────────────────────────────────────────────────────────────
loan_data <- read.csv("loan_agg.csv")

# ── Feature names (matching server input IDs) ────────────────────────────────
TAB_FEATURES <- c(
  "n_payments", "mean_days_late", "max_days_late",
  "frac_late", "mean_pay_ratio", "frac_underpay", "frac_on_time",
  "mean_log_instalment", "mean_log_payment",
  "AMT_CREDIT", "AMT_INCOME_TOTAL"
)

FEATURE_LABELS <- c(
  "n_payments"          = "# Payments",
  "mean_days_late"      = "Mean Days Late",
  "max_days_late"       = "Max Days Late",
  "frac_late"           = "Frac Late",
  "mean_pay_ratio"      = "Avg Pay Ratio",
  "frac_underpay"       = "Frac Underpay",
  "frac_on_time"        = "Frac On Time",
  "mean_log_instalment" = "Log Instalment",
  "mean_log_payment"    = "Log Payment",
  "AMT_CREDIT"          = "Loan Amount",
  "AMT_INCOME_TOTAL"    = "Annual Income"
)

# ── Train / test split ────────────────────────────────────────────────────────
set.seed(42)
N <- nrow(loan_data)
train_idx  <- sample(seq_len(N), size = round(0.7 * N))
train_data <- loan_data[ train_idx, ]
test_data  <- loan_data[-train_idx, ]

# ── Fit logistic regression (same as HW3 baseline) ───────────────────────────
X_train <- scale(train_data[, TAB_FEATURES])
scale_center <- attr(X_train, "scaled:center")
scale_scale  <- attr(X_train, "scaled:scale")

logreg_model <- glm(
  TARGET ~ .,
  data   = as.data.frame(cbind(X_train, TARGET = train_data$TARGET)),
  family = binomial(link = "logit")
)

# ── Precompute test-set predictions ──────────────────────────────────────────
X_test_scaled <- scale(test_data[, TAB_FEATURES],
                        center = scale_center, scale = scale_scale)
test_probs <- predict(logreg_model,
                      newdata = as.data.frame(X_test_scaled),
                      type    = "response")

# ── Helper: compute confusion matrix metrics at a threshold ──────────────────
cm_metrics <- function(y_true, y_prob, threshold) {
  y_pred <- as.integer(y_prob >= threshold)
  TP <- sum(y_pred == 1 & y_true == 1)
  TN <- sum(y_pred == 0 & y_true == 0)
  FP <- sum(y_pred == 1 & y_true == 0)
  FN <- sum(y_pred == 0 & y_true == 1)
  precision <- if ((TP + FP) > 0) TP / (TP + FP) else 0
  recall    <- if ((TP + FN) > 0) TP / (TP + FN) else 0
  f1        <- if ((precision + recall) > 0) 2 * precision * recall / (precision + recall) else 0
  accuracy  <- (TP + TN) / length(y_true)
  list(TP = TP, TN = TN, FP = FP, FN = FN,
       precision = precision, recall = recall, f1 = f1, accuracy = accuracy)
}

# ── Precompute ROC curve data ─────────────────────────────────────────────────
roc_data <- local({
  thresholds <- seq(0, 1, length.out = 200)
  y <- test_data$TARGET
  p <- test_probs
  do.call(rbind, lapply(thresholds, function(t) {
    m  <- cm_metrics(y, p, t)
    fpr <- if ((m$FP + m$TN) > 0) m$FP / (m$FP + m$TN) else 0
    data.frame(threshold = t, fpr = fpr, tpr = m$recall)
  }))
})

# AUC via trapezoid
auc_val <- local({
  rd <- roc_data[order(roc_data$fpr), ]
  sum(diff(rd$fpr) * (head(rd$tpr, -1) + tail(rd$tpr, -1))) / 2
})

# ── Precompute PR curve data ──────────────────────────────────────────────────
pr_data <- local({
  thresholds <- seq(0, 1, length.out = 200)
  y <- test_data$TARGET
  p <- test_probs
  do.call(rbind, lapply(thresholds, function(t) {
    m <- cm_metrics(y, p, t)
    data.frame(threshold = t, precision = m$precision, recall = m$recall)
  }))
})

# ── Precompute threshold sweep ────────────────────────────────────────────────
sweep_data <- local({
  thresholds <- seq(0.02, 0.50, by = 0.01)
  y <- test_data$TARGET
  p <- test_probs
  do.call(rbind, lapply(thresholds, function(t) {
    m <- cm_metrics(y, p, t)
    data.frame(threshold = t,
               precision = m$precision, recall = m$recall, f1 = m$f1)
  }))
})

# ── Coefficient data (standardized log-odds) ─────────────────────────────────
coeff_data <- local({
  co <- coef(logreg_model)
  co <- co[names(co) != "(Intercept)"]
  data.frame(
    feature = factor(FEATURE_LABELS[names(co)], levels = FEATURE_LABELS[names(co)]),
    coeff   = as.numeric(co),
    direction = ifelse(as.numeric(co) > 0, "risk", "safe")
  )
})


# ════════════════════════════════════════════════════════════════════════════
# SERVER
# ════════════════════════════════════════════════════════════════════════════
server <- function(input, output, session) {

  # ── Reactive: build new-loan data frame from sidebar inputs ───────────────
  new_loan_raw <- eventReactive(input$assess_btn, {
    # Derive log-transformed amounts (mirrors HW3 preprocessing)
    log_inst <- log1p(input$amt_credit  / 12)   # approximate monthly instalment
    log_pay  <- log1p(input$amt_credit  / 12 * input$mean_pay_ratio)

    data.frame(
      n_payments           = input$n_payments,
      mean_days_late       = input$mean_days_late,
      max_days_late        = input$max_days_late,
      frac_late            = input$frac_late,
      mean_pay_ratio       = input$mean_pay_ratio,
      frac_underpay        = input$frac_underpay,
      frac_on_time         = input$frac_on_time,
      mean_log_instalment  = log_inst,
      mean_log_payment     = log_pay,
      AMT_CREDIT           = input$amt_credit,
      AMT_INCOME_TOTAL     = input$amt_income
    )
  })

  # ── Reactive: scale and predict ───────────────────────────────────────────
  predicted_prob <- reactive({
    req(new_loan_raw())
    x_scaled <- scale(new_loan_raw()[, TAB_FEATURES],
                      center = scale_center, scale = scale_scale)
    predict(logreg_model, newdata = as.data.frame(x_scaled), type = "response")
  })

  # ── Reactive: threshold (live — not gated on button) ─────────────────────
  current_threshold <- reactive({ input$threshold })

  # ── Reactive: metrics at current threshold ────────────────────────────────
  current_metrics <- reactive({
    cm_metrics(test_data$TARGET, test_probs, current_threshold())
  })


  # ── OUTPUT: probability display ───────────────────────────────────────────
  output$prob_display <- renderUI({
    if (is.null(new_loan_raw())) {
      return(div(class = "awaiting", "Press 'Assess Risk' to score a loan"))
    }

    prob  <- predicted_prob()
    pct   <- round(prob * 100, 1)
    thresh <- current_threshold()

    verdict <- if (prob < thresh * 0.6) "low"
               else if (prob < thresh)  "medium"
               else                     "high"

    color <- switch(verdict,
                    low    = COL_LOW,
                    medium = COL_MED,
                    high   = COL_HIGH)

    badge_class <- paste0("risk-badge risk-", verdict)
    badge_text  <- switch(verdict,
                          low    = "Low Risk",
                          medium = "Borderline",
                          high   = "High Risk")

    tagList(
      div(class = "prob-number", style = paste0("color:", color),
          paste0(pct, "%")),
      div(class = "prob-label", "estimated default probability"),
      br(),
      span(class = badge_class, badge_text)
    )
  })

  # ── OUTPUT: threshold sensitivity sparkline ───────────────────────────────
  output$threshold_plot <- renderPlot({
    thresh_vals <- seq(0.02, 0.50, by = 0.005)

    probs_vec <- if (!is.null(new_loan_raw())) {
      rep(as.numeric(predicted_prob()), length(thresh_vals))
    } else {
      rep(NA, length(thresh_vals))
    }

    df <- data.frame(
      threshold = thresh_vals,
      decision  = thresh_vals  # the line we cross
    )

    p <- ggplot(df, aes(x = threshold)) +
      geom_vline(xintercept = current_threshold(),
                 color = COL_ACCENT2, linewidth = 0.8, linetype = "dashed") +
      theme_credit() +
      theme(panel.grid.major = element_blank(),
            axis.title.y = element_blank(),
            axis.text.y  = element_blank()) +
      labs(x = "Threshold", title = NULL)

    if (!is.null(new_loan_raw())) {
      p_val <- as.numeric(predicted_prob())
      p <- p +
        geom_hline(yintercept = p_val, color = COL_ACCENT, linewidth = 0.6) +
        annotate("point", x = current_threshold(), y = p_val,
                 color = if (p_val >= current_threshold()) COL_HIGH else COL_LOW,
                 size = 3) +
        scale_y_continuous(limits = c(0, 1)) +
        labs(y = "Default Probability")
    }

    p
  }, bg = COL_SURFACE)

  # ── OUTPUT: metric tiles ──────────────────────────────────────────────────
  output$metrics_tiles <- renderUI({
    m <- current_metrics()
    fmt <- function(x) sprintf("%.1f%%", x * 100)

    div(class = "metrics-row",
      div(class = "metric-tile",
        div(class = "metric-value", fmt(m$accuracy)),
        div(class = "metric-label", "Accuracy")),
      div(class = "metric-tile",
        div(class = "metric-value", style = paste0("color:", COL_ACCENT),
            fmt(m$recall)),
        div(class = "metric-label", "Recall")),
      div(class = "metric-tile",
        div(class = "metric-value", fmt(m$precision)),
        div(class = "metric-label", "Precision")),
      div(class = "metric-tile",
        div(class = "metric-value", fmt(m$f1)),
        div(class = "metric-label", "F1"))
    )
  })

  # ── OUTPUT: confusion matrix ──────────────────────────────────────────────
  output$confusion_matrix <- renderUI({
    m <- current_metrics()
    tags$table(class = "cm-table",
      tags$thead(
        tags$tr(
          tags$th(""),
          tags$th("Predicted: No Default"),
          tags$th("Predicted: Default")
        )
      ),
      tags$tbody(
        tags$tr(
          tags$th("Actual: No Default"),
          tags$td(class = "cm-tn",
            m$TN, tags$span(class = "cm-sublabel", "True Negative")),
          tags$td(class = "cm-fp",
            m$FP, tags$span(class = "cm-sublabel", "False Positive"))
        ),
        tags$tr(
          tags$th("Actual: Default"),
          tags$td(class = "cm-fn",
            m$FN, tags$span(class = "cm-sublabel", "False Negative")),
          tags$td(class = "cm-tp",
            m$TP, tags$span(class = "cm-sublabel", "True Positive"))
        )
      )
    )
  })

  # ── OUTPUT: coefficient plot ──────────────────────────────────────────────
  output$coeff_plot <- renderPlot({
    df <- coeff_data[order(coeff_data$coeff), ]
    df$feature <- factor(df$feature, levels = df$feature)

    ggplot(df, aes(x = coeff, y = feature, fill = direction)) +
      geom_col(width = 0.65) +
      geom_vline(xintercept = 0, color = COL_MUTED, linewidth = 0.5) +
      scale_fill_manual(values = c(risk = COL_HIGH, safe = COL_LOW),
                        guide = "none") +
      labs(x = "Standardized Log-Odds", y = NULL) +
      theme_credit() +
      theme(axis.text.y = element_text(size = 9, color = COL_TEXT))
  }, bg = COL_SURFACE)

  # ── OUTPUT: ROC curve ─────────────────────────────────────────────────────
  output$roc_plot <- renderPlot({
    thresh <- current_threshold()
    m      <- cm_metrics(test_data$TARGET, test_probs, thresh)
    fpr_pt <- if ((m$FP + m$TN) > 0) m$FP / (m$FP + m$TN) else 0
    tpr_pt <- m$recall

    ggplot(roc_data, aes(x = fpr, y = tpr)) +
      geom_abline(slope = 1, intercept = 0,
                  color = COL_BORDER, linetype = "dashed") +
      geom_line(color = COL_ACCENT2, linewidth = 1) +
      geom_point(aes(x = fpr_pt, y = tpr_pt),
                 color = COL_ACCENT, size = 3.5) +
      annotate("text", x = 0.6, y = 0.15,
               label = paste0("AUC = ", round(auc_val, 3)),
               color = COL_MUTED, size = 3.2, family = "mono") +
      labs(x = "False Positive Rate", y = "True Positive Rate") +
      coord_equal() +
      theme_credit()
  }, bg = COL_SURFACE)

  # ── OUTPUT: PR curve ──────────────────────────────────────────────────────
  output$pr_plot <- renderPlot({
    thresh <- current_threshold()
    m      <- cm_metrics(test_data$TARGET, test_probs, thresh)

    ggplot(pr_data, aes(x = recall, y = precision)) +
      geom_line(color = COL_ACCENT2, linewidth = 1) +
      geom_point(aes(x = m$recall, y = m$precision),
                 color = COL_ACCENT, size = 3.5) +
      geom_hline(yintercept = mean(test_data$TARGET),
                 color = COL_BORDER, linetype = "dashed") +
      labs(x = "Recall", y = "Precision") +
      coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) +
      theme_credit()
  }, bg = COL_SURFACE)

  # ── OUTPUT: threshold sweep ───────────────────────────────────────────────
  output$threshold_sweep_plot <- renderPlot({
    thresh <- current_threshold()

    sweep_long <- reshape(sweep_data,
      varying   = c("precision", "recall", "f1"),
      v.names   = "value",
      timevar   = "metric",
      times     = c("Precision", "Recall", "F1"),
      direction = "long"
    )

    ggplot(sweep_long, aes(x = threshold, y = value, color = metric)) +
      geom_line(linewidth = 1) +
      geom_vline(xintercept = thresh,
                 color = COL_ACCENT, linewidth = 0.8, linetype = "dashed") +
      scale_color_manual(
        values = c(Precision = COL_ACCENT2, Recall = COL_LOW, F1 = COL_MED),
        name   = NULL) +
      labs(x = "Decision Threshold", y = "Score") +
      coord_cartesian(ylim = c(0, 1)) +
      theme_credit() +
      theme(legend.position = "top")
  }, bg = COL_SURFACE)

  # ── OUTPUT: data explorer – days late bar ─────────────────────────────────
  output$days_late_plot <- renderPlot({
    df <- loan_data
    df$late_bucket <- cut(df$mean_days_late,
      breaks = c(-Inf, -10, 0, 10, 30, Inf),
      labels = c("< -10", "-10–0", "0–10", "10–30", "> 30"))

    agg <- aggregate(TARGET ~ late_bucket, data = df, FUN = mean)
    agg$pct <- agg$TARGET * 100

    ggplot(agg, aes(x = late_bucket, y = pct)) +
      geom_col(fill = COL_ACCENT, width = 0.6) +
      labs(x = "Mean Days Late Bucket", y = "Default Rate (%)") +
      theme_credit()
  }, bg = COL_SURFACE)

  # ── OUTPUT: data explorer – predicted prob distribution ───────────────────
  output$prob_dist_plot <- renderPlot({
    df <- data.frame(
      prob    = test_probs,
      default = factor(test_data$TARGET, labels = c("No Default", "Default"))
    )

    ggplot(df, aes(x = prob, fill = default)) +
      geom_histogram(bins = 40, alpha = 0.75, position = "identity") +
      geom_vline(xintercept = current_threshold(),
                 color = COL_ACCENT, linetype = "dashed", linewidth = 0.8) +
      scale_fill_manual(values = c("No Default" = COL_LOW, "Default" = COL_HIGH),
                        name = NULL) +
      labs(x = "Predicted Default Probability", y = "Count") +
      theme_credit() +
      theme(legend.position = "top")
  }, bg = COL_SURFACE)

  # ── OUTPUT: data explorer – feature distribution by default ───────────────
  output$feature_dist_plot <- renderPlot({
    feat <- input$explorer_feature
    df   <- data.frame(
      value   = loan_data[[feat]],
      default = factor(loan_data$TARGET, labels = c("No Default", "Default"))
    )

    ggplot(df, aes(x = value, fill = default)) +
      geom_density(alpha = 0.6) +
      scale_fill_manual(values = c("No Default" = COL_LOW, "Default" = COL_HIGH),
                        name = NULL) +
      labs(x = FEATURE_LABELS[feat], y = "Density") +
      coord_cartesian(xlim = c(quantile(df$value, 0.01, na.rm = TRUE),
                               quantile(df$value, 0.99, na.rm = TRUE))) +
      theme_credit() +
      theme(legend.position = "top")
  }, bg = COL_SURFACE)

}
