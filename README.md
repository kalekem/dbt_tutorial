# dbt_tutorial

This is the code source repo used in this dbt tutorial video(s): 

Steps:
 - Clone this repo `git clone https://github.com/kalekem/dbt_tutorial.git `
 - Run the ddls to create table in BigQuery. Make sure to specify your project and dataset ids
 - Run dbt models, if you have same structure as mine then your run snapshot first then incremental model follows

 Command to Run Snapshot:
 - `dbt snapshot --select <snapshot_name> i.e dbt snapshot --select students_snapshot`

 Command To Run Incremental Model:
 - `dbt run --select <model_name> i.e dbt run --select students_base`

 Command To Refresh incremental Model:
 - `dbt run --select <model_name> --full-refresh i.e dbt run --select students_base --full-refresh

Note: You should have dbt core installed and setup to connect to BigQuery to follow the above steps successfully

### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
