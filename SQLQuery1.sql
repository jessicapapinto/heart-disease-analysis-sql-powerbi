-- 1. Introduction -- 
-- Cardiovascular disease (CVD) remains one of the leading causes of morbidity and mortality worldwide. Early identification of risk factors and accurate diagnosis are critical to improving patient outcomes and reducing healthcare costs. Despite significant advances in medical science, CVD continues to affect millions of people globally, with risk factors ranging from demographic characteristics such as age and sex to clinical markers such as cholesterol levels and electrocardiographic findings. --
-- This project explores the UCI Heart Disease dataset, which contains clinical data from patients evaluated for coronary artery disease across four medical institutions: Cleveland Clinic Foundation, Hungarian Institute of Cardiology, University Hospital Zurich, and VA Long Beach. The dataset combines data from 920 patients and 14 clinical variables, making it one of the most widely used datasets in cardiovascular research.
-- The primary objective of this project is to use SQL for data exploration, cleaning, and analysis, and Power BI for interactive dashboard visualization, to identify key clinical patterns and risk factors associated with heart disease. A particular focus is placed on understanding whether commonly assumed risk factors — such as chest pain and high cholesterol — are truly predictive in this population, and whether any unexpected patterns emerge from the data.
-- This analysis combines a data science approach with clinical domain knowledge, drawing on peer-reviewed literature to contextualise and interpret findings. The goal is not only to identify statistical associations but to understand their clinical significance and implications for patient care.

-- 2. Clinical Background
-- 2.1 Age and Cardiovascular Risk
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

-- 5. Data Quality Assessment
-- Before performing any analysis, the dataset was examined to ensure data integrity. The assessment was performed in the following order: (1) overall structure, (2) data types, (3) distinct values per column, (4) missing values by column and institution, (5) documentation of issues and decisions.

-- 5.1 Dataset Overview


select * from heart_disease_uci
SELECT COUNT(*) AS total_registos
FROM heart_disease_uci;
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'heart_disease_uci';

SELECT DISTINCT ca FROM heart_disease_uci;
SELECT DISTINCT oldpeak FROM heart_disease_uci;
SELECT DISTINCT num FROM heart_disease_uci;
SELECT DISTINCT slope FROM heart_disease_uci;

SELECT dataset, COUNT(*) AS ca_nulos
FROM heart_disease_uci
WHERE ca IS NULL
GROUP BY dataset;

SELECT dataset, COUNT(*) AS oldpeak_nulos
FROM heart_disease_uci
WHERE oldpeak IS NULL
GROUP BY dataset;

SELECT dataset, COUNT(*) AS slope_null
From heart_disease_uci
Where slope is null
Group by dataset

SELECT dataset, COUNT(*) AS oldpeak_negativos
FROM heart_disease_uci
WHERE convert(decimal(2,1), oldpeak) < 0
GROUP BY dataset;

Select distinct thal
from heart_disease_uci

Select dataset, COUNT(*) AS thal_nulos
from heart_disease_uci
where thal is null
Group by dataset

select distinct sex
from heart_disease_uci

select distinct cp
from heart_disease_uci

SELECT DISTINCT restecg
FROM heart_disease_uci;

SELECT dataset, COUNT(*) AS restecg_nulos
FROM heart_disease_uci
WHERE restecg is null
Group by dataset

SELECT DISTINCT fbs
FROM heart_disease_uci;


Select dataset, count(*) as fbs_null
from heart_disease_uci
wher
Group by dataset


# quero ver se o género influencia a ter ou não na doença

select distinct sex, num
from heart_disease_uci


Select
	sex,
	diagnosis,
	total,
	convert(decimal(4,2),round(total*100.00/TotalSex,1))
from (
	Select
		sex,
		Case when num = '0' then 'No Disease' ELSE 'Disease Present' end as diagnosis,
		COUNT(*) AS total,
		CASE WHEN sex = 'Female' then
			(Select Count(*) from heart_disease_uci where sex = 'Female')
		else
			(Select Count(*) from heart_disease_uci where sex = 'Male')
		End as TotalSex
	from heart_disease_uci
	group by sex, Case when num = '0' then 'No Disease' ELSE 'Disease Present' end
) as diagnosis_percentage
order by sex, diagnosis


select *,
    Convert(decimal(4,2),ROUND(No_Disease*100.0/SUM(total) OVER (PARTITION BY sex,age_group), 1)) AS No_Disease_percentage,
	Convert(decimal(4,2),ROUND(Disease*100.0/SUM(total) OVER (PARTITION BY sex,age_group), 1)) AS Disease_percentage
from(
	Select
		sex,
		case 
			when age < 40 then 'Under 40'
			when age BETWEEN 40 AND 55 then '40-55'
			when age BETWEEN 56 AND 65 then '56-65'
			ELSE 'Over 65'
		End AS age_group,
		Sum( Case when num = '0' then 1 ELSE 0 end) as No_Disease, 
		Sum( Case when num = '0' then 0 ELSE 1 end) as Disease, 
		Count(*) As total
	from heart_disease_uci
	GROUP BY 
		sex,
		CASE 
			WHEN age < 40 THEN 'Under 40'
			WHEN age BETWEEN 40 AND 55 THEN '40-55'
			WHEN age BETWEEN 56 AND 65 THEN '56-65'
			ELSE 'Over 65'
		END
) as age_diagnosis
ORDER BY sex, age_group


Select 
	sex, 
	Min(chol) as chol_min,
	Max(chol) as chol_max
from heart_disease_uci
group by sex


SELECT 
    sex,
    CASE WHEN num = '0' THEN 'No Disease' ELSE 'Disease Present' END AS diagnosis,
    CASE 
        WHEN chol < 200 THEN 'Under 200 mg/mL'
        WHEN chol BETWEEN 200 AND 239 THEN '200-239 mg/mL'
        ELSE 'Over 240 mg/mL' 
    END AS chol_group,
	COUNT(*) AS total
FROM heart_disease_uci
WHERE chol IS NOT NULL
GROUP BY 
    sex,
    CASE WHEN num = '0' THEN 'No Disease' ELSE 'Disease Present' END,
	CASE 
        WHEN chol < 200 THEN 'Under 200 mg/mL'
        WHEN chol BETWEEN 200 AND 239 THEN '200-239 mg/mL'
        ELSE 'Over 240 mg/mL' 
    END
ORDER BY sex, chol_group



Select
	cp, No_Diagnosis, Disease_Present, total,
	Round(Disease_Present*100/total,1) as percentage_disease
from (
	Select 
		cp,
		Sum(case when num = '0' then 1 else 0 end) as No_Diagnosis,
		Sum(case when num != '0' then 1 else 0 end) as Disease_Present,
		Count(*) as total
	from heart_disease_uci
	group by cp
) as table_1


Select
	thal, Non_disease, Disease, total,
	Convert(decimal(4,2), Round(disease*100.0/total,1)) as percentage_disease
from(
	Select
		thal, 
		Sum(CASE when num = '0' then 1 else 0 end) as Non_disease,
		Sum(CASE when num != '0' then 1 else 0 end) as Disease_Present,
		Count(*) as total
	from heart_disease_uci
	WHERE thal IS NOT NULL
	group by thal
) table_2

Select
	ca, Non_disease,Disease_Present,total,
	Convert(decimal(4,2), Round(Disease_Present*100.0/total,1)) as percentage_disease
from (
	Select 
		ca, 
		Sum(case when num = '0' then 1 else 0 end) as Non_disease,
		Sum(case when num != '0' then 1 else 0 end) as Disease_Present,
		Count(*) as total
	from heart_disease_uci
	where ca is not null
	group by ca
) as table_3

Select
	oldpeak_range ,Non_disease,Disease_Present, total,
	Disease_Present*100/total as disease_percentage
from(
	Select 
		Case
			when convert(decimal(2,1),oldpeak)<0 then 'bellow 0'
			when convert(decimal(2,1),oldpeak) = 0 then 'normal'
			when convert(decimal(2,1),oldpeak) > 0 then 'above 0'
		end as oldpeak_range,
		Sum(case when num = '0' then 1 else 0 end) as Non_disease,
		Sum(case when num != '0' then 1 else 0 end) as Disease_Present, 
		Count(*) as total
	from heart_disease_uci
	where oldpeak is not null
	group by
		Case
			when convert(decimal(2,1),oldpeak)<0 then 'bellow 0'
			when convert(decimal(2,1),oldpeak) = 0 then 'normal'
			when convert(decimal(2,1),oldpeak) > 0 then 'above 0'
		end
) as table_4




CREATE VIEW heart_disease_clean AS
SELECT
    -- Demographics
    sex,
    age,
    CASE
        WHEN age < 40 THEN 'Under 40'
        WHEN age BETWEEN 40 AND 55 THEN '40-55'
        WHEN age BETWEEN 56 AND 65 THEN '56-65'
        ELSE 'Over 65'
    END AS age_group,

    -- Diagnosis
    CASE WHEN num = '0' THEN 'No Disease' ELSE 'Disease Present' END AS diagnosis,
    num AS disease_severity,

    -- Cholesterol
    chol,
    CASE
        WHEN chol IS NULL THEN 'No Data'
        WHEN chol < 200 THEN 'Under 200 mg/mL'
        WHEN chol BETWEEN 200 AND 239 THEN '200-239 mg/mL'
        ELSE 'Over 240 mg/mL'
    END AS chol_group,

    -- Chest pain
    cp,

    -- Blood pressure
    trestbps,

    -- ST segment
    CONVERT(DECIMAL(4,1), oldpeak) AS oldpeak,
    CASE
        WHEN oldpeak IS NULL THEN 'No Data'
        WHEN CONVERT(DECIMAL(2,1), oldpeak) < 0 THEN 'Below 0'
        WHEN CONVERT(DECIMAL(2,1), oldpeak) = 0 THEN 'Normal'
        ELSE 'Above 0'
    END AS oldpeak_group,

    -- Other clinical variables
    thal,
    CONVERT(INT, ca) AS ca,
    slope,
    fbs,
    restecg,
    thalch,
    exang,
    dataset

FROM heart_disease_uci;

Select*
from heart_disease_clean