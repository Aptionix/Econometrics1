# Figures export both PDF and PNG plus the numbers used to draw them.

line_plot <- function(d, x, variables, labels = variables, title = NULL, ylab = NULL, points = FALSE) {
  long <- d %>% select(all_of(c(x, variables))) %>%
    pivot_longer(all_of(variables), names_to = "series", values_to = "value") %>%
    mutate(series = factor(series, levels = variables, labels = labels))
  p <- ggplot(long, aes(x = .data[[x]], y = value, colour = series, linetype = series, group = series)) +
    geom_line(na.rm = TRUE, linewidth = .6) + scale_colour_grey(start = 0, end = .65) +
    labs(x = if (x == "year") "Year" else NULL, y = ylab, title = title)
  if (points) p <- p + geom_point(na.rm = TRUE, size = 1.5)
  p
}

run_figure1 <- function() {
  hiring <- read_source("london_add1") %>%
    bind_rows(data.frame(year = 1829, month = 9, day = 20, date = as.Date("1829-09-20"),
                         num_appointed = NA_real_, num_removed = NA_real_, current_total = 0)) %>% arrange(date)
  long <- hiring %>% mutate(num_appointed = 10 * num_appointed, num_removed = 10 * num_removed) %>%
    pivot_longer(c(current_total, num_appointed, num_removed), names_to = "series", values_to = "value")
  a <- ggplot(long, aes(date, value, colour = series)) + geom_line(na.rm = TRUE, linewidth = .6) +
    scale_colour_manual(values = c(current_total = "black", num_appointed = "blue", num_removed = "forestgreen"),
                        breaks = c("current_total", "num_appointed", "num_removed"), labels = c("Total", "Appointments", "Removals")) +
    scale_y_continuous("Weekly number: Total", sec.axis = sec_axis(~.x/10, name = "Weekly appointments/removals")) +
    labs(x = NULL, title = "Metropolitan Police: Weekly hiring")
  leavers <- read_source("london_add2") %>% count(leaveweek, div, name = "leavers") %>%
    complete(leaveweek, div, fill = list(leavers = 0)) %>% group_by(leaveweek) %>% summarise(leavers = sum(leavers), .groups = "drop")
  b <- line_plot(leavers, "leaveweek", "leavers", title = "Weekly number of leavers: All police divisions", ylab = "Weekly number of leavers") +
    theme(legend.position = "none")
  removals <- read_source("london_add3") %>%
    filter(startdate < as.Date("1838-07-02") | startdate > as.Date("1838-12-30")) %>%
    mutate(segment = as.integer(startdate > as.Date("1838-12-30"))) %>%
    pivot_longer(c(discat_drunk, discat_conduct, discat_crime, discat_other), names_to = "series", values_to = "value")
  c <- ggplot(removals, aes(startdate, value, colour = series, group = interaction(series, segment))) +
    geom_line(na.rm = TRUE, linewidth = .6) +
    scale_colour_manual(values = c(discat_drunk = "black", discat_conduct = "forestgreen", discat_crime = "blue", discat_other = "red"),
      breaks = c("discat_drunk", "discat_conduct", "discat_crime", "discat_other"), labels = c("Drunk", "Misconduct", "Crime", "Other")) +
    labs(x = NULL, y = "Weekly number of removals", title = "Weekly removals: All police divisions")
  plots <- list(a, b, c)
  for (j in 1:3) save_plot(plots[[j]], paste0("figure1", LETTERS[j]))
  save_plot(patchwork::wrap_plots(plots, ncol = 1), "figure1", 9, 12)
  save_csv(hiring, "figure1A", "data"); save_csv(leavers, "figure1B", "data"); save_csv(removals, "figure1C", "data")
  invisible(plots)
}

stata_density <- function(x) {
  x <- x[!is.na(x)]
  # Stata's type-2 quartiles and variance-one Epanechnikov, not R's Gaussian default.
  h <- .9 * min(sd(x), diff(quantile(x, c(.25, .75), type = 2)) / 1.349) * length(x)^(-.2)
  grid <- seq(min(x), max(x), length.out = 300)
  y <- vapply(grid, function(z) {
    u <- (z - x) / h
    mean(ifelse(abs(u) < sqrt(5), .75 / sqrt(5) * (1 - u^2 / 5), 0)) / h
  }, numeric(1))
  data.frame(distance = grid, density = y, bandwidth = h, n = length(x))
}

run_figure3 <- function() {
  d <- old_bailey() %>% filter(city == 0, dist_mls <= 16) %>%
    mutate(nr_new_police = type_policeman + type_other_post, nr_old_police = type_watchman + type_other_pre,
           homicide = offsubcat_comb %in% c("murder", "manslaughter"))
  samples <- list(
    A = list(filter(d, post1829 == 1, police_at_crimescene == 1), filter(d, post1829 == 1, police_at_crimescene == 0)),
    B = list(filter(d, post1829 == 1, nr_new_police > 0 | is.na(nr_new_police)),
             filter(d, post1829 == 1, nr_old_police > 0 | is.na(nr_old_police))),
    C = list(filter(d, post1829 == 0, offsubcat_comb == "burglary_combined"), filter(d, post1829 == 1, offsubcat_comb == "burglary_combined")),
    D = list(filter(d, post1829 == 0, offsubcat_comb == "robbery_combined"), filter(d, post1829 == 1, offsubcat_comb == "robbery_combined")),
    E = list(filter(d, post1829 == 0, homicide), filter(d, post1829 == 1, homicide)))
  titles <- c(A = "Police at crime scene", B = "New/old type police witnesses", C = "Crime locations: Burglary",
               D = "Crime locations: Robbery", E = "Crime locations: Homicide")
  plots <- list(); numbers <- list()
  for (panel in names(samples)) {
    labels <- switch(panel, A = c("Police at crime scene (1829-1837)", "No police at crime scene (1829-1837)"),
      B = c("New police witness (1829-1837)", "Old police witness (1829-1837)"), c("Before (1821-1829)", "After (1829-1837)"))
    density <- bind_rows(lapply(1:2, function(j) mutate(stata_density(samples[[panel]][[j]]$dist_mls), series = labels[j])))
    density$series <- factor(density$series, levels = labels)
    limit <- if (panel %in% c("A", "B")) .5 else .4
    annotations <- bind_rows(lapply(1:3, function(j) {
      area <- c(4, 3, 2)[j]
      count <- vapply(samples[[panel]], function(a) sum(a$area == area), integer(1))
      data.frame(distance = c(2, 5.5, 11)[j], density = limit,
        label = paste(c("Treated", "Uncertain", "Control")[j], paste0("Series 1: N=", count[1]), paste0("Series 2: N=", count[2]), sep = "\n"))
    }))
    p <- ggplot(density, aes(distance, density, linetype = series)) + geom_line(linewidth = .7) +
      geom_vline(xintercept = c(4, 7), linetype = "dashed", colour = "#cf7891") +
      geom_text(data = annotations, aes(distance, density, label = label), inherit.aes = FALSE,
                size = 2.7, vjust = 1) +
      scale_linetype_manual(values = c("solid", "longdash")) +
      coord_cartesian(xlim = c(0, 16), ylim = c(0, limit)) +
      labs(x = "Distance from Charing Cross (miles)", y = "Kernel density", title = titles[[panel]]) +
      theme(legend.text = element_text(size = 8))
    plots[[panel]] <- p; numbers[[panel]] <- density
    save_plot(p, paste0("figure3", panel))
    save_csv(density, paste0("figure3", panel), "data")
  }
  save_plot(patchwork::wrap_plots(c(plots, list(patchwork::plot_spacer())), ncol = 2), "figure3", 12, 13)
  invisible(numbers)
}

event_plot <- function(rows, baseline, reference, limits, title, xlabel, breaks, labels = breaks) {
  rows$period <- ifelse(rows$time < reference, "pre", ifelse(rows$time > reference, "post", "reference"))
  display <- filter(rows, period != "reference")
  ggplot(display, aes(time, estimate, group = period)) +
    geom_hline(yintercept = 0, colour = "grey60") + geom_vline(xintercept = reference, colour = "grey50") +
    geom_line(aes(y = conf.low), linewidth = .4) + geom_line(aes(y = conf.high), linewidth = .4) +
    geom_line(linewidth = .6) + geom_point(aes(shape = period), size = 2) +
    scale_shape_manual(values = c(pre = 1, post = 16)) +
    annotate("segment", x = reference, xend = max(rows$time), y = baseline$estimate, yend = baseline$estimate,
              linetype = "dashed", colour = "grey50") +
    annotate("label", x = reference - .5, y = limits[2] * .88,
      label = sprintf("DD estimate: %.3f\n(s.e. = %.3f)", baseline$estimate, baseline$std.error), hjust = 1, size = 3) +
    scale_x_continuous(breaks = breaks, labels = labels) + coord_cartesian(ylim = limits) +
    labs(x = xlabel, y = "Coefficient and 95% C.I.", title = title) + theme(legend.position = "none")
}

london_event <- function(biennial = FALSE) {
  d <- crime_panel()
  if (biennial) d$event <- pmin(8L, pmax(1L, d$event %/% 2L))
  reference <- if (biennial) 4L else 9L
  levels <- setdiff(sort(unique(d$event)), reference)
  terms <- character()
  for (group in c("treat", "uncertain")) for (event in levels) {
    term <- paste0(group, "_event", event)
    d[[term]] <- as.integer(d$event == event) * d[[group]]
    terms <- c(terms, term)
  }
  models <- list(); plots <- list(); numbers <- list()
  for (y in crime_outcomes) {
    models[[y]] <- estimate(d, y, terms, old_fixed)
    baseline <- estimate(d, y, c("treat_post", "uncertain_post"), old_fixed)
    for (j in 1:2) {
      group <- c("treat", "uncertain")[j]
      rows <- models[[y]]$tidy %>% filter(term %in% paste0(group, "_event", levels))
      rows$time <- as.integer(sub(paste0(group, "_event"), "", rows$term)) - reference
      zero <- rows[1, ]; zero$time <- 0; zero$estimate <- zero$std.error <- zero$conf.low <- zero$conf.high <- 0
      rows <- bind_rows(rows, zero) %>% arrange(time)
      dd <- filter(baseline$tidy, term == paste0(group, "_post"))
      breaks <- if (biennial) -3:4 else -8:8
      labels <- if (biennial) c("<-7", "-6/-5", "-4/-3", "-2/-1", "0/+1", "+2/+3", "+4/+5", ">+7") else breaks
      prefix <- if (biennial) "fn22" else "figure4"
      name <- paste(prefix, y, j, sep = "_")
      p <- event_plot(rows, dd, 0, c(-6, 6), paste(tools::toTitleCase(y), c("Treated", "Uncertain")[j], sep = ": "),
                      if (biennial) "Two-year period relative to reform" else "Year after reform", breaks, labels)
      save_plot(p, name); save_csv(rows, name, "data")
      plots[[name]] <- p; numbers[[name]] <- rows
    }
  }
  export_models(models, if (biennial) "fn22" else "figure4")
  save_plot(patchwork::wrap_plots(plots, ncol = 2), if (biennial) "fn22" else "figure4", 12, 13)
  invisible(numbers)
}
run_figure4 <- function() london_event()
run_fn22 <- function() london_event(TRUE)

run_figure5 <- function() {
  attributes <- read_source("counties_add1")
  coordinates <- read_source("counties_add2")
  names(coordinates) <- c("id", "x", "y")
  coordinates <- coordinates %>% mutate(ring = cumsum(is.na(x) | is.na(y))) %>%
    filter(!is.na(x), !is.na(y)) %>% left_join(select(attributes, id, start_year), by = "id")
  years <- sort(unique(na.omit(attributes$start_year)))
  coordinates$start_year <- factor(coordinates$start_year, levels = years)
  a <- ggplot(coordinates, aes(x, y, group = interaction(id, ring), fill = start_year)) +
    geom_polygon(colour = "grey35", linewidth = .15) + coord_equal() +
    scale_fill_manual(values = grDevices::hcl.colors(length(years), "Blues 3", rev = TRUE), na.value = "white", name = "Start year") +
    labs(title = "Rollout of county police forces") + theme_void() + theme(legend.position = "left")
  d <- county_data(FALSE) %>% filter(!countyname %in% c("Middlesex incl. London", "York", "Sussex", "Suffolk")) %>%
    group_by(year) %>% summarise(police_any = sum(police_any, na.rm = TRUE), .groups = "drop") %>%
    filter(year > 1832, year < 1892)
  b <- line_plot(d, "year", "police_any", title = "Number of professional county police forces", ylab = "Number of police forces", points = TRUE) +
    geom_vline(xintercept = 1857, colour = "red") + theme(legend.position = "none")
  save_plot(a, "figure5A", 6, 8); save_plot(b, "figure5B")
  save_plot(patchwork::wrap_plots(a, b, ncol = 2), "figure5", 12, 7)
  save_csv(d, "figure5B", "data")
  invisible(list(map = a, counts = d))
}

run_figureA1 <- function() {
  d <- read_source("london_add4")
  p <- line_plot(d, "year", c("old_bailey_murders", "london_homicides"), c("Old Bailey murder trials", "London homicides"), ylab = "Number of homicides") +
    geom_vline(xintercept = c(1821, 1837), linetype = "dashed")
  save_plot(p, "figureA1"); save_csv(d, "figureA1", "data")
}

run_figureA2 <- function() {
  # Unlike the regression panel, the author's time-series graph does not fill
  # absent area/month/offence cells with zero; preserve that distinction.
  d <- old_bailey() %>% mutate(offence = ifelse(offsubcat_comb %in% c("murder", "manslaughter"), "homicide", offsubcat_comb)) %>%
    count(year, month, area, offence, name = "cases") %>% mutate(date = as.Date(sprintf("%04d-%02d-01", year, month)),
      area_label = factor(area, levels = c(4, 3, 2, 1), labels = c("Treated", "Uncertain", "Outside 7 miles", "City of London")))
  plots <- list()
  for (j in 1:3) {
    a <- filter(d, offence == c("burglary_combined", "robbery_combined", "homicide")[j])
    p <- ggplot(a, aes(date, cases, colour = area_label)) + geom_line(linewidth = .5) +
      scale_colour_grey(start = 0, end = .75) + geom_vline(xintercept = as.Date("1829-09-01"), colour = "red") +
      scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
      labs(x = NULL, y = "Number of crimes by month", title = tools::toTitleCase(crime_outcomes[j]))
    plots[[j]] <- p; save_plot(p, paste0("figureA2", LETTERS[j]))
  }
  save_plot(patchwork::wrap_plots(plots, ncol = 1), "figureA2", 9, 12)
  save_csv(d, "figureA2", "data")
}

run_figureA3 <- function() {
  d <- read_source("london_add5")
  save_plot(line_plot(d, "year", c("deaths", "choleradeaths"), c("All deaths", "Cholera deaths"),
                       ylab = "Deaths of Metropolitan Police officers", points = TRUE), "figureA3")
  save_csv(d, "figureA3", "data")
}

run_figureA4 <- function() {
  d <- read_source("london_add6")
  d[c("city", "inner_nocity", "outer")] <- d[c("city", "inner_nocity", "outer")] / 1000
  labels <- c("Inner London (excluding City)", "Outer London", "City of London")
  a <- line_plot(d, "year", c("inner_nocity", "outer", "city"), labels, ylab = "Population (thousands)", points = TRUE)
  b <- line_plot(d, "year", c("growth_inner_nocity", "growth_outer", "growth_city"), labels,
                 ylab = "Population growth (%)", points = TRUE) + geom_hline(yintercept = 0)
  save_plot(a, "figureA4A"); save_plot(b, "figureA4B")
  save_plot(patchwork::wrap_plots(a, b, ncol = 1), "figureA4", 9, 9)
  save_csv(d, "figureA4", "data")
}

run_figureA5 <- function() {
  d <- crime_panel(aggregation = "distance"); plots <- list()
  for (j in 1:2) {
    a <- if (j == 1) short_window(d) else d
    differences <- a %>% group_by(dist_group, post1829) %>% summarise(across(all_of(crime_outcomes), mean), .groups = "drop") %>%
      pivot_longer(all_of(crime_outcomes), names_to = "offence", values_to = "mean") %>%
      pivot_wider(names_from = post1829, values_from = mean, names_prefix = "post") %>% mutate(difference = post1 - post0)
    p <- ggplot(differences, aes(dist_group, difference, linetype = offence, colour = offence)) + geom_line(linewidth = .7) +
      scale_colour_grey(start = .1, end = .5) + scale_linetype_manual(values = c("longdash", "dotted", "dashed")) +
      geom_vline(xintercept = c(4, 7), linetype = "dashed") + scale_x_continuous(breaks = 1:15) +
      labs(x = "Distance from Charing Cross (miles)", y = "Difference in means", title = c("1828-1832", "1821-1837")[j])
    plots[[j]] <- p; save_plot(p, paste0("figureA5", LETTERS[j])); save_csv(differences, paste0("figureA5", LETTERS[j]), "data")
  }
  save_plot(patchwork::wrap_plots(plots, ncol = 1), "figureA5", 9, 9)
}

run_figureB1 <- function() {
  d <- county_data(FALSE) %>% filter(!countyname %in% c("Middlesex incl. London", "York", "Sussex", "Suffolk")) %>%
    group_by(year) %>% summarise(across(c(charges, crimes_committed, persons_appr_total), ~sum(.x, na.rm = TRUE)), .groups = "drop") %>%
    filter(year >= 1857, year < 1892) %>% mutate(across(c(crimes_committed, persons_appr_total), ~ifelse(year == 1876, NA_real_, .x)))
  p <- line_plot(d, "year", c("crimes_committed", "persons_appr_total", "charges"),
    c("Crimes committed", "Individuals apprehended", "Charges to trial"), ylab = "Number of incidents, apprehensions and charges", points = TRUE)
  save_plot(p, "figureB1"); save_csv(d, "figureB1", "data")
}

run_figureB2 <- function() {
  d <- county_data() %>% mutate(relative_year = year - first_full_year)
  times <- c(-9:-2, 0:8); terms <- character()
  for (group in c("eff", "ineff")) for (j in seq_along(times)) {
    term <- paste0(group, "_event", j)
    event <- if (times[j] == -9) d$relative_year <= -9 else if (times[j] == 8) d$relative_year >= 8 else d$relative_year == times[j]
    d[[term]] <- as.integer(event) * d[[paste0(group, "1500")]]
    terms <- c(terms, term)
  }
  models <- list(); plots <- list()
  for (i in seq_along(county_outcomes)) {
    y <- county_outcomes[i]
    models[[y]] <- estimate(d, y, terms, c("countyname", "year"), "countyname")
    baseline <- estimate(d, y, c("force_eff1500", "force_ineff1500"), c("countyname", "year"), "countyname")
    for (j in 1:2) {
      group <- c("eff", "ineff")[j]
      rows <- models[[y]]$tidy %>% filter(term %in% paste0(group, "_event", seq_along(times)))
      rows$time <- times[match(rows$term, paste0(group, "_event", seq_along(times)))]
      zero <- rows[1, ]; zero$time <- -1; zero$estimate <- zero$std.error <- zero$conf.low <- zero$conf.high <- 0
      rows <- bind_rows(rows, zero) %>% arrange(time)
      dd <- filter(baseline$tidy, term == paste0("force_", group, "1500"))
      name <- paste0("figureB2", LETTERS[i], j)
      p <- event_plot(rows, dd, -1, c(-.6, .6), paste(y, c("Sufficiently large", "Insufficiently large")[j], sep = ": "),
        "Years before/after reform", -9:8, c("<=-9", as.character(-8:7), ">=8"))
      plots[[name]] <- p; save_plot(p, name); save_csv(rows, name, "data")
    }
  }
  save_plot(patchwork::wrap_plots(plots, ncol = 2), "figureB2", 12, 16)
  export_models(models, "figureB2")
}
