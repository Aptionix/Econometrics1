# Model IDs retain paper column numbers; full coefficients are exported to CSV/RDS.

did_models <- function(d, y, cluster = NULL) {
  terms <- c("treat_post", "uncertain_post")
  models <- list()
  models <- add_model(models, paste0(y, "_c1"), d, y, terms, old_fixed, cluster)
  models <- add_model(models, paste0(y, "_c2"), short_window(d), y, terms, old_fixed, cluster)
  city_treated <- d %>% mutate(treat_post = as.integer((treat == 1 | (area == 1 &
    (year > 1832 | (year == 1832 & month >= 4)))) & post1829 == 1))
  models <- add_model(models, paste0(y, "_c3"), short_window(city_treated), y, terms, old_fixed, cluster)
  city_uncertain <- d %>% mutate(uncertain_post = as.integer((uncertain == 1 | area == 1) & post1829 == 1))
  models <- add_model(models, paste0(y, "_c4"), short_window(city_uncertain), y, terms, old_fixed, cluster)
  models <- add_model(models, paste0(y, "_c5"), filter(short_window(d), area != 1), y, terms, old_fixed, cluster)
  models
}

run_table1 <- function() {
  d <- crime_panel()
  models <- list(); summaries <- list()
  for (window in c("short", "full")) {
    sample <- if (window == "short") short_window(d) else d
    for (area in c(1:4, 5)) {
      a <- if (area == 5) sample else filter(sample, .data$area == .env$area)
      for (y in crime_outcomes) {
        id <- paste(y, window, area, sep = "_")
        models <- add_model(models, id, a, y, "post1829")
        summaries[[id]] <- bind_rows(lapply(0:1, function(post) {
          summary_rows(filter(a, post1829 == post), y, paste(window, area, post, sep = "_"))
        }))
      }
    }
  }
  save_csv(bind_rows(summaries), "table1_descriptives")
  export_models(models, "table1")
}

run_table2 <- function() {
  d <- old_bailey() %>% mutate(any_new_police = as.integer(type_policeman + type_other_post > 0),
                              any_old_police = as.integer(type_watchman + type_other_pre > 0))
  outcomes <- c("any_police_testimony", "any_new_police", "any_old_police", "police_at_crimescene")
  models <- list()
  for (j in seq_along(outcomes)) for (area in 1:4) for (short in 0:1) {
    a <- filter(d, .data$area == .env$area)
    if (short == 1) a <- short_window(a)
    models <- add_model(models, paste0("c", 2*j - 1 + short, "_area", area), a, outcomes[j],
                        "post1829", "offsubcat_comb")
  }
  export_models(models, "table2")
}

run_table3 <- function() {
  d <- crime_panel(); weekly <- crime_panel(aggregation = "week")
  distance <- crime_panel(aggregation = "distance")
  save_csv(d, "old_bailey_monthly", "data")
  save_csv(weekly, "old_bailey_weekly", "data")
  save_csv(distance, "old_bailey_distance", "data")
  models <- list()
  for (y in crime_outcomes) {
    models <- c(models, did_models(d, y))
    for (j in 6:7) models <- add_model(models, paste0(y, "_c", j),
      if (j == 6) d else short_window(d), y, c("treat_post", "uncertain_post"),
      c("area", "year", "month"), "area", poisson = TRUE)
    for (j in 8:11) {
      a <- if (j <= 9) weekly else distance
      if (j %in% c(9, 11)) a <- short_window(a)
      models <- add_model(models, paste0(y, "_c", j), a, paste0(y, "_any"),
        c("treat_post", "uncertain_post"), if (j <= 9) c("year", "week", "area") else old_fixed)
    }
  }
  export_models(models, "table3")
}

run_table4 <- function() {
  d <- daily_reports()
  variables <- c(paste0("num_agg_", c("total", "prop", "viol", "other")),
    paste0("numinfo_", c("total", "prop", "viol", "other")),
    paste0("anyinfo_", c("total", "prop", "viol", "other")),
    paste0("numcharge_", c("total", "prop", "viol", "other")),
    paste0("anycharge_", c("total", "prop", "viol", "other")), "num_propstolen", "any_propstolen")
  samples <- list(all = d, pre = filter(d, year < 1829), year1830 = filter(d, year == 1830), post = filter(d, year > 1829))
  save_csv(bind_rows(lapply(names(samples), function(s) summary_rows(samples[[s]], variables, s))), "table4")
}

daily_models <- function(d = daily_reports(), cluster = NULL, include_poisson = TRUE) {
  panels <- c(A = "num_agg", B = "anyinfo", C = "numinfo", D = "any_propstolen", E = "numcharge")
  models <- list()
  for (panel in names(panels)) {
    prefix <- panels[[panel]]
    total <- if (panel == "D") prefix else paste0(prefix, "_total")
    for (j in 1:if (panel == "D") 3 else 6) {
      y <- if (j <= 3) total else paste0(prefix, "_", c("prop", "viol", "other")[j - 3])
      models <- add_model(models, paste0(panel, "_c", j), if (j == 3) d else filter(d, year < 1831),
                          y, "postmet", if (j == 1) character() else daily_fixed, cluster)
    }
    if (include_poisson && panel %in% c("A", "C", "E")) for (j in 7:10) {
      y <- paste0(prefix, "_", c("total", "prop", "viol", "other")[j - 6])
      models <- add_model(models, paste0(panel, "_c", j), filter(d, year < 1831), y,
                          "postmet", daily_fixed, "office", poisson = TRUE)
    }
  }
  models
}

run_table5 <- function() export_models(daily_models(), "table5")

run_table6 <- function() {
  d <- daily_reports()
  terms <- c("postmet_jan1830", "postmet_nonjan1830", "postmet_1831", "postmet_1832")
  outcomes <- c(paste0("num_agg_", c("total", "prop", "viol")),
    paste0("numcharge_", c("total", "prop", "viol")),
    paste0("anyinfo_", c("total", "prop", "viol")), "any_propstolen")
  models <- list(); tests <- list()
  for (j in seq_along(outcomes)) {
    id <- paste0("c", j)
    models <- add_model(models, id, d, outcomes[j], terms, daily_fixed)
    tests[[id]] <- mutate(equality_test(models[[id]], terms), model = id)
  }
  save_csv(bind_rows(tests), "table6_equality_tests")
  export_models(models, "table6")
}

county_models <- function(d = county_data(), outcomes = county_outcomes) {
  models <- list(); tests <- list()
  for (y in outcomes) for (j in 1:4) {
    threshold <- c(NA, 1500, 2000, 2500)[j]
    terms <- if (j == 1) "force_existence_all" else c(paste0("force_eff", threshold), paste0("force_ineff", threshold))
    id <- paste0(y, "_c", j)
    models <- add_model(models, id, d, y, terms, c("countyname", "year"), "countyname")
    if (j > 1) tests[[id]] <- mutate(equality_test(models[[id]], terms), model = id)
  }
  attr(models, "equality_tests") <- bind_rows(tests)
  models
}

run_table7 <- function() {
  models <- county_models()
  save_csv(attr(models, "equality_tests"), "table7_equality_tests")
  export_models(models, "table7")
}

run_tableA1 <- function() {
  d <- read_source("london_add2") %>% filter(!div %in% c(".", "Supervisory"))
  table <- d %>% group_by(div) %>% summarise(all_hires = n(),
    all_hires_250 = sum(servicelength >= 250 | is.na(servicelength)),
    Before_Feb1830_250 = sum((servicelength >= 250 | is.na(servicelength)) & joindate < as.Date("1830-02-01"), na.rm = TRUE),
    After_Feb1830_250 = sum((servicelength >= 250 | is.na(servicelength)) &
      (joindate >= as.Date("1830-02-01") | is.na(joindate))), .groups = "drop") %>%
    mutate(category = ifelse(div %in% LETTERS[1:6], "early", "late"))
  save_csv(table, "tableA1")
}

run_tableA3 <- function() {
  d <- old_bailey()
  variables <- c("dist_mls", "dist_km", "codef", "date_difference", "any_police_testimony", "number_police_witness",
    "type_constable", "type_policeman", "type_watchman", "type_other_pre", "type_other_post", "type_missing", "police_at_crimescene")
  rows <- list()
  for (area in c("within7", "city", "outside7")) for (window in c("pre", "post", "short")) {
    a <- switch(area, within7 = filter(d, within_7mls == 1, city == 0),
                city = filter(d, within_7mls == 0, city == 1), outside7 = filter(d, within_7mls == 0, city == 0))
    a <- switch(window, pre = filter(a, post1829 == 0), post = filter(a, post1829 == 1), short = short_window(a))
    id <- paste(area, window, sep = "_")
    totals <- data.frame(sample = id, variable = c("incidents", sort(unique(d$offsubcat_comb))),
      n = c(nrow(a), vapply(sort(unique(d$offsubcat_comb)), function(y) sum(a$offsubcat_comb == y), integer(1))))
    rows[[id]] <- bind_rows(totals, summary_rows(a, variables, id))
  }
  save_csv(bind_rows(rows), "tableA3")
}

run_tableA4 <- function() {
  raw <- old_bailey(); models <- list()
  samples <- list(raw, filter(raw, is.na(location_type) | location_type != 3),
                  filter(raw, location_info == 0), filter(raw, !is.na(date_crime)))
  for (s in seq_along(samples)) {
    d <- crime_panel(samples[[s]]) %>% mutate(t = year - 1820)
    for (y in crime_outcomes) for (short in 0:1) {
      models <- add_model(models, paste0(y, "_c", 2*s - 1 + short), if (short == 1) short_window(d) else d,
        y, c("treat_post", "uncertain_post", if (s == 1) "factor(area):t"), old_fixed)
    }
  }
  export_models(models, "tableA4")
}

run_tableA5 <- function() {
  d <- crime_panel(); models <- list(); bootstrap <- list()
  for (y in crime_outcomes) models <- c(models, did_models(d, y, cluster = "area"))
  for (id in names(models)) bootstrap[[id]] <- mutate(wild_bootstrap(models[[id]], c("treat_post", "uncertain_post")), model = id)
  save_csv(bind_rows(bootstrap), "tableA5_bootstrap")
  export_models(models, "tableA5")
}

run_tableA6 <- function() {
  d <- daily_reports(); models <- list()
  outcomes <- c(A = "num_agg_total", B = "anyinfo_total", C = "any_propstolen", D = "numcharge_total")
  offices <- c("b", "h", "l", "m", "ms", "q", "u", "w")
  for (panel in names(outcomes)) for (j in seq_along(offices)) {
    models <- add_model(models, paste0(panel, "_c", j), filter(d, office != offices[j], year < 1831),
                        outcomes[[panel]], "postmet", daily_fixed)
  }
  weekly <- d %>% group_by(year, week, calweek, incomplete_week, office, officename, postmet, postmet1830) %>%
    summarise(across(all_of(unname(outcomes)), ~sum(.x, na.rm = TRUE)), .groups = "drop") %>%
    mutate(anyinfo_total = as.integer(anyinfo_total > 0),
           ln_num_agg_total = log(ifelse(num_agg_total == 0, .0001, num_agg_total)),
           ln_numcharge_total = log(ifelse(numcharge_total == 0, .0001, numcharge_total)))
  for (panel in names(outcomes)) for (j in 9:if (panel %in% c("A", "D")) 12 else 11) {
    a <- if (j %in% c(9, 11)) filter(weekly, year < 1831) else weekly
    if (j == 11) a <- filter(a, incomplete_week == 0)
    y <- if (j == 12) paste0("ln_", outcomes[[panel]]) else outcomes[[panel]]
    models <- add_model(models, paste0(panel, "_c", j), a, y, "postmet", c("office", "calweek"))
  }
  save_csv(weekly, "daily_reports_weekly", "data")
  export_models(models, "tableA6")
}

run_tableA7 <- function() {
  models <- daily_models(cluster = "office", include_poisson = FALSE)
  bootstrap <- lapply(names(models), function(id) mutate(wild_bootstrap(models[[id]], "postmet"), model = id))
  save_csv(bind_rows(bootstrap), "tableA7_bootstrap")
  export_models(models, "tableA7")
}

run_tableB1 <- function() {
  d <- county_data(FALSE) %>% filter(year == 1858, !countyname %in% c("Middlesex incl. London", "York", "Sussex", "Suffolk")) %>%
    select(countyname, start_month, start_year, fiscal_start_year, first_full_year, police_initial, people_per_police_initial) %>%
    arrange(start_year, start_month, countyname)
  save_csv(d, "tableB1")
}

run_tableB3 <- function() {
  d <- county_data() %>% mutate(reformtiming = case_when(first_full_year == 1841 ~ "early",
    first_full_year > 1841 & first_full_year < 1858 ~ "mid", first_full_year == 1858 ~ "late", TRUE ~ ""))
  varying <- c("fiscal_start_year", "force_existence_all", "charges", "violent_charges", "property_charges", "other_charges",
                "charges_rate", "viol_rate", "prop_rate", "other_rate")
  constant <- c("england", "wales", "num_parishes", "acres", "pop_combined", "people_per_police_initial", "eff1500_creation",
    "people_per_police_1858", "farmer", "male", "married", "native", "employed", "out_of_lf",
    "age_0_15", "age_16_25", "age_26_35", "age_36_45", "age_46_55", "age_56_65", "age_66_plus")
  rows <- list()
  for (s in c("all counties", "early", "late", "mid")) {
    a <- if (s == "all counties") d else filter(d, reformtiming == s)
    rows[[s]] <- bind_rows(summary_rows(a, varying, s), summary_rows(filter(a, year == 1851), constant, s))
  }
  save_csv(bind_rows(rows), "tableB3")
}

run_tableB4 <- function() {
  d <- adoption_data(TRUE); models <- list()
  population <- "pop_combined_scaled"
  neighbour <- "all_neigh_lag1_charges_rate"
  crime <- c("lag1_viol_rate", "lag1_prop_rate", "lag1_other_rate")
  early <- list("lag1_charges_rate", c("lag1_charges_rate", population),
    c("lag1_charges_rate", "lag1_any_neigh_force", population), c("lag1_any_neigh_force", crime, population),
    c("lag1_any_neigh_force", crime, population, neighbour), c("lag1_any_neigh_force", crime, population, neighbour, "police_initial_noncounty"))
  both <- c("lag1_any_neigh_eff_force", "lag1_any_neigh_ineff_force")
  all <- list("lag1_charges_rate", c("lag1_charges_rate", population), c("lag1_charges_rate", "lag1_any_neigh_force", population),
    c("lag1_charges_rate", both, population), c(both, crime, population), c(both, crime, population, neighbour),
    c(both, crime, population, neighbour, "police_initial_noncounty"))
  for (j in seq_along(early)) models <- add_model(models, paste0("c", j), filter(d, year == 1840),
    "adoption", early[[j]], cluster = "countyname")
  for (j in seq_along(all)) models <- add_model(models, paste0("c", j + 6), filter(d, year >= 1840, year <= 1857),
    "adoption", all[[j]], cluster = "countyname")
  export_models(models, "tableB4")
}

run_tableB5 <- function() {
  d <- county_data(FALSE) %>% filter(!countyname %in% c("Middlesex incl. London", "York", "Sussex", "Suffolk"))
  neighbours <- as.matrix(d[paste0("n", 1:9, "_id_name")])
  d$midsex_neigh <- as.integer(rowSums(neighbours == "Middlesex incl. London") > 0)
  first_ring <- c("Berks", "Bucks", "Essex", "Hertford", "Surrey")
  d$midsex_neigh2 <- as.integer(rowSums(matrix(neighbours %in% first_ring, nrow = nrow(d))) > 0 & d$midsex_neigh == 0)
  d <- short_window(d) %>% mutate(post1829 = as.integer(year >= 1830),
    midsex_neigh_post29 = midsex_neigh * post1829, midsex_neigh2_post29 = midsex_neigh2 * post1829)
  samples <- c(list(first_ring = filter(d, midsex_neigh == 1, midsex_neigh2 == 0)),
    setNames(lapply(first_ring, function(s) filter(d, countyname == s)), first_ring),
    list(second_ring = filter(d, midsex_neigh == 0, midsex_neigh2 == 1)),
    setNames(lapply(c("Bedford", "Cambridge", "Gloucester", "Kent", "Northampton", "Oxford", "Southampton", "Wilts"),
      function(s) filter(d, countyname == s)), c("Bedford", "Cambridge", "Gloucester", "Kent", "Northampton", "Oxford", "Southampton", "Wilts")),
    list(other = filter(d, midsex_neigh == 0, midsex_neigh2 == 0)))
  models <- list(); rows <- list()
  for (s in names(samples)) {
    models <- add_model(models, paste0("A_", s), samples[[s]], "log_charges", "post1829")
    rows[[s]] <- bind_rows(lapply(0:1, function(post) summary_rows(filter(samples[[s]], post1829 == post), "log_charges", paste0(s, "_", post))))
  }
  for (j in 1:2) models <- add_model(models, paste0("B_c", j), d, "log_charges",
    c("midsex_neigh_post29", "midsex_neigh2_post29"), c("year", "countyname"), if (j == 2) "countyname" else NULL)
  save_csv(bind_rows(rows), "tableB5_descriptives")
  export_models(models, "tableB5")
}

run_tableB6 <- function() {
  d <- adoption_data() %>% mutate(acres_scaled = acres / 10000, num_parishes_scaled = num_parishes / 100)
  shares <- c("farmer", "male", "married", "native", "employed", "age_0_15", "age_16_25", "age_26_35", "age_36_45", "age_46_55")
  for (v in shares) d[[paste0(v, "_pct")]] <- d[[v]] * 100
  pre <- c("viol_rate", "prop_rate", "other_rate", "any_neigh_eff_force", "any_neigh_ineff_force")
  for (v in pre) {
    source <- paste0("lag1_", v)
    d <- d %>% group_by(countyname) %>% mutate(!!paste0("preadopt_", v) := {
      x <- .data[[source]][which(adoption == 1)]
      if (any(!is.na(x))) max(x, na.rm = TRUE) else NA_real_
    }) %>% ungroup()
  }
  base <- c("acres_scaled", "num_parishes_scaled", "number_neighbors", "england", paste0(shares, "_pct"))
  models <- list()
  for (stage in 1:3) for (j in 1:2) {
    terms <- c(base, if (stage >= 2) paste0("preadopt_", pre), if (stage == 3) "pop_combined_scaled")
    models <- add_model(models, paste0("c", 2*stage - 2 + j), filter(d, year == 1858),
      c("eff1500_creation", "people_per_police_initial")[j], terms)
  }
  export_models(models, "tableB6")
}

run_tableB7 <- function() {
  d <- county_data()
  # The supplied do-file assigns the literal constant 536636.5 in column 5.
  # Record its baseline-equivalent specification and export the median split separately.
  d$acres_above_median <- as.integer(d$acres > median(d$acres, na.rm = TRUE))
  base <- c("force_eff1500", "force_ineff1500")
  models <- list()
  for (y in county_outcomes) for (j in 1:10) {
    a <- switch(as.character(j), `6` = filter(d, year >= 1835, year <= 1862),
      `7` = filter(d, year >= 1832, year <= 1849), `8` = filter(d, year >= 1850, year <= 1865),
      `9` = filter(d, england == 1), d)
    extra <- switch(as.character(j), `2` = "pop_combined", `3` = c("pop_combined", "england", "factor(region)"),
      `4` = "factor(region)*w", `5` = "w", `10` = c("any_neigh_eff_force", "any_neigh_ineff_force"), character())
    models <- add_model(models, paste0(y, "_c", j), a, y, c(base, extra), c("countyname", "year"), "countyname")
  }
  export_models(models, "tableB7")
  corrected <- list()
  for (y in county_outcomes) corrected <- add_model(corrected, paste0(y, "_c5_median_split"), d, y,
    c(base, "factor(acres_above_median)*w"), c("countyname", "year"), "countyname")
  export_models(corrected, "tableB7_median_split")
  models
}

# The original footnote blocks mostly print manual editing instructions. These
# wrappers execute those specifications, retaining the same models and samples.
run_fn13 <- function() {
  d <- crime_panel(old_bailey(uncertain_radius = 8)); models <- list()
  for (y in crime_outcomes) models <- c(models, did_models(d, y))
  export_models(models, "fn13")
}
run_fn28 <- function() export_models(daily_models(daily_reports(TRUE)), "fn28")
run_fn33 <- function() {
  models <- county_models(outcomes = c("log_chargerate", "log_violrate", "log_proprate", "log_otherrate"))
  save_csv(attr(models, "equality_tests"), "fn33_equality_tests")
  export_models(models, "fn33")
}
run_ref1 <- function() {
  d <- crime_panel() %>% short_window() %>% filter(!(year == 1832 & month > 5))
  models <- list()
  for (y in crime_outcomes) models <- add_model(models, y, d, y, c("treat_post", "uncertain_post"), old_fixed)
  export_models(models, "ref1")
}
