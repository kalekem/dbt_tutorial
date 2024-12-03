-- create students_raw table
-- replace project_id and datset_name with specific names from your bigquery environment
CREATE OR REPLACE TABLE `<project_id>.<dataset_name>.students_raw` (
  id int64,
  age int64,
  fname string,
  lname string,
  major string,
  event_time timestamp
)

--insert data to students_raw table
insert into `<project_id>.<dataset_name>.students_raw` (id, age, lname, fname, major, event_time)
values 
    (1, 20, 'Tom', 'Caipas','Computer Science', CURRENT_TIMESTAMP()),
    (2, 22, 'Kim', 'Tonny','Economics', CURRENT_TIMESTAMP()),
    (3, 20, 'Chebet', 'Lokal','Maths', CURRENT_TIMESTAMP()),
    (4, 20, 'Kibet', 'Kapel','History', CURRENT_TIMESTAMP()),
    (5, 20, 'John', 'Jones','Biology', CURRENT_TIMESTAMP());

-- update table records
update `<project_id>.<dataset_name>.students_raw`
set major ='Anthropology'
where id = 1;