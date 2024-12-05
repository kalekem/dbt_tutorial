# dbt_tutorial

Deploy Cloud Run Job:
- gcloud builds submit --config cloudbuild.yaml . 

Note: Period at the end means your cloud build file is in your current directory. This ensures that all the required files from your current directory are picked for deployment.