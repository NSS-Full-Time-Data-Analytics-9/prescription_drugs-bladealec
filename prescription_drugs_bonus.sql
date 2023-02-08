-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?
SELECT COUNT(npi) AS prescriber_no_prescription_count
FROM 
	(SELECT npi
	 FROM prescriber
	 EXCEPT
	 SELECT npi
	 FROM prescription) AS prescriber_no_prescription


-- 2.
--     a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.
SELECT  p2.specialty_description, d.generic_name, SUM(p1.total_claim_count) AS sum_claim
FROM drug AS d
INNER JOIN prescription AS p1
USING(drug_name)
INNER JOIN prescriber AS p2
ON(p1.npi=p2.npi)
WHERE p2.specialty_description ILIKE 'Family Practice'
GROUP BY p2.specialty_description, d.generic_name
ORDER BY sum_claim DESC
LIMIT 5;


--     b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT  p2.specialty_description, d.generic_name, SUM(p1.total_claim_count) AS sum_claim
FROM drug AS d
INNER JOIN prescription AS p1
USING(drug_name)
INNER JOIN prescriber AS p2
ON(p1.npi=p2.npi)
WHERE p2.specialty_description ILIKE 'cardiology'
GROUP BY p2.specialty_description, d.generic_name
ORDER BY sum_claim DESC
LIMIT 5;


--     c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.
(SELECT  p2.specialty_description, d.generic_name, SUM(p1.total_claim_count) AS sum_claim
FROM drug AS d
INNER JOIN prescription AS p1
USING(drug_name)
INNER JOIN prescriber AS p2
ON(p1.npi=p2.npi)
WHERE p2.specialty_description ILIKE 'cardiology'
GROUP BY p2.specialty_description, d.generic_name
ORDER BY sum_claim DESC
LIMIT 5)

UNION

(SELECT  p2.specialty_description, d.generic_name, SUM(p1.total_claim_count) AS sum_claim
FROM drug AS d
INNER JOIN prescription AS p1
USING(drug_name)
INNER JOIN prescriber AS p2
ON(p1.npi=p2.npi)
WHERE p2.specialty_description ILIKE 'family practice'
GROUP BY p2.specialty_description, d.generic_name
ORDER BY sum_claim DESC
LIMIT 5)
ORDER BY sum_claim DESC;


-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--     a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.
SELECT p1.npi, SUM(p1.total_claim_count) AS sum_claim_count, p2.nppes_provider_city
FROM prescription AS p1
INNER JOIN prescriber AS p2
USING(npi)
WHERE p2.nppes_provider_city ILIKE 'Nashville'
GROUP BY p1.npi, p2.nppes_provider_city
ORDER BY sum_claim_count DESC
LIMIT 5;

--     b. Now, report the same for Memphis.
SELECT p1.npi, SUM(p1.total_claim_count) AS sum_claim_count, p2.nppes_provider_city
FROM prescription AS p1
INNER JOIN prescriber AS p2
USING(npi)
WHERE p2.nppes_provider_city ILIKE 'Memphis'
GROUP BY p1.npi, p2.nppes_provider_city
ORDER BY sum_claim_count DESC
LIMIT 5;

--     c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.
(SELECT p1.npi, SUM(p1.total_claim_count) AS sum_claim_count, p2.nppes_provider_city
 FROM prescription AS p1
 INNER JOIN prescriber AS p2
 USING(npi)
 WHERE p2.nppes_provider_city ILIKE 'Nashville'
 GROUP BY p1.npi, p2.nppes_provider_city
 ORDER BY sum_claim_count DESC
 LIMIT 5)

UNION

(SELECT p1.npi, SUM(p1.total_claim_count) AS sum_claim_count, p2.nppes_provider_city
 FROM prescription AS p1
 INNER JOIN prescriber AS p2
 USING(npi)
 WHERE p2.nppes_provider_city ILIKE 'Memphis'
 GROUP BY p1.npi, p2.nppes_provider_city
 ORDER BY sum_claim_count DESC
 LIMIT 5)

Union

(SELECT p1.npi, SUM(p1.total_claim_count) AS sum_claim_count, p2.nppes_provider_city
 FROM prescription AS p1
 INNER JOIN prescriber AS p2
 USING(npi)
 WHERE p2.nppes_provider_city ILIKE 'Knoxville'
 GROUP BY p1.npi, p2.nppes_provider_city
 ORDER BY sum_claim_count DESC
 LIMIT 5)

UNION

(SELECT p1.npi, SUM(p1.total_claim_count) AS sum_claim_count, p2.nppes_provider_city
 FROM prescription AS p1
 INNER JOIN prescriber AS p2
 USING(npi)
 WHERE p2.nppes_provider_city ILIKE 'Chattanooga'
 GROUP BY p1.npi, p2.nppes_provider_city
 ORDER BY sum_claim_count DESC
 LIMIT 5)

ORDER BY sum_claim_count DESC;


-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

SELECT fips.county, od.deaths AS overdose_deaths
FROM fips_county AS fips
INNER JOIN overdoses AS od
USING(fipscounty)
WHERE od.deaths > (SELECT AVG(deaths)
				   FROM overdoses)
ORDER BY overdose_deaths DESC;



-- 5.
--     a. Write a query that finds the total population of Tennessee.
    
--     b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.