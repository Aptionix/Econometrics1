*****************************************************************************************
*** 	"The Impact of the First Professional Police Forces on Crime"
***		Journal of the European Economic Association
***		Anna Bindler (U Cologne, U Gothenburg) and Randi Hjalmarsson (U Gothenburg, CEPR)
***		Please contact the authors for questions/queries.
*****************************************************************************************

*** For this do-file to run, additional packages may need to be installed.

*** For wild cluster bootstrap:
*** Save cgmreg.ado in Stata directory (e.g. from http://cameron.econ.ucdavis.edu/research/papers.html).
*** Install 'cgmwildboot' (use e.g. findit cgmwildboot).
*** Install 'unique' (use e.g. findit unique)

*** For QML Poisson:
*** Install 'xtpqml' (use e.g. findit xtpqml) 

*** For event-study figures:
*** Install 'parmest' (use e.g. findit parmest)

*** For mapping the counties:
*** Install 'spmap' (e.g. findit spmap). You may also need to install  
*** 'shp2dta' and 'mif2dta'.


*** Specify your working directory here:
cd ""

capture log close
log using ab_rh_police_and_crime_jeea.log, replace


********************************************************************************
********************* Choose the part of the analysis to run. ******************
********************************************************************************
	
* I. Figures main text
	
	local figure1 = 0	
	local figure3 = 0	
	local figure4 = 0	
	local figure5 = 0	
	
* II. Tables main text	
	
	local table1 = 0	
	local table2 = 0	
	local table3 = 0	
	local table4 = 0	
	local table5 = 0	
	local table6 = 0	
	local table7 = 0	
	
* III. Online appendix figures - Appendix A
	
	local figureA1 = 0 
	local figureA2 = 0 
	local figureA3 = 0 
	local figureA4 = 0 
	local figureA5 = 0 
	
* IV. Online appendix tables - Appendix A

	local tableA1 = 0	
	local tableA3 = 0	
	local tableA4 = 0	
	local tableA5 = 0	
	local tableA6 = 0	 
	local tableA7 = 0	
	
* V. Online appendix figures - Appendix B

	local figureB1 = 0
	local figureB2 = 0
	
* VI. Online appendix tables - Appendix B	

	local tableB1 = 0	
	local tableB3 = 0	
	local tableB4 = 0	
	local tableB5 = 0	
	local tableB6 = 0	
	local tableB7 = 0	

* VII. Footnotes and references in the text 

	local fn13 = 0	
	local fn22 = 0
	local fn28 = 0 	
	local fn33 = 0	
	local ref1 = 0 
	
********************************************************************************
***************************** I. FIGURES MAIN TEXT *****************************
********************************************************************************

// Figure 1.	

if `figure1'==1{
	
	* Panel A.
		
		use ab_rh_police_and_crime_jeea_london_add1.dta, clear
		
		* Create a zero to start with.
		input
		1829 9 20 . . . 0
		end
		replace date = mdy(month,day,year) if year==1829 & month==9 & day==20
		format date %td
		sort date
		
		twoway ///
			(line current_total date, yaxis(1) lp(solid) lc(gs0) lw(medium)) ///
			(line num_appointed date, yaxis(2) lp(solid) lc(blue) lw(medium)) ///
			(line num_removed date, yaxis(2) lp(solid) lc(green) lw(medium)), ///
			title("Metropolitan Police: Weekly hiring") ///
			ytitle("Weekly number: Total", axis(1)) ///
			ytitle("Weekly number: Appointments/Removals", axis(2)) /// 
			ylabel(0(2000)8000, axis(1)) ylabel(0(200)800, axis(2)) ///
			xtitle("") legend(order(1 2 3) label(1 "Total") ///
			label(2 "Appointments") label(3 "Removals") rows(1)) ///
			graphregion(color(white)) bgcolor(white) 
			graph export "figure1A.pdf", replace
	
	
	* Panel B.
	
		use ab_rh_police_and_crime_jeea_london_add2.dta, clear
	
		gen temp = 1
		collapse (sum) temp, by(leaveweek div)
		fillin leaveweek div
		replace temp = 0 if temp==. & _fillin==1
		collapse (sum) temp, by(leaveweek)
		
		twoway ///
			(line temp leaveweek, lp(solid) lc(gs0) lw(medthick)), ///
			title("Weekly number of leavers: All police divisions") ///
			ytitle("Weekly number of leavers") xtitle("") ///
			legend(off) ///
			graphregion(color(white)) bgcolor(white) 
			graph export "figure1B.pdf", replace	
	
	* Panel C.
	
		use ab_rh_police_and_crime_jeea_london_add3.dta, clear
		
		twoway ///
			(line discat_drunk startdate if startdate<td(02jul1838), ///
				lp(solid) lc(gs0) lw(medthick)) ///
			(line discat_drunk startdate if startdate>td(30dec1838), ///
				lp(solid) lc(gs0) lw(medthick)) ///
			(line discat_conduct startdate if startdate<td(02jul1838), ///
				lp(solid) lc(green) lw(medthick)) ///
			(line discat_conduct startdate if startdate>td(30dec1838), ///
				lp(solid) lc(green) lw(medthick)) ///
			(line discat_crime startdate if startdate<td(02jul1838), ///
				lp(solid) lc(blue) lw(medthick)) ///
			(line discat_crime startdate if startdate>td(30dec1838), ///
				lp(solid) lc(blue) lw(medthick)) ///
			(line discat_other startdate if startdate<td(02jul1838), ///
				lp(solid) lc(red) lw(medthick)) ///
			(line discat_other startdate if startdate>td(30dec1838), ///
				lp(solid) lc(red) lw(medthick)), ///
			title("Weekly number of removals:" "All police divisions") ///
			ytitle("Weekly number of removals") xtitle("") ///
			legend(order(1 3 5 7) label(1 "drunk") label(3 "misconduct") ///
			label(5 "crime") label(7 "other") rows(1)) ///
			graphregion(color(white)) bgcolor(white) 
			graph export "figure1C.pdf", replace 
}

// Figure 3.

if `figure3'==1{

	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen burglary = (offsubcat_comb=="burglary_combined")
	gen robbery  = (offsubcat_comb=="robbery_combined")
	gen homicide = (offsubcat_comb=="murder"|offsubcat_comb=="manslaughter")
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	
	* Drop the City of London (geographically within 7 miles).
	drop if city==1
	* Cut off at 16 miles (i.e. just including the 15 miles threshold).
	drop if dist_mls>16
	
	
	* Panel A. 
	
		count if post1829==1 & treat==1 & police_at_crimescene==1
		count if post1829==1 & treat==1 & police_at_crimescene==0
		count if post1829==1 & uncertain==1 & police_at_crimescene==1
		count if post1829==1 & uncertain==1 & police_at_crimescene==0
		count if post1829==1 & treat==0 & uncertain==0 & police_at_crimescene==1
		count if post1829==1 & treat==0 & uncertain==0 & police_at_crimescene==0
		
		twoway /// 
			(kdensity dist_mls if post1829==1 & police_at_crimescene==1, ///
				lp(solid) lc(gs0) lw(medthick)) ///
			(kdensity dist_mls if post1829==1 & police_at_crimescene==0, ///
				lp(longdash) lc(gs0) lw(medthick)), ///
			xline(4 7, lp(dash)) ylabel(0(.1).5) ///
			ytitle("Kernel density") xtitle("Distance from Charing Cross (in miles)") ///
			legend(order(1 2) ///
			label(1 "Police at crime scene (1829-1837)") ///
			label(2 "No police at crime scene (1829-1837)") col(1)) ///
			graphregion(color(white)) bgcolor(white) ///
			text(.5 2 "Treated" " " "Police: N=195" "No police: N=531", ///
				size(small) placement(s)) ///
			text(.5 5.5 "Uncertain" " " "Police: N=13" "No police: N=67", ///
				size(small) placement(s)) ///
			text(.5 11 "Control" " " "Police: N=10" "No police: N=114", ///
				size(small) placement(s))
			graph export "figure3A.pdf", replace
			
	* Panel B.
	
		gen nr_new_police = type_policeman + type_other_post
		gen nr_old_police = type_watchman + type_other_pre
	
		count if post1829==1 & treat==1 & nr_new_police>0
		count if post1829==1 & treat==1 & nr_old_police>0
		count if post1829==1 & uncertain==1 & nr_new_police>0
		count if post1829==1 & uncertain==1 & nr_old_police>0
		count if post1829==1 & treat==0 & uncertain==0 & nr_new_police>0
		count if post1829==1 & treat==0 & uncertain==0 & nr_old_police>0
		
		twoway /// 
			(kdensity dist_mls if post1829==1 & nr_new_police>0, ///
				lp(solid) lc(gs0) lw(medthick)) ///
			(kdensity dist_mls if post1829==1 & nr_old_police>0, ///
				lp(longdash) lcolor(gs0) lw(medthick)), ///
			xline(4 7, lp(dash)) ylabel(0(.1).5) ///
			ytitle("Kernel density") xtitle("Distance from Charing Cross (in miles)") ///
			legend(order(1 2) ///
			label(1 "At least one 'new police' witness (1829-1837)") ///
			label(2 "At least one 'old police' witness (1829-1837)") col(1)) ///
			graphregion(color(white)) bgcolor(white) ///
			text(.5 2 "Treated" " " "New: N=428" "Old: N=101", ///
				size(small) placement(s)) ///
			text(.5 5.5 "Uncertain" " " "New: N=36" "Old: N=16", ///
				size(small) placement(s)) ///
			text(.5 11 "Control" " " "New: N=20" "Old: N=40", ///
				size(small) placement(s))
			graph export "figure3B.pdf", replace

	* Panel C.
	
		count if post1829==0 & treat==1 & burglary==1
		count if post1829==1 & treat==1 & burglary==1
		count if post1829==0 & uncertain==1 & burglary==1
		count if post1829==1 & uncertain==1 & burglary==1
		count if post1829==0 & treat==0 & uncertain==0 & burglary==1
		count if post1829==1 & treat==0 & uncertain==0 & burglary==1
		
		twoway /// 
			(kdensity dist_mls if post1829==0 & burglary==1, ///
				lp(solid) lc(gs0) lw(medthick)) ///
			(kdensity dist_mls if post1829==1 & burglary==1, ///
				lp(longdash) lc(gs0) lw(medthick)), ///
			xline(4 7, lp(dash)) ylabel(0(.1).4) ///
			ytitle("Kernel density") xtitle("Distance from Charing Cross (in miles)") ///
			legend(order(1 2) label(1 "Before (1821-1829)") ///
			label(2 "After (1829-1837)")) ///
			graphregion(color(white)) bgcolor(white) ///
			text(.4 2 "Treated" " " "Before: N=503" "After: N=487", ///
				size(small) placement(s)) ///
			text(.4 5.5 "Uncertain" " " "Before: N=37" "After: N=57", ///
				size(small) placement(s)) ///
			text(.4 11 "Control" " " "Before: N=67" "After: N=74", ///
				size(small) placement(s))
			graph export "figure3C.pdf", replace
	
	
	* Panel D. 
	
		count if post1829==0 & treat==1 & robbery==1
		count if post1829==1 & treat==1 & robbery==1
		count if post1829==0 & uncertain==1 & robbery==1
		count if post1829==1 & uncertain==1 & robbery==1
		count if post1829==0 & treat==0 & uncertain==0 & robbery==1
		count if post1829==1 & treat==0 & uncertain==0 & robbery==1
		
		twoway /// 
			(kdensity dist_mls if post1829==0 & robbery==1, ///
				lp(solid) lc(gs0) lw(medthick)) ///
			(kdensity dist_mls if post1829==1 & robbery==1, ///
				lp(longdash) lc(gs0) lw(medthick)), ///
			xline(4 7, lp(dash)) ylabel(0(.1).4) ///
			ytitle("Kernel density") xtitle("Distance from Charing Cross (in miles)") ///
			legend(order(1 2) label(1 "Before (1821-1829)") label(2 "After (1829-1837)")) ///
			graphregion(color(white)) bgcolor(white) ///
			text(.4 2 "Treated" " " "Before: N=269" "After: N=146", ///
				size(small) placement(s)) ///
			text(.4 5.5 "Uncertain" " " "Before: N=12" "After: N=13", ///
				size(small) placement(s)) ///
			text(.4 11 "Control" " " "Before: N=19" "After: N=35", ///
				size(small) placement(s))
			graph export "figure3D.pdf", replace
	
	* Panel E.
	
		count if post1829==0 & treat==1 & homicide==1
		count if post1829==1 & treat==1 & homicide==1
		count if post1829==0 & uncertain==1 & homicide==1
		count if post1829==1 & uncertain==1 & homicide==1
		count if post1829==0 & treat==0 & uncertain==0 & homicide==1
		count if post1829==1 & treat==0 & uncertain==0 & homicide==1
		
		twoway /// 
			(kdensity dist_mls if post1829==0 & homicide==1, ///
				lp(solid) lc(gs0) lw(medthick)) ///
			(kdensity dist_mls if post1829==1 & homicide==1, ///
				lp(longdash) lc(gs0) lw(medthick)), ///
			xline(4 7, lp(dash)) ylabel(0(.1).4) ///
			ytitle("Kernel density") xtitle("Distance from Charing Cross (in miles)") ///
			legend(order(1 2) label(1 "Before (1821-1829)") ///
			label(2 "After (1829-1837)")) ///
			graphregion(color(white)) bgcolor(white) ///
			text(.4 2 "Treated" " " "Pre: N=88" "Post: N=93", ///
				size(small) placement(s)) ///
			text(.4 5.5 "Uncertain" " " "Pre: N=6" "Post: N=10", ///
				size(small) placement(s)) ///
			text(.4 11 "Control" " " "Pre: N=12" "Post: N=15", ///
				size(small) placement(s))
			graph export "figure3E.pdf", replace

}

// Figure 4.

if `figure4'==1{

	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area

	gen crimes = 1

	* Collapse.
	collapse (sum) crimes, by(year month area treat uncertain offsubcat_comb)
	
	* Fill in missing values with zeros to construct panel.
	fillin year month area offsubcat_comb
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
		
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
		
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.
		
	* Reshape wide.
	reshape wide crimes, i(year month area treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
		
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
		
	* Create extensive margin variables.
	foreach var in burglary robbery homicide{
		count if `var'==.
		gen `var'_any = (`var'>0)
	}
	
	* Recode post variable (after aggregation to months).
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & month>=9
		 
	* Generate date variable (month x year)
	gen date = ym(year,month)
	format date %tm

	* Generate time to event variable, defined by "fiscal year".
	* That is year = September - August instead of January - December.
	* (Reform in September 1829.)
	gen event = .
		replace event = 1 if date>=tm(1821m1) & date<=tm(1821m8)
		replace event = 2 if date>=tm(1821m9) & date<=tm(1822m8) 
		replace event = 3 if date>=tm(1822m9) & date<=tm(1823m8)
		replace event = 4 if date>=tm(1823m9) & date<=tm(1824m8)
		replace event = 5 if date>=tm(1824m9) & date<=tm(1825m8)
		replace event = 6 if date>=tm(1825m9) & date<=tm(1826m8)
		replace event = 7 if date>=tm(1826m9) & date<=tm(1827m8)
		replace event = 8 if date>=tm(1827m9) & date<=tm(1828m8)
		replace event = 9 if date>=tm(1828m9) & date<=tm(1829m8)
		replace event = 10 if date>=tm(1829m9) & date<=tm(1830m8)
		replace event = 11 if date>=tm(1830m9) & date<=tm(1831m8)
		replace event = 12 if date>=tm(1831m9) & date<=tm(1832m8)
		replace event = 13 if date>=tm(1832m9) & date<=tm(1833m8)
		replace event = 14 if date>=tm(1833m9) & date<=tm(1834m8)
		replace event = 15 if date>=tm(1834m9) & date<=tm(1835m8)
		replace event = 16 if date>=tm(1835m9) & date<=tm(1836m8)
		replace event = 17 if date>=tm(1836m9) 
	
	* Loop over outcomes.
	foreach y in burglary robbery homicide{
	
	preserve
	
		* Run regressions and export results.
		reg `y' 1.event#1.treat 2.event#1.treat 3.event#1.treat 4.event#1.treat ///
			5.event#1.treat 6.event#1.treat 7.event#1.treat 8.event#1.treat ///
			10.event#1.treat 11.event#1.treat 12.event#1.treat 13.event#1.treat ///
			14.event#1.treat 15.event#1.treat 16.event#1.treat 17.event#1.treat ///
			1.event#1.uncertain 2.event#1.uncertain 3.event#1.uncertain 4.event#1.uncertain ///
			5.event#1.uncertain 6.event#1.uncertain 7.event#1.uncertain 8.event#1.uncertain ///
			10.event#1.uncertain 11.event#1.uncertain 12.event#1.uncertain ///
			13.event#1.uncertain 14.event#1.uncertain 15.event#1.uncertain 16.event#1.uncertain ///
			17.event#1.uncertain  ///
			i.year i.month i.area, r
			parmest, level(90 95) saving(esd_`y', replace)
		
		
		* Create graphs.

		use esd_`y', clear
		keep parm estimate min95 max95 min90 max90
		keep if min95!=0 & max95!=0
		keep if min90!=0 & max90!=0
		rename estimate coef
				
		gen id = "."
		replace id = "treatment" if _n>=1 & _n<=16
		replace id = "uncertain" if _n>=17 & _n<=32
		drop if id=="."
				
		bys id: gen t = _n
		replace t = t-8
		replace t = t-1 if t<=0
				
		expand 2 if t==-1, gen(flag)
		replace t = 0 if flag==1
		replace coef = 0 if flag==1
		replace min95 = 0 if flag==1
		replace max95 = 0 if flag==1
		replace min90 = 0 if flag==1
		replace max90 = 0 if flag==1
		drop flag
		sort id t
				
		gen temp = "`y'"
		if temp == "burglary"{
			local ddc_t = -0.106
			local dds_t = 0.370
			local ddc_u = 0.016
			local dds_u = 0.149
		}
		if temp == "robbery"{
			local ddc_t = -1.032
			local dds_t = 0.129
			local ddc_u = 0.129
			local dds_u = 0.088
		}
		if temp == "homicide"{
			local ddc_t = -0.008
			local dds_t = 0.139
			local ddc_u = -0.049
			local dds_u = 0.057
		}

		gen ddc = `ddc_t' if id=="treatment"
		replace ddc = `ddc_u' if id=="uncertain"
				
		twoway ///
		(connected coef t if t<0 & id=="treatment", msymbol(Oh) mcolor(gs0) msize(large) lw(medthick) lc(gs0)) ///
		(connected coef t if t>0 & id=="treatment", msymbol(O) mcolor(gs0)  msize(large) lw(medthick) lc(gs0)) ///
		(line min95 t if t<0 & id=="treatment", lcolor(gs0) lw(med) lp(solid)) ///
		(line min95 t if t>0 & id=="treatment", lcolor(gs0) lw(med) lp(solid)) ///
		(line max95 t if t<0 & id=="treatment", lcolor(gs0) lw(med) lp(solid)) ///
		(line max95 t if t>0 & id=="treatment", lcolor(gs0) lw(med) lp(solid)) ///
		(line ddc t if t>=0 & id=="treatment", lc(gs10) lp(dash) lw(medthick)), /// 
		xline(0, lc(gs5) lw(medthick)) /// 
		yline(0, lc(gs5) lw(medthick)) ///
		xlabel(-8(1)8) ///
		ylabel(-6(2)6) ///
		text(5.5 -1 "DD estimate: `ddc_t'" "(s.e. = `dds_t')", ///
		size(medium) placement(w) box fc(white)) /// 
		ytitle("Coefficient and 95% C.I.") xtitle("Year after reform") ///
		graphregion(color(white)) bgcolor(white) legend(off) 
		graph export "figure4_`y'_1.pdf", replace
				
		twoway ///
		(connected coef t if t<0 & id=="uncertain", msymbol(Oh) mcolor(gs0) msize(large) lw(medthick) lc(gs0)) ///
		(connected coef t if t>0 & id=="uncertain", msymbol(O) mcolor(gs0)  msize(large) lw(medthick) lc(gs0)) ///
		(line min95 t if t<0 & id=="uncertain", lcolor(gs0) lw(med) lp(solid)) ///
		(line min95 t if t>0 & id=="uncertain", lcolor(gs0) lw(med) lp(solid)) ///
		(line max95 t if t<0 & id=="uncertain", lcolor(gs0) lw(med) lp(solid)) ///
		(line max95 t if t>0 & id=="uncertain", lcolor(gs0) lw(med) lp(solid)) ///
		(line ddc t if t>=0 & id=="uncertain", lc(gs10) lp(dash) lw(medthick)), /// 
		xline(0, lc(gs5) lw(medthick)) /// 
		yline(0, lc(gs5) lw(medthick)) ///
		xlabel(-8(1)8) ///
		ylabel(-6(2)6) ///
		text(5.5 -1 "DD estimate: `ddc_u'" "(s.e. = `dds_u')", ///
		size(medium) placement(w) box fc(white)) /// 
		ytitle("Coefficient and 95% C.I.") xtitle("Year after reform") ///
		graphregion(color(white)) bgcolor(white) legend(off) 
		graph export "figure4_`y'_2.pdf", replace			
	
	restore
	
	erase esd_`y'.dta
	
	}

}

// Figure 5.

if `figure5'==1{

	* Panel A.
	
		use ab_rh_police_and_crime_jeea_counties_add1.dta, clear
		
		spmap start_year using ab_rh_police_and_crime_jeea_counties_add2, ///
			  id(id) clmethod(unique) fcolor(Blues2)
		graph export "figure5A.pdf", replace	
	
	* Panel B. 
	
		use ab_rh_police_and_crime_jeea_counties_main.dta, clear

		drop if countyname == "Middlesex incl. London"
		drop if countyname == "York"
		drop if countyname == "Sussex"
		drop if countyname == "Suffolk"
	
		collapse (sum) police_any, by(year)
	
		* Keep years 1832-1892 for the graphs (60 years).
		drop if year<=1832
		drop if year>=1892

		* Plot: Number of police forces over time.
		twoway connected police_any year if year>=1830, sort ///
			xline(1857, lcolor(red)) ///
			msize(small) msymbol(circle) mc(black) lc(black) lp(solid) ///
			ytitle("Number of police forces, national") ///
			xtitle("Year of observation") xlabel(1830(10)1890) ///
			graphregion(color(white)) bgcolor(white) 
		graph export "figure5B.pdf", replace
	
}

********************************************************************************
***************************** II. TABLES MAIN TEXT *****************************
********************************************************************************

// Table 1.

if `table1'==1{

	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area

	gen crimes = 1

	* Collapse.
	collapse (sum) crimes, by(year month area treat uncertain offsubcat_comb)
	
	* Fill in missing values with zeros to construct panel.
	fillin year month area offsubcat_comb
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
		
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
		
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.
		
	* Reshape wide.
	reshape wide crimes, i(year month area treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
		
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
		
	* Create extensive margin variables.
	foreach var in crime_total burglary robbery homicide{
		count if `var'==.
		gen `var'_any = (`var'>0)
	}
	
	* Recode post variable (after aggregation to months).
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & month>=9
	
	* Panel A.
		
		* Burglary.
		bys area post1829: sum burglary if year>=1828 & year<=1832
		bys area: reg burglary 1.post1829 if year>=1828 & year<=1832, r	
		bys post1829: sum burglary if year>=1828 & year<=1832
		reg burglary 1.post1829 if year>=1828 & year<=1832, r	

		* Robbery.
		bys area post1829: sum robbery if year>=1828 & year<=1832
		bys area: reg robbery 1.post1829 if year>=1828 & year<=1832, r			
		bys post1829: sum robbery if year>=1828 & year<=1832
		reg robbery 1.post1829 if year>=1828 & year<=1832, r
		
		* Homicide.
		bys area post1829: sum homicide if year>=1828 & year<=1832
		bys area: reg homicide 1.post1829 if year>=1828 & year<=1832, r
		bys post1829: sum homicide if year>=1828 & year<=1832
		reg homicide 1.post1829 if year>=1828 & year<=1832, r		
		
		
	* Panel B.
		
		* Burglary.
		bys area post1829: sum burglary
		bys area: reg burglary 1.post1829, r	
		bys post1829: sum burglary
		reg burglary 1.post1829, r
		
		* Robbery.
		bys area post1829: sum robbery
		bys area: reg robbery 1.post1829, r			
		bys post1829: sum robbery
		reg robbery 1.post1829, r	
		
		* Homicide.
		bys area post1829: sum homicide
		bys area: reg homicide 1.post1829, r		
		bys post1829: sum homicide
		reg homicide 1.post1829, r
		
}	
	
// Table 2.

if `table2'==1{

	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen any_new_police = type_policeman + type_other_post
	replace any_new_police = (any_new_police>0)
	
	gen any_old_police = type_watchman + type_other_pre
	replace any_old_police = (any_old_police>0)
	
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment"
		label values area area
	tab area, m
	encode offsubcat_comb, gen(off)
			
	* Column (1). 
	bys area: reg any_police_testimony 1.post1829 i.off, r
	
	* Column (2).
	bys area: reg any_police_testimony 1.post1829 i.off if year>=1828 & year<=1832, r

	* Column (3). 
	bys area: reg any_new_police 1.post1829 i.off, r
	
	* Column (4).
	bys area: reg any_new_police 1.post1829 i.off if year>=1828 & year<=1832, r
	
	* Column (5). 
	bys area: reg any_old_police 1.post1829 i.off, r
	
	* Column (6).
	bys area: reg any_old_police 1.post1829 i.off if year>=1828 & year<=1832, r

	* Column (7). 
	bys area: reg police_at_crimescene 1.post1829 i.off, r
	
	* Column (8).
	bys area: reg police_at_crimescene 1.post1829 i.off if year>=1828 & year<=1832, r
	
	
}	
	
// Table 3.

if `table3'==1{

	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area

	gen crimes = 1

	* Collapse.
	collapse (sum) crimes, by(year month area treat uncertain offsubcat_comb)
	
	* Fill in missing values with zeros to construct panel.
	fillin year month area offsubcat_comb
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
		
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
		
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.
		
	* Reshape wide.
	reshape wide crimes, i(year month area treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
		
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
		
	* Create extensive margin variables.
	foreach var in burglary robbery homicide{
		count if `var'==.
		gen `var'_any = (`var'>0)
	}
	
	* Recode post variable (after aggregation to months).
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & month>=9
	
	* Loop over outcomes for Panel A to C:
	foreach y in burglary robbery homicide{
	
		* Column (1).
		reg `y' 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area, r

		* Column (2).			
		reg `y' 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area if year>=1828 & year<=1832, r			
	
		* Column (3).
		preserve
			replace treat = 1 if area==1 & year>1832
			replace treat = 1 if area==1 & year==1832 & month>=4
			gen treat_x_post1829 = treat*post1829
			gen uncertain_x_post1829 = uncertain*post1829
			reg `y' treat_x_post1829 uncertain_x_post1829 ///
				i.year i.month i.area if year>=1828 & year<=1832, r
		restore
		
		* Column (4).
		preserve
			replace treat = 0 if area==1
			replace uncertain = 1 if area==1		
			gen treat_x_post1829 = treat*post1829
			gen uncertain_x_post1829 = uncertain*post1829
			reg `y' treat_x_post1829 uncertain_x_post1829 ///
				i.year i.month i.area if year>=1828 & year<=1832, r
		restore		
		
		* Column (5).
		reg `y' 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area if area!=1 & year>=1828 & year<=1832, r	
					
		* Column (6).
		preserve 
			xtset area
			gen treat_post 		= treat*post1829
			gen uncertain_post	= uncertain*post1829
			tab year, g(year_d)
			tab month, g(month_d)
			xtpqml `y' treat_post uncertain_post year_d* month_d*, fe irr	
			xtset, clear
		restore	
		
		* Column (7).
		preserve 
			xtset area
			gen treat_post 		= treat*post1829
			gen uncertain_post	= uncertain*post1829
			tab year, g(year_d)
			tab month, g(month_d)
			xtpqml `y' treat_post uncertain_post year_d* month_d* ///
				   if year>=1828 & year<=1832, fe irr	
			xtset, clear
		restore	
	
	}	
			
	* Alternative aggregation level: Week by area.

	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area
	
	preserve
	
		keep year month day date
		duplicates drop
		sort date
		
		fillin year month day
		replace date = mdy(month,day,year)
		drop if date==.
		drop _fillin
		
		gen dow = dow(date)
		gen aux = (dow==0)
		bys year: gen week = sum(aux)
		drop dow aux
		
		bys year: egen maxweek = max(week)
		bys year: egen minweek = min(week)
		
		save temp_weeks.dta, replace
	
	restore
	
	* Merge weeks back into main data.
	merge m:1 year month day date using temp_weeks.dta
	keep if _m==3
	drop _m
	erase temp_weeks.dta
	
	* Collapse.
	gen crimes = 1
	collapse (sum) crimes (mean) maxweek minweek, by(year week area treat uncertain offsubcat_comb)
	
	* Fill in missing values with zeros to construct panel.
	fillin year week area offsubcat_comb
	
	bys year: egen maxweek2 = max(maxweek)
	drop if week>maxweek2
	drop maxweek maxweek2
	
	bys year: egen minweek2 = max(minweek)
	drop if week<minweek2
	drop minweek minweek2
	
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
		
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
		
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.
		
	* Reshape wide.
	reshape wide crimes, i(year week area treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
		
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
		
	* Create extensive margin variables
	foreach var in burglary robbery homicide{
		count if `var'==.
		gen `var'_any = (`var'>0)
	}
	
	* Recode post variable (after aggregation to months).
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & week>=39
	
	* Loop over outcomes for Panel A to C:
	foreach y in burglary robbery homicide{
	
		* Column (8).
		reg `y'_any 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.week i.area, r
			
		* Column (9).
		reg `y'_any 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.week i.area if year>=1828 & year<=1832, r	
	
	}
	
	* Alternative aggregation level: Month by distance band.
	
	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area
		
	* Create distance bands around Charing Cross.
	gen dist_group = .
		replace dist_group = 1 if dist_mls<=1
		replace dist_group = 2 if dist_mls>1 & dist_mls<=2
		replace dist_group = 3 if dist_mls>2 & dist_mls<=3
		replace dist_group = 4 if dist_mls>3 & dist_mls<=4
		replace dist_group = 5 if dist_mls>4 & dist_mls<=5
		replace dist_group = 6 if dist_mls>5 & dist_mls<=6
		replace dist_group = 7 if dist_mls>6 & dist_mls<=7
		replace dist_group = 8 if dist_mls>7 & dist_mls<=8
		replace dist_group = 9 if dist_mls>8 & dist_mls<=9
		replace dist_group = 10 if dist_mls>9 & dist_mls<=10
		replace dist_group = 11 if dist_mls>10 & dist_mls<=11
		replace dist_group = 12 if dist_mls>11 & dist_mls<=12
		replace dist_group = 13 if dist_mls>12 & dist_mls<=13
		replace dist_group = 14 if dist_mls>13 & dist_mls<=14
		replace dist_group = 15 if dist_mls>14

	* Collapse.
	gen crimes = 1
	collapse (sum) crimes, by(year month area dist_group treat uncertain offsubcat_comb)
	
	* Fill in missing values with zeros to construct panel.
	fillin year month area dist_group offsubcat_comb
	
	drop if area==1 & dist_group>3
	drop if area==2 & dist_group<8
	drop if area==3 & (dist_group<5|dist_group>7)
	drop if area==4 & dist_group>4
	
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
		
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
		
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.
		
	* Reshape wide.
	reshape wide crimes, i(year month area dist_group treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
		
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
		
	* Create extensive margin variables.
	foreach var in burglary robbery homicide{
		count if `var'==.
		gen `var'_any = (`var'>0)
	}
	
	* Recode post variable (after aggregation to months)
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & month>=9
	
	* Loop over outcomes for Panel A to C:
	foreach y in burglary robbery homicide{
	
		* Column (10).
		reg `y'_any 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area, r
			
		* Column (11).
		reg `y'_any 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area if year>=1828 & year<=1832, r			
	
	}
	
	
}
	
// Table 4.

if `table4'==1{

	use ab_rh_police_and_crime_jeea_london_main2.dta, clear
	drop if (office=="mp"|office=="t")
	
	* All incidents (4 columns).
	sum num_agg_total num_agg_prop num_agg_viol num_agg_other
	sum num_agg_total num_agg_prop num_agg_viol num_agg_other if year<1829
	sum num_agg_total num_agg_prop num_agg_viol num_agg_other if year==1830
	sum num_agg_total num_agg_prop num_agg_viol num_agg_other if year>1829
	
	* Informations (4 columns).
	sum numinfo_total numinfo_prop numinfo_viol numinfo_other ///
		anyinfo_total anyinfo_prop anyinfo_viol anyinfo_other
	sum numinfo_total numinfo_prop numinfo_viol numinfo_other ///
		anyinfo_total anyinfo_prop anyinfo_viol anyinfo_other if year<1829
	sum numinfo_total numinfo_prop numinfo_viol numinfo_other ///
		anyinfo_total anyinfo_prop anyinfo_viol anyinfo_other if year==1830
	sum numinfo_total numinfo_prop numinfo_viol numinfo_other ///
		anyinfo_total anyinfo_prop anyinfo_viol anyinfo_other if year>1829
	
	* Charges (4 columns)	
	sum numcharge_total numcharge_prop numcharge_viol numcharge_other ///
		anycharge_total anycharge_prop anycharge_viol anycharge_other
	sum numcharge_total numcharge_prop numcharge_viol numcharge_other ///
		anycharge_total anycharge_prop anycharge_viol anycharge_other if year<1829
	sum numcharge_total numcharge_prop numcharge_viol numcharge_other ///
		anycharge_total anycharge_prop anycharge_viol anycharge_other if year==1830
	sum numcharge_total numcharge_prop numcharge_viol numcharge_other ///
		anycharge_total anycharge_prop anycharge_viol anycharge_other if year>1829	
		
	* Property stolen (4 columns)	
	sum num_propstolen any_propstolen	
	sum num_propstolen any_propstolen if year<1829
	sum num_propstolen any_propstolen if year==1830
	sum num_propstolen any_propstolen if year>1829	
	
}

// Table 5.

if `table5'==1{

	use ab_rh_police_and_crime_jeea_london_main2.dta, clear
	drop if office=="mp"|office=="t"
				
	encode office, gen(office_fe)
	gen dow = dow(date)
	
	rename any_propstolen any_propstolen_total
	rename num_propstolen num_propstolen_total

	* Columns (1)-(6): OLS.
	
	* Panel A.
	reg num_agg_total postmet if year<1831, r	
	reg num_agg_total postmet i.office_fe i.calweek i.dow if year<1831, r	
	reg num_agg_total postmet i.office_fe i.calweek i.dow, r	
	reg num_agg_prop postmet i.office_fe i.calweek i.dow if year<1831, r
	reg num_agg_viol postmet i.office_fe i.calweek i.dow if year<1831, r
	reg num_agg_other postmet i.office_fe i.calweek i.dow if year<1831, r
	
	* Panel B.
	reg anyinfo_total postmet if year<1831, r	
	reg anyinfo_total postmet i.office_fe i.calweek i.dow if year<1831, r	
	reg anyinfo_total postmet i.office_fe i.calweek i.dow, r	
	reg anyinfo_prop postmet i.office_fe i.calweek i.dow if year<1831, r
	reg anyinfo_viol postmet i.office_fe i.calweek i.dow if year<1831, r
	reg anyinfo_other postmet i.office_fe i.calweek i.dow if year<1831, r	
	
	* Panel C.
	reg numinfo_total postmet if year<1831, r	
	reg numinfo_total postmet i.office_fe i.calweek i.dow if year<1831, r	
	reg numinfo_total postmet i.office_fe i.calweek i.dow, r	
	reg numinfo_prop postmet i.office_fe i.calweek i.dow if year<1831, r
	reg numinfo_viol postmet i.office_fe i.calweek i.dow if year<1831, r
	reg numinfo_other postmet i.office_fe i.calweek i.dow if year<1831, r		
	
	* Panel D.
	reg any_propstolen postmet if year<1831, r	 
	reg any_propstolen postmet i.office_fe i.calweek i.dow if year<1831, r	
	reg any_propstolen postmet i.office_fe i.calweek i.dow, r	
	
	* Panel E.
	reg numcharge_total postmet if year<1831, r	
	reg numcharge_total postmet i.office_fe i.calweek i.dow if year<1831, r	
	reg numcharge_total postmet i.office_fe i.calweek i.dow, r	
	reg numcharge_prop postmet i.office_fe i.calweek i.dow if year<1831, r
	reg numcharge_viol postmet i.office_fe i.calweek i.dow if year<1831, r
	reg numcharge_other postmet i.office_fe i.calweek i.dow if year<1831, r	
	
	
	* Columns (7)-(10): QML Poisson.
	
	xtset office_fe
	tab calweek, g(calweek_d)
	tab dow, g(dow_d)
	
	* Panel A.
	xtpqml num_agg_total postmet calweek_d* dow_d* if year<1831, fe irr	
	xtpqml num_agg_prop postmet calweek_d* dow_d* if year<1831, fe irr	
	xtpqml num_agg_viol postmet calweek_d* dow_d* if year<1831, fe irr	
	xtpqml num_agg_other postmet calweek_d* dow_d* if year<1831, fe irr	
	
	* Panel C.
	xtpqml numinfo_total postmet calweek_d* dow_d* if year<1831, fe irr	
	xtpqml numinfo_prop postmet calweek_d* dow_d* if year<1831, fe irr	
	xtpqml numinfo_viol postmet calweek_d* dow_d* if year<1831, fe irr	
	xtpqml numinfo_other postmet calweek_d* dow_d* if year<1831, fe irr	
	
	* Panel E.
	xtpqml numcharge_total postmet calweek_d* dow_d* if year<1831, fe irr	
	xtpqml numcharge_prop postmet calweek_d* dow_d* if year<1831, fe irr	
	xtpqml numcharge_viol postmet calweek_d* dow_d* if year<1831, fe irr	
	xtpqml numcharge_other postmet calweek_d* dow_d* if year<1831, fe irr	
	
}

// Table 6.

if `table6'==1{
	
	use ab_rh_police_and_crime_jeea_london_main2.dta, clear
	drop if office=="mp"
				
	encode office, gen(office_fe)
	gen dow = dow(date)
	
	rename any_propstolen any_propstolen_total
	rename num_propstolen num_propstolen_total

	* Column (1). 
	reg num_agg_total postmet_jan1830 postmet_nonjan1830 postmet_1831 postmet_1832 ///
		i.office_fe i.calweek i.dow if office!="t" & year<1833, r
	test postmet_jan1830 = postmet_nonjan1830 = postmet_1831 = postmet_1832
	
	* Column (2).
	reg num_agg_prop postmet_jan1830 postmet_nonjan1830 postmet_1831 postmet_1832 ///
		i.office_fe i.calweek i.dow if office!="t" & year<1833, r
	test postmet_jan1830 = postmet_nonjan1830 = postmet_1831 = postmet_1832
	
	* Column (3).
	reg num_agg_viol postmet_jan1830 postmet_nonjan1830 postmet_1831 postmet_1832 ///
		i.office_fe i.calweek i.dow if office!="t" & year<1833, r
	test postmet_jan1830 = postmet_nonjan1830 = postmet_1831 = postmet_1832
	
	
	* Column (4).
	reg numcharge_total postmet_jan1830 postmet_nonjan1830 postmet_1831 postmet_1832 ///
		i.office_fe i.calweek i.dow if office!="t" & year<1833, r
	test postmet_jan1830 = postmet_nonjan1830 = postmet_1831 = postmet_1832
	
	* Column (5).
	reg numcharge_prop postmet_jan1830 postmet_nonjan1830 postmet_1831 postmet_1832 ///
		i.office_fe i.calweek i.dow if office!="t" & year<1833, r
	test postmet_jan1830 = postmet_nonjan1830 = postmet_1831 = postmet_1832
	
	* Column (6).
	reg numcharge_viol postmet_jan1830 postmet_nonjan1830 postmet_1831 postmet_1832 ///
		i.office_fe i.calweek i.dow if office!="t" & year<1833, r
	test postmet_jan1830 = postmet_nonjan1830 = postmet_1831 = postmet_1832
	
	
	* Column (7).
	reg anyinfo_total postmet_jan1830 postmet_nonjan1830 postmet_1831 postmet_1832 ///
		i.office_fe i.calweek i.dow if office!="t" & year<1833, r
	test postmet_jan1830 = postmet_nonjan1830 = postmet_1831 = postmet_1832

	* Column (8).
	reg anyinfo_prop postmet_jan1830 postmet_nonjan1830 postmet_1831 postmet_1832 ///
		i.office_fe i.calweek i.dow if office!="t" & year<1833, r
	test postmet_jan1830 = postmet_nonjan1830 = postmet_1831 = postmet_1832
	
	* Column (9).
	reg anyinfo_viol postmet_jan1830 postmet_nonjan1830 postmet_1831 postmet_1832 ///
		i.office_fe i.calweek i.dow if office!="t" & year<1833, r
	test postmet_jan1830 = postmet_nonjan1830 = postmet_1831 = postmet_1832	
	
	
	* Column (10).
	reg any_propstolen postmet_jan1830 postmet_nonjan1830 postmet_1831 postmet_1832 ///
		i.office_fe i.calweek i.dow if office!="t" & year<1833, r
	test postmet_jan1830 = postmet_nonjan1830 = postmet_1831 = postmet_1832
		
	
}

// Table 7.

if `table7'==1{

	use ab_rh_police_and_crime_jeea_counties_main.dta, clear
	keep if extmarg_sample_3265==1
	
	by countyname, sort: egen temp = min(year) if force_existence_all == 1
	by countyname, sort: egen first_full_year = max(temp)
	drop temp
	
	* Generate indicators if force is efficient or inefficient at creation, 
	* using different thresholds; generate interaction with force existence 
	* variable (measuring existence of an efficient or inefficient force).
	
	forvalues x=1500(250)2500{
		gen eff`x' = (people_per_police_initial<=`x' & people_per_police_initial!=.)
		gen force_eff`x' = force_existence_all * eff`x'
		gen ineff`x' = (people_per_police_initial>`x' & people_per_police_initial!=.)
		gen force_ineff`x' = force_existence_all * ineff`x'
	}
	
	* Loop over outcomes for Panels A-D:
	foreach var in log_charges log_violcharges log_propcharges log_othercharges {
	
		* Column (1).
		xi: reg `var' force_existence_all i.countyname i.year, cluster(countyname)
		drop _I*
			
		* Column (2).	
		xi: reg `var' force_eff1500 force_ineff1500 i.countyname i.year, cluster(countyname)
		test force_eff1500 = force_ineff1500
		drop _I*
			
		* Column (3).	
		xi: reg `var' force_eff2000 force_ineff2000 i.countyname i.year, cluster(countyname)
		test force_eff2000 = force_ineff2000
		drop _I*
		
		* Column (4).	
		xi: reg `var' force_eff2500 force_ineff2500 i.countyname i.year, cluster(countyname)
		test force_eff2500 = force_ineff2500
		drop _I*		
		
	}

}

********************************************************************************
***************************** III. ONLINE APPENDIX FIGURES A *******************
********************************************************************************

// Appendix Figure A1.

if `figureA1'==1{

	use ab_rh_police_and_crime_jeea_london_add4.dta, clear
	
		twoway ///
			(line old_bailey_murders year, lp(solid) lcolor(gs0) lw(medthick)) ///
			(line london_homicides year, lp(dash) lcolor(gs8) lw(medthick)), ///
			xline(1821 1837, lp(dash)) ///
			xlabel(1715 1750(50)1900) ylabel(0(10)70) ///
			legend(order(1 2)) ///
			graphregion(color(white)) bgcolor(white)
			graph export "figureA1.pdf", replace

}

// Appendix Figure A2.

if `figureA2'==1{

	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen cases = 1
	
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment"
		label values area area
	
	replace offsubcat_comb = "homicide" if offsubcat_comb=="manslaughter" | offsubcat_comb=="murder"
	
	collapse (sum) cases, by(year month area offsubcat_comb)
	gen date = ym(year,month)
	format date %tm
	
	* Panel A.
	
		twoway ///
			(line cases date if area==4 & offsubcat_comb=="burglary_combined", ///
				lp(solid) lc(gs0) lw(medthick)) /// 
			(line cases date if area==3 & offsubcat_comb=="burglary_combined", ///
				lp(solid) lc(gs4) lw(medthick)) ///
			(line cases date if area==2 & offsubcat_comb=="burglary_combined", ///
				lp(solid) lc(gs8) lw(medthick)) ///
			(line cases date if area==1 & offsubcat_comb=="burglary_combined", ///
				lp(solid) lc(gs12) lw(medthick)), ///
			tline(1829m9, lp(solid) lc(red)) ///
			title("Burglary") ///
			ytitle("Number of crimes by month", size(*0.9)) ///
			ylabel(0(5)20) xtitle("") ///
			tlabel(1821m1(24)1837m1, labsize(*0.9)) ///
			legend(order(1 2 3 4) cols(2) size(small) ///
			label(1 "Treated area") label(2 "Uncertainty area") ///
			label(3 "Control area (outside 7-miles)") ///
			label(4 "Control area (City of London)")) ///
			graphregion(color(white)) bgcolor(white) 
			graph export "figureA2A.pdf", replace
	
		twoway ///
			(line cases date if area==4 & offsubcat_comb=="robbery_combined", ///
				lp(solid) lc(gs0) lw(medthick)) /// 
			(line cases date if area==3 & offsubcat_comb=="robbery_combined", ///
				lp(solid) lc(gs4) lw(medthick)) ///
			(line cases date if area==2 & offsubcat_comb=="robbery_combined", ///
				lp(solid) lc(gs8) lw(medthick)) ///
			(line cases date if area==1 & offsubcat_comb=="robbery_combined", ///
				lp(solid) lc(gs12) lw(medthick)), ///
			tline(1829m9, lp(solid) lc(red)) ///
			title("Robbery") ///
			ytitle("Number of crimes by month", size(*0.9)) ///
			ylabel(0(5)20) xtitle("") ///
			tlabel(1821m1(24)1837m1, labsize(*0.9)) ///
			legend(order(1 2 3 4) cols(2) size(small) ///
			label(1 "Treated area") label(2 "Uncertainty area") ///
			label(3 "Control area (outside 7-miles)") ///
			label(4 "Control area (City of London)")) ///
			graphregion(color(white)) bgcolor(white) 
			graph export "figureA2B.pdf", replace
		
		twoway ///
			(line cases date if area==4 & offsubcat_comb=="homicide", ///
				lp(solid) lc(gs0) lw(medthick)) /// 
			(line cases date if area==3 & offsubcat_comb=="homicide", ///
				lp(solid) lc(gs4) lw(medthick)) ///
			(line cases date if area==2 & offsubcat_comb=="homicide", ///
				lp(solid) lc(gs8) lw(medthick)) ///
			(line cases date if area==1 & offsubcat_comb=="homicide", ///
				lp(solid) lc(gs12) lw(medthick)), ///
			tline(1829m9, lp(solid) lc(red)) ///
			title("Homicide") ///
			ytitle("Number of crimes by month", size(*0.9)) ///
			ylabel(0(5)20) xtitle("") ///
			tlabel(1821m1(24)1837m1, labsize(*0.9)) ///
			legend(order(1 2 3 4) cols(2) size(small) ///
			label(1 "Treated area") label(2 "Uncertainty area") ///
			label(3 "Control area (outside 7-miles)") ///
			label(4 "Control area (City of London)")) ///
			graphregion(color(white)) bgcolor(white) 
			graph export "figureA2C.pdf", replace

}
	
// Appendix Figure A3.

if `figureA3'==1{

	use ab_rh_police_and_crime_jeea_london_add5.dta, clear
	
		twoway ///
			(connected deaths year, m(O) mc(gs0) lp(solid) lc(gs0) lw(medthick)) ///
			(connected choleradeaths year, m(O) mc(gs0) lp(dash) lc(gs0) lw(medthick)), ///
			xlabel(1830(1)1836) ylabel(0(10)50) ///
			legend(order(1 2)) ///
			graphregion(color(white)) bgcolor(white)
			graph export "figureA3.pdf", replace
}

// Appendix Figure A4.

if `figureA4'==1{

	use ab_rh_police_and_crime_jeea_london_add6.dta, clear
	
	replace city = city/1000
	replace inner_nocity = inner_nocity/1000
	replace outer = outer/1000
		
	* Panel A.
	
		twoway ///
			(connected inner_nocity year, ///
				m(O) mc(gs0) lp(solid) lc(gs0) lw(medthick)) ///
			(connected outer year, ///
				m(O) mc(gs5) lp(solid) lc(gs5) lw(medthick)) ///
			(connected city year, ///
				m(O) mc(gs10) lp(solid) lc(gs10) lw(medthick)), ///
			xlabel(1811(10)1901) ylabel(0(1000)6000) ///
			ytitle("Population (in thousands)") ///
			legend(order(1 2 3) label(1 "Inner London (excl. City)") ///
			label(2 "Outer London") label (3 "City of London") col(3) size(small)) ///
			graphregion(color(white)) bgcolor(white)
			graph export "figureA4A.pdf", replace
		
	* Panel B.
	
		twoway ///
			(connected growth_inner_nocity year, ///
				m(O) mc(gs0) lp(solid) lc(gs0) lw(medthick)) ///
			(connected growth_outer year, ///
				m(O) mc(gs5) lp(solid) lc(gs5) lw(medthick)) ///
			(connected growth_city year, ///
				m(O) mc(gs10) lp(solid) lc(gs10) lw(medthick)), ///
			xlabel(1811(10)1901) ylabel(-50(25)50) ///
			ytitle("Population growth in %") yline(0, lc(black)) ///
			legend(order(1 2 3) label(1 "Inner London (excl. City)") ///
			label(2 "Outer London") label (3 "City of London") col(3) size(small)) ///
			graphregion(color(white)) bgcolor(white)
			graph export "figureA4B.pdf", replace
		
}

// Appendix Figure A5.

if `figureA5'==1{
	
	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area
		
	* Create distance bands around Charing Cross.
	gen dist_group = .
		replace dist_group = 1 if dist_mls<=1
		replace dist_group = 2 if dist_mls>1 & dist_mls<=2
		replace dist_group = 3 if dist_mls>2 & dist_mls<=3
		replace dist_group = 4 if dist_mls>3 & dist_mls<=4
		replace dist_group = 5 if dist_mls>4 & dist_mls<=5
		replace dist_group = 6 if dist_mls>5 & dist_mls<=6
		replace dist_group = 7 if dist_mls>6 & dist_mls<=7
		replace dist_group = 8 if dist_mls>7 & dist_mls<=8
		replace dist_group = 9 if dist_mls>8 & dist_mls<=9
		replace dist_group = 10 if dist_mls>9 & dist_mls<=10
		replace dist_group = 11 if dist_mls>10 & dist_mls<=11
		replace dist_group = 12 if dist_mls>11 & dist_mls<=12
		replace dist_group = 13 if dist_mls>12 & dist_mls<=13
		replace dist_group = 14 if dist_mls>13 & dist_mls<=14
		replace dist_group = 15 if dist_mls>14

	* Collapse.
	gen crimes = 1
	collapse (sum) crimes, by(year month area dist_group treat uncertain offsubcat_comb)
	
	* Fill in missing values with zeros to construct panel.
	fillin year month area dist_group offsubcat_comb
	
	drop if area==1 & dist_group>3
	drop if area==2 & dist_group<8
	drop if area==3 & (dist_group<5|dist_group>7)
	drop if area==4 & dist_group>4
	
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
		
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
		
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.
		
	* Reshape wide.
	reshape wide crimes, i(year month area dist_group treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
		
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
		
	* Create extensive margin variables.
	foreach var in burglary robbery homicide{
		count if `var'==.
		gen `var'_any = (`var'>0)
	}
	
	* Recode post variable (after aggregation to months).
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & month>=9
	
	preserve

		* Create differences in means.
		keep if year>=1828 & year<=1832
		collapse (count) burglary_N=burglary robbery_N=robbery homicide_N=homicide ///
				 (mean)  burglary_m=burglary robbery_m=robbery homicide_m=homicide ///
				 (sd) 	 burglary_sd=burglary robbery_sd=robbery homicide_sd=homicide, ///
						 by(dist_group post1829)
		reshape long burglary_ robbery_ homicide_, i(dist_group post1829) j(stat) string
		reshape wide burglary_-homicide_, i(dist_group stat) j(post1829)
		rename *_0 *_before
		rename *_1 *_after
		order dist_group stat burglary* robbery* homicide*
		keep if stat=="m"
		drop stat
		
		foreach var in burglary robbery homicide{
			gen `var'_diff = `var'_after-`var'_before
		}
		
		* Panel A.
		
		twoway /// 
		(line burglary_diff dist_group, lp(longdash) lc(gs2) lw(medthick)) ///
		(line robbery_diff dist_group, lp(shortdash) lc(gs4) lw(medthick)) ///
		(line homicide_diff dist_group, lp(dot) lc(gs6) lw(medthick)), /// 
		xline(4 7, lp(dash)) xlabel(1(1)15) ylabel(-1(.5)1) ///
		ytitle("Difference in means") ///
		xtitle("Distance from Charing Cross (in miles)") ///
		legend(order(1 2 3) ///
		label(1 "Burglary") label(2 "Robbery") label(3 "Homicide") col(3)) ///
		graphregion(color(white)) bgcolor(white) ///
		text(1 2 "Treated", size(medium) placement(s)) ///
		text(1 5.5 "Uncertain", size(medium) placement(s)) ///
		text(1 11 "Control", size(medium) placement(s))
		graph export "figureA5A.pdf", replace
		
	restore	
	
	preserve

		* Create differences in means.
		collapse (count) burglary_N=burglary robbery_N=robbery homicide_N=homicide ///
				 (mean)  burglary_m=burglary robbery_m=robbery homicide_m=homicide ///
				 (sd) 	 burglary_sd=burglary robbery_sd=robbery homicide_sd=homicide, ///
						 by(dist_group post1829)
		reshape long burglary_ robbery_ homicide_, i(dist_group post1829) j(stat) string
		reshape wide burglary_-homicide_, i(dist_group stat) j(post1829)
		rename *_0 *_before
		rename *_1 *_after
		order dist_group stat burglary* robbery* homicide*
		keep if stat=="m"
		drop stat
		
		foreach var in burglary robbery homicide{
			gen `var'_diff = `var'_after-`var'_before
		}
		
		* Panel B.
		
		twoway /// 
		(line burglary_diff dist_group, lp(longdash) lc(gs2) lw(medthick)) ///
		(line robbery_diff dist_group, lp(shortdash) lc(gs4) lw(medthick)) ///
		(line homicide_diff dist_group, lp(dot) lc(gs6) lw(medthick)), /// 
		xline(4 7, lp(dash)) xlabel(1(1)15) ylabel(-1(.5)1) ///
		ytitle("Difference in means") ///
		xtitle("Distance from Charing Cross (in miles)") ///
		legend(order(1 2 3) ///
		label(1 "Burglary") label(2 "Robbery") label(3 "Homicide") col(3)) ///
		graphregion(color(white)) bgcolor(white) ///
		text(1 2 "Treated", size(medium) placement(s)) ///
		text(1 5.5 "Uncertain", size(medium) placement(s)) ///
		text(1 11 "Control", size(medium) placement(s))
		graph export "figureA5B.pdf", replace
		
	restore	
	
}

********************************************************************************
***************************** IV. ONLINE APPENDIX TABLES A *********************
********************************************************************************

// Appendix Table A1.

if `tableA1'==1{

	use ab_rh_police_and_crime_jeea_london_add2.dta, clear
	
		gen temp = 1
		collapse (sum) temp, by(div)	
		drop if div=="."|div=="Supervisory"
		rename temp all_hires
		save temp.dta, replace	
	
	use ab_rh_police_and_crime_jeea_london_add2.dta, clear
	
		gen stayer = (servicelength>=250)
		gen temp = 1
		collapse (sum) temp, by(div stayer)
		reshape wide temp, i(div) j(stayer) 
		drop if div=="."|div=="Supervisory"
		drop temp0
		rename temp1 all_hires_250
		merge 1:1 div using temp.dta
		drop _m
		order div all_hires
		save temp.dta, replace
	
	use ab_rh_police_and_crime_jeea_london_add2.dta, clear
		
		gen early_joiners = (joindate<td(01feb1830))
		keep if servicelength>=250
		gen temp = 1
		collapse (sum) temp, by(early_joiners div)
	
		reshape wide temp, i(div) j(early_joiners) 
		drop if div=="."|div=="Supervisory"
		rename temp0 After_Feb1830_250
		rename temp1 Before_Feb1830_250
		replace Before_Feb1830_250 = 0 if Before_Feb1830_250==.
		
		merge 1:1 div using temp.dta
		drop _m
		erase temp.dta
		
		order div all_hires all_hires_250 Before_Feb1830_250 After_Feb1830_250
		rename div Division
		
		gen cat = "early" if Division=="A" | Division=="B" | Division=="C" | ///
							 Division=="D" | Division=="E" | Division=="F"
		replace cat = "late" if cat==""
	
		label var Division 			 "Met. Police Division"
		label var all_hires 		 "All hires: 21 Sep 1829-27 Mar 1830; all"
		label var all_hires_250 	 "All hires: 21 Sep 1829-27 Mar 1830; service length>=250 days"
		label var Before_Feb1830_250 "Early hires: 21 Sep 1829-31 Jan 1830; service length>=250 days"
		label var After_Feb1830_250  "Late hires: 01 Feb 1830-27 Mar 1830; service length>=250 days"
		label var cat				 "Early/late"
		
		describe
		list, table 	

}

// Appendix Table A3.

if `tableA3'==1{

	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen obs = 1
	tab offsubcat_comb, g(off)
	rename off1 burglary
	rename off2 manslaughter
	rename off3 murder 
	rename off4 robbery
	
	* Column (1).
	sum obs 		if within_7mls==1 & city==0 & post1829==0
	sum obs 		if within_7mls==1 & city==0 & post1829==0 & burglary==1
	sum obs 		if within_7mls==1 & city==0 & post1829==0 & manslaughter==1
	sum obs 		if within_7mls==1 & city==0 & post1829==0 & murder==1
	sum obs 		if within_7mls==1 & city==0 & post1829==0 & robbery==1
	sum dist_mls 				if within_7mls==1 & city==0 & post1829==0
	sum dist_km	 				if within_7mls==1 & city==0 & post1829==0	
	sum codef	 				if within_7mls==1 & city==0 & post1829==0		
	sum date_difference			if within_7mls==1 & city==0 & post1829==0			
	sum any_police_testimony	if within_7mls==1 & city==0 & post1829==0
	sum number_police_witness	if within_7mls==1 & city==0 & post1829==0
	sum type_constable			if within_7mls==1 & city==0 & post1829==0
	sum type_policeman			if within_7mls==1 & city==0 & post1829==0
	sum type_watchman			if within_7mls==1 & city==0 & post1829==0
	sum type_other_pre			if within_7mls==1 & city==0 & post1829==0
	sum type_other_post			if within_7mls==1 & city==0 & post1829==0
	sum type_missing			if within_7mls==1 & city==0 & post1829==0
	sum police_at_crimescene	if within_7mls==1 & city==0 & post1829==0
		
	* Column (2).
	sum obs 		if within_7mls==1 & city==0 & post1829==1
	sum obs 		if within_7mls==1 & city==0 & post1829==1 & burglary==1
	sum obs 		if within_7mls==1 & city==0 & post1829==1 & manslaughter==1
	sum obs 		if within_7mls==1 & city==0 & post1829==1 & murder==1
	sum obs 		if within_7mls==1 & city==0 & post1829==1 & robbery==1
	sum dist_mls 				if within_7mls==1 & city==0 & post1829==1
	sum dist_km	 				if within_7mls==1 & city==0 & post1829==1	
	sum codef	 				if within_7mls==1 & city==0 & post1829==1		
	sum date_difference			if within_7mls==1 & city==0 & post1829==1			
	sum any_police_testimony	if within_7mls==1 & city==0 & post1829==1
	sum number_police_witness	if within_7mls==1 & city==0 & post1829==1
	sum type_constable			if within_7mls==1 & city==0 & post1829==1
	sum type_policeman			if within_7mls==1 & city==0 & post1829==1
	sum type_watchman			if within_7mls==1 & city==0 & post1829==1
	sum type_other_pre			if within_7mls==1 & city==0 & post1829==1
	sum type_other_post			if within_7mls==1 & city==0 & post1829==1
	sum type_missing			if within_7mls==1 & city==0 & post1829==1
	sum police_at_crimescene	if within_7mls==1 & city==0 & post1829==1		
		
	* Column (3).
	sum obs 		if within_7mls==1 & city==0 & year>=1828 & year<=1832
	sum obs 		if within_7mls==1 & city==0 & year>=1828 & year<=1832 & burglary==1
	sum obs 		if within_7mls==1 & city==0 & year>=1828 & year<=1832 & manslaughter==1
	sum obs 		if within_7mls==1 & city==0 & year>=1828 & year<=1832 & murder==1
	sum obs 		if within_7mls==1 & city==0 & year>=1828 & year<=1832 & robbery==1
	sum dist_mls 				if within_7mls==1 & city==0 & year>=1828 & year<=1832
	sum dist_km	 				if within_7mls==1 & city==0 & year>=1828 & year<=1832	
	sum codef	 				if within_7mls==1 & city==0 & year>=1828 & year<=1832		
	sum date_difference			if within_7mls==1 & city==0 & year>=1828 & year<=1832			
	sum any_police_testimony	if within_7mls==1 & city==0 & year>=1828 & year<=1832
	sum number_police_witness	if within_7mls==1 & city==0 & year>=1828 & year<=1832
	sum type_constable			if within_7mls==1 & city==0 & year>=1828 & year<=1832
	sum type_policeman			if within_7mls==1 & city==0 & year>=1828 & year<=1832
	sum type_watchman			if within_7mls==1 & city==0 & year>=1828 & year<=1832
	sum type_other_pre			if within_7mls==1 & city==0 & year>=1828 & year<=1832
	sum type_other_post			if within_7mls==1 & city==0 & year>=1828 & year<=1832
	sum type_missing			if within_7mls==1 & city==0 & year>=1828 & year<=1832
	sum police_at_crimescene	if within_7mls==1 & city==0 & year>=1828 & year<=1832
	
	* Column (4).
	sum obs 		if within_7mls==0 & city==1 & post1829==0
	sum obs 		if within_7mls==0 & city==1 & post1829==0 & burglary==1
	sum obs 		if within_7mls==0 & city==1 & post1829==0 & manslaughter==1
	sum obs 		if within_7mls==0 & city==1 & post1829==0 & murder==1
	sum obs 		if within_7mls==0 & city==1 & post1829==0 & robbery==1
	sum dist_mls 				if within_7mls==0 & city==1 & post1829==0
	sum dist_km	 				if within_7mls==0 & city==1 & post1829==0	
	sum codef	 				if within_7mls==0 & city==1 & post1829==0		
	sum date_difference			if within_7mls==0 & city==1 & post1829==0			
	sum any_police_testimony	if within_7mls==0 & city==1 & post1829==0
	sum number_police_witness	if within_7mls==0 & city==1 & post1829==0
	sum type_constable			if within_7mls==0 & city==1 & post1829==0
	sum type_policeman			if within_7mls==0 & city==1 & post1829==0
	sum type_watchman			if within_7mls==0 & city==1 & post1829==0
	sum type_other_pre			if within_7mls==0 & city==1 & post1829==0
	sum type_other_post			if within_7mls==0 & city==1 & post1829==0
	sum type_missing			if within_7mls==0 & city==1 & post1829==0
	sum police_at_crimescene	if within_7mls==0 & city==1 & post1829==0
		
	* Column (5).
	sum obs 		if within_7mls==0 & city==1 & post1829==1
	sum obs 		if within_7mls==0 & city==1 & post1829==1 & burglary==1
	sum obs 		if within_7mls==0 & city==1 & post1829==1 & manslaughter==1
	sum obs 		if within_7mls==0 & city==1 & post1829==1 & murder==1
	sum obs 		if within_7mls==0 & city==1 & post1829==1 & robbery==1
	sum dist_mls 				if within_7mls==0 & city==1 & post1829==1
	sum dist_km	 				if within_7mls==0 & city==1 & post1829==1	
	sum codef	 				if within_7mls==0 & city==1 & post1829==1		
	sum date_difference			if within_7mls==0 & city==1 & post1829==1			
	sum any_police_testimony	if within_7mls==0 & city==1 & post1829==1
	sum number_police_witness	if within_7mls==0 & city==1 & post1829==1
	sum type_constable			if within_7mls==0 & city==1 & post1829==1
	sum type_policeman			if within_7mls==0 & city==1 & post1829==1
	sum type_watchman			if within_7mls==0 & city==1 & post1829==1
	sum type_other_pre			if within_7mls==0 & city==1 & post1829==1
	sum type_other_post			if within_7mls==0 & city==1 & post1829==1
	sum type_missing			if within_7mls==0 & city==1 & post1829==1
	sum police_at_crimescene	if within_7mls==0 & city==1 & post1829==1		
		
	* Column (6).
	sum obs 		if within_7mls==0 & city==1 & year>=1828 & year<=1832
	sum obs 		if within_7mls==0 & city==1 & year>=1828 & year<=1832 & burglary==1
	sum obs 		if within_7mls==0 & city==1 & year>=1828 & year<=1832 & manslaughter==1
	sum obs 		if within_7mls==0 & city==1 & year>=1828 & year<=1832 & murder==1
	sum obs 		if within_7mls==0 & city==1 & year>=1828 & year<=1832 & robbery==1
	sum dist_mls 				if within_7mls==0 & city==1 & year>=1828 & year<=1832
	sum dist_km	 				if within_7mls==0 & city==1 & year>=1828 & year<=1832	
	sum codef	 				if within_7mls==0 & city==1 & year>=1828 & year<=1832		
	sum date_difference			if within_7mls==0 & city==1 & year>=1828 & year<=1832			
	sum any_police_testimony	if within_7mls==0 & city==1 & year>=1828 & year<=1832
	sum number_police_witness	if within_7mls==0 & city==1 & year>=1828 & year<=1832
	sum type_constable			if within_7mls==0 & city==1 & year>=1828 & year<=1832
	sum type_policeman			if within_7mls==0 & city==1 & year>=1828 & year<=1832
	sum type_watchman			if within_7mls==0 & city==1 & year>=1828 & year<=1832
	sum type_other_pre			if within_7mls==0 & city==1 & year>=1828 & year<=1832
	sum type_other_post			if within_7mls==0 & city==1 & year>=1828 & year<=1832
	sum type_missing			if within_7mls==0 & city==1 & year>=1828 & year<=1832
	sum police_at_crimescene	if within_7mls==0 & city==1 & year>=1828 & year<=1832
	
	* Column (7).
	sum obs 		if within_7mls==0 & city==0 & post1829==0
	sum obs 		if within_7mls==0 & city==0 & post1829==0 & burglary==1
	sum obs 		if within_7mls==0 & city==0 & post1829==0 & manslaughter==1
	sum obs 		if within_7mls==0 & city==0 & post1829==0 & murder==1
	sum obs 		if within_7mls==0 & city==0 & post1829==0 & robbery==1
	sum dist_mls 				if within_7mls==0 & city==0 & post1829==0
	sum dist_km	 				if within_7mls==0 & city==0 & post1829==0	
	sum codef	 				if within_7mls==0 & city==0 & post1829==0		
	sum date_difference			if within_7mls==0 & city==0 & post1829==0			
	sum any_police_testimony	if within_7mls==0 & city==0 & post1829==0
	sum number_police_witness	if within_7mls==0 & city==0 & post1829==0
	sum type_constable			if within_7mls==0 & city==0 & post1829==0
	sum type_policeman			if within_7mls==0 & city==0 & post1829==0
	sum type_watchman			if within_7mls==0 & city==0 & post1829==0
	sum type_other_pre			if within_7mls==0 & city==0 & post1829==0
	sum type_other_post			if within_7mls==0 & city==0 & post1829==0
	sum type_missing			if within_7mls==0 & city==0 & post1829==0
	sum police_at_crimescene	if within_7mls==0 & city==0 & post1829==0
		
	* Column (8).
	sum obs 		if within_7mls==0 & city==0 & post1829==1
	sum obs 		if within_7mls==0 & city==0 & post1829==1 & burglary==1
	sum obs 		if within_7mls==0 & city==0 & post1829==1 & manslaughter==1
	sum obs 		if within_7mls==0 & city==0 & post1829==1 & murder==1
	sum obs 		if within_7mls==0 & city==0 & post1829==1 & robbery==1
	sum dist_mls 				if within_7mls==0 & city==0 & post1829==1
	sum dist_km	 				if within_7mls==0 & city==0 & post1829==1	
	sum codef	 				if within_7mls==0 & city==0 & post1829==1		
	sum date_difference			if within_7mls==0 & city==0 & post1829==1			
	sum any_police_testimony	if within_7mls==0 & city==0 & post1829==1
	sum number_police_witness	if within_7mls==0 & city==0 & post1829==1
	sum type_constable			if within_7mls==0 & city==0 & post1829==1
	sum type_policeman			if within_7mls==0 & city==0 & post1829==1
	sum type_watchman			if within_7mls==0 & city==0 & post1829==1
	sum type_other_pre			if within_7mls==0 & city==0 & post1829==1
	sum type_other_post			if within_7mls==0 & city==0 & post1829==1
	sum type_missing			if within_7mls==0 & city==0 & post1829==1
	sum police_at_crimescene	if within_7mls==0 & city==0 & post1829==1		
		
	* Column (9).
	sum obs 		if within_7mls==0 & city==0 & year>=1828 & year<=1832
	sum obs 		if within_7mls==0 & city==0 & year>=1828 & year<=1832 & burglary==1
	sum obs 		if within_7mls==0 & city==0 & year>=1828 & year<=1832 & manslaughter==1
	sum obs 		if within_7mls==0 & city==0 & year>=1828 & year<=1832 & murder==1
	sum obs 		if within_7mls==0 & city==0 & year>=1828 & year<=1832 & robbery==1
	sum dist_mls 				if within_7mls==0 & city==0 & year>=1828 & year<=1832
	sum dist_km	 				if within_7mls==0 & city==0 & year>=1828 & year<=1832	
	sum codef	 				if within_7mls==0 & city==0 & year>=1828 & year<=1832		
	sum date_difference			if within_7mls==0 & city==0 & year>=1828 & year<=1832			
	sum any_police_testimony	if within_7mls==0 & city==0 & year>=1828 & year<=1832
	sum number_police_witness	if within_7mls==0 & city==0 & year>=1828 & year<=1832
	sum type_constable			if within_7mls==0 & city==0 & year>=1828 & year<=1832
	sum type_policeman			if within_7mls==0 & city==0 & year>=1828 & year<=1832
	sum type_watchman			if within_7mls==0 & city==0 & year>=1828 & year<=1832
	sum type_other_pre			if within_7mls==0 & city==0 & year>=1828 & year<=1832
	sum type_other_post			if within_7mls==0 & city==0 & year>=1828 & year<=1832
	sum type_missing			if within_7mls==0 & city==0 & year>=1828 & year<=1832
	sum police_at_crimescene	if within_7mls==0 & city==0 & year>=1828 & year<=1832	

}

// Appendix Table A4.

if `tableA4'==1{

	* Area specific trend (columns 1-2).
	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area

	gen crimes = 1

	* Collapse.
	collapse (sum) crimes, by(year month area treat uncertain offsubcat_comb)
	
	* Fill in missing values with zeros to construct panel.
	fillin year month area offsubcat_comb
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
		
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
		
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.
		
	* Reshape wide.
	reshape wide crimes, i(year month area treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
		
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
		
	* Create extensive margin variables.
	foreach var in burglary robbery homicide{
		count if `var'==.
		gen `var'_any = (`var'>0)
	}
	
	* Recode post variable (after aggregation to months).
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & month>=9
	
	gen t = year - 1820
	
	* Loop over outcomes for Panel A to C:
	foreach y in burglary robbery homicide{

		* Column (1).
		reg `y' 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area i.area#c.t, r	

		* Column (2).			
		reg `y' 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area i.area#c.t if year>=1828 & year<=1832, r	
	
	}
	
	
	* Exclude "long streets" locations.
	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
					
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area

	gen crimes = 1
		
	* Drop long streets (fuzzy location type 1).
	keep if location_type!=3

	* Collapse.
	collapse (sum) crimes, by(year month area treat uncertain offsubcat_comb)
		
	* Fill in missing values with zeros to construct panel.
	fillin year month area offsubcat_comb
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
			
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
			
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.
	
	* Reshape wide.
	reshape wide crimes, i(year month area treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
			
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
			
	* Recode post variable (after aggregation to months).
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & month>=9

	* Loop over outcomes for Panel A to C:
	foreach y in burglary robbery homicide{

		* Column (3).
		reg `y' 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area, r	

		* Column (4).			
		reg `y' 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area if year>=1828 & year<=1832, r	
	
	}
	
		
	* Include only "no issue" locations.
	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
		
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area

	gen crimes = 1
	
	* Keep "no issue locations" only (fuzzy location type 2).
	keep if location_info==0

	* Collapse.
	collapse (sum) crimes, by(year month area treat uncertain offsubcat_comb)
		
	* Fill in missing values with zeros to construct panel.
	fillin year month area offsubcat_comb
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
			
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
			
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.
	
	* Reshape wide.
	reshape wide crimes, i(year month area treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
			
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
			
	* Recode post variable (after aggregation to months).
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & month>=9

	* Loop over outcomes for Panel A to C:
	foreach y in burglary robbery homicide{

		* Column (5).
		reg `y' 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area, r	

		* Column (6).			
		reg `y' 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area if year>=1828 & year<=1832, r	
	
	}
	
	* Exclude missing crime dates.		
	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
		
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area

	gen crimes = 1
		
	* Drop if crime date is missing (proxied by trial date in baseline).
	keep if date_crime!=.

	* Collapse.
	collapse (sum) crimes, by(year month area treat uncertain offsubcat_comb)
		
	* Fill in missing values with zeros to construct panel.
	fillin year month area offsubcat_comb
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
			
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
			
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.

	*** Reshape wide.
	reshape wide crimes, i(year month area treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
			
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
			
	* Recode post variable (after aggregation to months).
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & month>=9

	* Loop over outcomes for Panel A to C:
	foreach y in burglary robbery homicide{

		* Column (7).
		reg `y' 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area, r	

		* Column (8).			
		reg `y' 1.treat#1.post1829 1.uncertain#1.post1829 ///
			i.year i.month i.area if year>=1828 & year<=1832, r	
	
	}	

}

// Appendix Table A5.

if `tableA5'==1{

	use ab_rh_police_and_crime_jeea_london_main1.dta, clear
	
	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area

	gen crimes = 1

	* Collapse the data.
	collapse (sum) crimes, by(year month area treat uncertain offsubcat_comb)
	
	* Fill in missing values with zeros to construct panel.
	fillin year month area offsubcat_comb
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
		
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
		
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.
		
	* Reshape wide.
	reshape wide crimes, i(year month area treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
		
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
		
	* Recode post variable (after aggregation to months).
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & month>=9
	
	* Create dummy variables as factor variables not allowed in cgmwildboot command.
	qui tab year, gen(yeardummy)
	qui tab month, gen(monthdummy)
	qui tab area, gen(areadummy)
	gen treat_post 		= (treat==1 & post1829==1)
	gen uncertain_post 	= (uncertain==1 & post1829==1)
	
	local fe_year 	yeardummy2-yeardummy17
	local fe_month	monthdummy2-monthdummy12
	
	* Loop over outcomes for Panel A to C:
	foreach y in burglary robbery homicide{
	
		* Column (1).
		cgmwildboot `y' treat_post uncertain_post ///
					`fe_year' `fe_month' areadummy2 areadummy3 areadummy4, /// 
					cluster(area) bootcluster(area) reps(1000) seed(1234)
					
		* Column (2).			
		cgmwildboot `y' treat_post uncertain_post ///
					`fe_year' `fe_month' areadummy2 areadummy3 areadummy4 ///  
					if year>=1828 & year<=1832, /// 
					cluster(area) bootcluster(area) reps(1000) seed(1234)		
	
		* Column (3).
		preserve
			replace treat = 1 if area==1 & year>1832
			replace treat = 1 if area==1 & year==1832 & month>=4
			gen treat_x_post1829 = treat*post1829
			gen uncertain_x_post1829 = uncertain*post1829
			cgmwildboot `y' treat_x_post1829 uncertain_x_post1829 ///
					`fe_year' `fe_month' areadummy2 areadummy3 areadummy4 ///
					if year>=1828 & year<=1832, /// 
					cluster(area) bootcluster(area) reps(1000) seed(1234)
		restore
		
		* Column (4).
		preserve
			replace treat = 0 if area==1
			replace uncertain = 1 if area==1		
			gen treat_x_post1829 = treat*post1829
			gen uncertain_x_post1829 = uncertain*post1829
			cgmwildboot `y' treat_x_post1829 uncertain_x_post1829 ///
					`fe_year' `fe_month' areadummy2 areadummy3 areadummy4 ///
					if year>=1828 & year<=1832, /// 
					cluster(area) bootcluster(area) reps(1000) seed(1234)
		restore			
	
		* Column (5).
		cgmwildboot `y' treat_post uncertain_post ///
					`fe_year' `fe_month' areadummy3 areadummy4 ///
					if area!=1 & year>=1828 & year<=1832, /// 
					cluster(area) bootcluster(area) reps(1000) seed(1234)

	}
}	

// Appendix Table A6.

if `tableA6'==1{

	use ab_rh_police_and_crime_jeea_london_main2.dta, clear
	drop if office=="mp"|office=="t"
				
	encode office, gen(office_fe)
	gen dow = dow(date)
	
	rename any_propstolen any_propstolen_total
	rename num_propstolen num_propstolen_total
	
	* Columns (1)-(8).

		* Panel A.
		foreach o in b h l m ms q u w{ 
		reg num_agg_total postmet i.office_fe i.calweek i.dow if office!="`o'" & year<1831, r	
		}
		
		* Panel B.
		foreach o in b h l m ms q u w{ 
		reg anyinfo_total postmet i.office_fe i.calweek i.dow if office!="`o'" & year<1831, r	
		}
	
		* Panel C.
		foreach o in b h l m ms q u w{ 
		reg any_propstolen postmet i.office_fe i.calweek i.dow if office!="`o'" & year<1831, r	
		}

		* Panel D.
		foreach o in b h l m ms q u w{ 
		reg numcharge_total postmet i.office_fe i.calweek i.dow if office!="`o'" & year<1831, r	
		}
	
	
	* Columns (9)-(12).	

	use ab_rh_police_and_crime_jeea_london_main2.dta, clear
	drop if office=="mp"|office=="t"
	
	* Collapse to the weekly level. 
	
	collapse (sum) num_agg_total anyinfo_total any_propstolen numcharge_total, ///
			by(year week calweek incomplete_week office officename 			   ///
			postmet postmet1830)
	
	foreach var in num_agg_total numcharge_total  {
		count if `var'==0
		gen ln_`var' = ln(`var')
		replace ln_`var' = ln(`var' + 0.0001) if `var'==0 & ln_`var'==.
	}
	
	* Recode extensive margin measure.
	replace anyinfo_total = (anyinfo_total>0)
				
	* Generate variables for fixed effects.
	encode office, gen(office_fe)

		* Panel A.
		reg num_agg_total postmet i.office_fe i.calweek if year<1831, r	
		reg num_agg_total postmet i.office_fe i.calweek, r	
		reg num_agg_total postmet i.office_fe i.calweek if year<1831 & incomplete_week==0, r	
		reg ln_num_agg_total postmet i.office_fe i.calweek , r	
	
		* Panel B.
		reg anyinfo_total postmet i.office_fe i.calweek if year<1831, r	
		reg anyinfo_total postmet i.office_fe i.calweek, r	
		reg anyinfo_total postmet i.office_fe i.calweek if year<1831 & incomplete_week==0, r	
	
		* Panel C.
		reg any_propstolen postmet i.office_fe i.calweek if year<1831, r	
		reg any_propstolen postmet i.office_fe i.calweek, r	
		reg any_propstolen postmet i.office_fe i.calweek if year<1831 & incomplete_week==0, r	
	
		* Panel D.
		reg numcharge_total postmet i.office_fe i.calweek if year<1831, r	
		reg numcharge_total postmet i.office_fe i.calweek, r	
		reg numcharge_total postmet i.office_fe i.calweek if year<1831 & incomplete_week==0, r	
		reg ln_numcharge_total postmet i.office_fe i.calweek , r	
	
}

// Appendix Table A7.

if `tableA7'==1{

	use ab_rh_police_and_crime_jeea_london_main2.dta, clear
	drop if office=="mp"|office=="t"
				
	encode office, gen(office_fe)
	gen dow = dow(date)
	
	rename any_propstolen any_propstolen_total
	rename num_propstolen num_propstolen_total
	
	* Create dummy variables as factor variables not allowed in cgmwildboot.
	qui tab office_fe, gen(office_fe_d)
	qui tab calweek, gen(calweek_d)
	qui tab dow, gen(dow_d)
	
	local fe_office 	office_fe_d2-office_fe_d8
	local fe_calweek	calweek_d2-calweek_d18
	local fe_dow		dow_d2-dow_d6
	
	* Panel A, SE1.
	reg num_agg_total postmet if year<1831, cluster(office_fe)	
	reg num_agg_total postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)	
	reg num_agg_total postmet i.office_fe i.calweek i.dow, cluster(office_fe)	
	reg num_agg_prop postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)
	reg num_agg_viol postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)
	reg num_agg_other postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)
	
	* Panel A, SE2.
	cgmwildboot num_agg_total postmet if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)	
	cgmwildboot num_agg_total postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot num_agg_total postmet `fe_office' `fe_calweek' `fe_dow', 				///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)	
	cgmwildboot num_agg_prop postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, 	///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot num_agg_viol postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, 	///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot num_agg_other postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	
	* Panel B, SE1.
	reg anyinfo_total postmet if year<1831, cluster(office_fe)	
	reg anyinfo_total postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)	
	reg anyinfo_total postmet i.office_fe i.calweek i.dow, cluster(office_fe)	
	reg anyinfo_prop postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)
	reg anyinfo_viol postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)
	reg anyinfo_other postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)	

	* Panel B, SE2.
	cgmwildboot anyinfo_total postmet if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)	
	cgmwildboot anyinfo_total postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot anyinfo_total postmet `fe_office' `fe_calweek' `fe_dow', 			  ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)	
	cgmwildboot anyinfo_prop postmet `fe_office' `fe_calweek' `fe_dow' if year<1831,  ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot anyinfo_viol postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, 	///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot anyinfo_other postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
				
	* Panel C, SE1.
	reg numinfo_total postmet if year<1831, cluster(office_fe)	
	reg numinfo_total postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)	
	reg numinfo_total postmet i.office_fe i.calweek i.dow, cluster(office_fe)	
	reg numinfo_prop postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)
	reg numinfo_viol postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)
	reg numinfo_other postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)		
	
	* Panel C, SE2.
	cgmwildboot numinfo_total postmet if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot numinfo_total postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot numinfo_total postmet `fe_office' `fe_calweek' `fe_dow', 				///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)	
	cgmwildboot numinfo_prop postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, 	///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot numinfo_viol postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, 	///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot numinfo_other postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)	
	
	* Panel D, SE1.
	reg any_propstolen postmet if year<1831, cluster(office_fe)	 
	reg any_propstolen postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)	
	reg any_propstolen postmet i.office_fe i.calweek i.dow, cluster(office_fe)	

	* Panel D, SE2.
	cgmwildboot any_propstolen postmet if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)	
	cgmwildboot any_propstolen postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot any_propstolen postmet `fe_office' `fe_calweek' `fe_dow', 				///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)	
				
	* Panel E, SE1.
	reg numcharge_total postmet if year<1831, cluster(office_fe)	
	reg numcharge_total postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)	
	reg numcharge_total postmet i.office_fe i.calweek i.dow, cluster(office_fe)	
	reg numcharge_prop postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)
	reg numcharge_viol postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)
	reg numcharge_other postmet i.office_fe i.calweek i.dow if year<1831, cluster(office_fe)	

	* Panel E, SE2.
	cgmwildboot numcharge_total postmet if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)	
	cgmwildboot numcharge_total postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot numcharge_total postmet `fe_office' `fe_calweek' `fe_dow', 				///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)	
	cgmwildboot numcharge_prop postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, 	///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot numcharge_viol postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, 	///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
	cgmwildboot numcharge_other postmet `fe_office' `fe_calweek' `fe_dow' if year<1831, ///
				cluster(office_fe) bootcluster(office_fe) reps(1000) seed(1234)
				
}


********************************************************************************
***************************** V. ONLINE APPENDIX FIGURES B *********************
********************************************************************************

// Appendix Figure B1.

if `figureB1'==1{
	
	use ab_rh_police_and_crime_jeea_counties_main.dta, clear

		drop if countyname == "Middlesex incl. London"
		drop if countyname == "York"
		drop if countyname == "Sussex"
		drop if countyname == "Suffolk"
		
		collapse (sum) charges crimes_committed persons_appr_total, by(year)
	
		* Keep years 1832-1892 for the graphs (60 years).
		drop if year<=1832
		drop if year>=1892

		* Replace zeros (from collapsing) with missing values.
		replace crimes_committed = . if year< 1857 | year == 1876
		replace persons_appr_total = . if year< 1857 | year == 1876
	
		twoway ///
		(connected crimes_committed year, sort msize(small) msymbol(circle) ///
										  mc(black) lc(black) lp(solid)) ///
		(connected persons_appr_total year, sort msize(small) msymbol(square) ///
											mc(black) lc(black) lp(solid)) ///
		(connected charges year, sort msize(small) msymbol(triangle) ///
								 mc(black) lc(black) lp(solid)) ///
		if year>=1857, ylabel(5000(5000)15000) ///
		ytitle("No. of incidents, apprehensions and charges to trial") ///
		xtitle("Year of observation") xlabel(1860(10)1890) ///
		graphregion(color(white)) bgcolor(white) ///
		legend(order(1 "crimes committed" 2 "individuals apprehended" 3 "charges to trial" ) ///
		col(3) size(small)) 
		graph export "figureB1.pdf", replace
	
}

// Appendix Figure B2.

if `figureB2'==1{

	use ab_rh_police_and_crime_jeea_counties_main.dta, clear
	keep if extmarg_sample_3265==1
	
	by countyname, sort: egen temp = min(year) if force_existence_all == 1
	by countyname, sort: egen first_full_year = max(temp)
	drop temp
	
	* Generate indicators if force is efficient or inefficient at creation, 
	* using different thresholds; generate interaction with force existence 
	* variable (measuring existence of an efficient or inefficient force).
	
	forvalues x=1500(250)2500{
		gen eff`x' = (people_per_police_initial<=`x' & people_per_police_initial!=.)
		gen force_eff`x' = force_existence_all * eff`x'
		gen ineff`x' = (people_per_police_initial>`x' & people_per_police_initial!=.)
		gen force_ineff`x' = force_existence_all * ineff`x'
	}

	* Generate indicators for leads and lags for both efficient/inefficient forces.

	gen eff1500_0 = year-first_full_year == 0 & eff1500 == 1
	gen eff1500_1 = year-first_full_year == 1 & eff1500 == 1
	gen eff1500_2 = year-first_full_year == 2 & eff1500 == 1
	gen eff1500_3 = year-first_full_year == 3 & eff1500 == 1
	gen eff1500_4 = year-first_full_year == 4 & eff1500 == 1
	gen eff1500_5 = year-first_full_year == 5 & eff1500 == 1
	gen eff1500_6 = year-first_full_year == 6 & eff1500 == 1
	gen eff1500_7 = year-first_full_year == 7 & eff1500 == 1
	gen eff1500_8plus = year-first_full_year >= 8 & eff1500 == 1
	gen eff1500_pre_1 = year-first_full_year == -1 & eff1500 == 1
	gen eff1500_pre_2 = year-first_full_year == -2 & eff1500 == 1
	gen eff1500_pre_3 = year-first_full_year == -3 & eff1500 == 1
	gen eff1500_pre_4 = year-first_full_year == -4 & eff1500 == 1
	gen eff1500_pre_5 = year-first_full_year == -5 & eff1500 == 1
	gen eff1500_pre_6 = year-first_full_year == -6 & eff1500 == 1
	gen eff1500_pre_7 = year-first_full_year == -7 & eff1500 == 1
	gen eff1500_pre_8 = year-first_full_year == -8 & eff1500 == 1
	gen eff1500_pre_9plus = year-first_full_year <= -9 & eff1500 == 1

	gen ineff1500_0 = year-first_full_year == 0 & ineff1500 == 1
	gen ineff1500_1 = year-first_full_year == 1 & ineff1500 == 1
	gen ineff1500_2 = year-first_full_year == 2 & ineff1500 == 1
	gen ineff1500_3 = year-first_full_year == 3 & ineff1500 == 1
	gen ineff1500_4 = year-first_full_year == 4 & ineff1500 == 1
	gen ineff1500_5 = year-first_full_year == 5 & ineff1500 == 1
	gen ineff1500_6 = year-first_full_year == 6 & ineff1500 == 1
	gen ineff1500_7 = year-first_full_year == 7 & ineff1500 == 1
	gen ineff1500_8plus = year-first_full_year >= 8 & ineff1500 == 1
	gen ineff1500_pre_1 = year-first_full_year == -1 & ineff1500 == 1
	gen ineff1500_pre_2 = year-first_full_year == -2 & ineff1500 == 1
	gen ineff1500_pre_3 = year-first_full_year == -3 & ineff1500 == 1
	gen ineff1500_pre_4 = year-first_full_year == -4 & ineff1500 == 1
	gen ineff1500_pre_5 = year-first_full_year == -5 & ineff1500 == 1
	gen ineff1500_pre_6 = year-first_full_year == -6 & ineff1500 == 1
	gen ineff1500_pre_7 = year-first_full_year == -7 & ineff1500 == 1
	gen ineff1500_pre_8 = year-first_full_year == -8 & ineff1500 == 1
	gen ineff1500_pre_9plus = year-first_full_year <= -9 & ineff1500 == 1

	foreach y in log_charges log_violcharges log_propcharges log_othercharges{
	
		* i) Run regressions and export regression results.
		xi: qui regress `y' eff1500_pre_9plus eff1500_pre_8 eff1500_pre_7 ///
			eff1500_pre_6 eff1500_pre_5 eff1500_pre_4 eff1500_pre_3 eff1500_pre_2 ///
			eff1500_0 eff1500_1 eff1500_2 eff1500_3 ///
			eff1500_4 eff1500_5 eff1500_6 eff1500_7 eff1500_8plus ineff1500_pre_9plus ///
			ineff1500_pre_8 ineff1500_pre_7 ineff1500_pre_6 ineff1500_pre_5 ///
			ineff1500_pre_4  ineff1500_pre_3 ineff1500_pre_2 ///  
			ineff1500_0 ineff1500_1 ineff1500_2 ineff1500_3 ineff1500_4 ineff1500_5 /// 
			ineff1500_6 ineff1500_7 ineff1500_8plus i.countyname i.year, cluster(countyname)
			parmest, saving(esd_`y', replace)
		
		* ii) Create graphs.
		preserve
		
			use esd_`y', clear
				
				keep parm estimate min95 max95
				keep if min95!=0 & max95!=0
				rename estimate coef
				
				gen id = "."
				replace id = "efficient" 	if _n>=1 & _n<=17
				replace id = "inefficient" 	if _n>=18 & _n<=34
				drop if id=="."
				
				bys id: gen t = _n
				replace t = t-9
				replace t = t-1 if t<0
				
				expand 2 if t==0, gen(flag)
				replace t = -1 if flag==1
				replace coef = 0 if flag==1
				replace min95 = 0 if flag==1
				replace max95 = 0 if flag==1
				drop flag
				sort id t
			
				label define t  -9 "-<9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" ///
								-3 "-3" -2 "-2" -1 "-1" 0 "0" 1 "+1" 2 "+2" ///
								3 "+3" 4 "+4" 5 "+5" 6 "+6" 7 "+7" 8 ">+8"
				label values t t
				
				gen temp = "`y'"
				if temp == "log_charges"{
					local ddc_eff = -0.190
					local dds_eff = 0.062
					local ddc_ineff = 0.022
					local dds_ineff = 0.043		
					local panel = "A"
				}
				if temp == "log_violcharges"{
					local ddc_eff = -0.183
					local dds_eff = 0.104
					local ddc_ineff = 0.002 
					local dds_ineff = 0.058		
					local panel = "B"
				}
				if temp == "log_propcharges"{
					local ddc_eff = -0.143
					local dds_eff = 0.065
					local ddc_ineff = 0.064
					local dds_ineff = 0.050	
					local panel = "C"
				}
				if temp == "log_othercharges"{
					local ddc_eff = -0.181
					local dds_eff = 0.120
					local ddc_ineff = -0.027
					local dds_ineff = 0.077
					local panel = "D"
				}
				
				gen ddc_eff = `ddc_eff'
				gen ddc_ineff = `ddc_ineff' 
				
				twoway ///
				(connected coef t if t<-1 & id=="efficient", msymbol(Oh) mcolor(gs0) msize(large) lw(medthick) lc(gs0)) ///
				(connected coef t if t>-1 & id=="efficient", msymbol(O) mcolor(gs0)  msize(large) lw(medthick) lc(gs0)) ///
				(line min95 t if t<-1 & id=="efficient", lcolor(gs0) lw(med) lp(solid)) ///
				(line min95 t if t>-1 & id=="efficient", lcolor(gs0) lw(med) lp(solid)) ///
				(line max95 t if t<-1 & id=="efficient", lcolor(gs0) lw(med) lp(solid)) ///
				(line max95 t if t>-1 & id=="efficient", lcolor(gs0) lw(med) lp(solid)) ///
				(line ddc_eff t if t>=-1 & id=="efficient", lc(gs10) lp(dash) lw(medthick)), /// 
				xline(-1, lc(gs5) lw(medthick)) /// 
				yline(0, lc(gs5) lw(medthick)) ///
				xlabel(-9(1)8, val) ///
				ylabel(-0.6(0.2)0.6) ///
				text(0.55 -1 "DD estimate: `ddc_eff'" "(s.e. = `dds_eff')", ///
				size(medium) placement(w) box fc(white)) /// 
				ytitle("Coefficient and 95% C.I.") xtitle("Years before/after reform") ///
				graphregion(color(white)) bgcolor(white) legend(off) 
				graph export "figureB2`panel'1.pdf", replace

				twoway ///
				(connected coef t if t<-1 & id=="inefficient", msymbol(Oh) mcolor(gs0) msize(large) lw(medthick) lc(gs0)) ///
				(connected coef t if t>-1 & id=="inefficient", msymbol(O) mcolor(gs0)  msize(large) lw(medthick) lc(gs0)) ///
				(line min95 t if t<-1 & id=="inefficient", lcolor(gs0) lw(med) lp(solid)) ///
				(line min95 t if t>-1 & id=="inefficient", lcolor(gs0) lw(med) lp(solid)) ///
				(line max95 t if t<-1 & id=="inefficient", lcolor(gs0) lw(med) lp(solid)) ///
				(line max95 t if t>-1 & id=="inefficient", lcolor(gs0) lw(med) lp(solid)) ///
				(line ddc_ineff t if t>=-1 & id=="inefficient", lc(gs10) lp(dash) lw(medthick)), /// 
				xline(-1, lc(gs5) lw(medthick)) /// 
				yline(0, lc(gs5) lw(medthick)) ///
				xlabel(-9(1)8, val) ///
				ylabel(-0.6(0.2)0.6) ///
				text(0.55 -1 "DD estimate: `ddc_ineff'" "(s.e. = `dds_ineff')", ///
				size(medium) placement(w) box fc(white)) /// 
				ytitle("Coefficient and 95% C.I.") xtitle("Years before/after reform") ///
				graphregion(color(white)) bgcolor(white) legend(off) 
				graph export "figureB2`panel'2.pdf", replace
				
			restore
			
		erase esd_`y'.dta
	 
	}	

}

********************************************************************************
***************************** VI. ONLINE APPENDIX TABLES B *********************
********************************************************************************

// Appendix Table B1.

if `tableB1'==1{

	use ab_rh_police_and_crime_jeea_counties_main.dta, clear

	by countyname, sort: egen temp = min(year) if force_existence_all == 1
	by countyname, sort: egen first_whole_year = max(temp)
	drop temp
	
	* Keep 1858 only (no panel needed; time-invariant information).
	keep if year==1858
	
	* Keep relevant variables.
	keep countyname start_month start_year fiscal_start_year first_whole_year ///
		 police_initial people_per_police_initial 
		
	* Format: Order variables.
	order countyname start_month start_year fiscal_start_year first_whole_year ///
		police_initial people_per_police_initial  
	
	* Format: Label variables.	 
	label var countyname 		"County Name"
	label var start_month 		"Start Month"
	label var start_year		"Start Year"
	label var fiscal_start_year	"Fiscal Start Year"
	label var first_whole_year	"First Whole (Fiscal) Year"
	label var police_initial	"Initial Force Size"
	label var people_per_police_initial "Initial People per Police"
	
	* Generate flag for excluded counties.
	gen excluded = (countyname=="Middlesex incl. London" | ///
					countyname=="York" | countyname=="Sussex" | countyname=="Suffolk")
	
	* Format: Sort.
	sort excluded start_year start_month countyname
	drop if excluded==1
	drop excluded
	
	describe
	list, table

}

// Appendix Table B3.

if `tableB3'==1{

	use ab_rh_police_and_crime_jeea_counties_main.dta, clear
	keep if extmarg_sample_3265==1

	* Generate indicators for the first full year of treatment.
	by countyname, sort: egen temp = min(year) if force_existence_all == 1
	by countyname, sort: egen first_whole_year = max(temp)
	drop temp
	
	* Generate indicators for early, mid and late reformers.		  
	gen reformtiming = "early" if first_whole_year == 1841
	replace reformtiming = "mid" if first_whole_year > 1841 & first_whole_year < 1858
	replace reformtiming = "late" if first_whole_year == 1858

	* Summary statistics for the whole sample: Time-variant variables.
	preserve 
		collapse (count) fiscal_start_year force_existence_all ///
						 charges violent_charges property_charges other_charges ///
						 charges_rate viol_rate prop_rate other_rate
		xpose, clear varname
		rename v1 N
		save "temp1.dta", replace
	restore					 
	preserve 
		collapse (mean) fiscal_start_year force_existence_all ///
						 charges violent_charges property_charges other_charges ///
						 charges_rate viol_rate prop_rate other_rate
		xpose, clear varname
		rename v1 mean
		merge 1:1 _varname using "temp1.dta"
		drop _m
		save "temp1.dta", replace
	restore
	preserve 
		collapse (sd) fiscal_start_year force_existence_all ///
						 charges violent_charges property_charges other_charges ///
						 charges_rate viol_rate prop_rate other_rate
		xpose, clear varname
		rename v1 SD
		merge 1:1 _varname using "temp1.dta"
		drop _m
		save "temp1.dta", replace
	restore
	
	* Summary statistics for the whole sample: Time-invariant variables.
	preserve
		keep if year == 1851
		collapse (count) england wales num_parishes acres pop_combined ///
						 people_per_police_initial eff1500_creation people_per_police_1858 ///
						 farmer male married native employed out_of_lf ///
						 age_0_15 age_16_25 age_26_35 age_36_45 age_46_55 age_56_65 age_66_plus
		xpose, clear varname
		rename v1 N
		save "temp2.dta", replace
	restore	
	preserve 
		keep if year == 1851
		collapse (mean) england wales num_parishes acres pop_combined ///
						people_per_police_initial eff1500_creation people_per_police_1858 ///
						farmer male married native employed out_of_lf ///
						age_0_15 age_16_25 age_26_35 age_36_45 age_46_55 age_56_65 age_66_plus
		xpose, clear varname
		rename v1 mean
		merge 1:1 _varname using "temp2.dta"
		drop _m
		save "temp2.dta", replace
	restore
	preserve 
		keep if year == 1851
		collapse (sd) england wales num_parishes acres pop_combined ///
						people_per_police_initial eff1500_creation people_per_police_1858 ///
						farmer male married native employed out_of_lf ///
						age_0_15 age_16_25 age_26_35 age_36_45 age_46_55 age_56_65 age_66_plus
		xpose, clear varname
		rename v1 SD
		merge 1:1 _varname using "temp2.dta"
		drop _m
		save "temp2.dta", replace
	restore
	preserve
		use "temp1.dta", clear
		append using "temp2.dta"
		gen sample = "all counties"
		save "temp1.dta", replace
	restore	
	
	tab reformtiming, g(ref)
	
	* Summary statistics by reform time: 
	foreach var in ref1 ref2 ref3{
		
		* Time-variant variables
		preserve 
			keep if `var'==1
			collapse (count) fiscal_start_year force_existence_all ///
							 charges violent_charges property_charges other_charges ///
							 charges_rate viol_rate prop_rate other_rate
			xpose, clear varname
			rename v1 N
			save "temp1_`var'.dta", replace
		restore					 
		preserve 
			keep if `var'==1
			collapse (mean) fiscal_start_year force_existence_all ///
							 charges violent_charges property_charges other_charges ///
							 charges_rate viol_rate prop_rate other_rate
			xpose, clear varname
			rename v1 mean
			merge 1:1 _varname using "temp1_`var'.dta"
			drop _m
			save "temp1_`var'.dta", replace
		restore
		preserve 
			keep if `var'==1
			collapse (sd) fiscal_start_year force_existence_all ///
							 charges violent_charges property_charges other_charges ///
							 charges_rate viol_rate prop_rate other_rate
			xpose, clear varname
			rename v1 SD
			merge 1:1 _varname using "temp1_`var'.dta"
			drop _m
			save "temp1_`var'.dta", replace
		restore
	
		* Time-invariant variables.
		preserve
			keep if year == 1851 & `var'==1
			collapse (count) england wales num_parishes acres pop_combined ///
							 people_per_police_initial eff1500_creation people_per_police_1858 ///
							 farmer male married native employed out_of_lf ///
							 age_0_15 age_16_25 age_26_35 age_36_45 age_46_55 age_56_65 age_66_plus
			xpose, clear varname
			rename v1 N
			save "temp2_`var'.dta", replace
		restore	
		preserve 
			keep if year == 1851 & `var'==1
			collapse (mean) england wales num_parishes acres pop_combined ///
							people_per_police_initial eff1500_creation people_per_police_1858 ///
							farmer male married native employed out_of_lf ///
							age_0_15 age_16_25 age_26_35 age_36_45 age_46_55 age_56_65 age_66_plus
			xpose, clear varname
			rename v1 mean
			merge 1:1 _varname using "temp2_`var'.dta"
			drop _m
			save "temp2_`var'.dta", replace
		restore
		preserve 
			keep if year == 1851 & `var'==1
			collapse (sd) england wales num_parishes acres pop_combined ///
							people_per_police_initial eff1500_creation people_per_police_1858 ///
							farmer male married native employed out_of_lf ///
							age_0_15 age_16_25 age_26_35 age_36_45 age_46_55 age_56_65 age_66_plus
			xpose, clear varname
			rename v1 SD
			merge 1:1 _varname using "temp2_`var'.dta"
			drop _m
			save "temp2_`var'.dta", replace
		restore
		preserve
			use "temp1_`var'.dta", clear
			append using "temp2_`var'.dta"
			if("`var'"=="ref1"){
				gen sample = "early"
			}
			if("`var'"=="ref2"){
				gen sample = "late"
			}
			if("`var'"=="ref3"){
				gen sample = "mid"
			}
			save "temp1_`var'.dta", replace
		restore	
	}
	
	* Append all and format.
	use "temp1", clear
	append using "temp1_ref1"
	append using "temp1_ref2"
	append using "temp1_ref3"
	
	erase "temp1_ref1.dta"
	erase "temp1_ref2.dta"
	erase "temp1_ref3.dta"
	erase "temp2.dta"
	erase "temp2_ref1.dta"
	erase "temp2_ref2.dta"
	erase "temp2_ref3.dta"
	
	order sample _varname N mean SD
	
	gen order = .
		replace order = 1 if _varname=="fiscal_start_year"
		replace order = 2 if _varname=="force_existence_all"
		replace order = 3 if _varname=="charges" 
		replace order = 4 if _varname=="violent_charges" 
		replace order = 5 if _varname=="property_charges" 
		replace order = 6 if _varname=="other_charges" 
		replace order = 7 if _varname=="charges_rate" 
		replace order = 8 if _varname=="viol_rate"
		replace order = 9 if _varname=="prop_rate" 
		replace order = 10 if _varname=="other_rate"
		replace order = 11 if _varname=="england" 
		replace order = 12 if _varname=="wales" 
		replace order = 13 if _varname=="num_parishes" 
		replace order = 14 if _varname=="acres" 
		replace order = 15 if _varname=="pop_combined"
		replace order = 16 if _varname=="people_per_police_initial" 
		replace order = 17 if _varname=="eff1500_creation" 
		replace order = 18 if _varname=="people_per_police_1858" 
		replace order = 19 if _varname=="farmer" 
		replace order = 20 if _varname=="male" 
		replace order = 21 if _varname=="married" 
		replace order = 22 if _varname=="native" 
		replace order = 23 if _varname=="employed" 
		replace order = 24 if _varname=="out_of_lf" 
		replace order = 25 if _varname=="age_0_15" 
		replace order = 26 if _varname=="age_16_25" 
		replace order = 27 if _varname=="age_26_35"
		replace order = 28 if _varname=="age_36_45"
		replace order = 29 if _varname=="age_46_55"
		replace order = 30 if _varname=="age_56_65"
		replace order = 31 if _varname=="age_66_plus"
		
	sort sample order
	drop order
	
	format N %9.0f
	format mean %9.2f
	format SD %9.2f
	
	describe
	list, table
	
	erase "temp1.dta"

}

// Appendix Table B4.

if `tableB4'==1{

	use ab_rh_police_and_crime_jeea_counties_main.dta, clear
	keep if extmarg_sample_3265==1
  
	* Generate variable that turns equal one in fiscal year county adopts force.
	gen adoption = (year == fiscal_start_year)
	replace adoption = . if year>fiscal_start_year

	* Create lagged charges and charge rates (as potential predictors).
	* 1-year lag
	foreach var in charges_rate viol_rate prop_rate other_rate ///
				  any_neigh_force any_neigh_eff_force any_neigh_ineff_force{
				  bys countyname (year): gen lag1_`var' = `var'[_n-1]
	}	
	* 2-year lag
	foreach var in charges_rate viol_rate prop_rate other_rate ///
				  any_neigh_force any_neigh_eff_force any_neigh_ineff_force{
				  bys countyname (year): gen lag2_`var' = `var'[_n-2]
	}
	* 3-year lag
	foreach var in charges_rate viol_rate prop_rate other_rate ///
				  any_neigh_force any_neigh_eff_force any_neigh_ineff_force{
				  bys countyname (year): gen lag3_`var' = `var'[_n-3]
	}

	* Get lagged crime measures for neighbouring counties
	preserve
		keep countyname year lag1_charges_rate
		forvalues x=1(1)9{
			gen n`x'_id_name = countyname
			gen n`x'_lag1_charges_rate = lag1_charges_rate
		}
		drop countyname lag1_charges_rate
		save temp_crime_neighbors.dta, replace
	restore
	
	forvalues x=1(1)9{
		merge m:1 year n`x'_id_name using temp_crime_neighbors.dta, ///
			keepusing(n`x'_lag1_charges_rate)
		drop if _m==2
		drop _m
	}	
	
	erase temp_crime_neighbors.dta
	
	* Generate average crime rate of all neighbours
	egen all_neigh_lag1_charges_rate = rmean(n1_lag1_charges_rate-n9_lag1_charges_rate)
	
	* Scale population variable for ease of interpretation (in 1000 population)
	gen pop_combined_scaled = pop_combined/10000
	
	
	* 1840 cross-section: Predictors of early adoption.
			
		* Column (1).
		reg adoption lag1_charges_rate if year==1840, cluster(countyname)
		
		* Column (2).
		reg adoption lag1_charges_rate pop_combined_scaled if year==1840, cluster(countyname)
	
		* Column (3).
		reg adoption lag1_charges_rate lag1_any_neigh_force pop_combined_scaled ///
			if year==1840, cluster(countyname)

		* Column (4).
		reg adoption lag1_any_neigh_force lag1_viol_rate ///
			lag1_prop_rate lag1_other_rate pop_combined_scaled ///
			if year==1840, cluster(countyname)
		
		* Column (5).
		reg adoption lag1_any_neigh_force lag1_viol_rate ///
			lag1_prop_rate lag1_other_rate pop_combined_scaled ///
			all_neigh_lag1_charges_rate ///
			if year==1840, cluster(countyname)
		
		* Column (6).
		reg adoption lag1_any_neigh_force lag1_viol_rate ///
			lag1_prop_rate lag1_other_rate pop_combined_scaled ///
			all_neigh_lag1_charges_rate police_initial_noncounty ///
			if year==1840, cluster(countyname)
		
	* All counties 1840-1857: Predictors of adoption.
	
		* Column (7).
		reg adoption lag1_charges_rate if year>=1840 & year<=1857, cluster(countyname)
	
		* Column (8).
		reg adoption lag1_charges_rate pop_combined_scaled if year>=1840 & year<=1857, cluster(countyname)
	
		* Column (9).
		reg adoption lag1_charges_rate lag1_any_neigh_force pop_combined_scaled  ///
			if year>=1840 & year<=1857, cluster(countyname)
		
		* Column (10).
		reg adoption lag1_charges_rate lag1_any_neigh_eff_force ///
			lag1_any_neigh_ineff_force pop_combined_scaled ///
			if year>=1840 & year<=1857, cluster(countyname)

		* Column (11).
		reg adoption lag1_any_neigh_eff_force ///
			lag1_any_neigh_ineff_force lag1_viol_rate lag1_prop_rate ///
			lag1_other_rate pop_combined_scaled ///
			if year>=1840 & year<=1857, cluster(countyname)

		* Column (12).
		reg adoption lag1_any_neigh_eff_force ///
			lag1_any_neigh_ineff_force lag1_viol_rate lag1_prop_rate ///
			lag1_other_rate pop_combined_scaled ///
			all_neigh_lag1_charges_rate ///
			if year>=1840 & year<=1857, cluster(countyname)			

		* Column (13).
		reg adoption lag1_any_neigh_eff_force ///
			lag1_any_neigh_ineff_force lag1_viol_rate lag1_prop_rate ///
			lag1_other_rate pop_combined_scaled ///
			all_neigh_lag1_charges_rate police_initial_noncounty ///
			if year>=1840 & year<=1857, cluster(countyname)				
		
}

// Appendix Table B5.

if `tableB5'==1{

	* Use earlier sample (i.e. before 1832)
	use ab_rh_police_and_crime_jeea_counties_main.dta, clear
	
	drop if  countyname=="Middlesex incl. London" | ///
			 countyname=="Sussex" | ///
			 countyname=="York"  | ///
			 countyname=="Suffolk"
	bys countyname: egen temp = min(year) if force_existence_all==1
	bys countyname: egen first_full_year = max(temp)
	drop temp
	
	* Generate indicators if force is efficient or inefficient at creation, 
	* according to main (1500) threshold.
	gen eff1500 = (people_per_police_initial<=1500 & people_per_police_initial!=.)
	gen ineff1500 = (people_per_police_initial>1500 & people_per_police_initial!=.)
	
	* Interact indicators with force in existence variable to indicate existence
	* of efficient/inefficient force.
	gen force_eff1500 = force_existence_all * eff1500
	gen force_ineff1500  = force_existence_all * ineff1500
	
	* Generate dummy variable = 1 if London/Middlesex is neighboring county.
	* (= First ring around London.)
	gen midsex_neigh = (n1_id_name == "Middlesex incl. London" | ///
						n2_id_name == "Middlesex incl. London" | ///
						n3_id_name == "Middlesex incl. London" | /// 
						n4_id_name == "Middlesex incl. London" | ///
						n5_id_name == "Middlesex incl. London" | /// 
						n6_id_name == "Middlesex incl. London" | /// 
						n7_id_name == "Middlesex incl. London" | /// 
						n8_id_name == "Middlesex incl. London" | /// 
						n9_id_name == "Middlesex incl. London" )
	table countyname midsex_neigh

	* Generate interaction with post-1829 variable.
	gen midsex_neigh_post29 = (midsex_neigh==1 & year>=1830)
	gen post1829 = (year>=1830)
	
	* Generate dummy variable = 1 if neighbor of London/Middlesex neighbor.
	* (= Second ring around London.)
	gen midsex_neigh2 = 0
	forvalues x=1(1)9{
		replace midsex_neigh2 = 1 if (n`x'_id_name=="Berks"| ///
									  n`x'_id_name=="Bucks"| ///
									  n`x'_id_name=="Essex"| ///
									  n`x'_id_name=="Hertford"| ///
									  n`x'_id_name=="Surrey"| ///
									  n`x'_id_name=="Berks")
	}	
	replace midsex_neigh2 = 0 if midsex_neigh==1
	table countyname midsex_neigh2
	gen midsex_neigh2_post29 = (midsex_neigh2==1 & year>=1830)
	
	keep if year>=1828 & year<=1832
	
	* Panel A.
	
		* Direct neighbors.
		
		bys post1829: sum log_charges if midsex_neigh==1 & midsex_neigh2==0
		reg log_charges post1829 if midsex_neigh==1 & midsex_neigh2==0, r
	
		bys post1829: sum log_charges if countyname=="Berks"
		reg log_charges post1829 if countyname=="Berks", r
		
		bys post1829: sum log_charges if countyname=="Bucks"
		reg log_charges post1829 if countyname=="Bucks", r
		
		bys post1829: sum log_charges if countyname=="Essex"
		reg log_charges post1829 if countyname=="Essex", r
		
		bys post1829: sum log_charges if countyname=="Hertford"
		reg log_charges post1829 if countyname=="Hertford", r
		
		bys post1829: sum log_charges if countyname=="Surrey"
		reg log_charges post1829 if countyname=="Surrey", r		
	
		* Second neighbors.
		
		bys post1829: sum log_charges if midsex_neigh==0 & midsex_neigh2==1
		reg log_charges post1829 if midsex_neigh==0 & midsex_neigh2==1, r
	
		bys post1829: sum log_charges if countyname=="Bedford"
		reg log_charges post1829 if countyname=="Bedford", r
		
		bys post1829: sum log_charges if countyname=="Cambridge"
		reg log_charges post1829 if countyname=="Cambridge", r
		
		bys post1829: sum log_charges if countyname=="Gloucester"
		reg log_charges post1829 if countyname=="Gloucester", r
		
		bys post1829: sum log_charges if countyname=="Kent"
		reg log_charges post1829 if countyname=="Kent", r
		
		bys post1829: sum log_charges if countyname=="Northampton"
		reg log_charges post1829 if countyname=="Northampton", r	
		
		bys post1829: sum log_charges if countyname=="Oxford"
		reg log_charges post1829 if countyname=="Oxford", r	
		
		bys post1829: sum log_charges if countyname=="Southampton"
		reg log_charges post1829 if countyname=="Southampton", r	
				
		bys post1829: sum log_charges if countyname=="Wilts"
		reg log_charges post1829 if countyname=="Wilts", r			
	
		* Remaining counties.
		
		bys post1829: sum log_charges if midsex_neigh==0 & midsex_neigh2==0
		reg log_charges post1829 if midsex_neigh==0 & midsex_neigh2==0, r
	
	* Panel B. 
	
		xi: reg log_charges midsex_neigh_post29 midsex_neigh2_post29 i.year i.countyname ///
				if year>=1828 & year<=1832, r
		drop _I*
		
		xi: reg log_charges midsex_neigh_post29 midsex_neigh2_post29 i.year i.countyname ///
				if year>=1828 & year<=1832, cluster(countyname)
		drop _I*

}

// Appendix Table B6.

if `tableB6'==1{

	use ab_rh_police_and_crime_jeea_counties_main.dta, clear
	keep if extmarg_sample_3265==1
  
	* Generate variable that turns equal to one in fiscal year county adopts force.
	gen adoption = (year == fiscal_start_year)
	replace adoption = . if year>fiscal_start_year

	* Create lagged charges and charge rates (as potential predictors).
	* 1-year lag
	foreach var in charges_rate viol_rate prop_rate other_rate ///
				  any_neigh_force any_neigh_eff_force any_neigh_ineff_force{
				  bys countyname (year): gen lag1_`var' = `var'[_n-1]
	}	
	* 2-year lag
	foreach var in charges_rate viol_rate prop_rate other_rate ///
				  any_neigh_force any_neigh_eff_force any_neigh_ineff_force{
				  bys countyname (year): gen lag2_`var' = `var'[_n-2]
	}
	* 3-year lag
	foreach var in charges_rate viol_rate prop_rate other_rate ///
				  any_neigh_force any_neigh_eff_force any_neigh_ineff_force{
				  bys countyname (year): gen lag3_`var' = `var'[_n-3]
	}

	* Scale population variable for ease of interpretation (in 1000 population)
	gen pop_combined_scaled = pop_combined/10000
	
	* Scale acres and number of parishes for the same reason.
	gen acres_scaled = acres/10000
	gen num_parishes_scaled = num_parishes/100
	
	* Scale shares to get percentages.
	gen farmer2 = farmer*100
	gen male2 = male *100
	gen married2=married*100
	gen native2=native*100
	gen employed2=employed*100
	gen age_0_15_2=age_0_15*100
	gen age_16_25_2=age_16_25*100
	gen age_26_35_2=age_26_35*100
	gen age_36_45_2=age_36_45*100
	gen age_46_55_2=age_46_55*100
	
	* Regressions: Efficient/inefficient in year of adoption (at creation) and
	* possible predictors. Note: Use 1858 in the dataset as adoption completed 
	* at that point, but note that both efficiency at creation as well as 1851 
	* census data are fixed at that point.
	
	* Columns (1) and (2).
	foreach var in eff1500_creation people_per_police_initial{
		
		regress `var' acres_scaled num_parishes_scaled number_neighbors england ///
				farmer2 male2 married2 native2 employed2 ///
				age_0_15_2 age_16_25_2 age_26_35_2 age_36_45_2 age_46_55_2 ///
				if year==1858, robust
		sum `var' if e(sample)==1	
	
	}
	
	* Generate additional variables.
	foreach var in viol_rate prop_rate other_rate ///
					   any_neigh_eff_force any_neigh_ineff_force{
					   gen temp = lag1_`var' if adoption==1
					   bys countyname: egen preadopt_`var' = max(temp)
					   drop temp
	}			   
	
	* Columns (3) and (4).
	foreach var in eff1500_creation people_per_police_initial{
	
		regress `var' acres_scaled num_parishes_scaled number_neighbors england ///
				farmer2 male2 married2 native2 employed2 ///
				age_0_15_2 age_16_25_2 age_26_35_2 age_36_45_2 age_46_55_2 ///
				preadopt* ///
				if year==1858, robust
		sum `var' if e(sample)==1		
		
	}
	
	* Columns (5) and (6).
	foreach var in eff1500_creation people_per_police_initial{
	
		regress `var' acres_scaled num_parishes_scaled number_neighbors england ///
				farmer2 male2 married2 native2 employed2 ///
				age_0_15_2 age_16_25_2 age_26_35_2 age_36_45_2 age_46_55_2 ///
				preadopt* pop_combined_scaled ///
				if year==1858, robust
		sum `var' if e(sample)==1	
	
	}

}

// Appendix Table B7.

if `tableB7==1'{

	use ab_rh_police_and_crime_jeea_counties_main.dta, clear
	keep if extmarg_sample_3265==1
	
	by countyname, sort: egen temp = min(year) if force_existence_all == 1
	by countyname, sort: egen first_full_year = max(temp)
	drop temp
	
	* Generate indicators if force is efficient or inefficient at creation, 
	* using different thresholds; generate interaction with force existence 
	* variable (measuring existence of an efficient or inefficient force).
	forvalues x=1500(250)2500{
		gen eff`x' = (people_per_police_initial<=`x' & people_per_police_initial!=.)
		gen force_eff`x' = force_existence_all * eff`x'
		gen ineff`x' = (people_per_police_initial>`x' & people_per_police_initial!=.)
		gen force_ineff`x' = force_existence_all * ineff`x'
	}

	* Generate indicator for above-median size of county
	sum acres, d
	gen acres_above_median = (536636.5)

	* Loop over outcomes for Panels A-D:
	foreach var in log_charges log_violcharges log_propcharges log_othercharges {
	
		* Column (1).
		xi: reg `var' force_eff1500 force_ineff1500 i.countyname i.year, ///
			cluster(countyname)
		drop _I*
	
		* Column (2).
		xi: reg `var' force_eff1500 force_ineff1500 i.countyname i.year ///
			pop_combined, cluster(countyname)
		drop _I*
	
		* Column (3).
		xi: reg `var' force_eff1500 force_ineff1500 i.countyname i.year ///
			pop_combined england i.region, cluster(countyname)
		drop _I*
		
		* Column (4).
		xi: reg `var' force_eff1500 force_ineff1500 i.countyname i.year ///
			i.region*w, cluster(countyname)
		drop _I*

		* Column (5).
		xi: reg `var' force_eff1500 force_ineff1500 i.countyname i.year ///
			i.acres_above_median*w, cluster(countyname)
		drop _I*	
		
		* Column (6).
		xi: reg `var' force_eff1500 force_ineff1500 i.countyname i.year ///
			if year>=1835 & year<=1862, cluster(countyname)
		drop _I*
		
		* Column (7).
		xi: reg `var' force_eff1500 force_ineff1500 i.countyname i.year ///
			if year>=1832 & year<=1849, cluster(countyname)
		drop _I*

		* Column (8).
		xi: reg `var' force_eff1500 force_ineff1500 i.countyname i.year ///
			if year>=1850 & year<=1865, cluster(countyname)
		drop _I*	

		* Column (9).
		xi: reg `var' force_eff1500 force_ineff1500 i.countyname i.year ///
			if england==1, cluster(countyname)
		drop _I*
		
		* Column (10).
		xi: reg `var' force_eff1500 force_ineff1500 i.countyname i.year ///
			any_neigh_eff_force any_neigh_ineff_force, cluster(countyname)
		drop _I*		
				
	}

}

********************************************************************************
***************************** VII. FOOTNOTES AND REFERENCES MAIN TEXT **********
********************************************************************************

// Footnote 13.

if `fn13'==1{

	di as text "{hline 59}" _newline ///
		"To test the robustness of the results to an 8-mile instead" ///
		_newline ///
		"of a 7-mile radius, replace the condition dist_mls<=7 with" ///
		_newline ///
		"dist_mls<=8 when defining the uncertain group in the code" ///
		_newline ///
		"above (e.g., Table 1)." ///
		_newline "{hline 59}" 
		
}

// Footnote 22.

if `fn22'==1{

	use ab_rh_police_and_crime_jeea_london_main1.dta, clear

	gen treat = (dist_mls<=4 & city==0)
	gen uncertain = (dist_mls<=7 & city==0 & treat==0)
	gen area = .
		replace area = 1 if city==1
		replace area = 2 if treat==0 & city==0
		replace area = 3 if uncertain==1
		replace area = 4 if treat==1
		label define area 1 "city" 2 "control" 3 "uncertain" 4 "treatment" 5 "overall"
		label values area area

	gen crimes = 1

	* Collapse.
	collapse (sum) crimes, by(year month area treat uncertain offsubcat_comb)
	
	* Fill in missing values with zeros to construct panel.
	fillin year month area offsubcat_comb
	replace crimes=0 if _fillin==1 & crimes==.
	drop _fillin
		
	replace treat=1	if area==4 & treat==.
	replace treat=0	if area!=4 & treat==.
		
	replace uncertain=1	if area==3 & uncertain==.
	replace uncertain=0 if area!=3 & uncertain==.
		
	* Reshape wide.
	reshape wide crimes, i(year month area treat uncertain) j(offsubcat_comb) string
	rename crimesburglary_combined burglary
	rename crimesmanslaughter manslaughter
	rename crimesmurder murder
	rename crimesrobbery_combined robbery
		
	gen homicide = manslaughter + murder
	gen crime_total = burglary + homicide + robbery
		
	* Create extensive margin variables.
	foreach var in burglary robbery homicide{
		count if `var'==.
		gen `var'_any = (`var'>0)
	}
	
	* Recode post variable (after aggregation to months).
	gen post1829 = 0
	replace post1829 = 1 if year>=1830
	replace post1829 = 1 if year==1829 & month>=9
		 
	* Generate date variable (month x year)
	gen date = ym(year,month)
	format date %tm

	* Generate time to event variable, defined by "fiscal year".
	* That is year = September - August instead of January - December.
	* (Reform in September 1829.)
	gen event = .
		replace event = 1 if date<=tm(1823m8)
		replace event = 2 if date>=tm(1823m9) & date<=tm(1825m8)
		replace event = 3 if date>=tm(1825m9) & date<=tm(1827m8)
		replace event = 4 if date>=tm(1827m9) & date<=tm(1829m8)
		replace event = 5 if date>=tm(1829m9) & date<=tm(1831m8)
		replace event = 6 if date>=tm(1831m9) & date<=tm(1833m8)
		replace event = 7 if date>=tm(1833m9) & date<=tm(1835m8)
		replace event = 8 if date>=tm(1835m9)
	
	* Loop over outcomes.
	foreach y in burglary robbery homicide{
	
	preserve
	
		* Run regressions and export results.
		qui reg `y' 1.event#1.treat 2.event#1.treat 3.event#1.treat 5.event#1.treat ///
				6.event#1.treat 7.event#1.treat 8.event#1.treat ///
				1.event#1.uncertain 2.event#1.uncertain 3.event#1.uncertain ///
				5.event#1.uncertain 6.event#1.uncertain 7.event#1.uncertain ///
				8.event#1.uncertain i.year i.month i.area, r
			parmest, level(90 95) saving(esd_`y', replace)
		
		* Create graphs.

		use esd_`y', clear
			keep parm estimate min95 max95
			keep if min95!=0 & max95!=0
			rename estimate coef
			
			gen id = "."
			replace id = "treatment" if _n>=1 & _n<=7
			replace id = "uncertain" if _n>=8 & _n<=14
			drop if id=="."
			
			bys id: gen t = _n
			replace t = t-3
			replace t = t-1 if t<=0
			
			expand 2 if t==-1, gen(flag)
			replace t = 0 if flag==1
			replace coef = 0 if flag==1
			replace min95 = 0 if flag==1
			replace max95 = 0 if flag==1
			drop flag
			sort id t
			
			label define t -3 "<-7" -2 "-6/-5" -1 "-4/-3" 0 "-2/-1" 1 "0/+1" 2 "+2/+3" 3 "+4/+5" 4 ">+7" 
			label values t t
		
			gen temp = "`y'"
			if temp == "burglary"{
				local ddc_t = -0.106
				local dds_t = 0.370
				local ddc_u = 0.016
				local dds_u = 0.149
			}
			if temp == "robbery"{
				local ddc_t = -1.032
				local dds_t = 0.129
				local ddc_u = 0.129
				local dds_u = 0.088
			}
			if temp == "homicide"{
				local ddc_t = -0.008
				local dds_t = 0.139
				local ddc_u = -0.049
				local dds_u = 0.057
			}

			gen ddc = `ddc_t' if id=="treatment"
			replace ddc = `ddc_u' if id=="uncertain"
			
			twoway ///
			(connected coef t if t<0 & id=="treatment", msymbol(Oh) mcolor(gs0) msize(large) lw(medthick) lc(gs0)) ///
			(connected coef t if t>0 & id=="treatment", msymbol(O) mcolor(gs0)  msize(large) lw(medthick) lc(gs0)) ///
			(line min95 t if t<0 & id=="treatment", lcolor(gs0) lw(med) lp(solid)) ///
			(line min95 t if t>0 & id=="treatment", lcolor(gs0) lw(med) lp(solid)) ///
			(line max95 t if t<0 & id=="treatment", lcolor(gs0) lw(med) lp(solid)) ///
			(line max95 t if t>0 & id=="treatment", lcolor(gs0) lw(med) lp(solid)) ///
			(line ddc t if t>=0 & id=="treatment", lc(gs10) lp(dash) lw(medthick)), /// 
			xline(0, lc(gs5) lw(medthick)) /// 
			yline(0, lc(gs5) lw(medthick)) ///
			xlabel(-3(1)4, val) ///
			ylabel(-6(2)6) ///
			text(5.5 -1 "DD estimate: `ddc_t'" "(s.e. = `dds_t')", ///
			size(medium) placement(w) box fc(white)) /// 
			ytitle("Coefficient and 95% C.I.") xtitle("Year after reform") ///
			graphregion(color(white)) bgcolor(white) legend(off) 
			
			twoway ///
			(connected coef t if t<0 & id=="uncertain", msymbol(Oh) mcolor(gs0) msize(large) lw(medthick) lc(gs0)) ///
			(connected coef t if t>0 & id=="uncertain", msymbol(O) mcolor(gs0)  msize(large) lw(medthick) lc(gs0)) ///
			(line min95 t if t<0 & id=="uncertain", lcolor(gs0) lw(med) lp(solid)) ///
			(line min95 t if t>0 & id=="uncertain", lcolor(gs0) lw(med) lp(solid)) ///
			(line max95 t if t<0 & id=="uncertain", lcolor(gs0) lw(med) lp(solid)) ///
			(line max95 t if t>0 & id=="uncertain", lcolor(gs0) lw(med) lp(solid)) ///
			(line ddc t if t>=0 & id=="uncertain", lc(gs10) lp(dash) lw(medthick)), /// 
			xline(0, lc(gs5) lw(medthick)) /// 
			yline(0, lc(gs5) lw(medthick)) ///
			xlabel(-3(1)4, val) ///
			ylabel(-6(2)6) ///
			text(5.5 -1 "DD estimate: `ddc_u'" "(s.e. = `dds_u')", ///
			size(medium) placement(w) box fc(white)) /// 
			ytitle("Coefficient and 95% C.I.") xtitle("Year after reform") ///
			graphregion(color(white)) bgcolor(white) legend(off) 			
		
		restore
	
	erase esd_`y'.dta
	
	}

}

// Footnote 28.

if `fn28'==1{

	di as text "{hline 59}" _newline ///
		"To test the robustness of the results to including the Thames" /// 
		_newline ///
		"office, simply adjust the code (e.g., Table 4) and replace" /// 
		_newline ///
		"the line  -drop if (office==`mp'|office==`t')- with" ///
		_newline ///
		"-drop if (office==`mp')- to keep the Thames office." ///
		_newline "{hline 59}" 

}

// Foonote 33.

if `fn33'==1{
	
	di as text "{hline 59}" _newline ///
		"To test the robustness of the results to using per capita," ///
		_newline ///
		"rates simply replace the outcome variables in the code above:" ///
		_newline ///
		"log_charges with log_chargerate; log_violcharges with" ///
		_newline ///
		"log_violrate; log_propcharges with log_proprate;" ///
		_newline ///
		"log_othercharges_alt with log_otherrate_alt" ///
		_newline "{hline 59}"
		
}

// Reference on page 18.

if `ref1'==1{

	di as text "{hline 59}" _newline ///
		"To test the robustness of the results to avoiding the" /// 
		_newline ///
		"Cholera epidemic years and months, simply restrict the" ///
		_newline ///
		"estimation window as follow:" ///
		_newline ///
		"keep if year>=1828 & year<=1832" ///
		_newline ///
		"drop if year==1832 & month>5" /// 
		_newline "{hline 59}"
		
}

********************************************************************************
********************************************************************************
********************************************************************************

log close



