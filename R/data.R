# The original script counts each supplied row as one crime; do not re-filter incident.
old_bailey <- function(uncertain_radius = 7) {
  read_source("london_main1") %>% mutate(
    treat = as.integer(dist_mls <= 4 & city == 0),
    uncertain = as.integer(dist_mls <= uncertain_radius & city == 0 & treat == 0),
    area = case_when(city == 1 ~ 1L, treat == 1 ~ 4L, uncertain == 1 ~ 3L, TRUE ~ 2L),
    dist_group = pmin(15L, pmax(1L, as.integer(ceiling(dist_mls)))))
}

crime_panel <- function(d = old_bailey(), aggregation = "month") {
  if (aggregation == "week") {
    # Stata fillin makes the full year x month x day product; weeks start Sunday,
    # with week 0 before the first Sunday (not ISO weeks).
    calendar <- expand_grid(year = sort(unique(d$year)), month = sort(unique(d$month)),
                            day = sort(unique(d$day)))
    calendar$date <- as.Date(sprintf("%04d-%02d-%02d", calendar$year, calendar$month, calendar$day),
                            format = "%Y-%m-%d")
    calendar <- calendar %>% filter(!is.na(date)) %>% arrange(year, date) %>%
      group_by(year) %>% mutate(week = cumsum(as.POSIXlt(date)$wday == 0),
                                minweek = min(week), maxweek = max(week)) %>% ungroup()
    d <- d %>% left_join(select(calendar, year, month, day, week), by = c("year", "month", "day"))
    counts <- d %>% count(year, week, area, offsubcat_comb, name = "crimes") %>%
      complete(year, week, area, offsubcat_comb, fill = list(crimes = 0L)) %>%
      left_join(distinct(calendar, year, minweek, maxweek), by = "year") %>%
      filter(week >= minweek, week <= maxweek) %>% select(-minweek, -maxweek)
    id <- c("year", "week", "area")
  } else if (aggregation == "distance") {
    counts <- d %>% count(year, month, area, dist_group, offsubcat_comb, name = "crimes") %>%
      complete(year, month, area, dist_group, offsubcat_comb, fill = list(crimes = 0L)) %>%
      filter(!(area == 1 & dist_group > 3), !(area == 2 & dist_group < 8),
             !(area == 3 & (dist_group < 5 | dist_group > 7)), !(area == 4 & dist_group > 4))
    id <- c("year", "month", "area", "dist_group")
  } else {
    counts <- d %>% count(year, month, area, offsubcat_comb, name = "crimes") %>%
      complete(year, month, area, offsubcat_comb, fill = list(crimes = 0L))
    id <- c("year", "month", "area")
  }
  panel <- counts %>% pivot_wider(id_cols = all_of(id), names_from = offsubcat_comb,
                                  values_from = crimes) %>%
    rename(burglary = burglary_combined, robbery = robbery_combined) %>%
    mutate(homicide = murder + manslaughter, crime_total = burglary + robbery + homicide,
           treat = as.integer(area == 4), uncertain = as.integer(area == 3))
  for (v in c("burglary", "robbery", "homicide", "crime_total")) panel[[paste0(v, "_any")]] <- as.integer(panel[[v]] > 0)
  panel$post1829 <- as.integer(panel$year >= 1830 | (panel$year == 1829 &
                                if (aggregation == "week") panel$week >= 39 else panel$month >= 9))
  panel$treat_post <- panel$treat * panel$post1829
  panel$uncertain_post <- panel$uncertain * panel$post1829
  if (aggregation != "week") {
    panel$date <- as.Date(sprintf("%04d-%02d-01", panel$year, panel$month))
    panel$event <- pmin(17L, pmax(1L, panel$year - 1820L + as.integer(panel$month >= 9)))
  }
  panel
}

daily_reports <- function(include_thames = FALSE) {
  d <- read_source("london_main2") %>% filter(office != "mp")
  if (!include_thames) d <- d %>% filter(office != "t")
  d$dow <- as.POSIXlt(d$date)$wday
  d
}

county_data <- function(main_sample = TRUE) {
  d <- read_source("counties_main")
  if (main_sample) d <- d %>% filter(extmarg_sample_3265 == 1)
  d <- d %>% group_by(countyname) %>%
    mutate(first_full_year = if (any(force_existence_all == 1, na.rm = TRUE))
      min(year[force_existence_all == 1], na.rm = TRUE) else NA_real_) %>% ungroup()
  for (threshold in seq(1500, 2500, 250)) {
    d[[paste0("eff", threshold)]] <- as.integer(!is.na(d$people_per_police_initial) & d$people_per_police_initial <= threshold)
    d[[paste0("ineff", threshold)]] <- as.integer(!is.na(d$people_per_police_initial) & d$people_per_police_initial > threshold)
    d[[paste0("force_eff", threshold)]] <- d$force_existence_all * d[[paste0("eff", threshold)]]
    d[[paste0("force_ineff", threshold)]] <- d$force_existence_all * d[[paste0("ineff", threshold)]]
  }
  d
}

adoption_data <- function(neighbours = FALSE) {
  variables <- c("charges_rate", "viol_rate", "prop_rate", "other_rate",
                 "any_neigh_force", "any_neigh_eff_force", "any_neigh_ineff_force")
  d <- county_data() %>% arrange(countyname, year) %>% group_by(countyname)
  for (lag in 1:3) d <- d %>% mutate(across(all_of(variables), ~dplyr::lag(.x, lag), .names = paste0("lag", lag, "_{.col}")))
  d <- d %>% ungroup() %>% mutate(adoption = ifelse(year > fiscal_start_year, NA_real_, as.integer(year == fiscal_start_year)),
                                 pop_combined_scaled = pop_combined / 10000)
  if (neighbours) {
    for (j in 1:9) {
      lookup <- d %>% select(year, countyname, lag1_charges_rate)
      names(lookup)[2:3] <- c(paste0("n", j, "_id_name"), paste0("n", j, "_lag1_charges_rate"))
      d <- left_join(d, lookup, by = c("year", paste0("n", j, "_id_name")))
    }
    d$all_neigh_lag1_charges_rate <- rowMeans(as.matrix(d[paste0("n", 1:9, "_lag1_charges_rate")]), na.rm = TRUE)
    d$all_neigh_lag1_charges_rate[is.nan(d$all_neigh_lag1_charges_rate)] <- NA_real_
  }
  d
}

short_window <- function(d) filter(d, year >= 1828, year <= 1832)
crime_outcomes <- c("burglary", "robbery", "homicide")
county_outcomes <- c("log_charges", "log_violcharges", "log_propcharges", "log_othercharges")
daily_fixed <- c("office", "calweek", "dow")
old_fixed <- c("year", "month", "area")
