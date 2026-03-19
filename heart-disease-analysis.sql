-- ============================================
-- 5. DATA QUALITY ASSESSMENT
-- ============================================

-- Before performing any analysis, the dataset was examined to ensure 
-- data integrity. The assessment was performed in the following order:
-- (1) overall structure
-- (2) data types
-- (3) distinct values per column
-- (4) missing values by column and institution
-- (5) documentation of issues and decisions


-- --------------------------------------------
-- 5.1 Dataset Overview
-- --------------------------------------------

-- View all rows in the table
SELECT * 
FROM heart_disease_uci;

-- Count total records
SELECT COUNT(*) AS total_registos 
FROM heart_disease_uci;

-- Count records per institution
SELECT dataset, COUNT(*) AS total 
FROM heart_disease_uci 
GROUP BY dataset;

-- Result:
-- Cleveland Clinic Foundation:        304
-- Hungarian Institute of Cardiology:  293
-- University Hospital Zurich:         123
-- VA Long Beach:                      200

-- Important observation: the number of records differs considerably 
-- between institutions. This imbalance suggests that data collection 
-- was not uniform across hospitals. As will be confirmed in section 5.4, 
-- Cleveland has the most complete data across all variables, while 
-- Switzerland and VA Long Beach show significant missing data for 
-- several key clinical variables. Results should therefore be 
-- interpreted with caution, as findings may be more representative 
-- of the Cleveland population than the full multi-institutional dataset.


-- --------------------------------------------
-- 5.2 Data Types
-- --------------------------------------------

-- View all column names and their data types
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'heart_disease_uci';

-- Result:
-- id          nvarchar
-- age         int
-- sex         nvarchar
-- dataset     nvarchar
-- cp          nvarchar
-- trestbps    int
-- chol        int
-- fbs         bit
-- restecg     nvarchar
-- thalch      int
-- exang       bit
-- oldpeak     nvarchar  -- should be float, use CONVERT when needed
-- slope       nvarchar
-- ca          nvarchar  -- should be int, use CONVERT when needed
-- thal        nvarchar
-- num         nvarchar  -- should be int, use CONVERT when needed


-- --------------------------------------------
-- 5.3 Verifying Column Values
-- Objective: check for unexpected values,
-- text where numbers are expected, or values
-- outside the clinically expected range
-- --------------------------------------------

SELECT DISTINCT ca FROM heart_disease_uci;
SELECT DISTINCT oldpeak FROM heart_disease_uci;
SELECT DISTINCT num FROM heart_disease_uci;
SELECT DISTINCT slope FROM heart_disease_uci;
SELECT DISTINCT thal FROM heart_disease_uci;
SELECT DISTINCT sex FROM heart_disease_uci;
SELECT DISTINCT cp FROM heart_disease_uci;
SELECT DISTINCT restecg FROM heart_disease_uci;
SELECT DISTINCT fbs FROM heart_disease_uci;

-- --------------------------------------------
-- 5.4 Missing Values (NULLs) by Institution
-- Objective: understand the origin of missing
-- values before deciding how to treat them
-- --------------------------------------------

-- Cholesterol NULLs
-- Result: all missing values from Switzerland
-- Decision: keep as NULL, exclude from analysis
SELECT dataset, COUNT(*) AS chol_nulos 
FROM heart_disease_uci 
WHERE chol IS NULL 
GROUP BY dataset;

-- Major Vessels (ca) NULLs
-- Result: Cleveland 5 (1.6%) | Hungary 290 (99%) | Switzerland 118 (96%) | VA Long Beach 198 (99%)
-- Decision: use Cleveland data only - major limitation
SELECT dataset, COUNT(*) AS ca_nulos 
FROM heart_disease_uci 
WHERE ca IS NULL 
GROUP BY dataset;

-- ST Segment Depression (oldpeak) NULLs
-- Result: Cleveland 0 | Hungary 0 | Switzerland 6 (5%) | VA Long Beach 56 (28%)
-- Decision: well recorded, no action needed
SELECT dataset, COUNT(*) AS oldpeak_nulos 
FROM heart_disease_uci 
WHERE oldpeak IS NULL 
GROUP BY dataset;

-- ST Segment Slope (slope) NULLs
-- Result: Cleveland 1 (0.3%) | Hungary 189 (64%) | Switzerland 17 (14%) | VA Long Beach 102 (51%)
-- Decision: use with caution - significant missing data in Hungary and VA Long Beach
SELECT dataset, COUNT(*) AS slope_nulos 
FROM heart_disease_uci 
WHERE slope IS NULL 
GROUP BY dataset;

-- Stress Test (thal) NULLs
-- Result: Cleveland 3 (1%) | Hungary 265 (90%) | Switzerland 52 (42%) | VA Long Beach 166 (83%)
-- Decision: use Cleveland data only - major limitation
SELECT dataset, COUNT(*) AS thal_nulos 
FROM heart_disease_uci 
WHERE thal IS NULL 
GROUP BY dataset;

-- Resting ECG (restecg) NULLs
-- Result: Hungary 1 | Switzerland 1 - only 2 NULLs total
-- Decision: negligible, no action needed
SELECT dataset, COUNT(*) AS restecg_nulos 
FROM heart_disease_uci 
WHERE restecg IS NULL 
GROUP BY dataset;

-- Fasting Blood Sugar (fbs) NULLs
-- Result: Cleveland 0 | Hungary 8 (3%) | Switzerland 75 (61%) | VA Long Beach 7 (3.5%)
-- Decision: exclude Switzerland from fbs analysis
SELECT dataset, COUNT(*) AS fbs_nulos 
FROM heart_disease_uci 
WHERE fbs IS NULL 
GROUP BY dataset;


-- --------------------------------------------
-- 5.5 Negative Values in oldpeak
-- Objective: investigate clinically unexpected
-- negative values in ST segment depression
-- --------------------------------------------

-- Count negative values
-- Result: 12 negative values total
-- Decision: keep - may represent ST elevation, clinically significant
SELECT COUNT(*) AS oldpeak_negativos 
FROM heart_disease_uci 
WHERE convert(decimal(2,1), oldpeak) < 0;

-- Check which institution they come from
-- Result: Switzerland 11 | VA Long Beach 1
SELECT dataset, COUNT(*) AS oldpeak_negativos 
FROM heart_disease_uci 
WHERE convert(decimal(2,1), oldpeak) < 0 
GROUP BY dataset;


-- --------------------------------------------
-- 5.6 Summary of Data Quality Decisions
-- --------------------------------------------

-- Issue                                Decision
-- chol NULLs from Switzerland          Keep as NULL, exclude from cholesterol analysis
-- ca - 99% missing outside Cleveland   Use Cleveland data only - major limitation
-- thal - 90%+ missing outside          Use Cleveland data only - major limitation
--   Cleveland
-- slope - 50-64% missing in Hungary    Use with caution - note as limitation
--   and VA Long Beach
-- fbs - 61% missing in Switzerland     Exclude Switzerland from fbs analysis
-- restecg - only 2 NULLs total         Negligible - no action needed
-- oldpeak negative values (n=12)       Keep - investigate in analysis
-- num ranges 0-4                       Group 1-4 as disease present

-- General observation: Switzerland consistently shows the most
-- data quality issues across multiple variables. Results involving
-- Swiss data should be interpreted with particular caution.


-- --------------------------------------------
-- 5.7 Cleaned View for Power BI
-- Objective: consolidate all cleaned and
-- transformed variables into a single view
-- for use in Power BI dashboard
-- --------------------------------------------

CREATE VIEW heart_disease_clean AS
SELECT
    sex,
    age,
    CASE
        WHEN age < 40 THEN 'Under 40'
        WHEN age BETWEEN 40 AND 55 THEN '40-55'
        WHEN age BETWEEN 56 AND 65 THEN '56-65'
        ELSE 'Over 65'
    END AS age_group,
    CASE WHEN num = '0' THEN 'No Disease' ELSE 'Disease Present' END AS diagnosis,
    num AS disease_severity,
    chol,
    CASE
        WHEN chol IS NULL THEN 'No Data'
        WHEN chol < 200 THEN 'Under 200 mg/mL'
        WHEN chol BETWEEN 200 AND 239 THEN '200-239 mg/mL'
        ELSE 'Over 240 mg/mL'
    END AS chol_group,
    cp,
    trestbps,
    CONVERT(DECIMAL(4,1), oldpeak) AS oldpeak,
    CASE
        WHEN oldpeak IS NULL THEN 'No Data'
        WHEN CONVERT(DECIMAL(2,1), oldpeak) < 0 THEN 'Below 0'
        WHEN CONVERT(DECIMAL(2,1), oldpeak) = 0 THEN 'Normal'
        ELSE 'Above 0'
    END AS oldpeak_group,
    thal,
    CONVERT(INT, ca) AS ca,
    slope,
    fbs,
    restecg,
    thalch,
    exang,
    dataset
FROM heart_disease_uci;

-- Verify the view was created correctly
SELECT * FROM heart_disease_clean;


-- ============================================
-- 6. DATA ANALYSIS
-- ============================================

-- All analyses below aim to answer the clinical 
-- questions defined in Section 4.
-- Results and clinical interpretations are 
-- documented in the comments after each query.


-- --------------------------------------------
-- 6.1 Overall Disease Distribution
-- Objective: understand the overall balance
-- of disease vs no disease in the dataset
-- --------------------------------------------

-- Result: Disease Present 509 (55.33%) | No Disease 411 (44.67%)
-- Near-balanced distribution - favourable for analysis


-- --------------------------------------------
-- 6.2 Heart Disease by Sex
-- Objective: determine whether sex influences
-- the likelihood of heart disease
-- --------------------------------------------

-- Result: Female 25.80% disease | Male 63.20% disease
-- Males significantly higher prevalence
-- Note: dataset imbalanced - 79% male (726 vs 194 females)
-- Consistent with established literature on sex-based cardiovascular risk


-- --------------------------------------------
-- 6.3 Heart Disease by Age Group and Sex
-- Objective: determine whether age is a
-- significant risk factor and how it
-- interacts with sex
-- --------------------------------------------

-- Result: Males 37.7% (Under 40) to 80.6% (Over 65) - progressive increase
-- Females stable ~15% until 55, sharp rise to 50% at 56-65
-- Consistent with post-menopausal loss of oestrogen cardioprotection
-- Note: females over 65 only n=15 - insufficient for conclusions


-- --------------------------------------------
-- 6.4 Heart Disease by Cholesterol Level
-- Objective: determine whether cholesterol
-- levels are associated with heart disease
-- Note: Switzerland excluded (all chol NULL)
-- --------------------------------------------

-- First checked min/max cholesterol by sex:
-- Female: min 141, max 564
-- Male: min 85, max 603
-- Male minimum of 85 is clinically suspicious (< 100 mg/dl)
-- Kept in dataset but noted as potential data quality issue

-- Result: clear trend in females (10% to 30.6%)
-- Weaker trend in males (45.9% to 61.7%)
-- Males with normal cholesterol still 45.9% disease
-- Suggests sex is stronger independent risk factor than cholesterol


-- --------------------------------------------
-- 6.5 Heart Disease by Chest Pain Type
-- Objective: determine which chest pain type
-- is most predictive of heart disease
-- --------------------------------------------

-- Result: Asymptomatic 79% | Typical angina 43% | Non-anginal 35% | Atypical 13%
-- Chest pain alone is a poor predictor of heart disease
-- Asymptomatic patients have highest prevalence - silent ischaemia
-- Important: systematic screening needed regardless of symptoms


-- --------------------------------------------
-- 6.6 Heart Disease by Stress Test (thal)
-- Objective: determine whether stress test
-- results are predictive of heart disease
-- Note: thal only reliable for Cleveland data
-- 486 NULLs excluded
-- --------------------------------------------

-- Result: Normal 29.6% | Fixed defect 76.1% | Reversable defect 80.2%
-- Abnormal stress test results strongly predictive (76-80%)
-- Fixed defect = scar tissue from previous infarction
-- Reversable defect = active ischaemia - most concerning finding
-- Based on 434 valid records - predominantly Cleveland data


-- --------------------------------------------
-- 6.7 Heart Disease by Major Vessels (ca)
-- Objective: determine whether number of
-- affected vessels relates to diagnosis
-- Note: ca only reliable for Cleveland data
-- --------------------------------------------

-- Result: 0 vessels 26.5% | 1 vessel 68.7% | 2 vessels 80.5% | 3 vessels 85%
-- Strong linear association - most convincing result in dataset
-- Consistent with progressive nature of coronary artery disease


-- --------------------------------------------
-- 6.8 Heart Disease by ST Segment (oldpeak)
-- Objective: determine whether ST segment
-- changes are associated with heart disease
-- --------------------------------------------

-- Result: Normal 33% | Above 0 70% | Below 0 75%
-- Any ST abnormality strongly associated with disease (70-75%)
-- Below 0 group only n=12 - insufficient for definitive conclusions


-- ============================================
-- 7. DISCUSSION
-- ============================================

-- 7.1 Sex as a Dominant Risk Factor
-- The most striking finding is the magnitude of the sex difference:
-- 63.2% in males versus 25.8% in females.
-- In females, disease prevalence remains stable at ~15% until age 55,
-- then rises sharply to 50% in the 56-65 group.
-- This aligns precisely with the timing of menopause and loss of
-- oestrogen-mediated cardioprotection.
-- This underscores the importance of increased cardiovascular
-- screening in post-menopausal women.

-- 7.2 The Paradox of Chest Pain
-- The most counterintuitive finding is that asymptomatic patients
-- have the highest disease prevalence (79%), substantially exceeding
-- patients with typical angina (43%).
-- This reflects the well-documented phenomenon of silent ischaemia,
-- particularly common in diabetic patients and women.
-- The low disease prevalence in atypical angina (13.8%) further
-- reinforces that chest pain alone is insufficient for diagnosis.
-- Objective diagnostic tools are essential.

-- 7.3 Objective Markers as Superior Predictors
-- In contrast to the poor predictive value of symptoms, objective
-- clinical markers showed consistently strong associations:
-- - Number of affected vessels: near-perfect linear relationship
--   from 26.5% (0 vessels) to 85% (3 vessels)
-- - Stress test defects: fixed defects 76.1%, reversable 80.2%
-- - ST segment depression: 70% disease vs 33% with normal ST
-- These findings confirm the clinical value of objective diagnostic
-- tools over symptom-based assessment.

-- 7.4 Cholesterol - A Risk Factor with Nuance
-- The expected trend was observed - higher cholesterol associated
-- with higher disease prevalence.
-- However, the relationship was notably weaker in males.
-- Males with desirable cholesterol still showed 45.9% disease,
-- suggesting age and sex are more dominant risk factors.
-- Limitation: only total cholesterol available - LDL and HDL
-- would provide more clinically meaningful information.

-- 7.5 Data Quality and Institutional Differences
-- Cleveland provided the most complete data.
-- Hungary, Switzerland, and VA Long Beach showed significant
-- missing data for ca (99%), thal (90%), and cholesterol (100%).
-- Analyses of ca and thal are effectively analyses of the
-- Cleveland population rather than the full dataset.
-- Switzerland showed systematic issues across multiple variables.


-- ============================================
-- 8. LIMITATIONS
-- ============================================

-- - Dataset heavily imbalanced: males represent 79% of the sample
-- - Variables ca and thal only reliable for Cleveland Clinic data
-- - Switzerland shows systematic data collection issues
-- - Total cholesterol alone is not the most accurate risk indicator
--   LDL and HDL fractions would be more informative
-- - Small sample of females over 65 (n=15) limits conclusions
-- - Negative oldpeak values (n=12) too few for definitive conclusions
-- - No treatment information, lifestyle factors, or family history
-- - Cross-sectional data does not allow for causal inference


-- ============================================
-- 9. CONCLUSIONS
-- ============================================

-- This analysis combining SQL data exploration and Power BI
-- visualization has yielded several important clinical insights.

-- Key Takeaways:
-- 1. Asymptomatic patients have the highest disease prevalence (79%)
--    Silent ischaemia is clinically significant and often overlooked
-- 2. Objective markers (ca, thal, oldpeak) are far more reliable
--    predictors than subjective symptom presentation
-- 3. Post-menopausal women show a sharp increase in cardiovascular
--    risk - screening should be intensified after menopause
-- 4. Data quality varies substantially across institutions -
--    Cleveland data is most reliable for this dataset
-- 5. A multifactorial approach to cardiovascular risk assessment
--    is essential - no single marker is sufficient