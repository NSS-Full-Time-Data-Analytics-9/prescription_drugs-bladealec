-- 1.
--     1.a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. 

SELECT npi,
	   SUM(total_claim_count) AS total_claim_sum  
	   
FROM prescription

GROUP BY npi
ORDER BY SUM(total_claim_count) DESC;
-- total_claim_count is per drug so we needed to sum claims for each drug
-- npi 1881634483 , total_claim_sum 99707


--     1.b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT p1.npi
      ,p1.nppes_provider_first_name
	  ,p1.nppes_provider_last_org_name
	  ,p1.specialty_description
	  ,SUM(p2.total_claim_count) AS total_claim_sum 
	  
FROM prescriber AS p1
	INNER JOIN prescription AS p2
	USING(npi)
	
GROUP BY p1.npi
	    ,p1.nppes_provider_first_name
		,p1.nppes_provider_last_org_name
		,p1.specialty_description
		
ORDER BY total_claim_sum DESC;
-- Bruce Pendley , Family Practice , 99707



-- 2. 
--     2.a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT prescriber.specialty_description,
	   SUM(prescription.total_claim_count) AS total_claim_sum
	   
FROM prescriber
	 INNER JOIN prescription
	 USING(npi)
	 
GROUP BY prescriber.specialty_description		 
ORDER BY SUM(prescription.total_claim_count) DESC;
-- Family Practice , 9752347 claims


--     2.b. Which specialty had the most total number of claims for opioids?
SELECT prescriber.specialty_description,
	   SUM(prescription.total_claim_count) AS total_claim_sum
	   
FROM prescription
	 INNER JOIN prescriber
	 USING(npi)
	 INNER JOIN drug
	 USING(drug_name)
	 
WHERE opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description	 
ORDER BY SUM(prescription.total_claim_count) DESC;
-- Nurse Practitioner , 900845 claims

--     2.c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT COUNT(*) AS no_prescript_specialties_amnt

FROM (
	
(SELECT DISTINCT(specialty_description)
 FROM prescriber)
 
EXCEPT

(SELECT DISTINCT(prescriber.specialty_description)
 FROM prescription
 INNER JOIN prescriber
 USING (npi))
	
	 ) AS no_prescription_specialties;
-- 15 specialites
 
 
--     2.d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

SELECT DISTINCT specialty_description
FROM prescriber;
---------
SELECT p1.specialty_description
	  ,ROUND(( opioid_claim.opioid_claim_count / SUM(p2.total_claim_count)) * 100, 2) AS opioid_claim_percentage
	  
FROM prescriber AS p1
	 INNER JOIN prescription AS p2
	 USING(npi)
	 INNER JOIN
				(SELECT DISTINCT(p1.specialty_description)
	   				   ,SUM(p2.total_claim_count) AS opioid_claim_count
 				 FROM prescriber AS p1
	  			 INNER JOIN prescription AS p2
	  			 USING(npi)
				 INNER JOIN drug
				 USING(drug_name)
 				 WHERE opioid_drug_flag = 'Y'
 				 GROUP BY p1.specialty_description) AS opioid_claim				 
	 USING(specialty_description)
	 
GROUP BY p1.specialty_description, opioid_claim.opioid_claim_count
ORDER BY opioid_claim_percentage DESC;



-- 3. 
--     3.a. Which drug (generic_name) had the highest total drug cost?

SELECT DISTINCT(drug.generic_name)
	  ,SUM(prescription.total_drug_cost)::money AS drug_cost_sum
	  
FROM drug
	 INNER JOIN prescription
	 USING(drug_name) 
	 
GROUP BY drug.generic_name
ORDER BY drug_cost_sum DESC;
-- **VERY HIGH** "INSULIN GLARGINE,HUM.REC.ANLOG" total cost 104264066.35 ; price paid for all claims, (2013-2017)?


--     3.b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT DISTINCT(drug.generic_name)
	   ,(ROUND(SUM(prescription.total_drug_cost) / SUM(total_day_supply) , 2))::money AS total_cost_perday
	   
FROM drug
	 INNER JOIN prescription
	 USING(drug_name)
	 
GROUP BY drug.generic_name
ORDER BY total_cost_perday DESC;
-- "C1 ESTERASE INHIBITOR" $3495.22



-- 4. 
--     4.a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT DISTINCT(prescription.drug_name),
	   CASE WHEN drug.opioid_drug_flag = 'Y' THEN 'opioid'
	   		WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			ELSE 'neither' END AS drug_type

FROM prescription
	 INNER JOIN drug
	 USING(drug_name)
	 
ORDER BY drug_type;


--     4.b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT
	   CASE WHEN drug.opioid_drug_flag = 'Y' THEN 'opioid'
	   		WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			ELSE 'neither' END AS drug_type,
	   (SUM(prescription.total_drug_cost))::money AS total_cost

FROM prescription
	 INNER JOIN drug
	 USING(drug_name)
	 
GROUP BY drug_type
ORDER BY total_cost DESC;



-- 5. 
--     5.a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT fips_county.state
	  ,COUNT(DISTINCT(cbsa.cbsa)) AS cbsa_count
	  
FROM cbsa
	 INNER JOIN fips_county
	 USING(fipscounty)
	 
WHERE state ILIKE 'TN'
GROUP BY fips_county.state;
-- my approach

SELECT DISTINCT cbsa, cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN%';
-- above (3 lines) is from Chris Gorman ; another way to approach


--     5.b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

(SELECT cbsa.cbsa, SUM(population.population) AS population_sum
FROM cbsa
	 INNER JOIN population
	 USING(fipscounty)
GROUP BY cbsa.cbsa
ORDER BY SUM(population.population) DESC
LIMIT 1)

UNION

(SELECT cbsa.cbsa, SUM(population.population) AS population_sum
FROM cbsa
	 INNER JOIN population
	 USING(fipscounty)
GROUP BY cbsa.cbsa
ORDER BY SUM(population.population)
LIMIT 1)
ORDER BY population_sum DESC;
-- MAX: cbsa "34980", pop 1830410
-- MIN: cbsa "34100", pop 116352


--     5.c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

(SELECT fips_county.fipscounty
 	   ,fips_county.county
 	   ,fips_county.state
	   ,SUM(population.population) AS population_sum

 FROM fips_county
	  INNER JOIN population
	  USING(fipscounty)
	 
 GROUP BY fips_county.fipscounty
 		 ,fips_county.county
 		 ,fips_county.state)

EXCEPT

(SELECT cbsa.fipscounty
 	   ,fips_county.county
 	   ,fips_county.state
 	   ,SUM(population.population) AS population_sum
 
 FROM cbsa
 	  INNER JOIN population
 	  USING(fipscounty)
 	  INNER JOIN fips_county
 	  USING(fipscounty)

	  GROUP BY cbsa.fipscounty
 		      ,fips_county.county
 		      ,fips_county.state)
	  
ORDER BY population_sum DESC
LIMIT 1;
-- Sevier, TN pop. 95523



-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name
	  ,SUM(total_claim_count) AS summed_claim_count
FROM prescription
GROUP BY drug_name
HAVING SUM(total_claim_count) >= 3000
ORDER BY summed_claim_count DESC;


--     6.b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name
	  ,SUM(total_claim_count) AS summed_claim_count
	  ,CASE WHEN drug.opioid_drug_flag = 'Y' THEN true
	   ELSE 'false' END AS opioid
	   
FROM prescription
	 INNER JOIN drug
	 USING(drug_name)
	 
GROUP BY drug_name, opioid
HAVING SUM(total_claim_count) >= 3000
ORDER BY summed_claim_count DESC;
-- **10 more rows were added from part a** ; I found two drugs that were added and they dont seem to be duplicates


--     6.c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT p2.nppes_provider_first_name,
	   p2.nppes_provider_last_org_name,
	   p1.drug_name,
	   SUM(p1.total_claim_count) AS summed_claim_count,
	   CASE WHEN d.opioid_drug_flag = 'Y' THEN true
	   ELSE 'false' END AS opioid
	   
FROM prescription AS p1
	 INNER JOIN drug AS d
	 USING(drug_name)
	 INNER JOIN prescriber AS p2
	 USING(npi)
	 
GROUP BY p2.nppes_provider_first_name,
		 p2.nppes_provider_last_org_name,
	     p1.drug_name,
		 opioid
		 
HAVING SUM(total_claim_count) >= 3000
ORDER BY summed_claim_count DESC;



-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     7.a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT p1.npi
	   ,d.drug_name
--	   ,p1.specialty_description AS specialty
--	   ,p1.nppes_provider_city AS city

 FROM prescriber AS p1
	  CROSS JOIN drug AS d
	 
 WHERE p1.specialty_description ILIKE 'Pain Management'
	   AND p1.nppes_provider_city ILIKE 'NASHVILLE'
	   AND d.opioid_drug_flag = 'Y'

	   
--     7.b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p1.npi
	  ,d.drug_name
	  ,SUM(COALESCE(p2.total_claim_count, 0)) AS total_claim_count
--	  ,p2.specialty_description AS specialty
--	  ,p2.nppes_provider_city AS city
--	  ,d.opioid_drug_flag AS opioid
FROM prescriber AS p1
	 CROSS JOIN drug AS d
	 FULL JOIN prescription AS p2
	 USING(npi, drug_name)
	 
	 
WHERE p1.specialty_description ILIKE 'Pain Management'
	  AND p1.nppes_provider_city ILIKE 'NASHVILLE'
	  AND d.opioid_drug_flag = 'Y'
GROUP BY p1.npi, d.drug_name
ORDER BY total_claim_count DESC;
	
	
--     7.c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT p1.npi
	  ,d.drug_name
	  ,SUM(COALESCE(p2.total_claim_count, 0)) AS total_claim_count
--	  ,p2.specialty_description AS specialty
--	  ,p2.nppes_provider_city AS city
--	  ,d.opioid_drug_flag AS opioid
FROM prescriber AS p1
	 CROSS JOIN drug AS d
	 FULL JOIN prescription AS p2
	 USING(npi, drug_name)
	 
	 
WHERE p1.specialty_description ILIKE 'Pain Management'
	  AND p1.nppes_provider_city ILIKE 'NASHVILLE'
	  AND d.opioid_drug_flag = 'Y'
GROUP BY p1.npi, d.drug_name
ORDER BY total_claim_count DESC;
