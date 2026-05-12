# Smart Canada Tax — Technical Development Log

**Company:** [Your Company Name]
**Project:** Smart Canada Tax — Canadian Tax Calculation iOS Application & Web Platform
**Platform:** iOS (SwiftUI), Web (HTML/JS)
**Last Updated:** 2026-05-12

---

## Project Overview

Smart Canada Tax is an iOS application and companion website that provides accurate Canadian federal and provincial tax calculations, AI-powered tax Q&A, and educational resources. Technical work involves building a precise multi-jurisdiction tax calculation engine, an AI-assisted tax advisory system, and synchronized web calculators.

---

## Development Log

---

### March–April 2026
**Work:** Core tax calculation engine

**Technical Activity:**
- Built stateless `TaxCalculator` struct handling all 13 Canadian provinces and territories
- Federal bracket calculations with Basic Personal Amount (BPA) credit logic
- Quebec abatement (16.5% federal tax reduction for Quebec residents)
- Ontario surtax (additional 20%/36% on provincial tax above thresholds)
- Provincial bracket data architecture: `Province` enum carrying per-province bracket arrays, BPA values, HST/PST/GST rates
- Investigated accuracy against CRA's own tax tables — identified edge cases in BPA phase-out for high incomes (above $165,430) requiring graduated credit reduction logic
- Corporate tax engine: CCPC (Canadian Controlled Private Corporation) small business deduction (SBD) — 9% federal rate on first $500K active income, passive income grind calculation
- GST/HST calculator covering all provincial rate combinations (HST provinces vs GST+PST provinces vs Quebec QST)

---

### April 10, 2026
**Commits:** `d42099b`, `9f25b0e`, `e874898`, `c8efe68`, `f7f5bc8`
**Work:** Web calculator platform — 6 calculators matching app logic exactly

**Technical Activity:**
- Built personal income tax web calculator in vanilla JavaScript — required replicating Swift tax logic in JS without introducing rounding discrepancies
- Discovered floating-point precision differences between Swift `Double` and JavaScript `Number` for bracket boundary calculations — standardized to 2 decimal places at each bracket step to ensure consistency
- Built GST/HST, RRSP, corporate tax, self-employed, and rental income calculators
- All calculators use identical rate tables as the iOS app to ensure output consistency across platforms

---

### April 10–12, 2026
**Commits:** `5c83261`, `4d95fa7`, `c9faeb8`
**Work:** Blog platform, navigation, UI consistency

**Technical Activity:**
- Built blog section with SEO-optimized articles on Canadian tax topics
- Standardized navigation bar across all pages — identified inconsistency causing white-on-white text on some calculator pages; resolved with explicit color declarations per page

---

### April 22, 2026
**Commit:** `95387bd`
**Work:** Legal compliance — CPA references

**Technical Activity:**
- Removed "licensed" qualifier from all CPA/advisor references throughout app and website to ensure compliance with CPA Canada professional designation regulations

---

### April 24–26, 2026
**Commits:** `9cb8eb0`, `fcbcc6b`
**Work:** SEO content — capital gains, CRA My Account, RRSP/TFSA deadline

**Technical Activity:**
- Published capital gains tax guide with 2026 inclusion rate information
- Published RRSP vs TFSA deadline guide targeting search queries identified via Google Search Console

---

### May 11, 2026
**Commits:** `61ccbf8`, `b1beacc`
**Work:** Blog expansion, StoreKit removal

**Technical Activity:**
- Published Tax Brackets 2026 and T4 vs T4A guides targeting high-volume search queries
- Removed Apple In-App Purchase (StoreKit) integration — IAP products were not configured in App Store Connect causing "Product not available" errors for all users
- Replaced purchase flow with direct contact form (web3forms) — eliminates App Store payment processing dependency
- Updated Legal and Privacy Policy text to reflect removal of Apple payment processing

---

*This log is updated after each development session.*
