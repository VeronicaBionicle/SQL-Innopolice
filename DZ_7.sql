select * from adult_income ai;

-- Распределение по расе, полу и уровню дохода
select race, sex, income_label, count(1) cnt from adult_income ai
group by race, sex, income_label
order by race, sex, case when income_label = '<=50K' then 0 else 1 end;

-- Распределение по расе, полу и уровню дохода
create view v_race_sex_income_grouping as
select race, sex, income_label
, count(1) cnt
, case grouping(race, sex, income_label)
		when 2 then 'Total by race'
		when 4 then 'Total by sex'
		when 6 then 'Total' end grouping
from adult_income ai
group by grouping sets ((race, income_label), (sex, income_label), (race, sex, income_label), (income_label))
order by race, sex, case when income_label = '<=50K' then 0 else 1 end;

-- Распределение по образованию и роду деятельности
create view v_education_occupation_grouping as
select education, occupation, count(1) cnt
, case grouping(education, occupation) 
		when 1 then 'Total by education'
		when 2 then 'Total by occupation'
		when 3 then 'Total' end grouping
from adult_income ai 
group by cube(education, occupation)
order by 1, 2, 3;

-- Распределение по полу и возрасту
create view v_age_sex_grouping as
select age , sex, count(1) cnt
, case grouping(age , sex)
		when 1 then 'Total by age'
		when 3 then 'Total' end grouping
from adult_income ai 
group by rollup(age , sex)
order by 1, 2;

select * from v_race_sex_income_grouping;
select * from v_education_occupation_grouping where occupation = 'Craft-repair';
select * from v_age_sex_grouping;
