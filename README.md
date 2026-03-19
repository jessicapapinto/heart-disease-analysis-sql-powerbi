# heart-disease-analysis-sql-powerbi
Analysis of UCI Heart Disease dataset using SQL and Power BI

# 1. Introduction 
Cardiovascular disease (CVD) remains one of the leading causes of morbidity and mortality worldwide. Early identification of risk factors and accurate diagnosis are critical to improving patient outcomes and reducing healthcare costs. Despite significant advances in medical science, CVD continues to affect millions of people globally, with risk factors ranging from demographic characteristics such as age and sex to clinical markers such as cholesterol levels and electrocardiographic findings. --

This project explores the UCI Heart Disease dataset, which contains clinical data from patients evaluated for coronary artery disease across four medical institutions: Cleveland Clinic Foundation, Hungarian Institute of Cardiology, University Hospital Zurich, and VA Long Beach. The dataset combines data from 920 patients and 14 clinical variables, making it one of the most widely used datasets in cardiovascular research.

The primary objective of this project is to use SQL for data exploration, cleaning, and analysis, and Power BI for interactive dashboard visualization, to identify key clinical patterns and risk factors associated with heart disease. A particular focus is placed on understanding whether commonly assumed risk factors — such as chest pain and high cholesterol — are truly predictive in this population, and whether any unexpected patterns emerge from the data.

This analysis combines a data science approach with clinical domain knowledge, drawing on peer-reviewed literature to contextualise and interpret findings. The goal is not only to identify statistical associations but to understand their clinical significance and implications for patient care.

# 2. Clinical Background
## 2.1 Age and Cardiovascular Risk
-- Age is one of the strongest independent risk factors for cardiovascular disease. The prevalence of myocardial infarction is approximately 3.8% in individuals under 60 years and rises to 9.5% in those aged 60 and above. True coronary syndromes are uncommon in individuals under 40 years of age unless specific risk factors are present (DOI: 10.1016/j.eclinm.2023.102230). In this dataset, any patient under 40 presenting with heart disease should be interpreted with caution and examined for additional compounding risk factors.

-- 2.2 Chest Pain Classification (cp)
-- Chest pain can have many causes, both cardiac and non-cardiac. Cardiac causes include angina, myocardial infarction, and pericarditis. Non-cardiac causes include gastroesophageal reflux, anxiety, muscle tension, and pulmonary embolism. Chest pain is classified according to the Diamond criteria:
-- Typical angina: retrosternal discomfort lasting 2-15 minutes, triggered by exertion or stress, relieved by rest or nitrates Atypical angina: only two of the above characteristics present Non-cardiac chest pain: one or none of the above characteristics Asymptomatic: no chest pain — patient may have silent ischaemia
-- This terminology has been considered ambiguous in recent literature (DOI: 10.1161/HCQ.0000000000000112). A patient coded as asymptomatic may still have silent ischaemia — a clinically important consideration.

-- 2.3 Cholesterol and Fasting Blood Sugar
-- Hyperlipidaemia and diabetes are well-established etiological risk factors for cardiovascular disease (DOI: 10.1016/j.rec.2020.10.006). Reference values:
-- < 200 mg/dl: desirable 
-- 200-239 mg/dl: borderline high
-- = 240 mg/dl: high risk Fasting blood sugar > 120 mg/dl (fbs = 1): indicates possible diabetes or pre-diabetes
-- It is important to note that total cholesterol alone is not the most accurate cardiovascular risk indicator. Ideally, LDL and HDL should be assessed separately. This dataset only provides total cholesterol, which represents a limitation.

-- 2.4 ST Segment Depression (oldpeak)
-- The ST segment in an ECG represents the period between ventricular depolarization and repolarization. ST segment depression indicates myocardial ischaemia — the greater the depression, the higher the likelihood of coronary artery disease. Values above 2mm are considered clinically significant (DOI: 10.1161/01.cir.99.21.2829). Negative oldpeak values may represent ST segment elevation, associated with acute myocardial infarction.

-- 2.5 Major Vessels (ca)
-- The number of major vessels colored by fluoroscopy indicates how many coronary arteries show significant stenosis (narrowing >= 50%). The heart has three main coronary arteries: LAD, LCX, and RCA. This measurement is obtained through coronary angiography — an invasive procedure where contrast dye is injected and visualized under real-time X-ray.
-- ca = 0: no vessels affected 
-- ca = 1: one vessel affected 
-- ca = 2: two vessels affected 
-- ca = 3: all three main vessels affected — severe disease

-- 2.6 Stress Test Results (thal)
-- Normal: no perfusion defects Fixed defect: scar tissue — indicative of previous myocardial infarction 
-- Reversable defect: active ischaemia — most clinically concerning finding

-- 3. Dataset Description
-- The dataset contains 303 patients and 14 clinical variables collected from four institutions: Cleveland Clinic Foundation, Hungarian Institute of Cardiology, University Hospital Zurich, and University Hospital Basel.
-- VariableDescriptionClinical Reference ValuesagePatient age in yearsRisk increases significantly after 45 (M) / 55 (F)sex0 = Female, 1 = MaleMales at higher risk at younger agecpChest pain type (0–3)0 = typical angina, 3 = asymptomatictrestbpsResting blood pressure (mmHg)Normal < 120 mmHgcholSerum cholesterol (mg/dl)Normal < 200, High > 240fbsFasting blood sugar > 120 mg/dl1 = possible diabetesrestecgResting ECG results0 = normalthalachMaximum heart rate achievedDecreases with ageexangExercise-induced angina1 = present (concerning)oldpeakST depression induced by exercise> 2 mm clinically significantslopeSlope of peak exercise ST segment2 = flat/downsloping (concerning)caMajor vessels colored (0–3)0 = healthy, 3 = severe diseasethalStress test result7 = reversible defect (most concerning)targetHeart disease diagnosis0 = absent, 1 = present

-- 4. Analysis Objectives
-- Does sex influence the likelihood of heart disease?
-- Is age a significant risk factor and does it interact with sex?
-- Are cholesterol levels associated with heart disease?
-- Which chest pain type is most predictive of heart disease?
-- Is ST segment depression (oldpeak) associated with disease?
-- How does the number of affected vessels relate to diagnosis?
-- What is the distribution of stress test results across diagnoses?
