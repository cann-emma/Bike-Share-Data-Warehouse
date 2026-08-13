# Cyclistic Rider Behavior Warehouse

An end-to-end data warehouse and behavioral analysis of Chicago's Divvy bike-share system, designed to identify how casual riders and annual members use the service differently and inform targeted membership conversion strategies.

This project reimagines the Google Data Analytics Capstone (Cyclistic case study) with a production-grade data warehouse architecture, dimensional modeling, and portfolio-quality visualizations, replacing the original flat-file analysis with a scalable, star-schema approach

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CYCLISTIC DATA WAREHOUSE                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌───────────┐       ┌───────────────┐       ┌──────────────────┐  │
│  │           │       │               │       │                  │  │
│  │    RAW    │──────▶│    STAGED     │──────▶│     MODELED      │  │
│  │           │       │               │       │                  │  │
│  └───────────┘       └───────────────┘       └──────────────────┘  │
│                                                                     │
│  • 12 monthly CSVs    • Deduplication       • fact_trips           │
│  • Ingested as-is     • Type casting        • dim_date             │
│  • No transformation  • Null handling       • dim_rider            │
│  • Source of truth    • Name cleaning       • dim_bike_type        │
│                       • Validation          • dim_station           │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                         ANALYSIS LAYER                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Star Schema (fact_trips + 4 dimensions)                           │
│        │                                                            │
│        ├──▶ Tableau Dashboards (behavioral analysis)               │
│        │      • Station ridership dominance                        │
│        │      • Weekly riding patterns                             │
│        │      • Ride type preferences                              │
│        │      • Trip duration distributions                        │
│        │                                                            │
│        └──▶ Report & Recommendations                               │
│               • Casual vs. member behavioral differences           │
│               • Targeted conversion strategies                     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Status

Complete: Data warehouse pipeline (Raw → Staged → Modeled)
In progress: Visualization outputs and documentation

Interactive dashboards available [here](https://public.tableau.com/app/profile/emma.cann3541/viz/CyclisticUserAnalysisVisualization/Dashboard1#1)
